#! /bin/csh -f
# Customizations for my environments (CRL specific)
#
# Used mainly by .cshrc
#

set path = (~/bin /usr/local/bin $path)

setenv TMPDIR ~/tmp
setenv LESS "-cXI-P--Less-- ?f%f:(stdin). ?e(END):?pb(%pb\%) ?m(%i of %m)..%t"
## setenv LESS "-c-P--Less-- ?f%f:(stdin). ?e(END):?pb(%pb\%) ?m(%i of %m)..%t"
setenv PRINTER lexquad
## setenv PRINTER lexdraft
setenv SHOW_WARNINGS 1
# TODO: use `domainname` in .login
setenv DOMAINNAME cs.nmsu.edu
setenv WWW_HOME http://www.cs.nmsu.edu
setenv FVWM_DEBUG 1

setenv TEXINPUTS .:$HOME/LATEX:/local/teTeX/texmf/tex/latex/base

# Unable to convert: alias gtar_tvfz 'zcat \!:1 | gtar tvf - \!:2*'
# Unable to convert: alias gtar_xvfz 'zcat \!:1 | gtar xvf - \!:2*'

## alias set_display 'setenv DISPLAY CRL-XTERM8:0.0; printenv DISPLAY'
## alias set_cs_display 'setenv DISPLAY monticello:0.0; printenv DISPLAY'
## alias set_display 'setenv DISPLAY pylos:0.0; printenv DISPLAY'
alias set_display="setenv DISPLAY jw-hds:0.0; printenv DISPLAY"
## alias set_cs_display 'setenv DISPLAY aztec:0.0; printenv DISPLAY'
alias set_cs_display="setenv DISPLAY jw-hds:0.0; printenv DISPLAY"
alias set_display_="setenv DISPLAY monticello:0.0; printenv DISPLAY"
alias set_home_display="setenv DISPLAY ${REMOTEHOST}:0.0; printenv DISPLAY"
alias set_last_display="setenv DISPLAY `cat ~/.old_current_display`; printenv DISPLAY"

alias crl_load="pushd /usr/local/scripts; ./crl_load; popd"

function issue () { echo Issuing: $*; $* }

# Lexicon lookup's
#

#	Lisp stuff
## alias cl_man_ "/home/zakynthos1/acl4.2/lib/emacs/fi/clman /home/zakynthos1/acl4.2/lib/emacs/fi/clman.data \!:1"
if ($?ALLEGRO_CL_HOME == 0) setenv ALLEGRO_CL_HOME /local2/acl4.2/lib
function cl_man_ () { $ALLEGRO_CL_HOME/emacs/fi/clman $ALLEGRO_CL_HOME/emacs/fi/clman.data $1 }
function cl_man () { cl_man_ $1 | less }
function cl_apropos () { grep -i $1 ~/tpo/clman.synopsis }

#  GraphLing stuff
setenv GRAPHLING_HOME /home/ch2/graphling
setenv GRAPHLING $GRAPHLING_HOME
## setenv COCOHOME $GRAPHLING_HOME/coco/
setenv WNSEARCHDIR $GRAPHLING/TOOLS/WORDNET/dict
## alias graphling_env 'unsetenv GRAPHLING_SETENV; source $GRAPHLING_HOME/UTILITIES/setenv.sh --script_dir $GRAPHLING_HOME/UTILITIES'
## alias graphling_env_ 'unsetenv GRAPHLING_SETENV; source $GRAPHLING_HOME/TOM/setenv.sh --script_dir $GRAPHLING_HOME/TOM'
alias graphling_env="unsetenv GRAPHLING_SETENV; source $GRAPHLING_HOME/UTILITIES/setenv.sh --script_dir $GRAPHLING_HOME/UTILITIES; source $GRAPHLING_HOME/UTILITIES/set_aliases.sh"
alias graphling_env_="unsetenv GRAPHLING_SETENV; source $GRAPHLING_HOME/TOM/UTILITIES/setenv.sh --script_dir $GRAPHLING_HOME/TOM/UTILITIES"
alias gl_env='graphling_env'
alias gl_env_='graphling_env_'
alias gl_trace="setenv DEBUG_LEVEL 5; setenv GRAPHLING_TRACE 1; unsetenv GRAPHLING_SETENV"
## append_path $COCOHOME
function do_old_exp () { nice +19 ~/GRAPH_LING/do_old_exp.sh >&\! old_exp.log & }
alias tag="$GRAPHLING_HOME/BrillTagger/Bin_and_Data/do_tagger.sh"
alias count_senses='perl_ count_it.perl "[^ ]+#\d+"'
alias lsi_env="append_path /home/graphling/TOOLS/LSI/LSI_BASE/bin"
alias ws_env="setenv PERLLIB ~/WORD_SENSE/LEXREL:${PERLLIB}; setenv PATH ~/WORD_SENSE/LEXREL:${PATH}; rehash"

