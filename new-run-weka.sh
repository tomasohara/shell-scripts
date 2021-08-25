#! /bin/bash
# run-weka.sh: script for running Weka classifiers, defaulting to Naive Bayes, ZeroR (most common class),
# and J48 (a C4.5 clone).
#
# TODO:
# - *** echo CLASSPATH and other implicit setting needed to reproduce ***
# - Add in support for meta-folds (see new-run-lexicalization-POS-experiments.sh).
# - Standardize file extension usage (e.g., 'naive' for Naive Bayes rather
#   than 'naive-bayes').
# - Use CSV feaure of Weka to avoid need for feature2ml.perl and test/train ARFF header fixup.
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
skip_arff=0                     # skip conversion to ARFF format
folds=10			# number of cross-validation folds
usual=0				# use usual Weka classifiers (Naive Bayes and ZeroR)
trace=0				# script tracing
verbose=0			# detailed output
## OLD: debug=0			   # debug level
debug="$DEBUG_LEVEL"		# debug level
class_pos_option="-last"	# feature2ml option for class variable position
feature2ml_options="-stdout=0"  # other feature2ml options
nolabels=1			# first line specifies lables
max_mem=1024			# java VM size
weka_jar=""			# path to Weka jar file
include_SVM=0                   # include libSVM (as well as J48)
time_option=""                  # prefix placeholder for timing command (e.g., via /bin/time)
include_J48=1                   # include J48 (C4.5 clone)
other_classifier_labels=()      # labels for other classifiers to run
other_classifier_classes=()     # java class names for other classifiers to run (sans weka.classifier prefix)

# Show usage if no arguments are given
if [ "$1" = "" ]; then
    script_name=$(basename $0)
    echo ""
    echo "usage: $0 [options] training-file [testing-file]"
    echo "options = [--folds N] [--usual] [--svm] [--[skip-]j48] ] [--csv] [--skip-arff] [--no-labels] [--label-file file] [--trace] [--debug] [--weka jar-file] [--4GB | --2GB | [--GB N] | [--max-mem mb]] [--time] [--other-classifier label relative-class-spec]"
    echo ""
    echo "Examples:"
    echo ""
    echo "$0 toms-foods-train.table toms-foods-test.table"
    echo ""
    echo "perlgrep.perl -para 'Feature variable assignments' table.doc | extract_matches.perl '^\S+\t\S+\t(.*)' - | perl -pe 's/ /\_/g;' >| feature-labels.list";
    echo "$0 --usual --first --label-file feature-labels.list table0.train table0.test"
    echo ""
    echo "$0 --weka c:/Program-Misc/Weka-3-7/weka.jar  mass-noun.data >| mass-noun.data.log 2>&1"
    echo ""
    echo "$script_name --weka ~/programs/java/weka-3-8-5/weka.jar iris.arff > iris.weka.log 2>&1"
    echo ""
    echo "Notes:"
    echo "- Assumes CLASSPATH is includes weka.jar; use -weka option if not."
    echo "- By default J4.8 is only run."
    echo "- With --usual option, Naive Bayes (simple) and libSVM are also included."
    echo "- CLASSPATH should use Unix format if spaces in path."
    echo "- Use run-all-weka-classifiers.sh to run all available classifiers in Weka."
    echo "- 10-fold cross validation is run by default unless test file specified."
    echo "- Use --folds to change number of folds."
    echo "- First line is assumed to be feature labels unless --no-labels specified."
    echo "- Lines starting with ';' or '#' are assumed to be comments (see feature2ml.perl)."
    echo "- Tabular format (i.e., tab-delimited) assumed unless --csv specified (comma separated)."
    echo "- The -verbose option by itself gives detailed output and in combination with --trace, also enabled bash verbose command setting."
    echo "- The --debug option enables Weka debugging output but unfortunatelty is not supported by some classifiers (e.g., J48)."
    exit
fi

