#!/bin/bash
#
# This script clones a GitHub repository, generates a pip requirements file,
# builds a Docker image, and runs a Github Actions workflow locally.
#
# Note:
# - When running under a Mac M1 the architecture needs to be specified to x64_64 (amd).
#   This is a no-op otherwise (e.g., under Linux) as x64_64 is used by defauly.
# - Selective shellcheck whitelisting:
#   SC2086: Double quote to prevent globbing and word splitting
#
# Warning:
# - *** Changes need to be synchronized in 3 places: Dockerfile, local-workflow.sh, and .github/workflow/*.yml!
#
#--------------------------------------------------------------------------------
# Aside: [maldito] docker image info
#
# after RUN_WORKFLOW:
# $ docker images
# REPOSITORY            TAG         IMAGE ID       CREATED       SIZE
# <none>                <none>      e5423ec78b75   6 hours ago   1.76GB
# catthehacker/ubuntu   act-20.04   02147d5b7ca9   2 weeks ago   1.11GB
#
# $ docker tag $(docker images | head -1) my-shell-scripts
# $ docker images
# ...
# my-shell-scripts      latest      e5423ec78b75   7 hours ago   1.76GB
# 
#


# Variables
## DEBUG: set -o xtrace
REPO_URL="https://github.com/tomasohara/shell-scripts.git"
REPO_DIR_NAME="shell-scripts"
## OLD: IMAGE_NAME="local/test-act:latest"
IMAGE_NAME="${REPO_DIR_NAME}-dev"
## OLD: ACT_WORKFLOW="ubuntu-latest=local/test-act"
## TODO:
ACT_WORKFLOW="ubuntu:act-20.04"
ACT_PULL="false"
LOCAL_REPO_DIR="$PWD"
DEBUG_LEVEL="${DEBUG_LEVEL:-2}"
GIT_BRANCH=${GIT_BRANCH:-""}
BUILD_OPTS=${BUILD_OPTS:-}
RUN_OPTS=${RUN_OPTS:-}
# TODO3: put all up here fore clarity
#  CLONE_REPO, AUTO_REQS, RUN_BUILD, BUILD_OPTS, RUN_WORKFLOW, RUN_OPTS, WORKFLOW_FILE
if [ "$DEBUG_LEVEL" -gt 4 ]; then
    source "${TOM_BIN:-/home/tomohara/bin}/all-tomohara-aliases-etc.bash"
    trace-vars IMAGE_NAME LOCAL_REPO_DIR DEBUG_LEVEL GIT_BRANCH BUILD_OPTS
fi

# Set bash regular and/or verbose tracing
if [ "${TRACE:-0}" = "1" ]; then
    set -o xtrace
fi
if [ "${VERBOSE:-0}" = "1" ]; then
    set -o verbose
fi

# Optionally clone the GitHub repository into temp. dir
# note: normally skipped as local workflows intended for testing before checkin
if [ "${CLONE_REPO:-0}" = "1" ]; then
    echo "Cloning repository: $REPO_URL"
    cd "$TMP"
    git clone "$REPO_URL"
    cd "$REPO_DIR_NAME"
fi

# Optionally, generate pip requirements file
# Note: normally uses ./requirements.txt (n.b., avoid extraneous modules in one off scripts)
export REQUIREMENTS="$LOCAL_REPO_DIR/requirements.txt"
if [ "${AUTO_REQS:-0}" = "1" ]; then
    export REQUIREMENTS="$PWD/requirements.auto"
    echo "Generating pip requirements file ($REQUIREMENTS)"
    pipreqs --print "$LOCAL_REPO_DIR" > "$REQUIREMENTS"
fi

# Build the Docker image
if [ "${RUN_BUILD:-1}" = "1" ]; then
    echo "Building Docker image: $IMAGE_NAME"
    # note: maldito docker doesn't support --env for build, just run
    # Also, --build-arg misleading: see
    #    https://stackoverflow.com/questions/42297387/docker-build-with-build-arg-with-multiple-arguments
    ## TODO: docker build --build-arg "DEBUG_LEVEL=$DEBUG_LEVEL" --build-arg "GIT_BRANCH=$GIT_BRANCH" --platform linux/x86_64 --tag "$IMAGE_NAME" .
    # shellcheck disable=SC2086
    ## OLD: docker build --build-arg "GIT_BRANCH=$GIT_BRANCH" --platform linux/x86_64 $BUILD_OPTS --tag "name:$IMAGE_NAME" .
    ## TEST
    docker build --build-arg "GIT_BRANCH=$GIT_BRANCH" --platform linux/x86_64 $BUILD_OPTS --tag my-shell-scripts .
fi

# Run the Github Actions workflow locally
# TODO: get this to effing work [maldito act]
if [ "${RUN_WORKFLOW:-1}" = "1" ]; then
    file="${WORKFLOW_FILE:-act.yml}"
    ## TEST (Pass along debug level in environment)
    echo "Running Github Actions locally w/ $file"
    # shellcheck disable=SC2086
    ## TODO: act --env DEBUG_LEVEL="$DEBUG_LEVEL" --container-architecture linux/amd64 --pull="$ACT_PULL" -platform "$ACT_WORKFLOW" --workflows ./.github/workflows/"$file" $RUN_OPTS
    ## TEST: act --verbose --env DEBUG_LEVEL="$DEBUG_LEVEL" --container-architecture linux/amd64 --pull="$ACT_PULL" -platform my-shell-scripts --workflows ./.github/workflows/"$file" $RUN_OPTS
    act --verbose --env DEBUG_LEVEL="$DEBUG_LEVEL" --container-architecture linux/amd64 --pull="$ACT_PULL" --workflows ./.github/workflows/"$file" $RUN_OPTS
    # TODO: docker tag IMAGE-ID my-shell-scripts
    # EX (see above): docker tag $(docker images --quiet | head -1) my-shell-scripts
fi

# Run via docker directly
if [ "${RUN_DOCKER:-0}" = "1" ]; then
   echo "Running Tests via Docker"
   ## OLD: docker run -it --env DEBUG_LEVEL="$DEBUG_LEVEL" --mount type=bind,source="$(pwd)",target=/home/shell-scripts shell-scripts-dev
   docker run -it --env DEBUG_LEVEL="$DEBUG_LEVEL" --mount type=bind,source="$(pwd)",target=/home/shell-scripts my-shell-scripts
fi
