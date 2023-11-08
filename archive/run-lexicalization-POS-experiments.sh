#! /bin/bash
# run-lexicalization-POS-experiments.sh: script for running machine learning
# experiments in which the part-of-speech for lexicalizations are inferred
# from denotations in the Cyc KB, as discussed in the Cycorp IJCAI-03 
# paper submission:
#
#    Inducing criteria for lexicalization parts of speech using the Cyc
#    KB, and its extension to WordNet 
#
#    Tom O'Hara, Stefano Bertolo, Nancy Salay, Bjoern Aldag, 
#    Jon Curtis, Michael Witbrock, and Kathy Panton
#
# This covers the special case for mass-count classification from the Cycorp IWCS-5 paper.
#
#    Inducing criteria for mass noun lexical mappings using the Cyc KB,
#    and its extension to WordNet
#
#    Tom O'Hara, Nancy Salay, Michael Witbrock, Dave Schneider,
#    Bjoern Aldag, Stefano Bertolo, Kathy Panton, Fritz Lehmann*,
#    Jon Curtis, Matt Smith, David Baxter, and Peter Wagner
#
# The classification is done using the Weka machine learning. This also
# assumes that the preprocessing of Cyc's lexical information has already
# been done using the preprecoess-lexical-data.sh script.
#
# NOTES: 
# - This requires the metrics file extract_cyc_speech_part_full.metrics
#     zcat extract_cyc_speech_part_full.log.gz | perl -Ssw get_cyc_speech_part_collocations.perl - >| extract_cyc_speech_part_full.cooccur
#     perl -Ssw calc_cooccurrence.perl -precision=6 extract_cyc_speech_part_full.cooccur >| extract_cyc_speech_part_full.metrics
#
# TODO:
# - document all the input files
# - add support for separate reference term selection in 10-fold cross validation
# - show an example illustrating the manual steps that this script automates
# - put the result in a separate subdirectory per experiment so that the file name 
#   doesn't have to be unique for each
#
#........................................................................
# Weka options
#
# -t <name of training file>	training file
# -T <name of test file>	test file
# -x <number of folds>		number of folds for cross-validation
# -i				outputs information-retrieval statistics
# -k				outputs information-theoretic statistics.
#
#........................................................................
#
## set -o xtrace

# Set defaults for the options
wordnet=0			# map reference terms into wordnet
map=""				# optional mapping label for output file
extract_file="extract_cyc_speech_part_full.log.gz"  # input file
folds=10			# number of cross-validation folds
rerun=0				# rerun classification without reformatting tables
all=0				# use all Weka classifiers (not just J48)
mass=0				# use full set speech parts (not just mass and count)
subset="full"			# label of speech part subset for output file
POS_regex="\w+"			# egrep regular expression for POS filtering
trace=0				# script tracing
features="-specific-inherited"	# label of feature settings for file name
debug=0				# debug level

# Show usage if no arguments are given
if [ "$1" = "" ]; then
    echo ""
    echo "usage: $0 [options] num-ref-terms metric [num-instances]"
    echo "options = [--mass] [--wordnet] [--folds N] [--rerun] [--all]"
    echo "          [--wordunit] [--headword] [--suffixes] [--dir dirname] [--debug]"
    echo ""
    echo "num-ref-terms is number of Cyc terms used as reference terms (i.e., binary feature)."
    echo "The total number of features is twice this value (one each for isa and genls)."
    echo ""
    echo "Examples:"
    echo ""
    echo "$0 256 joint"
    echo ""
    echo "$0 - object_stuff_types.list"
    echo ""
    echo "export CLASSPATH=$HOME/bin/weka-3-2-3/weka.jar"
    echo "$0 256 freq >| general-speech-parts-experiments.256.log 2>&1"
    echo ""
    echo "$0 --mass 128 freq >| mass-count-experiments.128.log 2>&1"
    echo ""
    echo "$0 --wordunit -mass 128 freq >| word-mass-count-experiments.128.log 2>&1"
    echo ""
    echo "Notes:"
    echo "Description of options:"
    echo "    --all           run all classifiers"
    echo "    --mass          use just the MassNoun and CountNoun speech parts"
    echo "    --wordunit      use wordunit for headword as a feature"
    echo "    --headword      use inflected headword as a feature"
    echo "    --suffixes      include each suffixes of size 2, 3, and 4"
    echo "    --rerun         rerun the experiment using existing feature file"
    echo "    --wordnet       map the reference terms into WordNet synsets"
    echo "    --folds N       run N-fold cross validation"
    echo "By default, the main result will be in the following file:"
    echo "      freq-full-specific-inherited.128.x10."
    echo "See the README file for an explanation of the naming convention."
    echo ""
    exit
