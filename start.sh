#! /bin/bash
#
# start.sh: invokes document-specific program based on file argument (e.g., okular for pdf files). This is analogous to the Windows start command.
#
# TODO:
# - Allow for invoking more than one file (e.g., for viewing multiple images).
# - Allow for user to override the application, such as via enironment
#   (e.g., IMAGE_APP=gimp).
# - Get programs for each type from user configuration files (e.g., mime settings).
#

# Uncomment following line(s) for tracing:
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#  
## echo "$@"
## set -o xtrace
## set -o verbose

# Set bash regular and/or verbose tracing
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#
if [ "${DEBUG_LEVEL:-0}" -ge 4 ]; then
    echo "$0 $@"
fi
if [[ "${TRACE:-0}" == "1" ]]; then
    set -o xtrace
fi
if [[ "${VERBOSE:-0}" == "1" ]]; then
    set -o verbose
fi

# Get defaults for programs
BROWSER=${BROWSER:-firefox}

# Support for MacOS-special casing
under_mac=0
if [ "$(uname)" = "Darwin" ]; then under_mac=1; fi

# Parse command-line options
# TODO: #
more_options=0; case "$1" in -*) more_options=1 ;; esac
show_usage=0;
for_editting=0
verbose=0
while [ "$more_options" = "1" ]; do
    if [ "$1" = "--trace" ]; then
	set -o xtrace;
    elif [ "$1" = "--help" ]; then
	show_usage=1;
    elif [ "$1" = "--view" ]; then
	for_editting=0;
    elif [ "$1" = "--edit" ]; then
	for_editting=1;
    elif [ "$1" = "--open" ]; then
	for_editting=1;
    elif [ "$1" = "--under-mac" ]; then
	under_mac=1;
    elif [ "$1" = "--not-mac" ]; then
	under_mac=0;
    elif [ "$1" = "--verbose" ]; then
	verbose=1;
    elif [ "$1" = "--" ]; then
	break;
    else
	echo "ERROR: Unknown option: $1";
	show_usage=1;
	break
    fi
    shift;
    more_options=0; case "$1" in -*) more_options=1 ;; esac
done
file="$1"
arg2="$2"
 
# Show usage statement if explicitly requested, if bad argument specified, or
# if no file is specified.
# Note: uses $arg2 to check for extraneous args
#
if [[ ($show_usage = 1) || ("$file" = "") || ("$arg2" != "") ]]; then
    script=$(basename "$0")
    echo ""
    echo "Usage: $script [--view|[--edit|--open]] [--verbose] [--trace] [misc-options] file"
    echo "    misc-options: [--help] [--not-mac]"
    echo ""
    echo "Examples:"
    echo ""
    echo "$0 virtualBox-5-2-16-UserManual.pdf"
    echo ""
    echo "$0 --edit virtualBox-5-2-16-UserManual.pdf"
    echo ""
    echo "Notes:"
    echo "- Opens application to view (or edit) file based its file extension."
    echo "- Directories will be viewed with Gnome nautilus."
    echo "- Emacs is used as a fallback."
    echo "- Currently only one file is supported." 
    ## TODO: Show the applications associated with specific file extensions
    echo ""
    exit
fi

#...............................................................................
# Helper function

# invoke(program, file): invoke PROGRAM over FILE sending output to
# temporary log file with today's date
# Note: intended for libreoffice and ocular (for PDF) which issue a lot of extraneous messgaes to stderr
# TODO: convert into external script??
function invoke () {
    local program="$1"
    local file="$2"
    local today
    today=$(date '+%d%b%y')
    local log_dir="$TEMP/$USER/invocations"
    if [ ! -e "log_dir" ]; then mkdir -p "$log_dir"; fi
    local log_file
    log_file="$log_dir/$(basename "$program")-$(basename "$file")-$today.log"
    local program_arg=""
    if [ ! -e "$log_file" ]; then touch "$log_file"; fi
    ## OLD: if [ "$verbose" = "1" ]; then echo "Issuing: \"$program\" \"$file\" >> \"$log_file\" 2>&1"; fi
    if [[ (! -e "$program") && ("$program" != "open") ]]; then
	if [ "$under_mac" = "1" ]; then
            if [[ ! ("$program" =~ .*\.app) ]]; then
                program="$program.app"
            fi
	    program_arg="-a $program"
	    program="open"
	fi
    fi
    ## OLD: "$program" "$file" >> "$log_file" 2>&1
    # disable shellcheck: SC2086 [Double quote to prevent globbing and word splitting]
    # shellcheck disable=SC2086
    {
        if [ "$verbose" = "1" ]; then echo "Issuing: \"$program\" $program_arg \"$file\" >> \"$log_file\" 2>&1"; fi
        "$program" $program_arg "$file" >> "$log_file" 2>&1
    }
    if [ $? -ne 0 ]; then
        echo "Problem running '$program' (status=$?):"
        tail --verbose "$log_file"
    fi
    }

