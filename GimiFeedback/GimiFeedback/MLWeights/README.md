## run this cli command to add mlpackage to git

```bash
# if your current directory is 2025-C4-A10
cd ./GimiFeedback/GimiFeedback/MLWeights
git clone https://huggingface.co/natural-beauty/KcELECTRA-base-v2022
cd KcELECTRA-base-v2022
mv KcELECTRA-base-v2022.mlpackage ..
cd ..
rm -rf KcELECTRA-base-v2022
```