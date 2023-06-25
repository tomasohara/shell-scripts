#! /bin/csh -f
# Customizations for my environments
#
# Used mainly by .cshrc
#
# note: assumes the following directories
#   ~/bin	scripts and other binary files
#   ~/src	source files
#   ~/temp	private temporary files
#   ~/mail      mail files
#   ~/info      personal information
#
# also, ~/bin is assumed to contain the following files
#   do_setup.sh  this script
#   all_script_alias.sh  aliases generated by stripping .perl & .sh in ~/bin
#   script_alias.sh      other script aliases
#
# set echo=1
# echo do_setup.sh

# Uncomment the following for .login/.cshrc tracing
startup-trace in do_setup.sh

# Alias for conditional sourcing of helper scripts
alias conditional-source 'if (-e \!:1) source \!:1'

# Aliases to invoke common scripts without extension.
# This file is automatically generated, some of them are overridden below
conditional-source ~/bin/all_script_alias.sh
conditional-source ~/bin/script_alias.sh
unalias foreach

# Remap cd, etc. to change the xterm title.
# Also, the title is set automatically so that an initial cd is not needed.
# The following is causing problems with less
#
if ($?TERM == 0) setenv TERM unknown
if (("$TERM" == "xterm") && ("$UNDER_EMACS" == "0")) then
    alias cd 'cd \!*; echo "]2;${HOST}:$cwd"'
    alias pushd 'pushd \!*; echo "]2;${HOST}:$cwd"'
    alias popd 'popd; echo "]2;${HOST}:$cwd"'
    ## echo "^[]2;${HOST}:$cwd^G"

    # The following is now causing problems with less
    ## cd .
endif

#	Test for changing the xterm title
alias cd0 'cd \!*; echo "]1;${HOST}:$cwd"'
alias newcd 'cd \!*; echo "]2;${HOST}:$cwd"'
alias pwd_ 'pwd; echo "]2;${HOST}:$cwd"'
alias pwd0 'pwd; echo "]1;${HOST}:$cwd"'
alias pwd1 'pwd; echo "]1;${HOST}"'
alias set_xterm_title 'echo "]2;\!*"'
alias set_xterm_title_ 'echo "]1;\!*"'
alias fix_remote 'conditional-source ~/check_remote.sh; conditional-source ~/.cshrc; cd .'

# CSH/TCSH settings
set history=500
set savehist=400
set noclobber
unset mail
set nobeep = 1


# Set the file creation mask to allow r access for the group members
## # (rw for user; none for group & others)
## umask 077
# (rw for user; r for group; none for others)
umask 027


# Set standard environment variables
setenv TMPDIR /tmp
setenv LESS "-cXI-P--Less-- ?f%f:(stdin). ?e(END):?pb(%pb\%) ?m(%i of %m)..%t"
setenv LESSCHARSET latin1
setenv PAGER less
alias zless 'zcat \!* | less'
setenv PERLLIB "$HOME/bin:"`printenv PERLLIB`
# Make sure OSTYPE is defined
if ("`printenv OSTYPE`" == "") setenv OSTYPE unknown
## setenv PRINTER lexdual
setenv PRINTER lexfine

# Set my environment variables (used in aliases below and in perl scripts)
setenv TEMP ~/temp
setenv DEBUG_MODE 1
setenv DEBUG_LEVEL 3

# define aliases for DOS commands
## OLD: alias cls clear
#alias dir 'ls -l -t'
alias dir 'ls -alt \!* | more'
alias dir_ 'ls -alt \!* | cut -c33-132 | more'

# define aliases for linux
if ($OSTYPE == "linux") then
    alias gtar tar
    alias gfind find
endif

# define a whole slew of other aliases
alias subdirs 'ls -alt \!* | grep ^d | more'
alias sublinks 'ls -alt \!* | grep ^l | more'
alias dirp 'dir \!* | $PAGER'
alias dir_ro 'dir \!* | grep -v "^.[^ ]*w[^ ]*" | more'
alias old_dir_rw 'dir \!* | grep rw | grep -v "^[dl]"'
alias dir_rw 'dir \!* | grep rw | grep -v "^[dl]" | grep -v "^\-r\-\-r\-\-r\-\-"'
alias show_ro dir_ro
alias show_rw dir_rw
## alias copy cp
## alias move mv
alias type cat
## alias ren 'mv'
alias nmake 'make'
alias start '\!*  &'

