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
# - Selectively ignore following shellcheck warnings
#    -- SC2016: (info): Expressions don't expand in single quotes
#    -- SC2046: Quote this to prevent word splitting
#    -- SC2086: Double quote to prevent globbing and word splitting.
#    -- SC2155: Declare and assign separately to avoid masking return values
#    -- SC2139: This expands when defined, not when used. Consider escaping.
#
# TODO:
# - ***** Put work-specific stuff in separate file!"
# - **** Add EX-bases tests for all numeric aliases!
# - ***** Fix problems noted by shellcheck (and rework false positives)!.
# - *** Indent [maldito] shell-check blocks.
# - ** Add macros to provide cribsheet on usage!
# - *** Purge way-old stuff (e.g., lynx related)!
# - ** Add option to move alias not to put files in subdirectory of target directory. That is, the move command aborts rather than doing following: 'move sub-dir target-dir' ==> target-dir/sub-dir/sub-dir).
# - ** Minimize overriding commands like 'cd' and 'script' to avoid confusion.
# - ** Likewise non-standard usages for variables like 'PS1' (e.g., via 'PS_symbol').
# - * Drop support for solaris and remove BAREBONES_HOST support.
# - Get rid of old-work junk (e.g., Intemass, Juju, and JSL)!
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
#

# For debugging: Uncomment the following line(s)
## DEBUG: echo in tomohara-aliases.bash 1>&2
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
	    # SC2046 [Quote this to prevent word splitting], and SC2086 [Double quote to prevent globbing and word splitting].
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
    eval "function $alias { $command" '"$@"' "; }"
}
#................................................................................
# General environment settings
## TOM-IDIOSYNCRATIC
## OLD: cond-export DEBUG_LEVEL 4
cond-export DEBUG_LEVEL 3

#...............................................................................
# Directory for Tom O'Hara's scripts, defaulting to /home/tomohara if available
# otherwise $HOME/bin
## TOM-IDIOSYNCRATIC
## DEBUG: 
## OLD: cond-export TOM_DIR "/home/tomohara"
# Note: ${BASH_SOURCE[0]}" is the scirpt being sourced. The array itself gives
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
#
alias trace='startup-trace'
alias enable-startup-tracing='export STARTUP_TRACING=1'
alias disable-startup-tracing='export STARTUP_TRACING=0'
alias enable-console-tracing='export CONSOLE_TRACING=1'
alias disable-console-tracing='export CONSOLE_TRACING=0'

# Helper functions (along with aliases and variables)
#
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
# todays-date(): outputs date in format DDmmmYY (e.g., 22apr20)
## TODO: drop leading digits in day of month
## NOTE: keep in synch with common.perl get_file_ddmmmyy and .emacs edit-adhoc-notes-file
function todays-date { date '+%d%b%y' | downcase-stdin; }
# todays-date-mmmYY(): date in format mmmYY (e.g., sep20)
function todays-date-mmmYY { todays-date | perl -pe 's/^\d\d//;'; }
## OLD
## todays_date=$(todays-date)
## MISC:
## # Convenience alias and bash variable for better tab-completion
## OLD
alias hoy=todays-date
hoy=$(todays-date)
# Note: version so Spanish not used in note files
# TODO: punt on tab-completion (i.e., TODAY => today)???
alias TODAY=todays-date
alias date-central='TZ="America/Chicago" date'

## TOM-IDIOSYNCRATIC
# em-adhoc-notes(): edit adhoc notes file using format _{dir}-notes-{host}-{date} (e.g., _bin-notes-reempl-may22.txt)
## OLD: em-adhoc-notes(): edit adhoc notes file using format _{host}-adhoc-{date} (e.g., _reempl-adhoc-notes.13may22.txt)
## OLD: alias em-adhoc-notes='emacs-tpo _adhoc-notes.$(TODAY).txt'
## OLD: alias em-adhoc-notes='emacs-tpo _${HOST_NICKNAME:misc}-adhoc-notes-$(TODAY).txt'
## BAD: alias-fn em-adhoc-notes 'emacs-tpo _${HOST_NICKNAME:misc}-adhoc-notes-$(todays-date-mmmYY).txt'
## OLD: function em-adhoc-notes { emacs-tpo "_${HOST_NICKNAME:misc}-adhoc-notes-$(todays-date-mmmYY).txt"; }
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
## OLD:
reference-variable "$hoy, $T"
## TODO: reference-variable $hoy, $T

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
set bell-style none
export HISTCONTROL=ignoredups
export HISTTIMEFORMAT='[%F %T] '
# Ensure that the history files are merged (n.b., timestamping required for
# proper sequencing of entries from different shell windows).
set histappend
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

## OLD
## 
## # Ensure OSTYPE environment variable for script usage
## if [ "$(printenv OSTYPE)" = "" ]; then
##     export OSTYPE="$OSTYPE";
## fi
## 
## # Fixup for Linux OSTYPE setting (likewise for solaris)
## # TODO: use ${OSTYPE/[0-9]*/}
## # TODO: use OSTYPE_BRIEF instead of trumping environment
## case "$OSTYPE" in linux-*) export OSTYPE=linux; esac
## case "$OSTYPE" in solaris*) 
##      export OSTYPE=solaris; 
##      alias printenv='printenv.sh'
## esac

