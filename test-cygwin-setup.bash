# cygwin-setup.bash: Setup TPO's bash environment for use under CygWin.
#
# Originally used to mount the Dos drives as /<letter (e.g., /c)
#    mount options:
#      --executable:  treat all files under mount point as executables
#      --force:       don't warn about missing mount point directories
#      --binary:      text files are equivalent to binary files (newline = \n)
# Later extended with XP-specific overrides to settings in do_setup.bash.
#
# NOTE:
# - Invoked via ~/.bashrc and ~/.bash_profile.
#


# Define function for startup tracing
#
# NOTES:
# - The STARTUP_TRACING and CONSOLE_TRACING env. vars affect tracing.
# - See C:\cartera-de-tomas\bin\cygwin-trace.bat for how they can be set.
#   This is intended as a target for a Windows shortcut.
#
# TODO:
# - Fix stupid winpath/bash-word-splitting problems (e.g., in em-cyg alias).
#
if [ -e ~/bin/startup-tracing.bash ]; then source ~/bin/startup-tracing.bash; fi

startup-trace in cygwin-setup.bash

# Fixup for domain name setup
if [ $USERDOMAIN = "TPO-PORTATIL" ]; then export USERDOMAIN=NONESUCH; fi

# Note: binmode is used so that CR's are not converted into CR/NL sequences.
# That is, the Unix convention is used, even for the representation on disk.
export mount_options="--binary --force --executable"
alias my-mount='mount $mount_options'
function dos-mount () { if [ ! -e /$1 ]; then my-mount $mount_options "$1:\\" /$1; fi; }
dos-mount c
case $USERDOMAIN in
    NONESUCH) dos-mount r;;
    CONVERA) dos-mount m; dos-mount v;;
esac

export WINDRIVE=c
export CYGDRIVE=c

# Create mount point 'symbolic links'
# NOTE: unix symbolic links are not used since Emacs doesn't understand
# the .lnk files used under Win32
#
my-mount "${WINDRIVE}:\\Documents and Settings\\$USERNAME" /my-data
my-mount "${WINDRIVE}:\\Documents and Settings\\$USERNAME\\My Documents" /my-docs
my-mount "${WINDRIVE}:\\Documents and Settings\\$USERNAME\\Desktop" /desktop
my-mount "${WINDRIVE}:\\cartera-de-tomas\\bin" /my-bin

# Convera links
if [ $USERDOMAIN = "CONVERA" ]; then
    # TODO: resolve problem with execute mode on network drives
    my-mount "${WINDRIVE}:\\Documents and Settings\\$USERNAME\\bin-copy" /my-bin
    my-mount "V:\\tohara" /vobs
    ## TODO: my-mount '/my-docs/Test Documents' /test-docs
fi

# Show optional path modification tracing (here and below)
startup-trace "0. PATH=$PATH"

# Path and Perl lib setup
# NOTES:
# - the existing CygWin path (i.e., in $PATH already) generally is appended
# to rather than prepended to avoid conflicts with older unix-like
# utilities (e.g., c:\bin\less).
# - default path dirs put at end (e.g., so that 
#
export MYBIN=/my-bin
export PERLLIB=$MYBIN:$PERLLIB
## export PATH=$PERLLIB:/c/mybin:/c/bin:"/$WINDRIVE/Program Files/Misc:/$WINDRIVE/Program Files/Java/jdk1.5.0/bin:/c/Program Files/Apache Software Foundation/apache-ant-1.6.2/bin:$PATH"
#
# Append misc. directories to end (e.g., utilities with better CygWin version)
# NOTES:
# - /c/bin is mainly for win32 executables (from elsewhere) and also has some
# scripts (eg, updatedsc.pl). 'E:\Program Files\Support Tools contains tools
# from XP's resource kit.
# - /c/mybin and /c/bin contain old Unix style programs for Windows, so 
# these need to be at the end of the path to avoid conflicts
#
export PATH=$PATH:"/c/mybin:/c/bin:/$WINDRIVE/Program-Misc"
#
startup-trace "1. PATH=$PATH"
# Prepend more important directories to front
# NOTES:
# - ~/bin (ie, /f/cartera-de-tomas/unix-bin) is mirror of scripts in CS
# account, which represent the most up-to-date version; /c/mybin contains
# windows-based scripts along with some of the unix-bin scripts;
# - Sun's Java version 1.5 overrides Microsoft's version (e.g.,  c:\windows\system32).
#
## OLD:
## if [ "$USERDOMAIN" = "CONVERA" ]; then
##     export PATH=$MYBIN:"/$WINDRIVE/Program Files/Java/jdk1.5.0/bin":$PATH
## else
##     export PATH=$MYBIN:"/$WINDRIVE/Program Files/Java/jdk1.6.0/bin":$PATH
## fi
## TEST: export PATH=$MYBIN:"/$WINDRIVE/Program Files (x86)/Java/jdk1.6.0_27/bin":/$WINDRIVE/Program-Misc/apache-ant-1.7.1:$PATH
## NOTE: JDK and ant directories copied from /c/Program Files (x86)/java with release number dropped (e.f., jdk1.6.0_27 to jdk-1-6
export PATH=$MYBIN:"/$WINDRIVE/Program-Misc/jdk-1-6/bin":/$WINDRIVE/Program-Misc/apache-ant-1-7/bin:$PATH

