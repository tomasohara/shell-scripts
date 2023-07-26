# do_setup.bash: Initialization file for use with bash
# *** OLD: DO NOT MODIFY: use tomohara-aliases.bash instead! ***
#
# NOTES:
# - Obsolete old code flagged with '## OLD': either older definition
#   or no longer used).
# - Misc. old code flagged with '## MISC' (e.g., old but potentially useful).
# - This gets invoked from $BIN/tomohara-aliases.bash.
# - from bash manual:
#   Special Parameters
#   ...
#        @      Expands to the positional parameters, starting from
#               one.   When  the  expansion  occurs  within  double
#               quotes,  each parameter expands as a separate word.
#               That is, `` $@'' is equivalent to ``$1'' ``$2'' ...
#               When there are no positional parameters, ``$@'' and
#               $@ expand to nothing (i.e., they are removed).
# - CygWin takes very long to process this script so certain sections
#   are not evaluated if under arahomot; TODO: check for CygWin flag.
# - Variables in function definitions should be declared local to avoid subtle problems
#   due to retained values.
# - Function definition syntax:
#      [ function ] name () { command-list; }
#   where () is optional if 'function' given
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
#
# TODO:
# - *** Merge this script into tomohara-aliases.bash (to minimize number of scripts for setup such as .bashrc, that one, and this one).
# - ** In meantime. finish conditioning little-used stuff on INCLUDE_MISC_ALIASES, as follows:
#   if [ "$INCLUDE_MISC_ALIASES" = "1" ]; then ... fi
# - ** Similarly, comment out aliases no longer used.
# - ** Place old but potentially useful stuff in external script (e.g., Tex support).
# - Replace /tmp with $TEMP in old and miscelleneous aliases (see INCLUDE_MISC_ALIASES usages below).
# - convert $* to "$@" throughout, as appropriate
# - add more structure and decompose into helper scripts (e.g, wordnet aliases)
# - use dashes instead of underscores in scripts as well as macros
# - decompose into do-cs-setup.bash do-arahomot-setup.bash, etc.
# - add more optional sections (as with 'if [ "$HOST" != "arahomot" ]; ...'
# - replace '-' macro suffix (eg, 'gr-') with something more uniformative (eg, '-alt')
# - create function for recreating local directories (e.g., ~/info) assumed by do-setup scripts (e.g., do_setup.bash)
# - Remove () from function definitions.
# - Add error checking in functions for unspecified arguments.
# - Make sure all function variables use local.
# - Add upcase alias (perl -pe 's/(.*)/\U$1\e/g;')
# - Make sure functions don't refer to undefined macros (e.g., defined later).
# - Document environment variable assumptions (e.g., HOST, DEFAULT_HOST, etc.)!
#

# Uncomment the following line for tracing:
## set -o xtrace
## echo do_setup.bash

# Uncomment the following to display the environment variables
# TODO: use startup-trace for this
## alias printenv="set | egrep '^\w+='"
## alias printenv="set | egrep '[^ ]+='"
## printenv.sh

## OLD
## # Bash customizations (e.g., no beep)
## set bell-style none
## export HISTCONTROL=erasedups
## # via `man 3 strftime`:
## #    %F     Equivalent to %Y-%m-%d (the ISO 8601 date format). (C99)
## #    %T     The time in 24-hour notation (%H:%M:%S). (SU)
## export HISTTIMEFORMAT='[%F %T] '

# Directory for scripts
if [ "$BIN" = "" ]; then export BIN="$TOM_BIN"; fi
if [ "$BIN" = "" ]; then export BIN=~/bin; fi

# Helper functions:
#    conditional-source(filename): source in bash commands from filename if exists
#    check-arg(function-name, last-argument): issue warning if argument missing
# NOTE: use $FUNCNAME as first argument to check-arg (eg, 'check-arg $FUNCNAME $1';)
#
function conditional-source () { if [ -e "$1" ]; then source $1; else echo "Warning: bash script file not found (so not sourced):"; echo "    $1"; fi; }
#
function check-arg () { if [ "$2" == "" ]; then echo "WARNING: missing argument to $1"; fi; }

# Alias for startup-script tracing via startup-trace function
if [ ! -e "$HOME/temp" ]; then
   echo "WARNING: creating $HOME/temp for startup script logs"
   mkdir "$HOME/temp"
fi
## OLD
## function startup-trace () { if [ "$STARTUP_TRACING" = "1" ]; then echo $* [$HOST `date`] >> $HOME/temp/.startup-$HOST-$$.log; fi; }
## conditional-source $BIN/startup-tracing.bash
#

## OLD
## alias trace='startup-trace'
## alias enable-startup-tracing='export STARTUP_TRACING=1'
## alias disable-startup-tracing='export STARTUP_TRACING=0'
## alias enable-console-tracing='export CONSOLE_TRACING=1'
## alias disable-console-tracing='export CONSOLE_TRACING=0'

#-------------------------------------------------------------------------------
trace 'in do_setup.bash'

# Fixup for Linux OSTYPE setting (likewise for solaris)
# TODO: use ${OSTYPE/[0-9]*/}
case "$OSTYPE" in linux-*) export OSTYPE=linux; esac
case "$OSTYPE" in solaris*) 
     export OSTYPE=solaris; 
     alias printenv='printenv.sh'
esac

## OLD:
## # Settings for less command 
## # LESS="-cFIX-P--Less-- ?f%f:(stdin). ?e(END):?pb(%pb\%) ?m(%i of %m)..%t"
## #
## # less options:
## #     -c   full screen repaints to be painted from the top line down
## #     -F   automatically exit if the entire file can  be  displayed on first screen
## #     -I   searches ignore case even if the pattern contains uppercase letters
## #     -S   Causes lines longer than the screen width to be chopped
## #     -X   Disables sending the termcap initialization and deinitialization
## #     -P   changes the prompt
## # to override on command line
## #     -+<option> 	ex: -+F
## #     
## export LESS="-cFIX-P--Less-- ?f%f:(stdin). ?e(END):?pb(%pb\%) ?m(%i of %m)..%t"
## # Disables full-screen repaints under minimal-installation hosts (e.g., Beowolf nodes)
## if [ "$BAREBONES_HOST" = "1" ]; then export LESS="-cIX-P--Less-- ?f%f:(stdin). ?e(END):?pb(%pb\%) ?m(%i of %m)..%t"; fi
## ## export LESSCHARSET=latin1
## export PAGER=less
## NOTE: following needed for multilingual aliases
export PAGER_CHOPPED="less -S"
export PAGER_NOEXIT="less -+F"
## function zless () { zcat "$@" | $PAGER; }
## alias less-="$PAGER_NOEXIT"
alias less-pager="$PAGER_NOEXIT"
## alias less-tail="$PAGER_NOEXIT +G"
## export ZPAGER=zless

#-------------------------------------------------------------------------------
trace start of main settings

# Path settings
# TODO: define a function for removing duplicates from the PATH while
# preserving the order
function show-path-dir () { (echo "${1}:"; printenv $1 | perl -pe "s/:/\n/g;") | $PAGER; }
alias show-path='show-path-dir PATH'
function append-path () { export PATH=${PATH}:$1; }
function prepend-path () { export PATH=$1:${PATH}; }

## OLD: export ORIGINAL_PATH=$PATH
# TODO: develop a function for doing this
if [ "`printenv PATH | grep $BIN:`" = "" ]; then
   export PATH="$BIN:$PATH"
fi
if [ "`printenv PATH | grep $BIN/${OSTYPE}:`" = "" ]; then
   export PATH="$BIN/${OSTYPE}:$PATH"
fi
# TODO: make optional & put append-path later to account for later PERLLIB changes
append-path $PERLLIB
# Put current directoy at end of path; can be overwritting with ./ prefix
export PATH="$PATH:."
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/lib:$LD_LIBRARY_PATH

## OLD
## # Bash settings
## #
## # FIGNORE: A colon-separated list of suffixes to ignore when performing filename completion ("tab completion")
## export FIGNORE=".o:.fasl:.fas:.lib"
## ## TEST: export FIGNORE=".o:.fasl:.fas:.lib:.log"
## ## TODO: figure out how to exlcude .log for executable-tab-expansion (e.g., first position)
## export FIGNORE=".o:.fasl:.fas:.lib"
## set -o noclobber
## # MAILCHECK: Specifies how often (in seconds) bash checks for mail.
## # ... If this variable is unset, the shell disables mail checking.
## unset MAILCHECK
## 
## # MAIL If this parameter is set to a file name and the MAILPATH variable is not
## #      set, bash informs the user of the arrival of mail in the specified file.
## unset MAIL

# Unix environ
# note:
# - TEMP is my private temp dir; TMP is system temp dir
# - these settings should be done in .bashrc, .cshrc, etc. so that trace could use TEMP
## OLD:
## export TEMP=$HOME/temp
## export TMP=/tmp
## export TMPDIR=$TEMP
## # The following are in support of ps_sort.perl
## export LINES
## export COLUMNS
# NOTE: resize used to set lines below
#
if [ "$DOMAIN_NAME" = "" ]; then export DOMAIN_NAME=`domainname.sh`; fi

## OLD:
## # NMSU CS settings
## if [ "$DOMAIN_NAME" = "cs.nmsu.edu" ]; then
##     export TOM=/home/ch1/tomohara
##     export GRAPHLING_TOM=/home/ch2/graphling/USERS/TOM
##     export OTHER_TOM=/home/ch3/graphling2/USER/TOM
##     # PRINTER is set in do_setup.sh
##     # TODO: figure out out to use a pattern; also use separate variable
##     # based on OSTYPE (to avoid problems with other programs that rely on it)
##     ## if [ "$OSTYPE" = "solaris2.6" ]; then export OSTYPE=solaris; fi
##     ## if [ "$OSTYPE" = "solaris2.7" ]; then export OSTYPE=solaris; fi
##     alias cs-hosts='echo `cat $HOME/cs/cs-hosts.list`'
##     alias cs-load='cs-load.sh --all'
##     ## alias p4-load='cs-load.sh --p4'
##     alias p4-load='cs-load.sh `cat $HOME/cs/cs-summer-p4-linux-hosts.list`'
##     alias p4-free='p4-load | grep " 0 users "'
##     alias p4-busy='p4-load | grep "load average: [0-9].[1-9]"'
##     alias wb-load='cs-load.sh --wb'
##     ## alias bw-load='cs-load.sh --bw'
##     alias bw-load='cs-load.sh --reverse --bw'
##     alias bw-load-half1='cs-load.sh --bw1'
##     alias bw-load-half2='cs-load.sh --bw2'
##     ## alias bw-load='cs-load.sh --bw'
##     ## alias dominica-load='rup.sh dominica'
##     alias bangkok-load='rup.sh bangkok'
##     alias mount-cd='mount /dev/cdrom'
##     alias unmount-cd='umount /dev/cdrom'
##     alias ml='/local/ml-110/bin/sml'
##     ## alias set-home-display-export='export DISPLAY=128.123.63.127:0.0; echo "DISPLAY set to $DISPLAY"'
##     ## if [ "$BEOWULF_NODE" = "1" ]; then
##        ## alias emacs='xemacs'
##     ## fi
##     export DEFAULT_HOST=thoth
##     if [ -e $HOME/.default_host ]; then export DEFAULT_HOST=`cat $HOME/.default_host`; fi
## fi
## alias run-csh='export USE_CSH=1; csh; export USE_CSH=0'

#-------------------------------------------------------------------------------
# Tex settings
trace Tex settings
## export TEXINPUTS=.:$HOME/latex:/local/teTeX-1.04/share/texmf/tex/latex/base
## TODO: add something like following; check all do_tex logs to see which dirs are used
# export TEXINPUTS=.:$HOME/latex:/usr/share/texmf/tex/latex/base:/usr/share/texmf/tex/latex/psnfss
export LATEX=/usr/share/texmf/tex/latex
## export TEXINPUTS=.:$HOME/latex:$LATEX/base:$LATEX/psnfss:$LATEX/graphics:$LATEX/cmbright
## TODO: export TEXINPUTS=.:$HOME/latex:$LATEX


#-------------------------------------------------------------------------------