#	Artwork stuff
function pl_apropos () { grep -i $1 ~/tpo/prolog.synopsis }
alias swi-prolog="~/my_artwork/pl-2.1.14/src/pl -G24000 -L24000 -A24000"
alias pl="~/my_artwork/pl-2.1.14/src/pl -G24000 -L24000 -A24000"
alias pl_="~/my_artwork/pl-2.1.14/src/pl "
function clone_cnv () { if (! -e $2.cnv) cp $1.cnv $2.cnv; if (! -e $2.sp_act) cp $1.sp_act $2.sp_act; if (! -e $2_gold.cnv) cp $1_gold.cnv $2_gold.cnv; if (! -e $2.time) cp $1.time $2.time; }
# alias extract_dialog "extract_subfile.pe '^ *\([0-9]' '^ *([^0-9])' \!:1 | grep -v '^ *;' | grep -v '^ *$'"
function clean_output () { sed -e "s/+beg_sim+/beg_sim/g" -e "s/+end_sim+/end_sim/g" -e "s/\([0-9][0-9]*[a-z][a-z]*,\)/\[\[u\1/g" < $1  >! $2 ; echo "." >>! $2 }
# Unable to convert: alias do_artwork '~/my_artwork/do_artwork.sh debug \!:2* \!:1  >&\! \!:1.log &'
# Unable to convert: alias extract_times '~/my_artwork/artwork debug extract_time \!:2* \!:1  >&\! \!:1.time_out; less \!:1.time_out'
# Unable to convert: alias evaluate_times '~/my_artwork/artwork debug evaluate_times \!:2* \!:1  >&\! \!:1.eval; less \!:1.eval'
# Unable to convert: alias compare_times_ '~/my_artwork/artwork debug compare_times \!:3* \!:1 \!:2'
function compare_times () { compare_times_ $* >&\! temp_time.diff; less temp_time.diff }
# Unable to convert: alias validate_times '~/my_artwork/artwork compare_times \!:2* \!:1 \!:1'


function remove_cr () { dobackup $1; asc < backup/$1 >! $1 }


#   Reference sources
function find_entry () { ~/info/find_entry.pe $* }
alias websters='find_entry'
alias ldoce='ldoce_lookup.sh'
alias collins='collins_lookup.sh'
function wordnet () { wn $* -hypen -g }
function websters () { perl_ websters_lookup.perl -pre_context=25 $* | & less +26 }
alias websters_='perl_'
function websters_pp () { perl_ websters_lookup.perl $* | perl_ pp_websters.perl | less }
alias wpp='websters_pp'

# Bilingual dictionaries
function german_lookup_ () { zgrep $* ~/Multilingual/German/german_english.dict }
function german_lookup () { zgrep -w -i ^$* ~/Multilingual/German/german_english.dict }
alias german_='german_lookup_'
alias german='german_lookup'

function french_lookup_ () { zgrep $* ~/Multilingual/French/french_english.dict }
function french_lookup () { zgrep -w -i ^$* ~/Multilingual/French/french_english.dict }
alias french_='french_lookup_'
alias french='french_lookup'

