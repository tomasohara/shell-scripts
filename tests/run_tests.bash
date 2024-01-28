#! /usr/bin/env bash
#
# Wrapper around master_test.py and summary_stats.bash
#
# Note:
# - Includes support for overriding DEBUG_LEVEL and TEST_REGEX for use with Docker,
#   working around quirks for Nektos/Act (see local-workflows.sh).
#

# Set bash regular and/or verbose tracing
if [ "${TRACE:-0}" = "1" ]; then
    set -o xtrace
fi
if [ "${VERBOSE:-0}" = "1" ]; then
    set -o verbose
fi

# Get environment overrides
# TODO3: Get optional environment settings from _test-config.bash
## DEBUG: export DEBUG_LEVEL=6
## TEST: export TEST_REGEX="calc-entropy-tests"
# Show environment if detailed debugging
DEBUG_LEVEL=${DEBUG_LEVEL:-0}
if [ "$DEBUG_LEVEL" -ge 5 ]; then
    echo "in $0 $*"
    echo "Environment: {"
    printenv | sort | perl -pe "s/^/    /;"
    echo "   }"
fi

# Run the python tests and then the alias tests
# note: the python stdout and stderr streams are unbuffered so interleaved
dir=$(dirname "${BASH_SOURCE[0]}")
export PYTHONUNBUFFERED=1
echo -n "Running tests under "
python3 --version
python3 "$dir"/master_test.py
python_result="$?"

# Run the alias tests and show info from show output log (-o)
## TODO: python3 "$dir"/batspp_report.py --text
## TODO2: run via su (or sudo) with a non-root account!
bash "$dir"/summary_stats.bash -o
bash_result="$?"

# *** Note: need to make sure both the Python tests and the bash alias ones get accounted for in the final status code
combined_result=$(($python_result + $bash_result))
exit "$combined_result"
