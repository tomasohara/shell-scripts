#! /bin/bash
#
# adhoc-rainbow-test.sh: Run rainbow classifier over data. The input data
# files must be contained in a directory structure with separate subdirectories
# for each category. The output includes the rainbow BLAH
# TODO: finish description
#
# By default, 10% of the data is set aside for testing. Rainbow will be cross-fold validation
# in the other 90%.
#
# Automates following steps:
#
# 1. Package input files into format required by rainbow
#
#    $ ./make-ai-categorizer-data.perl -d=4 -rainbow -target_file=common-geo_cn-reuters.list -overwrite -fixed_training=1 -min_test=0 -test_percent=10 -max_cat_files=10 -in_dir=geo_cn-testable-data -out_dir=reuters-geo_cn-testable-fixed-rainbow - > make-reuters-geo_cn-testable-fixed-rainbow.log 2>&1
#
# 2. Have rainbow preprocess the training data proper (i.e., omitting test data)
#
#    $ rainbow -b -d reuters-geo_cn-testable-fixed-rainbow --index reuters-geo_cn-testable-fixed-rainbow/training/* > index-reuters-geo_cn-testable-fixed-rainbow.log 2>&1
# 
# 3. Have rainbow test over the test partition of input data
#
#    $ rainbow -b -d reuters-geo_cn-testable-fixed-rainbow --test-files reuters-geo_cn-testable-fixed-rainbow/test > test-reuters-geo_cn-testable-fixed-rainbow.log 2>&1
#
# 4. Determine results over test data
#
# $ perl -S rainbow-stats -s < test-reuters-geo_cn-testable-fixed-rainbow.log
# 61.78 27.03
# 
# 5. Optionally have rainbow test over held-out data
#
# $ rainbow -b -d reuters-geo_cn-testable-fixed-rainbow --test-files 'C:\data\reuters-21578\geo_cn-test' > rainbow-common-reuters-21578-test-fixed.log 2> rainbow-common-reuters-21578-test-fixed.error
#
# 6. Evaluate the held-out data performance
#
# $ extract_matches.perl '([^\/\\]+)/[^\/\\]+.txt [^:]+ \1:' rainbow-common-reuters-21578-test-fixed.log | wc -l
# 11
#
#........................................................................
# TODO:
# - Output confusion matrix (e.g., rainbow_stats w/o -s option).
# - Show top-N accuracy (w/ epsilon option).
# - Have option to remove the rainbow working directory and miscellaneous
#   output files (e.g., make-adhoc-rainbow.log).
# - Format the results of the held-out as with test data results (e.g., accuracy and stdev).
# - Ensure all output files use common prefix to simplify access later.
#


# Uncomment following line(s) for tracing:
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#  
## set -o xtrace
## set -o verbose
## echo "$@"

# Show usage statement with example
#
if [ "$1" = "" ]; then
    echo ""
    echo "Usage: `basename $0` [options] data_dir"
    echo ""
    echo "main options: [--testing-data dir] [--make-options ops] [--training-options ops] [--testing-options ops] [--cats file] [--label text] [--trace] [--max-cat-files n] [--trace] [--cats file]"
    echo ""
    echo "other options: [--test-pct pct] [--heldout pct] [--subfiles] [--rainbow-test] [--skip-make] [--skip-index] [--skip-testing] [--index-dir dir]"
    echo ""
    echo "Example: "
    echo ""
    echo "`basename $0` --label pruned-reuters-geo_cn --data geo_cn-testable-data --cats test-geo_cn-reuters.list --testing-data 'C:\data\reuters-21578\geo_cn-test' --training-options '--method=tfidf'"
    ##
    ## TODO: show example using rainbow --test-set option
    echo ""
    echo "Notes:"
    echo ""
    echo "- Use --cats for specifying subset of categories from input directory to use."
    echo "- Use --max-cat-files to limit number of files per category in training data."
    echo "- Use --make-options to pass along options for make-categorizer-data.perl."
    echo "- Use --training-options (--testing-options) to pass along training (testing) options."
    echo "- The testing percentage defaults to 10%: use --test-pct to change."
    echo "- The test and helpdout directories must match the structure of the training directory: "
    echo "  for each category, there is a subdirecotory with the actual test files tagged as such."
    echo "- The --label option actually gives base, with rainbow and other components added as well."
    echo "- Use . for data directory when --skip-make specified."
    exit
