# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# eval_misc.perl: Evaluate the results of the mixture or Ken's new 
# evaluation method, producing output similar to choose_best_forms.prl. 
#
# NOTES:
# 
# The results are input into eval_wsd_exps.sh, so make sure changes to
# the output format are accounted for there.
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

&init_var(*new_eval, &FALSE);

if ((defined($ARGV[0]) && ($ARGV[0] eq "help"))
    || (!defined($ARGV[0]) && &blocking_stdin())) {
    $options = "options = n/a";
    $example = "ex: $script_name whatever\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
}

$total_accuracy = 0;
$total_precision = 0;
$total_recall = 0;
$num = 0;


printf "%s\t%s\t%s\t%s\t%s\n",
       "Fold", "Accur.", "Prec.", "Recall", "Model";

undef($/);			# set entire-file input mode

while (<>) {
    &dump_line();
    chop;
    next if (/^\s*$/);

    $accuracy = 0;
    $precision = 0;
    $recall = 0;
    $model = "n/a";

    # Extract the accuracy, recall, and precision figures
    if ($new_eval) {
	# Check for best model section and extract results for test data
	# example:
	# 	*** BEST MODEL ***
	# 	  3 AD AG AK
	# 	 Source   Acc    Prec   Rec
	# 	training: 0.7755 0.7755 1.0000
	# 	testing:  0.7321 0.7321 1.0000
	#
	if (/testing:\s*(\S+)\s*(\S+)\s*(\S+)/) {
	    $accuracy = $1;
	    $precision = $2;
	    $recall = $3;
	}
	if (/BEST MODEL.*\n\s*\S+\s+(.*)/) {
	    $model = $1;
	}
    }
    else {
	if (/accuracy\s*=\s*(\S+)/) {
	    $accuracy = $1;
	}
	if (/recall\s*=\s*(\S+)/) {
	    $recall = $1;
	}
	if (/precision\s*=\s*(\S+)/) {
	    $precision = $1;
	}
    }

    # Accumulate the totals
    $total_accuracy += $accuracy;
    $total_recall += $recall;
    $total_precision += $precision;

    # Print the current results
    printf "%d\t%5.3f\t%5.3f\t%5.3f\t%s\n", 
       $num, $accuracy, $precision, $recall, $model;
    $num++;
}

# Determine the overall results and print the totals line
if ($num > 0) {
    $total_accuracy /= $num;
    $total_recall /= $num;
    $total_precision /= $num;
}
printf "%-s\t%5.3f\t%5.3f\t%5.3f\n", 
       "total", $total_accuracy, $total_precision, $total_recall;
