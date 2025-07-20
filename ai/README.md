# Training for Sentiment Analysis

### 1. Environment
- this Project is only supported MacOS.
- python 3.11 version recommended
- if you use [conda](https://www.anaconda.com/docs/getting-started/miniconda/install#quickstart-install-instructions), please run bellow command
```
conda create -n [env name] python=3.11 -y
conda activate [env name]
```

- dependencies : shell script about libraries that need to be installed. you can install easily using this code
```
sh install/install_requirements.sh
```

### 2. Directory Structure

- configs : configuration yaml file about experiment settings. you must run using config.yaml file.
```
python3 train.py --config [config file name]
```

- data : python file for data process function according to model
- model : python file about model
- save : directory in which the trained model is stored
- trainer : python file that trainer function
- utils : a variety of utility functions

### 3. Usage
If you want to run, please observe the following format.
```
python3 train.py --config baseline
```

If you want to run more than 1, please use the `train_manymany.sh` shell script
```
sh train_manymany.sh
```

When you want to run **only prediction using trained model**, please add model directory to `only_predict`
```
python3 train.py --config baseline \
--only_predict baseline/epoch:03_model.pt
```

For more information on configuration settings, see the configs.yaml file.

___

### 4. Hugging Face Dataset Conversion & Upload

#### 1. environment setting
1. rename .envs_template to .envs
2. replace "YOUR_TOKEN" to [HF_TOKEN](https://www.notion.so/posacademy/2362b843d5af80358341e9e6286a7988?source=copy_link#2362b843d5af80c8a87afc7406abd8c7) in .envs