fi

# Check the command-line arguments
moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
while [ "$moreoptions" = "1" ]; do
    if [ "$1" = "--wordnet" ]; then
	wordnet=1
	map="wn-"
    elif [ "$1" = "--folds" ]; then
	folds=$2
	shift
    elif [ "$1" = "--dir" ]; then
	shift
	cd $1
    elif [ "$1" = "--rerun" ]; then
	rerun=1
    elif [ "$1" = "--all" ]; then
	all=1
    elif [ "$1" = "--wordunit" ]; then
	export wordunit=1
	features="${features}-wu"
    elif [ "$1" = "--headword" ]; then
	export headword=1
	features="${features}-hw"
    elif [ "$1" = "--suffixes" ]; then
	export suffixes=1
	features="${features}-suffix"
    elif [ "$1" = "--trace" ]; then
	trace=1
    elif [ "$1" = "--debug" ]; then
	debug=1
    elif [ "$1" = "--mass" ]; then
	mass=1
	subset="mass"
	POS_regex="MassNoun|SimpleNoun|CountNoun"
    else
	echo "ERROR: invalid option '$1'"
        exit
    fi
    shift
    moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
done

collocates=$1
instances=1000000
metric=freq
if [ "$2" != "" ]; then metric=$2; fi
if [ "$3" != "" ]; then 
    instances=$3
    features="${features}-$instances"
fi
result_base="${map}$metric-${subset}${features}.$collocates.x$folds"


# Display the settings in effect
system_status.sh -
echo "result_base=${result_base}"
echo "collocates=$collocates; metric=$metric; instances=$instances; folds=$folds"
echo "features='$features' POS_regex='${POS_regex}' subset='$subset' map='$map'"

# Make sure the script directory is in the path
dir=`dirname $0`
export PATH="${dir}:$PATH"
if [ $?PERLLIB = 0 ]; then export PERLLIB=""; fi
export PERLLIB="${dir}:$PERLLIB"

if [ $trace = 1 ]; then echo "dir=$dir; PERLLIB=$PERLLIB; PATH=$PATH"; fi

#........................................................................
# Extract the reference term based 'collocation' information
#
# Notes: 
#
# - This is used later by format_cyc_speech_part_features.perl.
#
# - By default, this just uses frequency to determine the reference terms.
# But these can also be derived by co-occurrence analysis over the
# lexical data in extract_cyc_speech_part_full.log.gz. 
#
# TODO:
# - Use separate collocation lists per fold in case the metric is the
# default one just based on frequency (e.g., MI).
#

# Determine column position in metrics output file
pos=-1
case "$metric" in
    joint) pos=0;;
    dice) pos=1;;
    jaccard) pos=2;;
    MI) pos=3;;
    mi) pos=3;;
    x2) pos=4;;
    g2) pos=5;;
    avg-MI) pos=6;;
    avg-mi) pos=6;;
    freq) pos=666;;
esac

# Extract the list of types by sorting by that position in the metrics file and taking top-N types

# TODO: do selective tracing
if [ $trace = 1 ]; then 
    set -o verbose