alias resize_ 'resize >! $TEMP/resize.sh; conditional-source $TEMP/resize.sh'

alias show_macros 'alias | grep \!*.'
alias do_setup 'conditional-source ~/bin/do_setup.sh'
alias all_setup 'conditional-source ~/.cshrc'
alias crl_setup 'conditional-source ~/bin/crl_setup.sh'
alias ed_setup 'em ~/bin/do_setup.sh'
alias ed_crl_setup 'em ~/bin/crl_setup.sh'
alias view_mail 'less ~/mail/CURRENT_MAIL'
alias view_mail_ 'zless ~/mail/OLD/mail_\!:1.gz'
alias view_mail_log 'less ~/mail/logged_messages'
alias view_mail_log_ 'zless ~/mail/OLD/logged_messages_\!:1.gz'
alias view_mail_aliases 'less ~/.mailrc'
alias summarize_mail 'egrep -h "^((From)|(Subject)|(Date)):" \!*'
alias mail_ "/usr/ucb/mail"
alias calc "echo \!* | bc -l"
alias old_perl_calc 'perl -e "print \!*;"'
alias perl_calc 'echo \!* | perl_ perlcalc.perl -'
alias perlcalc perl_calc
alias usage "du --kilobytes | sort -rn >&\! usage.list; less usage.list"

alias reminder 'echo TODO: \!* | mail -s "TODO: \!*" tomohara'
alias todo 'echo \!* \	`date` >>! ~/info/todo_list.text'
alias view_todo 'tail -r ~/info/todo_list.text | less -S'

# wrappers around count_it.perl (\x27 is a single quote "'")
## alias count_ext 'ls | count_it "\.([^.]*)\$"'
# NOTE: uses hokey "$ *" to get around stupid csh problem w/ $
alias count_exts 'ls | count_it "\.[^.]*$ *" | sort -rn'
alias count_words "count_it '[^\s.,\x27?]+' \!*"
alias count_words_i "count_it -i '[^\s.,\x27?]+' \!*"

#  other alias
alias ed 'emacs  \!* &'
alias em 'emacs  \!* &'
alias em_quick 'emacs -q \!* &'
alias em_debug 'emacs -debug-init \!* &'
alias em_fn 'emacs -fn "\!:1" \!:2* &'
alias em_small 'emacs -fn "-adobe-courier-bold-r-normal--12-120-75-75-m-70-iso8859-1" \!* &'
alias em_large 'emacs -fn "-adobe-courier-bold-r-normal--18-180-75-75-m-110-iso8859-1" -geometry 70x30 \!* &'
alias em_very_large 'emacs -fn "-adobe-courier-bold-r-normal--24-240-75-75-m-150-iso8859-1" -geometry 60x20 \!* &'
## alias nm 'nemacs \!* &'
alias mule '~cwang/local/bin/mule \!* &'
alias mule_ '~cwang/local/bin/mule \!* -l /usr/local/lib/emacs/lisp/local/nmsu-lisp.elc &'
alias repeat "\!-1:ags/\!:1/\!:2"
alias prepeat 'perl -e "\$last=\!-1; \$last =~ s/\!:1/\!:2/g; system("$last");'
## alias repeat_ '\!-1:ags/\!:1/\!:2'
## alias repeat_sg_ "\!-1:ags/1/2"

