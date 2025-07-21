# AI Module for Sentiment Analysis

## Directory Structure

```
ai/
├── configs/                # Configuration files for training
│   └── baseline.yaml      # Default configuration for training
├── converting/            # Tools for model conversion and inference
│   ├── convert_model_to_mlpackage.py  # Script to convert PyTorch model to CoreML format
│   ├── test_mlpackage.swift           # Swift code for CoreML model inference
│   └── Package.swift                  # Swift package definition for CoreML inference
├── data/                  # Data processing modules
│   ├── __init__.py
│   ├── dataset.py         # Dataset preparation
│   ├── evaluator.py       # Model evaluation metrics
│   └── preprocess.py      # Data preprocessing functions
├── install/               # Installation scripts
│   └── install_requirements.sh  # Script to install dependencies
├── klue_roberta_base.mlpackage/  # Converted CoreML model
├── results/               # Training results and saved models
├── trainer/               # Training modules
│   └── Trainer.py         # Main trainer implementation
└── train.py              # Main training script
```

## Setup and Installation

### Environment Requirements
- macOS (required for MPS acceleration)
- Python 3.11 (recommended)

### Setting Up with Conda
```bash
conda create -n [env name] python=3.11 -y
conda activate [env name]
```

### Installing Dependencies
```bash
sh install/install_requirements.sh
```

### Hugging Face Authentication
1. Rename `.envs_template` to `.envs`
2. Replace "YOUR_TOKEN" with your Hugging Face token in `.envs`

## Training a Model

### Basic Training
```bash
python3 train.py --config baseline
```

### Configuration
Training parameters are defined in `configs/baseline.yaml`, including:
- Model selection: `klue/roberta-base`
- Dataset: `spicy-4class-sequence-classification-dataset`
- Batch sizes, learning rate, epochs, etc.

### Inference Only
To run inference with a trained model without training:
```bash
python3 train.py --config baseline --only_test path/to/model.pt
```

## Model Conversion and iOS/macOS Integration

### Converting to CoreML
The project includes tools to convert trained PyTorch models to CoreML format for use in iOS/macOS applications:

```bash
python3 converting/convert_model_to_mlpackage.py
```

This script:
1. Loads a trained model from the results directory
2. Wraps it in a format suitable for CoreML
3. Converts it to a `.mlpackage` file

### Swift Integration
The `converting/test_mlpackage.swift` file demonstrates how to use the converted model in Swift:

```bash
cd converting
swift test_mlpackage.swift
```

This script:
1. Loads the CoreML model
2. Tokenizes input text
3. Performs inference
4. Displays prediction results

### Swift Package for Production Use
A Swift package is provided in the `converting` directory for easier integration with iOS/macOS projects:

```bash
cd converting
swift build
```

## Evaluation

The system automatically evaluates models using various metrics:
- Accuracy
- F1 Score (micro, macro, weighted)
- Precision (micro, macro, weighted)
- Recall (micro, macro, weighted)

Results are saved in the `results` directory under the appropriate experiment name.

## License

This project is part of the Developer Academy POSTECH 2025-C4-A10 challenge.
