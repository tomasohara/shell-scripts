#! /bin/env bash
#
# Loads aliases to be tested via the BatsPP infrastructure, along
# with convenience aliases for the tests.
#
# Simple Usage:
#   export TOM_BIN=/home/joe/shell-scripts;
#   source $TOM_BIN/tests/aliases-for-testing.bash
#
# Note:
# - Omits tomohara-settings.bash unless SOURCE_SETTINGS=1,
# - The env.options are TRACE_/VERBOSE_SOURCE rather than TRACE/VERBOSE in
#   case sourced via a script which used the latter (see local-workflows.sh).
#

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
##
source_dir="$(dirname "${BASH_SOURCE[0]:-$0}")"
source "$source_dir/../all-tomohara-aliases.bash"

# Add convenience aliases for testing
# note: DURING_ALIAS minimizes tracing (see main.py and debug.py under mezcla)
alias eval-condition='DURING_ALIAS=1 python eval_condition.py'

# Re-enable tracing if enabled at start
$was_tracing || set - -o xtrace
