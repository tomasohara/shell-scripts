#! /bin/csh -f
#
# diff.sh: wrapper around diff that accounts for whitespace,
# especially pesky carriage return (CR) differences.
#
# Notes:
# - Intended for use with diff3 for merging files
#   ex: alias diff3-merge='/usr/bin/diff3 --merge --text --diff-program=diff.sh'
# - Also see fdo_diff.sh for more complicated version (e.g., allowing for file patterns).
# - Diff options:
#   -b  --ignore-space-change: Ignore changes in the amount of white space.
#   -w  --ignore-all-space: Ignore all white space.
#   -B  --ignore-blank-lines: Ignore changes whose lines are all blank.
#   -a  --text: Treat all files as text.
#

# Uncomment (or comment) the following for enabling (or disabling) tracing
## set echo=1


# Parse command-line arguments, checking for diff options
# NOTE: options with embedded spaces not supported (eg, '--label LABEL')
set diff_options=""
set whitespace_options="-wbB"
while ("$1" =~ -*)
    set diff_options = "$diff_options $1"
    shift
end
if ("$2" == "") then
    set script_name = `basename $0`
    echo ""
    echo "usage: `basename $0` [options] file1 file2"
    echo ""
    echo "ex: `basename $0` tpo-julien-alexa-Job-Search-Contact-Info.txt alexa-top-job-search-sites.txt"
    echo ""
    echo "notse: "
    echo "- CR's converted to newlines, and multiple newlines are collapsed"
    echo "- uses $whitespace_options diff opiton to ignore white space."
    echo ""
    exit
endif

# Determine the files to compare (allowing just directory to be given for 2nd)
#
set file1="$1"
set file2="$2"
if (-d "$file2") then
    set base1 = `basename "$file1"`
    set file2 = "$file2/$base1"
endif
if (! -e "$file2") then
    echo "$file2" does not exist
    exit
endif
#
set temp1=/tmp/my-diff-1.$$
set temp2=/tmp/my-diff-2.$$

# Convert files with <CR>'s changed into <NL>'s.
# Also, collapse multiple <NL> sequences into one <NL>/
#
perl -0777 -pe 's/\r/\n/g;' "$file1" | perl -0777 -pe 's/\n\n+/\n/;' > "$temp1"
perl -0777 -pe 's/\r/\n/g;' "$file2" | perl -0777 -pe 's/\n\n+/\n/;' > "$temp2"
if (! -e "$temp1") echo "WARNING: unable to create intermediate file $temp1"
if (-z "$temp1") echo "WARNING: empty intermediate file $temp1"
if (! -e "$temp2") echo "WARNING: unable to create intermediate file $temp2"
if (-z "$temp2") echo "WARNING: empty intermediate file $temp2"

# Compare the files ignoring white spaces and blank lines
diff -q $whitespace_options $diff_options "$temp1" "$temp2" > /dev/null
if ($? == 1) echo "Differences:   $file1    $file2"
diff $whitespace_options $diff_options "$temp1" "$temp2" |& perl -pe "s@$temp1@$file1@; s@$temp2@$file2@;"

# Cleanup
if ($?DEBUG_LEVEL == 0) set DEBUG_LEVEL=0
if ($DEBUG_LEVEL < 4) rm "$temp1" "$temp2"
