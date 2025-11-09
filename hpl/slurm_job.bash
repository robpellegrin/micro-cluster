#!/bin/bash

##
# A simple demo of sbatch
##

#SBATCH --job-name=hpl_benchmark
#SBATCH --ntasks=28             # Number of tasks (processes)
#SBATCH --nodes=7               # Use 7 nodes
#SBATCH --time=01:00:00         # Time limit (hh:mm:ss)
#SBATCH --output=output.log     # Output file

# Run the HPL benchmark program using srun
srun ./hpl.bin

# Run with `sbatch slurm_job.bash`
