#! /usr/bin/env bash
#
# Convenience script for loading all my aliases, functions, etc.
## UPDATE 12 Jul 26: TOM_BIN-related cleanup.
#
# Tom's typical usage (n.b., idiosyncratic settings):
#   SOURCE_SETTINGS=1 source ~tomohara/bin/all-tomohara-aliases-etc.bash
#
# Simple Usage (see advanced below for use in scripts):
#   export TOM_BIN="/home/tom/shell-script"
#   source "$TOM_BIN/all-tomohara-aliases-etc.bash"
#
# Debugging usage:
#   TRACE_SOURCE=1 VERBOSE_SOURCE=1 source ~/bin/all-tomohara-aliases-etc.bash > ~/bin/all-tomohara-aliases-etc.debug.log 2>&1
#
# Note:
# - Omits tomohara-settings.bash unless SOURCE_SETTINGS=1,
# - The env.options are TRACE_/VERBOSE_SOURCE rather than TRACE/VERBOSE in
#   case sourced via a script which used the latter (see local-workflows.sh).
# - Ignoring following shellcheck warnings:
#   SC1091: Not following: ... was not specified as input (see shellcheck -x).
#   shellcheck disable=SC1091
#
#-------------------------------------------------------------------------------
# Advanced usage (e.g., within scripts using aliases):
#
#   # Get aliases (n.b., tracing should be delayed)
#   shopt -s expand_aliases
#   {
#       alias_script="all-tomohara-aliases-etc.bash"
#       source_dir="$(dirname "$(which "$alias_script")")"
#       # filters shellcheck SC1090 [Can't follow non-constant source]
#       # shellcheck disable=SC1090
#       source "$source_dir/$alias_script"
#   }
#   #
#   # Set tracing (delayed so alias definitions not traced)
#   if [ "$trace" = "1" ]; then
#       set -o xtrace
#   fi
#   if [ "$verbose" = "1" ]; then
#       set -o verbose
#   fi
#

# Optional startup trace
(( DEBUG_LEVEL >= 6 )) && echo "in ${BASH_SOURCE[0]}"

# Guard against re-entry
if [ "${ALIASES_PROCESSED:-0}" == 1 ]; then
    echo "Warning: unexpected re-invocation of ${BASH_SOURCE[0]}; set ALIASES_PROCESSED=0 first"
    return
fi
ALIASES_PROCESSED=1

# Set bash regular and/or verbose tracing
# note: tracing off by default unless active for current shell
was_tracing=false
if [[ "" != "$(set -o | grep 'xtrace.*on')" ]]; then 
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
source_dir="$(realpath "$(dirname "${BASH_SOURCE[0]:-$0}")")"
export TOM_BIN
TOM_BIN="$(realpath "${TOM_BIN:-"$source_dir"}")"
if [ "$TOM_BIN" != "$source_dir" ]; then
    echo "FYI: TOM_BIN different from all-tomohara-aliases-etc.bash source dir:"
    echo "    $TOM_BIN"
    echo "    $source_dir"
    source_dir="$TOM_BIN"
fi
## TEMP: make sure source dir in path
## NOTE: also done in tomohara-settings but needed here for set-title-to-current-dir in tomohara-settings.bash
if [ "$(echo ":$PATH:" | egrep ":$source_dir/?":)" = "" ]; then
   export PATH="$PATH:$TOM_BIN"
fi
## OLD: (( DEBUG_LEVEL >= 4 )) && echo "FYI: sourcing $source_dir/tomohara-aliases.bash, etc."
## TODO3: define temporary alias (or rename to something specialized)
function source {
    local script="$1"
    (( DEBUG_LEVEL >= 4 )) && echo "issuing: source \"$script\""
    command source "$script"
}
source "$source_dir/tomohara-aliases.bash"
if [ "${SOURCE_SETTINGS:-0}" = "1" ]; then
    source "$source_dir/tomohara-settings.bash"
fi
source "$source_dir/more-tomohara-aliases.bash"
source "$source_dir/tomohara-proper-aliases.bash"
##
## TEST: removes aliases and functions for use in testing aliases (see tests/summary_stats.bash)
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
## VERY-BAD: $was_tracing || set - -o xtrace
## NOTE: The above set the $@ parameters to "-o xtrace"! Via bash manual:
##   set [-abefhkmnptuvxBCEHPT] [-o option-name] [--] [-] [arg ...]
##     - Signal the end of options, cause all remaining  args to be assigned
##       to the positional parameters. The -x and -v options are turned off. ...
##
$was_tracing || set +o xtrace
