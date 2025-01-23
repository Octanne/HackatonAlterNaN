# Frequently Asked Questions

Summary

[[_TOC_]]

## Documentation can't be accessed

From AsterStudy, the documentation can't be accessed
using a container, for technical reasons.

One must open the _File_ menu then _Preferences_. In _SALOME_, ensure that there
is `/usr/bin/firefox` for _External browser/Application_.

Then if the page stays blank when the documentation is opened, it is probably
caused by a proxy setting, which depends on your network system.

## Launching the SIF file fails

Executing the contain fails :

```bash
$ ./salome_meca-lgpl-2022.1.0-1-20221225-scibian-9.sif
/usr/bin/env: run-singularity: Aucun fichier ou dossier de ce type
```

Singularity package is not installed properly. Furthermore, it is strongly recommended
to use the given script launcher which
allows to control the GPU acceleration and _mount_ specific directories.

## GPU acceleration is not active

When launching salome_meca using the container, such display is given :

```none
INFO:    Could not find any nv files on this host!
WARNING: Could not find any nv libraries on this host!
WARNING: You may need to manually edit /usr/local/etc/singularity/nvliblist.conf
*****************************************************
INFO : Running salome_meca in software rendering mode
*****************************************************
```

By default, the launches tries to use GPU acceleration. However, this feature is
only available for Nvidia devices. Hence, if one does not have one, a sofware rendering
will be employed (instead of crashing salome_meca!). If you're using Windows, the
software rendering is mandatory.

The given message is there to inform you that no driver was found for the NVidia device.
One may use the `--soft` option of the launcher in order to avoid this _warning_ and
automatically enforce the _software rendering mode_.
See [Launcher options](./usage.md#launcher-options).

## What is a directory binding?

Executing an application within a container allows to fully separate the software,
its environment, and the environment on the host machine. For instance, the content
of `/usr/bin` on the host machine cannot be accessed with the container as the SIF
has its own file system.

Yet, it is possible to grant access to specific directories located on the host machine
to the conatiner. Fo instance, the `$HOME` directory is by default shared between host
machine and the container. Moreover, for practical reasons, it is also located in
the `$HOME` directory of the container.

Other files or directories can also be shared : it is referred to as _binding_.
For instance, one may want to acces the `/local00/tmp/utility-1.0` directory on the
host machine within the container. Using the right _binding_ command, it can be
shared in a directory within the container, such as `/opt/utility`.
