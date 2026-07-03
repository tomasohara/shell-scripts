## bash-cheatsheet.bash: Quick reference for common Bash constructs

Notes:
- Intended as a compact, high-signal reminder of common idioms.
- Update 27 Jun 2026: simplified the descriptions (e.g., clarify template references).
- The \*'d constructs flag important common constructs used in this repo and
  assumed by the prototypical script in template.bash (e.g., defaulting, env-flag tests, 
  functions, case-based option parsing, etc.). 
- Review these \*'d cases when creating new script or porting an existing script to the repo.

Misc. Notes:
- Favors modern Bash (3.2+; associative arrays and case modification require 4+).
- Run Bash in a pristine environment via:
    `env --ignore-environment bash --noprofile --norc`
- Sanity-check scripts with `bash -n` (syntax) and `shellcheck` (lint); see the
  "Checking / Validating Scripts" section below.
- via POE Assistant and then Claude
- Update 26 Jun 2026: Incorporated tips from old template.bash.
- Update 27 Jun 2026: Starred constructs used by template.bash; added option
  parsing (getopt) and script-checking sections.
- References below to 'template' are for template.bash.

TODO:
- Rework the prioritization to distinguish (a) use in highlighting important constructs
  with respect to the repo usage versus (b) pointing out some of the subtleties of Bash.

## Variables

```bash
var="value"                     # assignment (no spaces around =)
readonly CONST="fixed"          # read-only variable
export VAR="value"              # export to child processes
declare -g GLOBAL="x"           # * global declaration from within a function

# Defaulting / guarding
echo "${var:-default}"          # ** use default if var unset or empty (template: ${DEBUG_LEVEL:-0})
echo "${var:=default}"          # assign default if var unset or empty
echo "${var:+alt}"              # use alt if var is set (and non-empty)
echo "${var:?error message}"    # error (and exit) if var unset or empty

# Indirect expansion
name="PATH"                     # name of variable to dereference
echo "${!name}"                 # value of variable named PATH

# Length
echo "${#var}"                  # number of characters in value
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
if [ "$n" -eq 3 ]; then echo tres; fi   # * -eq -ne -lt -le -gt -ge

# File tests
[ -e file ]                     # exists
[ -f file ]                     # regular file
[ -d dir  ]                     # directory
[ -s file ]                     # non-empty
[ -r file ]                     # readable

# String tests
[ -n "$str" ]                   # non-empty string
[ -z "$str" ]                   # empty string

result=$([ "$test" ] && echo "true-val" || echo "false-val")   # * ternary idiom (template: DEBUG_SCRIPT=...)

[ "${VERBOSE:-0}" == "1" ]      # ** boolean env-flag test (used throughout repo & template)
```

## \* Case Statement (Pattern-matching Multi-way Branch)

```bash
# * Core of the template's option-parsing loop (see getopt section below).
case "$var" in
    pattern1)  echo one ;;
    ec2*)      echo AWS ;;
    hostw*)    echo HW ;;
    *)         echo default ;;        # default/catch-all clause
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
echo "${#arr[@]}"               # * number of elements (length)
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

## \* Functions

```bash
function myfunc {               # -or- myfunc () { ... }); * function definition
	: "docstring workaround"
    local arg1="$1"             # * local: keep helper vars out of global scope
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
echo "$#"                       # * number of args (template: orig_argc=$#)
echo "$*"                       # all args as one word
echo "$@"                       # ** all args individually quoted
echo "${!#}"                    # last argument
echo "$?"                       # * exit status of last command (template: getopt check)

shift                           # * drop $1 (template option loop); 'shift 2' drops $1 and $2
```

## \*\* Command-Line Option Parsing (getopt)

The template's primary structure: getopt normalizes short/long options, then a
case loop consumes them. (Bash's builtin `getopts` handles short options only;
the external `getopt` adds long options.) See examples/chatgpt-get-long-options-parsing.bash.

```bash
# -o = short opts; --long = long opts; trailing ':' means "takes a value"
TEMP=$(getopt -o htvl: --long help,trace,verbose,level: -n "$0" -- "$@")
if [ $? != 0 ]; then echo "Error: bad options" >&2; exit 1; fi
eval set -- "$TEMP"             # ** reassign $1,$2,... to normalized args (quotes essential)

while true; do
    case "$1" in
        -h|--help)    show_usage=1; shift ;;
        -t|--trace)   trace=1; shift ;;
        -l|--level)   level="$2"; shift 2 ;;    # * value option consumes $1 and $2
        --)           shift; break ;;           # ** end of options; rest are positional
        *)            echo "Internal error: $1" >&2; exit 1 ;;
    esac
done
# getopt unravels bundled short opts (-tv -> -t -v) and reorders args before "--"
```

## Command Substitution

```bash
result=$(command args)          # ** preferred form (template: script=$(basename "$0"))
result=`command args`           # legacy form (avoid: no nesting, awkward quoting)
```

## Redirection

```bash
cmd > file                      # stdout to file
cmd 2> file                     # stderr to file
cmd &> file                     # * stdout + stderr to file
cmd >> file                     # append stdout
cmd 2>&1                        # redirect stderr to stdout
echo "Error: ..." >&2           # * write message to stderr (template: error/usage output)
```

## Here Documents / Here Strings

```bash
cat <<EOF                       # here doc
line1
line2
EOF

cat <<-EOF                      # * indented here doc (n.b., requires tab)
    indented line               # should be "\tindented line" (i.e., space used in markdown)
EOF

grep foo <<<"some text"         # ** here string
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
<-- TODO2: flesh out history substitution and note relation to grepl-hist-tail -->

## Debugging

```bash
set -o xtrace                   # * show expansions (set -x)
set -o verbose                  # show raw input lines (set -v)
set -e                          # exit on error (use cautiously)
set -u                          # error on unset variables
set -o pipefail                 # fail on pipe errors
set -euo pipefail               # * strict mode, combined (n.b., in template gated by STRICT=1)

# ** Template header: env-flag-gated tracing (enable without editing the script)
if [ "${DEBUG_LEVEL:-0}" -ge 4 ]; then echo "$0 $*"; fi
if [[ "${TRACE:-0}" == "1" ]]; then set -o xtrace; fi
if [[ "${VERBOSE:-0}" == "1" ]]; then set -o verbose; fi

shopt -s expand_aliases

env --ignore-environment bash --noprofile --norc
```

## \* Checking / Validating Scripts

```bash
bash -n script.bash             # ** syntax check only (parse, don't run)
shellcheck script.bash          # ** static analysis / lint (catches quoting bugs, etc.)
shellcheck -s bash script.bash  # force bash dialect
bash -x script.bash args        # run with execution trace (debugging)
```

```bash
# * Check every real bash script in a directory.
#   n.b. filter by shebang: .sh here includes csh scripts that bash -n would
#   wrongly flag (this repo has 5 such #!/bin/csh files, e.g. kill_em.sh).
for f in *.bash *.sh; do
    head -1 "$f" | grep -q bash || continue   # skip non-bash (csh, etc.)
    bash -n "$f" || echo "SYNTAX ERROR: $f"
done
# Repo status (27 Jun 2026): all 29 bash scripts pass 'bash -n'.
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
#   note: each case must end in ';;' (or ';&' or ';;&').
# - if [[ $1 =~ .*/ ]]; then echo "$1" ends in slash; fi
# - if [[ ! $file =~ http ]]; then echo hey; fi
```

## TODO (e.g., Additions and Loose Ends)

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
