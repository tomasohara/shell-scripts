#! /bin/csh -f
#
# new_do_wsd_exp.sh: setup & run WSD experiment with default settings or
# with those specified via setenv_XXX.sh scripts. For the latter, see
#    /home/graphling/EXPERIMENTS/SETENV_SCRIPTS
#
# Experiments are run indirectly via setup_wsd_experiment.perl, which
# in turns uses the standard GraphLing script (run_experiment.sh).
#
# To alleviate the file-system bottleneck caused by running several 
# jobs in parallel, there is an option to run the experiments on
# the local file sustem (e.g., under /tmp) and then copy the results
# back to the working directory.
#
# NOTES:
# - Similar to do_wsd_exp.sh except that only one experiment at a time 
#   supported to allow for specifying the test case.
#
# - *** The command-line options here need to be synchronized with
# do_all_wsd_remote.sh, which automates running jobs on different 
# machines.
#
# - This started out as an ad-hoc script used to simplify overnight 
# runs. Therefore, some of the option settings might be arbitrary.
#
# TODO:
# - reconcile this with the general options in do_wsd_exp.sh
# - Be careful with long variable names in (stupid) csh.
# - Rework log output so that all output is shown in word.log, not just
#   the word-specific part. In particular, put setenv display there.
# - Add sanity checks for the environment settings, such as for values
#   with '=' which might be a typo (e.g., confusion between bash and csh).
# - Make sure the script dir is in the PATH (sanity check for problem
#   with setenv.sh's GRAPHLING_SETENV setting)
#
# Uncomment the following for tracing the script
set echo = 1

# Initialize settings
set extra_args = ""
set subdir = ""
set subdir_suffix = `printenv subdir_suffix`
set script_dir = `dirname $0`
set script_name = `basename $0`
set setenv_scripts = ()
set cleanup = 1

## echo "starting $script_name"

# Initialize temporary directory settings
# Note: /local/tmp is used in place of /tmp if found since the 
# CS parallel node machines (wb1 ... wb32) don't have much space for /tmp
set use_temp_dir = `printenv use_temp_dir`
set temp_dir = /tmp/graphling.$$
if (-d /local/tmp) set temp_dir = /local/tmp/graphling.$$

# Make sure the GraphLing utilities are accessible
#
# NOTE: To use an alternative set of utility scripts, setup the graphling
# evironment beforehand.
#
## Uncomment the following for command tracing
## setenv GRAPHLING_TRACE 1
source $script_dir/setenv.sh
if ($DEBUG_LEVEL >= 4) set cleanup = 0

# Show usage statement if insufficient arguments given
if ("$1" == "") then
    echo ""
    echo "usage: `basename $0` [options] training_data_spec [test_data_spec]"
    echo ""
    echo "options = [--data_set name] [--search] [--forward] [--preprocess] "
    echo "          [--subdir-suffix label] [--new] [--setenv_script file] "
    echo "          [--organization [PC1 | PC2 | OR1 | OR2]] "
    echo "          [--use-temp-dir] [--temp-dir dir] [--debug] [--force] "
    echo ""
    echo "examples: "
    echo ""
    echo "nice +9 $script_name lemon"
    echo ""
    echo "nice +9 $script_name --search --data_set HECTOR bake"
    echo ""
    echo "nice +9 $script_name --setenv ../setenv_forward.sh --subdir-suffix _FWD power"
    echo ""
    echo "nice +9 $script_name --use-temp --setenv ../setenv_g2_bin.sh --setenv ../setenv_backward.sh business"
    echo ""
    echo "nice -9 $script_name setenv_differentia_refinement.sh /home/graphling/DATA/LEXICAL_RELATIONS/framenet-preposition.annotations temp-sentence-23185.txt >| do_exp.log 2>&1"
    echo ""
    echo "NOTES: "
    echo ""
    echo "- The file data_set.list is used for the default dataset name."
    echo ""
    echo "- data_seta is usually one of following:"
    echo "     DSO        DSO Wall Street Journal annotations"
    echo "     SENSEVAL1  Evaluation data used in 1st SensEval"
    echo "     Treebank	  Penn Treebank semantic roles"
    echo "     FrameNet	  Berkeley FrameNet semantic roles"
    echo "  See setup_wsd_experiment.perl for others."
    echo ""
    echo ""
    exit
endif

# Show system information and time (useful for remote problem diagnosis)
uname -a
date
echo "$0 $*"

