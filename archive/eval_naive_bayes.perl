# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# eval_naive_bayes.perl: Analyze the results of the classification experiments
# to see how Naive Bayes fared compared to the models that were selected, which
# could include Naive Bayes.
#
# NOTE: This relies upon assumptions concerning how the Naive Bayes model
# occurs in the list of models searched, based on how the WSD experiments are
# set up.
#
# TODO: Rework report.prl to simplify some of the extractions required below.
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';
require 'extra.perl';

&init_var(*NUM_FOLDS, 10);
&init_var(*NAIVE_BAYES_POS, 0);

if ((defined($ARGV[0]) && ($ARGV[0] eq "help"))
    || (!defined($ARGV[0]) && &blocking_stdin())) {
    $options = "options = n/a";
    $example = "examples:\n\n$script_name BOOK DOOR LAW PLACE STATE WORLD\n\n";
    $example .= "$script_name `cat words.list` >&! eval_naive_bayes.log\n";
    $example .= "$script_name `cat sample_words.list` >&! eval_naive_bayes_sample.log\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
}

# Initialize tabulations
local($total_selected) = 0;
local($total_nb_best) = 0;
local($total_sel_best) = 0;
local($total_folds) = 0;
local($total_nb_accuracy) = 0;
local($total_sel_accuracy) = 0;
local($total_sel_improvement) = 0;
local($total_best_accuracy) = 0;
local($total_exps) = 0;

# Initialize
&init_topN();

# Print header
printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
	"Exp", "Select", "NB Best", "SelBest", 
        "NB Acc", "SelAcc", "Improve", "BestAcc";

# Process each of the experiments
foreach $dir (@ARGV) {
    &analyze_naive_bayes($dir);
}

# Display overall results
if ($total_exps > 0) {
    $total_nb_accuracy /= $total_exps;
    $total_sel_accuracy /= $total_exps;
    $total_sel_improvement /= $total_exps;
    $total_best_accuracy /= $total_exps;
}
&debug_out(4, "totals: #sel: %d; #best: %d; #sel best: %d; #folds: %d; ",
	   $total_selected, $total_nb_best, $total_sel_best, $total_folds);
&debug_out(4, "NB acc: %.3f; sel acc: %.3f; sel impr: %.3f; best acc: %.3f\n", 
	   $total_nb_accuracy, $total_sel_accuracy, $total_sel_improvement, 
	   $total_best_accuracy);

printf "%s\t%d\t%d\t%d\t%.3f\t%.3f\t%.3f\t%.3f\n", 
    "total", $total_selected, $total_nb_best, $total_sel_best, 
    $total_nb_accuracy, $total_sel_accuracy, 
    $total_sel_improvement, $total_best_accuracy;


#------------------------------------------------------------------------------

