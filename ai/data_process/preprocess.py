from utils.constants import TextInputBatch
from typing import Type, Literal
from transformers import PreTrainedTokenizer
from utils.constants import Tensor2D, Batch, Sequence
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
        text_input_batch: TextInputBatch,
    ) -> tuple[dict[str, Tensor2D[Batch, Sequence]], TextInputBatch]:
        assert text_input_batch is not None, ValueError(
            "text_input_batch is None\nPlease check the data"
        )

        if self.mode == "test":
            return self._test_preprocess(text_input_batch)
        elif self.mode in ["train", "val"]:
            assert all([label is not None for label in text_input_batch["labels"]]), (
                ValueError("labels contains None\nPlease check the data")
            )
            return self._train_preprocess(text_input_batch)

    def _test_preprocess(
        self: "SequenceClassificationPreprocessor",
        text_input_batch: TextInputBatch,
    ) -> tuple[dict[str, Tensor2D[Batch, Sequence]], TextInputBatch]:
        batch = self.tokenizer.batch_encode_plus(
            text_input_batch["texts"],
            max_length=self.max_seq_length,
            padding=self.padding,
            padding_side=self.padding_side,
            truncation=True,
            return_attention_mask=True,
            return_token_type_ids=True,
            return_tensors="pt",
        )

        return batch, text_input_batch

    def _train_preprocess(
        self: "SequenceClassificationPreprocessor",
        text_input_batch: TextInputBatch,
    ) -> tuple[dict[str, Tensor2D[Batch, Sequence]], TextInputBatch]:
        batch = self.tokenizer.batch_encode_plus(
            text_input_batch["texts"],
            max_length=self.max_seq_length,
            padding=self.padding,
            padding_side=self.padding_side,
            truncation=True,
            return_attention_mask=True,
            return_token_type_ids=True,
            return_tensors="pt",
        )
        batch["labels"] = torch.tensor(
            [self.labels.index(label) for label in text_input_batch["labels"]],
            dtype=torch.long,
        ).unsqueeze(1)

        return batch, text_input_batch


if __name__ == "__main__":
    # command : python -m ai.data_process.preprocess
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

    text_input_batch: TextInputBatch = TextInputBatch(
        texts=["It's sunny today!", "I'm so sad."], labels=["긍정", "부정"]
    )
    print(text_input_batch)

    batch, text_input_batch = preprocessor.preprocess(text_input_batch)

    print(batch)
