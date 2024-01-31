#! /usr/bin/env bash
#
# Wrapper around master_test.py and summary_stats.bash
#
# Note:
# - Includes support for overriding DEBUG_LEVEL and TEST_REGEX for use with Docker,
#   working around quirks for Nektos/Act (see local-workflows.sh).
#

# Set bash regular and/or verbose tracing
DEBUG_LEVEL=${DEBUG_LEVEL:-0}
if [ "$DEBUG_LEVEL" -ge 3 ]; then
    echo "in $0 $* [$(date)]"
fi
if [ "${TRACE:-0}" = "1" ]; then
    set -o xtrace
fi
if [ "${VERBOSE:-0}" = "1" ]; then
    set -o verbose
fi
dir=$(dirname "${BASH_SOURCE[0]}")

# Make sure directory and parent directory on PATH and PYTHONPATH
# TODO3: find out why not being done under Github runner (docker OK)
script_dir="$(realpath "$dir/..")"
test_dir="$(realpath "$dir")"
export PATH="$PATH:$script_dir:$test_dir"
export PYTHONPATH="$PYTHONPATH:$script_dir:$test_dir"

# Optionally source temporary settings script
temp_script="$dir/_temp_test_settings.bash"
if [ -e "$temp_script" ]; then
    env_before=$(printenv)
    source "$temp_script"
    env_after=$(printenv)
    if [ "$env_before" != "$env_after" ]; then
        echo "FYI: environment changes made via $temp_script"
    fi
fi

# Get environment overrides
# TODO3: Get optional environment settings from _test-config.bash
## DEBUG: export DEBUG_LEVEL=6
## TEST: export TEST_REGEX="calc-entropy-tests"
# Show environment if detailed debugging
## OLD: DEBUG_LEVEL=${DEBUG_LEVEL:-0}
if [ "$DEBUG_LEVEL" -ge 5 ]; then
    ## OLD: echo "in $0 $*"
    echo "Environment: {"
    printenv | sort | perl -pe "s/^/    /;"
    echo "   }"
fi

# Run the python tests and then the alias tests
# note: the python stdout and stderr streams are unbuffered so interleaved
## OLD: dir=$(dirname "${BASH_SOURCE[0]}")
python_result=0
if [ "${RUN_PYTHON_TESTS:-1}" == "1" ]; then
    export PYTHONUNBUFFERED=1
    echo -n "Running tests under "
    python3 --version
    python3 "$dir"/master_test.py
    python_result="$?"
fi

# Run the alias tests and show info from show output log (-o)
## TODO: python3 "$dir"/batspp_report.py --text
## TODO2: run via su (or sudo) with a non-root account!
bash_result=0
if [ "${RUN_BASH_TESTS:-1}" == "1" ]; then
    bash "$dir"/summary_stats.bash -o
    bash_result="$?"
fi

# End of processing
if [ "$DEBUG_LEVEL" -ge 3 ]; then
    echo "out $0 [$(date)]"
fi

# Return status code used by Github actions
# *** Note: need to make sure both the Python tests and the bash alias ones get accounted for in the final status code
combined_result=$(($python_result + $bash_result))
exit "$combined_result"
