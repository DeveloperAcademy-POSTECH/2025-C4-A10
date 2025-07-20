import torch.nn as nn
from transformers import PreTrainedModel, AutoModel, AutoConfig
from utils.constants import Tensor2D, Sequence, Batch
import torch


class ModelForSequenceClassification(PreTrainedModel):
    # Reference) https://github.com/huggingface/transformers/blob/34133d0a790787739bfc9a42603985de3728ede4/src/transformers/models/bert/modeling_bert.py#L1472-L1558
    def __init__(
        self: "ModelForSequenceClassification",
        config: AutoConfig,
        labels: list[str],
    ) -> None:
        super().__init__(config)
        self.num_labels = len(labels)
        self.classifier = nn.Sequential(
            nn.Dropout(p=config.hidden_dropout_prob),
            nn.Linear(config.hidden_size, self.num_labels),
        )
        self.post_init()
        self.model = AutoModel.from_pretrained(config._name_or_path)

    def forward(
        self: "ModelForSequenceClassification",
        input_ids: Tensor2D[Batch, Sequence],
        attention_mask: Tensor2D[Batch, Sequence],
        token_type_ids: Tensor2D[Batch, Sequence],
        labels: Tensor2D[Batch, Sequence] = None,
    ) -> tuple[torch.Tensor, torch.Tensor] | tuple[torch.Tensor]:
        output = self.model(
            input_ids=input_ids,
            attention_mask=attention_mask,
            token_type_ids=token_type_ids,
        )

        logits = self.classifier(output[1])

        loss = None
        if labels is not None:
            loss_fct = nn.CrossEntropyLoss()
            loss = loss_fct(logits.view(-1, self.num_labels), labels.view(-1))

        return (loss, logits) if loss is not None else (logits,)
