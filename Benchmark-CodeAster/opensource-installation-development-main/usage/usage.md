# Using salome_meca

Summary

[[_TOC_]]

## Description of the SIF

The Singularity Image File is based on a Scibian9 OS. salome_meca is then installed
on the OS, along with its many prerequisites. Moreover, all the prerequisites in order
to compile code_aster are already present in the container.

A container may be used as a Linux binary. Such usage is similar to executing the
`appli_Vxxx/salome` script on a native Scibian9 installation.
Yet, it is strongly recommanded to employ the given launcher which results from the
installation procedure. Once installed, one may notice the presence of two files:

```bash
salome_meca-lgpl-2022.1.0-1-20221225-scibian-9
salome_meca-lgpl-2022.1.0-1-20221225-scibian-9.sif
```

> **NOTE:**
> Theses pages always refer to the last version of salome_meca et the prerequisites
> for the last development version.
>
> The previous containers are available from
> [Changelog of Singularity Images and prerequisites](./devel/changelog.md).

## Launching salome_meca

One may launch salome_meca by using such command :

```bash
./salome_meca-lgpl-2022.1.0-1-20221225-scibian-9
```

In order to the display the different options of the script, one may use the `--help` option:

```bash
./salome_meca-lgpl-2022.1.0-1-20221225-scibian-9 --help
```

## Example

In order to star a text-mode SALOME session :

```bash
./salome_meca-lgpl-2022.1.0-1-20221225-scibian-9 -- start --port=2877 -t
```

Excuting a Python script within a SALOME _shell_ session using a previous SALOME session :

```bash
./salome_meca-lgpl-2022.1.0-1-20221225-scibian-9 -- shell --port=2877 -- python3 my-script.py
```

Terminating a SALOME session

```bash
./salome_meca-lgpl-2022.1.0-1-20221225-scibian-9 -- kill 2877
```

## Launcher options

- `-s/--soft`

  By default, the launcher will try to use GPU acceleration. However, this option is only
  available for NVIDIA cards. If you're using a non-Nvidia GPU, one may use the `--soft`
  option which renders a CPU-based graphical acceleration using the MESA libraries.
  Performance within SALOME is not as good as with GPU but up to 500K nodes, it is still
  bearable for the viewer. Furthermore, it does not influence code_aster's performances
  at all.

- `--no-scratch`

  During a simulation, it might be necessary to write temporary files on the hard drive
  i.e. swapping. In Scibian, the defaut `/tmp` directory is rather small size-wise and
  as a consequence, salome_meca will try to write in `/local00/tmp`.
  Thus, if necessary, --no scratch will cancel this auto-mounted drive.
  See [What is a directory binding?][1].

- `--no-prefs`

  Some sofwares, when executing within the containze, may use specific user preferences
  which may be incompatible with the host machine : _Salome_, _Firefox_ (in order to
  access the documentation). Yet, modifying these parameters on the host machine may
  cause issues with its usage on the host machine. Thus, the contain is using its own
  set of parameters for `.config`, `.gnome` and `.mozilla` directories. They are binded
  from `.$HOME/.config/aster/salome_meca-lgpl-2021` One may use the option `--no-prefs`
  to undo the binding. See [What is a directory binding?][1].

## Launcher options - For developers

- `-B/--bind`

  This option allows the binding of files or directories. It is identical to the one
  available within Singularity (cf. `singularity exec --help`).
  See [What is a directory binding?][1].

  One can replace a file or directory within the container using such option.
  Thus, for instance, on can replace a product within the plateform by a newer version
  of the same product. Yet, this option only works as long as the new version is
  compatible with the other products within the container.

  Since the launcher is copied on the host machine at the end of the isntallation
  procedure, one may modify the script if needed.

- `--shell`

  This option starts a shell (bash) session within the container instead of
  luunching salome_meca :

  `./salome_meca-lgpl-2022.1.0-1-20221225-scibian-9 --shell` starts a bash session.

  `./salome_meca-lgpl-2022.1.0-1-20221225-scibian-9 -- shell` starts a bash session in
  salome_meca's environment.

- `--config_file`

  The configuration parameters of the laucher are, by default, saved in
  `$HOME/.config/aster/salome_meca-lgpl-2021.json`. With this option, one may
  specify another location.

- `--list`

  This options lists all the productions (modules or plugins) available in the launcher using such convention :

  `--product-name   local-path:container-path`

  `container-path` is the product's installation directory within the container.
  and `local-path` is the one on the host's machine.

[1]: ./faq.md#what-is-a-directory-binding
