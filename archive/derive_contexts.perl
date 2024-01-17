# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# derive_contexts.perl: Derive corpus-based contexts for each of the 
# categories from Roget's Thesaurus. This supports Yarowsky's (1992)
# approach to unsupervised word-sense disambigutation:
#
# from [Yarowsky 92]:
#
# Step 1: Collect Contexts which are representative of the Roget
# Category.
# 
# The goal of this step is to collect a set of words that are typically
# found in the context of a Roget category. To do this, we extract {\it
# concordances} of 100 surrounding words for each occurrence of each
# member of the category in the corpus.
# ...
# 
# An attempt is made to minimize this effect [spurious senses] and to
# make the sample representative .... If a word such as {\it drill}
# occurs $k$ times in the corpus, all words in the context of {\it
# drill} contribute weight $1/k$ to the frequency sums.
#
# REF:
#
# Yarowsky, David, "Word-Sense Disambiguation Using Statistical Models
# of Roget's Categories Trained on Large Corpora", in Proc. COLING-92.
#
#
# TODO:
# - Look into ways of distributing the work among different instances
#   of the script.
# - Rename to derive_roget_contexts.perl.
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

if ((defined($ARGV[0]) && ($ARGV[0] eq "help"))
    || (!defined($ARGV[0]) && &blocking_stdin())) {
    $options = "options = [-rogets_index=F] [-stop_list_file=F] [-window_size=N] [-append_contexts=0|1]";
    $example = "ex: $script_name w9_1.text\n";
    $example .= "$script_name -category_filter=\"225_investment 716_attack 784_giving 787_lending 809_expenditure\" w9_sample.text\n";

    die "\nusage: $script_name [options] corpus_file ...\n\n$options\n\n$example\n\n";
}

&init_var(*rogets_index, "roget_categories.index");
&init_var(*category_filter, "");
&init_var(*stop_list_file, "wsj_high_frequency.text");
&init_var(*window_size, 50);
&init_var(*append_contexts, &FALSE);
&init_var(*just_frequency, &TRUE);

&init_roget_contexts();

foreach $file (@ARGV) {
    if (!open(CORPUS, "<$file")) {
	&debug_out(1, "*** unable to open $file ($!)\n");
	next;
    }
    &debug_out(3, "processing $file ...\n");
    $num = 0;

    # Read through the corpus, maintaining the context for each word
    # and updating the context files for each category.
    while (<CORPUS>) {
	$_ = &to_lower($_);
	&debug_out(3, "$num lines processed\n", $num) if (($num % 1000) == 0);
	$num++;
	foreach $word (split) {
	    $word = &trim_punctuation($word);
	    if ($word ne "") {
		if ($just_frequency) {
		    &update_roget_frequencies($word);
		}
		else {
		    &update_roget_contexts($word);
		}
	    }
	}
    }
    close(CORPUS);
}

# If just the frequencies are being maintained, then output the
# associative arrays for each of the Roget categories.
if ($just_frequency) {
    foreach $category (keys(%roget_category)) {
	*frequency = eval "\*freq_$category";
	&write_frequencies(*frequency, "$category.context");
    }
}


#------------------------------------------------------------------------------

# Initialize globals used for maintaining the Roget category contexts
# (specifically in update_roget_contexts).
#
# Globals:
#    word_queue			list of words +/- window_size to current one
#    pos			right end of the queue
#    center			middle position of the queue
#    roget_categories           list of Roget categories
#    word_categories		assoc. array given Roget category for word
#
sub init_roget_contexts {
    %categories_updated = ();
    @suffix = ("s", "es", "ing", "ed", "est", "er", "ly");

    # Initialize the stop list of words not to check in the corpus.
    # Augment the list with the words from the stop list file if given
    #
    @stop_list = ("", "a", "and", "from", "of", "to", "the");
    if ($stop_list_file ne "") {
	push (@stop_list, split(/\s+/, &read_file($stop_list_file)));
	push (@stop_list, "");
    }
    $stop_list = join("\t", @stop_list);
    &debug_out(5, "stop_list=$stop_list\n");

    # Determine the categories to include (defaults to all)
    local(%include);
    foreach $category (&tokenize($category_filter)) {
	&set_entry(*include, $category, &TRUE);
    }

    # Read in the Roget categories inverted index
    # NOTE: phrases are ignored
    #
    %word_categories = ();
    %roget_category = ();
    &debug_out(4, "reading roget's thesaurus index ($rogets_index)\n");
    open(WORD_INDEX, "<$rogets_index") || die "unable to open $rogets_index\n";
    while (<WORD_INDEX>) {
	($word, $categories) = split(/\t/, $_);
	if ($word !~ /\s/) {
	    $word_categories{$word} = $categories;
	}
	foreach $category (&tokenize($categories)) {
	    # Ignore the category if not on the category filter
	    if (($category_filter ne "") 
		&& (&get_entry(*include, $category, &FALSE) == &FALSE)) {
		next;
	    }
	    $roget_category{$category} = &TRUE;
	}
    }
    close(WORD_INDEX);

    # Reset the existing files unless there are to be retained
    # (eg, if parallel updates are being made)
    if ($append_contexts == &FALSE) {
	foreach $category (keys(%roget_category)) {
	    &write_file("$category.context", "");
	}
    }

    # Initialize the queue for the context window
    $max_pos = 2 * $window_size + 1;
    for ($i = 0; $i < $max_pos; $i++) {
	$word_queue[$i] = "";
    }
    $pos = 0;
    $center = $window_size;

    return;
}


