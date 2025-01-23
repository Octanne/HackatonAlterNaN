# Singularity Installation

Summary

[[_TOC_]]

The provided container is a Singularity container. It is are compatible
Singularity 3.5 and above. Some Linux distributions do not provide by
default such version. For instance, the version of Singularity available
in Ubuntu 18.04's repositories (package _singularity-container_) is
version 2.5.2. As a consequence one has to compile another version from
scratch.

First, try to installation Singularity from your packages manager.
Otherwise, it must be compiled from scratch.

Installation instructions are provided above but if is recommended to follow
complete instructions from the
[Singularity QuickStart Guide](https://sylabs.io/guides/latest/user-guide/quick_start.html).

## Ubuntu 18

The version of singularity available in apt is not recent enough and as
a consequence, singularity needs to be compiled from scratch.

## Ubuntu 20

The version of singularity available in apt is not recent enough and as
a consequence, singularity needs to be compiled from scratch.

## CentOS

If using CentOS, _EPEL_ package manager can be used in order to download
Singularity. One first needs to update the package-list and install
epel-release:

```bash
sudo dnf search epel
sudo dnf install epel-release
```

The packages list can then be updated as follows:

```bash
sudo dnf update
```

Finally, Singularity can be downloaded and installed, along with its
prerequisites:

```bash
sudo dnf install singularity
```

Adn you're done!

## Compile from scratch

> See the [Singularity User Guide](https://sylabs.io/guides/latest/user-guide/)
> of the latest version and up-to-date instructions.

Building Singularity v3.6.4 requires Go Language as a prerequisite
(version 1.14+). Hence, it is also mandatory to build this product, but
the process is painless. Go has its own prerequisites. If using a
Debian-like system:

```bash
sudo apt-get install -y build-essential libseccomp-dev pkg-config squashfs-tools cryptsetup
```

If using another distribution, the listed packages must of course be
installed.

Then, in order to compile Go, one must set two environment variables.
Here are the commands which can of course be modified to suit your
personal choices if needed:

```bash
echo 'export GOPATH=${HOME}/go' >> ~/.bashrc
echo 'export PATH=/usr/local/go/bin:${PATH}:${GOPATH}/bin' >> ~/.bashrc
source ~/.bashrc
```

Then, Go can be downloaded:

```bash
cd $HOME
wget https://golang.org/dl/go1.15.5.linux-amd64.tar.gz
tar -C ./ -xzf go1.15.5.linux-amd64.tar.gz
go version
```

Now that Go is available, Singularity's source code can be downloaded.
First, let's create a directory and then clone de source code using
git:

```bash
mkdir $HOME/dev && cd $HOME/dev
git clone https://github.com/sylabs/singularity.git && cd singularity
```

The current stable version is v3.7.0. In order to compile this version,
on must update the source code at the right revision (tag) using git:

```bash
git checkout v3.7.0
```

Finally, it is now possible to build Singularity:

```bash
./mconfig
cd ./builddir
make
sudo make install
```

Now, it is possible to verify whether installation was performed
correctly and the compiled version (v3.7.0) :

```bash
singularity version
```
