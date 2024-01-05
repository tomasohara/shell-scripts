# startup-tracing.bash: Defines startup-trace function for optionally tracing 
# invocation of bash scripts. The log file will be placed in the /tmp directory
# (or the directory specified by TEMP or TMP).
#
# USAGE EXAMPLE:
#   if [ -e ~/bin/startup-tracing.bash ]; then source ~/bin/startup-tracing.bash; fi
#
# NOTES:
# - Environment variables
#	STARTUP_TRACING		enables tracing if 1
#	CONSOLE_TRACING		echoes to console as well as log file
#	VERBOSE_TRACING		echoes miscellaneous tracing as well (but just to console)
#
# TODO:
# - Use DEBUG_LEVEL rather than VERBOSE_TRACING.
#

# maldito spellcheck: this should be an option, not the default
#   SC2153: Possible misspelling: TMP may not be assigned, but TEMP is
# shellcheck disable=SC2153

if [ "$STARTUP_TRACING" = "" ]; then STARTUP_TRACING=0; fi
if [ "$CONSOLE_TRACING" = "" ]; then CONSOLE_TRACING=0; fi
if [ "$VERBOSE_TRACING" = "" ]; then VERBOSE_TRACING=0; fi
DEBUG_LEVEL=${DEBUG_LEVEL:-0}
if [ "$TEMP" = "" ]; then TEMP="$TMP"; fi
if [ "$TEMP" = "" ]; then TEMP=/tmp; fi

function startup-trace () { 
    if [ "$VERBOSE_TRACING" = "1" ]; then 
	set -o xtrace;
	echo TEMP=$TEMP;
	# Enable full trace if debugging (TODO4: ... $(calc-int 'TL_DETAILED'))
	if [ "$DEBUG_LEVEL" -ge 4 ]; then
	    set -o verbose
	fi
    fi;
    if [ "$STARTUP_TRACING" = "1" ]; then
	echo "$* [$HOSTNAME $(date)]" >> "$TEMP/_startup-$USER-$HOST-$$.log";
    fi; 
    if [ "$CONSOLE_TRACING" = "1" ]; then
	echo "$* [$HOSTNAME $(date)]";
    fi;
}
