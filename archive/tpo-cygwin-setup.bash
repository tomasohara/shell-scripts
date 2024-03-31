# tpo-cygwin-setup.bash: Setup TPO's bash environment for use under CygWin.
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
# TODO:
# - *** reconcile with tpo-plata changes ***
# - Reorganize, so that cygwin proper aliases (e.g., cygstart) are all before cygwin-based aliases (e.g., kdiff).
#

echo "cygset in: USER='$USER'"

# Define function for startup tracing
#
# NOTES:
# - The STARTUP_TRACING, CONSOLE_TRACING, and VERBOSE_TRACING env. vars affect
#   tracing. For example, under Windows command prompt (TODO: ome liner):
#       set STARTUP_TRACING=1
#       set CONSOLE_TRACING=1
#       set VERBOSE_TRACING=1
#       cygwin
# - See C:\cartera-de-tomas\bin\my-cygwin-trace.bat for how they can be set.
#   This is intended as a target for a Windows shortcut.
#
# TODO:
# - Fix stupid winpath/bash-word-splitting problems (e.g., in em-cyg alias).
#
## export STARTUP_TRACING=1; export CONSOLE_TRACING=1;

# TODO: cond-setenv TOM_BIN "~/bin/"
if [ "$TOM_BIN" = "" ]; then export TOM_BIN=~/bin; fi
if [ -e "$TOM_BIN/startup-tracing.bash" ]; then source "$TOM_BIN/startup-tracing.bash"; fi

startup-trace in tpo-cygwin-setup.bash

# Fixup for domain name setup
if [ $USERDOMAIN = "TPO-PORTATIL" ]; then export USERDOMAIN=NONESUCH; fi
if [ $USERDOMAIN = "TPO-ESCRITORIO" ]; then export USERDOMAIN=NONESUCH; fi

# Make sure mount uses /c instead of /cygdrive/c, etc.
# TODO: make this permanent (e.g., via user fstab).
mount --change-cygdrive-prefix /

# Locale settings
unset LANG

# Misc settings
#
# Disable warning about DOS paths (e.g., 'C:\Program-Misc\procexp.exe').
## BAD: export nodosfilewarning=1
export CYGWIN=nodosfilewarning

# Note: binmode is used so that CR's are not converted into CR/NL sequences.
# That is, the Unix convention is used, even for the representation on disk.
## OLD: export mount_options="--binary --force --executable --user"
export mount_options="--force"
alias my-mount-aux='mount $mount_options'
function my-mount () { local win_dir="$1"; local unix_dir="$2"; if [ ! -e "$unix_dir" ]; then my-mount-aux $mount_options "$win_dir" "$unix_dir"; fi; }
## OLD: function dos-mount () { if [ ! -e /$1 ]; then my-mount $mount_options "$1:\\" /$1; fi; }
function dos-mount () { my-mount "$1:\\" "/$1"; }
dos-mount c
case $USERDOMAIN in
    # TODO: work around 'Operation not permitted' with cdrom drive w/o disc
## OLD: NONESUCH) dos-mount r;;
    NONESUCH) dos-mount d;;
    CONVERA) dos-mount m; dos-mount v;;
esac

# Make sure WINDRIVE and HOMEDRIVE have appropriate letters:
#   WINDRIVE (c): operating system files
#   TPODRIVE (d): where cartera-de-tomas and other personal directories reside
#   CYGDRIVE (c): where cygwin files reside
#
if [ "$WINDRIVE" = "" ]; then 
    export WINDRIVE=c
    if [ -e "d:/Windows" ]; then export WINDRIVE=d; fi
    export TPODRIVE=c
    if [ -e "d:/cartera-de-tomas" ]; then export TPODRIVE=d; fi
fi
export CYGDRIVE=$WINDRIVE
if [ -e "d:/cygwin" ]; then export CYGDRIVE=d; fi

