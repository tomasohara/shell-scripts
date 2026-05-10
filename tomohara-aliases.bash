#! /usr/bin/env bash
# -*- coding: utf-8 -*-
#
# tomohara-aliases.bash: Tom's Initialization file for use with bash,
# using suppoting scripts from
#    http://www.cs.nmsu.edu/~tomohara/useful-scripts/tpo-useful-scripts.tar.gz
#
# This is in the process of being re-organized to make it easier to test and to
# isolate the isolate the stuff specific to my workflow (i.e., "idiosyncratic").
#
# NOTES:
# - *** This is a pruned down version of do_setup.bash. It should be renamed to tohara-setup.bash as it includes more than just just aliases!
# - ** Put overly large function definitions into scripts (e.g., prepare-find-files-here, hg-pull-and-update, show-unicode-code-info-aux, and init-condaN)!
#   These can be identified as follows:
#      $ grep -A20 ^function ~/bin/tomohara-aliases.bash | perl -pe 's/^function/\n$&/;' | egrep -v '^(#|alias)' | para-len | sort -rn | less
# - * add alias for resolving command binary with fallback to "command name" (e.g., resolve-command ls => /bin/ls or "command ls").
# - * Drop () from function definition, as optional!
#   For example,
#      Function definition syntax:
#         [ function ] name () { command-list; }
#      where () is optional if 'function' given
#   Therefore,
#      function fubar1 () { 666; };
#      function fubar2 { 666; };
#      set | grep -A3 ^fubar[12]
#   =>
#     fubar1 () 
#     { 
#         echo 666
#     }
#     fubar2 () 
#     { 
#         echo 666
#     }
#
# - Obsolete old code flagged with '## OLD': either older definition
#   or no longer used).
# - Misc. old code flagged with '## MISC' (e.g., old but potentially useful).
# - Exceptionally idiosyncratic aliases are flagged with '## TOM-IDIOSYNCRATIC'. (These
#   should be considered as experimental.)
# - See extra-tomohara-aliases.bash for aliases for adhoc aliases (e.g., not
#   used on a regular basis and/or special purpose).
# - This gets invoked from $HOME/.bashrc.local.
# - from bash manual:
#   Special Parameters
#   ...
#        @      Expands to the positional parameters, starting from
#               one.   When  the  expansion  occurs  within  double
#               quotes,  each parameter expands as a separate word.
#               That is, `` $@'' is equivalent to ``$1'' ``$2'' ...
#               When there are no positional parameters, ``$@'' and
#               $@ expand to nothing (i.e., they are removed).
# - $* is like $@ except that it accounts for inter-field separator (IFS)
# - CygWin takes very long to process this script so certain sections
#   are not evaluated if under arahomot; TODO: check for CygWin flag.
# - Variables in function definitions should be declared local to avoid subtle problems
#   due to retained values.
# - Alias definition syntax:
#      alias [-p] [name[=value] ...]
# - from bash man page:
#    When  bash  is  invoked  as an interactive login shell, it
#    first reads and executes commands from the file  /etc/pro-
#    file,  if  that  file exists.  After reading that file, it
#    looks for ~/.bash_profile, ~/.bash_login, and  ~/.profile,
#    in  that  order,  and reads and executes commands from the
#    first one that exists and is  readable. 
#    ...
#    When  an  interactive  shell  that is not a login shell is
#    started, bash reads and executes commands from  ~/.bashrc,
#    if  that  file exists.
#    ...
# - Commonly used Bash features which might not be familiar:
#    -- $(...) is used in place of `...` (as the backtick is escape for GNU screen terminal shell utility.
#    -- 'command cmd' invoke specifed Unix cmd, not aliases/functions.
#    -- 'builtin cmd' likewise invokes shell builtin cmd, not aliases/functions.
#    -- "$@" which argument list with each argument quoted.
#    -- 'ENV_VAR=value command ...' runs command with temp. environment setting.
# - Likewise commonly used Unix features which might not be familiar:
#    -- 'realpath file' returns full path for file with relative path.
# - Selectively ignores following shellcheck warnings:
#    -- SC2016: Expressions don't expand in single quotes
#    -- SC2046: Quote this to prevent word splitting
#    -- SC2086: Double quote to prevent globbing and word splitting.
#    -- SC2155: Declare and assign separately to avoid masking return values
#    -- SC2139: This expands when defined, not when used. Consider escaping.
#    -- SC2206: Quote to prevent word splitting/globbing
#    -- SC2116: Useless echo?
# - Globally ignores the following:
#    -- SC1001: Can't follow non-constant source
#    -- SC1091: Not following: ... was not specified as input (see shellcheck -x)
#    shellcheck disable=SC1001,SC1091
#
# TODO:
# - ***** Move settings to tomohara-settings.bash (i.e., export's and the like).
# - ***** Put work-specific stuff in separate file!"
# - **** Add EX-bases tests for all numeric aliases!
# - ***** Fix problems noted by shellcheck (and rework false positives)!.
# - *** Indent [maldito] shell-check blocks.
# - ** Add macros to provide cribsheet on usage!
# - *** Purge way-old stuff (e.g., lynx related)!
# - *** Use check_usage for usage statements.
# - ** Add option to move alias not to put files in subdirectory of target directory. That is, the move command aborts rather than doing following: 'move sub-dir target-dir' ==> target-dir/sub-dir/sub-dir).
# - ** Minimize overriding commands like 'cd' and 'script' to avoid confusion.
# - ** Likewise non-standard usages for variables like 'PS1' (e.g., via 'PS_symbol').
# - * Drop support for solaris and remove BAREBONES_HOST support.
# - Replace backquote evaluation (`...`) with $(...)
# - ** Fix the many cracks that fell through alias categorization (alias/function grouping???).
# - convert $* to "$@" throughout, as appropriate
# - add more structure and decompose into helper scripts (e.g, wordnet aliases)
# - use dashes instead of underscores in scripts as well as macros
# - decompose into do-cs-setup.bash do-arahomot-setup.bash, etc.
# - add more optional sections (as with 'if [ "$HOSTNAME" != "arahomot" ]; ...'
# - replace '-' macro suffix (eg, 'gr-') with something more uniformative (eg, '-alt')
# - create function for recreating local directories (e.g., ~/info) assumed by do-setup scripts (e.g., do_setup.bash)
# - Remove () from function definitions.
# - Add error checking in functions for unspecified arguments.
# - Make sure all function variables use local.
# - Add upcase alias (perl -pe 's/(.*)/\U$1\e/g;')
# - Make sure functions don't refer to undefined macros (e.g., defined later).
# - Main environment variables (e.g., HOST, DEFAULT_HOST, etc.)!
#     DEFAULT_HOST: (remote) hostname which gets omitted from xterm title
#     MY_GREP_OPTIONS: options for grep command (e.g., "-n -d skip -s")
#     TOM_BIN: directory for shell scripts
#     TODO: the rest
# - Miscellaneous environment variables:
#     GTAR: gnu version of tar (n.b., same as tar under Linux)
#     NICE: command for running another under nice priority
#     PYTHON: command for runnng python (e.g., "nice -19 /usr/bin/time python -u")
#     SORT_COL2: key specification for sort (e.g., "--key=2")
#     TPO_SSH_KEY: path to private SSH key
# - Make sections more apparent and easier to grep (e.g., use Xyz settings (or Xyz Stuff, along
#   with section dividers).
# - Replace '/bin/cmd ...' with 'command cmd ...' in aliases.
# - Check for undeclared local variables in functions.
#

# For debugging: Uncomment the following line(s)
## OLD: ## DEBUG: echo in tomohara-aliases.bash 1>&2
[[ $DEBUG_LEVEL -ge 6 ]] && echo in "${BASH_SOURCE[0]}" 1>&2
## DEBUG: set -o xtrace

#...............................................................................
# Bash wrappers

# Conditional environment variable setting
# Format: cond-export VAR1 VALUE1 [VAR2 VALUE2] ...
# EX: export FU="bar"; conditional-export FU baz; echo $FU => bar
#
function conditional-export () {
    local var value
    local args
    while [ "$1" != "" ]; do
        var="$1" value="$2";
        ## DEBUG: echo "value for env. var. $var: $(printenv "$var")"
        if [ "$(printenv "$var")" == "" ]; then
            # Ignores SC1066: Don't use $ on the left side of assignments
            # shellcheck disable=SC1066,SC2046,SC2086
            export $var="$value"
        fi
        args="$*"
        shift 2
        if [ "$args" = "$*" ]; then
            echo "Error: Unexpected value in conditional-export (var='$var'; val='$value')"
            return 
        fi
    done
}
#
alias conditional-setenv='conditional-export'
alias cond-export='conditional-export'
# TODO: drop following after all do_setup.bash settings moved here
alias cond-setenv='conditional-export'
# global(var-name, ...): declare var-name to be global (e.g., global count)
alias global='declare -g'

# For debugging: Uncomment the following to display the environment variables (TODO: rework via startup-trace).
## printenv.sh

# alias-fn(name, statement, ...): define NAME alias via function def w/ STATEMENT ...
# NOTE:
# - Variable intended for run-time evaluation should be passed inside a single quoted string (or escaped with \)
# - This is so that the alias becomes a "first class" citizen, such as allowing for
#   environment variables to be set as in 'alias-fn echo-ENV1 'echo "$ENV1"'; ENV1=one echo-ENV1
# - Use dummy command if a background command is invoked: gotta hate Bash!
#   ex: alias-fn eyes 'xeyes & true'
# - General version as replacement for complex aliases with multiple commands
##
# ex: alias-fn trace-PS1 'echo \$PS1="$PS1" 1>&2'
# TODO: fix problem with embedded invocations (see em-adhoc-notes below)
function alias-fn {
    local alias="$1"
    shift
    local body="$*"
    eval "function $alias { $body; }"
}
# simple-alias-fn(name, command): variant that takes command and appends "$@"
# ex: simple-alias-fn git-next-checkin 'invoke-alt-checkin'
# Note: this is streamlined version of alias-fn intended as replacement for 'alias name=command' usages
function simple-alias-fn {
    if [ "$3" != "" ]; then
        echo "usage: simple-alias-fn alias command"
        echo "note: '\$\@' gets appended to command"
        return
    fi
    local alias="$1"
    local command="$2"
    # note: 
    eval "function $alias { $command" '"$@"' "; }"
}
# deprecated-alias-fn: version of simple-alias-fn that issues deprecated warning
# TODO3: seee if it can be defined via simple-alias-fn
function deprecated-alias-fn {
    local alias="$1"
    local command="$2"
    eval "function $alias { echo 'Warning: deprecated alias: $alias' 1>&2; $command" '"$@"' "; }"
}
#................................................................................
# General environment settings
## TOM-IDIOSYNCRATIC

cond-export DEBUG_LEVEL 3

#...............................................................................
# Directory for Tom O'Hara's scripts, defaulting to /home/tomohara if available
# otherwise $HOME/bin
## TOM-IDIOSYNCRATIC
## DEBUG: 
# Note: ${BASH_SOURCE[0]}" is the script being sourced. The array itself gives
# the source files for all functions on the execution call stack.
# See https://stackoverflow.com/questions/35006457/choosing-between-0-and-bash-source.
alias_source_dir="$(dirname "${BASH_SOURCE[0]:-$0}")"
cond-export TOM_DIR "$alias_source_dir/.."
if [ ! -d "$TOM_DIR" ]; then
    echo "Warning unable to resolve TOM_DIR; using $HOME" 1>&2
    export TOM_DIR="$HOME";
fi
#
master_alias_script="all-tomohara-aliases-etc.bash"
cond-export TOM_BIN "$alias_source_dir"
if [ ! -e "$TOM_BIN/$master_alias_script" ]; then
    echo "Warning: Unable to find $master_alias_script in Tom's bin directory ()" 1>&2
fi
alias tomohara-setup='source $TOM_BIN/$master_alias_script'

# Alias for startup-script tracing via startup-trace function
if [ ! -e "$HOME/temp" ]; then
   echo "WARNING: creating $HOME/temp for startup script logs"
   mkdir "$HOME/temp"
fi
#
# Define simple version of startup tracing
function startup-trace () { if [ "$STARTUP_TRACING" = "1" ]; then echo "$@" "[$HOSTNAME $(date)]" >> "$HOME/temp/.startup-$HOSTNAME-$$.log"; fi; }
# conditional-source(filename): source in bash commands from filename if exists
function conditional-source () { if [ -e "$1" ]; then source "$1"; else echo "Warning: bash script file not found (so not sourced):"; echo "    $1"; fi; }
function quiet-conditional-source { source "$@" > /dev/null 2>&1; }
#
# Enable full-blown startup tracing if evailable
# note: kept separate for use in other scripts
conditional-source "$TOM_BIN/startup-tracing.bash"
startup-trace "post-tracing init in ${BASH_SOURCE[0]}"
#
alias trace='startup-trace'
alias enable-startup-tracing='export STARTUP_TRACING=1'
alias disable-startup-tracing='export STARTUP_TRACING=0'
alias enable-console-tracing='export CONSOLE_TRACING=1'
alias disable-console-tracing='export CONSOLE_TRACING=0'

#................................................................................
# Helper functions (along with aliases and variables)
#

# missing-options(): whether no options specified or --help/-h
# note: based on POE Assistant
# usage: if missing-options "$@"; then echo "Usage: ..."; fi
function missing-options {
    [[ $# -eq 0 || "$1" == "--help" || "$1" == "-h" ]]
}

# function-usage(): helper alias for showing function usage statements
# note: based on POE Assistant
# Sample usage:
#    function fubar {
#        if missing-options "$@"; then
#           function-usage --synopsis "fouled up beyond recognition" --example "now"
#           return
#        fi
#        echo "is fubar: " "$1"
#    }
function function-usage {
    local synopsis=""
    local example=""
    local notes=""
    local args="{path | -}    # with - for stdin"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --args) args="$2"; shift 2 ;;
            --synopsis) synopsis="$2"; shift 2 ;;
            --example)  example="$2"; shift 2 ;;
            --notes)    notes="$2"; shift 2 ;;
            *) break ;;
        esac
    done

    local fn="${FUNCNAME[1]}"

    echo "Usage: $fn $args"
    [[ -n "$synopsis" ]] && echo "Synopsis: $synopsis"
    [[ -n "$example"  ]] && echo "Example: $fn $example"
    [[ -n "$notes"    ]] && echo -e "Note:\n$notes"

    return 0
}

# space-check(arg): ensures ARG has no embedded spaces (and no other arguments)
function space-check() {
   if [ "$2" != "" ]; then
      echo "Error: space-check accepts just 1 arg; extraneous arg follows: $2"
   fi
   case "$1" in *\ *) echo "Error: argument should not contain spaces: $1";; esac
}
# downcase-stdin(): convert STDIN to lowercase
# downcase-text(text, ...): downcase TEXT
# EX: echo "Tomás" | downcase-stdin => "tomás"
## BAD: function downcase-stdin() { perl -pe 's/.*/\L$&/;'; }
## TODO:
## alias perl-utf8="perl -e \"use open ':std', ':encoding(UTF-8)'\""
## function downcase-stdin() { perl-utf8 -pe 's/.*/\L$&/;'; }
function downcase-stdin { perl -pe "use open ':std', ':encoding(UTF-8)'; s/.*/\L$&/;"; }
function downcase-text { echo "$@" | downcase-stdin; }
# date-ddmmmyy(date_spec): return date using European style (e.g., 25feb26)
function date-ddmmmyy {
    if [ "$1" == "" ]; then
        echo "usage: _ date-specification"
        echo "example: ${FUNCNAME[0]} --date='@'"
        echo "alt example: ${FUNCNAME[0]} --date='@0'"
        ## TODO5: arcane example: $((36525/100 * 60*60*24))
    fi
    date --date "$1" '+%d%b%y' | downcase-stdin;
}
# todays-date(): outputs date in format DDmmmYY (e.g., 22apr20)
## TODO: drop leading digits in day of month
## NOTE: keep in synch with common.perl get_file_ddmmmyy and .emacs edit-adhoc-notes-file
## example usage: ddmmmyy=$(todays-date); ... run-it > _run-it-$ddmmmyy.log 2>&1
## OLD: function todays-date { date '+%d%b%y' | downcase-stdin; }
function todays-date { date-ddmmmyy "now"; }
# todays-date-mmmYY(): date in format mmmYY (e.g., sep20)
function todays-date-mmmYY { todays-date | perl -pe 's/^\d\d//;'; }
# hoy: alternative to todays-date
alias hoy=todays-date
hoy=$(todays-date)
# Note: version so Spanish not used in note files
# TODO: punt on tab-completion (i.e., TODAY => today)???
alias TODAY=todays-date
alias date-central='TZ="America/Chicago" date'

# ddmmmyy-hhmm(): return timestamp in European-like format using a single token (e.g., 31dec25@2359).
# note: This is intended for use in filenames (e.g., _free-21Feb26@1549).
# ex: 01jan26@0001).
function mmddyy-hhmm {
    ## OLD: date '+%d%b%y@%H%M'
    date '+%d%b%y@%H%M' | downcase-stdin;
}
alias todays-date-hhmm='mmddyy-hhmm'

# file-date-mmdddyy(): return file's timestamp in European format without hours and minutes
# note: %y gives time of last data modification, human-readable
function file-date-mmdddyy {
    if missing-options "$@"; then
        function-usage --synopsis "return file timestamp using mmdddyy" --example "$TMP/fubar.txt"
        return        
    fi
    date-ddmmmyy "$(stat --format=%y "$1")";
}

## TOM-IDIOSYNCRATIC
# em-adhoc-notes(): edit adhoc notes file using format _{dir}-notes-{host}-{date} (e.g., _bin-notes-reempl-may22.txt)
## Lorenzo review: what's the purpose of keeping the old versions?
## BAD: alias-fn em-adhoc-notes 'emacs-tpo _${HOST_NICKNAME:misc}-adhoc-notes-$(todays-date-mmmYY).txt'
function em-adhoc-notes {
    emacs-tpo "$(downcase-text "$(basename "$PWD")-notes-${HOST_NICKNAME:tpo-host}-$(todays-date-mmmYY).txt")";
}

alias T='TODAY'
# update-today-vars() & todays-update: update the various today-related variables
# aside: descriptive name for function and convenience alias (tab-completion)
# TODO: try for cron-like bash function to enable such updates automatically
function update-today-vars {
    TODAY=$(todays-date)
    T=$TODAY
}
update-today-vars
alias todays-update='update-today-vars'
#
# reference-variable(var, ...): use to mark VAR as used in order to silence bash liners like shell check (e.g., for variables only used interactively)
# usage: reference-variable "$var1, ..."
# TODO: figure out way to do without quotes (e.g., to avoid SC2086: Double quote to prevent globbing ...)
function reference-variable { true; }
reference-variable "$hoy $T"

# Alias creation helper(s)
# Note: does no-op so that status set to 0 for sake of tests/test_tomohara-aliases.bash setup
# TODO: use more explicit way to set status
## TODO: function quiet-unalias { unalias "$@" 2> /dev/null; echo > /dev/null; }
function quiet-unalias {
    ## HACK: do nothing if running under bats-core
    if [ "$BATS_TEST_FILENAME" != "" ]; then
        if [ "$BATCH_MODE" != "1" ]; then
            echo "Ignoring unalias over $* for sake of bats"
        fi
        return
    fi
    unalias "$@" 2> /dev/null || true;
}

# Bash customizations (e.g., no beep)
# via https://www.gnu.org/software/bash/manual/bash.html
# - If the histappend shell option is set (see Bash Builtins), the lines are
# appended to the history file, otherwise the history file is overwritten.
# - HISTCONTROL
# ... ‘ignoredups’ causes lines which match the previous history entry to not
# be saved. .... ‘erasedups’ causes all previous lines matching the
# current line to be removed from the history list before that line is saved.
# - HISTSIZE: maximum number of commands to remember ... less than zero [means] every
# command [is] saved ... default value [is] 500...
# - HISTFILESIZE: maximum number of lines contained in the history file. 
# TODO: do more excerpting or just summarize above.
## BAD: set bell-style none
## NOTE: 'set bell-style none' is a readline/.inputrc directive, not a bash command
export HISTCONTROL=ignoredups
export HISTTIMEFORMAT='[%F %T] '
# Ensure that the history files are merged (n.b., timestamping required for
# proper sequencing of entries from different shell windows).
## BAD: set histappend
shopt -s histappend
# note: following are 50x the defaults
## BAD:
## export HISTSIZE=50000
## export HISTFILESIZE=100000
export HISTSIZE=25000
export HISTFILESIZE=32767
#
# Note: bash setting(s) in ~/.bash_profile
# format: shopt [-s | -u] optionname
#   where -s to sets and -u unsets
#   shopt -s nocaseglob   # ignore case in filename glob patterns
#
# Ignore case in pattern matching
shopt -s nocasematch

#-------------------------------------------------------------------------------
trace do_setup.bash invocation

# Get initital settings from ~/bin/do_setup.bash
if [ -e "$TOM_BIN/do_setup.bash" ]; then source "$TOM_BIN/do_setup.bash"; fi

#-------------------------------------------------------------------------------
trace 'in tomohara-aliases.bash'

# # HACK: load in older tpo-setup.bash
# conditional-source $TOM_BIN/tpo-setup.bash

# under-os(regex, [quiet=0]): Whether REGEX matches $OSTYPE
# note: outputs boolean code and also sets status code
function under-os {
    local regex="$1"
    local quiet="$2"
    local under_os=0
    if [[ "$OSTYPE" =~ $regex ]]; then under_os=1; fi
    if [ "$quiet" != "1" ]; then
        echo "$under_os"
    fi
    [ "$under_os" != 0 ]
    return $?
    }
# under-macos([quiet]) => boolean: whether running under maldito macintosh
# EX: (under-macos; wc -l /vmlinuz 2> /dev/null) =/=> $'0\n1'
# example; under-macros 1 && echo "good luck"
function under-macos {
    under-os ".*darwin.*" "$@"
    return $?
}
# under-linux([quiet]) => boolean: whether under favorite son OS
# example; under-linux 1 && echo "good job"
function under-linux {
    under-os ".*linux.*" "$@"
    return $?
}
function under-cygwin {
    under-os ".*cygwin.*" "$@"
    return $?
}

# Settings for less command 
# LESS="-cFIX-P--Less-- ?f%f:(stdin). ?e(END):?pb(%pb\%) ?m(%i of %m)..%t"
#
# less options:
#     -c   full screen repaints to be painted from the top line down
#     -F   automatically exit if the entire file can  be  displayed on first screen
#     -I   searches ignore case even if the pattern contains uppercase letters
#     -S   Causes lines longer than the screen width to be chopped
#     -X   Disables sending the termcap initialization and deinitialization
#     -P   changes the prompt
# to override on command line
#     -+<option>    ex: -+F
#     
cond-export LESS "-cFIX-P--Less-- ?f%f:(stdin). ?e(END):?pb(%pb\%) ?m(%i of %m)..%t"
# Disables full-screen repaints under minimal-installation hosts (e.g., Beowolf nodes)
if [ "$BAREBONES_HOST" = "1" ]; then export LESS="-cIX-P--Less-- ?f%f:(stdin). ?e(END):?pb(%pb\%) ?m(%i of %m)..%t"; fi
export PAGER="${PAGER:-less}"
cond-export PAGER_CHOPPED "less -S"
cond-export PAGER_NOEXIT "less -+F"
# less-pattern(pattern, ...): invoke less with PATTERN (and other args) unless empty
function less-pattern {
    if [ "$1" ]; then less -p "$@"; else less; fi
}
function zless () { zcat "$@" | $PAGER; }
# 
# zhead(file, head-opts)
function zhead () { 
    local file="$1"
    shift
    zcat "$file" | head "$@"
}
alias less-='$PAGER_NOEXIT'
alias less-clipped='$PAGER_NOEXIT -S'
alias less-tail='$PAGER_NOEXIT +G'
alias less-tail-clipped='$PAGER_NOEXIT +G -S'
alias ltc=less-tail-clipped
cond-export ZPAGER zless

