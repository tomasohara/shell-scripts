# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# lexrel2network.perl: Originally to convert output from extract_lex_rels.perl
# into a feature vector representation and produce a similarity network 
# suitable for input to Pathfinder (now obsolete). 
#
# Now the main purpose is to produce a Bayesian Network (BN), along the
# lines suggested in [Bruce & Wiebe 95]. This takes a lexical relation
# listing (e.g., either manual annotations or automatically produced by
# extract-differentia.perl).  and produces a BN network from it.
# Optionally (or soley) the explicit WordNet (WN) links can be used to
# produce the network.
#
# If using feature vectors, relation specification (e.g., derived from
# dictionary definitions) are converted into feature vectors by converting
# each relation object into a restricted set of "informative" ancestors in
# WordNet (100 or so synsets). If using a Bayesian Network, the relational
# structure is retained (ie, not flattened), although the link direction
# might be inverted.
#
# WordNet is used to flesh out the relations, to ensure greater connectivity.
# For example. given an implicit relation inferred from the glosses, the 
# links in the network will go from the definitional headword to the target
# word (or sense) and from the target to each of its parents and so forth.
# Alternatively, for each lexical relations (LexRel) derived from each
# definition, the  object is related to the most "informative" ancestor (MIA)
# in WordNet, which is determined by finding the lowest-level ancestor in the
# list of moderate-frequency synsets. This can either be a series of links
# joining the intermediate synsets, or it can be a direct link, which is
# equivalent to using the MIA as a semantic feature.
#
# TODO: 
# - Revise comments to reflect recent changes (and not-so-recent changes).
# - Disambigutate the relation objects (here or in extract_lex_rels.perl)
#   ex: 'body of people' => 'body#2 of people#2'.
# - Minimize the overlap among the synsets used for the features.
# - Create a separate module for the belief network support.
# - Make sure at least the hypernym is always included.
# - Add the hyponyms for the word senses to the network.
# - ** Change "local" declarations (dynamic scoping) to "my" (lexical).
# - Define accessor-style routines for creating assoc. array keys.
# - ** Use n, v, adj, and adv in place of noun, verb, etc. in the node names.
# - Check .sense_map file for root or cross-category part-of-speech changes
#   (e.g., boil => boiling).
# - Generalize from assumed WordNet sense inventory to arbitrary ones.
# - Document the lexrel file format separately.
# - Extend the lexrel file format to allow for synonyms.
# - Make the output format more standard.
# - Decompose collocation nodes to avoid overly large cliques
# - ***** Rework collocation nodes in terms of separate evidence nodes
#   per sense rather than one per word.
# - Add simple depenedency-output format
# - Have separate option for max_senses (instead of overloading max_vars)
# - Rename %synset_frequency to %estimated_synset_frequency to distinguish
#   from SemCor frequencies.
# - *** Test difference with SemCor frequencies rather than estimated ones.
# - Have option to omit use of WordNet 'most information ancestor'
#   when deriving the links based on implicit relations.
#   (See add_relational_dependencies).
# - Make sure WordNet relations have priorioty over LexRels in case of cycles.
# - Have option to ignore word nodes when processing partially sense annotated relations.
# - ** Have option to include lexrels from words mentioned in the sentence.
# - * Likewise, have option for using lexrels of words in other lexrels.
# - * Revise the data for the estimated synset frequencies.
# - have wordnet.perl and/or graphling.perl handle -abbreviate_POS
# - convert &incr_entry usages into routines.
# - Rename %headwords and @head to %source_nodes and @sorted_sorce_nodes.
# - use more of the support in belief_network.perl for BN construction.
# - Make '<basename>.empirical' check off by default (set on in make_network.perl).
# - Figure out problem with incorrectly-typed nodes due to cycle prevention code.
# - Distinguish nodes added due to lexrels from those due to WordNet.
# - Track down entraneous headword entry (eg, 'xyz_1' and 'xyz__1')
#
# NOTES:
# - The global associative array %synset_frequency stores the estimated
#   frequencies for each synset (by category). It is keyed off of a tuple
#   consisting of the category name and synset name (eg, "noun:entity#1").
# - Dependencies created with add_conditional_dependency(head, object, support)
#   create links from object to head (ie, 'object -> head'). In terms of
#   Bayesian Networks, the second argument awlays specifies the parents.
#   Unfortunately, the code is a little unclear about this, especially due
#   to the option for inverting the links (see $bottom_up_links).
# - Support for most informative ancestor (MIA) and estimated synset
#   frequencies inspired by Resnik (1995).
# - See bn_wsd_classify.perl for master script for performing hybrid 
#   classification using statical classifier along with Bayesian network.
#
#
# REFERENCES:
# - Bruce, Rebecca, and Janyce Wiebe (1995), "Towards the Acquisition and
#   Representation of a Broad-Coverage Lexicon, in working notes of
#   AAAI Spring Symposium on Representation and Acquisition of Lexical
#   Knowledge: Polysemy, Ambiguity, and Generalizity, March 27-29,
#   Stanford, CA, pp. 174-179.
#
# - O'Hara, Tom (1999), "Empirical acquisition of finer word-sense distinctions",
#   Unpublished thesis proposal, http://www.cs.nmsu.edu/~tomohara/proposal.
#
# - Resnik, P. (1995), "Disambiguating Noun Groupings with Respect to WordNet
#   Senses", in Proc. WVLC.
#
# - Wiebe, Janyce, Tom O'Hara, and Rebecca Bruce. 1998. Constructing
#   Bayesian networks from WordNetfor word-sense disambiguation:
#   Representational and processing issues. in Proc. Usage of WordNet in
#   Natural Language Processing Systems, pp 23-30. COLING-ACL '98 Workshop,
#   August 16, 1998,University of Montreal.
#
#
# TECH. NOTES:
# - Belief network coding: The conditional probabilities encode the
# influence of the hypernyms and other related words in determining the
# applicability of a given sense. Should mutual exclusion of the senses
# be enforce as well? Or should this be handled by a separate decision
# model (eg, a statistical classifier). Also, in the case of incomplete
# information regarding the influences, which should be quite common,
# should "other" be explicitly encoded? Or should the network just
# deal with what is given.
#
# Copyright (c) 2004 Tom O'Hara and New Mexico State University.
# Freely available via GNU General Public License (see GNU_public_license.txt).
#


# Load in the common module, making sure the script dir is in Perl's lib path
BEGIN {
    my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir);
    require 'common.perl';

    # Load in the other modules
    #
    require 'graphling.perl';
    use vars qw/$GRAPHLING_HOME $default_POS $wn_cache_dir/;
    #
    require 'wordnet.perl';
    #
    require 'belief_network.perl';
    use vars qw/$belief_format %bn_node_declaration/;
    #
    require 'penn_tags.perl';
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
# NOTE: strict refs not used to allow for file handle string references
use strict;
no strict "refs";

use vars qw/$max_vars $inclusion_list $inclusion_file $context_list
    $context_file $single_MIA $single_POS $abbreviate_POS
    $skip_explicit_wordnet_links $add_explicit_wordnet_links
    $full_dependencies $full_wordnet_dependencies $ignore_lexrels
    $clip_branch $default_POS $lexrel_file $DATA_DIR $lexrel_base
    $binary_nodes $empirical_support_file $show_vectors $show_network
    $produce_belief_net $feature_delim $all_hypernyms $feat_freq_min
    $max_term_freq $combine_head_senses $combine_synset_senses
    $include_cat $uniform_frequency $max_support $skip_rels
    $top_down_links $bottom_up_links $embedded_nodes $add_mutex
    $skip_mutex $evidence_threshold $use_evidence_values $logical_zero
    $use_contextual_priors $use_est_freq_priors $use_word_evidence
    $skip_collocation_link $add_collocation_link $include_plain_heads
    $EPSILON/;


# Set defaults for options, which can be overridden from the command-line
# using Perl's -s option (eg, perl -sw this_script.perl -option=value ...)
#

# Main options
#
&init_var(*max_vars, 10);		# max number of conditional variables
&init_var(*inclusion_list, "");		# list of words to build network for
&init_var(*inclusion_file, "");		# file of the same
## &init_var(*context_list, $inclusion_list); # list of words defining context
&init_var(*context_file, $inclusion_file); # file of the same
&init_var(*single_MIA, &FALSE);		# only use one MIA per word
## &init_var(*single_POS, &FALSE);		# are the relations restricted to a POS
&init_var(*abbreviate_POS, &FALSE);	# use 'n' for 'noun', etc. in network
&init_var(*skip_explicit_wordnet_links, &FALSE); # don't use explicit WN rels
&init_var(*add_explicit_wordnet_links,
	  ! $skip_explicit_wordnet_links);	# use explicit WordNet rels

&init_var(*full_dependencies, &TRUE);	# add full relational dependencies
&init_var(*full_wordnet_dependencies, &TRUE);	# add full WN dependencies
&init_var(*ignore_lexrels, &FALSE);	# skip links for implicit Lex Rel's
&init_var(*clip_branch, ! $ignore_lexrels);	# stop WN hierarchy at MIA
## &init_var(*default_POS, "noun");	# default part-of-speech
&init_var(*lexrel_file,	"");		# file w/ lexical relations

&init_var(*DATA_DIR, "${GRAPHLING_HOME}${delim}DATA${delim}LEXICAL_RELATIONS");
&init_var(*lexrel_base,			# base name for lexical relations
	  "${DATA_DIR}${delim}dso_wn_");
&init_var(*binary_nodes, &FALSE);	# single node per word (not per sense)
&init_var(*empirical_support_file, "");	# file name for empirical support

# Miscellaneous options
#
&init_var(*show_vectors, &FALSE);	# show feature-vector representation
&init_var(*show_network, &FALSE);	# show similarity matrix of senses
&init_var(*produce_belief_net, 		# produce belief net (not feature vect)
	  ! $show_vectors);
&init_var(*feature_delim, " ");			# delimiter for feature matrix
&init_var(*all_hypernyms, &TRUE);	# all hypernyms considered for MIA's
&init_var(*feat_freq_min, 1);		# min. references for feature synsets
&init_var(*max_term_freq, &MAXINT);	# maximum frequency for terms in relations
&init_var(*combine_head_senses, &FALSE);   # combine head senses into one
&init_var(*combine_synset_senses, &FALSE); # combine synset senses into one
&init_var(*include_cat, &FALSE);	# include gram. category in word label
&init_var(*uniform_frequency, $ignore_lexrels);	# assume uniform frequency for synsets
&init_var(*max_support, 1.0);		# maximum link support for dependencies
&init_var(*skip_rels, " genus "); 	# lexical relations to ignore
&init_var(*top_down_links, &FALSE);	# use links from higher to lower level
					# concepts (ie., reverse isa)
&init_var(*bottom_up_links, 		# use links from lower levels to higher
	  ! $top_down_links);		# ones (ie, isa links)
&init_var(*embedded_nodes, &FALSE);	# use embedded node for source rather than head
&init_var(*add_mutex, &FALSE);		# add mutual exlusion node for binary sense nodes of same word
&init_var(*skip_mutex, ! $add_mutex);	# skip the sense mutual exclusion?
&init_var(*evidence_threshold, 0.10); 	# nodes w/ 10% of max support
&init_var(*use_evidence_values, &FALSE); # use node values rather than index in evidence spec.
&init_var(*logical_zero, 0.001); 	# the value to use for logical zero
my($logical_one) = 1.0 - $logical_zero;
&init_var(*use_contextual_priors, &FALSE); # prior probs based on contextual support
&init_var(*use_est_freq_priors, &FALSE); # assign priors by estimated synset frequency
&init_var(*use_word_evidence, &FALSE); # the words themselves are treated as evidence
&init_var(*skip_collocation_link, &FALSE);  # skip link for collocation support
&init_var(*add_collocation_link, ! $skip_collocation_link); # add link for collocation support
&init_var(*include_plain_heads, &FALSE); # include node for head w/o part of speech

# Global variable declaration
#
# Relational dependencies
# TODO: add others here to avoid conflicts with other modules
our(%relation_weight);		# default weights for relation types (OBSOLETE)
our(%references);		# reference counts for the nodes
our(%dependency_support);	# key=<head,object>; positive support from object to head
our(%relation_support);		# same for 'implicit relations' (ie, lexrels)
our(%dependency_exclusive);	# key=<head>; true if all links are exclusive
# 
# Bayesian network support
our(%dependencies);		# conditional dependencies for BN
our(%node_declaration);		# whether nodes have been declared
our(%node_value);		# values for a node at given value index
our(%node_type);		# type of BN node or variable (eg, binary)
our(%node_num_values);		# number of values for BN variable
our(%headwords);		# list of relational source nodes
				# NOTE: 'headword' is now misnomer
our(@head);			# sorted list of relation source nodes
our($transitive_closure);	# ref to digraph for BN transitive closure
#
# Old support for feature vectors
our(@feature_synsets);		# list of synset's in the feature vector
our(%synset_vector);		# assoc array defining all the feature vectors
#
#
# Estimated synset frequency
our(%synset_support);		# contextual (freq) support for synsets
our($max_synset_support);	# maximum for %synset_support
our(%synset_frequency);		# estimated synset frequency (ala Resnik 95)
				# note: freq's are percolated upwards