# Create mount point 'symbolic links'
# NOTE: unix symbolic links are not used since Emacs doesn't understand
# the .lnk files used under Win32
#
export DOCS="${WINDRIVE}:\\Documents and Settings\\$USERNAME\\My Documents"
my-mount "${WINDRIVE}:\\Documents and Settings\\$USERNAME" /my-data
my-mount "${WINDRIVE}:\\Documents and Settings\\$USERNAME\\My Documents" /my-docs
## OLD: my-mount "${WINDRIVE}:\\Documents and Settings\\$USERNAME\\My Documents\\My Pictures" /my-pics
my-mount "${WINDRIVE}:\\Documents and Settings\\$USERNAME\\Pictures" /my-pics
## my-mount "${WINDRIVE}:\\Documents and Settings\\$USERNAME\\Desktop" /desktop
my-mount "${TPODRIVE}:\\cartera-de-tomas\\bin" /my-bin
my-mount "${WINDRIVE}:\\Documents and Settings\\$USERNAME\\Desktop\\Texts" /texts
## OLD: if [ "$USER" != "tomohara" ]; then my-mount "${WINDRIVE}:\\Documents and Settings\\tomohara\\Desktop\\Texts" /tpo-texts; fi

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
if [ "$PERLLIB" = "" ]; then PERLLIB="."; else PERLLIB="$PERLLIB:."; fi
# TODO: use 'perl -v' to derive "5.8", etc.
export PERLLIB=$MYBIN:$PERLLIB:/usr/lib/perl5/5.8:/usr/lib/perl5/site_perl/5.8:/usr/lib/perl5/vendor_perl/5.8
#
# Append misc. directories to end (e.g., utilities with better CygWin version)
# NOTES:
# - c:/bin is mainly for win32 executables (from elsewhere) and also has some
# scripts (eg, updatedsc.pl). 'E:\Program Files\Support Tools contains tools
# from XP's resource kit.
# - c:/mybin and c:/bin contain old Unix style programs for Windows, so 
# these need to be at the end of the path to avoid conflicts
#
# Note: removed above as conflicts with find's -execdir option
# (e.g., "insecure relative path c"); now supported via add-mybin alias.
## OLD: export PATH=$PATH:"/$WINDRIVE/Program-Misc"
export PATH=$PATH:"/$WINDRIVE/Program-Misc/windows"
alias add-mybin="export PATH=\$PATH:$TPODRIVE:/mybin:$TPODRIVE:/bin"
#
startup-trace "1. PATH=$PATH"
# Prepend more important directories to front
# NOTES:
# - ~/bin (e.g., m:/cartera-de-tomas/unix-bin) is mirror of scripts in CS
# account, which represent the most up-to-date version; c:/mybin contains
# windows-based scripts along with some of the unix-bin scripts;
# - Sun's Java version 1.5 overrides Microsoft's version (e.g.,  c:\windows\system32).
#
## NOTE: JDK and ant directories copied from /c/Program Files (x86)/java with release number dropped (e.f., jdk1.6.0_27 to jdk-1-6
export ANT_HOME="/$WINDRIVE/Program-Misc/java/ant-1-7"
export JAVA_HOME="/$WINDRIVE/Program-Misc/java/jdk-1-6"
# TODO: Java-CC-5-0
export PATH=$MYBIN:"$JAVA_HOME/bin:$ANT_HOME/bin:$PATH"
#
startup-trace  "2. PATH=$PATH"

# Setup other path-like variables (e.g., TEXINPUTS for latex directories)
#
## export TEXINPUTS=.:~/latex:/usr/share/texmf/tex/latex/base
## export TEXINPUTS=.:~/latex:/usr/share/texmf/tex/latex/base:/usr/share/texmf/tex/latex/psnfss:/usr/share/texmf/tex/latex/graphics
## TODO: export TEXINPUTS=.:$HOME/latex:$LATEX

# Cygwin specific stuff
# TODO: put after do_setup.bash invocation (e.g., with set-display-local).
export OSTYPE=cygwin
alias cygwin-setup='source ~/bin/tpo-cygwin-setup.bash'
## OLD: alias fix-startup-scripts='$TOM_BIN/remove_carriage_returns.perl ~/*setup*.bash $TOM_BIN/*setup*.bash'
alias cygwin-startup='cygwin-setup'
alias cyg-setup='cygwin-setup'
function cygwin-proper-setup () { BAREBONES_SHELL=1; cygwin-setup; BAREBONES_SHELL=0; }
alias cygwin-version='strings c:/cygwin/bin/cygwin1.dll | grep -A20 BEGIN_CYGWIN_VERSION_INFO'

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

