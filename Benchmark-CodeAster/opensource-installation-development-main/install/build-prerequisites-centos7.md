# Compiling prerequisites on CentOS7

Summary

[[_TOC_]]

> These instructions are related to CentOS 7 but it should be very similar on
> all other CentOS/RedHat/Fedora distributions.

Download the archive containing the sources of the prerequisites that are expected
by the development version of code_aster you want to build.

The `codeaster-prerequisites-XXX-oss` archives are available on the
[Changelog of Singularity Images and prerequisites](../devel/changelog.md).
Example, download `codeaster-prerequisites-20220817-oss` archive to build code_aster 16.3.0.

## Installing base system utilities with yum

```shell
sudo yum install cmake3 bison flex tk swig3
sudo ln -s $(which cmake3) /usr/local/bin/cmake
sudo ln -s $(which ctest3) /usr/local/bin/ctest
```

## Installing compilers and some libraries with yum

```shell
sudo yum install centos-release-scl-rh devtoolset-8-toolchain
sudo yum install zlib-devel libxml2-devel atlas-devel
sudo yum install rh-git227
```

- `rh-git227` provides a recent git version.
- openblas not installed since atlas comes with scipy.

## Installation MPI runtime and libraries with yum

```shell
sudo yum install openmpi-devel
sudo ln -s /usr/lib64/openmpi/bin/mpiexec /usr/local/bin/mpiexec
```

- Prefer install OpenMPI 4 from source (default package is OpenMPI 1!).
- Wrappers available from `/usr/lib64/openmpi/bin`.

## Installing Python and related packages with yum

```shell
sudo yum install python3-devel python36-scipy scipy Cython python36-Cython
```

## Installing Boost packages (for medcoupling) with yum

```shell
sudo yum install \
    boost169-python3-devel boost169-filesystem boost169-regex \
    boost169-system boost169-thread boost169-date-time \
    boost169-chrono boost169-serialization
```

- Create `/opt/aster/boost/{include,lib}`
- `ln -s /usr/lib64/libboost* /opt/aster/boost/lib/`
- `ln -s libboost_xxx.so.1.69.0 libboost_xxx.so`

## Building code_aster prerequisites

See the
[same how-to on Debian](build-prerequisites-debian11.md#building-codeaster-prerequisites)
and before starting the compilation define the environment using:

```bash
scl enable devtoolset-8 bash
export PATH=$PATH:/usr/lib64/openmpi/bin

cd codeaster-prerequisites-<version>-oss
sed -i -e 's#-lopenblas#-L /usr/lib64/atlas -lsatlas#g' utils/general.sh
sed -i -e 's#LIBPATH="#LIBPATH="/usr/lib64/atlas #g' \
       -e 's#maths-libs=auto#maths-libs="scalapack satlas"#g' src/mumps.sh
sed -i -e "s#centos8#$(uname -n)#g" utils/generate_env.py

cat << eof >> utils/build_env.sh

CA_CFG_MEDCOUPLING=( "-DBOOST_ROOT=/opt/aster/boost" )
eof
```

and then, start the compilations with:

```shell
make ROOT=/opt/aster ARCH=gcc8-atlas-ompi RESTRICTED=0
```
