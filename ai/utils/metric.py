from typing import *
import collections
import datasets
from glob import glob
from seqeval.metrics import f1_score, precision_score, recall_score
import string
import os
import json
import csv
import re

class BaselineMetrics():
    def __init__(
        self,
        test_data:datasets.arrow_dataset.Dataset=None,
        labels:List[str]=None,
        data_dir:str='data/',
        is_sequence:bool=False,
    ):
        self.label_map = {i: label for i, label in enumerate(labels)}
        self.data_dir = data_dir
        self.test_example = test_data
        self.test_ground_truths = self._read_ground_truths(data_dir + "test/entities/*", mode='test')
        self.is_sequence = is_sequence
            
    def _set_save_dir(self, save_dir):
        self.save_dir = 'save/' + save_dir
        print('='*50, f'output 저장 경로는 {self.save_dir} 입니다.' , '='*50, sep='\n\n')
    
    def valid_eval(self, preds, true_label_ids, words_ids):
        preds_list, out_label_list = self._arrange_pred_gt_labels(preds, true_label_ids, words_ids)
        results = {
            "val_f1": f1_score(out_label_list, preds_list),
            "val_precision": precision_score(out_label_list, preds_list),
            "val_recall": recall_score(out_label_list, preds_list),
        }

        return results
        
    def test_eval(self, preds, true_label_ids, words_ids):
        gt_parses = self.test_ground_truths
        preds_list,_ = self._arrange_pred_gt_labels(preds, true_label_ids, words_ids)
        self._make_output_csv_file(preds_list)
        pr_parses = self._gen_pr_parsers_from_csv()
        
        return self._evaluation(pr_parses, gt_parses)
        
    def _read_ground_truths(self, data_files: Union[str, List[str]], mode='train'):
        gt_parses = {}
        if isinstance(data_files, str): # 전체 싸악 긁어오기 
            for file_name in glob(data_files):
                with open(file_name, "r") as f:
                    data = json.load(f)
                file_name = os.path.splitext(os.path.basename(file_name))[0]
                gt_parses[file_name] = data
        else:
            for file_name in data_files: # 원하는 파일만 긁어오기
                with open(self.data_dir+f'{mode}/entities/{file_name}.txt', "r") as f:
                    data = json.load(f)
                file_name = os.path.splitext(os.path.basename(file_name))[0]
                gt_parses[file_name] = data
                
        return gt_parses
    
    def _arrange_pred_gt_labels(self, preds, true_label_ids, words_ids):
        preds_list = [[] for _ in range(true_label_ids.shape[0])]
        out_label_list = [[] for _ in range(true_label_ids.shape[0])]
        
        # postprocess
        start_word_id, last_word_id = 0, 511
        for i in range(true_label_ids.shape[0]):
            word_ids = words_ids[i]
            start_idx = 0
            while word_ids[start_idx] < -1:
                start_idx += 1
            start_word_id = word_ids[start_idx]
            if (
                start_word_id == last_word_id and
                true_label_ids[i][start_idx] != -100 and
                self.label_map[true_label_ids[i][start_idx]] == preds_list[i-1][-1]
            ): # 오버플로우로 인해 짤린 두 시퀀스의 마지막 토큰과 첫번째 토큰이 동일한 단어인지 판별
                next_idx = 1
                while start_word_id == word_ids[start_idx+next_idx]:
                    next_idx += 1
                seq_length = range(start_idx+next_idx, true_label_ids.shape[1]) # 해당 토큰 건너뛰기
            else:
                seq_length = range(true_label_ids.shape[1])
                
            for j in seq_length:
                if true_label_ids[i, j] != -100:

                    out_label_list[i].append(self.label_map[true_label_ids[i][j]])
                    preds_list[i].append(self.label_map[preds[i][j]])
                    
                    last_word_id = word_ids[j]

        return preds_list, out_label_list
        
    def _make_output_csv_file(self, preds_list):
        output_test_predictions_file = os.path.join(self.save_dir, f"output.csv")
        with open(output_test_predictions_file, "w", encoding="utf8") as writer:
            csv_writer = csv.writer(writer, lineterminator='\n')
            if self.is_sequence:
                rows = []
                for words, file_name in zip(self.test_example['words'], self.test_example['file_name']):
                    for word in words:
                        rows.append([word, 0, file_name])
                
                idx = 0
                for preds in preds_list:
                    for pred in preds:
                        try:
                            output_line = rows[idx]
                            output_line[1] = pred
                            csv_writer.writerow(output_line)
                            idx += 1
                        except:
                            print(pred)
                            
            else:                
                words = self.test_example['words']
                file_names = self.test_example['file_name']
                for word, pred, file_name in zip(words, preds_list, file_names):
                    output_line = [word, pred[0], file_name]
                    csv_writer.writerow(output_line)
    
    def _gen_pr_parsers_from_csv(self):
        with open(self.save_dir+"/output.csv", "r", encoding="utf-8") as f:
            pr_parses = {}
            for text, pred_label, file_name in csv.reader(f):
                if file_name not in pr_parses:
                    pr_parses[file_name] = {"company": [], "date": [], "address": [], "total": []}
                if pred_label == 'O':
                    continue
            
                if pred_label == "S-COMPANY":
                    pred_label = "company"
                elif pred_label == "S-DATE":
                    pred_label = "date"
                elif pred_label == "S-ADDRESS":
                    pred_label = "address"
                elif pred_label == "S-TOTAL":
                    pred_label = "total"
                pr_parses[file_name][pred_label].append(text)

            for (file_name, pr_parse) in pr_parses.items():
                for (pred_label, value) in pr_parse.items():
                    pr_parse[pred_label] = " ".join(value)
        
        return pr_parses

    def _evaluation(self, pr_parses, gt_parses):
        assert len(gt_parses) == len(pr_parses)
        parses = collections.defaultdict(lambda: {"gold": dict, "infer": dict})
        f1 = exact_match = exact_match_no_space = total = 0
        entity_score_per_entity = collections.defaultdict(
            lambda: {
                "entity_em": 0.0,
                "entity_em_no_space": 0.0,
                "entity_f1": 0.0,
            }
        )
        total_per_entity = collections.defaultdict(int)

        filenames = list(gt_parses.keys())
        for file_name in filenames:
            gt_parse = gt_parses[file_name]
            pr_parse = pr_parses[file_name]

            for key in gt_parse:
                total += 1
                total_per_entity[key] += 1
                ground_truths = " ".join(gt_parse[key])
                try:
                    prediction = " ".join(pr_parse[key])
                except KeyError:
                    prediction = ""
                
                parses[file_name][key] = {"gold": ground_truths, "infer": prediction}
                exact_match += self._exact_match_score(prediction, ground_truths)
                f1 += self._get_char_level_f1_score(prediction, ground_truths)
                exact_match_no_space += self._exact_match_score(
                    prediction, ground_truths, remove_whitespace=True
                )

                entity_score_per_entity[key]["entity_em"] += self._exact_match_score(
                    prediction, ground_truths
                )
                entity_score_per_entity[key]["entity_em_no_space"] += self._exact_match_score(
                    prediction, ground_truths, remove_whitespace=True
                )
                entity_score_per_entity[key]["entity_f1"] += self._get_char_level_f1_score(
                    prediction, ground_truths
                )

        exact_match = 100.0 * exact_match / total
        f1 = 100.0 * f1 / total
        exact_match_no_space = 100.0 * exact_match_no_space / total

        # get entity score per entities
        assert len(entity_score_per_entity.keys()) == len(total_per_entity.keys())
        for key in entity_score_per_entity:
            entity_score_per_entity[key]["entity_em"] = (
                100.0 * entity_score_per_entity[key]["entity_em"] / total_per_entity[key]
            )
            entity_score_per_entity[key]["entity_f1"] = (
                100.0 * entity_score_per_entity[key]["entity_f1"] / total_per_entity[key]
            )
            entity_score_per_entity[key]["entity_em_no_space"] = (
                100.0 * entity_score_per_entity[key]["entity_em_no_space"] / total_per_entity[key]
            )

        result = {
            'f1': f1,
            "em" : exact_match,
            "em_no_space": exact_match_no_space,
        }

        return result
    
    def _normalize_answer(self, text:str, remove_whitespace: bool = False):
        def remove_(text):
            """불필요한 기호 제거"""
            text = re.sub("'", " ", text)
            text = re.sub('"', " ", text)
            text = re.sub("《", " ", text)
            text = re.sub("》", " ", text)
            text = re.sub("<", " ", text)
            text = re.sub(">", " ", text)
            text = re.sub("〈", " ", text)
            text = re.sub("〉", " ", text)
            text = re.sub("\(", " ", text)
            text = re.sub("\)", " ", text)
            text = re.sub("‘", " ", text)
            text = re.sub("’", " ", text)
            return text

        def white_space_fix(text):
            return " ".join(text.split())

        def white_space_remove(text):
            return "".join(text.split())

        def remove_punc(text):
            exclude = set(string.punctuation)
            return "".join(ch for ch in text if ch not in exclude)

        def lower(text):
            return text.lower()

        if remove_whitespace:
            return white_space_remove(remove_punc(lower(remove_(text))))
        else:
            return white_space_fix(remove_punc(lower(remove_(text))))


    def _get_char_level_f1_score(self, prediction:str, ground_truth:str, remove_whitespace: bool = False):
        prediction_tokens = self._normalize_answer(prediction, remove_whitespace).split()
        ground_truth_tokens = self._normalize_answer(ground_truth, remove_whitespace).split()

        # F1 by character
        prediction_Char = []
        for tok in prediction_tokens:
            now = [a for a in tok]
            prediction_Char.extend(now)

        ground_truth_Char = []
        for tok in ground_truth_tokens:
            now = [a for a in tok]
            ground_truth_Char.extend(now)

        common = collections.Counter(prediction_Char) & collections.Counter(ground_truth_Char)
        num_same = sum(common.values())
        if num_same == 0:
            return 0

        precision = 1.0 * num_same / len(prediction_Char)
        recall = 1.0 * num_same / len(ground_truth_Char)
        f1 = (2 * precision * recall) / (precision + recall)

        return f1


    def _exact_match_score(self, prediction, ground_truth, remove_whitespace: bool = False):
        pred = self._normalize_answer(prediction, remove_whitespace)
        gt = self._normalize_answer(ground_truth, remove_whitespace)
        
        return pred == gt
    
    # def _gen_pr_parsers(self, preds_list, examples):
    #     words = examples['words']
    #     file_names = examples['file_name']
    #     pr_parses = {
    #         file_name : {"company": [], "date": [], "address": [], "total": []}
    #         for file_name in file_names
    #     }
    #     for word, pred, file_name in zip(words, preds_list, file_names):
    #         if pred[0] == "O":
    #             continue
    #         if pred[0] == "S-COMPANY":
    #             pred_label = "company"
    #         elif pred[0] == "S-DATE":
    #             pred_label = "date"
    #         elif pred[0] == "S-ADDRESS":
    #             pred_label = "address"
    #         elif pred[0] == "S-TOTAL":
    #             pred_label = "total"
    #         pr_parses[file_name][pred_label].append(word)
        
    #     for (file_name, pr_parse) in pr_parses.items():
    #         for (pred_label, value) in pr_parse.items():
    #             pr_parse[pred_label] = " ".join(value)
                
    #     return pr_parses