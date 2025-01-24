#!/bin/bash
#SBATCH --job-name=Cube_perf
#SBATCH --error=Cube_perf.e%j
#SBATCH --mem-per-cpu=5000
#SBATCH --time=00:45:00
#SBATCH --hint=nomultithread
#SBATCH --exclusive

# values changed by passing options
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1

# system specific:
#SBATCH --partition=cn
#SBATCH --wckey=P11YB:ASTER

INSTALLDIR=${INSTALLDIR:-${HOME}/dev/codeaster/install/mpi}
. ${INSTALLDIR}/share/aster/profile.sh

# --bind-to xxx
# --tag-output
mpiexec -np ${SLURM_NPROCS} --bind-to none \
    ${INSTALLDIR}/bin/run_aster --only-proc0 --memory_limit=15000 Cube_perf.py

suffix=""
test ! -z "${USE_LEGACY}" && suffix="${suffix}-legacy"
test ! -z "${SOLVER}" && suffix="${suffix}-$(tr '[:upper:]' '[:lower:]' <<< ${SOLVER})"
test -f slurm-${SLURM_JOBID}.out && \
    mv slurm-${SLURM_JOBID}.out Cube_perf-R${REFINE}-${SLURM_NNODES}N-${SLURM_NPROCS}p${suffix}
