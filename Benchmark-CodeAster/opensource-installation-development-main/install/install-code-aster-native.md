# Compiling code_aster from scratch

Summary

[[_TOC_]]

> **NOTE**
>
> Compiling prerequisites from scratch is reserved to advanced users with skills in
> computer science.
>
> The recommended way for the most of the usecases is to
> [compile code_aster in the container environment](../devel/compile.md).

## Installation of the prerequisites

The archives of the sources of the prerequisites are available from the
[Changelog of Singularity Images and prerequisites](../devel/changelog.md).

See [Compiling prerequisites on Debian 11][deb11] and
[Compiling prerequisites on CentOS 7][centos7] depending on your platform to
install code_aster prerequisites.
For CentOS, see also [the specific commands to be used](install-code-aster-native-centos7.md).

[deb11]: build-prerequisites-debian11.md
[centos7]: build-prerequisites-centos7.md

## Installation of code_aster from sources

### Cloning the code_aster source repository

```bash
mkdir -p $HOME/dev/codeaster
cd $HOME/dev/codeaster
git clone https://gitlab.com/codeaster/src.git
```

### Configuring the version

This step is necessary to tell code_aster where the prerequisites have been
installed. An environment file has been created during the installation of the
prerequisites as `/opt/aster/<prereq-version>/<arch>/<hostname>_mpi.sh`

Source this file and the process will be fully automatic:

```bash
. /opt/aster/*/*/*_mpi.sh
```

Then, the configuration is done with:

```bash
cd $HOME/dev/codeaster/src
./configure --prefix=/opt/aster/install/mpi
# or
./waf configure --prefix=/opt/aster/install/mpi
```

### Compiling code_aster

```bash
cd $HOME/dev/codeaster/src
make
# or
./waf install -j $(nproc)
```

### Alternative commands

By default the installation directory is `$HOME/dev/codeaster/install/mpi`
which is convenient for daily development.
In this case, you can just configure, build and install in one step:

```bash
cd $HOME/dev/codeaster/src
make bootstrap
```

See `make help` to see more options (for example, to build a version with
debugging symbols).

## Validation

Passing testcases of the _submit_ list:

```bash
/opt/aster/install/mpi/bin/run_ctest -L submit -LE need_data --resutest=/tmp/resu_submit --timefactor=3
```

A full validation is necessary before considering the installation as qualified.

At the time of writing this article, it still remains issues with recent GNU Compilers
(9.x, 10.x) that must be investigated.