# analyze_naive_bayes(expirement_directory)
#
# Analyze the reports in the experiment directory to see how Naive Bayes
# performed compared to the selected model. This requires the report format
# used in the new psuedo-test evaluation method (developed by Ken).
#
# TODO: Revise report.prl to make some of the following code more 
#       straightforward.
#
sub analyze_naive_bayes {
    local ($dir) = @_;
    &debug_out(4, "analyze_naive_bayes(@_)\n");

    # Make sure the reports exist
    if (! (-e "$dir/table0.report")) {
	&error_out("Missing report files in $dir\n");
	return;
    }

    # Initialize tabulations
    local($num_selected) = 0;
    local($num_nb_best) = 0;
    local($num_sel_best) = 0;
    local($num_folds) = 0;
    local($sum_sel_accuracy) = 0;
    local($sum_sel_improvement) = 0;
    local($sum_nb_accuracy) = 0;
    local($sum_best_accuracy) = 0;

    # Analyze the results of each fold
    &debug_out(4, "%s\n", $dir);
    local($fold);
    for ($fold = 0; $fold < $NUM_FOLDS; $fold++) {
	local($report) = "$dir/table${fold}.report";
	if (!open(FOLD_REPORT, "<$report")) {
	    &debug_out(3, "WARNING: Unable to open fold report of %s (%s)\n",
		       $dir, $report);
	    next;
	}
	local($nb_accuracy) = 0.0;
	local($nb_model) = "";
	local($in_scores) = &TRUE;
	## local($sel_model_pos) = -1;
	local($sel_model) = "";
	local($sel_accuracy) = 0.0;
	local(@accuracy);
	local(%accuracy);

	$num_folds++;
	&clear_topN(*max_model_pos, *max_accuracy);
	while (<FOLD_REPORT>) {
	    &dump_line();
	    next if (/^\s*\#/);		# ignore comments
	    chop;

	    local($model_pos, $accuracy, $complexity, $model);
	    if ($in_scores) {
		if (/^\s+(\d+)\s+.*tst\s+(\S+)/i) {
		    $model_pos = $1;  $accuracy = $2;
		    &debug_out(5, "pos=${model_pos} a=$accuracy\n");
		    
		    if ($model_pos == $NAIVE_BAYES_POS) {
			$nb_accuracy = $accuracy;
		    }
		    if ($accuracy != -1) {
			## &revise_topN(*max_model_pos, *max_accuracy, 
			##	        $model_pos, $accuracy);
			
			$accuracy[$model_pos] = $accuracy;
		    }
		}
		elsif (/BEST MODEL/i) {
		    $in_scores = &FALSE;
		}
	    }
	    elsif (($sel_model eq "")
		   && /^\s*(\d+)\s+(.*)/) {
		## $sel_complexity = $1;  
		$sel_model = $2;
		&debug_out(5, "sel_model='%s'\n", $sel_model);
	    }
	    elsif (/testing:\s+(\S+)/) {
		$sel_accuracy = $1;
	    }
	    elsif (/^\s*(\d+)\s+(\d+)\s+model\s+(.*)/i) {
		$model_pos = $1;  $complexity = $2;  $model = $3;
		&debug_out(5, "pos=${model_pos} c=$complexity m='$model'\n");

		if ($model_pos == $NAIVE_BAYES_POS) {
		    $nb_model = $model;
		}
		&revise_topN(*max_model_pos, *max_accuracy, 
			     "$model_pos: $model", 
			     $accuracy[$model_pos]);
	    }
	}
	close(FOLD_REPORT);
	&debug_out(4, "fold $fold:\n");
	&debug_out(4, "selected = %s (%.3f)\n", $sel_model, $sel_accuracy);

	## &show_topN(*max_model_pos, *max_accuracy);
	&debug_out(4, "top %d models by accuracy:\n", $TOPN);
	&reference_vars($TOPN);
	&show_topN(*max_accuracy, *max_model_pos, STDERR, "%.3f\t%s\n")
		   unless (&DEBUG_LEVEL < 4);
	&debug_out(4, "\n");
	if (!defined($max_accuracy[0])) {
	    &debug_out(3, "WARNING: incomplete report file data\n");
	    next;
	}

	# Tabulate the number of times Naive Bayes was selected, etc.
	&debug_out(5, "nb_vs_sel: %.3f\t%.3f\n", 
		       $accuracy[$NAIVE_BAYES_POS], $sel_accuracy);
	if ($sel_model eq $nb_model) {
	    $num_selected++;
	}
	else {
	    &debug_out(4, "not_same: %.3f\t%.3f\n", 
		       $accuracy[$NAIVE_BAYES_POS], $sel_accuracy);	    
	}
	if ($nb_accuracy == $max_accuracy[0]) {
	    $num_nb_best++;
	}
	if ($sel_accuracy == $max_accuracy[0]) {
	    $num_sel_best++;
	}

	if ($accuracy[$NAIVE_BAYES_POS] != $sel_accuracy) {
	    &debug_out(4, "not_eq:\t%.3f\t%.3f\n", 
		       $accuracy[$NAIVE_BAYES_POS], $sel_accuracy);
	}
	$sum_nb_accuracy += $accuracy[$NAIVE_BAYES_POS];
	$sum_sel_accuracy += $sel_accuracy;
	$sum_best_accuracy += $max_accuracy[0];
	$sum_sel_improvement += ($sel_accuracy - $accuracy[$NAIVE_BAYES_POS]);
    }

    # Display current results (with respect to Naive Bayes model)
    $sum_nb_accuracy /= $num_folds;
    $sum_sel_accuracy /= $num_folds;
    $sum_sel_improvement /= $num_folds;
    $sum_best_accuracy /= $num_folds;
    &debug_out(4, "#selected=%d; #best=%d; #folds=%d; NB accuracy=%.3f sel_acc=%.3f sel_improve=%.3f best_acc=%.3f\n", 
	       $num_selected, $num_nb_best, $num_folds, $sum_nb_accuracy, 
	       $sum_sel_accuracy, $sum_sel_improvement, $sum_best_accuracy);
    printf "%s\t%d\t%d\t%d\t%.3f\t%.3f\t%.3f\t%.3f\n", 
	    $dir, $num_selected, $num_nb_best, $num_sel_best, 
            $sum_nb_accuracy, $sum_sel_accuracy, $sum_sel_improvement, 
            $sum_best_accuracy;
    &debug_out(4, "\n\n");

    # Update the overall totals
    # TODO: define parameters for these
    $total_selected += $num_selected;
    $total_nb_best += $num_nb_best;
    $total_sel_best += $num_sel_best;
    $total_folds += $num_folds;
    $total_nb_accuracy += $sum_nb_accuracy;
    $total_sel_accuracy += $sum_sel_accuracy;
    $total_sel_improvement += $sum_sel_improvement;
    $total_best_accuracy += $sum_best_accuracy;
    $total_exps++;

    return;
}
