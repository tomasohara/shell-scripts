#! /usr/bin/env bash
#! /bin/bash
#
# Sets the xterm title bar to the string given on the command line.
# The first argument gives the full title and the second the iconified title.
#
# NOTES:
# - Includes hostname in title if not default host (from environment or file).
# - Assumes DEFAULT_HOST environment variable specifies the default HOST
#   in full format (eg., dime-box.cyc.com) or specified in ~/.default-host.
#   -- See ~/.bashrc and ~/bin/tomohara-aliases.bash.
#   -- Also see set-title-to-current-dir and reset-prompt in latter.
# - under CygWin the Windows interepreter (CMD) title built-in command is used
# - See http://tldp.org/HOWTO/Xterm-Title-4.html#ss4.3 for an explanation of doing
#   this under bash and other Unix shells.
# - Under unix, the echoing must be done with -n (DUH)!
# - Shows original user if running sudo (via SUDO_USER).
# - Similarly shows suffix defined in environment (via XTERM_TITLE_SUFFIX).
#   -- See add-conda-env-to-xterm-title in anaconda-aliases.bash
# - Be careful when modifying code after the $PS_symbol support, which should
#   go first. That is, put changes before the '=====...===' line,
# - HACK: Output not done if $BATCH_MODE or $UNDER_EMACS is 1 (but still goes through motions).
#
# EXAMPLE:
# - set_xterm_title.bash "/c/cartera-de-tomas/ILIT" "ILIT"
#
# TODO:
# - Document environment variable usage:
#   HOST PWD TERM DEFAULT_HOST USER HOST_NICKNAME OSTYPE HOSTNAME SUDO_USER HOME BATCH_MODE UNDER_EMACS
# - Add environment variables for prefix (and affix?) analagous to XTERM_TITLE_SUFFIX.
#   
#........................................................................
# Miscellaneous Notes:
#
# from windows command interpreter help (also see www.ss64.com/nt):
# CMD [[/C | /K] string] Starts a new instance of the command interpreter
#     /C  Carries out the command specified by string and then terminates
#     /K  Carries out the command specified by string but remains
# TITLE [string] Sets the window title for the command prompt window.
#
#........................................................................
# Technical Notes:
#
# from http://rtfm.etla.org/xterm/ctlseq.html:
#
# Definitions 
# c   The literal character c  
# C   A single (required) character.  
# Ps  A single (usually optional) numeric parameter, composed of one of more digits.  
# Pm  A multiple numeric parameter composed of any number of single
#     numeric parameters, separated by ; character(s). Individual values for
#     the parameters are listed with Ps .
# Pt  A text parameter composed of printable characters 
#
# C1 (8-Bit) Control Characters 
#
# The xterm program recognizes both 8-bit and 7-bit control
# characters. It generates 7-bit controls (by default) or 8-bit if S8C1T
# is enabled. The following pairs of 7-bit and 8-bit control characters
# are equivalent:
#
# 7-bit  8-bit  Hex   Description  
#
# ESC[ 	 CSI    0x9b  Control Sequence Introducer 
#
# note: ESC appears as contol-[ under Emacs (i.e., '')
#
# Functions using CSI, ordered by the final character(s)
#
# CSI Ps ; Ps ; Ps t Window manipulation (from dtterm, as well as
# extensions). Valid values for the first (and any additional parameters)
# are:
#    2 0 Report xterm window's icon label as OSC L label ST 
#    2 1 Report xterm window's title as OSC l title ST 
#
# Operating System Controls 
#
# OSC Ps ; Pt ST Set Text Parameters. For colors and font, if Pt is a
# "?", the control sequence elicits a response which consists of the
# control sequence which would set the corresponding value. The dtterm
# control sequences allow you to determine the icon name and window
# title.
#
#........................................................................
# Escape codes for Setting Unix xterm titles (synopsis of above???):
#
# OSC Ps ; Pt BEL
#   0 Change Icon Name and Window Title to Pt 
#   1 Change Icon Name to Pt 
#   2 Change Window Title to Pt 
#


# Uncomment following line(s) for tracing (in order of verbosity):
# - echo args to show invocation (e.g., testing multiple invocations as with in anaconda-aliases.bash)
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#  
## BASIC: echo "in $0: args=$@"
## HACK: echo "BATCH_MODE=$BATCH_MODE"
## USUAL: set -o xtrace
## DEBUG: set -o verbose

