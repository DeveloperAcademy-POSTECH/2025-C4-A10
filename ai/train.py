import torch
import argparse
from omegaconf import DictConfig, OmegaConf

from transformers import AutoTokenizer, AutoModelForSequenceClassification
from datasets import load_dataset
from utils.seed import seed_everything

from data.dataset import SequenceClassificationDataset
from trainer.trainer import Trainer
from utils.scheduler import (
    get_constant_schedule_with_warmup,
    get_linear_schedule_with_warmup,
    get_cosine_schedule_with_warmup,
)
from data.evaluator import Evaluator

import torch.optim as optim
from os import environ, getenv
from dotenv import load_dotenv
from huggingface_hub import login, whoami

# login huggingface hub
load_dotenv(".envs")
login(token=getenv("HF_TOKEN"))
user_info = whoami()
print(f"Logged in as: {user_info['name']}")

environ["TOKENIZERS_PARALLELISM"] = "false"
environ["NCCL_P2P_DISABLE"] = "1"


def main(config: DictConfig) -> None:
    seed_everything(config.train.seed)
    assert torch.backends.mps.is_available(), ValueError(
        "This training code only supports MacOS."
        "Please delete this error if you are using other OS."
    )
    # load huggingface dataset
    dataset = load_dataset(f"{config.organization}/{config.dataset}")
    labels = list(dataset["train"].features["label"].names)
    print(
        "=" * 50,
        f"labels : {labels}",
        "=" * 50,
        sep="\n",
    )
    tokenizer = AutoTokenizer.from_pretrained(config.model)

    # data initialize
    train_dataset = SequenceClassificationDataset(
        dataset=dataset["train"],
        tokenizer=tokenizer,
        labels=labels,
        max_seq_length=config.train.max_length,
        mode="train",
    )
    val_dataset = SequenceClassificationDataset(
        dataset=dataset["validation"],
        tokenizer=tokenizer,
        labels=labels,
        max_seq_length=config.train.max_length,
        mode="val",
    )
    test_dataset = SequenceClassificationDataset(
        dataset=dataset["test"],
        tokenizer=tokenizer,
        labels=labels,
        max_seq_length=config.train.max_length,
        mode="test",
    )

    evaluator = Evaluator(labels=labels)

    model = AutoModelForSequenceClassification.from_pretrained(
        config.model,
        num_labels=len(labels),
        id2label={i: label for i, label in enumerate(labels)},
        label2id={label: i for i, label in enumerate(labels)},
    )

    optimizer = getattr(optim, config.train.optimizer)(
        model.parameters(), lr=config.train.learning_rate
    )
    num_training_steps = config.train.max_epoch * len(train_dataset)
    if (scheduler := config.train.scheduler) == "constant":
        lr_scheduler = None
    elif scheduler == "constant_schedule_with_warmup":
        lr_scheduler = get_constant_schedule_with_warmup(
            optimizer, num_warmup_steps=num_training_steps * 0.1
        )
    elif scheduler == "linear_schedule_with_warmup":
        lr_scheduler = get_linear_schedule_with_warmup(
            optimizer,
            num_warmup_steps=num_training_steps * 0.1,
            num_training_steps=num_training_steps,
        )
    elif scheduler == "cosine_schedule_with_warmup":
        lr_scheduler = get_cosine_schedule_with_warmup(
            optimizer,
            num_warmup_steps=num_training_steps * 0.1,
            num_training_steps=num_training_steps,
        )
    else:
        raise ValueError(f"Invalid scheduler: {config.train.scheduler}")

    trainer = Trainer(
        config=config,
        model=model,
        train_dataset=train_dataset,
        val_dataset=val_dataset,
        test_dataset=test_dataset,
        tokenizer=tokenizer,
        compute_metrics=evaluator,
        optimizers=(optimizer, lr_scheduler),
        labels=labels,
    )

    if not config.only_test:
        trainer.loop()  # train + predict
    else:
        trainer.test(config.only_test)  # only predict


def arg_parsing() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--config",
        type=str,
        default="baseline",
        help="write configuration yaml file name",
    )
    parser.add_argument(
        "--only_test", type=str, default="", help="write best model directory path"
    )
    args, _ = parser.parse_known_args()

    return args


if __name__ == "__main__":
    # ex) python3 train.py --config baseline
    args = arg_parsing()
    config = OmegaConf.load(f"./configs/{args.config}.yaml")
    config["original_filename"] = args.config
    if args.only_test:
        config["only_test"] = args.only_test

    main(config)
