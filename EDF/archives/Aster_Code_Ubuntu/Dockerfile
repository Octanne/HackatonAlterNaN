# Start with an Ubuntu base image
FROM ubuntu:20.04

# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

# Install base system utilities and development tools
RUN apt-get update && apt-get install -y \
    cmake bison flex tk swig \
    zlib1g-dev libxml2-dev libatlas-base-dev \
    python3 python3-dev python3-pip python3-numpy python3-scipy cython3 \
    git wget tar build-essential gfortran \
    libboost-dev libboost-python-dev libboost-filesystem-dev \
    libboost-regex-dev libboost-system-dev libboost-thread-dev \
    libboost-date-time-dev libboost-chrono-dev libboost-serialization-dev \
    openmpi-bin libopenmpi-dev && \
    ln -s /usr/bin/cmake /usr/local/bin/cmake && \
    ln -s /usr/bin/ctest /usr/local/bin/ctest

# Define directories for Boost library
RUN mkdir -p /opt/aster/boost/include && mkdir -p /opt/aster/boost/lib && \
    ln -s /usr/lib/x86_64-linux-gnu/libboost* /opt/aster/boost/lib/

# Environment setup for OpenMPI
ENV PATH=$PATH:/usr/lib/x86_64-linux-gnu/openmpi/bin

# Create the working directory
WORKDIR /opt/aster

# Download and extract code_aster prerequisites
# Replace the URL with the actual URL for the required prerequisites archive
RUN wget -O codeaster-prerequisites.tar.gz "https://www.code-aster.org/FICHIERS/prerequisites/codeaster-prerequisites-20240327-oss.tar.gz" && \
    tar -xzf codeaster-prerequisites.tar.gz && \
    rm codeaster-prerequisites.tar.gz

# Modify configuration files
WORKDIR /opt/aster/codeaster-prerequisites-20240327-oss
RUN sed -i -e 's#-lopenblas#-L /usr/lib/x86_64-linux-gnu/atlas -lsatlas#g' utils/general.sh && \
    sed -i -e 's#LIBPATH="#LIBPATH="/usr/lib/x86_64-linux-gnu/atlas #g' \
           -e 's#maths-libs=auto#maths-libs="scalapack satlas"#g' src/mumps.sh && \
    sed -i -e "s#centos8#$(uname -n)#g" utils/generate_env.py

RUN echo 'CA_CFG_MEDCOUPLING=( "-DBOOST_ROOT=/opt/aster/boost" )' >> utils/build_env.sh

# Compile code_aster prerequisites
RUN make ROOT=/opt/aster ARCH=gcc-atlas-ompi RESTRICTED=0

# Set the default working directory
WORKDIR /opt/aster

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]

