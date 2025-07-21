from pathlib import Path
from typing import Literal, Dict, Any
import json
import numpy as np
from datetime import datetime
import torch


class Evaluator:
    """평가 결과 저장 폴더 생성/중복 처리"""

    def __init__(
        self: "Evaluator",
        labels: list[str],
        save_dir: str = "evaluate_results",
    ):
        self.labels: dict[int, str] = {i: label for i, label in enumerate(labels)}

    def evaluate(
        self: "Evaluator",
        golds: np.ndarray | list,
        preds: np.ndarray | list,
        texts: list[str],
        ids: list[int | str | torch.Tensor] | None,
        mode: Literal["valid", "test"] = "test",
    ) -> dict[str, float]:
        """split에 맞춰 valid_eval / test_eval 호출"""
        assert len(golds) == len(preds), ValueError(
            f"Length of golds and preds must be the same\ngolds: {len(golds)}\npreds: {len(preds)}"
        )
        assert None not in golds, ValueError("None value is not allowed in golds")
        assert None not in preds, ValueError("None value is not allowed in preds")
        if isinstance(golds, list):
            golds = np.array(golds)
        if isinstance(preds, list):
            preds = np.array(preds)

        results = self._eval(golds, preds, texts, ids)
        with open(self.save_dir / f"{mode}_evaluate_results.json", "w") as f:
            json.dump(results, f, indent=4, ensure_ascii=False)
        return results

    def _eval(
        self: "Evaluator",
        golds: np.ndarray,
        preds: np.ndarray,
        texts: list[str],
        ids: list[int | str | torch.Tensor] | None,
    ) -> Dict[str, Any]:
        # Custom accuracy calculation
        total_samples = len(golds)
        incorrect_ids = []
        correct_count = 0

        # Compare predictions with gold labels and track incorrect IDs
        for i in range(total_samples):
            if golds[i] == preds[i]:
                correct_count += 1
            else:
                if isinstance(ids[i], torch.Tensor) or isinstance(ids[i], np.ndarray):
                    id = ids[i].item()
                elif isinstance(ids[i], str):
                    id = str(ids[i])
                else:
                    id = ids[i]
                text = texts[i]
                gold_label = int(golds[i])
                pred_label = int(preds[i])
                gold_label_name = self.labels.get(int(gold_label), "")
                pred_label_name = self.labels.get(int(pred_label), "")

                row = {
                    "index": i,
                    "id": id,
                    "text": text,
                    "gold_label": gold_label,
                    "gold_label_name": gold_label_name,
                    "pred_label": pred_label,
                    "pred_label_name": pred_label_name,
                }
                incorrect_ids.append(row)

        # Calculate accuracy
        accuracy = correct_count / total_samples if total_samples > 0 else 0.0

        return {
            "accuracy": accuracy,
            "total_samples": total_samples,
            "incorrect_count": len(incorrect_ids),
            "correct_count": correct_count,
            "incorrect_predictions": incorrect_ids,
        }

    def set_save_dir(self: "Evaluator", save_dir: str) -> None:
        """평가 결과 저장 폴더 생성/중복 처리"""
        base = Path(save_dir)
        if not base.exists():
            base.mkdir(parents=True)
            self.save_dir = base
            return

        # 이미 존재할 경우 → 비어 있으면 그대로, 아니면 뒤에 _1, _2 …
        if any(base.iterdir()):
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            base = base.parent / f"{base.name}_{timestamp}"
            base.mkdir(parents=True)

        self.save_dir = base


if __name__ == "__main__":
    evaluator = Evaluator(labels=["O", "B", "I"])
    golds = np.array([0, 1, 2, 0, 1, 2])
    preds = np.array([0, 2, 1, 1, 2, 1])
    evaluator.evaluate(
        golds,
        preds,
        texts=["text1", "text2", "text3", "text4", "text5", "text6"],
        ids=[1, 2, 3, 4, 5, 6],
    )
