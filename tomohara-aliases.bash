# tomohara-aliases.bash: Tom's Initialization file for use with bash,
# using suppoting scripts from
#    http://www.cs.nmsu.edu/~tomohara/useful-scripts/tpo-useful-scripts.tar.gz
#
# NOTES:
# - ***** Put work-specific stuff in separate file!"
# - **** Add EX-bases tests for all numeric aliases!
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
#
# TODO:
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
# - Change references to grep with $GREP (e.g., egrep) for consistency and to avoid head scratching about extended regex patterns not working 
#

# For debugging: Uncomment the following line for tracing.
## echo in tomohara-aliases.bash
## set -o xtrace

#...............................................................................
# Conditional environment variable setting
# Format: cond-export VAR1 VALUE1 [VAR2 VALUE2] ...
#
function conditional-export () {
    local var value
    while [ "$1" != "" ]; do
        var="$1" value="$2";
        ## DEBUG: echo "value for env. var. $var: $(printenv "$var")"
        if [ "$(printenv "$var")" == "" ]; then
            export $var="$value"
        fi
        shift 2
    done
}
#
alias conditional-setenv='conditional-export'
alias cond-export='conditional-export'
# TODO: drop following after all do_setup.bash settings moved here
alias cond-setenv='conditional-export'

# For debugging: Uncomment the following to display the environment variables (TODO: rework via startup-trace).
## printenv.sh

#...............................................................................
# Directory for Tom O'Hara's scripts, defaulting to /home/tomohara if available
# otherwise $HOME/binDEBUG: 
cond-export TOM_DIR "/home/tomohara"
if [ ! -d "$TOM_DIR" ]; then export TOM_DIR=$HOME; fi
#
cond-export TOM_BIN "$TOM_DIR/bin"
if [ ! -e "$TOM_BIN/tomohara-aliases.bash" ]; then echo "*** Unable to resolve Tom's bin directory ***"; fi
alias tomohara-setup="source $TOM_BIN/tomohara-aliases.bash"

# Alias for startup-script tracing via startup-trace function
if [ ! -e "$HOME/temp" ]; then
   echo "WARNING: creating $HOME/temp for startup script logs"
   mkdir "$HOME/temp"
fi
#
# Define simple version of startup tracing
## OLD: function startup-trace () { if [ "$STARTUP_TRACING" = "1" ]; then echo $* [$HOSTNAME $(date)] >> $HOME/temp/.startup-$HOSTNAME-$$.log; fi; }
function startup-trace () { if [ "$STARTUP_TRACING" = "1" ]; then echo "$@" [$HOSTNAME $(date)] >> $HOME/temp/.startup-$HOSTNAME-$$.log; fi; }
# conditional-source(filename): source in bash commands from filename if exists
function conditional-source () { if [ -e "$1" ]; then source $1; else echo "Warning: bash script file not found (so not sourced):"; echo "    $1"; fi; }
function quiet-conditional-source { source "$@" > /dev/null 2>&1; }
#
# Enable full-blown startup tracing if evailable
# note: kept separate for use in other scripts
conditional-source $TOM_BIN/startup-tracing.bash
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
function downcase-stdin() { perl -pe 's/.*/\L$&/;'; }
function downcase-text() { echo "$@" | downcase-stdin; }
# todays-date(): outputs date in format DDMmmYY (e.g., 22Apr20)
## OLD: function todays-date() { date '+%d%b%y' | perl -pe 's/.*/\L$&/;'; }
## TODO: drop leading digits in day of month
function todays-date() { date '+%d%b%y' | downcase-stdin; }
todays_date=$(todays-date)
## MISC:
## # Convenience alias and bash variable for better tab-completion
## alias hoy=todays-date
## hoy=$(todays-date)
# Note: version so Spanish not used in note files
# TODO: punt on tab-completion (i.e., TODAY => today)???
alias TODAY=todays-date
## OLD: TODAY=$(todays-date)
alias date-central='TZ="America/Chicago" date'
## OLD: alias em-adhoc-notes='emacs-tpo _adhoc.$(TODAY).log'
alias em-adhoc-notes='emacs-tpo _adhoc-notes.$(TODAY).txt'
alias T='TODAY'
## OLD: T=$(TODAY)
# update-today-vars() & todays-update: update the various today-related variables
# aside: descriptive name for function and convenience alias (tab-completion)
# TODO: try for cron-like bash function to enable such updates automatically
function update-today-vars {
    TODAY=$(todays-date)
    T=$TODAY
}
update-today-vars
alias todays-update='update-today-vars'

# Alias creation helper(s)
## OLD: function quiet-unalias () { unalias "$@" 2> /dev/null; }
# Note: does no-op so that status set to 0 for sake of tests/test_tomohara-aliases.bash setup
# TODO: use more explicit way to set status
## TODO: function quiet-unalias { unalias "$@" 2> /dev/null; echo > /dev/null; }
function quiet-unalias {
    ## HACK: do nothing if running under bats-core
    if [ "$BATS_TEST_NUMBER" != "" ]; then
	if [ "$BATCH_MODE" != "1" ]; then
            echo "Ignoring unalias over $@ for sake of bats"
	fi
        return
    fi
    unalias "$@" 2> /dev/null;
    echo > /dev/null;
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
## OLD: export HISTCONTROL=erasedups
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
# Note: bash setting(s) in ~/.bash+profile
# format: shopt [-s | -u] optionname
# where -s to sets and -u unsets
# shopt -s nocaseglob   # ignore case in filename glob patterns
#
# Ignore case in pattern matching
shopt -s nocasematch

#-------------------------------------------------------------------------------
trace do_setup.bash invocation

# Get initital settings from ~/bin/do_setup.bash
if [ -e $TOM_BIN/do_setup.bash ]; then source $TOM_BIN/do_setup.bash; fi

#-------------------------------------------------------------------------------
trace 'in tomohara-aliases.bash'

# # HACK: load in older tpo-setup.bash
# conditional-source $TOM_BIN/tpo-setup.bash

# Fixup for Linux OSTYPE setting (likewise for solaris)
# TODO: use ${OSTYPE/[0-9]*/}
case "$OSTYPE" in linux-*) export OSTYPE=linux; esac
case "$OSTYPE" in solaris*) 
     export OSTYPE=solaris; 
     alias printenv='printenv.sh'
esac

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
alias less-="$PAGER_NOEXIT"
alias less-clipped="$PAGER_NOEXIT -S"
alias less-tail="$PAGER_NOEXIT +G"
alias less-tail-clipped="$PAGER_NOEXIT +G -S"
alias ltc=less-tail-clipped
export ZPAGER=zless

#-------------------------------------------------------------------------------
trace start of main settings

# Path settings
# TODO: define a function for removing duplicates from the PATH while
# preserving the order
function show-path-dir () { (echo "${1}:"; printenv $1 | perl -pe "s/:/\n/g;") | $PAGER; }
alias show-path='show-path-dir PATH'
# append-path(path): appends PATH to environment variable unless already there
## TODO: function in-path { local path=$(tr ":" "\n" | $GREP "^$1$$"); return ($path != ""); }
# TODO: add force argument to ensure last (or first)
function append-path () { if [[ ! (($PATH =~ ^$1:) || ($PATH =~ :$1:) || ($PATH =~ :$1$)) ]]; then export PATH="${PATH}:$1"; fi }
function prepend-path () { if [[ ! (($PATH =~ ^$1:) || ($PATH =~ :$1:) || ($PATH =~ :$1$)) ]]; then export PATH="$1:${PATH}"; fi }
# TODO: rework append-/prepend-path and python variants via generic helper
function append-python-path () { export PYTHONPATH=${PYTHONPATH}:"$1"; }
function prepend-python-path () { export PYTHONPATH="$1":${PYTHONPATH}; }

# TODO: develop a function for doing this
if [ "`printenv PATH | $GREP $TOM_BIN:`" = "" ]; then
   export PATH="$TOM_BIN:$PATH"
fi
if [ "`printenv PATH | $GREP $TOM_BIN/${OSTYPE}:`" = "" ]; then
   export PATH="$TOM_BIN/${OSTYPE}:$PATH"
fi
# TODO: make optional & put append-path later to account for later PERLLIB changes
append-path $PERLLIB
prepend-path "$HOME/python/Mezcla/mezcla"
append-path "$HOME/python"
# Put current directoy at end of path; can be overwritting with ./ prefix
export PATH="$PATH:."
# Note: ~/lib only used to augment existing library, not pre-empt
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/lib:$HOME/lib/linux

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
export TEMP=$HOME/temp
export TMP=$TEMP/tmp
export TMPDIR=$TMP
mkdir -p "$TEMP" "$TMP" "$TMPDIR"
# NOTE: LINE and COLUMNS are in support of ps_sort.perl and h (history).
# They get reset via resize.
cond-export LINES 52
cond-export COLUMNS 80

# NOTE: resize used to set lines below
#
if [ "$DOMAIN_NAME" = "" ]; then export DOMAIN_NAME=`domainname.sh`; fi
alias run-csh='export USE_CSH=1; csh; export USE_CSH=0'

# Note: support for prompt prefix
# reset-prompt(symbol): resets PS1 to PS_symbol, optionally changed to symbol
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
    ## OLD: local new_PS_symbol="$1"
    local new_PS_symbol="$@"
    ## OLD:
    if [ "$new_PS_symbol" = "" ]; then new_PS_symbol="${DEFAULT_PS_SYMBOL:-$PS_symbol}"; fi
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
## OLD: alias root-prompt='reset-prompt "# "'
alias reset-prompt-root='reset-prompt "# "'
alias reset-prompt-dollar="reset-prompt '$'"
alias reset-prompt-default="reset-prompt '$PS_symbol'"

#-------------------------------------------------------------------------------
# More misc stuff

# reset CDPATH to just current directory
export CDPATH=.

