# Read output files and extract the results (value and time)
# Example : 
# Using Boost 1.53.0
# Global initial seed: 2880001847      argv[1]= 100000     argv[2]= 1000000
#  value= 5.136977 in 56.491334 seconds
# Performance in seconds : 56.491

c8g_dir="results_benchmark/C8G"
c7g_dir="results_benchmark/C7G"

# We want to extract from "value= 5.136977 in 56.491334 seconds"

values=()
times=()

# C8G
for i in 1 2 4 8 16 32 64 96
do
    output_file="$c8g_dir/results/BSM_${i}_output.txt"
    value=$(grep -oP 'value= \K[0-9.]*' $output_file)
    time=$(grep -oP 'in \K[0-9.]*' $output_file)
    # echo "C8G $i $value $time"
    # Add to arrays
    values+=($value)
    times+=($time)
done

echo "C8G" > values.txt
for i in ${!values[@]}
do
    echo "${values[$i]}" >> values.txt
done

echo "C8G" > times.txt
for i in ${!times[@]}
do
    echo "${times[$i]}" >> times.txt
done

values=()
times=()

# C7G
for i in 1 2 4 8 16 32 64
do
    output_file="$c7g_dir/results/BSM_${i}_output.txt"
    value=$(grep -oP 'value= \K[0-9.]*' $output_file)
    time=$(grep -oP 'in \K[0-9.]*' $output_file)
    # echo "C7G $i $value $time"
    # Add to arrays
    values+=($value)
    times+=($time)
done

echo "C7G" >> values.txt
for i in ${!values[@]}
do
    echo "${values[$i]}" >> values.txt
done

echo "C7G" >> times.txt
for i in ${!times[@]}
do
    echo "${times[$i]}" >> times.txt
done

