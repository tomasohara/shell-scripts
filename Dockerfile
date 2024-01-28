# Docker file to support CI/CD via Github actions
#
# Usage:
# 1. Build the image:
#   $ docker build --tag name:shell-scripts-dev -f- . <Dockerfile
#   # TODO3: what the hell is -f- for (why so effing cryptic, docker)!
# 2. Run tests using the created image (n.b., uses entrypoint at end below with run_tests.bash):
#   $ docker run -it --rm --mount type=bind,source="$(pwd)",target=/home/shell-scripts shell-scripts-dev
#   NOTE: --rm removes container afterwards; -it is for --interactive with --tty
#   TODO2: --mount => --volume???
# 3. [Optional] Run a bash shell using the created image:
#   $ docker run -it --rm --entrypoint='/bin/bash' --mount type=bind,source="$(pwd)",target=/home/shell-scripts my-shell-scripts
#   # note: might need to tag the image (maldito docker): see local-workflows.sh
# 4. Remove the image:
#   $ docker rmi shell-scripts-dev
#
# Note:
# - Environment overrides not supported during build, so arg's must be used instead. See
#       https://vsupalov.com/docker-arg-env-variable-guide/#overriding-env-values
#
# Warning:
# - *** Changes need to be synchronized in 3 places: Dockerfile, local-workflow.sh, and .github/workflows/*.yml!
#


# Use the GitHub Actions runner image with Ubuntu
# NOTE: Uses older 20.04 both for stability and for convenience in pre-installed Python downloads (see below).
# See https://github.com/catthehacker/docker_images
FROM catthehacker/ubuntu:act-20.04

# Set default debug level (n.b., use docker build --build-arg "arg1=v1" to override)
# Also optionally set the regex of tests to run.
# Note: maldito act/nektos/docker not overriding properly
## TODO2: fixme (see tests/run_tests.bash for workaround)
## TODO4: ARG DEBUG_LEVEL=2
ARG DEBUG_LEVEL=4
## DEBUG: ARG DEBUG_LEVEL=5
ARG TEST_REGEX=""
## DEBUG: ARG TEST_REGEX="testing-tips"

# [Work in progress]
# Set branch override: this is not working due to subtle problem with the tfidf package
#   ValueError: '/home/tomohara/python/tfidf' is not in the subpath of '/tmp/pip-req-build-4wdbom6g'
#   OR one path is relative and the other is absolute.
# Note: this is intended to avoid having to publish an update to PyPI.
ARG GIT_BRANCH=""
## HACK: hardcode branch to tom-dev due to stupid problems with act/docker
## DEBUG: ARG GIT_BRANCH="tom-dev"

# Trace overridable settings
RUN echo "DEBUG_LEVEL=$DEBUG_LEVEL; GIT_BRANCH=$GIT_BRANCH"

# Set the working directory
ARG WORKDIR=/home/shell-scripts
WORKDIR $WORKDIR

# Install necessary dependencies and tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget tar ca-certificates && \
    true
    ## TODO4: rm -rf /var/lib/apt/lists/*

# Install other stuff
# note: this is to support logging into the images for debugging issues
# TODO3: get to work
RUN if [ "$DEBUG_LEVEL" -ge 4 ]; then apt-get install --yes emacs kdiff3 less tcsh zip || true; fi

# Set the Python version to install
# NOTE: The workflow yaml files now handle this (e.g., via matrix support)
## TODO: keep in sync with .github/workflows
## OLD: ARG PYTHON_VERSION=3.9.16
## TEST: ARG PYTHON_VERSION=3.8.12
ARG PYTHON_VERSION=3.11.4


