#! /bin/csh -f
# Customizations for my environments (CRL specific)
#
# Used mainly by .cshrc
#

echo .cshrc-in stupid >> $HOME/cshrc.log
set path = (~/bin /usr/local/bin $path)
echo .cshrc-in stupid >> $HOME/cshrc.log

echo .cshrc-in stupid >> $HOME/cshrc.log
setenv TMPDIR ~/tmp
echo .cshrc-in stupid >> $HOME/cshrc.log
setenv LESS "-cXI-P--Less-- ?f%f:(stdin). ?e(END):?pb(%pb\%) ?m(%i of %m)..%t"
echo .cshrc-in stupid >> $HOME/cshrc.log
## setenv LESS "-c-P--Less-- ?f%f:(stdin). ?e(END):?pb(%pb\%) ?m(%i of %m)..%t"
echo .cshrc-in stupid >> $HOME/cshrc.log
setenv PRINTER sp4
echo .cshrc-in stupid >> $HOME/cshrc.log
setenv SHOW_WARNINGS 1
echo .cshrc-in stupid >> $HOME/cshrc.log
# TODO: use `domainname` in .login
echo .cshrc-in stupid >> $HOME/cshrc.log
setenv DOMAINNAME cs.nmsu.edu
echo .cshrc-in stupid >> $HOME/cshrc.log
setenv WWW_HOME http://www.cs.nmsu.edu
echo .cshrc-in stupid >> $HOME/cshrc.log
setenv FVWM_DEBUG 1
echo .cshrc-in stupid >> $HOME/cshrc.log

echo .cshrc-in stupid >> $HOME/cshrc.log
## alias set_display 'setenv DISPLAY CRL-XTERM8:0.0; printenv DISPLAY'
echo .cshrc-in stupid >> $HOME/cshrc.log
## alias set_cs_display 'setenv DISPLAY monticello:0.0; printenv DISPLAY'
echo .cshrc-in stupid >> $HOME/cshrc.log
## alias set_display 'setenv DISPLAY pylos:0.0; printenv DISPLAY'
echo .cshrc-in stupid >> $HOME/cshrc.log
alias set_display 'setenv DISPLAY jw-hds:0.0; printenv DISPLAY'
echo .cshrc-in stupid >> $HOME/cshrc.log
## alias set_cs_display 'setenv DISPLAY aztec:0.0; printenv DISPLAY'
echo .cshrc-in stupid >> $HOME/cshrc.log
alias set_cs_display 'setenv DISPLAY jw-hds:0.0; printenv DISPLAY'
echo .cshrc-in stupid >> $HOME/cshrc.log
alias set_display_ 'setenv DISPLAY monticello:0.0; printenv DISPLAY'
echo .cshrc-in stupid >> $HOME/cshrc.log
alias set_home_display 'setenv DISPLAY ${REMOTEHOST}:0.0; printenv DISPLAY'
echo .cshrc-in stupid >> $HOME/cshrc.log
alias set_last_display 'setenv DISPLAY `cat ~/.old_current_display`; printenv DISPLAY'
echo .cshrc-in stupid >> $HOME/cshrc.log

echo .cshrc-in stupid >> $HOME/cshrc.log
alias crl_load 'pushd /usr/local/scripts; ./crl_load; popd'
echo .cshrc-in stupid >> $HOME/cshrc.log

echo .cshrc-in stupid >> $HOME/cshrc.log
alias issue 'echo Issuing: \!*; \!*'
echo .cshrc-in stupid >> $HOME/cshrc.log

echo .cshrc-in stupid >> $HOME/cshrc.log
# Lexicon lookup's
echo .cshrc-in stupid >> $HOME/cshrc.log
#
echo .cshrc-in stupid >> $HOME/cshrc.log

