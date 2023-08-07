# This builds the base images that we can use for development testing. See
#   .github/workflows/tests.yml
#
# Notes:
# - Mostly based initially on
#     https://stackoverflow.com/a/70866416 [How to install python specific version on docker?]
# - For Docker docs, see https://docs.docker.com/get-started.
#
# Usage:
# 1. Build the image:
#   $ docker build -t mezcla-dev -f- . <Dockerfile
#   # TODO: build --platform linux/x86_64 ...
# 2. Run tests using the created image (n.b., uses entrypoint at end below with run_tests.bash):
#   $ docker run -it --rm --mount type=bind,source="$(pwd)",target=/home/mezcla mezcla-dev
#   TODO: --mount => --volume???
#   NOTE: --rm removes container afterwards; -it is for --interactive with --tty
# 3. [Optional] Run a bash shell using the created image:
#   $ docker run -it --rm --entrypoint='/bin/bash' --mount type=bind,source="$(pwd)",target=/home/mezcla mezcla-dev
# 4. Remove the image:
#   $ docker rmi mezcla-dev
#

## OLD
## FROM ubuntu:18.04
## NOTE: Uses a smaller image to speed up build
## TEST: FROM ghcr.io/catthehacker/ubuntu:act-latest
FROM catthehacker/ubuntu:act-20.04

ARG WORKDIR=/home/mezcla
ARG REQUIREMENTS=$WORKDIR/requirements.txt

## TODO?: RUN mkdir -p $WORKDIR

WORKDIR $WORKDIR

# Set the Python version to install
## TODO: keep in sync with .github/workflows
## TODO: ARG PYTHON_VERSION=3.9.16
## TEST:
ARG PYTHON_VERSION=3.8.12

# Install Python
# See https://stackoverflow.com/a/70866416 [How to install python specific version on docker?]
#
## OLD:
## # Note: we install Python 3.8 to maintain compatibility with some libraries
## # Note: DEBIAN_FRONTEND=noninteractive must be setted on-the-fly to avoid unintended changes
## RUN apt update -y && apt-get install sudo -y
## RUN useradd -m docker && echo "docker:docker" | chpasswd && adduser docker sudo
## RUN sudo apt upgrade -y && \
##     DEBIAN_FRONTEND=noninteractive apt-get install -y wget build-essential checkinstall  libreadline-gplv2-dev  libncursesw5-dev  libssl-dev  libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev zlib1g-dev && \
##     cd /usr/src && \
##     sudo wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz && \
##     sudo tar xzf Python-${PYTHON_VERSION}.tgz && \
##     cd Python-${PYTHON_VERSION} && \
##     DEBIAN_FRONTEND=noninteractive sudo ./configure --enable-optimizations && \
##     DEBIAN_FRONTEND=noninteractive sudo make install
## RUN apt-get update -y && apt-get install git -y
#
# Download, extract, and install the specified Python version
# Note:
# - Uses versions prepared for Github Actions
# - To find URL links, see https://github.com/actions/python-versions:
#   ex: https://github.com/actions/python-versions/releases/download/3.8.12-117929/python-3.8.12-linux-20.04-x64.tar.gz
# - Also see https://stackoverflow.com/questions/74673048/github-actions-setup-python-stopped-working.
RUN wget -qO /tmp/python-${PYTHON_VERSION}-linux-20.04-x64.tar.gz \
        "https://github.com/actions/python-versions/releases/download/${PYTHON_VERSION}-117929/python-${PYTHON_VERSION}-linux-20.04-x64.tar.gz" && \
    mkdir -p /opt/hostedtoolcache/Python/${PYTHON_VERSION}/x64 && \
    tar -xzf /tmp/python-${PYTHON_VERSION}-linux-20.04-x64.tar.gz \
        -C /opt/hostedtoolcache/Python/${PYTHON_VERSION}/x64 --strip-components=1 && \
    rm /tmp/python-${PYTHON_VERSION}-linux-20.04-x64.tar.gz

## TODO (use streamlined python installation):
## RUN apt-get update && \
##     apt-get install -y software-properties-common && \
##     add-apt-repository -y ppa:deadsnakes/ppa && \
##     apt-get update && \
##     apt install -y python$PYTHON_MAJ_MIN

# Some programs require a "python" binary
## OLD: RUN ln -s $(which python3) /usr/local/bin/python

# Set the working directory visible
ENV PYTHONPATH="${PYTHONPATH}:$WORKDIR"

# Install pip for the specified Python version
RUN wget -qO /tmp/get-pip.py "https://bootstrap.pypa.io/get-pip.py" && \
    python3 /tmp/get-pip.py && \
    rm /tmp/get-pip.py

# Install the package requirements
## OLD: RUN python -m pip install --upgrade pip
COPY ./requirements.txt $REQUIREMENTS
RUN python -m pip install -r $REQUIREMENTS
## TODO3: add option for optional requirements (likewise, for all via '#full#")
##   RUN python -m pip install --verbose $(perl -pe 's/^#opt#\s*//g;' $REQUIREMENTS | grep -v '^#')

## TEMP workaround: copy source to image
## COPY . $WORKDIR/mezcla

# Download the NLTK required data
## OLD: RUN python -m nltk.downloader -d /usr/local/share/nltk_data all
RUN python -m nltk.downloader -d /usr/local/share/nltk_data punkt averaged_perceptron_tagger

# Install required tools and libraries
RUN apt-get update -y && apt-get install -y lsb-release && apt-get clean all
RUN apt install rcs

# Run the test, normally pytest over mezcla/tests
# Note: the status code (i.e., $?) determines whether docker run succeeds (e.h., OK if 0)
ENTRYPOINT './tools/run_tests.bash'
