#! /bin/bash
# run-weka.sh: script for running Weka classifiers, defaulting to ID3, Naive BAyes,
# and J48 (a c4.5 clone),.
#
# TODO:
# - *** echo CLASSPATH and otherr implicit setting needed to reproduce ***
# - Have option to bypass .arff conversion.
# - Reconcile with run_weka_classifiers.sh.
# - Add in support for meta-folds (see new-run-lexicalization-POS-experiments.sh).
# - Standardize file extension usage (e.g., 'naive' for Naive Bayes rather
#   than 'naive-bayes').
# - Remove -all option and point users to run-all-weka-classifiers.sh
#
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

# Uncomment following line(s) for tracing:
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#  
## echo "$@"
## set -o xtrace
## set -o verbose

# Set defaults for the options
folds=10			# number of cross-validation folds
all=0				# use all Weka classifiers (not just J48)
all_bases=0			# run meta-classifiers on all base classifiers
usual=0				# use usual Weka classifiers (J48, naive and ID3)
trace=0				# script tracing
verbose=0			# detailed output
debug=0				# debug level
class_pos_option="-last"	# feature2ml option for class variable position
misc_feature2ml_options=""      # other feature2ml options
nolabels=1			# first line specifies lables
max_mem=1024			# java VM size
weka_jar=""			# path to Weka jar file

# Show usage if no arguments are given
if [ "$1" = "" ]; then
    echo ""
    echo "usage: $0 [options] training-file [testing-file]"
    echo "options = [--folds N] [--all] [--all-bases] [--usual] [--nolabels] [--label-file file] [--trace] [--debug] [--weka jar-file]"
    echo ""
    echo "Examples:"
    echo ""
    echo "$0 toms-foods-train.table toms-foods-test.table"
    echo ""
    echo "perlgrep.perl -para 'Feature variable assignments' table.doc | extract_matches.perl '^\S+\t\S+\t(.*)' - | perl -pe 's/ /\_/g;' >| feature-labels.list";
    echo "$0 --usual --first --label-file feature-labels.list table0.train table0.test"
    echo ""
    echo "$0 -weka c:/Program-Misc/Weka-3-7/weka.jar  mass-noun.data >| mass-noun.data.log 2>&1"
    echo ""
    echo "Notes:"
    echo "- Assumes CLASSPATH is includes weka.jar; use -weka option if not."
    echo "- By default J4.8 is used as base classification class."
    echo "- CLASSPATH should use Unix format if spaces in path."
    echo ""
    echo "Description of options:"
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
    elif [ "$1" = "--all-bases" ]; then
	all_bases=1
    elif [ "$1" = "--usual" ]; then
	usual=1
    elif [ "$1" = "--trace" ]; then
	trace=1
    elif [ "$1" = "--verbose" ]; then
	verbose=1
    elif [ "$1" = "--debug" ]; then
	debug=1
    elif [ "$1" = "--label-file" ]; then
	export labels=`cat $2`
	nolabels=1
	shift
    elif [ "$1" = "--max-mem" ]; then
        max_mem=$2
        shift
    elif [ "$1" = "--4GB" ]; then
        ## max_mem=4096
        max_mem=3800
    elif [ "$1" = "--2GB" ]; then
        max_mem=2048
    elif [ "$1" = "--labels" ]; then
	nolabels=0
    elif [ "$1" = "--no-labels" ]; then
	nolabels=1
    elif [ "$1" = "--first" ]; then
	class_pos_option="-first"
    elif [ "$1" = "--last" ]; then
	class_pos_option="-last"
    elif [ "$1" = "--weka" ]; then
        weka_jar="$2"
        shift
    elif [ "$1" = "--csv" ]; then
	misc_feature2ml_options="-csv"
    else
	echo "ERROR: invalid option '$1'"
        exit
    fi
    shift
    moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
done

train_file=$1
train_base=`basename "$train_file" .table`
result_base=$train_base
if [ "$2" != "" ]; then 
    test_file=$2
fi

if [ $trace = 1 ]; then 
    set -o xtrace
    if [ $verbose = 1 ]; then
	set -o verbose
    fi
fi

#........................................................................
# Extract the feature table from lexical data using Weka's arff format

# Determine temporary file dir and basename prefix
# TODO: allow for temp directory specification
temp_dir="$TMP"
if [ "$temp_dir" = "" ]; then
    if [ -d /local/tmp ] && [ -w /local/tmp ]; then temp_dir="/local/tmp"; fi
fi
## if [ $debug = 1 ]; then temp_dir=./temp-; fi
if [ $OSTYPE = "cygwin" ]; then temp_dir=`cygpath -w "$temp_dir"`; fi
temp="$temp_dir/temp-$$"
temp_log="$temp-run-weka.log"
echo "" > $temp_log

# Convert feature table into Weka's .arff format
cp $train_file $temp-${train_base}.table