# WordNet
export wn=/usr/bin/wn
export WNSEARCHDIR=/usr/lib/wnres/dict
if [ $USERDOMAIN = "NONESUCH" ]; then
    export wn="${WINDRIVE}:"'\Program-Misc\WordNet\2.1\bin\wn.exe'
    export WNSEARCHDIR="${WINDRIVE}:"'\Program-Misc\WordNet\2.1\dict\'
fi
## OLD: function set-wn-env () { local version=$1; export WNHOME=/usr/lib/wnres$version; unset WNSEARCHDIR; export wn=wn; }
# NOTE: WNSEARCHDIR set redundantly for sake of wn-grep scripts
function set-wn-env () { local version=$1; export WNHOME=/usr/lib/wnres$version; export WNSEARCHDIR=$WNHOME/dict; export wn=wn; }
alias wn20='set-wn-env 20'
alias wn21='set-wn-env 21'
alias wn30='set-wn-env 30; export wn=wn30'

# XP, etc.
# TODO: consolidate with  Win32 helpers below
## OLD: alias restart-computer='shutdown --reboot 5'
alias reboot-computer='shutdown --reboot 5'
## OLD: function check-disk() { local drive="c"; if [ "$1" != "" ]; then drive="$1"; fi; chkdsk /f "${drive}:"; }
# chkdsk options: /f fix errors; /r locate bad sectors and recover (implies /f)
# OLD: function check-disk() { local drive="c"; if [ "$1" != "" ]; then drive="$1"; fi; chkdsk /r "${drive}:"; }
function check-disk() { local drive="$1"; if [ "$drive" = "" ]; then echo "Usage: check-disk drive-letter"; return; fi; chkdsk /r "${drive}:"; }
alias check-this-disk='check-disk `cygpath -wa . | perl -pe "s/^([a-z]):.*/\1/i;"`'
alias start-alt='cmd /c start'
alias winword-read-only='start winword /Mreopen_readonly'
function msword() { start-alt winword `winpath "$@"`; }
alias winword-regular=msword
function msexcel() { start-alt excel `winpath "$@"`; }
## alias excel-regular=msexcel
alias excel=msexcel
## TODO: alias excel="start 'c:/Program Files (x86)/Microsoft Office/Office12/EXCEL.EXE'"
#
alias blank-screen="nircmd monitor off &"

# Bash
# Predefine LINES for use in h alias for history 
# TODO: use resize command (after fixing problem in batch mode)
if [ "$LINES" = "" ]; then export LINES=52; fi

#------------------------------------------------------------------------
# Get main settings from do_setup.bash

startup-trace "3. [pre-do_setup.bash] PATH=$PATH"

## # Set remapped GraphLing path (via GraphLing symbolic link)
## export GRAPHLING_HOME=/t/GRAPH_LING
export GRAPHLING_HOME=/home/graphling
export TOOLS=$GRAPHLING_HOME/TOOLS
export UTILITIES=$GRAPHLING_HOME/UTILITIES
alias graphling-env='append-path $UTILITIES'

# UNDER_EMACS: Special environment variable for handling Emac's problems
# For example, this is used to avoid setting xterm title so that the
# control sequence doesn't show up in the buffer
# See .emacs for UNDER_EMACS definition
if [ "$UNDER_EMACS" = "" ]; then export UNDER_EMACS=0; fi

# Get other settings (mainly command aliases) from do_setup.bash
## OLD: if [ "$BAREBONES_SHELL" != "1" ]; then source /my-bin/do_setup.bash; fi