# Check the command-line arguments
moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
while [ "$moreoptions" = "1" ]; do
    if [ "$1" = "--folds" ]; then
	folds=$2
	shift
    elif [ "$1" = "--usual" ]; then
	usual=1
    elif [ "$1" = "--svm" ]; then
	include_SVM=1
    elif [ "$1" = "--j48" ]; then
	include_J48=1
    elif [ "$1" = "--skip-j48" ]; then
	include_J48=0
    elif [ "$1" = "--trace" ]; then
	trace=1
	set -o xtrace
	if [ $verbose = 1 ]; then set -o verbose; fi
    elif [ "$1" = "--verbose" ]; then
	verbose=1
	if [ $trace = 1 ]; then set -o verbose; fi
    elif [ "$1" = "--debug" ]; then
	debug=1
    elif [ "$1" = "--label-file" ]; then
	export labels=`cat $2`
	nolabels=1
	shift
    elif [ "$1" = "--max-mem" ]; then
        max_mem=$2
        shift
    elif [ "$1" = "--GB" ]; then
        max_mem=$(($2 * 1024))
        shift
    elif [ "$1" = "--4GB" ]; then
        max_mem=4096
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
	feature2ml_options="$feature2ml_options -csv"
    elif [ "$1" = "--time" ]; then
	time_option="/bin/time"
    elif [ "$1" = "--other-classifier" ]; then
	other_classifier_labels=(${other_classifier_labels[*]} $2)
	other_classifier_classes=(${other_classifier_classes[*]} $3)
	shift 2
    elif [ "$1" = "--skip-arff" ]; then
	skip_arff=1
    elif [ "$1" == "--trace" ]; then
	set -o xtrace
    else
	echo "ERROR: invalid option '$1'"
        exit
    fi
    shift
    moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
done

# Check file options
# TODO: warn about filenames with leading dashes due to argument order problems
# ex: new-run-weka.sh new-run-weka.sh --verbose --csv --labels ...
# NOTE: Conversion to arff format skipped if "arff" in training filename
# TODO: check for other specific extensions (e.g., .csv and .data)
train_file="$1"
ext="table"
if [[ $train_file =~ .arff ]]; then
    skip_arff=1;
    ext="arff";
else
    ext=$(echo "$train_file" | perl -pe 's/^.*\.(\w+)$/$1/;')
fi

if [ $verbose = 1 ]; then echo "train_file: $train_file"; fi
## OLD: train_base=`basename "$train_file" .table`
train_base=$(basename "$train_file" .$ext)
result_base=$train_base
test_file=""
if [ "$2" != "" ]; then
    test_file="$2"
fi
if [ $verbose = 1 ]; then echo "test_file: $test_file"; fi

# Optionally enable tracing
## OLD:
## if [ $trace = 1 ]; then
##    set -o xtrace
##    if [ $verbose = 1 ]; then
##	set -o verbose
##    fi
## fi

#........................................................................
# Extract the feature table from lexical data using Weka's arff format

# Determine temporary file dir and basename prefix
# TODO: allow for temp directory specification
temp_dir="$TMP"
if [ "$temp_dir" = "" ]; then
    if [ -d /local/tmp ] && [ -w /local/tmp ]; then temp_dir="/local/tmp"; fi
fi
if [ $debug = 1 ]; then temp_dir=.; fi
if [ $OSTYPE = "cygwin" ]; then temp_dir=`cygpath -w "$temp_dir"`; fi
temp="$temp_dir/temp-$$"
temp_log="$temp-run-weka.log"
echo "" > $temp_log

# Convert feature table into Weka's .arff format
if [ $skip_arff = 1 ]; then
    # Copy over ARFF files as is
    cp -vp $train_file $temp-${train_base}.arff
    if [ "$test_file" != "" ]; then cp -vp $test_file $temp-${test_base}.arff; fi
else
    # Convert training file into ARFF
    cp -vp $train_file $temp-${train_base}.$ext
    options="-weka $feature2ml_options $class_pos_option"
    if [ $nolabels = 1 ]; then options="$options -nolabels"; fi
    if [ $verbose = 1 ]; then echo "Issuing: feature2ml.perl $options $temp-${train_base}.$ext"; fi
    $time_option  perl -Ssw feature2ml.perl $options $temp-${train_base}.$ext >> $temp_log
    #
    # Optionally convert test file, syncrhonizing header with training file
    if [ "$test_file" != "" ]; then
	test_base=`basename "$test_file" .$ext`
	result_base="${train_base}-${test_base}"

	# Convert testing file into ARFF
	cp -vp $test_file $temp-${test_base}.$ext
	if [ $verbose = 1 ]; then echo "Issuing: feature2ml.perl $options $temp-${test_base}.$ext"; fi
	$time_option  perl -Ssw feature2ml.perl $options $temp-${test_base}.$ext >> $temp_log

        # Make sure the ARFF file headers match for training and test files
        # NOTE: the label line of both of the original files must match.
        #
	# Create combined ARFF data file
	cat $train_file $test_file >| $temp-${result_base}.$ext
	$time_option  perl -Ssw feature2ml.perl $options $temp-${result_base}.$ext >> $temp_log >> $temp_log
	#
        # Extract the attribute listing from the combined data file
	grep '^@' $temp-${result_base}.arff > $temp-${result_base}.header
        #
        # Replace the training data header with the combined header
	grep -v '^@' $temp-${train_base}.arff >| $temp-${train_base}.data
	cat $temp-${result_base}.header $temp-${train_base}.data >| $temp-${train_base}.arff
        #
        # Replace the test data header with the combined header
	grep -v '^@' $temp-${test_base}.arff >| $temp-${test_base}.data
	cat $temp-${result_base}.header $temp-${test_base}.data >| $temp-${test_base}.arff
    fi
