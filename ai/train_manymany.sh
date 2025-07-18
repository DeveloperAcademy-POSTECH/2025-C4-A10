#!/bin/bash
CONFIGS=("layoutlmv2_large_sequence_lr1" "layoutlmv2_large_sequence_lr2" "layoutlmv2_large_sequence_lr3" "layoutlmv2_large_sequence_lr4" "layoutlmv2_large_sequence_lr6" "layoutlmv2_large_sequence_lr7" "layoutlmv2_large_sequence_lr8" "layoutlmv2_large_sequence_lr9", "layoutlmv2")

for (( i=0; i<9; i++ ))
do
    python3 train.py --config ${CONFIGS[$i]}
done