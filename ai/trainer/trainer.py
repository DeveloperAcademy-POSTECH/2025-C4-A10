from tqdm.auto import tqdm
import torch
import wandb
import numpy as np
from pathlib import Path
import time
import gc
from omegaconf import DictConfig
from utils.wandb_setting import wandb_setting
from utils.file_io import save_model
from torch.utils.data import Dataset, DataLoader, RandomSampler, SequentialSampler
from transformers import (
    PreTrainedModel,
    PreTrainedTokenizerBase,
)
from typing import Type, Any
import shutil


class Trainer:
    """
    훈련과정입니다.
    """

    def __init__(
        self: "Trainer",
        config: DictConfig,
        model: PreTrainedModel | torch.nn.Module,
        train_dataset: Dataset,
        val_dataset: Dataset,
        test_dataset: Dataset,
        tokenizer: Type[PreTrainedTokenizerBase],
        compute_metrics=None,
        optimizers: (
            tuple[torch.optim.Optimizer, torch.optim.lr_scheduler.LambdaLR] | None
        ) = (None, None),
        labels: list[str] | None = None,
    ):
        self.config = config

        self.model = model
        self.device = torch.device("mps")
        self._move_model_to_device()

        self.train_dataset = train_dataset
        self.val_dataset = val_dataset
        self.test_dataset = test_dataset
        self.tokenizer = tokenizer

        self.compute_metrics = compute_metrics
        self.optimizer, self.lr_scheduler = optimizers
        self.label_map = {i: label for i, label in enumerate(labels)}

        if not config.only_test:
            self.save_dir = "{save_dir}/{entity}/{project}/{group}/{experiment}".format(
                save_dir=config.save_dir,
                entity=config.wandb.entity,
                project=config.wandb.project,
                group=config.wandb.group,
                experiment=config.wandb.experiment,
            )
            Path(self.save_dir, "model").mkdir(parents=True, exist_ok=True)
            self.compute_metrics.set_save_dir(self.save_dir + "/evaluate_results")
        else:
            self.compute_metrics.set_save_dir(config.only_test + "/evaluate_results")
        self.is_wandb = wandb_setting(self.config)
        self.best_model_epoch_dir, self.val_loss_values, self.val_score_values = (
            [],
            [],
            [],
        )
        self.best_global_epoch = 1

    def loop(self: "Trainer") -> None:
        if self.config.only_test:
            self._test()
        else:
            for epoch in range(1, self.config.train.max_epoch + 1):
                standard_time = time.time()
                self._train_epoch()
                self._val_epoch(epoch)
                if self.is_wandb:
                    wandb.log(
                        {
                            "epoch": epoch,
                            "runtime(Min)": (time.time() - standard_time) / 60,
                        }
                    )
            self._test()

    def test(self: "Trainer", best_model_path: str | None = None):
        if best_model_path:
            best_model = best_model_path
        else:
            model_dir = f"save/{self.save_dir}/model"
            best_model = model_dir + Path(model_dir).glob("best*")[-1].name
        self._test(best_model)

    def _train_epoch(self: "Trainer") -> None:
        self.model.train()
        epoch_loss, steps = 0, 0
        dataloader = self._get_train_dataloader()
        pbar = tqdm(
            range(len(dataloader)),
            position=1,
            leave=False,
        )
        for step, batch in enumerate(dataloader):
            steps += 1
            inputs = {
                "input_ids": batch["input_ids"].to(self.device),
                "attention_mask": batch["attention_mask"].to(self.device),
                "token_type_ids": batch["token_type_ids"].to(self.device),
                "labels": batch["labels"].to(self.device),
            }
            outputs = self.model(**inputs)

            loss = outputs.loss
            loss.backward()
            epoch_loss += loss.clone().detach().cpu().numpy().item()

            self.optimizer.step()
            self.optimizer.zero_grad()

            pbar.update(1)
            pbar.set_postfix(
                {
                    "loss": epoch_loss / steps,
                    "lr": self.optimizer.param_groups[0]["lr"],
                }
            )
            if self.is_wandb:
                wandb.log({"train_loss": epoch_loss / steps})

        if self.lr_scheduler:
            self.lr_scheduler.step()
        pbar.close()
        clear_memory(batch, dataloader)

    def _val_epoch(self: "Trainer", epoch: int) -> None:
        val_loss, val_steps = 0, 0
        preds, golds = [], []
        dataloader = self._get_val_dataloader()
        pbar = tqdm(
            range(len(dataloader)),
            position=1,
            leave=False,
        )
        self.model.eval()
        for step, valid_batch in enumerate(dataloader):
            with torch.no_grad():
                inputs = {
                    "input_ids": valid_batch["input_ids"].to(self.device),
                    "attention_mask": valid_batch["attention_mask"].to(self.device),
                    "token_type_ids": valid_batch["token_type_ids"].to(self.device),
                    "labels": valid_batch["labels"].to(self.device),
                }

                outputs = self.model(**inputs)

            loss = outputs.loss
            logits = outputs.logits

            val_steps += 1
            val_loss += loss.clone().detach().cpu().numpy().item()
            pred_labels = logits.argmax(dim=-1).clone().detach().cpu().numpy()
            true_labels = valid_batch["labels"].clone().detach().cpu().numpy()
            preds.extend(pred_labels.tolist())
            golds.extend(true_labels.tolist())
            pbar.update(1)
            pbar.set_postfix(
                {
                    "val_loss": val_loss / val_steps,
                }
            )

        clear_memory(valid_batch, dataloader)
        pbar.close()
        val_loss /= val_steps
        scores = self.compute_metrics.evaluate(golds, preds, mode="val")

        print(f"Epoch [{epoch}/{self.config.train.max_epoch}] Val_loss :", val_loss)
        for key, value in scores.items():
            print(f"Epoch [{epoch}/{self.config.train.max_epoch}] {key} :", value)

        if self.is_wandb:
            wandb.log(
                {
                    "epoch": epoch,
                    "val_loss": val_loss,
                    "val_f1": scores["f1_score_micro"],
                }
            )
            for key, value in scores.items():
                wandb.log({"epoch": epoch, f"{key}": value})

        epoch = "0" + str(epoch) if epoch < 9 else str(epoch)
        torch.save(
            self.model.state_dict(), f"{self.save_dir}/model/epoch:{epoch}_model.pt"
        )
        print("save checkpoint!")
        # loss 기준

        self.best_model_epoch_dir.append(
            f"{self.save_dir}/model/epoch:{epoch}_model.pt"
        )
        self.val_loss_values.append(val_loss)
        self.val_score_values.append(scores["f1_score_micro"])

        best_epoch = np.array(self.val_loss_values).argmin()
        best_model_path = Path(self.best_model_epoch_dir[best_epoch])
        shutil.copyfile(
            best_model_path,
            best_model_path.with_stem(best_model_path.stem + "_best"),
        )

        if (self.config.train.max_epoch == 1) or (self.best_global_epoch < best_epoch):
            self.best_global_epoch = best_epoch
            save_model(
                self.config,
                self.config["original_filename"],
                self.model,
                self.tokenizer,
                self.save_dir,
            )

    def _test(self: "Trainer") -> None:
        self._move_model_to_device()
        self.model.eval()

        preds, golds = [], []
        dataloader = self._get_test_dataloader()
        pbar = tqdm(
            range(len(dataloader)),
            position=1,
            leave=False,
        )
        for step, test_batch in enumerate(dataloader):
            with torch.no_grad():
                inputs = {
                    "input_ids": test_batch["input_ids"].to(self.device),
                    "attention_mask": test_batch["attention_mask"].to(self.device),
                    "token_type_ids": test_batch["token_type_ids"].to(self.device),
                }

                outputs = self.model(**inputs)
            logits = outputs.logits

            pred_labels = logits.argmax(dim=-1).clone().detach().cpu().numpy()
            true_labels = test_batch["labels"].clone().detach().cpu().numpy()
            preds.extend(pred_labels.tolist())
            golds.extend(true_labels.tolist())
            pbar.update(1)

        pbar.close()

        scores = self.compute_metrics.evaluate(golds, preds, mode="test")
        if self.is_wandb:
            for key, value in scores.items():
                wandb.log({f"{key}": value})

        clear_memory(batch=test_batch, model=self.model, dataloader=dataloader)
        print("=" * 50, "Test Complete!", scores, "=" * 50, sep="\n")

    def _move_model_to_device(self: "Trainer") -> None:
        if self.model is None:
            raise ValueError("Trainer: model을 넣어주세요.")
        current_device = next(self.model.parameters()).device
        if current_device != self.device:
            self.model.to(self.device)

    def _get_train_dataloader(self: "Trainer") -> DataLoader:
        if self.train_dataset is None:
            raise ValueError("Trainer: train 데이터셋을 넣어주세요.")

        train_dataset = self.train_dataset
        batch_size = self.config.train.train_batch_size
        sampler = RandomSampler(train_dataset)

        return DataLoader(
            train_dataset,
            batch_size=batch_size,
            sampler=sampler,
        )

    def _get_val_dataloader(self: "Trainer") -> DataLoader:
        if self.val_dataset is None:
            raise ValueError("Trainer: val 데이터셋을 넣어주세요.")

        val_dataset = self.val_dataset
        batch_size = self.config.train.val_batch_size
        sampler = SequentialSampler(val_dataset)

        return DataLoader(
            val_dataset,
            batch_size=batch_size,
            sampler=sampler,
        )

    def _get_test_dataloader(self: "Trainer") -> DataLoader:
        if self.test_dataset is None:
            raise ValueError("Trainer: test 데이터셋을 넣어주세요.")

        test_dataset = self.test_dataset
        batch_size = 1
        sampler = SequentialSampler(test_dataset)

        return DataLoader(
            test_dataset,
            batch_size=batch_size,
            sampler=sampler,
        )


def clear_memory(
    batch: dict[str, Any] = None,
    model: PreTrainedModel = None,
    dataloader: DataLoader = None,
) -> None:
    if batch is not None:
        del batch
    if model is not None:
        del model
    if dataloader is not None:
        del dataloader

    torch.mps.empty_cache()
    gc.collect()
