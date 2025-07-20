from typing import Type, Literal
from transformers import PreTrainedTokenizer
from torch.utils.data import Dataset
from .preprocess import SequenceClassificationPreprocessor
from utils.constants import TextInput, Tensor1D, Sequence


class SequenceClassificationDataset(Dataset):
    def __init__(
        self: "SequenceClassificationDataset",
        dataset: list[TextInput],
        tokenizer: Type[PreTrainedTokenizer],
        labels: list[str],
        max_seq_length: int = 512,
        padding: Literal["max_length"] | bool = "max_length",
        padding_side: Literal["left", "right"] = "right",
        ignore_id: int = -100,
        mode: Literal["train", "val", "test"] = "test",
    ) -> None:
        self.dataset = dataset
        self.preprocessor = SequenceClassificationPreprocessor(
            tokenizer=tokenizer,
            labels=labels,
            max_seq_length=max_seq_length,
            padding=padding,
            padding_side=padding_side,
            ignore_id=ignore_id,
            mode=mode,
        )

    def __len__(self: "SequenceClassificationDataset") -> int:
        return len(self.dataset)

    def __getitem__(
        self: "SequenceClassificationDataset", idx: int
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
        batch = self.preprocessor.preprocess(self.dataset[idx])

        return batch


if __name__ == "__main__":
    # command : python -m ai.data.dataset
    from transformers import AutoTokenizer
    from torch.utils.data import DataLoader

    labels = ["긍정", "부정"]
    mode = "train"

    tokenizer = AutoTokenizer.from_pretrained("bert-base-uncased")
    dataset = SequenceClassificationDataset(
        dataset=[
            TextInput(text="It's sunny today!", label="긍정"),
            TextInput(text="I'm so sad.", label="부정"),
        ],
        tokenizer=tokenizer,
        labels=labels,
        max_seq_length=128,
        padding="max_length",
        padding_side="right",
        ignore_id=-100,
        mode=mode,
    )
    print(dataset[0])

    dataloader = DataLoader(
        dataset=dataset,
        batch_size=2,
        shuffle=True if mode == "train" else False,
        num_workers=1,
        pin_memory=True,
    )

    for batch in dataloader:
        print(batch)