# Miscellaneous
our(@all_categories);		# grammatic categories supported
our($filter_words);		# indicates if words are being filtered
our($add_wordnet_dependency_fn); # function for adding WN-based relations

# If command line arguments are missing, give a usage message.
# note: $#ARGV = (# of arguments) - 1
if (!defined($ARGV[0])) {
    &usage();
}
elsif ($ARGV[0] eq "help") {
    &usage();
}
elsif ($ARGV[0] eq "-") {
    shift @ARGV;
}
elsif ($lexrel_file eq "") {
    $lexrel_file = $ARGV[0];
}
else {
    &warning("Ignoring command-line arg '$ARGV[0]' since -lexrel_file specified\n");
}
# sanity check: all perl command-line switches should have been processed
&assert((join("\t", @ARGV) !~ /\t-.*/));

# Initialize data structures and supporting modules
#
&lexrel_initialize();


# Scan through the lexical relation listing and tabulate all the cases
# with the relations weighted by a scale factor. The result is placed
# in a associative array, keyed by pairs of heads and objects.
#
&mark_target_words();
if ($ignore_lexrels == &FALSE) {
    if ($lexrel_file ne "") {
	&tabulate_lexical_relations($lexrel_file, $default_POS)
	}
    else {
	# Use relation listings for each WN part-of-speech category
	# TODO: use WordNet version indicators in file name
        my(@wn_POS) = ("noun", "verb", "adj", "adv");
        foreach my $POS (@wn_POS) {
            my($file) = "${lexrel_base}${POS}.rels";
    	    if (-e $file) {
		&tabulate_lexical_relations($file, $POS);
        	}
	    else {
	        &debug_print(&TL_DETAILED, "WARNING: couldn't find $file\n");
	    }
        }
    }
}


# Derive a feature vector for each word sense and produce similarity
# network.
#
if ($show_vectors) {

    &derive_feature_vectors();

    # Computes the pairwise similarities for each headword and display the
    # two-dimensional similarity matrix.
    #
    if ($show_network) {
	&compute_similarities();
    }
}


# Derive a (Bayesian) belief network
# NOTE: the relations based on the explicit information in WordNet is
# derived during the belief network construction
# TODO: add better way of specifying basename; also, have option for default
#
if ($produce_belief_net) {
    my(@referenced_synsets);
    my($base) = "lexrel";
    if ($inclusion_file ne "") {
	$base = &basename($inclusion_file, ".roots");
    }
    if ($context_file ne "") {
        $base = &basename($context_file, ".post");
        &tabulate_contextual_support($context_file);
    }
    $transitive_closure = &new_closure();
    &produce_belief_network($base, \@referenced_synsets);
}


clean_up();
&exit();

#----------------------------------------------------------------------------


sub usage {
    select(STDERR);
    my($belief_network_options) = &belief_network_options;
    print <<USAGE_END;

Usage: $script_name [options] [lexical_relation_listing]

options = [-default_POS=noun|verb|adj|adv] [-lexrel_file=file]
          [-noun_max=N] [-noun_min=N] [-noun_data=file] [-verb_max=N] ...
	  [-combine_head_senses=0|1] [-combine_synset_senses=0|1]
	  [-show_vectors=0|1] [-produce_belief_net=0|1] [-max_vars=N]
          $belief_network_options
	  [-inclusion_list="word1 word1 ... wordN"] [-inclusion_file="name"]
	  [-full_dependencies=0|1] [-bottom_up_links=0|1] [-binary_nodes=0|1]
	  [-ignore_lexrels=0|1] [-skip_mutex=0|1] [-logical_zero=N]

Given the output from extract_lex_rels.perl, this script will derive
a (Bayesian) belief network can be produced in a variety of formats
(eg, HUGIN, MSBN, BELIEF).

Alternatively feature vectors can be produced for each word, using
high-level WordNet synset as features. Then a similarity matrix for
the word senses is produced. The matrix output is intended to be used
with Pathfinder to isolate groups of related senses. 

The inclusion list specifies the words (without sense indicators) that
should only be included. Since words are separated by spaces, use
underscores in phrases (eg, -inclusion_list="member social_class").

examples:

$script_name -use_MSBN=1 -inclusion_list="table door implement" -lexrel_file="noun_samples.rels" >&! noun_samples.dsc

$script_name -belief_format=NONAME -inclusion_list="city state" >! city-state.bnet

$script_name -use_HUGIN=1 -inclusion_list="public"  >&! public.net

$script_name -use_MSBN=1 -ignore_lexrels=0 -inclusion_file="dso_ch09_002.roots"  >! dso_ch09_002.dsc

USAGE_END

    &exit();
}


# lexrel_initialize()
#
# Perform various initializations
# TODO: such as ...
#
sub lexrel_initialize {
    &debug_print(&TL_DETAILED, "lexrel_initialize(@_)\n");

    # initialize WordNet access
    $wn_cache_dir = $DATA_DIR unless defined($wn_cache_dir);
    &debug_print(&TL_VERBOSE, "wn_cache_dir=$wn_cache_dir\n");
    &wn_init();

    @all_categories = ("noun", "verb", "adj", "adv");

    # Read in the frequencies by grammatical category. The default is to
    # use the top 100 synsets for each category. These defaults can be 
    # overwritten via command-line parameters (e.g., -noun_max=100)
    # TODO: use WordNet version numbers in the data files
    # 
    my($total_frequency) = 1;
    if ($uniform_frequency == &FALSE) {
	foreach my $cat (@all_categories) {
	    # Determine the category parameters
	    my($freq_file) = &get_parameter("${cat}_data", 
					    "${DATA_DIR}${delim}wn-$cat.freq");
	    my($freq_min) = &get_parameter("${cat}_min", 1);
	    my($freq_max) = &get_parameter("${cat}_max", 500);

	    # read in synset frequencies
	    &debug_print(&TL_VERBOSE, "c=$cat file=$freq_file $freq_min to $freq_max\n");
	    $total_frequency += &read_synset_frequencies($cat, $freq_file, 
							 $freq_min, $freq_max);
	}
    }
    &debug_print(&TL_VERBOSE, "total synset frequency: $total_frequency\n");

    # Read in the term frequencies (ie, wordform frequencies)
    if ($max_term_freq < &MAXINT) {
	&init_term_freq();
    }

    # Initialize weights for scaling relation strength
    # NOTE: this is only used for the obsolete manual annotation support
    #
    %relation_weight = ("genus", 0.75,
			"spec", 0.5,
			"attr", 0.25,
			"object", 0.2);
    $max_synset_support = 0.0001;

    # If a inclusion list is specified, then word-filtering is in effect.
    # Convert from space-delimited list to tab delimited list, and make sure
    # there are tabs at the start and end to facilitate searching.
    #
    $filter_words = &FALSE;
    if ($inclusion_file ne "") {
	$inclusion_list = &read_file($inclusion_file);
    }
    if ($inclusion_list ne "") {
	$filter_words = &TRUE;
	$inclusion_list = "\t$inclusion_list\t";
    }
    $inclusion_list =~ s/\s+/\t/g;
    &debug_print(&TL_DETAILED, "filter_words=$filter_words inclusion_list='$inclusion_list'\n");

#     # Similarly, if there is a list of words defining the context.
#     #
#     @context_list = ();
#     if ($context_file ne "") {
# 	$context_list = &read_file($context_file);
#     }
#     if ($context_list ne "") {
#         ## $context_list = "\t$context_list\t";
#         ## $context_list =~ s/\s+/\t/g;
#         @context_list = split(/\s+/, $context_list);
#     }

    # Set up function overrides
    $add_wordnet_dependency_fn = \&add_bottom_up_wordnet_dependency;
    if ($bottom_up_links == &FALSE) {
	$add_wordnet_dependency_fn = \&add_top_down_wordnet_dependency;
    }

    # Debug traces to avoid Perl warnings
    $node_declaration{"_dummy_node_"} = 0;
    &debug_out(&TL_DETAILED, "node_declaration keys=(%s)\n", keys(%node_declaration));
    

    return;
}


# clean_up()
#
# Clean-up things
#
sub clean_up {

    &wn_cleanup();			# cleanup WordNet access

    return;
}


