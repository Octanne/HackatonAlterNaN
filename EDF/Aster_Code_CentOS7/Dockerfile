# Start with an Ubuntu base image
FROM centos:7

ENV LANG=C.UTF-8

# Set new repo URL
RUN sed -i s/mirror.centos.org/vault.centos.org/g /etc/yum.repos.d/CentOS-*.repo
RUN sed -i s/^\#.*baseurl=http/baseurl=http/g /etc/yum.repos.d/CentOS-*.repo
RUN sed -i s/^mirrorlist=http/\#mirrorlist=http/g /etc/yum.repos.d/CentOS-*.repo
RUN yum clean all && rm -rf /var/cache/yum && yum makecache

# Install base system utilities
RUN yum update -y && yum install -y wget cmake3 bison flex tk swig3 glibc-common && \
ln -s $(which cmake3) /usr/local/bin/cmake && \
ln -s $(which ctest3) /usr/local/bin/ctest

# Set the locale to en_US.UTF-8
RUN localedef -i en_US -f UTF-8 en_US.UTF-8 && \
    export LANG=en_US.UTF-8 && \
    export LC_ALL=en_US.UTF-8

#RUN sed -i 's/^enabled=2/enabled=0/' /etc/yum.repos.d/CentOS-SCLo-scl.repo

# Installing compilers and some libraries (removed: centos-release-scl-rh)
RUN yum install -y devtoolset-8-toolchain \
zlib-devel libxml2-devel atlas-devel rh-git227

# Installation MPI runtime and libraries
# Prefer install OpenMPI 4 from source (default package is OpenMPI 1!).
# Wrappers available from /usr/lib64/openmpi/bin.
RUN yum install -y wget perl gcc gcc-c++ make && \
    wget https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.5.tar.gz && \
    tar -xvf openmpi-4.1.5.tar.gz && \
    cd openmpi-4.1.5 && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && \
    make install && \
    ldconfig && \
    cd .. && \
    rm -rf openmpi-4.1.5 openmpi-4.1.5.tar.gz

# Installing Python and related packages
RUN yum install -y python3-devel python36-scipy scipy Cython python36-Cython

# Put into build folder
RUN mkdir /root/build
WORKDIR /root/build

# Install Boost 1.69 from source
RUN yum install -y bzip2 which && \
    wget https://archives.boost.io/release/1.69.0/source/boost_1_69_0.tar.bz2 && \
    tar -xjf boost_1_69_0.tar.bz2 && \
    cd boost_1_69_0 && \
    ./bootstrap.sh --prefix=/opt/aster/boost --with-python=python3 && \
    ./b2 install
# Clean Install Boost 1.69
RUN rm -rf boost_1_69_0 boost_1_69_0.tar.bz2 && \
    ln -s /usr/lib64/libboost* /opt/aster/boost/lib/

# Optional: Create additional symbolic links for specific Boost libraries
#RUN ln -s /opt/aster/boost/lib/libboost_filesystem.so.1.69.0 /opt/aster/boost/lib/libboost_filesystem.so && \
#    ln -s /opt/aster/boost/lib/libboost_regex.so.1.69.0 /opt/aster/boost/lib/libboost_regex.so && \
#    ln -s /opt/aster/boost/lib/libboost_system.so.1.69.0 /opt/aster/boost/lib/libboost_system.so && \
#    ln -s /opt/aster/boost/lib/libboost_thread.so.1.69.0 /opt/aster/boost/lib/libboost_thread.so && \
#    ln -s /opt/aster/boost/lib/libboost_date_time.so.1.69.0 /opt/aster/boost/lib/libboost_date_time.so && \
#    ln -s /opt/aster/boost/lib/libboost_chrono.so.1.69.0 /opt/aster/boost/lib/libboost_chrono.so && \
#    ln -s /opt/aster/boost/lib/libboost_serialization.so.1.69.0 /opt/aster/boost/lib/libboost_serialization.so

# Building code_aster prerequisites
RUN mkdir -p codeaster-prerequisites && \
    cd codeaster-prerequisites && \
    wget https://www.code-aster.org/FICHIERS/prerequisites/codeaster-prerequisites-20240327-oss.tar.gz && \
    tar -xzf codeaster-prerequisites-20240327-oss.tar.gz && \
    cd codeaster-prerequisites-20240327-oss && \
    sed -i -e 's#-lopenblas#-L /usr/lib64/atlas -lsatlas#g' utils/general.sh && \
    sed -i -e 's#LIBPATH="#LIBPATH="/usr/lib64/atlas #g' \
           -e 's#maths-libs=auto#maths-libs="scalapack satlas"#g' src/mumps.sh && \
    sed -i -e "s#centos8#$(uname -n)#g" utils/generate_env.py

# Append custom CA_CFG_MEDCOUPLING to build_env.sh
RUN echo 'CA_CFG_MEDCOUPLING=( "-DBOOST_ROOT=/opt/aster/boost" )' >> /root/build/codeaster-prerequisites/codeaster-prerequisites-20240327-oss/utils/build_env.sh
# https://www.code-aster.org/FICHIERS/prerequisites/codeaster-prerequisites-20240327-oss.tar.gz

# Clean up
RUN yum clean all && rm -rf /var/cache/yum

CMD ["/bin/bash"]

