## bash-cheatsheet.bash: Quick reference for common Bash constructs

Notes:
- Intended as a compact, high-signal reminder of common idioms.
- Unfortunately, it became a little monster: see \*'s for important stuff.
- Favors modern Bash (3.2+; associative arrays and case modification require 4+).
- Run Bash in a pristine environment via:
    `env --ignore-environment bash --noprofile --norc`
- via POE Assistant and then Claude
- Update 26 Jun 2026: Incorporated tips from old template.bash.

## Variables

```bash
var="value"                     # assignment (no spaces around =)
readonly CONST="fixed"          # read-only variable
export VAR="value"              # export to child processes
declare -g GLOBAL="x"           # * global declaration from within a function

# Defaulting / guarding
echo "${var:-default}"          # use default if var unset or empty
echo "${var:=default}"          # assign default if var unset or empty
echo "${var:+alt}"              # use alt if var is set (and non-empty)
echo "${var:?error message}"    # error (and exit) if var unset or empty

# Indirect expansion
name="PATH"
echo "${!name}"                 # value of variable named PATH

# Length
echo "${#var}"
```

## Parameter Expansion (String Operations)

```bash
# Prefix/suffix removal
echo "${var#pattern}"           # shortest prefix removal
echo "${var##pattern}"          # longest prefix removal
echo "${var%pattern}"           # shortest suffix removal
echo "${var%%pattern}"          # longest suffix removal

# Substitution
echo "${var/from/to}"           # replace first match
echo "${var//from/to}"          # ** replace all matches
echo "${var/#from/to}"          # replace at start only
echo "${var/%from/to}"          # replace at end only

# Substring
echo "${var:2}"                 # substring from offset 2
echo "${var:2:5}"               # * "" at offset 2, length 5

# Case modification (Bash 4+)
echo "${var^}"                  # uppercase first (i.e., capitalize)
echo "${var^^}"                 # uppercase all
echo "${var,}"                  # lowercase first
echo "${var,,}"                 # lowercase all
value="${value@L}"              # lowercase (alternative form)
```

## Conditionals

```bash
if [ "$x" = "value" ]; then echo yes; fi
if [[ "$x" == value* ]]; then echo glob; fi
# TODO: add regex gotcha's (e.g., potential trailing space confusion)
if [[ "$x" =~ ^re[gG]ex$ ]]; then echo regex; fi

if [[ EXPR_a ]]; then
    STMT_a
elif [[ EXPR_b ]]; then
    STMT_b
else
    STMT_c
fi

if [[ (EXPR1) && (EXPR2) ]]; then STMT; fi
if (( n > 10 )); then echo big; fi
if [ "$n" -eq 3 ]; then echo tres; fi   # -eq -ne -lt -le -gt -ge

# File tests
[ -e file ]                     # exists
[ -f file ]                     # regular file
[ -d dir  ]                     # directory
[ -s file ]                     # non-empty
[ -r file ]                     # readable

# String tests
[ -n "$str" ]                   # non-empty string
[ -z "$str" ]                   # empty string

result=$([ "$test" ] && echo "true-val" || echo "false-val")

[ "${VERBOSE:-0}" == "1" ]
```

## Case

```bash
case "$var" in
    pattern1)  echo one ;;
    ec2*)      echo AWS ;;
    hostw*)    echo HW ;;
    *)         echo default ;;
esac
```

## Loops

```bash
for x in a b c; do echo "$x"; done

for (( i=0; i<5; i++ )); do
    echo "$i"
done

while [ "$condition" ]; do commands; done

while read -r line; do
    echo "$line"
done < file.txt

echo {0..9}
echo {a..z}
```

## Arrays

```bash
arr=(one two three)
echo "${arr[0]}"                # first element
echo "${arr[@]}"                # ** all elements (individually quoted)
echo "${arr[*]}"                # all elements (single word)
echo "${#arr[@]}"               # * number of elements
arr+=(four)                     # append

local dirs=("${@:-.}")          # default to current dir if no args

declare -A map                  # * associative array (Bash 4+)
map[key]="value"
echo "${map[key]}"
```

## Arithmetic

```bash
(( i++ ))
(( max_mem = 4 * 1024 ))
echo $(( 4 * 1024 ))

let i++
let delay+=5
```

## Functions

