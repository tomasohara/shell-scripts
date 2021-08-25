# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# disambiguate_text.perl: Disambiguate the words in a text by finding
# the Roget's category that best matches the text's context and then
# selecting the sense that applies in the context of a Roget's category.
#
# from [Yarowsky 92]:
#
# Step 3: Use the resulting weightd to predict the appropriate category for
# a word in a novel context.
#
# When any of the salient words derived in step 2 [see calculate_weights.perl]
# appear in the context of an ambiguaous word, there is evidence that the
# word belongs to the indicated category. If serveral such words appear, the
# evidence is compunded. Using Bayes' rule, we sum their weights, over all 
# words in context, and determine the category for which the sume is greatest.
#
#	ARGMAX [Pr(RCat | context) =] SUM (Pr(w | RCat) x Pr(Rcat)/Pr(w))
#         RCat                    w in context
#
# REF:
#
# Yarowsky, David, "Word-Sense Disambiguation Using Statistical Models
# of Roget's Categories Trained on Large Corpora", in Proc. COLING-92.
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';
require 'extra.perl';

if ((defined($ARGV[0]) && ($ARGV[0] eq "help"))
    || (!defined($ARGV[0]) && &blocking_stdin())) {
    $options = "options = [-word_count_file=file] [-by_importance=0|1]";
    $example = "ex: nice +19 $script_name -category_pattern='(animal)|(instrument)' crane.text >&! crane.log\n";
    $example .= "$script_name -d=6 -category_pattern='(promise)|(property)|(event)' policy.text >&! policy.log\n";
    $example .= "$script_name -TOPN=100 policy.text >&! policy100.log\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
}


## &init_var(*word_count_file, "w9_1.freq");
&init_var(*max_weights, 1000);
&init_var(*category_pattern, ".*");
&init_var(*by_importance, &FALSE);
&init_topN(5);
&init_var(*weight_file_pattern, "*/*.weights");
## $log2 = log(2);

## # Read in the global frequencies
## #
## $total_global_frequency = &read_frequencies(*global_frequency, $word_count_file);
## &assert('$total_global_frequency > 0');


# Process each context file specified on the command line
#
foreach $file (<@ARGV>) {
    $text = &read_file($file);

    &clear_topN(*max_category, *max_weight);
    foreach $weight_file (glob($weight_file_pattern)) {
	$category = &remove_dir(&basename($weight_file, ".weights"));

	if ($category !~ $category_pattern) {
	    &debug_out(7, "skipping category $category\n");
	    next;
	}

	if ($by_importance == &TRUE) {
	    $alt_weight_file = "$weight_file.alt";
	    &issue_command("sort -rn +1 $weight_file > $alt_weight_file")
		unless (-e $alt_weight_file);
	    $weight_file = $alt_weight_file;
	}
	&read_weights($category, $weight_file, *weight);
	$context_weight = &tally_word_weights($text);
	&revise_topN(*max_category, *max_weight, $category, $context_weight);
    }

    &show_topN(*max_category, *max_weight);
}

#------------------------------------------------------------------------------


sub old_trim_punctuation {
    local ($word) = @_;

    $word =~ s/^[,\.!@\#$%^&*\(\)\{\}\[\]\"\']//g;
    $word =~ s/[,\.!@\#$%^&*\(\)\{\}\[\]\"\']$//g;
    
    return ($word);
}


sub tally_word_weights {
    local ($context, *weight) = @_;
    local ($word);
    &debug_out(7, "tally_word_weights(@_)\n");

    # TODO: apply window of 50 words around current
    local ($context_weight) = 0.0;
    @context = split(/\s+/, $context);
    foreach $word (@context) {
	$word = &iso_lower(&trim_punctuation($word));
	$weight = &get_entry(*weight, "$category:$word");
	if ($weight > 0) {
	    &debug_out(6, "weight($word) = %.3f\n", $weight);
	    $context_weight += $weight;
	}
    }

    return ($context_weight);
}


sub read_weights {
    local ($category, $weight_file, *weight) = @_;
    &debug_out(5, "read_weights(@_)\n");

    # See if the weights have already been read
    if (defined($weight{"$category:_"})) {
	return;
    }

    # Open the file, and terminate the program if not found
    open(WEIGHT, "<$weight_file")
	|| die "unable to open word weight file: $weight_file ($!)\n";

    # Read in the weights from the file, up to the maximum number
    &debug_out(3, "Reading word frequencies ($weight_file) ...\n");
    $count = 0;
    local($last_value) = &MAXINT;
    while (<WEIGHT>) {
	s/\#.*$//;		# remove comments
	if (/^\s*$/) {		# ignore blank lines
	    next;
	}
	($word, $weight, $importance) = split(/\t/, $_);

	# Perform a sanity check on the weights (should be sorted)
	&debug_out(9, "$word, $weight, $importance\n");
	if ($by_importance) {
	    &assert('$importance <= $last_value');
	    $last_value = $importance;
	}
	else {
	    &assert('$weight <= $last_value');
	    $last_value = $weight;
	}

	# Add the weight to the associative array, keyed off of the
	# category and word pair
	$weight{"$category:$word"} = $weight;
	if (++$count >= $max_weights) {
	    last;
	}
    }
    close(WEIGHT);
    $weight{"$category:_"} = &TRUE;

    return ($count);
}


sub read_frequencies {
    local (*frequency, $freq_file) = @_;
    &debug_out(5, "read_frequencies(@_)\n");

    open(FREQ, "<$freq_file")
	|| die "unable to open word frequency file: $freq_file ($!)\n";
	
    &debug_out(3, "Reading word frequencies ($freq_file) ...\n");
    $total = 0;
    while (<FREQ>) {
	if (/^\s*\#/) {		# ignore comments
	    next;
	}
	($word, $count) = split(/\t/, $_);
	$word = &iso_lower(&trim_punctuation($word));
	$frequency{$word} = $count;
	$total += $count;
    }
    close(FREQ);

    return ($total);
}
