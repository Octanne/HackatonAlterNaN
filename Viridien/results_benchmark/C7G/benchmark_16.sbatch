#!/bin/bash
#SBATCH --job-name=BSM_16
#SBATCH --output=results_benchmark/C7G/results/BSM_16_output.txt
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --time=10:00:00
#SBATCH --nodelist=c7g-st-c7g-16xlarge-1
#SBATCH --partition=c7g

./BSM 100000 1000000

# End of job script