## export PATH=$PATH:"/$WINDRIVE/Program Files/Java/j2re1.4.0_01/bin":"/$WINDRIVE/Program Files/Support Tools"
#
startup-trace  "2. PATH=$PATH"

# Setup other path-like variables
#
## export TEXINPUTS=.:~/latex:/usr/share/texmf/tex/latex/base
## export TEXINPUTS=.:~/latex:/usr/share/texmf/tex/latex/base:/usr/share/texmf/tex/latex/psnfss:/usr/share/texmf/tex/latex/graphics
## TODO: export TEXINPUTS=.:$HOME/latex:$LATEX


# Cygwin specific stuff
export OSTYPE=cygwin
alias cygwin-setup="source ~/cygwin-setup.bash"
alias fix-startup-scripts='~/bin/remove_carriage_returns.perl ~/*setup*.bash ~/bin/*setup*.bash'
alias cygwin-startup='cygwin-setup'
alias cyg-setup='cygwin-setup'
function cygwin-proper-setup () { BAREBONES_SHELL=1; cygwin-setup; BAREBONES_SHELL=0; }

alias show-display-export='lynx -dump http://192.168.1.1/index.html | extract_matches.perl -replacement="export DISPLAY=\1:0.0" "NAT IP Address: (\S+)"'
alias show-cs-display-export='ipconfig | extract_matches.perl -replacement="export DISPLAY=\1:0.0" "IP Address.*: (\d+.\d+\.\d+\.\d+)"'
alias display-export=show-display-export
alias home-display=show-display-export
alias display-cs-export=show-cs-display-export
alias cs-export=show-cs-display-export
## alias show-cs-display-export='echo export DISPLAY=128.123.63.127:0.0'
#
# note: the use of & is leading to a strange problem with logout being invoked occasionally
## function wd () { windiff `echo $* | perl -pe 's#^/(\w)/#/\1:#g; s#/\s*$##g;'` & }
function wd () { windiff `echo ' ' $* | perl -pe 's# /(\w)/# \1:/#g; s#/\s*$##g;'`; }
function new-wd () { windiff `echo ' ' "$@" | perl -pe 's#([ \"])/(\w)/#\1\2:/#g; s#/\s*$##g;'`; }
function cyg-diff() { cygwin-tkdiff.sh "$@" & }
function cyg-rcsdiff() { co -p "$1" >| $TEMP/$1; cygwin-tkdiff.sh "$1" $TEMP & }

# Win32 helper functions
#
## # NOTE:
## # start-win32 relies upon Win32 version of start.exe from Win98 (in /c/BIN)
## # since XP start is built into the command interpretter (cmd.exe)
## #
## function start-win32 () { start "$@" ; cd .; }
#
alias start-win32='cygstart'
alias start='start-win32'
# NOTE: winpath output quotes files with embedded spaces
function winpath () { cygpath.exe -wa "$@" | perl -pe 's/^(.* .*)$/"$1"/g;'; }
alias winpath-this-dir='winpath $PWD'
function start-win32- () { local path=`winpath "$1"`; start-win32 "$path"; }
## function explore-dir () { start-win32 explorer `cygpath -w "$1"`; }
function explore-dir () { local dir="$1"; if [ "$dir" = "" ]; then dir="."; fi; start-win32 explorer `cygpath -w "$dir"`; }
alias explore-this-dir='explore-dir "$PWD"'
#
function dos-url-path () { cygpath -wa "$1" | perl -pe 's@\\@/@g; s@^@file:///@;'; }
function firefox () { start firefox -new-window `dos-url-path "$1"`; }
alias start-firefox='firefox'
#
function ie () { start iexplore `dos-url-path "$1"`; }
alias start-ie='ie'
#
function foxit () { start 'C:\Program Files\Foxit Software\Foxit Reader\Foxit Reader.exe' `winpath "$@"`; }

