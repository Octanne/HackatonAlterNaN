#:q!/bin/bash

# Variables
VERSION_CAS=20240327
COMPILE_ROOT=${HOME}/ACFL_CodeAster
INSTALL_DIR=${COMPILE_ROOT}/aster
WRKDIR=${COMPILE_ROOT}/codeaster-prerequisites-${VERSION_CAS}-oss
PYVENV_CAS=${COMPILE_ROOT}/venv
PYTHON39=${HOME}/modules_locales/python-build/python39
ACFL_TO_GCC_LINK=${COMPILE_ROOT}/acfl_bin
ACFL_DIR=/tools/acfl/24.10/arm-linux-compiler-24.04_AmazonLinux-2
MPI_DIR=/tools/openmpi/4.1.7/acfl/24.04

# Install boost root 
#  wget https://archives.boost.io/release/1.87.0/source/boost_1_87_0.tar.bz2
#  tar --bzip2 -xf boost_1_87_0.tar.bz2
#  cd boost_1_87_0
#  ./bootstrap.sh --prefix=${HOME}/boost-build -with-libraries=python,filesystem,regex,system,thread,date_time,chrono,serialization --with-python=python3.9
#  ./b2 python=3.9 include=${HOME}/python-build/python39/include/python3.9 library-path=${HOME}/python-build/python39/lib/python3.9 --prefix=${HOME}/boost-build
#  ./b2 install -j6 --prefix=${HOME}/boost-build
#export BOOST_ROOT=${HOME}/boost-build

# Install metis 5
# wget https://github.com/KarypisLab/METIS/archive/refs/tags/v5.1.1-DistDGL-v0.5.tar.gz
# tar -xvzf v5.1.1-DistDGL-v0.5.tar.gz
# cd METIS-5.1.1-DistDGL-v0.5/
# cd GKLib
# wget https://github.com/KarypisLab/GKlib/archive/refs/tags/METIS-v5.1.1-DistDGL-0.5.tar.gz
# tar -xvzf METIS-v5.1.1-DistDGL-0.5.tar.gz
# mv GKlib-METIS-v5.1.1-DistDGL-0.5/* .
# cd ../
# make config shared=1 cc=gcc prefix=${HOME}/metis-build
# make install
#export C_INCLUDE_PATH=${HOME}/metis-build/include:$C_INCLUDE_PATH
#export CPLUS_INCLUDE_PATH=${HOME}/metis-build/include:$CPLUS_INCLUDE_PATH
#export LIBRARY_PATH==${HOME}/metis-build/lib:$LIBRARY_PATH
#export LD_LIBRARY_PATH=${HOME}/metis-build/lib:$LD_LIBRARY_PATH
#export CPATH=${HOME}/metis-build/include:$CPATH

# CMAKE https://github.com/Kitware/CMake/releases/download/v3.31.4/cmake-3.31.4-linux-aarch64.sh
#export PATH=${HOME}/cmake-3.31.4-linux-aarch64/bin:$PATH

# We install miniconda
#  mkdir -p ~/miniconda3
#  wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh -O ~/miniconda3/miniconda.sh
#  bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
#  rm ~/miniconda3/miniconda.sh
#  source ~/miniconda3/bin/activate
#  conda create -n codeaster_build python=3.9 -y

# We install python3.9.17 with staticlibs
#if [ ! -d "${PYTHON39}" ] ; then
#  mkdir -p ${PYTHON39} && cd ${PYTHON39}/../
#  wget https://www.python.org/ftp/python/3.9.17/Python-3.9.17.tgz 
#  tar -xzf Python-3.9.17.tgz
#  cd Python-3.9.17
#  ./configure --enable-shared --enable-optimizations --with-lto --prefix=${PYTHON39}
#  make -j$(nproc)
#  sudo make altinstall
#fi

# PATH Setting UP
#LD_LIBRARY_PATH=${ACFL_DIR}/lib64:${MPI_DIR}/lib:$LD_LIBRARY_PATH
#export LD_LIBRARY_PATH=${PYTHON39}/lib:$LD_LIBRARY_PATH
export PATH=${ACFL_TO_GCC_LINK}:${PATH}

# Module load
module purge
module unuse /tools/acfl/24.04/modulefiles
module unuse ${HOME}/modules_locales/modulefiles 
module use /tools/acfl/24.04/modulefiles
module use ${HOME}/modules_locales/modulefiles
module load acfl/24.04
module load acfl-24.04/openblas/r0.3.20
module load acfl-24.04/openmpi/4.1.7
module load acfl-24.04/boost-libs/1.73.0
module load python/3.9
module load cmake/3.31.4

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
  #ln -s $PYTHON39/bin/python3.9 ${ACFL_TO_GCC_LINK}/python3

  # For BLACS in Scalapack adding :
  # -DCMAKE_C_FLAGS="${CFLAGS} -fpermissive -Wno-error=implicit-function-declaration" \

  # For MUMPS : 
  # Uncomment line 106 of src/mumps.sh
  
  # For Miss3d :
  # sed -i "s/-mcmodel=medium/-mcmodel=small/g" src/Makefile.inc to src/miss3d.sh
  # sed -i "s/-fdefault-double-8//g" src/Makefile.inc to src/miss3d.sh
  # sed -i "s/-fdefault-real-8//g" src/Makefile.inc to src/miss3d.sh
  # sed -i "s/-fdefault-integer-8//g" src/Makefile.inc to src/miss3d.sh


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

# We have to do this cmd :
# /fsx/home/etud2-2/ACFL_CodeAster/codeaster-prerequisites-20240327-oss/.venv_petsc/bin/python3 -m pip install numpy

echo "Do those command to continue : 
#make ROOT=${INSTALL_DIR} ARCH=acfl24-openblas-ompi4 RESTRICTED=0 check
#make ROOT=${INSTALL_DIR} ARCH=acfl24-openblas-ompi4 RESTRICTED=0 setup_venv
#make ROOT=${INSTALL_DIR} ARCH=acfl24-openblas-ompi4 RESTRICTED=0"