alias em_misc  'em_fn -misc-fixed-medium-r-normal--14-110-100-100-c-70-iso8859-1'
alias em_nw 'emacs --no-windows \!*'
alias gr 'grep -i -n ' 
alias gr_ 'grep -n '
alias gc 'grep -i -n \!* *.cxx *.c *.cpp' 
alias gc_ 'grep -n \!* *.cxx *.c *.cpp' 
alias gh 'grep -i -n \!* *.h'
alias gh_ 'grep -n \!* *.h'
alias gl 'grep -i -n \!* *.lsp *.lisp'
alias glx 'grep -i -n \!* *.lx *.lxx'
alias gp 'grep -i -n \!* *.pl *.plg *.plp' 
alias gp_ 'grep -n \!* *.pl *.plg *.plp' 
alias gu 'grep -c -i -n \!* | grep -v ":0"'
alias gv 'ghostview \!* &'
alias gv_ 'ghostview -magstep -2 \!* &'
alias perlgrep 'perl -n -e "print if /\!:1/i;" \!:2*'
alias perlgrep_ 'perl -n -e "print if \!:1;" \!:2*'
alias h 'history 50'
alias hist 'history'
alias xm 'xman &'
alias xt 'xterm &'
alias findspec 'find \!:1 -name \*\!:2\* \!:3* -print'
alias findspec2 'find \!:1 -name \*\!:2\* -print \!:3*'
alias findspec_ 'find \!:1 -name \!:2 \!:3* -print'
## alias findgrep 'find \!:1 -name \*\!:2\* -print -exec grep \!:3* {}\;\;'
alias findgrep 'find \!:1 -name \*\!:2\* -print -exec grep -i \!:3* \{\} \;'
alias findgrep_ 'find \!:1 -name \!:2 -print -exec grep -i \!:3* \{\} \;'
alias mt 'mailtool &'
alias xtr 'xterm -e rlogin \!* &'
alias gind 'cp \!:1 ~/temp/gind.TEMP; gindent -kr -ts4 ~/temp/gind.TEMP; cat ~/temp/gind.TEMP';
alias show_path 'printenv PATH'
alias show_time '/usr/bin/date'
alias ppsgml 'ppsgml.pe \!:1 | less'
## alias tkd 'tkdiff \!* &'
## alias tkdiff 'tkdiff \!* &'
## alias tkdiff_ tkdiff
alias wide_diff 'diff --ignore-all-space --side-by-side --width=160 \!*'
alias wide_diff_ 'wide_diff \!* >&! /tmp/$$; em /tmp/$$'
alias make_tar 'find . -maxdepth 1 -type f -print | gtar cvfTz \!:1 -'

alias printq 'lpq -P$PRINTER'

alias qui 'qui \!* &'

alias gsort sort

# RSC stuff
#
# alias get 'co'
alias get 'co -M \!:*'
alias get_ 'get \!:*; chmod +w \!:*'
alias qget get_
## alias put 'rcs -l \!:*; echo "." | ci -u -t"" \!:*'
alias put 'rcs -l \!:*; ci -u -m"." -t-"." \!:*'
alias full_put "rcs -l \!:2*; ci -u -m'\!:1' -t-'.' \!:2*"
## alias qput 'rcs -l \!:*; echo "." | ci -u -t-"" \!:* ; chmod +w \!:*'
alias qput 'rcs -l \!:*; ci -u -m"." -t-"." \!:* ; chmod +w \!:*'
alias lock 'rcs -l'
alias put_each "foreach.sh ""'""put"' $f'"'"
alias qput_each "foreach.sh ""'""qput"' $f'"'"
alias rcs_status 'rlog  -L  -l  RCS/*'
alias rcs_synch 'co -M RCS/*,v'
alias do_rcsdiff 'do_rcsdiff.sh >&\! rcsdiff.list; viewfile rcsdiff.list'

#alias append_path 'setenv PATH $PATH:\!:1'
#alias prepend_path 'setenv PATH \!:1:$PATH'
#alias append_path 'set _dir_=\!:1; setenv PATH $(PATH):$(_dir_); unset _dir_'
alias append_path 'setenv PATH ${PATH}:\!:1; rehash'
#alias prepend_path 'setenv PATH \!:1:${PATH}'
alias prepend_path 'set _dir_ = \!:1; setenv PATH ${_dir_}:${PATH}; unset _dir_; rehash'
alias prepend_perl_path 'set _dir_ = \!:1; setenv PERLLIB ${_dir_}:${PERLLIB}; unset _dir_'
alias my_rehash 'chmod +x *.sh *.pe *.prl *.perl; rehash'

#	Make it harder to "accidentally" delete or overwrite files
alias rm "echo rm is too wicked, so command not issued: rm \!*"
alias mv "echo mv is too wicked, so command not issued: mv \!*"
alias cp "echo cp is too wicked, so command not issued: cp \!*"
alias delete "/bin/rm -i"
alias copy "/bin/cp -i -p"
alias move "/bin/mv -i"
alias rename "move"
alias ren "move"
alias del "delete"

