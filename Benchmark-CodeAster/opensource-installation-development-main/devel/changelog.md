# Changelog of Singularity Images and prerequisites

Summary

[[_TOC_]]

Voir [Compiling code_aster development version](./compile.md).

## Availability

The Singularity containers are available for download from the
[code_aster website](https://www.code-aster.org).

The images name is built this manner:

```none
salome_meca-lgpl-<salome_meca version>-<packaging>-<prerequisites version>-<base os>.sif
```

The last available images are based on salome_meca 2023, **recommended version**.

The last container embedding salome_meca 2022 was:
[salome_meca-lgpl-2022.1.0-1-20221225-scibian-9](https://www.code-aster.org/FICHIERS/singularity/salome_meca-lgpl-2022.1.0-1-20221225-scibian-9.sif),
it contains prerequisites version `20221225`.

The last container embedding salome_meca 2021 was:
[salome_meca-lgpl-2021.1.0-2-20220817-scibian-9](https://www.code-aster.org/FICHIERS/singularity/salome_meca-lgpl-2021.1.0-2-20220817-scibian-9.sif),
it contains prerequisites version `20220817`.

The last container embedding salome_meca 2020 was:
[salome_meca-lgpl-2020.0.1-1-scibian-9](https://www.code-aster.org/FICHIERS/singularity/salome_meca-lgpl-2020.0.1-1-scibian-9.sif),
it contains prerequisites version `20210414`.

A container is valid to build a development version of code_aster up to it is
replaced by the next one.

Example: To build the version 16.0.10, the image named `20210811` must be downloaded.

## Version 17

- starting from 17.0.13 :
  [salome_meca-lgpl-2023.1.0-4-20240327-scibian-10](https://www.code-aster.org/FICHIERS/singularity/salome_meca-lgpl-2023.1.0-4-20240327-scibian-10.sif)

  (sources of prerequisites: [codeaster-prerequisites-20240327-oss](https://www.code-aster.org/FICHIERS/prerequisites/codeaster-prerequisites-20240327-oss.tar.gz))

## Version 16

- starting from 16.3.2:
  [salome_meca-lgpl-2022.1.0-1-20221225-scibian-9](https://www.code-aster.org/FICHIERS/singularity/salome_meca-lgpl-2022.1.0-1-20221225-scibian-9.sif)

  (sources of prerequisites: [codeaster-prerequisites-20221225-oss](https://www.code-aster.org/FICHIERS/prerequisites/codeaster-prerequisites-20221225-oss.tar.gz))

- starting from 16.2.4:
  [salome_meca-lgpl-2021.1.0-2-20220817-scibian-9](https://www.code-aster.org/FICHIERS/singularity/salome_meca-lgpl-2021.1.0-2-20220817-scibian-9.sif)

  (sources of prerequisites: [codeaster-prerequisites-20220817-oss](https://www.code-aster.org/FICHIERS/prerequisites/codeaster-prerequisites-20220817-oss.tar.gz))

- starting from 16.1.13:
  [salome_meca-lgpl-2021.1.0-1-20220405-scibian-9](https://www.code-aster.org/FICHIERS/singularity/salome_meca-lgpl-2021.1.0-1-20220405-scibian-9.sif)

- starting from 16.0.12:
  [salome_meca-lgpl-2021.0.0-2-20211014-scibian-9](https://www.code-aster.org/FICHIERS/singularity/salome_meca-lgpl-2021.0.0-2-20211014-scibian-9.sif)

- starting from 16.0.6:
  [salome_meca-lgpl-2021.0.0-1-20210811-scibian-9](https://www.code-aster.org/FICHIERS/singularity/salome_meca-lgpl-2021.0.0-1-20210811-scibian-9.sif)

- starting from 16.0.0:
  [salome_meca-lgpl-2021.0.0-0-20210601-scibian-9](https://www.code-aster.org/FICHIERS/singularity/salome_meca-lgpl-2021.0.0-0-20210601-scibian-9.sif)

## Version 15

- starting from 15.3.17:
  [salome_meca-lgpl-2021.0.0-0-20210601-scibian-9](https://www.code-aster.org/FICHIERS/singularity/salome_meca-lgpl-2021.0.0-0-20210601-scibian-9.sif)

The oldest image is:
[salome_meca-lgpl-2020.0.1-1-scibian-9](https://www.code-aster.org/FICHIERS/singularity/salome_meca-lgpl-2020.0.1-1-scibian-9.sif) (with prerequisites `20210414`).
