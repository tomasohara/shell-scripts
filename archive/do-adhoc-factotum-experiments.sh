#! /bin/csh -f
#
# do-adhoc-factotum-experiments.sh: adhoc script for running factotum experiments remotely,
# mainly for the Beowulf cluster (wb1 ... wb32)
#
# TODO:
# - generalize through the use of an .ini file rather than hardcoding the command-line invocation
# - determine the WB hosts to use dynamically based on system load (see foreach.perl)
# - rename ALL- to UNFILTERED- (use ALL- for all relations)
# - first produce a list of free wb hosts (eg, load < .10)
# - use the local file system for the log files (do_wsd.log) to minimize access to file server
# - add --sorted option instead of hardcoding it below

# Uncomment (or comment) the following for enabling (or disabling) tracing
## set echo=1

# Initialize defaults for options
set all=0
set common_setenv="setenv_factotum.sh setenv_naive_bayes.sh"
set do_wsd_options="--use-temp-dir"
set dir_prefix=""

# Initiailize experiment indicators
set pruned_prep=0
set unfiltered_pruned_prep=0
set sorted_pruned_prep=0
set marked_relations=0
set just_POS=0
set no_POS=0
set functional=0
set factotum=0
set functional=0
set pruned_functional=0
set all_pruned_functional=0

# Determine the parallel node controller to use
# TODO: add support for using regular Linux hosts
set WB=""
if ("$HOST" == "medusa") set WB="wb"
if ("$HOST" == "colossus") set WB="bw"
if ("$WB" == "") then
    echo ""
    echo "ERROR: This must be run under medusa or colossus"
    echo ""
    exit
endif

# Parse command-line arguments
if ("$1" == "") then
    set script_name = `basename $0`
    echo ""
    echo "usage: `basename $0` [options]"
    echo ""
    echo "options = [--all] [--debug] [--test] [--setenv file]"
    echo "          [--pruned-prep] [--sorted-pruned-prep] [--unfiltered-pruned-prep]"
    echo "          [--functional] [--pruned-functional] [--all-pruned-functional]"
    echo "          [--marked-relations] [--factotum] [--no-POS] [--just-POS]"
    echo ""
    echo "examples:"
    echo ""
    echo "`basename $0` --functional"
    echo ""
    echo "$0 --debug --unfiltered-pruned-prep"
    echo ""
    echo "$0 --all"
    echo ""
    exit
endif
while ("$1" =~ -*)
    if ("$1" == "--all") then
	set all=1
    else if ("$1" == "--debug") then
	set do_wsd_options="${do_wsd_options} --no-temp-dir --debug"
	set dir_prefix="${dir_prefix}DEBUG-"
    else if ("$1" == "--test") then
	set dir_prefix="${dir_prefix}TEST-"
    else if ("$1" == "--setenv") then
	set common_setenv="${common_setenv} $2"
	shift
    else if ("$1" == "--pruned-prep") then
	set pruned_prep=1
    else if ("$1" == "--sorted-pruned-prep") then
	set sorted_pruned_prep=1
    else if ("$1" == "--unfiltered-pruned-prep") then
	set unfiltered_pruned_prep=1
    else if ("$1" == "--marked-relations") then
	set marked_relations=1
    else if ("$1" == "--factotum") then
	set factotum=1
    else if ("$1" == "--functional") then
	set functional=1
    else if ("$1" == "--pruned-functional") then
	set pruned_functional=1
    else if ("$1" == "--all-pruned-functional") then
	set all_pruned_functional=1
    else if ("$1" == "--no-POS") then
	set no_POS=1
    else if ("$1" == "--just-POS") then
	set just_POS=1
    else
	# TODO: just show the usage statement if unknown option encountered
	echo "WARNING: unknown option: $1"
    endif
    shift
end