# Setup HOME and WIN32HOME directories (for CygWin and GNU-ish Win32 programs)
# TODO: rename WIN32HOME to avoid possible confusion with WINDIR
if [ "$HOME" = "/" ]; then export HOME=/c/cartera-de-tomas; fi
export WIN32HOME=`winpath $HOME`

# Other Windows-related settings
# NOTE" These must be quoted when used with commands (e.g., 'copy nifty-script.bat "$SENDTO"')
export MYDATA="${WINDRIVE}:"'\Documents and Settings\'"$USERNAME"
export MYDOCS="$MYDATA\My Documents"
export SENDTO="$MYDATA\SendTo"

# XP/CygWin
alias check-disk='chkdsk /f c:'
## alias restart-computer='shutdown --reboot 5'
alias reboot-computer='shutdown --reboot 5'

# WordNet
export wn=/usr/bin/wn
export WNSEARCHDIR=/usr/lib/wnres/dict
if [ $USERDOMAIN = "NONESUCH" ]; then
    export wn="${WINDRIVE}:"'\Program-Misc\WordNet\2.1\bin\wn.exe'
    export WNSEARCHDIR="${WINDRIVE}:"'\Program-Misc\WordNet\2.1\dict\'
fi

# XP
alias check-disk='chkdsk /f c:'
alias winword-read-only='start winword /Mreopen_readonly'
function msword() { start winword `winpath "$@"`; }
alias winword-regular=msword

# Bash
# Predefine LINES for use in h alias for history 
# TODO: use resize command (after fixing problem in batch mode)
if [ "$LINES" = "" ]; then export LINES=52; fi

#------------------------------------------------------------------------
# Get main settings from do_setup.bash

## # Set remapped GraphLing path (via GraphLing symbolic link)
## export GRAPHLING_HOME=/t/GRAPH_LING
export GRAPHLING_HOME=/home/graphling
export TOOLS=$GRAPHLING_HOME/TOOLS
export UTILITIES=$GRAPHLING_HOME/UTILITIES

# UNDER_EMACS: Special environment variable for handling Emac's problems
# For example, this is used to avoid setting xterm title so that the
# control sequence doesn't show up in the buffer
# See .emacs for UNDER_EMACS definition
if [ "$UNDER_EMACS" = "" ]; then export UNDER_EMACS=0; fi

# Get other settings (mainly command aliases) from do_setup.bash
if [ "$BAREBONES_SHELL" != "1" ]; then source /my-bin/do_setup.bash; fi

startup-trace "3. PATH=$PATH"

#------------------------------------------------------------------------
# Post-hoc changes for do_setup.bash
#
# NOTE:
# - this addresses differences in file specifications, etc. due to running
#   under Windows (via CygWin)
#
# TODO:
# - integrate this into do_setup.bash with appropriate conditionalization
#

# Set TEMP to /e/temp
# NOTE: now also set in .bashrc_profile which is executed prior to this
if [ "$TEMP" = "" ]; then export TEMP=/$WINDRIVE/temp; fi

# CSH-style setenv command
function setenv () { export $1=$2; }
function cond-setenv { if [ "`printenv $1`" = "" ]; then export $1=$2; fi; }

# TODO: fix problem with do_setup alias being overridden via 'do_setup' invocation
# alias do-setup='cygwin-setup; source /my-bin/do_setup.bash'
alias do-setup='cygwin-setup'
alias do-setup-='source /my-bin/do_setup.bash'
alias ed-setup='em  ~/cygwin-setup.bash $MYBIN/do_setup.bash'
alias emacs-bat='emacs.bat'
alias emacs-='win32-emacs.sh'
alias em-='emacs-'
alias em-devel="em --devel"

