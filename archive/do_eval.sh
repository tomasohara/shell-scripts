#! /bin/csh -f
#
# do_eval.sh: evaluate the results of the word alignment
#
# TODO:
# - generalize to other language pairs
# - rename to something like do_align_eval.sh
#


# Parse the arguments
#

if ("$1" == "") then
    echo ""
    echo "usage `basename $0` align_output"
    echo ""
    echo "ex: nice +19 `basename $0` runit.var.log >&! do_eval.var.log &"
    echo ""
    exit
endif

set results = $1
set echo = 1


# Split output based on Engl-Span & Span-Eng sections
#

perl -Ssw split_subfiles.perl word1 word1 temp_output < $1


# Run each section though the evaluation
#

perl -Ssw qd_eval.perl -spanish=0 temp_output_1 > temp_english.eval

perl -Ssw qd_eval.perl -spanish=1 temp_output_2 > temp_spanish.eval


# Display the results
#

cat temp_english.eval
cat temp_spanish.eval


