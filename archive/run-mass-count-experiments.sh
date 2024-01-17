#! /bin/bash
# script for formatting mass-count speeh part features and performing the classification
# using the Weka machine learning package
#
# NOTES: 
# - This requires the metrics file extract_cyc_speech_part_full.metrics
#     zcat extract_cyc_speech_part_full.log.gz | perl -Ssw get_cyc_speech_part_collocations.perl - >| extract_cyc_speech_part_full.cooccur
#     perl -Ssw calc_cooccurrence.perl -precision=6 extract_cyc_speech_part_full.cooccur >| extract_cyc_speech_part_full.metrics
#
# TODO:
# - document all the input files
# - add support for separate reference term selection in 10-fold cross validation
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
wordnet=0
map_prefix=""
extract_file="extract_cyc_speech_part_full.log.gz"
folds=10
rerun=0
all=0

# Show usage if no arguments are given
if [ "$1" = "" ]; then
    echo ""
    echo "usage: $0 [options] num-ref-terms metric [num-instances]"
    echo "       options=[--wordnet] [--folds N] [--rerun] [--all]"
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
    echo "export CLASSPATH=/home/$USER/bin/weka-3-2-3/weka.jar"
    echo "$0 128 freq >| mass-count-experiments.128.log 2>&1"
    echo ""
    echo "Notes:"
    echo "- Description of options:"
    echo "      --all           run all classifiers"
    echo "      --rerun         rerun the experiment using existing feature file"
    echo "      --wordnet       map the reference terms into WordNet synsets"
    echo "      --folds N       run N-fold cross validation"
    echo "- By default, the main result will be in the following file:"
    echo "      unquoted-freq-mass-full-specific-inherited.128.x10."
    echo "See the README file for an explanation of the naming convention."
    echo ""
    exit
fi

# Check the command-line arguments
moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
while [ "$moreoptions" = "1" ]; do
    if [ "$1" = "--wordnet" ]; then
	wordnet=1
	map_prefix="wn-"
    fi
    if [ "$1" = "--folds" ]; then
	folds=$2
	shift
    fi
    if [ "$1" = "--rerun" ]; then
	rerun=1
    fi
    if [ "$1" = "--all" ]; then
	all=1
    fi
    shift
    moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
done

collocates=$1
instances=1000000
metric=freq
if [ "$2" != "" ]; then metric=$2; fi
if [ "$3" != "" ]; then instances=$3; fi
echo "collocates=$collocates; metric=$metric; instances=$instances; folds=$folds"

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
set -o xtrace
if [ $rerun = 0 ]; then
    if [ $pos = -1 ]; then
        cp $metric unquoted-mass-count-$metric.list
    
    elif [ "$metric" = "freq" ]; then
        # For the special case of frequency, determine the parent types that occur
        # most often for mass noun and count noun denotatums from the original listing.
    
        # Create separate lists for ISA's and GENLS's
        # TODO: have separate -collocates option for ISA and GENLS
    
        echo zcat ${extract_file} \| perl -Ssw perlgrep.perl -para '"POS=(MassNoun|SimpleNoun|CountNoun)"' \| grep '"types="' \| perl -Ssw count_it.perl '"([^\t]+)"' \| cut -f1 \| egrep -v '"(types)|( )"' \> full-mass-count-${metric}-isa.list
        # Get list of ISA reference terms
        zcat ${extract_file} | perl -Ssw perlgrep.perl -para "POS=(MassNoun|SimpleNoun|CountNoun)" | grep "types=" | perl -Ssw count_it.perl "([^\t]+)" | cut -f1 | egrep -v "(types)|( )" > full-mass-count-${metric}-isa.list
    
        # Filter out the quoted collections from the ISA list
        perl -Ssw intersection.perl -diff -line full-mass-count-${metric}-isa.list quotedCollection.list | head -$collocates > unquoted-mass-count-${metric}-isa.list
    
        # Get list of GENLS reference terms
        zcat ${extract_file} | perl -Ssw perlgrep.perl -para "POS=(MassNoun|SimpleNoun|CountNoun)" | grep "generalizations=" | perl -Ssw count_it.perl "([^\t]+)" | cut -f1 | egrep -v "(generalizations)|( )" > full-mass-count-${metric}-genls.list
    
        # Filter out the quoted collections from the GENLS list
        perl -Ssw intersection.perl -diff -line full-mass-count-${metric}-genls.list quotedCollection.list | head -$collocates > unquoted-mass-count-${metric}-genls.list
    
    else
    
        # Extract the list of reference terms from the co-occurrence analysis listing
        # TODO: see if egrep has a special tab character class (eg, \t); or, use perlgrep
        sort +$pos -rn extract_cyc_speech_part_full.metrics | egrep "	(MassNoun|SimpleNoun|CountNoun)" > full-mass-count-$metric.list
        perl -Ssw intersection.perl -diff -line full-mass-count-$metric.list quotedCollection.list | head -$collocates | perl -Ssw extract_matches.perl '\S+$' - >| unquoted-mass-count-$metric.list
    
    fi
fi

#........................................................................
# Optionally, map the reference terms into wordnet
mapping_options=""
if [ $rerun = 0 ]; then
    if [ "$wordnet" = 1 ]; then

        perl -Ssw paste.perl -keys unquoted-mass-count-$metric-isa.list cyc_ancestor_list_wordnet_mapping.data | grep -v "n/a" | grep -v "???" | perl -pe "s/\t\t/\t/;" >| unquoted-mass-count-$metric.wordnet
        perl -Ssw paste.perl -keys unquoted-mass-count-$metric-genls.list cyc_ancestor_list_wordnet_mapping.data | grep -v "n/a" | grep -v "???" | perl -pe "s/\t\t/\t/;" >> unquoted-mass-count-$metric.wordnet
    
        mapping_options="-mapping_file=unquoted-mass-count-$metric.wordnet"
    fi
fi


#........................................................................
# Extract the feature table from lexical data using Weka's arff format

# Produce feature table in tab-delimited format
if [ $rerun = 0 ]; then
    zcat ${extract_file} | head -$instances | perl -Ssw format_cyc_speech_part_features.perl -separate -type_file=unquoted-mass-count-$metric-isa.list -generalization_file=unquoted-mass-count-$metric-genls.list $mapping_options - | egrep "^(POS|MassNoun|SimpleNoun|CountNoun)" >| temp-mass-full-specific-inherited.table
fi

# Convert feature table into Weka's .arff format
if [ $rerun = 0 ]; then
    perl -Ssw feature2ml.perl -first -weka temp-mass-full-specific-inherited.table
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
result_base="unquoted-${map_prefix}$metric-mass-full-specific-inherited.$collocates.x$folds"
weka_options="-i -k -x $folds -t temp-mass-full-specific-inherited.arff"

# Run miscellaneous classifiers for comparison purposes: ID3 decision tree,
# as well as the simple and enhanced Naive Bayes classifiers.
if [ $all = 1 ]; then
    nice -19 java -mx1024m -oss1024m weka.classifiers.Id3  $weka_options >| ${result_base}.id3
    nice -19 java -mx1024m -oss1024m weka.classifiers.NaiveBayesSimple $weka_options >| ${result_base}.naive
    nice -19 java -mx1024m -oss1024m weka.classifiers.NaiveBayes $weka_options >| ${result_base}.naive-plus
fi

# Run the main classification using J48 decision tree classifier (C4.5 clone)
nice -19 java -mx1024m -oss1024m weka.classifiers.j48.J48 $weka_options >| ${result_base}.j48
