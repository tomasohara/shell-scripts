#!/bin/bash

# This script builds a Docker image and runs a Github Actions workflow locally.
#
# Note:
# - When running under a Mac M1 the architecture needs to be specified to x64_64 (amd).
#   This is a no-op otherwise (e.g., under Linux) as x64_64 is used by defauly.
#

# Variables
IMAGE_NAME="local/test-act:latest"
ACT_WORKFLOW="ubuntu-latest=local/test-act"
ACT_PULL="false"

# Set bash regular and/or verbose tracing
if [ "${TRACE:-0}" = "1" ]; then
    set -o xtrace
fi
if [ "${VERBOSE:-0}" = "1" ]; then
    set -o verbose
fi

# Build the Docker image
if [ "${RUN_BUILD:-1}" = "1" ]; then
    echo "Building Docker image: $IMAGE_NAME"
    docker build --platform linux/x86_64 -t "$IMAGE_NAME" .
fi

# Run the Github Actions workflow locally
if [ "${RUN_WORKFLOW:-1}" = "1" ]; then
    file="${WORKFLOW_FILE:-act.yml}"
    echo "Running Github Actions locally w/ $file"
    act --verbose --container-architecture linux/amd64 --pull="$ACT_PULL" -P "$ACT_WORKFLOW" -W ./.github/workflows/act.yml
fi

# Run via docker directly
if [ "${RUN_DOCKER:-1}" = "1" ]; then
   echo "Running Tests via Docker"
   docker run -it --env DEBUG_LEVEL="$DEBUG_LEVEL" --mount type=bind,source="$(pwd)",target=/home/mezcla mezcla-dev
fi