## # GraphLing-related environment variables
## #
## trace host-specific settings
## if [ "$DOMAIN_NAME" = "cs.nmsu.edu" ]; then
##     trace GraphLing-related environment variables
##     # Commonly used directories
##     if [ "$GRAPHLING_HOME" = "" ]; then export GRAPHLING_HOME=/home/graphling; fi
##     export GL_HOME=$GRAPHLING_HOME
##     export DATA=$GL_HOME/DATA
##     export GL_TOOLS=$GL_HOME/TOOLS
##     export SCRIPT_DIR=$GL_HOME/USERS/TOM/UTILITIES
##     export GL_UTILITIES=$GL_HOME/USERS/TOM/UTILITIES
##     export EXPERIMENTS=$GL_HOME/EXPERIMENTS
##     export HUGIN_SERVER=$GL_TOOLS/HUGIN/PCSOL_HUGIN/SERVER
##     export SOURCE=$GL_HOME/SOURCE
##     export FEATURE_SOURCE=$SOURCE/FEATURE_TOOLS
##     #
##     # Those for some common experiment directories
##     export FRAMENET_PREPOSITION=$EXPERIMENTS/FRAMENET-PREPOSITION
##     export TREEBANK_PREPOSITION=$EXPERIMENTS/TREEBANK-PREPOSITION
##     export SENSEVAL2=$EXPERIMENTS/SENSEVAL2
##     export SENSEVAL3=$EXPERIMENTS/SENSEVAL3
##     export SENSEVAL=$SENSEVAL3
##     export BN_EXAMPLES=$EXPERIMENTS/EXAMPLE-BAYES-NETS
##     ## export COOKING=$EXAMPLE_BAYES_NETS/COOKING
##     export DSO_BAYES=$GL_HOME/EXPERIMENTS/DSO/BAYESIAN-NETWORKS
##     ## export SENSEVAL2_BAYES=$GL_HOME/EXPERIMENTS/SENSEVAL2/BAYESIAN-NETWORKS
##     ## export FACTOTUM=$EXPERIMENTS/FACTOTUM
##     ## export LYRICS=$EXPERIMENTS/LYRICS
##     export SOYBEAN=$GL_HOME/USERS/TOM/SOYBEAN
##     export DIFFERENTIA=$EXPERIMENTS/DIFFERENTIA
##     export SETENV_SCRIPTS=$EXPERIMENTS/SETENV_SCRIPTS
##     export LEXICAL=$DATA/LEXICAL_RELATIONS
##     export WSJ=$DATA/WSJ
##     #
##     # Cyc-related directories
##     export SPEECH_PART=/home/ch1/tomohara/speech-part-inference
##     export CYC_SPEECH_PART=/home/ch1/tomohara/speech-part-inference/cyc
## 
##     # Personal file settings
##     #
##     # Environment variables pointing to commonly used directories
##     export TOM=/home/ch1/tomohara
##     export CARTERA_DE_TOMAS=$TOM/cartera-de-tomas
##     export TOMAS=$CARTERA_DE_TOMAS
## 
##     # Other commonly used directories
##     export ELISP=/usr/share/emacs/21.2/lisp
## 
##     # Allegro Common Lisp
##     export ACL=$GL_TOOLS/ACL
##     alias acl='$ACL/bin/pb_cl'
## fi

## OLD:
## # ILIT-specific initializations
## export ILIT_HOST=0
## if [ "$HOST" = "arahomot" ]; then
##     export THOTH=thoth.ilit.umbc.edu
##     export YAVIN=yavin.ilit.umbc.edu
##     export NABOO=naboo.ilit.umbc.edu
##     export BACKUP_SERVER=$NABOO
##     export ILIT_SERVER=$THOTH
## fi
## 
## if [ "$HOST" = "thoth" ]; then
##    echo "WARNING: unexpected host THOTH (should now be YAVIN)"
##    export ILIT_HOST=1
## elif [ "$HOST" = "yavin" ]; then
##    export ILIT_HOST=1
##    append-path /home/shared/bin:/usr/java/j2sdk1.4.2_01/bin:/usr/local/ant/bin
##    export SHARED=/home/shared
##    export _CATALINA_HOME=/usr/tomcat4
##    export CVSROOT=$SHARED/cvsroot
##    export POSTGRES_HOME=/home/pgsql
## elif [ "$HOST" = "naboo" ]; then
##    export ILIT_HOST=1
##    export JAVA_HOME=/usr/java/jdk1.5.0_05
##    ## append-path /home/shared/bin:/usr/java/jdk1.5.0_05/bin
##    append-path /home/shared/bin
##    prepend-path /usr/java/jdk1.5.0_05/bin
##    prepend-path /naboo/data/shared/source/apache-ant-1.6.5/bin
##    ## append-path /usr/site/ant-1.6.5/bin
##    ## export SHARED=/naboo/data/shared
##    export SHARED=/home/shared
##    export _CATALINA_HOME=/usr/tomcat5
## 
##    # TODO: create mirror of thoth /home under naboo (w/ dummy dirs for users and other private directories)
##    export CVSROOT=:ext:$USER@yavin.ilit.umbc.edu:/home/shared/cvsroot
##    export MAVEN_HOME=$SHARED/source/maven-1.0.2
##    append-path $MAVEN_HOME/bin
##    export POSTGRES_HOME=/var/lib/pgsql
##    export THOTH_BACKUP=/usr/site/backups/thoth_home
## 
##    export ACL=/usr/local/acl/acl62
##    alias acl='$ACL/alisp'
## fi
## 
## if [ "$ILIT_HOST" = "1" ]; then
##    ## export DOMAIN_NAME=ilit.umbc.edu
##    export DOMAIN_NAME=umbc.edu
##    
##    export CVSROOT=$SHARED/cvsroot
##    export PREP_SRC=$SHARED/Text-preprocessor-v4.0a/Projects/prep
##    export PREP_DATA=$SHARED/data/prep
##    export ARCHIVE=$SHARED/archive
##    export BIN=$SHARED/bin
##    export FULL_ANALYZER=$BIN/Full_Analyzer
##    export REFERENCE=$ANALYZER/reference
##    export WWW=/home/www
##    export LOOKUP_SRC=$SHARED/Text-preprocessor-v4.0a/Projects/lookup
##    export GRAPHLING_HOME=$SHARED/graphling
## 
##    export GRAPHLING_HOME=$SHARED/graphling
##    export GL_HOME=$GRAPHLING_HOME
##    export GL_DATA=$GL_HOME/DATA
##    export GL_TOOLS=$GL_HOME/TOOLS
##    export GL_EXPERIMENTS=$GL_HOME/EXPERIMENTS
##    export GL_UTILITIES=$GL_HOME/UTILITIES
##    append-path $GL_UTILITIES
##    export LINK_GRAMMAR_HOME=$GL_TOOLS/LINK_GRAMMAR
## 
##    export BUGZILLA=$WWW/bugzilla
##    export SOURCE=$SHARED/source
##    export DEKADE=$SOURCE/tpo/dekade
##    DEDAKE_SERVER_PORT=16777
##    MY_DEDAKE_SERVER_PORT=16778
##    export ANALYZER=$BIN/tpo-Full_Analyzer
##    export SCRIPTS=$ANALYZER/scripts
##    export TOMCAT_LOGS=$_CATALINA_HOME/logs
##    export DEKADE_LOGS=/home/tmp/log-files
##    export STORAGE_DIR=/home/tmp/tpo-dekade_storage
##    export VP=$SOURCE/tpo/virtual-patient/VP-Tutor
##    export VP_=$SOURCE/virtual-patient/VP-Tutor
## 
##    export SWING_TUTORIAL=$SHARED/source/swing-tutotial
##    export SWING_TUTORIAL_COMPONENTS=$SWING_TUTORIAL/uiswing/components/example-swing
## 
##    export FRAMENET_PREPOSITION=$GL_EXPERIMENTS/TEST-FRAMENET
## 
##    alias openoffice='/naboo/data/openoffice/program/soffice'
## 
##    export EMACSDIR='/usr/share/emacs/21.3'
## 
##    export UMBC_WEB_HOST="gl.umbc.edu"
## 
##    # Remove special language settings (e.g., UTF)
##    # TODO: set the encoding explicitly
##    unset LANG
## fi
## #
## function host-upload () { local host=$1; shift; $scpcmd "$@" $host:temp; }
## function host-download-dir () {
##          local host=$1; shift;
##          local dir="$1"; shift;
##          local files=`echo " $@ " | perl -pe "s@ (\\S+)@$host:temp/\\$1 @g;"`;
##          $scpcmd $files $dir; echo "downloaded to $dir"; }
## #
## # TODO: 
## if [ "$HOST" != "thoth" ]; then
##    alias ilit-upload='host-upload $THOTH'
##    alias ilit-download='host-download-dir $THOTH ~/xfer'
##    alias ilit-download-here='host-download-dir $THOTH .'
## fi
## #
## if [ "$HOST" != "naboo" ]; then
##    alias naboo-upload='host-upload $NABOO'
##    alias naboo-download='host-download-dir $NABOO ~/xfer'
##    alias naboo-download-here='host-download-dir $NABOO .'
## fi
## #
## ## OLD: alias ssh-tunnel-db='set_xterm_title.bash "ssh tunnel for Postgress access"; ssh -L 5432:localhost:5432 thoth.ilit.umbc.edu'

## OLD:
## # Convera stuff
## # TODO: see why domainname is 'converanis' and not 'convera.com'
## if [ "$DOMAIN_NAME" = "converanis" ]; then
##    export GRAPHLING_HOME=/mdhome/tohara/graphling;
##    export GL_DATA=$GRAPHLING_HOME/DATA
##    export GL_TOOLS=$GRAPHLING_HOME/TOOLS
##    export GL_EXPERIMENTS=$GRAPHLING_HOME/EXPERIMENTS
##    export GL_UTILITIES=$GRAPHLING_HOME/UTILITIES
##    ## append-path $GL_UTILITIES
##    alias gv=/usr/bin/ggv
##    alias xterm-utf8="xterm -u8 -fn '-b&h-lucidatypewriter-medium-r-normal-sans-0-0-75-75-m-0-iso10646-1'"
##    #
##    if [ "$INSTALL_DIR" = "" ]; then export INSTALL_DIR=$HOME/Convera/rware; fi
##    rware_dir="$INSTALL_DIR"
##    #
##    alias start-jboss='(pushd $rware_dir/jboss-4.0.3/bin; run.sh >| run-jboss.log 2>&1; popd) &'
##    alias stop-jboss='$rware_dir/jboss-4.0.3/bin/shutdown.sh'
##    alias kill-jboss='kill_em.sh -p "java.*jboss"'
##    alias view-jboss-log='less $rware_dir/jboss-4.0.3/server/rware/log/server.log'
##    #
##    alias rware-env-here='export INSTALL_DIR=$PWD; source set_rware_env.sh; do-setup'
##    #
##    rware_bin=$rware_dir/bin
##    rware_lib=$rware_dir/lib
##    alias start-admind='$rware_dir/admin/manage_admind start'
##    alias stop-admind='$rware_dir/admin/manage_admind stop'
##    alias restart-admind="stop-admind; start-admind"
##    alias query-admind="ps_mine.sh | grep execd"
##    alias kill-admind="kill_em.sh -p execd"
##    #
##    function kill-rware-forcibly() { foreach.perl 'kill_em.sh $f' execd cqdh cqindex cqns cqquery cqsched cqserv cqxref cqkey cqcred rwadmin DefaultCluster DefaultIndexCluster DefaultCluster_SearchService NameService_default CrossRef_default; ps_mine.sh; }
##    #
##    alias ssh-neon='ssh -X neon'
##    #
##    alias start-dcw="$rware_dir/bin/start_dcw"
##    #
##    prepend-path /SCM/3rd_party/ant/1.6.5/bin
##    export ANT_HOME=/SCM/3rd_party/ant/1.6.5
##    export CLASSPATH=$CLASSPATH:/SCM/3rd_party/junit/3.8.1/
##    #
##    # Miscellaneous directories
##    NIGHTLY=/SCM/available/v82/nightly
## 
##    # X Windows related
##    # TODO: alias=enable-remote-hosts="xterm -e '/usr/bin/bash -c /usr/X11R6/bin/xhost +'"
##    alias set-tohara-display='export DISPLAY=10.0.34.33:0.0'
## 
##    # Remove special language settings (e.g., UTF)
##    # TODO: set the encoding explicitly
##    unset LANG
## fi

#-------------------------------------------------------------------------------
# Java related stuff

## OLD:
## trace Java settings
## alias ant-rebuild-war='(/bin/rm /tmp/$USER/*; ant dist; remove; install) >| ant-war-rebuild.log 2>&1; $PAGE +G ant-war-rebuild.log'
## alias ant-rebuild='(ant clean compile; ant remove; ant install-build) >| ant-rebuild.log 2>&1; $PAGER +G ant-rebuild.log'

#-------------------------------------------------------------------------------
# SSH key switching
trace SSH settings
alias ssh-putty-keys='/bin/cp -f $HOME/.ssh2/authorization.putty $HOME/.ssh2/authorization; /bin/cp -f $HOME/.ssh2/identification.putty $HOME/.ssh2/identification'
alias home-keys='ssh-putty-keys'
alias ssh-linux-keys='/bin/cp -f $HOME/.ssh2/authorization.linux $HOME/.ssh2/authorization; /bin/cp -f $HOME/.ssh2/identification.linux $HOME/.ssh2/identification'
## OLD: alias cs-keys='ssh-linux-keys'

# reset CDPATH to just current directory
export CDPATH=.

# Just use $ for Bash prompt
# NOTE: cd override puts directory name in xterm title
## OLD: export PS1="$ "
## TODO: define conditional-export (see tomohara-aliases.bash)
if [ "$PS1" = "" ]; then export PS1="$ "; fi

# flag for turning off GNOME, which can be flakey at times
export USE_GNOME=1