# under-macos() => boolean: whether running under maldito macintosh
# EX: (under-macos; wc -l /vmlinuz 2> /dev/null) =/=> $'0\n1'
function under-macos {
    local under_mac=0
    if [[ "$OSTYPE" =~ darwin.* ]]; then under_mac=1; fi
    ## TODO: return $under_mac
    echo "$under_mac"
}
function under-linux {
    local under_linux=0
    if [[ "$OSTYPE" =~ linux.* ]]; then under_linux=1; fi
    ## TODO: return $under_linux
    echo "$under_linux"
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
export LESS="-cFIX-P--Less-- ?f%f:(stdin). ?e(END):?pb(%pb\%) ?m(%i of %m)..%t"
# Disables full-screen repaints under minimal-installation hosts (e.g., Beowolf nodes)
if [ "$BAREBONES_HOST" = "1" ]; then export LESS="-cIX-P--Less-- ?f%f:(stdin). ?e(END):?pb(%pb\%) ?m(%i of %m)..%t"; fi
## OLD:
## export LESSCHARSET=latin1
export PAGER=less
export PAGER_CHOPPED="less -S"
export PAGER_NOEXIT="less -+F"
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
export ZPAGER=zless

#-------------------------------------------------------------------------------
trace start of main settings

# Path settings
# TODO: define a function for removing duplicates from the PATH while
# preserving the order
function show-path-dir () { (echo "${1}:"; printenv "$1" | perl -pe "s/:/\n/g;") | $PAGER; }
alias show-path='show-path-dir PATH'
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
## OLD: function prepend-path () { if [[ ! (($PATH =~ ^$1:) || ($PATH =~ :$1:) || ($PATH =~ :$1$)) ]]; then export PATH="$1:${PATH}"; fi }
#
function append-path-force () { export PATH="${PATH}:$1"; }
function prepend-path-force () { export PATH="$1:${PATH}"; }
alias prepend-path=prepend-path-force

# TODO: rework append-/prepend-path and python variants via generic helper
function append-python-path () { export PYTHONPATH=${PYTHONPATH}:"$1"; }
function prepend-python-path () { export PYTHONPATH="$1":${PYTHONPATH}; }

## OLD:
## # TODO: develop a function for doing this
## if [ "$(printenv PATH | $GREP "$TOM_BIN":)" = "" ]; then
##    export PATH="$TOM_BIN:$PATH"
## fi
## if [ "$(printenv PATH | $GREP "$TOM_BIN/${OSTYPE}":)" = "" ]; then
##    export PATH="$TOM_BIN/${OSTYPE}:$PATH"
## fi
## # TODO: make optional & put append-path later to account for later PERLLIB changes
## append-path "$PERLLIB"
## ## OLD (see below): prepend-path "$HOME/python/Mezcla/mezcla"
## append-path "$HOME/python"
## # Put current directoy at end of path; can be overwritting with ./ prefix
## export PATH="$PATH:."
## # Note: ~/lib only used to augment existing library, not pre-empt
## ## OLD: export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/lib:$HOME/lib/linux
## export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/lib:$HOME/lib/$OSTYPE

#-------------------------------------------------------------------------------
# Bash stuff (settings, etc.)
#
# FIGNORE: A colon-separated list of suffixes to ignore when performing filename completion ("tab completion")
export FIGNORE=".o:.fasl:.fas:.lib"
## TEST: export FIGNORE=".o:.fasl:.fas:.lib:.log"
## TODO: figure out how to exlcude .log for executable-tab-expansion (e.g., first position)
export FIGNORE=".o:.fasl:.fas:.lib"
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
# TODO: Put settings in .bashrc, so that trace could use TEMP.
cond-export TEMP "$HOME/temp"
## HACK: don't allow /tmp for TMP
## TODO1: move TMP, etc. into tomohara-settings.bash
if [ "$TMP" = "/tmp" ]; then unset TMP; fi
cond-export TMP "$TEMP/tmp"
cond-export TMPDIR "$TMP"
mkdir -p "$TEMP" "$TMP" "$TMPDIR"
# NOTE: LINE and COLUMNS are in support of ps_sort.perl and h (history).
# They get reset via resize.
cond-export LINES 52
cond-export COLUMNS 80
#
# NOTE: resize used to set LINES below

if [ "$DOMAIN_NAME" = "" ]; then
    # shellcheck disable=SC2155
    # TODO: cond-export
    export DOMAIN_NAME=$(domainname.sh);
fi
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
## TODO: resolve interaction among 'reset-prompt', 'script' and 'add-conda-env-to-xterm-title' (see anacdonda-aliases.bash for latter)
cond-export PS_symbol '$'
function reset-prompt {
    ## DEBUG: echo "reset-prompt" "$@"
    local new_PS_symbol="$*"
    ## OLD:
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
alias reset-prompt-dollar='reset-prompt "\$"'
## OLD: alias reset-prompt-default="reset-prompt '$PS_symbol'"
{
    # shellcheck disable=SC2139
    alias reset-prompt-default="reset-prompt '$PS_symbol'"
}
## TODO: alias reset-prompt-default='reset-prompt "\$PS_symbol"'

# rehash(): reset locations for programs
alias rehash='hash -l' 

#-------------------------------------------------------------------------------
# More misc stuff
## TOM-IDIOSYNCRATIC

# reset CDPATH to just current directory
export CDPATH=.

## OLD
## # Just use $ for Bash prompt
## # NOTE: cd override puts directory name in xterm title
## OLD: reset-prompt
##

## OLD:
## NOTE: This was causing problems with the Jupyter bash kernel
## as it modifies prompt for parsing purposes.
## # If interactive session, change prompt to $PS1 (via $PS_symbol).
## # Note: directory is instead put in xterm title (via set_xterm_title.bash)
## if [[ $- =~ i ]]; then reset-prompt; fi

# flag for turning off GNOME, which can be flakey at times
# See xterm.sh (e.g., gnome-terminal).
export USE_GNOME=1

# General Settings for my scripts
## OLD: export DEBUG_LEVEL=2
export PRECISION=3
alias debug-on='export DEBUG_LEVEL=3'
if [ "$PERLLIB" = "" ]; then PERLLIB="."; else PERLLIB="$PERLLIB:."; fi
# NOTE: perl uses architecture-specific subdirectories under PERLLIB
export PERLLIB="$TOM_BIN:$PERLLIB:$HOME/perl/lib/perl5/site_perl/5.8"
# HACK: not all cygwin directories being recognized
export PERLLIB="$HOME/perl/lib/perl5/5.16:$HOME/perl/lib/perl5/5.16/vender_perl:$PERLLIB"
alias perl-='perl -Ssw'
export MANPATH="$HOME/perl/share/man/man1:$MANPATH"
append-path "$HOME/perl/bin"
# Note: TIME is used for changing output format, so TIME_CMD used instead.
# TODO: Do check for environment variable overlap (as with DEBUG_LEVEL clash with software
# used at Convera).
## OLD: export TIME_CMD=/usr/bin/time
## BAD: export TIME_CMD="command time"
# note: command is a binary under MacOs but just a shell builtin under Linux
export TIME_CMD="command time"
if [ "$(which "command" 2> /dev/null)" == "" ]; then
    export TIME_CMD=/usr/bin/time
fi
export PERL="$NICE $TIME_CMD perl -Ssw"
## OLD: export BRIEF_USAGE=1

# Terminal window title
alias set-xterm-title='set_xterm_title.bash'
alias set-xterm-window='set-xterm-title'
# Set the title for the current xterm, unless if not running X
function set-title-to-current-dir () { 
    local dir
    dir=$(basename "$PWD"); 
    local other_info=""; 
    if [ "$CLEARCASE_ROOT" != "" ]; then other_info="; $other_info cc=$CLEARCASE_ROOT"; fi
    set-xterm-window "$dir [$PWD]$other_info";
    ## Note: until VM setup for current client, the symbol is put before the directory basename.
    ## TEST: set-xterm-window "$PS_symbol $dir [$PWD]$other_info";
    ## TODO: set-xterm-window "$dir [$PS_symbol$PWD]$other_info";
}
if [[ ("$TERM" = "xterm") || ("$TERM" = "cygwin") ]]; then set-title-to-current-dir; fi
#
alias reset-xterm-title='set-xterm-window "$HOSTNAME $PWD"'
## OLD: quiet-unalias alt-xterm-title
# alt-xterm-title([prefix=alt]): change xterm title to PREFIX DIR-BASENAME [PWD]
function alt-xterm-title() { 
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
## OLD: alias cls='clear'
## NOTE: Unfortunately clear clobbers the terminal scrollback buffer.
## via https://askubuntu.com/questions/792453/how-to-stop-clear-from-clearing-scrollback-buffer:
##    type CTRL+L instead of clear
## TAKE1: alias cls="printf '\33[H\33[2J'"
##   where \33 is octal code for Escape (i.e., 0x1B)
## TAKE2
## OLD: alias clear="echo 'use cls instead (or /bin/clear)'"
alias clear="echo 'use cls instead (or command clear)'"
alias cls="command clear -x"
{
    # TODO: see if this is a shellcheck bug
    #    SC2034: MV appears unused. Verify it or export it.
    # shellcheck disable=SC2034
    ## OLD: MV="/bin/mv -i $other_file_args"
    MV="command mv -i $other_file_args"
}
alias mv='$MV'
alias move='mv'
alias move-force='move -f'
# TODO: make sure symbolic links are copied as-is (ie, not dereferenced)
## OLD: CP="/bin/cp -ip $other_file_args"
CP="command cp -ip $other_file_args"
reference-variable "$CP"
alias copy='$CP'
## OLD
## alias copy-force='/bin/cp -fp $other_file_args'
## alias cp='/bin/cp -i $other_file_args'
## alias rm='/bin/rm -i $other_file_args'
## alias delete='/bin/rm -i $other_file_args'
alias del="delete"
alias copy-force='command cp -fp $other_file_args'
alias cp='command cp -i $other_file_args'
# maldito shellcheck bug: SC2032: Use own script or sh -c '..' to run this from find
# shellcheck disable=SC2032
alias rm='command rm -i $other_file_args'
alias delete='command rm -i $other_file_args'
## OLD: alias delete-force='/bin/rm -f $other_file_args'
# shellcheck disable=SC2034
{
force_echo=""
newline_tab=$'\n\t'
# TODO1: fix newline/tab support
alias disable-forced-deletions='force_echo="echo Warning: run enable-forced-deletions or issue:$newline_tab"'
alias enable-forced-deletions='force_echo=""'
}
disable-forced-deletions
#
## OLD
## alias delete-force='$force_echo /bin/rm -f $other_file_args'
alias delete-force='$force_echo command rm -f $other_file_args'
#
alias remove-force='delete-force'
# TODO: make sure that rellowing only applied to directories
## OLD: alias remove-dir='/bin/rm -rv'
alias remove-dir='command rm -rvi'
alias delete-dir='remove-dir'
## OLD
## alias remove-dir-force='/bin/rm -rfv'
## alias delete-dir-force='remove-dir-force'
## OLD: alias remove-dir-force='$force_echo /bin/rm -rfv'
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
    # maldito shellcheck (SC2086: Double quote to prevent globbing)
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
export NICE="nice -19"
## DUPLICATE: export TIME_CMD="/usr/bin/time"

alias fix-dir-permissions="find . -type d -exec chmod go+xs {} \;"

#-------------------------------------------------------------------------------
trace directory commands

# Support for ls (list directory contents)
# 
# ls options: # --all: all files; -l long listing; -t by time; --human-readable: uses numeric suffixes like MB; --no-group: omit file permision group; --directory: no subdirectory listings.
# TODO: Add --long as alias for -l to ls source control and check-in [WTH?]! Likweise, all aliases for other common options without long names (e.g., -t).
#
## OLD: LS="/bin/ls"
LS="command ls"
core_dir_options="--all -l -t  --human-readable"
dir_options="${core_dir_options} --no-group"
# maldito shellcheck: SC2046 [Quote this to prevent word splitting] and SC2086 [Double quote to prevent globbing]
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
# subdirs-proper(): shows subdirs in colymn format omitting ones w/ leading dots
# note: omits cases like ./ and ./.cpan from find and then removes ./ prefix
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
## OLD: alias symlinks-proper='symlinks | cut --characters=43-'
#
## OLD: function sublinks-proper { sublinks "$@" | cut --characters=42-  | $PAGER; }
## BAD
## ls_filename_col=40
## if [ "$(under-macos)" = "1" ]; then ls_filename_col=42; fi
## function sublinks-proper { sublinks "$@" | cut --characters=${ls_filename_col}-  | $PAGER; }
## example: "lrwxrwxrwx   1 tomohara tomohara   20 2023-06-23 16:50 mezcla -> python/Mezcla/mezcla"
##           1            2 3        4          5  6          7     8
function ls-long-tsv { ls -l --time-style=long-iso "$@" | perl -pe 's/ +/\t/g;'; }
function sublinks-proper { ls-long-tsv "$@" | $GREP ^l | cut.perl -fields="8-" - | tr $'\t' ' ' | $PAGER; }
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

# Grep settings
# TODO: use gr and gr_ throughout for consistency
# TODO: use -P flag (i.e.,  --perl-regexp) w/ grep rather than egrep
# Notes:
# - MY_GREP_OPTIONS used instead of GREP_OPTIONS since grep interprets latter
#   -n       show line numbers
#   -d skip  skip directories (i.e., don't treat as files)
#   -s       suppress error messages (e.g., unreadable files)
#   -E       extended regex support (i.e., old egrep)
# - /bin/grep used to avoid alias and to allow for use with exec
# - egrep is normally used unless the pattern will never use extended regex's
## TODO: quiet-unalias grep
## TODO: add alias for resolving grep binary with fallback to "command grep"
## OLD: GREP="/bin/grep"
GREP="command grep"
## NOTE: -E is --extended-regexp
## OLD: EGREP="$GREP -E"
EGREP="$GREP --perl-regexp"
export MY_GREP_OPTIONS="-n $skip_dirs -s"
# maldito shellcheck (SC2086: Double quote to prevent globbing)
# shellcheck disable=SC2086
{
function gr () { $GREP $MY_GREP_OPTIONS -i "$@"; }
function gr- () { $GREP $MY_GREP_OPTIONS "$@"; }
SORT_COL2="--key=2"
# grep-unique(pattern, file, ...): count occurrence of pattern in file...
function grep-unique () { $EGREP -c $MY_GREP_OPTIONS "$@" | $GREP -v ":0$" | sort -rn $SORT_COL2 -t':'; }
# grep-missing(pattern, file, ...): show files without pattern 
# TODO: archive
function grep-missing () { $EGREP -c $MY_GREP_OPTIONS "$@" | $GREP ":0"; }
alias gu='grep-unique -i'
## OLD
## alias gru='gu'
alias gu-='grep-unique'
# gu-all: run gu over all files in current dir
# TODO: archive
function gu-all () { grep-unique "$@" ./* | $PAGER; }
#
function gu- () { $GREP -c $MY_GREP_OPTIONS "$@" | $GREP -v ":0"; }
#
# grepl(pattern, [other_grep_args]): invokes grep over PATTERN and OTHER_GREP_ARGS and then pipes into less for PATTERN
# NOTE: actually uses egrep
# TODO: use more general way to ensure pattern given last while readily extractable for less -p usage
## OLD: function grep-to-less () { $EGREP $MY_GREP_OPTIONS "$@" | $PAGER_NOEXIT -p"$1"; }
function grep-to-less () {
    # TODO: fix warning about possible discrepency between grep regex and less, such as when ^ used (e.g., with multiple files in grep output)
    if [[ ($1 =~ ^[^]) && ($# -gt 2) ]]; then
	echo "Error: ^ will be intrepretted differently by less (e.g., due to multiple files)" 1>&2
    else
	$EGREP $MY_GREP_OPTIONS "$@" | $PAGER_NOEXIT -p"$1";
    fi
}
alias grepl-='grep-to-less'
function grepl () { pattern="$1"; shift; grep-to-less "$pattern" -i "$@"; }
}

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
alias grep-nonascii='perlgrep.perl "[\x80-\xFF]"'

# Searching for files
# TODO:
# - specify find options in an environment variable
# - rework in terms of Perl regex? (or use -iregex in place of -iname)
#
# Ignores shellcheck SC2086 [Double quote to prevent globbing] in find aliases.
# shellcheck disable=SC2086
{         # start shellcheck block
## OLD: function findspec () { if [ "$2" = "" ]; then echo "Usage: findspec dir glob-pattern find-option ... "; else /usr/bin/find $1 -iname \*$2\* $3 $4 $5 $6 $7 $8 $9 2>&1 | $GREP -v '^find: '; fi; }
function findspec () { if [ "$2" = "" ]; then echo "Usage: findspec dir glob-pattern find-option ... "; else command find $1 -iname \*$2\* $3 $4 $5 $6 $7 $8 $9 2>&1 | $GREP -v '^find: '; fi; }
# findspec[-all](dir, pattern, option): find files in directory tried, optionally following links (-all)
## OLD: function findspec-all () { /usr/bin/find $1 -follow -iname \*$2\* $3 $4 $5 $6 $7 $8 $9 -print 2>&1 | $GREP -v '^find: '; }
function findspec-all () { command find $1 -follow -iname \*$2\* $3 $4 $5 $6 $7 $8 $9 -print 2>&1 | $GREP -v '^find: '; }
function fs () { findspec . "$@" | $EGREP -iv '(/(backup|build)/)'; } 
function fs-ls () { fs "$@" -exec ls -l {} \; ; }
alias fs-='findspec-all .'
function fs-ext () { find . -iname \*."$1" | $EGREP -iv '(/(backup|build)/)'; } 
# TODO: extend fs-ext to allow for basename pattern (e.g., fs-ext java ImportXML)
function fs-ls- () { fs- "$@" -exec ls -l {} \; ; }
#
findgrep_opts="-in"
#
# NOTE: findgrep macros use $findgrep_opts dynamically (eg, user can change $findgrep_opts)
function findgrep-verbose () { find "$1" -iname \*"$2"\* -print -exec $GREP $findgrep_opts "$3" $4 $5 $6 $7 $8 $9 \{\} \;; }
# findgrep(dir, filename_pattern, line_pattern): $GREP through files in DIR matching FILENAME_PATTERN for LINE_PATTERN
function findgrep () { find $1 -iname \*"$2"\* -exec $GREP $findgrep_opts "$3" $4 $5 $6 $7 $8 $9 \{\} /dev/null \;; }
# TODO: archive
function findgrep- () { find $1 -iname $2 -print -exec $GREP $findgrep_opts "$3" $4 $5 $6 $7 $8 $9 \{\} \;; }
function findgrep-ext () { local dir="$1"; local ext="$2"; shift; shift; find "$dir" -iname "*.$ext" -exec $GREP $findgrep_opts "$@" \{\}  /dev/null \;; }
# fgr(filename_pattern, line_pattern): $GREP through files matching FILENAME_PATTERN for LINE_PATTERN
function fgr () { findgrep . "$@" | $EGREP -v '((/backup)|(/build))'; }
function fgr-ext () { findgrep-ext . "$@" | $EGREP -v '(/(backup)|(build)/)'; }
alias fgr-py='fgr-ext py'
## OLD: }
#
# prepare-find-files-here([--out-dir out_dir_spec]): produces listing(s) of files in current directory
# tree, in support of find-files-here; this contains full ls entry (as with -l).
# (The subdirectory listings produced by 'ls -alR' are preceded by blank lines,
# which is required for find-files-here as explained below.)
# Notes: Also puts listing proper in ls-aR.list (i.e., just list of files).
# TODO: create external script and have alias call the script
# Ignores SC2068: Double quote array expansions
function prepare-find-files-here () {
    local dir="."
    if [ "$1" = "--out-dir" ]; then
	dir="$2"
	shift 2;
	mkdir -p "$dir"
    fi
    if [ "$1" != "" ]; then
        echo "Error: No arguments accepted; did you mean find-files-here?"
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
function find-files-there () { perlgrep.perl -para -i "$@" | $EGREP -i '((:$)|('"$1"'))' | $PAGER_NOEXIT -p "$1"; }
function find-files-here () { find-files-there "$1" "$PWD/ls-alR.list"; }
# following variants for sake of tab completion
alias find-files='find-files-here'
alias find-files-='find-files-there'
# TODO: function find-files-dated () { perlgrep.perl -para -i "$@" | $EGREP -i '((:$)|('$1'))' | $PAGER_NOEXIT -p "$1"; }
#
# TODO: add --quiet option to dobackup.sh (and port to bash)
# TODO: function conditional-backup() { if [ -e backup/"$1" ]; then dobackup.sh "$1"; fi; }
## OLD: alias make-file-listing='listing="ls-aR.list"; dobackup.sh "$listing"; $LS -aR >| "$listing" 2>&1'
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
## OLD: alias emacs-tpo='tpo-invoke-emacs.sh'
## TODO: alias-fn emacs-tpo 'tpo-invoke-emacs.sh'
function emacs-tpo { tpo-invoke-emacs.sh "$@"; }
## OLD: alias em=emacs-tpo
alias-fn em tpo-invoke-emacs.sh
# em-fn(font, [file ...]): invoke emcas with specified font
function em-fn () { em -- -fn "$@"; }
alias em-tags=etags
#
## alias em-large='em-fn "-DAMA-Ubuntu Mono-normal-normal-normal-*-24-*-*-*-m-0-iso10646-1"'
## OLD: alias em-large='em-fn "-DAMA-Ubuntu Mono-normal-normal-normal-*-28-*-*-*-m-0-iso10646-1"'
## OLD: function em-large { em-fn "-DAMA-Ubuntu Mono-normal-normal-normal-*-28-*-*-*-m-0-iso10646-1" "$@"; }
## Note: Bash construct ${VAR:-VAL} use VAL if VAR not defined, and here VAL starts with -!
## TODO?: cond-export EMACS_LARGE_FONT "-DAMA-Ubuntu\\ Mono-normal-normal-normal-*-24-*-*-*-m-0-iso10646-1"
##
## HACK: uses <space> due to stupid shell tricks (see tpo-invoke-emacs.sh)
## cond-export EMACS_LARGE_FONT "-DAMA-Ubuntu<space>Mono-normal-normal-normal-*-24-*-*-*-m-0-iso10646-1"
cond-export EMACS_LARGE_FONT "-DAMA-Ubuntu Mono-normal-normal-normal-*-24-*-*-*-m-0-iso10646-1"
cond-export EMACS_OPTIONS ""
function em-large-default { export EMACS_OPTIONS="$EMACS_OPTIONS -fn '$EMACS_LARGE_FONT'"; }
function em-large { em-fn "$EMACS_LARGE_FONT" "$@"; }
alias em-nw='emacs -l ~/.emacs --no-windows'
## TODO: alias em-tpo='emacs -l ~/.emacs'
alias em-tpo-nw='emacs -l ~/.emacs --no-windows'
alias em_nw='em-nw'
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
## OLD:
## function em-debug () { em --debug-init "$@"; }
## function em-quick () { em --quick "$@"; }
function em-debug () { em -- --debug-init "$@"; }
function em-quick () { em -- --quick "$@"; }

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
    perl -SSw reverse.perl "$HOME/organizer/todo_list.text" | $PAGER_CHOPPED $search_arg; 
}
}
# maldito shellcheck: SC2119 [Use ... "$@" if function's $1 should mean script'1 $1]
# and SC2181 [Check exit code directly]
# shellcheck disable=SC2119,SC2181
{
function add-todo () { echo "$@" $'\t'"$(date)" >> "$HOME/organizer/todo_list.text"; if [ "$?" = "0" ]; then view-todo; fi; }
}
#
function todo-one-week () { add-todo "[within 1 week] " "$@"; }
#
function todo () { if [ "$1" == "" ]; then echo add-todo '"[within N weeks] ..."'; else todo-one-week "$@"; fi; }
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
function perl-calc () { perl- perlcalc.perl -args "$@"; }
# TODO: read up on variable expansion in function environments
function perl-calc-init () { initexpr="$1"; shift; echo "$@" | perl- perlcalc.perl -init="$initexpr" -; }
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
# - The number must be preceded by a word boundary and followed by whitespace.
# This was added in support of the usage function (e.g., numeric subdirectory names).
# TODO:
# - Convert to Perl script to avoid awkward bash command line construction.
# - Make the trailing context a word-boundry as well (rather than whitespace).
# EX: echo "1024 1572864 1073741824" | apply-numeric-suffixes => 1K 1.5M 1G
# EX: echo "1024 1572864 1073741824" | apply-numeric-suffixes 1 => 1K 1572864 1073741824
function apply-numeric-suffixes () {
    local just_once="$1"
    local g="g";
    if [ "$just_once" = "1" ]; then g=""; fi
    # TODO: make only sure the first number is converted if just-once applies
    # NOTE: 3 args to sprintf: coefficient, KMGT suffix, and post-context
    ## DEBUG; perl -pe '$suffixes="_KMGT";  s@\b(\d{4,15})(\s)@$pow = log($1)/log(1024);  $new_num=($1/1024**$pow);  $suffix=substr($suffixes, $pow, 1);  print STDERR ("s=$suffixes p=$pow nn=$new_num l=$suffix\n"); sprintf("%.3g%s%s", $new_num, $suffix, $2)@e'"$g;"
    perl -pe '$suffixes="_KMGT";  s@\b(\d{4,15})(\s)@$pow = int(log($1)/log(1024));  $new_num=($1/1024**$pow);  $suffix=substr($suffixes, $pow, 1);  sprintf("%.3g%s%s", $new_num, $suffix, $2)@e'"$g;"
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
## TODO: output header (e.g., "num-blocks<TAB>dir    # note: blocksize is 1k")
# usage(): Shows usage for current directory with block size converted to bytes with
#
# default_assignment(value1, value2): return VALUE1 if defined else VALUE2
# TODO: echo $([ $1 ] && echo $1 || echo $2)
# See https://unix.stackexchange.com/questions/126706/bashs-conditional-operator-and-assignment.
function default_assignment {
    local result="$1"
    if [ "$result" = "" ]; then result="$2"; fi
    echo "$result"
}
#
function usage {
    ## TODO: output_file=(("$1"||"usage.list"));
    output_file=$(default_assignment "$1" "usage.list")
    rename-with-file-date "$output_file";
    $NICE du --block-size=1K --one-file-system 2>&1 | $NICE sort -rn | apply-usage-numeric-suffixes >| "$output_file" 2>&1;
    $PAGER "$output_file";
}
function usage-alt {
    local output_file
    local basename
    basename="$(basename "$PWD")"
    ## OLD: if [ "$basename" = "" ]; then basename="fs-root"; fi
    if [[ ("$basename" = "") || ("$basename" = "/") ]]; then basename="fs-root"; fi
    output_file="$TEMP/$basename-usage.list";
    usage "$output_file"
}

function byte-usage () { output_file="usage.bytes.list"; backup-file $output_file; $NICE du --bytes --one-file-system 2>&1 | $NICE sort -rn | apply-usage-numeric-suffixes >| $output_file 2>&1; $PAGER $output_file; }
## TODO: function usage () { du --one-file-system --human-readable 2>&1 | sort -rn >| usage.list 2>&1; $PAGER usage.list; }

# check-errors(LOG-FILE): in check for known errors in LOG-FILE...
# also: check-all-errors|warnings: variants including more patterns and with warnings subsuming errors.
# HACK: quiet added to disable filename with multiple files
function check-errors-aux { check_errors.perl "$@"; }
## # -or-:
## function check-errors-aux { PERL_SWITCH_PARSING=1 check_errors.py "$@"; };
# note: ALIAS_DEBUG_LEVEL is global for aliases and functions which should use default DEBUG_LEVEL (e.g., 2), not current (e.g., 4)
ALIAS_DEBUG_LEVEL=${DEBUG_LEVEL}
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
    ## OLD: (QUIET=1 DEBUG_LEVEL=$ALIAS_DEBUG_LEVEL CONTEXT=5 check-errors-aux ${args[@]}) 2>&1 | $PAGER;
    (QUIET=1 DEBUG_LEVEL=$ALIAS_DEBUG_LEVEL CONTEXT=5 check-errors-aux "${args[@]}") 2>&1 | $PAGER;
}
## OLD:
## alias check-all-errors='check-errors -warnings'
## alias check-warnings='echo "*** Error: use check-all-errors instead ***"; echo "    check-all-errors"'
# note: with -relaxed, the pattern matching is looser (hence more errors show)
alias check-all-errors='check-errors -relaxed'
alias check-warnings='check-errors -warnings -strict'
alias check-all-warnings='check-all-errors -warnings -relaxed'
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
    
    # Show tail unless same as head
    # note: disables SC2181 [Check exit code directly]
    # shellcheck disable=SC2181
    if [ $? != 0 ]; then
        echo "\$?=$?"
        cat "$tail";
    fi
}
}         # end shellcheck block

# Note: various aliases for doing diff-based comparisons
#
function tkdiff () { wish -f "$TOM_BIN"/tkdiff.tcl "$@" & }
alias rdiff='rev_vdiff.sh'
alias tkdiff-='tkdiff -noopt'
#
## OLD: function kdiff () { kdiff.sh "$@" & }
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
# maldito shellcheck: SC2034: diff_options appears unused. Verify it or export it.
# shellcheck disable=SC2034
{
diff_options="--ignore-space-change --ignore-blank-lines"
alias diff='command diff $diff_options'
}
alias diff-default='command diff'
alias diff-ignore-spacing='diff --ignore-all-space'
#
# do-diff(): wrapper into do_diff.sh, which allows for glob patterns of current vs target dirs
alias do-diff='do_diff.sh'
#
function diff-rev () {
    local diff_program="diff"
    if [ "$1" = "--diff-prog" ]; then
        diff_program="$2"
        shift 2
    fi
    local right_file="$1"
    local left_file="$2"
    if [ -d "$left_file" ]; then left_file="$left_file"/$(basename "$right_file"); fi
    # TODO: create helper for resolving one file relative to dir of another
    ## BAD: if [ ! -e "$left_file" ]; then left_file=$(dirname "$right_file")/"$left_file"; fi
    "$diff_program" "$left_file" "$right_file"
}
alias kdiff-rev='diff-rev --diff-prog kdiff'
alias diff-log-output='compare-log-output.sh'
alias vdiff-rev=kdiff-rev

# most-recent-backup(file): returns most recent backup for FILE in ./backup, accounting for revisions (e.g., extract_matches.perl.~4~)
function most-recent-backup {
    if [ "$1" = "" ]; then
        echo "usage: most-recent-backup filename"
        echo "use BACKUP_DIR=dir ... to override use of ./backup"
        return
    fi
    local file="$1";
    local dir="$BACKUP_DIR"; if [ "$dir" = "" ]; then dir=./backup; fi
    ## OLD: $LS -t $dir/* | $EGREP "/$file(~|.~*)?" | head -1;
    ## TODO: rework to avoid false positives
    $LS -t $dir/* $dir/.* | $EGREP "/$file(~|.~*)?" | head -1;
}
# TODO: test for dot-files:
#   touch backup .fubar.~666~; most-recent-backup .fubar => .fubar
#
# diff-backup(file): compare FILE vs. most recent backup
# TODO: fix handling of dot files
function diff-backup-helper {
    local diff="$1"; local file="$2";
    local backup_file
    backup_file="$(most-recent-backup "$file")"
    if [ "$backup_file" = "" ]; then
	echo "Error: no backup for '$file'"
    else 
	echo "Issuing: '$diff' '$backup_file' '$file'"
	"$diff" "$backup_file" "$file";
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
alias cell-signature='signature cell'
alias home-signature='signature home'
alias po-signature='signature po'
alias tpo-signature='signature tpo'
alias tpo-scrappycito-signature='signature tpo-scrappycito'
alias scrappycito-signature='signature scrappycito'
alias farm-signature='signature farm'
alias circulo-signature='signature circulo'
# TODO: automatically derive aliases for ~/info/*.signature*

#-------------------------------------------------------------------------------
trace file archiving commands

# Tar archive creation and manipulation
# tar options:
# -x extract; -v verbose; -f file source; -z compressed; -k don't overwrite files
## NOTE: gtar is used on some BSD-based system (e.g., MacOS), but tar is used on Linux.
## OLD: GTAR="tar"
GTAR="tar"
if [ "$(which gtar)" != "" ]; then
    GTAR="gtar"
fi
if [[ ! $($GTAR --version) =~ GNU ]]; then
    echo "Warning: GNU tar not available" 1>&2
fi
alias gtar='$GTAR'
#
# ls-relative(file): show pathname of FILE relative to $HOME (e.g., ~/xfer/do_setup.bash)
function ls-relative () { $LS -d "$1" | perl -pe "s@$HOME@~@;"; }
#
# make-tar(archive_basename, [dir=.], [depth=max], [filter=pattern]): tar up directory with results placed 
#   in archive_base.tar.gz and log file in archive_base.tar.log; afterwards display the tar archive size, log contents, and archive path.
# Filenames matching the optional filter are excluded.
# EX: make-tar ~/xfer/program-files-structure 'C:\Program Files' 1
#   
# Note: -xdev is so that find doesn't use other file systems
find_options="-xdev"
function make-tar () { 
    local base="$1"; local dir="$2"; local depth="$3"; local filter="$4";
    local depth_arg=""; local filter_arg="."
    local size_arg="";
    if [ "$dir" = "" ]; then dir="."; fi;
    if [ "$depth" != "" ]; then depth_arg="-maxdepth $depth"; fi;
    if [ "$filter" != "" ]; then filter_arg="-v $filter"; fi;
    if [ "$USE_DATE" = "1" ]; then base="$base-$(TODAY)"; fi
    if [ "$MAX_SIZE" != "" ]; then size_arg="-size -${MAX_SIZE}c"; fi
    # TODO: make pos-tar ls optional, so that tar-in-progress is viewable
    ## OLD:
    # maldito shellcheck: SC2086 [Double quote to prevent globbing and word splitting]
    # shellcheck disable=SC2086
    ## OLD: (find "$dir" $find_options $depth_arg -not -type d -print | $GREP -i "$filter_arg" | $NICE $GTAR cvfTz "$base.tar.gz" -) >| "$base.tar.log" 2>&1;
    (find "$dir" $find_options $depth_arg $size_arg -not -type d -print | $GREP -i "$filter_arg" | $NICE $GTAR cvfTz "$base.tar.gz" -) >| "$base.tar.log" 2>&1;
    ## DUH: -L added to support tar-this-dir in directory that is symbolic link, but unfortunately
    ## that leads to symbolic links in the directory itself to be included
    ## BAD: (find -L "$dir" $find_options $depth_arg -not -type d -print | egrep -i "$filter_arg" | $NICE $GTAR cvfTz "$base.tar.gz" -) >| "$base.tar.log" 2>&1; 
    ($LS -l "$base.tar.gz"; cat "$base.tar.log") 2>&1 | $PAGER; 
    ls-full "$base.tar.gz";
    ls-relative "$base.tar.gz"; 
}
# TODO: handle filenames with embedded spaces
#
# tar-dir(dir, depth, [filter]): create archive of DIR in ~/xfer, using subdirectories up to DEPTH, and optionally 
# filtering files matching exlusion filter.
#
function tar-dir () {
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
function tar-just-dir () { tar-dir "$1" 1; }
#
# tar-this-dir(): create tar archive into TEMP, for sud-directory tree routed
# in current directory (using directory basename as file prefix instead of .)
# ex: TEMP=/mnt/my-external-drive/tmp tar-this-dir
function tar-this-dir () { local dir="$PWD"; pushd-q ..; tar-dir "$(basename "$dir")"; popd-q; }
# test of resolving problem with tar-this-dir if dir a symbolic link from apparent parent
# TODO: fixme
function new-tar-this-dir () {
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
function tar-this-dir-normal () { local dir="$PWD"; pushd-q ..; tar-dir "$(basename "$dir")" "" "/(archive|backup|temp)/"; popd-q; }
#
function tar-just-this-dir () { local dir="$PWD"; pushd-q ..; tar-dir "$(basename "$dir")" 1; popd-q; }
function make-recent-tar () { (find . -type f -mtime -"$2" | $GTAR cvfzT "$1" -; ) 2>&1 | $PAGER; ls-relative "$1"; }
#
# " (for Emacs)
# NOTE: above quote needed to correct for Emacs color coding
# TODO: rework basename extraction
#
function view-tar () { $GTAR tvfz "$@" 2>&1 | $PAGER; }
function extract-tar () { $NICE $GTAR xvfzk "$@" 2>&1 | $PAGER; }
function extract-tar-force () { $NICE $GTAR xvfz "$@" 2>&1 | $PAGER; }
function extract-tar-here () { pushd ..; $NICE $GTAR xvfzk "$@" 2>&1 | $PAGER; popd; }
alias untar='extract-tar'
alias untar-here='extract-tar-here'
alias un-tar=untar
alias untar-force='extract-tar-force'
alias create-tar='make-tar-with-subdirs'
alias make-full-tar='make-tar'
# TODO: handle filenames with embedded spaces
alias recent-tar-this-dir='make-recent-tar $TEMP/recent-$(basename "$PWD")'
function sort-tar-archive() { (tar tvfz "$@" | sort --key=3 -rn) 2>&1 | $PAGER; }
#
# TODO: tar-this-dir-there???
# ex: ¢ TEMP=/mnt/wd6tbp2vfat/backup/tpo-servidor tar-this-dir
#
alias tar-this-dir-dated='USE_DATE=1 tar-this-dir'

#.......................................

#
# command-to-pager(command, arg1, ...): helper function for use in aliases: sends command output to $PAGER (e.g., less)
function command-to-pager { "$@" | $PAGER; }
alias view-zip='command-to-pager unzip -v'
alias un-zip='command-to-pager unzip'

alias color-xterm='rxvt&'

alias count-it='perl- count_it.perl'
alias count_it=count-it
function count-tokens () { count-it "\S+" "$@"; }
# TODO: rework via chomp
function count-line-text () { count-it '^([^\n\r]*)[\n\r]*$' "$@"; }
alias extract-matches='extract_matches.perl'
# EX: echo $'1 one\n2 two\n3' | perlgrep 'o\w' => "1 one"
alias perlgrep='perl- perlgrep.perl'
alias perl-grep=perlgrep
function para-grep { perlgrep -para "$@" 2>&1 | $GREP -v "Can't open \*notes\*"; }
alias para-gr='para-grep -i -n'

#................................................................................
# Note grepping (e.g., using timestamp sorted excerpts)
# TOM-IDIOSYNCRATIC

## TODO: make a pass to ensure aliases have unique leading prefix, as well as being easy to remember (n.b., ease of tab completion vs. recall)
function cached-notes-para-gr { para-gr "$@" _master-note-info.list | $PAGER; }
# TODO: work out better name
function cached-notes-para-gr-less { cached-notes-para-gr "$@" | less -p "$1"; }
##
## OLD
## # EX: echo $'1\n2\n3\n4\n5' | calc-stdev => "num = 5; mean = 3.000; stdev = 1.581; min = 1.000; max = 5.000; sum = 15.000"
## function calc-stdev () { sum_file.perl -stdev "$@" -; }
## ## MISC: alias calc-stdev-file='calc-stdev <'
## ## MISC: alias sum-col2='sum_file.perl -col=2 -'
##
notes_glob="*notes*.txt  *notes*.list *notes*.log"
# maldito shellcheck: SC2086 [Double quote to prevent globbing and word splitting]
# shellcheck disable=SC2086
{
function notes-grep() { perlgrep "$@" $notes_glob; }
#
# aliases for grepping through notes files and archiving non-note log files 
function para-notes-gr { perlgrep -para -i "$@" $notes_glob 2>&1 | $GREP -v "Can't open \*notes\*" | $PAGER; }
# TODO: use xyz-grl in analogy with grepl alias (n.b., uses $PAGER)
function para-notes-gr-less-p { para-notes-gr "$@" | less -p "$1"; }
# notes-entry-gr(): treat text with -----'s as single unit for searching
# notes-entry-gr-aux(glob, pattern): search for PATTERN in GLOB
function notes-entry-gr-aux() {
    local glob="$1"
    shift
    ## OLD: perl -00 -pe 's/\n\n/\n \n/g; s/^\-{40}/\n$&/g;' $glob 2>&1 | perlgrep -para -i "$@" -  2>&1 | $PAGER;
    perl -00 -pe 's/\n\n/\n \n/g; s/^\-{40}/\n$&/g;' $glob 2>&1 | perlgrep -para -i "$@" -  2>&1 | less -p "$1";
}
}
alias notes-entry-gr='notes-entry-gr-aux "$notes_glob"'
function notes-entry-gr-less-p { notes-entry-gr "$@" | less -p "$1"; }
alias entry-notes=notes-entry-gr
alias cached-entry-gr='notes-entry-gr-aux _master-note-info.list'
function cached-entry-gr-less-p { cached-entry-gr "$@" | less -p "$1"; }
# TODO: * work good scheme for shortcut aliases (e.g. both memorable and easily tab-completable)!
alias grepl-entry=cached-entry-gr-less-p
alias grepl-entry-here=entry-notes

#................................................................................

# TODO: use .list instead of .log in note files to minimize need for such an awkward move alias/function (n.b., .log files more common due to script usage than .list)
#
function prep-brill() { prep_brill.perl "$1" > "$1".pp; }

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
	echo "note: use ' ' for options to use default"
	echo "ex: pdf-to-ascii zhang-skillspan-naccl2022.pdf 1 ' '"
	return
    fi
    local file="$1"
    local verbose="$2";
    local options="$3"
    if [ "$options" = "" ]; then options="-layout"; fi
    local target
    target=$(basename "$1" .pdf)".ascii";
    ## OLD: if [ "$verbose" = "1" ]; then echo "checking $target"; fi
    if [ ! -s "$target" ]; then
        ## OLD: if [ "$verbose" = "1" ]; then echo "creating $target"; fi
        if [ "$verbose" = "1" ]; then
	    echo "creating $target w/ options '$options'";
	fi
	# quiet shellcheck on quoting args
	# shellcheck disable=SC2046,SC2086
        cmd.sh --time-out 30 pdftotext $options "$file" "$target";
    else
	if [ "$verbose" = "1" ]; then echo "skipping existing $target"; fi
    fi
    $LS -lt "$target"
}
function all-pdf-to-ascii () { for f in *.pdf; do pdf-to-ascii "$f"; done; }

# Specialized file editors
function run-app {
    local path="$1";
    local app
    app=$(basename "$path");
    shift;
    local log
    log=$TEMP/"$app-$(TODAY).log"
    if [ -e "$log" ]; then
	echo "FYI: Updating $app's log $log"
    fi
    "$app" "$@" >> "$log" 2>&1 &
    ## TODO: make sure command invoked OK and then put into background
    sleep 5
    ## OLD: check-errors "$log" | cat
    check-errors -quiet=0 "$log" | cat
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
# show-all-macros(pattern): show aliases or functions matching PATTERN
# TODO: allow for specifying word-boundary matching
function show-all-macros () {
    pattern="$*";
    if [ "$pattern" = "" ]; then pattern=.; fi;
    alias | $GREP -i "$pattern" | perl -ne 'print("$_\n");';
    show-functions-aux | perlgrep -i -para $pattern;
}

# show-macros(pattern): like show-all-macros, excluding leading _ in name
function show-macros () { show-all-macros "$*" | perlgrep -v -para "^_"; }
# shellcheck disable=SC2016
alias-fn show-macros-proper 'show-macros | $GREP "^\w"'
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
alias colon-sort="sort \$SORT_COL2 -t ':'"
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
function echoize { perl -00 -pe 's/\n(.)/ $1/g;'; }

#-------------------------------------------------------------------------------
trace file manipulation and conversions

function asc-it () { dobackup.sh "$1"; asc < BACKUP/"$1" >| "$1"; }
# TODO: use dos2unix under CygWin
alias remove-cr='tr -d "\r"'
alias perl-slurp='perl -0777'
alias alt-remove-cr='perl-slurp -pe "s/\r//g;"'
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
alias kill-em='kill_em.sh'
alias kill-it='kill-em --pattern'
# NOTE: see filter-dirnames added to strip directory names
# TODO: rename as ps-mine-sans-dirs
## BAD: alias ps-mine-='ps-mine "$@" | filter-dirnames'
function ps-mine- { ps-mine "$@" | filter-dirnames; }
alias ps_mine='ps-mine'
## DUP: alias ps-mine-='ps-mine "$@" | filter-dirnames'
alias ps-mine-all='ps-mine --all'
alias rename-files='perl- rename_files.perl'
alias rename_files='rename-files'
alias testwn='perl- testwn.perl'
alias perlgrep='perl- perlgrep.perl'
alias foreach='perl- foreach.perl'

#--------------------------------------------------------------------------------
# Adhoc aliases for renaming aliases
## TOM-IDIOSYNCRATIC#

# rename-spaces: replace spaces in filenames of current dir with underscores
alias rename-spaces='rename-files -q -global " " "_"'
# TODO2: handle smart quotes
alias rename-quotes='rename-files -q -global "'"'"'" ""'   # where "'"'"'" is concatenated double quote, single quote, and double quote
# rename-special-punct: replace runs of any troublesome punctuation in filename w/ _
## OLD: alias rename-special-punct='rename-files -q -global -regex "_*[&\!\*?\(\)\[\]]" "_"'
## OLD: alias rename-special-punct='rename-files -q -global -regex "_*[&\!\*?\(\)\[\]]" "_"; rename-files -q -global -regex "–" "-"'
alias rename-special-punct='rename-files -q -global -regex "_*[&\!\*?\(\)\[\]·’®]" "_"; rename-files -q -global -regex "–" "-"'
# TODO: test
#     $ touch '_what-the-hell?!'; rename-special-punct; ls _what* => _what-the-hell_
## TODO:
## alias rename-spaces='rename-files -rename_old -q -global " " "_"'
## alias rename-quotes='rename-files -rename_old -q -global "'"'"'" ""'   # where "'"'"'" is concatenated dou[???]
## OLD: alias rename-special-punct='rename-files -q -global -regex "[&\!\*?]" ""'
## alias rename-special-punct='rename-files -rename_old -q -global -regex "[&\!\*?\(\)]" ""'
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
# TODO: make this less of a sledgehammer
## BAD: alias rename-utf8-encoded='rename-files -global -regex "[0x80-0xFF]\{3,\}" "_"'
## OLD: alias rename-utf8-encoded='rename-files -global -regex "[\x80-\xFF]\{3,\}" "_"'
## OLD: alias rename-utf8-encoded='rename-files -quick -global -regex "[\x80-\xFF]+" "_"'
## OLD: alias rename-utf8-encoded='rename-files -quick -global -regex "[\x80-\xFF]{1,4}" "_"'
alias rename-utf8-encoded-sledgehammer='rename-files -quick -global -regex "[\x80-\xFF]{1,4}" "_"'
## OLD: alias rename-emoji=rename-utf8-encoded
# via https://en.wikipedia.org/wiki/UTF-8:
#    U+10000	U+10FFFF	11110xxx	10xxxxxx	10xxxxxx	10xxxxxx;   note: F[8-F]{3}
# rename-utf8-emoji: replace U+10000 characters in filenames with _'s
# note: emoji considered synonymous with emoticon
## OLD: alias rename-utf8-emoji='rename-files -quick -global -regex "[\xF0-\xFF][\x80-\xFF]{1,3}" "_"'
alias rename-utf8-emoji='rename-files -quick -global -regex "[\xF0-\xFF][\x80-\xFF]{1,3}" "_"'
## TODO2 (handle cases like U+2728 [sparkle] w/ UTF8 0xE29CA8):
#    alias rename-utf8-emoji-misc='rename-files -quick -global -regex "[\xE0-\xFF][\x80-\xFF]{2,3}" "_"'
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
# maldito shellcheck: SC2120 (warning): ... references arguments, but none are ever passed.
# shellcheck disable=SC2120
function move-versioned-files {
    if [ "$1" = "" ]; then
	echo "usage: [ENV] move-versioned-files 'brace_pattern' dir"
	echo "    where ENV = [READONLY=1]"
	## TODO: echo "    where ENV = [MOVE=command] ...        use 'mv -v' to move read
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
    ## OLD: move  $(eval dir-rw *$D${ext_pattern}[0-9]*  *$D*[0-9]*$D${ext_pattern}  *$D${ext_pattern}$D*[0-9][0-9]*   *$D*[0-9][0-9]*$D${ext_pattern}  2>&1 | perl-grep -v 'No such file' | perl -pe 's/(\S+\s+){6}\S+//;' | sort -u) "$dir"
    ## OLD: move  $(ls -l *$D${ext_pattern}[0-9]*  *$D*[0-9]*$D${ext_pattern}  *$D${ext_pattern}$D*[0-9][0-9]*   *$D*[0-9][0-9]*$D${ext_pattern}  2>&1 | perl-grep -v "(No such file)|(^..$perm)" | perl -pe 's/(\S+\s+){7}\S+//;' | sort -u) "$dir"
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
# move-versioned-files-alt: alternative version for moving all files with DDMMMDD-style timestamp into ./old
## OLD: alias move-versioned-files-alt='mkdir -p old; move *[0-9][0-9][a-z][a-z][a-z]*[0-9][0-9]* old'
# shellcheck disable=SC2010,SC2086
{
function move-versioned-files-alt {
    mkdir -p old;
    local version_regex="[0-9][0-9][a-z][a-z][a-z]*[0-9][0-9]"
    move ./*$version_regex* old
    local false_positives
    false_positives="$(ls old/*$version_regex* 2>&1 | grep -v 'No such file' | egrep "(adhoc)|(.txt$)")"
    if [ "$false_positives" != "" ]; then
	echo "Warning: potential misplaced files"
	echo "    $false_positives"
    fi
    }
}

#--------------------------------------------------------------------------------

# rename-with-file-date(file, ...): rename each file(s) with .ddMmmYY suffix
# Notes: 1. If file.ddMmmYY exists, file.ddMmmYY.N tried (for N in 1, 2, ...).
# 2. No warning is issued if the file doesn't exist, so can be used as a no-op.
# TODO: have option to put suffix before extension
function rename-with-file-date() {
    ## DEBUG: set -o xtrace
    local f new_f
    local verbose=0
    local move_command="move"
    if [ "$1" = "--copy" ]; then
        ## TODO: move_command="copy"
        move_command="command cp --interactive --verbose --preserve"
        shift
    fi
    if [ "$1" = "--verbose" ]; then
	verbose=1
	shift
    fi
    for f in "$@"; do
        ## DEBUG: echo "f=$f"
        ## OLD: if [ -e "$f" ]; then
	if [[ "$f" =~ \.[0-9]{2}[a-z]{3,4} ]]; then
	    ## TODO2: [ $verbose = 1 ] && echo "Ignoring file with timestamp: $f"
	    [ $verbose = 1 ] && echo "Ignoring file with timestamp: $f"
        elif [ -e "$f" ]; then
           new_f=$(get-free-filename "$f.$(date --reference="$f" '+%d%b%y')" ".")
           ## DEBUG: echo
           eval "$move_command" "$f" "$new_f";
	else
	   ## TODO2: [ $verbose ] && echo "FYI: no '$f'"
	   [ $verbose = 1 ] && echo "FYI: no '$f'"
        fi
    done;
    ## DEBUG: set - -o xtrace
}
## HACK: See if function required for proper handling by bats-core
function copy-with-file-date { rename-with-file-date --copy "$@"; }

# Statistical helpers
alias bigrams='perl -sw "$TOM_BIN"/count_bigrams.perl -N=2'
alias unigrams='perl -sw "$TOM_BIN"/count_bigrams.perl -N=1'
alias word-count=unigrams

# EX: echo $'1\n2\n3\n4\n5' | calc-stdev => "num = 5; mean = 3.000; stdev = 1.581; min = 1.000; max = 5.000; sum = 15.000"
function calc-stdev () { sum_file.perl -stdev "$@" -; }
## MISC: alias calc-stdev-file='calc-stdev <'
## MISC: alias sum-col2='sum_file.perl -col=2 -'

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
## BAD: function show-unicode-control-chars { perl -pe 'use Encode "decode_utf8"; s/[\x00-\x1F]/chr($&+0x2400)/e;'; }
# See https://stackoverflow.com/questions/42193957/errorwide-character-in-print-at-x-at-line-35-fh-read-text-files-from-comm.
## BAD: function show-unicode-control-chars { perl -pe 'use open ":std", ":encoding(UTF-8)"; s/[\x00-\x1F]/chr($& + 0x2400)/eg;'; }
function show-unicode-control-chars { perl -pe 'use open ":std", ":encoding(UTF-8)"; s/[\x00-\x1F]/chr(ord($&) + 0x2400)/eg;'; }


#-------------------------------------------------------------------------------
trace Unix aliases

## TODO: archive
function group-members () { ypcat group | $GREP -i "$1"; }
# TODO: check if _make.log exists prior to move
## OLD: function do-make () { /bin/mv -f _make.log _old_make.log; make "$@" >| _make.log 2>&1; $PAGER _make.log; }
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
## OLD: alias diff3-merge='/usr/bin/diff3 --merge --text --diff-program=diff.sh'
alias diff3-merge='command diff3 --merge --text --diff-program=diff.sh'
## TODO: --auto
function kdiff-merge() {
    if [ "$3" = "" ]; then
        echo "usage: $0 changed1 old changed2 output"
        return
    fi
    kdiff3 --merge --output "$4" "$1" "$2" "$3"
}
#
quiet-unalias which
## OLD: function which { /usr/bin/which "$@" 2> /dev/null; }
function which { command which "$@" 2> /dev/null; }
#
# absolute-path(filename): returns actual full path for filename
function absolute-path { realpath "$1"; }
# full-dirname(filename): returns full path of directory for file
# TODO: use realpath
#
# OLD:
## function full-dirname () {
##     local dir;
##     dir=$(dirname "$1");
##     case $dir in .*) dir="$PWD/$1";; esac;
##     echo "$dir";
## }
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
## OLD: alias gtime='/usr/bin/time'
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
## OLD: function perl-echo () { perl -e 'print "'"$1"'\n";'; }
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

# Unix/Win32 networking aliases
if [ "$OSTYPE" != "cygwin" ]; then alias ipconfig=ifconfig; fi
alias set-display-local='export DISPLAY=localhost:0.0'

# Bash aliases
# Note: '- -o' is idiom for turning off
alias bash-trace-on='set -o xtrace'
alias bash-trace-off='set - -o xtrace'
#
# trace-cmd(command-line): runs command-line with bash tracing enable to
# show argument expansion with result piped into less
function trace-cmd() {
    (
	## TODO: warn about need for extra quotes
	## if [[ "$*" =~ " " ]; then echo  "FYI: Make sure command doubly-quoted to trace-cmd""
        echo "start: $(date)";
        bash-trace-on; 
        ## OLD: eval "$@";
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
## OLD: alias old-count-exts='$LS | count-it "\.[^.]*\w" | sort $SORT_COL2 -rn | $PAGER'
function count-exts () { $LS | count-it '\.[^.]+$' | sort $SORT_COL2 -rn | $PAGER; }
function count-exts-all { (count-exts | cat; $LS | count-it '^[^.]+(\.*)$') | sort $SORT_COL2 -rn | $PAGER; }

alias kill-iceweasel='kill_em.sh iceweasel'

# cmd-output(cmd, ...): show output for cmd to _{cmd}-$(TODAY).log (with spaces
# replaced by underscores)
#
function cmd-output () {
    local command="$*"
    local output_file
    output_file="_$(echo "$command" | tr ' ' '_')-$(TODAY).list"
    ## OLD: $command 2>&1 | ansifilter > "$output_file"
    ## TODO3?: use separate invocations for aliases than for other commands
    ($command || eval "$command") 2>&1 | ansifilter > "$output_file"
    $PAGER_NOEXIT "$output_file"
}

# cmd-usage(command): output usage for command to _command.list (with spaces
# replaced by underscores)
function cmd-usage () {
    local command="$*"
    local usage_file
    usage_file="_$(echo "$command" | tr ' ' '_')-usage.list"
    $command --help  2>&1 | ansifilter > "$usage_file"
    $PAGER_NOEXIT "$usage_file"
}
## TODO:
## function cmd-usage () {
##     cmd-output "$*" --help
## }

#-------------------------------------------------------------------------------
# More Linux stuff
# TODO: condition upon using Linux kernel (or cygwin
alias configure='./configure --prefix ~'
alias pp-xml='xmllint --format'
alias pp-html='pp-xml --html'
# ex: pp-url "www.fu.com?p1=fu&p2=bar" => "www.fu.com\n\t?p1=fu\n\t&p2=bar"
alias pp-url-aux='perl -pe "s/[\&\?]/\n\t$&/g;"'
function pp-url { echo "$@" | pp-url-aux; }
alias check-xml='xmllint --noout'
alias check-xml-valid='check-xml --valid'
alias soffice-calc='/usr/lib/libreoffice/program/soffice.bin --calc'
alias libreoffice-write='run-app libreoffice --writer'
alias libreoffice-pdf='run-app libreoffice --draw'
alias libreoffice-calc='run-app libreoffice --calc'
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
function truncate-width { cut --characters=1-"$(calc-int "$COLUMNS - 1")" "$@"; }

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
# Notes: 1. If <base> exists <base><sep><N> checked until the filename not used (for N in 2, 3, ... ).
# 2. See sudo-admin for sample usage; also see rename-with-file-date.
# 3. If Ext specified, it is added after the numeric part (n.b., including sep). It is used
# to ensure that the filename ends with a specific extension instead of a number.
# EX: get-free-filename("really-unique-filename", ".") => "really-unique-filename"
# EX: get-free-filename("/boot/initrd", ".", "img") => "/boot/initrd.1.img"
# TODO: start counting L at 0 so that first affix using 1 not 2
#
function get-free-filename() {
    local base="$1"
    local sep="$2"
    local ext="$3"
    local L=1
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
    ## OLD: local prefix="_config-"
    local prefix="_config."
    local base
    base="$prefix$(todays-date).log"
    sudo chmod ugo-w "$prefix"*.log* 2> /dev/null
    local script_log
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
    ## OLD: local user_home="/home/$SUDO_USER"
    local user_home
    # maldito shellchecK: SC2116 (style): Useless echo?
    # shellcheck disable=SC2116
    ## BAD: user_home="$(echo ~$SUDO_USER)"
    user_home="$(bash -c "echo ~$SUDO_USER")"
    local changes_log="${user_home}/_fix-home-permission.log"
    if [ "$SUDO_USER" = "" ]; then
        echo "Warning: no sudo user for current shell"
    else
        rename-with-file-date "$changes_log"
        # TODO: account for alternative home dir schemes
        chown --recursive --changes "$SUDO_USER" "$user_home" > "$changes_log" 2>&1
        $PAGER "$changes_log"
    fi
}

## OLD:
# alias hibernate='sudo systemctl hibernate'

#-------------------------------------------------------------------------------
# HTML stuff
alias check-html='check-xml --html'
## TODO: archive (see check_html_javascript.py)
function check-html-java-script () {
  local file="$1"
  local base
  base="$(basename "$file" .html)"
  extract_subfile.perl -include_start=0 -include_end=0 '<script type=\"text/javascript\">' '</script>' "$file" >| "$TEMP/$base.js"
  jsl -process "$TEMP/$base.js"
}

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
# scp-host-up(host, file, ...): upload FILES to HOST
function scp-host-up() { local host="$1"; shift; scp -P $SSH_PORT -i "$TPO_SSH_KEY" "$@" "$TPO_SSH_USER@$host:$TMP"; }
#
## TOM-IDIOSYNCRATIC
# scp-aws-up(host, file, ...): updload FILES to HOST, after making sure ~/xfer directory files writable
function scp-aws-up() { local host="$1"; shift;
                        ssh -p $SSH_PORT -i "$TPO_SSH_KEY" "$TPO_SSH_USER@$host" chmod u+w \~/xfer/'*';
                        scp -P $SSH_PORT -i "$TPO_SSH_KEY" "$@"  "$TPO_SSH_USER@$host":xfer; }
function scp-aws-down() { local host="$1"; shift; for _file in "$@"; do scp -P $SSH_PORT -i "$TPO_SSH_KEY" "$TPO_SSH_USER@$host":xfer/$_file .; done; }
#
# TODO: consolidate host keys; reword hostwinds in terms of generic host not AWS
#
export AWS_HOST="52.15.125.52"
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
alias hw-login='ssh-host-login-aws $HOSTWINDS_HOST'
alias hw-upload='scp-aws-up $HOSTWINDS_HOST'
alias hw-download='scp-aws-down $HOSTWINDS_HOST'
alias new-hw-login='ssh-host-login-aws $NEW_HOSTWINDS_HOST'
alias new-hw-upload='scp-aws-up $NEW_HOSTWINDS_HOST'
alias new-hw-download='scp-aws-down $NEW_HOSTWINDS_HOST'
#
alias old-hw-login=hw-login
alias old-hw-upload=hw-upload
alias old-hw-download=hw-download
#
alias hw1-login=old-hw-login
alias hw1-upload=old-hw-upload
alias hw1-download=old-hw-download
alias hw2-login=new-hw-login
alias hw2-upload=new-hw-upload
alias hw2-download=new-hw-download

# Set dummy default host on AWS and HostWinds so hostname always in xterm title (see set_xterm_title.bash).
# Sample hostnames under AWS is ip-172-31-37-185 and under Hostwinds is ip-172-31-37-185.
# TODO: Get domainname.sh working (or information partcular to uname -a).
# NOTE: temporary hack for remote servers until set_xterm_title.bash fixed (7 Feb 2020): echo n/a > ~/.default_host
## TEMP: if [[ ("$DEFAULT_HOST" = "") && (($HOSTNAME =~ ip-*) || ($HOSTNAME = tpo-servidor) || ($HOSTNAME =~ cvps*)) ]]; then export DEFAULT_HOST=n/a; fi
if [[ ("$DEFAULT_HOST" = "") && (($HOSTNAME =~ ip-*) || ($HOSTNAME =~ cvps*)) ]]; then export DEFAULT_HOST=n/a; fi


#................................................................................
# Other host-related stuff
# TODO: make generic (e.g., by making nickname optional)

## OLD
## function gr-juju-notes () { grepl "$@" /c/work/juju/*notes* $JJDATA/*notes*; }
## function gr-juju-notes-archive () { MY_GREP_OPTIONS="" grepl "$@" /c/work/juju/_note-archive.list; }
## alias gr-juju-archive-notes=gr-juju-notes-archive

alias uname-node='uname -n'
## OLD: alias pwd-host-info='pwd; echo $HOST_NICKNAME; uname-node'
alias pwd-host-info='pwd; echo "${HOST_NICKNAME:-n/a}"; uname-node'

# TODO: put following elsewhere
## MISC
## conditional-export SANDBOX ~/python/tohara
## conditional-export MISC_TRACING_LEVEL 4
## alias restart-screen='screen-startup.sh >| $TEMP/screen-startup.$$.log 2>&1'

## OLD
## #-------------------------------------------------------------------------------
## 
## # MRJob stuff (python-based map-reduce)
## #
## # show-job-tracker([port=40001]): enable tunneling for job tracker on temp EC2 host
## # and then invoke firefox for link using corresponding port
## # note: ssh options: -f background; -n redirect stdin; -N no command; -T disable pseudo-tty; -L port forwarding specification
## job_tracker_port=40001
## function show-job-tracker() {
##     local port="$1"
##     if [ "$port" == "" ]; then port=$job_tracker_port; fi
##     # Maldito shellcheck [SC2029: Note that, unescaped, this expands on the client side]
##     # shellcheck disable=SC2029
##     ssh -fnNT -i "$TPO_SSH_KEY" -L$port:localhost:$port "$TPO_SSH_USER@$mrjob_ec2_host"
##     firefox http://localhost:$port/jobtracker.jsp &
## }
## alias kill-job-trackers=' kill_em.sh -p L$job_tracker_port'

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
function ps-sort-once { ps_sort.perl -num_times=1 -by=time "$@" -; }
alias ps-sort-time='ps-sort-once -by=time'
alias ps-time=ps-sort-time
alias ps-sort-mem='ps-sort-once -by=mem '
alias ps-mem=ps-sort-mem
alias ps-sort-help='ps_sort.perl'

# get-process-parent(pid): return parent process-id for PID
# ¢ ps al | egrep "(PID|$$)"
# F   UID   PID  PPID PRI  NI    VSZ   RSS WCHAN  STAT TTY        TIME COMMAND
# 0  1000  3723  3840  20   0  25136  7724 wait   Ss   pts/51     0:01 bash
# 4  1000 25056  3723  20   0  28920  1612 -      R+   pts/51     0:00 ps al
# 0  1000 25057  3723  20   0  14228  1024 pipe_w S+   pts/51     0:00 grep -E --color=auto (PID|372
# 
function get-process-parent() { local pid="$1"; if [ "$pid" = "" ]; then pid=$$; fi; ps al | perl -Ssw extract_matches.perl "^\d+\s+\d+\s+$pid\s+(\d+)"; }

# Make sure script appends rather than overwrites.
# In addition, set SCRIPT_PID, so that set_xterm_title.bash can indicate within script.
# Also, appends $ to prompt symbol so that typescript prompt searchable with strings command
## HACK: set envionment for sake of set_xterm_title.bash (TODO check PPID for this)
## TODO: use stack for old_PS_symbol maintenance??? (also allows for recursive invocation, such as with '$ $ $')
## TODO: rename as my-script to avoid confusion
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
function ps-sort-once { ps_sort.perl -num_times=1 -by=time "$@" -; }
alias ps-sort-time='ps-sort-once -by=time'
alias ps-time=ps-sort-time
alias ps-sort-mem='ps-sort-once -by=mem '
alias ps-mem=ps-sort-mem

# get-process-parent(pid): return parent process-id for PID
# ¢ ps al | egrep "(PID|$$)"
# F   UID   PID  PPID PRI  NI    VSZ   RSS WCHAN  STAT TTY        TIME COMMAND
# 0  1000  3723  3840  20   0  25136  7724 wait   Ss   pts/51     0:01 bash
# 4  1000 25056  3723  20   0  28920  1612 -      R+   pts/51     0:00 ps al
# 0  1000 25057  3723  20   0  14228  1024 pipe_w S+   pts/51     0:00 grep -E --color=auto (PID|372
# 
function get-process-parent() { local pid="$1"; if [ "$pid" = "" ]; then pid=$$; fi; ps al | perl -Ssw extract_matches.perl "^\d+\s+\d+\s+$pid\s+(\d+)"; }

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

    # Reset bashrc status variables
    export PROFILE_PROCESSED=0 BASHRC_PROCESSED=0
    
    # Change xterm title to match
    set-title-to-current-dir
    ## DEBUG: echo "script: 2. PS1='$PS1' old_PS_symbol='$old_PS_symbol' PS_symbol='$new_PS_symbol'"
    # Run command
    ## maldito macos
    ## OLD: command script --append "$@"
    command script -a "$@"
    
    # Restore prompt
    unset SCRIPT_PID
    reset-prompt "$old_PS_symbol"
    ## DEBUG: echo "script: 3. PS1='$PS1' old_PS_symbol='$old_PS_symbol' PS_symbol='$new_PS_symbol'"
    
    # Get rid of lingering 'script' in xterm title
    ## DEBUG: echo "Restoring xterm title: full=$save_full save=$save_icon"
    set-xterm-title "$save_full" "$save_icon"
}
}
# TODO: put this in a separate file
## OLD: alias script-update='script _update-$(T).log'
## OLD: alias script-update='script  _update-$(T).log  make-git-update.bash'
function script-update {
    local command_indicator=""
    ## TODO: under-linux && command_indicator="-c"
    if [ "$(under-linux)" = "1" ]; then
	command_indicator="-c"
    fi
    # shellcheck disable=SC2046,SC2086
    script  "_update-$(T).log"  $command_indicator make-git-update.bash
}

# ansi-filter(filename]: wrapper around ansifilter with stdio and stdout instead of files
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
    if [ "$message" = "" ]; then message="Press enter to continue"; fi
    # note: with -p for prompt and -r makes backslash not an escape [avoids shellcheck warning]
    read -r -p "$message "
}

#-------------------------------------------------------------------------------
# Python related
## *** Python stufff ***

## OLD: export PYTHON_CMD="/usr/bin/time python -u"
export PYTHON_CMD="$TIME_CMD python -u"
export PYTHON="$NICE $PYTHON_CMD"
export PYTHONPATH="$HOME/python:$PYTHONPATH"
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
alias ps-python-full='ps-mine python'
# note: excludes ipython and known system-related python scripts;
# also excludes related bash and time processes.
## OLD: alias ps-python='ps-python-full | $EGREP -iv "(screenlet|ipython|egrep|update-manager|software-properties|networkd-dispatcher)"'
alias ps-python='ps-python-full | $EGREP -iv "(screenlet|ipython|egrep|perl-regexp|update-manager|software-properties|networkd-dispatcher|((bash|emacs|time) .*python))"'
alias show-python-path='show-path-dir PYTHONPATH'

# Remove compiled files .pyc for regular (debug) version and .pyo for optimized
# TODO: add option for forced removal; try using '-name "*.py[co]"')
function delete-compiled-python-files-aux {
    local rm_options=${1:-"-v"}
    # Maldito shellcheck [SC2086: Double quote to prevent globbing and word splitting]
    # shellcheck disable=SC2086
    ## OLD: find . \( -name "*.pyc" -o -name "*.pyo" \) -exec /bin/rm $rm_options {} \;
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
    root=$(hg root 2> /dev/null);
    ## TODO: --persistent=n (to avoid caching)
    PYTHONPATH="$root:.:$PYTHONPATH" $NICE pylint "$@" | perl -00 -ne 'while (/(\n\S+:\s*\d+[^\n]+)\n( +)/) { s/(\n\S+:\s*\d+[^\n]+)\n( +)/$1\r$2/mg; } print("$_");' 2>&1 | $PAGER;
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
function python-lint-work() { python-lint-full "$@" 2>&1 | $EGREP -v '\((bad-continuation|bad-option-value|fixme|invalid-name|locally-disabled|too-few-public-methods|too-many-\S+|trailing-whitespace|star-args|unnecessary-pass)\)' | $EGREP -v '^(([A-Z]:[0-9]+)|(Your code has been rated)|(No config file found)|(PYLINTHOME is now)|(\-\-\-\-\-))' | $PAGER; }
# TODO: rename as python-lint-tpo for clarity (and make python-lint as alias for it)
# note: R0801 is for duplicate lines across source files (no mnemonic)
function python-lint() { python-lint-work --disable=R0801 "$@" 2>&1 | $EGREP -v '(Exactly one space required)|\((bad-continuation|bad-whitespace|bad-indentation|bare-except|c-extension-no-member|consider-using-enumerate|consider-using-f-string|consider-using-with|global-statement|global-variable-not-assigned|keyword-arg-before-vararg|len-as-condition|line-too-long|logging-not-lazy|misplaced-comparison-constant|missing-final-newline|no-self-use|redefined-variable-type|redundant-keyword-arg|superfluous-parens|too-many-arguments|too-many-instance-attributes|trailing-newlines|useless-\S+|wrong-import-order|wrong-import-position)\)' | $PAGER; }

# run-python-lint-batched([file_spec="*.py"]: Run python-lint in batch mode over
# files in FILE_SPEC, placing results in pylint/<today>.
#
function get-python-lint-dir () {
    local python_version_major
    python_version_major=$(pylint --version 2>&1 | extract_matches.perl "Python (\d)")
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
         DEBUG_LEVEL=5 python-lint "$f" >| "$out_dir/$pre$b".log 2>&1
         head "$out_dir/$pre$b".log
     done) >| "$out_dir/summary.log"
    less -p '^\** Module' "$out_dir/summary.log";
}

# python-import-path(module): find path for package directory of MODULE
# Note: this checks output via module initialization output shown with python -v
# ex: /usr/local/misc/programs/anaconda3/lib/python3.8/site-packages/sklearn/__pycache__/__init__.cpython-38.pyc matches /usr/local/misc/programs/anaconda3/lib/python3.8/site-packages/sklearn/__init__.py
function python-import-path-all() { local module="$1"; python -u -v -c "import $module" 2>&1; }
## OLD: function python-import-path-full() { local module="$1"; python-import-path-all "$@" | extract_matches.perl "((matches (.*\W$module[^/]*[/\.][^/]*))|ModuleNotFoundError)"; }
function python-import-path-full() { local module="$1"; python-import-path-all "$@" | extract_matches.perl "((matches (.*\W${module}[^/]*[/\.][^/]*))|ModuleNotFoundError)"; }
function python-import-path() { python-import-path-full "$@" | head -1; }

#
## note: gotta hate python!
function python-module-version-full { local module="$1"; python -c "import $module; print([v for v in [getattr($module, a, '') for a in '__VERSION__ VERSION __version__ version'.split()] if v][0])"; }
# TODO: check-error if no value returned
function python-module-version { python-module-version-full "$@" 2> /dev/null; }
function python-package-members() { local package="$1"; python -c "import $package; print(dir($package));"; }
#
alias python-setup-install='log=setup.log;  rename-with-file-date $log;  uname -a > $log;  python setup.py install --record installed-files.list >> $log 2>&1;  ltc $log'
# TODO: add -v (the xargs usage seems to block it)
## OLD: alias python-uninstall-setup='cat installed-files.list | xargs /bin/rm -vi; rename_files.perl -regex ^ un installed-files.list'
alias python-uninstall-setup='cat installed-files.list | xargs command rm -vi; rename_files.perl -regex ^ un installed-files.list'

# ipython(): overrides ipython command to set xterm title and to add git repo base directory to python path
function ipython() { 
    local ipython
    ipython=$(which ipython)
    if [ "$ipython" = "" ]; then echo "Error: install ipython first"; return; fi
    set-xterm-window "ipython [$PWD]"
    # note: git-root currently `git rev-parse --show-toplevel' (see git-aliases.bash);
    # no-op if not in a git repo (e.g., PYTHONPATH=":..."
    git_base_dir=$(git-root 2> /dev/null)
    ## OLD: ipython "$@"
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
function py-diff () { do_diff.sh '*.py *.mako' "$@" 2>&1 | $PAGER; }

## OLD
## # kivy-win32-env(): enables environment variabless for Kivy under cyggwin, using win32 python
## function kivy-win32-env {
##    export PYTHONPATH='c:/cartera-de-tomas/python;c:/Program-Misc/python/kivy-1-9-0/kivy27'
##    kivy_dir="/c/Program-Misc/python/kivy-1-9-0"
##    python_dir="$kivy_dir/Python27"
##    prepend-path "$kivy_dir:$kivy_dir/Python27:$kivy_dir/tools:$kivy_dir/Python27/Scripts:$kivy_dir/gstreamer/bin:$kivy_dir/MinGW/bin:$kivy_dir/SDL2/bin"
## }

alias elide-data='python -m transpose_data --elide'
alias kill-python="kill_em.sh --filter 'ipython|emacs' python"
alias kill-python-all="kill_em.sh python"
## TODO
## function which-program {
##     local program="$1"
##     result=$(which "$programe")
##     if [[ ("$result" == "") || ("$verbsr ]; then result="$result;$(whereis "$program"); fi
##     if ...
##     }
## alias which-python='which-program python'
alias which-python='which python'

# run-jupyter-notebook-posthoc(): try to show log info previously not shown via run-jupyter-notebook
# TODO: enable multiple-versions backups
function run-jupyter-notebook-posthoc() {
    ## OLD:
    ## local log
    ## log="$TEMP/jupyter-$(TODAY).log"
    local log="$1"
    echo "checking log: $log"
    # TODO: resolve problem extracting URL
    # TEMP:
    tail "$log"
    # Show URL
    echo -n "URL: "
    extract-matches 'http:\S+' "$log" | sort -u    
}

# run-jupyter-notebook(port=18888): run jupyter notebook on PORT
function run-jupyter-notebook () {
    local port="$1"; if [ "$port" = "" ]; then port=8888; fi
    local ip="$2"; if [ "$ip" = "" ]; then ip="127.0.0.1"; fi
    local log
    log="$TEMP/jupyter-p$port-$(TODAY).log"
    # note: clears notebook token to disable authentication
    jupyter notebook --NotebookApp.token='' --no-browser --port $port --ip $ip >> "$log" 2>&1 &
    ## OLD
    ## echo "$log"
    # Let jupyter initialize
    local delay=5
    echo "sleeping $delay seconds for log to stabilize (maldito jupyter)"
    sleep $delay
    ## OLD
    ## # TODO: resolve problem extracting URL
    ## # TEMP:
    ## tail "$log"
    ## # Show URL
    ## echo -n "URL: "
    ## extract-matches 'http:\S+' "$log" | sort -u    
    run-jupyter-notebook-posthoc "$log"
}
alias jupyter-notebook-redir=run-jupyter-notebook
alias jupyter-notebook-redir-open='run-jupyter-notebook 8888 0.0.0.0'

# Python-based utilities
## OLD: function extract-text() { python -m extract_document_text "$@"; }
# extract-text(document-file): extracts text from structured document file (e.g., Word or PDF)
# note: to avoid hardcoded 'python -m mezcla.extract_document_text' invovation uses awkward which-based approach
## TODO: figure out way for python to pull script from path (as with perl -S)
function extract-text() { python "$(which extract_document_text.py)" "$@"; }
alias xtract-text='extract-text'

# test-script(script): run unit test for script (i.e., tests/test_script)
# and outputs to file given by tests/_test-<script_basename>.<date>.log.
# note: run in verbose mode with unbuffered I/O so output synchronized.
# TODO: rework to take the actual test script and to pipe results to pager
## TOM-IDIOSYNCRATIC
#
function test-script () {
    local base
    base=$(basename "$1" .py)
    local date
    date=$(todays-date)
    # note: uses both Mercurial root and . (in case not in repository)
    local root
    root=$(hg root)
    # maldito shellcheck (SC2086: Double quote to prevent globbing)
    # shellcheck disable=SC2086
    PYTHONPATH="$root:.:$SANDBOX/tests:$PYTHONPATH" $NICE $PYTHON tests/"test_$base.py" --verbose >| tests/"_test_$base.$date.log" 2>&1;
    less-tail tests/"_test_$base.$date.log";
}
#
alias test-script-debug='ALLOW_SUBCOMMAND_TRACING=1 DEBUG_LEVEL=5 MISC_TRACING_LEVEL=5 test-script'

# randomize-datafie(file, [num[): randomize datafile optionally pruned to NUM lines, preserving header line
#
function randomize-datafile() {
    local file="$1"
    local num_lines="$2"
    if [ "$num_lines" = "" ]; then num_lines=$(wc -l < "$file"); fi
    #
    head -1 "$file"
    tail --lines=+2 "$file" | python -m mezcla.randomize_lines | head -"$num_lines"
}

# filter-random(pct, file, [include_header=1])Randomize lines based on percentages, using output lile (e.g., _r10pct-fubar.data).
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
    $type "$file" | $PYTHON -m filter_random "$opts" --ratio "$ratio" - > "$result" 2> "$result.log"

    # Compress result if original compressed
    if [ "$compressed" = "1" ]; then 
       gzip --force "$result"; 
    fi
}

# Load supporting scripts
#
conditional-source "$TOM_BIN/anaconda-aliases.bash"
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
function url-path () {
    local file="$1"
    ## OLD: echo "$(realpath "$file")" | perl -pe 's@^@file:///@;'
    realpath "$file" | perl -pe 's@^@file:///@;'
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
alias chromium='invoke-browser /usr/lib/chromium-browser/chromium-browser'
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

alias nvidia-smi-loop='nvidia-smi --loop=1'
alias nvidia-loop=nvidia-smi-loop

# Multilingual
# TODO: put other common ones from do_setup.sh here

# Notes:
# - Aliases for emacs-qd-trans-sp.sh, which opens an Emacs terminal for running ye olde Quick-N-dirty Spanish word translator.
# - ed-trans-sp is used for consistency with recent aliases for editing info (ed-past-info for past-info.odt and ed-tomas for tomas.odt.
# - TODO: rename ed-tomas, as doc generalized to be a Spanish cheatsheet.
# - TODO: * Add hook(s) into Google and/or Bing translators!
## OLD: alias emacs-qd-trans-sp='pushd $TOM_DIR/multilingual; ./emacs-qd-trans-sp.sh; popd'
alias emacs-qd-trans-sp='pushd ${MULTILINGUAL_DIR:-"$TOM_DIR/multilingual"}; ./emacs-qd-trans-sp.sh; popd'
alias em-trans-sp=emacs-qd-trans-sp
alias ed-trans-sp=em-trans-sp

#-------------------------------------------------------------------------------
# Music related

## OLD
## function make-lilypond-png () {
##     local file="$1"
##     local base
##     base=$(basename "$file" .ly)
##     # note follpwing doesn't work as lilypond puts temporary files in current dir
##     ## TODO: local base=$(dirname "$file")/$(basename "$file" .ly)
##     lilypond_dir="/c/Program-Misc/music/lilypond"
##     PATH="$lilypond_dir/usr/bin:$PATH" lilypond --png --verbose "$file" >| "$base.png" 2>| "$base.log"
##     tail -5 "$base.log"
## }

#-------------------------------------------------------------------------------
# WordNet related
# See do_setup.bash

# Adhoc fixup's
wn="$(which wn > /dev/null 2>&1)"
if [ "$wn" == "" ]; then
    ## TODO: echo "Warning: unable to find WordNet wn binary"
    ## OLD: wn=/usr/bin/wn
    wn=wn
fi
## OLD:
## for _dir_ in /usr/share/wordnet /c/cygwin/lib/wnres/dict; do
##     if [[ ( ! -d "$WNSEARCHDIR") && ( -d $_dir_ ) ]]; then
##         export WNSEARCHDIR=$_dir_
##     fi
## done

#........................................................................
# Miscellaneous bash scripting helpers
# TODO: move other aliases here
trace bash helpers

# shell-check[-full](options, script, ...): run script through shellcheck
# with filtering given it's buggy filtering mecahanism (and anal retentiveness)
# note: specifies checking for bash (TODO: make optional)
function shell-check-full {
    shellcheck -s bash "$@";
}
function shell-check {
    # note: filters out following
    # - SC1090: Can't follow non-constant source. Use a directive to specify location.
    # - SC1091: Not following: ./my-git-credentials-etc.bash was not specified as input (see shellcheck -x).
    # - SC2004: $/${} is unnecessary on arithmetic variables
    # - SC2009: Consider using pgrep instead of grepping ps output.
    # - SC2012: Use find instead of ls to better handle non-alphanumeric filenames
    # - SC2129: Consider using { cmd1; cmd2; } >> file instead of individual redirects.
    # - SC2164: Use 'cd ... || exit' or 'cd ... || return' in case cd fails.
    # - SC2181 (style): Check exit code directly with e.g. 'if mycmd;' ...
    # - SC2196 (info): egrep is non-standard
    # - SC2219 (style): Instead of 'let expr', prefer (( expr )) .
    # - SC2230: which is non-standard
    # - TODO2: -e 'SC1090,SC1091,SC2009,SC2012,SC2129,SC2164,SC2181'
    ## OLD: shell-check-full "$@" | perl -0777 -pe 's/\n\s+(Did you mean:)/\n$1/g;' | perl-grep -para -v '(SC1090|SC1091|SC2009|SC2012|SC2129|SC2164|SC2181|SC2219|SC2230)';
    shell-check-full --exclude="SC1090,SC1091,SC2004,SC2009,SC2012,SC2129,SC2164,SC2181,SC2196,SC2219,SC2230" "$@" | perl -0777 -pe 's/\n\s+(Did you mean:)/\n$1/g;';
}

#-------------------------------------------------------------------------------
# Work-specific stuff (adhoc)
#
# TODO: put in separate file
#

#-------------------------------------------------------------------------------
# System administration
# TODO: do for ???
## OLD:
## if [ "$USER" = "root" ]; then
##     alias kill-software-updater='kill_em.sh --all --pattern "(software-properties-gtk|gnome-software|update-manager)"'
## fi
alias kill-software-updater='kill_em.sh --all --pattern "(software-properties-gtk|gnome-software|update-manager)"'
## OLD: alias update-software='/usr/bin/update-manager'
alias update-software='command update-manager'
alias kill-clam-antivirus='kill_em.sh --all -p clamd'

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

#------------------------------------------------------------------------
# Aliases for [re-]invoking aliases
alias tomohara-aliases='source "$TOM_BIN/tomohara-aliases.bash"'
alias tomohara-settings='source "$TOM_BIN/tomohara-settings.bash"'
alias more-tomohara-aliases='source "$TOM_BIN/more-tomohara-aliases.bash"'
alias tomohara-proper-aliases='source "$TOM_BIN/tomohara-proper-aliases.bash"'

# Optional end tracing
## OLD: startup-trace 'out tomohara-aliases.bash'
trace 'out tomohara-aliases.bash'
## DEBUG: echo 'out tomohara-aliases.bash'
