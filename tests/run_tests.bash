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
dir=$(dirname "${BASH_SOURCE[0]}")
python3 "$dir"/master_test.py
## TODO: python3 "$dir"/batspp_report.py --text
bash "$dir"/summary_stats.bash
