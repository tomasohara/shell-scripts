#!/bin/bash

# This script clones a GitHub repository, generates a pip requirements file,
# builds a Docker image, and runs a Github Actions workflow locally.

# Variables
REPO_URL="https://github.com/tomasohara/shell-scripts.git"
REPO_DIR_NAME="shell-scripts"
IMAGE_NAME="local/test-act:latest"
ACT_WORKFLOW="ubuntu-latest=local/test-act"
ACT_PULL="false"

# Clone the GitHub repository
echo "Cloning repository: $REPO_URL"
git clone "$REPO_URL"
cd "$REPO_DIR_NAME"

# Generate pip requirements file
echo "Generating pip requirements file"
pipreqs .

# Build the Docker image
echo "Building Docker image: $IMAGE_NAME"
docker build -t "$IMAGE_NAME" .

# Run the Github Actions workflow locally
echo "Running Github Actions locally"
act --pull="$ACT_PULL" -P "$ACT_WORKFLOW" -W ./.github/workflows/act.yml