#	System, processes, etc.
alias kill_em "ps | grep \!:1 | sed -e 's/ .*//g' | sed -e 's/^/kill -9 /g' >! ~/bin/kill_em.sh ; conditional-source ~/bin/kill_em.sh"
alias old_ps_by_size "ps auxg | cut -c1-15,25-128 | sort -n -r +2 | less"
alias ps_by_size "perl_ ps_sort.perl -by=sz | less"
alias new_ps_by_size "perl_ ps_sort.perl -by=sz -num_times=50"
alias ps_by_cpu "perl_ ps_sort.perl -by=cpu | less"
alias new_ps_by_cpu "perl_ ps_sort.perl -by=cpu -num_times=50"
alias ps_by_size_ "ps -efl | sort -n -r +9 | less"
alias ps_sort "perl_ ps_sort.perl -num_times=60 -by=\!:1 \!:2*"
alias mem_in_use "ps auxg | cut -c25-29 | sum_file.pe"
alias mem_used_by "ps auxg | grep \!:1 | cut -c25-29 | sum_file.pe"
alias whozon 'perl_ whozon.perl | sort >! $TEMP/whozon.list; less -S $TEMP/whozon.list'
alias whozon_ 'whozon | grep -i \!* | less'

#       Make stuff
alias viewfile 'set viewer = less; if (`wc -l < \!:1` < 50) set viewer = more; $viewer \!:1'
alias do_make0 'make -n \!* >&\! make.log; viewfile make.log'
alias do_make 'cat make.log >>&\! old_make.log; make \!* >&\! make.log; viewfile make.log'

#       TEX stuff
alias do_tex 'do_tex.sh'
## alias do_tex 'echo r | latex \!:1.tex; dvips -o \!:1.ps \!:1.dvi; gv \!:1.ps'
alias do_slitex 'echo r | slitex \!:1.tex; dvips -o \!:1.ps \!:1.dvi; gv \!:1.ps'
alias do_tex_ 'echo r | latex \!:1.tex; dvips -o \!:1.ps \!:1.dvi'
## alias my_spell 'touch \!:1.spell; spell +\!:1.spell'
alias old_spell_tex 'detex \!:1.tex | perl_ spell.perl -spell_file=\!:1.spell | sort'
alias spell_tex 'do_tex \!:1; dvi2tty -w 132 \!:1.dvi | perl -p -e "s/\*\n//; s/^ \*//; s/\-\n//;" >! \!:1.tty; perl_ spell.perl -spell_file=\!:1.spell \!:1.tty | sort'
alias spell_tex_ '(spell_tex \!:1) |& less'

# File conversions
alias asc_it "dobackup \!:1; asc < BACKUP/\!:1 >! \!:1"
# alias remove_cr 'tr -d "\r"'
# alias remove_cr_it 'dobackup \!:1; remove_cr < backup/\!:1 >! \!:1'
alias old_remove_cr 'perl -i.bak -pn -e "s/\r//;"'
alias remove_cr 'perl -pe "s/\r//g;"'

# More misc
alias old_asc 'perl -p -e "s/[^\x20-\x7F\x0D\x0A\x09]//g;" '
alias xv 'xv \!* &'
alias xv_ 'xv_solaris \!* &'
alias lookup_mail_alias 'grep -i \!* ~/.pine_addressbook'
alias lookup_mail_alias_ 'grep -i \!* ~/.mailrc'
alias mail_alias lookup_mail_alias
alias lynx_bookmarks_ 'perl_ bookmark2ascii.perl ~/lynx_bookmarks.html'
alias lynx_bookmarks 'lynx_bookmarks_ | less'
alias lynx_book_marks_ lynx_bookmarks_
alias lynx_book_marks lynx_bookmarks
alias view_bookmarks_ 'perl_ bookmark2ascii.perl ~/lynx_bookmarks.html ~/.netscape/bookmarks.html'
alias view_bookmarks 'view_bookmarks_ | less'
alias view_book_marks view_bookmarks
alias view_book_marks_ view_bookmarks_
alias lookup_bookmark 'view_bookmarks_ | grep -A1 \!*'
alias lookup_lynx_bookmark 'lynx_bookmarks_ | grep -A1 \!*'
alias lynx_dump 'echo \!:1 >&! \!:2; lynx -dump -nolist -width=256 \!:1 >> \!:2; less \!:2'

