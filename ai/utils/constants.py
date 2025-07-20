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


class TextInput(TypedDict):
    text: Text
    label: Label | None


class TextInputBatch(TypedDict):
    texts: list[Text]
    labels: list[Label | None]


class EncoderModelInputBatch(TypedDict):
    input_ids: Tensor2D[Batch, Sequence]
    attention_mask: Tensor2D[Batch, Sequence]
    token_type_ids: Tensor2D[Batch, Sequence]
