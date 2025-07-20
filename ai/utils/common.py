import torch


def str_to_torch_dtype(dtype: str | torch.dtype) -> torch.dtype:
    if isinstance(dtype, str):
        dtype_map = {
            "float32": torch.float32,
            "float16": torch.float16,
            "bfloat16": torch.bfloat16,
            "float64": torch.float64,
            "int32": torch.int32,
            "int64": torch.int64,
        }
        if dtype.lower() in dtype_map:
            return dtype_map.get(dtype.lower())
        else:
            return None
    return dtype
