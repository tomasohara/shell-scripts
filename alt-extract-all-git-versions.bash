#! /usr/bin/env bash
#
# Extracts all versions of a file under git.
#
# Note:
# - Akternative version that accounts for renamed files.
# - based on https://stackoverflow.com/questions/12850030/git-getting-all-previous-version-of-a-specific-file-folder
# - shell check
#   SC2016 (info): Expressions don't expand in single quotes
#   SC2116 (style): Useless echo?
# - Uses git log with following options (seee git-log manpage):
#      --date-order       commit timestamp order
#      --diff-filter=d    exclude deletions
#      --reverse          shown older commits first
#      --format="%ad %H"  author date with hour
#      --date=iso-strict  strict ISO 8601 format
#      --follow           list history beyond renames
#
# TODO1: fix problem with extraneous error codes from git cat-file over alternative
# TODO3: merge with extract-all-git-versions.bash
#

# Helpers
function full-usage {
    local script
    script="$(basename "$0")"
    echo ""
    echo "Usage: $script [--human] [--help] git-path [extract-dir]"
    echo ""
    echo "Examples:"
    echo ""
    echo "$0 README.md /tmp/README-versions"
    echo ""
    echo "PRETTY=1 VERBOSE=1 {script} Dockerfile"
    echo ""
    echo "Notes:"
    echo "- default extract-dir: $export_to_expr"
    echo "- Env. vars: {EXPORT_TO, PRETTY, VERBOSE, TMP}"
    echo "- Experimental ones: {MAX_NUM, ALLOW_RENAMES}"
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
DEFAULT_EXPORT_TO="$(eval echo "$export_to_expr")"
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

## OLD: USAGE=$'\nNote:\n- cd to the root of your git proj, as follows:\n  cd "$(git rev-parse --show-toplevel)"\n- specify path to file you with to inspect\n- example:\n  '"$0 some/path/to/file"
NEWLINE=$'\n'
TWO_NEWLINES="$NEWLINE$NEWLINE"
## OLD: script="$(basename "$0")"
## OLD: USAGE="Usage: $(basename "$0") [--human] path [extract-dir=$DEFAULT_EXPORT_TO]${NEWLINE}${NEWLINE}Example(s):${NEWLINE}${NEWLINE}$0 README.md /tmp/README-versions${NEWLINE}${NEWLINE}PRETTY=1 VERBOSE=1 ${script} Dockerfile"
USAGE=$(full-usage | grep 'Usage:')

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
#rm "${EXPORT_TO}"/*

# reset coutner
COUNT=0
GOOD_COUNT=0

base=$(basename "$0" .bash)
info="$TMP/_$base.$$.info"
ALLOW_RENAMES="${ALLOW_RENAMES:-1}"
if [ "$ALLOW_RENAMES" == "0" ]; then
    git log --diff-filter=d --date-order --reverse --format="%ad %H" --date=iso-strict "$GIT_PATH_TO_FILE" | grep -v '^commit' > "$info"
else
    # note: --follow used to account for renames (see other options above)
    git log --follow --format="%ad %H" --date=iso-strict "$GIT_PATH_TO_FILE" | grep -v '^commit' > "$info"
    # Get information on renames
    # TODO2: factor in relative path of current directory if not invoked from git root
    # "R100	.github/workflows/python.yml	.github/workflows/github.yml"
    git log --name-status --follow "$GIT_PATH_TO_FILE" | grep ^R > "$info.renames"
    ALT_PATHS=$(cut -f2 -d $'\t' "$info.renames")
    $debug && echo "ALT_PATHS=(${ALT_PATHS[*]})"
fi
TOTAL_NUM=$(wc -l < "$info")
MAX_NUM=${MAX_NUM:-$TOTAL_NUM}

while read -r LINE; do
    # ex: 2021-05-09T22:27:20-05:00 d124b2a3c1de2b2c0cd834b0fa9097e871d7f141
    COUNT=$((COUNT + 1))
    if [ "$COUNT" -gt "$MAX_NUM" ]; then
	break
    fi
    $debug && echo "LINE$COUNT: $LINE"
    COMMIT_DATE=$(echo "$LINE" | cut -d ' ' -f 1)
    # optionally, convert date into DDmmmYY-HHMM format
    version_spec="$COUNT"
    date_spec="$COMMIT_DATE"
    hour_spec=""
    if $pretty; then
	date_spec="$(date "+%d%b%y" --date="$COMMIT_DATE")"
	hour_spec="$(date "+%H%M" --date="$COMMIT_DATE")"
	VERSION_NUM="$COUNT"
	if [ "$ALLOW_RENAMES" == "1" ]; then
	    VERSION_NUM=$(($TOTAL_NUM - $COUNT + 1))
	fi
	version_spec="v$VERSION_NUM"
    fi
    COMMIT_SHA=$(echo "$LINE" | cut -d ' ' -f 2)
    $debug && echo "COUNT=$COUNT LINE=$LINE COMMIT_DATE=$COMMIT_DATE COMMIT_SHA=$COMMIT_SHA"
    ## OLD: $verbose && printf '.'
    ## OLD: output_file="$EXPORT_TO/$GIT_SHORT_FILENAME.$COUNT.$COMMIT_DATE"
    output_file="$EXPORT_TO/$GIT_SHORT_FILENAME.${version_spec}-${date_spec}"
    if [ -e "$output_file" ]; then
	echo "Warning: adding time of day ($hour_spec) to distinguish '$output_file'";
	output_file="${output_file}_${hour_spec}";
    fi
    ## DEBUG:
    echo "Trying main path $REL_GIT_PATH_TO_FILE for version $version_spec"
    git cat-file -p "$COMMIT_SHA:$REL_GIT_PATH_TO_FILE" > "$output_file" 2> "$info.err"
    if [ $? -eq 0 ]; then
	let GOOD_COUNT++
    else
	head -3 "$info.err"
	if [ "$ALLOW_RENAMES" == "1" ]; then
	    for f in "${ALT_PATHS[@]}"; do
		echo "Trying alternative path $f"
		git cat-file -p "$COMMIT_SHA:$f" >| "$output_file" 2>  "$info.err"
		if [ $? -eq 0 ]; then
		    let GOOD_COUNT++
		    break
		fi
		head -3 "$info.err"
	    done
	    echo "Error: unable to resolve commit $COMMIT_SHA"
	fi
    fi
    $verbose && echo "$output_file"
done <"$info"

# return success code
$verbose && echo ""
echo "$GOOD_COUNT versions stored in ${EXPORT_TO} for $GIT_PATH_TO_FILE"
exit 0
