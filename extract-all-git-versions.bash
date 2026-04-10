#! /usr/bin/env bash
#
# Extracts all versions of a file under git.
#
# Note:
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
# TODO3: merge with alt-extract-all-git-versions.bash
#

# Helpers
function full-usage {
    local script
    script="$(basename "$0")"
    echo ""
    echo "    Warning: deprecated script: use alt-extract-all-git-versions.bash."
    echo ""
    echo "Usage: [env-spec] $script [--human] [--help] git-path [extract-dir]"
    echo ""
    echo "Examples:"
    echo ""
    # HACK: Uses Usage in filename so shows up in brief usage
    echo "NUM_REVISIONS=5 $script --human Usage.txt /tmp/git-versions"
    echo ""
    echo "PRETTY=1 VERBOSE=1 $0 Dockerfile"
    echo ""
    echo "Notes:"
    echo "- Default extract-dir: $export_to_expr"
    echo "- Env. vars: {EXPORT_TO, NUM_REVISIONS, PRETTY, VERBOSE, TMP}"
    echo "- Experimental ones: {QUICK_MODE}"
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
export_to_expr='$TMP/all_versions_exported'
# note: see https://stackoverflow.com/questions/11065077/the-eval-command-in-bash-and-its-typical-uses
# shellcheck disable=SC2116
$debug && echo "export_to_expr=$export_to_expr"
DEFAULT_EXPORT_TO="$(eval echo "$export_to_expr")"
$debug && echo "DEFAULT_EXPORT_TO=$DEFAULT_EXPORT_TO"
pretty=false
if [ "${PRETTY:-0}" = "1" ]; then pretty=true; fi

# Command line argument checks
if [ "$1" = "--human" ]; then
    verbose=true
    pretty=true
    shift
fi
if [ "$1" = "--help" ]; then
    full-usage
    exit
fi
export_to_value="${EXPORT_TO:-$DEFAULT_EXPORT_TO}"
EXPORT_TO="${2:-$export_to_value}"
#
# take relative path to the file to inspect
GIT_PATH_TO_FILE="$1"

NEWLINE=$'\n'
TWO_NEWLINES="$NEWLINE$NEWLINE"
USAGE=$(full-usage | grep 'Usage')

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

# Get information on commits, optionally checking for additional records due to renames
git log --diff-filter=d --date-order --reverse --format="%ad %H" --date=iso-strict "$GIT_PATH_TO_FILE" | grep -v '^commit' > "$info"
TOTAL_NUM=$(wc -l < "$info")
if [ "${QUICK_MODE:-0}" == "0" ]; then
    total_num_cases=$(git --no-pager log --follow "$GIT_PATH_TO_FILE" | grep -c '^commit')
    if [ "$TOTAL_NUM" != "$total_num_cases" ]; then
        echo "Warning: Additional cases due to renames: try alt-extract-all-git-versions.bash"
    fi
fi

# Extract the revisions
NUM_REVISIONS="${NUM_REVISIONS:-$TOTAL_NUM}"
first_case=$(($TOTAL_NUM - $NUM_REVISIONS + 1))
while read -r LINE; do
    # ex: 2021-05-09T22:27:20-05:00 d124b2a3c1de2b2c0cd834b0fa9097e871d7f141
    COUNT=$((COUNT + 1))
    if [ $COUNT -lt $first_case ]; then
        $debug && echo "FYI: Ignoring case $COUNT ($LINE))"
        continue
    fi
    COMMIT_DATE=$(echo "$LINE" | cut -d ' ' -f 1)
    # optionally, convert date into DDmmmYY-HHMM format
    version_spec="$COUNT"
    date_spec="$COMMIT_DATE"
    hour_spec=""
    if $pretty; then
        date_spec="$(date "+%d%b%y" --date="$COMMIT_DATE")"
        hour_spec="$(date "+%H%M" --date="$COMMIT_DATE")"
        version_spec="v$COUNT"
    fi
    COMMIT_SHA=$(echo "$LINE" | cut -d ' ' -f 2)
    $debug && echo "COUNT=$COUNT LINE=$LINE COMMIT_DATE=$COMMIT_DATE COMMIT_SHA=$COMMIT_SHA"
    output_file="$EXPORT_TO/$GIT_SHORT_FILENAME.${version_spec}-${date_spec}"
    if [ -e "$output_file" ]; then
        echo "Warning: adding time of day ($hour_spec) to distinguish '$output_file'";
        output_file="${output_file}_${hour_spec}";
    fi
    git cat-file -p "$COMMIT_SHA:$REL_GIT_PATH_TO_FILE" > "$output_file"
    if [ $? -eq 0 ]; then
        let GOOD_COUNT++
    fi
    $verbose && echo "$output_file"
done <"$info"

# return success code
$verbose && echo ""
echo "$GOOD_COUNT versions stored in ${EXPORT_TO} for $GIT_PATH_TO_FILE"
exit 0