# Show usage if no arguments or --help
# TODO: put argument processing in loop (see template.bash)
restore_base="$TMP/_set_xterm_title.$PPID"
restore_title=0
## TODO: save_title=0
save_title=1
print_full=0
print_icon=0
show_usage=0
debug=0
## DEBUG: debug=1
moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
while [ "$moreoptions" = "1" ]; do
    if [ "$1" = "--trace" ]; then
        set -o xtrace
    elif [ "$1" = "--help" ]; then
        show_usage=1
    elif [ "$1" = "--debug" ]; then
        debug=1
    elif [ "$1" = "--restore" ]; then
        restore_title=1
    elif [ "$1" = "--no-save" ]; then
        save_title=0
    elif [ "$1" = "--save" ]; then
        save_title=1
    elif [ "$1" = "--print-full" ]; then
        print_full=1
	restore_title=1
	save_title=0
    elif [ "$1" = "--print-icon" ]; then
        print_icon=1
	restore_title=1
	save_title=0
    else
	echo "ERROR: Unknown option: $1";
    fi
    shift;
    moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
done
if [[ ("$1" = "")
    && (("$restore_title" = "0") && ("$print_full" = "0") && ("$print_icon" = "0")) ]]; then
    show_usage="1"
fi

# Show usage statement if --help given or missing option
if [ "$show_usage" = "1" ]; then
    script=$(basename "$0")
    ## TODO: echo "Usage: [--trace] [--restore | --save] [--print-[full|icon]] [--help] $0 title [icon-title]"
    echo "Usage: [--trace] [--restore] [--[no]-save] [--print-[full|icon]] [--help] $0 title [icon-title]"
    echo ""
    echo "Notes:"
    ## TODO: echo "- -save makes a copy of current title (under $TMP)."
    echo "- Use --no-save to block automatic --save"
    echo "- -restore uses previously saved title and icon (see function script in tomohara-aliases.bash)."
    echo ""
    echo "Examples:"
    echo ""
    # NOTE:
    # - '"'...'"' is used to add double quotes around each double-quoted
    #   argument in case of embedded spaces.
    # - Otherwise, the following could have been used:
    #     $script     "$(basename $PWD)"        "[$PWD]"
    # EX: set_xterm_title.bash "Documents" "[/home/tomohara/Documents]"
    # TODO: See if clearer way to do this quoting.
    ## OLD: echo "$script" '"'"$(basename $PWD)"'"'  '"'"[$PWD]"'"'
    echo "$script" \"\$\(basename \$PWD\)\"  \"\$PWD\"
    echo ""
    echo "$script 'ssh tunnel for mysql'"
    exit
fi

# Extract the arguments from the command line
# HACK: Uses 'SCREEN: ' prefix if under screen 
# TODO: show a usage statement if no arguments given
full="$1"
icon="$2"
if [ "$icon" = "" ]; then icon=$full; fi
## OLD: if [ "$TERM" = "screen" ]; then full="SCREEN: $full"; icon="SCREEN: $icon"; fi
if [[ "$TERM" =~ screen ]]; then full="SCREEN: $full"; icon="SCREEN: $icon"; fi
## echo full="$full"
## echo icon="$icon"

#...............................................................................
# A bunch of adhoc stuff changes to the window title

# Make sure hostname set and see if optional default host indicated
if [ "$HOST" = "" ]; then
    HOST="$HOSTNAME"
    ## OLD: if [ "$HOST" = "" ]; then HOST=`uname -n`; fi
    if [ "$HOST" = "" ]; then HOST=$(uname -n); fi
fi
if [ "$DEFAULT_HOST" = "" ]; then
    ## OLD: if [ -e $HOME/.default_host ]; then DEFAULT_HOST=`cat $HOME/.default_host`; fi
    if [ -e "$HOME/.default_host" ]; then DEFAULT_HOST=$(cat "$HOME/.default_host"); fi
fi

# If default host indicated and not the current host, add name as prefix
# note: n/a used for DEFAULT_HOST to force this (see tohara-aliases.bash).
if [  "$DEFAULT_HOST" != "" ]; then
    if [ "$HOST" != "$DEFAULT_HOST" ]; then
    	# Add a nickname for the host from environment (e.g., set in ~/.bash_profile).
    	if [ "$HOST_NICKNAME" != "" ]; then HOST="$HOST ($HOST_NICKNAME)"; fi

	# Make the settings for the xerm title
	full="$HOST: $full"
	icon="$HOST: $icon"
    fi
