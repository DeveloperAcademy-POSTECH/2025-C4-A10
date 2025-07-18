from tqdm.auto import tqdm
from typing import *
import torch
import wandb
import numpy as np
import os
import time
import gc
from omegaconf import DictConfig
from utils import wandb_setting, check_dir
from seqeval.metrics import f1_score, precision_score, recall_score
from torch.utils.data import Dataset, DataLoader, RandomSampler, SequentialSampler
from transformers import PreTrainedModel, DataCollator, PreTrainedTokenizerBase, DataCollatorForTokenClassification, default_data_collator

class BaselineTrainer():
    """
    훈련과정입니다.
    """
    def __init__(
        self,
        config: Optional[Union[DictConfig, dict]] = None,
        model: Union[PreTrainedModel, torch.nn.Module] = None,
        train_dataset: Optional[Dataset] = None,
        val_dataset: Optional[Dataset] = None,
        test_dataset:Optional[Dataset] = None,
        data_collator: Optional[DataCollator] = None,
        tokenizer: Optional[PreTrainedTokenizerBase] = None,
        compute_metrics = None,
        optimizers: Tuple[torch.optim.Optimizer, torch.optim.lr_scheduler.LambdaLR] = (None, None),
        labels:List[str] = None
    ):
        self.config = config

        self.device = torch.device('cuda')
        self._move_model_to_device(model, self.device)
        self.model = model
        
        default_collator = default_data_collator if tokenizer is None else DataCollatorForTokenClassification(tokenizer)
        self.data_collator = data_collator if data_collator is not None else default_collator
        self.train_dataset = train_dataset
        self.val_dataset = val_dataset
        self.test_dataset = test_dataset
        self.tokenizer = tokenizer
        
        self.compute_metrics = compute_metrics
        self.optimizer, self.lr_scheduler = optimizers
        self.label_map = {i: label for i, label in enumerate(labels)}

        if not config.only_predict:
            self.save_dir = check_dir(self.config.save_dir, self.config.do_predict)
        self.compute_metrics._set_save_dir(self.save_dir if not config.only_predict else config.save_dir)
        self.is_wandb = wandb_setting(self.config)
        self.best_model_epoch_dir, self.val_loss_values, self.val_score_values = [], [], []

    def loop(self):
        for epoch in range(self.config.train.max_epoch):
            standard_time = time.time()
            self._train_epoch()
            self._eval_epoch(epoch)
            if self.is_wandb:
                wandb.log({'epoch' : epoch, 'runtime(Min)' : (time.time() - standard_time) / 60})
        del self.train_dataset, self.val_dataset
        best_model_name = self.select_best_model() if self.config.train.max_epoch > 1 else None
        if self.config.do_predict and best_model_name:
            self._predcit(best_model_name)
            
    def predict(self, best_model_path:Optional[str]=None):
        if best_model_path:
            best_model = best_model_path
        else:
            model_dir = f'save/{self.save_dir}'
            best_model = model_dir + [model for model in os.listdir(model_dir) if 'best' in model][-1]
        self._predcit(best_model)
    
    def _train_epoch(self):
        gc.collect()
        self.model.train()
        epoch_loss, steps = 0, 0
        for batch in (pbar:=tqdm(self._get_train_dataloader())):
            self.optimizer.zero_grad()
            steps += 1
            inputs = {
                    'input_ids': batch['input_ids'].to(self.device),
                    'attention_mask': batch['attention_mask'].to(self.device),
                    'token_type_ids': batch['token_type_ids'].to(self.device),
                    'labels':batch['labels'].to(self.device)
                }
            if 'layoutlmv2' in self.config.model.model_name: # image and bbox
                inputs = self._layoutlmv2_input(inputs, batch)
            elif 'layoutlmv3' in self.config.model.model_name:# image and bbox
                inputs = self._layoutlmv3_input(inputs, batch)
            elif 'layoutlm' in self.config.model.model_name: # bbox
                inputs = self._layoutlm_input(inputs, batch)
                
            outputs = self.model(**inputs)
            
            loss = outputs[0]
            loss.backward()
            epoch_loss += loss.clone().detach().cpu().numpy().item()
            
            self.optimizer.step()
            
            pbar.set_postfix({
                'loss' : epoch_loss / steps,
                'lr' : self.optimizer.param_groups[0]['lr'],
            })
            if self.is_wandb:
                wandb.log({'train_loss':epoch_loss/steps})

        if self.lr_scheduler:
            self.lr_scheduler.step()
        pbar.close()

    def _eval_epoch(self, epoch:int):
        val_loss, val_steps = 0, 0
        words_ids = []
        preds, true_label_ids = np.empty((1,self.config.train.max_length)), np.empty((1,self.config.train.max_length))
        self.model.eval()
        for valid_batch in (pbar:=tqdm(self._get_val_dataloader())):
            with torch.no_grad():
                inputs = {
                        'input_ids': valid_batch['input_ids'].to(self.device),
                        'attention_mask': valid_batch['attention_mask'].to(self.device),
                        'token_type_ids': valid_batch['token_type_ids'].to(self.device),
                        'labels':valid_batch['labels'].to(self.device)
                    }
                if 'layoutlmv2' in self.config.model.model_name: # image and bbox
                    inputs = self._layoutlmv2_input(inputs, valid_batch)
                elif 'layoutlmv3' in self.config.model.model_name:# image and bbox
                    inputs = self._layoutlmv3_input(inputs, valid_batch)
                elif 'layoutlm' in self.config.model.model_name: # bbox
                    inputs = self._layoutlm_input(inputs, valid_batch)

                outputs = self.model(**inputs)
                
            loss, logits = outputs

            val_steps += 1
            val_loss += loss.clone().detach().cpu().numpy().item()
            preds = np.append(preds, logits.argmax(dim=-1).clone().detach().cpu().numpy(), axis=0)
            true_label_ids = np.append(true_label_ids, inputs["labels"].clone().detach().cpu().numpy(), axis=0)
            words_ids.append(valid_batch['word_ids'].tolist())
            
        pbar.close()
        preds = np.delete(preds, 0, axis=0)
        true_label_ids = np.delete(true_label_ids, 0, axis=0)
        words_ids = sum(words_ids,[])
        val_loss /= val_steps
        
        scores = self.compute_metrics.valid_eval(preds, true_label_ids, words_ids)
        
        print(f"Epoch [{epoch+1}/{self.config.train.max_epoch}] Val_loss :", val_loss)
        for key, value in scores.items():
            print(f"Epoch [{epoch+1}/{self.config.train.max_epoch}] {key} :", value)
        
        if self.is_wandb:
            wandb.log({'epoch' : epoch+1, 'val_loss' : val_loss})
            for key, value in scores.items():
                wandb.log({'epoch' : epoch+1, f'{key}' : value})
            
        epoch = '0' + str(epoch+1) if epoch < 9 else epoch + 1
        torch.save(self.model.state_dict(), f'save/{self.save_dir}/epoch:{epoch}_model.pt')
        print('save checkpoint!')

        self.best_model_epoch_dir.append(f'save/{self.save_dir}/epoch:{epoch}_model.pt')
        self.val_loss_values.append(val_loss)
        self.val_score_values.append(scores['val_f1'])

    def _predcit(self, best_model_name:str):
        checkpoint = torch.load(best_model_name)
        self.model.load_state_dict(checkpoint)
        self._move_model_to_device(self.model, self.device)
        self.model.eval()
        
        words_ids = []
        preds, true_label_ids = np.empty((1,self.config.train.max_length)), np.empty((1,self.config.train.max_length))
        for test_batch in ((pbar:=tqdm(self._get_test_dataloader()))):
            with torch.no_grad():
                inputs = {
                        'input_ids': test_batch['input_ids'].to(self.device),
                        'attention_mask': test_batch['attention_mask'].to(self.device),
                        'token_type_ids': test_batch['token_type_ids'].to(self.device),
                    }
                if 'layoutlmv2' in self.config.model.model_name: # image and bbox
                    inputs = self._layoutlmv2_input(inputs, test_batch)
                elif 'layoutlmv3' in self.config.model.model_name:# image and bbox
                    inputs = self._layoutlmv3_input(inputs, test_batch)
                elif 'layoutlm' in self.config.model.model_name: # bbox
                    inputs = self._layoutlm_input(inputs, test_batch)
                    
                outputs = self.model(**inputs)
            logits = outputs[0]

            words_ids.append(test_batch['word_ids'].tolist())
            preds = np.append(preds, logits.argmax(dim=-1).clone().detach().cpu().numpy(), axis=0)
            true_label_ids = np.append(true_label_ids, test_batch["labels"].numpy(), axis=0)
        
        pbar.close()
        preds = np.delete(preds, 0, axis=0)
        true_label_ids = np.delete(true_label_ids, 0, axis=0)
        words_ids = sum(words_ids,[])

        scores = self.compute_metrics.test_eval(preds, true_label_ids, words_ids)
        if self.is_wandb:
            for key, value in scores.items():
                wandb.log({f'{key}' : value})
        print('='*50, 'Inference Complete!', scores, '='*50, sep='\n')
        
    def _move_model_to_device(self, model, device):
        model = model.to(device)
        
    def _layoutlm_input(self, inputs:dict, batch:dict):
        inputs['bbox'] = batch["bbox"].to(self.device)
        
        return inputs
    
    def _layoutlmv2_input(self, inputs:dict, batch:dict):
        inputs['bbox'] = batch["bbox"].to(self.device)
        inputs['image'] = batch["image"].to(self.device)
    
        return inputs
    
    def _layoutlmv3_input(self, inputs:dict, batch:dict):
        inputs['bbox'] = batch["bbox"].to(self.device)
        inputs['image'] = batch["image"].type(torch.FloatTensor).to(self.device)
    
        return inputs

    def _get_train_dataloader(self) -> DataLoader:
        if self.train_dataset is None:
            raise ValueError("Trainer: train 데이터셋을 넣어주세요.")
        
        train_dataset = self.train_dataset
        batch_size = self.config.train.batch_size
        sampler = RandomSampler(train_dataset)
        collate_fn = self.data_collator

        return DataLoader(
            train_dataset,
            batch_size=batch_size,
            sampler=sampler,
            collate_fn=collate_fn,
            pin_memory=True,
            num_workers=self.config.train.num_workers
        )
        
    def _get_val_dataloader(self) -> DataLoader:
        if self.val_dataset is None:
            raise ValueError("Trainer: val 데이터셋을 넣어주세요.")
        
        val_dataset = self.val_dataset
        batch_size = self.config.train.batch_size
        sampler = SequentialSampler(val_dataset)
        collate_fn = self.data_collator

        return DataLoader(
            val_dataset,
            batch_size=batch_size,
            sampler=sampler,
            collate_fn=collate_fn,
            pin_memory=True,
            num_workers=self.config.train.num_workers
        )

    def _get_test_dataloader(self) -> DataLoader:
        if self.test_dataset is None:
            raise ValueError("Trainer: test 데이터셋을 넣어주세요.")
        
        test_dataset = self.test_dataset
        batch_size = self.config.train.test_batch_size
        sampler = SequentialSampler(test_dataset)
        collate_fn = self.data_collator

        return DataLoader(
            test_dataset,
            batch_size=batch_size,
            sampler=sampler,
            collate_fn=collate_fn,
            pin_memory=True,
            num_workers=self.config.train.num_workers
        )

    def select_best_model(self):
        # loss 기준
        best_model = self.best_model_epoch_dir[np.array(self.val_loss_values).argmin()]
        # score 기준
        # best_model = self.best_model_epoch_dir[np.array(self.val_score_values).argmax()]
        os.rename(best_model, best_model.split('.pt')[0] + '_best.pt')
        
        return best_model.split('.pt')[0] + '_best.pt'