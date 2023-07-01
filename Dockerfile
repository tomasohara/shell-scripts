# Docker file to support CI/CD via Github actions
#
# Usage:
# 1. Build the image:
#   $ docker build -t shell-scripts-dev -f- . <Dockerfile
#   # TODO: build --platform linux/x86_64 ...
# 2. Run tests using the created image (n.b., uses entrypoint at end below with run_tests.bash):
#   $ docker run -it --rm --mount type=bind,source="$(pwd)",target=/home/shell-scripts shell-scripts-dev
#   NOTE: --rm removes container afterwards; -it is for --interactive with --tty
#   TODO: --mount => --volume???
# 3. [Optional] Run a bash shell using the created image:
#   $ docker run -it --rm --entrypoint='/bin/bash' --mount type=bind,source="$(pwd)",target=/home/shell-scripts shell-scripts-dev
# 4. Remove the image:
#   $ docker rmi shell-scripts-dev
#


# Use the GitHub Actions runner image with Ubuntu
FROM ghcr.io/catthehacker/ubuntu:act-latest

# Set the working directory
WORKDIR /app

# Install necessary dependencies and tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget tar ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Set the Python version to install
## TODO: keep in sync with .github/workflows
ARG PYTHON_VERSION=3.9.16

# Download, extract, and install the specified Python version
RUN wget -qO /tmp/python-${PYTHON_VERSION}-linux-22.04-x64.tar.gz \
        "https://github.com/actions/python-versions/releases/download/${PYTHON_VERSION}-3647595251/python-${PYTHON_VERSION}-linux-22.04-x64.tar.gz" && \
    mkdir -p /opt/hostedtoolcache/Python/${PYTHON_VERSION}/x64 && \
    tar -xzf /tmp/python-${PYTHON_VERSION}-linux-22.04-x64.tar.gz \
        -C /opt/hostedtoolcache/Python/${PYTHON_VERSION}/x64 --strip-components=1 && \
    rm /tmp/python-${PYTHON_VERSION}-linux-22.04-x64.tar.gz

# Set environment variables to use the installed Python version as the default
ENV PATH="/opt/hostedtoolcache/Python/${PYTHON_VERSION}/x64/bin:${PATH}"

# Install pip for the specified Python version
RUN wget -qO /tmp/get-pip.py "https://bootstrap.pypa.io/get-pip.py" && \
    python3 /tmp/get-pip.py && \
    rm /tmp/get-pip.py

# Copy the project's requirements file to the container
COPY requirements.txt /app/

# Install the project's dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Clean up unnecessary files
RUN apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Run the test, normally pytest over mezcla/tests
# Note: the status code (i.e., $?) determines whether docker run succeeds (e.h., OK if 0)
ENTRYPOINT './tests/run_tests.bash'