## OLD:
## # General Settings for my perl scripts
## ## OLD
## ## export DEBUG_LEVEL=2
## ## alias debug-on='export DEBUG_LEVEL=3'
## ## OLD: export ORIGINAL_PERLLIB=$PERLLIB
## if [ "$PERLLIB" = "" ]; then PERLLIB="."; else PERLLIB="$PERLLIB:."; fi
## ## export PERLLIB="$BIN:$PERLLIB:$HOME/perl/lib/perl5/site_perl/5.8.0:$HOME/perl/lib/perl5/site_perl/5.8.0/i386-linux-thread-multi/:$HOME/lib/perl5/5.00503/i386-linux:$BIN/MODULES"
## # NOTE: perl uses architecture-specific subdirectories under PERLLIB
## export PERLLIB="$BIN:$PERLLIB:$HOME/perl/lib/perl5/site_perl/5.8"
## # HACK: not all cygwin directories being recognized
## export PERLLIB="$PERLLIB:$HOME/perl/lib/perl5/site_perl/5.8/cygwin"
## alias perl-='perl -Ssw'
## ## if [ "$MANPATH" = "" ]; then MANPATH="."; else MANPATH="$MANPATH:."; fi
## export MANPATH="$HOME/perl/share/man/man1:$MANPATH"
## append-path $HOME/perl/bin

## OLD:
## # Set the title for the current xterm, unless if not running X
## function set-title-to-current-dir () { 
##     local dir=`basename "$PWD"`; 
##     local other_info=""; 
##     if [ "$CLEARCASE_ROOT" != "" ]; then other_info="; $other_info cc=$CLEARCASE_ROOT"; fi
##     set_xterm_title.bash "$dir [$PWD]$other_info";
## }
## ## if [ "$TERM" = "xterm" ]; then set-title-to-current-dir; fi
## if [[ ("$TERM" = "xterm") || ("$TERM" = "cygwin") ]]; then set-title-to-current-dir; fi
## #
## alias reset-xterm-title='set_xterm_title.bash "$HOSTNAME $PWD"'
## alias alt-xterm-title='set_xterm_title.bash "alt $PWD"'

# Set file creation permission mask to enable RWX for user & group and none for others
# NOTE:
# - X needed in case directories created (or program files)
# - usage: umask ugo -or- umask symbolic-mode
#
## OLD: umask ug+rwx
# NOTE: umask is getting set to 0002 with above
#
## TODO: umask ug=rwx,o=r

# Settings for wordnet
# TODO: put these below with the other WN settings
## export WNSEARCHDIR=$GL_TOOLS/WORDNET-1.6/dict
## export wn=$GL_TOOLS/WORDNET-1.6/bin/$OSTYPE/wn
## alias wn17-env='conditional-source $GL_TOOLS/OLD/WORDNET-1.7/wn17_setenv.bash; export wn=$GL_TOOLS/OLD/WORDNET-1.7/bin/$OSTYPE/wn'
alias wn15-env='conditional-source $GL_TOOLS/WORDNET-1.5/wn15_setenv.bash; export wn=$GL_TOOLS/WORDNET-1.5/bin/$OSTYPE/wn'
alias wn16-env='conditional-source $GL_TOOLS/WORDNET-1.6/wn16_setenv.bash; export wn=$GL_TOOLS/WORDNET-1.6/bin/$OSTYPE/wn'
alias wn171-env='conditional-source $GL_TOOLS/WORDNET-1.7.1/wn171_setenv.bash; export wn=$GL_TOOLS/WORDNET-1.7.1/bin/$OSTYPE/wn'
alias wn20-env='conditional-source $GL_TOOLS/WORDNET-2.0/wn20_setenv.bash; export wn=$GL_TOOLS/WORDNET-2.0/bin/$OSTYPE/wn'
## OLD: if [ "$WNSEARCHDIR" = "" ]; then wn20-env; fi
## if [ "$WNSEARCHDIR" = "" ]; then wn171-env; fi

#-------------------------------------------------------------------------------
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
## OLD: alias cls='clear'
alias mv='/bin/mv -i $other_file_args'
alias move='mv'
alias move-force='move -f'
# TODO: make sure symbolic links are copied as-is (ie, not dereferenced)
alias copy="cp -ip $other_file_args"
alias copy-force="/bin/cp -fp $other_file_args"
alias cp="/bin/cp -i $other_file_args"
alias rm="/bin/rm -i $other_file_args"
alias delete="/bin/rm -i $other_file_args"
alias del="delete"
alias delete-force="/bin/rm -f $other_file_args"
alias remove-force='delete-force'
alias remove-dir-force='/bin/rm -rfv'
alias delete-dir-force='remove-dir-force'
#
## function copy-readonly () { if [ "$3" != "" ]; then echo 'only two arguments please!'; else /bin/cp -ipf $1 $2; if [ -f $2 ]; then  chmod -w $2; else chmod -w $2/`basename $1`; fi; fi; }
alias copy-readonly='copy-readonly.sh'
#
NICE="nice -19"

## OLD:
## #------------------------------------------------------------------------
## # Directory commands (via ls):
## trace directory commands
## 
##  
## # ls options: # -a all files; -l long listing; -t by time; -k in KB; -h human readable; -G no group; -d no subdirectory listings
## #
## core_dir_options="-altkh"
## dir_options="${core_dir_options}G"
## if [ "$OSTYPE" = "solaris" ]; then dir_options="-alt"; fi
## if [ "$BAREBONES_HOST" = "1" ]; then dir_options="-altk"; fi
## function dir () { ls ${dir_options} "$@" 2>&1 | $PAGER; }
## alias ls-full='ls ${core_dir_options}'
## function dir-full () { ls-full "$@" 2>&1 | $PAGER; }
## ## OLD: alias dir-='dir-full'
## alias dir-='ls ${dir_options}'
## function dir-sans-backups () { ls ${dir_options} "$@" 2>&1 | grep -v '~[0-9]*~' | $PAGER; }
## #
## # Miscellaneous directory helpers
## # Shows read-only files (for user)
## # ex: -r-xr-xr-x  1 root 4.7K 2013-12-13 17:18 ngram_filter.py
## function dir-ro () { ls ${dir_options} "$@" 2>&1 | grep -v '^[^ld].w' | $PAGER; }
## # Shows writable files (for user)
## # ex: -rwxr-x--x  1 root 9.4K 2014-06-26 20:18 gensim_test.py
## function dir-rw () { ls ${dir_options} "$@" 2>&1 | grep '^[^ld].w' | $PAGER; }
## # Shows files not executable
## # ex -rw-r--r-- 1 root 3.9K 2014-06-09 01:54 /mnt/tohara/src/sandbox/tohara/randomize_lines.py
## function dir-non-executable () { ls ${dir_options} "$@" 2>&1 | grep -v '^[^ld]..x' | $PAGER; }
## 
## function subdirs () { ls ${dir_options} "$@" 2>&1 | grep ^d | $PAGER; }
## ## OLD: alias subdirs-proper='find . -maxdepth 1 -type d | grep -v "^\.\$"'
## alias subdirs-proper='find . -maxdepth 1 -type d | grep -v "^\.\$" | perl -pe "s@^\./@@;" | column'
## # note: -f option overrides -t: Unix sorts alphabetically by default; via ls manpage:
## #    -f     do not sort, enable -aU, disable -ls --color
## ## OLD: function subdirs-alpha () { ls ${dir_options} -f "$@" 2>&1 | grep ^d | $PAGER; }
## # drwxr-xr-x   3 root root     4096 Jun 12 02:39 boot
## # 1            2 3    4        5    6   7  8     9
## ## TEST: function subdirs-alpha () { ls -al "$@" 2>&1 | grep ^d | cut -d' ' -f9- | $PAGER; }
## function subdirs-alpha () { ls -al "$@" 2>&1 | grep ^d | $PAGER; }
## function sublinks () { ls ${dir_options} "$@" 2>&1 | grep ^l | $PAGER; }
## ## OLD: function sublinks-alpha () { ls ${dir_options} -f "$@" 2>&1 | grep ^l | $PAGER; }
## ## TEST: function sublinks-alpha () { ls -al "$@" 2>&1 | grep ^l | cut -d' ' -f9- | $PAGER; }
## function sublinks-alpha () { ls -al "$@" 2>&1 | grep ^l | $PAGER; }
## #
## alias glob-links='find . -maxdepth 1 -type l | sed -e "s/.\///g"'
## alias glob-subdirs='find . -mindepth 1 -maxdepth 1 -type d | sed -e "s/.\///g"'
## 
## #
## alias ls-R='ls -R >| ls-R.list; wc -l ls-R.list'
## #
## # TODO: create ls alias that shows file name with symbolic links (as with ls -l but without other information
## # ex: ls -l | perl -pe 's/^.* \d\d:\d\d //;'

# Grep commands
trace grep commands
#
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
modern_grep=`grep -V 2>&1 | head -1 | perl -ne 's/^.*(\d+\.\d+)/$1/; print ($1 >= 2.4 ? 1 : 0);'`
if [ "$modern_grep" = 1 ]; then skip_dirs="-d skip"; fi

# Grep settings
# TODO: use gr and gr_ throughout for consistency
# TODO: use -P flag (i.e.,  --perl-regexp) w/ grep rather than egrep
# NOTE: MY_GREP_OPTIONS used instead of GREP_OPTIONS since grep interprets latter
export GREP=egrep
export MY_GREP_OPTIONS="-n $skip_dirs"
## alias gr='$GREP $skip_dirs -i -n'
## alias gr-="'$GREP $skip_dirs -n '
function gr () { $GREP $MY_GREP_OPTIONS -i "$@"; }
function gr- () { $GREP $MY_GREP_OPTIONS "$@"; }
## TODO: selection sort option spec based on version of bash or sort
## SORT_COL2="+1"
SORT_COL2="--key=2"
## OLD: function grep-unique () { $GREP -c $MY_GREP_OPTIONS "$@" | grep -v ":0" | sort -rn +1 -t':'; }
## function grep-unique () { $GREP -c $MY_GREP_OPTIONS "$@" | grep -v ":0" | sort -rn --key=2 -t':'; }
function grep-unique () { $GREP -c $MY_GREP_OPTIONS "$@" | grep -v ":0" | sort -rn $SORT_COL2 -t':'; }
function grep-missing () { $GREP -c $MY_GREP_OPTIONS "$@" | grep ":0"; }
alias gu='grep-unique -i'
alias gu-='grep-unique'
function gu-all () { grep-unique "$@" * | $PAGER; }
alias gn='grep-missing'

function gu- () { $GREP -c $MY_GREP_OPTIONS "$@" | grep -v ":0"; }
function grepl () { $GREP -i $MY_GREP_OPTIONS "$@" | $PAGER -p$1; }
function grepl- () { $GREP $MY_GREP_OPTIONS "$@" | $PAGER -p$1; }

# gr-c: grep through c/c++ source and headers files
# note: --no-messages suppresses warnings about missing files
function gr-c () { gr --no-messages "$@" *.c *.cpp *.cxx *.h; }

## function gr-tex () { gr "$@" *.tex *.sty; }
## function gr-tex- () { gr- "$@" *.tex *.sty; }

## function gr-lisp () { gr "$@" *.lisp *.cl; }
## function gr-lisp- () { gr- "$@" *.lisp *.cl; }
## function old-trace-lisp () { echo "(trace" `perlgrep -show_filename=0 -para -v '\#\|[^\000]+defun[^\000]+\|\#'  "$@" | extract_matches.perl "^\s*\(defun (\S+)" -` ")"; }
## function trace-lisp () { echo -n "(trace "; perlgrep.perl -show_filename=0 -para -v '\#\|[^\000]+defun[^\000]+\|\#'  "$@" | extract_matches.perl "^\s*\(defun (\S+)" - | perl -pe "s/\n/ /;"; echo " )"; }
# TODO: create function for creating gr-xyz aliases
# TODO: -or- create gr-xyz template
## function gr-xyz () { gr- "$@" *.xyz; }
#
# show-line-context(file, line-num): show 5 lines before LINE-NUM in FILE
function show-line-context() { cat -n $1 | egrep -B5 "^\W+$2\W"; }

# Helper function for grep-based aliases pipe into less
function gr-less () { gr "$@" | $PAGER; }

# Commonly used grepping situations
function gr-python () { gr "$@" ~/python/*.py; }

# Other grep-related stuff
#
alias grep-nonascii='perlgrep.perl "[\x80-\xFF]"'
alias gr-nonascii='perlgrep.perl -n "[\x80-\xFF]"'

## Old ILIT stuff (TODO remove this and other old stuff no longer used)
## # Aliases for ILIT OntoSem lisp sources files, lexicon and ontology
## lisp_source_files="lisp-source-files.list"
## function gr-ontosem () { dir=$1; shift; gr "$@" `cat $dir/$lisp_source_files | perl -pe "s@^@$dir/@;"` | $PAGER; }
## alias gr-onto-full='gr-ontosem $ANALYZER'
## function gr-onto () { gr-ontosem "$ANALYZER" "$@" | perl -pe "s@^$ANALYZER/*@@;" | $PAGER; }
## function gr-lexicon () { gr-less "$@" $ANALYZER/Inputs/combo-lex.lisp; }
## alias gr-lex='gr-lexicon'
## function gr-ontology () { gr-less "$@" $ANALYZER/Knowledge/Ontology/mikro-ontology.lisp; }
## alias clisp='clisp.sh'
## alias load-install='clisp -- -norc -i install.lisp'
## alias load-tpo-install='clisp -- -norc -i tpo-install.lisp'
## alias load-tpo-medical-install='clisp -- -norc -i tpo-medical-install.lisp'
## alias load-medical-install='clisp -- -norc -i medical-install.lisp'
## alias compile-ontosem='load-install'
## alias delete-fasl='find . \( -name "*.lib" -o -name "*.fas" -o -name "*.fasl" \) -exec rm -fv {} \;'
## alias delete-fasl-plus='/bin/rm -fv lispinit.mem; delete-fasl'
## alias reload-medical-install='delete-fasl; load-medical-install'
## 
## # Likewise for VP source
## ## function gr-vp () { gr-less "$@" $VP/src/edu/umbc/ilit/*/*.java; }
## function gr-vp () { dir=$VP/src/edu/umbc/ilit; gr "$@" $dir/*/*.java | perl -pe "s@^$dir/@@;" | $PAGER; }
## function gr-vp-tests () { dir=$VP/test/edu/umbc/ilit; gr "$@" $dir/*/*.java | perl -pe "s@^$dir/@@;" | $PAGER; }
## 
## alias kill-animator='kill_em.sh -p animator4.Main'
## function recreate-ontosem-image () { pushd $ANALYZER; clisp.sh --image lispinit.mem -- -x '(progn (load "tpo-init.lisp") (create-lisp-image))'; popd; }

