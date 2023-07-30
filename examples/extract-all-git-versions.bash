#! /usr/bin/env bash
#
# Extracts all versions of a file under git.
#
# via https://stackoverflow.com/questions/12850030/git-getting-all-previous-version-of-a-specific-file-folder
#

# Set bash tracing
verbose=false
if [ "${VERBOSE:-0}" = "1" ]; then
    verbose=true
fi
if [ "${TRACE:-0}" = "1" ]; then
    set -o xtrace
    $verbose && set -o verbose
fi
## TODO: set strict more (i.e., fail immediately on error)
## set -e

# we'll write all git versions of the file to this folder:
TMP=${TMP:-/tmp}
DEFAULT_EXPORT_TO="$TMP/all_versions_exported"
pretty=false
if [ "${PRETTY:-0}" = "1" ]; then pretty=true; fi

# Command line argument checks
if [ "$1" = "--human" ]; then
    verbose=true
    pretty=true
    shift
fi
EXPORT_TO="${2:-$DEFAULT_EXPORT_TO}"
#
# take relative path to the file to inspect
GIT_PATH_TO_FILE="$1"

## OLD: USAGE=$'\nNote:\n- cd to the root of your git proj, as follows:\n  cd "$(git rev-parse --show-toplevel)"\n- specify path to file you with to inspect\n- example:\n  '"$0 some/path/to/file"
NEWLINE=$'\n'
TWO_NEWLINES="$NEWLINE$NEWLINE"
script="$(basename "$0")"
USAGE="Usage: $(basename "$0") [--human] path [extract-dir=$DEFAULT_EXPORT_TO]${NEWLINE}${NEWLINE}Example(s):${NEWLINE}${NEWLINE}$0 README.md /tmp/README-versions${NEWLINE}${NEWLINE}PRETTY=1 VERBOSE=1 ${script} Dockerfile"


# check if got argument
if [ "${GIT_PATH_TO_FILE}" == "" ]; then
    ## OLD: echo "error: no arguments given. ${USAGE}" >&2
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
#rm "${EXPORT_TO}"/*

# reset coutner
COUNT=0

base=$(basename "$0" .bash)
info="$TMP/_$base.$$.info"
git log --diff-filter=d --date-order --reverse --format="%ad %H" --date=iso-strict "$GIT_PATH_TO_FILE" | grep -v '^commit' > "$info"
while read -r LINE; do
    # ex: 2021-05-09T22:27:20-05:00 d124b2a3c1de2b2c0cd834b0fa9097e871d7f141
    COUNT=$((COUNT + 1))
    COMMIT_DATE=$(echo "$LINE" | cut -d ' ' -f 1)
    # optionaly, convert date into DDmmmYY-HHMM format
    version_spec="$COUNT"
    date_spec="COMMIT_DATE"
    hour_spec=""
    if $pretty; then
	date_spec="$(date "+%d%b%y" --date="$COMMIT_DATE")"
	hour_spec="$(date "+%H%M" --date="$COMMIT_DATE")"
	version_spec="v$COUNT"
    fi
    COMMIT_SHA=$(echo "$LINE" | cut -d ' ' -f 2)
    ## DEBUG: echo "COUNT=$COUNT LINE=$LINE COMMIT_DATE=$COMMIT_DATE COMMIT_SHA=$COMMIT_SHA"
    ## OLD: $verbose && printf '.'
    ## OLD: output_file="$EXPORT_TO/$GIT_SHORT_FILENAME.$COUNT.$COMMIT_DATE"
    output_file="$EXPORT_TO/$GIT_SHORT_FILENAME.${version_spec}-${date_spec}"
    if [ -e "$output_file" ]; then
	echo "Warning: adding time of day ($hour_spec) to distinguish '$output_file'";
	output_file="${output_file}_${hour_spec}";
    fi
    git cat-file -p "$COMMIT_SHA:$REL_GIT_PATH_TO_FILE" > "$output_file"
    $verbose && echo "$output_file"
done <"$info"

# return success code
$verbose && echo ""
echo "$COUNT versions stored in ${EXPORT_TO} for $GIT_PATH_TO_FILE"
exit 0
