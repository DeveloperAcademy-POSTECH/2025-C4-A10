from utils.constants import TextInput
from typing import Type, Literal
from transformers import PreTrainedTokenizer
from utils.constants import Tensor1D, Sequence
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
        mode: Literal["train", "val", "test"] = "test",
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
        text_input: TextInput,
    ) -> dict[
        Literal[
            "input_ids",
            "attention_mask",
            "token_type_ids",
            "label_texts",
            "labels",
        ],
        Tensor1D[Sequence],
    ]:
        assert text_input is not None and len(text_input) > 0, ValueError(
            "text_input is None or empty\nPlease check the data"
        )

        if self.mode == "test":
            return self._test_preprocess(text_input)
        elif self.mode in ["train", "val"]:
            assert text_input["label"] is not None, ValueError(
                "label is None\nPlease check the data"
            )
            return self._train_preprocess(text_input)

    def _test_preprocess(
        self: "SequenceClassificationPreprocessor",
        text_input: TextInput,
    ) -> dict[
        Literal[
            "input_ids",
            "attention_mask",
            "token_type_ids",
            "label_texts",
        ],
        Tensor1D[Sequence],
    ]:
        batch = self.tokenizer.encode_plus(
            text_input["text"],
            max_length=self.max_seq_length,
            padding=self.padding,
            padding_side=self.padding_side,
            truncation=True,
            return_attention_mask=True,
            return_token_type_ids=True,
            return_tensors="pt",
        )
        batch = {k: v.squeeze() for k, v in batch.items()}
        batch["label_texts"] = text_input["label"]

        return batch

    def _train_preprocess(
        self: "SequenceClassificationPreprocessor",
        text_input: TextInput,
    ) -> dict[
        Literal[
            "input_ids",
            "attention_mask",
            "token_type_ids",
            "label_texts",
            "labels",
        ],
        Tensor1D[Sequence],
    ]:
        batch = self.tokenizer.encode_plus(
            text_input["text"],
            max_length=self.max_seq_length,
            padding=self.padding,
            padding_side=self.padding_side,
            truncation=True,
            return_attention_mask=True,
            return_token_type_ids=True,
            return_tensors="pt",
        )
        batch = {k: v.squeeze() for k, v in batch.items()}
        batch["label_texts"] = text_input["label"]
        batch["labels"] = torch.tensor(
            self.labels.index(text_input["label"]),
            dtype=torch.long,
        ).unsqueeze(0)

        return batch


if __name__ == "__main__":
    # command : python -m ai.data.preprocess
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

    text_input: TextInput = TextInput(text="It's sunny today!", label="긍정")
    print(text_input)

    batch = preprocessor.preprocess(text_input)

    print(batch)
