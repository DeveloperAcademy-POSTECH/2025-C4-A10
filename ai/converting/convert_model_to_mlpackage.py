from transformers import AutoTokenizer, AutoModelForSequenceClassification
import torch
import torch.nn as nn
import torch.nn.functional as F
import coremltools as ct
import numpy as np
from dotenv import load_dotenv
from os import getenv
from huggingface_hub import login

load_dotenv("../.envs")
login(token=getenv("HF_TOKEN"))

# 모델과 토크나이저 이름 지정
model_path = "natural-beauty/KcELECTRA-base-v2022-lr8e-6-DewyData-constantwarmup"
model = AutoModelForSequenceClassification.from_pretrained(model_path)
tokenizer = AutoTokenizer.from_pretrained(model_path)
model.eval()


class WrappedModel(nn.Module):
    def __init__(self: "WrappedModel", base_model):
        super().__init__()
        self.base_model = base_model

    def forward(
        self: "WrappedModel",
        input_ids,
        attention_mask,
        token_type_ids,
    ) -> torch.Tensor:
        outputs = self.base_model(
            input_ids=input_ids,
            attention_mask=attention_mask,
            token_type_ids=token_type_ids,
        )
        logits = outputs.logits
        probs = F.softmax(logits, dim=-1)

        return probs


wrapped_model = WrappedModel(model)
wrapped_model.eval()

label_list = ["긍정", "중립", "부정", "매우 부정"]
text = "야이 쓰레기야."
inputs = tokenizer.encode_plus(
    text,
    truncation=True,
    return_tensors="pt",
    padding="max_length",
    max_length=512,
    return_token_type_ids=True,
    return_attention_mask=True,
)
with torch.no_grad():
    outputs = model(**inputs)
logits = outputs.logits
softmax = nn.Softmax(dim=1)(logits)
_, predicted = torch.max(logits, dim=1)
result = label_list[predicted.item()]

print(inputs)
print("original Probabilities : ", softmax)
print(predicted)
print(result)

# 트레이싱
# Extract individual tensors for tracing
tracing_inputs = (
    inputs["input_ids"],
    inputs["attention_mask"],
    inputs["token_type_ids"],
)
traced_model = torch.jit.trace(wrapped_model, tracing_inputs)

# CoreML 입력 타입 지정 (필요 시 token_type_ids 포함)
coreml_inputs = [
    ct.TensorType(name="input_ids", shape=inputs["input_ids"].shape, dtype=np.int32),
    ct.TensorType(
        name="attention_mask", shape=inputs["attention_mask"].shape, dtype=np.int32
    ),
    ct.TensorType(
        name="token_type_ids", shape=inputs["token_type_ids"].shape, dtype=np.int32
    ),
]

# 변환 진행
mlmodel = ct.convert(
    traced_model,
    inputs=coreml_inputs,
    classifier_config=ct.ClassifierConfig(
        class_labels=list(model.config.id2label.keys()),
    ),
    convert_to="mlprogram",
    compute_precision=ct.precision.FLOAT32,
)

# mlmodel 테스트
input_ids = inputs["input_ids"].numpy().astype(np.int32)
attention_mask = inputs["attention_mask"].numpy().astype(np.int32)
token_type_ids = inputs["token_type_ids"].numpy().astype(np.int32)

print(
    f"Input shapes: input_ids={input_ids.shape}, attention_mask={attention_mask.shape}, token_type_ids={token_type_ids.shape}"
)
print(
    f"Input dtypes: input_ids={input_ids.dtype}, attention_mask={attention_mask.dtype}, token_type_ids={token_type_ids.dtype}"
)

output = mlmodel.predict(
    {
        "input_ids": input_ids,
        "attention_mask": attention_mask,
        "token_type_ids": token_type_ids,
    }
)
print(output)


# 모델 저장
mlmodel.save("KcELECTRA-base-v2022.mlpackage")
print("\n✅ Model successfully converted and saved as 'KcELECTRA-base-v2022.mlpackage'")
print(
    f"✅ Test prediction successful: {output['classLabel']} (confidence: {max(output['classLabel_probs'].values()):.4f})"
)
