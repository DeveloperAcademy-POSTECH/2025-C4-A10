import torch
from datasets import load_dataset

class BaselinePreprocess():
    def __init__(self, tokenizer, max_seq_length=512, is_split_into_words=None):
        self.max_seq_length = max_seq_length
        self.is_split_into_words = is_split_into_words
        self.tokenizer = tokenizer
        self.cls_token_box=[0, 0, 0, 0]
        self.sep_token_box=[1000, 1000, 1000, 1000]
        self.pad_token_box=[0, 0, 0, 0]
        self.cls_token = tokenizer.cls_token
        self.sep_token = tokenizer.sep_token
        self.pad_token = tokenizer.pad_token
        self.unk_token = tokenizer.unk_token
        self.special_token_map = {
            self.tokenizer(special, add_special_tokens=False)['input_ids'][0]:special
                             for special in self.tokenizer.special_tokens_map.values()
            }
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
            }
        """
        features = self.tokenizer(
            examples['words'],
            max_length = self.max_seq_length,
            return_token_type_ids=True,
            return_overflowing_tokens=True,
            truncation=True,
            is_split_into_words=self.is_split_into_words,
            padding='max_length'
        )
        
        features['bbox'] = []
        features['labels'] = []
        features['word_ids'] = []
        if self.add_image_data:
            features['image'] = []
        for input_idx, seq_idx in enumerate(features.pop('overflow_to_sample_mapping')):
            # referenced by features
            input_ids = features['input_ids'][input_idx]
            word_ids = features.word_ids(input_idx)
            features['word_ids'].append(word_ids)
            
            # reference by exmaples
            if self.add_image_data:
                features['image'].append(self.image_data[examples['file_name'][seq_idx]])
            boxes = examples['boxes'][seq_idx]
            labels = examples['labels'][seq_idx]

            label_ids = []
            bbox = []
            last_word_index = -1
            for token_idx, token_id in enumerate(input_ids):
                word_idx = word_ids[token_idx] # example word
                if isinstance(word_idx, type(None)): # if example word is None, that is special token
                    
                    if self.special_token_map[token_id] == self.cls_token:
                        label_ids.append(self.pad_token_label_id)
                        bbox.append(self.cls_token_box)
                        
                    elif self.special_token_map[token_id] == self.sep_token:
                        label_ids.append(self.pad_token_label_id)
                        bbox.append(self.sep_token_box)
                        
                    elif self.special_token_map[token_id] == self.pad_token:
                        label_ids.append(self.pad_token_label_id)
                        bbox.append(self.pad_token_box)
                        
                    else: # UNK features or MASK token
                        print('UNK token exist')
                        if self.is_split_into_words: # sequence units
                            bbox.append(boxes[word_idx])
                            if word_idx != last_word_index:
                                label_ids.append(labels[word_idx])
                                last_word_index = word_idx
                            else:
                                label_ids.append(self.pad_token_label_id)
                        else:
                            bbox.append(boxes[0]) # token units
                            if word_idx != last_word_index:
                                label_ids.append(labels[0])
                                last_word_index = (word_idx + 1)
                            else:
                                label_ids.append(self.pad_token_label_id)
                                last_word_index += 1
                else:
                    if self.is_split_into_words: # sequence units
                        bbox.append(boxes[word_idx])
                        if word_idx != last_word_index:
                            label_ids.append(labels[word_idx])
                            last_word_index = word_idx
                        else:
                            label_ids.append(self.pad_token_label_id)
                    else:
                        bbox.append(boxes[0]) # token units
                        if word_idx != last_word_index:
                            label_ids.append(labels[0])
                            last_word_index = (word_idx + 1)
                        else:
                            label_ids.append(self.pad_token_label_id)
                            last_word_index += 1
                        
            features['bbox'].append(bbox)
            features['labels'].append(label_ids)
            
        return features