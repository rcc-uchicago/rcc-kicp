#!/bin/bash

#SBATCH -N 1
#SBATCH -n 4
#SBATCH --time=00:10:00
#SBATCH --partition=gpu2 
#SBATCH --gres=gpu:1
#SBATCH --output=job_%j.out
#SBATCH --error=job_%j.err

module load cuda/10.1

./simple



 
