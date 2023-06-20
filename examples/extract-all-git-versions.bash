#! /usr/bin/env bash
#
# Extracts all versions of a file under git.
#
# via https://stackoverflow.com/questions/12850030/git-getting-all-previous-version-of-a-specific-file-folder
#

# Set bash tracing
if [ "${TRACE:-0}" = "1" ]; then
    set -o xtrace
fi
if [ "${VERBOSE:-0}" = "1" ]; then
    set -o verbose
fi
## TODO: set strict more (i.e., fail immediately on error)
## set -e

# we'll write all git versions of the file to this folder:
TMP=${TMP:-/tmp}
EXPORT_TO=$TMP/all_versions_exported

# take relative path to the file to inspect
GIT_PATH_TO_FILE="$1"

# ---------------- don't edit below this line --------------

## OLD: USAGE="Please cd to the root of your git proj and specify path to file you with to inspect (example: $0 some/path/to/file)"
USAGE=$'\nNote:\n- cd to the root of your git proj, as follows:\n  cd "$(git rev-parse --show-toplevel)"\n- specify path to file you with to inspect\n- example:\n  '"$0 some/path/to/file"

# check if got argument
if [ "${GIT_PATH_TO_FILE}" == "" ]; then
    echo "error: no arguments given. ${USAGE}" >&2
    exit 1
fi

# check if file exists
if [ ! -f "${GIT_PATH_TO_FILE}" ]; then
    echo "error: File '${GIT_PATH_TO_FILE}' does not exist. ${USAGE}" >&2
    exit 1
fi

# make sure in repo dir
if ! git rev-parse --show-toplevel >/dev/null 2>&1 ; then
    echo "Error: you must run this from within a git working directory. ${USAGE}" >&2
    exit 1
fi

# extract just a filename from given relative path (will be used in result file names)
GIT_SHORT_FILENAME=$(basename "$GIT_PATH_TO_FILE")

# create folder to store all revisions of the file
if [ ! -d "${EXPORT_TO}" ]; then
    echo "creating folder: ${EXPORT_TO}"
    mkdir "${EXPORT_TO}"
fi

## uncomment next line to clear export folder each time you run script
#rm "${EXPORT_TO}"/*

# reset coutner
COUNT=0

# iterate all revisions
##
## OLD:
## git rev-list --all --objects -- ${GIT_PATH_TO_FILE} | \
##     cut -d ' ' -f1 | \
## while read h; do \
##      COUNT=$((COUNT + 1)); \
##      COUNT_PRETTY=$(printf "%04d" $COUNT); \
##      COMMIT_DATE=`git show $h | head -3 | grep 'Date:' | awk '{print $4"-"$3"-"$6}'`; \
##      if [ "${COMMIT_DATE}" != "" ]; then \
##          git cat-file -p ${h}:${GIT_PATH_TO_FILE} > ${EXPORT_TO}/${COUNT_PRETTY}.${COMMIT_DATE}.${h}.${GIT_SHORT_FILENAME};\
##      fi;\
## done    
##
# note: -r treats backslash literally
##
## OLD2:
## (while read -r h; do 
##      COUNT=$((COUNT + 1));
##      COUNT_PRETTY=$(printf "%04d" $COUNT);
##      COMMIT_DATE=$(git show "$h" | head -3 | grep 'Date:' | awk '{print $4"-"$3"-"$6}');
##      if [ "${COMMIT_DATE}" != "" ]; then
##          git cat-file -p "${h}:${GIT_PATH_TO_FILE}" > "${EXPORT_TO}/${GIT_SHORT_FILENAME}.${COUNT_PRETTY}.${COMMIT_DATE}";
##  
##      fi;
## done) <<<"$(git rev-list --all --objects -- "${GIT_PATH_TO_FILE}" |  cut -d ' ' -f1)"
##
## ALT:
## git log --diff-filter=d --date-order --reverse --format="%ad %H" --date=iso-strict "$FILE_PATH" | grep -v '^commit' | \
##     while read LINE; do \
##         COMMIT_DATE=`echo $LINE | cut -d ' ' -f 1`; \
##         COMMIT_SHA=`echo $LINE | cut -d ' ' -f 2`; \
##         printf '.' ; \
##         git cat-file -p "$COMMIT_SHA:$FILE_PATH" > "$EXPORT_TO/$COMMIT_DATE.$COMMIT_SHA.$FILE_NAME" ; \
##     done
## echo

(while read -r LINE; do
     # ex: 2021-05-09T22:27:20-05:00 d124b2a3c1de2b2c0cd834b0fa9097e871d7f141
     COUNT=$((COUNT + 1))
     COMMIT_DATE=$(echo "$LINE" | cut -d ' ' -f 1)
     COMMIT_SHA=$(echo "$LINE" | cut -d ' ' -f 2)
     printf '.'
     git cat-file -p "$COMMIT_SHA:$GIT_PATH_TO_FILE" > "$EXPORT_TO/$GIT_SHORT_FILENAME.$COUNT.$COMMIT_DATE"
done) <<<"$(git log --diff-filter=d --date-order --reverse --format="%ad %H" --date=iso-strict "$GIT_PATH_TO_FILE" | grep -v '^commit')"

# return success code
echo "result stored to ${EXPORT_TO}"
exit 0
