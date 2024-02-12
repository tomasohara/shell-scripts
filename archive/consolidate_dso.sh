#! /bin/csh -f
#
# consolidate.sh: produce
#

## set echo = 1

if ("$1" == "") then
    echo "usage: $0 'sentence_id'"
    echo
    echo "ex: $0 'dj11.db #771'"
    exit
endif
set pattern = "$1"
shift

## grep "dj11.db #771" *.n | dso2sgml.perl > ! dj11_771.data &
eval grep "'"$pattern" '" *.n >! temp_sentence.data
perl -Ssw dso2sgml.perl temp_sentence.data