#-------------------------------------------------------------------------------
trace start of main settings

# Path settings
# TODO: define a function for removing duplicates from the PATH while
# preserving the order
function show-path-dir () { (echo "${1}:"; printenv "$1" | perl -pe "s/:/\n/g;") | $PAGER; }
# show-path(): show PATH entries one per line
# show-lib-path(): shows LD_LIBRARY_PATH entries one per line
alias show-path='show-path-dir PATH'
alias show-lib-path='show-path-dir LD_LIBRARY_PATH'
# append-path(path): appends PATH to environment variable unless already there
## TODO: function in-path { local path=$(tr ":" "\n" | $GREP "^$1$$"); return ($path != ""); }
# TODO: add force argument to ensure last (or first)
function append-path () { if [[ ! (($PATH =~ ^$1:) || ($PATH =~ :$1:) || ($PATH =~ :$1$)) ]]; then export PATH="${PATH}:$1"; fi }
function append-path-warn {
    if [ ! -e "$1" ]; then
        echo "Warning: append-path non-existent: $1" 1>&2
    fi
    append-path "$1";
}
#
function append-path-force () { export PATH="${PATH}:$1"; }
function prepend-path-force () { export PATH="$1:${PATH}"; }
alias prepend-path=prepend-path-force

# TODO: rework append-/prepend-path and python variants via generic helper
function append-python-path () { export PYTHONPATH=${PYTHONPATH}:"$1"; }
function prepend-python-path () { export PYTHONPATH="$1":${PYTHONPATH}; }

# is-true(env_var, default): returns true iff env_var set to true-like value
# usage: local verbose=$(is-true "VERBOSE"); ... $verbose && echo "step n"
function is-true {
    # Get the environment variable name
    local env_name="$1"
    
    # Get the value of that environment variable (default to "false")
    local value=
    value=$(eval echo "\${$env_name:-false}")
    
    # Convert to lowercase for easier checking
    value=$(echo "$value" | tr '[:upper:]' '[:lower:]')
    
    # Check if it's a false-like value
    local result=true
    case "$value" in
        0|f|false|no|off|"")
            result=false
            ;;
    esac
    echo $result
}

#-------------------------------------------------------------------------------
# Bash stuff (settings, etc.)
#
# FIGNORE: A colon-separated list of suffixes to ignore when performing filename completion ("tab completion")
export FIGNORE=".o:.fasl:.fas:.lib"
## TEST: export FIGNORE=".o:.fasl:.fas:.lib:.log"
## TODO: figure out how to exclude .log for executable-tab-expansion (e.g., first position)
set -o noclobber
#
# case-insensitive file glob
shopt -s nocaseglob
# note: add following to your .inputrc for case-insenstive tab completion
#    set completion-ignore-case on

#
# MAILCHECK: Specifies how often (in seconds) bash checks for mail.
# ... If this variable is unset, the shell disables mail checking.
unset MAILCHECK
#
# Make sure tab completion not escaped for directory names
# Stupid bash developers: dropped without explicit warning!
## shopt -s direxpand

# MAIL If this parameter is set to a file name and the MAILPATH variable is not
#      set, bash informs the user of the arrival of mail in the specified file.
unset MAIL

# Unix environ stuff
# Note:
# - TEMP is private temp dir (e.g., ~/temp); TMP is system temp dir (e.g., /tmp)
# - See https://en.wikipedia.org/wiki/TMPDIR.
# - Also see tomohara-settings.bash and ~/.bash_profile.
cond-export TEMP "$HOME/temp"
cond-export TMP "$TEMP/tmp"
cond-export TMPDIR "$TMP"
mkdir -p "$TEMP" "$TMP" "$TMPDIR"
# NOTE: LINE and COLUMNS are in support of ps_sort.perl and h (history).
# They get reset via resize.
cond-export LINES 52
cond-export COLUMNS 80
#
# NOTE: resize used to set LINES below
alias run-csh='export USE_CSH=1; csh; export USE_CSH=0'

# Note: support for prompt prefix
# reset-prompt(symbol): resets PS1 to PS_symbol, optionally changed to symbol
# If symbol is empty, then DEFAULT_PS_SYMBOL  is used.
# This could be a no-op if PS1 already is based on PS_symbol,
# ex: reset-prompt '§'                 # section sign [U+00A7]
# TODO: document PSn usage (e.g., Bash manual excerpt)
## TEST
## # PS_prefix should be defined in host-specific file (e.g., ~/.bashrc.<nickname>)
## # elsewhere: export PS_prefix="T "
## alias reset-prompt='export PS1="$PS_prefix""$ "'
# Note: PS_symbol defines the prompt symbol (e.g., '$' vs. '§' [U+00A7])
# example override (from .bashrc):
#    export PS_symbol="¢"      # cent sign (U+00A2)
## TODO: resolve interaction among 'reset-prompt', 'script' and 'add-conda-env-to-xterm-title' (see anaconda-aliases.bash for latter)
cond-export PS_symbol '$'
function reset-prompt {
    ## DEBUG: echo "reset-prompt" "$@"
    local new_PS_symbol="$*"
    if [ "$new_PS_symbol" = "" ]; then new_PS_symbol="${DEFAULT_PS_SYMBOL:-$PS_symbol}"; fi
    # Do nothing if empty
    if [ "$new_PS_symbol" = "" ]; then return; fi    
    ## TODO: if [ "$new_PS_symbol" = "" ]; then echo $'Usage: reset-prompt symbol\nex: reset-prompt §"\n'; return; fi
    ## TODO: add options to reset PS1 and to list good symbols for prompts
    # Make the change
    ## DEBUG: echo "reset-prompt: 1. PS1='$PS1' old_PS_symbol='$old_PS_symbol' PS_symbol='$new_PS_symbol'"
    export PS_symbol="$new_PS_symbol";
    export PS1="$PS_symbol "
    ## DEBUG: echo "reset-prompt: 2. PS1='$PS1' old_PS_symbol='$old_PS_symbol' PS_symbol='$new_PS_symbol'"
    # Update xterm title
    set-title-to-current-dir;
    ## DEBUG: echo "reset-prompt: 3. PS1='$PS1' old_PS_symbol='$old_PS_symbol' PS_symbol='$new_PS_symbol'"
}
alias reset-prompt-root='reset-prompt "#"'
alias root-prompt=reset-prompt-root
alias reset-prompt-dollar='reset-prompt "\$"'
{
    # shellcheck disable=SC2139
    alias reset-prompt-default="reset-prompt '$PS_symbol'"
}
## TODO: alias reset-prompt-default='reset-prompt "\$PS_symbol"'

# rehash(): reset locations for programs
## BAD: alias rehash='hash -l' 
alias rehash='hash -r; hash -l' 

#
# check_usage(arg, help): shows HELP if ARG --help or empty, setting status true (0) if displayed
# sample: check_usage "$1" $'usage: munge filename\nexample: munge /etc/password' && return
function check_usage {
    local expected_arg="$1"
    local usage_text="$2"
    if [[ ("$expected_arg" == "--help") || ("$expected_arg" == "") ]]; then
        echo "$usage_text"
        true
    else
        false
    fi
}

#-------------------------------------------------------------------------------
# More misc stuff
## TOM-IDIOSYNCRATIC

# reset CDPATH to just current directory
export CDPATH=.

# flag for turning off GNOME, which can be flakey at times
# See xterm.sh (e.g., gnome-terminal).
cond-export USE_GNOME 1

# General Settings for my scripts
cond-export PRECISION 3
alias debug-on='export DEBUG_LEVEL=3'
if [ "$PERLLIB" = "" ]; then PERLLIB="."; else PERLLIB="$PERLLIB:."; fi
# NOTE: perl uses architecture-specific subdirectories under PERLLIB
export PERLLIB="$TOM_BIN:$PERLLIB:$HOME/perl/lib/perl5/site_perl/5.8"
# HACK: not all cygwin directories being recognized
export PERLLIB="$HOME/perl/lib/perl5/5.16:$HOME/perl/lib/perl5/5.16/vender_perl:$PERLLIB"
# perl-(): perl with following options: -S use path; -s enable switches (-x=v); -w show warnings;
# See perlrun manpage.
# TODO4: rename perl- to perl-usual???
alias perl-='perl -Ssw'
## Lorenzo review: should change this to perl-alt following TODO's
## TODO: function alias-perl { DURING_ALIAS=1 perl "$@"; }
# alias-perl(): perl with DURING_ALIAS defined (n.b., avoids excess tracing; see common.perl)
## NOTE: using perl.sh in alias leads to problems under Github workflows
## TODO: alias alias-perl='DURING_ALIAS=1 perl.sh -Ssw'
## TODO?
## function alias-perl {
##    DURING_ALIAS=1 env perl --Sw "eval $*";
## }
# shellcheck disable=SC2016
## OLD: simple-alias-fn alias-perl 'DURING_ALIAS=1 DEBUG_LEVEL=$ALIAS_DEBUG_LEVEL perl -Ssw'
# note: DURING_ALIAS normally unset; set as 0 to debug aliases using alias-perl
# example: DURING_ALIAS=0 check-errors $log
simple-alias-fn alias-perl 'DURING_ALIAS=${DURING_ALIAS:-1} DEBUG_LEVEL=$ALIAS_DEBUG_LEVEL perl -Ssw'
#
# alias-python: python invocation for using in aliases
# note: avoids excess tracing; see debug.py and main.py;
# uses function to allow ALIAS_DEBUG_LEVEL override;
# also sets PYTHONSAFEPATH to avoid conflicts from mezcla from current dir
# (n.b., added in python 3.11).
# shellcheck disable=SC2016
simple-alias-fn alias-python 'DURING_ALIAS=${DURING_ALIAS:-1} PYTHONSAFEPATH=1 DEBUG_LEVEL=$ALIAS_DEBUG_LEVEL python3'
# alias-python-which(script): invoke script as alias (e.g., minimal tracing)
## TODO2: derive more intuitive name (e.g., 
function alias-python-which {
    local script="$1"
    shift
    alias-python "$(which "$script")" "$@";
}
#
export MANPATH="$HOME/perl/share/man/man1:$MANPATH"
append-path "$HOME/perl/bin"
# Note: TIME is used for changing output format, so TIME_CMD used instead.
# TODO: Do check for environment variable overlap (as with DEBUG_LEVEL clash with software
# used at Convera).
## BAD: export TIME_CMD="command time"
# note: command is a binary under MacOs but just a shell builtin under Linux
cond-export TIME_CMD "command time"
if [ "$(which "command" 2> /dev/null)" == "" ]; then
    export TIME_CMD=/usr/bin/time
fi
cond-export PERL "$NICE $TIME_CMD alias-perl"

# Terminal window title
alias set-xterm-title='set_xterm_title.bash'
alias set-xterm-window='set-xterm-title'
# Set the title for the current xterm, unless if not running X
# set-title-to-current-dir(): use $PWD with ~ un-expansion for xterm title
function set-title-to-current-dir () { 
    local dir
    dir=$(basename "$PWD");
    ## TODO: local pwd="${PWD/$HOME/~}"
    local pwd
    pwd="$(echo "$PWD" | perl -pe "s@$HOME@~@;")"
    local other_info=""; 
    if [ "$CLEARCASE_ROOT" != "" ]; then other_info="; $other_info cc=$CLEARCASE_ROOT"; fi
    set-xterm-window "$dir [$pwd]$other_info";
    ## Note: until VM setup for current client, the symbol is put before the directory basename.
    ## TEST: set-xterm-window "$PS_symbol $dir [$pwd]$other_info";
    ## TODO: set-xterm-window "$dir [$PS_symbol$pwd]$other_info";
}
if [[ ("$TERM" = "xterm") || ("$TERM" = "cygwin") ]]; then set-title-to-current-dir; fi
#
alias reset-xterm-title='set-xterm-window "$HOSTNAME $PWD"'
# old-alt-xterm-title([prefix=alt]): change xterm title to PREFIX DIR-BASENAME [PWD]
# Warning: this doesn't modify the prompt symbol (e.g. $PS_symbol). For that,
# use the new reset-prompt-label in tomohara-proper-aliases.bash.
function old-alt-xterm-title() { 
    local dir
    local prefix="$1"
    if [ "$prefix" = "" ]; then prefix="alt"; fi
    dir=$(basename "$PWD")
    set-xterm-window "$prefix: $dir [$PWD]"; 
}
# TODO: see if DEFAULT_HOST used outside of xterm title
alias set-xterm-default-host='export DEFAULT_HOST=n/a; cd .'
alias gterm=gnome-terminal
# background-app(app, arg1, ...): runs APP in background with ARG1, ...
# note: helper for alias so that arguments can be added by user (e.g., --help)
function background-app () { "$@" & }
alias gdisk-mgr='background-app gnome-disks'

# Set file creation permission mask to enable RWX for user & group and none for others
# NOTE:
# - X needed in case directories created (or program files)
# - usage: umask ugo -or- umask symbolic-mode
#
# NOTE: umask is getting set to 0002 with above
#
## TODO: umask ug=rwx,o=r

# Settings for the Language Toolkit that comes with Open Office
cond-export LANGUAGE_TOOL_HOME "$TOM_DIR/programs/java/LanguageTool-2.1"

#------------------------------------------------------------------------
# Shell aliases for overriding commands, etc
#
trace alias overrides

# Command overrides for cd, etc. that set the xterm title to the current directory
# TODO: use alias's instead so that the same name can be used as the command
# NOTES: 
#
# - (from bash manual)  There is no mechanism for using arguments in
# the replacement text, as in csh. If arguments are needed, a shell
# function should be used.
#
# This is conditioned upon not running under emacs, so that the escape
# sequence doesn't end up in the buffer.
#
if [ "$UNDER_EMACS" != "1" ]; then
    function cd () { builtin cd "$@"; set-title-to-current-dir; }
    function pushd () { builtin pushd "$@"; set-title-to-current-dir; }
    function popd () { builtin popd; set-title-to-current-dir; }
fi
alias chdir='cd'
# cd-realdir(dir): change into the real path for DIR
# cd-this-realdir: ditto for current directory
function cd-realdir {
    local dir="$1";
    if [ "$dir" = "" ]; then dir=.; fi;
    # note: cd/pwd used so that xterm updated
    cd "$(realpath "$dir")";
    pwd;
}
alias cd-this-realdir='cd-realdir .'
# shellcheck disable=SC2016
alias-fn pushd-this-realdir 'pushd "$(realpath ".")"'

# pushd-q, popd-q: quiet versions of pushd and popd
#
function pushd-q () { builtin pushd "$@" >| /dev/null; }
function popd-q () { builtin popd >| /dev/null; }
#

# Command overrides for moving and copying files
# NOTE: -p option of cp (i.e., --preserve  "preserve file attributes if possible")
# leads to problems when copying files owner by others (although group writable)
#    cp: preserving times for /usr/local/httpd/internal/cgi-bin/phone-list: Operation not permitted
# - other options for cp, mv, and rm: -i interactive; and -v verbose.
other_file_args="-v"
if [ "$OSTYPE" = "solaris" ]; then other_file_args=""; fi
## NOTE: Unfortunately clear clobbers the terminal scrollback buffer.
## via https://askubuntu.com/questions/792453/how-to-stop-clear-from-clearing-scrollback-buffer:
##    type CTRL+L instead of clear
## TAKE1: alias cls="printf '\33[H\33[2J'"
##   where \33 is octal code for Escape (i.e., 0x1B)
## TAKE2
alias clear="echo 'use cls instead (or command clear)'"
alias cls="command clear -x"
{
    # TODO: see if this is a shellcheck bug
    #    SC2034: MV appears unused. Verify it or export it.
    # shellcheck disable=SC2034
    MV="command mv -i $other_file_args"
}
alias mv='$MV'
alias move='mv'
alias move-force='move -f'
# move-then-link(file, dir): moves FILE to DIR and then creates symbolic link
function move-then-link {
    local file="$1"
    ## TODO: chomp $dir
    local dir="$2"
    move "$file" "$dir"
    link-symbolic "$dir/$file"
}
# TODO: make sure symbolic links are copied as-is (ie, not dereferenced)
CP="command cp -ip $other_file_args"
reference-variable "$CP"
alias copy='$CP'
alias del="delete"
alias copy-force='command cp -fp $other_file_args'
alias cp='command cp -i $other_file_args'
alias copy-noclobber-old='copy --no-clobber'
alias copy-noclobber='copy --update=none'
alias move-noclobber-old='move --no-clobber'
alias move-noclobber='move --update=none'
# maldito shellcheck bug: SC2032: Use own script or sh -c '..' to run this from find
# shellcheck disable=SC2032
alias rm='command rm -i $other_file_args'
alias delete='command rm -i $other_file_args'
# shellcheck disable=SC2034
{
    ## NOTE: redundancy is needed for sake of sanity (force_echo was getting inadvertently
    ## reset due to cut-n-paste)
    ## BAD: force_echo=""
    declare -g force_echo
    force_echo="disable-forced-deletions-aux"
    newline_tab=$'\n\t'
    # TODO1: fix newline/tab support
    # disable-forced-deletions-aux(): shows deletion command on separate line
    # note: for use in $force_echo prefix to delete-force aliases
    function disable-forced-deletions-aux {
        # Make sure no embedded spaces
        local f
        for f in "$@"; do
            if [[ "$f" =~ " " ]]; then
                echo "Error: files with embedded spaces not supported by delete[-dir]-force"
                echo "  $f"
                return
            fi
        done

        # Proceed with 
        echo "Warning: run enable-forced-deletions or issue:"
        echo -n $'\t'
        ## TODO3: for f in "$@"; do echo -n "\"$f"\"; done
        echo "$@"
    }
}
## 
alias disable-forced-deletions='force_echo="disable-forced-deletions-aux"'
alias enable-forced-deletions='force_echo=""'
disable-forced-deletions
#
alias delete-force='$force_echo command rm -f $other_file_args'
#
alias remove-force='delete-force'
# TODO: make sure that rellowing only applied to directories
alias remove-dir='command rm -rvi'
alias delete-dir='remove-dir'
## TODO2: rework xyz-force as prompted command (e.g., `read -r -e -i "$prompt" command; eval "$command";`)
alias remove-dir-force='$force_echo command rm -rfv'
alias delete-dir-force='remove-dir-force'
#
alias copy-readonly='copy-readonly.sh'
function copy-readonly-spec () {
    local spec="$1"
    local dir="$2"
    if [[ ("$3" != "") || ($dir = "") || ($spec == "") ]]; then
        echo "Usage: copy-readonly-spec pattern dir";
        return
    fi
    # shellcheck disable=SC2086
    for f in $($LS $spec); do copy-readonly "$f" "$dir"; done
}
# copy-readonly-to-dir(dir, file, ...): variant of copy-readonly-spec with
# directory first and files given in args 2, 3, etc.
function copy-readonly-to-dir () {
    local dir="$1"
    shift
    for f in "$@"; do copy-readonly "$f" "$dir"; done
}
#
cond-export NICE "nice -19"
## DUPLICATE: export TIME_CMD="/usr/bin/time"

# fix-group-dir-permissions(): fix group sticky bin for directory
## OLD (deprecated):
alias fix-dir-permissions="find . -type d -exec chmod go+xs {} \;"
## TODO3 (add "use set_group_permissions.bash" warning):
## OLD: function fix-group-dir-permissions { (find . -type d | xargs chmod --changes go+xs ) 2>&1 | $PAGER; }
## NOTE: Uses 'print0 ... xargs -0' to avoid chell-check warning; via POE Assistant
function fix-group-dir-permissions { (find . -type d -print0 | xargs -0 chmod --changes go+xs) 2>&1 | "$PAGER"; }
## TODO2: function fix-group-dir-permissions { (find . -type d -exec chmod --changes go+xs {} +) 2>&1 | "$PAGER"; }
## where '-exec ... +' is replacement for xargs usage

#-------------------------------------------------------------------------------
trace directory commands

# Support for ls (list directory contents)
# 
# ls options: # --all: all files; -l long listing; -t by time; --human-readable: uses numeric suffixes like MB; --no-group: omit file permision group; --directory: no subdirectory listings.
# TODO: Add --long as alias for -l to ls source control and check-in [WTH?]! Likweise, all aliases for other common options without long names (e.g., -t).
#
LS="command ls"
core_dir_options="--all -l -t  --human-readable"
dir_options="${core_dir_options} --no-group"
# shellcheck disable=SC2046,SC2086
{
if [ "$OSTYPE" = "solaris" ]; then dir_options="-alt"; fi
if [ "$BAREBONES_HOST" = "1" ]; then dir_options="-altk"; fi
function dir () {
    local opts="$dir_options"
    # note: see https://stackoverflow.com/questions/1853946/getting-the-last-argument-passed-to-a-shell-script
    local dir="${!#}"
    # hack: only shows directory contents if name ends in slash (e.g., /etc/)
    # note: pattern is POSIX extended regular expression as per bash manual
    local regex="^.*/$";
    if [[ (! (($dir != "") || ($dir =~ $regex))) ]]; then
        opts="$opts --directory";
    fi
    $LS ${opts} "$@" 2>&1 | $PAGER;
}
function dir-proper () { $LS ${dir_options} --directory "$@" 2>&1 | $PAGER; }
alias ls-full='$LS ${core_dir_options}'
function dir-full () { ls-full "$@" 2>&1 | $PAGER; }
## TODO: WTH with the grep (i.e., isn't there a simpler way)?
function dir-sans-backups () { $LS ${dir_options} "$@" 2>&1 | $GREP -v '~[0-9]*~' | $PAGER; }
# dir-ro/dir-rw(spec): show files that are read-only/read-write for the user
function dir-ro () { $LS ${dir_options} "$@" 2>&1 | $GREP -v '^..w' | $PAGER; }
function dir-rw () { $LS ${dir_options} "$@" 2>&1 | $GREP '^..w' | $PAGER; }

function subdirs () { $LS ${dir_options} "$@" 2>&1 | $GREP ^d | $PAGER; }
#
# subdirs-proper(): shows subdirs in column format omitting ones w/ leading dots
# note: omits cases like ./ and ./.cpan from find and then removes ./ prefix
# TODO3: have option to include dot-file subdirs like .config
quiet-unalias subdirs-proper
function subdirs-proper () { find . -maxdepth 1 -type d | $EGREP -v '^((\.)|(\.\/\..*))$' | sort | perl -pe "s@^\./@@;" | column; }
# note: -f option overrides -t: Unix sorts alphabetically by default
# via man ls:
#   -f     do not sort, enable -aU, disable -$LS --color
# TODO: simplify -t removal (WTH with perl regex replacement?!)
function dir_options_sans_t () { echo "$dir_options" | perl -pe 's/\-t//;'; }
function subdirs-alpha () { $LS $(dir_options_sans_t) "$@" 2>&1 | $GREP ^d | $PAGER; }
function sublinks () { $LS ${dir_options} "$@" 2>&1 | $GREP ^l | $PAGER; }
function sublinks-alpha () { $LS $(dir_options_sans_t) "$@" 2>&1 | $GREP ^l | $PAGER; }
# TODO: show non-work-related directory example
#
alias symlinks='sublinks'
# symlinks-proper: just show file name info for symbolic links, which starts at column 43
#
## BAD
## ls_filename_col=40
## if [ "$(under-macos)" = "1" ]; then ls_filename_col=42; fi
## function sublinks-proper { sublinks "$@" | cut --characters=${ls_filename_col}-  | $PAGER; }
## example: "lrwxrwxrwx   1 tomohara tomohara   20 2023-06-23 16:50 mezcla -> python/Mezcla/mezcla"
##           1            2 3        4          5  6          7     8
function ls-long-tsv { ls -l --time-style=long-iso "$@" | perl -pe 's/ +/\t/g;'; }
function sublinks-proper { ls-long-tsv "$@" | $GREP ^l | alias-perl cut.perl -fields="8-" - | tr $'\t' ' ' | $PAGER; }
alias symlinks-proper=sublinks-proper
#
alias glob-links='find . -maxdepth 1 -type l | sed -e "s/.\///g"'
alias glob-subdirs='find . -mindepth 1 -maxdepth 1 -type d | sed -e "s/.\///g"'
#
alias ls-R='$LS -R >| ls-R.list; wc -l ls-R.list'
#
# TODO: create ls alias that shows file name with symbolic links (as with ls -l but without other information
# ex: ls -l | perl -pe 's/^.* \d\d:\d\d //;'
}

