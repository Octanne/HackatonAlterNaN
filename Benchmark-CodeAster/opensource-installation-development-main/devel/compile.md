# Compiling code_aster development version in the container environment

One may want to use compile a more recent version of code_aster.
The container is ready for such usage as it comes along with all the prerequisites!

Summary

[[_TOC_]]

> **NOTE**
>
> Previous step required:
> [Download and install the container](../install/installation_linux.md).
>
> To build older versions of code_aster, choose the container following the
> [Changelog of Singularity Images and prerequisites](./devel/changelog.md).

## Preparing the access to the container

It is important to work in the container since the environment is all prepared in
order to compile code_aster.

For sake of simpliciy, one might want to be able to use the container without actually
being in the container's directory. This can be done by adding the script to the
`$PATH` environment variable on the host machine. For instance, one can add
`$HOME/bin` to `$PATH` in one's `.bashrc` by simply adding this line :

```bash
export PATH=${HOME}/bin:${PATH}
```

Then, make a symbolic link to the container in `$HOME/bin` :

```bash
mkdir -p ${HOME}/bin
cd ${HOME}/bin
ln -s ${HOME}/containers/salome_meca-lgpl-2022.1.0-1-20221225-scibian-9 .
```

The last line implies that the container was installed in `${HOME}/containers/`.

To test it out, one can open a new terminal and determine whether the container
can be launched from any diretory:

```bash
salome_meca-lgpl-2022.1.0-1-20221225-scibian-9 --help
```

## Working _within_ the container

It is important to be working in the container since the environment is all prepared
for a painless code_aster compilation _from scratch_ . Thus, one must use a shell
session within the container :

```bash
salome_meca-lgpl-2022.1.0-1-20221225-scibian-9 --shell
```

## Creating the code_aster repositories

First, let's create a directory for the repositories:

```bash
mkdir -p $HOME/dev/codeaster
```

Then, let's clone the repositories from GitLab.com:

```bash
cd $HOME/dev/codeaster
git clone https://gitlab.com/codeaster/src.git
git clone https://gitlab.com/codeaster/devtools.git
```

---
**NOTE:**

In order to clone the repositories, one must be able to access <https://gitlab.com>.
Thus, it may be necessary to set your proxy beforehand.

This operation may take some time since code_aster has a long history!

---

## Building codeaster

In the container's shell, it is quite straightforward :

```bash
cd $HOME/dev/codeaster/src
./waf configure
./waf install -j 4
```

Parameter 4 implies that the code will be compiled in parallel, using 4 procs.
One may modify it to any other number, depending on the machine employed.

## What's different when using a container

A container has its own environment and as a consequence, within the container,
one cannot access the system on the host machine. For instance, if you use a specific
text editor on your host machine, you cannot use it in the container!

Habits must this be changed : it it possible to use two terminal windows: one in the
container for compilation and another one, on the host machine in order to access de
source code with one's favorite editor. If needed, on can _bind_ specific folders
in order to access them within the container.

For instance, if on wants to access a USB stick mounted on the host machine in
`/media/user/USB500`, one can use such command in order to enter the container with
access to the USB stick :

```bash
salome_meca-lgpl-2022.1.0-1-20221225-scibian-9 --bind /media/user/USB500 --shell
# the stick can now be accessed in /media/user/USB500...
```

and if one would rather mount it in `/data` instead :

```bash
salome_meca-lgpl-2022.1.0-1-20221225-scibian-9 --bind /media/user/USB500:/data --shell
# the stick can now be accessed in /data...
```

## Using the development version

Whether, you're using the _old school_ astk or AsterStudy within salome_meca, the
development version is already made available in the container.
Simply choose `DEV` version.

However this automatic detection takes for granted that your installation is located
in `$HOME/dev/codeaster/install/std/share/aster` which is the usual directory if you
cloned the repositories in `$HOME/dev/codeaster`. If it's not the case, one only
has to modify the last line of the file `$HOME/.astkrc/prefs` (within the container
as it is located somewhere else on the host machine! ) accordingly.

For instance, we put in `~/.astkrc/prefs`:

```none
vers : DEV:$HOME/dev/codeaster/install/std/share/aster
vers : DEV_MPI:$HOME/dev/codeaster/install/mpi/share/aster
```

