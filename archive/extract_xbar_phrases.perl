#!/usr/bin/perl -sw
#
# extract_xbar_phrases.perl: extract NP (or VP, etc.) phrases from the text
# TODO: use a more intuitive name
#
# Portions Copyright (c) 2001 Cycorp, Inc.
# Portions Copyright (c) 2002-2004 Tom O'Hara.  All rights reserved. 
#
# Note:
# - NBar's are NP's without determiners, etc.
#
# TODO:
# - delete the .prep and .tag files unless debugging
# - distinguish past-part and pres-part from verb
# - support VBar's
#

# Load in the common module, making sure the script dir is first in Perl's lib path
BEGIN { my $dir = `dirname $0`; chop $dir; unshift(@INC, $dir); }
require 'common.perl';
use vars qw/$TEMP/;
require 'extra.perl';
require 'penn_tags.perl';	# conversions from Treebank tags to grammatical categories

# Process the command-line options
if (!defined($ARGV[0])) {
    my($options) = "options = [-context=N] [-quick] [-verbs]";
    my($example) = "examples:\n\n$script_name chapter7.text > chapter7.NPs.freq\n\n";
    $example .= "$0 -context=2 chapter7.text > chapter7.NPs.context\n\n";
    my($note) = "";
    ## $note .= "notes:\n\nSome usage note.\n";			# TODO: add optional note

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n$note\n";
}
&init_var(*quick, &FALSE);			# reuse intermediary files from previous run
&init_var(*skip_prep, $quick);			# reuse preprocessed text data
&init_var(*skip_tag, $quick);			# reuse part-of-speecg taggings
&init_var(*context, 0);				# context windows size (around NPs, VPs, etc.)
&init_var(*show_freq, ($context == 0));		# show phrase frequency
&init_var(*verbs, &FALSE);			# should verbs be shown instead
&init_var(*nbar, &FALSE);			# should NP omit determiners, etc.
my($target_tag) = ($verbs ? "VP" : $nbar ? "NBar" : "NP");	# target tag

my($temp_file) = "";
my($file) = $ARGV[0];

if ($file eq "-") {
    $temp_file = "$TEMP/temp-extract-$$.text";
    &write_file($temp_file, &read_entire_input());
    $file = $temp_file;
}


my($base) = &trim(&basename($file, ".text"));

# Preprocess the text
&run_command("prep_brill.perl $file > $base.prep")
    unless ($skip_prep);

# Run the Brill part-of-speech tagger
&run_command("run_brill_tagger.sh $base.prep > $base.tag")
    unless ($skip_tag);

my(%noun_phrase_counts);
open(TAGGED, "<$base.tag")
    || die "Unexpected error reading part-of-speech tagged file $base,tag ($!)\n";