# Parse command-line arguments
set force = 0		# force processing of arguments (ie, skip sanity checks)
while (("$1" =~ -*) || ($1 =~ *setenv*.sh))
    if ("$1" == "--dir") then
	cd $2
	shift
    else if (("$1" == "--subdir-suffix") || ("$1" =~ --suffix*)) then
	set subdir_suffix = "$2"
	shift
    else if ("$1" == "--subdir") then
	set subdir = "$2"
	shift
    else if ("$1" == "--keep") then
	set cleanup = 0
    else if ("$1" =~ --script_dir*) then
	set script_dir = "$2"
	shift
    else if ("$1" =~ --setenv*) then
	# append the following argument to the list of setenv scripts
	set setenv_scripts = ($setenv_scripts[*] $2)
	shift
    # omits need for --setenv if file name starts in setenv_???
    else if ("$1" =~ *setenv*.sh) then
	# append the argument to the list of setenv scripts
	set setenv_scripts = ($setenv_scripts[*] $1)
    # support for common cases (debug, CI, etc.)
    else if ("$1" =~ --debug*) then
	set setenv_scripts = ($setenv_scripts[*] setenv_debug.sh)
	set subdir_suffix = "_DEBUG"
    else if ("$1" == "--not-nice") then
	setenv NOT_NICE 1
    else if ("$1" =~ --search*) then
	set extra_args = "$extra_args -model_search"
    else if ("$1" =~ --data*) then
	setenv data_set "$2"
	shift
    else if ("$1" =~ --fixed*) then
	set extra_args = "$extra_args -model_search=0"
    else if ("$1" == "--force") then
	set force = 1
    else if ("$1" =~ --forw*) then
	if ($?COCO_SCRIPT == 0) setenv COCO_SCRIPT coco_wsd_forward.template
	if ($?ORDER_MODELS == 0) setenv ORDER_MODELS 1
	if ($?MAX_MODELS == 0) setenv MAX_MODELS 15
	set extra_args = "$extra_args -model_search"
    else if ("$1" =~ --back*) then
	if ($?COCO_SCRIPT == 0) setenv COCO_SCRIPT coco_wsd_backward.template
	set extra_args = "$extra_args -model_search"
    else if ("$1" =~ --naive*) then
	if ($?COCO_SCRIPT == 0) setenv COCO_SCRIPT coco_naive-bayes.template
    else if ("$1" =~ --prep*) then
	set extra_args = "$extra_args -always_preprocess"
    else if ("$1" =~ --new*) then
	if ($?FEATURE_PROGRAM == 0) setenv FEATURE_PROGRAM new_getfmc6.1
	## set setup_wsd = "new_setup_wsd_experiment.perl"
    else if ("$1" =~ --org*) then
	setenv ORGANIZATION "$2"
	shift
    else if ("$1" =~ --temp*) then
	set use_temp_dir = 1
	set temp_dir = "$2"
	shift
    else if ("$1" =~ --use-temp*) then
	set use_temp_dir = 1
    else if ("$1" =~ --no-temp*) then
	set use_temp_dir = 0
    else
	echo "ERROR: unknown option: $1"
	exit
    endif
    shift
end
set training = "$1"
set testing = "$2"
if ("$testing" != "") then
    set extra_args = "$extra_args -test_annotations=$testing"
endif

# Setup the environment based on the setenv scripts
# TODO: reconcile with code in do_all_wsd.sh and run_experiment.sh
set setenv_dir = "$GRAPHLING_HOME/EXPERIMENTS/SETENV_SCRIPTS"
foreach setenv_script ($setenv_scripts)
    echo "setenv_script = ${setenv_script}"
    if ((! -e "$setenv_script") && (-e "$setenv_dir/$setenv_script")) then
	set setenv_script = "$setenv_dir/$setenv_script"
    endif
    if (-e "$setenv_script") then
	source $setenv_script
	cat $setenv_script
    else
	echo "ERROR: unable to find $setenv_script"
	exit
    endif
end

# Display the arguments derived from the command line and/ environment
set setup_wsd = `printenv setup_wsd_experiment_script`
if ("$setup_wsd" == "") set setup_wsd = "setup_wsd_experiment.perl"

