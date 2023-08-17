 #! /bin/bash
# 
# Invokes Emacs with current directory unless files specified on command
# line and using ~/.emacs.tpo instead of ~/.emacs (for when using shared
# hosts). If the X-Windows DISPLAY environment is not set, then
# the console version of Emacs is forced (via --no-windows).
#
# Notes:
# - Background support is placed here rather than in Bash aliases or
# functions, so that the Emacs processes don't show up via Bash jobs
# command (as it tends to clutter the display).
# - Basis for em alias under Linux.
# - See win32-emacs.sh for similar script for use under Cygwin.
#
#-------------------------------------------------------------------------------
# Note: Based on following alias/functions definition (see tohara-aliases.bash)
#
# emacs_options="--geometry 80x50"
# if [ -e "~/.emacs.tpo" ]; then
#     alias emacs-tpo='emacs -l ~/.emacs.tpo'
#     if [ "$DISPLAY" = "" ]; then 
#         alias emacs-tpo='emacs -l ~/.emacs.tpo --no-windows $emacs_options'
#         function em () { if [ "$1" = "" ]; then emacs-tpo .; else emacs-tpo "$@"; fi; }
#     else
#         function em () { if [ "$1" = "" ]; then emacs-tpo .; else emacs-tpo "$@"; fi & }
#     fi
# else
#     function em () { if [ "$1" = "" ]; then emacs $emacs_options .; else emacs $emacs_options "$@"; fi & }
#     alias emacs-tpo=em
# fi
#

# Uncomment following line(s) for tracing:
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#  
## echo "$@"
## set -o xtrace
## DEBUG: set -o verbose

# Show usage statement
#
if [ "$1" = "--help" ]; then
    script=$(basename "$0")
    echo ""
    echo "usage: $script [--trace] [--[skip-]nohup] [--options token-or-string] [--foreground] [--quick] [--emacs program] [--] [emacs-arguments]"
    echo ""
    echo "ex: $0 -- --geometry 80x50"
    echo ""
    echo "Notes:"
    echo "- Put any emacs arguments after the -- spec."
    echo "- You can also use EMACS_PROGRAM environment variable to override program."
    echo ""
    exit
fi

# Setup Emacs options (50 rows, 80 columns, and use background process)
# Note: Emacs sets EMACS env. var in terminal session, so EMACS_PROGRAM used instead
# Aside: in general longer names preferred to minimize conflicts as with DEBUG vs. DEBUG_LEVEL.
## OLD: emacs_options="--geometry 80x50"
use_nohup="0"
## TODO: emacs_options="${EMACS_OPTIONS:-}"
emacs_options=""
in_background="1"
## OLD: emacs="emacs"
## BAD: emacs="${EMACS:-emacs}"
emacs="${EMACS_PROGRAM:-emacs}"

## TEST
## # Use nohup if under Mac OS
## if [[ "$OSTYPE" =~ darwin.* ]]; then
##     native_m1_emacs="/Applications/Emacs.app/Contents/MacOS/Emacs-arm64-11"
##     if [ -e "$native_m1_emacs" ]; then
##        emacs="$native_m1_emacs"
##     else
##        use_nohup="1"
##     fi
## fi

# Use nohup if under Mac OS
if [[ "$OSTYPE" =~ darwin.* ]]; then
    use_nohup="1"
fi

# Parse command-line options
#
moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
quick=0
emacs_args=0
under_mac="0"
if [[ "$OSTYPE" =~ darwin.* ]]; then
    under_mac="1"
fi
while [ "$moreoptions" = "1" ]; do
    if [ "$1" = "--trace" ]; then
        set -o xtrace;
    elif [ "$1" = "--emacs" ]; then
        emacs="$2"
        shift
    elif [ "$1" = "--foreground" ]; then
        in_background="0"
    elif [ "$1" = "--mac" ]; then
        under_mac="1"
    elif [ "$1" = "--nohup" ]; then
        use_nohup="1"
    elif [ "$1" = "--skip-nohup" ]; then
        use_nohup="0"
    elif [[ ("$1" = "-q") || ("$1" = "--quick") ]]; then
        emacs_options="$emacs_options -q";
        quick=1
    elif [ "$1" = "--options" ]; then
        emacs_options="$emacs_options $2";
        shift;
    elif [ "$1" = "--" ]; then
        shift;
	emacs_args=1
        break;
    else
        echo "ERROR: Unknown option: $1";
        exit;
    fi
    shift 1;
    moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
