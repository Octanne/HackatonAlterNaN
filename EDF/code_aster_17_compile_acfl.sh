#!/bin/bash

# Variables
VERSION_CAS=20240327
COMPILE_ROOT=${HOME}/ACFL_CodeAster
INSTALL_DIR=${COMPILE_ROOT}/aster
WRKDIR=${COMPILE_ROOT}/codeaster-prerequisites-${VERSION_CAS}-oss
PYVENV_CAS=${COMPILE_ROOT}/venv
ACFL_TO_GCC_LINK=${COMPILE_ROOT}/acfl_bin
ACFL_DIR=/tools/acfl/24.04/arm-linux-compiler-24.04_AmazonLinux-2
MPI_DIR=/tools/openmpi/4.1.7/acfl/24.04

# We install miniconda
if [ 1 == 0 ]; then
  mkdir -p ~/miniconda3
  wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh -O ~/miniconda3/miniconda.sh
  bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
  rm ~/miniconda3/miniconda.sh
fi

# PATH Setting UP
PATH=${ACFL_TO_GCC_LINK}:${MPI_DIR}/bin:${PATH}
#LD_LIBRARY_PATH=${ACFL_DIR}/lib64:${MPI_DIR}/lib:$LD_LIBRARY_PATH

# Module load
module unload all
module use /tools/acfl/24.10/modulefiles
module use /tools/acfl/24.04/modulefiles
module load acfl/24.04
module load openmpi/4.1.6
# We load python env
source ~/miniconda3/bin/activate

# Preparing folder for compile env
if [ ! -d "${COMPILE_ROOT}" ]; then
  mkdir -p ${COMPILE_ROOT}/ && cd ${COMPILE_ROOT}/

  # Links up for compiler
  mkdir -p ${ACFL_TO_GCC_LINK}
  ln -s ${ACFL_BIN}/armclang ${ACFL_TO_GCC_LINK}/gcc
  ln -s ${ACFL_BIN}/armclang++ ${ACFL_TO_GCC_LINK}/g++
  ln -s ${ACFL_BIN}/armflang ${ACFL_TO_GCC_LINK}/gfortran

  # Prerequisites DL
  wget https://www.code-aster.org/FICHIERS/prerequisites/codeaster-prerequisites-${VERSION_CAS}-oss.tar.gz
  tar xzf codeaster-prerequisites-${VERSION_CAS}-oss.tar.gz
  cd ${WRKDIR}

  # Python setup
  python -m venv --system-site-packages ${PYVENV_CAS}
  python -m pip install --upgrade pip
  python -m pip install -r ${WRKDIR}/reqs/requirements_dev.txt
  mpi4py_spec=$(. ${WRKDIR}/VERSION ; printf "mpi4py==${MPI4PY}")
  python -m pip install "${mpi4py_spec}"
else
  cd ${WRKDIR}
fi

# Check make
make ROOT=${INSTALL_DIR} ARCH=gcc13-openblas-ompi4 RESTRICTED=0 check
make ROOT=${INSTALL_DIR} ARCH=gcc13-openblas-ompi4 RESTRICTED=0 setup_venv