# Run all factotum relations: FACTOTUM-{NAIVE,HYPER,BOTH}
if  ($factotum || $all) then

    set dir_prefix="${dir_prefix}FACTOTUM"
    set common_setenv="${common_setenv} setenv_wsd.sh setenv_factotum_adjacency.sh setenv_filtered_05pct.sh"
    set annot_file="$PWD/factotum.annotations"
    mkdir -p ${dir_prefix}-NAIVE; mkdir -p ${dir_prefix}-HYPER; mkdir -p ${dir_prefix}-BOTH 

    rsh -n ${WB}11 do_wsd_exp.sh --dir $PWD/${dir_prefix}-NAIVE ${do_wsd_options} $common_setenv $annot_file >& ${dir_prefix}-NAIVE/do_wsd.log &

    rsh -n ${WB}12 do_wsd_exp.sh --dir $PWD/${dir_prefix}-HYPER ${do_wsd_options} $common_setenv setenv_new_hypernyms.sh $annot_file >& ${dir_prefix}-HYPER/do_wsd.log &

    rsh -n ${WB}13 do_wsd_exp.sh --dir $PWD/${dir_prefix}-BOTH ${do_wsd_options} $common_setenv setenv_new_hypernyms.sh setenv_wsd.sh $annot_file >& ${dir_prefix}-BOTH/do_wsd.log &
endif


# Run all functional relations: FUNCTIONAL-{NAIVE,HYPER,BOTH}
if  ($functional || $all) then

    set dir_prefix="${dir_prefix}FUNCTIONAL"
    set common_setenv="${common_setenv} setenv_wsd.sh setenv_factotum_adjacency.sh setenv_filtered_05pct.sh"
    set annot_file="$PWD/functional.annotations"
    mkdir -p ${dir_prefix}-NAIVE; mkdir -p ${dir_prefix}-HYPER; mkdir -p ${dir_prefix}-BOTH 

    rsh -n ${WB}7 do_wsd_exp.sh --dir $PWD/${dir_prefix}-NAIVE ${do_wsd_options} $common_setenv $annot_file >& ${dir_prefix}-NAIVE/do_wsd.log &

    rsh -n ${WB}8 do_wsd_exp.sh --dir $PWD/${dir_prefix}-HYPER ${do_wsd_options} $common_setenv setenv_new_hypernyms.sh $annot_file >& ${dir_prefix}-HYPER/do_wsd.log &

    rsh -n ${WB}9 do_wsd_exp.sh --dir $PWD/${dir_prefix}-BOTH ${do_wsd_options} $common_setenv setenv_new_hypernyms.sh setenv_wsd.sh $annot_file >& ${dir_prefix}-BOTH/do_wsd.log &
endif


# Run all pruned functional relations: PRUNED-FUNCTIONAL-{NAIVE,HYPER,BOTH}
if  ($pruned_functional || $all) then

    set dir_prefix="${dir_prefix}PRUNED-FUNCTIONAL"
    set common_setenv="${common_setenv} setenv_wsd.sh setenv_factotum_adjacency.sh setenv_filtered_05pct.sh"
    set annot_file="$PWD/pruned-functional.annotations"
    mkdir -p ${dir_prefix}-NAIVE; mkdir -p ${dir_prefix}-HYPER; mkdir -p ${dir_prefix}-BOTH 

    rsh -n ${WB}14 do_wsd_exp.sh --dir $PWD/${dir_prefix}-NAIVE ${do_wsd_options} $common_setenv $annot_file >& ${dir_prefix}-NAIVE/do_wsd.log &

    rsh -n ${WB}15 do_wsd_exp.sh --dir $PWD/${dir_prefix}-HYPER ${do_wsd_options} $common_setenv setenv_new_hypernyms.sh $annot_file >& ${dir_prefix}-HYPER/do_wsd.log &

    rsh -n ${WB}16 do_wsd_exp.sh --dir $PWD/${dir_prefix}-BOTH ${do_wsd_options} $common_setenv setenv_new_hypernyms.sh setenv_wsd.sh $annot_file >& ${dir_prefix}-BOTH/do_wsd.log &
endif


# Run all pruned functional relations: PRUNED-FUNCTIONAL-{NAIVE,HYPER,BOTH}
if  ($all_pruned_functional || $all) then

    set dir_prefix="${dir_prefix}PRUNED-FUNCTIONAL"
    set common_setenv="${common_setenv} setenv_wsd.sh setenv_factotum_adjacency.sh setenv_unfiltered.sh"
    set annot_file="$PWD/pruned-functional.annotations"
    mkdir -p ${dir_prefix}-NAIVE; mkdir -p ${dir_prefix}-HYPER; mkdir -p ${dir_prefix}-BOTH 

    rsh -n ${WB}1 do_wsd_exp.sh --dir $PWD/${dir_prefix}-NAIVE ${do_wsd_options} $common_setenv $annot_file >& ${dir_prefix}-NAIVE/do_wsd.log &

    rsh -n ${WB}2 do_wsd_exp.sh --dir $PWD/${dir_prefix}-HYPER ${do_wsd_options} $common_setenv setenv_new_hypernyms.sh $annot_file >& ${dir_prefix}-HYPER/do_wsd.log &

    rsh -n ${WB}3 do_wsd_exp.sh --dir $PWD/${dir_prefix}-BOTH ${do_wsd_options} $common_setenv setenv_new_hypernyms.sh setenv_wsd.sh $annot_file >& ${dir_prefix}-BOTH/do_wsd.log &
