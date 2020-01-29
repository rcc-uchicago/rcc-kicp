#!/bin/bash

#SBATCH --job-name=my_cool_sceince
#SBATCH --output=%j_my_cool_sceince.out
#SBATCH --error=%j_my_cool_sceince.err
#SBATACH --mem=2G
#SBATCH --partition=broadwl-lc
#SBATCH --time=00:20:00
##SBATCH --reservation=kicpworkshop_cpu
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8

module load Anaconda3/2019.03

python -u test.py

echo "Job finished on `date`" 