## function gr-c () { gr "$@" *.c *.cpp; }
## function gr-c- () { gr- "$@" *.c *.cpp; }

## function gr-h () { gr "$@" *.h; }
## function gr-h- () { gr- "$@" *.h; }

function gr-bib () { perlgrep.perl -i -para "$@" *.bib; }
function gr-biblio () { perlgrep.perl -i -para "$@" *bib*.ascii; }

# Searching for files
# TODO:
# - specify find options in an environment variable
# - rework in terms of Perl regex? (or use -iregex in place of -iname)
#
## function findspec () { find $1 -iname \*$2\* $3 $4 $5 $6 $7 $8 $9 -print 2>&1 | grep -v '^find: '; }
## function findspec () { find $1 -iname \*$2\* $3 $4 $5 $6 $7 $8 $9 2>&1 | grep -v '^find: '; }
function findspec () { if [ "$2" = "" ]; then echo "Usage: findspec dir glob-pattern find-option ... "; else find $1 -iname \*$2\* $3 $4 $5 $6 $7 $8 $9 2>&1 | grep -v '^find: '; fi; }
function findspec-all () { find $1 -follow -iname \*$2\* $3 $4 $5 $6 $7 $8 $9 -print 2>&1 | grep -v '^find: '; }
function fs () { findspec . "$@" | egrep -iv '(/(backup|build)/)'; } 
function fs-ls () { fs "$@" -exec ls -l {} \; ; }
alias fs-='findspec-all .'
function fs-ext () { find . -iname \*.$1 | egrep -iv '(/(backup|build)/)'; } 
# TODO: extend fs-ext to allow for basename pattern (e.g., fs-ext java ImportXML)
function fs-ls- () { fs- "$@" -exec ls -l {} \; ; }
alias fs-java='fs-ext java'
#
findgrep_opts="-in"
#
# NOTE: findgrep macros use $findgrep_opts dynamically (eg, user can change $findgrep_opts)
## OLD: function findgrep-verbose () { find $1 -follow -iname \*$2\* -print -exec egrep $findgrep_opts "$3" $4 $5 $6 $7 $8 $9 \{\} \;; }
function findgrep-verbose () { find $1 -iname \*$2\* -print -exec egrep $findgrep_opts "$3" $4 $5 $6 $7 $8 $9 \{\} \;; }
## OLD: function findgrep () { find $1 -follow -iname \*$2\* -exec egrep $findgrep_opts "$3" $4 $5 $6 $7 $8 $9 \{\} /dev/null \;; }
# findgrep(dir, filename_pattern, line_pattern): grep through files in DIR matching FILENAME_PATTERN for LINE_PATTERN
function findgrep () { find $1 -iname \*$2\* -exec egrep $findgrep_opts "$3" $4 $5 $6 $7 $8 $9 \{\} /dev/null \;; }
function findgrep- () { find $1 -iname $2 -print -exec egrep $findgrep_opts $3 $4 $5 $6 $7 $8 $9 \{\} \;; }
## function findgrep-ext () { find "$1" -iname "*.$2" -exec egrep $findgrep_opts "$3" "$4" "$5" "$6" "$7" "$8" "$9" \{\}  /dev/null \;; }
function findgrep-ext () { local dir="$1"; local ext="$2"; shift; shift; find "$dir" -iname "*.$ext" -exec egrep $findgrep_opts "$@" \{\}  /dev/null \;; }
# NOTE: findgrep-foreach removed since unused
# TODO: put other little used aliases in new do-full-setup.bash file
## OLD: function findgrep-foreach () { find $1 -follow -iname \*$2\* -exec egrep $findgrep_opts -l $3 \{\} \; | foreach.perl "$4" -; }
## OLD: function findgrep-foreach- () { find $1 -follow -iname \*$2\* -exec egrep $findgrep_opts -l $3 \{\} \; | foreach.perl $4 $5 $6 $7 $8 $9; }
##
# fgr(filename_pattern, line_pattern): grep through files matching FILENAME_PATTERN for LINE_PATTERN
function fgr () { findgrep . "$@" | egrep -v '((/backup)|(/build))'; }
function fgr-ext () { findgrep-ext . "$@" | egrep -v '(/(backup)|(build)/)'; }
function fgr-java () { findgrep-ext . "java" "$@" | egrep -v '(/(backup)|(build)/)'; }
#
## OLD: alias prepare-find-files-here='ls -alR >| ls-alR.list 2>&1'
## OLD: alias prepare-find-files-here="dobackup ls-alR.list fi; $NICE ls -alR >| ls-alR.list 2>&1"
function prepare-find-files-here () { if [ -e "ls-alR.list" ]; then dobackup.sh ls-alR.list; fi; $NICE ls -alR >| ls-alR.list 2>&1; }
## OLD: function find-files-there () { perlgrep.perl -para "$1" "$2" | egrep -i '((^\.)|('$1'))' | $PAGER_NOEXIT -p "$1"; }
function find-files-there () { perlgrep.perl -para -i "$@" | egrep -i '((^\.)|('$1'))' | $PAGER_NOEXIT -p "$1"; }
function find-files-here () { find-files-there "$1" "$PWD/ls-alR.list"; }
#
# TODO: add --quiet option to dobackup.sh (and port to bash)
# TODO: function conditional-backup() { if [ -e "$1" ]; then dobackup.sh $1; fi; }
alias make-file-listing='listing="ls-aR.list"; dobackup.sh "$listing"; ls -aR >| "$listing" 2>&1'

# Emacs commands
#
## OLD:
## alias emacs-='emacs'
## if [ "$DISPLAY" = "" ]; then 
##    alias emacs-='emacs --no-windows'
##    function em () { if [ "$1" = "" ]; then emacs- .; else emacs- "$@"; fi; }
## else
##    function em () { if [ "$1" = "" ]; then emacs- .; else emacs- "$@"; fi & }
## fi
## alias ed='em'
alias em=tpo-invoke-emacs.sh
function em-fn () { em -fn "$1" $2 $3 $4 $5 $6 $7 $8 $9; }
alias em-tags=etags
#
alias em-misc='em-fn -misc-fixed-medium-r-normal--14-110-100-100-c-70-iso8859-1'
alias em-nw='emacs --no-windows'
alias em_nw='em-nw'
function em-file () { set_xterm_title.bash "`basename $1` [`full-dirname $1`]"; em-nw "$@"; }
## OLD: alias em-dir='em .'
## OLD: function em-dir() { pushd "$1"; em .; popd; }
alias em-this-dir='em .'
alias em-devel='em --devel'
#
## OLD
## function em-debug () { em -debug-init "$@"; }
## function em-quick () { em -q "$@"; }
## function em-small () { em -fn "-adobe-courier-bold-r-normal--12-120-75-75-m-70-iso8859-1" "$@"; }
## function em-large () { em -fn "-adobe-courier-bold-r-normal--18-180-75-75-m-110-iso8859-1" -geometry 70x30 "$@"; }
## function em-very-large () { em -fn "-adobe-courier-bold-r-normal--24-240-75-75-m-150-iso8859-1" -geometry 60x20 "$@"; }

## OLD:
## # Simple TODO-list maintenance commands
## #
## # add-todo(text): adds text<TAB><timestamp> to to-do list
## # todo: print example of using add-todo (for cut-n-paste purposes)
## # TODO: figure out way to have example copied into bash input buffer
## #
## # NOTE: tac is GNU reverse program ('reverse' of cat)
## # TODO: document all bash aliases (and functions) for benefit of others (and yourself!)
## ## OLD: alias view-todo="perl -SSw reverse.perl $HOME/info/todo_list.text | $PAGER_CHOPPED"
## # TODO: revert to using tac; why was reverse.perl used instead???
## alias view-todo="perl -SSw reverse.perl $HOME/organizer/todo_list.text | $PAGER_CHOPPED"
## #
## ## OLD: function add-todo () { echo "$@" \	`date` >> $HOME/info/todo_list.text ; view-todo; }
## function add-todo () { echo "$@" \	`date` >> $HOME/organizer/todo_list.text ; view-todo; }
## #
## function todo-one-week () { add-todo "[within 1 week] " "$@"; }
## #
## ## function todo () { echo add-todo '"[within N weeks] ..."'; }
## function todo () { if [ "$1" == "" ]; then echo add-todo '"[within N weeks] ..."'; else todo-one-week "$@"; fi; }
## #
## # todo:(text): convenience alias for todo() for cut-n-paste of 'TODO: ...' notes from files
## alias todo:='todo'
## # TODO: enable bash case insensitivity for support of TODO and TODO: as well
## # (eg, via "shopt -s nocaseglob" and "set completion-ignore-case on" in .bash_profile??
## alias TODO='todo'
## alias TODO:='todo'
## function TODO1() { todo "$@"'!'; }
## alias todo1=TODO1
## #
## function todo! () { if [ "$1" == "" ]; then todo; else todo "$@"'!'; fi; }
## #
## # mail-todo: version of todo that also ends email
## # TODO: use lynx to submit send-to type URL
## function mail-todo () { add-todo "$*"; echo TODO: "$*" | mail -s "TODO: $*" ${USER}@${DOMAIN_NAME}; }
## #
## # Likewise for time tracking
## ## OLD: alias view-track-time="tac $HOME/info/time_tracking_list.text | $PAGER_CHOPPED"
## alias view-track-time="tac $HOME/organizer/time_tracking_list.text | $PAGER_CHOPPED"
## alias view-time-tracking=view-track-time
## #
## ## OLD: function add-track-time () { echo "$@" \	`date` >> $HOME/info/time_tracking_list.text ; view-track-time; }
## function add-track-time () { echo "$@" \	`date` >> $HOME/organizer/time_tracking_list.text ; view-track-time; }
## #
## function track-time () { if [ "$1" == "" ]; then echo add-track-time '"..."'; else add-track-time "$@"; fi; }

## OLD:
# TODO: put signature in tomohara-aliases.bash
# TODO: use ~/organizer instead of ~/info???
## OLD: alias address-info='cat $HOME/info/address.text'
## OLD: alias combined-signature='cat $HOME/info/.combined-signature'
## OLD: alias full-signature='combined-signature'
## OLD: alias cs-signature='cat $HOME/info/.cs-signature'
## OLD: alias cell-signature='cat $HOME/info/.cell-signature'
## OLD: alias alt-cell-signature='cat $HOME/info/.alt-cell-signature'
## OLD: alias home-signature='cat $HOME/info/.home-signature'
## OLD: alias ilit-signature='cat $HOME/info/.ilit-signature'
## OLD: alias alt-cell-signature='cat $HOME/info/.alt-cell-signature'
## OLD: alias tomas-signature='cat $HOME/info/.tomas-signature'
## OLD: alias tpo-signature='cat $HOME/info/.tpo-signature'
## OLD: alias txstate-signature='cat $HOME/info/.txstate-signature'
## OLD: function signature () { cat $HOME/info/.$1-signature; }
## OLD:
## function signature () {
##     if [ "$1" = "" ]; then
## 	ls $HOME/info/.$1-signature
## 	echo "Usage: signature dotfile-prefix"
## 	echo "ex: signature scrappycito"
## 	return;
##     fi
##     cat $HOME/info/.$1-signature
## }
## alias cell-signature='signature cell'
## alias home-signature='signature home'
## alias po-signature='signature po'
## alias tpo-signature='signature tpo'
## alias tpo-scrappycito-signature='signature tpo-scrappycito'
##
## OLD: alias pr-signature='signature pr'
#
# create aliases using underscores instead of dashes
# TODO: automatically do this for all aliases and scripts!
# TODO: see if bash has some translation option that would handle this transparently
#
## OLD:
## # TODO: create separate env-var for info directory (eg, $INFO)
## function gr-tidbits () { gr "$@" $HOME/info/tidbits.text; }

