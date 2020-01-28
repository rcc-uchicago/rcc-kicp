#!/bin/bash
#SBATCH --job-name=first_python_job
#SBATCH --output=%j_first_python_job.out
#SBATCH --error=%j_first_python_job.err
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=2000M
#SBATCH --partition=broadwl
#SBATCH --time=1:00:00

module load python
echo "job started at `date`"

python hello_world.py

echo "job finished at `date`"
