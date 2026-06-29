#! /usr/bin/env bash
#
# Extracts all versions of a file under git.
#
# Note:
# - Alternative version that accounts for renamed files.
# - based on https://stackoverflow.com/questions/12850030/git-getting-all-previous-version-of-a-specific-file-folder
# - shell check
#   SC2016 (info): Expressions don't expand in single quotes
#   SC2116 (style): Useless echo?
# - Uses git log with following options (seee git-log manpage):
#      --date-order       commit timestamp order
#      --diff-filter=d    exclude deletions
#      --reverse          show older commits first
#      --format="%ad %H"  author date with hour
#      --date=iso-strict  strict ISO 8601 format
#      --follow           list history beyond renames
#
# TODO1: fix problem with extraneous error codes from git cat-file over alternative
# TODO3: merge with extract-all-git-versions.bash
#
# -------------------------------------------------------------------------------
# Details of Rename Resolution:
# - Uses a single 'git log --follow --name-status' pass to build a per-commit
#   mapping of (date, SHA, actual-file-path).
# - For A/C/M/T status lines the path is taken as-is; for R (rename) lines the
#   old path (pre-rename, field 2) is used, since that is the path git cat-file
#   needs to retrieve the file content from that commit.
# - This replaces an earlier two-pass approach (separate commit list + rename list
#   via grep ^R) that failed when git --follow traced history through
#   content-similar but independently-created files.  In that case --follow
#   produced no R entry in the name-status output (the sibling file appeared as A),
#   leaving ALT_PATHS empty and making every fallback attempt fail.
# -------------------------------------------------------------------------------
#

# Helpers
function full-usage {
    local script
    script="$(basename "$0")"
    declare -g export_to_expr
    echo ""
    echo "Usage: [env-spec] $script [--human] [--help] git-path [extract-dir]"
    echo ""
    echo "Examples:"
    echo ""
    ##
    ## OLD:
    ## # HACK: Uses Usage in filename so shows up in brief usage
    ## echo "NUM_REVISIONS=5 $script --human Usage.txt $export_to_expr"
    ##
    # HACK: Uses 'Usage' in filename so shows up in brief usage: see USAGE=... below.
    echo "NUM_REVISIONS=5 $script --human --verbose Usage.txt $export_to_expr"
    echo ""
    echo "PRETTY=1 VERBOSE=1 $0 Dockerfile"
    echo ""
    echo "Notes:"
    echo "- Default extract-dir: $export_to_expr"
    echo "- Env. vars: {EXPORT_TO, NUM_REVISIONS, PRETTY, VERBOSE, TMP}"
    echo "- Experimental ones: {ALLOW_RENAMES}"
    echo ""
}

# Set bash tracing
verbose=false
if [ "${VERBOSE:-0}" = "1" ]; then
    verbose=true
fi
debug=false
if [ "${DEBUG:-0}" = "1" ]; then
    debug=true
fi
if [ "${TRACE:-0}" = "1" ]; then
    set -o xtrace
    $verbose && set -o verbose
fi
## TODO: set strict more (i.e., fail immediately on error)
## set -e

# we'll write all git versions of the file to this folder:
TMP=${TMP:-/tmp}
# shellcheck disable=SC2016
export_to_expr='$TMP/all-git-versions'
# note: see https://stackoverflow.com/questions/11065077/the-eval-command-in-bash-and-its-typical-uses
# shellcheck disable=SC2116
$debug && echo "export_to_expr=$export_to_expr"
DEFAULT_EXPORT_TO="$(eval echo "$export_to_expr")"
$debug && echo "DEFAULT_EXPORT_TO=$DEFAULT_EXPORT_TO"
pretty=false
if [ "${PRETTY:-0}" = "1" ]; then pretty=true; fi

# Command line argument checks
while [[ $1 =~ ^-.* ]]; do
    if [ "$1" = "--human" ]; then
        ## OLD: verbose=true
        pretty=true
        shift
    fi
    if [ "$1" = "--verbose" ]; then
        verbose=true
        shift
    fi
    if [ "$1" = "--help" ]; then
        full-usage
        exit
    fi
done
export_to_value="${EXPORT_TO:-$DEFAULT_EXPORT_TO}"
EXPORT_TO="${2:-$export_to_value}"
#
# take relative path to the file to inspect
GIT_PATH_TO_FILE="$1"

NEWLINE=$'\n'
TWO_NEWLINES="$NEWLINE$NEWLINE"
USAGE=$(full-usage | grep 'Usage')      # brief usage

# check if got argument
if [ "${GIT_PATH_TO_FILE}" == "" ]; then
    echo "${USAGE}" >&2
    exit 1
fi

# check if file exists
if [ ! -f "${GIT_PATH_TO_FILE}" ]; then
    echo "Error: File '${GIT_PATH_TO_FILE}' does not exist.${TWO_NEWLINES}${USAGE}" >&2
    exit 1
fi

# make sure in repo dir
if ! git rev-parse --show-toplevel >/dev/null 2>&1 ; then
    echo "Error: you must run this from within a git working directory.${TWO_NEWLINES}${USAGE}" >&2
    exit 1
fi

# Resolve relative path with respect to git root directory
GIT_ROOT_DIR="$(realpath "$(git rev-parse --show-toplevel)")"
REL_GIT_PATH_TO_FILE="$(realpath "$GIT_PATH_TO_FILE" | perl -pe "s@$GIT_ROOT_DIR/@@;")"

# extract just a filename from given relative path (will be used in result file names)
GIT_SHORT_FILENAME=$(basename "$GIT_PATH_TO_FILE")