# Mail commands
trace mail commands
#
alias view-mail='$PAGER $HOME/mail/In'
function view-mail- () { $ZPAGER $HOME/mail/OLD/mail_$1.gz; }
alias view-mail-log='$PAGER $HOME/mail/sent-mail'
function view-mail-log- () { $ZPAGER $HOME/mail/OLD/logged_messages_$1.gz; }
alias view-mail-aliases='$PAGER $HOME/.mailrc'
## OLD:
## function mail-tpo () { mail -s $1 tom_o_hara@msn.com < $1; }
## function mail-tpo () { mail -s $1 tomohara@umbc.edu < $1; }

## OLD:
## # Simple calculator commands
## function old-calc () { echo "$@" | bc -l; }
## ## function perl-calc () { echo "$@" | perl- perlcalc.perl -; }
## function perl-calc () { perl- perlcalc.perl -args "$@"; }
## # TODO: read up on variable expansion in function environments
## function perl-calc-init () { initexpr=$1; shift; echo "$@" | perl- perlcalc.perl -init="$initexpr" -; }
## alias calc='perl-calc'
## alias calc-init='perl-calc-init'
## alias calc-int='perl-calc -integer'
## function old-perl-calc () { perl -e "print $*;"; }
## function hex2dec { perl -e "printf '%d', 0x$1;" -e 'print "\n";'; }
## ## OLD: function oct2dec { perl -e "printf '%d', 0$1;" -e 'print "\n";'; }
## ## OLD: function oct2hex { perl -e "printf '%x', oct(q/$1/);" -e 'print "\n";'; }
## function dec2hex { perl -e "printf '%x', $1;" -e 'print "\n";'; }
## ## OLD: function dec2oct { perl -e "printf '%o', $1;" -e 'print "\n";'; }
## function bin2dec { perl -e "printf '%d', 0b$1;" -e 'print "\n";'; }
## function dec2bin { perl -e "printf '%b', $1;" -e 'print "\n";'; }
## alias hv='hexview.perl'
## 
## # Miscellaneous commands
## trace Miscellaneous commands
## #
## alias startx-='startx >| startx.log 2>&1'
## alias xt='xterm.sh &'
## alias gt='gnome-terminal &'
## ## OLD: alias h='history $LINES'
## alias hist='history $LINES'
## # Removes timestamp from history (e.g., " 1972  [2014-05-02 14:34:12] dir *py" => " 1972  dir *py")
## # TEST: function hist { h | perl -pe 's/^(\s*\d+\s*)(\[[^\]]+\])(.*)/$1$3/;'; }
## # note: funciton used to simplify specification of quotes
## function h { hist | perl -pe 's/^(\s*\d+\s*)(\[[^\]]+\])(.*)/$1$3/;'; }
## ## alias lynx='lynx -cookies'
## alias new-lynx='lynx-2.8.4'
## alias fix-keyboard='kbd_mode -a'
## function asctime() { perl -e "print (scalar localtime($1));"; echo ""; }
## function filter-dirnames () { perl -pe 's/\/[^ \"]+\/([^ \/\"]+)/$1/g;'; }
## ## alias ns="nice -10 netscape &"
## ## alias ns="netscape &"
## alias ns="$NICE netscape >| $HOME/temp/netscape-$$.log 2>&1 &"
## ## alias netscape-6.1='/opt/local/pkg/netscape6.1/netscape >| /tmp/netscape-6.1.log 2>&1 &'
## ## alias ns6.1='netscape-6.1'
## ## alias netscape-6.2='/opt/local/pkg/netscape6.2/netscape >| /tmp/netscape-6.2.log 2>&1 &'
## ## alias ns6.2='netscape-6.2'
## 
## # alias type='cat'  # interferes with type command
## alias reverse='tac'
## function backup-file () { local file="$1"; if [ -e "$file" ]; then dobackup.sh "$file"; fi; }
## alias tpo-backup='make-tpo-backup.sh'
## function relativize-path () { echo "$@" | perl -pe "s@(^| )$HOME/@~/@;g"; }
## #
## ## OLDER: function usage () { du --kilobytes --one-file-system 2>&1 | sort -rn >| usage.list 2>&1; $PAGER usage.list; }
## ## OLD: function usage () { $NICE du --kilobytes --one-file-system 2>&1 | $NICE sort -rn >| usage.list 2>&1; $PAGER usage.list; }
## function usage () { output_file="usage.list"; backup-file $output_file; $NICE du --block-size=1K --one-file-system 2>&1 | $NICE sort -rn >| $output_file 2>&1; $PAGER $output_file; }
## ## TODO: function usage () { du --one-file-system --human-readable 2>&1 | sort -rn >| usage.list 2>&1; $PAGER usage.list; }
## #
## ## OLD: function check-errors () { (check_errors.perl -skip_warnings -context=5 "$@") 2>&1 | $PAGER; }
## function check-errors () { (check_errors.perl -context=5 "$@") 2>&1 | $PAGER; }
## ## function check-all-errors () { (check_errors.perl -skip_warnings=0 -context=5 "$@") 2>&1 | $PAGER; }
## function check-all-errors () { (check_errors.perl -warnings -context=5 "$@") 2>&1 | $PAGER; }
##     ## function check-all-warnings () { (check_errors.perl -skip_warnings=0 -context=5 -all_possible_warnings "$@") 2>&1 | $PAGER; }
## alias check-all-warnings='echo use check-all-errors instead; check-all-errors'
## 
## ## OLD: alias clock='xclock -geom 80x80+6+62 -analog -fg black -bg ivory &'
## 
## function tkdiff () { wish -f $BIN/tkdiff.tcl "$@" & }
## function old-tkdiff () { wish -f $BIN/old_tkdiff.tcl "$@" & }
## function new-tkdiff () { wish -f $BIN/tkdiff.tcl "$@" & }
## ## OLD: alias vdiff='tkdiff'
## alias vdiff='kdiff'
## alias rdiff='rev_vdiff.sh'
## alias tkdiff-='tkdiff -noopt'
## alias vd=tkdiff
## alias vd-=tkdiff-
## alias diff='command diff -wb'
## function diff-verbose () { echo "Issuing: diff -wb ..."; command diff -wb "$@"; }
## alias diff-='command diff'
## ## OLD:
## ## function vdiff-rev () {
## ##     local left_file="$2"
## ##     local right_file="$1"
## ##     if [ -d "$left_file" ]; then left_file="$left_file/$right_file"; fi
## ##     vdiff "$left_file" "$right_file"
## ## }

# Bookmark commands
# TODO: have version that just uses a single bookmark source
function view-bookmarks () { perl- bookmark2ascii.perl "$@" $HOME/.netscape/bookmarks.html $HOME/lynx_bookmarks.html | $PAGER; }
## alias view-book-marks=view-bookmarks
## alias view-book-marks-=view-bookmarks_
function lookup-bookmark () { view-bookmarks_ | $GREP $MY_GREP_OPTIONS -A1 "$@"; }
alias bookmark-gr='lookup-bookmark'
alias lynx-bookmarks-='perl- bookmark2ascii.perl $HOME/lynx_bookmarks.html'
alias lynx-bookmarks='lynx-bookmarks- | $PAGER'
## alias lynx-book-marks-=lynx-bookmarks-
## alias lynx-book-marks=lynx-bookmarks
function lookup-lynx-bookmark () { lynx-bookmarks- | $GREP $MY_GREP_OPTIONS -A1 "$@"; }

## OLD:
## # Tar archive creation and manipulation
## # tar options:
## # -x extract; -v verbose; -f file source; -z compressed; -k don't overwrite files
## trace tar archive commands
## GTAR="tar"
## alias gtar="$GTAR"
## #
## # ls-relative(file): show pathname of FILE relative to $HOME (e.g., ~/xfer/do_setup.bash)
## function ls-relative () { ls -d "$1" | perl -pe "s@$HOME@~@;"; }
## #
## # make-tar(archive_basename, [dir=.], [depth=max], [filter=pattern]): tar up directory with results placed 
## #   in archive_base.tar.gz and log file in base.log; afterwards display the tar size, log, and path.
## # Filenames matching the optional filter are excluded.
## # EX: make-tar ~/xfer/program-files-structure 'C:\Program Files' 1
## #   
## find_options=""
## function make-tar () { 
## 	 local base=$1; local dir=$2; local depth=$3; local filter=$4;
## 	 local depth_arg=""; local filter_arg="."
## 	 if [ "$dir" = "" ]; then dir="."; fi;
## 	 if [ "$depth" != "" ]; then depth_arg="-maxdepth $depth"; fi;
## 	 if [ "$filter" != "" ]; then filter_arg="-v $filter"; fi;
## 	 # TODO: make pos-tar ls optional, so that tar-in-progress is viewable
## 	 (find "$dir" $find_options $depth_arg -not -type d -print | egrep -i "$filter_arg" | $NICE $GTAR cvfTz "$base.tar.gz" -) >| "$base.log" 2>&1; 
## 	 (ls -l "$base.tar.gz"; cat "$base.log") 2>&1 | $PAGER; 
## 	 ls-full "$base.tar.gz";
## 	 ls-relative "$base.tar.gz"; 
## }
## # TODO: handle filenames with embedded spaces
## #
## # tar-dir(dir, depth, [filter]): create archive of DIR in ~/xfer, using subdirectories up to DEPTH, and optionally 
## # filtering files matching exlusion filter.
## #
## function tar-dir () {
## 	local dir=$1; local depth=$2;
## 	local archive_base=$TEMP/`basename "$dir"`
## 	make-tar "$archive_base" "$dir" $depth
## }
## function tar-just-dir () { tar-dir $1 1; }
## #
## function tar-this-dir () { local dir="$PWD"; pushd-q ..; tar-dir "`basename "$dir"`"; popd-q; }
## #
## # tar-this-dir-normal: creates archive of directory, excluding archive, backup, and temp subdirectories
## function tar-this-dir-normal () { local dir="$PWD"; pushd-q ..; tar-dir "`basename "$dir"`" "" "/(archive|backup|temp)/"; popd-q; }
## #
## function tar-just-this-dir () { local dir="$PWD"; pushd-q ..; tar-dir "`basename "$dir"`" 1; popd-q; }
## function make-recent-tar () { (find . -type f -mtime -$2 | $GTAR cvfzT $1 -; ) 2>&1 | $PAGER; ls-relative $1; }
## #
## # " (for Emacs)
## # NOTE: above quote needed to correct for Emacs color coding
## # TODO: rework basename extraction
## #
## function view-tar () { $GTAR tvfz "$@" 2>&1 | $PAGER; }
## function extract-tar () { $NICE $GTAR xvfzk "$@" 2>&1 | $PAGER; }
## function extract-tar-force () { $NICE $GTAR xvfz "$@" 2>&1 | $PAGER; }
## function extract-tar-here () { pushd ..; $NICE $GTAR xvfzk "$@" 2>&1 | $PAGER; popd; }
## alias untar='extract-tar'
## alias untar-here='extract-tar-here'
## alias un-tar=untar
## alias untar-force='extract-tar-force'
## ## alias make-tar='make-tar-with-subdirs'
## alias create-tar='make-tar-with-subdirs'
## alias make-full-tar='make-tar'
## # TODO: handle filenames with embedded spaces
## ## alias tar-this-dir='make-tar-with-subdirs $TEMP/`basename "$PWD"`'
## ## alias tar-just-this-dir='make-tar-sans-subdirs $TEMP/`basename $PWD`'
## alias recent-tar-this-dir='make-recent-tar $TEMP/recent-`basename "$PWD"`'
## function sort-tar-archive() { (tar tvfz "$@" | sort --key=3 -rn) 2>&1 | $PAGER; }

alias color-xterm='rxvt&'

## function xv () { xli "$@" }

alias count-it='perl- count_it.perl'
alias count_it=count-it
## alias count-tokens='count-it "\S+"'
## BAD: function count-tokens () { count-it "$@" "\S+"; }
function count-tokens () { count-it "\S+" "$@"; }
alias perlgrep='perl- perlgrep.perl'
function calc-stdev () { sum_file.perl -stdev "$@" -; }
alias calc-stdev-file='calc-stdev <'

## OLD:
## alias hotbot-freq='perl- web_freq.perl -hotbot'
## alias altavista-freq='perl- web_freq.perl -altavista'
## function get-hotbot-blurbs () { web_freq.perl -full $1 | perlgrep -A=1 '^ *\d+\.' | $PAGER; }
## function show-hotbot-precontext () { web_freq.perl -full $1 | count-it -i "\w+ $1" | sort $SORT_COL2 -rn -t'	' | $PAGER; }
## function show-hotbot-precontext () { web_freq.perl -full $1 | count-it -i "\w+ $1" | sort $SORT_COL2 -rn -t'	' | $PAGER; }
## function show-hotbot-precontext- () { web_freq.perl -full $1 | count-it -i -foldcase "\w+ $1" | sort $SORT_COL2 -rn -t'	' | $PAGER; }
## function show-hotbot-postcontext () { web_freq.perl -full $1 | count-it -i "$1 \w+" | sort $SORT_COL2 -rn -t'	' | $PAGER; }
## function show-hotbot-postcontext- () { web_freq.perl -full $1 | count-it -i -foldcase "$1 \w+" | sort $SORT_COL2 -rn -t'	' | $PAGER; }
## 
## function show-altavista-precontext () { web_freq.perl -download_urls -altavista -full $1 | count-it -i "\w+ $1" | sort $SORT_COL2 -rn -t'	' | $PAGER; }
## function show-altavista-postcontext () { web_freq.perl -download_urls -altavista -full $1 | count-it -i "$1 \w+" | sort $SORT_COL2 -rn -t'	' | $PAGER; }

