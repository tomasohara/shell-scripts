#! /usr/bin/env bash
#
# Bash file for making temporary settings for the tests. This is intended
# for adhoc debugging and avoids having to specify settings seperately
# for Docker images vs. Github VM runners. This get sourced via run_tests.bash.
#
# Warning:
# - *** It is ok to check-in change in temporary changes for testing Github
#   actions on your branch. Hoever, make sure no temporary changes are pushed
#   to main (e.g., SCP_OUTPUT=1 or any use of TEST_REGEX).
#
# Example settings:
#    export DEBUG_LEVEL=5               # run with verbose tracing
#
#    export TEST_REGEX="tips|README"    # run tests with tips or README in file
#
## export DEBUG_LEVEL=4               # use verbose tracing

# HACK: settings for testing BatsPP archive creation
## TEMP: export UNDER_DOCKER=1

# Regular settings
# Note: Archiving output will only be done if running under docker;
# also, scp will be skipped. It is used for debugging Github Actions
## export ARCHIVE_OUTPUT=1            # create output archive in repo root under docker
## export SCP_OUTPUT=0                # don't copy results to server via scp
## export USE_SSH_AUTH=0              # use ssh w/ scrappycito.pem for git updates

# Override settings if under testing VM
# Note: 1 .most settings off so user can override when running locally,
# but, it is awkward to do so for docker or Github runner jobs.
# 2. For other Github Actions env. vars, see https://www.theserverside.com/blog/Coffee-Talk-Java-News-Stories-and-Opinions/environment-variables-full-list-github-actions
if [ "$DEPLOYMENT_BASEPATH" == "/opt/runner" ]; then
    export ARCHIVE_OUTPUT=1
    export USE_SSH_AUTH=1
    export DEBUG_LEVEL=5
fi

# Temporary settings
#
# Note: set regex for debugging specific tests. You can check it in to
# test Github actions, but again *** don't merge into main ***.
#
## export TEST_REGEX="git|tips|entropy|testing-support-script-tests|eval-condition|sanity"
## export REMAP_TMP=1               # all /tmp files => $BATSPP_TEMP (see summary_stats.bash)
## export SHOW_FAILURE_CONTEXT=0    # hide redundant error report (see batspp_report.py)
