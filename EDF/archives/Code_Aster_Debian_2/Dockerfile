# Utiliser une image de base Debian
FROM debian:11

# Configuration de l'environnement
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV PETSC_ARCH=arch-linux-c-opt
ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH

# Installer les dépendances
RUN apt-get update && apt-get install -y \
    cmake bison flex tk swig zlib1g-dev libxml2-dev libopenblas-dev \
    python3 python3-dev python3-pip python3-numpy python3-scipy cython3 \
    git wget tar build-essential gfortran \
    libboost-dev libboost-python-dev libboost-filesystem-dev \
    libboost-regex-dev libboost-system-dev libboost-thread-dev \
    libboost-date-time-dev libboost-chrono-dev libboost-serialization-dev \
    openmpi-bin libopenmpi-dev libmetis-dev libmumps-dev libsuperlu-dev \
    libscalapack-mpi-dev libblas-dev liblapack-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Télécharger et installer PETSc
WORKDIR /tmp
RUN wget https://web.cels.anl.gov/projects/petsc/download/release-snapshots/petsc-3.22.2.tar.gz && \
    tar -xzf petsc-3.22.2.tar.gz && cd petsc-3.22.2 && \
    export PETSC_DIR=$(pwd) && \
    ./configure --prefix=/opt/aster/petsc --with-mpi=1 && \
    make && make install && \
    rm -rf /tmp/petsc-3.22.2*

# Créer les répertoires pour Code_Aster
RUN mkdir -p /opt/aster/boost/include /opt/aster/boost/lib /opt/aster/codeaster-prerequisites

# Définir les répertoires pour la bibliothèque Boost
RUN ln -s /usr/lib/x86_64-linux-gnu/libboost* /opt/aster/boost/lib/

# Configurer l'environnement OpenMPI
ENV PATH=$PATH:/usr/lib/x86_64-linux-gnu/openmpi/bin

# Répertoire de travail par défaut
WORKDIR /opt/aster

CMD ["/bin/bash"]
