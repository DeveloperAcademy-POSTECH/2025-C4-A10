#!/bin/bash
### install requirements for layoutLMv2

pip install numpy==1.22.3
pip install seqeval==1.2.2
pip install transformers==4.26.1
pip install tqdm==4.63.0
pip3 install torch==1.8.0+cu101 torchvision==0.9.0+cu101 -f https://download.pytorch.org/whl/torch_stable.html
python -m pip install detectron2 -f https://dl.fbaipublicfiles.com/detectron2/wheels/cu101/torch1.8/index.html
pip install wandb==0.13.10
pip install omegaconf==2.3.0
pip install datasets==2.9.0
pip install seaborn==0.12.2
pip install scikit-learn==1.2.1
apt-get update
apt-get -y install libgl1-mesa-glx
pip install opencv-python==4.7.0.68
apt install tesseract-ocr
pip install pytesseract==0.3.10
python -m pip install detectron2 -f https://dl.fbaipublicfiles.com/detectron2/wheels/cu101/torch1.8/index.html
pip install multiprocess==0.70.13 dill==0.3.5.1
pip install jupyter
pip install ipykernel