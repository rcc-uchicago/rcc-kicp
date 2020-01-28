#!/bin/bash

#SBATCH --job-name=my_cool_sceince
#SBATCH --output=%j_my_cool_sceince.out
#SBATCH --error=%j_my_cool_sceince.err
#SBATACH --mem=2G
#SBATCH --partition=gpu2 --gres=gpu:1
#SBATCH --time=00:20:00
##SBATCH --account=kicp
##SBATCH --reservation=kicp_workshop
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8

module load Anaconda3/2019.03
conda activate tf-gpu-1.14.0
module load cuda/10.0

echo "Job started on `date`"

python -u function_approx_batch.py
echo "Job finished on `date`" 
