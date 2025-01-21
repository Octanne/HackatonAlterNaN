# Start with an Ubuntu base image
FROM debian:11

# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

# Update & Upgrade image
RUN apt-get update && apt-get upgrade -y

# Installing base system utilities with apt
RUN apt-get install -y \
     git cmake bison flex tk swig

# Installing compilers and some libraries with apt
RUN apt-get install gcc g++ gfortran libopenblas-dev zlib1g-dev libxml2-dev

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]

