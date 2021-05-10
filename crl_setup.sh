#! /bin/csh -f
# Customizations for my environments (CRL specific)
#
# Used mainly by .cshrc
#

## set path = (~/bin /usr/local/bin/groff /usr/local/bin $path)
set path = (~/bin /usr/local/bin $path)

setenv TMPDIR ~/tmp
setenv LESS "-cXI-P--Less-- ?f%f:(stdin). ?e(END):?pb(%pb\%) ?m(%i of %m)..%t"
setenv PRINTER rex
setenv SHOW_WARNINGS 1
setenv DEFAULT_HOST corinth
# TODO: use `domainname` in .login
setenv DOMAINNAME crl.nmsu.edu
if (-e ~/.default_host) setenv DEFAULT_HOST `cat ~/.default_host`

setenv TEXINPUTS .:$HOME/TEX:/usr/local/teTeX-0.4/texmf/tex/latex/base

# Use the GNU versions of cp, mv & rm
# Also, copy preserves the date
alias delete "/usr/local/bin/rm -i"
alias copy "/usr/local/bin/cp -i -p"
alias move "/usr/local/bin/mv -i"
setenv LS "/usr/local/bin/ls"

if ($?OSTYPE == 0) setenv OSTYPE 'who-knows'
if ($OSTYPE == "solaris") then
    alias resize_ '~/bin/sol_resize >! $TEMP/resize.sh; source $TEMP/resize.sh'
endif

# Environment settings for MUC-related projects
# 
setenv CRLDIR /home/tipster
## setenv SKIP_POST 1
## setenv SKIP_SMORPH 1
setenv TAG_UPPERCASE 1
setenv QUINTUS_PROLOG_PATH /usr/local/bin/prolog
alias old_ne_settings 'unsetenv SKIP_SMORPH; unsetenv TAG_UPPERCASE'
alias new_ne_settings 'setenv SKIP_SMORPH 1; setenv TAG_UPPERCASE 1'
alias show_ne_settings 'printenv SKIP_SMORPH; printenv TAG_UPPERCASE; printenv SKIP_JUMAN; printenv MUC_DEBUG; printenv MUC_TRACE_LEVEL'
alias grep_garbage "perl -n -e 'print if /[\x01-\x7F][\x80-\xFF][\x01-\x7F]/; \!*'"

## alias set_display 'setenv DISPLAY CRL-XTERM10:0.0; printenv DISPLAY'
alias set_display 'setenv DISPLAY jw-hds:0.0; printenv DISPLAY'
## alias set_cs_display 'setenv DISPLAY monticello:0.0; printenv DISPLAY'
alias set_cs_display 'setenv DISPLAY aztec:0.0; printenv DISPLAY'
alias set_display_ 'setenv DISPLAY monticello:0.0; printenv DISPLAY'
alias set_home_display 'setenv DISPLAY ${REMOTEHOST}:0.0; printenv DISPLAY'
alias set_last_display 'setenv DISPLAY `cat ~/.old_current_display`; printenv DISPLAY'
alias rsession '( source ~/bin/set_display.sh; rsh -n \!:1 ~/bin/xsession.sh ) >&! rsession.log &'
## alias rsession '( source ~/bin/set_display.sh; rexec.sh \!:1 ~/bin/xsession.sh )'
alias rsession_ 'rsession $DEFAULT_HOST'
alias X 'setenv UNDER_X 1; startx >&! startx.log'

alias crl_load 'pushd /usr/local/scripts; ./crl_load; popd'