endif


# Run pruned-functional experiments w/preps: PRUNED-ADJ-PREP-{NAIVE,HYPER,BOTH}
if  ($pruned_prep || $all) then

    set dir_prefix="${dir_prefix}PRUNED-ADJ-PREP"
    set common_setenv="${common_setenv} setenv_wsd.sh setenv_factotum_adjacency.sh setenv_filtered_05pct.sh"
    set annot_file="$PWD/pruned-prep-functional.annotations"
    mkdir -p ${dir_prefix}-NAIVE; mkdir -p ${dir_prefix}-HYPER; mkdir -p ${dir_prefix}-BOTH 

    rsh -n ${WB}17 do_wsd_exp.sh --dir $PWD/${dir_prefix}-NAIVE ${do_wsd_options} $common_setenv $annot_file >& ${dir_prefix}-NAIVE/do_wsd.log &

    rsh -n ${WB}18 do_wsd_exp.sh --dir $PWD/${dir_prefix}-HYPER ${do_wsd_options} $common_setenv setenv_new_hypernyms.sh $annot_file >& ${dir_prefix}-HYPER/do_wsd.log &

    rsh -n ${WB}19 do_wsd_exp.sh --dir $PWD/${dir_prefix}-BOTH ${do_wsd_options} $common_setenv setenv_new_hypernyms.sh setenv_wsd.sh $annot_file >& ${dir_prefix}-BOTH/do_wsd.log &

endif


# Run sorted pruned-functional experiments w/preps: SORTED-PRUNED-ADJ-PREP-{NAIVE,HYPER,BOTH}
if  ($sorted_pruned_prep || $all) then

    set dir_prefix="${dir_prefix}SORTED-PRUNED-ADJ-PREP"
    set common_setenv="${common_setenv} setenv_wsd.sh setenv_factotum_adjacency.sh setenv_filtered_05pct.sh"
    set annot_file="$PWD/sorted-pruned-prep-functional.annotations"
    mkdir -p ${dir_prefix}-NAIVE; mkdir -p ${dir_prefix}-HYPER; mkdir -p ${dir_prefix}-BOTH 

    rsh -n ${WB}20 do_wsd_exp.sh --dir $PWD/${dir_prefix}-NAIVE ${do_wsd_options} $common_setenv $annot_file >& ${dir_prefix}-NAIVE/do_wsd.log &

    rsh -n ${WB}21 do_wsd_exp.sh --dir $PWD/${dir_prefix}-HYPER ${do_wsd_options} $common_setenv setenv_new_hypernyms.sh $annot_file >& ${dir_prefix}-HYPER/do_wsd.log &

    rsh -n ${WB}22 do_wsd_exp.sh --dir $PWD/${dir_prefix}-BOTH ${do_wsd_options} $common_setenv setenv_new_hypernyms.sh setenv_wsd.sh $annot_file >& ${dir_prefix}-BOTH/do_wsd.log &

endif


# Run unfiltered pruned-functional experiments w/preps: ALL-PRUNED-ADJ-PREP-{NAIVE,HYPER,BOTH}
if  ($unfiltered_pruned_prep || $all) then

    set dir_prefix="${dir_prefix}ALL-PRUNED-ADJ-PREP"
    set common_setenv="${common_setenv} setenv_wsd.sh setenv_factotum_adjacency.sh setenv_unfiltered.sh"
    set annot_file="$PWD/sorted-pruned-prep-functional.annotations"
    mkdir -p ${dir_prefix}-NAIVE; mkdir -p ${dir_prefix}-HYPER; mkdir -p ${dir_prefix}-BOTH 

    rsh -n ${WB}23 do_wsd_exp.sh --dir $PWD/${dir_prefix}-NAIVE ${do_wsd_options} $common_setenv $annot_file >& ${dir_prefix}-NAIVE/do_wsd.log &

    rsh -n ${WB}24 do_wsd_exp.sh --dir $PWD/${dir_prefix}-HYPER ${do_wsd_options} $common_setenv setenv_new_hypernyms.sh $annot_file >& ${dir_prefix}-HYPER/do_wsd.log &

    rsh -n ${WB}25 do_wsd_exp.sh --dir $PWD/${dir_prefix}-BOTH ${do_wsd_options} $common_setenv setenv_new_hypernyms.sh setenv_wsd.sh $annot_file >& ${dir_prefix}-BOTH/do_wsd.log &

