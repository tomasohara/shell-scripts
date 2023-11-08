#! /bin/csh -f
#
# test_get_collocations.sh: script for testing get_collocations.sh without
# having to go through run_experiment.sh
#

# Parse command-line arguments
set file = ""

if ("$1" == "--help") then
    echo ""
    echo "usage: `basename $0` [options]"
    echo ""
    echo "ex: `basename $0` whatever"
    echo ""
    exit
endif
while ("$1" =~ -*)
    if ("$1" == "--file") then
	set file = "$2"
	shift
    else if ("$1" == "--bar") then
	echo "hey"
    else
	echo "unknown option: $1"
    endif
    shift
end
if ("$file" == "") set file = "$1"
if ("$file" == "") `echo *.preprocess`

set echo = 1
set base = `basename $file .preprocess`
set colls_anywhere = 1
set colls_within = 0
set colls_pattern = 0
set use_new_CI = 1
set use_g2_test = 0
set sidfile = "SIDFILE.train0"
set do_word_sense = 1
set organization = "PC1"
set script_dir = `dirname $0`
source ${script_dir}/get_collocations.sh