# em-cyg(filelist): invoke emacs using the Win32 filename(s) in the list
# NOTE: The bash backquote operating is choking over files with embedded spaces, since
# it performs word splitting by default on the output. As seen below, I punted
# on getting this to work for filelist with more than 1 file.
#
function em-cyg- () { em- `winpath "$1"`; }
function em-cyg () { local file="$1"; if [ "$file" = "" ]; then file=.; fi; em- '"'`winpath "$file"`'"'; }
alias em-test='em-cyg'
alias em='emacs-'

# Directory locations
export CARTERA_DE_TOMAS=$HOME
export TOMAS=$CARTERA_DE_TOMAS
export TOM=/c/tom
export PREPROCESSOR=$CARTERA_DE_TOMAS/ILIT/preprocessor
export PREP_DATA=/c/ILIT/data/prep
export PREP_SRC=/c/ILIT/source/prep
## export ANALYZER=$PREPROCESSOR/bin/Full_Analyzer
unset FULL_ANALYZER
export _FULL_ANALYZER=/home/shared/bin/Full_Analyzer
export ANALYZER=/c/ILIT/Full_Analyzer
export ONTOSEM_DIR='c:\ILIT\Full_Analyzer'
export SOURCE=/c/ILIT/source
export ONTOSEM=`winpath $ANALYZER`
## export MEANING_PROCS=$ANALYZER/meaning-procedures
## export REFERENCE=$ANALYZER/reference
export SCRIPTS=$ANALYZER/scripts
export LOOKUP_SRC=$PREPROCESSOR/src/Projects/lookup
# TODO: move ILIT settings to new ilit-setup.bash
export BIN_ILIT=/c/ILIT/bin
export DEKADE=/c/ILIT/source/dekade
export VP=/c/ILIT/simulation/VP-Tutor
export VP_EDITOR_DIR=/c/ILIT/MedicalPatientCreator
export POSTGRES_HOME="/c/Program Files/PostgreSQL/8.0/data"
export SWING_TUTORIAL=/c/Miscellaneous/swing-tutorial
export SWING_TUTORIAL_COMPONENTS=$SWING_TUTORIAL/uiswing/components/example-swing
export ANIMATION=/c/ILIT/simulation/animation/VP-Animator

# Multilingual dictionaries
multiling_dir="/$WINDRIVE/tom/MultiLingual/"
setenv _FRENCH_DICT $multiling_dir/French/french_english.dict
setenv GERMAN_DICT $multiling_dir/German/german_english.dict
setenv ITALIAN_DICT $multiling_dir/Italian/italian_english.dict
setenv MULTI_DICT $multiling_dir/Multi/multilingual.dict 
setenv SPANISH_DICT $multiling_dir/Spanish/spanish_english.dict
setenv SPANISH_IRREG_DICT $multiling_dir/Spanish/spanish_irregular.dict
setenv ENGLISH_DICT $multiling_dir/Spanish/english_spanish.dict
setenv LATIN_DIR $multiling_dir/Latin
function latin-lookup() { echo "$@" | $MYBIN/qd_trans_latin.perl -; }

## function wn-index-gr () { egrep -i -h "$2" $3 $4 $5 $6 $7 $8 $9 "$WNSEARCHDIR/$1.idx"; }
## alias wn-n-gr='wn-index-gr noun'
## alias wn-v-gr='wn-index-gr verb'
## alias wn-adj-gr='wn-index-gr adj'
## alias wn-adv-gr='wn-index-gr adv'
# function wn-gr () { egrep -i -h "$@" "$WNSEARCHDIR/[nva]*.idx"
# }
# TODO: fix problem with globbing under cygwin
## function wn-gr () { egrep -i -h "$@" "$WNSEARCHDIR/noun.idx" "$WNSEARCHDIR/verb.idx" "$WNSEARCHDIR/adj.idx" "$WNSEARCHDIR/adv.idx"; }
## function wn-data-gr () { egrep -i -h "$@" "$WNSEARCHDIR/*.dat"; }
# NOTE: WN2.1 under Windows now uses Unix naming convention (see macros in bin/do_setup.bash)
## function wn-index-gr () { egrep -i -h "$2" $3 $4 $5 $6 $7 $8 $9 "$WNSEARCHDIR/$1.idx"; }


# Redo WordNet settings
# TODO: figure out why the previous settings not sufficient
if [ $USERDOMAIN = "NONESUCH" ]; then
    export wn=`cygpath -u "${WINDRIVE}:"'\Program-Misc\WordNet\2.1\bin\wn.exe'`
    export WNSEARCHDIR="${WINDRIVE}:"'\Program-Misc\WordNet\2.1\dict\'
