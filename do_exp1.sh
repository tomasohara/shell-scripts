#! /bin/csh -f
#
# Runs a GraphLing experiment using the setup for EMNLP experiment 1
#

# NOTE: feature.ini must specify F57.2-F62.2 as well as the usuals
#
set script_dir = /home/graphling/UTILITIES
if ($?SCRIPT_DIR == 1) then
    set script_dir = $SCRIPT_DIR
endif
source ${script_dir}/do_exp_helper.sh

if ($ok == 1) then
    set exp_options = "--organization PC1 --syntactic --backward"
    setenv WINSIZE 1
    setenv ALT_WINSIZE 1
    setenv ONE_SID_PER_CLAUSE 1
    $nice_cmd ${SCRIPT_DIR}/run_experiment.sh $exp_options $other_options $file
endif
