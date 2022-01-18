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
    script=`basename $0`
    echo ""
    echo "Usage: $script [--view|[--edit|--open]] [--verbose] [--trace] [--help] file"
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
    local today=$(date '+%d%b%y')
    ## OLD: local log_dir="$TEMP/invocations"
    local log_dir="$TEMP/$USER/invocations"
    if [ ! -e "log_dir" ]; then mkdir -p "$log_dir"; fi
    local log_file="$log_dir/$(basename "$program")-$(basename "$file")-$today.log"
    if [ ! -e "$log_file" ]; then touch "$log_file"; fi
    if [ "$verbose" = "1" ]; then echo "Issuing: \"$program\" \"$file\" >> \"$log_file\" 2>&1"; fi
    "$program" "$file" >> "$log_file" 2>&1
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
    nautilus "$file" &
    exit
fi
# Otherwise, use program based on file extension
lower_file=$(echo "$file" | perl -pe 's/(.*)/\L$1/;')

# Change invoked program if different for editing than for viewing
pdf_program="evince"
image_program="eog"
# TODO: doc_program="libreoffice"
if [ "$for_editting" = "1" ]; then
    pdf_program="okular"
    image_program="pinta"
fi
    
#
case "$lower_file" in
    # PDF and posscript files
    ## OLD: *.pdf | *.ps) invoke evince "$@" & ;;
    ## OLD: *.pdf | *.ps) invoke okular "$@" & ;;
    *.pdf | *.ps) invoke "$pdf_program" "$@" & ;;

    # Image files
    # note: uses viewer that Files invokes (eog, the "eye of GNOME")
    ## OLD: *.jpeg | *.jpg | *.png | *.gif | *.xcf) invoke /usr/lib/pinta/Pinta.exe "$@" & ;;
    ## OLD: *.jpeg | *.jpg | *.png | *.gif | *.xcf) invoke eog "$@" & ;;
    *.jpeg | *.jpg | *.png | *.gif | *.svg | *.xcf) invoke "$image_program"  "$@" & ;;

    # Video files
    *.mov | *.mp4) invoke vlc "$@" & ;;

    # Audio files
    *.mp3 | *.wav) invoke vlc "$@" & ;;
    
    # MS Office and LibreOffice files: word processor files, spreadsheets, etc.
    *.doc | *.docx | *.pptx | *.odp | *.odt | *.odg | *.xls | *.xlsx | *.csv) invoke libreoffice "$@" & ;;

    # HTML files and XML files
    *.html | *.xml) invoke firefox "$@" & ;;

    # Text files
    *.txt | *.text) invoke emacs "$@" & ;;

    # Windows XPS printer
    *.oxps | *.xps) invoke mupdf "$@" & ;;
    
    ## TEST:
    ## This illustrates what happens when ';;' not used at end of case
    ## *.abc | *.pdq) echo hey; emacs "$@"
    ## BAD: *.xyz)
    ##		   echo hey2; emacs "$@" & ;;
    
    # Default processing
    *)
       echo ""
       echo "*** Warning: Unknown extension in $1; using Emacs"
       invoke emacs "$@" & ;;
esac
