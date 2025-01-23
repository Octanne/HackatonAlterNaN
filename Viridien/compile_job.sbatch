#!/bin/bash
#SBATCH --job-name=BSM_compile      # Name of the job
#SBATCH --output=results/compile_output.txt  # Standard output file
#SBATCH --error=results/compile_error.txt   # Standard error file
#SBATCH --ntasks=1                  # Number of tasks (1 for a single compilation task)
#SBATCH --cpus-per-task=16           # Number of CPU cores per task (adjust as necessary)
#SBATCH --time=00:30:00             # Maximum runtime (adjust as necessary)

# Load necessary modules (if needed, e.g., armclang)
module load armpl/24.10.1

# Compilation command
armclang++ -g -O3 -DREAL=float -mcpu=native -march=armv8-a+sve -ftree-vectorize -flto -std=c++17 -fopenmp -o BSM BSM.cxx -lboost_random

# End of job script