#------------------------------------------------------------------------

alias do-resize="resize >| $TEMP/resize.sh; conditional-source $TEMP/resize.sh"
## do-resize

# Displaying bash aliases and functions
# note: $*. used in grep to handle special case of no pattern
trace alias display
#
## alias show-functions='typeset -f | perl -pe "s/^declare/\ndeclare/;"'

## OLD: alias show-functions='typeset -f | perl -pe "s/^}/}\n/;"'
alias show-functions-aux='typeset -f | perl -pe "s/^}/}\n/;"'
## OLD: function show-macros () { pattern="$*"; if [ "$pattern" = "" ]; then pattern=.; fi; alias | gr $pattern ; show-functions | perlgrep -i -para $pattern; }
function show-all-macros () { pattern="$*"; if [ "$pattern" = "" ]; then pattern=.; fi; alias | gr $pattern ; show-functions-aux | perlgrep -i -para $pattern; }
function show-macros () { show-all-macros "$*" | perlgrep -v -para "^_"; }
# TODO: figure out how to exclude env. vars from show-variables output
function show-variables () { set | $GREP -i '^[a-z].*='; }

function show-macros-by-word () { pattern="\b$*\b"; if [ "$pattern" = "" ]; then pattern=.; fi; alias | $GREP $pattern ; show-functions-aux | perlgrep -para $pattern; }
alias show-macros='show-macros'
alias show-aliases='alias | $PAGER'
## OLD: alias show-functions='show-functions | $PAGER'
# TODO: see if other aliases were "recursively" defined
alias show-functions='show-functions-aux | $PAGER'


# Editing and activating new settings
#
## alias do-setup="source $BIN/do_setup.sh"
alias do-setup="conditional-source $HOME/.bashrc"
alias ed-setup="em $BIN/do_setup.bash; do-setup"
## OLD: alias ed-setup-="em-nw $BIN/do_setup.bash; do-setup"
## OLD:
## alias ed-setup-nw="em-nw $BIN/do_setup.bash; do-setup"
## alias ed-full-setup="em $BIN/do_setup.sh $BIN/do_setup.bash; do-setup"
## alias ed-full-setup-="em-nw $BIN/do_setup.sh $BIN/do_setup.bash; do-setup"
# following for backward compatibility
alias do_setup='do-setup'
alias ed_setup='ed-setup'


function summarize-mail () { $GREP -h "^((From)|(Subject)|(Date)):" $HOME/mail/In | $PAGER; }
function summarize-mail- () { $GREP -h "^((From)|(Subject)|(Date)):" "$@" | $PAGER; }

# Sorting wrappers
#
## OLD: alias tab-sort="sort $SORT_COL2 -t '	'"
alias tab-sort="sort -t '	'"
alias colon-sort="sort $SORT_COL2 -t ':'"
alias gc-sort='colon-sort -rn $SORT_COL2'
alias freq-sort='tab-sort -rn $SORT_COL2'
function para-sort() { perl -00 -e '@paras=(); while (<>) {push(@paras,$_);} print join("\n", sort @paras);' $*; }

# CVS stuff
#
# CVS options used:
#  -p	output to stdout (i.e., don't update in place)
#  -d	create any directories missing from the working directory
# diff options
#  -w   ignore white space when comparing lines
#  -b	ignore changes in amount of white space
#  -B	ignore changes that just insert or delete blank lines
if [ "$INCLUDE_MISC_ALIASES" = "1" ]; then
    trace CVS stuff
    #
    function cvs- () { cvs "$@" >| /tmp/cvs_.$$ 2>&1; $PAGER /tmp/cvs_.$$; }
    function cvs-filtered () { filter=$1; shift; cvs "$@" 2>&1 >| /tmp/cvs_.$$ 2>&1; $GREP -v "$1" /tmp/cvs_.$$ | $PAGER; }
    #
    function cvs-diff () { cvs-filtered "^cvs diff: Diffing" diff -wb "$@" | $PAGER -p "^Index"; }
    alias cvs-get='cvs- update'
    alias cvs-get-read-only='cvs update -p'
    alias cvs-put='cvs- commit'
    alias cvs-log='cvs- log'
    alias cvs-status='cvs- status'
    alias cvs-update='cvs-filtered "^cvs update" update -d'
    alias cvs-update-latest='cvs-filtered "^cvs update" update -A'
    alias cvs-examine='cvs-filtered "^cvs update" -n update -d'
    alias cvs-modified='cvs- status | $GREP Modified | extract_matches.perl "File: (\S+)" | echoize'
    alias cvs-modules='cvs checkout -c'
    alias cvs-annotate='cvs- annotate'
    alias cvs-extract-all='extract_all_versions.perl -cvs'
    #
    # cvs-update-all: performs 'cvs update' grepping for conflicts and changes
    #
    function cvs-update-all () { 
        cvs update -d "$@" >| /tmp/update-$$.log 2>&1; 
        $GREP "^C" /tmp/update-$$.log >| /tmp/all-update-$$.log; 
        cat /tmp/update-$$.log >> /tmp/all-update-$$.log; 
        less -+F -+I -p "^(U|C|M|Merging|(cvs (update|server)))" /tmp/all-update-$$.log;
    }
fi

## OLD: alias echoize='perl -pe "s/\n/ /;"; echo;'

# RCS stuff
if [ "$INCLUDE_MISC_ALIASES" = "1" ]; then
    # alias get 'co'
    function get () { co -M "$@"; }
    function get-read-only () { co -p "$@"; }
    function get- () { get $*; chmod +w "$@"; }
    alias qget='get-'
    function put () { rcs -l $*; ci -u -m"." -t-"." "$@"; }
    function full-put () { rcs -l $1; ci -u -m"$2 $3 $4 $5 $6 $7 $8 $9" -t-"."; }
    function qput () { rcs -l $*; ci -u -m"." -t-"." "$@" ; chmod +w "$@"; }
    alias lock="rcs -l"
    alias put-each='foreach.sh ""'""put"' $f'"''
    alias qput-each='foreach.sh ""'""qput"' $f'"''
    alias rcs-status="rlog  -L  -l  RCS/*"
    alias rcs-synch="co -M RCS/*,v"
    function do-rcsdiff () { do_rcsdiff.sh $* >&\! rcsdiff.list; viewfile rcsdiff.list; }
fi

# File manipulation and conversions
trace File manipulation and conversions
function asc-it () { dobackup.sh $1; asc < BACKUP/$1 >| $1; }
# TODO: use dos2unix under CygWin
alias remove-cr='tr -d "\r"'
## OLD: alias alt-remove-cr='perl -0777 -pe "s/\r//g;"'
alias perl-slurp='perl -0777'
alias alt-remove-cr='perl-slurp -pe "s/\r//g;"'
function remove-cr-and-backup () { dobackup.sh $1; remove-cr < backup/$1 >| $1; }
alias perl-remove-cr='perl -i.bak -pn -e "s/\r//;"'

# Text manipulation
alias 'intersection=intersection.perl'
alias 'difference=intersection.perl -diff'
alias 'line-intersection=intersection.perl -line'
alias 'line-difference=intersection.perl -diff -line'
## OLD: function show-line () { tail +$1 $2 | head -1; }
function show-line () { tail --lines=+$1 $2 | head -1; }

# Function for extracting pattern matches from a file
# ex: extract-matches "genls (.*) Dog" dogs.cyc
function old-extract-matches () { perl -ne "while (/$1/) { printf \"%s\\n\", \$1; s/$1//; }" $2; }

