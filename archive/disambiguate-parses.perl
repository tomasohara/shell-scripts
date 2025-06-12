# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# disambiguate-parses.perl: Disambiguate parses in relational tuple format
# by resolving the underlying relations (e.g., for prepositions) and by
# disambiguating the source and target terms.
#
# The input parses consists of relationships in the following format:
#	'<' source-word ',' relation-word ',' target-word '>' [':' weight]
# Each word in turn is specified as follows:
#       [offset. ] POS:word
# where the offset is the 0-based position in the sentence.
# The output format excludes the offset and adds in a sense indicator:
#	POS:word#sense
#
# This was designed for use in the lexical-relation extraction system
# based on WordNet differentia (see extract-differentia.perl).
#------------------------------------------------------------------------
# Sample input:
#
# parse_ID: N00015787
# sense: noun:artifact#1
# definition: An artifact is a man-made object  .
# syntactic dependencies:
# <2. n:artifact, 3. v:is, 6. n:object>: 0.250
# <5. adj:man-made, modifier-of-5-6, 6. n:object>: 0.500
#
# Sample output:
#
# parse_ID: N00015787
# sense: noun:artifact#1
# definition: An artifact is a man-made object  .
# syntactic dependencies:
# <2. n:artifact, 3. v:is, 6. n:object>: 0.250
# <5. adj:man-made, modifier-of-5-6, 6. n:object>: 0.500
# semantic relations:
# <noun:artifact#1, is-a, noun:object#1>: 0.250
# <adjective:man-made#1, modifier-of, noun:object#1>: 0.500
#
#------------------------------------------------------------------------
# NOTES:
# - Word position is omitted from the output. 
# - Anaphora is not addressed in the output. This would require introducing 
#   variables or changing the representation to a more general format.
# - The relations represented are at the level of types or categories. To
#   handle instance-level relationships, variables could be introduced as done
#   in Cyc's CYCL representation language (first-order predicate logic).
# - If a term can't be disambiguated, the sense number is omitted.
# _ To allow for batch classification of the relations (for efficiency), the
#   parse info is read in its entirety before disambiguation is done. Also,
#   the results are saved to a temp file in same format at for term disambiguation.
# - Terms that cannot be disabmiguated as left without the sense indicator
#   (e.g., noun:run).
# - Internally the sense number of -1 is used for an untagged sense. Sense
#   0 would be better for compatibility with other GraphLing scripts, but 
#   sense 0 used to be the default category by the WSD classifier and thus
#   there still might be conflicts with the older scripts.
# - The sentence is assumed to have dummy words added so that there is a unique
#   token for each relation represented in the sentence (just for sanity checks);
#   ex: "The fat dog slept modifier-of-1-2"
#
# TODO:
# - Batch all the relationships together before running the classifier
#   to reduce the overhead of loading probability tables, etc.
# - Use relationship vs. relation, etc. consistently here and in other
#   lexrel-related scripts.
# - Allow for a more-general frame-based representation.
# - Remove any dependencies on WordNet (e.g., comments regarding parse_wordnet_def.perl).
# - *** Develop automated unit-test facility based on EX's in function header comments
# - Have an option so that terms not disambiguated are tagged with a sense sense
#   indicator (e.g., noun:run#-1).
# - Show the raw link grammar relations in differentia listing.
# - Revise sample input/output to reflect current version.
# - Remove the dummy relation words from the 'sentence:' section of output?
# - *** Reduce memory usage!
#
# Copyright (c) 2004 Tom O'Hara and New Mexico State University.
# Freely available via GNU General Public License (see GNU_public_license.txt).
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN {
    my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir);
    require 'common.perl';
    use vars qw/$d $TEMP $script_name/;
    require 'extra.perl';
    require 'graphling.perl';
    use vars qw/$GRAPHLING $reuse $UNTAGGED_SENSE $DUMMY_SENSE/;
}


# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
use vars qw/$LEXREL_DIR $relation_dataset $classification_dir $term_disambig_file $max_target_displacement $just_batched_disambiguation $batched_disambiguation $single_disambiguation $retain_relational_offsets/;

