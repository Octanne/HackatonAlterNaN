# Start with an Ubuntu base image
FROM debian:11

# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

# Install base system utilities and development tools
RUN apt-get update && apt-get install -y \
    zlib1g-dev libxml2-dev libatlas-base-dev \

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]