function italian_lookup_ () { zgrep $* ~/Multilingual/Italian/italian_english.dict }
function italian_lookup () { zgrep -w -i ^$* ~/Multilingual/Italian/italian_english.dict }
alias italian_='italian_lookup_'
alias italian='italian_lookup'

setenv SPANISH_DICT ~/Multilingual/Spanish/spanish_english.dict
function spanish_lookup_ () { zgrep $* $SPANISH_DICT }
function spanish_lookup () { zgrep -w -i ^$* $SPANISH_DICT }
alias spanish_='spanish_lookup_'
alias spanish='spanish_lookup'

function multi_lookup_ () { zgrep $* ~/Multilingual/Multi/multilingual.dict }
function multi_lookup () { zgrep -w -i ^$* ~/Multilingual/Multi/multilingual.dict }

#	Environment stuff
setenv ARTWORK_SWI_HOME /home/tohara/my_artwork/swi_test
setenv ARTWORK_DEBUG 1
setenv ARTWORK_HOST hellespont
setenv ARTWORK_TIMEOUT 1800
## setenv ARTWORK_HOST zakynthos

# Up the limits
limit datasize 150m
function color_fvwm () { ~/bin/fvwm95-2 -f "FvwmM4 /home/tohara/xfer/.fvwm2rc95" >&\! fvwm.log }

# CS-specific stuff
#
function slc () { source /local/config/cshrc.$1 }
## alias ftp_put 'perl -s ~/bin/ftp_put.pe \!*'
## alias ftp_get 'perl -s ~/bin/ftp_get.pe \!*'
## alias tkdiff 'wish -f ~/bin/tkdiff \!* &'
setenv PERLLIB ~tohara/bin
alias cs_setup='source'
alias do_setup="source ~/bin/do_setup.sh; cs_setup"

# alias print_sp3 'a2ps \!* | lpr -Psp3'
# alias print_sp4 'a2ps \!* | lpr -Psp4'
# alias print 'a2ps \!* | lpr -Psp4; lpq -Psp4'
alias lpr4="lpr -Plexquad"
alias print4="print.sh -Plexquad"
alias print4q="lpq -Plexquad"
alias printq="lpq -Psp4"

alias gtar='tar'

if ($?OSTYPE == 0) setenv OSTYPE 'who-knows'
if ($OSTYPE == linux) then
alias lynx_="$HOME/bin/lynx_2.8 -cookies -use_mouse -cfg=$HOME/bin/lynx_linux.cfg"
endif

if (`printenv LD_LIBRARY_PATH` == "") setenv LD_LIBRARY_PATH /usr/lib
setenv LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:$HOME/lib:$HOME/lib/X11

set autologout=6000
alias add_floppy='volrmmount'
alias add_floppy_='volcheck'
alias 'remove_floppy='volrmmount'
alias lex_put="ftp_put -dir=LEX/REF_PAPERS"
unalias mail

alias wb_rup='perl -Ssw foreach.perl -HOST=medusa -remote -busy_load=5 -no_files "uptime"'
alias lin_rup='perl -Ssw foreach.perl -HOST=ursa -remote -busy_load=5 -no_files "uptime"'

function utils_get () { dobackup $*; ftp_get -dir=/home/graphling/UTILITIES $*; my_rehash }
function utils_put () { ftp_put -dir=/home/graphling/UTILITIES $* }
function utils_get_ () { dobackup $*; ftp_get -dir=/home/graphling/TOM/UTILITIES $*; my_rehash }
function utils_put_ () { ftp_put -dir=/home/graphling/TOM/UTILITIES $* }

alias calc='perl_calc'
alias enrico_tgif='/home/pippo1/epontell/bin/tgif'

setenv ICAL_LIBRARY ~/lib/ical/v2.2/

alias w_='whozon'

setenv LYNX lynx.sh

alias ns="xset +fp /usr/openwin/lib/X11/fonts/75dpi/; xset fp rehash; nice +10 netscape &"

function xinit_ () { xinit >&\! .xinit.log }

alias csmachines='/home/adm_bin/utils/csmachines'
