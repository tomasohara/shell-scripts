#! /usr/bin/env bash
#
# Runs bash2pyengine trapping for segmentation fault. See
#   https://unix.stackexchange.com/questions/53289/does-segmentation-fault-message-come-under-stderr
#
# Note:
# - Use BASH2PY_DIR to specify directory for Bash2py.
#
# TODO:
# - check for other errors
# - have option to invoke produce gdb basktrace on error
# 
#

# Uncomment following line(s) for tracing:
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#  
## echo "$@"
## set -o xtrace
## DEBUG: set -o verbose
#
# Set bash regular and/or verbose tracing
if [ "${TRACE:-0}" = "1" ]; then
    set -o xtrace
fi
if [ "${VERBOSE:-0}" = "1" ]; then
    set -o verbose
fi

# Resolve directory for basy2py
script_dir=$(dirname "${BASH_SOURCE[0]}")
src_dir="${BASH2PY_DIR:-$script_dir}"
prog="${BASH2PY_PROG:-bash2pyengine}"
if [ ! -e "$src_dir/$prog" ]; then
    src_dir="$PWD"
fi
if [ ! -e "$src_dir/$prog" ]; then
    echo "Warning: unable to find $prog"
fi

# Run the program, trapping for faults
trap 'if [[ $? -eq 139 ]]; then echo "Segmentation fault"; fi' CHLD
echo "Running $src_dir/$prog $*"
if [ "${UNDER_GDB:-0}" = "1" ]; then
    newline=$'\n'
    echo "run '$*'${newline}bt$newline}q" | gdb "$src_dir/$prog"
else
    "$src_dir/$prog" "$@"
fi
