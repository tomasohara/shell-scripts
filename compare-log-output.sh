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
#
# Regex patterns:
# - 1. hexadecimal with prefix (e.g., "0x1234")
# - 2. "" of size 4 or 8 (e.g., "1234" or "F000100A")
# - 3. "" with leading & trailing digits (e.g., "[sha256:]99f14c4b8174ea549d7ff9050fe9d305f59153eddecfae52c56d0f0c7821e6d4")
## OLD: ignore='((0x)?[0-9A-Fa-f]{7,16})'
## TODO3: allow arbitrary hex strings not startingand ending with digits
ignore_hex1='(0x[0-9A-Fa-f]+)'
ignore_hex2='(\b([0-9A-Fa-f]{4})|([0-9A-Fa-f]{8})\b)'
ignore_hex3='(\b[0-9][0-9A-Fa-f]+[A-Fa-f][0-9A-Fa-f]+[0-9]\b)'
ignore_user=''
# - timestamps (e.g., "1 Jan 1970 12:01am" and "1/01/70 12:00:01")
timestamp_regex1="(\\S+\\s*\\S+\\s*\\d{4} \\d{1,2}:\\d{2}:\\d{2} *[ap]m )"
timestamp_regex2="(\\d{1,2}\\/\\d{2}\\/\\d{2} \\d{1,2}:\\d{2}:\\d{2})"
# - ISO (e.g., "2023-11-26T23:23:29.0096998Z")
timestamp_regex3="(\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\.\\d{6,}Z)"
#
filter_time=0
filter_hex=1
relaxed_filtering=0
retain_whitespace=0
show_usage=0
verbose_output=0
moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
while [ "$moreoptions" = "1" ]; do
    if [ "$1" = "--trace" ]; then
	set -o xtrace
	## DEBUG: set -o verbose
    elif [ "$1" = "--diff" ]; then
	diff="$2";
	shift
    elif [ "$1" = "--verbose" ]; then
	verbose_output=1
    elif [ "$1" = "--plain-diff" ]; then
	diff="diff";
    elif [ "$1" = "--include-ptrs" ]; then
        echo "Warning: deprecated option: $1"
        filter_hex=1;
    elif [ "$1" = "--filter-time" ]; then
        filter_time=1;
    elif [ "$1" = "--no-filter-time" ]; then
        filter_time=0;
    elif [ "$1" = "--include-time" ]; then
        echo "Warning: deprecated option: $1"
        filter_time=1;
    elif [ "$1" = "--include-hex" ]; then
        echo "Warning: deprecated option: $1"
        filter_hex=0;
    elif [ "$1" = "--filter-hex" ]; then
        filter_hex=1;
    elif [ "$1" = "--no-filter-hex" ]; then
        filter_hex=0;
    elif [ "$1" = "--relaxed" ]; then
        relaxed_filtering=1
    elif [ "$1" = "--reset-ignore" ]; then
        echo "Warning: deprecated option: $1"
        ignore_user="";
    elif [ "$1" = "--retain-whitespace" ]; then
        retain_whitespace=1;
    elif [ "$1" = "--ignore" ]; then
        if [ "$ignore_user" != "" ]; then
            ignore_user="$ignore_user|($2)";
        else
	    ignore_user="$2";
        fi
	shift
    else
	if [ "$1" != "--help" ]; then
	    echo "unknown option: $1";
	fi
	show_usage=1
    fi
    shift 1;
    moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
done
#

if [ "$1" = "" ]; then
    show_usage=1
