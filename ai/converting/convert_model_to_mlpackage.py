from transformers import AutoTokenizer, AutoModelForSequenceClassification
import torch
import torch.nn as nn
import coremltools as ct
import numpy

# 모델과 토크나이저 이름 지정
model_path = "/Users/seonjong/workspace/challenge_4/2025-C4-A10/ai/results/natural-beauty/sentiment-analysis/baseline/klue/roberta-base/serving_model"
tokenizer = AutoTokenizer.from_pretrained(model_path)
model = AutoModelForSequenceClassification.from_pretrained(model_path)


class WrappedModel(nn.Module):
    def __init__(self: "WrappedModel", base_model):
        super().__init__()
        self.base_model = base_model

    def forward(self, input_ids, attention_mask, token_type_ids=None) -> int:
        outputs = self.base_model(
            input_ids=input_ids,
            attention_mask=attention_mask,
            token_type_ids=token_type_ids,
        )
        logits = outputs.logits
        class_id = logits.argmax(dim=-1)

        return class_id


wrapped_model = WrappedModel(model)
wrapped_model.eval()

text = "CoreML conversion example"
inputs = tokenizer.encode_plus(
    text,
    max_length=512,
    padding="max_length",
    padding_side="right",
    truncation=True,
    return_attention_mask=True,
    return_token_type_ids=True,
    return_tensors="pt",
)
for k, v in inputs.items():
    print(k, v.shape)

dummy_input = (
    inputs["input_ids"],
    inputs["attention_mask"],
    inputs.get("token_type_ids"),  # BERT 계열은 token_type_ids 필요
)

# 트레이싱
traced_model = torch.jit.trace(wrapped_model, dummy_input)

# CoreML 입력 타입 지정 (필요 시 token_type_ids 포함)
coreml_inputs = [
    ct.TensorType(name="input_ids", shape=inputs["input_ids"].shape, dtype=numpy.int64),
    ct.TensorType(
        name="attention_mask", shape=inputs["attention_mask"].shape, dtype=numpy.int64
    ),
]
if "token_type_ids" in inputs:
    coreml_inputs.append(
        ct.TensorType(
            name="token_type_ids",
            shape=inputs["token_type_ids"].shape,
            dtype=numpy.int64,
        )
    )

# 변환 진행
mlmodel = ct.convert(traced_model, inputs=coreml_inputs, source="pytorch")

# 모델 저장
mlmodel.save("klue_roberta_base.mlpackage")