alias set_muc_debug 'setenv MUC_DEBUG 1; setenv MUC_TRACE_LEVEL 4; setenv | grep MUC_'
## alias muc_trace 'setenv MUC_DEBUG 1; setenv MUC_TRACE_LEVEL 3'
alias set_muc_trace 'setenv MUC_DEBUG 1; setenv MUC_TRACE_LEVEL \!:1; ; setenv | grep MUC_'
alias use_my_code 'setenv DONT_USE_MUC_PATH 1; prepend_path ~/muc/code;'
alias use_my_sp_code 'setenv DONT_USE_MUC_PATH 1; prepend_path ~/muc/sp_code;'
alias xcomp_tags 'compare_tags.sh \!:1.out keys/\!:1.key v'
alias comp_tags 'compare_tags.sh \!:1.out keys/\!:1.key nv \!:2*'
alias comp_tags_ 'compare_tags.sh \!:1.out keys/\!:1.key nv \!:2* > /dev/null'
## alias find_dates 'find_tagged_expr.pe TIMEX DATE \!*'
## alias find_times 'find_tagged_expr.pe TIMEX TIME \!*'
## alias find_money 'find_tagged_expr.pe ENUMEX MONEY \!*'
## alias find_percent 'find_tagged_expr.pe ENUMEX PERCENT \!*'
## alias find_people 'find_tagged_expr.pe ENAMEX PERSON \!*'
## alias find_orgs 'find_tagged_expr.pe ENAMEX ORGANIZATION \!*'
## alias find_locs 'find_tagged_expr.pe ENAMEX LOCATION \!*'
alias do_all_docs 'do_all_docs.sh \!* >&\! lst.\!:1 &'
alias issue 'echo Issuing: \!*; \!*'
alias tag_names 'tag_names.sh \!* >& \!:1.lst'

# Lexicon lookup's
#
alias fgrep_collins 'fgrep -i \!* ~/SPAN_MUC/old_test/collins/lex.data'
alias grep_collins 'gr \!* ~/SPAN_MUC/old_test/collins/lex.data'
alias old_sp_lookup '~/SPAN_MUC/old_test/lookup.sh \!*'

# Text processing
alias kwic 'kwicx -c 30 -k \!:* | sed -e "s/     */ /g" -e "s/^.*://g"'

#	Lisp stuff
# alias cl_man_ "/home/zakynthos1/acl4.2/lib/emacs/fi/clman /home/zakynthos1/acl4.2/lib/emacs/fi/clman.data \!:1"
alias cl_man_ "/usr/local/allegro-cl-4.2/lib/emacs/fi/clman /usr/local/allegro-cl-4.2/lib/emacs/fi/clman.data \!:1"
alias cl_man "cl_man_ \!:1 | less"
alias cl_apropos "grep -i \!:1 ~/tpo/clman.synopsis"
setenv lisp cl

#  GraphLing stuff
setenv GRAPHLING_HOME /home/graphling
setenv GRAPHLING $GRAPHLING_HOME
setenv COCOHOME $GRAPHLING_HOME/coco/
alias graphling_env 'unsetenv GRAPHLING_SETENV; source $GRAPHLING_HOME/UTILITIES/setenv.sh --script_dir $GRAPHLING_HOME/UTILITIES'
alias graphling_env_ 'unsetenv GRAPHLING_SETENV; source $GRAPHLING_HOME/TOM/UTILITIES/setenv.sh --script_dir $GRAPHLING_HOME/TOM/UTILITIES'
alias gl_env graphling_env
alias gl_env_ graphling_env_
alias gl_trace 'setenv DEBUG_LEVEL 5; setenv GRAPHLING_TRACE 1; unsetenv GRAPHLING_SETENV'
alias gl_untrace 'setenv DEBUG_LEVEL 3; unsetenv GRAPHLING_TRACE; unsetenv GRAPHLING_SETENV'
## append_path $COCOHOME

alias utils_get 'dobackup \!*; ftp_get -dir=/home/graphling/UTILITIES \!*; my_rehash'
alias utils_put 'ftp_put -dir=/home/graphling/UTILITIES \!*'
alias utils_get_ 'dobackup \!*; ftp_get -dir=/home/graphling/TOM/UTILITIES \!*; my_rehash'
alias utils_put_ 'ftp_put -dir=/home/graphling/TOM/UTILITIES \!*'

alias do_old_exp 'nice +19 ~/GRAPH_LING/do_old_exp.sh >&! old_exp.log &'
alias tag '$GRAPHLING_HOME/BrillTagger/Bin_and_Data/do_tagger.sh'
alias count_senses 'count_it.perl "[^ ]+#\d+"'

