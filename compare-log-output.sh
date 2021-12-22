#! /bin/sh
#
# compare-tmr-output.sh: compare trace output listings ignoring differences
# due to timestamps
#
# TODO:
# - Rename to indicate underlying diff operation (e.g., diff-log-output.sh).
# - Extend so that multiple ignore patterns are allowed.
# - Allow for case-sensitive regex's.
#

# Uncomment the line(s) below for tracing (verbose shows command before and after, xtrace just shows it after):
#  
# set -o verbose
# set -o xtrace

# Parse command-line arguments
diff=kdiff.sh
## OLD: ignore='(0x)?[0-9A-Fa-f]{7,8}'
ignore='(0x)?[0-9A-Fa-f]{7,16}'
moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
while [ "$moreoptions" = "1" ]; do
    if [ "$1" = "--trace" ]; then
	set -o xtrace
    elif [ "$1" = "--diff" ]; then
	diff="$2";
	shift
    elif [ "$1" = "--plain-diff" ]; then
	diff="diff";
    elif [ "$1" = "--include-ptrs" ]; then
        ignore="";
    elif [ "$1" = "--ignore" ]; then
	ignore="$2";
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
    echo "    options: [--ignore perl-regex] [--include-ptrs] [--plain-diff] [--diff program]"
    echo ""
    echo "Examples:"
    echo ""
    echo "$script_name --ignore '^\d+:\d+:\d+,\d+' jboss-init-1.log  jboss-init-2.log"
    echo ""
    echo "$script_name --ignore '^\s*<job_id>.*' city_easternshore_md.xml ../craigslist_20160609_usa100/"
    echo ""
    echo "Notes:"
    echo "- The regex pattern matching is not case sensitive (i.g., case ignored)."
    echo "- Timestamps are removed prior to comparison."
    echo "- Hex addresses are removed as with '--ignore [0-9A-Fa-f]{7,16}'."
    echo "- Additional filtering can be done via --ignore, but only one can be given (implies --include-ptrs)."
    echo "- kdiff is default diff program (see kdiff.sh)."
    echo "- The pattern for ignore is a perl regex."
    echo "- Only one pattern is allowed, including the hex address filter."
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

# Strip out timestamps (e.g., "Jun 14, 2006 3:18:43 AM" and "[06/19/06 16:16:04]")
# TODO: 
# - Support logging-style timestamps.
# - Try following:
#      pattern="((\\S+\\s*\\S+\\s*\\d{4} \\d{1,2}:\\d{2}:\\d{2} [ap]m )|(\\d{1,2}\\/\\d{2}\\/\\d{2} \\d{1,2}:\\d{2}:\\d{2}))"
#      perl -pe "'" "s/$pattern//i;" "'" $file1 > /tmp/$base1 ...
# - Decompose timestamp regex to make more efficient.
# - Make this timestamp removal optional.
# NOTE: Backslashes used above to avoid shell interpretation (during string interpolation).
## OLD:
## perl -pe 's/((\S+\s*\S+\s*\d{4} \d{1,2}:\d{2}:\d{2} [ap]m )|(\d{1,2}\/\d{2}\/\d{2} \d{1,2}:\d{2}:\d{2}))//ig;'  "$file1" > "/tmp/$base1"
## perl -pe 's/((\S+\s*\S+\s*\d{4} \d{1,2}:\d{2}:\d{2} [ap]m )|(\d{1,2}\/\d{2}\/\d{2} \d{1,2}:\d{2}:\d{2}))//ig;'  "$file2" > "/tmp/$base2"
timestamp_regex1="(\\S+\\s*\\S+\\s*\\d{4} \\d{1,2}:\\d{2}:\\d{2} [ap]m )"
timestamp_regex2="(\\d{1,2}\\/\\d{2}\\/\\d{2} \\d{1,2}:\\d{2}:\\d{2})"
perl -pe "s/$timestamp_regex1//ig; s/$timestamp_regex2//ig;" "$file1" > "/tmp/$base1"
perl -pe "s/$timestamp_regex1//ig; s/$timestamp_regex2//ig;" "$file2" > "/tmp/$base2"

# Strip out user-specified patterns
# Note: include hex address stripping
if [ "$ignore" != "" ]; then
    perl -i.bak -pe "s/$ignore//gi;" "/tmp/$base1" "/tmp/$base2"
fi

# Do comparison of the result
"$diff" "/tmp/$base1" "/tmp/$base2"
