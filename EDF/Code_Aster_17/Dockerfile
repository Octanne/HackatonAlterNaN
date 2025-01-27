# Start with an Ubuntu base image
FROM debian:12

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

# Setup GCC et FORTRAN 13
# Add the sid repository
RUN echo "deb http://ftp.de.debian.org/debian sid main" > /etc/apt/sources.list.d/sid.list
# Create a pinning file for low priority
RUN echo "Package: *\nPin: release o=Debian,a=sid\nPin-Priority: 100" > /etc/apt/preferences.d/sid
# Update package lists
RUN apt-get update && \
    apt-get install -t sid -y gcc-13 cpp-13 g++-13 gfortran-13 \
    clang-13 clang-format-13 libomp-13-dev && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 40 && \
    update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran-13 40 && \
    rm /usr/bin/cpp && rm /etc/alternatives/cpp && \
    update-alternatives --install /usr/bin/cpp cpp /usr/bin/cpp-13 40 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 40

# We set ENV VARS
ENV VERSION_CAS=20240327
ENV WRKDIR=/root/codeaster-prerequisites-${VERSION_CAS}-oss

# Building code_aster prerequisites
RUN mkdir -p /opt/aster && \
	chown $(id -nu):$(id -ng) /opt/aster -R

# Cloning the code_aster source repository
RUN mkdir -p /root/dev/codeaster
WORKDIR /root/dev/codeaster
RUN git clone https://gitlab.com/codeaster/src.git

# Download and untar codeaster-prerequisites-VERSION-oss
WORKDIR /root
RUN wget https://www.code-aster.org/FICHIERS/prerequisites/\
codeaster-prerequisites-${VERSION_CAS}-oss.tar.gz && \
	tar xzf codeaster-prerequisites-${VERSION_CAS}-oss.tar.gz
WORKDIR ${WRKDIR}

# We set PYTHON
ENV PATH=/opt/venv/bin:${PATH}
RUN \
    python3 -m venv --system-site-packages /opt/venv ; \
    python3 -m pip install --upgrade pip ; \
    python3 -m pip install -r ${WRKDIR}/reqs/requirements_dev.txt ; \
    mpi4py_spec=$(. ${WRKDIR}/VERSION ; printf "mpi4py==${MPI4PY}") ; \
    python3 -m pip install "${mpi4py_spec}"

# We activate the use of system libmetis-dev
RUN sed -i 's|#LMETIS     = -L\${DEST}/metis-\${METIS}/lib -lmetis|LMETIS     = -L${DEST}/metis-${METIS}/lib -lmetis # This line has been uncommented|' src/mumps.sh

# Compile en gcc-12 et 13 mais test marche pas => test en GCC-14 sans activé cette modif
# We replace medium -mcmodel by large because medium not support in ARM gfortran
RUN sed -i '33i sed -i "s/-mcmodel=medium/-mcmodel=small/g" src/Makefile.inc' src/miss3d.sh

# We add -Wno-narrowing on CMakeLists of INTERP_KERNEL
RUN sed -i '49i sed -i "s/ADD_DEFINITIONS(-Wsign-compare -Wconversion)/ADD_DEFINITIONS(-Wsign-compare -Wconversion -Wno-narrowing)/g" "$(pwd)/../src/INTERP_KERNEL/CMakeLists.txt"' src/medcoupling.sh

# Start compilation
RUN export DISTR=debian-12 ; \
   make ROOT=/opt/aster ARCH=gcc13-openblas-ompi4 RESTRICTED=0 check ; \
   make ROOT=/opt/aster ARCH=gcc13-openblas-ompi4 RESTRICTED=0 setup_venv ; \
   make ROOT=/opt/aster ARCH=gcc13-openblas-ompi4 RESTRICTED=0

# We source the prerequisites and compile
WORKDIR /root/dev/codeaster
RUN . /opt/aster/*/*/*_mpi.sh && \
    cd $HOME/dev/codeaster/src && \
    ./waf configure --prefix=/opt/aster/install/mpi && \
    ./waf install -j $(nproc)

# We add user 
# Create a new user 'aster'
# Create the user, set the password, and add to groups
RUN useradd -m -s /bin/bash aster \
    && echo "aster:aster" | chpasswd \
    && usermod -aG sudo aster \
    && usermod -aG root aster

# Clean up
RUN apt-get install -y sudo && apt-get clean && rm -rf /var/lib/apt/lists/*

# Check if installation pass Validation
#WORKDIR /root
#RUN /opt/aster/install/mpi/bin/run_ctest -L submit -LE need_data --resutest=/tmp/resu_submit --timefactor=3 ; exit 0

USER aster
# Add the line to source the script in .bashrc
RUN echo '. /opt/aster/*/*/*_mpi.sh' >> /home/aster/.bashrc

CMD ["/bin/bash"]
