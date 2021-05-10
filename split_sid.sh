#!/bin/csh -f

###########################################################
# Split a SIDFILE into two parts: training set and test set.
# (SID stands for sentence ID.)
#
# Input: SIDFILE, k-fold
# Output: k pairs of SIDFILE.test and SIDFILE.train
#
###########################################################

set dir = `dirname $0`
if (`printenv DEBUG_MODE` != "") set echo = 1   # command tracing

# Check command-line arguments
#
if ($#argv != 2) then 
    echo ""
    echo "Usage: $0 SIDFILE k-fold"
    echo ""
    echo "ex: $0 SIDFILE 10"
    echo ""
    exit 1
endif
set sidfile = "$1"
set num_folds = "$2"

# Compute total lines in the overall SIDFILE
set total = `cat $sidfile | wc -l`
echo "Total lines in $sidfile = $total"

# Split file with the sentence ID's into subfiles for each fold
perl -Ssw build_SID.prl $sidfile $total $num_folds