alias get_wn_defs 'get_defs.perl -base=\!:1_wn -words="\!:1" > ! \!:1_wn.post; less \!:1_wn.post'
alias get_ldoce_defs 'get_defs.perl -base=\!:1_ldoce -words="\!:1" -use_ldoce=1 > ! \!:1_ldoce.post; less \!:1_ldoce.post'
alias lsi_env 'append_path /home/graphling/TOOLS/LSI/LSI_BASE/bin'
alias ws_env 'graphling_env; setenv PERLLIB ~/WORD_SENSE/LEXREL:${PERLLIB}; setenv PATH ~/WORD_SENSE/LEXREL:${PATH}; rehash'
## alias ws_env_ 'ws_env; setenv ignore_lexrels 0; setenv binary_nodes 1; setenv bottom_up_links 0; setenv | grep -v "[A-Z]"'
alias ws_env_ 'ws_env; setenv skip_empirical 1; setenv binary_nodes 1; setenv bottom_up_links 0; setenv | grep -v "[A-Z]"'
alias yar_env 'graphling_env; dir_env ~/WORD_SENSE/YAROWSKY'
#	Artwork stuff
alias pl_apropos "grep -i \!:1 ~/tpo/prolog.synopsis"
alias swi-prolog "~/my_artwork/pl-2.1.14/src/pl -G24000 -L24000 -A24000"
setenv PLHOME /home/artwork/CODE/TestCurrent/pl-2.1.14
alias pl "$PLHOME/src/pl -G24000 -L24000 -A24000"
alias pl_ "$PLHOME/src/pl "
alias clone_cnv "if (! -e \!:2.cnv) cp \!:1.cnv \!:2.cnv; if (! -e \!:2.sp_act) cp \!:1.sp_act \!:2.sp_act; if (! -e \!:2_gold.cnv) cp \!:1_gold.cnv \!:2_gold.cnv; if (! -e \!:2.time) cp \!:1.time \!:2.time;"
# alias extract_dialog "extract_subfile.pe '^ *\([0-9]' '^ *([^0-9])' \!:1 | grep -v '^ *;' | grep -v '^ *$'"
alias clean_output 'sed -e "s/+beg_sim+/beg_sim/g" -e "s/+end_sim+/end_sim/g" -e "s/\([0-9][0-9]*[a-z][a-z]*,\)/\[\[u\1/g" < \!:1  >! \!:2 ; echo "." >>! \!:2'
alias do_artwork '~/my_artwork/do_artwork.sh debug \!:2* \!:1  >&\! \!:1.log &'
alias extract_times '~/my_artwork/artwork debug extract_time \!:2* \!:1  >&\! \!:1.time_out; less \!:1.time_out'
alias evaluate_times '~/my_artwork/artwork debug evaluate_times \!:2* \!:1  >&\! \!:1.eval; less \!:1.eval'
alias compare_times_ '~/my_artwork/artwork debug compare_times \!:3* \!:1 \!:2'
alias compare_times 'compare_times_ \!* >&\! temp_time.diff; less temp_time.diff'
alias validate_times '~/my_artwork/artwork compare_times \!:2* \!:1 \!:1'

#	Mikrokosmos stuff
alias concept_names_ "grep '(MAKE-FRAME' \!:1 | sed -e 's/^.*MAKE-FRAME \([^ ]*\) .*/\1/g' | sort"
alias concept_names "grep '(MAKE-FRAME' \!:1 | sed -e 's/^.*MAKE-FRAME \([^ ]*\) .*/\1/g' | sort >! \!:2"
alias grep_cats 'grep -v "[()]"'
alias grep_lex 'grep -h -i -B10 -A20 \!:* ~/Mikro/LexTool/?'
alias grep_lex_ 'grep -i -B10 -A20 \!:* ~/Mikro/LexTool/?'

#   Reference sources
alias websters 'websters_lookup.perl -pre_context=25 \!* | & less +26'
alias websters_ websters_lookup.perl
alias websters_pp 'websters_lookup.perl \!* | pp_websters.perl | less'
alias wpp websters_pp
## alias ldoce 'ldoce_lookup.sh \!* | sort -t_ -n +1 +2 | less'
alias ldoce 'ldoce_lookup.sh \!*'
alias ldoce_ex 'ldoce_lookup.sh --example \!* | less'
alias ldoce_ex_ 'ldoce_lookup.sh --example \!* | less -S'
alias collins collins_lookup.sh
alias wordnet 'wn \!* -synsn -synsv -synsa -synsr -g'
alias wordnet_ 'wn \!* -hypen -hypev -hypea -hyper -g'
# alias lookup 'ldoce \!* ; websters \!*'
# alias lookup_all 'ldoce \!* ; websters \!*; wordnet \!*'
alias wn16_env 'source ~/LANG_TOOLS/semantic_tool/WORDNET-1.6/wn16_setenv.sh'

