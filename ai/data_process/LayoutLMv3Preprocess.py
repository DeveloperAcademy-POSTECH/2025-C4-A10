import torch
from datasets import load_dataset
from tqdm.auto import tqdm

class LayoutLMv3Preprocess():
    def __init__(self, tokenizer, max_seq_length=512, is_split_into_words=None):
        self.max_seq_length = max_seq_length
        self.is_split_into_words = is_split_into_words
        self.tokenizer = tokenizer
        try: # In case of LayoutLM, self.tokenizer include pad_token_label
            self.pad_token_label_id=self.tokenizer.pad_token_label
        except:
            self.pad_token_label_id=torch.nn.CrossEntropyLoss().ignore_index
    
    def convert_examples_to_features(self, examples):
        r"""
        convert exmaple data to feature data that will be used for model inputs
        :param:
            examples: column-base batched exmaple
            example = {
                'guid' str: word's id ex) train_1
                'words' List[str]: words truncated in bounding box units
                'labels' List[str]: entity label corresponding to the word,
                'boxes' List[List[int]]: normailzed bounding box ex)[25,34,54,100],
                'actual_bboxes' List[List[int]]:actual bounding box,
                'file_name' str:file_name,
                'page_size' List[int]:page_size [width, height]     
            }
        :return:
            features: column-base batched feature
            feature = {
                input_ids List[int]: token units input data 
                attention_mask List[int]: If 1, the token at the corresponding index is not a padding token
                token_type_ids List[int]: divide two sentence
                bbox List[List[int]]: token units bbox
                labels List[int]: token units labels
                image List[List[List[int]]]: pixel image
            }
        """

        features = self.tokenizer(
            text=examples['words'],
            boxes=examples['boxes'],
            word_labels=examples['labels'],
            max_length = self.max_seq_length,
            return_token_type_ids=True,
            truncation=True,
            return_overflowing_tokens=True,
            padding='max_length'
        )

        features['word_ids'] = []
        features['image'] = []
        for input_idx, seq_idx in enumerate(features.pop('overflow_to_sample_mapping')):
            word_ids = features.word_ids(input_idx)
            features['word_ids'].append(word_ids)
            features['image'].append(examples['image'][seq_idx])
            input_ids = features['input_ids'][input_idx]
            if 1437 in input_ids:
                '''
                special symbol error like "~~OPTICARE".
                Please refer to https://github.com/Ssunbell/Upstage_Visual_information_extraction/issues/4
                '''
                bbox = features['bbox'][input_idx]
                labels = features['labels'][input_idx]
                del_list = [i for i in range(len(input_ids)) if input_ids[i] == 1437]

                tuning = 0
                for i in del_list:
                    i -= tuning
                    del bbox[i]
                    bbox.append([0,0,0,0]) # padding
                    
                    del labels[i]
                    labels.append(-100)
                    
                    del input_ids[i]
                    input_ids.append(1)
                    tuning += 1

                features['bbox'][input_idx] = bbox
                features['labels'][input_idx] = labels
                features['input_ids'][input_idx] = input_ids
                
        return features