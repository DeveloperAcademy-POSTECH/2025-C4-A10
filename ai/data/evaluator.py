from pathlib import Path
from typing import Literal
import json
import numpy as np
from sklearn.metrics import precision_score, recall_score, f1_score, accuracy_score


class Evaluator:
    """평가 결과 저장 폴더 생성/중복 처리"""

    def __init__(
        self: "Evaluator",
        labels: list[str],
        save_dir: str = "evaluate_results",
        data_dir: str = "data/",
    ):
        self.save_dir = self._set_save_dir(save_dir)
        self.labels: dict[int, str] = {i: label for i, label in enumerate(labels)}
        self.data_dir: str = data_dir

    def evaluate(
        self: "Evaluator",
        golds: np.ndarray,
        preds: np.ndarray,
        split: Literal["valid", "test"] = "test",
    ) -> dict[str, float]:
        """split에 맞춰 valid_eval / test_eval 호출"""
        assert len(golds) == len(preds), ValueError(
            f"Length of golds and preds must be the same\ngolds: {len(golds)}\npreds: {len(preds)}"
        )
        assert None not in golds, ValueError("None value is not allowed in golds")
        assert None not in preds, ValueError("None value is not allowed in preds")

        results = self._eval(preds, golds)
        with open(self.save_dir / f"{split}_evaluate_results.json", "w") as f:
            json.dump(results, f, indent=4, ensure_ascii=False)
        return results

    def _eval(
        self: "Evaluator",
        golds: np.ndarray,
        preds: np.ndarray,
    ) -> dict[str, float]:
        return {
            "accuracy": accuracy_score(golds, preds),
            "f1_score_micro": f1_score(golds, preds, average="micro"),
            "precision_micro": precision_score(golds, preds, average="micro"),
            "recall_micro": recall_score(golds, preds, average="micro"),
            "f1_score_macro": f1_score(golds, preds, average="macro"),
            "precision_macro": precision_score(golds, preds, average="macro"),
            "recall_macro": recall_score(golds, preds, average="macro"),
            "f1_score_weighted": f1_score(golds, preds, average="weighted"),
            "precision_weighted": precision_score(golds, preds, average="weighted"),
            "recall_weighted": recall_score(golds, preds, average="weighted"),
        }

    @staticmethod
    def _set_save_dir(save_dir: str) -> Path:
        """평가 결과 저장 폴더 생성/중복 처리"""
        base = Path(save_dir)
        if not base.exists():
            base.mkdir(parents=True)
            return base

        # 이미 존재할 경우 → 비어 있으면 그대로, 아니면 뒤에 _1, _2 …
        if any(base.iterdir()):
            i = 1
            while Path(f"{base.name}_{i}").exists():
                i += 1
            base = Path(f"{base.name}_{i}")
            base.mkdir(parents=True)

        return base


if __name__ == "__main__":
    evaluator = Evaluator(labels=["O", "B", "I"])
    golds = np.array([0, 1, 2, 0, 1, 2])
    preds = np.array([0, 2, 1, 1, 2, 1])
    evaluator.evaluate(golds, preds)
