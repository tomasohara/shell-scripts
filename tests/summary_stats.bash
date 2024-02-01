#!/bin/bash
#
# summary_stats.bash works in the following manner:
# 1) ./batspp_report.py -k (regenerates all KCOV dirs and output in HTML)
# 2) [optional] ./kcov_result.py --list --export (returns result according to the KCOV outputs) 
# 3) Output of the process is also stored in ./summary_stats.txt
#
# Warning:
# - This should not be run under an admin-like account (e.g., root or power user), because the tests might inadvertantly delete files.
# - It is safest to use a separate testing account with minimal permissions.
#   *** Otherwise, bad things might happen to your good files! ***
#

# Set bash regular and/or verbose tracing
if [ "${TRACE:-0}" = "1" ]; then
    set -o xtrace
fi
if [ "${VERBOSE:-0}" = "1" ]; then
    set -o verbose
fi

# Help Message (i.e., usage)
display_help() {
    echo "Usage: $0 [-f]"
    echo "    -o Shows output log (summary_stats.log)"
    echo "    -h Displays this help message"
}

# Applying options for output log
# TODO2: enable long arguments (see ../examples/chatgpt-get-long-options-parsing.bash)
output_log=false
while getopts "oh" option; do
    case $option in
        o)
           output_log=true
           ;;
        h)
           display_help
           exit 0
           ;;
        \?)
           echo  "Invalid option: -$OPTARG" >&2
           display_help
           exit 1
           ;;
    esac
done

# Change into testing script directory (e.g., ~/shell-scripts/tests)
cd "$(dirname "$0")"

# TEMP: set github credentials
# Note:
# - This is not secure, but scrappycito only has access it is own repos. For example,
#     https://github.com/scrappycito/git-bash-test.
# - The HOME directory is checked instead of USER because Github and docker use root.
#    {/home/shell-scripts, /home/runner, /home/testuser}
## OLD: if [[ ("$HOME" == "/home/shell-scripts") || ("$HOME" == "/home/runner") ]]; then
## TODO2: if [[ $HOME =~ /home/(shell-scripts|runner|testuser) ]]; then
if [[ $HOME =~ /home/(shell-scripts|runner) ]]; then
    echo "FYI: modifying ~/.gitconfig and ~/.git-credentials"
    
    # Set user ID
    git config --global user.email "scrappycito@gmail.com"
    git config --global user.name "Scrappy Cito"

    # Overide specific usages to use token
    ## OLD: export MY_GIT_TOKEN=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
    export MY_GIT_TOKEN=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
    git config --global url."https://api:$MY_GIT_TOKEN@github.com/".insteadOf "https://github.com/"
    git config --global url."https://ssh:$MY_GIT_TOKEN@github.com/".insteadOf "ssh://git@github.com/"
    git config --global url."https://git:$MY_GIT_TOKEN@github.com/".insteadOf "git@github.com:"

    # Eanble credentials store (i..e, cached in file)
    git config --global credential.helper "store"
    ## TODO: git config --file ~/.git-credentials "$MY_GIT_TOKEN"
    echo "https://scrappycito:$MY_GIT_TOKEN@github.com" > ~/.git-credentials
fi

# Derive name for output file
# Note: Uses unique output subdir under ~/temp (or $BATSPP_OUTPUT).
# Likewise, uses unique temp subdir under /tmp  (or $BATSPP_TEMP).
timestamp=$(date '+%d%b%y-%H%M')
TMP=${TMP:-/tmp}
BATSPP_OUTPUT="${BATSPP_OUTPUT:-"$HOME/temp/BatsPP-$timestamp"}"
BATSPP_TEMP="${BATSPP_TEMP:-"$TMP/BatsPP-$timestamp"}"
mkdir --parents "$BATSPP_OUTPUT" "$BATSPP_TEMP"
echo "FYI: Using $BATSPP_OUTPUT for output and $BATSPP_TEMP for temp. files"

## TEMP: Enable flag for deleting aliases in order to force fail some tests
## NOTE: this enables a bunch of alias removals in all-tomohara-aliases-etc.bas
## export DIR_ALIAS_HACK=1

