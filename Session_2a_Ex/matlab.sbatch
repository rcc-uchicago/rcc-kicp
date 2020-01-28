#!/bin/bash
#SBATCH --job-name=first_matlab_job
#SBATCH --output=%j_first_matlab_job.out
#SBATCH --error=%j_first_matlab_job.err
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=2000M
#SBATCH --partition=broadwl
#SBATCH --time=1:00:00

module load matlab
echo "job started at `date`"

matlab -nodisplay -r "run hello_world.m"

echo "job finished at `date`"
