# Compiling code_aster from scratch on CentOS7

[inst-deb11]: install-code-aster-native.md
[deb11]: build-prerequisites-debian11.md
[centos7]: build-prerequisites-centos7.md

> Please refer to [Compiling code_aster (on Debian11)][inst-deb11] for the
> steps to follow.
> This test has been done on a temporary virtual machine with non-packaged
> installation and without properly modules environment.
> That's why some commands are complicated or verbosy.

Summary

[[_TOC_]]

See also [Compiling prerequisites on CentOS 7][centos7] to install code_aster prerequisites.

## Installation of code_aster from sources

On CentOS with this [installation of prerequisites][centos7],
The build environment setting is more complicated because of non-standard paths
to find the compilers and some basic tools:

```bash
scl enable devtoolset-8 bash
export PATH=$PATH:/usr/lib64/openmpi/bin
export PATH=$PATH:/opt/rh/rh-git227/root/bin
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/lib64/openmpi/lib
```

### Cloning the code_aster source repository

Thanks to the previous line `git` is now available.
See [generic section](install-code-aster-native.md#cloning-the-code_aster-repository).

### Configuring the version

As in the [generic section](install-code-aster-native.md#configuring-the-version)
by sourcing this file and the process will be fully automatic:

```bash
. /opt/aster/*/*/*_mpi.sh
```

This example uses the `atlas` libraries. So the configuration command line
should tell the mathematical libraries to be used:

```bash
cd $HOME/dev/codeaster/src
./waf configure --maths-libs="scalapack satlas" --prefix=/opt/aster/install/mpi
```

### Compiling code_aster and validation

See [generic sections](install-code-aster-native.md#compiling-code_aster).
