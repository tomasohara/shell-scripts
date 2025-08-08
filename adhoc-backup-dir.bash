#! /usr/bin/env bash
#
# adhoc-backup-dir.bash: performs backup of current directory, limited to files changed
# in given period or smaller than a certain size.
#
# Note:
# - Originally based on Bash notes in file, so includes ';' for cut-n-paste and other
#   interactive relics.
# - Selectively ignores following shellcheck warnings:
#   SC1090: Can't follow non-constant source
#   SC2086: Double quote to prevent globbing
#   SC2010 (warning): Don't use ls | grep. Use a glob or a for loop with a condition to allow non-alphanumeric filenames.
#

# Uncomment following line(s) for tracing:
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#  
if [ "${DEBUG_LEVEL:-0}" -ge 4 ]; then
    echo "$0 $*"
fi
if [[ "${TRACE:-0}" == "1" ]]; then
    set -o xtrace
fi
if [[ "${VERBOSE:-0}" == "1" ]]; then
    set -o verbose
fi

# Show usage statement
# TODO: convert into a function that get invoked when $1 is empty or --help
# in $@.
# NOTE: See sync-loop.sh for an example.
#
if [[ ("$1" = "") || ("$1" = "--help") ]]; then
    script=$(basename "$0")
    ## TODO: if [ $script ~= *\ * ]; then script='"'$script'"; fi
    ## TODO: base=$(basename "$0" .bash)
    echo ""
    echo "Usage: $0 [--trace] [--help] [-- | -]"
    echo ""
    echo "Examples:"
    echo ""
    echo "$0 --"
    echo ""
    echo "INTERACTIVE=1 BACKUP_DRIVE=~/usb/sd512 MAX_DAYS_OLD=\$((3*365/12)) MAX_SIZE_CHARS=\$((5 * 1024**2)) $script --"
    echo ""
    echo "Notes:"
    echo "- By default, included files mopdified within 30 days and no larger than 1mb."
    echo "- Default backup directory is \$BACKUP_DRIVE/backup/$HOSTNAME".
    echo "- Using INTERACTIVE=1 to enable more sanity checks (n.b., work in progress)."
    echo "- Other env. options: BACKUP_DIR, EXCLUDE_REGEX, MAX_DAYS_OLD, MAX_SIZE_CHARS, SOURCE_DIR, TARGET_DIR."
    echo "- The -- option is to use default options and to avoid usage statement."
    echo ""
    exit
fi

# Parse command-line options
#
moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
trace=0
verbose=0
while [ "$moreoptions" = "1" ]; do
    if [ "$1" = "--trace" ]; then
        trace=1
    elif [ "$1" = "--verbose" ]; then
        verbose=1
    elif [[ ("$1" = "--") || ("$1" = "-") ]]; then
        break
    else
        echo "ERROR: Unknown option: $1";
        exit
    fi
    shift;
    moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
done

# TODO: create helper with this
# Get aliases (n.b., tracing should be delayed)
shopt -s expand_aliases
{
    source_dir="$(dirname "${BASH_SOURCE[0]:-$0}")"
    # shellcheck disable=SC1090
    source "$source_dir"/all-tomohara-aliases-etc.bash
}
#
# Set tracing (delayed so alias definitions not traced)
if [ "$trace" = "1" ]; then
    set -o xtrace
fi
if [ "$verbose" = "1" ]; then
    set -o verbose
fi

# TEMP: adhoc fixup for crontab usage
append-path "$source_dir"

