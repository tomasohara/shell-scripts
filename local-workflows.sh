#!/bin/bash

# This script clones a GitHub repository, generates a pip requirements file,
# builds a Docker image, and runs a Github Actions workflow locally.
#
# Note:
# - When running under a Mac M1 the architecture needs to be specified to x64_64 (amd).
#   This is a no-op otherwise (e.g., under Linux) as x64_64 is used by defauly.
#

# Set bash regular and/or verbose tracing
if [ "${TRACE:-0}" = "1" ]; then
    set -o xtrace
fi
if [ "${VERBOSE:-0}" = "1" ]; then
    set -o verbose
fi

# Variables
REPO_URL="https://github.com/tomasohara/shell-scripts.git"
REPO_DIR_NAME="shell-scripts"
## OLD: IMAGE_NAME="local/test-act:latest"
IMAGE_NAME="${REPO_DIR_NAME}-dev"
ACT_WORKFLOW="ubuntu-latest=local/test-act"
ACT_PULL="false"
LOCAL_REPO_DIR="$PWD"

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
    docker build --platform linux/x86_64 --tag "$IMAGE_NAME" .
fi

# Run the Github Actions workflow locally
if [ "${RUN_WORKFLOW:-1}" = "1" ]; then
    echo "Running Github Actions locally"
    act --container-architecture linux/amd64 --pull="$ACT_PULL" -P "$ACT_WORKFLOW" -W ./.github/workflows/act.yml
fi
