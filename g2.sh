#!/bin/csh -f
# uses -f (fast load) in case user has aliases overriding rm, mv, etc.

############################################################################
# FILENAME: g2
# AUTHOR: Lei Duan
# DATE: Jan 1997
############################################################################

if ($#argv != 3) then 
   echo "Usage: g2 mergedfile outputfile SIDFILE"
   exit 1
endif
if (`printenv DEBUG_MODE` != "") set echo = 1   # command tracing
set script_dir = `dirname $0`
if ($script_dir == ".") set script_dir = `pwd`

# arguments:
#
# g2 - shell script command
#     
# mergedfile - merged annotation file
#
# outputfile - result of g^2 test.
# 
# SIDFILE - which part of mergedfile will be chosen as training data
#
#

# prepare bigrams for g2 test: choose words in any place in a sentence
prepare_bigram_all $1 out $3 3

# prepare bigrams for g2 test: choose words within N of main verb
#prepare_bigram_all5 $1 out $3 3

sort out -o out.1
sort +1 out -o out.2
rm out

#do g2 test
g2test2 out.1 out.2 out
rm out.1
rm out.2
sort -r -n out -o out.1
rm out

#choose collocations
perl ${script_dir}/choose_g2_colls.prl out.1 $2 20
rm out.1


 