echo .cshrc-in stupid >> $HOME/cshrc.log
#	Lisp stuff
echo .cshrc-in stupid >> $HOME/cshrc.log
## alias cl_man_ "/home/zakynthos1/acl4.2/lib/emacs/fi/clman /home/zakynthos1/acl4.2/lib/emacs/fi/clman.data \!:1"
echo .cshrc-in stupid >> $HOME/cshrc.log
if ($?ALLEGRO_CL_HOME == 0) setenv ALLEGRO_CL_HOME /local2/acl4.2/lib
echo .cshrc-in stupid >> $HOME/cshrc.log
alias cl_man_ "$ALLEGRO_CL_HOME/emacs/fi/clman $ALLEGRO_CL_HOME/emacs/fi/clman.data \!:1"
echo .cshrc-in stupid >> $HOME/cshrc.log
alias cl_man "cl_man_ \!:1 | less"
echo .cshrc-in stupid >> $HOME/cshrc.log
alias cl_apropos "grep -i \!:1 ~/tpo/clman.synopsis"
echo .cshrc-in stupid >> $HOME/cshrc.log

echo .cshrc-in stupid >> $HOME/cshrc.log
#  GraphLing stuff
echo .cshrc-in stupid >> $HOME/cshrc.log
setenv GRAPHLING_HOME /home/ch2/graphling
echo .cshrc-in stupid >> $HOME/cshrc.log
setenv GRAPHLING $GRAPHLING_HOME
echo .cshrc-in stupid >> $HOME/cshrc.log
setenv COCOHOME $GRAPHLING_HOME/coco/
echo .cshrc-in stupid >> $HOME/cshrc.log
setenv WNSEARCHDIR $GRAPHLING/TOOLS/WORDNET/dict
echo .cshrc-in stupid >> $HOME/cshrc.log
alias graphling_env 'source $GRAPHLING_HOME/UTILITIES/setenv.sh --script_dir $GRAPHLING_HOME/UTILITIES'
echo .cshrc-in stupid >> $HOME/cshrc.log
alias graphling_env_ 'source $GRAPHLING_HOME/TOM/setenv.sh --script_dir $GRAPHLING_HOME/TOM'
echo .cshrc-in stupid >> $HOME/cshrc.log
append_path $COCOHOME
echo .cshrc-in stupid >> $HOME/cshrc.log
alias do_old_exp 'nice +19 ~/GRAPH_LING/do_old_exp.sh >&! old_exp.log &'
echo .cshrc-in stupid >> $HOME/cshrc.log
alias tag '$GRAPHLING_HOME/BrillTagger/Bin_and_Data/do_tagger.sh'
echo .cshrc-in stupid >> $HOME/cshrc.log
alias count_senses 'count_it.perl "[^ ]+#\d+"'
echo .cshrc-in stupid >> $HOME/cshrc.log
alias lsi_env 'append_path /home/graphling/TOOLS/LSI/LSI_BASE/bin'
echo .cshrc-in stupid >> $HOME/cshrc.log
alias ws_env 'setenv PERLLIB ~/WORD_SENSE/LEXREL:${PERLLIB}; setenv PATH ~/WORD_SENSE/LEXREL:${PATH}; rehash'
echo .cshrc-in stupid >> $HOME/cshrc.log

