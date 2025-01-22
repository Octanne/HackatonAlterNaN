# Start with an Ubuntu base image
FROM debian:11

# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

# Install apt packages requirement
RUN apt-get update && apt-get upgrade -y && \
    apt install -y \
    metis \
    libmetis5 \
    libmetis-dev \
    apt-utils \
    aspell \
    aspell-fr \
    bash-completion \
    bison \
    ccache \
    clang-13 \
    clang-format-13 \
    cmake \
    curl \
    flex \
    g++ \
    gcc \
    gdb \
    gettext \
    gfortran \
    git \
    graphviz \
    imagemagick \
    less \
    libboost-chrono-dev \
    libboost-date-time-dev \
    libboost-filesystem-dev \
    libboost-python-dev \
    libboost-regex-dev \
    libboost-serialization-dev \
    libboost-system-dev \
    libboost-thread-dev \
    libglu1-mesa \
    libncurses5 \
    libomp-13-dev \
    libopenblas-dev \
    libopenmpi-dev \
    libunwind-dev \
    libxcursor1 \
    libxml2-dev \
    lmod \
    locales \
    mercurial \
    nano \
    net-tools \
    openmpi-bin \
    pkg-config \
    procps \
    python3-dev \
    python3-numpy \
    python3-pip \
    python3-scipy \
    python3-sphinx \
    python3-texext \
    python3-venv \
    python3-yaml \
    swig \
    tk \
    valgrind \
    vim \
    wget \
    zlib1g-dev \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/tmp/*

# Building code_aster prerequisites
RUN mkdir -p /opt/aster && \
	chown $(id -nu):$(id -ng) /opt/aster -R

# Cloning the code_aster source repository
RUN mkdir -p /root/dev/codeaster
WORKDIR /root/dev/codeaster
RUN git clone https://gitlab.com/codeaster/src.git

WORKDIR /root
ENV VERSION_CAS=20240327
# Download and untar codeaster-prerequisites-20240327-oss
RUN wget https://www.code-aster.org/FICHIERS/prerequisites/\
codeaster-prerequisites-${VERSION_CAS}-oss.tar.gz && \
	tar xzf codeaster-prerequisites-${VERSION_CAS}-oss.tar.gz
WORKDIR /root/codeaster-prerequisites-${VERSION_CAS}-oss

# We activate the use of system libmetis-dev
RUN sed -i 's|#LMETIS     = -L\${DEST}/metis-\${METIS}/lib -lmetis|LMETIS     = -L${DEST}/metis-${METIS}/lib -lmetis # This line was been uncommented|' src/mumps.sh

# We replace medium -mcmodel by large because medium not support in ARM gfortran
RUN sed -i '33i sed -i "s/-mcmodel=medium/-mcmodel=small/g" src/Makefile.inc' src/miss3d.sh

# Start compilation
#RUN make ROOT=/opt/aster ARCH=gcc10-openblas-ompi4 RESTRICTED=0
#RUN make ROOT=/opt/aster ARCH=gcc-atlas-ompi RESTRICTED=0
#RUN make ROOT=/opt/aster ARCH=gcc10-openblas-seq

# We source the prerequisites and compile
#WORKDIR /root/dev/codeaster
#RUN . /opt/aster/*/*/*_mpi.sh && \
#	cd $HOME/dev/codeaster/src && \
#	./configure --prefix=/opt/aster/install/mpi && \
#	cd $HOME/dev/codeaster/src && \
#	make

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]