alias cd-env='export PERLLIB=`pwd`:${PERLLIB}; export PATH=`pwd`:${PATH};'
function dir-env () { _dir=$1; export PERLLIB=${_dir}:${PERLLIB}; export PATH=${_dir}:${PATH}; unset _dir; }
function strip-dirs () { echo $1 | perl -pe s#$2[^:]+:?##g; }
function clear-my-env () { export PATH=`strip-dirs $PATH $HOME`; export PERLLIB=`strip-dirs $PERLLIB $HOME`; }
function clear-local-env () { export PATH=`strip-dirs $PATH /home`; export PERLLIB=`strip-dirs $PERLLIB /home`; }
function show-perl-libs () { perl -e 'print join("\n", @INC), "\n";'; }

#........................................................................
# Remote access
trace Remote access
#
function rtop () { rsh $1 top 50 | $PAGER; }
# rsh-list: show the rsh processes with just CPU through TTY fields omitted
#
# notes:
#          1         2         3         4         5         6         7         8
# 12345678901234567890123456789012345678901234567890123456789012345678901234567890
# USER       PID %CPU %MEM   VSZ  RSS TTY      STAT START   TIME COMMAND
# tomohara  2272  0.0  0.3  2808 1904 pts/0    S    Nov20   0:00 bash
# tomohara 17523  0.0  0.2  3184 1360 pts/0    R    22:10   0:00 ps auxwww
#
# NOTE: 
# - Not applied to solaris machines due to older bash not supporting for loop.
#

if [[ ("$DOMAIN_NAME" = "cs.nmsu.edu") && ("$OSTYPE" != "solaris") ]]; then
   conditional-source $BIN/rsh-aliases.bash
fi

alias ps-users='ps_mine.sh -a | $GREP -v root'
alias ps-sort='ps_sort.perl -'

#........................................................................
# alias for counting words on individual lines thoughout a file
# (Gotta hate csh)
trace line wrd count, etc. commands
function line-wc () { perl -n -e '@_ = split; printf "%d\t%s", 1 + $#_, $_;' "$@"; }
alias line-word-len='line-wc'
function line-len () { perl -ne 'printf "%d\t$_", length($_) - 1;' "$@"; }
function para-len () { perl -00 -ne 'printf "%d\t$_", length($_) - 1;' "$@"; }
alias ls-line-len='ls | line-len | sort -rn | less'

alias parse-mail="perl -Ss parse_mail.perl -batch"

alias pine-='pine -folder-collections=$PWD/\[\]'
alias pine-read-only='pine -o'

function check-class-dist () { count-it "^(\S+)\t" $1 | perl- calc_entropy.perl -; }

alias fix-dir-permissions="find . -type d -exec chmod go+xs {} \;"

alias 2bib='bibitem2bib'

# Postscript related processing
trace Postscript related processing
#
## function gv () { ghostview "$@" &  }
function condensed-print () { mpage "$@" | lpr; }
function pdf-view () { acroread "$@" & }
function pdf-print () { acroread -toPostScript < "$1" | lpr; lpq; }
## alias acroprint='pdf-print'
function ps-print () { lpr < "$1"; }
alias ps-view='gv'
## OLD: alias pv='pdf-view'
## OLD:
## function pdf-to-ascii () { ps2ascii "$1" > "$1.ascii"; }
## function all-pdf-to-ascii () { 
##     for f in *.pdf; do 
## 	echo "checking $f.ascii"; 
## 	if [ ! -e "$f.ascii" ]; then 
## 	    echo "converting $f"; 
## 	    pdf-to-ascii "$f"; 
## 	fi; 
##     done; 
## }
#
#
# v alias for view .ps or .pdf files
# NOTE: 
# TODO: account for file w/ ext; extend for other file types
#
function view-ps-or-pdf () { 
    local basename=`echo "$1" | perl -pe "s/\.[^\.]*\$//;"`; 
    if [[ (-e "$1") && ("$WINDIR" != "") ]]; then 
         start $1;  
    elif [ -e "$basename.ps" ]; then 
	 gv "$basename.ps"; 
    elif [ -e "$basename.pdf" ]; then 
	 pv "$basename.pdf"; 
    else 
	 echo "Unsupported view type in $1"; 
    fi; 
}
#
alias v='view-ps-or-pdf'
#
function ps-to-text () { base=`basename $1 .ps`; ps2ascii $1 >| $base.ascii; }
alias alt-ps-to-text='pstext.bat'


# TODO: generate aliases for .sh and .perl scripts automatically
# ls *.sh *.perl | perl -pe "s/(\w+)\.\w+/alias \1='$&'/g; s/(\w+.perl)/perl- \1/g;" >| _all_alias.list
trace extension-less shortcuts
alias convert-termstrings='perl- convert_termstrings.perl'
## alias do-diff='do_diff.sh'
alias do-rcsdiff='do_rcsdiff.sh'
alias dobackup='dobackup.sh'
## alias hotbot-freq='hotbot_freq.sh'
alias kill-em='kill_em.sh'
alias ps-mine='ps_mine.sh --filtered'
alias ps_mine='ps-mine'
alias ps-mine-='ps-mine | filter-dirnames'
alias ps-mine-all='ps-mine --all'
alias rename-files='perl- rename_files.perl'
alias rename_files='rename-files'
## OLD: alias rename-spaces='rename-files -global " " "_"'
alias testwn='perl- testwn.perl'
alias perlgrep='perl- perlgrep.perl'
alias foreach='perl- foreach.perl'

# Statistical helpers
alias bigrams='perl -sw $BIN/count_bigrams.perl -N=2'
alias unigrams='perl -sw $BIN/count_bigrams.perl -N=1'
alias word-count=unigrams

# Lynx stuff
function old-lynx-dump () { echo "$1"; lynx -width=128 -dump "$1"; }
function lynx-dump () { echo "$1" >| $2; lynx -width=128 -dump -nolist "$1" >> $2; $PAGER $2; }
if [ "$BAREBONES_HOST" = "1" ]; then export lynx_width=0; fi

# Lisp stuff
function acl-apropos() { $GREP -i "$@" $HOME/info/online-reference-works/clman.synopsis; }
function clisp-apropos() { $GREP -i "$@" $HOME/info/online-reference-works/clisp-apropos.list; }

# OLD: CSH-like aliases
#
## function setenv () { export $1="$2"; }
## alias unsetenv='unset'
## function cond-setenv { if [ "`printenv $1`" = "" ]; then export $1=$2; fi; }

## OLD: alias unlimit=ulimit

#------------------------------------------------------------------------
# Bilingual dictionary access
trace bilingual dict support
## OLD: multiling_dir=$HOME/multilingual
multiling_dir=${MULTILINGUAL_DIR:-"$HOME/multilingual"}
cond-setenv SPANISH_DICT $multiling_dir/spanish/spanish_english.dict
cond-setenv SPANISH_IRREG_DICT $multiling_dir/spanish/spanish_irregular.dict
cond-setenv ENGLISH_DICT $multiling_dir/spanish/english_spanish.dict
# NOTE: grep flags file UTF-8 indicator at top as binary
dict_grep="zegrep --ignore-case --text"
dict_word_grep="$dict_grep --word-regexp"
function spanish-lookup- () { $dict_grep "$@" $SPANISH_DICT | less-pager -S; }
## OLD: function old-spanish-lookup () { $dict_grep "((^$@)|(	$@))\b" $SPANISH_DICT; }
# Note: spanish-lookup only looks for entry words (i.e., accent-less key or entry word)
# whereas spanish-lookup- checks entire entry. Likewise for english-lookup[-]
# example: cena<TAB>cena<TAB>f. supper. 2 la Santa Cena, the Last Supper.
function spanish-lookup () { $dict_grep "((^$@)|(	$@))[,	]" $SPANISH_DICT; }
#
function english-lookup- () { $dict_grep "$@" $ENGLISH_DICT; }
function english-lookup () { $dict_grep "((^$@)|(	$@))\b" $ENGLISH_DICT; }
alias english-='english-lookup-'
alias english='english-lookup'
alias eng='english'
alias eng-='english-'

function add-multilingual-dicts() {
    ## OLD: cond-setenv SPANISH_IRREG_DICT $multiling_dir/spanish/spanish_irregular.dict;
    ## OLD: cond-setenv ENGLISH_DICT $multiling_dir/spanish/english_spanish.dict;
    ## TODO: reword lang-lookup- to lang-lookup-loose
    cond-setenv _FRENCH_DICT $multiling_dir/French/french_english.dict;
    cond-setenv GERMAN_DICT $multiling_dir/German/german_english.dict;
    cond-setenv ITALIAN_DICT $multiling_dir/Italian/italian_english.dict;
    cond-setenv MULTI_DICT $multiling_dir/Multi/multilingual.dict;
    #
    function german-lookup- () { $dict_grep "$@" $GERMAN_DICT; };
    function german-lookup () { $dict_word_grep ^"$@" $GERMAN_DICT; };
    alias german-='german-lookup-';
    alias german='german-lookup';
    #
    function french-lookup- () { $dict_grep "$@" $_FRENCH_DICT; };
    function french-lookup () { $dict_word_grep ^"$@" $_FRENCH_DICT; };
    alias french-='french-lookup-';
    alias french='french-lookup';
    #
    function italian-lookup- () { $dict_grep "$@" $ITALIAN_DICT; };
    function italian-lookup () { $dict_word_grep ^"$@" $ITALIAN_DICT; };
    alias italian-='italian-lookup-';
    alias italian='italian-lookup';
    #
    ## OLD: function latin-lookup() { lynx -dump "http://catholic.archives.nd.edu/cgi-bin/lookup.pl?stem=$1&ending=" | $PAGER; };
    ## OLD: function latin-lookup-() { lynx -dump "http://catholic.archives.nd.edu/cgi-bin/lookdown.pl?$1" | $PAGER; };
    function latin-lookup-() { lynx -dump "http://www.archives.nd.edu/cgi-bin/lookdown.pl?$1" | $PAGER; };
    ## OLD: alias latin='latin-lookup';
    alias latin-='latin-lookup-';

    function multi-lookup () { $dict_word_grep ^"$@" $MULTI_DICT; }
    function multi-lookup- () { $dict_grep "$@" $MULTI_DICT; }
    alias multi='multi-lookup'
    alias multi-='multi-lookup-'
}    
if [ "$OSTYPE" != "cygwin" ]; then
    add-multilingual-dicts
fi
alias spanish-='spanish-lookup-'
alias spanish='spanish-lookup'
alias sp=spanish
## TODO: reword sp- to sp-loose
alias sp-=spanish-
alias pp-spanish='pp_spanish_entry.perl'
## TODO: reword sp-pp- to sp-pp-aux
function sp-pp- () { sp $@ | pp-spanish; }
function sp-pp-loose () { sp- $@ | pp-spanish; }
function sp-pp () { sp-pp- $1 >| $1.pp; $PAGER $1.pp; }

function spanish-trans-phrase () { phrase=$1; shift; echo "$phrase" | $multiling_dir/Spanish/qd_trans_spanish.perl "$@" -; }
alias trans-spanish-phrase='spanish-trans-phrase'
alias trans-sp='qd_trans_spanish.perl -maxlen=256 -redirect -'
alias qd-trans-sp='trans-sp'
alias old-qd-trans-sp='qd_trans_spanish.perl -redirect -'

# Unicode support
#
## OLD: function show-unicode-code-info() { perl -CIOE   -e 'use Encode "encode_utf8"; print "char\tord\toffset\tencoding\n";'    -ne 'chomp;  printf "%s: %d\n", $_, length($_); foreach $c (split(//, $_)) { $encoding = encode_utf8($c); printf "%s\t%04X\t%d\t%s\n", $c, ord($c), $offset, unpack("H*", $encoding); $offset += length($encoding); }   $offset += length($/); print "\n"; ' < $1; }

#------------------------------------------------------------------------
# Arabic text processing
if [ "$DOMAIN_NAME" = "cs.nmsu.edu" ]; then
   alias remove-arabic-diacritic='perl -pe "s/[\xF0-\xFF]//g;"'
   export AMORPH_COMBINED=/home/grad4/tomohara/TOM/english-arabic/combined/morph
fi

#------------------------------------------------------------------------
# Unix aliases
trace Unix aliases

## alias cyc-groups='ypcat group'
function group-members () { ypcat group | $GREP -i $1; }
# TODO: check if _make.log exists prior to move
function do-make () { /bin/mv -f _make.log _old_make.log; make "$@" >| _make.log 2>&1; $PAGER _make.log; }
## alias do-gzip='nice -19 gzip -rfv . >| ../gzip_`basename $PWD`.log 2>&1; $PAGER ../gzip_`basename $PWD`.log'
#
# $ man merge
#   merge [ options ] file1 file2 file3
#   merge  incorporates all changes that lead from file2 to file3 into file1.
# NOTE: merge -p mod-file1 original mod-file2 >| new-file
alias merge='echo "do-merge MODFILE1 OLDFILE MODFILE2 > NEWFILE"'
alias do-merge='/usr/bin/merge -p'
#
## alias old-which='echo "note: using TYPE rather than WHICH"; /usr/bin/which'
## OLD: alias which='/usr/bin/which'
## alias do-which='/usr/bin/which'
#
# full-dirname(filename): returns full path od directory for file
#
function full-dirname () { local dir=`dirname $1`; case $dir in .*) dir="$PWD/$1";; esac; echo $dir; }
# 
function rpm-extract () { rpm2cpio $1 | cpio --extract --make-directories; }
#
alias dump-url='wget --recursive --relative'
#
alias gtime='/usr/bin/time'

## alias slackware-version='cat /etc/slackware-version'
alias redhat-version="/etc/redhat-release"
alias system-status='system_status.sh -'
function apropos-command () { apropos $* 2>&1 | $GREP '(1)' | $PAGER; }
function split-tokens () { perl -pe "s/\s+/\n/g;" "$@"; }
alias tokenize='split-tokens'
function perl-echo () { perl -e 'print "'$1'\n";'; }
## function perl-printf () { perl -e 'printf "$1\n", @_[1..$#_];';  }
##
## function perl-printf () { perl -e "printf \"$1\"", qw/$2 $3 $4 $5 $6 $7 $8 $9/; }
function perl-printf () { perl -e "printf \"$1\", $2;"; }
##
## TODO: get folllowing to work for 'perl-print "how now\nbrown cow\n"'
## function perl-print () { perl -e "print $1"; -e 'print "\n";'; }
function perl-print () { perl -e "printf \"$1\";" -e 'print "\n";'; }
function perl-print-n () { perl -e "printf \"$1\";"; }

# Unix/Win32 networking aliases
if [ "$OSTYPE" != "cygwin" ]; then alias ipconfig=ifconfig; fi
alias set-display-local='export DISPLAY=localhost:0.0'

# Bash aliases
alias bash-trace-on='set -o xtrace'
alias bash-trace-off='set - -o xtrace' ## ???
function trace-cmd() { bash-trace-on; eval "$@"; bash-trace-off; }
## ALT: function trace-cmd() { bash-trace-on; @_; bash-trace-off; }
alias cmd-trace='trace-cmd'

## OLD:
## # Compressing/uncompressing a subdirectory tree (ignoring symbolic links) 
## # TODO: write scripts for this (given the comlexity)
## # TODO: don't uncompress compressed archives (.tar.gz files)
## function compress-dir() { log_file=/tmp/compress_`basename "$1"`.log ; find $1 \( -not -type l \) -exec gzip -vf {} \; >| "$log_file" 2>&1; $PAGER "$log_file"; }
## # NOTE: zipped archived are kept compressed
## function uncompress-dir() { log_file=/tmp/uncompress_`basename "$1"`.log ; find $1 \( -not -type l \) \( -not -name \*.tar.gz \) -exec gunzip -vf {} \; >| "$log_file" 2>&1; $PAGER "$log_file"; }
## alias compress-cd='compress-dir $PWD'
## alias uncompress-cd='uncompress-dir $PWD'

alias old-count-exts='ls | count-it "\.[^.]*\w" | sort $SORT_COL2 -rn | $PAGER'
function count-exts () { ls | count-it '\.[^.]+$' | sort $SORT_COL2 -rn | $PAGER; }

alias kill-netscape='kill_em.sh -p netscape; /bin/rm -v -f $HOME/.netscape/lock'
alias kill-cmucl='kill_em.sh -p cmucl'
alias kill-sleep='kill_em.sh sleep'
## function kill-gnome () { foreach.sh 'kill_em.sh $f' gnome magicdev panel xscreensaver cdplayer_applet  enlightenment asclock_applet ical gtcd sproingies  }

# Aliases for working with Perlfect indexing system
trace indexing commands
conditional-source $BIN/indexing-aliases.bash

#-------------------------------------------------------------------------------
# TeX stuff
# TODO: place in external script
trace TeX stuff

alias do-tex='do_tex.sh'
## alias tex-it='do_tex.sh --clean --biblio `basename $PWD`.tex 2>&1 | $PAGER'
## alias retex-it='do_tex.sh --biblio `basename $PWD`.tex 2>&1 | $PAGER'
# TODO: have bash function for setting and resetting tracing
# TODO: figure out how to get the 'set +o xtrace' trace not to show up
## function run-do-tex () { base=`basename $PWD`; set -o xtrace; ( do_tex.sh $* $base.tex) 2>&1 | $PAGER; set +o xtrace > /dev/null 2>&1 }
function run-do-tex () { ( set -o xtrace; do_tex.sh $*; set +o xtrace) 2>&1 | $PAGER; }
alias tex-file='run-do-tex --biblio --check-vbox'
alias clean-tex-file='tex-file --clean'
function tex-dir () { tex-file "$@" `basename $PWD`; }
function clean-tex-dir () { tex-file --clean "$@" `basename $PWD`; }
alias tex-it='run-do-tex --clean --biblio'
alias retex-it='run-do-tex --biblio'
#
function spell-tex () { do_tex.sh $1; dvi2tty -w 132 $1.dvi | perl -p -e "s/\*\n//; s/^ \*//; s/\-\n//;" >| $1.tty; perl- spell.perl -spell_file=$1.spell $1.tty | sort | $PAGER; }
function spell-tex- () { dvi2tty -w 132 $1.dvi >| $1.tty; perl- spell.perl -spell_file=$1.spell $1.tty | sort | $PAGER; }
## OLD: export LATEX2HTML_OPTIONS='-split 4 -link 2 -address "" -info ""'

# Linux stuff
alias configure='./configure --prefix ~'
alias pp-xml='xmllint --format'
alias check-xml='xmllint --noout --valid'