## OLD
## # Just use $ for Bash prompt
## # NOTE: cd override puts directory name in xterm title
## OLD: reset-prompt
##

# If interactive session, change prompt to $PS1 (via $PS_symbol).
# Note: directory is instead put in xterm title (via set_xterm_title.bash)
if [[ $- =~ i ]]; then reset-prompt; fi

# flag for turning off GNOME, which can be flakey at times
# See xterm.sh (e.g., gnome-terminal).
export USE_GNOME=1

# General Settings for my scripts
export DEBUG_LEVEL=2
export PRECISION=3
alias debug-on='export DEBUG_LEVEL=3'
if [ "$PERLLIB" = "" ]; then PERLLIB="."; else PERLLIB="$PERLLIB:."; fi
# NOTE: perl uses architecture-specific subdirectories under PERLLIB
export PERLLIB="$TOM_BIN:$PERLLIB:$HOME/perl/lib/perl5/site_perl/5.8"
# HACK: not all cygwin directories being recognized
export PERLLIB="$HOME/perl/lib/perl5/5.16:$HOME/perl/lib/perl5/5.16/vender_perl:$PERLLIB"
alias perl-='perl -Ssw'
export MANPATH="$HOME/perl/share/man/man1:$MANPATH"
append-path $HOME/perl/bin
# Note: TIME is used for changing output format, so TIME_CMD used instead.
# TODO: Do check for environment variable overlap (as with DEBUG_LEVEL clash with software
# used at Convera).
export TIME_CMD=/usr/bin/time
export PERL="$NICE $TIME_CMD perl -Ssw"
export BRIEF_USAGE=1

