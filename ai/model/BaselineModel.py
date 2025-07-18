import torch.nn as nn
from transformers import AutoModel, LayoutLMPreTrainedModel

class BaselineModel(LayoutLMPreTrainedModel):
    """_summary_
    베이스라인 모델입니다.
    """
    def __init__(self, config, num_labels, dropout_rate):
        super().__init__(config)
        self.num_labels = num_labels
        self.classifier = nn.Sequential(
            nn.Dropout(p=dropout_rate),
            nn.Linear(config.hidden_size, self.num_labels)
        )
        self.post_init()
        self.model = AutoModel.from_pretrained(config._name_or_path)

    def forward(self,
        input_ids=None,
        bbox=None,
        labels=None,
        attention_mask=None,
        token_type_ids=None,
        position_ids=None,
    ):
        output = self.model(
            input_ids=input_ids,
            bbox=bbox,
            attention_mask=attention_mask,
            token_type_ids=token_type_ids,
            position_ids=position_ids,
        )

        logits = self.classifier(output[0]) # pooler

        loss = None
        if labels is not None:
            loss_fct = nn.CrossEntropyLoss()
            loss = loss_fct(logits.view(-1, self.num_labels), labels.view(-1))

        return (loss, logits) if loss is not None else (logits,)