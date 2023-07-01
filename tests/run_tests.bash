#! /usr/bin/env bash
#
# Wrapper around master_test.py and summary_stats.bash
#

# Uncomment following line(s) for tracing:
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#  
## echo "$@"
## set -o xtrace
## DEBUG: set -o verbose

# Run the python tests and then the alias tests
dir=$(dirname "${BASH_SOURCE[0]}")
python3 "$dir"/master_test.py
## TODO: python3 "$dir"/batspp_report.py --text
bash "$dir"/summary_stats.bash
