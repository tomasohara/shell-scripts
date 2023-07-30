# !/bin/env bash
#
# Convenience script for loading all my aliase, functions, etc.
#
# usage: TOM_BIN=/home/tom/shell-script; source $TOM_BIN/all-tomohara-aliases.bash
#
# note:
# - Omits tomohara-settings.bash unless SOURCE_SETTINGS=1,
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
##
source_dir="$(dirname "${BASH_SOURCE[0]:-$0}")"
export TOM_BIN="$source_dir"
source "$source_dir/tomohara-aliases.bash"
if [ "${SOURCE_SETTINGS:-0}" = "1" ]; then
    source "$source_dir/tomohara-settings.bash"
fi
source "$source_dir/more-tomohara-aliases.bash"
source "$source_dir/tomohara-proper-aliases.bash"
##
## TEST: for testing alias tests (see tests/batspp_report.py)
##
if [ "${DIR_ALIAS_HACK:-0}" = "1" ]; then
    unalias link-symbolic link-symbolic-force link-symbolic-regular
    unalias link-symbolic-safe ln-symbolic ln-symbolic-force
    #
    unalias compress-this-dir create-index-this-dir debug-index-this-dir debug-index-this-dir-by-type debug-search-this-dir delete-dir delete-dir-force em-dir em-this-dir explore-dir fix-dir-permissions index-this-dir index-this-dir-by-type recent-tar-this-dir remove-dir remove-dir-force search-this-dir tar-this-dir-dated ununcompress-this-dir
    #
    unalias glob-link glob-subdirs symlinks-proper
    #
    for f in aux-debug-index-dir aux-debug-index-type-in-dir aux-debug-search-dir aux-index-dir aux-index-type-in-dir aux-search-dir basename-with-dir clean-tex-dir compress-dir copy-readonly-to-dir cs-download-dir dir get-python-lint-dir git-move-to-dir new-tar-this-dir set-title-to-current-dir show-path-dir tar-dir tar-just-dir tar-just-this-dir tar-this-dir tex-dir uncompress-dir; do unset -f $f; done
    #
fi
##
$was_tracing || set - -o xtrace
