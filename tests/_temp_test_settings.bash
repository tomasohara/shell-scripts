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
export DEBUG_LEVEL=5

# HACK: settings for testing BatsPP archive creation
## TEMP: export UNDER_DOCKER=1

# Regular settings
# Note: Archiving output will only be done if running under docker;
# also, scp will be skipped. It is used for debugging Github Actions
export ARCHIVE_OUTPUT=1
export SCP_OUTPUT=0

# Temporary settings
# Note: set regex for debugging specific tests. You can check it in to
# test Github actions, but 
# TEMP: export TEST_REGEX="tips|entropy|testing-support-script-tests|eval-condition|sanity"
