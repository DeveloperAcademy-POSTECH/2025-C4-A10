# AI Model Training for Sentiment Analysis

이 디렉토리는 한국어 감정 분석 모델을 학습하기 위한 코드를 포함하고 있습니다. 다양한 한국어 언어 모델(KcELECTRA, KLUE-RoBERTa, KoELECTRA 등)을 사용하여 감정 분류 모델을 훈련할 수 있습니다.

## 🚀 빠른 시작

### 1. 환경 설정

#### 필수 요구사항
- Python 3.8 이상
- macOS (Apple Silicon 권장 - MPS 지원)
- HuggingFace Hub 계정 및 토큰
- Weights & Biases 계정 및 토큰 (선택사항)

#### 의존성 설치
```bash
# 프로젝트 루트에서 ai 디렉토리로 이동
cd ai

# 필요한 패키지 설치
bash install/install_requirements.sh
```

#### 환경 변수 설정
```bash
# 환경 변수 템플릿 복사
cp .envs_template .envs

# .envs 파일을 편집하여 토큰 입력
# HF_TOKEN="your_huggingface_token_here"
# WANDB_TOKEN="your_wandb_token_here"
```

### 2. 모델 학습 실행

#### 기본 학습
```bash
python3 train.py --config baseline
```

#### 특정 모델 학습
```bash
# KcELECTRA 모델 학습
python3 train.py --config kcelectra_base_lr1e_5

# KLUE-RoBERTa 모델 학습
python3 train.py --config klue_roberta_base_lr1e_5
```

#### 배치 학습 (여러 설정 동시 실행)
```bash
bash train_manymany.sh
```

## 📁 디렉토리 구조

```
ai/
├── configs/                 # 모델 학습 설정 파일들
│   ├── baseline.yaml        # 기본 설정 (klue/roberta-base)
│   ├── kcelectra_base_*.yaml # KcELECTRA 모델 설정들
│   ├── klue_roberta_*.yaml  # KLUE-RoBERTa 모델 설정들
│   └── koelectra_base_*.yaml # KoELECTRA 모델 설정들
├── data/                    # 데이터 처리 및 평가 유틸리티
│   ├── dataset.py          # 데이터셋 클래스
│   ├── evaluator.py        # 모델 평가 로직
│   └── preprocess.py       # 데이터 전처리
├── trainer/                 # 학습 로직
│   └── trainer.py          # 메인 트레이너 클래스
├── utils/                   # 공통 유틸리티
│   ├── scheduler.py        # 학습률 스케줄러
│   ├── seed.py            # 시드 설정
│   └── wandb_setting.py   # WandB 설정
├── converting/             # iOS 배포용 모델 변환
│   ├── convert_model_to_mlpackage.py
│   └── test_mlpackage.swift
├── install/                # 설치 스크립트
│   └── install_requirements.sh
├── train.py               # 메인 학습 스크립트
└── train_manymany.sh      # 배치 학습 스크립트
```

## ⚙️ 설정 파일 이해하기

### 기본 설정 예시 (baseline.yaml)
```yaml
wandb:
  entity: natural-beauty
  project: sentiment-analysis
  group: baseline
  experiment: klue/roberta-base
  use_wandb: True

model: klue/roberta-base
organization: natural-beauty
dataset: spicy-4class-sequence-classification-dataset-example

train:
  optimizer: AdamW
  scheduler: constant_schedule_with_warmup
  train_batch_size: 1
  val_batch_size: 1
  max_epoch: 2
  learning_rate: 2e-5
  max_length: 512
  seed: 42
```

### 주요 설정 옵션
- `model`: 사용할 HuggingFace 모델명
- `learning_rate`: 학습률 (1e-5 ~ 4e-5 권장)
- `max_epoch`: 최대 에포크 수
- `batch_size`: 배치 크기
- `scheduler`: 학습률 스케줄러 종류

## 🎯 지원하는 모델들

1. **KcELECTRA-base-v2022**: 한국어 특화 ELECTRA 모델
2. **KLUE-RoBERTa**: KLUE 벤치마크용 RoBERTa 모델
3. **KoELECTRA**: 한국어 ELECTRA 모델
4. **XLM-RoBERTa**: 다국어 RoBERTa 모델

각 모델별로 다양한 학습률 설정이 준비되어 있습니다.

## 📊 학습 모니터링

### Weights & Biases 사용
학습 진행 상황은 WandB를 통해 모니터링할 수 있습니다:
1. WandB 계정 생성 및 토큰 획득
2. `.envs` 파일에 토큰 설정
3. 학습 시작 후 WandB 대시보드에서 확인

### 로컬 결과 확인
학습 결과는 `results/` 디렉토리에 저장됩니다.

## 🔄 iOS 앱 배포용 모델 변환

학습된 PyTorch 모델을 iOS 앱에서 사용하기 위해 CoreML 형식으로 변환할 수 있습니다:

```bash
cd converting
python3 convert_model_to_mlpackage.py
```

변환된 모델은 `.mlpackage` 형식으로 저장되며, iOS 프로젝트에서 직접 사용할 수 있습니다.

## 🛠️ 고급 사용법

### 커스텀 설정 파일 생성
새로운 실험을 위해 커스텀 설정 파일을 생성할 수 있습니다:

1. `configs/` 디렉토리에 새 YAML 파일 생성
2. 기존 설정 파일을 참고하여 파라미터 조정
3. `python3 train.py --config your_config_name` 으로 실행

### 테스트만 실행하기
이미 학습된 모델로 테스트만 수행하려면:
```yaml
only_test: "/path/to/your/trained/model"
```

## 🔧 문제 해결

### 일반적인 오류들

1. **MPS 관련 오류**
   - Apple Silicon Mac에서만 지원됩니다
   - Intel Mac 사용 시 코드에서 MPS 체크 부분을 수정해야 합니다

2. **HuggingFace 토큰 오류**
   - `.envs` 파일에 올바른 토큰이 설정되었는지 확인
   - HuggingFace Hub에 로그인되었는지 확인

3. **메모리 부족 오류**
   - `batch_size`를 줄여보세요
   - 더 작은 모델을 사용해보세요

4. **데이터셋 로드 오류**
   - 인터넷 연결 확인
   - HuggingFace 데이터셋 접근 권한 확인

### 로그 확인
학습 중 문제가 발생하면 콘솔 출력과 WandB 로그를 확인하세요.

## 📝 추가 정보

- 학습된 모델은 한국어 감정 분석(긍정, 중립, 부정, 매우 부정) 4클래스 분류를 수행합니다
- 모든 설정은 YAML 파일을 통해 관리되므로 코드 수정 없이 실험 가능합니다
- 배치 학습 스크립트를 통해 여러 설정을 한 번에 실행할 수 있습니다

문제가 발생하거나 추가 도움이 필요하면 프로젝트 관리자에게 문의하세요.
