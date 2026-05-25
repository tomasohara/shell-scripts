## bash-cheatsheet.bash: Quick reference for common Bash constructs

Notes:
- Intended as a compact, high-signal reminder of common idioms.
- Favors modern Bash (3.2+; associative arrays and case modification require 4+).
- Run Bash in a pristine environment via:
    `env --ignore-environment bash --noprofile --norc`
- via POE Assistant and then Claude


## VARIABLES

```bash
var="value"                     # assignment (no spaces around =)
readonly CONST="fixed"          # read-only variable
export VAR="value"              # export to child processes
declare -g GLOBAL="x"           # global declaration from within a function

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

## PARAMETER EXPANSION (STRING OPS)

```bash
# Prefix/suffix removal
echo "${var#pattern}"           # shortest prefix removal
echo "${var##pattern}"          # longest prefix removal
echo "${var%pattern}"           # shortest suffix removal
echo "${var%%pattern}"          # longest suffix removal

# Substitution
echo "${var/from/to}"           # replace first match
echo "${var//from/to}"          # replace all matches
echo "${var/#from/to}"          # replace at start only
echo "${var/%from/to}"          # replace at end only

# Substring
echo "${var:2}"                 # from offset 2
echo "${var:2:5}"               # offset 2, length 5

# Case modification (Bash 4+)
echo "${var^}"                  # capitalize first
echo "${var^^}"                 # uppercase all
echo "${var,}"                  # lowercase first
echo "${var,,}"                 # lowercase all
value="${value@L}"              # lowercase (alternative form)
```

## CONDITIONALS

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

## CASE

```bash
case "$var" in
    pattern1)  echo one ;;
    ec2*)      echo AWS ;;
    hostw*)    echo HW ;;
    *)         echo default ;;
esac
```

## LOOPS

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

## ARRAYS

```bash
arr=(one two three)
echo "${arr[0]}"                # first element
echo "${arr[@]}"                # all elements (individually quoted)
echo "${arr[*]}"                # all elements (single word)
echo "${#arr[@]}"               # number of elements
arr+=(four)                     # append

local dirs=("${@:-.}")          # default to current dir if no args

declare -A map                  # associative array (Bash 4+)
map[key]="value"
echo "${map[key]}"
```

## ARITHMETIC

```bash
(( i++ ))
(( max_mem = 4 * 1024 ))
echo $(( 4 * 1024 ))

let i++
let delay+=5
```

## FUNCTIONS

```bash
myfunc() {
    local arg1="$1"
    local var1 var2="init"
    echo "$arg1"
    return 0
}

echo "${FUNCNAME[0]}"           # current function name
echo "${FUNCNAME[@]}"           # call stack

src_dir=$(dirname "${BASH_SOURCE[0]}")
```

## POSITIONAL PARAMETERS

```bash
echo "$#"                       # number of args
echo "$*"                       # all args as one word
echo "$@"                       # all args individually quoted
echo "${!#}"                    # last argument
echo "$?"                       # exit status of last command

shift
```

## COMMAND SUBSTITUTION

```bash
result=$(command args)          # preferred form
result=`command args`           # legacy form
```

## REDIRECTION

```bash
cmd > file                      # stdout to file
cmd 2> file                     # stderr to file
cmd &> file                     # stdout + stderr to file
cmd >> file                     # append stdout
cmd 2>&1                        # redirect stderr to stdout
```

## HERE DOCUMENTS / HERE STRINGS

```bash
cat <<EOF
line1
line2
EOF

grep foo <<<"some text string"

cat <<-EOF
	indented line
EOF
```

## PATH MANIPULATION

```bash
PATH="${PATH#/some/bin:}"       # remove prefix from PATH
PATH="$PATH:/new/bin"           # append to PATH
PATH="/new/bin:$PATH"           # prepend to PATH
```

## SPECIAL COMMANDS
```
: [argument]                    # null command (for side effect)
! [argument]                    # negative null command
![non-space]...                 # history subsitution
```

## DEBUGGING

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