# link-symbolic-safe: creates symbolic link and avoids quirks with links to directories
# EX: link-symbolic-safe /tmp temp-link; link-symbolic-safe --force ~/temp temp-link; ls -l temp-link | grep /tmp => ""
# TODO3: decide on using ln-symbolic vs link-symbolic vs both
alias ln-symbolic='ln --symbolic --verbose'
alias link-symbolic=ln-symbolic
alias link-symbolic-safe='ln-symbolic --no-target-directory --no-dereference'
alias ln-symbolic-safe=link-symbolic-safe
alias link-symbolic-regular='ln-symbolic'
alias ln-symbolic-force='ln-symbolic --force'
alias link-symbolic-force=ln-symbolic-force

#-------------------------------------------------------------------------------
trace grep commands

# check for a modern version of grep. For example,
#
# $ grep -V
# grep (GNU grep) 2.4.2
#
# Copyright 1988, 1992-1999, 2000 Free Software Foundation, Inc.
# ...
#
# In contrast, here's an old verion (e.g., under medusa):
#
# $ grep -V
# GNU grep version 2.0
# usage: grep [-[[AB] ]<num>] [-[CEFGVchilnqsvwx]] [-[ef]] <expr> [<files...>]
#
skip_dirs=""
if [[ $(grep --version) =~ Copyright.*2[0-9][0-9][0-9] ]]; then skip_dirs="-d skip"; fi