endif



# Run unfiltered marked-pruned-functional experiments w/preps: MARKER-PRUNED-ADJ-PREP-{NAIVE,HYPER,BOTH}
if  ($marked_relations || $all) then

    set dir_prefix="${dir_prefix}MARKER-PRUNED-ADJ"
    set common_setenv="${common_setenv} setenv_wsd.sh setenv_factotum_adjacency.sh setenv_unfiltered.sh"
    set annot_file="$PWD/marked-pruned-functional.annotations"
    mkdir -p ${dir_prefix}-NAIVE; mkdir -p ${dir_prefix}-HYPER; mkdir -p ${dir_prefix}-BOTH 

    # note: bw27 is currently down
    rsh -n ${WB}26 do_wsd_exp.sh --dir $PWD/${dir_prefix}-NAIVE ${do_wsd_options} $common_setenv $annot_file >& ${dir_prefix}-NAIVE/do_wsd.log &

    rsh -n ${WB}28 do_wsd_exp.sh --dir $PWD/${dir_prefix}-HYPER ${do_wsd_options} $common_setenv setenv_new_hypernyms.sh $annot_file >& ${dir_prefix}-HYPER/do_wsd.log &

    rsh -n ${WB}29 do_wsd_exp.sh --dir $PWD/${dir_prefix}-BOTH ${do_wsd_options} $common_setenv setenv_new_hypernyms.sh setenv_wsd.sh $annot_file >& ${dir_prefix}-BOTH/do_wsd.log &

endif

# Run with just part of speech (unfiltered): ALL-POS-{NAIVE,ADJ-NAIVE}
if  ($just_POS || $all) then

    set dir_prefix="${dir_prefix}ALL-POS"
    set common_setenv="${common_setenv} setenv_wsd.sh setenv_just_part-of-speech.sh setenv_unfiltered.sh"
    set annot_file="$PWD/pruned-prep-functional.annotations"
    mkdir -p ${dir_prefix}-NAIVE; mkdir -p ${dir_prefix}-ADJ-NAIVE 

    rsh -n ${WB}30 do_wsd_exp.sh --dir $PWD/${dir_prefix}-NAIVE ${do_wsd_options} $common_setenv $annot_file >& ${dir_prefix}-NAIVE/do_wsd.log &

    rsh -n ${WB}31 do_wsd_exp.sh --dir $PWD/${dir_prefix}-ADJ-NAIVE ${do_wsd_options} $common_setenv setenv_factotum_adjacency.sh $annot_file >& ${dir_prefix}-ADJ-NAIVE/do_wsd.log &

endif


# Run without part of speech w/ preps (unfiltered): NO-POS-{NAIVE,HYPER,BOTH}
if  ($no_POS || $all) then

    set dir_prefix="${dir_prefix}NO-POS"
    set common_setenv="${common_setenv} setenv_wsd.sh setenv_no_part-of-speech.sh setenv_filtered_05pct.sh"
    set annot_file="$PWD/pruned-prep-functional.annotations"
    mkdir -p ${dir_prefix}-NAIVE; mkdir -p ${dir_prefix}-HYPER; mkdir -p ${dir_prefix}-BOTH 

    rsh -n ${WB}4 do_wsd_exp.sh --dir $PWD/${dir_prefix}-NAIVE ${do_wsd_options} $common_setenv $annot_file >& ${dir_prefix}-NAIVE/do_wsd.log &

    rsh -n ${WB}5 do_wsd_exp.sh --dir $PWD/${dir_prefix}-HYPER ${do_wsd_options} $common_setenv setenv_new_hypernyms.sh $annot_file >& ${dir_prefix}-HYPER/do_wsd.log &

    rsh -n ${WB}6 do_wsd_exp.sh --dir $PWD/${dir_prefix}-BOTH ${do_wsd_options} $common_setenv setenv_new_hypernyms.sh setenv_wsd.sh $annot_file >& ${dir_prefix}-BOTH/do_wsd.log &

endif
