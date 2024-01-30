#! /usr/bin/env bash
#
# Bash file for making temporary settings for the tests. This is intended
# for adhoc debugging and avoids having to specify settings seperately
# for Docker images vs. Github VM runners.
# This get sourced via run_tests.bash.
#
# Example settings:
#    export DEBUG_LEVEL=5               # run with verbose tracing
#
#    export TEST_REGEX="tips|README"    # run tests with tips or README in file
#
export DEBUG_LEVEL=5
export TEST_REGEX="tips|entropy|testing-support-script-tests|eval-condition|sanity"
# HACK: settings for testing BatsPP archive creation
export UNDER_DOCKER=1
export ARCHIVE_OUTPUT=1
