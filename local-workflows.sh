#!/bin/bash
#
# This script uses GitHub local actions via act:
#    https://github.com/nektos/act
# It builds a Docker image and runs a Github Actions workflow locally.
#
# It also supports running the actions directly via docker. This includes
# building the image and running via docker, done separately to support
# inspection of the image.
#
# Note:
# - There are some old options such as for cloning repository and
#   generating requirements.
# - When running under a Mac M1 the architecture needs to be specified to x64_64 (amd).
#   This is a no-op otherwise (e.g., under Linux) as x64_64 is used by default.
# - Selective shellcheck whitelisting:
#   SC2086: Double quote to prevent globbing and word splitting
#
# Warning:
# - *** Changes need to be synchronized in 3 places: Dockerfile, local-workflow.sh, and .github/workflow/*.yml!
#
# TODO:
# - Use an environment/config file to simplify passing environment variables:
#   See https://docs.docker.com/engine/reference/commandline/run
#   and act man page (https://github.com/nektos/act/blob/master/cmd/root.go).
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
# $ docker tag $(docker images | head -1) shell-scripts-dev
# $ docker images
# ...
# shell-scripts-dev      latest      e5423ec78b75   7 hours ago   1.76GB
#
#

# Helpers
#
# to_bool(value): convert {1, true} to true and everything else false
# ex: to_bool(1) => true; to_bool(0) => false
function to_bool {
    if [[ ("$1" == "1") || ("$1" == "true") ]]; then
	echo "true";
    else
	echo "false";
    fi;
}
#
# trace-vars(var, ...): trace each VAR in command line
# note: output format: VAR1=VAL1; ... VARn=VALn;
function trace-vars {
    local var
    for var in "$@"; do
        echo -n "$var=$(eval echo "\${$var}"); "
    done
    echo
}

# Variables
# note:
# - USER_ENV is of form "ENV1=val1 ENV2=val2 ...".
# - act pull is not required (n.b., misleading error message due to permissions, etc.).
## DEBUG: set -o xtrace
REPO_URL="https://github.com/tomasohara/shell-scripts.git"
REPO_DIR_NAME="shell-scripts"
IMAGE_NAME="${REPO_DIR_NAME}-dev"
## OLD: ACT_WORKFLOW="ubuntu:act-20.04"
## OLD: ACT_PULL="false"
ACT_PULL=$(to_bool "${ACT_PULL:-0}")
LOCAL_REPO_DIR="$PWD"
DEBUG_LEVEL="${DEBUG_LEVEL:-2}"
GIT_BRANCH="${GIT_BRANCH:-}"
BUILD_OPTS="${BUILD_OPTS:-}"
RUN_OPTS="${RUN_OPTS:-}"
USER_ENV="${USER_ENV:-}"
## Added environment variables for the option exposure
ACT_JSON="${ACT_JSON:-""}"
RUN_BUILD="${RUN_BUILD:-0}"
RUN_DOCKER="${RUN_DOCKER:-0}"
RUN_WORKFLOW="${RUN_WORKFLOW:-1}"
WORKFLOW_FILE="${WORKFLOW_FILE:-act.yml}"
RUN_BUILD_CACHELESS="${RUN_BUILD_CACHELESS:-0}"
# TODO3: put all env. init up here for clarity
#   CLONE_REPO, AUTO_REQS, etc.
if [ "$DEBUG_LEVEL" -ge 4 ]; then
    echo "in $0 $* [$(date)]"
    ## OLD: source "${TOM_BIN:-/home/tomohara/bin}/all-tomohara-aliases-etc.bash"
    echo "Before argument parsing:"
    trace-vars IMAGE_NAME ACT_PULL LOCAL_REPO_DIR DEBUG_LEVEL GIT_BRANCH BUILD_OPTS USER_ENV
    trace-vars ACT_JSON RUN_BUILD RUN_DOCKER RUN_WORKFLOW WORKFLOW_FILE RUN_BUILD_CACHELESS
fi

# Display script usage
usage() {
    echo "Usage: $0 [--help|-h] [--build|-b] [--cacheless|-c] [--docker|-d] [--file <workflow_file>] [--json <act_json>]"
    echo "Options:"
    echo "  --build     (-b)    Run docker build"
    echo "  --cacheless (-c)    Run docker build by clearing build caches"
    echo "  --docker    (-d)    Run Docker directly (bypassing nektos act) (default: $RUN_DOCKER)"
    echo "  --file      (-f)    Specify workflow file (default: $WORKFLOW_FILE)"
    echo "  --json      (-j)    Specify act JSON (default: $ACT_JSON)"
    echo "  --help      (-h)    Displays the help message and exit"
    exit 1
}

# Function for set_option and implementing it
set_option(){
    case "$1" in
        --build|-b)
            RUN_BUILD=1
            RUN_WORKFLOW=0
            ;;
        --cacheless|-c)
            RUN_BUILD_CACHELESS=1
            RUN_WORKFLOW=0
            ;;
        --docker|-d)
            RUN_DOCKER=1
            RUN_WORKFLOW=0
            ;;
        --file|-f)
            if [ -n "$2" ]; then
                WORKFLOW_FILE="$2"
                shift
            else
                echo "Error: Missing argument for --file"
                usage
            fi
            ;;
        --json|-j)
            if [ -n "$2" ]; then
                ACT_JSON="$2"
                shift
            else
                echo "Error: Missing argument for --json"
                usage
            fi
            ;;
        --help|-h)
            usage
            ;;
        *)
            echo "Error: Unknown option: $1"
            usage
            ;;
    esac
}