fi

# If sudo being used, add current user name to end (e.g., "...; user=root")
# OLD: (("$SUDO_USER" != "") && ("$SUDO_USER" != "$USER"))
# TODO: just use LOGNAME test???
if [[ ((("$SUDO_USER" != "") && ("$SUDO_USER" != "$USER")) || ("$LOGNAME" != "$USER")) ]]; then
    ## DEBUG: echo "adding user"
    full="$full; user=$USER"
    icon="$icon; user=$USER"
fi
# Add suffix from XTERM_TITLE_SUFFIX env. var.:
if [ "$XTERM_TITLE_SUFFIX" != "" ]; then
    full="$full; $XTERM_TITLE_SUFFIX"
    icon="$icon; $XTERM_TITLE_SUFFIX"
fi

# If SCRIPT_PID set, add this at start
#
if [ "$SCRIPT_PID" != "" ]; then
    full="script:$SCRIPT_PID $full"
    icon="script:$SCRIPT_PID $icon"
fi

# Show derived titles
if [ "$debug" = "1" ]; then
    echo "new titles: full='$full'; icon='$icon'"
fi

#================================================================================
# Be careful when modifying remainder of script.

if [ "$save_title" = "1" ]; then
    if [ "$debug" = "1" ]; then echo "Updating title cache (${restore_base}*)"; fi
    echo "$full" >| "${restore_base}.full.list"
    echo "$icon" >| "${restore_base}.icon.list"
fi
if [ "$restore_title" = "1" ]; then
    ## DEBUG: echo "Restoring from title cache (${restore_base}*)";
    full=$(cat "${restore_base}.full.list")
    icon=$(cat "${restore_base}.icon.list")
fi
if [ "$print_full" = "1" ]; then
    echo "$full"
    exit
fi
if [ "$print_icon" = "1" ]; then
    echo "$icon"
    exit
fi
# If prompt prefix set, include that at very start.
# Note: excludes special dollar signs: small (﹩) U+FE69, full-width (＄) U+FF04, or heavy dollar sign (💲) U+1F4B2, where regular ($) is U+0024
# TODO: just add that full version (i.e., not minimized)
#
declare PS_symbol
if [ "$PS_symbol" != "" ]; then
    ## BAD: if [[ ! ($PS_symbol =~ [$﹩＄💲]) ]]; then
    if [[ ($PS_symbol =~ ^.*[﹩＄💲].*$) ]]; then
	## DEBUG:
	echo "Omitting special dollar-sign PS_symbol ($PS_symbol) from title"
	true
    else
	full="$PS_symbol $full"
	icon="$PS_symbol $icon"
    fi
fi
#
# Note: *** put other changes above this one (so PS_symbol kept first)

#...............................................................................
# Do the actual title change

# Note: Disable ansi terminal output if running in pseudo-interactive
# mode (i.e., $BATCH_MODE=1 and 'i' in $-)
if [[ ("$BATCH_MODE" = "1") || ("$UNDER_EMACS" = "1") ]]; then
    ## DEBUG: echo "Ignoring ansi terminal update"
    true

# Under CygWin, set title using Win32 cmd command to set title to '<args>'
# NOTE: title is a built-in command of the XP shell
elif [ "$TERM" = "cygwin" ]; then
    ## TODO: both  ## DEBUG: echo cygwin case
    ## TODO: cmd /k title ...?
    cmd /c title "$icon"

## # If not default host, set Window and minimized title to '<host>:<args>'
## # TODO: use $full and $icon
## elif [ "$HOST" != "$DEFAULT_HOST" ]; then
##    ## DEBUG: echo non-default host case
##    echo "]0;${HOST}: $*";

# Otherwise set Window and minimized title to '<args>'
else
    ## DEBUG: echo default host case
    ## OLD: echo "]0;$*";
    ## echo in else clause
    # TODO: use example based on http://tldp.org/HOWTO/Xterm-Title-4.html#ss4.3
    #    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
    #       where \033 is the character code for ESC, and \007 for BEL.
    # NOTE: via https://www.gnu.org/software/bash/manual/bash.html:
    #    PROMPT_COMMAND [is] interpreted as a command to execute before printing the primary prompt ($PS1).
    ## OLD: echo "]1;$icon";
    ## OLD: echo "]2;$full";
    echo -n "]1;$icon";
    echo -n "]2;$full";
fi

## TODO: delete
## dummy change for git