if ($?data_set == 0) then
    # NOTE: This is support for the older style of specifying the dataset
    # via a file in the experiment directory. This should now be done
    # via the setenv script. For an example, see
    #    /home/graphling/EXPERIMENTS/SETENV_SCRIPTS/setenv_framenet_as_CG.sh
    setenv data_set ""
    if (-e "data_set.list") setenv data_set `cat data_set.list`
endif
echo "pwd = `pwd`"
echo "PWD = $PWD"
echo "data_set = ${data_set}"
echo "training = $training"
echo "testing = $testing"
echo "extra_args = ${extra_args}"
echo "setup_wsd = ${setup_wsd}"
echo "PERLLIB = `printenv PERLLIB`"
echo "PATH = $PATH"
echo "environment:"
printenv


# Optionally, use a local temporary directory for the output files
# Note: Using a local directory alleviates problem with file server 
# becoming a bottleneck.
set base_dir = $PWD
if ($use_temp_dir) then
    mkdir ${temp_dir}
    cd ${temp_dir}
endif

# Setup and process the experiments for each word
if ($DEBUG_LEVEL >= 5) set echo = 1
set file = ""

# Do a sanity check to ensure that setenv script names are not being
# treated as a word for the classification
# NOTE: this avoids a common problem 
if (("$training" =~ *setenv*) && ($force == 0)) then
	echo "ERRROR: setenv script $training being treated as word for experiment"
	echo "Check the command line arguments; use --force to ignore"
	exit
endif

# Determine word (or dummy word ADHOC) used in reference to the experiment
# NOTE: $word is used to refer to the training data for backward compatibility
set word = $training

# Check for adhoc-experiments
if ("$training" =~ *.annot*) then
	set file = $training
	if ($file !~ /*) set file = "${base_dir}/$file"
	set word = "ADHOC"
	if ($subdir == "") set subdir = "."
	unset data_set
	setenv data_set NONE
endif

# Determine the subdirectory for the experiment. If not specified
# then it is derived from training data word 
if ($subdir == "") then
    # Deriver subdirectory from training data (word) and make uppercase
    set subdir = "$training${subdir_suffix}"
    set subdir = `echo $subdir | tr "a-z" "A-Z"`
endif

# Create the experiment directory
if (-e "${base_dir}/$word") then
    # Remove old symbolic link, which also serves as a completion flag
	# (e.g., eval_wsd_exps.sh requires the symbolic links)
	# TODO: use a more direct method to indicate completion
	rm -f ${base_dir}/$word

	# Remove old reports
	rm -f ${base_dir}/$subdir/table*.report		
endif
if (! -e "$subdir") then
	mkdir $subdir
endif

# Produce log header showing time and environment
# NOTE: process ID used in case multiple jobs being run in same directory
set final_word_log = "$word-$$.log"
set word_log = "_$word-$$.log"
echo "# Classification of word $word (${HOST}: `date`)" >&! $word_log
echo "#" >>&! $word_log
echo "# setenv scripts: ${setenv_scripts}"
echo "#"
echo "# Some system statistics" >>&! $word_log
w >>&! $word_log
df . >>&! $word_log
if ($OSTYPE == "linux") then
	free >>&! $word_log
	ps_mine.sh --all >>&! $word_log
else
	top >>&! $word_log
endif
printenv >>&! $word_log

# Setup and run the experiment
# NOTE: $file will be '' for word-based experiments

perl -Ssw ${setup_wsd} -data_set=${data_set} -run_exp ${extra_args} $word $subdir $file >>&! $word_log

# Move the log file to the word subdir and rename old logs to start with old-
set old_log_files = `ls ${base_dir}/$subdir/${word}-*.log`
if ("$old_log_files" != "") then
	perl -Ssw rename_files.perl ${word}- old-${word}- $old_log_files
endif
mv $word_log $subdir/$final_word_log
if ($cleanup) cleanup_exp.sh $subdir

# Establish new symbolic link (which serves partly as a completion flag)
# NOTE: Used in evaluation scripts to get most recent directory for the word
# TODO: eliminate the need for the symbolic link
ln -s $subdir $word

# Copy the output files from the temporary directory to the final destination
if ($use_temp_dir) then
    cd $base_dir
    # cp options: -d don't de-reference (symbolic) links; -r recursive; 
    #             -p preserve timestamps; -f force overwrites
    cp -d -r -p -f ${temp_dir}/* .
    if ($DEBUG_LEVEL < 4) rm -r -f ${temp_dir}
endif
