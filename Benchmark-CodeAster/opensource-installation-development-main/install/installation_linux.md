# Installation on Linux

> These guidelines are for a Linux Distribution. If you are trying to use the
> container with Windows using WSL2, please refer to the
> [Windows](./installation_windows.md) section instead.

Summary

[[_TOC_]]

## Installation directory

This documentation takes for granted that the installation directory of
the salome_meca container is within a user's directory, such as
`$HOME/containers`. The name of this directory can of
course be modified, but one needs to adapt accordingly the command
lines.

First, let's create the specified directory :

```bash
mkdir -p ${HOME}/containers
cd ${HOME}/containers
```

Unless duly noted, every operation aftwards is performed within this
directory.

## Singularity Installation

The provided container is a singularity container. It is are compatible
Singularity 3.5 and above.

First, try to installation Singularity from your packages manager.
Otherwise, it must be compiled from scratch.

See the [instructions to install Singularity](./singularity_installation.md).

## Dowloading the container

The Singularity Image File (SIF) must be downloaded locally. Wget can be
used in order to download it directly from code_aster's website :

```bash
wget -c https://www.code-aster.org/FICHIERS/singularity/salome_meca-lgpl-2022.1.0-1-20221225-scibian-9.sif
```

This is the last version as writing this page.

The images name is built this manner:

```none
salome_meca-lgpl-<salome_meca version>-<packaging>-<prerequisites version>-<base os>.sif
```

The filesize is significant (6 GB) and one may want to allow sufficient
time for such download. if the download fails for some reason, it can be
continued using the `wget -c` option.

## Post-install configuration

A salome_meca launcher file is located within the container. Hence, one
must copy the file on the local machine's directory. A script has been
prepared in order to do so.

```bash
singularity run --app install salome_meca-lgpl-2022.1.0-1-20221225-scibian-9.sif
```

You will see this output:

```none
Installation successfully completed.
To start salome_meca, just use:
  .../containers/salome_meca-lgpl-2022.1.0-1-20221225-scibian-9
or (in the installation directory):
  ./salome_meca-lgpl-2022.1.0-1-20221225-scibian-9

If you want to check your configuration, use:
  singularity run --app check salome_meca-lgpl-2022.1.0-1-20221225-scibian-9.sif
```

In order to display the different options of the launcher, one may use
`--help`:

```bash
./salome_meca-lgpl-2022.1.0-1-20221225-scibian-9 --help
```

salome_meca can then be launched simply by using this command:

```bash
./salome_meca-lgpl-2022.1.0-1-20221225-scibian-9
```

One may refer to [Using salome_meca](../usage/usage.md) in orded to learn
more about the launcher!