while [[ $# -gt 0 ]]; do
    set_option "$1"
    shift
done

# Trace out main environment overrides
if [ "$DEBUG_LEVEL" -ge 4 ]; then
    echo "After argument parsing:"
    trace-vars IMAGE_NAME ACT_PULL LOCAL_REPO_DIR DEBUG_LEVEL GIT_BRANCH BUILD_OPTS USER_ENV
    trace-vars ACT_JSON RUN_BUILD RUN_DOCKER RUN_WORKFLOW WORKFLOW_FILE RUN_BUILD_CACHELESS
fi

# Set bash regular and/or verbose tracing
## DEBUG: echo "TRACE=$TRACE VERBOSE=$VERBOSE"
if [ "${TRACE:-0}" = "1" ]; then
    set -o xtrace
fi
if [ "${VERBOSE:-0}" = "1" ]; then
    set -o verbose
fi

# Change into script directory
src_dir=$(dirname "${BASH_SOURCE[0]}")
command cd "$src_dir"

# Do sanity checks for potential problems
## TODO1: fix bug with image selection blocking progress (set default and disable interactive mode)
##   choose the default image you want to use with act
if [[ ("$RUN_WORKFLOW" == "1") && (! -e ~/.actrc) ]]; then
    echo "Error: run act to configure default image in ~/.actrc"
    exit
fi
if [ "" = "$(groups | grep docker)" ]; then
    echo "Error: you need to be in the docker group to use act (or docker)"
    exit
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
# Note: normally uses ./requirements.txt (n.b., avoids extraneous modules in one off scripts);
# also, pipreqs no longer installed by default due to Docker issue.
export REQUIREMENTS="$LOCAL_REPO_DIR/requirements.txt"
if [ "${AUTO_REQS:-0}" = "1" ]; then
    export REQUIREMENTS="$PWD/requirements.auto"
    echo "Generating pip requirements file ($REQUIREMENTS)"
    pipreqs --print "$LOCAL_REPO_DIR" > "$REQUIREMENTS"
fi

# Build the Docker image
if [ "${RUN_BUILD}" = "1" ] || [ "${RUN_BUILD_CACHELESS}" = "1" ]; then
    echo "Building Docker Image: $IMAGE_NAME"
    cache_option="--tag"
    # note: maldito docker doesn't support --env for build, just run
    # Also, --build-arg misleading: see
    #    https://stackoverflow.com/questions/42297387/docker-build-with-build-arg-with-multiple-arguments
    if [ "${RUN_BUILD_CACHELESS}" = "1" ]; then
        echo "  (cacheless option enabled)"
        cache_option="--no-cache -t"
    fi
    #
    # shellcheck disable=SC2086
    docker build --build-arg "GIT_BRANCH=$GIT_BRANCH" --platform linux/x86_64 $BUILD_OPTS ${cache_option} "$IMAGE_NAME" .
fi

# Run the Github Actions workflow locally
# TODO1: get this to retain image (to allow for post-mortem review)
if [[ "$RUN_WORKFLOW" == "1" ]]; then
    act="${ACT_PROGRAM:-act}"
    file="$WORKFLOW_FILE"
    echo "Running Github Actions locally via $act w/ $file"

    ## TODO: GITHUB_TOKEN="$(gh auth token)" or set via environment
    # Note: Unfortunately, the environment setting is not affecting the docker
    # invocation. A workaround is to modify the 'Run tests' steps in the
    # workflow configuration file (e.g., .github/workflows/debug.yml).
    ## TODO2: fix environment (see tests/run_tests.bash for workaround
    ## via temporary settings script)
    # note: ACT_JSON can be used to disable act-specific flags (e.g., to enable runner matrix)
    misc_args=()
    json="${ACT_JSON}"
    if [ "$json" != "" ]; then misc_args+=(--eventpath ./.github/workflows/"$json"); fi;
    # shellcheck disable=SC2086
    "$act" --verbose --env "DEBUG_LEVEL=$DEBUG_LEVEL $USER_ENV" --container-architecture linux/amd64 --pull="$ACT_PULL" --workflows ./.github/workflows/"$file" $RUN_OPTS "${misc_args[@]}"
    # TODO: docker tag IMAGE-ID shell-scripts-dev
    # EX (see above): docker tag $(docker images --quiet | head -1) shell-scripts-dev
fi

# Run via docker directly
if [[ "$RUN_DOCKER" == "1" ]]; then
    echo "Running Tests via Docker"
    # Convert VAR1=val1 VAR2=val2 ... to "--env VAR1=val1 --env VAR2=val2 ..."
    user_env_spec=$(echo " $USER_ENV" | perl -pe 's/ (\w+=)/ --env $1/g;')
    # shellcheck disable=SC2086
    docker run -it --env "DEBUG_LEVEL=$DEBUG_LEVEL" $user_env_spec --mount type=bind,source="$(pwd)",target=/home/"$REPO_DIR_NAME" "$IMAGE_NAME"
fi

# End processing
if [ "$DEBUG_LEVEL" -ge 4 ]; then
    echo "out $0 [$(date)]"
fi