fi

#........................................................................
# Make sure Weka binaries accessible

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

# Set java VM options
#  -mx<size> maximum heap size
#  -oss<size> java thread stack size
java_options="-mx${max_mem}m -oss${max_mem}m"

# Setup the options for the Weka classifiers
#   -v: Outputs no statistics for training data.
## OLD   -i: Outputs detailed information-retrieval statistics for each class (i.e., "Detailed Accuracy By Class" section).
#   -k: Outputs information-theoretic statistics (e.g., "K&B Relative Info Score" and "Complexity improvement").
#   -t: Training file.
#   -T: Testing file.
#   -x: Number of folds for cross-validation.
#   -D: Debug mode (*** not supported by J48 ***)
weka_options=""
if [ $debug = 1 ]; then weka_options="${weka_options} -D"; fi
## OLD: weka_options="${weka_options} -v -i -k -t $temp-${train_base}.arff"
weka_options="${weka_options} -v -k -t $temp-${train_base}.arff"
if [ "$test_file" != "" ]; then
    weka_options="${weka_options} -T $temp-${test_base}.arff"
else
    weka_options="${weka_options} -x $folds"
fi

# Trace the options
if [ $verbose = 1 ]; then
    echo "Java options: $java_options"
    echo "Weka options: $weka_options"
fi

# Determine where to look for the results
test_section='Stratified cross-validation'
if [ "$test_file" != "" ]; then test_section='Error on test data'; fi

# Determine classes for each of the usual classifiers: ZeroR, Naive Bayes, and J48
# Note: order is from fastest to slowest (to allow for quicker feedback)
classifier_base="weka.classifiers"
j48=$classifier_base.trees.J48
svm=$classifier_base.functions.LibSVM
## OLD: naive=$classifier_base.bayes.NaiveBayesSimple
naive=$classifier_base.bayes.NaiveBayes
zeror=$classifier_base.rules.ZeroR
classifier_labels=(${other_classifier_labels[*]})
classifier_classes=(${other_classifier_classes[*]})
if [ $include_J48 = 1 ]; then
    # Add in J48 (C4.5 clone)
    classifier_labels=(${classifier_labels[*]} j48)
    classifier_classes=(${classifier_classes[*]} $j48)
fi
if [ $usual = 1 ]; then
    # Add in some baseline classifiers
    classifier_labels=(zeror naive ${classifier_labels[*]})
    classifier_classes=($zeror $naive ${classifier_classes[*]})
fi
if [ $include_SVM = 1 ]; then
    # Add in libSVM (which could take a long time to run)
    classifier_labels=(${classifier_labels[*]} svm)
    classifier_classes=(${classifier_classes[*]} $svm)
fi
num_classifiers=${#classifier_classes[*]}

# Run the usual classifiers SVM and NaiveBayes
#
function check-weka-results () {
    echo -n "$1	";
    grep -A3 "$test_section" ${result_base}.$1  | grep 'Correctly Classified Instances' | perl -pe 's/\-Correctly.* (\S+ +\%)/\t\1/;';
}
#
for (( i=0; i < $num_classifiers; i++ )); do
    label=${classifier_labels[$i]}
    classifier=${classifier_classes[$i]}
    if [ $verbose = 1 ]; then 
	echo "i: $i"
	echo "Running $label ($classifier)"
	echo "Issuing: java $java_options $classifier $weka_options"
    fi
    # TODO: put debug option here and special case for exlcusions like J48 (and also redirect stderr to stdout???)
    $time_option  java  $java_options  $classifier  $weka_options >| ${result_base}.$label
    check-weka-results $label
done

# Cleanup the temporary files ($temp is "$temp_dir/temp-$$")
if [ $debug = 0 ]; then rm --force $temp-*; fi
