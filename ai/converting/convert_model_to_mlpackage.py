from transformers import AutoTokenizer, AutoModelForSequenceClassification
import torch
import torch.nn as nn
import torch.nn.functional as F
import coremltools as ct
import numpy as np

# 모델과 토크나이저 이름 지정
model_path = "/Users/seonjong/workspace/challenge_4/2025-C4-A10/ai/results/natural-beauty/sentiment-analysis/baseline/klue/roberta-base/serving_model"
tokenizer = AutoTokenizer.from_pretrained(model_path)
model = AutoModelForSequenceClassification.from_pretrained(model_path)


class WrappedModel(nn.Module):
    def __init__(self: "WrappedModel", base_model):
        super().__init__()
        self.base_model = base_model

    def forward(
        self: "WrappedModel",
        input_ids,
    ) -> torch.Tensor:
        outputs = self.base_model(input_ids=input_ids)
        logits = outputs.logits
        probs = F.softmax(logits, dim=-1)

        return probs


wrapped_model = WrappedModel(model)
wrapped_model.eval()

text = "CoreML conversion example"
inputs = tokenizer.encode_plus(
    text,
    max_length=512,
    padding="max_length",
    padding_side="right",
    truncation=True,
    return_tensors="pt",
)

dummy_input = inputs["input_ids"]

# 트레이싱
traced_model = torch.jit.trace(wrapped_model, dummy_input)

# CoreML 입력 타입 지정 (필요 시 token_type_ids 포함)
coreml_inputs = [
    ct.TensorType(name="input_ids", shape=inputs["input_ids"].shape, dtype=np.int32),
]

# 변환 진행
mlmodel = ct.convert(
    traced_model,
    inputs=coreml_inputs,
    classifier_config=ct.ClassifierConfig(
        class_labels=list(model.config.id2label.values()),
    ),
    source="pytorch",
)

# 모델 저장
mlmodel.save("MyModel.mlpackage")