# NMSDF/Military stuff
function gr-army-acronym () { gr -w -i "$@" $TOMAS/military/manuals/AR310_50-army-abbreviations.txt; }
function gr-army-acronym- () { $GREP "$@" $TOMAS/military/manuals/AR310_50-army-abbreviations.txt; }

# SSH-related aliases
scpcmd='scp -p'
function cs-download-dir () { _dir="$1"; shift;_files=`echo " $@ " | perl -pe 's# (\S+)#tomohara\@colossus.cs.nmsu.edu:temp/$1 #g;'`; $scpcmd $_files $dir; echo "downloaded to $dir"; }
alias cs-download='cs-download-dir ~/xfer'
alias cs-download-here='cs-download-dir .'

#------------------------------------------------------------------------

## OLD:
## # GraphLing settings
## if [ "$DOMAIN_NAME" = "cs.nmsu.edu" ]; then
##     trace GraphLing settings
##     # note: this sets base for some other utilities (e.g., GRAPHLING_HOME)
##     # see do_setup.sh
##     ## alias graphling-env='source $UTILITIES/setenv.sh'
##     alias graphling-path='export PATH=$GL_UTILITIES:$PATH; export PERLLIB=$GL_UTILITIES:$PERLLIB;'
##     alias graphling-debug='export DEBUG_LEVEL=5; export GRAPHLING_TRACE=1;'
##     unset GRAPHLING_SETENV
##     function check-wsd-errors () { (log_file=$1/$1-*.log; echo $log_file; check_errors.perl -skip_warnings -context=5 $log_file) 2>&1 | $PAGER; }
##     function check-all-wsd-errors () { (log_file=$1/$1-*.log; echo $log_file; check_errors.perl -skip_warnings=0 -context=5 $log_file) 2>&1 | $PAGER; }
##     alias check-accuracy='grep total [A-Z]*/SAMPLEALL.REPORT.SUMMARY | extract_matches.perl -replacement="\L\1\t\2" "^([A-Z]+)\S+\s+(\S+)"'
##     function compare-accuracy () { perl- paste.perl -keys  $1 $2 | $GREP -v 'n/a' | perl- sum_file.perl -labels -diff -f1=2 -f2=3; }
##     alias weka-env='export CLASSPATH=$GL_TOOLS/WEKA/weka-3-2-3/weka.jar'
## 
##     alias kill-graphling='kill_em.sh --graphling'
##     function gr-all-util () { gr $* $GL_UTILITIES/*.perl $GL_UTILITIES/*.prl $GL_UTILITIES/*.sh; }
##     function gr-util () { gr $* $GL_UTILITIES/*.perl; }
##     alias gr-out-of-mem='grep -i "out of memory" *.log'
## fi

#------------------------------------------------------------------------
# WordNet settings
trace WordNet settings

alias xw='xwordnet &'
if [ "$DOMAIN_NAME" = "cs.nmsu.edu" ]; then
   export WN15=$GL_TOOLS/WORDNET-1.5
   export WN16=$GL_TOOLS/WORDNET-1.6
   export WN17=$GL_TOOLS/WORDNET-1.7
   export WN171=$GL_TOOLS/WORDNET-1.7.1
   ## conditional-source $WN171/wn171_setenv.bash
   ## export WN=$WN171
   ## export WORDNET=$WN171
fi

# a variety of WordNet aliases
#
## export wn=wn.sh
if [ "$wn" = "" ]; then export wn=$WNHOME/bin/$OSTYPE/wn; fi
#
# WN interface options:
#    -g   Display gloss
#    -o   Display synset offset
#    -s   Display sense numbers in synsets
## export wn_options="-g -s -o"
export wn_options="-g -s"
## alias wn=$wn
function wn- () { "$wn" "$*" -synsn -synsv -synsa -synsr $wn_options | $PAGER_CHOPPED; }
function wn-opt () { "$wn" "$@" -synsn -synsv -synsa -synsr $wn_options | $PAGER_CHOPPED; }
## alias wn='wn-'
function wn-v () { "$wn" "$*" -synsv $wn_options | $PAGER_CHOPPED; }
function wn-v-opt () { "$wn" "$@" -synsv $wn_options | $PAGER_CHOPPED; }
function wn-n () { "$wn" "$*" -synsn $wn_options | $PAGER_CHOPPED; }
function wn-n-opt () { "$wn" "$@" -synsn $wn_options | $PAGER_CHOPPED; }
function wn-full () { "$wn" "$*" -hypen -hypev -synsa -synsr $wn_options | $PAGER_CHOPPED; }
function wn-full- () { "$wn" "$*" -treen -treev -synsa -synsr $wn_options | $PAGER_CHOPPED; }

function wn-index-gr () { $GREP -i -h "$2" $3 $4 $5 $6 $7 $8 $9 "$WNSEARCHDIR/index.$1"; }
alias wn-n-gr='wn-index-gr noun'
alias wn-v-gr='wn-index-gr verb'
alias wn-adj-gr='wn-index-gr adj'
alias wn-adv-gr='wn-index-gr adv'
## OLD: function wn-gr () { $GREP -i -h "$@" "$WNSEARCHDIR/index.[nva]*"; }
## OLD: function wn-data-gr () { $GREP -i -h "$@" "$WNSEARCHDIR/data.*"; }
function wn-gr () { $GREP -i -h "$@" "$WNSEARCHDIR"/index.[nva]*; }
function wn-data-gr () { $GREP -i -h "$@" "$WNSEARCHDIR"/data.*; }
alias wn-def-gr='wn-data-gr'

# MSVC stuff
alias vcvars='source $BIN/vcvars.sh'

## OLD:
## # ClearCase stuff
## #
## # TODO
## # - add _new_dir hack to .bashrc in order to fource cd change
## # try using cleartool -exec option to set the view
## # TODO: function sv-rware() { sv $1; cd /vobs/rware; }
## # $ cleartool help setview
## # Usage: setview [-login] [-exec command-invocation] view-tag
## #
## # function sv-rware() { echo "TODO: cd /vobs/rware"; sv $1; }
## #
## if [ "$INCLUDE_MISC_ALIASES" = "1" ]; then
##     function cc-errors () { (check-errors -verbose "$@"; check-all-errors -verbose "$@"; echo -n "Log: "; head -10000000 "$@" /dev/null;) 2>&1 | less; }
##     #
##     if [ "$OSTYPE" != "cygwin" ]; then
##         function sv-rware() { echo "Issue:"; echo "cd /vobs/rware"; cleartool setview $1; }
##         #
##         alias rware='sv-rware tohara'
##         alias rware1='sv-rware tohara1'
##         alias ct=cleartool
##         alias sv='ct setview'
##         alias cc='ct'
##         alias cc-help='ct help'
##         alias cc-config='ct catcs'
##         # NOTE: -pre works OK for checked-out items, but unintuitively shows difference
##         # for those not checked out (i.e., not always comparison of local version vs. master as in cvs diff).
##         alias cc-diff='ct diff -gra -pre'
##         alias cc-diff-='ct diff -diff -pre -options "-blank_ignore"'
##         alias cc-tree='ct lsvtree -g'
##         alias cc-ci='ct ci'
##         alias cc-co-reserved='ct co -c test'
##         alias cc-unco='ct unco'
##         alias cc-co-unreserved='ct co -unreserved -c test'
##         alias cc-co='cc-co-unreserved'
##         alias cc-add='cc mkelem'
##         alias cc-add-dir='cc-add -eltype directory'
##         alias cc-checkouts-full='ct lsco -avobs -cview'
##         #
##         ## function cc-checkouts() { cc-checkouts-full | extract_matches.perl '/vobs/rware/([^"]+)' -; }
##         alias cc-checkouts-rware='cc-checkouts-full | extract_matches.perl "/vobs/rware/(\S+). from"'
##         alias cc-checkouts-ce='cc-checkouts-full | extract_matches.perl "/vobs/ce/(\S+). from"'
##         alias cc-checkouts-all='cc-checkouts-full | extract_matches.perl "/vobs/(\S+). from"'
##         alias cc-checkouts-here='cc-checkouts-full | extract_matches.perl "$PWD/(\S+). from"'
##         alias fix-bin-scripts='chmod go-w ~/bin/*'
##         alias fix-permissions='chmod ugo-st'
##         alias cc-checkouts-='fix-bin-scripts; cc-checkouts'
##         #
##         function old-cc-errors () { (chmod go-w ~/bin/*; echo -n "Errors: "; check-errors -verbose "$@"; echo -n "Warnings: "; check-all-errors -verbose "$@"; echo -n "Log: "; head -10000000 "$@" /dev/null;) 2>&1 | less; }
##         alias cc-errors-='fix-bin-scripts; cc-errors'
##         #
##         function cc-all-diffs () { cc-checkouts-here | foreach.perl -trace 'cleartool diff -diff_format -pre $f' - >| _diff.list 2>&1; less _diff.list; }
##         #
##         function cc-bad-permissions () { ls -alR . | perlgrep "^[d\-]\S+[tSs]"; }
##         #
##         alias conv-setup='source ~/unix-bin/convera-setup.bash'
##         #
##         ## TODO: conv-setup
##         #
##         alias view-system-log='sudo emacs --no-windows /var/log/messages'
##     fi
## fi

## MISC:
## # GNU C compiler aliases
## if [ "$INCLUDE_MISC_ALIASES" = "1" ]; then
##     if [ "$HOST" != "arahomot" ]; then
##         trace compiler aliases
##         # gcc options:
##         # 	-g	produce debugging information
##         #	-pedantic	Issue all the  warnings  demanded  by  strict  ANSI standard  C; reject all programs that use forbidden extensions.
##         #	-Wall	issue all types of warning
##         #	-O	optimize (needed for catching unitialized variables -Wuninitialized)
##         ## OLD: function compile () { gcc -pedantic -g -Wall -O -o `basename $1 .c` $1; }
##         function compile () { gcc -g -Wall -O -o `basename $1 .c` $1; }
##         function anal-compile () { gcc -pedantic -g -Wall -O -o `basename $1 .c` $1; }
##         function anal-compile++ () { g++ -pedantic -include cstdlib -g -Wall -O -o `basename $1 .cpp` $1; }
##         function compile++ () { g++ -include cstdlib -g -Wall -O -o `basename $1 .cpp` $1; }
##         function preprocess () { gcc -E -o `basename $1 .cpp`.pp "$1"; }
##         alias debug-compile='compile'
##         function release-compile () { gcc -pedantic -Wall -O4 -o `basename $1 .c` $1; }
##         function math-compile () { gcc -pedantic -lm -g -Wall -O -o `basename $1 .c` $1; }
##     fi
## fi

#........................................................................
# Miscellaneous local environment helpers
trace misc local helpers

## OLD:
## if [ "$DOMAIN_NAME" = "cs.nmsu.edu" ]; then
##     # CS 167/467 stuff
##     # TODO: define alias for invoking Netscape composed with course page index
##     alias print-course-page='echo $HOME/html/cs167-467/index.html'
##     
##     # CS Stuff
##     function print () { a2ps $1 | lpr | lpq; }
##     function lpq-all () { foreach.perl 'echo \"\"; lpq -Plex$f' draft fine dual quad; echo ""; }
##     # TODO: use a function for lprm-all as done for lpq-all
##     alias lprm-all="foreach.perl 'lprm -Plex\$f' draft fine dual quad"
##     function set-printer () { export PRINTER=$1; lpq; }
##     alias lexfine='set-printer lexfine'
##     alias lexquad='set-printer lexquad'
##     alias lexdraft='set-printer lexdraft'
##     alias lexdual='set-printer lexdual'
##     alias swap-caps='xmodmap $HOME/.xmodmap_caps'
##     alias soffice='/local/Office52/program/soffice'
## 
##     function remote-processes () { foreach.perl -trace -remote -busy_load=0 'ps_mine.sh '; }
##     function remote-processes-logged () { remote-processes >| $HOME/temp/remote_processes.log 2>&1; $PAGER $HOME/temp/remote_processes.log; }
##       
##     function find-TOM-file () { $GREP -i "(:\$|$1)" $HOME/TOM/.ls-alR.list | $PAGER -p $1; }
##     function find-OTHER-TOM-file () { $GREP -i "(:\$|$1)" $OTHER_TOM/.ls-alR.list | $PAGER -p $1; }
##     function find-graphling-file () { $GREP -i "(:\$|$1)" /home/graphling/ls-alR.list | $PAGER -p $1; }
## 
##     # CRL Stuff
##     alias crl-telnet='telnet kimmerion.nmsu.edu'
##     
##     # Pitt Stuff
##     alias pitt-telnet='ssh -l tomohara gomez.cs.pitt.edu'
##     
##     # Internet aliases
##     alias show-ip-address='host $HOST'
## 
##     # Cyc stuff
##     alias open-cyc-setup='conditional-source $BIN/opencyc_setup.bash'
##     alias cyc-setup='conditional-source $BIN/cyc_setup.bash'
##     export OPENCYC=$GL_TOOLS/OpenCyc/opencyc-0.7.0
##     export RKF_CYC=$TOM/cyc-home
##     export MASS_COUNT=$TOM/mass-count-experiments
##     
##     # WWW Stuff
##     alias add-htpasswd='/home/httpbin/htpasswd -m $HOME/html/.htpasswd'
## fi

# Optional end tracing
trace 'out do_setup.bash'
