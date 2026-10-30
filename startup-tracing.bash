# startup-tracing.bash: Defines startup-trace function for optionally tracing 
# invocation of bash scripts. The log file will be placed in the /tmp directory
# (or the directory specified by TEMP or TMP).
#
# USAGE EXAMPLE:
#   if [ -e ~/bin/startup-tracing.bash ]; then source ~/bin/startup-tracing.bash; fi
#
# NOTES:
# - Environment variables
#       STARTUP_TRACING         enables tracing to log file if 1
#       CONSOLE_TRACING         echoes to console
#       VERBOSE_TRACING         echoes miscellaneous tracing as well (but just to console)
#
# TODO:
# - Use DEBUG_LEVEL rather than VERBOSE_TRACING.
# TODO2: Rename as tomohara-startup-tracing.bash as interwined with the eponymous scripts (tomohara-aliases.bash, etc.)???.
#
## UPDATE 2026-10-27: reworks STARTUP_TRACING, etc. defaults
## UPDATE 2026-10-20: Revise VERBOSE_TRACING interpretation.

# maldito shellcheck: this should be an option, not the default
#   SC2153: Possible misspelling: TMP may not be assigned, but TEMP is
# shellcheck disable=SC2153

if [ "$STARTUP_TRACING" = "" ]; then STARTUP_TRACING=-1; fi
if [ "$CONSOLE_TRACING" = "" ]; then CONSOLE_TRACING=-1; fi
if [ "$VERBOSE_TRACING" = "" ]; then VERBOSE_TRACING=-1; fi
DEBUG_LEVEL=${DEBUG_LEVEL:-0}
if [ "$TEMP" = "" ]; then TEMP="$TMP"; fi
if [ "$TEMP" = "" ]; then TEMP=/tmp; fi

# startup-trace(msg): trace MSG at DEBUG_LEVEL 5+
function startup-trace () {
    # note: tracing blocked when STARTUP_TRACING explicitly set to 0
    if [ "$STARTUP_TRACING" = "0" ]; then
        return
    fi

    # Set tracing (TODO3: put in separate function like startup-trace-init)
    ## TODO2: straighten out VERBOSE_TRACING ambiguity (e.g., shell-scripts verbose debug level vs Bash verbose option)
    ## NOTE: SET_XTRACE and SET_VERBOSE added as workaround
    if [[ ("$VERBOSE_TRACING" = "1") || ("$SET_XTRACE" = "1") ]]; then 
        set -o xtrace;
        echo TEMP="$TEMP;"
        # Enable full trace if debugging (TODO4: ... $(calc-int 'TL_DETAILED'))
        ## OLD: if [ "$DEBUG_LEVEL" -ge 4 ]; then
        if [[ ("$DEBUG_LEVEL" -ge 7) || ("$SET_VERBOSE" = "1") ]]; then
            set -o verbose
        fi
    fi;

    # File logging and/or console
    if [ "$STARTUP_TRACING" = "1" ]; then
        ## BAD: echo "$* [$HOSTNAME $(date)]" >> "$TEMP/_startup-$USER-$HOST-$$.log";
        ## NOTE: HOSTNAME is more standard; see https://www.gnu.org/software/bash/manual/html_node/Bash-Variables.html
        echo "$* [$HOSTNAME $(date)]" >> "$TEMP/_startup-$USER-$HOSTNAME-$$.log";
    fi; 
    if [ "$CONSOLE_TRACING" = "1" ] || [ "$DEBUG_LEVEL" -ge 5 ]; then
        ## OLD: echo "$* [$HOSTNAME $(date)]";
        ## TODO3: echo $* ... $redir
        if [ "$STDERR_TRACING" = 1 ]; then
            echo "$* [$HOSTNAME $(date)]" 1>&2;
        else
            echo "$* [$HOSTNAME $(date)]";
        fi;
    fi;
}
# startup-trace-debug(msg): trace MSG with DEBUG_LEVEL 6+
# note: used in tomohara-aliases.bash
function startup-trace-debug { DEBUG_LEVEL=$(min DEBUG_LEVEL 6) startup-trace "$@"; }

##------------------------------------------------------------------------------
## TEMP: Duplicate definitions to work around chicken-and-egg problem
## NOTE: See tomohara-aliases.bash in shell-scripts repo

# conditional-source(filename): source in bash commands from filename if exists
## OLD: function conditional-source () { if [ -e "$1" ]; then source $1; else echo "Warning: bash script file not found (so not sourced):"; echo "    $1"; fi; }
# note: filters out shellcheck SC1090 [Can't follow non-constant source.]
# shellcheck disable=SC1090
function conditional-source () { if [ -e "$1" ]; then source "$1"; else startup-trace -e "Warning: bash script file not found (so not sourced):\n    $1"; fi; }
#
# append-path(path): appends PATH to environment variable unless already there
function append-path () { if [[ ! (($PATH =~ ^$1:) || ($PATH =~ :$1:) || ($PATH =~ :$1$)) ]]; then export PATH="${PATH}:$1"; fi }
#
# min(x, y): minimum of X and Y
function min { local a=$1 b=$2; echo $(( a <= b ? a : b )); }