done
# note: remainder of "$@" used below

# Force console model if DISPLAY environment not set
if [ "$DISPLAY" = "" ]; then
    ## DEBUG: 
    echo "no DISPLAY setting, so adding --no-windows and setting in_background"
    emacs_options="$emacs_options --no-windows"
    in_background="0"
fi

# Use ~/.emacs.tpo (in place of ~/.emacs) if available
if [[ ($quick = "0") && (-e "$HOME/.emacs.tpo") ]]; then
     emacs_options="$emacs_options -l $HOME/.emacs.tpo"
fi

# resolve-path(filename) => absolute filename
function resolve-path() {
    local filename="$1"
    local new_filename
    new_filename="$(realpath "$filename")"
    ## DEBUG: echo "resolving '$filename' => '$new_filename'" 1>&2
    echo "$new_filename"
}

# Reset bash flags
export BASHRC_PROCESSED=0 PROFILE_PROCESSED=0

## TODO: resolve <space> in emacs options
# EX: "-DAMA-Ubuntu<space>Mono-normal-normal-normal-*-24-*-*-*-m-0-iso10646-1" => "-DAMA-Ubuntu Mono-normal-normal-normal-*-24-*-*-*-m-0-iso10646-1"
# NOTE: works around problem with space in font name in EMACS_OPTIONS env. var
## emacs_options="${emacs_options//<space>/ /}"

# Invoke emacs, adding current directory if no args (so dired invoked)
## DEBUG: echo "FYI: which '$emacs' => '$(which "$emacs")'"
# note: disables shellcheck SC2046 [Quote this to prevent word splitting], SC2048 [Use $... (with quotes) to prevent whitespace problems], and SC2086 [Double quote to prevent globbing]
# shellcheck disable=SC2046,SC2048,SC2086
if [ "$in_background" = "1" ]; then
    # note: eval not used with variable for "&" in case spaces in filenames
    # TODO: rework so that no-op option added if empty (to avoid SC2086 disabled)
    #   ex: emacs "${emacs_options:- --eval 1}" "$@" &
    args=("$@");
    if [ "$under_mac" = "1" ]; then
        args=()
        if [ $# == 0 ]; then args+=("$(resolve-path .)"); fi
        # note: resolve fullpath for non-option filename due to quirk under macos
        for filename in "$@"; do
    	    ## DEBUG: echo "filename=$filename"
            if [[ ("$emacs_args" = "0") && ($filename =~ [^-]*) ]]; then
                filename=$(resolve-path "$filename")
            fi
            args+=("$filename")
        done
    fi
    #
    if [ "$use_nohup" = "1" ]; then
        ## BAD: nohup emacs $emacs_options "$@" >> $TEMP/nohup.log 2>&1 &
        ## OLD: nohup emacs $emacs_options $(realpath "$@" 2> /dev/null) >> $TEMP/nohup.log 2>&1 &
        # note: adds current directory so emacs starts in it rather than home (note< stupid nohup quirk
        # TODO: simplify awkward Bash constructions to similate csh 'unshift .'!
        ## OLD: nohup emacs $emacs_options $(realpath "${args[*]}") >> $TEMP/nohup.log 2>&1 &
        ## OLD2: $nohup emacs $emacs_options $(realpath "${args[*]}") >> $TEMP/nohup.log 2>&1 &
        ## DEBUG: echo "background w/ nohup"
        ## DEBUG: echo "issuing: $emacs $emacs_options '$(realpath ${args[*]})' \>\> $TEMP/nohup.log 2>&1 &"
        ## OLD: nohup "$emacs" $emacs_options $(realpath "${args[*]}") >> $TEMP/nohup.log 2>&1 &
	nohup "$emacs" $emacs_options "${args[*]}" >> $TEMP/nohup.log 2>&1 &
    else
        ## DEBUG: echo "regular background (i.e., non-nohup)"
        ## DEBUG: echo "issuing: $emacs $emacs_options ${args[*]} &"
	## DEBUG: set -o xtrace
	## DEBUG: echo "${args[@]}"
        "$emacs" $emacs_options "${args[@]}" &
    fi
else
    ## DEBUG: echo "in foreground"
    ## DEBUG: echo "issuing: $emacs $emacs_options ${args[*]}"
    "$emacs" $emacs_options "$@"
fi
