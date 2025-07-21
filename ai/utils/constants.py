from typing import TypeVar, Generic, TypedDict
import torch

Batch = TypeVar("Batch", bound=int)
Sequence = TypeVar("Sequence", bound=int)
HiddenState = TypeVar("HiddenState", bound=torch.Tensor)


class Tensor1D(Generic[Sequence]):
    def __init__(self: "Tensor1D", tensor: torch.Tensor):
        assert tensor.dim() == 1, ValueError("Tensor must be 1-dimensional")
        self.tensor = tensor
        self.s: Sequence = tensor.size(0)  # sequence length
        assert self.s == tensor.size(0), ValueError(
            f"Expected Sequence {self.s}, but got {tensor.size(0)}"
        )

    def size(self: "Tensor1D") -> tuple[int]:
        return self.tensor.size()

    def __repr__(self: "Tensor1D") -> str:
        return f"Tensor(shape=({self.s}))"


class Tensor2D(Generic[Batch, Sequence]):
    def __init__(self: "Tensor2D", tensor: torch.Tensor):
        assert tensor.dim() == 2, ValueError("Tensor must be 2-dimensional")
        self.tensor = tensor
        self.b: Batch = tensor.size(0)  # batch size
        self.s: Sequence = tensor.size(1)  # sequence length
        assert self.b == tensor.size(0), ValueError(
            f"Expected batch {self.b}, but got {tensor.size(0)}"
        )
        assert self.s == tensor.size(1), ValueError(
            f"Expected Sequence {self.s}, but got {tensor.size(1)}"
        )

    def size(self: "Tensor2D") -> tuple[int, int]:
        return self.tensor.size()

    def __repr__(self: "Tensor2D") -> str:
        return f"Tensor(shape=({self.b}, {self.s}))"


class Tensor3D(Generic[Batch, Sequence, HiddenState]):
    def __init__(self: "Tensor3D", tensor: torch.Tensor):
        assert tensor.dim() == 3, ValueError("Tensor must be 3-dimensional")
        self.tensor = tensor
        self.b: Batch = tensor.size(0)  # batch size
        self.s: Sequence = tensor.size(1)  # sequence length
        self.h: HiddenState = tensor.size(2)  # hidden state size
        assert self.b == tensor.size(0), ValueError(
            f"Expected batch {self.b}, but got {tensor.size(0)}"
        )
        assert self.s == tensor.size(1), ValueError(
            f"Expected Sequence {self.s}, but got {tensor.size(1)}"
        )
        assert self.h == tensor.size(2), ValueError(
            f"Expected Hidden State {self.h}, but got {tensor.size(2)}"
        )

    def size(self: "Tensor3D") -> tuple[int, int, int]:
        return self.tensor.size()

    def __repr__(self: "Tensor3D") -> str:
        return f"Tensor(shape=({self.b}, {self.s}, {self.h}))"


Text = TypeVar("Text", bound=str)
Label = TypeVar("Label", bound=str)


class Input(TypedDict):
    """
    Input data example
        text: "It's sunny today!"
        label: "긍정"
    """

    text: Text
    label: Label | None


class InputBatch(TypedDict):
    """
    Input batch data example
        texts: ["It's sunny today!", "I'm so sad."]
        labels: ["긍정", "부정"]
    """

    texts: list[Text]
    labels: list[Label | None]


class EncoderModelInputBatch(TypedDict):
    """
    Encoder model input batch data example
        input_ids: torch.Tensor([[101, 202, 303, ...], ...])
        attention_mask: torch.Tensor([[1, 1, 1, ...], ...])
        token_type_ids: torch.Tensor([[0, 0, 0, ...], ...])
        labels: torch.Tensor([[0], ...]) | None
    """

    input_ids: Tensor2D[Batch, Sequence]
    attention_mask: Tensor2D[Batch, Sequence]
    token_type_ids: Tensor2D[Batch, Sequence]
    labels: Tensor2D[Batch, Sequence] | None


class SequenceClassificationInputBatch(EncoderModelInputBatch):
    """
    Sequence classification input batch data example
        input_ids: torch.Tensor([[101, 202, 303, ...], ...])
        attention_mask: torch.Tensor([[1, 1, 1, ...], ...])
        token_type_ids: torch.Tensor([[0, 0, 0, ...], ...])
        labels: torch.Tensor([[0], ...]) | None
        original_texts: ["It's sunny today!", "I'm so sad."]
        label_texts: ["긍정", "부정"]
        ids: ["1", "2"]
    """

    original_texts: list[Text]
    label_texts: list[Label]
    ids: list[int | str]
