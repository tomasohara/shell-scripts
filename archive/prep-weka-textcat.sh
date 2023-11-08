#! /bin/bash
#
# TODO: prep-weka-textcat.sh: prepare a Weka ARFF file for text categorization
# experiments, using the contents of a given directory with category specific
# subdirectories for the training data.
#
# Notes: automates the following process:
#
# 1. Convert directory structure into ARFF file
#
#    java -Xmx1024m -cp weka.jar weka.core.converters.TextDirectoryLoader -dir 'c:\data\bow-over-lyrics\cal500-lyrics-hypernym-classifier' >| _1_cal500-lyrics-hypernym-classifier.arff
#
# 2. Convert string attributes into word token attributed
#
#    java -cp weka.jar weka.filters.unsupervised.attribute.StringToWordVector < _1_cal500-lyrics-hypernym-classifier.arff >| _2_cal500-lyrics-hypernym-classifier.arff
#
# 3. Re-order so that the classification variable comes last (needed for libSVM)
#
#    java -cp weka.jar weka.filters.unsupervised.attribute.Reorder -R 2-last,first < _2_cal500-lyrics-hypernym-classifier.arff >| _3_cal500-lyrics-hypernym-classifier.arff
#
#

# Uncomment following line(s) for tracing:
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#  
## echo "$@"
## set -o xtrace
## set -o verbose

# Parse command-line options
#
weka_jar="c:/Program-Misc/Weka-3-7/weka.jar"
#
moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
while [ "$moreoptions" = "1" ]; do
    if [ "$1" = "--trace" ]; then
	set -o xtrace
    elif [ "$1" = "--weka-jar" ]; then
	weka_jar="$2"
	shift
    elif [ "$1" = "--" ]; then
	break
    else
	echo "ERROR: Unknown option: $1"
	exit
    fi
    shift 1
    moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
done
text_dir="$1"
temp_base="/tmp/prep-weke-textcat-$$"
classpath="$weka_jar"


# TODO: Show usage statement
#
if [ "$text_dir" = "" ]; then
    echo ""
    echo "usage: `basename $0` [--weka-jar file] text-dir"
    echo ""
    echo "example:"
    echo "`basename $0` --weka-jar c:/Program-Misc/Weka-3-7/weka.jar c:/data/rainbow/20_newsgroups >| 20_newsgroups.arff"
    echo ""
    echo "Note: use Java-style paths even if under Cygwin (as in example above)."
    echo ""
    exit
fi


# Convert directory structure into ARFF file
#
java -Xmx1024m -cp "$classpath" weka.core.converters.TextDirectoryLoader -dir "$text_dir" > "$temp_base.string.arff"

# Convert string attributes into word token attributed
#
java -cp "$classpath" weka.filters.unsupervised.attribute.StringToWordVector < "$temp_base.string.arff" > "$temp_base.word.arff"

# Re-order so that the classification variable comes last (needed for libSVM)
#
java -cp "$classpath" weka.filters.unsupervised.attribute.Reorder -R 2-last,first < "$temp_base.word.arff" > "$temp_base.reorder.arff"

# Output the file version
cat "$temp_base.reorder.arff"