# tabulate_lexical_relations(relation_file, default_POS)
# 
# Scan through the lexical relation listing and tabulate all the cases
# with the relations weighted by a scale factor. The result is placed
# in a associative array, keyed by pairs of heads and objects.
#
# The heads are normally the sense-specified word (eg, order#11).  But
# it can be just the word itself, in which case the senses are combined
# together to form a single vector. This can be used for comparisons
# against word-similarity approaches that don't differentiate at the
# sense level.
#
# When senses are combined, special handling is needed for words in
# the same synset. Otherwise, this exact similarity will dominate the
# similarities with other words, as with table ~ board. One way would be
# to just remove the "extra" senses:
#    perl -pn -e "s/: /\t/;" dso.post | sort -u +1 | sort > ! dso.upost
# But this eliminates a valid source of similarity.
#
# NOTE:
# - The lexical relation file is assumed to list the relations for each
#   sense of the target words from WordNet.
#
# EXAMPLE:
#     input relations:
#         beagle -> has-part -> ear
#         ear -> has-attr -> floppy
#
#     non-embedded output dependencies:
#         P(beagle | ear)
#         P(beagle | floppy)
#
#     embedded output dependencies:
#         P(beagle | beagle-ear)
#         P(beagle-ear | beagle-ear-floppy, ear)
#         P(beagle-ear-floppy | floppy)
#
# TODO:
# - Handle relations specified via examples.
# - Clean up access to global %headwords assoc array.
# - Generalize to non-numeric sense numbers.
# - Specify format expected including misc lines like 'example'.
# - Show sample input (relations for some headword).
#
sub tabulate_lexical_relations {
    my($file, $default_POS) = @_;
    &debug_print(&TL_VERBOSE, "tabulate_lexical_relations(@_)\n");
    &debug_print(&TL_DETAILED, "Tabulating lexical relation weights in $file ...\n");

    my($head) = "";		# headword against which relations apply
    my($POS) = $default_POS;	# headword part of speech
    my($include) = &TRUE;	# should the headword be included in network
    my($num_heads) = 0;		# number of headwords in lexrel file
    my($num_filtered) = 0;	# number of filtered headwords (not in inclusion list)
    my(@source_nodes);		# stack of active relational source nodes

    open (LEXRELS, "<$file")
	|| die "ERROR: Unable to open lexical relations file $file ($!)\n";

    while (<LEXRELS>) {
	&dump_line($_, &TL_VERY_VERBOSE);
	chop;
	s/^\s*\#.*//;		# remove comments
	s/^\s*example\s*$//;	# remove "example" indicator
	next if (/^\s*$/);	# ignore blank lines

	# head has form "[<POS>:]<word>[#<sense_num>]"
        #     12          34        5  6
	# TODO: handle symbolic sense labels (eg, via parse_sense)
	if (/^(([a-z]+):)?(([a-z-]+)(\#([0-9]+))?):/) {
	    my($full_POS) = defined($2) ? &convert_POS($2) : $default_POS;
	    my($POS) = $full_POS;
	    $POS = &wn_letter_for_POS($POS) if ($abbreviate_POS);
	    $head = $3;		
	    my($word) = $4;
	    if ($combine_head_senses) {
		$head = $word;
	    }
	    $num_heads++;

	    # The final head specification includes the part-of-speech
	    $head = "$POS:$head";

	    # Determine whether the word should be filtered out
	    $include = &TRUE;
	    if ($filter_words 
		&& (index($inclusion_list, "\t${full_POS}:$word\t") == -1)) {
		&debug_print(&TL_VERY_VERBOSE, "filtering out $head\n");
		$num_filtered++;
		$include = &FALSE;
	    }
	    else {
		# TODO: add routine for doing this
		&incr_entry(\%headwords, $head, 1);
	    }

	    @source_nodes = ($head);
	}
	# target has form <TAB><REL><sp><TARGET>[<sp>(<WEIGTH>)]
	# $n's:  $1   $2                      $3            $5
	elsif (/^(\t+)([-_:a-z0-9]+\#?\S+?)\s+([^\(]*)(\s*\((\S+)\))?/i) {
	    my($level) = length($1);
	    my($relation) = $2;
	    my($objects) = &to_lower($3);
	    my($weight) = defined($5) || "";

	    # Ignore the relation information if this sense is filtered out
	    if (($include == &FALSE) || $ignore_lexrels) {
		&debug_print(&TL_VERY_VERBOSE, "filtered data: rel='$relation' objs='$objects'\n");
		next;
	    }

	    # Use the headword as the source by default. If embedded nodes are used,
	    # they create a dummy source node based on the nodes in the path from
	    # the head to use most recent target at a lower depth.
	    # NOTE: This helps to avoid overly dense Bayesian networks, in particular
	    # problems with nodes in the underlying tree of cliques being too large 
	    # for evaluation (see Hugin log for diagnostics on this).
	    # TODO: have option to just use most recent target at a lower depth
	    my($source) = $head;
	    if ($embedded_nodes) {
		&assert($level <= ((scalar @source_nodes) + 1));
		my($num_extra) = max(0, ((scalar @source_nodes) - $level));
		for (my $i = 0; $i < $num_extra; $i++) {
		    pop(@source_nodes) unless ($#source_nodes == 0);
		}

		# Use concantenation of nodes on path unless length is 1
		if ((scalar @source_nodes) > 1) {
		    $source = join('_', @source_nodes);

		    # Make sure the internal POS tags are not extractable
		    # and assign POS dummy tag to entire token
		    # TODO: work out a cleaner way of doing this
		    $source =~ s/[\#:]/_/g;
		    $source = "none:$source";
		}
	    }

	    # Skip over relations in list of those to ignore
	    if ($skip_rels =~ /$relation /) {
	        next;
	    }

	    if ($weight eq "") {
		$weight = &get_relation_weight($relation, $level);
	    }

	    # Add relationships involving the source with each of the objects.
	    # NOTE: multiple objects mainly used in manual annotations.
	    $objects =~ s/(( or )|( and )|(; *)|(  +))/;/g;
	    &debug_print(&TL_VERBOSE, "s=$source l=$level r='$relation' o='$objects' w=$weight\n");
	    my($last_object) = "n/a";
	    foreach my $object (split(/;/, $objects)) {
		$object = &trim($object);
		if ($object ne "n/a") {
		    # Check for old-style object category (eg, pursuit/noun)
		    # TODO: remove this obsolete option (-include_cat)
		    if ($include_cat && ($object =~ /(\S+)\/(\S+)/)) {
			$object = "$1:$2";
		    }
		    # Make sure the full category label is used
		    if ($object =~ /^(\S+):(\S+)/ && (length($1) < 4)) {
			my($cat, $sense) = ($1, $2);
			$cat = &convert_POS($cat);
			$cat = &wn_letter_for_POS($cat) if ($abbreviate_POS);
			$object = "$cat:$sense";
		    }
		    $last_object = $object;

		    # Add the relationship unless object occurs too much in corpus
		    if (&get_term_freq($object) <= $max_term_freq) {
			# NOTE: head = [POS:]word[#sense]
			if ($embedded_nodes) {
			    # Create intermediate dummy node with special POS 'none'
			    # add relation from source to dummy and then to object
			    # TODO: streamline dummy-node-token construction code
			    my($target) = $object;
			    $target =~ s/[\#:]/_/g;
			    my($dummy) = "${source}_${target}";
			    if ($source !~ /^none:/) {
				$dummy =~ s/[\#:]/_/g;
				$dummy = "none:$dummy";
			    }

			    &add_relationship($source, $dummy, 1.0);
			    &add_relationship($dummy, $object, $weight);
			}
			else {
			    &add_relationship($source, $object, $weight);
			}
		    }
		    else {
			&debug_print(&TL_DETAILED, "WARNING: Ignoring high-frequency object '$object'\n");

		    }
		}
	    }

	    # Add last object to list of potential source nodes
	    push(@source_nodes, $last_object);
	}
	else {
	    &debug_print(&TL_DETAILED, "WARNING: ignoring lexrel line: $_\n");
	}
    }

    # Cleanup
    close(LEXRELS);
    &assert($num_heads > 0);
    &assert($num_filtered < $num_heads);

    return;
}


# add_relationship(source, object, weight): make note of the relationship from source
# to object with the given weight. 
# NOTES:
# - these are lated added to the network by tabulate_conditional_probabilities
# - uses global hash \%relation_support
#
sub add_relationship {
    my($source, $object, $weight) = @_;
    &debug_print(&TL_VERBOSE, "add_relationship(@_)\n");

    &incr_entry(\%relation_support, "$source|$object", $weight);
}


# mark_target_words(): Makes sure the target words from the inclusion file 
# are marked as the headwords (or "headsenses") to be disambiguated
#
# NOTE:
# - This assumes that WordNet serves as the target sense inventory
# - This uses the global %headwords associative array
#
sub mark_target_words {
    &debug_print(&TL_DETAILED, "mark_target_words(@_)\n");

    # Make sure the usage count for each sense node is non-zero
    my($target, $i);
    foreach $target (&tokenize($inclusion_list)) {
	## &incr_entry(\%headwords, $target) unless ($target eq "");
	my($POS, $head) = &parse_POS($target);
	$POS = &wn_letter_for_POS($POS) if ($abbreviate_POS);
	my($num_senses) = &wn_get_num_senses($head, $POS);
	for (my $i = 1; $i <= $num_senses; $i++) {
	    &incr_entry(\%headwords, "$POS:${head}#$i");
	}
    }

    return;
}


# derive_feature_vectors()
#
# Derive a feature vector for each word sense, where the features are
# the high-level synsets corresponding to the objects from the sense's
# lexical relations. The vectors are displayed both in raw form and in
# a spare representation.
#
# TODO:
# - clean-up the access to the global associate arrays:
#   %synset_vector, %references, %relation_support, %headwords
#
sub derive_feature_vectors {
    &debug_print(&TL_DETAILED, "Deriving feature vectors ...\n");
    my($head, $object);

    # For each object of the relations determined from the definition,
    # finds the "most informative ancestor" and increments the support
    # for this head-synset pair by the relation weight.
    # NOTE: The grammatical categories are checked in turn until an 
    # anecestor is located.
    #
    foreach my $head_object (sort(keys(%relation_support))) {
	($head, $object) = split(/\|/, $head_object);
	my(@categories) = @all_categories;
	my($cat);
	if ($object =~ /:/) {
	    ($cat, $object) = split(/:/, $object);
	    @categories = ($cat);
	}
	&incr_entry(\%headwords, $head, 1);
	foreach $cat (@categories) {
	    my($num) = 0;
	    my(@MIA) = &most_informative_ancestors($cat, $object);
	    if ($#MIA < 0) {
		next;
	    }
	    foreach my $object_synset (@MIA) {
		&incr_entry(\%synset_vector, "$head|$object_synset", 
			    $relation_support{$head_object});
		&incr_entry(\%references, $object_synset, 1);
		$num++;
	    }

	    last if ($num > 0);
	}
    }

    # Determine the feature synsets by pruning the high-level synset
    # features that haven't been referenced often.
    #
    &determine_main_synsets(\@feature_synsets);

    # Print the feature vectors: first in raw form; then as a sparse vector
    #
    printf "Feature vectors:\n";
    printf "\n";
    printf "KEY: %s\n", join(" ", @feature_synsets);
    printf "\n";
    @head = sort(keys(%headwords));
    foreach $head (@head) {
	my(@features) = &get_feature_vector($head);
	print "$head: @features\n";
    }
    print "\n";
    foreach $head (@head) {
	my(@features) = &get_feature_vector($head);
	print "$head: { ";
	for (my $i = 0; $i <= $#features; $i++) {
	    ## print "$i~$features[$i] " if ($features[$i] > 0);
	    print "$feature_synsets[$i]~$features[$i] " if ($features[$i] > 0);
	}
	print "}\n";
    }
    print "\n";


    return;
}



# determine_main_synsets(array_ref): Determine the feature synsets by pruning
# the high-level synset features that haven't been referenced often. The result
# is returned in the array given by the first argument.
# NOTES:
# - USes global associative arrays %synset_frequency and %references
#
sub determine_main_synsets {
    my($main_synsets_ref) = @_;
    my($num, $synset, $last_word);
    &debug_print(&TL_DETAILED, "determine_main_synsets(@_)\n");

    # Check each synset in sorted order for references
    @$main_synsets_ref = ();
    $num = 0;
    $last_word = "";
    foreach $synset (sort(keys(%synset_frequency))) {
	my($synset_node) = &make_node_name($synset);

	# Remove the sense indicator if the senses are being combined
	# TODO: see if this should modify $synset_node
	if ($combine_synset_senses) {
	    my($word, $sense_num); 
	    ($word, $sense_num) = &parse_sense($synset);

	    # Skip the word if same as the last (note sort above)
	    if ($word eq $last_word) {
		next;
	    }
	    $last_word = $word;
	}

	# Include nodes that are referenced frequenctly enough (by default once)
	my($num_refs) = &get_entry(\%references, $synset_node, 0);
	if ($num_refs >= $feat_freq_min) {
	    $$main_synsets_ref[$num] = $synset;
	    &debug_print(&TL_VERBOSE, "fs[$num]=$synset\trefs=$num_refs\n");
	    $num++;
	}
    }

    return;
}


# compute_similarities()
#
# Computes the pairwise similarities for each headword (usually at the sense
# level). The result is a two-dimensional similarity matrix that is displayed
# followed by the (nontrivial) min and max case for each head.
#
# NOTE: uses global @head list
#
sub compute_similarities {
    my($i, $j, $similarity, @min_sim, @min_head, @max_sim, @max_head);

    # Print the matrix header showing the column (and row) words
    #
    for ($i = 0; $i <= $#head; $i++) {
	printf "$i~$head[$i] ";
    }
    print "\n";
    print "\t";
    # This time just show the position labels for each column
    for ($i = 0; $i <= $#head; $i++) {
	printf "%4d${feature_delim}", $i;
    }
    print "\n";
    &init_var(*EPSILON, "0.001");

    # Output the contents of the array as a two-dimensional distance matrix,
    # where distance is the inverse of similarity (ie, 1.0 - similarity).
    # NOTE: The array is printed after collecting the data to allow for tracing.
    #
    my(%sim);
    my($net);
    for ($i = 0; $i <= $#head; $i++) {
	printf "$i\t";
	$min_sim[$i] = $MAXINT; $min_head[$i] = "n/a";
	$max_sim[$i] = -$MAXINT; $max_head[$i] = "n/a";
	for ($j = 0; $j <= $#head; $j++) {
	    if ($i <= $j) {
		$similarity = &feature_similarity($head[$i], $head[$j]);
		$sim{$i}{$j} = $similarity;
	    }
	    else {
		$similarity = $sim{$j}{$i};
	    }
	    if ($similarity < $EPSILON) {
		$net = sprintf " -  ${feature_delim}";
	    }
	    else {
		$net = sprintf "%4.2f${feature_delim}", (1.00 - $similarity);
	    }

	    # Update the minimum and maximum similarity for the word
	    # Ignore the trivial cases of no similarity are exact similarity
	    if (($similarity > 0) && ($similarity < 1)) {
		if ($similarity < $min_sim[$i]) {
		    $min_sim[$i] = $similarity;
		    $min_head[$i] = $head[$j];
		}
		if ($similarity > $max_sim[$i]) {
		    $max_sim[$i] = $similarity;
		    $max_head[$i] = $head[$j];
		}
	    }
	}
	$net = sprintf "\n";
    }
    print "%s\n", $net;

    # Display the minimum and maximum similarity pairs for each word
    #
    printf "Min/Max Similarity pairs by headword\n";
    for ($i = 0; $i <= $#head; $i++) {
	printf "%s: min=(%s, %.2f) max=(%s, %.2f)\n", 
	        $head[$i], 
	        $min_head[$i], (($min_sim[$i] < $MAXINT) ? $min_sim[$i] : 0.0),
 	        $max_head[$i], (($max_sim[$i] > 0) ? $max_sim[$i] : 0.0);
    }
    print "\n";
}


# get_relation_weight(relation, level): determines the weight to assign
# the specified relation type at the given level of indirection (1 for direct).
# This will scale the relation weight by 0.9 for each level, including the
# direct relations (thus 0.9 is the highest weight). If the relation is 
# unknown, then a default 0f 0.2 is assigned to the weight
#
# NOTES:
# - only used for manually-annotated relations (e.g., dso_wn_noun.rels)
# - uses global relation_weight associative array
# TODO:
# - parameterize the weight defaults; clean up interface
#
sub get_relation_weight {
    my($relation, $level) = @_;
    my($weight) = 0.2;

    &assert(defined($relation_weight{"genus"}));
    if (defined($relation_weight{$relation})) {
	$weight = $relation_weight{$relation};
    }
    else {
	&warning("No relation weight defined for '$relation'\n");
    }
    if ($level > 1) {
	$weight *= (0.9 ** $level);
    }
    &debug_print(&TL_VERY_DETAILED, "get_relation_weight(@_) => $weight\n");

    return ($weight);
}


# most_informative_ancestors(cat, word, [use_single_MIA=1])
#
# Returns the ancestor synsets for the word that provides the most
# "information", determined by finding the first one in a list of
# moderately-occurring synsets.
#
# One ancestor per sense is returned. However, if the single_MIA
# option is set, only the first such one is returned. This is the one
# most likely to be appropriate given the frequency-based sense ordering.
#
# NOTE: This relies upon WordNet's ordering of senses by frequency.
#
# TODO:
# - Use the estimated synset frequency as a way of pruning
#   uninformative synsets (a la information content).
# - ??? Return a list of the most informative synset by sense
# EX-TODO: most_informative_ancestors("noun:beagle#1") => "noun:dog#1"
#
sub most_informative_ancestors {
    my($cat, $word, $use_single_MIA) = @_;
    $use_single_MIA = $single_MIA unless defined($single_MIA);
    my($ancestors, $ancestor_list, $ancestor_set, $ancestor, $depth);
    my(@MIA) = ();
    my($num) = 0;

    # Get ancestors, not including the word's synsets
    $ancestors = &wn_get_ancestors($word, $cat, &FALSE, $all_hypernyms);
    $ancestors = &to_lower($ancestors);
  get_ancestors:
    foreach $ancestor_list (split(/\n/, $ancestors)) {
      check_sense_ancestors:
	foreach $ancestor_set (split(/\t/, $ancestor_list)) {
	    ($depth, $ancestor_set) = split(/: /, $ancestor_set);
	    foreach $ancestor (split(/ /, $ancestor_set)) {
		my($synset_id) = &make_node_name("${cat}:${ancestor}");
		if ($uniform_frequency) {
                    # If using uniform frequency, fake a frequency entry
                    &incr_entry(\%synset_frequency, $synset_id, 1);
                    }
		
		if (&get_entry(\%synset_frequency, $synset_id, 0) > 0) {
		    $MIA[$num++] = $synset_id;
		    last get_ancestors if ($single_MIA);
		    last check_sense_ancestors;
		}
	    }
	}
    }
    &debug_print(&TL_VERBOSE, "most_informative_ancestors(@_) => @MIA\n");

    return (@MIA);
}


# read_synset_frequencies(category, corpora, start, end)
# 
# Read in the synset frequencies that were determined by word counts for
# the words subsumed by the synset (all words for descendant synsets).
# The start parameter indicates the position of the first synset in the
# file to include, in order to exclude high-frequency synsets. Likewise,
# the end parameter indicates the position of the last synset to include.
# This assumes that the file is sorted in descending order.
#
# NOTE: the synsets included from the list define the feature vector
# for words
#
# TODO:
# - prune uninformative synsets from the list
# - put in wordnet.perl & reconcile with read_frequencies in extra.perl
#
sub read_synset_frequencies {
    my($cat, $corpora, $start, $end) = @_;
    &debug_print(&TL_DETAILED, "read_synset_frequencies(@_)\n");
    my($total_frequency) = 0;

    &debug_print(&TL_DETAILED, "Reading corpora frequencies ($corpora) ...\n");
    open(SYNSET_FREQ, "<$corpora")
	|| die "ERROR: Unable to open synset frequency file: $corpora ($!)\n";
	
    for (my $i = 1; ($i <= $end) && ($_ = <SYNSET_FREQ>); $i++) {
	chop;
	if (/^\#/) {		# ignore comments
	    next;
	}
	if ($i >= $start) {
	    my($count, $synset) = split('\t', $_);
	    my($synset_node) = &make_node_name("${cat}:${synset}");
	    &set_entry(\%synset_frequency, $synset_node, $count);
	    $total_frequency += $count;
	}
    }
    close(SYNSET_FREQ);

    return ($total_frequency);
}



# feature_similarity(head1, head2)
#
# Calculate the similarity between the two words by calculating the
# dot product of their feature vectors. (Is this just the normalized
# inner product as defined similarly in [Hearst 97] "TextTiling" in CL 23:1)
#
#    dot_product = V1 * V2 / sqrt(|V1| + |V2|)
#
#    where V1 * V2 = sum(V1_i * V2_i)
#
# NOTE: the synsets in the frequency table define the feature vector
# for the words
#
# TODO: make sure the weights are normalized beforehand
#
sub feature_similarity {
    my($head1, $head2) = @_;
    my($similarity) = 0.0;
    my($sum_squares1, $sum_squares2) = (0.0, 0.0);
    my(@weight1, @weight2);

    @weight1 = &get_feature_vector($head1);
    @weight2 = &get_feature_vector($head2);
    my($i);
    for ($i = 0; $i <= $#weight1; $i++) {
 	$sum_squares1 += ($weight1[$i] * $weight1[$i]);
 	$sum_squares2 += ($weight2[$i] * $weight2[$i]);
 	$similarity += ($weight1[$i] * $weight2[$i]);
    }
    my($unnormalized) = $similarity;
    if (($sum_squares1 > 0) && ($sum_squares2 > 0)) {
	$similarity /= (sqrt($sum_squares1 * $sum_squares2));
    }
    &debug_out(&TL_VERBOSE, "feature_similarity(%s, %s) => %.2f (%.2f)\n", 
	       $head1, $head2, $similarity, $unnormalized);

    return ($similarity);
}


# get_feature_vector(headword)
#
# Returns the feature vector for the headword in a standard list format.
# (The vector is stored internally distributed throughout an associative
#  array.)
#
# globals variables:
#    @feature_synsets:	list of synset's in the feature vector
#    %synset_vector:	assoc array defining all the feature vectors
#
sub get_feature_vector {
    my($head) = @_;
    my(@features) = ();
    my($feature_synset);

    my($i) = 0;
    foreach $feature_synset (@feature_synsets) {
	$features[$i++] = &get_entry(\%synset_vector, 
				     "$head|$feature_synset", 0);
    }

    return (@features);
}


# get_parameter(var_name, default)
#
# Returns the value for the command-line parameter, specified as follows
#       perl -s script_name.perl -var=value 
#
# If a value hasn't been specified on the command line, then the default
# value is used.
#
# example: &get_parameter("${cat}_data", "$cat.freq");
# TODO: put in common.perl & reconcile with init_var
# 
sub get_parameter {
    my($var_name, $default) = @_;
    my($value);
    &debug_print(&TL_VERY_DETAILED, "get_parameter(@_)\n");

    
    $value = eval "\$$var_name";
    $value = $default if (!defined($value));

    return ($value);
}


#------------------------------------------------------------------------------


# tabulate_contextual_support(context_words)
#
# Given a list of words representing the current context, determine support
# for the high-level synsets. This is done by finding the most informative
# ancectors for each word and incrementing thier support.
#
# TODO: Use part-of-speech tagging to determine the category.
#       See if this can be combined with similar code for tabulating the
#       relation support.
#

sub tabulate_contextual_support {
    my($context_file) = @_;
    my(@context_list, @tag_list);
    &debug_print(&TL_DETAILED, "tabulate_contextual_support(@_)\n");

    # Read in the Penn Treebank tags (converted to traditional ones)
    &read_pos_tags($context_file, \@context_list, \@tag_list, &TRUE);

    # Find the high-level synsets for each word and increments their
    # support
    for (my $i = 0; $i <= $#context_list; $i++) {
	# Skip miscellaneous parts-of-speech (eg, prepositions)
	if ($tag_list[$i] !~ /^((noun)|(verb)|(adjective)|(adverb))/i) {
	    next;
	}
	my($object) = $context_list[$i];

	# Check all the categories, but give preference to the one
	# tagged by the part-of-speech tagger.
        my(@categories) = ($tag_list[$i], @all_categories);
        foreach my $cat (@categories) {

	    # Find the "informative" high-level synsets for the word
	    # (one per sense).
	    my(@MIA) = &most_informative_ancestors($cat, $object, &FALSE);
	    if ($#MIA < 0) {
		next;
	    }

	    # Determine the number of senses for the object
	    # TODO: order the senses by prior probability (e.g., roughly sense # in WN)
	    my($num_senses) = &wn_get_num_senses($object, $cat);
	    $num_senses = &max($num_senses, $max_vars);

	    # Determine the support that each MIA gets
	    my($base_support) = 1 / $num_senses;
	    my($synset_support) = $base_support / (1 + $#MIA);
	    my($synset);
	    my($num) = 0;

	    # Increment the support for each of the informative ancestors
	    foreach my $MIA_synset (@MIA) {
		my($synset) = $MIA_synset;
		if ($combine_synset_senses) {
		    my($sense_num);
		    ($synset, $sense_num) = &parse_sense($synset);
		}
		if ($synset ne "") {
		    $num++;

		    my($node) = &make_node_name($synset);
		    &incr_entry(\%synset_support, $node, $synset_support);
		    if ($synset_support{$node} > $max_synset_support) {
			$max_synset_support = $synset_support{$node};
		    }
		}
	    }

	    last;		# no need to check other categories
	}

    }

    return;
}


#------------------------------------------------------------------------------

# produce_belief_network(base_filename, referenced_synsets_list_ref)
#
# Produce a bayesian belief network, in a variety of formats including
# BELIEF1.2 and MSBN-style (aka BNIF for Belief Network Interchange Format).
# See belief_network.perl for other formats supported.
#
# The basic idea is to encode the lexical relations as conditional
# probabilities. To do this, the relations are reversed in effect.
# The main complication comes in combining the weights from links
# coming into the same head within the usual probabilistic contrainst
# (eg, sum(P_i) = 1.0 if P_i partition U).
# NOTE: This includes extraction of links based on the explicit WordNet info
# TODO: separate out the WordNet relation extraction for modularity
#

sub produce_belief_network {
    my($base, $referenced_synsets_ref) = @_;
    my(%headwords_proper);
    &debug_print(&TL_DETAILED, "produce_belief_network(@_)\n");

    # First tabulate the conditional probabilities by combining the relations
    # having the same target.
    # ex: P(small | beagle) & P(small | chihuahua) => P(small | beagle, chihuahua)
    &tabulate_conditional_probabilities($base, \%headwords_proper);

    # Determine the list of referenced synsets, which forms the set of nodes
    &determine_main_synsets($referenced_synsets_ref);

    # Print the network representations
    my(@referenced_synsets_list) = keys(%references);
    &output_belief_network($base, \@referenced_synsets_list);

    # Create the file specifying values for (evidence) nodes
    &output_evidence_list($base, \@referenced_synsets_list, \%headwords_proper);

    return;
}


# tabulate_conditional_probabilities(file_base, headwords_proper)
#
# Derive the conditional probabilities that define the network 
# connectivity. These are based both on the explicit lexical relations
# encoded in WordNet and on the implicit ones extracted from the
# dictionary definitions.
# NOTES:
# - uses globals @head, %headwords, and %relation_support
# TODO:
# - separate out the extraction of the WordNet relations to make more modular
#
sub tabulate_conditional_probabilities {
    my($base, $headwords_proper_ref) = @_;
    &debug_print(&TL_DETAILED, "tabulate_conditional_probabilities(@_)\n");

    # For each object of the relations determined from the definition,
    # add a conditional dependency of the head on the object. Also,
    # add dependencies for each of the hyponym synsets and whatever
    # other significant relations can be found in WordNet.
    #
    # NOTE: %relation_support is empty if implicit relations are ignoreed
    #
    # TODO:
    # - Have an option to just add what WordNet provides, as a baseline
    #   belief network.
    # - Have an option to add the most informative ancestor along
    #   each synset branch, adjusting weights appropriately.
    #
    &trace_assoc_array(\%relation_support);
    my($head_object);
    foreach $head_object (sort(keys(%relation_support))) {
	&debug_print(&TL_VERY_DETAILED, "processing head_object '$head_object'\n");
	my($head, $object) = split(/\|/, $head_object);
	my($head_POS, $head_word) = &parse_POS($head);
	my($support) = $relation_support{$head_object};

	if ($full_dependencies) {
	    &add_full_relational_dependencies($head, $object, $support);
	}
	else {
	    &add_relational_dependencies($head, $object, $support);
	}
	if ($head_POS ne "unknown") {
	    &incr_entry(\%headwords, $head);
	}
    }

    # Sort the list of headwords
    #
    @head = sort(keys(%headwords));
    &debug_print(&TL_VERY_VERBOSE, "head=@head\n");

    # Add the dependencies derived from the explicit WordNet links
    # TODO: place in separate subroutine
    #
    if ($add_explicit_wordnet_links) {
	foreach my $headword (@head) {
	    my($POS, $head) = &parse_POS($headword);
	    $POS = &wn_letter_for_POS($POS) if ($abbreviate_POS);
	    my($word) = &parse_sense($head);
	    # TODO: map the head using .sense_map if not in WordNet
	    &incr_entry($headwords_proper_ref, "$POS:$word");

	    # Recursively add links to all ancestors in WordNet
	    if ($full_wordnet_dependencies) {
		&add_full_wordnet_dependencies($POS, $head);
	    }

	    # Or, just add direct links to most-informative ancestors
	    else {
		# TODO: separate as add_informative_wordnet_dependencies
		my(@MIA) = &most_informative_ancestors($POS, $head);
		my($object_synset);
		foreach $object_synset (@MIA) {
		    # TODO: use add_wordnet_dependency
		    if ($bottom_up_links) {
			&add_conditional_dependency($object_synset, "$POS:$head",
						    $logical_one);
		    }
		    else {
			my($num_children) = &wn_get_num_children($object_synset);
			# TODO: use add_top_down_wordnet_dependency for this
			&add_conditional_dependency("$POS:$head", $object_synset,
						    1 / $num_children);
		    }
		}
	    }

	    # Add an "equality" dependency from the plain head (i.e., no
	    # category label) to the full version. This is used to circumvent
	    # cycles, which might occur when a non-hypernym relation points
	    # back to one of the descendants of the headword.
	    # NOTE: This leads to a minor problem during evaluation, since
	    # default categories are used for heads without part of speech.
	    # TODO: let cycle-detection handle problems
	    if ($include_plain_heads
		&& ($ignore_lexrels == &FALSE)) {
		&add_conditional_dependency($head, "$POS:$head", $logical_one);
	    }

	    # Add exclusive-or dependency from the head to the "senseless" word
	    if ($bottom_up_links && ($skip_mutex == &FALSE)) {
		my($word, $sense_num) = &parse_sense($head);
		&add_exclusive_dependency("word_$word", "$POS:${head}");
	    }
	}
    }

    # Add a dependency from the head to a dummy collocational link
    if ($add_collocation_link) {
	my(@heads_proper) = sort(keys(%$headwords_proper_ref));
	&add_empirical_support($base, \@heads_proper);
    }

    return;
}


# add_empirical_support(file_base, head_words_proper_list_ref)
#
# Create a "virtual evidence" node (see [Pearl 88]) for each of the
# headwords. The distribution is taken from two associative arrays,
# derived from the empirical support file (see read_empirical_support).
# The result is added to the network in the form of a node labelled
# coll:<POS>:<head> with links from the sense nodes (or a single link
# to the multi-valued word node).
#
sub add_empirical_support {
    my($base, $heads_proper_ref) = @_;
    my(%empirical_support, %empirical_support_ids);
    &debug_print(&TL_DETAILED, "add_empirical_support(@_)\n");
    &debug_print(&TL_VERBOSE, "heads_proper=(@$heads_proper_ref)\n");

    # Read in the support for the senses of each headword
    &read_empirical_support($base, \%empirical_support, \%empirical_support_ids);

    # Add virtual evidence nodes for each head
    my($head);
    foreach my $headword (@$heads_proper_ref) {
	my($POS, $head) = &parse_POS($headword);
	$POS = &wn_letter_for_POS($POS) if ($abbreviate_POS);
	# Get the support for this headword and convert to an array.
	# Then make sure this agrees in size with the number of senses.
	my(@support) = &tokenize(&get_entry(\%empirical_support, "$POS:$head", ""));
	my(@senses) = &tokenize(&get_entry(\%empirical_support_ids, "$POS:$head", ""));
	my($num_senses) = scalar @senses;
	&assert(($POS eq "unknown") || ($num_senses > 0));
	my($default_support) = (($num_senses > 0) ? (1 / $num_senses) 
				   : $logical_one);
	&debug_print(&TL_VERBOSE, "pos=$POS h=$head #supp=(@support) senses=(@senses)\n");
	## &assert(($#support < 0) || (($#support + 1) == $num_senses));

	# Add the support for each sense, using the default if not specified
	# TODO: weed out WordNet dependencies (e.g., integral sense numbers)
	for (my $i = 0; $i < $num_senses; $i++) {
	    my($sense_num) = defined($senses[$i]) ? $senses[$i]: "0";
	    my($sense_support) = $support[$i] || $default_support;
	    if ($binary_nodes) {
		&add_exclusive_dependency("coll:$POS:${head}",
					  "$POS:${head}#${sense_num}",
					  $sense_support);
					  
	    }
	    else {
		&add_conditional_dependency("coll:$POS:${head}", 
					    "$POS:${head}#${sense_num}",
					    $sense_support);
	    }
	}
    }

    return;
}


# read_empirical_support(base_file_name, support_hash_ref, ids_hash_ref)
# 
# Read in the support for the senses of each headword. The result is
# stored in an associative array keyed off of the headword (e.g.,
# noun:cook). A separate associate array is used for the sense labels
# (e.g. <noun:cook> => "1 1.2 6 1a 1b 2 3 4 5").
#
# Example input:
#
# # word	sense	probability
# adjective:boil#508262	0.000
# adjective:boil#507063	0.998
# ...
# adjective:boil#2	0.000
# noun:lemon#1	1.000
# noun:lemon#2	0.000
# noun:lemon#3	0.000
# noun:sugar#1	0.996
# noun:sugar#0	0.000
# ...
# noun:sugar#516291	0.000
#
# 
# Sample Result:
#
# emp-support: {
# 	adjective:boil:  0.000 0.998 0.000 0.002 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000
# 	noun:lemon:  1.000 0.000 0.000
# 	noun:sugar:  0.996 0.000 0.004 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000 0.000
# 	}
# support-ids: {
# 	adjective:boil:  508262 507063 1 507068 507064 507067 506361 507066 520605 0 508425 508406 520604 508434 508263 508786 508713 2
# 	noun:lemon:  1 2 3
# 	noun:sugar:  1 0 2 516278 516115 516279 516217 516119 516259 516304 516270 516291
# 	}
# 
# TODO: put into graphling.perl (or new bayes-net.perl)
#
sub read_empirical_support {
    &debug_print(&TL_DETAILED, "read_empirical_support(@_): empirical_support_file=$empirical_support_file\n");
    my($base, $empirical_support_ref, $support_ids_ref) = @_;
    my($file) = $empirical_support_file;
    $file = "$base.empirical" if ($file eq "");

    if (!open(SUPPORT, "<$file")) {
	&warning("Can't open empirical data file '$file'\n");
	return;
    }
    while (<SUPPORT>) {
	&debug_print(&TL_VERY_DETAILED, "emp-support: $_");
	s/^\s*\#.*//;		# strip comments
	next if (/^\s*$/);	# skip blank lines
	my($headword, @rest) = split;
	my($POS, $head) = &parse_POS($headword);
	my($head_proper, $sense) = &parse_sense($head);
	$POS = &wn_letter_for_POS($POS) if ($abbreviate_POS);
	&append_entry($empirical_support_ref, "$POS:$head_proper", " @rest");
	&append_entry($support_ids_ref, "$POS:$head_proper", " $sense");
    }
    close(SUPPORT);
    &trace_assoc_array($empirical_support_ref, &TL_DETAILED, "emp-support");
    &trace_assoc_array($support_ids_ref, &TL_DETAILED, "support-ids");

    return;
}


# add_relational_dependencies(headword, object)
#
# Add conditional dependencies to reflect the support the object
# provides for the head. This can include multiple dependencies if
# several high-level synsets of the objects are to be added to 
# account for ambiguity.
#
# NOTES:
#    The grammatical categories are checked in turn until an 
#    anecestor is located.
#
#    As a simpification, the conditional dependencies added directly
#    mirror the features w/ nonzero weights for the head.
#
# TODO:
# - Make the conditional dependency go from the head to the object
#   word instead of directly to the most informative ancestor (MIA). 
#   Then include a dependency from the object to the MIA.
# - Have option to include branches for all parts of speech.
# - don't attempt to add WN dependencies for embedded nodes
#
sub add_relational_dependencies {
    my($head, $object, $rel_support) = @_;
    &debug_print(&TL_VERBOSE, "add_relational_dependencies(@_)\n");

    my(@categories) = @all_categories;
    my($cat);
    my($single_cat) = &FALSE;
    if ($object =~ /:/) {
	($cat, $object) = split(/:/, $object);
	@categories = ($cat);
	$single_cat = $TRUE;
    }
    foreach $cat (@categories) {
	my($POS) = $cat;
	$POS = &wn_letter_for_POS($POS) if ($abbreviate_POS);
	my(@MIA) = &most_informative_ancestors($POS, $object);
	if (($#MIA < 0) && (! $single_cat)) {
	    next;
	}
	my($synset_support) = ($#MIA > 0) ? 1 / (1 + $#MIA) : 1;
	my($scaled_support) = $rel_support * $synset_support;
	my($synset);
	my($num_synsets) = 0;
	my($num_head_senses) = &wn_get_num_senses($head, $POS);
	my($num_object_senses) = &wn_get_num_senses($object, $POS);
	$num_head_senses = &max($num_head_senses, $max_vars);
	$num_object_senses = &max($num_object_senses, $max_vars);

	foreach my $MIA_synset (@MIA) {
	    my($ancestor) = $MIA_synset;
	    if ($combine_synset_senses) {
		my($sense_num);
		($ancestor, $sense_num) = &parse_sense($ancestor);
	    }
	    if ($ancestor ne "") {
		$num_synsets++;
		if ($bottom_up_links) {
		    # Add 'logical' link from the object to the MIA with weight
		    # inversely proportional to number of senses for object
		    # TODO: handle problem w/ too many dep's -> MIA
		    &add_conditional_dependency($ancestor, "$POS:$object", 
						1 / $num_object_senses);
		}
		else {
		    # Add link from MIA w/ support based on original relation
		    # support scaled inversely by number of MIA's.
		    # TODO: make weight based on num descendants for MIA
		    &add_conditional_dependency("$POS:$object", $ancestor, 
						$scaled_support);
		}
	    }
	}

	if (($num_synsets > 0) || ($single_cat)) {
	    # Add the relation from the category-less head (eg, "implement_1")
	    # to the object spec including the category (eg, "noun_tool").
	    #
	    # NOTE: The relation source omits the category as an indirect
	    # way of avoiding cycles in the WordNet-based hierarchy. This
	    # works since all implicit links start at hypothesis nodes
	    # and go to hypernym nodes, whereas the explicit links always
	    # go to synset nodes.
	    #
	    # TODO: revise comments to reflect object -> head links
	    if ($bottom_up_links) {
		# Add link from the head to relational object with weight
		# given by the predefinied relational support value
		&add_conditional_dependency("$POS:$object", $head, $rel_support);
	    }
	    else {
		my($support) = $rel_support;
		$support /= $num_object_senses if ($num_object_senses > 0);

		# Add link from the relational object to the head with weight
		# inversely proportional to number of senses for the head
		&add_conditional_dependency($head, "$POS:$object", $support);
	    }
	    last;
	}
    }

    return;
}


# add_full_relation_dependencies(headword, object, support)
#
# Like add_relation_dependencies but also including the full WordNet
# isa hierarchy for the object (rather than a link from object TO its
# MIA).
#
# TODO:
# - don't attempt to add WN dependencies for embedded nodes
# - use helper routine to reduce redundance with add_relation_dependencies
#
sub add_full_relational_dependencies {
    my($head, $object, $rel_support) = @_;
    &debug_print(&TL_VERBOSE, "add_full_relational_dependencies(@_)\n");
    my($ancestors, $ancestor_list, $ancestor_set, $ancestor);

    # Determine which categories to check. Normally, the head (and object)
    # specify the categories. But all are checked if none specified.
    #
    my(@categories) = @all_categories;
    my($cat);
    my($single_cat) = &FALSE;
    if ($object =~ /:/) {
 	($cat, $object) = split(/:/, $object);
 	@categories = ($cat);
	$single_cat = $TRUE;
    }

    # Try each of the categories until the first POS/head pair succeeds
    # TODO: have option to include each applicable POS category
    #
    foreach $cat (@categories) {
	my($POS) = $cat;
	$POS = &wn_letter_for_POS($POS) if ($abbreviate_POS);
	my($num_object_senses) = &wn_get_num_senses($object, $POS);

	# Try to add relations from the object (eg, "noun_tool") to its 
	# synsets (eg, "noun_tool_1", ... "noun_tool_4"). 
	#
	if ((&add_full_wordnet_dependencies($POS, "$POS:$object") > 0)
	    || $single_cat) {

	    # Add the relation from the category-less head (eg, "implement_1")
	    # to the object spec including the category (eg, "noun_tool").
	    #
	    # NOTE: The relation source omits the category as an indirect
	    # way of avoiding cycles in the WordNet-based hierarchy. This
	    # works since all implicit links start at hypothesis nodes
	    # and go to homonym nodes, whereas the explicit links always
	    # go to synset nodes.
	    # TODO: include the head cat and let cycle-detection handle this
	    #
	    if ($bottom_up_links) {
		# Add link from the head to relational object with weight
		# given by the predefinied relational support value
		&add_conditional_dependency("$POS:$object", $head, $rel_support);
	    }
	    else {
		my($support) = $rel_support;
		$support /= $num_object_senses if ($num_object_senses > 0);

		# Add link from the relational object to the head with weight
		# inversely proportional to number of senses for the head
		&add_conditional_dependency($head, "$POS:$object", $support);
	    }
	    last;
	}
    }

    return;
}


# add_wordnet_dependencies(headword_category, head, wordnet_cat)
# 
# Add a strong dependency to the head's hypernym, scaled by the
# number of sibling synsets for the head.
#
# TODO: add dependencies for other explicit WordNet links
#
# NOTE: The headword category is the category of the source node,
#       where as the Wordnet category is the one to use for the
#       WordNet lookups. These will normally be the same.
#
sub add_wordnet_dependencies {
    my($head_cat, $head, $cat) = @_;
    &debug_print(&TL_VERBOSE, "add_wordnet_dependencies(@_)\n");

    my($ancestors, $ancestor_list, $ancestor_set, $depth);
    $ancestors = &wn_get_ancestors($head, $cat);
    $ancestors = &to_lower($ancestors);
    if ($ancestors ne "") {
	foreach $ancestor_list (split(/\n/, $ancestors)) {
	    foreach $ancestor_set (split(/\t/, $ancestor_list)) {
		($depth, $ancestor_set) = split(/: /, $ancestor_set);
		if ($depth == 1) {
		    my(@ancestors) = split(/\s+/, $ancestor_set);
		    # note: indirect call via reference
		    &$add_wordnet_dependency_fn($head_cat, $head, $cat, 
						$ancestors[0]);
		}
	    }
	}
    }

    return;
}



# add_bottom_up_wordnet_dependency(headword_category, head, wordnet_cat, ancestor)
#
# Add a conditional dependency with the link from the headword category to
# the ancestor. The probabilites will be based on implication (ie, logical 1).
#
sub add_bottom_up_wordnet_dependency {
    my($head_cat, $head, $cat, $ancestor) = @_;
    &debug_print(&TL_VERBOSE, "add_bottom_up_wordnet_dependency(@_)\n");

    &add_conditional_dependency("${cat}:$ancestor", 
				"${head_cat}:${head}", 
				$logical_one);

    return;
}



# add_top_down_wordnet_dependency(headword_category, head, wordnet_cat, ancestor)
#
# Add a conditional dependency with the link from the ancestor to the
# headword category. The link weight will be based on a high value (1.0)
# scaled by a factor reflecting the number of children for the ancestor.
# TODO: use 1/#siblings as the support rather than max(.5, (1 - .05 * #siblings))
#
sub add_top_down_wordnet_dependency {
    my($head_cat, $head, $cat, $ancestor) = @_;
    &debug_print(&TL_VERBOSE, "add_top_down_wordnet_dependency(@_)\n");

    my(@siblings) = split(/\t/, &wn_get_children($ancestor, $cat));
    &assert($#siblings >= 0);
    my($support) = &max(0.5, $logical_one - (0.05 * $#siblings));
    &add_conditional_dependency("${head_cat}:${head}", 
				"${cat}:$ancestor", 
				$support);

    return;
}



# add_full_wordnet_dependencies(headword_category, headword)
#
# Add in dependencies to reproduce the full WordNet ISA hierarchy for the
# headword. Branches for each sense of the word will be included, unless
# a sense indicator is given (eg, "table#3").
#
# TODO: Exclude the uninformative synsets at the top of the hierarchies
#       (eg, entity#1, act#2), so that the evidence nodes are more suitable
#       for encoding context.
#
# NOTE: The headword_category is the default category for the source node.
#       It is overridden if head spec. gives the category (eg, "n:dog").
#
sub add_full_wordnet_dependencies {
    my($head_cat, $head) = @_;
    &debug_print(&TL_VERBOSE, "add_full_wordnet_dependencies(@_)\n");
    my($cat, $ancestors, $ancestor_list, $ancestor_set, $ancestor, $depth);

    # By default, all categories (N, V, Adj, Adv) are checked. But the
    # headword could have a category indicator (eg, "noun:tableland")
    #
    my($num) = 0;
    my(@categories) = @all_categories;
    if ($head =~ /:/) {
	($head_cat, $head) = split(/:/, $head);
	@categories = ($head_cat);
    }

    # Try to add WordNet dependencies, checking each of the four categories
    # in order until a WordNet link is found.
    #
    foreach $cat (@categories) {
	my($POS) = $cat;
	$POS = &wn_letter_for_POS($POS) if ($abbreviate_POS);

	$ancestors = &wn_get_ancestors($head, $POS);
	$ancestors = &to_lower($ancestors);
	if ($ancestors ne "") {

	    # Add a dependency from the head to each of its parent
	    # in each sense. Normally, there will be just one parent,
	    # but multiple senses might be common (to support ambiguous
	    # lexical relations).
	    #
	    &add_wordnet_dependencies($head_cat, $head, $POS);

	    # Add dependencies from each of the ancestors to their
	    # repective parents. Note the complexity of the triply-nested
	    # loop is required to properly handle both multiple senses
	    # and the possibility of multiple hypernyms for a synset.
	    # TODO: make this explanation clear
	    #
	    my(@ancestor_list) = split(/\n/, $ancestors);
	    foreach $ancestor_list (@ancestor_list) {
	      current_branch:
		foreach $ancestor_set (split(/\t/, $ancestor_list)) {
		    ($depth, $ancestor_set) = split(/: /, $ancestor_set);
		    foreach $ancestor (split(/ /, $ancestor_set)) {

			# Don't go futher on this branch if an informative
			# ancestor has been reached.
			if ($clip_branch 
			    && &informative_synset($ancestor, $POS)) {
			    last current_branch;
			}
			# Add dependency from the ancestor to its parent
			#
			## &add_wordnet_dependencies($head_cat, $ancestor, $POS);
			&add_wordnet_dependencies($POS, $ancestor, $POS);
			$num++;
		    }
		}
	    }
	    last;
	}
    }

    return ($num);
}


# informative_synset(synset, cat)
# 
# This function Indicates if the synset is informative in the sense of being
# on the list of synsets that have moderate frequency in a corpus.
# TODO: use synset_spec rather than synset_id (confusion w/ offset IDs)
#
sub informative_synset {
    my($synset, $cat) = @_;
    my($synset_id) = &make_node_name("${cat}:${synset}");
    my($ok) = &FALSE;

    if (&get_entry(\%synset_frequency, $synset_id, 0) > 0) {
	$ok = &TRUE;
    }

    return ($ok);
}


# add_exclusive_dependency(headword, object_synset, [support])
# NOTE:                        node <- parent [for Bayesian network]
#
# Add an exlusive-or dependency to the headword from the synset
# (eg, to word_dog from dog_1). This creates a strong positive
# dependency between the nodes and forces the link probabilities
# to reflect the exclusive-or condition.
# NOTE: All links must be exclusive if any are.
#
sub add_exclusive_dependency {
    my($head, $object, $support) = @_;
    my($node) = &make_node_name($head);
    $support = $logical_one if (!defined($support));

    &add_conditional_dependency($head, $object, $support);
    &set_entry(\%dependency_exclusive, $node, &TRUE);
}


# make_node_name(word)
#
# Ensure that the name for the node is compatible both with the
# belief software to be used and with internal conventions used
# for association lists (eg, '|' separates components of names).
#
# This just replaces special characters with underscores.
# TODO: address all special characters
# TODO: account for name clashes
#
sub make_node_name {
    my($word) = @_;

    # Apply fix-up for sloppy category prefixing
    # TODO: fix the problem at the source
    if ($word =~ s/::/:/g) {
	&warning("Fixed sloppy category prefixing in '@_'\n");
    }

    ## $word =~ s/\#/__/;		# use two underscores for sense divider
    $word =~ s/[:\#\-\~\. ]/_/g;	# use single underscore for other punctuation
    &debug_print(&TL_VERY_VERBOSE, "make_node_name(@_) => $word\n");

    return ($word);
}


# add_conditional_dependency(headword, object_word, relation_support)
# NOTE:                        node <- parent [for Bayesian network]
#
# Add a conditional dependency from the headword to the object word (or 
# synset), having the specified support weight. This just adds the
# object and the support to lists keyed off of the headword.
# Returns true if the link was added OK.
#
# The dependency is added to the list keyed off of the head. Each dependency
# is a tuple of the form <head_value, object, object_value> stored in a
# tab-delimited string in an association list keyed off of the head. A
# separate association list is used to store the numeric support value 
# for the dependency to facilitate updates. This is keyed off a tuple of
# the form <head, head_value, object, object_value>.
#
# TODO:
# - Remove assumption that head is a word-sense specification
# (e.g., for collocational nodes like coll:noun:lemon).
# - Clarify how the link direction is interpreted (ie, object -> head).
#
sub add_conditional_dependency {
    my($head, $object, $support) = @_;
    &debug_print(&TL_VERBOSE, "add_conditional_dependency(@_)\n");

    # Make sure the support uses epsilon's instead of 0 or 1
    $support = $logical_zero if ($support <= 0.0);
    $support = $logical_one if ($support >= 1.0);

    # If all nodes are binary, use the old method
    if ($binary_nodes == &TRUE) {
	return (&add_binary_conditional_dependency($head, $object, $support));
    }

    # Derive the value for each of the head and object by taking the
    # specified sense number or using "True" (1) if none present.
    #
    # ex: "noun:ability#2" => node="noun:ability" value=2
    #     "word_student" => node="word_student" value=1
    #
    my($head_value, $object_value);
    ($head, $head_value) = &parse_sense($head);
    $head_value = 1 if ($head_value eq "0");
    ($object, $object_value) = &parse_sense($object);

    # Standardize the form of the node names to ensure compatibility
    # with the belief software
    # TODO: make sure us
    # Make sure the head and object names only have characters that are
    # compatible with the belief software
    $head = &make_node_name($head);
    $object = &make_node_name($object);

    # Ignore circular dependencies
    if ($head eq $object) {
	&debug_print(&TL_DETAILED, "*** WARNING: Ignoring reflexive dependency for $head\n");
	return (&FALSE);
    }

    # Check for cycles in the network (BN's must be DAG's)
    # NOTE: checks for reverse transitive link (ie, object to head)
    if (&closure_has_link($transitive_closure, $head, $object)) {
	&warning("Skipping link $object -> $head to avoid a cycle\n");
	return (&FALSE);
    }

    # Update the list of encountered values for each variable
    # TODO: implement list routines for this
    &append_entry(\%node_value, "$head", " $head_value ");
    &append_entry(\%node_value, "$object", " $object_value ");

    &incr_entry(\%synset_frequency, $head, 0);
    &incr_entry(\%synset_frequency, $object, 0);
    &incr_entry(\%references, $head, 1);
    &incr_entry(\%references, $object, 1);

    # Add it to the list unless already there
    # TODO: only ignore subsequent support for hypernym links
    my($dependency_spec) = "${head_value}|${object}|${object_value}";
    my($dependencies) = &get_entry(\%dependencies, $head, "");
    if (index($dependencies, "\t${dependency_spec}\t") == -1) {
        &append_entry(\%dependencies, $head, "\t$dependency_spec\t");
    }
    else {
	$support = 0;
    }

    # Set (or update) the support for the dependency link
    &incr_entry(\%dependency_support, "$head|$dependency_spec", $support);

    # Revise the transitive closure (used for cycle detection)
    # TODO: replace global $transitive_closure with a field of a new BN object
    &revise_closure($transitive_closure, $object, $head);

    return (&TRUE);
}

# add_binary_conditional_dependency(headword, object_word, relation_support)
# NOTE:                                node <- parent [for Bayesian network]
#
# This is an alternative version of add_conditional_dependency that uses binary
# nodes per sense rather than creating a multiple-valued node for the word.
# Returns true if the link was added OK.
#
sub add_binary_conditional_dependency {
    my($head, $object, $support) = @_;
    &debug_print(&TL_VERBOSE, "add_binary_conditional_dependency(@_)\n");

    # Standardize the form of the node names to ensure compatibility
    # with the belief software
    $head = &make_node_name($head);
    $object = &make_node_name($object);

    # Ignore circular dependencies
    if ($head eq $object) {
	&debug_print(&TL_DETAILED, "*** WARNING: Ignoring reflexive dependency for $head\n");
	return (&FALSE);
    }

    # Check for cycles in the network (BN's must be DAG's)
    # NOTE: checks for reverse transitive link (ie, object to head)
    if (&closure_has_link($transitive_closure, $head, $object)) {
	&warning("Skipping link $object -> $head to avoid a cycle\n");
	return (&FALSE);
    }

    # Increment the reference counts for the head and objecy
    &incr_entry(\%references, $head, 1);
    &incr_entry(\%references, $object, 1);
    # HACK: make sure both appear in the synset frequency listing
    &incr_entry(\%synset_frequency, $head, 0);
    &incr_entry(\%synset_frequency, $object, 0);

    # Add the object to the dependencies list for the head unless already there.
    # Also, set or increment the associated support (link weight).
    if (!defined($dependencies{$head})) {
	$dependencies{$head} = "\t";
    }
    if (index($dependencies{$head}, "\t$object\t") == -1) {
	$dependencies{$head} .= "$object\t";
    }
    else {
	## TODO: only ignore subsequent support for hypernym links
	$support = 0;
    }
    &incr_entry(\%dependency_support, "$head|$object", $support);

    # Revise the transitive closure (used for cycle detection)
    # TODO: replace global $transitive_closure with a field of a new BN object
    &revise_closure($transitive_closure, $object, $head);

    return (&TRUE);
}


# new_closure(closure_assoc_ref)
#
# Returns a new transitive closure object. Currently this just returns
# an anonymous associative array.
#
# TODO: place closure code in extra.perl
#
sub new_closure {
    return ({});
}


# revise_closure(closure_assoc_ref, source, target)
#
# Revise the transitive closure for the graph by adding the given
# link and propagating it through the graph.
# TODO: create test suite for this
#
sub revise_closure {
    my($closure_ref, $source, $target) = @_;
    &debug_print(&TL_VERY_DETAILED, "revise_closure(@_)\n");

    # Make sure an entry exists for the source node (and the target as well).
    # That is, create null adjacency lists for either if nonexistent.
    if (!defined($$closure_ref{$source})) {
	$$closure_ref{$source} = {};
    }
    if (!defined($$closure_ref{$target})) {
	$$closure_ref{$target} = {};
    }

    # Make note that the target is accessible from the source
    my($source_links_ref) = $$closure_ref{$source};
    $$source_links_ref{$target} = &TRUE;
    &debug_print(&TL_VERY_VERBOSE, "adding direct link $source -> $target\n");

    # Make note that all nodes accessible from the target are accessible from 
    # the source.
    my($target_links_ref) = $$closure_ref{$target};
    foreach my $node_from_target (keys(%$target_links_ref)) {
	# Add source -> node_from_target link
	$$source_links_ref{$node_from_target} = &TRUE;
	&debug_print(&TL_VERY_VERBOSE, "adding transitive source link $source -> $node_from_target\n");

    }

    # Make sure all nodes that can reach the source can reach the target
    # TODO: includes nodes accessible from the target as well
    foreach my $node_in_graph (keys(%$closure_ref)) {
	if (defined($$closure_ref{$node_in_graph}{$source})) {
	    &debug_print(&TL_VERY_VERBOSE, "adding transitive other link $node_in_graph -> $target\n");
	    $$closure_ref{$node_in_graph}{$target} = &TRUE;
	}
    }

    &debug_out(&TL_VERY_DETAILED, "nodes accessible from $source: %s\n",
	       join(" ", keys(%$source_links_ref)));
}


# closure_has_link(closure_assoc_ref, source, target)
#
# Determines whether the transitive closure for the graph includes the given
# link. The closure has already been computed, so this just checks whether
# the graph includes a link from the source to the target (ie, whether
# the target node is on the adjacency list for the source node).
# TODO: add test cases for this
#
sub closure_has_link {
    my($closure_ref, $source, $target) = @_;
    &debug_print(&TL_VERY_DETAILED, "closure_has_link(@_)\n");
    my($source_links_ref) = $$closure_ref{$source};

    my($is_linked) = (defined($source_links_ref) 
		      && defined($$source_links_ref{$target}));
    return ($is_linked);
}


# determine_node_type(word)
#
# Determines the node type for the word by checking the list of dependencies
# (<head_sense, object, object_sense>) associated with the word.
#
# ex: "table" w/ {"1:calendar:3", "2:desk:1" "5:board:6" "4:adj_flat:1"}
#     => "0 1 2 3 4 5"
# (i.e., table#1 => calendar#3, etc.)
#
# NOTES:
#    The node type is either a space-delimited list of ordered values or
#    a predefined type name (eg, binary). If a particular sense for a word
#    has no associated dependencies, that value is omitted.
#
#    This determines information needed later when the conditional dependencies
#    are output. Therefore this is stored in global assoc. arrays:
#        %node_type %node_num_values %node_value
#
sub determine_node_type {
    my($head) = @_;
    my($type) = "binary";
    my($num_values) = 2;	# needs 'local' for assertion

    # Use the cached value if available
    if (defined($node_type{$head})) {
	return ($node_type{$head});
    }

    # Sort the list of values and format as a space-delimited list
    # NOTE: A default value of '0' will be included
    if ($binary_nodes == &FALSE) {
	my($node) = &make_node_name($head);
	my($node_values) = &get_entry(\%node_value, $node, "");
	my($values) = " 0 ";
	foreach my $value (&tokenize($node_values)) {
	    $values .= " $value " unless ($values =~ / $value /);
	}
	my(@type) = sort(&tokenize($values));
	$type = join(" ", @type);
	$num_values = (1 + $#type);

	# Make a record of the values for convenient access later
	# TODO: name @type to @sorted_values
	my($i);
	for ($i = 0; $i < $num_values; $i++) {
	    ## &append_entry(\%node_value, "$node|$i", "$type[$i] ");
	    &set_entry(\%node_value, "$node|$i", "$type[$i]");
	}
    }
    $node_type{$head} = $type;
    $node_num_values{$head} = $num_values;
    &debug_print(&TL_VERY_DETAILED, "determine_node_type(@_) => $type (num=$num_values)\n");
    &assert($num_values >= 2);

    return ($type);
}


# strip_senses(word_list_ref)
#
# Strip the sense indicators from each word in the list.
# The result is returned as a new list
# TODO:
# - show example
# - re-implement in terms of map
#
sub strip_senses {
    my($word_list_ref) = @_;
    my(@new_list);
    my($word);

    foreach $word (@$word_list_ref) {
	my($new_word) = &parse_sense($word);
	push (@new_list, $new_word);
    }

    return (@new_list);
}


# output_belief_network(base-file, synset_list_ref)
#
# Produce a bayesian belief network consisting entirely of multiple-valued
# nodes. These include one for each headword from the lexical relations and 
# one for each synset headword that was referenced directly or indirectly.
# Each node has a value for each of its senses along with a value for the
# default case of not applicable; however, senses not required for any
# of the lexical relations are omitted to cut down on the network size.
#
# Currently, three Bayesian network formats are supported: HUGIN, MSBN, 
# and BELIEF. (See belief_network.perl for details.)
#
# NOTES:
# - Uses global associative arrays %head, %dependencies, and %node_declaration
#
# TODO:
# - reconcile as much as possible with output_binary_belief_network
#
sub output_belief_network {
    my($base, $referenced_synsets_ref) = @_;
    my($head, $synset);
    my(@head_list) = @head;	# TODO: just use original list
    my(@temp_head_list);
    &debug_print(&TL_DETAILED, "output_belief_network(@_)\n");

    # Trace the information on nodes
    &trace_array(\@head_list, &TL_VERBOSE, "head_list");
    &trace_array($referenced_synsets_ref, &TL_VERBOSE, "referenced_synsets");
    &trace_associative_array(\%dependencies, &TL_VERBOSE, "dependencies");

    # Use the old version if binary nodes are desired
    if ($binary_nodes) {
	return (&output_binary_belief_network(@_));
    }

    # Print the belief network header
    &print_header("lexrel2network");

    # Print the declarations section, which describes the nodes that
    # make up the network.
    # TODO: add function for printing comments to the BN file

    # First declare the hypothesis nodes (heads from the definitions)
    # NOTE: each head word in the list usually includes a sense indicator
    # TODO: Change the head list reference to a list w/o sense indicators
    ## &print_bn_comment("Declarations of hypothesis nodes");
    @temp_head_list = &strip_senses(\@head_list);
    &assert($#temp_head_list == $#head_list);
    foreach $head (@temp_head_list) {
	## my($headnode) = ($bottom_up_links ? "${default_POS}_${head}" : $head);
	my($headnode) = $head;
	my($node_type) = &determine_node_type($headnode);
	&print_node_declaration($headnode, "hypothesis", $node_type);
    }

    # Next declare the other nodes (those referenced by the heads)
    # NOTE: each synset word in the list includes a sense indicator
    # Change the synset list reference to a list w/o sense indicators
    ## &print_bn_comment("Declarations of other nodes");
    my(@temp_referenced_synsets) = &strip_senses($referenced_synsets_ref);
    foreach $synset (@temp_referenced_synsets) {
	my($node) = $synset;
	my($node_type) = &determine_node_type($node);
	&print_node_declaration($node, "other", $node_type);
    }

    # Print the node relationships (i.e., the conditional probabilities)
    my(@dependents) = sort(keys(%dependencies));
    foreach $head (@dependents) {
	&print_cond_probability($head);
    }

    # Print the prior probabilities for the high-level synsets
    # NOTE: This only works for top-down links, in which case since the 
    # high-level synsets have no incoming links (i.e., require priors).
    # Also, see tabulate_contextual_support for weight calculation.
    #
    open(SUPPORT, ">$base.support");
    &display_weights("SUPPORT", \%synset_support, "synset contextual support");
    close(SUPPORT);
    my(@independents) = &difference(\@temp_referenced_synsets, \@dependents);
    foreach my $node (@independents) {

	# First, a uniform distribution for each sense of the word
	my($num_values) = &get_entry(\%node_num_values, $node, 2);
	my($default_probability) = (1 / $num_values);
	my(@probability) = ($default_probability) x $num_values;

	# Next, for each sense of the node, determine whether there is
	# contextual support, adjusting the weight as applicable.
	my($i);
	my($total) = $probability[0];
	for ($i = 1; $i < $num_values; $i++) {
	    my($synset) = sprintf "%s_%s", $node, $node_value{"$node|$i"};
	    if ($use_contextual_priors) {
		# Set probability in terms of relative % of maximum support
		my($support) = &get_entry(\%synset_support, $synset);
		$probability[$i] = max($support / $max_synset_support,
				       $logical_zero);
	    }
	    elsif ($use_est_freq_priors) {
		# Note that the probability is specified in terms of the
		# frequency. These will be normalized in the next step.
		my($synset_id) = &make_node_name($synset);
		my($support) = &get_entry(\%synset_frequency, $synset, 1);
		$probability[$i] = $support;
	    }
	    $total += $probability[$i];
	}

	# Then, the probabilities are rescaled if necessary
	# NOTE: This time, the default entry's initial value is not considered
	#       as part of the new total
	my($new_total) = 0.0;
	for ($i = 1; $i < $num_values; $i++) {
	    $probability[$i] /= $total;
	    $new_total += $probability[$i];
	}
	$probability[0] = (1.0 - $new_total);

	# Finally, the prior probability specification is output
	## &print_prior_probability($node, @probability);
	&print_prior_probability($node, "@probability");
    }

    # Print the belief network trailer
    &print_trailer("lexrel2network");

    # Do some sanity checks:
    # Make sure all the nodes declarated have been referenced
    # TODO: fix this to use the right associative array in belief_network.perl
    foreach my $node_name (sort(keys(%node_declaration))) {
	if ($node_declaration{$node_name} != 0) {
	    &warning("Declaration/usage problem for %s (ref=%d)\n",
		     $node_name, $node_declaration{$node_name});
	}
    }

    return;
}


# output_binary_belief_network(synset_list)
#
# Produce a bayesian belief network consisting entirely of binary-valued
# nodes that indicates whether the corresponding sense applies or not.
#
# Currently, three Bayesian network formats are supported: HUGIN, MSBN, 
# and BELIEF. (See belief_network.perl for details.)
#
# NOTES:
# - Uses global associative arrays %head, %dependencies, and %node_declaration
#
# TODO:
# - reconcile with output_belief_network
#
sub output_binary_belief_network {
    my($base, $referenced_synsets_ref) = @_;
    my($head, $synset);
    my(@head_list) = @head;		# TODO: just use original list
    my(@temp_head_list);
    &debug_print(&TL_DETAILED, "output_binary_belief_network(@_)\n");

    # Print the belief network header
    &print_header("lexrel2network");

    # Print the declarations section, which describes the nodes that
    # make up the network.
    # TODO: add function for printing comments to the BN file

    # First declare the hypothesis nodes (heads from the definitions)
    # NOTE: each head word in the list usually includes a sense indicator
    ## &print_bn_comment("Declarations of hypothesis nodes");
    @temp_head_list = &intersection(\@head_list, $referenced_synsets_ref);
    foreach $head (@temp_head_list) {
	## my($headnode) = ($bottom_up_links ? "${default_POS}_${head}" : $head);
	my($headnode) = $head;
	my($node_type) = &determine_node_type($headnode);
	&print_node_declaration($headnode, "hypothesis", $node_type);
    }

    # Next declare the other nodes (those referenced by the heads)
    # NOTE: each synset word in the list includes a sense indicator
    ## &print_bn_comment("Declarations of other nodes");
    foreach $synset (@$referenced_synsets_ref) {
	my($node) = $synset;
	my($node_type) = &determine_node_type($node);
	&print_node_declaration($node, "other", $node_type);
    }

    # Print the node relationships (i.e., the conditional probabilities)
    my(@dependents) = sort(keys(%dependencies));
    foreach $head (@dependents) {
	&print_cond_probability($head);
    }

    # Print the prior probabilities for the high-level synsets
    # NOTE: This only works for top-down links, becuase the high-level
    # synsets then have no incoming links (i.e., require priors).
    # Also, see tabulate_contextual_support for weight calculation.
    #
    open(SUPPORT, ">$base.support");
    &display_weights("SUPPORT", \%synset_support, "synset contextual support");
    close(SUPPORT);
    my(@temp_referenced_synsets) = @$referenced_synsets_ref;
    ## foreach $synset (@temp_referenced_synsets) {
    ## 	$synset = &make_node_name($synset);
    ## }
    my(@independents) = &difference(\@temp_referenced_synsets, \@dependents);
    foreach $synset (@independents) {
	my($node) = &make_node_name($synset);

	# The synset is given a low probability by default
	my($num_values) = &get_entry(\%node_num_values, $node, 2);
	my($default) = $logical_zero;
	my(@probability) = (1.0 - $default, $default);

	# But if it received contextual support, that defines the probability
	my($support) = &get_entry(\%synset_support, $node, 0);
	if ($use_contextual_priors && ($support > 0)) {
	    $probability[1] = $support / $max_synset_support;
	    $probability[0] = (1.0 - $probability[1]);
	    }

	# Finally, the prior probability specification is output
	&print_prior_probability($node, "@probability");
    }

    # Print the belief network trailer
    &print_trailer("lexrel2network");

    # Do some sanity checks:
    # Make sure all the nodes declarated have been referenced
    foreach my $node_name (sort(keys(%bn_node_declaration))) {
	if ($bn_node_declaration{$node_name} != 0) {
	    &warning("Declaration/usage problem for %s (ref=%d)\n",
		     $node_name, $bn_node_declaration{$node_name});
	}
    }

    return;
}


# output_evidence_list(file_basename, referenced_synset_list_ref, headwords_proper_ref)
#
# Create the list of evidence nodes, which will get activated as observed 
# during the network interpretation. The format of the evidence file is
#        <node_name>':'<value_index>
#
sub output_evidence_list {
    my($base, $referenced_synsets_ref, $headwords_proper_ref) = @_;
    my($evidence_file) = "$base.evidence";
    my(@evidence);
    &debug_print(&TL_VERBOSE, "output_evidence_list(@_)\n");
    &debug_print(&TL_VERY_DETAILED, "referenced_synsets=(@$referenced_synsets_ref)\n");
    my($true_value) = ($use_evidence_values ? "True" : "1");

    if ($use_word_evidence) {
	# Each word used to construct the network becomes an evidence node
	my($roots) = &read_file("${base}.roots");
	$roots =~ s/(.*)\n/word_$1\n/g;
	@evidence = split(/\s+/, $roots);
    }
    elsif ($add_collocation_link) {
	my($head);
	foreach $head (sort(keys(%$headwords_proper_ref))) {
	    my($node) = &make_node_name("coll:$head");
	    push (@evidence, "$node:${true_value}");
	}
    }
    else {
	# Use each high-level synset with support above a certain threadhold
	# as evidence nodes
	my($support_threshold) = $max_synset_support * $evidence_threshold;
	&debug_print(&TL_VERBOSE, "checking support vs threshold of $support_threshold\n");
	foreach my $synset_key (keys(%synset_support)) {
	    &debug_print(&TL_VERBOSE, "k=$synset_key supp=$synset_support{$synset_key}\n");
	    if ($synset_support{$synset_key} >= $support_threshold) {
		&debug_print(&TL_DETAILED, "checking $synset_key for references\n");
		my($synset) = $synset_key;
		my($value) = $true_value;
		if ($binary_nodes == &FALSE) {
		    ($synset, $value) = &parse_sense($synset);
		}
		my($synset_node) = &make_node_name($synset);
		## if (&get_entry($referenced_synsets_ref, $synset_node, 0) > 0)
		if (&get_entry(\%references, $synset_node, 0) > 0) {
		    my($evidence) = "${synset_node}:$value";
		    push(@evidence, $evidence);
		}
	    }
	}
    }

    # Output the evidence list file
    my($evidence_list) = join("\n", @evidence) . "\n";
    &write_file($evidence_file, $evidence_list);

    return;
}


# normalize(list_ref, total): normalize the list (in place)
#
sub normalize {
    my($list_ref, $total) = @_;
    my($i);

    assert($total > 0);
    for ($i = 0; $i <= $#$list_ref; $i++) {
	$$list_ref[$i] /= $total;
    }
}


# print_cond_probability(node_name)
#
# Print the specification for a node's conditional probability,
# based on the dependencies from other nodes. This covers the general
# case with multiple-valued nodes, so it must account for dependencies
# due to actual word-sense relations as well as incidental dependencies,
# which occur given relations among the other senses of the words in
# question.
#
# For instance, consider a lexicon with the following entries:
#     animal: 1) living organism; 2) brute
#     dog: 1) animal; 2) cad
#     man: 1) animal; 2) human race
#
# The table produced for animal will reflect the logical implication from
# the hyponyms dog#1 and man#1 to the common hypernym animal#1, as well
# as other incidental dependencies, such as for dog#2 and man#2. Each word
# has as value of 0 to correspond to being not applicable. (For the sake
# of the example, no relation is assumed between cad and brute.)
#
#   dog, man | animal
#            |    0    1    2
#   -------------------------
#   0    0     1.00 0.00 0.00
#   0    1     0.00 1.00 0.00
#   0    2     1.00 0.00 0.00
#   1    0     0.00 1.00 0.00
#   1    1     0.00 1.00 0.00
#   1    2     0.00 1.00 0.00
#   2    0     1.00 0.00 0.00
#   2    1     0.00 1.00 0.00
#   2    2     1.00 0.00 0.00
#
# NOTE: the 0.00 terms are actually replaced w/ a small probability to
# reflect uncertainty of the knowledge (e.g., not all animals covered)
#
# See ascii2network.perl for a similar example of creating the conditional
# probabilty tables, although simpler since the probabilities are given.
#
sub print_cond_probability {
    my($node) = @_;
    &debug_print(&TL_VERY_DETAILED, "print_cond_probability(@_)\n");
    my($node_name) = &make_node_name($node);

    if ($binary_nodes == &TRUE) {
	return (print_binary_cond_probability(@_));
    }

    # Group the dependencies by head value
    my($dependencies) = &get_entry(\%dependencies, $node_name, "");
    &assert($dependencies ne "");

    # Check each dependency tuple in the tab-delimited list
    my($head_value, $object, $object_value);
    my(%dependents);
    my(%support);
    while ($dependencies =~ /\t([^\t]*)\|([^\t]*)\|([^\t]*)\t/) {
	$head_value = $1; $object = $2; $object_value = $3; 
	$dependencies = $';
	
	$dependents{$object} = &TRUE;
	$support{"$head_value:$object"} = $object_value;
    }

    # Specify the probabilities in canonical order (row major)
    # TODO: consider using ascii2network.perl to handle the specification
    #
    
    # First determine the number of dependents and truncate if too many for CPT
    my(@dependents) = sort(keys(%dependents));
    my($num_dependents) = ($#dependents + 1);
    if ($num_dependents > $max_vars) {
	&debug_out(&TL_DETAILED, "WARNING: %d dependents(s) will be ignored for $node\n",
		   ($num_dependents - $max_vars));
	my(@temp_dependents) = @dependents[0..$max_vars-1];
	@dependents = @temp_dependents;
	$num_dependents = $max_vars;
    }

    # Determine other misc. values
    my($node_type) = &determine_node_type($node);
    my($node_values) = ($node_type ne "binary" ? $node_type : "0 1");
    my(@node_values) = split(/\s+/, $node_values);
    my(@index) = (0) x $num_dependents;
    my($i, $j, $k);

    # Print the conditional probability specification header
    &print_cond_prob_header($node, \@dependents);

    # Determine the total number of rows in the table
    my($num_rows) = 1;
    foreach my $dependent (@dependents) {
	$num_rows *= &get_entry(\%node_num_values, $dependent, 2);
    }

    # Fill in each row of the table
    for ($i = 0; $i < $num_rows; $i++) {

	# Determine the probabilities for the current combination of the
	# node values and those of the dependents, except that the default
	# case for the node is determined from the others.
	#
	my(@probs);
	my($total_prob) = 0.00;
	for ($j = 1; $j <= $#node_values; $j++) {
	    my($node_value) = $node_values[$j];

	    # Pseudo-noisy-max combination of the values
	    $probs[$j] = 0.0;
	    for ($k = ($num_dependents - 1); $k >= 0; $k--) {
		my($var) = $dependents[$k];
		my($var_value) = &get_entry(\%node_value, "$var|$index[$k]");
		my($support) = &get_entry(\%dependency_support, 
				       "$node|$node_value|$var|$var_value", 
				       $logical_zero);
		$support = &min($support, 1.0);
		$probs[$j] = &max($probs[$j], $support);
	    }
	    $total_prob += $probs[$j];
	}
	if ($total_prob >= 1) {
	    $probs[0] = $logical_zero;
	    $total_prob += $probs[0];
	    &normalize(\@probs, $total_prob);
	    $total_prob = 1.0;
	}
	else {
	    $probs[0] = (1.0 - $total_prob);
	}

	# Output the current entry
	&print_cond_prob_entry(\@probs, \@index);

	# Increment the index values position indicators from right to left.
	# If an index wraps-around, continue with one to the left.
	for ($j = ($num_dependents - 1); $j >= 0; $j--) {
	    my($var) = $dependents[$j];
	    # Update the index position
	    my($num_values) = $node_num_values{$var} || 2;
	    $index[$j] = (1 + $index[$j]) % $num_values;
	    last if ($index[$j] > 0);
	}
    }


    # Print the conditional probability specification trailer
    &print_cond_prob_trailer($node);
}


# print_binary_cond_probability(node_name)
#
# Print the specification for a node's conditional probability, for
# the special case of binary nodes. The result will consist of
# truth-table style entries with the total positive and negative support
# given that the dependencies have the corresponding truth assignments.
#
# NOTE: This has been extended to optionally support exclusive-or conditions.
# The native support (eg, BELIEF's defxor) will be used if available;
# otherwise, the probabilities generated will reflect the xor truth table.
#
# TODO: use print_cond_probability for all nodes once it is stable
#
sub print_binary_cond_probability {
    my($node) = @_;
    &debug_print(&TL_VERY_DETAILED, "print_binary_cond_probability(@_)\n");
    my($node_name) = &make_node_name($node);

    if (!defined($dependencies{$node})) {
	## &debug_print(&TL_DETAILED, "No dependencies for $node\n");
	return;
    }
    my($dependencies) = $dependencies{$node};
    $dependencies =~ s/(^\t)|(\t\$)//g;
    my(@cond_vars) = split(/\t/, $dependencies);
    my(@cond_support);
    my($num_vars) = 1 + $#cond_vars;
    if ($num_vars > $max_vars) {
	&debug_out(&TL_DETAILED, "WARNING: %d variable(s) of %d will be ignored for $node\n",
		   ($num_vars - $max_vars), $num_vars);
	my(@temp_vars) = @cond_vars[0..$max_vars-1];
	@cond_vars = @temp_vars;
	$num_vars = $max_vars;
    }
    my($num_entries) = 2 ** $num_vars;

    # Determine if the links are exclusive
    my($is_xor) = &get_entry(\%dependency_exclusive, $node_name, &FALSE);
    &debug_print(&TL_VERBOSE, "is_xor=$is_xor\n");

    # Print the conditional probability specification header
    &print_cond_prob_header($node_name, \@cond_vars);

    # Determine the maximum support that a dependency can provide
    my($i, $j);
    my($max_value) = 0;
    my($support_percent) = 1.0;
    for ($j = 0; $j < $num_vars; $j++) {
	$cond_support[$j] = &get_entry(\%dependency_support,
				       "$node|$cond_vars[$j]");
	$max_value += $cond_support[$j];
    }
    if ($max_value < $max_support) {
	$support_percent = $max_value / $max_support;
    }

    # Print the truth-table style entries
    #
    for ($i = 0; $i < $num_entries; $i++) {
	my($value) = $logical_zero;
	my(@index);

	# First determine the index values for the current table entry.
	# This is equivalent to the binary representation of the current table
	# entry index.
	#
	# Also, accumulate the relation support weights
	# NOTE: the index is constructed in reverse order
	#
	# TODO: for ($j = $num_vars - 1; $j > 0; $j--)
	#
	my($num) = $i;
	my($num_nonzero) = 0;
	for ($j = 0; $j < $num_vars; $j++) {
	    my($positive) = $num % 2;
	    my($var) = $num_vars - $j - 1;
	    $num = int($num / 2);
	    if ($positive) {
		## $value += $cond_support[$j];
		$value += $cond_support[$var];
		$num_nonzero++;
	    }
	    $index[$var] = $positive;
	}
	my($value_percent) = 0.0;
	my($cond_value) = 0.0;

	# If the link is in an exclusive-or group, then the weight is
	# used only when a single parent contributed to the result
	if ($is_xor) {
	    if ($num_nonzero > 1) {
		$value = $logical_zero;
	    }
	    $max_value = 1.0;
	}

	# Determine the conditional value based on the combination. If using
	# bottom-up links, then ensure than the links adhere to propositional
	# logic semantics (currently, this just implements an OR). Otherwise,
	# the conditional weight is the percentage of the maximum possible.
	#
	# NOTE: bottom_up_links follow the grant proposal weight combinition
	#
	if ($bottom_up_links) {
	    $cond_value = ($value >= 1.0) ? 1.0 : $value;
	}
	else {	    
	    if ($max_value > 0) {
		$value_percent = $value / $max_value;
	    }
	    $cond_value = $value_percent * $support_percent;
	}
#if 1
	&debug_print(&TL_VERBOSE, "@index: $cond_value\n");
	$cond_value = &min($cond_value, $logical_one);
#endif

	# Print the current entry
	my(@cond_value) = (1.0 - $cond_value, $cond_value);
	&print_cond_prob_entry(\@cond_value, \@index, $is_xor);
    }

    # Print the conditional probability specification trailer
    &print_cond_prob_trailer($node_name, $is_xor);

    return;
}



#------------------------------------------------------------------------------


# display_weights(output_handle, weight_array_ref, title)
#
# Displays the contents of the associative array sorted in reverse numeric
# order (rather than by key).
#
sub display_weights {
    my($output_handle, $weights_ref, $title) = @_;
    &debug_print(&TL_VERBOSE, "display_weights(@_)\n");
    my(%weights) = %$weights_ref;	# TODO: avoid copy overhead
    my($key);

    printf $output_handle "# %s\n", $title;
    foreach $key (sort { $weights{$b} <=> $weights{$a} } keys %weights) {
	printf $output_handle "%s\t%.3f\n", $key, $weights{$key};
    }

    return;
}

