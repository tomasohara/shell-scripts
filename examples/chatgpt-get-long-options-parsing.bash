#!/bin/bash
#
# Conversion of simple-get-long-options-parsing.bash using ChatGPT along with manual
# changes for debugging.
#
# Note:
# - For background on using the getopt utility, see the following article:
#   https://stackoverflow.com/questions/402377/using-getopts-to-process-long-and-short-command-line-options
# - The Bash getopts doesn't support long options directly. It can be used
#   to implement using a two-step process, as shown in the above article.
#   However, the getopt approach is clearer and more flexible.
#
#-------------------------------------------------------------------------------
# Explanation by ChatGPT
#
# The eval set -- "$TEMP" line might look a bit cryptic at first, but it plays a crucial role in the way the arguments are re-ordered and set up for subsequent parsing. Here's a breakdown:
# 
# 1. getopt: This tool parses the command-line arguments and outputs a reordered version of those arguments that can be processed more easily. This is particularly valuable for handling long options and making sure the arguments are presented in a format that getopts (or another loop structure) can handle. The output of getopt is stored in the TEMP variable.
# 
# 2. set --: This is a command in the shell that sets the positional parameters ($1, $2, etc.). When you use set -- followed by some arguments, you're essentially replacing the current script's or function's positional parameters with the new set of arguments. In other words, you're overwriting $1, $2, etc., with new values.
# 
# 2. eval: This is a shell built-in command that evaluates its arguments as shell commands. It's often used in scripts to execute commands stored in a string or variable.
# 
# So, what does eval set -- "$TEMP" do?
# 
# The purpose of this line is to evaluate the string stored in TEMP (the reordered command-line arguments produced by getopt) as a set of shell commands. The set -- part then sets the positional parameters to these reordered arguments. As a result, after this line, $1, $2, etc., will correspond to the reordered command-line arguments, making subsequent processing straightforward.
# 
# Here's a step-by-step breakdown:
# 
# 1. Let's assume you call your script like this: ./myscript.sh -f --verbose file1 file2
#
# 2. After getopt, the TEMP variable might contain something like: -f --verbose -- 'file1' 'file2'
#
# 3. eval set -- "$TEMP" sets the positional parameters such that:
#   $1 is -f
#   $2 is --verbose
#   $3 is -- (a special indicator meaning the end of options and the beginning of regular arguments)
#   $4 is file1
#   $5 is file2
#
# 4. The rest of the script can then process these parameters easily in a loop structure.
# This whole process facilitates the combination of both long and short options and allows for straightforward argument handling afterward.
#--------------------------------------------------------------------------------
# TODO:
# - See if some utility handles automatic usage statement generation (as with argparse in Python).
#

# Display command-line usage
function usage(){
    local script
    script=$(basename "$0")
    echo ""
    echo "Usage: $script [options] filename1 filename2"
    echo "    options: [--fubar | -f] [--help | -h] [--trace | -t] [--verbose | -v]"
    echo ""
    echo "Example:"
    echo "    $script --fubar"
    echo ""
    echo "Note:"
    echo "- Use DEBUG_SCRIPT=1 to show getopt processing."
    echo ""
}

# Initialize options
fubar=0
show_usage=0
trace=0
verbose=0
level=0
DEBUG_SCRIPT=$([ "${DEBUG_SCRIPT:-0}" -eq 1 ] && echo true || echo false)

# Parse options with getopt
# Note: Unravels combined short options (e.g., "-xf" -> "-x -f")
# Also: long options taking values have a colon appended.
TEMP=$(getopt -o fhltv --long fubar,help,level:,trace,verbose -n "$0" -- "$@")
if [ $? != 0 ]; then
    echo "Terminating..." >&2
    exit 1
fi
$DEBUG_SCRIPT && echo "TEMP=$TEMP"
#
# Assign each distinct command-line argument to $1, $2, etc.
# Note the quotes around "$TEMP": they are essential!
# See the explanation in the header comments above.
eval set -- "$TEMP"

# Check command-line options, based on getopt conversion to $1, $2, etc.
while true ; do
    $DEBUG_SCRIPT && echo "\$1=$1"
 
    case "$1" in
        -f|--fubar)
            fubar=1
            shift
            ;;
        -h|--help)
            show_usage=1
            shift
            ;;
        -l|--level)
            level="$2"
            shift 2
            ;;
        -t|--trace)
            trace=1
            shift
            ;;
        -v|--verbose)
            verbose=1
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Internal error!"
            exit 1
            ;;
    esac
done

# Apply trace and verbose
if [ "$trace" == "1" ]; then
    set -o xtrace
fi

if [ "$verbose" == "1" ]; then
    set -o verbose
fi

# Show usage
if [ "$show_usage" == "1" ]; then
   usage
   exit
fi

# Show result
echo "fubar=$fubar"
echo "level=$level"
set -o | egrep '^(xtrace|verbose)\b'
