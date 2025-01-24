#!/bin/bash
#SBATCH --job-name=BSM_test         # Name of the job
#SBATCH --output=results/test_output.txt    # Standard output file
#SBATCH --error=results/test_error.txt     # Standard error file
#SBATCH --ntasks=1                  # Number of tasks (1 for a single execution)
#SBATCH --cpus-per-task=96           # Number of CPU cores per task (adjust as necessary)
#SBATCH --time=10:00:00             # Maximum runtime (adjust as necessary)
#SBATCH --nodelist=c8g-st-c8g-24xlarge-1
#SBATCH --partition=c8g

# Run the compiled executable
./BSM 100000 1000000
./BSM 1000000 1000000
./BSM 10000000 1000000
#./BSM 100000000 1000000

# End of job script
