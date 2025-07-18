# Training for Sentiment Analysis

### 1. Instructions

#### 1. directory structure

#### 2. directory details
- install : shell script about libraries that need to be installed. you can install easily using this code 
```
chmod +x install/install_requirements.sh
install/install_requirements.sh
```
- configs : configuration yaml file about experiment settings. you must run using config.yaml file.
```
python3 train.py --config [config file name]
```

- data : datasets
- data_process : python file for data preprocess fuction according to model
- model : python file about model
- save : directory in which the trained model is stored
- trainer : python file that trainer function
- utils : a variety of utility functions

### 2. Usage
If you want to run, please observe the following format.
```
python3 train.py --config baseline
```

If you want to run more than 1, please use the `train_manymany.sh` shell script
```
chmod +x train_manymany.sh
train_manymany.sh
```

When you want to run **only prediction using trained model**, please add model directory to `only_predict`
```
python3 train.py --config baseline \
--only_predict baseline/epoch:03_model.pt
```

For more information on configuration settings, see the configs.yaml file.

___