# Grep settings and aliases: too many to count!
# TODO: use gr and gr_ throughout for consistency
# TODO: use -P flag (i.e.,  --perl-regexp) w/ grep rather than egrep
# Notes:
# - MY_GREP_OPTIONS used instead of GREP_OPTIONS since grep interprets latter
#   -n       show line numbers
#   -d skip  skip directories (i.e., don't treat as files)
#   -s       suppress error messages (e.g., unreadable files)
#   -E       extended regex support (i.e., old egrep)
# - 'command grep' used to avoid alias and to allow for use with exec
# - egrep is normally used in other aliases instead of grep, unless the pattern will never use extended regex's
## TODO: quiet-unalias grep
## TODO: add alias for resolving grep binary with fallback to "command grep"
GREP="command grep"
simple-alias-fn egrep "$EGREP --color=auto"
EGREP="$GREP --perl-regexp"
# egrep(): issues grep with --perl-regexp
simple-alias-fn egrep "$EGREP --color=auto"
# MY_GREP_OPTIONS: options for use with grep aliases
cond-export MY_GREP_OPTIONS "-n $skip_dirs -s"
# shellcheck disable=SC2086
{
  function gr () { $GREP $MY_GREP_OPTIONS -i "$@"; }
  function gr- () { $GREP $MY_GREP_OPTIONS "$@"; }
  ## Lorenzo review: should change this to gr-alt following TODO's
  ##
  SORT_COL2="--key=2"
  # grep-unique(pattern, file, ...): count occurrence of pattern in file...
  function grep-unique () { $EGREP -c $MY_GREP_OPTIONS "$@" | $GREP -v ":0$" | sort -rn $SORT_COL2 -t':'; }
  # grep-missing(pattern, file, ...): show files without pattern 
  # TODO: archive
  function grep-missing () { $EGREP -c $MY_GREP_OPTIONS "$@" | $GREP ":0"; }
  alias gu='grep-unique -i'
  alias gu-='grep-unique'
  # gu-all: run gu over all files in current dir
  # TODO: archive
  function gu-all () { grep-unique "$@" ./* | $PAGER; }
  #
  function gu- () { $GREP -c $MY_GREP_OPTIONS "$@" | $GREP -v ":0"; }
  ## Lorenzo review: should change this to gu-alt following TODO's
  #
  # grepl(pattern, [other_grep_args]): invokes grep over PATTERN and OTHER_GREP_ARGS and then pipes into less for PATTERN
  # NOTE: actually uses egrep
  # TODO: use more general way to ensure pattern given last while readily extractable for less -p usage
  # Warning: unintuitive split of grep arguments for sake of less highlighting
  function grep-to-less () {
      # TODO: fix warning about possible discrepency between grep regex and less, such as when ^ used (e.g., with multiple files in grep output)
      if [[ ($1 =~ ^[^]) && ($# -gt 2) ]]; then
          echo "Error: ^ will be intrepretted differently by less (e.g., due to multiple files)" 1>&2
      else
          $EGREP $MY_GREP_OPTIONS "$@" | $PAGER_NOEXIT -p"$1";
      fi
  }
  alias grepl-='grep-to-less'
  function grepl () { local pattern="$1"; shift; grep-to-less "$pattern" -i "$@"; }
  # grepl-mako-py(pattern): check for pattern in files via grepl (i.e., to less)
  # shellcheck disable=SC2035
  function grepl-mako-py { grepl "$@" *.py *.mako tests/*.py; }
  #
  # grepl-hist-tail(): grep through bash history
  # note: uses redundant grepl for highlighting (with potentially split args noted above for grep-to-less)
  # TODO3: remove redundant item number (due to history and grepl)
  #    7255: 7255  [2026-03-13 22:57:03] my-gnome-terminal --title "copilot: mezcla" --no-xterm-title
  function grepl-hist-tail { history  | grepl "$@" | tail | grepl "$@"; }
  #
  # grepl-bashrc-etc(): grep through bash rc files excluding history
  # note: see grepl-hist-tail for rationale (e.g., double grepl and potentially split args)
  ## BAD: function grepl-bashrc-etc { grepl "$@" ~/.*bash* | grep -v '\.bash_history' | tail | grepl "$@"; }
  function grepl-bashrc-etc { grepl "$@" ~/.*bash* | grep -v '\.bash_history' | grepl "$@"; }
}
# gr-c: grep through c/c++ source and headers files
# note: --no-messages suppresses warnings about missing files
function gr-c () { gr --no-messages "$@" ./*.c ./*.cpp ./*.cxx ./*.h; }


# TODO: create function for creating gr-xyz aliases
# TODO: -or- create gr-xyz template
## function gr-xyz () { gr- "$@" *.xyz; }

# show-line-context(file, line-num): show 5 lines before LINE-NUM in FILE
# TODO: archive
function show-line-context() { cat -n "$1" | $GREP -B5 "^\W+$2\W"; }

# Helper function for grep-based aliases pipe into less
function gr-less () { gr "$@" | $PAGER; }

# Other grep-related stuff
#
# EX: echo $'L1: one\nL2: \xC3\xBE \nL3: three' | gr-nonascii => "2: L2: þ"
alias grep-nonascii='alias-perl perlgrep.perl "[\x80-\xFF]"'
alias gr-nonascii='alias-perl perlgrep.perl -n "[\x80-\xFF]"'

# Searching for files
# TODO:
# - specify find options in an environment variable
# - rework in terms of Perl regex? (or use -iregex in place of -iname)
#
# shellcheck disable=SC2086
{         # start shellcheck block
function findspec () { if [ "$2" = "" ]; then echo "Usage: findspec dir glob-pattern find-option ... "; else command find $1 -iname \*$2\* $3 $4 $5 $6 $7 $8 $9 2>&1 | $GREP -v '^find: '; fi; }
# findspec[-all](dir, pattern, option): find files in directory tried, optionally following links (-all)
function findspec-all () { command find $1 -follow -iname \*$2\* $3 $4 $5 $6 $7 $8 $9 -print 2>&1 | $GREP -v '^find: '; }
# TODO2: issue warning that fs filters backup and build dirs
function fs () { findspec . "$@" | $EGREP -iv '(/(backup|build)/)'; } 
## OLD: function fs-ls () { fs "$@" -exec ls -l {} \; ; }
function fs-ls () { fs "$@" -exec ls "$core_dir_options" {} \; ; }
# fs-ls-new(pattern): like fs-ls but omitting (extraneous) -print output
function fs-ls-new () { findspec . "$@" -exec ls "$core_dir_options" {} \; ; }
simple-alias-fn fs- 'findspec-all .'
## Lorenzo review: should change this to fs-alt following TODO's
function fs-ext () { find . -iname \*."$1" | $EGREP -iv '(/(backup|build)/)'; } 
# TODO: extend fs-ext to allow for basename pattern (e.g., fs-ext java ImportXML)
## OLD: function fs-ls- () { fs- "$@" -exec ls -l {} \; ; }
function fs-ls- () { fs- "$@" -exec ls "$core_dir_options" {} \; ; }
## Lorenzo review: should change this to fs-ls-alt following TODO's
#
findgrep_opts="-in"
#
# NOTE: findgrep macros use $findgrep_opts dynamically (eg, user can change $findgrep_opts)
function findgrep-verbose () { find "$1" -iname \*"$2"\* -print -exec $GREP $findgrep_opts "$3" $4 $5 $6 $7 $8 $9 \{\} \;; }
# findgrep(dir, filename_pattern, line_pattern): $GREP through files in DIR matching FILENAME_PATTERN for LINE_PATTERN
function findgrep () { find $1 -iname \*"$2"\* -exec $GREP $findgrep_opts "$3" $4 $5 $6 $7 $8 $9 \{\} /dev/null \;; }
# TODO: archive
function findgrep- () { find $1 -iname $2 -print -exec $GREP $findgrep_opts "$3" $4 $5 $6 $7 $8 $9 \{\} \;; }
## Lorenzo review: should change this to findgrep-alt following TODO's
function findgrep-ext () { local dir="$1"; local ext="$2"; shift; shift; find "$dir" -iname "*.$ext" -exec $GREP $findgrep_opts "$@" \{\}  /dev/null \;; }
# fgr(filename_pattern, line_pattern): $GREP through files matching FILENAME_PATTERN for LINE_PATTERN
# fgr-full(pattern): full findgrep from current dir for PATTERN
function fgr-full { findgrep . "$@"; }
# fgr-ext-full(extension, pattern): full findgrep for *.EXTENSION from current dir for PATTERN
function fgr-ext-full { findgrep-ext . "$@"; }
## OLD:
## function fgr () { findgrep . "$@" | $EGREP -v '((/backup)|(/build))'; }
## function fgr-ext () { findgrep-ext . "$@" | $EGREP -v '(/(backup)|(build)/)'; }
function fgr () { fgr-full | $EGREP -v '((/backup)|(/build))'; }
function fgr-ext () { findgrep-ext . "$@" | $EGREP -v '(/(backup)|(build)/)'; }
simple-alias-fn fgr-py 'fgr-ext py'
simple-alias-fn fgr-jupyter 'fgr-ext ipynb'
function fgr-py-etc () { fgr-py "$@"; fgr-jupyter "$@"; }
alias fgr-java='fgr-ext java'
#
# prepare-find-files-here([--out-dir out_dir_spec]): produces listing(s) of files in current directory
# tree, in support of find-files-here; this contains full ls entry (as with -l).
# (The subdirectory listings produced by 'ls -alR' are preceded by blank lines,
# which is required for find-files-here as explained below.)
# Notes: Also puts listing proper in ls-aR.list (i.e., just list of files).
# TODO: create external script and have alias call the script
# Ignores SC2068 [Double quote array expansions to avoid re-splitting elements]
function prepare-find-files-here () {
    local dir="."
    if [ "$1" = "--out-dir" ]; then
        dir="$2"
        shift 2;
        mkdir -p "$dir"
    fi
    if [ "$1" != "" ]; then
        echo "Error: No arguments accepted; did you mean find-files-here?"
        echo "Usage: ${FUNCNAME[0]} [--out-dir dir]"
        echo "ex: cd /; ${FUNCNAME[0]} --out-dir ~/temp/fs-index"
        return
    fi
    # Note:: uses -a to include dot files
    local brief_opts="aR"
    local full_opts="alR"
    local brief_file="$dir/ls-$brief_opts.list"
    local full_file="$dir/ls-$full_opts.list"
    local current_files=("$full_file" "$full_file.log" "$brief_file" "$brief_file.log")
    # Rename existing files with file date as suffix (TODO move into ./backup)
    # shellcheck disable=SC2068
    rename-with-file-date ${current_files[@]}

    # Perform the actual listings, putting errors in the .log file for each listing
    # Note: If root directory, filters out special directories (TODO: make optional and/or overridable).
    ## TODO: use approach based on filter variable and to avoid redundant hard-coding
    ## TODO: ** resolve intermittent problem when running under /
    if [ "$PWD" = "/" ]; then
        ($NICE $LS -$brief_opts | $EGREP -v '^\.(/(cdrom|dev|media|mnt|proc|run|sys|snap)$)' | perl -pe 's/^\./\n$&/;' > "$brief_file") 2> "$brief_file".log
        ($NICE $LS -$full_opts | $EGREP -v '^\.(/(cdrom|dev|media|mnt|proc|run|sys|snap)$)' | perl -pe 's/^\./\n$&/;' > "$full_file") 2> "$full_file".log
    else
        ($NICE $LS -$brief_opts | perl -pe 's/^\./\n$&/;' > "$brief_file") 2> "$brief_file".log
        ($NICE $LS -$full_opts | perl -pe 's/^\./\n$&/;' > "$full_file") 2> "$full_file".log
    fi;
    
    # shellcheck disable=SC2068
    $LS -lh ${current_files[@]}
}
alias prepare-find-files-there='prepare-find-files-here --out-dir'
#
# TODO: have variant of prepare-find-files that adds .mmmYY suffix to backup
#
# find-files-there(pattern, ls-alR-files): check for PATTERN in LS-ALR-FILES,
# showing the directory, which has trailing ':' in listing (i.e., DIR1:\nentry1\n...entryN\n\nDIR2:\n...)
# exs: "./archive:", "-rwxrwx--- 1 root vboxsf   19125 Dec  7  2013 morph.txt", "-rwxrwx--- 1 root vboxsf      35 Jan 17 12:19 python-notes.txt"
# Note: Perl paragraph-mode search first matches files along with the containing
# subdirectory, and then line-mode search filters out non-matching files.
#
function find-files-there () { alias-perl perlgrep.perl -para -i "$@" | $EGREP -i '((:$)|('"$1"'))' | $PAGER_NOEXIT -p "$1"; }
function find-files-here () { find-files-there "$1" "$PWD/ls-alR.list"; }
# following variants for sake of tab completion
alias find-files='find-files-here'
alias find-files-='find-files-there'
## Lorenzo review: should change this to find-files-alt following TODO's
# TODO: function find-files-dated () { alias-perl perlgrep.perl -para -i "$@" | $EGREP -i '((:$)|('$1'))' | $PAGER_NOEXIT -p "$1"; }
#
# TODO: add --quiet option to dobackup.sh (and port to bash)
# TODO: function conditional-backup() { if [ -e backup/"$1" ]; then dobackup.sh "$1"; fi; }
}         # end shellcheck block

#--------------------------------------------------------------------------------
# Emacs commands
## TOM-IDIOSYNCRATIC
#
# emacs-tpo([args] [file]...) invokes emacs w/ ~.emacs.tpo if exists otherwise ~/.emacs
# em: alias for emacs (or emacs-tpo) with dired for current directory if no file given
# em-nw: emacs with --no-windows
# TODO: add synopsis for others
#
## TODO: alias-fn emacs-tpo 'tpo-invoke-emacs.sh'
function emacs-tpo { tpo-invoke-emacs.sh "$@"; }
simple-alias-fn em tpo-invoke-emacs.sh
# em-fn(font, [file ...]): invoke emcas with specified font
function em-fn () { em -- -fn "$@"; }
alias em-tags=etags
#
## alias em-large='em-fn "-DAMA-Ubuntu Mono-normal-normal-normal-*-24-*-*-*-m-0-iso10646-1"'
## Note: Bash construct ${VAR:-VAL} use VAL if VAR not defined, and here VAL starts with -!
## TODO?: cond-export EMACS_LARGE_FONT "-DAMA-Ubuntu\\ Mono-normal-normal-normal-*-24-*-*-*-m-0-iso10646-1"
##
## HACK: uses <space> due to stupid shell tricks (see tpo-invoke-emacs.sh)
## cond-export EMACS_LARGE_FONT "-DAMA-Ubuntu<space>Mono-normal-normal-normal-*-24-*-*-*-m-0-iso10646-1"
cond-export EMACS_LARGE_FONT "-DAMA-Ubuntu Mono-normal-normal-normal-*-24-*-*-*-m-0-iso10646-1"
cond-export EMACS_OPTIONS ""
# Note: em-large-default-old not quite functional with other em-xyz aliases
function em-large-default-old { export EMACS_OPTIONS="$EMACS_OPTIONS -fn '$EMACS_LARGE_FONT'"; }
function em-large { em-fn "$EMACS_LARGE_FONT" "$@"; }
# Note: (un)set-large-emacs-font just changed the font used by tpo-invoke-emacs.sh
function set-large-emacs-font { export EMACS_FONT="$EMACS_LARGE_FONT"; }
function unset-large-emacs-font { unset EMACS_FONT; }
alias em-set-large-font=set-large-emacs-font
alias em-unset-large-font=unset-large-emacs-font
#
alias em-nw='emacs -l ~/.emacs --no-windows'
## TODO: alias em-tpo='emacs -l ~/.emacs'
alias em-tpo-nw='emacs -l ~/.emacs --no-windows'
alias em_nw='em-nw'
#
# em-file(filename): edit filename with current directory set to it's dir
# note: This avoids stupid link resolution problem under cygwin. It is
# also useful so that Emacs current directory is set appropriately.
function em-file() {
    local file="$1"
    local base
    base=$(basename "$file")
    local dir
    dir=$(dirname "$file")
    command pushd "$dir"
    em "$base"
    command popd
    }
alias em-dir=em-file
alias em-this-dir='em .'
alias em-devel='em --devel'
#
# em-debug: run emacs with debugger trapping errors (--debug-init)
# em-quick: run emacs without init files and omit splash screen (--quick)
# note: double dashes seprate tpo-invoke-emacs.sh args from emacs
function em-debug () { em -- --debug-init "$@"; }
function em-quick () { em -- --quick "$@"; }
# em-wide: invoke emacs with extra-wide window (e.g., for UHD monitor viewing two files)
# TODO2: fix order of files so first on left
function em-wide { em -- -geometry 288x50 -eval "(split-window-right)" "$@"; }

#--------------------------------------------------------------------------------
# Simple TODO-list maintenance commands
#
# add-todo(text): adds text<TAB><timestamp> to to-do list
# todo: print example of using add-todo (for cut-n-paste purposes)
# TODO: figure out way to have example copied into bash input buffer
#
# NOTE: tac is GNU reverse program ('reverse' of cat)
# TODO: document all bash aliases (and functions) for benefit of others (and yourself!)
# TODO: revert to using tac; why was reverse.perl used instead???
quiet-unalias view-todo
# TODO: track down source of following warning
# maldito shellcheck: [SC2120: ... references arguments, but none are ever passed]
# shellcheck disable=SC2120
{
function view-todo () {
    local search_arg=""
    if [ "$1" != "" ]; then search_arg="-p $1"; fi
    # note: quotes not put around search arg (as per SC2086) to avoid interpretation as file
    # shellcheck disable=SC2086
    alias-perl reverse.perl "$HOME/organizer/todo_list.text" | $PAGER_CHOPPED $search_arg; 
}
}
# maldito shellcheck: SC2119 [Use ... "$@" if function's $1 should mean script's $1]
# and SC2181 [Check exit code directly]
# shellcheck disable=SC2119,SC2181
{
    function add-todo {
        echo "$@" $'\t'"$(date)" >> "$HOME/organizer/todo_list.text" &&  view-todo;
    }
}
#
function todo-one-week () { add-todo "[within 1 week] " "$@"; }
#
function todo () { if [ "$1" == "" ]; then echo add-todo '"[within N weeks] ..."'; else todo-one-week "$@"; fi; }
function todo-sans-pager () { add-todo "$@" 2>&1 | head -1; }
#
# todo:(text): convenience alias for todo() for cut-n-paste of 'TODO: ...' notes from files
alias todo:='todo'
# TODO: enable bash case insensitivity for support of TODO and TODO: as well
# (eg, via "shopt -s nocaseglob" and "set completion-ignore-case on" in .bash_profile??
alias TODO='todo'
alias TODO:='todo'
function TODO1() { todo "$*"'!'; }
alias todo1=TODO1
#
## NOTE: stupid shellcheck chokes on the exclamation, but it is currently unused
## TODO:: function todo! () { if [ "$1" == "" ]; then todo; else todo "$@"'!'; fi; }

#
# mail-todo: version of todo that also sends email
# TODO: use lynx to submit send-to type URL
# TODO: use '$@' for '$*' (or note why not appropriate)
function mail-todo () { add-todo "$*"; echo TODO: "$*" | mail -s "TODO: $*" "${USER}@${DOMAIN_NAME}"; }
#
# Likewise for time tracking
alias view-track-time="tac \$HOME/organizer/time_tracking_list.text | \$PAGER_CHOPPED"
alias view-time-tracking=view-track-time
#
function add-track-time () { echo "$@" $'\t'"$(date)" >> "$HOME/organizer/time_tracking_list.text"; view-track-time; }
#
function track-time () { if [ "$1" == "" ]; then echo add-track-time '"..."'; else add-track-time "$@"; fi; }
alias time-tracking=track-time
alias 'track-time:'='track-time'

# Simple calculator commands
function old-calc () { echo "$@" | bc -l; }
# EX: perl-calc "2 / 4" => 0.500
function perl-calc () { alias-perl perlcalc.perl -args "$@"; }
# TODO: read up on variable expansion in function environments
function perl-calc-init () { initexpr="$1"; shift; echo "$@" | alias-perl perlcalc.perl -init="$initexpr" -; }
alias calc='perl-calc'
alias calc-prec6='perl-calc -precision=6'
alias calc-init='perl-calc-init'
alias calc-int='perl-calc -integer'
# TODO: use '$@' for '$*' (or note why not appropriate)
function old-perl-calc () { perl -e "print $*;"; }
function hex2dec { perl -e "printf '%d', 0x$1;" -e 'print "\n";'; }
function dec2hex { perl -e "printf '%x', $1;" -e 'print "\n";'; }
function bin2dec { perl -e "printf '%d', 0b$1;" -e 'print "\n";'; }
function dec2bin { perl -e "printf '%b', $1;" -e 'print "\n";'; }
## MISC: alias hv='hexview.perl'

#................................................................................
# Output postprocessing [Input too!]

# convert-emoticons(...): replace emoticons in input with description
# EX: convert-emoticons - <<<"💬" => "[speech balloon]"
alias convert-emoticons='alias-python "$(which convert_emoticons.py)"'
alias convert-emoticons-stdin='convert-emoticons -'

#-------------------------------------------------------------------------------
trace Miscellaneous commands

## MISC:
## alias startx-='startx >| startx.log 2>&1'
## alias xt='xterm.sh &'
## alias gt='gnome-terminal &'
alias hist='history $LINES'
# Removes timestamp from history (e.g., " 1972  [2014-05-02 14:34:12] dir *py" => " 1972  dir *py")
# TEST: function hist { h | perl -pe 's/^(\s*\d+\s*)(\[[^\]]+\])(.*)/$1$3/;'; }
# note: funciton used to simplify specification of quotes
quiet-unalias h
function h { hist | perl -pe 's/^(\s*\d+\s*)(\[[^\]]+\])(.*)/$1$3/;'; }
## MISC
## alias new-lynx='lynx-2.8.4'
## alias fix-keyboard='kbd_mode -a'
# EX: $ asctime | perl -pe 's/\d/N/g; s/\w+ \w+/DDD MMM/;' => "DDD MMM NN NN:NN:NN NNNN"
function asctime() { perl -e "print (scalar localtime($1));"; echo ""; }
# filter-dirnames: strip directory names from ps listing (TODO: rename as strip-dirnames)
function filter-dirnames () { perl -pe 's/\/[^ \"]+\/([^ \/\"]+)/$1/g;'; }

# comma-ize-number(): add commas to numbers in stdin
# EX: echo "1234567890" | comma-ize-number => 1,234,567,890
function comma-ize-number () { perl -pe 'while (/\d\d\d\d/) { s/(\d)(\d\d\d)([^\d])/\1,\2\3/g; } '; }
#
# apply-numeric-suffixes([once=0]): converts numbers in stdin to use K/M/G suffixes.
# Notes:
# - K, M, G and T based on powers of 1024.
# - If $once non-zero, then the substitution is only applied one-time per line.
# - The number must be occur at a word boundary.
# This was added in support of the usage function (e.g., numeric subdirectory names).
# TODO:
# - Convert to Perl script to avoid awkward bash command line construction.
# - Make the trailing context a word-boundry as well (rather than whitespace).
# EX: echo "1024 1572864 1073741824" | apply-numeric-suffixes => 1K 1.5M 1G
# EX: echo "1024 1572864 1073741824" | apply-numeric-suffixes 1 => 1K 1572864 1073741824
function apply-numeric-suffixes () {
    local just_once="${1:-0}"
    cat | alias-python -c "from mezcla.misc_utils import apply_numeric_suffixes_stdin as apply; apply(just_once=bool($just_once))"
}
#
# apply-usage-numeric-suffixes(): factors in 1k blocksize before applying numeric suffixes
# note: (?=\s) is lookahead pattern (see perlre manpage)
#
function apply-usage-numeric-suffixes() {
    perl -pe 's@^(\d+)(?=\s)@$1 * 1024@e;' | apply-numeric-suffixes 1
}
# TODO: rework so that pp version saved in file
alias usage-pp='usage | apply-usage-numeric-suffixes | $PAGER'
#
# number-columns(file): number each column in first line of tabular file
function number-columns () { head -1 "$1" | perl -0777 -pe '$c = 1; s/^/1: /; s/\t/"\t" . ++$c . ": "/eg;'; }
# TODO: s/\t/\\t/g;
function number-columns-comma () { head -1 "$1" | perl -pe 's/,/\t/g;' | number-columns -; }
# alias type='cat'  # interferes with type command
alias reverse='tac'
function backup-file () { local file="$1"; if [ -e "$file" ]; then dobackup.sh "$file"; fi; }
# default_assignment(value1, value2): return VALUE1 if defined else VALUE2
# TODO: echo $([ $1 ] && echo $1 || echo $2)
# See https://unix.stackexchange.com/questions/126706/bashs-conditional-operator-and-assignment.
function default_assignment {
    local result="$1"
    if [ "$result" = "" ]; then result="$2"; fi
    echo "$result"
}
#
## TODO: output header (e.g., "num-blocks<TAB>dir    # note: blocksize is 1k")
# usage([output_file=usage.list]): Shows usage for current directory with block size converted to bytes with
#
function usage {
    ## TODO: output_file=(("$1"||"usage.list"));
    local output_file
    output_file=$(default_assignment "$1" "usage.list")
    rename-with-file-date "$output_file";
    $NICE du --block-size=1K --one-file-system 2>&1 | $NICE sort -rn | apply-usage-numeric-suffixes > "$output_file" 2>&1;
    $PAGER "$output_file";
}
function usage-alt {
    local output_file
    local basename
    basename="$(basename "$PWD")"
    if [[ ("$basename" = "") || ("$basename" = "/") ]]; then basename="fs-root"; fi
    output_file="$TEMP/$basename-usage.list";
    usage "$output_file"
}

# byte-usage([output_file=usage.byes.list]): show "apparent size" usage of directory files in bytes
# 
## BAD:function byte-usage () { output_file="usage.bytes.list"; backup-file $output_file; $NICE du --bytes --one-file-system 2>&1 | $NICE sort -rn | apply-usage-numeric-suffixes >| $output_file 2>&1; $PAGER $output_file; }
function byte-usage () {
    local output_file
    output_file=$(default_assignment "$1" "usage.bytes.list")
    rename-with-file-date "$output_file";
    $NICE du --bytes --one-file-system 2>&1 | $NICE sort -rn | apply-numeric-suffixes 1 > "$output_file" 2>&1;
    $PAGER "$output_file";
}
## TODO: function usage () { du --one-file-system --human-readable 2>&1 | sort -rn >| usage.list 2>&1; $PAGER usage.list; }

# check-errors(LOG-FILE): check for known errors in LOG-FILE... with emoji characters changed to
# character name (e.g., "[check mark] Success" for U+2713).
# also: check-all-errors/warnings(): variants including more patterns and with warnings subsuming errors.
# HACK: quiet added to disable filename with multiple files
function check-errors-aux { alias-perl check_errors.perl "$@"; }
## # -or-:
## function check-errors-aux { PERL_SWITCH_PARSING=1 check_errors.py "$@"; };
# note: ALIAS_DEBUG_LEVEL is global for aliases and functions which should use default DEBUG_LEVEL (e.g., 2), not current (e.g., 4)
ALIAS_DEBUG_LEVEL=${ALIAS_DEBUG_LEVEL:-${DEBUG_LEVEL:-2}}
function check-errors () {
    ## NOTE: gotta dislike bash!
    local args=("$@");
    ## DEBUG: echo "args: ${args[@]}"; echo "len(args): ${#args[@]}"

    # Add - if no args or last arg is option (e.g., -warnings)
    ## BAD: if [[ ($# -eq 0) || (${args[$# - 1]} != "-") ]]; then
    if [[ ($# -eq 0) || (${args[$# - 1]} =~ ^-+) ]]; then
        ## DEBUG: echo "Adding stdin"
        args+=("-");
    fi;
    ## OLD: (DEBUG_LEVEL=$ALIAS_DEBUG_LEVEL QUIET=1 DURING_ALIAS=${DURING_ALIAS:-1} CONTEXT=5 check-errors-aux "${args[@]}") 2>&1 | DEBUG_LEVEL=$ALIAS_DEBUG_LEVEL convert-emoticons-stdin | $PAGER;
    ## TODO4: use QUIET_MODE to minimize potential env conflicts; likewise reword CONTEXT
    (DEBUG_LEVEL=$ALIAS_DEBUG_LEVEL QUIET="${QUIET:-1}" DURING_ALIAS="${DURING_ALIAS:-1}" CONTEXT="${CONTEXT:-5}" check-errors-aux "${args[@]}") 2>&1 | DEBUG_LEVEL=$ALIAS_DEBUG_LEVEL convert-emoticons-stdin | $PAGER;
}
# check-all-errors/warnings (file, ...): include more types of errors/warnings
# note: With -relaxed, the pattern matching is looser (hence more errors show)
# In addition, all following based on check-errors alias to avoid sanity check assertion
# that would occur with defining check-all-warnings in terms of check-warnings.
alias check-all-errors='check-errors -relaxed'
alias check-warnings='check-errors -warnings -strict'
## OLD: alias check-all-warnings='check-all-errors -warnings -relaxed -info'
alias check-all-warnings='check-errors -warnings -relaxed -info'
#
# check-errors-excerpt(log-file): show errors are start of log-file and at end if different
# maldito shellcheck: SC2119 [Use ... "$@" if function's $1 should mean script'1 $1]
# shellcheck disable=SC2119
{         # start shellcheck block
function check-errors-excerpt () {
    local base="$TMP/check-errors-excerpt-$$"
    local head="$base.head"
    local tail="$base.tail"
    # TODO3: add options for before and after
    check-errors -before=1 -after=2 "$@" | head | truncate-width >| "$head";
    cat "$head"
    check-errors -before=1 -after=2 "$@" | tail | truncate-width >| "$tail";
    diff "$head" "$tail" >| /dev/null
    local result="$?"
    
    # Show tail unless same as head
    # note: disables SC2181 [Check exit code directly]
    # shellcheck disable=SC2181
    if [[ $result != 0 ]]; then
        echo "\$?=$result"
        cat "$tail";
    fi
}
}         # end shellcheck block

# Note: various aliases for doing diff-based comparisons
#
function tkdiff () { wish -f "$TOM_BIN"/archive/tkdiff.tcl "$@" & }
alias rdiff='rev_vdiff.sh'
alias tkdiff-='tkdiff -noopt'
#
simple-alias-fn kdiff kdiff.sh
alias vdiff='kdiff'
#
# TOM-IDIOSYNCRATIC
#
# TODO: standardize the convention for overriding commands (e.g., following diff).
# In general, that should be avoid except for cases like 'clear' where new defaults
# led to destructive consequences (i.e., clearing scrollback buffer).
# TODO: maintain table with alias changes over time (e.g., diff- => diff-default)
#
# diff(): run diff command w/ --ignore-all-space (-w) and --ignore-space-change (-b)
#
diff_options="--ignore-space-change --ignore-blank-lines"
# maldito shellcheck: SC2034: diff_options appears unused. Verify it or export it.
# shellcheck disable=SC2034
alias diff='command diff $diff_options'
#
alias diff-default='command diff'
alias diff-ignore-spacing='diff --ignore-all-space'
#
# do-diff(): wrapper into do_diff.sh, which allows for glob patterns of current vs target dirs
alias do-diff='do_diff.bash'
#
function diff-rev () {
    local diff_program="diff"
    if [ "$1" = "--diff-prog" ]; then
        diff_program="$2"
        shift 2
    fi
    # Note: the "right" file is with respect to reversed visual diff (i.e., the first arg)
    local right_file="$1"
    local left_file="$2"
    if [ -d "$left_file" ]; then
        local old_left_file="$left_file"
        # First treat second arg as a directory to which basename of first file added
        # ex: ~/bin/file1 ~/backup => ~/bin/file1 vs. ~/backup/file1
        left_file="$left_file"/$(basename "$right_file");
        # Treat second arg as directory to which entire path of first added
        # ex: ~/bin/file1 ~/backup => ~/bin/file1 vs. ~/backup/bin/file1
        if [ ! -e "$left_file" ]; then
            left_file="$old_left_file/$right_file"
        fi
    fi
    # TODO: create helper for resolving one file relative to dir of another
    ## BAD: if [ ! -e "$left_file" ]; then left_file=$(dirname "$right_file")/"$left_file"; fi
    "$diff_program" "$left_file" "$right_file"
}
alias kdiff-rev='diff-rev --diff-prog kdiff'
alias diff-log-output='compare-log-output.sh'
alias vdiff-rev=kdiff-rev

# most-recent-backup(file): returns most recent backup for FILE in ./backup, accounting for revisions (e.g., extract_matches.perl.~4~)
# note: now uses backup dir relative to file if a path
function most-recent-backup {
    if [ "$1" = "" ]; then
        echo "usage: most-recent-backup filename"
        echo "use BACKUP_SUBDIR=dir ... to override use of ./backup"
        return
    fi
    ## TODO4: file => file_basename
    local file="$1";
    local dir="$BACKUP_SUBDIR"; if [ "$dir" = "" ]; then dir=./backup; fi
    local file_dir
    file_dir="$(dirname "$file")"
    if [ "." != "$file_dir" ]; then
        file="$(basename "$file")"
        dir="$file_dir/$dir"
    fi
    ## OLD: ## TODO: rework to avoid false positives
    ## BAD: $LS -t "$dir"/* "$dir"/.* | $EGREP "/$file(~|.~*)?" | head -1;
    ## OLD: $LS -t "$dir"/* "$dir"/.* | $EGREP "/$file(~|.~.*)?$" | head -1;
    ## TODO2: Let the shell include dotfiles (e.g., via temporary 'shopt -s dotglob nullglob')
    ## NOTE: See TODO.txt entry for 21 Apr 26
    $LS -t "$dir"/* "$dir"/.* 2> /dev/null | $EGREP "/$file(~|.~.*)?$" | head -1;
}
# TODO: test for dot-files:
#   touch backup .fubar.~666~; most-recent-backup .fubar => .fubar
#
# diff-backup(diff_command, file, [diff_arg ...]): compare FILE vs. most recent backup, using DIFF_PROGRAM and optional DIFF_ARGs
## OLD: # TODO: fix handling of dot files
function diff-backup-helper {
    local diff="$1"; local file="$2";
    shift 2;
    local backup_file
    backup_file="$(most-recent-backup "$file")"
    if [ "$backup_file" = "" ]; then
        echo "Error: no backup for '$file'"
    else 
        echo "Issuing: '$diff' ""$*"" '$backup_file' '$file'"
        "$diff" "$@" "$backup_file" "$file";
    fi
}
## TODO:
## alias-fn diff-backup 'diff-backup-helper diff "$@"'
## alias-fn kdiff-backup 'diff-backup-helper kdiff "$@"'
function diff-backup { diff-backup-helper diff "$@"; }
function kdiff-backup { diff-backup-helper kdiff "$@"; }

# signature(prefix): show ~/info/<prefix>-signature
# See
#     ^^^ TODO: what?
function signature () {
    if [ "$1" = "" ]; then
        $LS "$HOME/info/.$1-signature"
        echo "Usage: signature dotfile-prefix"
        echo "ex: signature scrappycito"
        return;
    fi
    ## TODO: echo filename and then cat??
    local filename="$HOME/info/.$1-signature"
    echo "$filename:"
    cat "$filename"
}

#-------------------------------------------------------------------------------
trace file archiving commands

# Tar archive creation and manipulation
# tar options:
# -x extract; -v verbose; -f file source; -z compressed; -k don't overwrite files
## NOTE: gtar is used on some BSD-based system (e.g., MacOS), but tar is used on Linux.
GTAR="tar"
if [ "$(which gtar)" != "" ]; then
    GTAR="gtar"
fi
if [[ ! $($GTAR --version) =~ GNU ]]; then
    echo "Warning: GNU tar not available" 1>&2
fi
## TODO2: simple-alias-fn gtar '$GTAR'
function gtar { $GTAR; }
#
# ls-relative(file): show pathname of FILE relative to $HOME (e.g., ~/xfer/do_setup.bash)
function ls-relative () { $LS -d "$1" | perl -pe "s@$HOME@~@;"; }
#
# make-tar(archive_basename, [dir=.], [depth=max], [filter=pattern]): tar up directory with results placed 
# in archive_base.tar.gz and log file in archive_base.tar.log; afterwards display the tar archive size, log contents, and archive path.
# Filenames matching the optional (exclusion) filter regex are excluded.
# EX: make-tar ~/xfer/program-files-structure 'C:\Program Files' 1
#
# TODO1: liberate me (e.g., put main support into script)!
# Note: -xdev is so that find doesn't use other file systems
# - depth and filter args can be given via TAR_DEPTH and TAR_FILTER
find_options="-xdev"
function make-tar () {
    # Warning: if no optional arguments are given, find and filtering will be skipped to preserve empty folders
    #          Otherwise if optional args are present, empty dirs will be excluded from final tar
    # Check arguments
    local base="$1"; local dir="$2";
    if [[ ("$base" == "--help") ||("$base" == "") ]]; then
        echo "Usage: make-tar base dir [depth [filter]]"
        echo "Env. options: USE_DATE, TEMP, GTAR, MAX_SIZE, TAR_DEPTH, TAR_FILTER, AFFIX"
        echo "note: TEMP used by tar-dir, etc.; Also see [un]set-tar-bzip2 and [un]set-tar-xz"
        echo "(or try GTAR_OPTS='vfJ' [... tor-browser-linux-x86_64-14.5.tar.xz])."
        echo $'example:\n\t'"TEMP='$BACKUP_DIR' tar-this-dir-dated"
        return
    fi
    ## TODO2: dispense with acrobatic arg parsing!
    local depth="${3:-${TAR_DEPTH:-""}}";
    local filter="${4:-${TAR_FILTER:-""}}"
    local affix="${AFFIX:-""}"
    if [ "$affix" != "" ]; then base="$base-$affix"; fi

    # Derive find/tar command line options
    local filter_arg=(.)
    local depth_arg=""
    local size_arg="";
    if [ "$dir" = "" ]; then dir="."; fi;
    if [ "$depth" != "" ]; then depth_arg="-maxdepth $depth"; fi;
    if [ "$filter" != "" ]; then filter_arg=(-v "$filter"); fi;
    global USE_DATE
    if [ "$USE_DATE" = "1" ]; then
        base="$base-$(TODAY)";
        ## TEST: rename-with-file-date "$base"*
        for f in "$base".tar.{gz,log}; do
            if [ -e "$f" ]; then
                move "$f" "$(get-free-filename "$f" "-")";
            fi;
        done
    fi
    global MAX_SIZE
    if [ "$MAX_SIZE" != "" ]; then size_arg="-size -${MAX_SIZE}c"; fi

    # Invoke find/tar
    # TODO: make pos-tar ls optional, so that tar-in-progress is viewable
    # shellcheck disable=SC2086
    if [ "${depth_arg}${size_arg}${filter_arg[*]}" == "." ]; then
        $NICE $GTAR cvfz "$base.tar.gz" "$dir" >| "$base.tar.log" 2>&1;
    else
        (find "$dir" $find_options $depth_arg $size_arg -not -type d -print | $EGREP -i "${filter_arg[@]}" | $NICE $GTAR cvfTz "$base.tar.gz" -) >| "$base.tar.log" 2>&1;
    fi
    ## DUH: -L added to support tar-this-dir in directory that is symbolic link, but unfortunately
    ## that leads to symbolic links in the directory itself to be included
    ## BAD: (find -L "$dir" $find_options $depth_arg -not -type d -print | egrep -i "$filter_arg" | $NICE $GTAR cvfTz "$base.tar.gz" -) >| "$base.tar.log" 2>&1;

    # Show info on resulting files (TODO2: check-errors over log)
    ($LS -l "$base.tar.gz"; cat "$base.tar.log") 2>&1 | $PAGER; 
    ls-full "$base.tar.gz";
    ls-relative "$base.tar.gz"; 
}
# TODO: handle filenames with embedded spaces
#
# tar-dir(dir, depth, [filter]): create archive of DIR in ~/xfer, using subdirectories up to DEPTH, and optionally 
# filtering files matching exclusion filter.
#
function tar-dir () {
    check_usage "$1" $'usage: tar-dir dir [depth]\nnote: see make-tar for more"' && return
    # Warning: see behaviour with optional arguments and subdirs in make-tar
    ## TODO 2: add support for optional filtering 
    local dir="$1"; local depth="$2";
    local archive_base
    archive_base="$TEMP"/$(basename "$dir")
    make-tar "$archive_base" "$dir" "$depth" 
}
## TODO: fix indentation for tar-dir and other aliases (make sure 4 spaces used); also, make sure no tabs used as w/ tar-dir above
##
## TEST: take 1 of fix tar-just-dir involving symbolic links
## function new-tar-dir () {
##    local dir="$1"
##    local depth="$2"
##    local actual_full_dir_path=$(realpath "$dir")
##    local archive_base=$TEMP/$(basename "$dir")
##    make-tar "$archive_base" "$actual_full_dir_path" $depth
## }
##

# Note: will exclude folders based on make-tar behaviour with specified depth 
function tar-just-dir () { tar-dir "$1" 1; }
#
# tar-this-dir(): create tar archive into TEMP, for sud-directory tree routed
# in current directory (using directory basename as file prefix instead of .)
# ex: TEMP=/mnt/my-external-drive/tmp tar-this-dir
# Note: will include empty folders in dir given the unspecified optional parameters, see make-tar
function tar-this-dir () { local dir="$PWD"; pushd-q ..; tar-dir "$(basename "$dir")"; popd-q; }
# test of resolving problem with tar-this-dir if dir a symbolic link from apparent parent
# TODO: fixme
function new-tar-this-dir () {
    ## TODO: fix un-initialized base variable
    # example dir change: /home/tomohara/tpo-magro-p3 [=> /media/tomohara/ff3410d4-5ffc-4c01-a2ca-75244b882aa2]
    local dir
    dir=$(basename "$PWD"); 
    # Go to parent dir                        /home/tomohara
    pushd-q ..
    # Get real basename                       ff3410d4-5ffc-4c01-a2ca-75244b882aa2
    local real_base="$base"
    if [ -L "$base" ]; then
        real_base=$($LS -ld "$base" | perl -pe 's@^.* -> (.*/)?([^/]+)@$2@;');
        # Go to real parent                   /media/tomohara
        cd "$(realpath "$dir"/..)"
    fi
    # Create tar of real subdir
    # TODO: pass along actual basename so that tar file can be renamed
    tar-dir "$real_base";
    popd-q;
}
#
# tar-this-dir-normal: creates archive of directory, excluding archive, backup, and temp subdirectories

## Lorenzo: tar-this-dir-normal and tar-just-this-dir can be expressend in terms of a helper function like
## function helper() {local dir="$PWD"; pushd-q ..; tar-dir "$(basename "$dir")" $1 $2; popd-q; }
## alias tar-this-dir-normal=helper "" "/(archive|backup|temp)/"
## alias tar-just-this-dir=helper "1" ""
function tar-this-dir-normal () { local dir="$PWD"; pushd-q ..; tar-dir "$(basename "$dir")" "" "/(archive|backup|temp)/"; popd-q; }
## TODO2: fix so tar-dir takes the filter arguments