echo .cshrc-in stupid >> $HOME/cshrc.log
#	Artwork stuff
echo .cshrc-in stupid >> $HOME/cshrc.log
alias pl_apropos "grep -i \!:1 ~/tpo/prolog.synopsis"
echo .cshrc-in stupid >> $HOME/cshrc.log
alias swi-prolog "~/my_artwork/pl-2.1.14/src/pl -G24000 -L24000 -A24000"
echo .cshrc-in stupid >> $HOME/cshrc.log
alias pl "~/my_artwork/pl-2.1.14/src/pl -G24000 -L24000 -A24000"
echo .cshrc-in stupid >> $HOME/cshrc.log
alias pl_ "~/my_artwork/pl-2.1.14/src/pl "
echo .cshrc-in stupid >> $HOME/cshrc.log
alias clone_cnv "if (! -e \!:2.cnv) cp \!:1.cnv \!:2.cnv; if (! -e \!:2.sp_act) cp \!:1.sp_act \!:2.sp_act; if (! -e \!:2_gold.cnv) cp \!:1_gold.cnv \!:2_gold.cnv; if (! -e \!:2.time) cp \!:1.time \!:2.time;"
echo .cshrc-in stupid >> $HOME/cshrc.log
# alias extract_dialog "extract_subfile.pe '^ *\([0-9]' '^ *([^0-9])' \!:1 | grep -v '^ *;' | grep -v '^ *$'"
echo .cshrc-in stupid >> $HOME/cshrc.log
alias clean_output 'sed -e "s/+beg_sim+/beg_sim/g" -e "s/+end_sim+/end_sim/g" -e "s/\([0-9][0-9]*[a-z][a-z]*,\)/\[\[u\1/g" < \!:1  >! \!:2 ; echo "." >>! \!:2'
echo .cshrc-in stupid >> $HOME/cshrc.log
alias do_artwork '~/my_artwork/do_artwork.sh debug \!:2* \!:1  >&\! \!:1.log &'
echo .cshrc-in stupid >> $HOME/cshrc.log
alias extract_times '~/my_artwork/artwork debug extract_time \!:2* \!:1  >&\! \!:1.time_out; less \!:1.time_out'
echo .cshrc-in stupid >> $HOME/cshrc.log
alias evaluate_times '~/my_artwork/artwork debug evaluate_times \!:2* \!:1  >&\! \!:1.eval; less \!:1.eval'
echo .cshrc-in stupid >> $HOME/cshrc.log
alias compare_times_ '~/my_artwork/artwork debug compare_times \!:3* \!:1 \!:2'
echo .cshrc-in stupid >> $HOME/cshrc.log
alias compare_times 'compare_times_ \!* >&\! temp_time.diff; less temp_time.diff'
echo .cshrc-in stupid >> $HOME/cshrc.log
alias validate_times '~/my_artwork/artwork compare_times \!:2* \!:1 \!:1'
echo .cshrc-in stupid >> $HOME/cshrc.log

echo .cshrc-in stupid >> $HOME/cshrc.log

echo .cshrc-in stupid >> $HOME/cshrc.log
alias remove_cr "dobackup \!:1; asc < backup/\!:1 >! \!:1"
echo .cshrc-in stupid >> $HOME/cshrc.log

echo .cshrc-in stupid >> $HOME/cshrc.log

echo .cshrc-in stupid >> $HOME/cshrc.log
#   Reference sources
echo .cshrc-in stupid >> $HOME/cshrc.log
alias find_entry "~/info/find_entry.pe \!*"
echo .cshrc-in stupid >> $HOME/cshrc.log
alias websters find_entry
echo .cshrc-in stupid >> $HOME/cshrc.log
alias ldoce ldoce_lookup.sh
echo .cshrc-in stupid >> $HOME/cshrc.log
alias collins collins_lookup.sh
echo .cshrc-in stupid >> $HOME/cshrc.log
alias wordnet 'wn \!* -hypen -g'
echo .cshrc-in stupid >> $HOME/cshrc.log

echo .cshrc-in stupid >> $HOME/cshrc.log
#	Environment stuff
echo .cshrc-in stupid >> $HOME/cshrc.log
setenv ARTWORK_SWI_HOME /home/tomohara/my_artwork/swi_test
echo .cshrc-in stupid >> $HOME/cshrc.log
setenv ARTWORK_DEBUG 1
echo .cshrc-in stupid >> $HOME/cshrc.log
setenv ARTWORK_HOST hellespont
echo .cshrc-in stupid >> $HOME/cshrc.log
setenv ARTWORK_TIMEOUT 1800
echo .cshrc-in stupid >> $HOME/cshrc.log
## setenv ARTWORK_HOST zakynthos
echo .cshrc-in stupid >> $HOME/cshrc.log

