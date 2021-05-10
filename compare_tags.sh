#!/bin/csh -f
#
# compare_tags.sh: compares the tags in two SGML files by first pretty
# printing the files (so that each tags is on a single line) and then
# running a visual diff on the result (optionally plain diff can be used)
#
# This script was developed during the MUC NE-tagging competition, so
# it is somewhat dated, although still potentially useful.
#
## set echo = 1

if ("$1" == "") then
    echo "Usage:	compares_tags.sh  result_file key_file (nv (tag))"
    exit
endif

set diff_args = "--ignore-case --ignore-all-space"
if ("$1" == "-w") then
   set diff_args = "$diff_args  --side-by-side"
   shift
endif

set result = $1
set diff_file = /tmp/`basename $result .out`.diff
set key = $2
set result_pp = /tmp/$result.pp
set key_pp = /tmp/$key.pp
set tag = 

perl -Ssw ppsgml.perl $key > $key_pp
perl -Ssw ppsgml.perl $result > $result_pp
if ($3 == "nv") then
	if ("$4" != "") set tag = $4
	echo $result_pp vs $key_pp > $diff_file
	diff $diff_args  $result_pp $key_pp >> $diff_file
	if ("$tag" != "") then
		grep -i -h "$tag" $diff_file
	else
		cat $diff_file
	endif
	## rm $key.diff
else
	tkdiff.tcl $result_pp $key_pp &
endif

rm $result_pp $key_pp $diff_file


