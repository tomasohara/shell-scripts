# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#! /usr/local/bin/perl -sw
#
# script to read word list and move associated file to appropriate
# directorory (TEST or TRAINING)
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

if ($#ARGV < 0) {
    print STDERR <<USAGE_END;

usage: ${script_name} [options] POS pos_list.text

options: [-disable_commands=0|1]  [-max_size_training=max_line_count]

example: ${script_name} n nlist.txt

USAGE_END

    exit;
}


$POS = shift @ARGV;
$POS =~ tr/NV/nv/;

$seed = time unless(defined($seed));
srand($seed);

open(TRAIN_LIST, "> ${POS}_training.list");
open(TEST_LIST, "> ${POS}_testing.list");

# Read the words all at once
@words = ();
$/ = 0777;			# lets I/O slurp a file in one gulp
$text = <>;
@words = split(/[ \t\n]+/, $text);
&assert('$#words > 0');

# Split into training and test sets
#
# NOTE: This splits both the number of distinct words annotated
#       and the total number of annotations by a 90/10 split, with a
#       bias towards making the test set larger.

$max = sprintf "%.0f", (0.90 * (1 + $#words));
$max_training = $max + 0;
$num_training = 0;
$size_training = 0;
$max_size_training = 347173	# derived via cat *.[nv] | wc
    unless defined(max_size_training);
$max_testing = (1 + $#words) - $max_training;
$num_testing = 0;
&debug_out(4, "max_training=$max_training max_testing=$max_testing\n");

foreach $word (@words) {
    # Determine the current file's size
    $file = "${word}.$POS";
    $file_size = &run_command("cat $file | wc -l");

    # put 90% of the words in the TRAINING set
    $for_training = (((rand() > 0.10) 
		      && ($num_training < $max_training)
		      && (($size_training + $file_size) < $max_size_training))
                    || ($num_testing > $max_testing));
    if ($for_training) {
        print TRAIN_LIST "$word\t$file_size\n";
	&issue_command("mv $file TRAINING");
        $num_training++;
        $size_training += $file_size;
    }
    else {
        print TEST_LIST "$word\t$file_size\n";
              	&issue_command("mv $file TESTING");
        $num_testing++;
        $size_testing += $file_size;
    }
}

close(TRAIN_LIST);
close(TEST_LIST);