# Terminal window title
alias set-xterm-title='set_xterm_title.bash'
## OLD: alias set-xterm-window='set_xterm_title.bash'
alias set-xterm-window='set-xterm-title'
# Set the title for the current xterm, unless if not running X
function set-title-to-current-dir () { 
    local dir=`basename "$PWD"`; 
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
quiet-unalias alt-xterm-title
function alt-xterm-title() { 
    local dir=$(basename $PWD)
    set-xterm-window "alt: $dir $PWD"; 
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
cond-export LANGUAGE_TOOL_HOME $TOM_DIR/programs/java/LanguageTool-2.1

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
## OLD: function cd-realdir { local dir="$1";  if [ "$dir" = "" ]; then dir=.; fi;  cd $(realpath "$dir"); }
function cd-realdir {
    local dir="$1";
    if [ "$dir" = "" ]; then dir=.; fi;
    cd $(realpath "$dir");
    pwd;
}
alias cd-this-realdir='cd-realdir .'

# pushd-q, popd-q: quiet versions of pushd and popd
#
function pushd-q () { builtin pushd "$@" >| /dev/null; }
function popd-q () { builtin popd "$@" >| /dev/null; }
#

# Command overrides for moving and copying files
# NOTE: -p option of cp (i.e., --preserve  "preserve file attributes if possible")
# leads to problems when copying files owner by others (although group writable)
#    cp: preserving times for /usr/local/httpd/internal/cgi-bin/phone-list: Operation not permitted
# - other options for cp, mv, and rm: -i interactive; and -v verbose.
other_file_args="-v"
if [ "$OSTYPE" = "solaris" ]; then other_file_args=""; fi
alias cls='clear'
MV="/bin/mv -i $other_file_args"
alias mv='$MV'
alias move='mv'
alias move-force='move -f'
# TODO: make sure symbolic links are copied as-is (ie, not dereferenced)
CP="/bin/cp -ip $other_file_args"
alias copy="$CP"
alias copy-force="/bin/cp -fp $other_file_args"
alias cp="/bin/cp -i $other_file_args"
alias rm="/bin/rm -i $other_file_args"
alias delete="/bin/rm -i $other_file_args"
alias del="delete"
alias delete-force="/bin/rm -f $other_file_args"
#
alias remove-force='delete-force'
# TODO: make sure that rellowing only applied to directories
alias remove-dir='/bin/rm -rv'
alias delete-dir='remove-dir'
alias remove-dir-force='/bin/rm -rfv'
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
    for f in $($LS $spec); do copy-readonly "$f" "$dir"; done
}
# copy-readonly-to-dir(dir, file, ...): variant of copy-readonly-spec with
# directory first and files given in args 2, 3, etc.
function copy-readonly-to-dir () {
    local dir="$1"
    shift
    ## TODO: copy-readonly-spec "'" "$@" "'"  "$dir"
    for f in $@; do copy-readonly "$f" "$dir"; done
}
#
export NICE="nice -19"
export TIME_CMD="/usr/bin/time"

alias fix-dir-permissions="find . -type d -exec chmod go+xs {} \;"

#-------------------------------------------------------------------------------
trace directory commands

# Support for ls (list directory contents)
# 
# ls options: # --all: all files; -l long listing; -t by time; --human-readable: uses numeric suffixes like MB; --no-group: omit file permision group; --directory: no subdirectory listings.
# TODO: Add --long as alias for -l to ls source control and check-in [WTH?]! Likweise, all aliases for other common options without long names (e.g., -t).
#
LS="/bin/ls"
core_dir_options="--all -l -t  --human-readable"
dir_options="${core_dir_options} --no-group"
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
function dir-proper () { $LS "${dir_options} --directory" "$@" 2>&1 | $PAGER; }
alias ls-full='$LS ${core_dir_options}'
function dir-full () { ls-full "$@" 2>&1 | $PAGER; }
function dir-sans-backups () { $LS ${dir_options} "$@" 2>&1 | $GREP -v '~[0-9]*~' | $PAGER; }
## OLD:
## function dir-ro () { $LS ${dir_options} "$@" 2>&1 | $GREP -v '^[^ld].w' | $PAGER; }
## function dir-rw () { $LS ${dir_options} "$@" 2>&1 | $GREP '^[^ld].w' | $PAGER; }
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
function dir_options_san_t () { echo "$dir_options" | perl -pe 's/t//;'; }
function subdirs-alpha () { $LS $(dir_options_san_t) "$@" 2>&1 | $GREP ^d | $PAGER; }
function sublinks () { $LS ${dir_options} "$@" 2>&1 | $GREP ^l | $PAGER; }
function sublinks-alpha () { $LS $(dir_options_san_t) "$@" 2>&1 | $GREP ^l | $PAGER; }
# TODO: show non-work-related directory example
#
alias symlinks='sublinks'
# symlinks-proper: just show file name info for symbolic links, which starts at column 43
alias symlinks-proper='symlinks | cut --characters=43-'
#
function sublinks-proper { sublinks "$@" | cut --characters=42-  | $PAGER; }
alias symlinks-proper=sublinks-proper
#
alias glob-links='find . -maxdepth 1 -type l | sed -e "s/.\///g"'
alias glob-subdirs='find . -mindepth 1 -maxdepth 1 -type d | sed -e "s/.\///g"'
#
alias ls-R='$LS -R >| ls-R.list; wc -l ls-R.list'
#
# TODO: create ls alias that shows file name with symbolic links (as with ls -l but without other information
# ex: ls -l | perl -pe 's/^.* \d\d:\d\d //;'

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
## TODO: quiet-unalias grep
## TODO: add alias for resolving grep binary with fallback to "command grep"
GREP="/bin/grep"
EGREP="$GREP -E"
export MY_GREP_OPTIONS="-n $skip_dirs -s"
function gr () { $GREP $MY_GREP_OPTIONS -i "$@"; }
function gr- () { $GREP $MY_GREP_OPTIONS "$@"; }
SORT_COL2="--key=2"
function grep-unique () { $GREP -c $MY_GREP_OPTIONS "$@" | $GREP -v ":0" | sort -rn $SORT_COL2 -t':'; }
function grep-missing () { $GREP -c $MY_GREP_OPTIONS "$@" | $GREP ":0"; }
alias gu='grep-unique -i'
alias gru='gu'
alias gu-='grep-unique'
function gu-all () { grep-unique "$@" * | $PAGER; }
#
function gu- () { $GREP -c $MY_GREP_OPTIONS "$@" | $GREP -v ":0"; }
#
# grepl(pattern, [other_grep_args]): invokes grep over PATTERN and OTHER_GREP_ARGS and then pipes into less for PATTERN 
# TODO: use more general way to ensure pattern given last while readily extractable for less -p usage
## OLD: function grep-to-less () { $GREP $MY_GREP_OPTIONS "$@" | $PAGER -p"$1"; }
function grep-to-less () { $GREP $MY_GREP_OPTIONS "$@" | $PAGER_NOEXIT -p"$1"; }
alias grepl-='grep-to-less'
function grepl () { pattern="$1"; shift; grep-to-less "$pattern" -i "$@"; }

# TODO: create function for creating gr-xyz aliases
# TODO: -or- create gr-xyz template
## function gr-xyz () { gr- "$@" *.xyz; }

# show-line-context(file, line-num): show 5 lines before LINE-NUM in FILE
function show-line-context() { cat -n $1 | $GREP -B5 "^\W+$2\W"; }

# Helper function for grep-based aliases pipe into less
function gr-less () { gr "$@" | $PAGER; }

# Other grep-related stuff
#
# EX: echo $'1 one\n2 \x80\n3 three' | gr-nonascii => $'2: 2 \x80'
alias grep-nonascii='perlgrep.perl "[\x80-\xFF]"'

# Searching for files
# TODO:
# - specify find options in an environment variable
# - rework in terms of Perl regex? (or use -iregex in place of -iname)
#
function findspec () { if [ "$2" = "" ]; then echo "Usage: findspec dir glob-pattern find-option ... "; else /usr/bin/find $1 -iname \*$2\* $3 $4 $5 $6 $7 $8 $9 2>&1 | $GREP -v '^find: '; fi; }
function findspec-all () { find $1 -follow -iname \*$2\* $3 $4 $5 $6 $7 $8 $9 -print 2>&1 | $GREP -v '^find: '; }
function fs () { findspec . "$@" | $EGREP -iv '(/(backup|build)/)'; } 
function fs-ls () { fs "$@" -exec ls -l {} \; ; }
alias fs-='findspec-all .'
function fs-ext () { find . -iname \*.$1 | $EGREP -iv '(/(backup|build)/)'; } 
# TODO: extend fs-ext to allow for basename pattern (e.g., fs-ext java ImportXML)
function fs-ls- () { fs- "$@" -exec ls -l {} \; ; }
#
findgrep_opts="-in"
#
# NOTE: findgrep macros use $findgrep_opts dynamically (eg, user can change $findgrep_opts)
function findgrep-verbose () { find $1 -iname \*$2\* -print -exec $GREP $findgrep_opts "$3" $4 $5 $6 $7 $8 $9 \{\} \;; }
# findgrep(dir, filename_pattern, line_pattern): $GREP through files in DIR matching FILENAME_PATTERN for LINE_PATTERN
function findgrep () { find $1 -iname \*$2\* -exec $GREP $findgrep_opts "$3" $4 $5 $6 $7 $8 $9 \{\} /dev/null \;; }
function findgrep- () { find $1 -iname $2 -print -exec $GREP $findgrep_opts $3 $4 $5 $6 $7 $8 $9 \{\} \;; }
function findgrep-ext () { local dir="$1"; local ext="$2"; shift; shift; find "$dir" -iname "*.$ext" -exec $GREP $findgrep_opts "$@" \{\}  /dev/null \;; }
# fgr(filename_pattern, line_pattern): $GREP through files matching FILENAME_PATTERN for LINE_PATTERN
function fgr () { findgrep . "$@" | $EGREP -v '((/backup)|(/build))'; }
function fgr-ext () { findgrep-ext . "$@" | $EGREP -v '(/(backup)|(build)/)'; }
alias fgr-py='fgr-ext py'
#
# prepare-find-files-here(): produces listing(s) of files in current directory
# tree, in support of find-files-here; this contains full ls entry (as with -l).
# (The subdirectory listings produced by 'ls -alR' are preceded by blank lines,
# which is required for find-files-here as explained below.)
# Notes: Also puts listing proper in ls-R.list (i.e., just list of files).
# TODO: create external script and have alias call the script
function prepare-find-files-here () {
    if [ "$1" != "" ]; then
        echo "Error: No arguments accepted; did you mean find-files-here?"
        return
    fi
    local brief_opts="R"
    local full_opts="alR"
    local brief_file="ls-$brief_opts.list"
    local full_file="ls-$full_opts.list"
    local current_files=($full_file $full_file.log $brief_file $brief_file.log)
    # Rename existing files with file date as suffix (TODO move into ./backup)
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
    
    $LS -lh ${current_files[@]}
}
#
# TODO: have variant of prepare-find-files that adds .mmmYY suffix to backup
#
# find-files-there(pattern, ls-alR-files): check for PATTERN in LS-ALR-FILES,
# showing the directory, which has trailing ':' in listing (i.e., DIR1:\nentry1\n...entryN\n\nDIR2:\n...)
# exs: "./archive:", "-rwxrwx--- 1 root vboxsf   19125 Dec  7  2013 morph.txt", "-rwxrwx--- 1 root vboxsf      35 Jan 17 12:19 python-notes.txt"
# Note: Perl paragraph-mode search first matches files along with the containing
# subdirectory, and then line-mode search filters out non-matching files.
#
function find-files-there () { perlgrep.perl -para -i "$@" | $EGREP -i '((:$)|('$1'))' | $PAGER_NOEXIT -p "$1"; }
function find-files-here () { find-files-there "$1" "$PWD/ls-alR.list"; }
# following variants for sake of tab completion
alias find-files='find-files-here'
alias find-files-='find-files-there'
# TODO: function find-files-dated () { perlgrep.perl -para -i "$@" | $EGREP -i '((:$)|('$1'))' | $PAGER_NOEXIT -p "$1"; }
#
# TODO: add --quiet option to dobackup.sh (and port to bash)
# TODO: function conditional-backup() { if [ -e "$1" ]; then dobackup.sh $1; fi; }
alias make-file-listing='listing="ls-aR.list"; dobackup.sh "$listing"; $LS -aR >| "$listing" 2>&1'

# Emacs commands
#
# emacs-tpo([args] [file]...) invokes emacs w/ ~.emacs.tpo if exists otherwise ~/.emacs
# em: alias for emacs (or emacs-tpo) with dired for current directory if no file given
# em-nw: emacs with --no-windows
# TODO: add synopsis for others
#
alias emacs-tpo='tpo-invoke-emacs.sh'
alias em=emacs-tpo
function em-fn () { em -fn "$1" $2 $3 $4 $5 $6 $7 $8 $9; }
alias em-tags=etags
#
alias em-misc='em-fn -misc-fixed-medium-r-normal--14-110-100-100-c-70-iso8859-1'
alias em-nw='emacs -l ~/.emacs --no-windows'
## TODO: alias em-tpo='emacs -l ~/.emacs'
alias em-tpo-nw='emacs -l ~/.emacs --no-windows'
alias em_nw='em-nw'
# em-file(filename): edit filename with current directory set to it's dir
# note: This avoids stupid link resolution problem under cygwin. It is
# also useful so that Emacs current directory is set appropriately.
function em-file() {
    local file="$1"
    local base=$(basename "$file")
    local dir=$(dirname "$file")
    command pushd $dir
    em "$base"
    command popd
    }
alias em-dir=em-file
alias em-this-dir='em .'
alias em-devel='em --devel'
#
function em-debug () { em -debug-init "$@"; }
function em-quick () { em --quick "$@"; }

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
function view-todo () {
    local search_arg=""
    if [ "$1" != "" ]; then search_arg="-p $1"; fi
    # note: quotes not put around search arg to avoid interpretation as file
    perl -SSw reverse.perl $HOME/organizer/todo_list.text | $PAGER_CHOPPED $search_arg; 
}
#
function add-todo () { echo "$@" $'\t'`date` >> $HOME/organizer/todo_list.text; if [ "$?" = "0" ]; then view-todo; fi; }
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
function TODO1() { todo "$@"'!'; }
alias todo1=TODO1
#
function todo! () { if [ "$1" == "" ]; then todo; else todo "$@"'!'; fi; }
#
# mail-todo: version of todo that also ends email
# TODO: use lynx to submit send-to type URL
# TODO: use '$@' for '$*' (or note why not appropriate)
function mail-todo () { add-todo "$*"; echo TODO: "$*" | mail -s "TODO: $*" ${USER}@${DOMAIN_NAME}; }
#
# Likewise for time tracking
alias view-track-time="tac $HOME/organizer/time_tracking_list.text | $PAGER_CHOPPED"
alias view-time-tracking=view-track-time
#
function add-track-time () { echo "$@" $'\t'`date` >> $HOME/organizer/time_tracking_list.text ; view-track-time; }
#
function track-time () { if [ "$1" == "" ]; then echo add-track-time '"..."'; else add-track-time "$@"; fi; }
alias time-tracking=track-time
alias 'track-time:'='track-time'

# Simple calculator commands
function old-calc () { echo "$@" | bc -l; }
# EX: perl-calc "2 / 4" => 0.500
function perl-calc () { perl- perlcalc.perl -args "$@"; }
# TODO: read up on variable expansion in function environments
function perl-calc-init () { initexpr=$1; shift; echo "$@" | perl- perlcalc.perl -init="$initexpr" -; }
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
function asctime() { perl -e "print (scalar localtime($1));"; echo ""; }
# filter-dirnames: strip directory names from ps listing
function filter-dirnames () { perl -pe 's/\/[^ \"]+\/([^ \/\"]+)/$1/g;'; }

# comma-ize-number(): add commas to numbers in stdin
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
    $NICE du --block-size=1K --one-file-system 2>&1 | $NICE sort -rn | apply-usage-numeric-suffixes >| $output_file 2>&1;
    $PAGER $output_file;
}
function usage-alt {
    local output_file=$TEMP/$(basename $PWD)"-usage.list";
    usage "$output_file"
}

function byte-usage () { output_file="usage.bytes.list"; backup-file $output_file; $NICE du --bytes --one-file-system 2>&1 | $NICE sort -rn | apply-usage-numeric-suffixes >| $output_file 2>&1; $PAGER $output_file; }
## TODO: function usage () { du --one-file-system --human-readable 2>&1 | sort -rn >| usage.list 2>&1; $PAGER usage.list; }

# check[all-]-(errors|warnings): check for known errors, with the check-all
# variant including more patterns and with warnings subsuming errors.
## OLD:
## function check-errors () { (check_errors.perl -context=5 "$@") 2>&1 | $PAGER; }
## function check-all-errors () { (check_errors.perl -warnings -relaxed -context=5 "$@") 2>&1 | $PAGER; }
function check-errors () { (DEBUG_LEVEL=1 check_errors.perl -context=5 "$@") 2>&1 | $PAGER; }
function check-all-errors () { (DEBUG_LEVEL=1 check_errors.perl -warnings -relaxed -context=5 "$@") 2>&1 | $PAGER; }
alias check-warnings='echo "*** Error: use check-all-errors instead ***"; echo "    check-all-errors"'
alias check-all-warnings='check-all-errors -strict'
#
# check-errors-excerpt(log-file): show errors are start of log-file and at end if different
function check-errors-excerpt () {
    local base="$TMP/check-errors-excerpt-$$"
    local head="$base.head"
    local tail="$base.tail"
    check-errors "$@" | head >| $head;
    cat "$head"
    check-errors "$@" | tail >| $tail;
    diff "$head" "$tail" >| /dev/null
    if [ $? != 0 ]; then
        echo "\$?=$?"
        cat "$tail";
    fi
}

