# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#!/usr/local/Gnu/bin/perl -sw
#!/usr/bin/perl -sw
#------------------------------------------------------------------------------
# File: choose_best_forms.prl
#
# Selects the best case from each fold by finding the model with the
# highest accuracy. This figure along with the corresponding precision 
# and recall is then averaged over all folds.
#
# Input: SAMPLEALL.fold0, SAMPLEALL.fold1, ...
# 9 May 97
#
# Example input:
#    Edges Model                        Accuracy Precision Recall Form
#    10    ABC ABF ACE AD AG AH AB      0.7553   0.7594    0.9947  
#    11    ABC ABF ACD ACE AG AH AB     0.7606   0.7647    0.9947  
#    12    ABC ABF ABG ACD ACE AH AB    0.7553   0.7594    0.9947  
#
#
# NOTE:
# An alternative average is derived that treats each metric separately.
# That is, the maximal precision in each fold might not be for the same
# model as that for the maximal accuracy.
#------------------------------------------------------------------------------


sub usage {
    select(STDERR);
    print <<USAGE_END;
Usage: $0 fold0 fold1 ...

USAGE_END

    exit 1;
}

require 'new_common.perl';		# in /home/graphling/UTILITIES

# If command line arguments are missing, give a usage message.
# $#ARGV = (# of arguments) - 1
($#ARGV >= 0) || &usage;

$use_alt = (defined($alt) ? $alt : $_FALSE);
debug_out(7, "TRUE=$_TRUE FALSE=$_FALSE\n");

$num_folds = 0;
$total_accuracy = 0.0;
$total_precision = 0.0;
$total_recall = 0.0;

printf "%5s %5s %-28s %10s %10s %10s\n",
       "Fold", "Edges", "Model", "Accuracy", "Precision", "Recall";

# Process each fold-results file separately
#
while ($#ARGV >= 0) {
    $num_folds++;
    $FoldResults = shift @ARGV;
    open(FOLD, "<$FoldResults");

    debug_out(4, "$FoldResults:\n");
    $line = 0;
    $best_edges = 0;
    $best_models = "";
    $best_accuracy = 0.0;
    $best_precision = 0.0;
    $best_recall = 0.0;
    $best_precision_alt = 0.0;
    $best_recall_alt = 0.0;

    while (<FOLD>) {
	chop;
	debug_out(5, "L%d: $_\n", $line++);
	if (/^Edges/) {
	    next;
	}

	# Change spaces before & after numbers to tabs
	# TODO: use tabs in fold file?
	s/([0-9])  */$1\t/g;
	s/  *([0-9])/\t$1/g;

	# Separate the fields
	($edges, $models, $accuracy, $precision, $recall) = split(/\t/, $_);
	debug_out(4, "e:$edges m:$models a:$accuracy p:$precision r:$recall\n");
	# See if this case is the new best one
	# All metrics are considered together, keyed off of accuracy
	if ($accuracy > $best_accuracy) {
	    $best_edges = $edges;
	    $best_models = $models;
	    $best_accuracy = $accuracy;
	    $best_precision = $precision;
	    $best_recall = $recall;
	}

	# Tabulate alternative cases of treating each metric separately
	if ($precision > $best_precision_alt) {
	    $best_precision_alt = $precision;
	}
	if ($recall > $best_recall_alt) {
	    $best_recall_alt = $recall;
	}
    }
    close(FOLD);

    # Use the alternative metrics, if desired
    if ($use_alt) {
	$best_precision = $best_precision_alt;
	$best_recall = $best_recall_alt;
    }

    # Display the results for this fold
    printf "%5d %5d %-28s %10.4f %10.4f %10.4f   \n", 
           $num_folds, $best_edges, $best_models, 
           $best_accuracy, $best_precision, $best_recall;

    # Tally the values into the overall sums
    $total_accuracy += $best_accuracy;
    $total_precision += $best_precision;
    $total_recall += $best_recall;
}

# Print totals
#
if ($num_folds > 0) {
    $total_accuracy /= $num_folds;
    $total_precision /= $num_folds;
    $total_recall /= $num_folds;
}
printf "\n";
printf "%5s %5s %-28s %10.4f %10.4f %10.4f\n", 
       "total", "", "", $total_accuracy, $total_precision, $total_recall;
printf "\n";
