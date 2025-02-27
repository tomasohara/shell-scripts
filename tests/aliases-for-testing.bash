#! /bin/env bash
#
# Loads aliases to be tested via the BatsPP infrastructure, along
# with convenience aliases for the tests. This works by loading
# the master alias file (e.g., all-tomohara-aliases-etc.bash),
# and then defines additional aliases or functions.
#
# Simple Usage:
#   export TOM_BIN=/home/joe/shell-scripts;
#   source $TOM_BIN/tests/aliases-for-testing.bash
#
# Advanced usage:
#   # note: makes sure the testing aliases in current repo used
#   BASH_ENV="$PWD/aliases-for-testing.bash" run-jupyter-notebook
#
# Note:
# - For convenience, aliases and functions are referred to as "macros".
# - Put test-only macros under testing-specific section:
#   see  "* Put new definitions here *" below.
# - The env. options are TRACE_/VERBOSE_SOURCE rather than TRACE/VERBOSE in
#   case sourced via a script which used the latter (see local-workflows.sh).
# - Disables following shellcheck warnings
#   SC2139 (warning): This expands when defined, not when used. Consider escaping.
#

#...............................................................................
# Initialization

## NOTE: xtrace support cuases problems when used as via BASH_ENV
## to ensure loaded instead of ~/.bashrc for use with Jupyter notenooks

# Set bash regular and/or verbose tracing
# note: tracing off by default unless active for current shell
was_tracing=false
if [ "1" = "$(set -o | grep -v '^xtrace.*on')" ]; then 
    was_tracing=true
fi
show_tracing="$was_tracing"
if [ "${TRACE_SOURCE:-0}" = "1" ]; then
    show_tracing=true
    set -o xtrace
fi
if [ "${VERBOSE_SOURCE:-0}" = "1" ]; then
    set -o verbose
fi

# Source the files with definitions for aliases, etc.
# note: normally this is done without tracing
shopt -s expand_aliases
$show_tracing && set -o xtrace

#-------------------------------------------------------------------------------
# Load macros to be tested

# note: $source_dir used elsewhere so $this_source_dir used here
## DEBUG: echo "in ${BASH_SOURCE[*]}"
this_source_dir="$(dirname "${BASH_SOURCE[0]:-$0}")"
## DEBUG: trace-vars this_source_dir
source "$this_source_dir/../all-tomohara-aliases-etc.bash"
## DEBUG: startup-trace "post-init: aliases-for-testing.bash"

#-------------------------------------------------------------------------------
# Define testing-specific macros
#
# NOTE: *** Put new definitions here ***

# eval-condition(condition): evaluates python-like CONDITION, including
# special support for stdin global, which contains input to script.
# note: DURING_ALIAS minimizes tracing (see main.py and debug.py under mezcla)
# shellcheck disable=SC2139
{
    alias eval-condition="DURING_ALIAS=1 python3 $this_source_dir/eval_condition.py"
    alias eval-equals="DURING_ALIAS=1 python3 $this_source_dir/eval_condition.py --equals"
    alias eval-not-equals="DURING_ALIAS=1 python3 $this_source_dir/eval_condition.py --not-equals"
}

#-------------------------------------------------------------------------------
# Cleanup

# Disable tracing unless enabled prior to invocation
$was_tracing || set - -o xtrace

## DEBUG: echo "out ${BASH_SOURCE[*]}"
