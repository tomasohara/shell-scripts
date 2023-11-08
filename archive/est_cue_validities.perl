# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# est_cue_validities.perl: estimate the cue validities (CV's) of properties
# for words defined in WordNet (or for relations extracted from definitions).
#
# Cue validites are a measure of how indicative features are of a
# particular class relative to a set of constrasting classes. The
# features used here are either content words from definitions (e.g.,
# 'domestic') or relation/target pairs from a lexical relation listing
# (e.g., 'modifies->noun:state').
#
# Two separate input formats are accepted. The first uses the WordNet
# hyponym tree listing for a base synset (considered as the category for
# sll the subsumed synsets). In this case, feataures are approximated by
# taking the content words from the definition. The second format uses
# relations derived from the WordNet definitions via a dependency parser
# (see parse_wordnet_defs.perl) optionally with relation and target term
# disambiguation (see extract-differentia.perl).
# 
# By default, the cue validities are calculated globally in which the
# set of constrasting concepts is based on the entire input (e.g., the
# hyponym tree listing for dog). Alternatively, they can be calculated
# relative to a 'most informative ancestor' (MIA) such as the WordNet hypernym
# synset which has the highest frequency from a tagged corpus like
# SemCor.  (A damping factor is applied so that ovely general synsets
# like object#1 are avoided.)
#
# NOTES:
#
# - Cue validity of feature F for class C (based on Bayes Rule):
#       P(C | F) = P(F | C) / \sum P(F | C_k)
#   where C_k are are classes that constrast with C.
#
#   To approximate this then,
#         P(F | C) = P(F ^ C) / P(C) 
#                  ~ f(F ^ C) / f(C)
#   where
#         f(F ^ C) is number of times feature occurs w/ class C          
#         f(C) is the number of features for class C
#
# - When the lexical relation input format is used, a separate script
#   must be used to reproduce the listing with the revised weights.
#   See reweight_relations.perl.
#
# REFERENCES:
#
# - Smith, Edward E., and Douglas L. Medlin (1981), Categories and
#   Concepts, Cambridge, MA: Hardvard University Press.
#
# - Rosch, Eleanor, and Carolyn B. Mervis (1975), "Family resemblance
#   studies in the internal structure of categories", Cognitive
#   Psychology, 7:573-605.
#
#------------------------------------------------------------------------
# sample input (WordNet hyponym tree format):
#
#    dog#1, domestic dog#1, Canis familiaris#1 -- (a member of the genus Canis (probably descended from the common wolf) that has been domesticated by man since prehistoric times; occurs in many breeds; "the dog barked all night")
#          => pooch#1, doggie#1, doggy#1, bow-wow#2 -- (informal terms)
#          => cur#1, mongrel#1, mutt#1 -- (an inferior dog or one of mixed breed)
#              => pariah dog#1, pye-dog#1, pie-dog#1 -- (ownerless half-wild mongrel dog common around Asian villages especially India)
#          => lapdog#1 -- (a dog small and tame enough to be held in the lap)
#          ...
#
# sample output using single/non-isolated CV's (e.g., one CV for relation/target pair):
#   
#    Cue validities for each concept:
#    Afghan_hound#1: { graceful:1.000, near:1.000, east:1.000, native:0.370, tall:0.150, silky:0.061, hound:0.045, long:0.029, coat:0.013, breed:0.008 }
#    Airedale#1:     { yorkshire:1.000, wiry:0.108, large:0.039, terrier:0.032, breed:0.023, breed:0.023, coat:0.018 }
#    ...
#    basset#1:       { leg:0.346, smooth:0.092, ear:0.087, hound:0.064, short:0.051,  long:0.042, breed:0.011 }
#    beagle#1:       { legged:0.235, smooth:0.092, hound:0.064, short:0.051, small:0.025, coat:0.018, breed:0.011 }
#    ...
#    borzoi#1:       { move:1.000, fast:0.615, tall:0.300, dog:0.017, breed:0.016 }
#    boxer#3:        { brindled:1.000, jaw:0.536, square:0.409, germany:0.267, stocky:0.179, muzzle:0.117, size:0.045, medium:0.044, short:0.028, develop:0.027, coat:0.010, dog:0.006, breed:0.006 }
#    ...
#    wolfhound#1:    { wolf:1.000, formerly:0.317, largest:0.222, use:0.056, hunt:0.047, dog:0.012, breed:0.011 }
#    working_dog#1:  { draft:0.629, animal:0.480, guide:0.176, work:0.162, several:0.102, guard:0.076, powerful:0.068, usually:0.056, large:0.021, dog:0.013, dog:0.013, breed:0.012, breed:0.012 }
#    
#........................................................................
# sample input (lexical relation format):
#
#   noun:angel#1:
#   	n/a	noun:angel (1.000)
#   	verb:is	verb:being (1.000)
#   		modifies-4-5	adj:spiritual (1.000)
#   		modified-by-5-6	adj:attendant (1.000)
#   			upon	God (1.000)
#   ...
#   noun:communism#1:
#   	n/a	noun:communism (1.000)
#   	verb:is	noun:form (1.000)
#   		of	noun:socialism (1.000)
#   			that	verb:abolishes (1.000)
#   				subject-of-6-8	noun:socialism (1.000)
#   				has-object-8-10	noun:ownership (1.000)
#   					modifies-9-10	adj:private (1.000)
#   ...
#   noun:yesterday#1:
#   	n/a	yesterday (1.000)
#   	verb:is	noun:day (1.000)
#   	verb:is	before (1.000)
#   	n/a	verb:is (1.000)
#   	before	today (1.000)
#   		before	immediately (1.000)
#   
#   
# sample output using isolated CV's (e.g., separate CV's for relation and target term):
#
#   Cue validities for each concept:
#   ...
#   noun:angel#1 (cognition#1):	{ n/a->noun:angel:1.000, verb:is->verb:being:1.000, modifies->adj:spiritual:1.000, modified-by->adj:attendant:1.000, upon->God:1.000 }
#   ...
#   noun:communism#1 (group#1):	{ n/a->noun:communism:1.000, verb:is->noun:form:1.000, of->noun:socialism:1.000, that->verb:abolishes:1.000, subject-of->noun:socialism:1.000, has-object->noun:ownership:1.000, modifies->adj:private:0.333 }
#   ...
#   noun:yesterday#1 (day#1):	{ n/a->yesterday:1.000, verb:is->before:1.000, before->today:1.000, before->immediately:1.000, n/a->verb:is:0.500, verb:is->noun:day:0.333 }
#   
#      
#........................................................................
# TODO:
# - Determine whether the class prior probabilities should not be incorporated,
#   since they seem to factor out:
#      P(C | F) = P(F | C) / \sum P(F | C_k)
#               = P(F | C)P(C) / \sum P(F | C_k)P(C_k)		[???]
#               = (P(F ^ C)/P(C))P(C) / \sum (P(F ^ C_k)/P(C_k))P(C_k)
#               = P(F ^ C) / \sum P(F ^ C_k)
# - *** Work out a simple test suite to ensure the CV's are calculated as desired.
# - Use WordNet for content word checks & morphological stemming.
# - Isolate synset category (ie, MIA) code and place in wordnet.perl
# - Develop test cases for synset category (ie, MIA) selection
#   (e.g., baseball_glove\#1 => equipment\#1)
# - Isolate WordNet dependencies.
# - Clarify relation of CV's computed here to distinction in psychology literature of
#   'category cue validity' versus 'individual cue validity'.
#
# Copyright (c) 2004 Tom O'Hara and New Mexico State University.
# Freely available via GNU General Public License (see GNU_public_license.txt).
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN {
    my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir);
    require 'common.perl';
    require 'wordnet.perl';
}