alias purify_on 'setenv PURIFYOPTIONS -windows=yes'
alias purify_off 'setenv PURIFYOPTIONS -windows=no'

alias rtf2latex rtf2LaTeX

alias xmodmap_caps 'xmodmap ~/.xmodmap_caps'
alias xmodmap_all 'xmodmap ~/.xmodmap_all'
alias xmodmap_sun 'xmodmap ~/.xmodmap_sun'

alias check_weather_ 'cat ~/temp/new_weather.log >>! ~/temp/weather.log; lynx -dump http://wrcc.sage.dri.edu/ldm/stateob/nmextemps >&! ~/temp/new_weather.log; less ~/temp/new_weather.log'
alias old_check_weather 'lynx -dump http://wrcc.sage.dri.edu/ldm/stateob/nmextemps |& less'
alias check_weather "lynx -dump 'http://www.wunderground.com/cgi-bin/findweather/getForecast?query=Las+Cruces%2C+NM' | less"

alias fix_keyboard 'kbd_mode -a'

alias cd_env 'setenv PERLLIB `pwd`:${PERLLIB}; setenv PATH `pwd`:${PATH}; rehash'
alias dir_env 'set _dir=\!:1; setenv PERLLIB {$_dir}:${PERLLIB}; setenv PATH ${_dir}:${PATH}; unset _dir; rehash'

alias rtop 'rsh \!:1 top 50 | less'

# Netscape aliases and support
alias ns 'netscape &'
alias nav 'nice +10 navigator &'
set cache_file = "/tmp/$USER/.netscape/cache"
if (! (-e ${cache_file})) then
    mkdir -p /tmp/$USER/.netscape/cache
endif
chmod go-rwx /tmp/$USER

alias latex2html '~/src/latex2html-98.1p1/latex2html'
## alias latex2html '~/src/latex2html-97.1/latex2html'
alias old_latex2html '~/src/latex2html-97.1/latex2html'
alias old_latex2html_ '~/src/latex2html-97.1/latex2html -address "" -my_bottom_navigation'
alias latex2html_ '~/src/latex2html-98.1p1/latex2html -local_icons -address ""'

alias fix_sh 'perl -i -pn -e "s#/bin/csh#/bin/csh#"'

# Information management stuff
# Requires version 4.0 or higher of glimpse
#
## alias index_files 'nice +19 glimpseindex -H . -i -w 1000 . >&! .glimpse_out &'
alias index_dir 'nice +19 glimpseindex -H . -i -w 1000  \!:1 >&! .glimpse_out &'
alias index_files 'index_dir .'
alias index_all_files 'index_dir ~'
alias glimpse_info 'glimpse -H ~/info'
alias mdir_od 'mdir | cut -c24-80 | sort -r | less'

alias anon_ftp_get 'ftp_get -user=anonymous'
alias set_current_display 'setenv DISPLAY \!:1; chmod +w ~/.current_display; echo \!:1 >! ~/.current_display; chmod -w ~/.current_display'

alias xsession 'conditional-source ~/bin/xsession.sh -q'

alias color_fvwm95 '$HOME/bin/fvwm95-2 -f "read $HOME/.color_fvwm2rc95"'
alias mono_fvwm95 '$HOME/bin/fvwm95-2 -f "read $HOME/.mono_fvwm2rc95"'

alias make_tar_ 'gfind . -name \*\!:1 -mtime -\!:2 | gtar cvfzT \!:3.tar.gz -'
alias make_recent_tar 'find . -mtime -\!:2 -type f | tar cvfzT \!:1 -'
alias glob_subdirs 'find . -mindepth 1 -maxdepth 1 -type d | sed -e "s/.\///g"'
alias glob_links 'find . -maxdepth 1 -type l | sed -e "s/.\///g"'

alias count_sense "count_it 'sense=(\d+)'"

alias asctime 'perl -e "print (scalar localtime(\!:1));"; echo ""'

alias printenv_lower "printenv | grep '^[a-z]'"

alias grep_ps 'perl -p -e "s/^.* (\S+\.ps).*/\1/;" \!:1 | grep .ps'

alias processor_status 'mpstat'