fi
if [ $rerun = 0 ]; then
    if [ $pos = -1 ]; then
        cp $metric temp-unquoted-${result_base}.list
    
    elif [ "$metric" = "freq" ]; then
        # For the special case of frequency, determine the parent types that occur
        # most often for mass noun and count noun denotatums from the original listing.
    
        # Create separate lists for ISA's and GENLS's
    
        # Get list of ISA reference terms
        zcat ${extract_file} | perl -Ssw perlgrep.perl -para "POS=(${POS_regex})" | grep "types=" | perl -Ssw count_it.perl "([^\t]+)" | cut -f1 | egrep -v "(types)|( )" > temp-all-${result_base}-isa.list
    
        # Filter out the quoted collections from the ISA list
        perl -Ssw intersection.perl -diff -line temp-all-${result_base}-isa.list quotedCollection.list | head -$collocates > temp-unquoted-${result_base}-isa.list
    
        # Get list of GENLS reference terms
        zcat ${extract_file} | perl -Ssw perlgrep.perl -para "POS=(${POS_regex})" | grep "generalizations=" | perl -Ssw count_it.perl "([^\t]+)" | cut -f1 | egrep -v "(generalizations)|( )" > temp-all-${result_base}-genls.list
    
        # Filter out the quoted collections from the GENLS list
        perl -Ssw intersection.perl -diff -line temp-all-${result_base}-genls.list quotedCollection.list | head -$collocates > temp-unquoted-${result_base}-genls.list
    
    else
    
        # Extract the list of reference terms from the co-occurrence analysis listing
        # TODO: see if egrep has a special tab character class (eg, \t); or, use perlgrep
        zcat extract_cyc_speech_part_full.metrics.gz | sort +$pos -rn | egrep "	(${POS_regex})" > temp-all-${result_base}.list
        perl -Ssw intersection.perl -diff -line temp-all-${result_base}.list quotedCollection.list | head -$collocates | perl -Ssw extract_matches.perl '\S+$' - >| temp-unquoted-${result_base}.list
    
    fi
fi

#........................................................................
# Optionally, map the reference terms into wordnet
mapping_options=""
if [ $rerun = 0 ]; then
    if [ "$wordnet" = 1 ]; then

        perl -Ssw paste.perl -keys temp-unquoted-${result_base}-isa.list cyc_ancestor_list_wordnet_mapping.data | grep -v "n/a" | grep -v "???" | perl -pe "s/\t\t/\t/;" >| temp-unquoted-${result_base}.wordnet
        perl -Ssw paste.perl -keys temp-unquoted-${result_base}-genls.list cyc_ancestor_list_wordnet_mapping.data | grep -v "n/a" | grep -v "???" | perl -pe "s/\t\t/\t/;" >> temp-unquoted-${result_base}.wordnet
    
        mapping_options="-mapping_file=temp-unquoted-${result_base}.wordnet"
    fi
fi


#........................................................................
# Extract the feature table from lexical data using Weka's arff format

# Produce feature table in tab-delimited format
if [ $rerun = 0 ]; then
    zcat ${extract_file} | perl -Ssw format_cyc_speech_part_features.perl -max_instances=$instances -separate -type_file=temp-unquoted-${result_base}-isa.list -genls_file=temp-unquoted-${result_base}-genls.list $mapping_options - | egrep "^(POS|${POS_regex})" >| temp-${result_base}.table
fi

# Convert feature table into Weka's .arff format
if [ $rerun = 0 ]; then
    perl -Ssw feature2ml.perl -first -weka temp-${result_base}.table
fi


#........................................................................
# Run the classifier using ID3, Bayes, and also J48 (C4.5 clone)
# TODO: have options for running specific classifiers

# Set up the Java path setting (i.e., CLASSPATH environment variable)
if [ "$CLASSPATH" = "" ]; then
   if [ $OSTYPE = "cygwin" ]; then
      export CLASSPATH="f:\\Program Files\\Weka-3-2\\weka.jar"
   else 
      export CLASSPATH="/home/graphling/TOOLS/WEKA/weka-3-2-3/weka.jar"
   fi
fi

# Setup the options for the Weka classifiers
weka_options="-i -k -x $folds -t temp-${result_base}.arff"

# Run miscellaneous classifiers for comparison purposes: ID3 decision tree,
# as well as the simple and enhanced Naive Bayes classifiers.
if [ $all = 1 ]; then
    nice -19 java -mx1024m -oss1024m weka.classifiers.Id3  $weka_options >| ${result_base}.id3
    nice -19 java -mx1024m -oss1024m weka.classifiers.NaiveBayesSimple $weka_options >| ${result_base}.naive
    ## nice -19 java -mx1024m -oss1024m weka.classifiers.NaiveBayes $weka_options >| ${result_base}.naive-plus
fi

# Run the main classification using J48 decision tree classifier (C4.5 clone)
nice -19 java -mx1024m -oss1024m weka.classifiers.j48.J48 $weka_options >| ${result_base}.j48

# Cleanup the temporary files
if [ $debug = 0 ]; then rm temp-${result_base}.*; fi
date
