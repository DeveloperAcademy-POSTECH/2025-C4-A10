import torch.nn as nn
from transformers import AutoModel, LayoutLMv2PreTrainedModel

class LayoutLMv2Model(LayoutLMv2PreTrainedModel):
    """_summary_
    LayoutLMv2 모델입니다.
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
        image=None,
        labels=None,
        attention_mask=None,
        token_type_ids=None,
        position_ids=None,
    ):
        outputs = self.model(
            input_ids=input_ids,
            bbox=bbox,
            image=image,
            attention_mask=attention_mask,
            token_type_ids=token_type_ids,
            position_ids=position_ids,
        )
        input_shape = input_ids.size()

        seq_length = input_shape[1]
        # only take the text part of the output representations
        sequence_output = outputs[0][:, :seq_length]
        logits = self.classifier(sequence_output)

        loss = None
        if labels is not None:
            loss_fct = nn.CrossEntropyLoss()
            loss = loss_fct(logits.view(-1, self.num_labels), labels.view(-1))

        return (loss, logits) if loss is not None else (logits,)