alias color_fvwm95 '$HOME/bin/fvwm95-2 -f "read $HOME/.color_fvwm2rc95" >>&! $HOME/color_fvwm95.log &'
alias mono_fvwm95 '$HOME/bin/fvwm95-2 -f "read $HOME/.mono_fvwm2rc95" >>&! $HOME/mono_fvwm95.log &'

alias ps_rsh 'ps_mine | grep rsh'

# alias for counting words on individual lines thoughout a file
# (Gotta hate csh)
alias line_wc 'perl -n -e '"'"'@_ = split; print "$#_\t$_";'"'"' \!*'

alias parse_mail 'perl -Ss parse_mail.perl -batch >>& ~/parse_mail.log'
alias group_members 'ypcat group | grep \!:1'

alias print_numbers "perl -e '" 'for($i=0;$i<\!:1;$i++) {print $i; ' 'print " ";} print "\n";' "'"

alias pine_ 'pine -folder-collections=$PWD/\[\]'

alias check_class_dist 'perl_ count_it.perl "^(\S+)\t" \!:1 | perl_ calc_entropy.perl -'

alias fix_dir_permissions 'find . -type d -exec chmod go+xs {} \;'

alias 2bib bibitem2bib

alias show_path 'printenv PATH | perl -pe "s/:/\n/g;" | less'

alias transcript typescript

# GNU C compiler aliases
# gcc options:
# 	-g	produce debugging information
#	-pedantic	Issue all the  warnings  demanded  by  strict  ANSI standard  C; reject all programs that use forbidden extensions.
#	-Wall	issue all types of warning
#	-O	optimize (needed for catching unitialized variables -Wuninitialized)
alias compile 'gcc -pedantic -g -Wall -o `basename \!:1 .c` \!:1'
alias debug_compile compile
alias math_compile 'gcc -pedantic -lm -g -Wall -o `basename \!:1 .c` \!:1'
alias release_compile 'gcc -O -pedantic -D NDEBUG -Wall -o `basename \!:1 .c` \!:1'

# CS 167/467 stuff
# TODO: define alias for invoking Netscape composed with course page index
alias print_course_page 'echo $HOME/html/cs167-467/index.html'

# GraphLing environment
# NOTE: This is used mainly for running simple experiments with the classifier
# without the graphical-model search.
setenv UTILITIES /home/graphling/USERS/TOM/UTILITIES
alias wsd_status 'perl_ foreach.perl -remote -busy_load=9 -no_files -d=4 "perl -sw $UTILITIES/wsd_status.perl"'
alias wsd_status_ 'perl_ foreach.perl -remote -busy_load=9 -no_files -d=4 -hostlist="\!*" "perl_ $UTILITIES/wsd_status.perl"'
alias wsd_kill 'perl_ foreach.perl "rsh -n &F kill_em.sh --graphling" \!*'
#
alias graphling_env 'set force_setenv=1; conditional-source $UTILITIES/setenv.sh; unset force_setenv'
alias main_graphling_env 'set force_setenv=1; set script_dir=$GRAPHLING_HOME/UTILITIES; setenv SCRIPT_DIR /home/graphling/UTILITIES/; conditional-source /home/graphling/UTILITIES/setenv.sh; unset force_setenv'
if ($?GRAPHLING_HOME == 0) setenv GRAPHLING_HOME /home/graphling
set script_dir=$UTILITIES
if ($?SKIP_GRAPHLING == 0) setenv SKIP_GRAPHLING 0
if ($OSTYPE == "solaris") then
    setenv SKIP_GRAPHLING 1
endif
if ($SKIP_GRAPHLING == 0) then
    conditional-source ${script_dir}/setenv.sh
endif
## echo "initial PATH=$PATH"
## setenv PATH ${script_dir}:$PATH

# WordNet settings
alias xw 'xwordnet &'
## source /home/ch2/graphling/TOOLS/WORDNET-1.6/wn16_setenv.sh
alias wn16_setenv 'conditional-source /home/ch2/graphling/TOOLS/WORDNET-1.6/wn16_setenv.sh'
alias wn171_setenv 'conditional-source /home/ch2/graphling/TOOLS/WORDNET-1.7.1/wn171_setenv.sh'
wn171_setenv

# Optional end tracing
startup-trace out do_setup.sh