use strict;
use vars qw/$no_stemming $all_words $simple_probs $global $local $approx
            $by_freq $damping_factor $full_relation $isolate $multiple $lisp/;

if (!defined($ARGV[0])) {
    my($options) = "options = [-no_stemming] [-all_words] [-simple_probs] [-global] [-isolate] [-multiple]";
    my($example) = "examples:\n\n$script_name hound.list\n\n";
    $example .= "$script_name -skip_stems -all_words animal.list\n";
    my($notes) = "Notes:\n\n";
    $notes .= "- -by_freq determines head category by synset frequency\n\n";

    printf STDERR "\nusage: $script_name [options]\n\n$options\n\n$example\n\n$notes";
    &exit();
}

# Initialize associative arrays w/ frequency counts for features & classes
#
my(%class_freq, %class_feature_freq);
my(%class_features, %synset_category);

# Get values for options that can be overriden on command-line
&init_var(*no_stemming, &FALSE); # don't stem the content words
&init_var(*all_words, &FALSE);	# use all words (function as well as content)
&init_var(*global, &FALSE);	# calculate CV's globally (i.e., no categories)
&init_var(*local, ! $global);	# calcs CV's locally (eg, hyponym base for cat)
&init_var(*by_freq, &FALSE);	# use synset frequency to determine category
&init_var(*damping_factor, 0.75);  # damping factor for ancestor frequency
&init_var(*full_relation, &FALSE); # use full relation name
&init_var(*isolate, &FALSE);	# isolate relation from target (ie, separate CV's)
#
# The following options are for internal testing purposes 
&init_var(*simple_probs, &FALSE); # tests simplified probability calculation
&init_var(*approx, &FALSE);	# use approximate calculations
&init_var(*multiple, &FALSE); 	# class occurrences based on feature occurrences
my($use_single_occurrence) = (! $multiple);
&init_var(*lisp, &FALSE);	# use lisp-style output

