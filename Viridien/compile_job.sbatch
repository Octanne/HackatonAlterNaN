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
armclang++ -fopenmp -O3 -ffast-math -march=native -std=c++17 -o BSM BSM.cxx

# End of job script