options="-weka $misc_feature2ml_options $class_pos_option"
if [ $nolabels = 1 ]; then options="$options -nolabels"; fi
perl -Ssw feature2ml.perl $options $temp-${train_base}.table >> $temp_log
if [ "$test_file" != "" ]; then
    test_base=`basename "$test_file" .table`
    result_base="${train_base}-${test_base}"
    cp $test_file $temp-${test_base}.table
    perl -Ssw feature2ml.perl $options $temp-${test_base}.table >> $temp_log

    # Make sure the file headers match for training and test files
    #
    # Extract the attribute listing from the combined data file
    # NOTE: the label line of both files must match
    ## cat $temp-${test_base}.table | perl -Ssw perlgrep.perl -v '^\s*$' > $temp-${result_base}.table
    ## tail +2 $temp-${train_base}.table >> $temp-${result_base}.table
    cat $train_file $test_file >| $temp-${result_base}.table
    perl -Ssw feature2ml.perl $options $temp-${result_base}.table >> $temp_log >> $temp_log
    grep '^@' $temp-${result_base}.arff > $temp-${result_base}.header
    #
    # Replace the training data header with the combined header
    grep -v '^@' $temp-${train_base}.arff >| $temp-${train_base}.data
    cat $temp-${result_base}.header $temp-${train_base}.data >| $temp-${train_base}.arff
    #
    # Replace the test data header with the combined header
    # TODO: have option for when no labels are included
    grep -v '^@' $temp-${test_base}.arff >| $temp-${test_base}.data
    cat $temp-${result_base}.header $temp-${test_base}.data >| $temp-${test_base}.arff
fi

#........................................................................
# Make sure Weka accessible

# Make sure CLASSPATH is setup properly under Cygwin
# TODO: handle spaces and also multiple paths properly

if [ "$weka_jar" != "" ]; then
    export CLASSPATH="$weka_jar:$CLASSPATH"
    if [ $OSTYPE = "cygwin" ]; then
	export CLASSPATH="`cygpath -w $CLASSPATH`"; 
    fi
fi

# Set up the Java path setting (i.e., CLASSPATH environment variable)
if [ "$CLASSPATH" = "" ]; then
    echo "Warning: guessing that default Weka location being used!"
    if [ $OSTYPE = "cygwin" ]; then 
    	# TODO: make sure default uses normal weka naming convention
	export CLASSPATH="/cycgpath/c/Program Files/Weka-3-7"
    else
	export CLASSPATH="`cygpath -w $CLASSPATH | perl -pe 's@^(\w):@/cygpath/$1@;'`"
    fi
fi

# Trace setting
if [ $verbose = 1 ]; then
    echo "CLASSPATH: $CLASSPATH"
fi

#........................................................................
# Run the classifier using ID3, Bayes, and also J48 (C4.5 clone)
# TODO: have options for running specific classifiers

# Set java VM options
#  -mx<size> maximum heap size
#  -oss<size> java thread stack size
java_options="-mx${max_mem}m -oss${max_mem}m"

# Setup the options for the Weka classifiers
#   -v: Outputs no statistics for training data
#   -t: training file
#   -T: testing file
#   -x: number of folds for cross-validation
weka_options="-v -i -k -t $temp-${train_base}.arff"
if [ "$test_file" != "" ]; then
    weka_options="${weka_options} -T $temp-${test_base}.arff"
else
    weka_options="${weka_options} -x $folds"
fi
# TODO: figure out Weka's debug option
## if [ $debug = 1 ]; then weka_options="-D ${weka_options}"; fi

# Trace the options
if [ $verbose = 1 ]; then
    echo "Java options: $java_options"
    echo "Weka options: $weka_options"
fi

# Determine where to look for the results
test_section='Stratified cross-validation'
if [ "$test_file" != "" ]; then test_section='Error on test data'; fi

# Determine classes for each of the usual classifiers: ID3, J48 and Naive Bayes
# TODO: add SVM
id3=weka.classifiers.trees.Id3
j48=weka.classifiers.trees.J48
j48_base=j48.J48
naive=weka.classifiers.bayes.NaiveBayesSimple

# Run the usual classifiers ID3 and NaiveBayes
#
function check-weka-results () { echo -n "$1	"; grep -A3 "$test_section" ${result_base}.$1  | grep 'Correctly Classified Instances' | perl -pe 's/\-Correctly.* (\S+ +\%)/\t\1/;'; }
#
if [ $usual = 1 ]; then
    echo "Running ID3 and Naive Bayes"

    nice -19 java $java_options $id3 $weka_options >| ${result_base}.id3
    check-weka-results id3

    nice -19 java  $java_options $naive $weka_options >| ${result_base}.naive
    check-weka-results naive
fi

# Run the main classification using J48 decision tree classifier (C4.5 clone)
echo "Running J4.8"
nice -19 java $java_options $j48 $weka_options >| ${result_base}.j48
#
grep -A3 "$test_section" ${result_base}.j48 | grep 'Correctly Classified Instances' | perl -pe 's/\-Correctly.* (\S+ +\%)/\t\1/;'

# Cleanup the temporary files
if [ $debug = 0 ]; then rm --force $temp-*; fi
