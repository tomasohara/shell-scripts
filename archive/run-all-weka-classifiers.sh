#! /bin/bash
# run-weka.sh: script for running all Weka classifiers over the input data file (ARFF format).
#
# Note:
# - Based on old run-weka.sh scrript that took tabular input as input.
#
# TODO:
# - Reconcile with run_weka_classifiers.sh.
# - Add in support for meta-folds (see new-run-lexicalization-POS-experiments.sh).
# - Add in support for non-arff input (e.g., converion via feature2ml.perl).
#........................................................................
# Weka options
#
# -t <name of training file>	training file
# -T <name of test file>	test file
# -x <number of folds>		number of folds for cross-validation
# -i				outputs information-retrieval statistics
# -k				outputs information-theoretic statistics.
# -v                            only only test data statistics
#
#........................................................................
# Excerpt from classifier listing (from Java properties files):
#
#   # Lists the Classifiers I want to choose from
#   weka.classifiers.Classifier=\
#    weka.classifiers.bayes.AODE,\
#    weka.classifiers.bayes.AODEsr,\
#    weka.classifiers.bayes.BayesianLogisticRegression,\
#    weka.classifiers.bayes.BayesNet,\
#     ...
#

# Uncomment following line(s) for tracing:
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#
## echo "$@"
## set -o xtrace
## set -o verbose

# Set defaults for the options
folds=10			# number of cross-validation folds
base_for_meta="trees.J48"       # base classifier for use with meta classifiers; TODO: use functions.LibSVM
all_bases=0			# run meta-classifiers on all base classifiers
trace=0				# script tracing
verbose=0			# detailed output
debug=0				# debug level
## weka_jar="c:/Program-Misc/Weka-3-7/weka.jar"
weka_jar=""                     # path to weka jar file (java archive)
max_mem=1024			# java VM size
output_dir="all"                # directory with results for each classification
timeout_option=""               # option to cmd.sh for specifying timeout

# Show usage if no arguments are given
if [ "$1" = "" ]; then
    script_name=`basename $0`
    echo ""
    echo "usage: $script_name [options] training-file [testing-file]"
    echo "options = [--folds N] [--base-for-meta classifier] [--all-bases] [-output-dir dir] [--nolabels] [--label-file file] [--trace] [--debug] [--weka jar]"
    echo ""
    echo "Examples:"
    echo ""
    echo "$0 20_newsgroups.arff"
    echo ""
    echo "$script_name --weka c:/Program-Misc/Weka-3-7/weka.jar iris.arff > all-iris.log 2>&1"
    echo ""
    echo "feature2ml.perl -weka -csv -last sample-reuters-esl.data > sample-reuters-esl.arff"
    echo "$script_name --trace --time-out 300 --4GB sample-reuters-esl.arff > all-sample-reuters-esl.data.log 2>&1"
    echo ""
    echo "Description of main options:"
    echo "    --all           run all classifiers with output put in ./all subdirectory"
    echo "    --all-bases     run meta-classifiers with all base classifiers"
    echo "    --folds N       run N-fold cross validation"
    echo ""
    exit
fi

# Check the command-line arguments
moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
while [ "$moreoptions" = "1" ]; do
    if [ "$1" = "--folds" ]; then
	folds=$2
	shift
    elif [ "$1" = "--all" ]; then
	all=1
    elif [ "$1" = "--base-for-meta" ]; then
	base_for_meta="$2"
	shift
    elif [ "$1" = "--all-bases" ]; then
	all_bases=1
    elif [ "$1" = "--output-dir" ]; then
	output_dir="$2"
	shift
    elif [ "$1" = "--trace" ]; then
	trace=1
    elif [ "$1" = "--verbose" ]; then
	verbose=1
    elif [ "$1" = "--verbose-trace" ]; then
	trace=1
	verbose=1
    elif [ "$1" = "--debug" ]; then
	debug=1
    elif [ "$1" = "--max-mem" ]; then
        max_mem=$2
        shift
    elif [ "$1" = "--GB" ]; then
        let max_mem=($2 * 1024)
        shift
    elif [ "$1" = "--4GB" ]; then
        max_mem=4096
    elif [ "$1" = "--2GB" ]; then
        max_mem=2048
    elif [ "$1" = "--weka-jar" ]; then
	weka_jar="$2"
	shift
    elif [ "$1" = "--weka" ]; then
	weka_jar="$2"
	shift
    elif [ "$1" = "--time-out" ]; then
	timeout_option="cmd.sh --time-out $2"
	shift
    elif [ "$1" = "--new-time-out" ]; then
	timeout_option="timeout $2"
	shift
    else
	echo "ERROR: invalid option '$1'"
        exit
    fi
    shift
    moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
done
classpath="$weka_jar"
if [ "$classpath" = "" ]; then
    classpath="$CLASSPATH"
fi
if [ "$classpath" = "" ]; then
    echo "Error: need to use --weka option for jar file or specify via CLASSPATH"
    exit