```bash
function myfunc {                # -or- myfunc () { ... }
    local arg1="$1"
    local var1 var2="init"
    echo "$arg1"
    return 0
}

echo "${FUNCNAME[0]}"           # * current function name
echo "${FUNCNAME[@]}"           # * call stack

src_dir=$(dirname "${BASH_SOURCE[0]}")
```

## Positional Parameters

```bash
echo "$#"                       # number of args
echo "$*"                       # all args as one word
echo "$@"                       # all args individually quoted
echo "${!#}"                    # last argument
echo "$?"                       # exit status of last command

shift
```

## Command Substitution

```bash
result=$(command args)          # preferred form
result=`command args`           # legacy form
```

## Redirection

```bash
cmd > file                      # stdout to file
cmd 2> file                     # stderr to file
cmd &> file                     # * stdout + stderr to file
cmd >> file                     # append stdout
cmd 2>&1                        # redirect stderr to stdout
```

## Here Documents / Here Strings

```bash
cat <<EOF                       # here doc
line1
line2
EOF

cat <<-EOF                      # indented here doc (n.b., requires tab)
	indented line
EOF

grep foo <<<"some text"        # ** here string
```

## Path Manipulation

```bash
PATH="${PATH#/some/bin:}"       # remove prefix from PATH
PATH="$PATH:/new/bin"           # append to PATH
PATH="/new/bin:$PATH"           # prepend to PATH
```

## Special Commands
```
: [argument]                    # * null command (for side effect)
! [argument]                    # negative null command
![non-space]...                 # history subsitution
```

## Debugging

```bash
set -o xtrace                   # show expansions (set -x)
set -o verbose                  # show raw input lines (set -v)
set -e                          # exit on error (use cautiously)
set -u                          # error on unset variables
set -o pipefail                 # fail on pipe errors

if [ "${DEBUG_LEVEL:-0}" -ge 4 ]; then echo "$0 $*"; fi
if [[ "${TRACE:-0}" == "1" ]]; then set -o xtrace; fi
if [[ "${VERBOSE:-0}" == "1" ]]; then set -o verbose; fi

shopt -s expand_aliases

env --ignore-environment bash --noprofile --norc
```

## \* Pro Tips

note: via Claude Opus 4.8

```
# Pro Tips (optional patterns to consider adding):
# - Cleanup on exit via trap:
#     tmp=$(mktemp); trap 'rm -f "$tmp"' EXIT
# - Guard required external commands:
#     command -v curl >/dev/null || { echo "Error: curl not found" >&2; exit 1; }
# - Use ${BASH_SOURCE[0]} instead of $0 when the script might be sourced:
#     script_dir=$(dirname "${BASH_SOURCE[0]}")
# - Use readonly for constants:
#     readonly MAX_RETRIES=3
# - Use printf for portable formatted output (echo -e is not portable):
#     printf "%-20s %s\n" "$key" "$value"

```

## \*\* Commonly Used Commands, etc.

note: Stuff from old template.bash
	
```
#     template                     comment
#     
#     if [ $x == value ]; then STMT; fi    old-style is [ $x = value ] ...
#     if [ EXPR_a ]; then STMT_a; elif [ EXPR_a  ]; then STMT_b; else STMT_c; fi
#     if [[ (EXPR1) && (EXPR2) ]]; then STMT; fi
#     if [[ $var =~ pattern ]]; then STMT; fi       note: requires Bash 3.0+
#        where pattern is unquoted egrep regex (n.b., use .*.ext not *.ext)
#     if (( ARITH_EXPR )); then STMT; fi
#     if [ -s "file" ]; then ...; fi    where -s is non-empty test (see below)
#     case EXPR in PATTERN_a) STMT_a;; PATTERN_b) STMT_b;; ... esac
#         where ';;' is analogous to break in C (to avoid fallthrough)
#     for name [in words ...]; do commands; done
#     for (( expr1 ; expr2 ; expr3 )) ; do commands ; done
#     while [ expr ] ; do commands ; done
#     $((arithmetic))              evaluate arithmetic expression
#     $(command ...)               same as `command ...`
#     ${var:-default}              use $var or "default"
#     ${var:=default}              likewise and also assigns default if unset
#     ${var/from/to}               var with FROM pattern changed to TO (once)
#     ${var//from/to}              likewise for all occurrences
#     true                         no-op (similar to :)
#     false                        negative no-op (similar to !)
#     :                            null command (special builtin)
#     !                            negative null command (special builtin)
#     $#                           number of positional arguments
#     $*                           all positional arguments
#     "$@"                         likewise all args but with individually quoting
#     $?                           status of last command: 0 for success
```