fi
if [ "$show_usage" = "1" ]; then
    script_name=$(basename "$0")
    echo ""
    echo "Usage: $script_name [options] file1 file2-or-dir"
    echo ""
    echo "    options: [--ignore perl-regex] [--include-ptrs | --include-time | --[no-]filter-hex] [--plain-diff] [--diff program]"
    echo "    misc-options: [--relaxed] [--[no]-filter-time] [--include-hex] [--reset-ignore] [--trace] [--verbose]"
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
    echo "- Use --reset-ignore to ignore the default patterns (deprecated)."
    echo "- The --include-ptrs option is alias for --include-hex."
    echo "- kdiff is default diff program (see kdiff.sh)."
    echo "- The --include-xyz options are deprecated: include refers to filtering not output."
    echo "- The --relaxed option include regex's that tend to overgenerate."
    if [ "$verbose_output" = "1" ]; then
        echo "- Timestamp regex's (doubly escaped for interpolation):"
        echo "  $timestamp_regex1"
        echo "  $timestamp_regex2"
        echo "  $timestamp_regex3"
        echo "- Hexadecimal regex (not escaped):"
        echo "  $ignore_hex1"
        echo "- Relaxed hexadecimal regex's (not escaped):"
        echo "  $ignore_hex2"
        echo "  $ignore_hex3"
    else
        echo "- Use --verbose for detailed help"
    fi
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
cp "$file1" "$TMP/$base1.orig"
cp "$file2" "$TMP/$base2"
cp "$file2" "$TMP/$base2.orig"

# Strip out timestamps (e.g., "Jun 14, 2006 3:18:43 AM" and "[06/19/06 16:16:04]")
# TODO: 
# - Support logging-style timestamps.
# - Try following:
#      pattern="((\\S+\\s*\\S+\\s*\\d{4} \\d{1,2}:\\d{2}:\\d{2} [ap]m )|(\\d{1,2}\\/\\d{2}\\/\\d{2} \\d{1,2}:\\d{2}:\\d{2}))"
#      perl -pe "'" "s/$pattern//i;" "'" $file1 > $TMP/$base1 ...
# - Decompose timestamp regex to make more efficient.
# - Make this timestamp removal optional.
# NOTE: Backslashes used above to avoid shell interpretation (during string interpolation).
if [ "$filter_time" = "1" ]; then
    ## OLD: perl -i.bak0 -pe "s/$timestamp_regex1//ig; s/$timestamp_regex2//ig;" "$TMP/$base1" "$TMP/$base2"
    perl -i.bak-ts1 -pe "s/$timestamp_regex1/<time>/ig;" "$TMP/$base1" "$TMP/$base2"
    perl -i.bak-ts2 -pe "s/$timestamp_regex2/<time>/ig;" "$TMP/$base1" "$TMP/$base2"
    perl -i.bak-ts3 -pe "s/$timestamp_regex3/<time>/ig;" "$TMP/$base1" "$TMP/$base2"
fi

# Strip out hexadecimal numbers
if [ "$filter_hex" = "1" ]; then
    perl -i.bak-hex1 -pe "s@($ignore_hex1)@<hex>@gi;" "$TMP/$base1" "$TMP/$base2"
    if [ "$relaxed_filtering" = "1" ]; then
        perl -i.bak-hex2 -pe "s@($ignore_hex2)@<hex>@gi;" "$TMP/$base1" "$TMP/$base2"
        perl -i.bak-hex3 -pe "s@($ignore_hex3)@<hex>@gi;" "$TMP/$base1" "$TMP/$base2"
    fi
fi

# Strip out user-specified patterns
## OLD: # Note: include hex address stripping
if [ "$ignore_user" != "" ]; then
    ## OLD: perl -i.bak1 -pe "s@($ignore)@@gi;" "$TMP/$base1" "$TMP/$base2"
    perl -i.bak-ign1 -pe "s@($ignore_user)@<user>@gi;" "$TMP/$base1" "$TMP/$base2"
fi

# Collapse whitespace
if [ "$retain_whitespace" = "0" ]; then
   ## OLD: perl -i.bak2 -pe "s/\s+/ /g; s/$/\n/;" "$TMP/$base1" "$TMP/$base2"
   perl -i.bak-ws1 -pe "s/\s+/ /g; s/$/\n/;" "$TMP/$base1" "$TMP/$base2"
fi

# Do comparison of the result
"$diff" "$TMP/$base1" "$TMP/$base2"