fi

# Emacs
export EMACSDIR_DEVEL="/$WINDRIVE"'/Program-Misc/GNU/emacs-devel'
export EMACSDIR=$EMACSDIR_DEVEL
export ELISP="$EMACSDIR/lisp"
alias cd-elisp='cd "$ELISP"; pwd'
export ETAGS="$EMACSDIR/bin/etags.exe"
alias em-tags='"'"$ETAGS"'"'
alias etags='echo ERROR: Use em-tags instead'

# Tomcat JSP server and related
if [ $USERDOMAIN = "ILIT" ]; then
    ## export TOMCAT="/$WINDRIVE"'/Program Files/Apache Software Foundation/Tomcat 5.5'
    ## export TOMCAT_NB40='C:\Program Files\netbeans-4.0\nb4.0\jakarta-tomcat-5.0.28'
    ## export TOMCAT_NB40_LOCALHOST='C:\Documents and Settings\tomohara\.netbeans\4.0\jakarta-tomcat-5.0.28_base\conf\Catalina\localhost'
    ## export TOMCAT_NB40_WORK=$TOMCAT_NB40_LOCALHOST'\..\..\..\work\Catalina\localhost\servlet_win32-dekade\org\apache\jsp'
    ##
    export TOMCAT_NB41='C:\Program Files\netbeans-4.1\enterprise1\jakarta-tomcat-5.5.7'
    export TOMCAT_NB41_LOCALHOST='C:\Documents and Settings\$USERNAME\.netbeans\4.1\jakarta-tomcat-5.5.7_base\conf\Catalina\localhost'
    export TOMCAT_NB41_WORK=$TOMCAT_NB41_LOCALHOST'\..\..\..\work\Catalina\localhost\servlet_win32-dekade\org\apache\jsp'
    ##
    export TOMCAT_NB50='C:\Program Files\netbeans-5.0\enterprise2\jakarta-tomcat-5.5.9'
    export TOMCAT_NB50_LOCALHOST='C:\Documents and Settings\$USERNAME\.netbeans\5.0\jakarta-tomcat-5.5.9_base\conf\Catalina\localhost'
    export TOMCAT_NB50_WORK=$TOMCAT_NB41_LOCALHOST'\..\..\..\work\Catalina\localhost\servlet_win32-dekade\org\apache\jsp'
    ##
    export TOMCAT='C:\Program Files\Apache Software Foundation\Tomcat 5.5'
    export TOMCAT_LOCALHOST=$TOMCAT'\conf\Catalina\localhost'
    export TOMCAT_WORK=$TOMCAT'\work\Catalina\localhost\win32-dekade\org\apache\jsp'
fi

## unset TEXINPUTS

# Aliases for Win32 commands
##
## function gv () { /$WINDRIVE/Program\ Files/Ghostgum/gsview/gsview32 $* & }
## function pdf-view () { /$WINDRIVE/Program\ Files/Adobe/Acrobat\ 5.0/Acrobat/Acrobat.exe '"'`remap_filename.perl $1`'"' & }
##
# NOTE: - commands invoked via start are redundantly put in background to avoid problem with xterm title being overwritten
#
## alias gv='start gsview32 &'
## function pdf-view () { start Acrobat.exe '"'`remap_filename.perl $1`'"' & }
## alias gv='start-win32 gsview32'
function gv () { start-win32 gsview32 `winpath "$1"`; }
## alias pdf-view='start-win32 Acrobat.exe'
function pdf-view () { start-win32 Acrobat.exe `winpath "$1"`; }
## alias pdf-view='pv'
#
alias vc='start-win32 MSDEV.EXE'

# Aliases for Unix commands not supported under CygWin
#
alias whereis='echo "note: WHEREIS is not supported under CygWin, use TYPE instead"'

# Aliases for killing particular programs
# NOTE: TASKKILL /IM image-name
function kill-app () { taskkill /IM $1.exe; }
function kill-app-force () { taskkill /F /IM $1.exe; }
alias kill-putty='kill-app putty'
alias kill-firefox='kill-app firefox'
## "E:\Program Files\Microsoft Visual Studio\Common\MSDev98\Bin\MSDEV.EXE"
alias kill-activesync-proper='kill-app WCESMgr'
alias kill-activesync='kill-activesync-proper; kill-app wcescomm'
#
alias restart-explorer='kill-app-force explorer; start explorer'

