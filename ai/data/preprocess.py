from utils.constants import Input
from typing import Type, Literal
from transformers import PreTrainedTokenizer
from utils.constants import SequenceClassificationInputBatch
import torch


class SequenceClassificationPreprocessor:
    def __init__(
        self: "SequenceClassificationPreprocessor",
        tokenizer: Type[PreTrainedTokenizer],
        labels: list[str],
        max_seq_length: int = 512,
        padding: Literal["max_length"] | bool = "max_length",
        padding_side: Literal["left", "right"] = "right",
        ignore_id: int = -100,
        mode: Literal["train", "val", "test", "infer"] = "test",
    ):
        self.tokenizer = tokenizer
        self.labels = labels
        self.max_seq_length = max_seq_length
        self.padding = padding
        self.padding_side = padding_side
        self.ignore_id = ignore_id
        self.mode = mode

    def preprocess(
        self: "SequenceClassificationPreprocessor",
        input: Input,
    ) -> SequenceClassificationInputBatch:
        assert input is not None and len(input) > 0, ValueError(
            "input is None or empty\nPlease check the data"
        )

        if self.mode in ["train", "val", "test"]:
            assert input["label"] is not None, ValueError(
                "label is None\nPlease check the data"
            )
            return self._preprocess(input)
        elif self.mode == "infer":
            return self._inference(input)
        else:
            raise ValueError(f"Invalid mode : {self.mode}")

    def _preprocess(
        self: "SequenceClassificationPreprocessor",
        input: Input,
    ) -> SequenceClassificationInputBatch:
        batch = self.tokenizer.encode_plus(
            input["text"],
            max_length=self.max_seq_length,
            padding=self.padding,
            padding_side=self.padding_side,
            truncation=True,
            return_attention_mask=True,
            return_token_type_ids=True,
            return_tensors="pt",
        )
        batch = {k: v.squeeze() for k, v in batch.items()}
        batch["labels"] = torch.tensor(
            input["label"],
            dtype=torch.long,
        ).unsqueeze(0)
        batch["original_texts"] = input["text"]
        batch["label_texts"] = self.labels[input["label"]]
        batch["ids"] = input["id"] if isinstance(input["id"], int) else int(input["id"])

        return batch

    def _inference(
        self: "SequenceClassificationPreprocessor",
        input: Input,
    ) -> SequenceClassificationInputBatch:
        batch = self.tokenizer.encode_plus(
            input["text"],
            max_length=self.max_seq_length,
            padding=self.padding,
            padding_side=self.padding_side,
            truncation=True,
            return_attention_mask=True,
            return_token_type_ids=True,
            return_tensors="pt",
        )
        batch = {k: v.squeeze() for k, v in batch.items()}
        batch["original_texts"] = input["text"]
        batch["ids"] = input["id"] if isinstance(input["id"], int) else int(input["id"])

        return batch


if __name__ == "__main__":
    # command : python -m data.preprocess
    from transformers import AutoTokenizer

    labels = ["긍정", "부정"]

    tokenizer = AutoTokenizer.from_pretrained("bert-base-uncased")
    preprocessor = SequenceClassificationPreprocessor(
        tokenizer=tokenizer,
        labels=labels,
        max_seq_length=128,
        padding="max_length",
        padding_side="right",
        ignore_id=-100,
        mode="train",
    )

    input: Input = Input(text="It's sunny today!", label=0, id=1)
    print(input)

    batch = preprocessor.preprocess(input)

    print(batch)
