#!/bin/bash

# Variables
VERSION_CAS=20240327
COMPILE_ROOT=${HOME}/ACFL_CodeAster
INSTALL_DIR=${COMPILE_ROOT}/aster
WRKDIR=${COMPILE_ROOT}/codeaster-prerequisites-${VERSION_CAS}-oss
PYVENV_CAS=${COMPILE_ROOT}/venv
PYTHON39=${HOME}/python-build/python39
ACFL_TO_GCC_LINK=${COMPILE_ROOT}/acfl_bin
ACFL_DIR=/tools/acfl/24.04/arm-linux-compiler-24.04_AmazonLinux-2
MPI_DIR=/tools/openmpi/4.1.7/acfl/24.04

# Install boost root 
#  wget https://archives.boost.io/release/1.87.0/source/boost_1_87_0.tar.bz2
#  tar --bzip2 -xf boost_1_87_0.tar.bz2
#  cd boost_1_87_0
#  ./bootstrap.sh --prefix=${HOME}/boost-build -with-libraries=python
#  ./b2 install
export BOOST_ROOT=${HOME}/boost-build

# CMAKE https://github.com/Kitware/CMake/releases/download/v3.31.4/cmake-3.31.4-linux-aarch64.sh
export PATH=${HOME}/cmake-3.31.4-linux-aarch64/bin:$PATH

# We install miniconda
if [ 1 == 0 ]; then
  mkdir -p ~/miniconda3
  wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh -O ~/miniconda3/miniconda.sh
  bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
  rm ~/miniconda3/miniconda.sh
  source ~/miniconda3/bin/activate
  conda create -n codeaster_build python=3.9 -y
fi

# We install python3.9.17 with staticlibs
if [ ! -d "${PYTHON39}" ] ; then
  mkdir -p ${PYTHON39} && cd ${PYTHON39}/../
  wget https://www.python.org/ftp/python/3.9.17/Python-3.9.17.tgz 
  tar -xzf Python-3.9.17.tgz
  cd Python-3.9.17
  ./configure --enable-shared --enable-optimizations --with-lto --prefix=${PYTHON39}
  make -j$(nproc)
  sudo make altinstall
fi

# PATH Setting UP
export PATH=${PYTHON39}/bin:${ACFL_TO_GCC_LINK}:${MPI_DIR}/bin:${PATH}
#LD_LIBRARY_PATH=${ACFL_DIR}/lib64:${MPI_DIR}/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=${PYTHON39}/lib:$LD_LIBRARY_PATH

# Module load
module unload all
module use /tools/acfl/24.10/modulefiles
module use /tools/acfl/24.04/modulefiles
module load acfl/24.04
module load openmpi/4.1.6

# PATH Setting UP
PATH=${PYVENV_CAS}/bin:${PATH}

# Preparing folder for compile env
if [ ! -d "${COMPILE_ROOT}" ]; then
  mkdir -p ${COMPILE_ROOT}/ && cd ${COMPILE_ROOT}/

  # Links up for compiler
  mkdir -p ${ACFL_TO_GCC_LINK}
  ln -s ${ACFL_DIR}/bin/armclang ${ACFL_TO_GCC_LINK}/gcc
  ln -s ${ACFL_DIR}/bin/armclang++ ${ACFL_TO_GCC_LINK}/g++
  ln -s ${ACFL_DIR}/bin/armflang ${ACFL_TO_GCC_LINK}/gfortran
  ln -s $PYTHON39/bin/python3.9 ${ACFL_TO_GCC_LINK}/python3

  # Prerequisites DL
  wget https://www.code-aster.org/FICHIERS/prerequisites/codeaster-prerequisites-${VERSION_CAS}-oss.tar.gz
  tar xzf codeaster-prerequisites-${VERSION_CAS}-oss.tar.gz
  cd ${WRKDIR} 

  # Python setup
  python3.9 -m venv --system-site-packages ${PYVENV_CAS}
  python3.9 -m pip install --upgrade pip 
  python3.9 -m pip install -r ${WRKDIR}/reqs/requirements_dev.txt
  mpi4py_spec=$(. ${WRKDIR}/VERSION ; printf "mpi4py==${MPI4PY}")
  python3.9 -m pip install "${mpi4py_spec}"
  python3.9 -m pip install "numpy"
else
  cd ${WRKDIR}
fi

echo "Do those command to continue : 
#make ROOT=${INSTALL_DIR} ARCH=gcc13-openblas-ompi4 RESTRICTED=0 check
#make ROOT=${INSTALL_DIR} ARCH=gcc13-openblas-ompi4 RESTRICTED=0 setup_venv
#make ROOT=${INSTALL_DIR} ARCH=gcc13-openblas-ompi4 RESTRICTED=0"
