#!/bin/bash

#SBATCH --job-name=hellompi
#SBATCH --output=hellompi.out
#SBATCH --time=00:30:00
#SBATCH --ntasks=4
#SBATCH --partition=broadwl-lc

# Load the default OpenMPI module.
module load openmpi

# Run the hellompi program with mpirun. The -n flag is not required;
# mpirun will automatically figure out the best configuration from the
# Slurm environment variables.
mpirun ./mpi_hello
