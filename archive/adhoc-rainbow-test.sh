#! /bin/bash
#
# adhoc-rainbow-test.sh: run rainbow classifier over data
#
# Automates following steps:
#
# $ ./make-ai-categorizer-data.perl -d=4 -rainbow -target_file=common-geo_cn-reuters.list -overwrite -fixed_training=1 -min_test=0 -test_percent=10 -max_cat_files=10 -in_dir=geo_cn-testable-data -out_dir=reuters-geo_cn-testable-fixed-rainbow - >| make-reuters-geo_cn-testable-fixed-rainbow.log 2>&1
# 
# $ rainbow -b -d reuters-geo_cn-testable-fixed-rainbow --index reuters-geo_cn-testable-fixed-rainbow/training/* >| index-reuters-geo_cn-testable-fixed-rainbow.log 2>&1
# 
# $ rainbow -b -d reuters-geo_cn-testable-fixed-rainbow --test-files reuters-geo_cn-testable-fixed-rainbow/test >| test-reuters-geo_cn-testable-fixed-rainbow.log 2>&1
# 
# $ perl -S rainbow-stats -s < test-reuters-geo_cn-testable-fixed-rainbow.log
# 61.78 27.03
# 
# $ rainbow -b -d reuters-geo_cn-testable-fixed-rainbow --test-files 'C:\data\reuters-21578\geo_cn-test' >| rainbow-common-reuters-21578-test-fixed.log 2>| rainbow-common-reuters-21578-test-fixed.error
# 
# $ extract_matches.perl '([^\/\\]+)/[^\/\\]+.txt [^:]+ \1:' rainbow-common-reuters-21578-test-fixed.log | wc -l
# 11
#
#........................................................................
# Sample output:
#
# $ ./adhoc-rainbow-test.sh --label pruned-reuters-geo_cn --data geo_cn-testable-data --cats test-geo_cn-reuters.list --testing-data 'C:\data\reuters-21578\geo_cn-test' --training-options '--method=tfidf'
# Results over test partition (avg-accuracy and stdev)
# 38.67 3.77
# Results over separate test data (# correct)
# 58
#
#........................................................................
# TODO:
# - Output confusion matrix (e.g., rainbow_stats w/o -s option).
# - Show top-N accuracy (w/ epsilon option).
#



# Uncomment following line(s) for tracing:
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#  
## set -o xtrace
## set -o verbose

# Parse command-line options
#
data_dir=""
cat_file=""
label="adhoc"
test_dir=""
training_options=""
testing_options=""
verbose=0
#
moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
while [ "$moreoptions" = "1" ]; do
    if [ "$1" = "--trace" ]; then
	set -o xtrace;
    elif [ "$1" = "--data" ]; then
	data_dir="$2"
	shift 1;
    elif [ "$1" = "--testing-data" ]; then
	test_dir="$2"
	shift 1;
    elif [ "$1" = "--training-options" ]; then
	training_options="$training_options $2"
	shift 1;
    elif [ "$1" = "--testing-options" ]; then
	testing_options="$testing_options $2"
	shift 1;
    elif [ "$1" = "--cats" ]; then
	cat_file="$2"
	shift 1;
    elif [ "$1" = "--label" ]; then
	label="$2"
	shift 1;
    elif [ "$1" = "--verbose" ]; then
	verbose=1;
    else
	echo "ERROR Unknown option '$1'";
	exit
    fi
    shift 1;
    moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
done
#
out_dir="$label-rainbow"

# Show usage statement
#
if [[ "$data_dir" = "" || "$cat_file" = "" ]]; then
    echo ""
    echo "usage: `basename $0` [options]"
    echo ""
    echo "options: [--data dir] [--testing-data dir] [--training-options ops] [--testing-options ops] [--cats file] [--label text] [--trace] [--verbose]"
    echo ""
    echo "examples:"
    echo ""
    echo "adhoc-rainbow-test.sh --label pruned-reuters-geo_cn --data geo_cn-testable-data --cats test-geo_cn-reuters.list"
    echo ""
    echo "adhoc-rainbow-test.sh --label pruned-reuters-geo_cn --data geo_cn-testable-data --cats test-geo_cn-reuters.list --testing-data 'C:\data\reuters-21578\geo_cn-test' --training-options '--method=tfidf'"
    echo ""
    echo "notes:"
    echo ""
    echo "The --data and --cats options are required."
    exit
fi

# Package files into format required by rainbow
#
# TODO: replace obsolete args: -fixed_training, target_file, rainbow, max_cat_files
perl -Ssw make-ai-categorizer-data.perl -d=4 -rainbow -target_file=$cat_file -overwrite -fixed_training=1 -min_test=0 -test_percent=10 -max_cat_files=10 -in_dir=$data_dir -out_dir=$out_dir - >| make-$label-rainbow.log 2>&1

# Prepreocess the data
#
rainbow -b -d $out_dir $training_options --index $out_dir/training/* >| index-$label-rainbow.log 2>&1

# Test over test partition of input data
#
rainbow -b -d $out_dir $testing_options --test-files $out_dir/test >| int-test-$label-rainbow.log 2>&1
#
echo "Results over test partition (avg-accuracy and stdev)"
perl -S rainbow-stats -s < int-test-$label-rainbow.log

# Test over separate test directory
#
if [ "$test_dir" != "" ]; then
    rainbow -b -d $out_dir $testing_options --test-files "$test_dir" >| ext-test-$label-rainbow.log 2>| ext-test-$label-rainbow.error
    echo "Results over separate test data (# correct)"
    perl -Ssw extract_matches.perl '([^\/\\]+)/[^\/\\]+.txt [^:]+ \1:' ext-test-$label-rainbow.log | wc -l
fi

# Show support files
if [ $verbose ]; then
    ls -l make-$label-rainbow.log index-$label-rainbow.log  int-test-$label-rainbow.log 
    if [ "$test_dir" != "" ]; then ls -l ext-test-$label-rainbow.log; fi
fi

