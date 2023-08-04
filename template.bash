#! /usr/bin/env bash
#
# TODO: name.sh: explanation
#
# NOTES:
# - templates for common bash expressions:
#     if [ $x = value ]; then STMT; fi
#     if [ EXPR_a ]; then STMT_a; elif [ EXPR_a  ]; then STMT_b; else STMT_c; fi
#     if [[ (EXPR1) && (EXPR2) ]]; then STMT; fi
#     if [[ $var =~ pattern ]]; then STMT; fi       note: requires Bash 3.0+
#        where pattern is unquoted egrep regex (n.b., use .*.ext not *.ext)
#     if (( ARITH_EXPR )); then STMT; fi
#     if [ -s "file" ]; then ...; fi
#     case EXPR in PATTERN_a) STMT_a;; PATTERN_b) STMT_b;; ... esac
#     for name [in words ...]; do commands; done
#     for (( expr1 ; expr2 ; expr3 )) ; do commands ; done
#     while [ expr ] ; do commands ; done
#     $((arithmetic))              evaluate arithmetic expression
#     $(command ...)               same as `command ...`
#     ${var:-default}              use $var or "default"
#     ${var//from/to}              var with FROM pattern changed to TO
#     true                         no-op
#     $#                           number of positional arguments
#     $*                           all positional arguments
#     "$@"                         likewise all args but with individually quoting
# - tools like OpenAI Codex and GitHub Copliot can be used to translate Bash constructs
#     https://github.com/features/copilot
# - For sake of simplicity, not all of the syntax is covered. (Likewise below.)
# - Running bash in a fresh environment (i.e., pristine settings):
#      env --ignore-environment bash --noprofile --norc
#   See https://unix.stackexchange.com/questions/48994/how-to-run-a-program-in-a-clean-environment-in-bash.
# TODO:
#  - variable increments (e.g., 'let i++' and 'let max_mem=(4 * 1024')
#     note: EXPR is C style;
#         Format                    Example
#         let EXPR                  let i++
#         let VAR=(EXPR)            let max_mem=(4 * 1024)
#   - array variable
#         list=(v1 value2 ... vN)   initialize
#         ${#list[@]}               number of elements (i.e., length)
#         ${list[1]}                second element
#         ${list[*]}                all elements
#         "${list[@]}"              likewise all but individually quoted (a la "$@")
#         list+=(value)             append value
#   - conditional expression (a la C ternary operator (test ? true-result : false-result)
#     note: approximation via https://stackoverflow.com/questions/3953645/ternary-operator-in-bash
#         $([ test ] && echo "true-result" || echo "false-result")
#   - echo to stderr (or print)     echo "..." 1>&2
#   - expression evaluation
#         (( EXPR ))                (( L++ ))
#     Preferred for arithmetic: see https://wiki.bash-hackers.org/commands/builtin/let.
#   - early return
#      return                       just inside functions
#      exit                         early script termination; avoid in functions or if script sourced
#   - history mechanism
#     !?string[?]                   find last command with string
#  - local variable declaration     note: space-separated not comma; simplified
#      local var1[=val1] [var2[=val2] ...]
#  - common file tests
#      -s file                      non-empty file (n.b., nothing like csh's -z)
#      -e file                      file exists
#      -f file                      regular file
#      -d file                      file is directory
# Examples:
# - for (( i=0; i<10; i++ )); do  echo $i; done
# - if [ "$XYZ" = "" ]; then export XYZ=fubar; fi
# - if [[ $JAVA_HOME =~ x64 ]]; then echo "64-bit Java"; fi
#   note: need to use .* not * for filename patterns (e.g., $fname =~ ^.*xcf$)
# - case "$HOST_NICKNAME" in ec2*) echo "AWS";; hostw*) echo "HW";; *) echo "non-server"; esac
#   NOTE: each case must end in ';;'
# - if [[ $1 =~ .*/ ]]; then echo "$1" ends in slash; fi
# - if [[ ! $file =~ http ]]; then echo hey; fi
#
# TODO:
# - *** Update me (e.g., from recent scripts)! ***
# - change existing scripts to use '#! /usr/bin/env bash'
# - Check the TODO comments for customizations needed for the script."
# - Put the template for common bash expressions elsewhere.
# - Add examples for each of the templates above.
# - Change 'shift 1' to 'shift' in ~/bin bash scripts.
# - Mention some useful variables:
#   (e.g., ${!#} for last argument--see https://stackoverflow.com/questions/1853946/getting-the-last-argument-passed-to-a-shell-script).
# - Document regex match quirks.
# - Document file tests (e.g., -e fubar.txt).
# - BASH_SOURCE usage for when source'd
#     src_dir=$(dirname "${BASH_SOURCE[0]}")
#

# Uncomment following line(s) for tracing:
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#  
## echo "$@"
## set -o xtrace
## DEBUG: set -o verbose
#
# Set bash regular and/or verbose tracing
if [ "${TRACE:-0}" = "1" ]; then
    set -o xtrace
fi
if [ "${VERBOSE:-0}" = "1" ]; then
    set -o verbose
fi

# Show usage statement
# TODO: convert into a function that get invoked when $1 is empty or --help
# in $@.
# NOTE: See sync-loop.sh for an example.
#
if [ "$1" = "" ]; then
    script=$(basename "$0")
    ## TODO: remove following which is only meant for when ./template.bash run
    if [ "$script" = "template.bash" ]; then echo "Warning: not intended for standalone usage"; fi;
    ## TODO: if [ $script ~= *\ * ]; then script='"'$script'"; fi
    ## TODO: base=$(basename "$0" .bash)
    echo ""
    ## TODO: add option or remove TODO placeholder
    echo "Usage: $0 [--TODO] [--trace] [--help] [--]"
    echo ""
    echo "Examples:"
    echo ""
    ## TODO: example 1
    echo "$0 example 1"
    echo ""
    ## TODO: example 2
    echo "$script example 2"
    echo ""
    echo "Notes:"
    echo "- The -- option is to use default options and to avoid usage statement."
    ## TODO: add more notes
    ## echo ""
    echo ""
    exit
fi

# Parse command-line options
# TODO: set getopt-type utility
#
moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
while [ "$moreoptions" = "1" ]; do
    # TODO : add real options
    if [ "$1" = "--trace" ]; then
	set -o xtrace
    elif [ "$1" = "--TODO-fubar" ]; then
	## TODO: implement
	echo "TODO-fubar"
    elif [[ ("$1" = "--") || ("$1" = "-") ]]; then
	break
    else
	echo "ERROR: Unknown option: $1";
	exit
    fi
    shift;
    moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
done

# TODO: Do whatever
