# !/bin/env bash
#
# Convenience script for loading all my aliase, functions, etc.
#
# usage: TOM_BIN=/home/tom/shell-script; source $TOM_BIN/all-tomohara-aliases.bash
#
# note:
# - The env.options are TRACE_/VERBOSE_SOURCE rather than TRACE/VERBOSE in
#   case sourcedvia a script which used the latter (see local-workflows.sh).
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
# note: normally this is down without tracing
shopt -s expand_aliases
$show_tracing && set -o xtrace
source_dir="$(dirname "${BASH_SOURCE[0]:-$0}")"
source "$source_dir/tomohara-aliases.bash"
if [ "${SOURCE_SETTINGS:-0}" = "1" ]; then
    source "$source_dir/tomohara-settings.bash"
fi
source "$source_dir/more-tomohara-aliases.bash"
source "$source_dir/tomohara-proper-aliases.bash"
$was_tracing || set - -o xtrace