# Note: various aliases for doing diff-based comparisons
#
function tkdiff () { wish -f $TOM_BIN/tkdiff.tcl "$@" & }
alias rdiff='rev_vdiff.sh'
alias tkdiff-='tkdiff -noopt'
#
function kdiff () { kdiff.sh "$@" & }
alias vdiff='kdiff'
#
# diff(): run diff command w/ --ignore-all-space (-w) and --ignore-space-change (-b)
diff_options="--ignore-space-change --ignore-blank-lines"
alias diff='command diff $diff_options'
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
    ## OLD: if [ -d "$left_file" ]; then left_file="$left_file/$right_file"; fi
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
    ## TODO: $LS -t $dir/* | $EGREP "/$file(~|.~*)" | head -1;
    $LS -t $dir/* | /bin/egrep "/$file(~|.~*)?" | head -1;
}
#
# diff-backup(file): compare FILE vs. most recent backup
function diff-backup-helper {
    local diff="$1"; local file="$2"; 
    "$diff" $(most-recent-backup "$file") "$file";
}
alias diff-backup='diff-backup-helper diff'
alias kdiff-backup='diff-backup-helper kdiff'

# See
#     ^^^ TODO: what
function signature () {
    if [ "$1" = "" ]; then
        $LS $HOME/info/.$1-signature
        echo "Usage: signature dotfile-prefix"
        echo "ex: signature scrappycito"
        return;
    fi
    ## TODO: echo filename and then cat??
    ## OLD: head $HOME/info/.$1-signature
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
GTAR="tar"
alias gtar="$GTAR"
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
    local base=$1; local dir=$2; local depth=$3; local filter=$4;
    local depth_arg=""; local filter_arg="."
    if [ "$dir" = "" ]; then dir="."; fi;
    if [ "$depth" != "" ]; then depth_arg="-maxdepth $depth"; fi;
    if [ "$filter" != "" ]; then filter_arg="-v $filter"; fi;
    # TODO: make pos-tar ls optional, so that tar-in-progress is viewable
    ## OLD:
    (find "$dir" $find_options $depth_arg -not -type d -print | $GREP -i "$filter_arg" | $NICE $GTAR cvfTz "$base.tar.gz" -) >| "$base.tar.log" 2>&1;
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
    local dir=$1; local depth=$2;
    local archive_base=$TEMP/`basename "$dir"`
    make-tar "$archive_base" "$dir" $depth
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
function tar-just-dir () { tar-dir $1 1; }
#
# tar-this-dir(): create tar archive into TEMP, for sud-directory tree routed
# in current directory (using directory basename as file prefix instead of .)
# ex: TEMP=/mnt/my-external-drive/tmp tar-this-dir
function tar-this-dir () { local dir="$PWD"; pushd-q ..; tar-dir "`basename "$dir"`"; popd-q; }
# test of resolving problem with tar-this-dir if dir a symbolic link from apparent parent
function new-tar-this-dir () {
    local dir="$PWD";                   # ex: /home/tomohara/tpo-magro-p3 [=> /media/tomohara/ff3410d4-5ffc-4c01-a2ca-75244b882aa2]
    local base=$(basename "$PWD")
    # Go to parent dir                        /home/tomohara
    pushd-q ..
    # Get real basename                       ff3410d4-5ffc-4c01-a2ca-75244b882aa2
    local real_base="$base"
    if [ -L "$base" ]; then
        real_base=$($LS -ld "$base" | perl -pe 's@^.* -> (.*/)?([^/]+)@$2@;');
        # Go to real parent                   /media/tomohara
        cd $(realpath $dir/..)
    fi
    # Create tar of real subdir
    # TODO: pass along actual basename so that tar file can be renamed
    tar-dir "$real_base";
    popd-q;
}
#
# tar-this-dir-normal: creates archive of directory, excluding archive, backup, and temp subdirectories
function tar-this-dir-normal () { local dir="$PWD"; pushd-q ..; tar-dir "`basename "$dir"`" "" "/(archive|backup|temp)/"; popd-q; }
#
function tar-just-this-dir () { local dir="$PWD"; pushd-q ..; tar-dir "`basename "$dir"`" 1; popd-q; }
function make-recent-tar () { (find . -type f -mtime -$2 | $GTAR cvfzT $1 -; ) 2>&1 | $PAGER; ls-relative $1; }
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
alias recent-tar-this-dir='make-recent-tar $TEMP/recent-`basename "$PWD"`'
function sort-tar-archive() { (tar tvfz "$@" | sort --key=3 -rn) 2>&1 | $PAGER; }
#
# TODO: tar-this-dir-there???
# ex: ¢ TEMP=/mnt/wd6tbp2vfat/backup/tpo-servidor tar-this-dir
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
# EX: echo $'1 one\n2 two\n3' | perlgrep 'o\w' => $'1 one'
alias perlgrep='perl- perlgrep.perl'
alias perl-grep=perlgrep
function para-grep { perlgrep -para "$@" 2>&1 | $GREP -v "Can't open \*notes\*"; }
alias para-gr='para-grep -i -n'
## TODO: make a pass to ensure aliases have unique leading prefix, as well as being easy to remember (n.b., ease of tab completion vs. recall)
function cached-notes-para-gr { para-gr "$@" _master-note-info.list | $PAGER; }
# TODO: work out better name
function cached-notes-para-gr-less { cached-notes-para-gr "$@" | less -p "$1"; }
# EX: echo $'1\n2\n3\n4\n5' | calc-stdev => "num = 5; mean = 3.000; stdev = 1.581; min = 1.000; max = 5.000; sum = 15.000"
function calc-stdev () { sum_file.perl -stdev "$@" -; }
## MISC: alias calc-stdev-file='calc-stdev <'
## MISC: alias sum-col2='sum_file.perl -col=2 -'
notes_glob="*notes*.txt  *notes*.list *notes*.log"
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
    perl -00 -pe 's/\n\n/\n \n/g; s/^\-{40}/\n$&/g;' $glob 2>&1 | perlgrep -para -i "$@" -  2>&1 | $PAGER;
}
alias notes-entry-gr='notes-entry-gr-aux "$notes_glob"'
function notes-entry-gr-less-p { notes-entry-gr "$@" | less -p "$1"; }
alias entry-notes=notes-entry-gr
alias cached-entry-gr='notes-entry-gr-aux _master-note-info.list'
function cached-entry-gr-less-p { cached-entry-gr "$@" | less -p "$1"; }
# TODO: * work good scheme for shortcut aliases (e.g. both memorable and easily tab-completable)!
alias grepl-entry=cached-entry-gr-less-p

# TODO: use .list instead of .log in note files to minimize need for such an awkward move alias/function (n.b., .log files more common due to script usage than .list)
#
function prep-brill() { prep_brill.perl "$1" > "$1".pp; }

# Specialized file viewers
# TODO: put image viewer here
function pdf-view () { okular "$@" & }
function image-view () { gpicview "$@" & }

# FIle conversion
# note: when ps2ascii hangups, it creates large output files (e.g., > 1gb)
# TODO: handle filename wit
## OLD:
## function pdf-to-ascii () { cmd.sh --time-out 30 ps2ascii "$1" > "$1.ascii"; }
## function all-pdf-to-ascii () { 
##     for f in *.pdf; do
##         echo "checking $f.ascii"; 
##         if [ ! -e "$f.ascii" ]; then 
##             echo "converting $f"; 
##             pdf-to-ascii "$f"; 
##         fi; 
##     done; 
## }
##
function pdf-to-ascii () {
    local file="$1"
    local verbose="$2";
    local target=$(basename "$1" .pdf)".ascii";
    if [ "$verbose" = "1" ]; then echo "checking $target"; fi
    if [ ! -s "$target" ]; then
        if [ "$verbose" = "1" ]; then echo "creating $target"; fi
        cmd.sh --time-out 30 pdftotext -layout "$file" "$target";
    fi
    $LS -lt "$target"
}
function all-pdf-to-ascii () { for f in *.pdf; do pdf-to-ascii "$f"; done; }

# Specialized file editors
function run-app {
    local path="$1";
    local app=$(basename $path);
    shift;
    ## OLD: local log=~/temp/"$app-$hoy.log"
    local log=~/temp/"$app-"$(TODAY)".log"
    "$app" "$@" >> "$log" 2>&1 &
    ## TODO: make sure command invoked OK and then put into background
    sleep 5
    check-errors "$log" | cat
    }
alias foxit='run-app /opt/foxitsoftware/foxitreader/FoxitReader'
alias gimp='run-app gimp'

#------------------------------------------------------------------------

alias do-resize="resize >| $TEMP/resize.sh; conditional-source $TEMP/resize.sh"

#-------------------------------------------------------------------------------
trace alias/function info

# Displaying bash aliases and functions
# note: '.' used in grep to handle special case of no pattern;
# TODO: use '$@' for '$*' (or note why not appropriate)
#
alias show-functions-aux='typeset -f | perl -pe "s/^}/}\n/;"'
# TODO: allow for specifying word-boundary matching
function show-all-macros () {
    pattern="$*";
    if [ "$pattern" = "" ]; then pattern=.; fi;
    alias | $GREP -i "$pattern" | perl -ne 'print("$_\n");';
    show-functions-aux | perlgrep -i -para $pattern;
}

function show-macros () { show-all-macros "$*" | perlgrep -v -para "^_"; }
# TODO: figure out how to exclude env. vars from show-variables output
function show-variables () { set | $GREP -i '^[a-z].*='; }