# Juju stuff
ec2_host="ec2-184-73-51-232.compute-1.amazonaws.com"
alias ssh-ec2-tpo="ssh -X -i ~/.ssh/juju-id_rsa  root@$ec2_host"
function scp-ec2-up() { scp -i ~/.ssh/juju-id_rsa "$@"  root@$ec2_host:xfer; }
function scp-ec2-down() { scp -i ~/.ssh/juju-id_rsa root@$ec2_host:xfer/$1 .; }
alias juju-upload=scp-ec2-up
alias juju-download=scp-ec2-down
alias juju-login=ssh-ec2-tpo
function gr-juju-notes () { grep "$@" ~/juju/*notes* /d/data/juju-data/*notes*; }
## OLD: export JJDATA=/d/data/juju-data
## OLD: export SRC=$JJDATA/src
## OLD: export SANDBOX=$SRC/sandbox/tohara
## OLD:  export QLOG=$SRC/query-log-analysis
export NLTK_DATA=/c/data/nltk_data
#
# Get Juju-related changes
# Note: tohara-aliases is streamlined version of do_setup.bash
## OLD: alias tohara-aliases="source $TOM_BIN/tohara-aliases.bash"
alias tomohara-aliases="source $TOM_BIN/tomohara-aliases.bash"

if [ "$BAREBONES_SHELL" != "1" ]; then tomohara-aliases; fi

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

startup-trace "4. [post-do_setup.bash] PATH=$PATH"

# Set TEMP to /e/temp
# NOTE: now also set in .bashrc_profile which is executed prior to this
if [ "$TEMP" = "" ]; then export TEMP=/$WINDRIVE/temp; fi

## OLD: (causes problem with emacs aliases so disabled [Cygwin-X not used much])
## # CygWin setups
## # see do_setup.bash for set-display-local (localhost:0.0).
## set-display-local

# Alias overrides (e.g., later Cygwin version)
# TODO: conditionalize
## OLD: function usage () { nice -19 du --block-size=1K --one-file-system 2>&1 | nice -19 sort -rn >| usage.list 2>&1; $PAGER usage.list; }
#
# disk-free(): Show free space under cygwin without including mount points (e.g., /my-pics for "C:/Documents and Settings/tomohara/My Documents/My Pictures")
# and with eliminating all the extra space it allots for the Filesystem column,
#
# Current df output:
# Filesystem                                     Size  Used Avail Use% Mounted on
# C:                                             941G  794G  148G  85% /c
# P:                                             3.7T  567G  3.1T  16% /p
# U:                                             120G   73G   47G  61% /u
#
## OLD: alias disk-free='df -h | fgrep -v ":/" | perl -pe "s/( ){40}//;"'
alias disk-free='df -h | fgrep -v ":/" | perl -pe "s/( ){36}//;"'
alias df-info=disk-free

# CSH-style setenv command
function setenv () { export $1=$2; }
## OLD: function cond-setenv { if [ "`printenv $1`" = "" ]; then export $1=$2; fi; }

# TODO: fix problem with do_setup alias being overridden via 'do_setup' invocation
# alias do-setup='cygwin-setup; source /my-bin/do_setup.bash'
alias do-setup='cygwin-setup'
alias do-setup-='source /my-bin/do_setup.bash'
# note: temp, workaround for emacs mount/cygwin-loading problem
## TODO: alias ed-setup='em ~/cygwin-setup.bash $MYBIN/do_setup.bash'
alias ed-setup='em ~/bin/tpo-cygwin-setup.bash $TOM_BIN/do_setup.bash'

# Emacs aliases
alias emacs-bat='emacs.bat'
alias emacs-='win32-emacs.sh'
alias emacs-win32='win32-emacs.sh'
alias em-='emacs-'
## OLD: alias em-devel="em --devel"
## OLD: function em-dir() { pushd "$1"; emacs-win32 .; popd; }
## OLD: alias em-docs='em-dir /my-docs;'
alias em-docs='pushd /my-docs; em; popd'

# em-file(filename): edit filename with current directory set to it's dir
# note: This avoids stupid link resolution problem under cygwin. It is
# also useful so that Emacs current directory is set appropriately.
function em-file() {
    local file="$1"
    local base=$(basename "$file")
    local dir=$(dirname "$file")
    pushd $dir
## OLD: em "$base"
    em- "$base"
    popd
    }
alias em-link=em-file

# em-cyg(filelist): invoke emacs using the Win32 filename(s) in the list
# NOTE: The bash backquote operating is choking over files with embedded spaces, since
# it performs word splitting by default on the output. As seen below, I punted
# on getting this to work for filelist with more than 1 file.
#
function em-cyg- () { em- `winpath "$1"`; }
function em-cyg () { local file="$1"; if [ "$file" = "" ]; then file=.; fi; em- '"'`winpath "$file"`'"'; }
alias em-test='em-cyg'
# NOTE: em is defined as function in bin/do_setup.bash
alias em='emacs-'
function em-dir() { emacs- "$@"; }

# Directory locations
export CARTERA_DE_TOMAS=$HOME
export TOMAS=$CARTERA_DE_TOMAS
export TOM="$TPODRIVE:/tom"

# Multilingual dictionaries
## OLD: multiling_dir="$TOM/MultiLingual/"
export multiling_dir="$TOM/MultiLingual/"
setenv SPANISH_DICT $multiling_dir/Spanish/spanish_english.dict
setenv SPANISH_IRREG_DICT $multiling_dir/Spanish/spanish_irregular.dict
setenv ENGLISH_DICT $multiling_dir/Spanish/english_spanish.dict
function set-multilingual-dicts () {
    setenv LATIN_DIR $multiling_dir/Latin
    setenv _FRENCH_DICT $multiling_dir/French/french_english.dict
    setenv GERMAN_DICT $multiling_dir/German/german_english.dict
    setenv ITALIAN_DICT $multiling_dir/Italian/italian_english.dict
    setenv MULTI_DICT $multiling_dir/Multi/multilingual.dict 
}

function latin-lookup-stdin() { $MYBIN/qd_trans_latin.perl -; }
function latin-lookup() { echo "$@" | latin-lookup-stdin; }

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
# TODO: /c/Program-Misc/emacs-24.5
## OLD: export EMACSDIR="/$WINDRIVE"'/Program-Misc/emacs-24.3'
## Note: following currently sets EMACSDIR to /c/Program-Misc/gnu/emacs-25-1-2
## TODO: export EMACSDIR=$(ls -td "/$WINDRIVE"/Program-Misc/gnu/emacs* | head -1)
## TEMP: use older version of Emacs until font problem becomes resolved (bold no longer used)
export EMACSDIR="/$WINDRIVE"'/Program-Misc/GNU/old/emacs-24.5'
export ELISP="$EMACSDIR/lisp"
alias cd-elisp='cd "$ELISP"; pwd'
export ETAGS="$EMACSDIR/bin/etags.exe"
alias em-tags='"'"$ETAGS"'"'
alias etags='echo ERROR: Use em-tags instead'

# Latex support
## OLD: unset TEXINPUTS

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
## OLD: function gv () { start-win32 gsview32 `winpath "$1"`; }
function gv () { start-win32 gsview64 `winpath "$1"`; }
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
function kill-process () { taskkill /PID $1; }
function kill-process-force () { taskkill /F /PID $1; }
alias kill-putty='kill-app putty'
alias kill-firefox='kill-app firefox'
alias kill-iexplore='kill-app'
#
alias restart-explorer='kill-app-force explorer; start explorer'
#
alias kill-rhapsody='kill-app-force rhapsody; kill-app-force rhaphlpr;'

alias reconfig-ip='ipconfig /release; ipconfig /renew'

# File system searching
## function find-files-there () { perlgrep.perl -para -i "$1" "$2" | egrep -i '((^\.)|('$1'))' | $PAGER_NOEXIT -p "$1"; }
# note: uses following from do_setup.bash
#   function find-files-there () { perlgrep.perl -para -i "$@" | egrep -i '((^\.)|('$1'))' | $PAGER_NOEXIT -p "$1"; }
function find-torre-file () { find-files-there "$@" /c/ls-alR.list  /d/ls-alR.list  /f/ls-alR.list; }
function find-plata-file () { find-files-there "$@" /c/ls-alR.list  /d/ls-alR.list; }

# Unicode stuff
## function show-unicode-code-info() { perl -CIOE -ne 'chomp; printf "%s: %d\n", $_, length($_); foreach $c (split(//, $_)) { printf "%s\t%04X\n", $c, ord($c); } ' < $1; }
## OLD: alias unipad='start "${X86_PROGRAM_FILES}\\SC UniPad\\up.exe"'
## OLD: alias unipad='start "/$WINDRIVE/Program-Misc/windows/SC-UniPad/up.exe"'
alias unipad='start-optional-file "/$WINDRIVE/Program-Misc/windows/SC-UniPad/up.exe"'

# Texas State aliases
## OLD: txstate_host="hercules.cs.txstate.edu"
alias alt-txstate-host='txstate_host="hercules.cs.txstate.edu"'
txstate_host="zeus.cs.txstate.edu"
## OLD: alias ssh-txstate="set_xterm_title.bash to17@txstate; ssh to17@$txstate_host"
function ssh-txstate () { set_xterm_title.bash "to17@txstate"; ssh to17@$txstate_host; }
# scp options: -p preserves modification times; -v verbose
function scp-txstate-up () { scp -p "$@" "to17@${txstate_host}:xfer"; }
function scp-txstate-down () { scp -p "to17@${txstate_host}:xfer/$1" .; }

# PaperRate aliases
# TODO: have generic function to handle backend for these and txstate ones
## paperrater_host="paperrater.com"
## alias alt-paperrater-host='paperrater_host="67.227.161.50"'
paperrater_host="paperrater.com"
alias alt-paperrater-host='paperrater_host="67.227.161.50"'
alias main-paperrater-host='paperrater_host="paperrater.com"'
function ssh-paperrater () { set_xterm_title.bash "tom@paperrater"; ssh tom@$paperrater_host; }
function scp-paperrater-up () { scp "$@" "tom@${paperrater_host}:xfer"; }


## OLD: # PaperRater.com stuff (now obsolete)
##### OLD: function scp-paperrater-down () { scp "tom@${paperrater_host}:xfer/$1" .; }
## function scp-paperrater-down () { if [ "$2" != "" ]; then echo "Error: only one file supported"; else scp "tom@${paperrater_host}:xfer/$1" .; fi; }
## alias review-screenshots='pushd "/my-data/AppData/Roaming/com.elance.tracker/Local Store/screenshots"; start .; copy --no-clobber * ~/essay-grading/old-screenshots; popd'
##### # Temp: use alternative host as default
##### alt-paperrater-host
## export PRCODE=d:/essay-grading/nlp-code-data/code

## OLD: # Cycorp stuff
## alias ssh-lynx='ssh tohara@lynx.cyc.com -L 5901:lynx.cyc.com:5901'
## alias ssh-cycorp=ssh-lynx

## OLD: # eLance stufff
## alias start-tracker='start "/c/Program Files (x86)/Tracker/Tracker.exe"'
## alias kill-tracker='kill-app-force tracker'
##### OLD: alias review-screenshots='pushd "/my-data/AppData/Roaming/com.elance.tracker/Local Store/screenshots"; start .; copy --no-clobber * ~/essay-grading/old-screenshots; popd'
## alias review-screenshots='move --no-clobber "/my-data/AppData/Roaming/com.elance.tracker/Local Store/screenshots/"* old-screenshots; start old-screenshots'

# Andrid stuff
export OHARAWARE=~/android/oharaware
export TRANS_BY_IMAGE=$OHARAWARE/trans_by_image
export JOB_SEARCH_APP=$SANDBOX/job_search_app

## OLD: # Scan Maker
## OLD:### alias enable-scanner='E:\\WINDOWS\\twain_32\\ScanWiz5\\SDII.exe'
## OLD: alias enable-scanner='start-win32 E:\\WINDOWS\\twain_32\\ScanWiz5\\SDII.exe'
## OLD: alias config-scanner='start-win32 E:\\WINDOWS\\twain_32\\ScanWiz5\\MSC.exe'
## OLD: alias set-scanner='enable-scanner; config-scanner'

# System services
# TODO: use 'net start/stop' for services instead (eg, for more informative error messages)
alias stop-service='sc stop'
alias start-service='sc start'
function restart-service () { stop-service $1; sleep 3; start-service $1; }
alias restart-printer-spooler='restart-service spooler'
# check-service(function, arg1): issues warning if no arguments to FUNCTION (i.e., ARG1 empty)
function check-arg () { if [ "$2" == "" ]; then echo "WARNING: missing argument to $1"; fi; }
## BAD: function check-service () { check-arg $FUNCNAME $1; sc query | remove-cr | perlgrep -i -para $1; }
alias check-service-proper='sc query'
function check-service () { check-arg check-service $1; check-service-proper | remove-cr | perlgrep -i -para $1; }
alias query-service='check-service'
# TODO: handle services like beep that are not shown with 'sc query'
function query-service-alt () { \
  if [ "$1" = "" ]; then \
     check-service-proper; \
  else \
     check-service-proper "$1"; if [ $? != 0 ]; then query-service $1; fi; \
  fi; \
}

# Personal network stuff
other_host=tpo-unknown
if [ "$HOSTNAME" = "tpo-plata" ]; then
    export TORRE_C="//tpo-torre/it"
    export TORRE_D="//tpo-torre/Spare"
    export TORRE_F="//tpo-torre/backup"
## OLD: export TORRE_S="//tpo-torre/wd-3tb"
    export DATA="d:/data"
    other_host=tpo-torre
fi
## OLD
## if [ "$HOSTNAME" = "tpo-torre" ]; then
##     export PLATA_C="//tpo-plata/it"
##     export PLATA_D="//tpo-plata/spare"
##     export DATA="f:/data"
##     other_host=tpo-plata
## fi
if [ "$HOSTNAME" = "tpo-flaco" ]; then
    export FLACO_C="//tpo-plata/it"
    export DATA="c:/data"
    other_host=tpo-plata
fi
function net-use-other() { 
    echo connecting to $other_host it and spare shares
    net use k: /delete; 
    net use k: "\\\\$other_host\\it" /USER:tomohara /PERSISTENT:yes; 
    net use p: /delete;
    if [ "$other_host" != "tpo-flaco" ]; then
	net use p: "\\\\$other_host\\Spare" /USER:tomohara /PERSISTENT:yes;
	net use q: /delete; 
	net use q: "\\\\$other_host\\bd-rom" /USER:tomohara /PERSISTENT:yes; 
    fi
}
alias net-use-$other_host='net-use-other'


# Internet Explorer
# NOTE: The bookmarks must be exported from IE first (default is 'My Documents/bookmark.htm')
function view-bookmarks () { perl- bookmark2ascii.perl "$@" "$USERPROFILE/My Documents/bookmark.htm" | $PAGER; }

# Win32 helper functions
#
alias start-win32='cygstart'
alias start='start-win32'
## TODO: alias start-optional-file='start-win32 "$1" $(winpath "$2" 2>&1 > /dev/null)'
alias start-optional-file='start-win32 "$1" $(winpath "$2" 2>&1 > /dev/null)'
# TODO: rework start aliases for cygwin
# OLD: alias start-alt='cmd /c start'
#
# NOTE: winpath output quotes files with embedded spaces
function winpath () { cygpath.exe -wa "$@" | perl -pe 's/^(.* .*)$/"$1"/g;'; }
alias winpath-this-dir='winpath $PWD'
#
function start-win32- () { local path=`winpath "$1"`; start-win32 "$path"; }
function start-win32-app-over () { start-win32 "$1" `winpath "$2"`; }
function run-cygwin-app-over () { "$1" `winpath "$2"`; }
function run-win32-app-over () { `winpath "$1"` `winpath "$2"`; }
#
## function explore-dir () { start-win32 explorer `cygpath -w "$1"`; }
#
## OLD: function explore-dir () { local dir="$1"; if [ "$dir" = "" ]; then dir="."; fi; start-win32 explorer `cygpath -w "$dir"`; }
function explore-dir () { local dir="$1"; if [ "$dir" = "" ]; then dir="."; fi; start-win32 -o `cygpath -w "$dir"`; }
alias explore-this-dir='explore-dir "$PWD"'
#
## OLD: function dos-url-path () { cygpath -wa "$1" | perl -pe 's@\\@/@g; s@^@file:///@;'; }
## TODO: implement in terms of new url-path alias, which uses realpath
function dos-url-path () { cygpath -wa "$1" | perl -pe 's@\\@/@g;  s@^@file:///@; s/ /%20/g;'; }
## OLD: function firefox () { start firefox -new-window `dos-url-path "$1"`; }
function firefox () { start-alt firefox -new-window `dos-url-path "$1"`; }
alias start-firefox='firefox'
#
## OLD: function ie () { start iexplore `dos-url-path "$1"`; }
function ie-local () { start iexplore `dos-url-path "$1"`; }
function ie () { start iexplore "$1"; }
alias start-ie='ie'
#
X86_PROGRAM_FILES="$WINDRIVE:\\Program Files (x86)"
if [ ! -e "${X86_PROGRAM_FILES}" ]; then X86_PROGRAM_FILES="$WINDRIVE:\\Program Files"; fi
#
function foxit () { start "${X86_PROGRAM_FILES}\\Foxit Software\\Foxit Reader\\Foxit Reader.exe" `winpath "$@"`; }
#
## OLD: function kdiff() { start "${X86_PROGRAM_FILES}\\KDiff3\\kdiff3.exe" `winpath "$1"` `winpath "$2"`; }
PROGRAM_FILES="$WINDRIVE:\\Program Files"
function kdiff() { start "${PROGRAM_FILES}\\KDiff3\\kdiff3.exe" `winpath "$1"` `winpath "$2"`; }

alias vdiff=kdiff
## TODO: put kdiff3 in Programs-Misc
# variant of kdiff that puts second file in left window
# so that right is associated with more recent:
# note: uses diff convention that second file can just be specified with a directory name
# ex: kdiff-rev chord-meaning-ismir.tex backup
function kdiff-rev() { 
    local left_file="$2"
    local right_file="$1"
    if [ -d "$left_file" ]; then left_file="$left_file/$right_file"; fi
    start "${X86_PROGRAM_FILES}\\KDiff3\\kdiff3.exe" `winpath "$left_file"` `winpath "$right_file"`
}
#
function dev-cpp() { start "$WINDRIVE:\\Program-Misc\\Dev-Cpp\\devcpp.exe" `winpath "$1"`; }
#
function process-explorer() { start procexp; }
## OLDL alias process-stats="process-explorer"
# NOTE: do- prefix is relatively uncommon
alias do-process-explorer="process-explorer"
## OLD;
## function process-monitor() { start procmon64; }
## alias process-internals="process-monitor"
function monitor-processes() { start procmon64; }

# Setup HOME and WIN32HOME directories (for CygWin and GNU-ish Win32 programs)
# TODO: rename WIN32HOME to avoid possible confusion with WINDIR
if [ "$HOME" != "" ]; then export HOME=`cygpath -u "$HOME"`; fi

export WIN32HOME=`winpath $HOME`

# Other Windows-related settings
# NOTE: These must be quoted when used with commands (e.g., 'copy nifty-script.bat "$SENDTO"')
export MYDATA="${WINDRIVE}:"'\Documents and Settings\'"$USERNAME"
export MYDOCS="$MYDATA\My Documents"
export SENDTO="$MYDATA\SendTo"

# Music software related
## OLD (causes win32 python to preclude cygwin)
## lilypond_dir="/c/Program-Misc/music/lilypond"
## # note: workarooud problem with Cygwin version of lilypond
## if [ -d "$lilypond_dir" ]; then PATH="$lilypond_dir/usr/bin:$PATH"; fi

# Whatever
# TODO: put these elsewhere
alias win32-perl="$WINDRIVE:/perl -Ssw"
alias stop-update-server='net stop wuauserv'
alias stop-moto='kill-app-force MotoHelperAgent; kill-app-force MotoHelperService'
# OLD: alias net-use-torre="net use k: /delete; net use k: '\\tpo-torre\it' /USER:tomohara /PERSISTENT:yes; net use p: /delete; net use p: '\\tpo-torre\Spare' /USER:tomohara /PERSISTENT:yes"

# Get rid of stupid junk from cygwin bash
unset TEXDOCVIEW_dvi
unset TEXDOCVIEW_html
unset TEXDOCVIEW_pdf
unset TEXDOCVIEW_ps
unset TEXDOCVIEW_txt

# Make sure terminal set up properly (via sourcing of resize output)
do-resize

startup-trace "5. PATH=$PATH"

# TEMP HACK: force user to be tom_o
if [ "$HOST_NICKNAME" = "flaco" ]; then
    _old_USER=$USER
    export USER=tom_o
    echo "Warning: changed USER from '$_old_USER' to $USER'"
fi

echo "cygset out: USER='$USER'"

startup-trace out tpo-cygwin-setup.bash