function tar-just-this-dir () { local dir="$PWD"; pushd-q ..; tar-dir "$(basename "$dir")" 1; popd-q; }
# GTAR_OPTS: usual options for aliases using gnu tar
GTAR_OPTS=""
## TODO2: GTAR_USUAL="$GTAR GTAR_OPTS"
function set-tar-bzip2 () { GTAR_OPTS="vfj"; }
function unset-tar-bzip2 () { reset-tar-opts; }
function set-tar-xz () { GTAR_OPTS="vfJ"; }
function reset-tar-opts { GTAR_OPTS="vfz"; }
function make-recent-tar () { (find . -type f -mtime -"$2" | $GTAR "c${GTAR_OPTS}T" "$1" -; ) 2>&1 | $PAGER; ls-relative "$1"; }
reset-tar-opts
#
# " (for Emacs)
# NOTE: above quote needed to correct for Emacs color coding
# TODO: rework basename extraction
#
function view-tar () { $GTAR "t${GTAR_OPTS}" "$@" 2>&1 | $PAGER; }
function extract-tar () { $NICE $GTAR "x${GTAR_OPTS}k" "$@" 2>&1 | $PAGER; }
function extract-tar-force () { $NICE $GTAR "x${GTAR_OPTS}" "$@" 2>&1 | $PAGER; }
function extract-tar-here () { pushd ..; $NICE $GTAR "x${GTAR_OPTS}k" "$@" 2>&1 | $PAGER; popd; }
alias untar='extract-tar'
alias untar-here='extract-tar-here'
alias un-tar=untar
alias untar-force='extract-tar-force'
alias create-tar='make-tar-with-subdirs'
alias make-full-tar='make-tar'
# TODO: handle filenames with embedded spaces
alias recent-tar-this-dir='make-recent-tar $TEMP/recent-$(basename "$PWD")'
function sort-tar-archive() { ($GTAR "t${GTAR_OPTS}" "$@" | sort --key=3 -rn) 2>&1 | $PAGER; }
#
# TODO: tar-this-dir-there???
# ex: $ TEMP=/mnt/wd6tbp2vfat/backup/tpo-servidor tar-this-dir
#
alias tar-this-dir-dated='USE_DATE=1 tar-this-dir'
alias tar-just-this-dir-dated='USE_DATE=1 tar-just-this-dir'

#.......................................

#
# command-to-pager(command, arg1, ...): helper function for use in aliases: sends command output to $PAGER (e.g., less)
function command-to-pager { "$@" | $PAGER; } 
alias view-zip='command-to-pager unzip -v'
alias un-zip='command-to-pager unzip'

alias color-xterm='rxvt&'

alias count-it='alias-perl count_it.perl'
alias count_it=count-it
# count-tokens: count occurrences of space-delimited tokens in input
function count-tokens () { count-it "\S+" "$@"; }
# count-line-text: count occurences of lines excluding newline or return
# TODO: rework via chomp; TODO2: fix stupid problems viewing under MacOS
function count-line-text () { count-it '^([^\n\r]*)[\n\r]*$' "$@"; }
alias extract-matches='alias-perl extract_matches.perl'
# EX: echo $'1 one\n2 two\n3' | perlgrep 'o\w' => "1 one"
alias perlgrep='alias-perl perlgrep.perl'
alias perl-grep=perlgrep
function para-grep { perlgrep -para "$@" 2>&1 | $GREP -v "Can't open \*notes\*"; }
alias para-gr='para-grep -i -n'

#................................................................................
# Note grepping (e.g., using timestamp sorted excerpts)
# TOM-IDIOSYNCRATIC

## TODO: make a pass to ensure aliases have unique leading prefix, as well as being easy to remember (n.b., ease of tab completion vs. recall)
function cached-notes-para-gr { para-gr "$@" _master-note-info.list | $PAGER; }
# TODO: work out better name
function cached-notes-para-gr-less { cached-notes-para-gr "$@" | less-pattern "$1"; }
##
notes_glob="*notes*.txt  *notes*.list *notes*.log"
# shellcheck disable=SC2086
{
function notes-grep() { perlgrep "$@" $notes_glob; }
#
# aliases for grepping through notes files and archiving non-note log files 
function para-notes-gr { perlgrep -para -i "$@" $notes_glob 2>&1 | $GREP -v "Can't open \*notes\*" | $PAGER; }
# TODO: use xyz-grl in analogy with grepl alias (n.b., uses $PAGER)
function para-notes-gr-less-p { para-notes-gr "$@" | less-pattern "$1"; }
# notes-entry-gr(): treat text with -----'s as single unit for searching
# notes-entry-gr-aux(glob, pattern): search for PATTERN in GLOB
function notes-entry-gr-aux() {
    if [[ "$2" == "" ]]; then
        echo "Usage: [HEURISTIC_NOTE_GREP=B] notes-entry-gr-aux file_glob pattern"
        echo ""
        return
    fi
    if [[ "${HEURISTIC_NOTE_GREP:-0}" == "1" ]]; then
        heuristic-notes-entry-gr-aux "$@";
        return
    fi
    local glob="$1"
    shift
    # note: convert consecutive newlines within dashed lines to <ln><sp><ln> so inside Perl "paragraph"
    perl -00 -pe 's/\n\n/\n \n/g; s/^\-{40}/\n$&/g;' $glob 2>&1 | perlgrep -para -i "$@" - 2>&1 | convert-emoticons-stdin | less-pattern "$1";
}
# heuristic-notes-entry-gr-aux(glob, regex): filters by terms in regex prior to notes-entry-gr-aux,
# converting highlighting regex into alternative rather than sequence (e.g., "dog.*cat" => "dog|cat").
# note: used with multiple operators over large notes files (abc.*pdq.*xyz) and also allows
# for AND-style entry matching.
function heuristic-notes-entry-gr-aux() {
    local note_files="$1"
    shift
    local regex="$*"
    # Filter by search terms joined by regex operators
    local temp_base="$TMP/_heuristic-notes-entry-gr-aux"
    local term_num=0
    # note: preprocesses to make Perl "paragraphs" be based on dash-line headers
    perl -00 -pe 's/\n\n/\n \n/g; s/^\-{40}/\n$&/g;' $note_files >| "$temp_base.$term_num"
    note_files="$temp_base.$term_num"
    for term in $(echo "$regex" | perl -pe 's/(\.\*)/ /g;'); do
        (( term_num++ ))
        perlgrep -para -i "$term" $note_files >| "$temp_base.$term_num"
        note_files="$temp_base.$term_num"
    done
    # Apply overall regex with | used for alternatives
    regex=$(echo "$regex" | perl -pe "s/ |(\.\*)/\|/g;")
    perlgrep -para -i "$regex" $note_files 2>&1 | convert-emoticons-stdin | less-pattern "$regex";
    ## TEST: for sake of less pattern highlighting', converts newlines to returns
    ## perlgrep -para -i "$regex" $note_files 2>&1 | convert-emoticons-stdin | perl -pe 's/\n(.)/\r$1/g;' | less-pattern "$regex";
    
}
}   ## end shellcheck
##
alias notes-entry-gr='notes-entry-gr-aux "$notes_glob"'
function notes-entry-gr-less-p { notes-entry-gr "$@" 2>&1 | less-pattern "$1"; }
alias entry-notes=notes-entry-gr
alias cached-entry-gr='notes-entry-gr-aux _master-note-info.list'
function cached-entry-gr-less-p { cached-entry-gr "$@" 2>&1 | less-pattern "$1"; }
# TODO: * work good scheme for shortcut aliases (e.g. both memorable and easily tab-completable)!
alias grepl-entry=cached-entry-gr-less-p
alias grepl-entry-here=entry-notes

#................................................................................

# TODO: use .list instead of .log in note files to minimize need for such an awkward move alias/function (n.b., .log files more common due to script usage than .list)
#
function prep-brill() { alias-perl prep_brill.perl "$1" > "$1".pp; }

# Specialized file viewers
# TODO: put image viewer here
function pdf-view () { okular "$@" & }
function image-view () { gpicview "$@" & }

# File conversion

# pdf-to-ascii(filename, [verbose=0], [options=""]): convert basename.pdf to basename.ascii
# TOM-IDIOSYNCRATIC
# notes:
# - The -layout option is default to make output match PDF layout
# - Any existing file is not overwritten.
# - When ps2ascii command hangs up, it creates large output files (e.g., > 1gb)
#   so timeout included.
# NOTE: pass in space for options to disable default of -layout
# TODO: handle filename with ... (e.g., special punctuation)???
function pdf-to-ascii () {
    if [ "$1" = "" ]; then
        echo "usage: pdf-to-ascii file [verbose=0] [options='-layout']"
        ## OLD: echo "note: use ' ' for options to use default"
        echo "note: use ' ' for options to use default (e.g., single column)"
        echo "ex: pdf-to-ascii zhang-skillspan-naccl2022.pdf 1 ' '"
        return
    fi
    local file="$1"
    local verbose="$2";
    local options="$3"
    if [ "$options" = "" ]; then options="-layout"; fi
    local target
    target=$(basename "$1" .pdf)".ascii";
    if [ ! -s "$target" ]; then
        if [ "$verbose" = "1" ]; then
            echo "creating $target w/ options '$options'";
        fi
        # quiet shellcheck on quoting args
        # shellcheck disable=SC2046,SC2086
        cmd.sh --time-out 30 pdftotext $options "$file" "$target";
    else
        echo "FYI: skipping existing $target"
    fi
    $LS -lt "$target"
}
function all-pdf-to-ascii () { for f in *.pdf; do pdf-to-ascii "$f"; done; }

# Specialized file editors
## TODO3: fix comment header [editors???]
#
# run-app(path, [arg, ...]): run app in background saving log to TEMP/basename-date.log
function run-app {
    if [[ ("$1" == "") || (("$1" == "--help")) ]]; then
        echo "usage: run-app ..."
        echo "note: set VERBOSE=1 for log exceprt"
        echo "ex: VERBOSE=1 run-app libreoffice -n ~/Templates/Letter-Portrait-Halfinch.ott"
        return
    fi
    local path="$1";
    local app
    app=$(basename "$path");
    shift;
    local log
    log=$TEMP/"$app-$(TODAY).log"
    if [ -e "$log" ]; then
        echo "FYI: Updating $app's log '$log'"
        python -c 'print("-" * 80)' >> "$log"
    fi
    local verbose=$(is-true "VERBOSE");

    # Format header with timestamp
    ## TODO2: add new alias for timestamp with hour
    local date_yyyy_mm_dd_hhmm="$(date '+%Y-%m-%d %H:%M')"
    echo "$date_yyyy_mm_dd_hhmm"$'\n' >> "$log"
    echo "$path" "$@" >> "$log" 2>&1 &
    
    # Invoke and trace log excerpt
    "$path" "$@" >> "$log" 2>&1 &
    ## TODO: make sure command invoked OK and then put into background
    local delay=5
    ## OLD: sleep-for "$delay" "waiting ${delay}s for $log"
    sleep-for "$delay" "waiting for log"
    check-errors-excerpt "$log"
    $verbose && tail "$log" | truncate-width
}
alias foxit='run-app /opt/foxitsoftware/foxitreader/FoxitReader'
alias gimp='run-app gimp'

#------------------------------------------------------------------------

# Resets terminal window size (LINES and COLUMNS)
## MISC???:
alias do-resize='resize >| $TEMP/resize.sh; conditional-source $TEMP/resize.sh'

#-------------------------------------------------------------------------------
trace alias/function info

# Displaying bash aliases and functions
# note: '.' used in grep to handle special case of no pattern;
# TODO: use '$@' for '$*' (or note why not appropriate)
#
# note: adds newline after '}' to support paragraph grep
alias show-functions-aux='typeset -f | perl -pe "s/^}/}\n/;"'
#
# show-all-macros(pattern): show aliases or functions matching PATTERN, including definition
# TODO: allow for specifying word-boundary matching
function show-all-macros () {
    local pattern="$*";
    if [ "$pattern" = "" ]; then pattern=.; fi;
    alias | $GREP -i "$pattern" | perl -ne 'print("$_\n");';
    show-functions-aux | perlgrep -i -para "$pattern";
}

# show-macros([pattern]): like show-all-macros, excluding leading _ in name
function show-macros () { show-all-macros "$*" | perlgrep -v -para "^_"; }
#
# show-macros-proper([pattern]): shows names of aliases/functions matching PATTERN
function show-macros-proper-old { show-macros "$@" | $EGREP "^\w"; }
function show-macros-proper {
    local pattern="${*:-.}"
    # note: first filters by likely alias or function definititions
    # ex: "alias move='mv'", "setenv () {\n    export "$1"="$2"\n}"
    show-macros "$pattern" | $EGREP '(^alias)|( \(\) $)' | perl -pe 's/alias ([^=]+)=.*/\1/;  s/^(\S+) \(\)/\1/;' | $EGREP "$pattern" | sort;
}
# display-macros(pattern): show definition(s) of alias or function matching pattern in name
function display-macros {
    show-macros "$@" | perlgrep -para ^"(alias )?""$*";
}
alias show-macros-specific=display-macros
#
# show-variables(): show defined variables
# TODO: figure out how to exclude env. vars from show-variables output
function show-variables () { set | $GREP -i '^[a-z].*='; }

## MISC: function show-macros-by-word () { pattern="\b$*\b"; if [ "$pattern" = "" ]; then pattern=.; fi; alias | $GREP $pattern ; show-functions-aux | perlgrep -para $pattern; }
alias show-aliases='alias | $PAGER'
# TODO: see if other aliases were "recursively" defined
alias show-functions='show-functions-aux | $PAGER'
function show-functions-proper { show-functions | extract-matches "^(\S+) \(" | $PAGER; }
# TODO: *** see if way to make bash automatically use less-like pager: too complicated to have to account in specific command aliases/functions
# TODO??: override 'function' to allow for showing bindings as with 'alias'
## function function { if ["$2" = "" ]; then show-functions "$1"; else builtin function "$@"
# NOTE: probably not possible for syntax reasons (e.g., braces)

#-------------------------------------------------------------------------------
trace setup and sorting wrappers

# Editing and activating new settings
#
alias do-setup='conditional-source $HOME/.bashrc'

# Sorting wrappers
#
alias tab-sort="sort -t $'\t'"
alias old-colon-sort="sort \$SORT_COL2 -t ':'"
alias colon-sort="sort -t ':'"
alias colon-sort-rev-num='colon-sort -rn'
alias freq-sort='tab-sort -rn $SORT_COL2'
alias comma-sort="sort -t ','"
#
# para-sort: sort paragraphs alphabetically
function para-sort() { perl -00 -e '@paras=(); while (<>) {push(@paras, $_);} print(join("\n", sort @paras));' "$@"; }
#
# echoize: output stdin (e.g., command output) on single line, as if echo $(command)
## BAD: alias echoize="perl -pe 's/\n(.)/ $1/;'"
## TODO: alias echoize="perl -pe 's/\n(.)/ \$1/;'"
function echoize { perl -0777 -pe 's/\n/ /g;  s/\s/ /g;  s/$/\n/;'; }

#-------------------------------------------------------------------------------
trace file manipulation and conversions

## TODO: make obsolete
function asc-it () { dobackup.sh "$1"; asc < backup/"$1" >| "$1"; } 
# TODO: use dos2unix under CygWin
alias remove-cr='tr -d "\r"'
alias perl-slurp='perl -0777'
alias alt-remove-cr='perl-slurp -pe "s/\r//g;"'
## TODO: make obsolete
function remove-cr-and-backup () { dobackup.sh "$1"; remove-cr < backup/"$1" >| "$1"; }
alias perl-remove-cr='perl -i.bak -pn -e "s/\r//;"'

# Text manipulation
alias 'intersection=intersection.perl'
alias 'difference=intersection.perl -diff'
alias 'line-intersection=intersection.perl -line'
alias 'line-difference=intersection.perl -diff -line'
function show-line () { tail --lines=+"$1" "$2" | head -1; }
#
# last-n-with-header(num, file): create sub-file with last NUM lines plus header from FILE
function last-n-with-header () { head --lines=1 "$2"; tail --lines="$1" "$2"; }

#-------------------------------------------------------------------------------
trace line/word count, etc. commands

# line-wc; alias for counting words on individual lines thoughout a file
# (Gotta hate csh)
function line-wc () { perl -n -e '@_ = split; printf("%d\t%s", 1 + $#_, $_);' "$@"; }
alias line-word-len='line-wc'
# 
function line-len () { perl -ne 'printf("%d\t%s", length($_) - 1, $_);' "$@"; }
function para-len () { perl -00 -ne 'printf("%d\t%s", length($_) - 1, $_);' "$@"; }
alias ls-line-len='$LS | line-len | sort -rn | less'

function check-class-dist () { count-it "^(\S+)\t" "$1" | perl- calc_entropy.perl -; }

alias 2bib='bibitem2bib'

#-------------------------------------------------------------------------------
trace extension-less shortcuts
## TODO: say what???!!! (i.e., wrt extension-less)

# TODO: generate aliases for .sh and .perl scripts automatically
# ls *.sh *.perl | perl -pe "s/(\w+)\.\w+/alias \1='$&'/g; s/(\w+.perl)/perl- \1/g;" >| _all_alias.list
alias convert-termstrings='perl- convert_termstrings.perl'
alias do-rcsdiff='do_rcsdiff.sh'
alias dobackup='dobackup.sh'
alias kill-em='kill_em.bash'
alias kill-it='kill-em --pattern'
# ps-mine: wrapper around ps_mine.sh w/ filtering (e.g., defunct)
alias ps-mine='ps_mine.bash --filtered'
# NOTE: see filter-dirnames added to strip directory names
# TODO: rename as ps-mine-sans-dirs
## BAD: alias ps-mine-='ps-mine "$@" | filter-dirnames'
## TODO3: deprecate cryptic aliases like ps-mine-
# ps-mine-sans-dir(): run ps-mine and string directories
function ps-mine-sans-dir { ps-mine "$@" | filter-dirnames; }
# ps-users(): exclude root user from ps-mine
function ps-users { ps_mine.sh -a | $GREP -v ^root; }
deprecated-alias-fn ps-mine- ps-mine-sans-dir
alias ps_mine='ps-mine'
## DUP: alias ps-mine-='ps-mine "$@" | filter-dirnames'
alias ps-mine-all='ps-mine --all'
alias rename-files='alias-perl rename_files.perl'
alias rename_files='rename-files'
alias foreach='alias-perl foreach.perl'

#--------------------------------------------------------------------------------
# Adhoc aliases for renaming aliases
## TOM-IDIOSYNCRATIC

# rename-spaces: replace spaces in filenames of current dir with underscores
alias-fn rename-spaces 'rename-files -q -global -rename_old " " "_"'
# TODO2: handle smart quotes
function rename-quotes {
    rename-files -q -global -rename_old "\"" "_";
    rename-files -q -global -rename_old "'" "_";
}

