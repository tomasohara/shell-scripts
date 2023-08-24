#! /usr/bin/env bash
#
# Wrapper around master_test.py and summary_stats.bash
#

# Set bash regular and/or verbose tracing
if [ "${TRACE:-0}" = "1" ]; then
    set -o xtrace
fi
if [ "${VERBOSE:-0}" = "1" ]; then
    set -o verbose
fi

# Run the python tests and then the alias tests
# note: the python stdout and stderr streams are unbuffered so interleaved
dir=$(dirname "${BASH_SOURCE[0]}")
export PYTHONUNBUFFERED=1
python3 "$dir"/master_test.py
python_result="$?"

## TODO: python3 "$dir"/batspp_report.py --text
bash "$dir"/summary_stats.bash
bash_result="$?"

# *** Note: need to make sure both the Python tests and the bash alias ones get accounted for in the final status code
combined_result=$(($python_result + $bash_result))
exit "$combined_result"
