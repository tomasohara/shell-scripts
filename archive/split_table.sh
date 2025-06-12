#!/bin/csh -f
# uses -f (fast load) in case user has aliases overriding rm, mv, etc.

###########################################################
# split a table into two parts: training set and test set.
# Input: table, k-fold, ith-split
# Output: table.test, table.train
###########################################################

if ($#argv != 3) then 
   echo "Usage: split_table table k-fold ith"
   exit 1
endif
set script_dir = `dirname $0`
if ($script_dir == ".") set script_dir = `pwd`

#compute total lines in $1
set total = `cat $1 | wc -l`
echo "Total lines in $1 = $total"

#split table
perl ${script_dir}/build_table_one_pair.prl $1 $total $2 $3
