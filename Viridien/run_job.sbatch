#!/bin/bash
#SBATCH --job-name=BSM_test         # Name of the job
#SBATCH --output=results/test_output.txt    # Standard output file
#SBATCH --error=results/test_error.txt     # Standard error file
#SBATCH --ntasks=1                  # Number of tasks (1 for a single execution)
#SBATCH --cpus-per-task=96           # Number of CPU cores per task (adjust as necessary)
#SBATCH --time=00:10:00             # Maximum runtime (adjust as necessary)

# Run the compiled executable
./BSM 1000000000 10

# End of job script
