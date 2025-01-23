#!/bin/bash
#SBATCH --job-name=BSM_32
#SBATCH --output=results_benchmark/C8G/results/BSM_32_output.txt
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --time=10:00:00
#SBATCH --nodelist=c8g-st-c8g-24xlarge-1
#SBATCH --partition=c8g

./BSM 100000 1000000

# End of job script
