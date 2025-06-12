#! /usr/bin/env bash
#
# adhoc-backup-dir.bash: performs backup of current directory, limited to files changed
# in given period or smaller than a certain size.
#

# Uncomment following line(s) for tracing:
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#  
## echo "$@"
## set -o xtrace
## DEBUG: set -o verbose

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
    echo "ROOT_BACKUP_DIR=~/usb/sd512 MAX_DAYS_OLD=\$((3*365/12)) MAX_SIZE_CHARS=\$((5 * 1024**2)) $script --"
    echo ""
    echo "Notes:"
    echo "- By default, included files mopdified within 30 days and no larger than 1mb."
    echo "- Default backup directory is \$ROOT_BACKUP_DIR/backup/$HOSTNAME".
    echo "- Other env. options: EXCLUDE_REGEX, MAX_DAYS_OLD, MAX_SIZE_CHARS, SOURCE_DIR, TARGET_DIR."
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
## maldito shellcheck: [SC1090: Can't follow non-constant source]
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

# TODO: Do whatever
# NOTE: This evolved from a scriptlet in a notes file (hence the {'s)
## {{
## TODO: cd /                # for system backup
   TARGET_DIR=${TARGET_DIR:-""}
   if [ -n "$TARGET_DIR" ]; then
       cd "$TARGET_DIR"
   fi
   export MISC_FIND_OPTIONS=""
   export BASE_DIR
   BASE_DIR=$(basename "$PWD")
   if [ "$BASE_DIR" = "/" ]; then
       # note: uses "fs-root" for label if / and retricts to same file system
       export BASE_DIR=fs-root;
       export MISC_FIND_OPTIONS="-xdev"
       ## TODO2: exclude adhoc files and directories
       EXCLUDE_REGEX="${EXCLUDE_REGEX:-"(/proc/|/swapfile/|/tmp/)"}"
   else
       # note: no-op exclusion filter
       EXCLUDE_REGEX="${EXCLUDE_REGEX:-"($^)"}"       
   fi
   export SOURCE_DIR="$PWD"
   ## TODO: pre-select based on existence (i.e., prioritized check)
   ROOT_BACKUP_DIR=${ROOT_BACKUP_DIR:-$HOME/usb/sd512}
   if [ ! -e "$ROOT_BACKUP_DIR" ]; then
       echo "Error: ROOT_BACKUP_DIR directory must exist ($ROOT_BACKUP_DIR)."
       exit
   fi
   export BACKUP_DIR="$ROOT_BACKUP_DIR/backup/$HOSTNAME"
   mkdir -p "$BACKUP_DIR"
   df -h "$BACKUP_DIR"
   ## OLD: script "$trace_log"
       ## maldito mac: (current directory not preserved)
       cd "$SOURCE_DIR"

       max_days_old=${MAX_DAYS_OLD:-30}
       max_size_chars=${MAX_SIZE_CHARS:-1048576}
       max_size_with_suffix="$(echo "$max_size_chars" | apply-numeric-suffixes | downcase-stdin)"b
       if (( (max_days_old >= 36000) && (max_size_chars >= 1000000000000) )); then  # 100+ years 1+ tb
           basename="${BACKUP_DIR}/full-$HOSTNAME-$BASE_DIR"
       elif (( (max_days_old >= 1800) && (max_size_chars >= 1000000000) )); then    # 5+ years 1+ gb
           basename="${BACKUP_DIR}/fullish-$HOSTNAME-$BASE_DIR"
       else
           basename="${BACKUP_DIR}/incr-$HOSTNAME-$BASE_DIR-${max_days_old}days-max${max_size_with_suffix}"
       fi
       basename="$basename-$(TODAY)"
       echo "basename: $basename"
       #
       ## OLD: TAR="command tar"
       TAR="tar"

       # maldito shellcheck (SC2086: Double quote to prevent globbing)
       # shellcheck disable=SC2086
       rename-with-file-date "$basename.tar.log" 
       $NICE find ./* ./.[^.]* $MISC_FIND_OPTIONS -type f -mtime "-$max_days_old" -size "-${max_size_chars}c" | $EGREP -v "EXCLUDE_REGEX" | $NICE $TAR cvfzT "$basename.tar.gz" - > "$basename.tar.log" 2>&1
       dir "$basename"* | cat
       ##
       check-errors-excerpt "$basename.tar.log" | head
   ## OLD:
   ## exit
   ##
   ## check-errors "$trace_log"
## }