# update_roget_contexts(word)
#
# Updates the files containing KWIC-style contexts for each of the Roget
# categories as follows:
#
# 1. Updates the context window queue by adding the specified word to the
#    right end ($pos) and removing the one on the left end (pos + 1 mod |Q|).
#    This maintains the window of words around the current one, which is
#    WindowSize words back from the new word.
#
# 2. If the new center word belongs to one or more Roget categories, then
#    update the context file for that category by appending a representation
#    of the current context.
#
# NOTES: 
#    For efficiency the circular queue is output as is, without normalizing
#    it's representation to match standard KWIC output.
#
#    Also, there are several globals that are maintained here. See
#    init_roget_contexts for a brief description.
#
sub update_roget_contexts {
    local($new_word) = @_;
    $word_queue[$pos] = $new_word;
    ## &debug_out(9, "update_roget_contexts(@_)\n");

    # Update the contexts for each category
    local($word) = $word_queue[$center];

    # Determine the list of categories for the word. First, check the
    # word as-is, then apply transformations to account for common suffixes.
    local($categories) = $word_categories{$word};
    for ($i = 0; (!defined($categories) && ($i <= $#suffix)); $i++) {
	local($new_word) = $word;
	$new_word =~ s/$suffix[$i]$//;
	$categories = $word_categories{$new_word};
	if (defined($categories)) {
	    $word = $new_word;
	}
    }
    if (defined($categories) && ($stop_list !~ /\t$word\t/)) {
	$categories = &trim($categories);

	# Create the context (which looks like a circular queue not
	# the traditional kwic)
	$word_queue[$center] = "*** $word ***";
	$context = "@word_queue\n";
	$word_queue[$center] = $word;

	# Update each of the categories
	foreach $category (split(/\s+/, $categories)) {
	    $context_file = "$category.context";
	    if (!defined($categories_updated{$category})) {
		&write_file($context_file, "");
		$categories_updated{$category} = &TRUE;
	    }
	    
	    &append_file($context_file, $context);
	}
    }

    $pos = ($pos + 1) % $max_pos;
    $center = ($center + 1) % $max_pos;

    return;
}


# update_roget_frequencies(word)
#
# Like update_roget_context, except that frequencies for each category
# are maintained in memory.
# NOTE: This requires a massive amount of memory (256MB+) for processing
# all 1000+ categories at the same time.
# 
sub update_roget_frequencies {
    local($new_word) = @_;
    $word_queue[$pos] = $new_word;
    ## &debug_out(9, "update_roget_frequencies(@_)\n");

    # Update the contexts for each category
    local($word) = $word_queue[$center];

    # Determine the list of categories for the word. First, check the
    # word as-is, then apply transformations to account for common suffixes.
    local($categories) = $word_categories{$word};
    for ($i = 0; (!defined($categories) && ($i <= $#suffix)); $i++) {
	local($new_word) = $word;
	$new_word =~ s/$suffix[$i]$//;
	$categories = $word_categories{$new_word};
	if (defined($categories)) {
	    $word = $new_word;
	}
    }
    if (defined($categories) && ($stop_list !~ /\t$word\t/)) {
	$categories = &trim($categories);

	# Create the context (which looks like a circular queue not
	# the traditional kwic)
	$context = "@word_queue\n";

	# Update the frequencies for each of the categories
	foreach $category (&tokenize($categories)) {
	    if (defined($roget_category{$category})) {
		*frequency = eval "\*freq_$category";
		&tally_words_in_context($context, *frequency);
	    }
	}
    }

    $pos = ($pos + 1) % $max_pos;
    $center = ($center + 1) % $max_pos;

    return;
}

# trim_punctuation(word)
#
# Removes leading and trailing punctuation from the word (or phrase).
#
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
    &debug_out(6, "tally_words_in_context(_, %s)\n", *frequency);

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

sub write_frequencies {
    local (*frequency, $freq_file) = @_;
    &debug_out(5, "write_frequencies(@_)\n");

    open(FREQ, ">$freq_file")
	|| die "unable to create word frequency file: $freq_file ($!)\n";
	
    &debug_out(4, "Writing word frequencies ($freq_file) ...\n");
    local($word);
    foreach $word (keys(%frequency)) {
	printf FREQ "%s\t%d\n", $word, $frequency{$word};
    }
    close(FREQ);

    return;
}