echo .cshrc-in stupid >> $HOME/cshrc.log
# Up the limits
echo .cshrc-in stupid >> $HOME/cshrc.log
limit datasize 150m
echo .cshrc-in stupid >> $HOME/cshrc.log
alias color_fvwm '~/bin/fvwm95-2 -f "FvwmM4 /home/tomohara/xfer/.fvwm2rc95" >&\! fvwm.log'
echo .cshrc-in stupid >> $HOME/cshrc.log

echo .cshrc-in stupid >> $HOME/cshrc.log
# CS-specific stuff
echo .cshrc-in stupid >> $HOME/cshrc.log
#
echo .cshrc-in stupid >> $HOME/cshrc.log
alias slc 'source /local/config/cshrc.\!:1'
echo .cshrc-in stupid >> $HOME/cshrc.log
## alias ftp_put 'perl -s ~/bin/ftp_put.pe \!*'
echo .cshrc-in stupid >> $HOME/cshrc.log
## alias ftp_get 'perl -s ~/bin/ftp_get.pe \!*'
echo .cshrc-in stupid >> $HOME/cshrc.log
alias tkdiff 'wish -f ~/bin/tkdiff \!* &'
echo .cshrc-in stupid >> $HOME/cshrc.log
setenv PERLLIB ~tomohara/bin
echo .cshrc-in stupid >> $HOME/cshrc.log
alias cs_setup source ~/bin/cs_setup.sh
echo .cshrc-in stupid >> $HOME/cshrc.log
alias do_setup 'source ~/bin/do_setup.sh; cs_setup'
echo .cshrc-in stupid >> $HOME/cshrc.log

echo .cshrc-in stupid >> $HOME/cshrc.log
# alias print_sp3 'a2ps \!* | lpr -Psp3'
echo .cshrc-in stupid >> $HOME/cshrc.log
# alias print_sp4 'a2ps \!* | lpr -Psp4'
echo .cshrc-in stupid >> $HOME/cshrc.log
# alias print 'a2ps \!* | lpr -Psp4; lpq -Psp4'
echo .cshrc-in stupid >> $HOME/cshrc.log
alias lpr4 'lpr -Plexquad'
echo .cshrc-in stupid >> $HOME/cshrc.log
alias print4 'print.sh -Plexquad'
echo .cshrc-in stupid >> $HOME/cshrc.log
alias print4q 'lpq -Plexquad'
echo .cshrc-in stupid >> $HOME/cshrc.log
alias printq 'lpq -Psp4'
echo .cshrc-in stupid >> $HOME/cshrc.log

echo .cshrc-in stupid >> $HOME/cshrc.log
alias gtar tar
echo .cshrc-in stupid >> $HOME/cshrc.log

echo .cshrc-in stupid >> $HOME/cshrc.log
if ($OSTYPE == linux) then
echo .cshrc-in stupid >> $HOME/cshrc.log
    alias lynx '$HOME/bin/lynx_2.7 -cfg=$HOME/bin/lynx_linux.cfg'
echo .cshrc-in stupid >> $HOME/cshrc.log
endif
echo .cshrc-in stupid >> $HOME/cshrc.log

echo .cshrc-in stupid >> $HOME/cshrc.log
if (`printenv LD_LIBRARY_PATH` == "") setenv LD_LIBRARY_PATH /usr/lib
echo .cshrc-in stupid >> $HOME/cshrc.log
setenv LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:/home/grad3/tomohara/lib:/home/grad3/tomohara/lib/X11
echo .cshrc-in stupid >> $HOME/cshrc.log

echo .cshrc-in stupid >> $HOME/cshrc.log
set autologout=6000
echo .cshrc-in stupid >> $HOME/cshrc.log
