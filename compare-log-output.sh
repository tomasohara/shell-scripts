#! /bin/sh
#
# compare-log-output.sh: compare trace output listings ignoring differences
# due to timestamps
#
# TODO:
# - Rename to indicate underlying diff operation (e.g., diff-log-output.sh).
# - Allow for case-sensitive regex's.
#

# Uncomment the line(s) below for tracing (verbose shows command before and after, xtrace just shows it after):
#
## set -o xtrace
## DEBUG: set -o verbose

# Parse command-line arguments
diff=kdiff.sh
ignore='((0x)?[0-9A-Fa-f]{7,16})'
include_time=0
moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
while [ "$moreoptions" = "1" ]; do
    if [ "$1" = "--trace" ]; then
	set -o xtrace
	## DEBUG: set -o verbose
    elif [ "$1" = "--diff" ]; then
	diff="$2";
	shift
    elif [ "$1" = "--plain-diff" ]; then
	diff="diff";
    elif [ "$1" = "--include-ptrs" ]; then
        ignore="";
    elif [ "$1" = "--include-time" ]; then
        include_time=1;
    elif [ "$1" = "--reset-ignore" ]; then
        ignore="";
    elif [ "$1" = "--ignore" ]; then
	## OLD: ignore="$2";
	ignore="$ignore|($2)";
	shift
    else
	echo "unknown option: $1";
	# TODO: show_usage=1
    fi
    shift 1;
    moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
done
#
if [ "$1" = "" ]; then
    script_name=$(basename "$0")
    echo ""
    echo "Usage: $script_name [options] file1 file2-or-dir"
    echo ""
    echo "    options: [--ignore perl-regex] [--include-ptrs | --include-time | --reset-ignore] [--plain-diff] [--diff program]"
    echo ""
    echo "Examples:"
    echo ""
    echo "$script_name --ignore '^\d+:\d+:\d+,\d+' jboss-init-1.log  jboss-init-2.log"
    echo ""
    echo "$script_name --ignore '^\s*<job_id>.*' city_easternshore_md.xml ../craigslist_20160609_usa100/"
    echo ""
    echo "Notes:"
    echo "- The regex pattern matching is not case sensitive (i.g., case ignored)."
    echo "- Timestamps are removed prior to comparison unless --include-time ."
    echo "- Hex addresses are removed as with '--ignore [0-9A-Fa-f]{7,16}'."
    echo "- Additional filter pattern can be specified via --ignore".
    echo "- The pattern for ignore is a perl regex."
    echo "- Use --reset-ignore to ignore the default patterns."
    echo "- The --include-ptrs option is alias for --reset-ignore."
    echo "- kdiff is default diff program (see kdiff.sh)."
    exit
fi

# Determine the files to work on
file1="$1"
file2="$2"
if [ -d "$file2" ]; then
    file2="$file2"/$(basename "$file1")
fi
base1="_1_"$(basename "$file1")
base2="_2_"$(basename "$file2")

# Setup copies under $TMP (n.b., later modified in place)
cp "$file1" "$TMP/$base1"
cp "$file2" "$TMP/$base2"

# Strip out timestamps (e.g., "Jun 14, 2006 3:18:43 AM" and "[06/19/06 16:16:04]")
# TODO: 
# - Support logging-style timestamps.
# - Try following:
#      pattern="((\\S+\\s*\\S+\\s*\\d{4} \\d{1,2}:\\d{2}:\\d{2} [ap]m )|(\\d{1,2}\\/\\d{2}\\/\\d{2} \\d{1,2}:\\d{2}:\\d{2}))"
#      perl -pe "'" "s/$pattern//i;" "'" $file1 > $TMP/$base1 ...
# - Decompose timestamp regex to make more efficient.
# - Make this timestamp removal optional.
# NOTE: Backslashes used above to avoid shell interpretation (during string interpolation).
if [ "$include_time" = "1" ]; then
    timestamp_regex1="(\\S+\\s*\\S+\\s*\\d{4} \\d{1,2}:\\d{2}:\\d{2} [ap]m )"
    timestamp_regex2="(\\d{1,2}\\/\\d{2}\\/\\d{2} \\d{1,2}:\\d{2}:\\d{2})"
    ## OLD:
    ## perl -pe "s/$timestamp_regex1//ig; s/$timestamp_regex2//ig;" "$file1" > "$TMP/$base1"
    ## perl -pe "s/$timestamp_regex1//ig; s/$timestamp_regex2//ig;" "$file2" > "$TMP/$base2"
    perl -i.bak0 -pe "s/$timestamp_regex1//ig; s/$timestamp_regex2//ig;" "$TMP/$base1" "$TMP/$base2"
fi

# Strip out user-specified patterns
# Note: include hex address stripping
if [ "$ignore" != "" ]; then
    ## OLD: perl -i.bak -pe "s@($ignore)@@gi;" "$TMP/$base1" "$TMP/$base2"
    perl -i.bak1 -pe "s@($ignore)@@gi;" "$TMP/$base1" "$TMP/$base2"
fi

# Do comparison of the result
"$diff" "$TMP/$base1" "$TMP/$base2"