## MISC: function show-macros-by-word () { pattern="\b$*\b"; if [ "$pattern" = "" ]; then pattern=.; fi; alias | $GREP $pattern ; show-functions-aux | perlgrep -para $pattern; }
alias show-aliases='alias | $PAGER'
# TODO: see if other aliases were "recursively" defined
alias show-functions='show-functions-aux | $PAGER'
# TODO: *** see if way to make bash automatically use less-like pager: too complicated to have to account in specific command aliases/functions
# TODO??: override 'function' to allow for showing bindings as with 'alias'
## function function { if ["$2" = "" ]; then show-functions "$1"; else builtin function "$@"
# NOTE: probably not possible for syntax reasons (e.g., braces)

#-------------------------------------------------------------------------------
trace setup and sorting wrappers

# Editing and activating new settings
#
alias do-setup="conditional-source $HOME/.bashrc"

# Sorting wrappers
#
alias tab-sort="sort -t $'\t'"
alias colon-sort="sort $SORT_COL2 -t ':'"
alias colon-sort-rev-num='colon-sort -rn'
alias freq-sort='tab-sort -rn $SORT_COL2'
# TODO: use '$@' for '$*' (or note why not appropriate)
function para-sort() { perl -00 -e '@paras=(); while (<>) {push(@paras,$_);} print join("\n", sort @paras);' $*; }
alias echoize="perl -pe 's/\n(.)/ $1/;'"

#-------------------------------------------------------------------------------
trace file manipulation and conversions

function asc-it () { dobackup.sh $1; asc < BACKUP/$1 >| $1; }
# TODO: use dos2unix under CygWin
alias remove-cr='tr -d "\r"'
alias perl-slurp='perl -0777'
alias alt-remove-cr='perl-slurp -pe "s/\r//g;"'
function remove-cr-and-backup () { dobackup.sh $1; remove-cr < backup/$1 >| $1; }
alias perl-remove-cr='perl -i.bak -pn -e "s/\r//;"'

# Text manipulation
alias 'intersection=intersection.perl'
alias 'difference=intersection.perl -diff'
alias 'line-intersection=intersection.perl -line'
alias 'line-difference=intersection.perl -diff -line'
function show-line () { tail --lines=+$1 $2 | head -1; }
#
# last-n-with-header(num, file): create sub-file with last NUM lines plus header from FILE
function last-n-with-header () { head --lines=1 "$2"; tail --lines=$1 "$2"; }

#-------------------------------------------------------------------------------
trace line/word count, etc. commands

# alias for counting words on individual lines thoughout a file
# (Gotta hate csh)
function line-wc () { perl -n -e '@_ = split; printf("%d\t%s", 1 + $#_, $_);' "$@"; }
alias line-word-len='line-wc'
function line-len () { perl -ne 'printf("%d\t%s", length($_) - 1, $_);' "$@"; }
function para-len () { perl -00 -ne 'printf("%d\t%s", length($_) - 1, $_);' "$@"; }
alias ls-line-len='$LS | line-len | sort -rn | less'

function check-class-dist () { count-it "^(\S+)\t" $1 | perl- calc_entropy.perl -; }

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
# TODO: see why --filter-dirnames added to ps-mine aliases
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
# rename-spaces: replace spaces in filenames of current dir with underscores
alias rename-spaces='rename-files -q -global " " "_"'
alias rename-quotes='rename-files -q -global "'"'"'" ""'   # where "'"'"'" is concatenated double quote, single quote, and double quote
## OLD: alias rename-special-punct='rename-files -q -global -regex "[&\!\*?]" ""'
alias rename-special-punct='rename-files -q -global -regex "[&\!\*?\(\)]" ""'
# move-duplicates: move duplicate produced via Firefox downloads
# ex: move "05-158-a-20 (1).pdf duplicates
alias move-duplicates='mkdir -p duplicates; move *\([0-9]\).* duplicates 2>&1 | $GREP -iv cannot.stat.*..No.such'
alias rename-etc='rename-spaces; rename-quotes; rename-special-punct; move-duplicates'
alias rename-parens='rename-files -global -regex "[\(\)]" "" *[\(\)]*'
# move "versioned" log files into ./log-file subdirectory
#    *** files end in .log[0-9]+ or .log and have numeric affix (e.g., do-xyz.log2, do-xyz.2.log, or do-xyz-30may21.log)
#
# move-log-files: move "versioned" log files to log-files
# move-output-files: likewise for output files with version numbers to ./output
# note: versioned files are those ending in numerics or with numeric affix
## TODO: use perl-style regex for more precise matching (effing over-arching glob's)
function move-versioned-files {
    local ext_pattern="$1"
    if [ "$ext_pattern" = "" ]; then ext_pattern="{list,log,txt}"; fi
    local dir="$2"
    if [ "$dir" = "" ]; then dir="versioned-files"; fi
    mkdir -p "$dir";
    ## OLD: local D="[.]"
    local D="[-.]"
    # TODO: fix problem leading to hangup (verification piped to 2>&1)
    # Notes: eval needed for $ext_pattern resolution
    # - excludes read-only files (e.g., ls -l => "-r--r--r--   1 tomohara   11K Nov  2 16:30 _master-note-info.list.log")
    # EXs:              fu.log2                fu.2.log                  fu.log.14aug21    fu.14aug21.log
    local file_list="$TEMP/_move-versioned-files-$$.list"
    ## TODO: dir-rw $(eval echo *$D$ext_pattern[0-9]*  *$D*[0-9]*$D$ext_pattern  *$D$ext_pattern$D*[0-9][0-9]*  *$D*[0-9][0-9]*$D$ext_pattern) 2>| "$file_list.log" | perl -pe 's/(\S+\s+){6}\S+//;' >| "$file_list"
    ## xargs -I "{}" $MV "{}" "$dir" < "$file_list"
    ## OLD: move  $(eval dir-rw *$D$ext_pattern[0-9]*  *$D*[0-9]*$D$ext_pattern  *$D$ext_pattern$D*[0-9][0-9]*   *$D*[0-9][0-9]*$D$ext_pattern  2>&1 | perl-grep -v 'No such file' | perl -pe 's/(\S+\s+){6}\S+//;') "$dir"
    move  $(eval dir-rw *$D$ext_pattern[0-9]*  *$D*[0-9]*$D$ext_pattern  *$D$ext_pattern$D*[0-9][0-9]*   *$D*[0-9][0-9]*$D$ext_pattern  2>&1 | perl-grep -v 'No such file' | perl -pe 's/(\S+\s+){6}\S+//;' | sort -u) "$dir"
}
alias move-log-files='move-versioned-files "{log,debug}" "log-files"'
# note: * the version regex should be kept quite specific to avoid useful files being moved into ./output
alias move-output-files='move-versioned-files "{csv,html,json,list,out,output,png,report,tsv,xml}" "output-files"'
alias move-adhoc-files='move-log-files; move-output-files'

# rename-with-file-date(file, ...): rename each file(s) with .ddMmmYY suffix
# Notes: 1. If file.ddMmmYY exists, file.ddMmmYY.N tried (for N in 1, 2, ...).
# 2. No warning is issued if the file doesn't exist, so can be used as a no-op.
# TODO: have option to put suffix before extension
function rename-with-file-date() {
    ## DEBUG: set -o xtrace
    local f new_f
    local move_command="move"
    if [ "$1" = "--copy" ]; then
        ## TODO: move_command="copy"
        move_command="command cp --interactive --verbose --preserve"
        shift
    fi
    for f in "$@"; do
        ## DEBUG: echo "f=$f"
        if [ -e "$f" ]; then
           new_f=$(get-free-filename "$f".$(date --reference="$f" '+%d%b%y') ".")
           ## DEBUG: echo
           eval "$move_command" "$f" "$new_f";
        fi
    done;
    ## DEBUG: set - -o xtrace
}
## OLD: alias copy-with-file-date='rename-with-file-date --copy'
## HACK: See if function required for proper handling by bats-core
function copy-with-file-date { rename-with-file-date --copy "$@"; }

# Statistical helpers
alias bigrams='perl -sw $TOM_BIN/count_bigrams.perl -N=2'
alias unigrams='perl -sw $TOM_BIN/count_bigrams.perl -N=1'
alias word-count=unigrams

