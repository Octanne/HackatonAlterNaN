# Create the results directory
mkdir -p results_benchmark
c8g_dir="results_benchmark/C8G"
c7g_dir="results_benchmark/C7G"
mkdir -p $c8g_dir
mkdir -p $c7g_dir

mkdir -p $c8g_dir/results
mkdir -p $c7g_dir/results

num_simulations=100000
num_runs=1000000

# Initialize variables to hold the last submitted job IDs
last_c8g_job_id=""
last_c7g_job_id=""

# Create and submit jobs for C8G
for i in 1 2 4 8 16 32 64 96
do
    # Create the benchmark script for C8G
    benchmark_script="$c8g_dir/benchmark_$i.sbatch"
    echo "#!/bin/bash" > $benchmark_script
    echo "#SBATCH --job-name=BSM_$i" >> $benchmark_script
    echo "#SBATCH --output=$c8g_dir/results/BSM_${i}_output.txt" >> $benchmark_script
    echo "#SBATCH --ntasks=1" >> $benchmark_script
    echo "#SBATCH --cpus-per-task=$i" >> $benchmark_script
    echo "#SBATCH --time=10:00:00" >> $benchmark_script
    echo "#SBATCH --nodelist=c8g-st-c8g-24xlarge-1" >> $benchmark_script
    echo "#SBATCH --partition=c8g" >> $benchmark_script
    echo "" >> $benchmark_script
    echo "./BSM $num_simulations $num_runs" >> $benchmark_script
    echo "" >> $benchmark_script
    echo "# End of job script" >> $benchmark_script

    # Submit the job with dependency
    # if [[ -z "$last_c8g_job_id" ]]; then
    #     # Submit the first job without dependency
    #     last_c8g_job_id=$(sbatch $benchmark_script | awk '{print $4}')
    # else
    #     # Submit the subsequent jobs with dependency
    #     last_c8g_job_id=$(sbatch --dependency=afterok:$last_c8g_job_id $benchmark_script | awk '{print $4}')
    # fi
done

# Create and submit jobs for C7G
for i in 1 2 4 8 16 32 64
do
    # Create the benchmark script for C7G
    benchmark_script="$c7g_dir/benchmark_$i.sbatch"
    echo "#!/bin/bash" > $benchmark_script
    echo "#SBATCH --job-name=BSM_$i" >> $benchmark_script
    echo "#SBATCH --output=$c7g_dir/results/BSM_${i}_output.txt" >> $benchmark_script
    echo "#SBATCH --ntasks=1" >> $benchmark_script
    echo "#SBATCH --cpus-per-task=$i" >> $benchmark_script
    echo "#SBATCH --time=10:00:00" >> $benchmark_script
    echo "#SBATCH --nodelist=c7g-st-c7g-16xlarge-1" >> $benchmark_script
    echo "#SBATCH --partition=c7g" >> $benchmark_script
    echo "" >> $benchmark_script
    echo "./BSM $num_simulations $num_runs" >> $benchmark_script
    echo "" >> $benchmark_script
    echo "# End of job script" >> $benchmark_script

    # Submit the job with dependency
    if [[ -z "$last_c7g_job_id" ]]; then
        # Submit the first job without dependency
        last_c7g_job_id=$(sbatch $benchmark_script | awk '{print $4}')
    else
        # Submit the subsequent jobs with dependency
        last_c7g_job_id=$(sbatch --dependency=afterok:$last_c7g_job_id $benchmark_script | awk '{print $4}')
    fi
done