while (<TAGGED>) {
    &dump_line();
    chop;
    my($text) = $_;

    # Separate the words from the parts of speech
    my(@words) = &tokenize($text);
    my($num_words) = (1 + $#words);
    my(@POS) = ("") x $num_words;
    my(@offset);
    for (my $i = 0; ($i < $num_words); $i++) {
	$offset[$i] = $i;
	if ($words[$i] =~ /(\S+)\/(\S+)/) {
	    # Get part of speech for the word
	    $words[$i] = $1;
	    $words[$i] = &to_lower($words[$i]) if ($show_freq);
	    $POS[$i] = &convert_penn_to_cat($2);
	    $POS[$i] = $words[$i] if ($POS[$i] eq "UNK");

	    # Convert special case parts of speech
	    if ($words[$i] eq "to") {
		$POS[$i] = "to_preposition";
	    }
	    $POS[$i] =~ s/proper-noun/noun/;
	}
    }
    &trace_array(\@words, &TL_DETAILED);
    &trace_array(\@POS, &TL_DETAILED);

    # Initialize the part-of-speech sequence string used in pattern matching
    my($POS_tags) = " @POS ";

    # Check for NBar patterns in the part-of-speech tags
    while (($POS_tags =~ / ((noun|adjective) )*(noun) /)
	   || ($POS_tags =~ / NBar (conjunction) NBar /)) {
	my($pattern) = $&;
	my($pre) = $`;		# '
	my($post) = $';		# '
	$POS_tags = $pre . " NBar " . $post;

	# Update the offset indicators
	my($pre_len) = scalar(&tokenize($pre));
	my($pattern_len) = scalar(&tokenize($pattern));
	my($start) = $offset[$pre_len];
	splice(@offset, $pre_len, $pattern_len, $start);
	if (&DEBUG_LEVEL >= &TL_DETAILED) {
	    my($end) = ($pre_len < $#offset) ? ($offset[$pre_len + 1] - 1) : $#words;
	    my($unit) = join(" ", @words[$start..$end]);	    
	    &debug_out(&TL_DETAILED, "grouping NBar '$unit' with pattern '$pattern' at offset $start\n");
	}
    }

    # Check for NP patterns in the part-of-speech tags
    # Also, group conjoined NP's
    if (! $nbar) {
	while (($POS_tags =~ / (determiner )?((noun|adjective) )*(NBar) /)
	       || ($POS_tags =~ / NP (conjunction|to_preposition|preposition) NP /)) {
	    my($pattern) = $&;
	    my($pre) = $`;
	    my($post) = $';	# '
	    $POS_tags = $pre . " NP " . $post;

	    # Update the offset indicators
	    my($pre_len) = scalar(&tokenize($pre));
	    my($pattern_len) = scalar(&tokenize($pattern));
	    my($start) = $offset[$pre_len];
	    splice(@offset, $pre_len, $pattern_len, $start);
	    if (&DEBUG_LEVEL >= &TL_DETAILED) {
		my($end) = ($pre_len < $#offset) ? ($offset[$pre_len + 1] - 1) : $#words;
		my($np) = join(" ", @words[$start..$end]);	    
		&debug_out(&TL_DETAILED, "grouping NP '$np' with pattern '$pattern' at offset $start\n");
	    }
	}
    }

    # Check for VP patterns in the part-of-speech tags
    # TODO: factor out common code with NP chunking
    if ($verbs) {
	while (($POS_tags =~ / verb /)
	       || ($POS_tags =~ / VP VP /)
	       || ($POS_tags =~ / VP conjunction VP /)
	       || ($POS_tags =~ / VP adverb /)
	       || ($POS_tags =~ / adverb VP /)
	       || ($POS_tags =~ / to_preposition VP /)
	       || ($POS_tags =~ / VP (adverb )*adjective /)
	       || ($POS_tags =~ / VP (preposition|to_preposition) NP /)
	       || ($POS_tags =~ / VP NP /)) {
	    my($pattern) = $&;
	    my($pre) = $`;
	    my($post) = $';	# '
	    $POS_tags = $pre . " VP " . $post;

	    # Update the offset indicators
	    my($pre_len) = scalar(&tokenize($pre));
	    my($pattern_len) = scalar(&tokenize($pattern));
	    my($start) = $offset[$pre_len];
	    splice(@offset, $pre_len, $pattern_len, $start);
	    if (&DEBUG_LEVEL >= &TL_DETAILED) {
		my($end) = ($pre_len < $#offset) ? ($offset[$pre_len + 1] - 1) : $#words;
		my($unit) = join(" ", @words[$start..$end]);	    
		&debug_out(&TL_DETAILED, "grouping VP '$unit' with pattern '$pattern' at offset $start\n");
	    }
	}
    }

    # Extract the phrases tagged NP or (VP etc.)
    if ($verbose) {
	print "tagged text: $text\n" if $verbose;
	print "text: @words\n" if $verbose;
	print "POS: ${POS_tags}\n" if $verbose;
	print "\n";
    }
    my(@new_POS) = &tokenize($POS_tags);
    for (my $i = 0; $i <= $#new_POS; $i++) {
	if ($new_POS[$i] eq $target_tag) {
	    my($start) = $offset[$i];
	    my($end) = ($i < $#offset) ? ($offset[$i + 1] - 1) : $#words;
	    my($phrase) = join(" ", @words[$start..$end]);

	    # If context words are desired add these to the phrase
	    if ($context > 0) {
		my($pre_start) = &max($start - $context, 0);
		my($pre_end) = &max($start - 1, 0);
		my($pre_context) = join(" ", @words[$pre_start..$pre_end]);
		my($post_start) = &min($end + 1, $#words);
		my($post_end) = &min($end + $context - 1, $#words);
		my($post_context) = join(" ", @words[$post_start..$post_end]);
		$phrase = "[$pre_context] $phrase [$post_context]";
	    }

	    &debug_print(&TL_DETAILED, "adding phrase '$phrase'\n");
	    &incr_entry(\%noun_phrase_counts, $phrase);
	}
    }
}
close(TAGGED);

# Display the frequency data, unless showing context in which case the NP's
# are just listed.
if ($show_freq) {
    print &format_freq_data(\%noun_phrase_counts);
    print "\n";
}
else {
    print join("\n", keys(%noun_phrase_counts));
    print "\n";
}

# Cleanup
if ($temp_file ne "") {
    unlink $temp_file unless (&DEBUGGING);
}

&exit();