# Specify other global variables
our($temp_sentence_file);	# file for sentences
our($DEFAULT_RELATION);		# the default relation (type) to use (e.g., "n/a")
our($relation_cache);		# file with batched relation disambiguations


# Show a usage statement if no arguments given
# NOTE: By convention - is used when no arguments are required
if (!defined($ARGV[0])) {
    my($options) = "main options = [-LEXREL_DIR=dir] [-relation_dataset=file] [-classification_dir=dir]\n";
    $options    .= "               [-term_disambig_file=file] [-max_target_displacement=n] [-batched_disambiguation] [-retain_relational_offsets]";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "examples:\n\n$script_name temp-differentia-16797.parse\n\n";
    $example .= "wn mouse -synsn -g | parse_wordnet_defs.perl -\n\n";
    my($note) = "";
    $note .= "notes:\n\nInput is assumed to be from parse_wordnet_defs.perl\n";

    print STDERR "\nusage: $script_name [options]\n\n$options\n\n$example\n$note\n";
    &exit();
}

# Initialize the script options checking for command-line overrides
&init();

# Set paragraph input mode
# TODO: figure out way to just set this locally
## $/ = "";
my($record_separator) = $/;
$/ = "";

# Read the entire set of parses and then restore input mode
my(@parses) = <ARGV>;
#/ = $record_separator;
# TODO: figure out the problem w/ '#/ = $record_separator'
$/ = "\n";

# Extract the information (eg, header, lexical relations) from the parse.
# Store as list of [header, lexical-relations, conceptual-relations] items
my(@parse_info) = &extract_parse_info(@parses);

# Disambiguate the terms and relations in the lexical relations
if ($batched_disambiguation) {
    &disambiguate_all_relations(\@parse_info);
}
&refine_parse_info(\@parse_info);

# Output the parse information including conceptual relations (ie, refine lexical ones)
&output_refined_info(\@parse_info);


&exit();


#------------------------------------------------------------------------------

# init(): initialize settings for the script
# EX: init() => 1
#
sub init {
    &debug_print(&TL_DETAILED, "init()\n");

    # Check the command-line options
    # note: Each initialization corresponds to a -var=value commandline option
    &init_var(*LEXREL_DIR, 		# dir. for lexical relation information
    	  "$GRAPHLING/DATA/LEXICAL_RELATIONS"); 
    my($default_annots) = ($test ? "sample-combined-relations.annotations" : "combined-relations.annotations");
    &init_var(*relation_dataset,	# dataset for relations annotations
	      "$LEXREL_DIR/$default_annots");
    &init_var(*classification_dir, 	# directory for classifier results
    	  "temp-classification");

    &init_var(*term_disambig_file, 	# file with word-sense disambiguations
	      "$LEXREL_DIR/xwn-1.7.1.sense");
    &init_var(*max_target_displacement,	# max. offset for target words in sent.
	      2);
    &init_var(*single_disambiguation,	# don't batch the disambiguations
	      &FALSE);
    &init_var(*just_batched_disambiguation, # only perform batch disambig.
	      &FALSE);
    &init_var(*batched_disambiguation,	# whether to batch relation disambig.
	      (! $single_disambiguation) || $just_batched_disambiguation);
    &init_var(*retain_relational_offsets, # keep offsets in relations (eg, modifies-7-8)
	      &FALSE);

    $temp_sentence_file = "$TEMP/temp-sentence-$$.txt";
    $DEFAULT_RELATION = "n/a";
    $relation_cache = "$TEMP/temp-relation-cache-$$.data";

    return (&TRUE);
}