# Download pre-compiled python build
# TODO2: Make this step optional because it conflict with python matrix in yaml files (e.g., github/worflow/github.yml).
# To find URL links, see https://github.com/actions/python-versions:
# ex: https://github.com/actions/python-versions/releases/tag/3.11.4-5199054971
#
# maldito https://github.com/actions uses stupid idiosyncratic tag
## OLD: ARG PYTHON_TAG=""
## TEST: ARG PYTHON_TAG="117929"
ARG PYTHON_TAG="5199054971"
#
RUN if [ "$PYTHON_VERSION" != "" ]; then                                                \
       wget -qO /tmp/python-${PYTHON_VERSION}-linux-20.04-x64.tar.gz "https://github.com/actions/python-versions/releases/download/${PYTHON_VERSION}-${PYTHON_TAG}/python-${PYTHON_VERSION}-linux-20.04-x64.tar.gz" && \
       mkdir -p /opt/hostedtoolcache/Python/${PYTHON_VERSION}/x64 &&                    \
       tar -xzf /tmp/python-${PYTHON_VERSION}-linux-20.04-x64.tar.gz                    \
           -C /opt/hostedtoolcache/Python/${PYTHON_VERSION}/x64 --strip-components=1 && \
       echo TODO: rm /tmp/python-${PYTHON_VERSION}-linux-20.04-x64.tar.gz;              \
    fi

# Set environment variables to use the installed Python version as the default
ENV PATH="/opt/hostedtoolcache/Python/${PYTHON_VERSION}/x64/bin:$WORKDIR:$WORKDIR/tests:${PATH}"

# Install pip for the specified Python version
RUN if [ "$PYTHON_VERSION" != "" ]; then                                                \
        wget -qO /tmp/get-pip.py "https://bootstrap.pypa.io/get-pip.py" &&              \
        python3 /tmp/get-pip.py &&                                                      \
        true || /tmp/get-pip.py;                                                        \
    fi

# Copy the project's requirements file to the container
ARG REQUIREMENTS=$WORKDIR/requirements.txt
COPY requirements.txt $REQUIREMENTS
## TODO3?: COPY tests/_test-config.bash $WORKDIR/tests

# Install the project's dependencies
## OLD: RUN pip install --verbose --no-cache-dir --requirement $REQUIREMENTS
RUN if [ "$PYTHON_VERSION" != "" ]; then                                                \
        pip install --verbose --no-cache-dir --requirement $REQUIREMENTS;               \
    fi

# Display environment (e.g., for tracking down stupid pip problems)
RUN printenv | sort

# Add local version of mezcla
# ex: DEBUG_LEVEL=4 GIT_BRANCH=aviyan-dev local-workflows.sh
RUN if [ "$GIT_BRANCH" != "" ]; then echo "Installing mezcla@$GIT_BRANCH"; pip install --verbose --no-cache-dir git+https://github.com/tomasohara/mezcla@$GIT_BRANCH; fi

# Clean up unnecessary files
RUN apt-get autoremove -y && \
    apt-get clean && \
    true
    ## TODO4: rm -rf /var/lib/apt/lists/*

# Show disk usage when debugging
RUN if [ "$DEBUG_LEVEL" -ge 5 ]; then                           \
    echo "Top directories by disk usage:";                      \
    du --block-size=1K / 2>&1 | sort -rn | head -20;         	\
fi

# Enable github access
# Note: This is not secure, but scrappycito only has access to
# to dummy repo's like https://github.com/tomasohara/git-bash-test.
## TODO:
## RUN git config --global user.email "scrappycito@gmail.com" && \
##     git config --global user.name "SCrappy Cito" && \
##     export MY_GIT_TOKEN=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 && \
##     git config --global url."https://api:$MY_GIT_TOKEN@github.com/".insteadOf "https://github.com/" && \
##     git config --global url."https://ssh:$MY_GIT_TOKEN@github.com/".insteadOf "ssh://git@github.com/" && \
##     git config --global url."https://git:$MY_GIT_TOKEN@github.com/".insteadOf "git@github.com:"

## # Run the test, normally pytest over ./tests
# Note: the status code (i.e., $?) determines whether docker run succeeds (e.h., OK if 0)
ENTRYPOINT DEBUG_LEVEL=$DEBUG_LEVEL TEST_REGEX="$TEST_REGEX" './tests/run_tests.bash'
