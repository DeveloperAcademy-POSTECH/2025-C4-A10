import argparse
import json
from pathlib import Path
from typing import Any, Dict, Type
from glob import glob

import os
from omegaconf import DictConfig, OmegaConf
import torch
import yaml
from transformers import PreTrainedModel, PreTrainedTokenizer

PathLike = str | bytes | Path


def dumper(obj: Any) -> Dict[str, Any]:
    try:
        return obj.toJSON()
    except AttributeError:
        return obj.__dict__


def save_json(write_path: PathLike, save_obj: Any) -> None:
    (write_path := Path(write_path)).parent.mkdir(parents=True, exist_ok=True)
    with write_path.open("w", encoding="utf-8") as f:
        json.dump(save_obj, f, default=dumper, ensure_ascii=False, indent=4)


def read_json(json_path: PathLike) -> Dict:
    with Path(json_path).open("r", encoding="utf-8") as f:
        return json.load(f)


def save_yaml(write_path: PathLike, save_obj: Any) -> None:
    (write_path := Path(write_path)).parent.mkdir(parents=True, exist_ok=True)
    with write_path.open("w", encoding="utf-8") as f:
        yaml.dump(
            save_obj, f, default_flow_style=False, allow_unicode=True, sort_keys=False
        )


def load_yaml(yaml_path: PathLike) -> Dict:
    with Path(yaml_path).open("r", encoding="utf-8") as f:
        return yaml.load(f, Loader=yaml.FullLoader)


def save_config_file(config: DictConfig, path: PathLike, resolve: bool = True) -> None:
    if resolve:
        OmegaConf.resolve(config)

    if not (path := Path(path)).exists() and path.is_dir():
        path.mkdir(parents=True, exist_ok=True)
    elif path.is_file():
        path = path.parent
        path.mkdir(parents=True, exist_ok=True)

    save_path = path / "config.yaml"
    with open(save_path, "w", encoding="utf-8") as f:
        OmegaConf.save(config=config, f=f)
        print(f"Config is saved at {save_path}")


def save_args_to_json(args: argparse.Namespace, config_path: PathLike):
    args_dict = vars(args)

    # JSON 직렬화가 불가능한 타입을 변환
    for key, value in args_dict.items():
        if isinstance(value, torch.dtype):
            args_dict[key] = str(value)

    save_json(config_path, args_dict)


def save_model(
    config: DictConfig,
    config_filename: str,
    model: Type[PreTrainedModel],
    tokenizer: Type[PreTrainedTokenizer],
    save_path: str,
):
    OmegaConf.save(config, Path(save_path) / f"{config_filename}.yaml")
    save_path = Path(save_path, "serving_model")
    save_path.mkdir(parents=True, exist_ok=True)
    try:
        model.save_pretrained(save_path)

        # config 저장
        model.config.save_pretrained(save_path)
        if isinstance(model, PreTrainedModel):
            # tokenizer 저장
            tokenizer.save_pretrained(save_path)

    except Exception as e:
        print(f"Failed to save model because of\n: {e}")
        raise


def save_state(obj: Any, save_path: Path):
    torch.save(obj.state_dict() if hasattr(obj, "state_dict") else obj, save_path)


def check_dir(save_directory: str, reverse_check_num: int = 10):
    if not os.path.isdir(f"save/{save_directory}"):
        """처음 초기화하는 경우"""
        print("모델을 저장할 디렉토리를 생성합니다.")
        os.makedirs(f"save/{save_directory}")
        if os.path.isdir(f"save/{save_directory}"):
            print("생성완료")

        return save_directory

    elif os.path.isdir(f"save/{save_directory}") and not bool(
        glob(f"save/{save_directory}/*.pt")
    ):  # 디렉토리는 생성했지만 저장한 모델이 없는 경우
        return save_directory

    elif (
        os.path.isdir(f"save/{save_directory}")
        and bool(glob(f"save/{save_directory}/*.pt"))
        and not bool(glob(f"save/{save_directory}/*.csv"))
    ):  # 훈련이 끝나고 inference만 하고 싶은 경우 마지막 디렉토리를 탐색
        last_directory = f"{save_directory}_{reverse_check_num}"
        number = reverse_check_num
        while last_directory not in os.listdir("save"):
            number -= 1
            if number < 10:
                str_num = "0" + str(number)
            else:
                str_num = str(number)

            if number > 0:
                last_directory = f"{save_directory}_{str_num}"
            else:
                last_directory = f"{save_directory}"
        print(f"inference 결과가 담길 디렉토리는 {last_directory}입니다.")

        return last_directory

    else:
        print(
            "파일이 덮여씌여지는 것을 방지하기 위해 새로운 디렉토리를 생성합니다. 필요없는 모델은 확인 후 삭제해주세요."
        )
        number = 1
        # next_directory가 없을때까지 다음 번호를 부여하면서 체크
        str_num = "0" + str(number)
        next_directory = f"{save_directory}_{str_num}"
        while next_directory in os.listdir("save"):
            number += 1
            if number < 10:
                str_num = "0" + str(number)
            else:
                str_num = str(number)
            next_directory = f"{save_directory}_{str_num}"

        os.makedirs(f"save/{next_directory}")
        if os.path.isdir(f"save/{next_directory}"):
            print("생성완료")

        return next_directory