# extract_parse_info(parse_data): Extracts the lexical relations and other information
# from the parse produced by parse_wordnet_defs.perl
#
# EX-old: extract_parse_info("Parse ID: N99999999\nsentence: A pen is a writing implement\nlinkages:\n<2. n:pen, 3. v:is, 6. n:implement>: 1.000\n<5. adj:writing, modifier-of-5-6, 6. n:implement>: 1.000\n", "Parse ID: N88888888") => (["N99999999", "A pen is a writing implement", "Parse ID: N99999999\nsentence: A pen is a writing implement", [<2. n:pen, 3. v:is, 6. n:implement>: 1.000\n<5. adj:writing, modifier-of-5-6, 6. n:implement>: 1.000], []], ["N88888888", "", "Parse ID: N88888888", [], []])
#
# EX: @_ = extract_parse_info("Parse ID: N99999999\nsentence: A pen is a writing implement modifier-of-5-6\nlinkages:\n<2. n:pen, 3. v:is, 6. n:implement>: 1.000\n<5. adj:writing, modifier-of-5-6, 6. n:implement>: 1.000\n", "Parse ID: N88888888"); stringify(\@_) => [['N99999999','A pen is a writing implement','Parse ID: N99999999\nsentence: A pen is a writing implement modifier-of-5-6',['<2. n:pen, 3. v:is, 6. n:implement>: 1.000','<5. adj:writing, modifier-of-5-6, 6. n:implement>: 1.000'],[]],['N88888888','','Parse ID: N88888888',[],[]]]
#
sub extract_parse_info {
    my(@parses) = @_;
    &debug_print(&TL_DETAILED, "extract_parse_info(@_)\n");
    my(@parse_info);

    foreach my $parse (@parses) {
        chomp $parse;
        &debug_print(&TL_VERBOSE, "parse={$parse}\n");
        my($parse_ID) = ($parse =~ /Parse ID: (\S+)/i);
        $parse_ID = "???" if (!defined($parse_ID));
        my($sentence) = ($parse =~ /sentence: ([^\n]+)/);
        $sentence = "" if (!defined($sentence));
        &assert($parse_ID =~ /[ANRV]\d{8}/);	# TODO: conditionalize on Wordnet
        &debug_print(&TL_DETAILED, "parse_ID=$parse_ID sentence=$sentence\n");
    
        # Extract the relations from the parse
	my(@lexical_relations);
	my($header) = $parse;
	&assert(($parse =~ /linkages:/));
        if ($parse =~ /linkages:([^\000]+)/i) {
	    $header = &trim($`);
	    my($linkages) = &trim($1);
	    $linkages = "" if ($linkages eq "n/a");

	    @lexical_relations = grep {! /^\s*\#/} split(/\n/, &trim($linkages));
	    &debug_print(&TL_DETAILED, "lexical_relations=(@lexical_relations)\n");
    	}
	push(@parse_info, [$parse_ID, $sentence, $header, \@lexical_relations, []]);

    }
    &debug_print(&TL_VERBOSE, "extract_parse_info(@_) => ", stringify(@parse_info), "\n");

    return (@parse_info);
}


# refine_parse_info(parse_data): Refine the parse via disambiguation
#
sub refine_parse_info {
    my($parse_info_ref) = @_;
    &debug_print(&TL_DETAILED, "refine_parse_info(@_)\n");

    foreach my $parse_info_ref (@{$parse_info_ref}) {
	&debug_out(&TL_VERBOSE, "revised parse_info=%s\n", stringify($parse_info_ref));
	my($parse_ID, $sentence, $header, $lexical_rels_ref, $conceptual_rels_ref) 
	    = @{$parse_info_ref};
	## &assert((scalar @{$lexical_rels_ref}) > 0);
	## &assert((scalar @{$conceptual_rels_ref}) == 0);
    
    	# Refine each of the relationships.
	# NOTE: By default offsets are remove for those left ambiguous (e.g., modifier-of-3-4)
    	# example: '<2. n:artifact, 3. v:is, 6. n:object>: 0.25'
    	#       => '<n:artifact#1, is-a, n:object#1>: 0.25'
    	foreach my $relationship (@{$lexical_rels_ref}) {
    	    my($source, $relation, $target, $weight) = &parse_relationship($relationship);
    	    $source = &disambiguate_term($source, $parse_ID, $sentence);
    	    $target = &disambiguate_term($target, $parse_ID, $sentence);
    	    $relation = &disambiguate_relation($relation, $parse_ID, $sentence);
	    $relation =~ s/(\S+)\-\d+\-d+/$1/ unless ($retain_relational_offsets);
    	    push (@{$conceptual_rels_ref}, &format_relationship($source, $relation, $target, $weight));
    	}
	&debug_out(&TL_VERBOSE, "again revised parse_info=%s\n", stringify($parse_info_ref));
    }
}


# output_refined_info(parse_info_ref): Output the conceptual relations in the
# revised parse-info structure.
#
sub output_refined_info {
    my($parse_info_ref) = @_;
    &debug_print(&TL_DETAILED, "output_refined_info(@_)\n");

    foreach my $parse_info_ref (@{$parse_info_ref}) {
	&debug_out(&TL_VERBOSE, "refined parse_info=%s\n", stringify($parse_info_ref));
	my($parse_ID, $sentence, $header, $lexical_rels_ref, $conceptual_rels_ref) = @{$parse_info_ref};
	## &assert((scalar @{$lexical_rels_ref}) > 0);
	## &assert((scalar @{$conceptual_rels_ref}) > 0);
    
    	# Print the conceptual relations (i.e., disambiguated lexical relations).
    	# The original relations are shown as comments
    	print "$header\n";
    	print "# ", join("\n# ", @{$lexical_rels_ref}), "\n";
    	print "conceputal relations:\n";
    	print join("\n", @{$conceptual_rels_ref}), "\n";
    	print "\n";
    }
}


# disambiguate_all_relations(parse_info_ref): disambiguate the relations in
# all of the parses, using a single classification run via GraphLing.
# Currently this just handles prepositional relation words.
#
# NOTE: By default refine_parse_info invokes the relation classifier one by one,
# which is vastly inefficient in the current GraphLing setup since the marginal
# probabilities are recalculated each time anew for the training data.
# TODO:
# - rename the variables for more clarity
#
sub disambiguate_all_relations {
    my($parse_info_ref) = @_;
    &debug_print(&TL_DETAILED, "disambiguate_all_relations(@_)\n");

    # Create list of sentences to use for the classification
    # example: To add is to make an addition <wf sense=-1>by</wf> combining numbers.
    my(@relation_annots, @relationships, @sentences, @parse_IDs);
    foreach my $parse_info_ref (@{$parse_info_ref}) {
	&debug_out(&TL_VERBOSE, "refined parse_info=%s\n", stringify($parse_info_ref));
	my($parse_ID, $sentence, $header, $lexical_rels_ref, $conceptual_rels_ref) 
	    = @{$parse_info_ref};
	## &assert((scalar @{$lexical_rels_ref}) > 0);
	## &assert((scalar @{$conceptual_rels_ref}) == 0);
    
    	foreach my $relationship (@{$lexical_rels_ref}) {
    	    my($source, $relation, $target, $weight) = &parse_relationship($relationship);
	    my($offset, $POS, $relation_word) = &parse_word_spec($relation);

	    if (! &is_prep($relation_word)) {
		&debug_print(&TL_VERBOSE, "not classifying non-prep: $relation_word\n");
		next;
	    }

	    push(@relation_annots, &format_annotation_sentence($sentence, $relation_word, $offset));
	    push(@parse_IDs, $parse_ID);
	    push(@relationships, $relationship);
	    push(@sentences, $sentence);
    	}
    }
    &debug_out(&TL_VERY_DETAILED, "relationships=%s\n", stringify(\@relationships));
    
    # Run all the classifications to determine the disambiguated relations
    # example: To add is to make an addition <wf sense=-1>by</wf> combining ...
    #       => MNR 
    # NOTE: result is just the list of the relation names
    my(@relations) = &run_relation_classifier(@relation_annots);

    # Output cache file for later use in actual relation disambiguation.
    # Separate annotations for the same sentence must be merged into one.
    &assert((scalar @relations) == (scalar @relationships));
    my(%relation_annots);
    for (my $i = 0; $i <= $#relations; $i++) {
	my($old_annot) = &get_entry(\%relation_annots, $parse_IDs[$i], "");

	# Create new relationship given the disambiguations
	# TODO:
	# - use relation_word for the relation-indicating word
	# - streamline extraneous arrays like @sentences (eg, derive from annot)
	my($source, $relation, $target, $weight) = &parse_relationship($relationships[$i]);
	my($offset, $POS, $word) = &parse_word_spec($relation);
	my($sense_spec) = &format_sense_spec($POS, $word, $relations[$i]);
	my($new_annot) = &sgml2sense(&format_annotation_sentence($sentences[$i], $sense_spec, $offset));

	# Merge the two annotations
	my($revised_annot) = ($old_annot eq "") ? $new_annot : &merge_annotations($old_annot, $new_annot);
	&set_entry(\%relation_annots, $parse_IDs[$i], $revised_annot);
    }

    # Output sentences with the new relation indicators
    # example: To add is to make an addition <wf sense=MNR>by</wf> ...
    &debug_out(&TL_VERY_DETAILED, "relation_annots=%s\n", stringify(\%relation_annots));
    &write_file($relation_cache, &format_assoc_data(\%relation_annots));

    return;
}


# sgml2sense(annots): returns #-style sense annotations given SGML wf-style
# EX: sgml2sense("the <wf sense=6>law</wf> arrived") => "the law#6 arrived"
#
sub sgml2sense {
    my($annots) = @_;
    &debug_print(&TL_VERBOSE, "sgml2sense(@_)\n");
    return (&run_command_over("perl -Ssw sgml2sense.perl -default_POS=''", $annots));
}


# merge_annotations(annots1, annots2): combine the annotations in the
# two sentences
# EX: merge_annotations("spring chicken#2", "spring#1 chicken") => "spring#1 chicken#2"
#
sub merge_annotations {
    my($annots1, $annots2) = @_;
    &debug_print(&TL_VERBOSE, "merge_annotations(@_)\n");
    &assert($annots1 !~ /<wf sense=/);
    &assert($annots2 !~ /<wf sense=/);

    # Convert to lists of tokens
    my(@annots1) = &tokenize($annots1);
    my(@annots2) = &tokenize($annots2);
    &assert((scalar @annots1) == (scalar @annots2));

    # Merge token by token, using first POS/word/sense component of each
    my(@merged_annots);
    for (my $i = 0; $i <= $#annots1; $i++) {
	my($POS1, $word1, $sense1) = &parse_sense_spec($annots1[$i]);
	my($POS2, $word2, $sense2) = &parse_sense_spec($annots2[$i]);

	my($POS) = ($POS1 ne "") ? $POS1 : $POS2;
	my($word) = ($word1 ne "") ? $word1 : $word2;
	my($sense) = ($sense1 ne $UNTAGGED_SENSE) ? $sense1 : $sense2;
	$merged_annots[$i] = &format_sense_spec($POS, $word, $sense);
    }
    my($merged_annots) = "@merged_annots";
    &debug_print(&TL_VERY_DETAILED, "merge_annotations() => \"$merged_annots\"\n");

    return ($merged_annots);
}


# disambiguate_term(word_spec, parse_ID, sentence): Resolve the specified word
# into it's underlying sense. This checks the disambiguation for the term using
# the predetermined disambiguations in the data file. The result is the sense
# in <POS>:<word>#<sense> format, unless the term cannot be disambiguated in
# which case just <POS>:<word> is returned.
#
# EX: disambiguate_term("7.n:jazz", "N00076344", "A jam session is an impromptu jazz concert") => "noun:jazz#2"
# EX-todo: disambiguate_term("n:artifact", "N00015787", "An artifact is a man-made object") => "noun:artifact#1"
#
# NOTE: For parses of WordNet definitions, the parse ID is assumed to be the
# synset ID (<POS_letter><data_file_offset>).
#
# TODO:
# - extend into handling phrases rather than just single words
# - Use some fall-back mechanism if not resolved (e.g., Leskian algorithm)
# - Provide better way of handling token offset mismatches
# - Provide options for how untagged senses are indicated (e.g., noun:dog#0 vs noun:dog)
#
sub disambiguate_term {
    my($word_spec, $parse_ID, $sentence) = @_;
    &debug_print(&TL_VERBOSE, "disambiguate_term(@_)\n");
    my($disambiguated_term) = &check_disambiguation_cache($term_disambig_file, $word_spec, $parse_ID, $sentence);

    # TODO: use a fall-back WSD technique such as Lesk-TD/IDF

    return ($disambiguated_term);
}

# check_disambiguation_cache($cache_file, word_spec, parse_ID, [default_sense])
#
# See if there exists a predetermined disambiguation for the given word in a particular
# parse case.
#
# EX: &write_file("/tmp/cache.data", "N00000000\tMy dog has fleas#1 .\nN00000001\tThe flea#2 market closed .\n"); check_disambiguation_cache("/tmp/cache.data", "fleas", "N00000000") => "fleas#1"
#
# NOTE: This supports use of external disambiguations (eg., Extended WordNet) as well
# as batched disambiguations done for efficiency purposes (eg, for relation classification)
#
sub check_disambiguation_cache {
    my($cache_file, $word_spec, $parse_ID, $default_sense) = @_;
    $default_sense = $UNTAGGED_SENSE if (!defined($default_sense));
    &debug_print(&TL_VERBOSE, "check_disambiguation_cache(@_)\n");
    my($target_offset, $target_POS, $target_word) = &parse_word_spec($word_spec);
    my($disambiguated_term) = &format_sense_spec($target_POS, $target_word, $UNTAGGED_SENSE);

    # Lookup the predetermined disambiguation in the data file
    # example: 'any N:entity#1 that V:causes#1 N:events#1 to V:happen#1'
    my($disambiguated_sentence) = &run_command("grep -i $parse_ID $cache_file");

    # Check the token at the specified offset to see if matches the target word.
    # The first matching token at offset near target offset is used, and the part
    # of speech of the lookup token is used (instead of one from the sense data).
    my($offset) = -1;
    foreach my $disambiguation_token (&tokenize($disambiguated_sentence)) {
	$offset++;
	my($POS, $word, $sense) = &parse_sense_spec($disambiguation_token);
	if ($word eq $target_word) {
	    $disambiguated_term = &format_sense_spec($target_POS, $target_word, $sense);
	    last if (abs($offset - $target_offset) <= $max_target_displacement);
	}
    }
    &debug_print(&TL_VERBOSE, "check_disambiguation_cache() => $disambiguated_term\n");

    return ($disambiguated_term);
}


# disambiguate_relation(relation_word_spec, parse_ID, sentence): Resolve the 
# relation-indicating word into the underlying relation, based on its usage in 
# the sentence. The result is the sense-spec using label for the relation
# (e.g., "along#location) or the original word spec (e.g., "that").
# Currently this just handles prepositional relation words.
#
# EX: cmd("touch $relation_cache"); disambiguate_relation("7. at", "N00341347", "a game played under artificial illumination at night") => "at#TMP"
# EX: disambiguate_relation("subject-of-5-7", "N02329747", "the operating part that transmits power to a mechanism") => "subject-of-5-7"
#
# NOTE:
# - When checking the cache, the default relation is UNTAGGED_SENSE (),
#   different from DEFAULT_RELATION (n/a) used by the relation classifier.
# TODO:
# - extend into handling relation-indicating phrases rather than just words
# - use predetermined disambiguations if available (e.g., analogous to disambiguate_term)
# - use a hierarchy of classifiers (e.g., prep-specific, fallback, etc.)
#
#
sub disambiguate_relation {
    my($word_spec, $parse_ID, $sentence) = @_;
    &debug_print(&TL_VERBOSE, "disambiguate_relation(@_)\n");
    my($relation) = $DEFAULT_RELATION;

    # The default is the relation word-spec with an untagged sense
    my($target_offset, $target_POS, $target_word) = &parse_word_spec($word_spec);
    my($disambiguated_term) = &format_sense_spec($target_POS, $target_word, $UNTAGGED_SENSE);

    # First check the disambiguation cache for the relation
    if ($batched_disambiguation) {
	$disambiguated_term = &check_disambiguation_cache($relation_cache, $word_spec, $parse_ID, $UNTAGGED_SENSE);
	my($POS, $word, $sense) = &parse_sense_spec($disambiguated_term);
	if ($sense ne $UNTAGGED_SENSE) {
	    $relation = $sense;
	}
    }

    # Run Graphling classifier over the sentence unless already disambiguated;
    # currently this just handles prepositional relation words.
    # NOTE: $just_batched_disambiguation hook is workaround for extraneous
    # classification problem
    if (($relation eq $DEFAULT_RELATION) && (! $just_batched_disambiguation)) {
	my($target_offset, $target_POS, $target_word) = &parse_word_spec($word_spec);
	if (&is_prep($target_word)) {
	    $relation = &classify_relation($relation_dataset, $target_word, $sentence, $target_offset);
	    if ($relation ne $DEFAULT_RELATION) {
		$disambiguated_term = &format_sense_spec($target_POS, $target_word, $relation);
	    }
	}
	else {
	    &debug_print(&TL_VERBOSE, "not classifying non-prep: $target_word\n");
	}
    }
    &debug_print(&TL_VERBOSE, "disambiguate_relation() => $disambiguated_term\n");

    return ($disambiguated_term);
}


# classify_relation(dataset, word, sentence, offset): determine the semantic
# relation that is indicated by function WORD at OFFSET in SENTENCE. If the
# relation cannot be classified, then "n/a" is returned.
#
# EX: $reuse=1; classify_relation("/home/graphling/DATA/LEXICAL_RELATIONS/combined-relations.annotations", "for", "social insurance for the disabled", 2) => "BNF"
#
# NOTE:
# - Currently the marginal probabilities for the GraphLing classifier are
#   re-evaluated each time (although the same), so repeated invocations can
#   be very inefficient. See disambigate_all_relations for batch processing.
# TODO:
# - put into graphling.perl
# - account for modification relations
#
sub classify_relation {
    my($relation_dataset, $word, $sentence, $offset) = @_;
    $offset = -1 if (!defined($offset));
    &debug_print(&TL_VERBOSE, "classify_relation(@_)\n");


    # Create formatted sentence for the classifier with dummy sense.
    # Then run the classifier and extract the relation tag determined.
    my($test_sentence) = &format_annotation_sentence($sentence, $word, $offset);
    my(@relations) = &run_relation_classifier($test_sentence);
    my($relation) = (defined($relations[0]) ? $relations[0] : $DEFAULT_RELATION);
    &debug_print(&TL_VERBOSE, "classify_relation() => $relation\n");

    return ($relation);
}


# run_relation_classifier(sentences): run the relation classifier over each of 
# the sentences, returning a list of relations (one per sentence)
#
# EX: $reuse=1; run_relation_classifier("meet <wf sense=-1>at</wf> noon", "man <wf sense=-1>at</wf> the corner") => ("TMP", "LOC")
# EX: run_relation_classifier("Factory payrolls fell <wf sense=-1>in</wf> September .") => ("TMP")
# EX: run_relation_classifier("His hands sit farther apart <wf sense=LOC>on</wf> the keyboard .") => ("LOC")
#
# TODO:
# - have option to only disambiguate function words in the relation position
# - have option to disambiguate non-function words as terms
#
sub run_relation_classifier {
    my(@sentences) = @_;
    my($results_file) = "$classification_dir/SAMPLE.DIST";
    my($old_sentence_file) = "$classification_dir/test_sentences.ADHOC";
    &debug_print(&TL_VERBOSE, "run_relation_classifier(@_)\n");

    # Run the classification unless the results file already exists for
    # same set of sentences (e.g., subsequent run on same data)
    my($sentence_data) = join("\n", @sentences) . "\n";
    my($old_sentence_data) = "";
    if ($reuse && (-e $old_sentence_file)) {
	$old_sentence_data = &read_file($old_sentence_file);
    }
    if ($sentence_data ne $old_sentence_data) {
	# Write the annotation file for input to GraphLing classifier
	&write_file($temp_sentence_file, $sentence_data);
	&debug_out(&TL_VERBOSE, "classifying %d sentences in %s: {\n%s}\n",
		   (scalar @sentences), $temp_sentence_file, $sentence_data);

	# Run the relation-classifier over the sentence(s)
	# NOTE: results are placed in the temp-classification subdirectory
	# TODO:
	# - add command-line option for specifying setenv-scripts
	# - remove the temp-classification directory after classification done
	# - prepare training feature tables separate from training since
	#   generally the same and time-consuming to produce via getfmc, etc.
	#   (also leads to excessivelar large trace files during debugging)
	my($options) = "-run_exp -test_annotations=$temp_sentence_file -setenv_scripts='setenv_differentia_refinement.sh'";
	$options .= " -reuse " if ($reuse);
	&perl("setup_wsd_experiment.perl $options ADHOC $classification_dir $relation_dataset");
	}
    else {
	&warning("Using existing relation classification: '$results_file'\n");
    }

    # Get the label(s) for the relation having the highest probability
    my(@relations);
    my(@class_labels_list, @class_probs_list);
    &get_classification_distribution($results_file, \@class_labels_list, \@class_probs_list);
    &assert((scalar @class_probs_list) == (scalar @sentences));

    &assert($#class_probs_list >= 0);
    for (my $i = 0; $i <= $#class_labels_list; $i++) {
	my(@class_labels) = @{$class_labels_list[$i]};
	my(@class_probs) = @{$class_probs_list[$i]};

	push(@relations, &max_label(\@class_labels, \@class_probs, $DEFAULT_RELATION));
    }
    &debug_out(&TL_VERBOSE, "run_relation_classifier() => %s\n", &stringify(\@relations));

    return (@relations);
}


# format_annotation_sentence(sentence, sense_spec, [offset=-1]): Create a SGML
# annotation for the word\#sense item at the specified offset of the sentence.
# NOTE: If the sense is not specified then DUMMY_SENSE (-1) is used.
#
# EX: format_annotation_sentence("how now brown cow", "brown#2") => "how now <wf sense=2>brown<\/wf> cow"
# EX: format_annotation_sentence("how now brown cow", "cow") => "how now brown <wf sense=-1>cow<\/wf>"
# EX: format_annotation_sentence("type is all of the tokens of the same symbol  .", "of", 6) => "type is all of the tokens <wf sense=-1>of</wf> the same symbol .
#
sub format_annotation_sentence {
    &debug_print(&TL_VERBOSE, "format_annotation_sentence(@_)\n");
    my($sentence, $sense_spec, $offset) = @_;
    $offset = -1 if (!defined($offset));
    my($POS, $word, $sense) = &parse_sense_spec($sense_spec);
    $sense = $DUMMY_SENSE if ($sense eq $UNTAGGED_SENSE);
    use vars qw/$POS/;

    my(@sentence_tokens) = &tokenize($sentence);
    $offset = &find_ignoring_case(\@sentence_tokens, $word) if ($offset == -1);
    &assert($offset > -1);
    my($pre_context, $post_context);
    if ($offset == -1) {
	## &warning("Unable to locate target word '$word' in sentence '$sentence'\n");
	$pre_context = $sentence;
	$post_context = "";
    }
    else {
	&assert($sentence_tokens[$offset] eq $word);
	$pre_context = join(" ", @sentence_tokens[0 .. $offset - 1]);
	$post_context = join(" ", @sentence_tokens[$offset + 1 .. $#sentence_tokens]);
    }
    my($test_sentence) = &trim("$pre_context <wf sense=$sense>$word<\/wf> $post_context");
    &debug_print(&TL_VERY_DETAILED, "format_annotation_sentence() => \"$test_sentence\"\n");

    return ($test_sentence);
}

# init_preps(): initialize the list of prepositions
# TODO: read the list from a file
#
my(%prepositions);
#
sub init_prep {
    &assert((scalar @_) == 0);
    &debug_print(&TL_DETAILED, "init_prep(@_)\n");

    my(@preposition_list) = qw/
	aboard about above across after against almost along alongside among
	amongst apart around as at atop away before behind below beneath
	beside beside beyond by down due during for from in inside into like
	near of off on onto out outside over past round since through through
	throughout to toward towards under underneath until unto up upon via
	with within without
	/;

    map { &set_entry(\%prepositions, $_, &TRUE); } @preposition_list;
    return;
}

# is_prep(word): indicate if the word is a preposition
# EX: is_prep("of") => 1
# EX: is_prep("which") => 0
# TODO: use generic function for checking arbitrary part-of-speech
#
sub is_prep {
    my($word) = @_;

    &init_prep() if (!defined($prepositions{"of"}));
    my($OK) = &get_entry(\%prepositions, $word, &FALSE);

    &debug_print(&TL_VERBOSE, "is_prep(@_) => ", &boolean($OK), "\n");

    return ($OK);
}