# Run the set of alias tests, making sure Tom's aliases are defined
# notes: disables SC2086: Double quote to prevent globbing and word splitting.
# BATSPP_REPORT_OPTS can be used to run coverage tests (e.g., --kcov) instead
# of the regular report (--txt).
# 
BATSPP_REPORT_OPTS=${BATSPP_REPORT_OPTS:-"--txt --definitions aliases-for-testing.bash"}
# shellcheck disable=SC2086
OUTPUT_DIR="$BATSPP_OUTPUT" TEMP_BASE="$BATSPP_TEMP" PYTHONPATH="..:$PYTHONPATH" python3 ./batspp_report.py $BATSPP_REPORT_OPTS -
batspp_result="$?"

## NOTE: kcov is not critical, so it is not run as part of workflow tests
## TODO: python3 ./kcov_result.py --list --summary --export | tee summary_stats.txt

# Generate output log when -o option enabled
if $output_log; then
    # TODO2: less => grep???
    ## OLD: grep -B20 "^not ok" "$(find "$BATSPP_OUTPUT" -name '*outputpp.out')" | less -p "not ok" > summary_stats.log
    grep -B20 "^not ok" "$(find "$BATSPP_OUTPUT" -name '*outputpp.out')" /dev/null >| summary_stats.log 2>&1
fi

# Optionally, create archive of BatsPP output dir and transfer to another host.
# TODO: define helper functions to faciliate this (n.b., gotta hate Bash)
#
UNDER_RUNNER_DEFAULT=0; if [ "$GITHUB_ACTIONS" == "true" ]; then UNDER_RUNNER_DEFAULT=1; fi
UNDER_RUNNER="${UNDER_RUNNER:-$UNDER_RUNNER_DEFAULT}"
UNDER_DOCKER_DEFAULT=0; if [[ (("$USER" == root) && ("$RUNNER_USER" == root)) ]]; then UNDER_DOCKER_DEFAULT=1; fi
UNDER_DOCKER="${UNDER_DOCKER:-$UNDER_DOCKER_DEFAULT}"
#
if [[ ($UNDER_RUNNER == "1") && ($UNDER_DOCKER == "1") ]]; then echo "Warning: unexpectedly runner&docker in $0"; fi
#
# Optionally, copy output to docker host
if [[ ("$UNDER_DOCKER" == "1") && ("${ARCHIVE_OUTPUT:-0}" == "1") ]]; then
    docker_host_dir="/home/shell-scripts"
    if [ -e "$docker_host_dir" ]; then
        tar_base="/home/shell-scripts/_batspp-output"
        tar cvfz "$tar_base.tar.gz" "$BATSPP_OUTPUT" >| "$tar_base.tar.log" 2>&1
    else
        echo "Error: can't xfer BatsPP archive because no host dir ($docker_host_dir)"
    fi
fi
#
# Optionally, copy output to ScrappyCito host using secure copy
# Note: This is unsecure, but the SSH key and the host aren't used in production.
if [ "${SCP_OUTPUT:-0}" == "1" ]; then
    mmddyyhhmm=$(date '+%d%b%y-%H%M')
    tar_base="/tmp/_batspp-output-$mmddyyhhmm"
    tar cvfz "$tar_base.tar.gz" "$BATSPP_OUTPUT" >| "$tar_base.tar.log" 2>&1
    #
    # TEMP: work around stupid git problem with permissions update to .pem file
    chmod --changes go-rw "scrappycito.pem"
    ls -lt "scrappycito.pem"
    #
    remote_spec="ubuntu@ec2-54-191-214-184.us-west-2.compute.amazonaws.com:xfer"
    echo "scp'ing $tar_base.tar.gz to $remote_spec"
    scp -P 22 -i "scrappycito.pem" -o StrictHostKeyChecking=no "$tar_base.tar.gz" $remote_spec
fi

# *** Note: the result needs to be that of alias tests (i.e., batspp_report.py)
exit "$batspp_result"