fi

# Parse command-line options
#
## data_dir="geo_cn-testable-data"
## cat_file="common-geo_cn-reuters.list"
cat_file=""
node_file=""
parent_file=""
label="adhoc"
ext_test_dir=""
full_rainbow_test=0	# obsolete???
test_qualifier=""
training_options=""
testing_options=""
max_cat_files=""
misc_make_options=""
use_heldout=0
skip_make=0
skip_training=0
skip_testing=0
verbose=0
test_pct=10
index_dir=""
#
moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
while [ "$moreoptions" = "1" ]; do
    if [ "$1" = "--trace" ]; then
	set -o xtrace;
    elif [ "$1" = "--testing-data" ]; then
	ext_test_dir="$2"
	test_qualifier="external"
	shift 1;
    elif [ "$1" = "--rainbow-test" ]; then
	# NOTE: --rainbow-test assumed unless --skip-testing specified
	full_rainbow_test=1
	skip_testing=0
    elif [ "$1" = "--training-options" ]; then
	training_options="$training_options $2"
	shift 1;
    elif [ "$1" = "--testing-options" ]; then
	testing_options="$testing_options $2"
	shift 1;
    elif [ "$1" = "--cats" ]; then
	cat_file="$2"
	shift 1;
    elif [ "$1" = "--max-cat-files" ]; then
	max_cat_files="$2"
	shift 1;
    elif [ "$1" = "--label" ]; then
	label="$2"
	shift 1;
    elif [ "$1" = "--parents" ]; then
	parent_file="$2"
	shift 1;
    elif [ "$1" = "--nodes" ]; then
	node_file="$2"
	shift 1;
    elif [ "$1" = "--make-options" ]; then
	misc_make_options="$misc_make_options $2"
	shift 1;
    elif [ "$1" = "--skip-make" ]; then
	skip_make=1
    elif [ "$1" = "--skip-make" ]; then
	skip_make=1
    elif [ "$1" = "--skip-training" ]; then
	skip_training=1
    elif [ "$1" = "--skip-testing" ]; then
	skip_testing=1
    elif [ "$1" = "--heldout" ]; then
	misc_make_options="$misc_make_options -heldout_percent=$2"
	use_heldout=1
	skip_testing=0
	shift 1;
    elif [ "$1" = "--test-pct" ]; then
	test_pct="$2"
	shift 1;
    elif [ "$1" = "--query-dir" ]; then
	query_file="/tmp/_query_file.$$"
	echo "" > $query_file
	# Concatenate files with <CR><NL>.<CR><NL> (i.e., period with DOS-style end-of-line sequences)
	for f in $2/*; do cat $f >> $query_file; perl -e 'print "\n.\n;";' >> $query_file; done
	shift 1;
    elif [ "$1" = "--query-file" ]; then
	## query_file="$2"
	query_file="/tmp/_query_file.$$"
	cat "$2" > $query_file;  perl -e 'print "\n.\n;";' >> $query_file
	shift 1;
    elif [ "$1" = "--index-dir" ]; then
	index_dir="$2"
	shift 1;
    elif [ "$1" = "--subfiles" ]; then
	misc_make_options="$misc_make_options -subfiles"
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
data_dir="$1"
if [ "$index_dir" = "" ]; then
    index_dir="$label-rainbow"
fi
test_dir=$index_dir/test
if [ "$use_heldout" = "1" ]; then 
    ext_test_dir=$index_dir/heldout; 
    test_qualifier="heldout";
elif [ "$ext_test_dir" = "" ]; then
    ext_test_dir=$test_dir; 
    test_qualifier="internal";
fi

# So sanity check on options
if [ ! -e "$data_dir" ]; then
    echo "ERROR: data directory '$data_dir' not found";
    exit;
fi


# Package files into format required by rainbow
# NOTE: 90% of data is used for training and 10% for testing.
#
if [ $skip_make = 0 ]; then
    if [ "$max_cat_files" != "" ]; then misc_make_options="$misc_make_options -max_cat_files=$max_cat_files"; fi
    if [ "$cat_file" != "" ]; then misc_make_options="$misc_make_options -target_file=$cat_file"; fi
    perl -Ssw make-categorizer-data.perl -d=4 -rainbow -overwrite -fixed_training=1 -min_test=0 -test_percent=$test_pct -in_dir=$data_dir -out_dir=$index_dir $misc_make_options - > make-$label-rainbow.log 2>&1
    # TODO: check-errors make-$label-rainbow.log
fi

# Preprocess the training data
# NOTE: -b option used to disable backspacing in rainbow logs.
#
if [ "$skip_training" = "0" ]; then 
    rainbow -b -d $index_dir $training_options --index $index_dir/training/* > index-$label-rainbow.log 2>&1

    # Test over test partition of input data
    #
    if [ "$test_pct" != "0" ]; then
	rainbow -b -d $index_dir $testing_options --test-files $test_dir > int-test-$label-rainbow.log 2> int-test-$label-rainbow.error
        #
	echo "Results over test paritition (avg-accuracy and stdev)"
	perl -S rainbow-stats < int-test-$label-rainbow.log > int-test-$label-rainbow.matrix
	perl -S rainbow-stats -s < int-test-$label-rainbow.log > int-test-$label-rainbow.eval
	cat int-test-$label-rainbow.eval
    fi
fi

# Test over separate test directory
#
test_base="-"
if [ "$skip_testing" = "0" ]; then
    test_base=reg-test-$label-rainbow
    if [ "$ext_test_dir" != "$test_dir" ]; then 
	test_base=ext-test-$label-rainbow
    fi
    rainbow -b -d $index_dir $testing_options --test-files "$ext_test_dir" > $test_base.log 2> $test_base.error
    echo "Results over $test_qualifier test data (# correct)"
    ## OLD: perl -sw ./extract_matches.perl '([^\/\\]+)/[^\/\\]+.txt [^:]+ \1:' $test_base.log | wc -l

    # Evaluate recall & precision
    # ex: node_file=geo_cn-terms.data; parent_file=geo_cn-parents.data
    perl -Ssw eval-wiki-categorization.perl -rainbow -prune_scores -min_score=0.01 -cat_subdirs -node_file="$node_file" -parent_file="$parent_file" $test_base.log >| $test_base.eval 2>&1
    # TODO: make top-N display optional
    match=exact
    if [ "$verbose" = "1" ]; then match="(exact|top-n)"; fi
    perl -Ssw perlgrep.perl -para "$match evaluation" $test_base.eval
fi

# Optionally test over separate data file (see --query-dir option handling above packing individual files into one)
if [ "$query_file" != "" ]; then
    echo "Results over untagged query data"
    query_base=query-$label-rainbow
    # Start rainbow (socket) server as background job and get pid
    rainbow -b -d $index_dir --query-server 9999 > $query_base.server.log 2>&1 &
    server_pid=$!
    # Send text file via telnet (socket) client
    sleep 15
    ## OLD: telnet localhost 9999 < "$query_file" > $query_base.log 2> $query_base.error
    new-telnet.perl -server=localhost -port=9999 - < "$query_file" > $query_base.log 2> $query_base.error
    # Stop the socket server
    ps | grep $server_pid
    kill $server_pid
    # Prettyprint the results
    perl -e 'require "common.perl";' -ne 'if (/^(\S+) (\d\.?\d+)\s*$/) { print "$1: ", &round($2), "\n"; } ' $query_base.log
fi

# Show support files
if [ "$verbose" == "1" ]; then
    ls -l make-$label-rainbow.log index-$label-rainbow.log  int-test-$label-rainbow.* 2>&1 | grep -v "No such file"
    if [ "$test_dir" != "" ]; then ls -l ext-test-$label-rainbow.* $test_base.* 2>&1 | grep -v "No such file"; fi
fi