# rename-special-punct: replace runs of any troublesome punctuation in filename w/ _
function rename-special-punct {
    # strip ascii punctuation
    # TODO: rename-files -q -global -regex "_*[&\!\*?\(\)\[\]]" "_";
    rename-files -q -global -rename_old -regex "_*[&\!\*?\(\)\[\]\,\;\:]" "_";

    # Rename leading dash with underscore (n.b., problem for ls command)
    rename-files - _ -*
    
    # strip unicode punctuation, ignoring shellcheck warnings like SC1112 [This is a unicode quote]
    # shellcheck disable=SC1111,SC1112,SC2206,SC2116
    {
        local unicode_punct="—·®“”″‶‘’– "
        ## TODO:
        ## local unicode_filenames=(*[$unicode_punct]*)
        ## if [ ${#unicode_filenames[@]} -eq 0 ]; then
        if [ "" = "$(ls ./*[$unicode_punct]* 2> /dev/null)" ]; then
            ## DEBUG: echo "No files with following unicode punctuation: $unicode_punct"
            return
        fi
        # note: unicode chars: U+0183 (·) U+174 (®) U+8220 (“) U+8221 (”) U+8243 (″) U+8246 (‶) U+8211 (–) U+8216 (‘) U+8217 (’) U+2014 (—) U+202f ( )
        # note: U+202f is narrow no-break space
        ## TODO: rename-files -q -global -rename_old -regex "_*[—·®“”″‶‘’–]" "_";   # note: all unicode
        local char;
        for char in "—" "·" "®" "“" "”" "″" "‶" "‘" "’" "–" " "; do        # note: all unicode
            rename-files -global -rename_old "$char" "_" ./*$char*
            ## TODO?: rename-files -global -rename_old "$char" "_" "${unicode_filenames[@]}"
        done;
        rename-files -q -global -rename_old -regex "__+" "_"; 
    }
}
# TODO: test
#     $ touch '_what-the-hell?!'; rename-special-punct; ls _what* => _what-the-hell_
## TODO:
## alias rename-spaces='rename-files -rename_old -q -global " " "_"'
## alias rename-quotes='rename-files -rename_old -q -global "'"'"'" ""'   # where "'"'"'" is concatenated dou[???]
# move-duplicates: move duplicate produced via Firefox downloads
# ex: move "05-158-a-20 (1).pdf duplicates
alias move-duplicates='mkdir -p duplicates; move *\([0-9]\).* duplicates 2>&1 | $GREP -iv cannot.stat.*..No.such'
# TODO: rename existing files with file date (instead of blocking rename)
alias rename-parens='rename-files -global -regex "[\(\)]" "" *[\(\)]*'
alias rename-etc='rename-spaces; rename-quotes; rename-special-punct; move-duplicates'
## TODO: alias rename-parens='rename-files -rename_old -global -regex "[\(\)]" "" *[\(\)]*'
#
# rename-utf8-encoded: replace runs of non-ascii UTF8 encodings with _
# note: '👇🏻' gets encoded as [???]; see show-unicode-code-info alias to way to illustrate encodings
# ASIDE: This seems much ado about nothing, but this is a minor accessibility issue for TPO;
# Specifically, he is sensitive to bright icons, especially if tacky!
alias rename-utf8-encoded-sledgehammer='rename-files -quick -global -regex "[\x80-\xFF]{1,4}" "_"'
# via https://en.wikipedia.org/wiki/UTF-8:
#    U+10000    U+10FFFF        11110xxx        10xxxxxx        10xxxxxx        10xxxxxx;   note: F[8-F]{3}
# rename-emoji: replace emoji characters in filenames with _'s (e.g., U+10000+ chars and U+26nn)
# note: emoji considered synonymous with emoticon
alias rename-utf8-emoji='rename-files -quick -global -regex "[\xF0-\xFF][\x80-\xFF]{1,3}" "_"' 
## TODO2 (handle cases like U+2728 [sparkle] w/ UTF8 0xE29CA8):
#    alias rename-utf8-emoji-misc='rename-files -quick -global -regex "[\xE0-\xFF][\x80-\xFF]{2,3}" "_"'
# note: check specifically for code blocks: U+26D3 [chains] is e29b93; U+1F917 [hugging face] is f09fa497
## Lorenzo review: same as OLD above
alias rename-emoji-old='rename-files -quick -global -regex "(\xE2[\x80-\xFF]{2})|(\xF0[\x80-\xFF]{3})" "_"'
# rename-emoji-aux: renames eomji in filenames with ascii descriptions
# note: if STRIP_EMOTICONS then uses REPLACEMENT_TEXT (see mezcla's convert_emoticons.py)
function rename-emoji-aux {
    # ex: "LangChain_🦜⛓️_-_Zep" => "LangChain_parrot_chains_-_Zep"
    local f new_f
    for f in "$@"; do
        ## TODO3: drop variation selectors (U+FE0F)
        new_f=$(echo "$f" | convert-emoticons-stdin | perl -pe 's/[\[\]]/_/g; s/__+/_/g;')
        rename-files "$f" "$new_f" "$f"
    done
}
# rename-emoji-verbose: replace emoji characters in filenames with brief char description (e.g., smiley-face)
simple-alias-fn rename-emoji-verbose rename-emoji-aux

simple-alias-fn rename-emoji 'STRIP_EMOTICONS=1 REPLACEMENT_TEXT=_ rename-emoji-aux'
# rename-emoji-here: rename files in current directory with emoji
function rename-emoji-here {
    # note: ensures no spaces and then filters files by potential emoticons before slow rename-emoji step proper
    # See https://stackoverflow.com/questions/39536390/match-unicode-emoji-in-python-regex.
    rename-spaces;
    local files;
    # Note: Disables shellcheck warning SC2207: Prefer mapfile or read -a to split command output (or quote to avoid splitting).
    # shellcheck disable=SC2207
    files=($(find . -maxdepth 1 | INPUT_ERROR=ignore  DURING_ALIAS=${DURING_ALIAS:-1} alias-python -m mezcla.simple_main_example --regex '[\u2000-\U0001FFFF]' -));
    rename-emoji "${files[@]}"
}

# rename-bad-dashes: replace " -" in filename with "_" and replace leadind dash with underscore
alias rename-bad-dashes="rename-files -quick -global -regex ' \-' '_'; rename-files -quick -global -regex '\-' '_' -*"; 

#-------------------------------------------------------------------------------
## TOM-IDIOSYNCRATIC

# move-versioned-files(pattern, dir): move files matching PATTERN into DIR (created if need be)
# move "versioned" log files into ./log-file subdirectory
#    *** files end in .log[0-9]+ or .log and have numeric affix (e.g., do-xyz.log2, do-xyz.2.log, or do-xyz-30may21.log)
# if - specified for pattern, then [a-z]* used
# notes:
# - requires numeric affix to avoid false positives
# - use READONLY to exclude writable files
# TODO:
# - add RELAXED for looser pattern matching
#
# move-log-files: move "versioned" log files to log-files
# move-output-files: likewise for output files with version numbers to ./output
# note: versioned files are those ending in numerics or with numeric affix
## TODO: use perl-style regex for more precise matching (maldito over-arching glob's)
## TODO3: reconcile with move-versioned-files-alt which is more precise but with less coverage.
# maldito shellcheck: SC2120 (warning): ... references arguments, but none are ever passed.
# shellcheck disable=SC2120
function move-versioned-files {
    if [ "$1" = "" ]; then
        echo "usage: [ENV] move-versioned-files 'brace_pattern' dir"
        echo "    where ENV = [READONLY=1]"
        ## TODO: echo "    where ENV = [MOVE=command] ...        use 'mv -v' to move read
        echo "note: try move-versioned-files-alt"
        return
    fi
    local ext_pattern="$1"
    if [ "$ext_pattern" = "-" ]; then ext_pattern="[a-z]*"; fi
    local dir="$2"
    if [ "$dir" = "" ]; then dir="versioned-files"; fi
    mkdir -p "$dir";
    local D="[-.]"
    local perm="-"
    if [ "$READONLY" = "1" ]; then perm="w"; fi
    # TODO: fix problem leading to hangup (verification piped to 2>&1)
    # Notes: eval needed for $ext_pattern resolution
    # - excludes read-only files (e.g., ls -l => "-r--r--r--   1 tomohara tomohara   11K Nov  2 16:30 _master-note-info.list.log")
    #                            regex groups:   1( ^ [no w])  2 3        4          5   6    7 8
    # maldito shellcheck: SC2035 [Use ./*glob* or -- *glob* so names with dashes won't become options]; SC2046 [Quote this to prevent word splitting], and SC2086 [Double quote to prevent globbing and word splitting]
    # shellcheck disable=SC2035,SC2046,SC2086
    ## DEBUG: echo *$D${ext_pattern}[0-9]*  *$D*[0-9]*$D${ext_pattern}  *$D${ext_pattern}$D*[0-9][0-9]*   *[0-9][0-9]*$D${ext_pattern}
    move  $(eval ls -l *$D${ext_pattern}[0-9]*  *$D*[0-9]*$D${ext_pattern}  *$D${ext_pattern}$D*[0-9][0-9]*   *[0-9][0-9]*$D${ext_pattern}  2>&1 | perl-grep -v "(No such file)|(^..$perm)" | perl -pe 's/(\S+\s+){7}\S+//;' | sort -u) "$dir"
    #     EXs:     fu.log2                 fu.2.log                    fu.log.14aug21                    fu-14aug21.log
    # maldito shellcheck: SC2119 [Use ... "$@" if function's $1 should mean script'1 $1]
    # shellcheck disable=SC2119
    if [ $? != 0 ]; then move-versioned-files; fi
}
alias move-log-files='move-versioned-files "{log,debug}" "log-files"'
# note: * the version regex should be kept quite specific to avoid useful files being moved into ./output
alias move-output-files='move-versioned-files "{csv,html,json,list,out,output,png,report,tsv,xml}" "output-files"'
alias move-adhoc-files='move-log-files; move-output-files'
alias move-old-files='move-versioned-files "*" old'
#
# move-versioned-files-alt: alternative version for moving all files with DDMMMDD-style timestamp into ./old
# Also include MM-DD-YYYY.
# note: incldues sanity check for misplaced files (e.g., adhoc notes or .txt)
# shellcheck disable=SC2010,SC2086
{
function move-versioned-files-alt {
    mkdir -p old;
    # note: regex is treated as a glob during move proper
    local version_regex="[0-9][0-9][a-z][a-z][a-z][0-9][0-9]"            # ddMMMyy
    local alt_version_regex="[0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]" # MM-dd-yyyy
    if [ "${STRICT:-0}" == "1" ]; then
        version_regex="[^0-9]${version_regex}[^0-9]"
        alt_version_regex="[^0-9]${alt_version_regex}[^0-9]"
    fi
    ## TODO2: work out a glob accounting for dot files
    move --no-clobber ./*$version_regex* ./*$alt_version_regex* old 2>&1 | grep -v "cannot stat"
    move --no-clobber ./.*$version_regex* ./.*$alt_version_regex* old 2>&1 | grep -v "cannot stat"
    local false_positives
    # note: uses -d to avoid descending into matched directories (which would list unrelated files);
    # uses [^a-zA-Z]\.txt$ to avoid flagging compound extensions like .log.txt or .list.txt
    false_positives="$(ls -d old/*$version_regex*  old/*$alt_version_regex* 2>&1 | $GREP -v 'No such file' | $EGREP "(adhoc)|([^a-zA-Z]\.txt$)")"
    false_positives="$false_positives$(ls -d old/.*$version_regex*  old/.*$alt_version_regex* 2>&1 | $GREP -v 'No such file' | $EGREP "(adhoc)|([^a-zA-Z]\.txt$)")"
    if [ "$false_positives" != "" ]; then
        echo "Warning: potential misplaced files (e.g., .txt ext or adhoc affix)"
        echo "    $false_positives"
        echo "Use STRICT=1 ... for more precise matching."
    fi
    }
}

#--------------------------------------------------------------------------------

# rename-with-file-date(file, ...): rename each file(s) with .ddMmmYY suffix
# Notes: 1. If file.ddMmmYY exists, file.ddMmmYY.N tried (for N in 1, 2, ...).
# 2. No warning is issued if the file doesn't exist, so can be used as a no-op.
# 3. with IGNORE_ALL=1 any file with date-like affix is ignored
# TODO: have option to put suffix before extension
function rename-with-file-date() {
    ## DEBUG: set -o xtrace
    local f new_f
    local verbose=0
    local move_command="move"
    if [[ ("$1" == "") || ("$1" == "--help") ]]; then
        echo "Usage: [ENV] rename-with-file-date [--help|--verbose] file ..."
        echo "    where ENV = [IGNORE_ALL=1] [DRY_RUN=1]"
        return
    fi
    if [ "$1" = "--copy" ]; then
        ## TODO: move_command="copy"
        move_command="command cp --interactive --verbose --preserve"
        shift
    fi
    if [ "$1" = "--verbose" ]; then
        verbose=1
        shift
    fi
    if [[ "$DRY_RUN" == "1" ]]; then
        move_command="echo todo: $move_command"
    fi    
    for f in "$@"; do
        ## DEBUG: echo "f=$f"
        # ex1: usage.list.23Aug23
        # ex2: Mezcla-9jan22.tar.gz
        # note: timestamp "component" uses periods around the potential date (e.g., Mezcla-9jan22.tar.gz)
        # whereas an "affix" is just substring (e.g., my12abc34file)
        if [[ ("$f" =~ \.[0-9]{2}[a-z]{3,4}[0-9]{2}.*$) ]]; then
            [ $verbose = 1 ] && echo "Ignoring file with timestamp component: $f"
        elif [[ ("$IGNORE_ALL" = "1") && ("$f" =~ [0-9]{2}[a-z]{3,4}[0-9]{2}) ]]; then
            [ $verbose = 1 ] && echo "Ignoring file with timestamp affix: $f"
        elif [ -e "$f" ]; then              # regular file exists
            ## TODO2: use same format as $(T)--lowercase as in $(get-free-filename ... $(date ... | downcase-stdin; ))
            new_f=$(get-free-filename "$f.$(date --reference="$f" '+%d%b%y')" ".")
            ## DEBUG: echo
            eval "$move_command" "$f" "$new_f";
        elif [ -L "$f" ]; then              # symbolic link exists
            # note: gets mod time via 'stat -c %y'
            ## OLD: new_f=$(get-free-filename "$f.$(date --date="$(stat -c %y "$f")" '+%d%b%y')" ".")
            local date_spec
            date_spec=$(file-date-mmdddyy "$f")
            new_f=$(get-free-filename "$f.$date_spec" ".")
            eval "$move_command" "$f" "$new_f";
        else
            ## TODO2: [ $verbose ] && echo "FYI: no '$f'"
            [ $verbose = 1 ] && echo "FYI: no '$f'"
        fi
    done;
    ## DEBUG: set +o xtrace
}
## HACK: See if function required for proper handling by bats-core
function copy-with-file-date { rename-with-file-date --copy "$@"; }

# Statistical helpers
alias bigrams='perl -sw "$TOM_BIN"/count_bigrams.perl -N=2'
alias unigrams='perl -sw "$TOM_BIN"/count_bigrams.perl -N=1'
alias word-count=unigrams

# calc-stdev: calculate stdard deviation iv sum_file.perl using -col=1 by default
# EX: echo $'1\n2\n3\n4\n5' | calc-stdev => "num = 5; mean = 3.000; stdev = 1.581; min = 1.000; max = 5.000; sum = 15.000"
function calc-stdev () { alias-perl sum_file.perl -stdev "$@" -; }

# Lynx stuff
# lynx-dump-stdout(option, ...): Run lynx with textual output to stdout
# lynx-dump(file, [[out-file], option, ...]): Run lynx over base.html with output to base.txt
lynx-dump-stdout () { lynx -width=512 -dump "$@"; }
lynx-dump () { 
    local in_file="$1"
    shift 1
    local base
    base=$(basename "$file" .html)
    #
    # TODO: address SC2049 [=~ is for regex. Use == for globs]
    # shellcheck disable=SC2049
    if [[ ("$out_file" = "" ) && (! "$1" =~ -*) ]]; then
        local out_file="$1"
    fi
    #
    if [ "$out_file" = "" ]; then out_file="$base.txt"; fi
    #
    lynx-dump-stdout "$@" "$file" > "$out_file" 2> "$out_file.log"
    if [ -s "$out_file.log" ]; then
        cat "$out_file.log"
        delete-force "$out_file.log"
    fi
}
if [ "$BAREBONES_HOST" = "1" ]; then export lynx_width=0; fi
alias lynx-html='lynx -force_html'

# CSH-like aliases
#
function setenv () { export "$1"="$2"; }
alias unsetenv='unset'
alias unexport='unset'

# Unicode support
#
# TODO: put show-unicode-code-info-aux into script (as with other overly-large function definitions like hg-pull-and-update)
# show-unicode-control-chars(): output Unicode codepoint (ordinal) and UTF-8 encoding for input chars with offset in line
function show-unicode-code-info-aux() { perl -CIOE   -e 'use Encode "encode_utf8"; print "char\tord\toffset\tencoding\n";'    -ne 'chomp;  printf "%s: %d\n", $_, length($_); foreach $c (split(//, $_)) { $encoding = encode_utf8($c); printf "%s\t%04X\t%d\t%s\n", $c, ord($c), $offset, unpack("H*", $encoding); $offset += length($encoding); }   $offset += length($/); print "\n"; ' < "$1"; }
function show-unicode-code-info { show-unicode-code-info-aux "$@"; }
function show-unicode-code-info-stdin() { local in_file="$TEMP/show-unicode-code-info.$$"; cat >| "$in_file";  show-unicode-code-info-aux "$in_file"; }
#
function output-BOM { perl -e 'print "\xEF\xBB\xBF\n";'; }
#
# show-unicode-control-chars(): Convert ascii control characters to printable Unicode ones (e.g., ␀ for 0x00)
# See https://stackoverflow.com/questions/42193957/errorwide-character-in-print-at-x-at-line-35-fh-read-text-files-from-comm.
## OLD: function show-unicode-control-chars { perl -pe 'use open ":std", ":encoding(UTF-8)"; s/[\x00-\x1F]/chr(ord($&) + 0x2400)/eg;'; }
function display-unicode-control-chars { perl -pe 'use open ":std", ":encoding(UTF-8)"; s/[\x00-\x1F]/chr(ord($&) + 0x2400)/eg;'; }
#
## TODO2: rework show-unicode-code-info*/show-unicode-control-chars for tab-completion
## TEMP:
alias display-unicode-info=show-unicode-code-info-stdin

#-------------------------------------------------------------------------------
trace Unix aliases

## TODO: archive
function group-members () { ypcat group | $GREP -i "$1"; }
# TODO: check if _make.log exists prior to move
## TODO: alias do-gzip='nice -19 gzip -rfv . >| ../gzip-$(basename $PWD).log 2>&1; $PAGER ../gzip-$(basename $PWD).log'
#
# $ man merge
#   merge [ options ] file1 file2 file3
#   merge  incorporates all changes that lead from file2 to file3 into file1.
# NOTE: merge -p mod-file1 original mod-file2 >| new-file
alias merge='echo "do-merge MODFILE1 OLDFILE MODFILE2 > NEWFILE"'
## alias do-merge='/usr/bin/merge -p'
alias do-merge='command merge -p'
# note: version of merge usinf diff3 to specify diff program (shell wrapper with whitespace ignored)
alias diff3-merge='command diff3 --merge --text --diff-program=diff.sh'
## TODO: --auto
function kdiff-merge() {
    if [ "$3" = "" ]; then
        echo "usage: ${FUNCNAME[0]} changed1 old changed2 output"
        return
    fi
    kdiff3 --merge --output "$4" "$1" "$2" "$3"
}
#
quiet-unalias which
# Disables shellchecks SC2317 [Command appears to be unreachable]
# TODO3: see why it is complaining
function which {
    # shellcheck disable=SC2317
    command which "$@" 2> /dev/null;
}
#
# absolute-path(filename): returns actual full path for filename
function absolute-path { realpath "$1"; }
# full-dirname(filename): returns full path of directory for file
# TODO: use realpath
#
function full-dirname { absolute-path "$1"; }
#
# base-name-with-dir(file, suffix): version of basename including dir
function basename-with-dir {
    local file="$1"
    local suffix="$2"
    echo "$(dirname "$file")/$(basename "$file" "$suffix")";
}
# 
function rpm-extract () { rpm2cpio "$1" | cpio --extract --make-directories; }
#
# dump-url(URL): dump URL tree to local dir
alias dump-url='wget --recursive --relative'
# get-url(URL): outputs URL contents
alias get-url=curl
# TODO: rename as simple-dump-url???
#
alias gtime='command time'

# see 'man 5 os-release'
# TODO: linux => unix
alias linux-version="cat /etc/os-release"
alias os-release=linux-version
alias system-status='system_status.sh -'
#
# apropos-command: show apropos output for lExecutable programs or shell commands (i.e., man section 1)
# TODO: use '$@' for '$*' (or note why not appropriate)
# TODO: 'apropos --section 1'
# EX: apropos-command time | grep asctime | wc -l => 0
function apropos-command () { apropos "$*" 2>&1 | $GREP '(1)' | $PAGER; }
#
# 
function split-tokens () { perl -pe "s/\s+/\n/g;" "$@"; }
alias tokenize='split-tokens'
#
# perl-echo(arg1): print arg1 via perl
# NOTE: Usually Bash $'string' special tokens can be used instead
#       (e.g., perl-echo "A\tB" => echo $'A\tB').
# TODO: try to minimize use of quotes in perl-echo (e.g., need to mix single with double) due to bash quirks
function perl-echo () { perl -e 'print "'"$*"'\n";'; }
## TODO: function perl-echo () { perl -e 'print "'"($*)"'\n";'; }
## MISC
function perl-echo-sans-newline () { perl -e 'print "'"$1"'";'; }
#
# perl-printf(format, arg): output ARG2 via perl format ARG1
## TODO: generalize perl-printf to more than 2 args
## function perl-printf () { perl -e 'printf "$1\n", @_[1..$#_];';  }
##
## function perl-printf () { perl -e "printf \"$1\"", qw/$2 "$3" "$4" "$5" "$6" "$7" "$8" "$9"/; }
## MISC
function perl-printf () { perl -e "printf \"$1\", $2;"; }
##
## TODO: get following to work for 'perl-print "how now\nbrown cow\n"'
## function perl-print () { perl -e "print $1"; -e 'print "\n";'; }
## MISC
function perl-print () { perl -e "printf \"$1\";" -e 'print "\n";'; }
## MISC
function perl-print-n () { perl -e "printf \"$1\";"; }
#
# quote-tokens(): puts double quote around each token on commnd line
# note: used to circumvent google search's annoying search term dropping
function quote-tokens () { echo "$@" | perl -pe 's/(\S+)/"\1"/g;'; }

# sleep-for(seconds, [message], [delay_spec]): sleep for SECONDS with MESSAGE (e.g., "delay") and DELAY_SPEC (e.g., "[sleep for Ns]")
function sleep-for {
    local sec="$1"
    ## OLD: local msg="${2:-"delay for ${sec}s"}"
    local msg="${2:-"delay"}"
    local delay_spec="${3:-"[sleep for ${sec}s]"}"
    echo "$msg $delay_spec"
    ## TODO3: allow for keypress (n.b., control-C aborts containing function)
    sleep "$sec"
}

# Unix/Win32 networking aliases
if [ "$OSTYPE" != "cygwin" ]; then alias ipconfig=ifconfig; fi
alias set-display-local='export DISPLAY=localhost:0.0'

# Bash aliases
# Note: '-o' ('+o') is idiom for turning off (on)
alias bash-trace-on='set -o xtrace'
## BAD: alias bash-trace-off='set - -o xtrace'
alias bash-trace-off='set +o xtrace'
#
# trace-cmd(command-line): runs command-line with bash tracing enable to
# show argument expansion with result piped into less
function trace-cmd() {
    (
        ## TODO: warn about need for extra quotes
        ## if [[ "$*" =~ " " ]]; then echo  "FYI: Make sure command doubly-quoted to trace-cmd"; fi
        echo "start: $(date)";
        bash-trace-on; 
        eval "$*"; 
        bash-trace-off;
        echo "end: $(date)";
    ) 2>&1 | $PAGER;
}
## ALT: function trace-cmd() { bash-trace-on; @_; bash-trace-off; }
alias cmd-trace='trace-cmd'

# Compressing/uncompressing a subdirectory tree (ignoring symbolic links) 
# TODO: write scripts for this (given the complexity)
# TODO: don't uncompress compressed archives (.tar.gz files)
function compress-dir() {
    log_file=$TEMP/compress_$(basename "$1").log;
    find "$1" \( -not -type l \) -exec gzip -vf {} \; >| "$log_file" 2>&1; 
    $PAGER "$log_file";
}
# NOTE: zipped archived are kept compressed
function uncompress-dir() {
    log_file=$TEMP/uncompress_$(basename "$1").log;
    find "$1" \( -not -type l \) \( -not -name \*.tar.gz \) -exec gunzip -vf {} \; >| "$log_file" 2>&1; $PAGER "$log_file";
}
alias compress-this-dir='compress-dir $PWD'
alias ununcompress-this-dir='uncompress-dir $PWD'

# count-exts(): tabulate the file extensions in current directory
# count-exts-all(): likewise including cases with no extension (e.g., 'it')
function count-exts () { $LS | count-it '\.[^.]+$' | sort $SORT_COL2 -rn | $PAGER; }
function count-exts-all { (count-exts | cat; $LS | count-it '^[^.]+(\.*)$') | sort $SORT_COL2 -rn | $PAGER; }

alias kill-iceweasel='kill-em iceweasel'

# flatten-path(path-label): convert PATH-LABEL to flattened file name:
# - slash, whitespace, and non-filename-safe chars converted to _
# - leading dashes converted to _
# - collapse multiple underscores to a single _
# ex: "recipes/regex/__init__.py" => "recipes_regex__init__.py"
# note:
# - this is intended for when there is wide variation of the input as with such as cmd-output
# - developed with several different AI assistants (POE, GPT, Claude)
# ex: "recipes/regex/__init__.py" => "recipes_regex_init_.py"
# TODO2: allow for existing __'s to be preserved; trim leading/trailing underscores
#
function flatten-path {
    # note: uses -pe '...' to avoid heredoc/pipe stdin conflict; \w covers unicode word chars; -CS is for unicode
    printf '%s\n' "$@" | perl -CS -pe '
        s/^-/_/u;         # leading dash => _
        s{[/\h]}{_}gu;    # slash + horizontal whitespace => _
        s/[^\w.\n-]/_/gu; # remaining non-filename-safe chars => _ (preserves unicode \w, dot, newline, dash)
        s/_+/_/g;         # collapse multple _s
        ## TODO?:
        ## s/_{3,}/_/g;      # collapse 3+ underscores to one (preserves existing __)
        ## s/^_+//;          # trim leading underscores
        ## s/_+$//;          # trim trailing underscores
    '
}
## TODO2:
## function flatten-path {
##     printf '%s\n' "$*" |
##         perl -p <<PERL
##             s/^-/_/;                    # leading dash
##             s{[\/\s]}{_}g;              # slash + whitespace
##             s{[^A-Za-z0-9._-]}{_}g;     # unsafe chars
##             s/_{3,}/_/g;                # collapse 3+
##             s/^_+//;                    # trim leading _
##             s/_+$//;                    # trim trailing _
## PERL
## }
##
# cmd-output(cmd, ...): show output for cmd to _{cmd}-$(TODAY).log (with spaces
# replaced by underscores)
# note: subsequent files for the same date use ...-$(TODAY).N.log (for N=1, ...)
# now: also replaces other characters like / and \W excluding dash.
#
function cmd-output () {
    local command="$*"
    if [[ ("$command" == "--help") || ("$command" == "") ]]; then
        echo "usage: [ADD_MINUTES=1] ${FUNCNAME[0]} [--help] [command [arg ...]]"
        return
    fi
    ## BAD: local output_base, output_file
    local output_base output_file
    ## OLD: output_base="_$(echo -n "$command" | perl -pe 's/[^\w.-]/_/g;')-$(TODAY)"
    ## OLD: output_base="_$(echo -n "$command" | perl -pe 's/[^\w.-]/_/g;')"
    ## BAD: output_base="_$(flatten-path "$command-usage.list")"
    output_base="_$(flatten-path "$command")"
    if [ "${ADD_MINUTES:0}" == "1" ]; then
        output_base="${output_base}-$(mmddyy-hhmm)"
    else
        output_base="${output_base}-$(TODAY)"
    fi
    output_file="$(get-free-filename "$output_base" . list)"
    ## TODO3?: use separate invocations for aliases than for other commands
    ($command || eval "$command") 2>&1 | ansifilter > "$output_file"
    $PAGER_NOEXIT "$output_file"
}
# cmd-output-hhmm(): version of cmd-output adding HHMM to timestamp
function cmd-output-hhmm () {
    ADD_MINUTES=1 cmd-output "$@"
}

# cmd-usage(command): output usage for command to _command.list (with spaces
# and file path chars replaced by underscores)
function cmd-usage () {
    local command="$*"
    local usage_file
    ## OLD: usage_file="_$(echo "$command" | perl -pe 's@[/ .]@_@g; s/_+/_/g;')-usage.list"
    usage_file="_$(flatten-path "$command-usage.list")"
    $command --help  2>&1 | ansifilter > "$usage_file"
    ## OLD: if [ $? -eq 0 ]; then $PAGER_NOEXIT "$usage_file"; fi
    [ $? -eq 0 ] || sleep-for 1.5 "FYI: using existing file";
    $PAGER_NOEXIT "$usage_file";
}
## TODO:
## function cmd-usage () {
##     cmd-output "$*" --help
## }

#-------------------------------------------------------------------------------
# More Linux stuff
## TOM-IDIOSYNCRATIC
# TODO: condition upon using Linux kernel (or cygwin
alias configure='./configure --prefix ~'
# pp-xml(xml-file): prettyprint xml-file to stdout
# pp-html(html-file): prettyprint html-file to stdout
## OLD:
## alias pp-xml='xmllint --format'
## alias pp-html='pp-xml --html'
function pp-xml {
    if missing-options "$@"; then
        function-usage --synopsis "prettyprint xml" --example "my-doc.xml"
        return        
    fi
    xmllint --format "$@"
}
function pp-html {
    if missing-options "$@"; then
        function-usage --synopsis "prettyprint html" --example "my-page.html"
        return        
    fi
    pp-xml --html "$@"
}
# ex: pp-url "www.fu.com?p1=fu&p2=bar" => "www.fu.com\n\t?p1=fu\n\t&p2=bar"
alias pp-url-aux='perl -pe "s/[\&\?]/\n\t$&/g;"'
function pp-url { echo "$@" | pp-url-aux; }
alias check-xml='xmllint --noout'
alias check-xml-valid='check-xml --valid'
alias soffice-calc='/usr/lib/libreoffice/program/soffice.bin --calc'
alias libreoffice-write='run-app libreoffice --writer'
alias libreoffice-pdf='run-app libreoffice --draw'
alias libreoffice-calc='run-app libreoffice --calc'
alias libreoffice-main='run-app libreoffice'
alias start=start.sh
alias edit='start.sh --edit'
alias open='start.sh --open'
alias explore-dir=nautilus
## TODO?
## alias gnome-settings=gsettings

# Emacs-related
# TODO: put elsewhere
# Note: em-dir ensures the current directory is same as for dir or file,
# so that closing ad then doing dired brings up that same dir.
alias em-docs='em-dir ~/Documents'
# TODO: add tomasohara alias for the aliases as well
alias ed-setup='em-dir "$TOM_BIN/tomohara-aliases.bash"'
alias em-setup=ed-setup
alias ed-past-info='em-dir ~/organizer/past-info.txt'
alias em-past-info=ed-past-info
alias ed-tomas='start.sh ~/organizer/tomas.odt'
alias em-tomas=ed-tomas

# Truncate text wider than current terminal window
# TODO: add truncation indicator (e.g., Unicode character for ...)
# maldito shellcheck: [SC2120: ... references arguments, but none are ever passed]
# shellcheck disable=SC2120
function truncate-width { cut --characters=1-"$(($COLUMNS - 2))" "$@"; }

#-------------------------------------------------------------------------------
# XWindows stuff
alias magnifier='run-app kmag'

#-------------------------------------------------------------------------------
# Linux admin

alias apt-install='sudo apt-get install --yes --fix-missing --no-remove'
alias apt-update='sudo apt-get update'
alias apt-search='sudo apt-cache search'
alias apt-installed='sudo apt list --installed'
alias apt-uninstall='sudo apt-get remove'
alias dpkg-install='sudo dpkg --install '
alias dpkg-extract='dpkg-deb --extract --verbose'
# TODO: disable if on remote host???
alias restart-network='sudo ifdown eth0; sudo ifup eth0'
alias hibernate-system='sudo systemctl hibernate'
alias suspend-system='sudo systemctl suspend'
alias shutdown-system='sudo shutdown'
alias restart-system='shutdown-system --reboot'
alias blank-screen='xset dpms force off'
alias stop-service='systemctl stop'
alias restart-service='sudo systemctl restart'
# TODO: rename as map-internet-ports???
# map-ports: shows TCP ports being listened to on the remote host
# note: -Pn option skips host discovery (a la no ping)
alias map-ports='nmap -Pn'

# get-free-filename(base, [sep=""], [ext=""]): get filename starting with BASE that is not used.
# Notes: 1. If <base> exists <base><sep><N> checked until the filename not used (for N in 1, 2, ... ).
# 2. See sudo-admin for sample usage; also see rename-with-file-date.
# 3. If Ext specified, it is added after the numeric part (n.b., including sep). It is used
# to ensure that the filename ends with a specific extension instead of a number.
# EX: get-free-filename("really-unique-filename", ".") => "really-unique-filename"
# EX: get-free-filename("/boot/initrd", ".", "img") => "/boot/initrd.1.img"
#
function get-free-filename() {
    local base="$1"
    local sep="$2"
    local ext="$3"
    local L=0
    local filename="$base"
    if [ "$ext" != "" ]; then filename="$filename$sep$ext"; fi
    ## DEBUG: local -p
    while [ -e "$filename" ]; do
        (( L++ ))
        filename="$base$sep$L"
        if [ "$ext" != "" ]; then filename="$filename$sep$ext"; fi
    done;
    ## DEBUG: local -p
    echo "$filename"
}

# sudo-admin(): create typescript as sudo user using filename based on current
# date using numeric suffixes if necessary until the filename is free (e.g., _config.30aug22.log2)
# note: exsting _config*.log files are made read-only so not later overwritten
# by accident
# TOM-IDIOSYNCRATIC
function sudo-admin () {
    local prefix="_admin-config."
    local base
    base="$prefix$(todays-date).log"
    sudo chmod ugo-w "$prefix"*.log* 2> /dev/null
    local script_log
    # TODO: (get-free-filename "$base" "." "log")???
    script_log=$(get-free-filename "$base")
    # note: maldito mac: need to special case
    local script_options="--flush"
    if [ "$(under-macos)" = "1" ]; then script_options="-t 0"; fi
    # maldito shellcheck: SC2033 [Shell functions can't be passed to external commands]; SC2086 [Double quote to prevent globbing and word splitting]
    # shellcheck disable=SC2033,SC2086
    sudo --set-home   script $script_options "$script_log"
}

# sync2(): invokes files system synchronization twice: one for good effect
# note: shold be down from a system administrator account (i.e., root)
alias sync2='sync; sync'

# fix-sudoer-home-permission(): fix permissions of home directory for user running
# sudo (e.g., so that they own all files)
#
function fix-sudoer-home-permission () {
    local user_home
    # shellcheck disable=SC2116
    ## BAD: user_home="$(echo ~$SUDO_USER)"
    user_home="$(bash -c "echo ~$SUDO_USER")"
    local changes_log="${user_home}/_fix-home-permission.log"
    if [ "$SUDO_USER" = "" ]; then
        echo "Warning: no sudo user for current shell"
    else
        rename-with-file-date "$changes_log"
        chown --recursive --changes "$SUDO_USER" "$user_home" > "$changes_log" 2>&1
        $PAGER "$changes_log"
    fi
}

#-------------------------------------------------------------------------------
# HTML stuff
# check-html(filename): check HTML in filename
alias check-html='check-xml --html'
# check-html-vnu(filename): likewise check HTML using Validator.nu [Nu Html Checker]
alias check-html-vnu='vnu'

#-------------------------------------------------------------------------------
# Remote host-related stuff
# TOM-IDIOSYNCRATIC
# TODO: straighten out private key to be used (e.g., was thomaspaulohara just used for intemass?)
#
## TOM-IDIOSYNCRATIC

TPO_SSH_KEY=~/.ssh/$USER-key.pem
SSH_PORT="22"
TPO_SSH_USER="$USER"
#
# ssh-host-login-aws(host): open SSH connection to HOST
# options: -X enables X11 forwarding; -i identity file; -q quiet mode; -p port
# TODO: For cygwin clients, unset TERM so set_xterm_title.bash not confused.
# Maldito shellcheck [SC2029: Note that, unescaped, this expands on the client side]
# shellcheck disable=SC2029
## TOM-IDIOSYNCRATIC
{
function ssh-host-aws-aux () { local host="$1"; shift; ssh -X -p $SSH_PORT -i "$TPO_SSH_KEY" "$TPO_SSH_USER@$host" "$@"; }
## TEST: use -q to try to disable hist-key-known-by-other-names warning (with annoying prompt)
## function ssh-host-aws-aux () { local host="$1"; shift; ssh -X -q -p $SSH_PORT -i "$TPO_SSH_KEY" "$TPO_SSH_USER@$host" "$@"; }
}
#
function ssh-host-login-aws () {
    local host="$1"
    shift;
    set-xterm-window "$host";
    ssh-host-aws-aux "$host" "$@";
}
## TODO: function run-remote-command-aws () { ssh-host-aws-aux "$@"; }
# Note: /tmp used in case host not setup with ~/temp
## TOM-IDIOSYNCRATIC
function scp-host-down() { scp -P $SSH_PORT -i "$TPO_SSH_KEY" "$TPO_SSH_USER@$1:$TMP/$2" .; }
# TODO: rework in terms of id_rsa-tomohara-keypair (as used on others hosts)
## TOM-IDIOSYNCRATIC
## TODO2: restore xterm prompt
# scp-host-up(host, file, ...): upload FILES to HOST
function scp-host-up() { local host="$1"; shift; scp -P $SSH_PORT -i "$TPO_SSH_KEY" "$@" "$TPO_SSH_USER@$host:$TMP"; }
#
## TOM-IDIOSYNCRATIC
# scp-aws-up(host, file, ...): upload FILES to HOST under SSH_XFER (~/xfer)
# scp-aws-down(...): similarly for download
function scp-aws-up() {
    local host="$1";
    shift;
    local xfer="${SSH_XFER:-xfer}"
    scp -P $SSH_PORT -i "$TPO_SSH_KEY" "$@"  "$TPO_SSH_USER@$host":"$xfer";
}
function scp-aws-down() {
    local host="$1";
    local xfer="${SSH_XFER:-xfer}"
    shift;
    for _file in "$@"; do
        scp -P $SSH_PORT -i "$TPO_SSH_KEY" "$TPO_SSH_USER@$host":"$xfer"/"$_file" .;
    done;
}
#
# TODO: consolidate host keys; reword hostwinds in terms of generic host not AWS
#
## TODO2: put this elsewhere (e.g., ~/.bashrc)
export AWS_HOST="52.15.125.52"
## Lorenzo review: is safe to have the explicit IP in a file?
aws_micro_host=ec2-52-15-125-52.us-east-2.compute.amazonaws.com
reference-variable $aws_micro_host
alias aws-login-micro='ssh-host-login-aws $aws_micro_host'
alias aws-upload-micro='scp-aws-up $aws_micro_host'
alias aws-download-micro='scp-aws-down $aws_micro_host'
#
alias aws-login=aws-login-micro
alias ssh-aws=aws-login
alias aws-upload=aws-upload-micro
alias aws-download=aws-download-micro
#
alias hw1-login='ssh-host-login-aws $HOSTWINDS_HOST'
alias hw1-upload='scp-aws-up $HOSTWINDS_HOST'
alias hw1-download='scp-aws-down $HOSTWINDS_HOST'
alias hw2-login='ssh-host-login-aws $NEW_HOSTWINDS_HOST'
alias hw2-upload='scp-aws-up $NEW_HOSTWINDS_HOST'
alias hw2-download='scp-aws-down $NEW_HOSTWINDS_HOST'
#
HW2_MISC="http://www.tomasohara.trade/misc"
alias hw2-upload-misc='echo see $HW2_MISC; SSH_XFER=misc hw2-upload'
function hw2-upload-misc-single {
    hw2-upload-misc "$@"
    echo see "$HW2_MISC/$(basename "$1")"
}

# Set dummy default host on AWS and HostWinds so hostname always in xterm title (see set_xterm_title.bash).
# Sample hostnames under AWS is ip-172-31-37-185 and under Hostwinds is ip-172-31-37-185.
# TODO: Get domainname.sh working (or information partcular to uname -a).
# NOTE: temporary hack for remote servers until set_xterm_title.bash fixed (7 Feb 2020): echo n/a > ~/.default_host
## TEMP: if [[ ("$DEFAULT_HOST" = "") && (($HOSTNAME =~ ip-*) || ($HOSTNAME = tpo-servidor) || ($HOSTNAME =~ cvps*)) ]]; then export DEFAULT_HOST=n/a; fi
if [[ ("$DEFAULT_HOST" = "") && (($HOSTNAME =~ ip-*) || ($HOSTNAME =~ cvps*)) ]]; then export DEFAULT_HOST=n/a; fi


#................................................................................
# Other host-related stuff
# TODO: make generic (e.g., by making nickname optional)

alias uname-node='uname -n'
alias pwd-host-info='pwd; echo "${HOST_NICKNAME:-n/a}"; uname-node'

# TODO: put following elsewhere
## MISC
## conditional-export SANDBOX ~/python/tohara
## conditional-export MISC_TRACING_LEVEL 4
## alias restart-screen='screen-startup.sh >| $TEMP/screen-startup.$$.log 2>&1'

#-------------------------------------------------------------------------------
# Misc. language related
alias json-pp='json_pp -json_opt utf8,pretty'
alias pp-json=json-pp
# note: canonical sorts the keys of hashes (utf8 avoids warning and pretty might be the default)
alias pp-json-sorted='json_pp -json_opt utf8,pretty,canonical'

#-------------------------------------------------------------------------------
# Hostwinds related
# cvps6185033409: old Ubuntu 12.04.02 i866
export HOSTWINDS_HOST=23.254.204.34
# hwsrv-592788.hostwindsdns.com: Ubuntu 16.04.02 x64
export NEW_HOSTWINDS_HOST=142.11.227.157

#-------------------------------------------------------------------------------
# General unix
#
# ps-all(pattern): show processes from all users matching PATTERN (or . in which case piped to less)
# TODO: have option to restrict to current user
function ps-all () { 
    local pattern="$1";
    local pager=cat;
    if [ "$pattern" = "" ]; then 
        pattern="."; 
        pager=$PAGER
    fi;
    ps_mine.sh --all | $EGREP -i "((^USER)|($pattern))" | $pager;
    }
alias ps-script='ps-all "\\bscript\\b" | $GREP -v "(gnome-session)"'
# ps-sort[-xyz]: various wrappers around ps_sort.perl
# note: the script now assume -once if DURING_ALIAS set (e.g., via alias-perl)
alias ps-sort='alias-perl ps_sort.perl'
function ps-sort-once { alias-perl ps_sort.perl -num_times=1 -by=time "$@" -; }
simple-alias-fn ps-sort-time 'ps-sort-once -by=time'
simple-alias-fn ps-time ps-sort-time
simple-alias-fn ps-sort-mem 'ps-sort-once -by=mem'
simple-alias-fn ps-mem ps-sort-mem
simple-alias-fn ps-sort-help 'alias-perl ps_sort.perl'
simple-alias-fn ps-sort-cpu 'ps-sort-once -by=cpu'

# mkdir-and-chdir(dir): create dir and then change into it
function mkdir-then-chdir {
    local dir="$1"
    [ "$2" == "" ] || echo "Warning: ignoring '$2' ...";
    mkdir "$dir"
    cd "$dir"
}

# get-process-parent(pid): return parent process-id for PID
# $ ps al | egrep "(PID|$$)"
# F   UID   PID  PPID PRI  NI    VSZ   RSS WCHAN  STAT TTY        TIME COMMAND
# 0  1000  3723  3840  20   0  25136  7724 wait   Ss   pts/51     0:01 bash
# 4  1000 25056  3723  20   0  28920  1612 -      R+   pts/51     0:00 ps al
# 0  1000 25057  3723  20   0  14228  1024 pipe_w S+   pts/51     0:00 grep -E --color=auto (PID|372
# 
function get-process-parent() { local pid="$1"; if [ "$pid" = "" ]; then pid=$$; fi; ps al | alias-perl extract_matches.perl "^\d+\s+\d+\s+$pid\s+(\d+)"; }

# Make sure script appends rather than overwrites.
# In addition, set SCRIPT_PID, so that set_xterm_title.bash can indicate within script.
# Also, appends $ to prompt symbol so that typescript prompt searchable with strings command
## HACK: set envionment for sake of set_xterm_title.bash (TODO check PPID for this)
## TODO: use stack for old_PS_symbol maintenance??? (also allows for recursive invocation, such as with '$ $ $')
## TODO: rename as my-script to avoid confusion

# Make sure script appends rather than overwrites.
# In addition, set SCRIPT_PID, so that set_xterm_title.bash can indicate within script.
# Also, appends $ to prompt symbol so that typescript prompt searchable with strings command
## HACK: set envionment for sake of set_xterm_title.bash (TODO check PPID for this)
## TODO: use stack for old_PS_symbol maintenance??? (also allows for recursive invocation, such as with '$ $ $')
## TODO: rename as my-script to avoid confusion
# Maldito shellcheck [SC2032: Use own script or sh -c '..' to run this from sudo.]
# shellcheck disable=SC2032
## TOM-IDIOSYNCRATIC
{
function script {
    ## THIS function is buggy!
    # Note: set_xterm_title.bash keeps track of titles for each process, so save copies of current ones
    local save_full
    save_full=$(set-xterm-title --print-full)
    local save_icon
    save_icon=$(set-xterm-title --print-icon)
    ## DEBUG: echo "save_full='$save_full'; save_icon='$save_icon'"
  
    # Change prompt
    local old_PS_symbol="$PS_symbol"
    export SCRIPT_PID=$$
    # Note: the prompt change is flakey
    ## BAD: reset-prompt "$PS_symbol\$"
    ## NOTE: The sequence should not be interpretable (e.g., '$$' is PID if PS_symbol is '$')
    ## Therefore, ':' now added to block '$$' being int when PS_symbol is '$',
    ## TODO: use thin Unicode space to make this closer to the bad but simpler case.
    reset-prompt "$PS_symbol:\$"
    ## DEBUG: echo "script: 1. PS1='$PS1' old_PS_symbol='$old_PS_symbol' PS_symbol='$new_PS_symbol'"

    ## OLD:
    ## # Reset bashrc status variables
    ## export PROFILE_PROCESSED=0 BASHRC_PROCESSED=0
    
    # Change xterm title to match
    set-title-to-current-dir
    ## DEBUG: echo "script: 2. PS1='$PS1' old_PS_symbol='$old_PS_symbol' PS_symbol='$new_PS_symbol'"
    # Run command
    ## maldito macos
    command script -a "$@"
    
    # Restore prompt
    unset SCRIPT_PID
    reset-prompt "$old_PS_symbol"
    ## DEBUG: echo "script: 3. PS1='$PS1' old_PS_symbol='$old_PS_symbol' PS_symbol='$new_PS_symbol'"
    
    # Get rid of lingering 'script' in xterm title
    # note: --simple avoids adding info from environment
    ## DEBUG: echo "Restoring xterm title: full='$save_full' save='$save_icon'"
    set-xterm-title --simple "$save_full" "$save_icon"
}
}
#
# script-update(): invoke a script for a git session
# TODO: put this in a separate file
function script-update {
    local command_indicator=""
    ## TODO: under-linux 1 && command_indicator="-c"
    if [ "$(under-linux)" = "1" ]; then
        command_indicator="-c"
    fi
    # shellcheck disable=SC2046,SC2086
    script  "_update-$(T).log"  $command_indicator make-git-update.bash
}

# ansi-filter(filename): wrapper around ansifilter with stdio and stdout instead of files
# TODO: issue request for proper Unix stdin support (n.b., this function is much ado about nothing)
function ansi-filter {
    local input_file="$1"
    if [ "$input_file" = "" ]; then
        input_file="$TMP/ansi-filter-in-$$.list"
        cat > "$input_file"
    fi
    local output_file="$TMP/ansi-filter-out-$$.list";
    ansifilter --input="$input_file" --output="$output_file"
    cat "$output_file"
}

# pause-for-enter(): print message and wait for user to press enter
# TODO: extend to press-any-key; see
#    https://unix.stackexchange.com/questions/293940/how-can-i-make-press-any-key-to-continue
function pause-for-enter () {
    local message="$1"
    local verbose=$(is-true "VERBOSE")
    local press_enter="Press enter to continue"
    if [[ "$message" == "" ]]; then
        message="Waiting for confirmation";
    fi
    if $verbose; then
        local newline_tab=$'\n\t'
        message="${message}${newline_tab}${press_enter}"
    fi
    # note: with -p for prompt and -r makes backslash not an escape [avoids shellcheck warning]
    read -r -p "$message "
}

#-------------------------------------------------------------------------------
# Python related
## *** Python stuff ***

cond-export PYTHON_CMD "$TIME_CMD python3 -u"
cond-export PYTHON "$NICE $PYTHON_CMD"
cond-export PYTHONPATH "$HOME/python:$PYTHONPATH"
cond-export PYTEST_CMD "$TIME_CMD pytest"
cond-export PYTEST "$NICE $PYTEST_CMD"
#
# add-python-path(pkg-dir): add PKG-DIR to PATH and PARENT to PYTHONPATH
## HACK: make sure Mezcla/mezcla resolves before python/mezcla
function add-python-path () {
    local package_path="$1"
    local parent_path
    parent_path=$(realpath "$package_path/..")
    # add package to path (e.g., $HOME/python/Mezcla/mezcla)
    ## TODO: prepend-path-force "$package_path"
    export PATH="$package_path:$PATH"
    # add parent to python-path spec (e.g., $HOME/python/Mezcla)
    export PYTHONPATH="$parent_path:$PYTHONPATH"
}
# EX: mezcla-devel; which system.py | grep -i Mezcla-main => ""
# note: mezcla-devel should be stable version of mezcla-tom
## TOM-IDIOSYNCRATIC
alias mezcla-devel='add-python-path $HOME/python/Mezcla/mezcla'
alias mezcla-main='add-python-path $HOME/python/Mezcla-main/mezcla'
alias mezcla-tom='add-python-path $HOME/python/Mezcla-tom/mezcla'
# Add mezcla-devel unless another version in path
if [[ ! "$PATH" =~ mezcla ]]; then
    ## TODO: echo "Warning: mezcla not in PATH"
    true
fi
#
# ps-python(): show user's python processing, excluding system ones
alias ps-python-full='ps-mine python'
# note: excludes ipython and known system-related python scripts;
# also excludes related bash and time processes.
alias ps-python='ps-python-full | $EGREP -iv "(screenlet|ipython|egrep|perl-regexp|update-manager|software-properties|networkd-dispatcher|/usr/bin|((bash|emacs|time) .*python))"'
# show-python-path(): shows PYTHONPATH entries one per line
alias show-python-path='show-path-dir PYTHONPATH'
# mezcla-debug(): invoke debug.py (n.b., used for diagnostic purposes with its imports)
simple-alias-fn mezcla-debug 'alias-python -m mezcla.debug'

# Remove compiled files .pyc for regular (debug) version and .pyo for optimized
# TODO: add option for forced removal; try using '-name "*.py[co]"')
function delete-compiled-python-files-aux {
    local rm_options=${1:-"-v"}
    # Maldito shellcheck [SC2086: Double quote to prevent globbing and word splitting]
    # shellcheck disable=SC2086
    # maldito shellcheck bug: SC2033: Shell functions can't be passed to external commands
    # shellcheck disable=SC2033
    find . \( -name "*.pyc" -o -name "*.pyo" \) -exec command rm $rm_options {} \;
}
alias delete-compiled-python-files=delete-compiled-python-files-aux
alias delete-compiled-python-files-force='delete-compiled-python-files-aux -vf'

# Python-lint filtering
# python-lint-full(filename): complete output from pylint, with caret-based
# context indicators retained by substiting carriage return for newline.
# python-lint-work(filename): pylint with moderate filtering
# python-lint(filename): pylint with usual filtering
# TODO: specify exclusion types in pylint command line (e.g., invalid-name)
# example: "C:674, 0: Invalid constant name "term_freq" (invalid-name)"
# example: "run_ner.py:413:0: C0330: Wrong continued indentation (add 8 spaces).
#                   'B-DATE', 'I-DATE', 'B-DOCTOR', 'I-DOCTOR', 'B-LOCATION', 'I-LOCATION', 'B-AGE', 'I-AGE',
#                   ^       | (bad-continuation)
# TODO: make Mercurial root-to-python-path hack optional
# TODO: add similar aliases for pep8 and pyflakes
# TODO: handle continutations of statements without indentation:
#   ner_eval/ner_detokenize.py:11:45: C0326: Exactly one space required after comma
#   parser.add_argument('--output_file', type=str,  help='')
#                                      ^ (bad-whitespace)
function python-lint-full() { 
    local root
    ## NOTE: mercurial root check now optional
    root="."
    if [[ "${CHECK_MERCURIAL:-0}" == "1" ]]; then
        root="$root:$(hg root 2> /dev/null)";
    fi
    ## TODO: --persistent=n (to avoid caching); record pylint status ($?)
    ## OLD: PYTHONPATH="$root:.:$PYTHONPATH" $NICE pylint --reports=n --score=n --persistent=n "$@" 2>&1 | $PAGER;
    PYTHONPATH="$root:.:$PYTHONPATH" $NICE pylint --reports=n --score=n --persistent=n "$@" 2>&1 | $PAGER;
    ## TODO3:
    ## local pylint_out="$TMP/_pylint-$$.out"
    ## PYTHONPATH="$root:$PYTHONPATH" $NICE pylint "$@" >| "$pylint_out"
    ## perl -00 -ne 'while (/(\n\S+:\s*\d+[^\n]+)\n( +)/) { s/(\n\S+:\s*\d+[^\n]+)\n( +)/$1\r$2/mg; } print("$_");' "$pylint_out" 2>&1 | $PAGER;
    ## funciton check-python-lint-status { ... if [[ $pylint_result =~ [0-9]:[0-9] ]] ...}; 
    ## check-python-lint-status "$pylint_out"
    ## TODO1: explain and fix the above while loop (e.g., line-continuation support)!
}
# Notes:
# - filters out context in addition to warning proper, as in following:
#    ex: C:244, 0: Exactly one space required after assignment
#    SKIP_ADS =  (IS_GI_JOB_SEARCH or system.getenv_bool("SKIP_ADS", False))
#             ^ (bad-whitespace)
# - filters out other extraneous output
#   ex: Your code has been rated at 7.43/10 ...
#   ex: No config file found ...
# - the following has two regex: *modify the first* to add more conditions to ignore; the second is just for the extraneous pylint output
# TODO4: refine (e.g., drop unnecessary-pass)
function python-lint-work() {
    local disables="bad-continuation,bad-option-value,fixme,invalid-name,locally-disabled,too-few-public-methods,trailing-whitespace,star-args,unnecessary-pass,R09,C0302"
    python-lint-full --disable="$disables" "$@" 2>&1 | $PAGER;
}
# TODO: rename as python-lint-tpo for clarity (and make python-lint as alias for it)
# note: R0801 is for duplicate lines across source files (no mnemonic)
function python-lint() {
    local disables="duplicate-code,bad-whitespace,bad-indentation,bare-except,c-extension-no-member,consider-using-enumerate,consider-using-f-string,consider-using-with,global-statement,global-variable-not-assigned,keyword-arg-before-vararg,len-as-condition,line-too-long,logging-not-lazy,misplaced-comparison-constant,no-self-use,redefined-variable-type,redundant-keyword-arg,superfluous-parens,too-many-arguments,too-many-branches,too-many-instance-attributes,too-many-locals,too-many-public-methods,too-many-positional-arguments,too-many-statements,trailing-newlines,useless-else-on-loop,useless-return,useless-super-delegation,useless-import-alias,wrong-import-order,wrong-import-position"
    python-lint-work --disable="$disables" "$@" 2>&1 | $PAGER;
}
# python-lint-filtered(file, ...): uses additional PYLINT_FILTER with python-lint over FILE ...
# note: added for run-python-lint-batched over mako-generated scripts
function python-lint-filtered {
    local user_filter="${PYLINT_FILTER:-"$^"}"
    python-lint "$@" | $EGREP -v "$user_filter" | $PAGER;
}

# run-python-lint-batched([file_spec="*.py"]: Run python-lint in batch mode over
# files in FILE_SPEC, placing results in pylint/<today>.
#
# get-python-lint-dir(): get output dir to use for pylint
function get-python-lint-dir () {
    local python_version_major
    python_version_major=$(pylint --version 2>&1 | alias-perl extract_matches.perl "Python (\d)")
    local affix="py${python_version_major}"
    local out_dir
    out_dir="_pylint/$(todays-date)-$affix"
    echo "$out_dir"
}
#
function run-python-lint-batched () {
    # TODO: support files with embedded spaces
    local file_spec="$*"
    if [ "$file_spec" = "" ]; then file_spec="*.py"; fi

    # Create output directory if needed
    local out_dir
    out_dir=$(get-python-lint-dir)
    mkdir -p "$out_dir"

    # Run pylint and pipe top section into less
    # Maldito shellcheck [SC2086: Double quote to prevent globbing and word splitting]
    # shellcheck disable=SC2086
    (for f in $($LS $file_spec); do
         # HACK: uses basename of parent prefix if invoked with path
         local b
         b=$(basename "$f")
         local pre=""
         # Note: uses directory name as prefix if file not in current dir
         local d
         d=$(dirname "$f")
         if [[ $f =~ / ]]; then pre="$(basename "$d")-"; fi
         DEBUG_LEVEL=5 python-lint-filtered "$f" >| "$out_dir/$pre$b".log 2>&1
         head "$out_dir/$pre$b".log
     done) >| "$out_dir/summary.log"
    less -p '^\** Module' "$out_dir/summary.log";
}

# python-import-path(module): find path for package directory of MODULE
# Note: this checks output via module initialization output shown with python -v
# ex: /usr/local/misc/programs/anaconda3/lib/python3.8/site-packages/sklearn/__pycache__/__init__.cpython-38.pyc matches /usr/local/misc/programs/anaconda3/lib/python3.8/site-packages/sklearn/__init__.py
function python-import-path-all() { local module="$1"; alias-python -u -v -c "import $module" 2>&1; }
function python-import-path-full() { local module="$1"; python-import-path-all "$@" | alias-perl extract_matches.perl "((matches (.*\W${module}[^/]*[/\.][^/]*))|ModuleNotFoundError)"; }
function python-import-path() { python-import-path-full "$@" | head -1; }

#
## note: gotta hate python!
function python-module-version-full { local module="$1"; alias-python -c "import $module; print([v for v in [getattr($module, a, '') for a in '__VERSION__ VERSION __version__ version'.split()] if v][0])"; }
# TODO: check-error if no value returned
function python-module-version { python-module-version-full "$@" 2> /dev/null; }
function python-module-version-alt {
    python -c "from mezcla.system import get_module_version; print(get_module_version('$1'));"
}
function python-package-members() { local package="$1"; alias-python -c "import $package; print(dir($package));"; }
#
## OLD: alias python-setup-install='log=setup.log;  rename-with-file-date $log;  uname -a > $log;  alias-python setup.py install --record installed-files.list >> $log 2>&1;  ltc $log'
alias python-setup-install='log=setup.log;  rename-with-file-date "$log";  uname -a > "$log";  alias-python setup.py install --record installed-files.list >> "$log" 2>&1;  ltc "$log"'
# TODO: add -v (the xargs usage seems to block it)
alias python-uninstall-setup='cat installed-files.list | xargs command rm -vi; alias-perl rename_files.perl -regex ^ un installed-files.list'

# ipython(): overrides ipython command to set xterm title and to add git repo base directory to python path
function ipython() { 
    local ipython
    ipython=$(which ipython)
    if [ "$ipython" = "" ]; then echo "Error: install ipython first"; return; fi
    set-xterm-window "ipython [$PWD]"
    # note: git-root currently `git rev-parse --show-toplevel' (see git-aliases.bash);
    # no-op if not in a git repo (e.g., PYTHONPATH=":..."
    git_base_dir=$(git-root 2> /dev/null)
    PYTHONPATH="$git_base_dir:$PYTHONPATH" command ipython "$@"
}

# python-trace(script, arg, ...): Run python SCRIPT with statement tracing
function python-trace {
    local script="$1"
    shift
    # maldito shellcheck (SC2086: Double quote to prevent globbing)
    # shellcheck disable=SC2086
    $PYTHON -m trace --trace "$(which "$script")" "$@"
    }

# py-diff(dir): check for difference in python scripts versus those in target
# TODO: specify options before the pattern (or modify do_diff.sh to allow after)
function py-diff () { do_diff.bash --no-glob '*.py *.mako' "$@" 2>&1 | $PAGER; }

alias elide-data='alias-python -m transpose_data --elide'
alias kill-python="kill-em --filter 'ipython|emacs' python"
alias kill-python-all="kill-em python"
## TODO
## function which-program {
##     local program="$1"
##     result=$(which "$programe")
##     if [[ ("$result" == "") || ("$verbose" == "1") ]]; then result="$result;$(whereis "$program"); fi
##     if ...
##     }
## alias which-python='which-program python'
alias which-python='which python3'
alias python-version='python3 --version'

# run-jupyter-notebook-posthoc(): try to show log info previously not shown via run-jupyter-notebook
# TODO: enable multiple-versions backups
function run-jupyter-notebook-posthoc() {
    local log="$1"
    echo "checking log: $log"
    # TODO: resolve problem extracting URL
    # TEMP: tail "$log"
    # Show URL
    echo -n "URL: "
    VERBOSE=1 extract-matches 'http:\S+' "$log" | sort -u
}

# run-jupyter-notebook(port=18888): run jupyter notebook on PORT
function run-jupyter-notebook () {
    local port="$1"; if [ "$port" = "" ]; then port=8888; fi
    local ip="$2"; if [ "$ip" = "" ]; then ip="127.0.0.1"; fi
    local log
    log="$TEMP/jupyter-p$port-$(TODAY).log"
    rename-with-file-date "$log"
    # note: clears notebook token to disable authentication
    ## TEST: jupyter notebook --ServerApp.token='' --no-browser --port "$port" --ip "$ip" >> "$log" 2>&1 &
    ## TODO1: make sure IdentityProvider.token is right one to use (maltdito jupyter)
    ## TODO4?: JUPYTER_TOKEN="" jupyter notebook --no-browser --port ...
    jupyter notebook --IdentityProvider.token='' --no-browser --port "$port" --ip "$ip" > "$log" 2>&1 &
    # Let jupyter initialize
    local delay=6
    echo "sleeping $delay seconds for jupyter to finish initializing"
    sleep $delay
    run-jupyter-notebook-posthoc "$log"
}
alias jupyter-notebook-redir=run-jupyter-notebook
alias jupyter-notebook-redir-open='run-jupyter-notebook 8888 0.0.0.0'
# TODO3: rename to run-jupyter-notebook-... for sake of tab completion
alias run-jupyter-notebook-redir-open=jupyter-notebook-redir-open
# TODO3: streamline the jupyter aliases
alias jupyter-notebook-open=jupyter-notebook-redir-open

# Python-based utilities

## OLD (moved to tomohara-proper-aliases.bash)
## # extract-text(document-file): extracts text from structured document file (e.g., Word or PDF)
## # note: to avoid hardcoded 'python -m mezcla.extract_document_text' invovation uses awkward which-based approach
## ## TODO: figure out way for python to pull script from path (as with perl -S)
## function extract-text() { alias-python "$(which extract_document_text.py)" "$@"; }
## alias xtract-text='extract-text'
## alias extract-text-html='html_utils.py --regular'

# test-script(script): run unit test for script (i.e., tests/test_script)
# and outputs to file given by tests/_test-<script_basename>.<date>.log.
# note: run in verbose mode with unbuffered I/O so output synchronized.
# TODO: rework to take the actual test script and to pipe results to pager
## TOM-IDIOSYNCRATIC
## OBSOLETE: use test-python-script instead
#
function test-script { test-python-script "$@"; }
alias test-script-debug='ALLOW_SUBCOMMAND_TRACING=1 DEBUG_LEVEL=5 MISC_TRACING_LEVEL=5 test-script'

# randomize-datafile(file, [num|percent]): randomize datafile optionally pruned to NUM lines (or percent), preserving header line
#
function randomize-datafile() {
    local file="$1"
    local num_lines="$2"
    if [[ $num_lines =~ % ]]; then
        num_lines=${num_lines//%/}
        alias-python -m mezcla.randomize_lines --header --percent "$num_lines" "$file"
    else
        if [ "$num_lines" = "" ]; then num_lines=$(wc -l < "$file"); fi
        head -1 "$file"
        tail --lines=+2 "$file" | alias-python -m mezcla.randomize_lines - | head -"$num_lines"
    fi
}

# filter-random(pct, file, [include_header=1]): Randomize lines based on percentages, using output lile (e.g., _r10pct-fubar.data).
# Notes:
# - By default, includes first line assuming it is header line.
# - Includes support for compressed files (both input and output).
function filter-random() {
    local pct="$1"
    local file="$2"
    local include_header="$3"
    if [ "$include_header" == "" ]; then include_header=1; fi

    # Derive settings from input arguments
    local ratio
    ratio=$(perl -e "printf('%.3f', ($pct / 100.0));")
    local compressed=0
    if [[ $file =~ .gz ]]; then compressed=1; fi
    local dir
    dir=$(dirname "$file")
    local base
    base=$(basename "$file")
    local type
    type="cat"
    local result
    result="$dir/_r${pct}pct-$base"

    # Filter the file, optionally uncompressing
    if [ "$compressed" = "1" ]; then 
       type="zcat"; 
       result=$(echo "$result" | perl -pe 's/.gz$//;')
    fi
    local opts=""
    if [ "$include_header" = "1" ]; then opts="$opts --include-header"; fi
    # maldito shellcheck (SC2086: Double quote to prevent globbing)
    # shellcheck disable=SC2086
    $type "$file" | alias-python -m filter_random "$opts" --ratio "$ratio" - > "$result" 2> "$result.log"

    # Compress result if original compressed
    if [ "$compressed" = "1" ]; then 
       gzip --force "$result"; 
    fi
}

# Load supporting scripts
#
## OLD:
conditional-source "$TOM_BIN/anaconda-aliases.bash"
## TODO2:
## if [[ $USE_ANACONDA =~ 1|true ]]; then
##     conditional-source "$TOM_BIN/anaconda-aliases.bash";
## fi
conditional-source "$TOM_BIN/git-aliases.bash"

# Web access
#
function curl-dump () {
    local url="$1";
    local base
    base=$(basename "$url");
    curl "$url" > "$base";
}
# EX: url-path $BIN/templata.html => "file:///$BIN/template.html"
# TODO3: add support for Windows
function url-path () {
    local file="$1"
    realpath "$file" | perl -pe 's@^@file://@;'
}
# invoke-browser(executable, [file]): Invokes browser EXECUTABLE, optionally
# to open local FILE.
# Note: url-path helps when the filename might be confused as a URL (e.g., not.a.url.html)
#
function invoke-browser() {
    local browser_executable="$1"
    local file="$2"
    if [ "$file" != "" ]; then
        if [[ ! $file =~ http ]]; then
            file=$(url-path "$file")
        fi
    fi
    ## TODO?
    ## if [ ! -e "$browser_executable" ]; then
    ##     browser_executable_path=$(which "browser_executable")
    ##     if [ "$browser_executable_path" = "" ]; then browser_executable="$_path"; fi   
    ## fi
    local browser_base
    browser_base=$(basename "$browser_executable")
    $browser_executable "$file" >> "$TEMP/$browser_base.$(TODAY).log" 2>&1 &
}
## TODO: try to get following aliases to work for brevity
## alias firefox='invoke-browser command "firefox"'
## alias opera='invoke-browser command "opera"'
## NOTE: which is a Bash builtin
# TODO: make following conditioned up Linux
## OLD: alias chromium='invoke-browser /usr/lib/chromium-browser/chromium-browser'
alias chromium='invoke-browser /usr/bin/chromium-browser'
## TODO: drop which's
## BAD: function which { builtin which "$1" 2> /dev/null; }
function which { command which "$1" 2> /dev/null; }
# maldito shellcheck: SC2139: [This expands when defined, not when used. Consider escaping]
# shellcheck disable=SC2139
{
## TEST: alias firefox='invoke-browser "'"$(which firefox 2> /dev/null)"'"'
alias firefox='invoke-browser "'"$(which firefox)"'"'
## TEST: alias opera='invoke-browser "'"$(which opera 2> /dev/null)"'"'
alias opera='invoke-browser "'"$(which opera)"'"'
alias tor-browser='invoke-browser "'"$(which tor-browser-en.sh)"'"'
}
alias run-tor-browser=tor-browser
alias run-epiphany-browser='invoke-browser epiphany-browser'

#-------------------------------------------------------------------------------
# NVidia GPU

# nvidia-smi-loop([secs=1]): run nvidia-smi with SECS looping
function nvidia-smi-loop {
    local secs="${1:-1}";
    nvidia-smi --loop="$secs";
}
alias nvidia-loop=nvidia-smi-loop

# Multilingual
# TODO: put other common ones from do_setup.sh here

# Notes:
# - Aliases for emacs-qd-trans-sp.sh, which opens an Emacs terminal for running ye olde Quick-N-dirty Spanish word translator.
# - ed-trans-sp is used for consistency with recent aliases for editing info (ed-past-info for past-info.odt and ed-tomas for tomas.odt.
# - TODO: rename ed-tomas, as doc generalized to be a Spanish cheatsheet.
# - TODO: * Add hook(s) into Google and/or Bing translators!
alias emacs-qd-trans-sp='pushd ${MULTILINGUAL_DIR:-"$TOM_DIR/multilingual"}; ./emacs-qd-trans-sp.sh; popd'
alias em-trans-sp=emacs-qd-trans-sp
alias ed-trans-sp=em-trans-sp

#-------------------------------------------------------------------------------
# WordNet related
# See do_setup.bash

# Adhoc fixup's
wn="$(which wn > /dev/null 2>&1)"
if [ "$wn" == "" ]; then
    ## TODO: echo "Warning: unable to find WordNet wn binary"
    wn=wn
fi

#........................................................................
# Miscellaneous bash scripting helpers

# TODO: move other aliases here
trace bash helpers

# shell-check[-full](options, script, ...): run script through shellcheck
# with filtering given it's awkward filtering mecahanism
# note: specifies checking for bash (TODO: make optional)
# Warning: use regular shellcheck for production code
function shell-check-full {
    shellcheck -s bash "$@";
}
function shell-check {                  ## TOM-IDIOSYNCRATIC
    # note: filters out following
    # - SC1090: Can't follow non-constant source. Use a directive to specify location.
    # - SC1091: Not following: ./my-git-credentials-etc.bash was not specified as input (see shellcheck -x).
    # - SC2004: $/${} is unnecessary on arithmetic variables
    # - SC2009: Consider using pgrep instead of grepping ps output.
    # - SC2012: Use find instead of ls to better handle non-alphanumeric filenames
    # - SC2119 [Use ... "$@" if function's $1 should mean script'1 $1]
    # - SC2120: foo references arguments, but none are ever passed.
    # - SC2129: Consider using { cmd1; cmd2; } >> file instead of individual redirects
    # - SC2155 (warning): Declare and assign separately to avoid masking return values
    # - SC2164: Use 'cd ... || exit' or 'cd ... || return' in case cd fails.
    # - SC2181 (style): Check exit code directly with e.g. 'if mycmd;' ...
    # - SC2196 (info): egrep is non-standard
    # - SC2219 (style): Instead of 'let expr', prefer (( expr )) .
    # - SC2230: which is non-standard
    local strict="${STRICT_MODE:-0}"
    local exclude="${SHELL_CHECK_EXCLUDE:-SC1090,SC1091,SC2004,SC2009,SC2012,SC2119,SC2120,SC2129,SC2155,SC2164,SC2181,SC2196,SC2219,SC2230}"
    local exclude_args="--exclude=$exclude"
    if [ "$strict" != "0" ]; then
        exclude_args=""
    fi
    local verbose=$(is-true "VERBOSE");
    $verbose && echo "Exclusions: $exclude"
    # shellcheck disable=SC2086
    shell-check-full $exclude_args "$@" | perl -0777 -pe 's/\n\s+(Did you mean:)/\n$1/g;';
}

#-------------------------------------------------------------------------------
# Work-specific stuff (adhoc)
#
# TODO: put in separate file
#

#-------------------------------------------------------------------------------
# System administration
# TODO: do for ???
alias kill-software-updater='kill-em --force --all --pattern "(software-properties|gnome-software|update-manager|update-notifier)"'
alias update-software='command update-manager'
alias kill-clam-antivirus='kill-em --all -p clamd'

#........................................................................
# Miscellaneous local environment helpers
trace misc local helpers

# sleepyhead: Invoke SleepyHead with debug trace sent to log file under ~/temp.
## TOM-IDIOSYNCRATIC
function sleepyhead() {
    log_file="$TEMP/sleepyhead.$(todays-date).log"
    echo "start: $(date)" >> "$log_file"
    command sleepyhead >> "$log_file" 2>&1 &
    echo "end: $(date)" $'\n' >> "$log_file"
}
alias sleepy='sleepyhead'

#-------------------------------------------------------------------------------
# Math functions
#
# via https://stackoverflow.com/questions/21452752/how-to-find-min-of-two-variables-in-linux
# TODO4: add min-str and max-str (e.g., using -le)???
#
function min {
    local a=$1 b=$2;
    local result;
    result=$(( a <= b ? a : b ));
    echo $result;
}
#
function max {
    local a=$1 b=$2;
    local result;
    result=$(( a >= b ? a : b ));
    echo $result;
}

#------------------------------------------------------------------------
# Aliases for [re-]invoking aliases
## TOM-IDIOSYNCRATIC
alias tomohara-aliases='source "$TOM_BIN/tomohara-aliases.bash"'
alias tomohara-settings='source "$TOM_BIN/tomohara-settings.bash"'
alias more-tomohara-aliases='source "$TOM_BIN/more-tomohara-aliases.bash"'
alias tomohara-proper-aliases='source "$TOM_BIN/tomohara-proper-aliases.bash"'

#------------------------------------------------------------------------
# Optional end tracing
trace 'out tomohara-aliases.bash'
## DEBUG: echo 'out tomohara-aliases.bash'