# create folder to store all revisions of the file
if [ ! -d "${EXPORT_TO}" ]; then
    $verbose && echo "creating folder: ${EXPORT_TO}"
    mkdir "${EXPORT_TO}"
fi

## uncomment next line to clear export folder each time you run script
## rm "${EXPORT_TO}"/*

# reset counter and do other initializaiton
COUNT=0
GOOD_COUNT=0
base=$(basename "$0" .bash)
info="$TMP/_$base.$$.info"
ALLOW_RENAMES="${ALLOW_RENAMES:-1}"

# Get information on commits, optionally checking for additional records due to renames
if [ "$ALLOW_RENAMES" == "0" ]; then
    git log --diff-filter=d --date-order --reverse --format="%ad %H" --date=iso-strict "$GIT_PATH_TO_FILE" | grep -v '^commit' > "$info"
else
    # note: --follow is used to account for renames (see other options above)
    # Combine commit info and per-commit file path into one pass:
    #   - COMMIT lines give date and SHA
    #   - A/C/M/T lines give path the file had in that commit
    #   - R lines give the old path (field 2) the file had before the rename
    # This avoids a separate rename-detection pass and correctly handles cases
    # where --follow uses content-similarity but produces no R entry (false renames
    # between independently-created files with similar content).
    git log --follow --name-status --format="COMMIT %ad %H" --date=iso-strict "$GIT_PATH_TO_FILE" | \
        perl -ne 'if (/^COMMIT (\S+) (\S+)/) { ($date,$sha)=($1,$2) }
                  elsif (/^[ACMT]\t(.+)/)    { print "$date $sha $1\n" }
                  elsif (/^R\d+\t([^\t]+)/)  { print "$date $sha $1\n" }' > "$info"
    $debug && echo "Commit/path list:"; $debug && cat "$info"
fi
TOTAL_NUM=$(wc -l < "$info")

# Extract the revisions
NUM_REVISIONS="${NUM_REVISIONS:-$TOTAL_NUM}"
while read -r LINE; do
    # ex: 2021-05-09T22:27:20-05:00 d124b2a3c1de2b2c0cd834b0fa9097e871d7f141
    COUNT=$((COUNT + 1))
    if [ "$COUNT" -gt "$NUM_REVISIONS" ]; then
        break
    fi
    $debug && echo "LINE$COUNT: $LINE"
    COMMIT_DATE=$(echo "$LINE" | cut -d ' ' -f 1)
    # optionally, convert date into DDmmmYY-HHMM format
    version_spec="$COUNT"
    date_spec="$COMMIT_DATE"
    hour_spec=""
    if $pretty; then
        # Use more readable date and version specs
        # ex: "README.md.1-2024-01-24T14:02:43+05:45" => "README.md.v3-24jan24"
        date_spec="$(date "+%d%b%y" --date="$COMMIT_DATE")"
        date_spec="${date_spec,,}"      # converts all text to lower
        hour_spec="$(date "+%H%M" --date="$COMMIT_DATE")"
        VERSION_NUM="$COUNT"
        if [ "$ALLOW_RENAMES" == "1" ]; then
            ## OLD: VERSION_NUM=$(($TOTAL_NUM - $COUNT + 1))
            VERSION_NUM=$((TOTAL_NUM - COUNT + 1))
        fi
        version_spec="v$VERSION_NUM"
    fi
    COMMIT_SHA=$(echo "$LINE" | cut -d ' ' -f 2)
    # for ALLOW_RENAMES use per-commit path extracted from --name-status (field 3+);
    # otherwise use the fixed relative path
    COMMIT_FILE_PATH="$REL_GIT_PATH_TO_FILE"
    if [ "$ALLOW_RENAMES" == "1" ]; then
        COMMIT_FILE_PATH=$(echo "$LINE" | cut -d ' ' -f 3-)
    fi
    $debug && echo "COUNT=$COUNT COMMIT_DATE=$COMMIT_DATE COMMIT_SHA=$COMMIT_SHA COMMIT_FILE_PATH=$COMMIT_FILE_PATH"
    output_file="$EXPORT_TO/$GIT_SHORT_FILENAME.${version_spec}-${date_spec}"
    if [ -e "$output_file" ]; then
        echo "Warning: adding time of day ($hour_spec) to distinguish '$output_file'";
        output_file="${output_file}_${hour_spec}";
    fi
    $debug && echo "Trying path $COMMIT_FILE_PATH for version $version_spec"
    ## OLD: git cat-file -p "$COMMIT_SHA:$COMMIT_FILE_PATH" > "$output_file" 2> "$info.err"
    ## NOTE: >| used since $info.err reused
    git cat-file -p "$COMMIT_SHA:$COMMIT_FILE_PATH" > "$output_file" 2>| "$info.err"
    commit_resolved=false
    ## OLD: if [ $? -eq 0 ]; then
    status="$?"
    if [ $status -eq 0 ]; then
        commit_resolved=true
        ## OLD: let GOOD_COUNT++
        (( GOOD_COUNT++ ))
    else
        head -3 "$info.err"
        ## OLD: echo "Error: unable to resolve commit $COMMIT_SHA"
        echo "Error: unable to resolve commit $COMMIT_SHA (status=$status)"
        rm -f "$output_file"
    fi
    $verbose && $commit_resolved && echo "$output_file"
done <"$info"

# return success code
$verbose && echo ""
echo "$GOOD_COUNT versions stored in ${EXPORT_TO} for $GIT_PATH_TO_FILE"
exit 0
