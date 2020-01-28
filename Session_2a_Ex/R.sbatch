#!/bin/bash
#SBATCH --job-name=first_R_job
#SBATCH --output=%j_first_R_job.out
#SBATCH --error=%j_first_R_job.err
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=2000M
#SBATCH --partition=broadwl
#SBATCH --time=1:00:00

module load R
echo "job started at `date`"

Rscript hello_world.R

echo "job finished at `date`"