# Lynx stuff
# lynx-dump-stdout(option, ...): Run lynx with textual output to stdout
# lynx-dump(file, [[out-file], option, ...]): Run lynx over base.html with output to base.txt
lynx-dump-stdout () { lynx -width=512 -dump "$@"; }
lynx-dump () { 
    local in_file="$1"
    shift 1
    local base=$(basename "$file" .html)
    #    
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
function setenv () { export $1="$2"; }
alias unsetenv='unset'
alias unexport='unset'

# Unicode support
#
# TODO: put show-unicode-code-info-aux into script (as with other overly-large function definitions like hg-pull-and-update)
# show-unicode-control-chars(): output Unicode codepoint (ordinal) and UTF-8 encoding for input chars with offset in line
function show-unicode-code-info-aux() { perl -CIOE   -e 'use Encode "encode_utf8"; print "char\tord\toffset\tencoding\n";'    -ne 'chomp;  printf "%s: %d\n", $_, length($_); foreach $c (split(//, $_)) { $encoding = encode_utf8($c); printf "%s\t%04X\t%d\t%s\n", $c, ord($c), $offset, unpack("H*", $encoding); $offset += length($encoding); }   $offset += length($/); print "\n"; ' < $1; }
function show-unicode-code-info-stdin() { in_file="$TEMP/show-unicode-code-info.$$"; cat >| $in_file;  show-unicode-code-info-aux $in_file; }
#
function output-BOM { perl -e 'print "\xEF\xBB\xBF\n";'; }
#
# show-unicode-control-chars(): Convert ascii control characters to printable Unicode ones (e.g., ␀ for 0x00)
## BAD: function show-unicode-control-chars { perl -pe 'use Encode "decode_utf8"; s/[\x00-\x1F]/chr($&+0x2400)/e;'; }
# See https://stackoverflow.com/questions/42193957/errorwide-character-in-print-at-x-at-line-35-fh-read-text-files-from-comm.
function show-unicode-control-chars { perl -pe 'use open ":std", ":encoding(UTF-8)"; s/[\x00-\x1F]/chr($& + 0x2400)/e;'; }


#-------------------------------------------------------------------------------
trace Unix aliases

function group-members () { ypcat group | $GREP -i $1; }
# TODO: check if _make.log exists prior to move
function do-make () { /bin/mv -f _make.log _old_make.log; make "$@" >| _make.log 2>&1; $PAGER _make.log; }
## TODO: alias do-gzip='nice -19 gzip -rfv . >| ../gzip-`basename $PWD`.log 2>&1; $PAGER ../gzip-`basename $PWD`.log'
#
# $ man merge
#   merge [ options ] file1 file2 file3
#   merge  incorporates all changes that lead from file2 to file3 into file1.
# NOTE: merge -p mod-file1 original mod-file2 >| new-file
alias merge='echo "do-merge MODFILE1 OLDFILE MODFILE2 > NEWFILE"'
alias do-merge='/usr/bin/merge -p'
# note: version of merge usinf diff3 to specify diff program (shell wrapper with whitespace ignored)
alias diff3-merge='/usr/bin/diff3 --merge --text --diff-program=diff.sh'
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
function which { /usr/bin/which "$@" 2> /dev/null; }
#
# full-dirname(filename): returns full path of directory for file
#
function full-dirname () { local dir=`dirname $1`; case $dir in .*) dir="$PWD/$1";; esac; echo $dir; }
#
# base-name-with-dir(file, suffix): version of basename include dir
function basename-with-dir {
    local file="$1"
    local suffix="$2"
    echo $(dirname "$file")/$(basename "$file" "$suffix");
}
# 
function rpm-extract () { rpm2cpio $1 | cpio --extract --make-directories; }
#
alias dump-url='wget --recursive --relative'
#
alias gtime='/usr/bin/time'

# see 'man 5 os-release'
alias linux-version="cat /etc/os-release"
alias os-release=linux-version
alias system-status='system_status.sh -'
# TODO: use '$@' for '$*' (or note why not appropriate)
function apropos-command () { apropos $* 2>&1 | $GREP '(1)' | $PAGER; }
function split-tokens () { perl -pe "s/\s+/\n/g;" "$@"; }
alias tokenize='split-tokens'
#
# TODO: try to minimize use of quotes in perl-echo (e.g., need to mix single with double) due to bash quirks
function perl-echo () { perl -e 'print "'$1'\n";'; }
function perl-echo-sans-newline () { perl -e 'print "'$1'";'; }
#
## TODO: generalize perl-printf to more than 2 args
## function perl-printf () { perl -e 'printf "$1\n", @_[1..$#_];';  }
##
## function perl-printf () { perl -e "printf \"$1\"", qw/$2 $3 $4 $5 $6 $7 $8 $9/; }
function perl-printf () { perl -e "printf \"$1\", $2;"; }
##
## TODO: get following to work for 'perl-print "how now\nbrown cow\n"'
## function perl-print () { perl -e "print $1"; -e 'print "\n";'; }
function perl-print () { perl -e "printf \"$1\";" -e 'print "\n";'; }
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
        echo "start: $(date)";
        bash-trace-on; 
        eval "$@"; 
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
    log_file=$TEMP/compress_`basename "$1"`.log;
    find $1 \( -not -type l \) -exec gzip -vf {} \; >| "$log_file" 2>&1; 
    $PAGER "$log_file";
}
# NOTE: zipped archived are kept compressed
function uncompress-dir() {
    log_file=$TEMP/uncompress_`basename "$1"`.log;
    find $1 \( -not -type l \) \( -not -name \*.tar.gz \) -exec gunzip -vf {} \; >| "$log_file" 2>&1; $PAGER "$log_file";
}
alias compress-this-dir='compress-dir $PWD'
alias ununcompress-this-dir='uncompress-dir $PWD'

alias old-count-exts='$LS | count-it "\.[^.]*\w" | sort $SORT_COL2 -rn | $PAGER'
function count-exts () { $LS | count-it '\.[^.]+$' | sort $SORT_COL2 -rn | $PAGER; }

alias kill-iceweasel='kill_em.sh iceweasel'

# cmd-usage(command): output usage for command to _command.list (with spaces
# replaced by underscores)
function cmd-usage () {
    local command="$@"
    local usage_file="_$(echo "$command" | tr ' ' '_')-usage.list"
    $command --help  2>&1 | ansifilter > "$usage_file"
    $PAGER_NOEXIT "$usage_file"
}

#-------------------------------------------------------------------------------
# More Linux stuff
# TODO: condition upon using Linux kernel (or cygwin
alias configure='./configure --prefix ~'
alias pp-xml='xmllint --format'
alias pp-html='pp-xml --html'
# ex: pp-url "www.fu.com?p1=fu&p2=bar" => "www.fu.com\n\t?p1=fu\n\t&p2=bar"
alias pp-url-aux='perl -pe "s/[\&\?]/\n\t$&/g;"'
function pp-url { echo "$@" | pp-url-aux; }
## OLD: alias check-xml='xmllint --noout --valid'
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
# Note: em-dir ensures the current directory is same as for dir or file,
# so that closing ad then doing dired brings up that same dir.
alias em-docs='em-dir ~/Documents'
# TODO: add tomasohara alias for the aliases as well
## OLD: alias em-aliases='em-dir $TOM_BIN/tomohara-aliases.bash'
## OLD: alias ed-setup=em-aliases
alias ed-setup='em-dir $TOM_BIN/tomohara-aliases.bash'
alias em-setup=ed-setup
## OLD: alias ed-past-info='start.sh ~/organizer/past-info.odt'
alias ed-past-info='em-dir ~/organizer/past-info.txt'
alias em-past-info=ed-past-info
alias ed-tomas='start.sh ~/organizer/tomas.odt'
alias em-tomas=ed-tomas

# Truncate text wider than current terminal window
# TODO: add truncation indicator (e.g., Unicode character for ...)
## OLD: alias truncate-width='cut --characters=1-$(calc-int "$COLUMNS - 1")'
function truncate-width { cut --characters=1-$(calc-int "$COLUMNS - 1") "$@"; }

#-------------------------------------------------------------------------------
# XWindows stuff
alias magnifier='run-app kmag'

#-------------------------------------------------------------------------------
# Linux admin

alias apt-install='sudo apt-get install --yes --fix-missing --no-remove'
alias apt-search='sudo apt-cache search'
alias apt-installed='sudo apt list --installed'
alias apt-uninstall='sudo apt-get remove'
alias dpkg-install='sudo dpkg --install '
# TODO: disable if on remote host???
alias restart-network='sudo ifdown eth0; sudo ifup eth0'
alias hibernate-system='sudo systemctl hibernate'
alias blank-screen='xset dpms force off'
alias stop-service='systemctl stop'
alias restart-service='sudo systemctl restart'

# get-free-filename(base, [sep=""]): get filename starting with BASE that is not used.
# Notes: 1. If <base> exists <base><sep><N> checked until the filename not used (for N in 2, 3, ... ).
# 2. See sudo-admin for sample usage; also see rename-with-file-date.
#
function get-free-filename() {
    local base="$1"
    local sep="$2"
    local L=1
    local filename="$base"
    ## DEBUG: local -p
    while [ -e "$filename" ]; do
        let L++
        filename="$base$sep$L"
    done;
    ## DEBUG: local -p
    echo "$filename"
}

# sudo-admin(): create typescript as sudo user using filename based on current
# date using numeric suffixes if necessary until the filename is free.
# note: exsting _config*.log files are made read-only so not later overwritten
# by accident
function sudo-admin () {
    local prefix="_config-"
    local base="$prefix$(todays-date).log"
    sudo chmod ugo-w "$prefix"*.log*
    local script_log=$(get-free-filename "$base")
    sudo --set-home   script --flush "$script_log"
}

# sync2(): invokes files system synchronization twice: one for good effect
# note: shold be down from a system administrator account (i.e., root)
alias sync2='sync; sync'

# fix-sudoer-home-permission(): fix permissions of home directory for user running
# sudo (e.g., so that they own all files)
#
function fix-sudoer-home-permission () {
    local user_home="/home/$SUDO_USER"
    local changes_log="${user_home}/_fix-home-permission.log"
    if [ "$SUDO_USER" = "" ]; then
        echo "Warning: no sudo user for current shell"
    else
        rename-with-file-date "$changes_log"
        # TODO: account for alternative home dir schemes
        chown --recursive --changes $SUDO_USER $user_home > "$changes_log" 2>&1
        $PAGER "$changes_log"
    fi
}

## OLD:
# alias hibernate='sudo systemctl hibernate'

#-------------------------------------------------------------------------------
# HTML stuff
alias check-html='check-xml --html'
function check-html-java-script () {
  local file="$1"
  local base="$(basename "$file" .html)"
  cat "$file" | extract_subfile.perl -include_start=0 -include_end=0 '<script type=\"text/javascript\">' '</script>' >| $TEMP/$base.js
  jsl -process $TEMP/$base.js
}

#-------------------------------------------------------------------------------
# Remote host-related stuff
# TODO: straighten out private key to be used (e.g., was thomaspaulohara just used for intemass?)
#

