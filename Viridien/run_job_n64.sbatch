#!/bin/bash
#SBATCH --job-name=BSM_test         # Name of the job
#SBATCH --output=results/test_output.txt    # Standard output file
#SBATCH --error=results/test_error.txt     # Standard error file
#SBATCH --ntasks=1                  # Number of tasks (1 for a single execution)
#SBATCH --cpus-per-task=64           # Number of CPU cores per task (adjust as necessary)
#SBATCH --time=10:00:00             # Maximum runtime (adjust as necessary)
#SBATCH --nodelist=c7g-st-c7g-16xlarge-1
#SBATCH --partition=c7g

# Run the compiled executable
./BSM 1000000 1000000

# End of job script
