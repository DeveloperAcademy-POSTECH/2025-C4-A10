import torch
import argparse
from omegaconf import OmegaConf

from transformers import AutoTokenizer, AutoConfig
from datasets import load_dataset
from utils.seed import seed_everything

import data_process as Data_process
import trainer as Trainer
import model as Model

import torch.optim as optim
import utils.metric as Metric
import os


os.environ["TOKENIZERS_PARALLELISM"] = "false"
os.environ["NCCL_P2P_DISABLE"] = "1"


def main(config):
    seed_everything(config.train.seed)
    assert torch.backends.mps.is_available(), ValueError(
        "This training code only supports MacOS."
        "Please fix this error if you are using other OS."
    )

    tokenizer = AutoTokenizer.from_pretrained(config.model.model_name)
    preprocess_fn = getattr(Data_process, config.data.preprocess)(
        tokenizer=tokenizer,
        max_seq_length=config.train.max_length,
        is_split_into_words=config.data.is_split_into_words,
    ).convert_examples_to_features

    # data initialize
    dataset = load_dataset(config.data.dataset)
    train_data, val_data, test_data = dataset["train"], dataset["val"], dataset["test"]
    train_dataset = train_data.map(
        preprocess_fn,
        remove_columns=train_data.column_names,
        num_proc=config.train.num_workers,
        batched=True,
    )
    val_dataset = val_data.map(
        preprocess_fn,
        remove_columns=val_data.column_names,
        num_proc=config.train.num_workers,
        batched=True,
    )
    test_dataset = test_data.map(
        preprocess_fn,
        remove_columns=test_data.column_names,
        num_proc=config.train.num_workers,
        batched=True,
    )
    (
        train_dataset.set_format("torch"),
        val_dataset.set_format("torch"),
        test_dataset.set_format("torch"),
    )

    print(
        "=" * 50,
        f"현재 적용되고 있는 메트릭 클래스는 {config.model.metric_class}입니다.",
        "=" * 50,
        sep="\n\n",
    )
    compute_metrics = getattr(Metric, config.model.metric_class)(
        test_data=test_data,
        labels=labels,
        data_dir=config.data.path,
        is_sequence=config.data.is_split_into_words,
    )

    print(
        "=" * 50,
        f"현재 적용되고 있는 모델 클래스는 {config.model.model_class}입니다.",
        "=" * 50,
        sep="\n\n",
    )
    model_config = AutoConfig.from_pretrained(config.model.model_name)
    model = getattr(Model, config.model.model_class)(
        config=model_config,
        num_labels=config.train.num_labels,
        dropout_rate=config.train.dropout_rate,
    )

    optimizer = getattr(optim, config.model.optimizer)(
        model.parameters(), lr=config.train.learning_rate
    )
    lr_scheduler = None

    print(
        "=" * 50,
        f"현재 적용되고 있는 트레이너는 {config.model.trainer_class}입니다.",
        "=" * 50,
        sep="\n\n",
    )
    trainer = getattr(Trainer, config.model.trainer_class)(
        config=config,
        model=model,
        train_dataset=train_dataset,
        val_dataset=val_dataset,
        test_dataset=test_dataset,
        tokenizer=tokenizer,
        compute_metrics=compute_metrics,
        optimizers=(optimizer, lr_scheduler),
        labels=labels,
    )

    if not config.only_predict:
        trainer.loop()  # train + predict
    else:
        trainer.predict(config.only_predict)  # only predict


def arg_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--config",
        type=str,
        default="baseline",
        help="write configuration yaml file name",
    )
    parser.add_argument(
        "--only_predict", type=str, default="", help="write best model directory path"
    )
    args, _ = parser.parse_known_args()

    return args


if __name__ == "__main__":
    # ex) python3 train.py --config baseline
    args = arg_parser()
    config = OmegaConf.load(f"./configs/{args.config}.yaml")
    config["only_predict"] = args.only_predict
    print(f"사용할 수 있는 GPU는 {torch.cuda.device_count()}개 입니다.")

    main(config)