TPO_SSH_KEY=~/.ssh/$USER-key.pem
SSH_PORT="22"
#
# TODO: For cygwin clients, unset TERM so set_xterm_title.bash not confused.
function ssh-host-aws-aux () { local host="$1"; shift; ssh -X -p $SSH_PORT -i $TPO_SSH_KEY $USER@$host "$@"; }
#
function ssh-host-login-aws () {
    local host="$1"
    shift;
    set-xterm-window "$host";
    ssh-host-aws-aux "$host" "$@";
}
## TODO: function run-remote-command-aws () { ssh-host-aws-aux "$@"; }
# Note: /tmp used in case host not setup with ~/temp
function scp-host-down() { scp -P $SSH_PORT -i $TPO_SSH_KEY "$USER@$1:$TMP/$2" .; }
# TODO: rework in terms of id_rsa-tomohara-keypair (as used on others hosts)
function scp-host-up() { local host="$1"; shift; scp -P $SSH_PORT -i $TPO_SSH_KEY "$@" "$USER@$host:$TMP"; }
#
function scp-aws-up() { local host="$1"; shift;
                        ssh -p $SSH_PORT -i $TPO_SSH_KEY $USER@$host chmod u+w "~/xfer/"*;
                        scp -P $SSH_PORT -i $TPO_SSH_KEY "$@"  $USER@$host:xfer; }
function scp-aws-down() { local host="$1"; shift; for _file in "$@"; do scp -i $TPO_SSH_KEY $USER@$host:xfer/$_file .; done; }
#
# TODO: consolidate host keys; reword hostwinds in terms of generic host not AWS
#
export AWS_HOST="52.15.125.52"
aws_micro_host=ec2-52-15-125-52.us-east-2.compute.amazonaws.com
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


