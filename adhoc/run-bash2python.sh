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
script_dir=$(dirname "${BASH_SOURCE[0]}")
src_dir="${BASH2PY_DIR:-$script_dir}"
trap 'if [[ $? -eq 139 ]]; then echo "Segmentation fault"; fi' CHLD
echo "Running $src_dir/bash2pyengine $*"
"$src_dir/bash2pyengine" "$@"