fi

# Optionally enable script tracing
if [ $trace = 1 ]; then 
    set -o xtrace
    if [ $verbose = 1 ]; then
	set -o verbose
    fi
fi

# Set data file options
train_file="$1"
result_base=`basename "$train_file" .arff`
if [ "$train_file" = "$result_base" ]; then
    echo "ERROR: Requires .arff input (and extension). See usage example for workaround."
    exit
fi
test_file=""
if [ "$2" != "" ]; then 
    test_file="$2"
fi

# Set Weka options
java_options="-mx${max_mem}m -oss${max_mem}m -cp ${classpath}"
weka_options="-v -i -k -t ${train_file}"
if [ "$test_file" != "" ]; then
    weka_options="${weka_options} -T ${test_file}"
else
    weka_options="${weka_options} -x $folds"
fi
# TODO: figure out Weka's debug option
## if [ $debug = 1 ]; then weka_options="-D ${weka_options}"; fi
if [ $verbose = 1 ]; then
    echo "CLASSPATH: $CLASSPATH"
    echo "Java options: $java_options"
    echo "Weka options: $weka_options"
fi

# Determine pattern to use for extracting results
test_section='Stratified cross-validation'
if [ "$test_file" != "" ]; then test_section='Error on test data'; fi

# Run all available classifiers for comparison purposes.
#
# NOTES:
# - List derived from src/main/java/weka/gui/GenericObjectEditor.props in weka-src.jar.
#   -- extract_matches.perl "weka.classifiers.([a-z][A-Za-z0-9_\.]+)" src/main/java/weka/gui/GenericObjectEditor.props | egrep -v 'meta|supportVector|evaluation.output|bayes.net'
# - Classifiers requiring numeric class values: 
#     m5.M5Prime  LRW  LinearRegression
# - Classifiers requiring 2-class datasets: 
#     Logistic  adtree.ADTree  SMO
# - NeuralNetwork must be invoked via interface (since net must be created first)
# - BVDecompose needs separate .arff file for decomposition
# - UserClassifier is for interactive classification
# TODO: add more explicit derivation notes (e.g., UserClassifier omitted)
#
# TODO: allow for versioning
#
## OLD:
## classifiers=(bayes.AODE  bayes.AODEsr  bayes.BayesianLogisticRegression  bayes.BayesNet  bayes.ComplementNaiveBayes  bayes.DMNBtext  bayes.HNB  bayes.NaiveBayes  bayes.NaiveBayesMultinomial  bayes.NaiveBayesMultinomialUpdateable  bayes.NaiveBayesSimple  bayes.NaiveBayesUpdateable  bayes.WAODE  functions.GaussianProcesses  functions.IsotonicRegression  functions.LeastMedSq  functions.LibLINEAR  functions.LibSVM  functions.LinearRegression  functions.Logistic  functions.MultilayerPerceptron  functions.PaceRegression  functions.PLSClassifier  functions.RBFNetwork  functions.SimpleLinearRegression  functions.SimpleLogistic  functions.SMO  functions.SMOreg  functions.VotedPerceptron  functions.Winnow  lazy.IB1  lazy.IBk  lazy.KStar  lazy.LBR  lazy.LWL  mi.CitationKNN  mi.MDD  mi.MIBoost  mi.MIDD  mi.MIEMDD  mi.MILR  mi.MINND  mi.MIOptimalBall  mi.MISMO  mi.MISVM  mi.MIWrapper  mi.SimpleMI  mi.TLD  mi.TLDSimple  misc.FLR  misc.HyperPipes  misc.OSDL  misc.SerializedClassifier  misc.VFI  scripting.GroovyClassifier  scripting.JythonClassifier  trees.ADTree  trees.BFTree  trees.DecisionStump  trees.FT  trees.Id3  trees.J48  trees.J48graft  trees.LADTree  trees.LMT  trees.M5P  trees.NBTree  trees.RandomForest  trees.RandomTree  trees.REPTree  trees.SimpleCart   rules.ConjunctiveRule  rules.DecisionTable  rules.DTNB  rules.JRip  rules.M5Rules  rules.NNge  rules.OLM  rules.OneR  rules.PART  rules.Prism  rules.Ridor  rules.ZeroR)
classifiers=(bayes.AODE bayes.AODEsr bayes.BayesianLogisticRegression bayes.BayesNet bayes.ComplementNaiveBayes bayes.DMNBtext bayes.HNB bayes.NaiveBayes bayes.NaiveBayesMultinomial bayes.NaiveBayesMultinomialUpdateable bayes.NaiveBayesSimple bayes.NaiveBayesUpdateable bayes.WAODE functions.GaussianProcesses functions.IsotonicRegression functions.LeastMedSq functions.LibLINEAR functions.LibSVM functions.LinearRegression functions.Logistic functions.MultilayerPerceptron functions.PaceRegression functions.PLSClassifier functions.RBFNetwork functions.SimpleLinearRegression functions.SimpleLogistic functions.SMO functions.SMOreg functions.VotedPerceptron functions.Winnow lazy.IB1 lazy.IBk lazy.KStar lazy.LBR lazy.LWL mi.CitationKNN mi.MDD mi.MIBoost mi.MIDD mi.MIEMDD mi.MILR mi.MINND mi.MIOptimalBall mi.MISMO mi.MISVM mi.MIWrapper mi.SimpleMI mi.TLD mi.TLDSimple misc.FLR misc.HyperPipes misc.OSDL misc.SerializedClassifier misc.VFI scripting.GroovyClassifier scripting.JythonClassifier trees.ADTree trees.BFTree trees.DecisionStump trees.FT trees.Id3 trees.J48 trees.J48graft trees.LADTree trees.LMT trees.M5P trees.NBTree trees.RandomForest trees.RandomTree trees.REPTree trees.SimpleCart rules.ConjunctiveRule rules.DecisionTable rules.DTNB rules.JRip rules.M5Rules rules.NNge rules.OLM rules.OneR rules.PART rules.Prism rules.Ridor rules.ZeroR)
#
## OLD: classifiers=(BVDecompose CVParameterSelection CostMatrix DecisionStump DecisionTable HyperPipes IB1 IBk Id3 KernelDensity LWR LinearRegression Logistic MultiScheme NaiveBayes NaiveBayesSimple OneR Prism SMO Stacking VFI VotedPerceptron ZeroR m5.M5Prime j48.PART j48.J48 kstar.KStar adtree.ADTree)
#
## new: FilteredClassifier
meta_classifiers=(AdaBoostM1 AdditiveRegression AttributeSelectedClassifier Bagging ClassificationViaClustering ClassificationViaRegression CostSensitiveClassifier CVParameterSelection Dagging Decorate END EnsembleSelection FilteredClassifier Grading GridSearch LogitBoost MetaCost MultiBoostAB MultiClassClassifier MultiScheme OrdinalClassClassifier RacedIncrementalLogitBoost RandomCommittee RandomSubSpace RegressionByDiscretization RotationForest Stacking StackingC ThresholdSelector Vote nestedDichotomies.ClassBalancedND nestedDichotomies.DataNearBalancedND nestedDichotomies.ND FilteredClassifier)
## OLD:
## meta_classifiers=(AdaBoostM1  AdditiveRegression  AttributeSelectedClassifier  Bagging  ClassificationViaClustering  ClassificationViaRegression  CostSensitiveClassifier  CVParameterSelection  Dagging  Decorate  END  EnsembleSelection  FilteredClassifier  Grading  GridSearch  LogitBoost  MetaCost  MultiBoostAB  MultiClassClassifier  MultiScheme  OrdinalClassClassifier  RacedIncrementalLogitBoost  RandomCommittee  RandomSubSpace  RegressionByDiscretization  RotationForest  Stacking  StackingC  ThresholdSelector  Vote  nestedDichotomies.ClassBalancedND  nestedDichotomies.DataNearBalancedND  nestedDichotomies.ND)
##
## OLD: meta_classifiers=(AdaBoostM1 AdditiveRegression AttributeSelectedClassifier Bagging CheckClassifier ClassificationViaRegression CostSensitiveClassifier DistributionMetaClassifier FilteredClassifier LogitBoost MetaCost MultiClassClassifier RegressionByDiscretization ThresholdSelector)