# Initilize misc. modules
&init_morph();
&wn_init();

# Read in the synset frequencies
if ($by_freq) {
    &init_synset_frequency();
}

# Tabulate the sense/property associations
#
my($category) = "";
my($synset) = "";
#
while (<>) {
    &dump_line();
    chop;

    # Ignore comments and blank lines
    s/^\s*\#.*//;
    next if (/^\s*$/);

    # Extract properties from the definition
    # NOTE: The synset for the lookup word is ignored (e.g., dog)
    # ex: "       => boarhound#1 -- (large hound used in hunting wild boars)"
    if (/=> (.*) -- \((.*)\)/) {
	$synset = $1;
	my($def) = $2;
	$def = "" if (!defined($def));
	$def =~ s/-/ /g;

	# Extract first synset from the list
	# TODO: make a subroutine in wordnet.perl for this
	$synset =~ s/,.*//;	# remove all but first synset
	$synset =~ s/\(.*\)//;	# remove category parenthetical, such as '(prenominal)'
	$synset = &trim($synset);
	$synset =~ s/ /_/g;	# change spaces to underscores

	# Make note of category for synset
	# TODO: increment class_freq for each feature occurrence
	&assert($global || ($category ne ""));
	&set_entry(\%synset_category, $synset, $category);
	&incr_entry(\%class_freq, $synset) if ($use_single_occurrence);

	# Tabulate content word associations
	my($word);
	foreach $word (&tokenize($def)) {
	    $word = &trim_punctuation($word);
	    next if ($word eq "");

	    if ($all_words || &is_content_word($word)) {
		my($feature) = ($no_stemming ? $word : &get_root($word));
		## &incr_entry(*feature_freq, $feature);

		# Update f(F,C) and f(C)
		&incr_entry(\%class_feature_freq, "$synset\t$feature");
		&incr_entry(\%class_freq, $synset) if (! $use_single_occurrence);
		&append_entry(\%class_features, $synset, " $feature");
	    }
	}
    }

    # Determine the category relative to which cue validities are defined
    # ex: "hound#1, hound dog#1 -- (any of several breeds of dog ... large drooping ears)"
    elsif ($local && (/^(.*) -- \(.*\)/)) {
	$category = $1;
	$category =~ s/, .*//;
    }

    # Check for relational-format relationship
    # ex: "	as#LOC  noun:entity#1 (1.000)"
    elsif (/^\t+(\S+)\t(\S+)\s*(\(\S+\))?/) {
	my($relation) = $1;
	my($target) = $2;
	my($weight) = $3;
	$weight = 1.0 if (! defined($weight));

	# Drop offset indicators from relation. Also, just use the relation
	# type (i.e., ignore relation word).
	$relation =~ s/\-\d+\-\d+//;
	$relation =~ s/^[^\#]+\#// unless ($full_relation);

	# Update the feature/class associations
	# TODO: have subroutine for doing this given list of features
	#
	# Update f(C)
	&incr_entry(\%class_freq, $synset) if (! $use_single_occurrence);
	#
	# Update co-occurrence frequencies
	if ($isolate) {
	    # Update f(FR,C) and f(FO,C), for relation and target term 'features'
	    &incr_entry(\%class_feature_freq, "$synset\t$relation", $weight);
	    &append_entry(\%class_features, $synset, " $relation");
	    &incr_entry(\%class_feature_freq, "$synset\t$target");
	    &append_entry(\%class_features, $synset, " $target", $weight);
	}
	else {
	    # Update f(F,C) where F is combination of relaton and target term
	    my($feature) = "$relation->$target";
	    &incr_entry(\%class_feature_freq, "$synset\t$feature", $weight);
	    &append_entry(\%class_features, $synset, " $feature");
	}
    }

    # Check for complete relational tuple format
    # ex: "DOG	ISA	MAMMAL"
    # TODO: reduce redundant code with the above
    elsif (/^(\S+)\t(\S+)\t(\S+)\s*$/) {
	my($new_synset) = $1;
	my($relation) = $2;
	my($target) = $3;
	my($weight) = 1.0;

	# Drop offset indicators from relation. Also, just use the relation
	# type (i.e., ignore relation word).
	$relation =~ s/\-\d+\-\d+//;
	$relation =~ s/^[^\#]+\#// unless ($full_relation);

	# Update the feature/class associations
	# TODO: have subroutine for doing this given list of features
	#
	# Update f(C)
	if (($new_synset ne $synset) || (! $use_single_occurrence)) {
	    $synset = $new_synset;
	    &incr_entry(\%class_freq, $synset);
	}
	#
	# Update co-occurrence frequencies
	if ($isolate) {
	    # Update f(FR,C) and f(FO,C), for relation and target term 'features'
	    &incr_entry(\%class_feature_freq, "$synset\t$relation", $weight);
	    &append_entry(\%class_features, $synset, " $relation");
	    &incr_entry(\%class_feature_freq, "$synset\t$target");
	    &append_entry(\%class_features, $synset, " $target", $weight);
	}
	else {
	    # Update f(F,C) where F is combination of relaton and target term
	    my($feature) = "$relation->$target";
	    &incr_entry(\%class_feature_freq, "$synset\t$feature", $weight);
	    &append_entry(\%class_features, $synset, " $feature");
	}
    }

    # Check for relational format headword
    # ex: "noun:whole#2:"
    elsif (/^(\S+):/) {
	$synset = $1;
	# TODO: increment class_freq for each feature occurrence
	&incr_entry(\%class_freq, $synset) if ($use_single_occurrence);
	my($POS, $synset_proper) = &wn_parse_word_spec($synset);

	# Determine the most informative ancestor (MIA) synset to serve as
	# category, either by taking the first ancestor or the one having
	# highest tagged frequency (taken from SemCor)
	# NOTE: frequency is scaled by depth to avoid overly general synsets
	# TODO: include the synset itself in frequency test
	# TODO: apply more principled scaling (eg, account for fanout)
	## my(@ancestors) = &wn_get_ancestor_list($synset);
	my(@ancestor_info) = split(/\t/, &wn_get_ancestors($synset, undef, &TRUE));
	if ($by_freq) {
	    ## my(@freqs) = map { &get_synset_freq($_, $POS); } @ancestors;
	    # TODO: figure out the problem with the map
	    my(@freqs, @ancestors, $depth);
	    for (my $i = 0; $i <= $#ancestor_info; $i++) {
		($depth, $ancestors[$i]) = $ancestor_info[$i] =~ /(?:(\d+): )?(\S+)/;
		$depth = $i if (!defined($depth));
		my($scale) = (1 + $depth) * $damping_factor;
		$freqs[$i] = $scale * &get_synset_freq($ancestors[$i], $POS);
	    }
	    $category = &max_label(\@ancestors, \@freqs);
	}
	else {
	    $category = $ancestor_info[0];
	    $category = "" if (! defined($category));
	    $category =~ s/^\d+: //;	# remove depth indicator
	}
	if (!defined($category) || ($category eq "")) {
	    &warning("Unable to determine category for $synset\n");
	    $category = $synset;
	}

	&set_entry(\%synset_category, $synset, $category);
    }

    # Other skip the input line
    else {
	&debug_print(&TL_DETAILED, "WARNING: ignoring line '$_'\n");
    }
}


# First, calculate P(F | C) for each (feature, class) pair
#
# NOTE: The class (C) here is given by the synset below. This
# is separate from the category, which determines the set of contrasting
# classes and is based on the most informative ancestor (MIA).
# TODO: use perl arrays rather than associative arrays
# TODO: try to minimize confusion in class versus category
#
my(%p_F_given_C, %sum_p_F_given_C);
foreach $synset (sort(keys(%class_freq))) {
    # Get list of features occurring for the class and the overall category
    my($features) = &get_entry(\%class_features, $synset);
    my($category) = &get_entry(\%synset_category, $synset);

    my($feature);
    foreach $feature (&tokenize($features)) {
	# Compute P(F|C) from the co-occurrence counts
	my($f_F_and_C) = &get_entry(\%class_feature_freq, "$synset\t$feature", 1);
	my($f_C) = ($approx ? 1 : &get_entry(\%class_freq, $synset, 1));
	my($p_F_given_C) = ($simple_probs ? 1.0 : $f_F_and_C / $f_C);

	# Record the probability of the feature (F) given the synset (C)
	# and increment the sum for the category/feature pair.
	# NOTE: synsets partitioned into categories determined by MIA
	if (! defined($p_F_given_C{"$synset\t$feature"})) {
	    &set_entry(\%p_F_given_C, "$synset\t$feature", $p_F_given_C);
	    &incr_entry(\%sum_p_F_given_C, "$category\t$feature", $p_F_given_C);
	}
    }
}
&trace_assoc_array(\%sum_p_F_given_C);

# Next, calculate P(C | F) for each (class, feature) pair. This is
# determined using Bayes Rule as P(F | C)/(sum P(F | C_i).
#
# TODO: make sure this matches standard cue validity calculation; in particular,
# shouldn't it be P(F | C)P(C) / (sum P(F | C_i)P(C_i)) as with standard Bayes Rule???
# TODO: reduce redundancy in the calculations
#
printf ";; " if ($lisp);
printf "Cue validities for each concept:\n";
print "(\n" if ($lisp);
foreach $synset (sort(keys(%class_freq))) {
    # Get list of features occurring for the class and the overall category
    my($features) = &get_entry(\%class_features, $synset);
    my($category) = &get_entry(\%synset_category, $synset);

    # Create the list of cue validity feature specifications for the current class
    # ex: (train:1.000, raccoon:0.333, dog:0.083, hunt:0.067) for coondog
    my($feature);
    my(@cue_validities);
    foreach $feature (&tokenize($features)) {
	# Calculate P(C|F)
	my($p_F_given_C) = &get_entry(\%p_F_given_C, "$synset\t$feature");
	my($sum_p_F_given_C) = &get_entry(\%sum_p_F_given_C, "$category\t$feature");
	my($p_C_given_F) = $p_F_given_C / $sum_p_F_given_C;

	# Add to cue validity list for current class (e.g., synset)
	## my($cue_validity) = sprintf "%s:%.3f", $feature, $p_C_given_F;
	my($cue_validity) = "$feature:" . &round($p_C_given_F);
	push(@cue_validities, $cue_validity);
    }

    # Sort the cue validities for the class and output as single line
    # ex: noun:baseball_glove#1 (object#1):	{ verb:is->noun:gloves:1.000, by->noun:fielders:1.000, in->noun:baseball:0.500, modified-by->verb:worn:0.143 }
    @cue_validities = sort by_validities @cue_validities;
    my($category_spec) = ($category eq "") ? "" : " ($category)";
    if ($lisp) {
	# Output a line with dotted pair for tuple and weight for each relationship
	# ex: ((ABANDON IS-A EXIT) . 0.500)
	foreach my $cue_validity (@cue_validities) {
	    my($relation, $target, $weight) = (($cue_validity =~ /(\S+)->(\S+):(\d\.?\d*)/));
	    print "(($synset $relation $target) . $weight)\n";
	}
    }
    else {
	printf "%s%s:\t{ %s }\n", $synset, $category_spec, join(", ", @cue_validities);
    }
}
print ")\n" if ($lisp);

&exit();


#------------------------------------------------------------------------------

# Basic morphology module
# TODO: move to separate module file (e.g., extra.perl)
#       develop support for a persistent cache

my(%word_root, %is_content_word);

# init_morph(): initialize simple morphology module
# TODO: place this elsewhere (e.g., extra.perl)
#
sub init_morph {
    &debug_print(&TL_DETAILED, "init_morph(@_)\n");

    my($word);
    my(@stop_list) = ("a", "an", "any", "as", "in", "the", "", "with");
    foreach $word (@stop_list) {
	$is_content_word{$word} = &FALSE;
    }
}


# get_root(word): returns root form of the word
#
sub get_root {
    my ($word) = @_;
    &debug_print(&TL_DETAILED, "get_root(@_)\n");

    # First, check the cache to see if the word was already checked
    my($root) = $word_root{$word};
    if (!defined($root)) {
	foreach my $POS (("noun", "verb", "adj", "adv")) {
	    $root = &wn_get_root($word, $POS);
	    last if ($root ne $word);
	}
	$word_root{$word} = $root;
    }
    &debug_print(&TL_VERY_VERBOSE, "get_root($word) => $root\n");

    return ($root);
}


# is_content_word(word): indicates if word is a content word
#
sub is_content_word {
    my ($word) = @_;
    &debug_print(&TL_DETAILED, "is_content_word(@_)\n");
    my($is_content_word) = &FALSE;
 
    if (defined($is_content_word{$word})) {
	$is_content_word = $is_content_word{$word};
    }
    elsif (&wn_has_word($word)) {
	$is_content_word = &TRUE;
	$is_content_word{$word} = &TRUE;
    }
    &debug_print(&TL_VERY_VERBOSE, "is_content_word($word) => $is_content_word\n");

    return ($is_content_word);
}

#------------------------------------------------------------------------------

# by_validities: (reverse) sort comparison routine for two feature 
# specifications with cue validity values (e.g., "tall:0.372" vs. "fast:0.615")
#
sub by_validities {
    my($feature_a) = $a;
    my($feature_b) = $b;

    # Remove the feature labels
    $feature_a =~ s/^.*://;
    $feature_b =~ s/^.*://;

    # Do a numeric comparison (reverse order)
    return ($feature_b <=> $feature_a);
}
