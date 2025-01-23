# Compiling prerequisites

Summary

[[_TOC_]]

> These instructions are related to Debian 11 but it should be very similar on
> all other Debian-based distributions (for example Ubuntu).

Download the archive containing the sources of the prerequisites that are expected by the development version of code_aster you want to build.

The `codeaster-prerequisites-XXX-oss` archives are available on the [Changelog of Singularity Images and prerequisites](../devel/changelog.md). Example, download `codeaster-prerequisites-20220817-oss` archive to build code_aster 16.3.0.

## Installing base system utilities with apt

```shell
sudo apt install git cmake bison flex tk swig
```

## Installing compilers and some libraries with apt

```shell
sudo apt install gcc g++ gfortran libopenblas-dev zlib1g-dev libxml2-dev
```

## Installation MPI runtime and libraries with apt

```shell
sudo apt install libopenmpi-dev
```

## Installing Python and related packages with apt

```shell
sudo apt install python3-dev python3-scipy cython3
```

## Installing Boost packages (for medcoupling) with apt

```shell
sudo apt install \
    libboost-python-dev libboost-filesystem-dev libboost-regex-dev \
    libboost-system-dev libboost-thread-dev libboost-date-time-dev \
    libboost-chrono-dev libboost-serialization-dev
```

## Building code_aster prerequisites

> NB: Use the administrator account (`root`/`sudo`) for administration tasks.
> If you do not want to use your personnal account for the installation,
> create a dedicated one, for example, `aster`.

In this example, a standard `aster` account will be the owner of the installation of code_aster and the prerequisites.
The installation directory will be `/opt/aster` (it can be wherever `aster` has write access).

```shell
sudo mkdir -p /opt/aster
```

Then

```shell
sudo chown aster /opt/aster
```

or (to give the ownership, on files and directories recursively, to the current user on his/her primary group)

```shell
sudo chown $(id -nu):$(id -ng) /opt/aster -R
```

Download the packages containing the prerequisites:

```shell
cd $HOME
wget https://www.code-aster.org/FICHIERS/prerequisites/codeaster-prerequisites-20220817-oss.tar.gz
tar xzf codeaster-prerequisites-20220817-oss.tar.gz
```

- `20220817` is the _version_ of the prerequisites package.
  This number changes each time the code_aster dependencies change.
  It must be selected for the code_aster version to be built according the same rule as for the Singularity images (with the same naming convention).
  See [Changelog of Singularity Images and prerequisites](../devel/changelog.md).

Start the compilations:

```shell
cd codeaster-prerequisites-20220817-oss
make ROOT=/opt/aster ARCH=gcc10-openblas-ompi4 RESTRICTED=0
```

- `ROOT` is the installation directory.

- `ARCH` is used to select some options, composed by 3 fields:

  - `gcc` is the compiler type (alternative `intel`, the version should not be used).

  - `openblas` or `mkl` (see `doc/install-mkl.md` to use MKL).

  - `ompi`, `impi` or `seq` stand for OpenMPI, IntelMPI or a sequential build
    (the version should not be used).

- `RESTRICTED=0` is necessary to select the open-source versions.

In case of error, logfiles are available in `.build-<ARCH>` directory.
The working directory of the last built dependency is `.build-<ARCH>/content`.

## Alternative using GCC 9

To install and use version 9 by default:

```shell
sudo apt install gcc-9 g++-9 gfortran-9
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 30
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 20
sudo update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran-9 30
sudo update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran-10 20
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-10 20
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 30
sudo update-alternatives --install /usr/bin/cpp cpp /usr/bin/cpp-10 20
sudo update-alternatives --install /usr/bin/cpp cpp /usr/bin/cpp-9 30
```

Check:

```shell
$ mpif90 --version
GNU Fortran (Debian 9.3.0-22) 9.3.0
Copyright (C) 2019 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```