In salome_meca you will not be prompted for a development version when starting
AsterStudy, but it will be available in the _History View_ tab.

To test the catalogue in AsterStudy, it suffices to add it in _File > Preferences > AsterStudy > Catalogs_ in salome_meca.

Enjoy!

## Additional functionality

### Launch of test cases

A functionality has been added to quickly run a test case.

We can repeat the `-n|--name` option to run several. The idea is not to replace an `astout` but to have a very quick way to verify a test.

```none
$ ./waf test -n sslp114a -n ssnv15a

Waf: Entering directory `/home/courtois/dev/codeaster/src/build/release'
destination of output files: /tmp/runtest_pp3IwA
running zzzz100c in 'release'
`- output in /tmp/runtest_pp3IwA/zzzz100c.output
`- exit 0
running zzzz100d in 'release'
`- output in /tmp/runtest_pp3IwA/zzzz100d.output
`- exit 4
Waf: Leaving directory `/home/courtois/dev/codeaster/src/build/release'
'test' finished successfully (2.134s)
```

In this example, we see a test that worked (`exit 0`), one that failed (`exit 4` appears in red). This is the return code of `as_run`. Another possible value is `nook` (in red).

The tests are run interactively. The results are stored in a temporary directory provided by the system.

The `waf test_debug` command works the same way using the executable installed via `waf install_debug`.

Additional options:

- `--exectool=debugger`: executes the test case in the _debugger_ as configured in `astk/as_run`.
- `--exectool=valgrind`: executes `valgrind` (or another tool) as configured in `astk/as_run`.

These options are normally used with the **debug** variant, so with `waf test_debug`.

Example:

> ```sh
> waf test_debug --exectool=debugger -n sslp114a
> ```

## Advanced container configuration for development

### Isolated host machine installation

By default, construction and installation are done respectively in `${HOME}/dev/codeaster/src/build` and `${HOME}/dev/codeaster/install`.
If you only use one configuration, you can skip this paragraph.

If you develop on the native configuration of your machine or in another container, you must avoid mixing them!
This is what the `-m/--mountdev` option of the launch script is for.
The two directories above will thus be _mount_ from `/local00/tmp/${USER}/. mounted/...` to be thus isolated.

We can start a shell in the container and check that the directories are well mounted (option `-v` or `-vv`) :

```sh
salome_meca-edf-XXXX -m -vv
```

If we have used the `--mountdev` option during construction, we have to remember to activate it also when we launch salome_meca.

### Configuration file

See `salome_meca-edf-XXXX --help`, the name of the configuration file is given.
We can add mount points in this file (JSON format).

We can see in this file that some directories (`mnt_config`) containing _user_ parameters are mounted in the subdirectory
`~/.config/aster/salome_meca-edf-XXXX`.
This allows them to be isolated and have a different configuration in the container.

Example: The fact that `~/.local` is isolated from the host machine allows us to install Python modules with _pip_ without risk of conflict if the versions of Python are different.

This also allows us to use specific values for certain tools.

File  `~/.config/aster/config.json` (in the container, either
`~/.config/aster/salome_meca-edf-XXXX/.config/aster/config.json` from the host):

```json
{
    "server" : [
        {
            "name": "*",
            "config": {
                "exectool": {
                    "memcheck": "valgrind --tool=memcheck --leak-check=full --error-limit=no --track-origins=yes"
                }
            }
        }
    ]
}
```

### Modified command prompt

To know immediately if we are in the container or not, in `~/.bashrc`, locate the first 4 lines defining `debian_chroot` below and add the following 4 lines:

```sh
# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi
if [ ! -z "${SINGULARITY_NAME}" ]; then
    debian_chroot="${SINGULARITY_NAME} "
    [ ${#SINGULARITY_NAME} -gt 25 ] && debian_chroot="...${SINGULARITY_NAME: -22} "
    export PROMPT_COMMAND=true
fi
```

The command prompt is thus modified and shows the image name :

```none
G79848@dsp0961317:~$ salome_meca-edf-2021.1.0-6-20220405-scibian-9 --shell
(...20210414-scibian-9.sif )G79848@dsp0961317:~$
```
