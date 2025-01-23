export INSTALLDIR=/software/restricted/simumeca/aster/install/unstable/mpi

# debug
REFINE=3 sbatch --nodes=1 --ntasks-per-node=1 run_bench.sh

# ~175.000 DOFs/proc
REFINE=6 sbatch --nodes=1 --ntasks-per-node=5 run_bench.sh
REFINE=7 sbatch --nodes=1 --ntasks-per-node=36 run_bench.sh
REFINE=8 sbatch --nodes=6 --ntasks-per-node=48 run_bench.sh
REFINE=9 sbatch --nodes=48 --ntasks-per-node=48 run_bench.sh

# ~300.000 DOFs/proc
REFINE=6 sbatch --nodes=1 --ntasks-per-node=3 run_bench.sh
REFINE=7 sbatch --nodes=1 --ntasks-per-node=22 run_bench.sh
REFINE=8 sbatch --nodes=4 --ntasks-per-node=42 run_bench.sh
REFINE=9 sbatch --nodes=30 --ntasks-per-node=45 run_bench.sh

# 50 M of DOFs
REFINE=8 sbatch --nodes=6 --ntasks-per-node=48 run_bench.sh
REFINE=8 sbatch --nodes=10 --ntasks-per-node=48 run_bench.sh
REFINE=8 sbatch --nodes=21 --ntasks-per-node=48 run_bench.sh
REFINE=8 sbatch --nodes=42 --ntasks-per-node=48 run_bench.sh

# max number of allocatable nodes
REFINE=9 sbatch --nodes=64 --ntasks-per-node=48 run_bench.sh


# legacy
REFINE=6 USE_LEGACY=1 SOLVER=PETSC sbatch --nodes=1 --ntasks-per-node=4 run_bench.sh
REFINE=6 USE_LEGACY=1 SOLVER=PETSC sbatch --nodes=2 --ntasks-per-node=24 run_bench.sh
REFINE=6 USE_LEGACY=1 SOLVER=PETSC sbatch --nodes=4 --ntasks-per-node=24 run_bench.sh

REFINE=6 USE_LEGACY=1 SOLVER=MUMPS sbatch --nodes=1 --ntasks-per-node=4 run_bench.sh
REFINE=6 USE_LEGACY=1 SOLVER=MUMPS sbatch --nodes=2 --ntasks-per-node=24 run_bench.sh
REFINE=6 USE_LEGACY=1 SOLVER=MUMPS sbatch --nodes=4 --ntasks-per-node=24 run_bench.sh