## \* Useful Bash snippets

```
#  - variable increments (e.g., 'let i++' and 'let max_mem=(4 * 1024')
#     note: EXPR is C style;
#         Format                    Example(s)
#         let EXPR                  let i++
#         let VAR=(EXPR)            let max_mem=(4 * 1024);    let delay+=5
#   - comparison operators:
#         -[eg|ne|lt|le|gt|ge]      if [ $num -eq 3 ]; then echo "tres"; fi
#   - array variables
#         arr=(v1 value2 ... vN)    initialize
#         ${#arr[@]}                number of elements (i.e., length)
#         ${arr[1]}                 second element
#         ${arr[*]}                 all elements
#         "${arr[@]}"               likewise all but individually quoted (a la "$@")
#         arr+=(value)              append value
#         "${arr:-default}"         default value; local dirs=("${@:-.}")
#   - conditional expression (a la C ternary operator (test ? true-result : false-result)
#     note: approximation via https://stackoverflow.com/questions/3953645/ternary-operator-in-bash
#         $([ test ] && echo "true-result" || echo "false-result")
#   - echo to stderr (or print)     echo "..." 1>&2
#   - expression evaluation
#         (( EXPR ))                (( L++ ))
#     Preferred for arithmetic: see https://wiki.bash-hackers.org/commands/builtin/let.
#   - early return
#      return                       just inside functions
#      -or- exit                    early script termination; *** avoid in functions or if script sourced ***
#   - history mechanism
#     !?string[?]                   find last command with string
#  - local variable declaration     note: space-separated not comma; simplified
#      local var1[=val1] [var2[=val2] ...]
#  - global variable declaration
#      declare -g variable
#  - common file tests
#      -s file                      non-empty file (n.b., nothing like csh's -z)
#      -e file                      file exists
#      -f file                      regular file
#      -d file                      file is directory
#  - other common tests
#      -n string                    whether string is non-empty
#      -z string                    whether string is empty
#  - here-documents
#      <<END\n line1\n...\nEND      multiple line using line1, ... as stdin
#  - here-strings
#      <<<"text"                    single line using TEXT as stdin
#  - indented here-documents        END can be indented; unfortunately requires tab indentation--hence brittle
#  - sequence expression
#      {n..m}                       echo "digits:" {0..9}; echo "letters: " {a..z}
#  - advanced redirection
#      &>                           same as `> ... 2>&1`
#  - common or useful bash arguments
#     -i -c                         run command as if interactive invocation
#     shopt -s expand_aliases       for alias support in scripts
#     TODO3: flesh out
#  - simple boolean env. testing    note: used throughout repo for convenience
#     [ "${ENV_VAR:-0}" == "1" ]    [ "${VERBOSE:-0}" == "1" ]
#  - general boolean env. testing   uses new function in tomohara-aliases.bash
#     local var=$(is-true "VAR");   local verbose=$(is-true "VERBOSE");
#  - deleting aliases and functions
#     unalias my-alias
#     unset -f my-function
```

## Miscellaneous Examples

```
# - for (( i=0; i<10; i++ )); do  echo $i; done
# - if [ "$XYZ" = "" ]; then export XYZ=fubar; fi
# - if [[ $JAVA_HOME =~ x64 ]]; then echo "64-bit Java"; fi
#   note: need to use .* not * for filename patterns (e.g., $fname =~ ^.*xcf$)
# - case "$HOST_NICKNAME" in ec2*) echo "AWS";; hostw*) echo "HW";; *) echo "non-server"; esac
#   NOTE: each case must end in ';;' (or ';&' or ';;&').
# - if [[ $1 =~ .*/ ]]; then echo "$1" ends in slash; fi
# - if [[ ! $file =~ http ]]; then echo hey; fi
```

## TODO

```
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
# - BASH_SOURCE usage for when source'd; in general: invocation stack array
#     echo "in ${BASH_SOURCE[0]}"
# - alternative BASH_SOURCE usage:
#     src_dir=$(dirname "${BASH_SOURCE[0]}")
# - name of current function: "${FUNCNAME[0]}"; in general: call stack array
# - value=${value@L}                    # make lowercase
#
```