# Stopping service for McAfee ePolicy Orchestrator Agent (EPO)
alias stop-epo='sc stop McAfeeFramework'

alias reconfig-ip='ipconfig /release; ipconfig /renew'

scpcmd='scp -p'
# TODO: have version that handles multiple arguments
function cs-upload () { $scpcmd "$@" tomohara@colossus.cs.nmsu.edu:temp; }
function cs-download-dir () { local dir="$1"; shift; local files=`echo " $@ " | perl -pe 's# (\S+)#tomohara\@colossus.cs.nmsu.edu:temp/$1 #g;'`; $scpcmd $files $dir; echo "downloaded to $dir"; }
alias cs-download='cs-download-dir ~/xfer'
alias cs-download-here='cs-download-dir .'

# UMBC/ILIT stuff
#
function ilit-upload () { $scpcmd "$@" thoth.ilit.umbc.edu:temp; }
# TODO: have version that handles multile arguments
function old-ilit-download () { if [ "$2" != "" ]; then echo "ignoring $2"; fi; $scpcmd thoth.ilit.umbc.edu:temp/$1 ~/xfer; }
function ilit-download-dir () { local dir="$1"; shift; local files=`echo " $@ " | perl -pe 's# (\S+)#tomohara\@thoth.ilit.umbc.edu:temp/$1 #g;'`; $scpcmd $files $dir; echo "downloaded to $dir"; }
alias ilit-download='ilit-download-dir ~/xfer'
alias ilit-download-here='ilit-download-dir .'
#
alias ssh-tunnel-db='set_xterm_title.bash "ssh tunnel for Postgress access (NABOO)"; ssh -L 5432:localhost:5432 naboo.ilit.umbc.edu'
alias ssh-tunnel-db-YAVIN='set_xterm_title.bash "ssh tunnel for Postgress access (YAVIN)"; ssh -L 5432:localhost:5432 yavin.ilit.umbc.edu'
export CVSROOT=":ext:tomohara@naboo.ilit.umbc.edu:/home/shared/cvsroot"

# Convera stuff
# TODO: create generic xyz-download-dir (i.e., reconciling ilit-download-dir and conv-download-dir)
## function conv-upload () { $scpcmd "$@" tohara@toharadev:xp-home/temp; }
function conv-upload () { $scpcmd "$@" tohara@toharadev:xfer; }
## function conv-upload () { $scpcmd "$@" tohara@toharadev:/tmp; }
function conv-download-dir () { 
    _dir="$1"; shift; 
    _files=`echo " $@ " | perl -pe 's# (\S+)#tohara\@toharadev:xfer/$1 #g;'`; 
    $scpcmd $_files $_dir; 
    echo "downloaded to $_dir"; 
}
alias conv-download='conv-download-dir ~/xfer'
alias conv-download-here='conv-download-dir .'

# Local network stuff
# TODO: reconcile with other xyz-upload's, etc.
function esc-upload () { $scpcmd "$@" tomas@tpo-escritorio:temp; }
function esc-download-dir () { 
    _dir="$1"; shift; 
    _files=`echo " $@ " | perl -pe 's# (\S+)#tomas\@tpo-escritorio:xfer/$1 #g;'`; 
    $scpcmd $_files $_dir; 
    echo "downloaded to $_dir"; 
}
alias esc-download='esc-download-dir ~/xfer'
alias esc-download-here='esc-download-dir .'

# Unicode stuff
## function show-unicode-code-info() { perl -CIOE -ne 'chomp; printf "%s: %d\n", $_, length($_); foreach $c (split(//, $_)) { printf "%s\t%04X\n", $c, ord($c); } ' < $1; }
alias unipad='start "C:\Program Files\SC UniPad\up.exe"'

# File listing searching
# ls otions: -a all files (includes .xyz files); -l long listing; -R recursive; -Q quote file names
function prepare-find-file () { nice -19 ls -alRQ /$1 >| /$1/ls-alR.list 2>&1; }
## function prepare-find-files () { prepare-find-file e; prepare-find-file d; prepare-find-file f; prepare-find-file c; }
function prepare-find-files () { prepare-find-file c; prepare-find-file d; }
function find-file () { egrep -i '((^\")|(".*'$2'))' /$1/ls-alR.list | less -p $2; }
function new-find-file () { perlgrep.perl -para '".*'$2 /$1/ls-alR.list | egrep -i '((^\")|('$2'))' | $PAGER -p $2; }