# Run the classifiers
if [ $verbose = 1 ]; then echo "Running all available Weka classifiers"; fi
mkdir -p "$output_dir"

# Run each regular classifier
for classifier in ${classifiers[@]}; do
    command_line="java $java_options weka.classifiers.$classifier $weka_options"
    if [ $verbose = 1 ]; then echo "Issuing: $command_line"; fi
    $timeout_option $command_line >| "$output_dir/${result_base}.$classifier" 2>&1
    if [ $? == 124 ]; then echo "Timeout!"; fi
done

# Run each meta-classifier using J4.8 as the base classifier (by default)
base_classifiers=($base_for_meta)
if [ $all_bases = 1 ]; then base_classifiers=(${classifiers[@]}); fi
for base in ${base_classifiers[@]}; do
    for classifier in ${meta_classifiers[@]}; do
	command_line="java $java_options weka.classifiers.$classifier -W weka.classifiers.$base $weka_options"
	if [ $verbose = 1 ]; then echo "Issuing: $command_line"; fi
	$timeout_option $command_line >| all/${result_base}.$base.$classifier 2>&1
	if [ $? == 124 ]; then echo "Timeout!"; fi
    done
done

# Extract the reults
grep -A3 "$test_section" $output_dir/${result_base}.* | grep 'Correctly Classified Instances' | perl -Ssw extract_matches.perl -fields=2 "${result_base}.(\S+)-Correctly Classified Instances.*\s+(\S+)\s+\%" | sort --key=2 -rn >| ${result_base}.all-classifiers
cat ${result_base}.all-classifiers
