# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# calculate_weights.perl: Calculate the weights for the salient words
# in the context of a Roget's category.
#
# from [Yarowsky 92]:
#
# Step 2: Indentify salient words in the collective context, and
# weight appropriately
#
# Intuitively, a salient word [inflectional distinctions ignored] is one 
# which appears significantly more often in the context of a category
# than at other points in the corpus, and hence is a better than average 
# indicator for the category. We formsalize this with a mutual-
# information-like estimate: $Pr(w|RCat) / Pr(w)$, the probability of
# a word (w) appreaing in the context of a Roget category divided by
# its overall probability in the corpus.
# ...
# We have smoothed the local estimates of $Pr(w|RCat)$ with global
# estimates of $Pr(w)$ to obtain a more reliable estimate.
# ...
# The numbers in parenthesis are the log of the salience
# ($log Pr(w|RCat) / Pr(w)$) which we will henceforth refer to as the
# word's {\em weight} in the statistical model of the category.
#
# REFS:
#
# Yarowsky, David, "Word-Sense Disambiguation Using Statistical Models
# of Roget's Categories Trained on Large Corpora", in Proc. COLING-92.
#
# Gale, William, Kenneth Church, and David Yarowsky (1992), "Discrimination
# Decisions for 100,000-Dimensional Spaces", AT\&T Statistical Research
# Report No. 103.
#
# Gale, William, Kenneth Church, and David Yarowsky (1992), "A Method
# for Disambigutating Word Senses in a Large Corpus", to appear in
# {\em Computers and Humanities}.
# 


# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

if ((defined($ARGV[0]) && ($ARGV[0] eq "help"))
    || (!defined($ARGV[0]) && &blocking_stdin())) {
    $options = "options = [-word_count_file=file] [-apply_frequency_scaling=0|1]";
    $example = "ex: nice +19 $script_name *.context >&! calculate.log\n";
    $example .= "ex: $script_name -word_count_file=wsj.freq *.context\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
}


&init_var(*word_count_file, "w9_1.freq");
&init_var(*apply_frequency_scaling, &FALSE);

$log2 = log(2);

# Read in the global frequencies
#
$total_global_frequency = &read_frequencies(*global_frequency, $word_count_file);
&assert('$total_global_frequency > 0');


# Process each context file specified on the command line
#
foreach $context_file (@ARGV) {
    $base = &basename($context_file, ".context");
    ## $context = &read_file($context_file);
    $temp_weight_file = "${base}.temp_weights";

    # Initialize the associative arrays for word-specific tallies & indicators
    %frequency = ();
    %processed = ();
    $total = 0;

    # Open the context file and complain if not found.
    # Likewise try to create the output weight file.
    $last_word = "";
    if (!open(CONTEXT, "< $context_file")) {
	&debug_out(2, "*** unable to open context file $context_file ($!)\n");
	next;
    }
    if (!open(WEIGHTS, "> $temp_weight_file")) {
	&debug_out(2, "*** unable to create category weight file $temp_weight_file ($!)\n");
	next;
    }

    # Read each context window for the category and tabulate the word 
    # occurrences
    while (<CONTEXT>) {
	# tabulate word counts
	if (/\*\*\* ([^*]+) \*\*\*/) {
	    $pre_context = $`;
	    $category_word = $1;
	    $post_context = $';

	    # Skip words already processed
	    if ($last_word ne $category_word) {
		if (defined($processed{$category_word})) {
		    # already seen this context
		    next;
		}
	    }
	    
	    # Analyze the context
	    # TODO: handle non-words at window boundary
	    local ($target_frequency) = $global_frequency{$category_word} || 1;
	    $incr = &tally_words_in_context($pre_context, *frequency);
	    $incr += &tally_words_in_context($post_context, *frequency);
	    $incr /= $target_frequency if ($apply_frequency_scaling);
	    $total += $incr;

	    # If there has been a category word change, mark previous one
	    # as already processed. This is done at the end of its batch
	    # so that batches don't need to be stored.
	    if ($last_word ne $category_word) {
		$processed{$last_word} = &TRUE;
		$last_word = $category_word;
	    }
	}
    }
    $total_frequency = $total;
    close(CONTEXT);

    # Now determine the weights based on the ratio of the local to global
    # frequencies (log (Pr(w|RCat) / Pr(w)))
    # TODO: do some sort of smoothing (see [Gale, Church and Yarowski 92])
    &debug_out(4, "# %s\t%s\t%s\t%s\t%s\t%s\t%s\n",
	       "word", "local", "global", "P(W)", "P(W|RCat)", 
	       "weight", "importance\n");
    printf WEIGHTS "# %s\t%s\t%s\n", "word", "weight", "importance\n";
    foreach $word (sort(keys(%frequency))) {
	## &assert('$global_frequency{$word}');
	if (!defined($global_frequency{$word})) {
	    $global_frequency{$word} = $frequency{$word};
	}
	$Pr_W = $global_frequency{$word} / $total_global_frequency;
	$Pr_W_given_RCat = $frequency{$word} / $total_frequency;
	$weight = log($Pr_W_given_RCat / $Pr_W) / $log2;
	$importance = ($frequency{$word} * $weight);
	&debug_out(4, "%s\t%d\t%d\t%.5f\t%.5f\t%.5f\t%.5f\n",
	 	   $word, $frequency{$word}, $global_frequency{$word},
	 	   $Pr_W, $Pr_W_given_RCat, $weight, $importance);
	printf WEIGHTS "%s\t%.3f\t%.3f\n", $word, $weight, $importance;
    }
    close(WEIGHTS);

    # Sort the weight files by the significance value for the word.
    # Note that Yarowsky orders the words by "importance" which is 
    # the product of "salience" and frequency. But until their smoothing
    # method is added, the ordering is done by salience since otherwise
    # high-frequency words would dominate the result.
    # 
    ## # Sort the weights by importance
    ## &issue_command("sort -rn +2 $temp_weight_file > ${base}.weights");
    # Sort the weights by salience
    &issue_command("sort -rn +1 $temp_weight_file > ${base}.weights");
    unlink $temp_weight_file;
}

#------------------------------------------------------------------------------

sub fubar {
    local ($fubar) = @_;
    &debug_out(4, "fubar(@_)\n");

    return;
}


sub old_trim_punctuation {
    local ($word) = @_;

    $word =~ s/^[,\.!@\#$%^&*\(\)\{\}\[\]\"\']//g;
    $word =~ s/[,\.!@\#$%^&*\(\)\{\}\[\]\"\']$//g;
    
    return ($word);
}


sub tally_words_in_context {
    local ($context, *frequency) = @_;
    local ($word);
    local ($count) = 0;

    local(@context) = split(/\s+/, $context);
    foreach $word (@context) {
	$word = &iso_lower(&trim_punctuation($word));
	if ($word ne "") {
	    &incr_entry(*frequency, $word);
	    $count++;
	}
    }

    return ($count);
}


sub read_frequencies {
    local (*frequency, $freq_file) = @_;

    open(FREQ, "<$freq_file")
	|| die "unable to open word frequency file: $freq_file ($!)\n";
	
    &debug_out(3, "Reading word frequencies ($freq_file) ...\n");
    local($total) = 0;
    while (<FREQ>) {
	if (/^\s*\#/) {		# ignore comments
	    next;
	}
	local($word, $count) = split(/\t/, $_);
	$word = &iso_lower(&trim_punctuation($word));
	$frequency{$word} = $count;
	$total += $count;
    }
    close(FREQ);

    return ($total);
}