function gr-juju-notes () { grepl "$@" /c/work/juju/*notes* $JJDATA/*notes*; }
function gr-juju-notes-archive () { MY_GREP_OPTIONS="" grepl "$@" /c/work/juju/_note-archive.list; }
alias gr-juju-archive-notes=gr-juju-notes-archive

alias uname-node='uname -n'
alias pwd-host-info='pwd; echo $HOST_NICKNAME; uname-node'

# TODO: put following elsewhere
## MISC
## conditional-export SANDBOX ~/python/tohara
## conditional-export MISC_TRACING_LEVEL 4
## alias restart-screen='screen-startup.sh >| $TEMP/screen-startup.$$.log 2>&1'

#-------------------------------------------------------------------------------

# MRJob stuff (python-based map-reduce)
#
# show-job-tracker([port=40001]): enable tunneling for job tracker on temp EC2 host
# and then invoke firefox for link using corresponding port
# note: ssh options: -f background; -n redirect stdin; -N no command; -T disable pseudo-tty; -L port forwarding specification
job_tracker_port=40001
function show-job-tracker() {
    local port="$1"
    if [ "$port" == "" ]; then port=$job_tracker_port; fi
    ssh -fnNT -i $TPO_SSH_KEY -L$port:localhost:$port $USER@$mrjob_ec2_host
    firefox http://localhost:$port/jobtracker.jsp &
}
alias kill-job-trackers=' kill_em.sh -p L$job_tracker_port'

#-------------------------------------------------------------------------------
# Misc. language related
## OLD: alias json-pp='json_pp'
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
function script {
    ## THIS function is buggy!
    # Note: set_xterm_title.bash keeps track of titles for each process, so save copies of current ones
    local save_full=$(set-xterm-title --print-full)
    local save_icon=$(set-xterm-title --print-icon)
    ## DEBUG: echo "save_full='$save_full'; save_icon='$save_icon'"
  
    # Change prompt
    local old_PS_symbol="$PS_symbol"
    export SCRIPT_PID=$$
    # Note: the prompt change is flakey
    reset-prompt "$PS_symbol\$"
    ## DEBUG: echo "script: 1. PS1='$PS1' old_PS_symbol='$old_PS_symbol' PS_symbol='$new_PS_symbol'"
    
    # Change xterm title to match
    set-title-to-current-dir
    ## DEBUG: echo "script: 2. PS1='$PS1' old_PS_symbol='$old_PS_symbol' PS_symbol='$new_PS_symbol'"
    # Run command
    command script --append "$@"
    
    # Restore prompt
    unset SCRIPT_PID
    reset-prompt "$old_PS_symbol"
    ## DEBUG: echo "script: 3. PS1='$PS1' old_PS_symbol='$old_PS_symbol' PS_symbol='$new_PS_symbol'"
    
    # Get rid of lingering 'script' in xterm title
    ## DEBUG: echo "Restoring xterm title: full=$save_full save=$save_icon"
    set-xterm-title "$save_full" "$save_icon"
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
    read -p "$message "
}

#-------------------------------------------------------------------------------
# Python related
## *** Python stufff ***

export PYTHON_CMD="/usr/bin/time python -u"
export PYTHON="$NICE $PYTHON_CMD"
export PYTHONPATH="$HOME/python:$PYTHONPATH"
## HACK: make sure Mezcla/mezcla resolves before python/mezcla
export PYTHONPATH="$HOME/python/Mezcla:$PYTHONPATH"
alias ps-python-full='ps-all python'
# note: excludes ipython and known system-related python scripts
alias ps-python='ps-python-full | $EGREP -iv "(screenlet|ipython|egrep|update-manager|software-properties|networkd-dispatcher)"'
alias show-python-path='show-path-dir PYTHONPATH'

# Remove compiled files .pyc for regular (debug) version and .pyo for optimized
# TODO: add option for forced removal; try using '-name "*.py[co]"')
## OLD: alias delete-compiled-python-files='find . \( -name "*.pyc" -o -name "*.pyo" \) -exec /bin/rm -v {} \;'
function delete-compiled-python-files-aux {
    local rm_options=${1:-"-v"}
    find . \( -name "*.pyc" -o -name "*.pyo" \) -exec /bin/rm $rm_options {} \;
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
    local root=$(hg root 2> /dev/null);
    ## TODO: --persistent=n (to avoid caching)
    PYTHONPATH="$root:.:$PYTHONPATH" $NICE pylint "$@" | perl -00 -ne 'while (/(\n\S+:\s*\d+[^\n]+)\n( +)/) { s/(\n\S+:\s*\d+[^\n]+)\n( +)/$1\r$2/mg; } print("$_");' 2>&1 | $PAGER;
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
function python-lint-work() { python-lint-full "$@" 2>&1 | $EGREP -v '\((bad-continuation|bad-option-value|fixme|invalid-name|locally-disabled|too-few-public-methods|too-many-\S+|trailing-whitespace|star-args|unnecessary-pass)\)' | $EGREP -v '^(([A-Z]:[0-9]+)|(Your code has been rated)|(No config file found)|(\-\-\-\-\-))' | $PAGER; }
# TODO: rename as python-lint-tpo for clarity (and make python-lint as alias for it)
function python-lint() { python-lint-work "$@" 2>&1 | $EGREP -v '(Exactly one space required)|\((bad-continuation|bad-whitespace|bad-indentation|bare-except|c-extension-no-member|consider-using-enumerate|consider-using-with|global-statement|global-variable-not-assigned|keyword-arg-before-vararg|len-as-condition|line-too-long|logging-not-lazy|misplaced-comparison-constant|missing-final-newline|redefined-variable-type|redundant-keyword-arg|superfluous-parens|too-many-arguments|too-many-instance-attributes|trailing-newlines|useless-\S+|wrong-import-order|wrong-import-position)\)' | $PAGER; }

# run-python-lint-batched([file_spec="*.py"]: Run python-lint in batch mode over
# files in FILE_SPEC, placing results in pylint/<today>.
#
function get-python-lint-dir () {
    local python_version_major=$(pylint --version 2>&1 | extract_matches.perl "Python (\d)")
    local affix="py${python_version_major}"
    local out_dir="_pylint/$(todays-date)-$affix"
    echo "$out_dir"
}
#
function run-python-lint-batched () {
    # TODO: support files with embedded spaces
    local file_spec="$@"
    if [ "$file_spec" = "" ]; then file_spec="*.py"; fi

    # Create output directory if needed
    local out_dir=$(get-python-lint-dir)
    mkdir -p "$out_dir"

    # Run pylint and pipe top section into less
    (for f in $($LS $file_spec); do
         # HACK: uses basename of parent prefix if invoked with path
         local b=$(basename "$f")
         local pre=""
         if [[ $f =~ / ]]; then pre="$(basename $(dirname "$f"))-"; fi
         DEBUG_LEVEL=5 python-lint "$f" >| "$out_dir/$pre$b".log 2>&1
         head "$out_dir/$pre$b".log
     done) >| "$out_dir/summary.log"
    less -p '^\** Module' "$out_dir/summary.log";
}

# python-import-path(module): find path for package directory of MODULE
# Note: this checks output via module initialization output shown with python -v
# ex: /usr/local/misc/programs/anaconda3/lib/python3.8/site-packages/sklearn/__pycache__/__init__.cpython-38.pyc matches /usr/local/misc/programs/anaconda3/lib/python3.8/site-packages/sklearn/__init__.py
function python-import-path-all() { local module="$1"; python -u -v -c "import $module" 2>&1; }
function python-import-path-full() { local module="$1"; python-import-path-all "$@" | extract_matches.perl "((matches (.*\W$module[^/]*[/\.][^/]*))|ModuleNotFoundError)"; }
function python-import-path() { python-import-path-full "$@" | head -1; }

#
## note: gotta hate python!
function python-module-version-full { local module="$1"; python -c "import $module; print([v for v in [getattr($module, a, '') for a in '__VERSION__ VERSION __version__ version'.split()] if v][0])"; }
# TODO: check-error if no value returned
function python-module-version { python-module-version-full "$@" 2> /dev/null; }
function python-package-members() { local package="$1"; python -c "import $package; print(dir($package));"; }
#
## OLD: alias python-setup-install='`<log=setup-$(TODAY).log; uname -a > $log; python setup.py install --record installed-files.list >> $log 2>&1; ltc $log'
alias python-setup-install='log=setup.log;  rename-with-file-date $log;  uname -a > $log;  python setup.py install --record installed-files.list >> $log 2>&1;  ltc $log'
# TODO: add -v (the xargs usage seems to block it)
alias python-uninstall-setup='cat installed-files.list | xargs /bin/rm -vi; rename_files.perl -regex ^ un installed-files.list'

# ipython(): overrides ipython command to set xterm title
function ipython() { 
    local ipython=$(which ipython)
    if [ "$ipython" = "" ]; then echo "Error: install ipython first"; return; fi
    set-xterm-window "ipython [$PWD]"
    $ipython "$@"
}

# python-trace(script, arg, ...): Run python SCRIPT with statement tracing
function python-trace {
    local script="$1"
    shift
    $PYTHON -m trace --trace $(which "$script") "$@"
    }

# py-diff(dir): check for difference in python scripts versus those in target
# TODO: specify options before the pattern (or modify do_diff.sh to allow after)
function py-diff () { do_diff.sh '*.py *.mako' "$@" 2>&1 | $PAGER; }

# kivy-win32-env(): enables environment variabless for Kivy under cyggwin, using win32 python
function kivy-win32-env {
   export PYTHONPATH='c:/cartera-de-tomas/python;c:/Program-Misc/python/kivy-1-9-0/kivy27'
   kivy_dir="/c/Program-Misc/python/kivy-1-9-0"
   python_dir="$kivy_dir/Python27"
   prepend-path "$kivy_dir:$kivy_dir/Python27:$kivy_dir/tools:$kivy_dir/Python27/Scripts:$kivy_dir/gstreamer/bin:$kivy_dir/MinGW/bin:$kivy_dir/SDL2/bin"
}

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

# run-jupyter-notebook(port=18888): run jupyter notebook on PORT
function run-jupyter-notebook () {
    local port="$1"; if [ "$port" = "" ]; then port=8888; fi
    local ip="$2"; if [ "$ip" = "" ]; then ip="127.0.0.1"; fi
    local log="$TEMP/jupyter-$(TODAY).log"
    jupyter notebook --NotebookApp.token='' --no-browser --port $port --ip $ip >> "$log" 2>&1 &
    # Show URL
    echo -n "URL: "
    sleep 3
    extract-matches 'http:\S+' "$log" | sort -u
}
alias jupyter-notebook-redir=run-jupyter-notebook
alias jupyter-notebook-redir-open='run-jupyter-notebook 8888 0.0.0.0'

# Python-based utilities
function extract-text() { python -m extract_document_text "$@"; }
alias xtract-text='extract-text'

# test-script(script): run unit test for script (i.e., tests/test_script)
# and outputs to file given by tests/_test-<script_basename>.<date>.log.
# note: run in verbose mode with unbuffered I/O so output synchronized.
# TODO: rework to take the actual test script and to pipe results to pager
#
function test-script () {
    local base=$(basename "$1" .py)
    local date=$(todays-date)
    # note: uses both Mercurial root and . (in case not in repository)
    local root=$(hg root)
    PYTHONPATH="$root:.:$SANDBOX/tests:$PYTHONPATH" $NICE $PYTHON tests/test_$base.py --verbose >| tests/_test_$base.$date.log 2>&1;
    less-tail tests/_test_$base.$date.log;
}
#
alias test-script-debug='ALLOW_SUBCOMMAND_TRACING=1 DEBUG_LEVEL=5 MISC_TRACING_LEVEL=5 test-script'

# randomize-datafie(file, [num[): randomize datafile optionally pruned to NUM lines, preserving header line
#
function randomize-datafile() {
    local file="$1"
    local num_lines="$2"
    if [ "$num_lines" = "" ]; then num_lines=$(wc -l "$file"); fi
    #
    head -1 "$file"
    tail --lines=+2 "$file" | python -m randomize_lines | head -$num_lines
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
    local ratio=$(perl -e "printf('%.3f', ($pct / 100.0));")
    local compressed=0
    if [[ $file =~ .gz ]]; then compressed=1; fi
    local dir=$(dirname $file)
    local base=$(basename $file)
    local type="cat"
    local result="$dir/_r${pct}pct-$base"

    # Filter the file, optionally uncompressing
    if [ "$compressed" = "1" ]; then 
       type="zcat"; 
       result=$(echo "$result" | perl -pe 's/.gz$//;')
    fi
    local opts=""
    if [ "$include_header" = "1" ]; then opts="$opt --include-header"; fi
    $type "$file" | $PYTHON -m filter_random $opts --ratio $ratio - > "$result" 2> "$result.log"

    # Compress result if original compressed
    if [ "$compressed" = "1" ]; then 
       gzip --force "$result"; 
    fi
}

# Load supporting scripts
#
conditional-source $TOM_BIN/anaconda-aliases.bash
conditional-source $TOM_BIN/git-aliases.bash

# Web access
#
function curl-dump () {
    local url="$1";
    local base=`basename $url`;
    curl $url > $base;
}
# EX: url-path $BIN/templata.html => "file:///$BIN/template.html"
function url-path () {
    local file="$1"
    echo $(realpath "$file") | perl -pe 's@^@file:///@;'
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
    local browser_base=$(basename "$browser_executable")
    $browser_executable "$file" >> $TEMP/$browser_base.$(TODAY).log 2>&1 &
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
## TEST: alias firefox='invoke-browser "'"$(which firefox 2> /dev/null)"'"'
alias firefox='invoke-browser "'"$(which firefox)"'"'
## TEST: alias opera='invoke-browser "'"$(which opera 2> /dev/null)"'"'
alias opera='invoke-browser "'"$(which opera)"'"'
alias tor-browser='invoke-browser "'"$(which tor-browser-en.sh)"'"'
alias run-tor-browser=tor-browser
alias run-epiphany-browser='invoke-browser epiphany-browser'

#-------------------------------------------------------------------------------
# NVidia GPU

alias nvidia-smi-loop='nvidia-smi --loop=1'

# Multilingual
# TODO: put other common ones from do_setup.sh here

# Notes:
# - Aliases for emacs-qd-trans-sp.sh, which opens an Emacs terminal for running ye olde Quick-N-dirty Spanish word translator.
# - ed-trans-sp is used for consistency with recent aliases for editing info (ed-past-info for past-info.odt and ed-tomas for tomas.odt.
# - TODO: rename ed-tomas, as doc generalized to be a Spanish cheatsheet.
# - TODO: * Add hook(s) into Google and/or Bing translators!
alias emacs-qd-trans-sp='pushd $TOM_DIR/multilingual; ./emacs-qd-trans-sp.sh; popd'
alias em-trans-sp=emacs-qd-trans-sp
alias ed-trans-sp=em-trans-sp

#-------------------------------------------------------------------------------
# Music related

function make-lilypond-png () {
    local file="$1"
    local base=$(basename "$file" .ly)
    # note follpwing doesn't work as lilypond puts temporary files in current dir
    ## TODO: local base=$(dirname "$file")/$(basename "$file" .ly)
    lilypond_dir="/c/Program-Misc/music/lilypond"
    PATH="$lilypond_dir/usr/bin:$PATH" lilypond --png --verbose "$file" >| "$base.png" 2>| "$base.log"
    tail -5 "$base.log"
}


# Adhoc fixup's
wn="$(which wn > /dev/null 2>&1)"
if [ "$wn" == "" ]; then
    ## TODO: echo "Warning: unable to find WordNet wn binary"
    wn=/usr/bin/wn
fi
for _dir_ in /usr/share/wordnet /c/cygwin/lib/wnres/dict; do
    if [[ ( ! -d "$WNSEARCHDIR") && ( -d $_dir_ ) ]]; then
        export WNSEARCHDIR=$_dir_
    fi
done

#........................................................................
# Miscellaneous bash scripting helpers
# TODO: move other aliases here
trace bash helpers

# shell-check[-full](options, script, ...): run script through shellcheck
# with filtering given it's buggy filtering mecahanism (and anal retentiveness)
function shell-check-full {
    shellcheck "$@";
}
function shell-check {
    # note: filters out following
    # - SC1090: Can't follow non-constant source. Use a directive to specify location.
    # - SC1091: Not following: ./my-git-credentials-etc.bash was not specified as input (see shellcheck -x).
    # - SC2009: Consider using pgrep instead of grepping ps output.
    # - SC2129: Consider using { cmd1; cmd2; } >> file instead of individual redirects.
    # - SC2155: Declare and assign separately to avoid masking return values
    # - SC2164: Use 'cd ... || exit' or 'cd ... || return' in case cd fails.
    shell-check-full "$@" | perl-grep -para -v '(SC1090|SC1091|SC2009|SC2129|SC2155|SC2164)';
}

#-------------------------------------------------------------------------------
# Work-specific stuff (adhoc)
#
# TODO: put in separate file
#

#-------------------------------------------------------------------------------
# System administration
# TODO: do for ???
if [ "$USER" = "root" ]; then
    alias kill-software-updater='kill_em.sh --all --pattern "(software-properties-gtk|gnome-software|update-manager)"'
fi
alias update-software='/usr/bin/update-manager'
alias kill-clam-antivirus='kill_em.sh --all -p clamd'

#........................................................................
# Miscellaneous local environment helpers
trace misc local helpers

# sleepyhead: Invoke SleepyHead with debug trace sent to log file under ~/temp.
function sleepyhead() {
    log_file="$HOME/temp/sleepyhead.$(todays-date).log"
    echo "start: $(date)" >> "$log_file"
    command sleepyhead >> "$log_file" 2>&1 &
    echo "end: $(date)" $'\n' >> "$log_file"
}
alias sleepy='sleepyhead'

#------------------------------------------------------------------------
# Aliases for [re-]invoking aliases
alias tomohara-aliases="source $TOM_BIN/tomohara-aliases.bash"
alias redo-tpo=tomohara-aliases
alias more-tomohara-aliases="source $TOM_BIN/more-tomohara-aliases.bash"

# Optional end tracing
startup-trace 'out tomohara-aliases.bash'