function find-c-file () { find-file c $1; }
## function find-d-file () { find-file d $1; }
function find-m-file () { find-file m $1; }
## function find-e-file () { find-file e $1; }
## function find-f-file () { find-file f $1; }
#
## TODO: replace with new-find-file (omits directories not containing the file):
## function new-find-file () { perlgrep.perl -para "$1" ls-alR.list | egrep -i '((^\.)|('$1'))' | less -p $1; }
# HACK: assume M listing produced via prepare-find-files-here (see do_setup.bash)
function find-m-file-new () { find-files-there "$1" /m/ls-alR.list; }

# ILIT-TPO backups
# TODO: have version that preserves old trace setting
function make-full-backup () {
    destdir=/t/OTHER-TOM/archive;
    set -o xtrace;
    date=`date '+%m%d%y'`;
    log_name="ilit-tpo-backup-$date.log";
    nice -19 make-ilit-tpo-backup.sh --full >| /c/backup/$log_name 2>&1;
    ilit-upload /c/backup/*${date}*
    set - -o xtrace;
}

# Scan Maker
## alias enable-scanner='E:\\WINDOWS\\twain_32\\ScanWiz5\\SDII.exe'
alias enable-scanner='start-win32 E:\\WINDOWS\\twain_32\\ScanWiz5\\SDII.exe'
alias config-scanner='start-win32 E:\\WINDOWS\\twain_32\\ScanWiz5\\MSC.exe'
alias set-scanner='enable-scanner; config-scanner'

# System services
# TODO: use 'net start/stop' for services instead (eg, for more informative error messages)
alias stop-service='sc stop'
alias start-service='sc start'
function check-arg () { if [ "$2" == "" ]; then echo "WARNING: missing argument to $1"; fi; }
function check-service () { check-arg $FUNCNAME $1; sc query | remove-cr | perlgrep -i -para $1; }
alias query-service='check-service'

# Internet Explorer
# NOTE: The bookmarks must be exported from IE first (default is 'My Documents/bookmark.htm')
function view-bookmarks () { perl- bookmark2ascii.perl "$@" "$USERPROFILE/My Documents/bookmark.htm" | $PAGER; }

# Postgres
export PSQL=/c/Program\ Files/PostgreSQL/8.0/bin/psql.exe

# Cyc macros
function gr-cyc () { zgrep -i -h "$@" /e/tom/cyc/.*English*gz; }
function gr-opencyc () { zgrep -i -h "$@" /e/tom/open-cyc/.*English*gz; }

# OntoSem
#
# recreate-ontosem-image(): Loads OntoSem via lispinit.mem and as well as
# changes via init.lisp (via tpo-init.lisp via .init.lisp via ~/.clisprc.lisp)
# and then recreated lisp image (for a quick and dirty update):
function recreate-ontosem-image () { pushd $ANALYZER; clisp.bat -M lispinit.mem -x "(create-lisp-image *debug-level*)"; popd; }
alias clisp='clisp.bat'
alias load-install='clisp -- -norc -i tpo-install.lisp'
alias load-medical-install='clisp -- -norc -i tpo-medical-install.lisp'
## export CLISPDIR='C:\clisp'
export CLISPDIR='C:\Programs_Misc\clisp-2.38'

# Whatever
alias win32-perl='/c/perl -Ssw'
alias stop-update-server='net stop wuauserv'

# Java related
export JUNIT="/c/Programs_Misc/JBuilder2005/thirdparty/junit3.8"

# Convera settings
# TODO: Consolidate Convera-specific settings here
alias conv-setup='source ~/convera-setup.bash'
if [ "$USERDOMAIN" = "CONVERA" ]; then
    conv-setup

    # Redefine some aliases
    function prepare-find-files () { prepare-find-file c; prepare-find-file m; }

    # TODO: use dynamic ip address determination (as with show-cs-display-export)
    conditional-source ~/bin/vcvars.sh

    # Get JDK1.4.2 from network
    # TODO: use local version
    prepend-path /s/3rd_party/ant/1.6.5/bin
    export ANT_HOME='S:\3rd_party\ant\1.6.5'
fi
#

# Make sure terminaml set up properly (via sourcing of resize output)
do-resize

startup-trace "4. PATH=$PATH"

startup-trace out cygwin-setup.bash