#	Environment stuff
## setenv WNSEARCHDIR /usr/local/src/wordnet1.5/dict
## setenv WNSEARCHDIR /home/tomohara/WORDNET1.5/dict
setenv WNSEARCHDIR /usr/local/wordnet/dict
setenv WN_ADDSENSE 1
setenv PLHOME /home/artwork/CODE/TestCurrent/pl-2.1.14
setenv PERLLIB ~/bin
## setenv ARTWORK_HOME /home/tomohara/my_artwork
## setenv ARTWORK_HOME /home/tomohara/temp_artwork
setenv ARTWORK_SWI_HOME /home/tomohara/my_artwork/SWI_TEST
setenv ARTWORK_DEBUG 1
setenv ARTWORK_HOST hellespont
setenv ARTWORK_TIMEOUT 1800
## setenv ARTWORK_HOST zakynthos

# CRL misc stuff
#
alias tide_env 'source ~tide/src/sunos/sunos.config'
setenv LEFTYPATH /home/ursa/src/Support/graphviz/sol.sun4/bin

# Spanish Lexical stuff
#
setenv SPANISH_DICT ~/OLD_LEX/Spanish/Dictionary/spanish_english.dict
setenv SPANISH_IRREG_DICT ~/OLD_LEX/Spanish/Dictionary/spanish_irregular.dict
setenv ENGLISH_DICT ~/OLD_LEX/Spanish/Dictionary/english_spanish.dict
alias sp_lookup 'grep \!* $SPANISH_DICT'
alias slu 'grep ^\!* $SPANISH_DICT'
alias slu_ 'grep -w ^\!* $SPANISH_DICT'
alias slu_pp 'slu_ \!:1 | perl -Ssw pp_entry.perl >! \!:1.pp; viewfile \!:1.pp'
alias eng_lookup 'grep \!* $ENGLISH_DICT'
alias elu 'grep ^\!* $ENGLISH_DICT'
alias elu_ 'grep -w ^\!* $ENGLISH_DICT'
alias elu_pp 'elu_ \!:1 | perl -Ssw pp_entry.perl -spanish=0 >! \!:1.pp; viewfile \!:1.pp'
alias crl_sp_lookup 'perl -Ss spanish_lookup.perl'
alias spanish_lookup crl_sp_lookup
alias lookup_spanish crl_sp_lookup
alias sp_env 'setenv PERLLIB ~/LEX/Spanish/Dictionary:${PERLLIB}; setenv PATH ~/LEX/Spanish/Dictionary:${PATH}; rehash'
alias crl_slu 'crl_sp_lookup -single_line=0'

# Misc lexical lookup
#
alias latin_lookup 'zcat ~/DICT/latin.gz | grep ^\!*'
alias latin_lookup_ 'zcat ~/DICT/latin.gz | grep \!*'
alias roget_lookup 'grep -10 \!:1 ~/DICT/roget/thes1911.asc | less -p\!:1'

# Up the limits
limit datasize 512m
limit filesize 512m

## alias color_fvwm '~/bin/fvwm95-2 -f "FvwmM4 /home/tomohara/xfer/.fvwm2rc95" >&\! fvwm.log'
alias color_fvwm  '~/bin/fvwm95-2 -f "read .color_fvwm2rc95 " &'

## unfortunately this is too slow
## graphling_env

alias w_ 'finger .all'
alias whozon_ 'perl_ whozon.perl -finger_cmd=/usr/ucb/finger >! $TEMP/whozon.list; less $TEMP/whozon.list'

alias remote_quad 'remote_print -lexquad'

alias wp 'echo use xwp to run WordPerfect'
alias lynx 'lynx2-8.sunos4 -cookies -cfg=~/bin/lynx2-8.cfg'
## alias pine 'pine-bin.sunos'

setenv LYNX "lynx2-8.sunos4"

alias my_rup 'rup crete thessaly $HOST'