# Do the backup
# NOTE: This evolved from a scriptlet in a notes file (hence the extraneous {'s)
{
    ## pre-init: export BACKUP_DRIVE="/mnt/micro-sd-1tb" MAX_DAYS_OLD=$((10 * 366)) MAX_SIZE_CHARS=$((10**9))
    ## *** cut-n-paste twice: 1) after optional cd and 3) after script ***
              ## TODO: cd /    ## for system backup;       export SUBDIRS="home tpo"
   {  ## * cut-n-paste #1
     TARGET_DIR=${TARGET_DIR:-""}
     if [ -n "$TARGET_DIR" ]; then
         cd "$TARGET_DIR"
     fi
     export MISC_FIND_OPTIONS="";
     export BASE_DIR;
     BASE_DIR=$(basename "$PWD");
     if [ "$BASE_DIR" = "/" ]; then
         # note: uses "fs-root" for label if / and retricts to same file system
         export BASE_DIR=fs-root;
         export MISC_FIND_OPTIONS="-xdev";
         ## TODO2: exclude adhoc files and directories
         EXCLUDE_REGEX="${EXCLUDE_REGEX:-"(/proc/|/swapfile/|/tmp/)"}";
     else
         # note: no-op exclusion filter
         EXCLUDE_REGEX="${EXCLUDE_REGEX:-"($^)"}";
     fi
     
     # Create backup directory after making sure not bad mount point (i.e., uninitialized)
     # TODO: see if more standard way to test for bad mount directory
     BACKUP_DRIVE="${BACKUP_DRIVE:-/mnt/backup}";
     export BACKUP_DIR="${BACKUP_DIR:-"$BACKUP_DRIVE/backup/$(uname -n)"}";
     # note: by convention /mnt/BAD-MOUNT-POINT.txt put in placeholder dir for mount
     if [ ! -e "$BACKUP_DRIVE/backup" ]; then
         # ex: "/mnt/wd6tbp2ntfs/backup/tpo-jugador" => "/mnt/wd6tbp2ntfs/"
         BACKUP_DRIVE=$(echo "$BACKUP_DIR" | perl -pe "s@^((/mnt|(/media/$USER))/[^/]+).*@\1@;");
     fi
     # shellcheck disable=SC2010
     if [[ "" != $(ls "$BACKUP_DRIVE" | grep -i "BAD-MOUNT-POINT") ]]; then
         pause-for-enter "Error: mount $BACKUP_DRIVE first";
     fi
     mkdir -p "$BACKUP_DIR";

     # Make miscellaneous settings in case typescript used interactively
     export SOURCE_DIR="${SOURCE_DIR:-"$PWD"}";
     export INTERACTIVE;
     INTERACTIVE="$(is-true "INTERACTIVE")";
     if [[ $- =~ i ]]; then export INTERACTIVE=true; fi;

     # Make sanity checks
     df -h "$BACKUP_DIR";
     trace_log="_n/a_.log";
     if $INTERACTIVE; then
         trace_log="$BACKUP_DIR/_make-${BASE_DIR}-incremental-backup-$(TODAY).log";
         rename-with-file-date "$trace_log";
         touch "$trace_log";
         echo "Trace log info:";
         echo -n $'\t'; wc "$trace_log";
         pause-for-enter "Make sure trace log created OK";
     fi
   }

   ok=0;
   if $INTERACTIVE; then
       ## TODO2: create temp script for part 2 and source that
       prompt="script '$trace_log'";
       read -r -e -i "$prompt" command;
       echo "cut-n-paste second snippet";
       eval "$command";
   fi
   {
       ## maldito mac: (current directory not preserved)
       cd "$SOURCE_DIR";

       ## * cut-n-paste #2;  m=3; export MAX_DAYS_OLD=$((m * 31)); c=100; export MAX_SIZE_CHARS=$((c * 2**20));  trace-vars MAX_DAYS_OLD MAX_SIZE_CHARS
       max_days_old="${MAX_DAYS_OLD:-31}";
       ## -or-: MAX_DAYS_OLD=92;   -or-: MAX_DAYS_OLD=366;   -or-: MAX_DAYS_OLD=$(calc-int "5 * 365.25");
       max_size_chars="${MAX_SIZE_CHARS:-$(calc-int "5 * 1024**2")}";
       ## -or-: MAX_SIZE_CHARS=131072 ## (128k)   -or-: MAX_SIZE_CHARS=1048577  -or-: MAX_SIZE_CHARS=1000000000 ## (1gb)
       trace-vars max_days_old max_size_chars | apply-numeric-suffixes;
       max_size_with_suffix=$(echo "$max_size_chars" | apply-numeric-suffixes);
       if (( (max_days_old >= 36000) && (max_size_chars >= 1000000000000) )); then
           basename="${BACKUP_DIR}/full-$HOSTNAME-$BASE_DIR";
       elif (( (max_days_old >= 1800) && (max_size_chars >= 1000000000) )); then
           basename="${BACKUP_DIR}/fullish-$HOSTNAME-$BASE_DIR";
       else
           basename="${BACKUP_DIR}/incr-$HOSTNAME-$BASE_DIR-${max_days_old}days-max${max_size_with_suffix}";
       fi
       basename="$basename-$(TODAY)";
       echo "basename: $basename";
       #
       TAR="${TAR:-"tar"}";
       #
       # NOTE: Filters /System/Volume to avoid spurious errors (e.g., "Cannot stat")
       subdirs=("${SUBDIRS:-"."}");
       if [[ ("${subdirs[*]}" == ".") && ("$BASE_DIR" == "fs-root") ]]; then
          # note: populate subdirs from the output of the command; -t strips newlines;
          # this redundantly includes . for files at top-level
          readarray -t subdirs < <(find . -maxdepth 1 -type d | $EGREP -v 'tmp');
       fi
       trace-array-vars subdirs;
       
       # Do the backup proper
       # note: extracts file list first and then creates archive (e.g., for better error recovery)
       # TODO3: remove if no errors are the tar log includes the file list
       rename-with-file-date "$basename.tar.log";
       ## OLD: ($NICE find "${subdirs[@]}" $MISC_FIND_OPTIONS -type f -mtime "-$max_days_old" -size "-${max_size_chars}c" | $EGREP -v '(^./System/Volume)' | $EGREP -v "EXCLUDE_REGEX" | $NICE $TAR cvfzT "$basename.tar.gz" -) > "$basename.tar.log" 2>&1;
       # shellcheck disable=SC2086
       {
           ($NICE find "${subdirs[@]}" $MISC_FIND_OPTIONS -type f -mtime "-$max_days_old" -size "-${max_size_chars}c" | $EGREP -v '(^./System/Volume)' | $EGREP -v "EXCLUDE_REGEX") > "$basename.file.list" 2> "$basename.file.log";
           ($NICE $TAR cvfzT "$basename.tar.gz" "$basename.file.list") > "$basename.tar.log" 2>&1;
       }
       ok=$?;
       dir "$basename"* | cat;
       #
       check-errors-excerpt "$basename.tar.log" | head;
     }

   if $INTERACTIVE; then
       [ $ok == 0 ] && exit;    # exit out of script command
       #
       check-errors-excerpt "$trace_log" | head;
   fi
}                   ## ** don't cut-n-paste here **