#...............................................................................
# Start of main processing

# Run extension-specific program over arguments
# Notes:
# - The program is run in background.
# - Syntax of the bash case statement:
#     case word in [ [(] pattern [ | pattern ] ... ) list ;; ] ... esac
# - This illustrated that ';;' is needed at the end of the commands for a
#   particular set of commands (not the end of line).
# TODO: try nocasematch to make matching case insensitive

# If a directory, open using file explorer (e.g., nautilus)
if [ -d "$file" ]; then
    ## OLD: nautilus "$file" &
    file_manager=nautilus
    ## OLD: if [ "$under_mac" = "1" ]; then file_manager="/System/Library/CoreServices/Finder.app/Contents/MacOS/Finder"; fi
    if [ "$under_mac" = "1" ]; then file_manager="open"; fi
    "$file_manager" "$file" &
    exit
fi
# Otherwise, use program based on file extension
lower_file=$(echo "$file" | perl -pe 's/(.*)/\L$1/;')

# Change invoked program if different for editing than for viewing
office_program="libreoffice"
pdf_program="evince"
image_program="eog"
default_program="emacs"
# TODO: doc_program="libreoffice"
if [ "$for_editting" = "1" ]; then
    pdf_program="okular"
    image_program="pinta"
fi
if [ "$under_mac" = "1" ]; then
    # HACK: use 'command open'
    # NOTE: unfortunately there is no dispatcher for office programs as under Windows
    pdf_program="open"
    image_program="open"
    office_program="open"
    default_program="open"
fi
if [[ $lower_file =~ ^.*\.xcf$ ]]; then
    image_program="gimp"
fi
    
#
case "$lower_file" in
    # PDF and postscript files
    *.pdf* | *.ps*) invoke "$pdf_program" "$@" & ;;

    # Image files
    # note: uses viewer that Files invokes, such as eog [the "eye of GNOME"] for images
    *.gif* | *.ico* | *.jpeg* | *.jpg* | *.png* | *.svg* | *.xcf*) invoke "$image_program"  "$@" & ;;

    # Video files
    *.mov* | *.mp*4) invoke vlc "$@" & ;;

    # Audio files
    *.mp*3 | *.wav*) invoke vlc "$@" & ;;
    
    # MS Office and LibreOffice files: word processor files, spreadsheets, etc.
    # warning: this only works well for MS-specific extension (.
    # if other applications are associated (e.g,. TextEdit for .rtf), then need to invoke via specific office program [maldito mac/microsoft].
    # note: MacOs has awkware sequence via [Finder > GetInfo > OpenWith/ChangeAll] to change the default. See
    #    https://www.macworld.com/article/672511/how-to-change-default-apps-on-mac.html
    *.doc* | *.docx* | *.pptx* | *.odp* | *.odt* | *.odg* | *.rtf* | *.xls* | *.xlsx* | *.csv*) invoke "$office_program" "$@" & ;;

    # HTML files and XML files
    # TODO: convert filename arguments to use file:// prefix (to distinguish from URL's)
    *.html* | *.xml*) invoke "$BROWSER" "$@" & ;;

    # Text files and dot files
    *.txt* | *.text* | .*) invoke emacs "$@" & ;;

    # Windows XPS printer
    *.oxps* | *.xps*) invoke mupdf "$@" & ;;
    
    ## TEST:
    ## This illustrates what happens when ';;' not used at end of case
    ## *.abc* | *.pdq*) echo hey; emacs "$@"
    ## BAD: *.xyz*)
    ##		   echo hey2; emacs "$@" & ;;

    # Invoke MacOs-style app as if program (e.g., Safari.app)
    *.app*)
       invoke "$@" & ;;
    
    # Invoke default program for unknown extension
    *.*) 
       echo ""
       echo "*** Warning: Unknown extension in $1; using $default_program"
       invoke "$default_program" "$@" & ;;
    
    # Invoke extension-less file as if program
    *)
       invoke "$@" & ;;
    
esac
