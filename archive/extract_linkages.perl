# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/bin/perl -sw
#
# extract_linkages.perl: extract Link grammar relations from the parse output
#
# Sample input:
#
# Found 1 linkage (1 had no P.P. violations) at null count 2
#   Unique linkage, cost vector = (UNUSED=2 DIS=0 AND=0 LEN=6)
# 
#   +--------------Xp-------------+
#   +--------Wi--------+          |
#   |           +---E--+          |
#   |           |      |          |
# ///// [how] now.e brown.v [cow] ?
# 
#        /////          Xp      <---Xp---->  Xp        ?
#  (m)   /////          Wi      <---Wi---->  Wi        brown.v
#  (m)   now.e          E       <---E----->  E         brown.v
#        ?              RW      <---RW---->  RW        /////
#
# Sample raw output:
#
# Weighted relations:
# </////, Wi, brown.v>: 1.00
# </////, Xp, ?>: 1.00
# <?, RW, /////>: 1.00
# <now.e, E, brown.v>: 1.00
#
# Sample raw output:
#
# text:   wine is fermented juice (of grapes especially).
# </////, Xp, .>
# </////, Wd, wine.n>
# <wine.n, Ss, is.v>
# <is.v, Ost, juice.n>
# <fermented.v, A, juice.n>
# <juice.n, MXs, of>
# <(, Xd, of>
# <of, Xc, )>
# <of, Jp, grapes.n>
# <., RW, /////>
#
#
# Sample processed output:
#
# <n:wine, v:is, n:juice>
# <v:fermented, mod, n:juice>
# <n:juice, of, n:grapes>
#------------------------------------------------------------------------
# Main link grammar relation types:
#
# A       connects pre-noun ("attributive") adjectives to nouns. Any
# AA      is used in the construction "How big a dog was it?"
# AF 	connects adjectives to verbs in cases where the adjective
# AL	connects a few determiners like "all" and "both" to 
# AM	is used in the comparative constructions "as much" and "as many".
# AN	connects noun-modifiers to nouns.
# AZ	connects the word "as" back to certain verbs that can take 
# B       is used in a number of situations, involving relative clauses
# BI	is used to connect forms of the verb "be" to some idiomatic
# BT	is used with time expressions acting as fronted objects, as
# BW	connects "what" (as a direct or indirect question word) to 
# C	connects conjunctions and certain verbs with subjects of clauses.
# CC	is used to connect clauses to coordinating conjunctions. 
# CO	is used to connect "openers" to subjects of clauses:
# CP      is used with verbs like "say", which can be used in a quotation
# CQ	is used to connect to auxiliaries in cases where the
# CX      is used in comparative constructions like the following:
# D 	connects determiners to nouns.
# DD	is used to connect definite determiners ("the", "his", "Jane's")
# DG	connects the word "the" with proper nouns. In general, proper nouns 
# DP	is used to connect possessive determiners to gerunds in cases
# DT	connects determiners with nouns in certain idiomatic time
# E	is used for verb-modifying adverbs which precede the verb:
# EA	connects adverbs to adjectives. Certain adverbs can modify
# EB	connects adverbs to forms of "be" before an object
# EC	connects adverbs and comparative adjectives: 
# EE	connects adverbs to other adverbs. Some adverbs can
# EF	is used to connect the word "enough" to adjectives and adverbs.
# EI	connects a few adverbs to "after" and "before", such as "soon",
# EL	connects certain words like "someone/everyone/no_one/anyone", 
# EN      connects certain adverbs to expressions of quantity: "We have
# ER	is used in the construction "the X-er..., the Y-er...":
# EZ	connects certain adverbs to the word "as", like "almost",
# FL	connects "for" to "long": "I didn't wait FOR LONG / FOR
# FM	connects the prepositon "from" to various other prepositions.
# G	connects proper nouns together in series.
# GN      is a link, always carrying a cost of 2, used in expressions 
# H	connects "how" to "much" or "many". "Much" and "many" can serve 
# I	connects certain verbs with infinitives.
# ID      is a special class of link-types that is generated by the
# IN	is used to connect the preposition "in" to certain idiomatic
# J	connects prepositions to their objects.
# JG	connects certain prepositions ("of" and "for") to proper-noun
# JQ	is used to connect prepositions to question-words in constructions
# JT      connects certain conjunctions to time-expressions that are not
# K	connects certain verbs with particles like "in", "out", "up",
# L	connects certain determiners to superlative adjectives. 
# LE      is a special connector used in comparative constructions to
# LI	connects a few verbs like "feel" and "seem" to the preposition 
# M       connects nouns to various kinds of post-nominal modifiers 
# MF	is used in this construction:
# MG	allows certain prepositions to modify proper nouns. We do
# MV      connects verbs (and adjectives) to modifying phrases like adverbs,
# MX	connects nouns to post-nominal noun modifiers surrounded by commas.
# N	connects the word "not" to preceding auxiliaries.
# ND 	connects numbers with certain expressions which require numerical
# NF	is used with NJ in idiomatic number expressions involving "of":
# NI	is used in a few special idiomatic number phrases:
# NJ	is used in idiomatic number expressions involving "of", like
# NN	connects number words together in series. The last word in the
# NO	is a connector given to words such as "um" and "oh" which have
# NR	connects fraction words with superlatives:
# NS 	serves a similar function to ND, only for singular expressions.
# NT	connects "not" to "to": "I told him NOT TO go".
# NW	is used in idiomatic number expressions. It is exactly like ND, except
# O	connects transitive verbs to direct or indirect objects:
# OD	is used for a few verbs like "rise" and "fall" which can take
# OF	connects certain verbs and adjectives to the word "of". In
# ON	is used to connect the preposition "on" to certain time expressions.
# OT	is used for a few verbs like "last" which can take time
# OX	is a special object connector used for "filler" subjects like
# P	is used to link forms of the verb "be" to various words that
# PF	is used in certain direct and indirect questions with "be". 
# PP	connects forms of "have" with past participles:
# Q	is used in questions, in several different ways. It is
# QI	connects certain verbs and adjectives to question-words, forming
# R	connects nouns to relative clauses. In subject-type
# RS      is used in subject-type relative clauses. 
# RW	connects the right-hand wall to the left-hand wall in cases
# S	connects subject-nouns to finite verbs:
# SF      is a special subject link-type used for certain "filler" subjects
# SFI	connects "filler" subjects "it" and "there" to invertible
# SI	is used in subject-verb inversion:
# SX	is used to connect the first person pronoun to "I" to the verbs
# SXI	is analogous to SX, except used in cases of s-v inversion. See
# TA 	is used to connect adjectives like "late" to month names: 
# TD	connects day-of-the-week words forward to words like "morning",
# TH	connects words that take "that [clause]" complements with the
# TI	is used for titles like "president" and "chairman", which
# TM	is used to connect month names to day numbers:
# TO	connects verbs and adjectives which take infinitival complements
# TQ	is used as the determiner link for time expressions
# TS	is used in subjunctive constructions. It connects certain
# TT	is used in expressions like this one:
# TW	connects days of the week to month names in sentences
# TY	is used for certain idiomatic usages of year numbers.
# U       is a special link used with nouns. In most cases,
# UN	connects the words "until" and "since" to certain time phrases
# V	is used for attaching various verbs to idiomatic expressions
# W	is used to attach main clauses to the wall (hereafter "the wall"
# WN	is used to connect "when" phrases back to time-nouns like "year"
# WR	is used to connect the word "where" to a few verbs like "put".
# X	is used to connect punctuation symbols to words. Xc connects
# Y       is used in certain idiomatic time and place expressions. It
# YP	is used in possessive constructions to connect plural noun 
# YS      connects nouns to the possessive suffix "'s". "'s" then acts 
# Z	connects the preposition "as" to certain verbs.
#........................................................................
# link parser part of speech suffixes:
# (see http://bobo.link.cs.cmu.edu/link/dict/introduction.html)
#
#    .n	 nouns
#    .v  verbs
#    .a  adjectives
#    .e  adverb
#    .p  preposotion
#    .s  singular
#    .p  plural (???)
#    ,t  title
#------------------------------------------------------------------------
# TODO:
# - Use a more standard notation for part-of-speech specification
#   (e.g., "wine.n" to "n:wine").
# - Show example of the offset usage above.
# - Drop the space after the offet (the period is sufficient for parsing).
# - Similarly use a better notation for the word-offset
#   (e.g., "1. wine.n" to "n:wine@1"???).
# - Decompose main loop into subroutines.
# - Make sure alternative interpretations for same relation-indicating word
#   don't appear together in result.
# - Distinguish disjunction from conjunction: 'or' and 'and' now handled same.
# - Handle relations involving pronouns.
# - Resolve words connected by ID relations into multi-word units.
#------------------------------------------------------------------------
# Copyright (c) 2005 Tom O'Hara and New Mexico State University.
# Freely available via GNU General Public License (see GNU_public_license.txt).
#


# Load in the common module, making sure the script dir is in Perl's lib path
BEGIN {
    $dir = `dirname $0`; chop $dir; unshift(@INC, $dir);
    require 'common.perl';
    ## use vars qw/$verbose/;
    require 'graphling.perl';
    require 'wordnet.perl';
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
use vars qw/$first $raw $processed $use_link_metrics $convert/;

# Show usage statement if insufficient command-line arguments given
#
if (!defined($ARGV[0])) {
    my($options) = "options = [-first] [-raw] [-processed]";
    my($example) = "ex: echo 'How now brown cow?' | link_parser.sh - | $script_name -\n";

    print "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
    &exit();
}

# Check command-line arguments
#
&init_var(*first, &FALSE);	# choose first parse as best
&init_var(*raw, &FALSE);	# show the raw (link grammar) relation tuples
&init_var(*processed, (! $raw)); # show the higher-level relation tuples
&init_var(*use_link_metrics, &FALSE); # factor Link Parser metrics into weights
&init_var(*convert, &FALSE);	# convert part-of-speech labels

# Initialize modules (e.g., WordNet access)
&wn_init();

# Extract relations from the link parser input
#
my(%relations);
my($input) = "";
my($new_parse) = &TRUE;
my($base_weight) = 1.0;
my($relation_weight) = 1.0;
my($parse_num) = 1;
my($num_parses);

while (<>) {
    &dump_line();
    chop;

    # Ignore comments
    next if (/^\s*\#/);

    # Check for the user input
    if (/(linkparser> )+(.*)/) {
	$input = $2;
    }

    # Check for a new set of parses. Set relation weight to inverse of number of parses.
    #
    # example: Found 2 linkages (2 had no P.P. violations) at null count 1
    # example: Found 26 linkages (15 of 25 random linkages had no P.P. violations) at null count 2
    if (/Found \d+ linkages? \((\d+) /) {
	$new_parse = &TRUE;
	$num_parses = $1;
	$num_parses = 1 if ($num_parses == 0);
	&debug_out(&TL_DETAILED, "Input text: %s\n", $input);
	$base_weight = 1 / $num_parses unless ($first);
    }

    # Check for a new parse, and determine the new weight for the links
    # NOTE: The weight is simply inversely proportional to the number of parses
    # TODO: assign weight based on relative merit determined from parse metrics
    # example: Linkage 1, cost vector = (UNUSED=1 DIS=0 AND=0 LEN=24)
    # example: Linkage 14, non-canonical, cost vector = (UNUSED=13 DIS=12 AND=10 LEN=60)
    if (/Linkage (\d+).*cost vector =./i) {
	$parse_num = $1;
    }
    elsif (/Unique linkage/i) {
	$parse_num = 1;
    }
    if (/cost vector = \(UNUSED=(\d+) DIS=(\d+) AND=(\d+) LEN=(\d+)\)/i) {
	my($metric_used, $metric_dis, $metric_and, $metric_len) = ($1, $2, $3, $4);
	my($parse_info) = $&;
	&debug_out(&TL_DETAILED, "parse %d: %s\n", $parse_num, $parse_info);
	$relation_weight = $base_weight;
	$relation_weight /= 2 if (($use_link_metrics) && ($metric_and > 0));
	$relation_weight = 1.0 if ($first);
    }

    # Tabulate the relations from the parse
    # NOTE: This assumes that a customized version of the link parser is used
    # so that offset are included in the relation display
    #
    # example:
    #
    #     ///// Jack kissed.v jane[?].n . 
    #    
    #           /////          Xp      <---Xp---->  Xp        4. .
    #     (m)   /////          Wd      <---Wd---->  Wd        1. Jack
    #     (m)   1. Jack        Ss      <---Ss---->  S         2. kissed.v
    #     (m)   2. kissed.v    O       <---O----->  O         3. jane[?].n
    #           4. .           RW      <---RW---->  RW        5. /////
    #
    if (/((\d+\. )?\S+)\s*\S+\s*<\-+([^\-]+)\-+>\s*\S+\s*((\d+\. )?\S+)/) {
	#12                         3                    45
	my($source, $relation, $target) = ($1, $3, $4);
	my($link_relationship) = $&;
	my($tuple) = sprintf "%s, %s, %s", $source, $relation, $target;

	# Convert from POS suffixes to POS prefixes
	# TODO: make sure you cover all the POS suffixes
	$tuple =~ s/\.g/\.v/g;		# change 'g(erund) to v(erb)'
	$tuple =~ s/\.s/\.n/g;		# change 's(ubstantive) to n(noun)'
	$tuple =~ s/(\S+)\.([aenpsv])/$2:$1/g;
	#
	# convert 'a' to 'adj;, 'e' to 'adv', etc.
	if ($convert) {
	    $tuple =~ s/\ba:/adj:/g;
	    $tuple =~ s/\be:/adv:/g;
	    $tuple =~ s/\bv:/verb:/g;
	    $tuple =~ s/\bn:/noun:/g;
	    $tuple =~ s/\bs:/noun:/g;	# substantive to noun
	    $tuple =~ s/\bg:/verb:/g;	# gerund to verb
	    $tuple =~ s/\bp://g;	# drop .p suffix (prep's & plurals)
	}


	# Get rid of [?]'s and other miscellaneous indicators
	$tuple =~ s/\[\?\]//g;

	# If only first parse desired, skip remaining ones
	if ($first && ($parse_num > 1)) {
	    next;
	}

	# Add relation tuple to the list
	&debug_print(&TL_VERBOSE, "link relationship: $link_relationship\n");
	&debug_print(&TL_VERBOSE, "tuple: <$tuple>\n");
	&incr_entry(\%relations, $tuple, $relation_weight);
    }
}

# Display the raw relations
#
if ($raw) {
    &output_relations(\%relations, "Raw");
}

if ($processed) {
    my($processed_relations_ref) = &combine_relations(\%relations);
    if (&DEBUGGING) {
	&output_relations(\%relations, "Raw", "# ");
    }
    &output_relations($processed_relations_ref, "Processed");
}

&exit();

#------------------------------------------------------------------------

# output_relations(relations_ref, label, output_prefix):
# Output a formatted listing of the list of relations in the hash.
# The hash keys give the relation, and the values are the weights.
# NOTE: the output_prefix is used to start each line (eg, for comments)
#
sub output_relations {
    my($relations_ref, $label, $prefix) = @_;
    $prefix = "" if (!defined($prefix));
    &debug_print(&TL_DETAILED, "output_relations(@_)\n");

    print "$prefix$label relations:\n" if ($verbose);
    foreach my $key (sort(keys(%$relations_ref))) {
	my($tuple) = $key;
	printf "%s<%s>: %.3f\n", $prefix, $tuple, ${$relations_ref}{$key};
    }

    return;
}

# init_link_relations(): initialize hash tables giving grammatical function 
# for each link grammar relation, using fine= and coarse-grained mappings.
#
# NOTE: the fine-grained mappings cover the top-100 or so linkages occuring
# in the parses for the DSO noun and verb defs (190 most frequent words)
# TODO:
# - include more fine-grained mappings
# - read the data from a file to allow for alternative mappings
# - standardize the resulting relations
#
my(%fine_link_relation_function);
my(%coarse_link_relation_function);
#
sub init_link_relations {
    &debug_print(&TL_VERBOSE, "init_link_relations(@_)\n");

    # Initialize the mapping of coarse-grain relations
    %fine_link_relation_function = (
	"A" => "modifies",	# pre-noun adjectives to following nouns
	"AN" => "modifies",	# noun-modifiers to following nouns
	"Am" => "comparative",	# used with comparatives
	"Bp" => "subject-of",	# plural noun to verb [relative clause]
	"Bs" => "subject-of",	# singular noun to verb [relative clause]
	"CC" => "joined-with",	# clauses to following coordinating conjunctions 
	"CO" => "modifies",	# "openers" to subjects of clauses
	"Ce" => "object-of",	# ???; verbs that take clausal complements
	"Cr" => "subject-of",	# subject of relative clause
	"Cs" => "subject-of",	# subject of subordinated clauses
	"D" => "determiner-of",	# determiners to nouns
	"DD" => "determiner-of", # definite determiners to numeral or nominal-adjective
	"Ds" => "determiner-of", # singular determiner
	"Dmc" => "determiner-of",	# non-singular, countable determiner
	"Dmcm" => "determiner-of",	# ???
	"Dmu" => "determiner-of",	# non-singular, uncountable determiner
	"Dsu" => "determiner-of",	# singular, uncountable determiner
	"E" => "modifies",	# verb-modifying adverbs which precede the verb
	"EA" => "modifies",	# TODO: fill in descriptions here and below
	"EAm" => "modifies",	# 
	"EBm" => "modifies",	# 
	"EBx" => "modifies",	# 
	"EL" => "modifies",	# 
	"Em" => "modifies",	# 
	"I" => "modal-verb",	# verbs with infinitives
	"IDBAU" => "idiom",	# words of idiomatic expressions 
	"IDPK" => "idiom",	# 
	"IDPL" => "idiom",	# 
	"IDPO" => "idiom",	# 
	"IDQD" => "idiom",	# 
	"IDUU" => "idiom",	# 
	"IDVZ" => "idiom",	# 
	"IDYG" => "idiom",	# 
	"If" => "modal",	# verbs with infinitives
	"Ix" => "modal",	# 
	"J" => "prep-obj",	# prepositions to their objects
	"Jp" => "prep-obj",	# prepositions to plural object
	"Js" => "prep-obj",	# prepositions to singular object
	"Jw" => "prep-obj",	# prepositions to noun-phrase question-words
	"K" => "particle",	# verbs with particles 
	"La" => "determiner-of",	# determiners to superlative adjectives
	"MVa" => "modified-by",	# verbs and adjectives to modifying phrases that follow
	"MVi" => "modified-by",	# 
	"MVl" => "modified-by",	# 
	"MVp" => "modified-by",	# 
	"MVs" => "modified-by",	# 
	"MVx" => "modified-by",	# 
	"MX" => "modifies",	# modifying phrases with commas to preceding nouns
	"MXp" => "modifies",	# 
	"MXs" => "modifies",	# 
	"MXsp" => "modifies",	# 
	"Ma" => "modified-by",	#  nouns to various kinds of post-noun modifiers
	"Mg" => "modified-by",	# 
	"Mj" => "modified-by",	# 
	"Mp" => "modified-by",	# 
	"Mv" => "modified-by",	# 
	"O" => "has-object",	# transitive verbs to their objects
	"OF" => "particle",	# verbs and adjectives to the word "of"
	"Op" => "has-object",	# 
	"Opn" => "has-object",	# 
	"Opt" => "has-object",	# 
	"Os" => "has-object",	# 
	"Osc" => "has-object",	# 
	"Osn" => "has-object",	# 
	"Ost" => "has-object",	# 
	"Ox" => "has-object",	# 
	"PF" => "modal",	# certain questions with "be"
	"PP" => "modal",	# "have" with past participles
	"PPf" => "modal",	# 
	"Pa" => "modal",	# 
	"Paf" => "modal",	# 
	"Pafm" => "modal",	# 
	"Pam" => "modal",	# 
	"Pg" => "modal",	# 
	"Pp" => "modal",	# 
	"Pv" => "modal",	# 
	"Pvf" => "modal",	# 
	"Qd" => "modal",	# used in questions
	"R" => "modified-by",	# nouns to relative clauses
	"RS" => "subject-of",	# relative pronoun to the verb
	"RW" => "to-wall",	# right-hand wall to the left-hand wall
	"S" => "subject-of",	# subject nouns to finite verbs
	"SFp" => "subject-of",	# filler subjects (eg, "it") to finite verbs
	"SFsx" => "subject-of",	# 
	"SIs" => "subject-of",	# subject nouns to verbs [subject-verb inversion]
	"Sp" => "subject-of",	# plural nouns to plural verb [main clause]
	"Spx" => "subject-of",	# 
	"Ss" => "subject-of",	# singular nouns to singular verb [main clause]
	"TO" => "modal",	# verbs and adjectives to the word "to"
	"TOf" => "modal",	# 
	"TOn" => "modal",	# 
	"TOo" => "modal",	# 
	"Wd" => "to-wall",	# 
	"Wi" => "to-wall",	# 
	"Wq" => "to-wall",	# 
	"Xc" => "is-punctuation",	# used with punctuation
	"Xca" => "is-punctuation",	# 
	"Xd" => "is-punctuation",	# 
	"Xp" => "is-punctuation",	# 
	"Xx" => "is-punctuation",	# 
	"YS" => "is-possessive",	# nouns to the possessive suffix
	"" => "???" 
	);

    # Initialize the mapping of coarse-grain relations
    %coarse_link_relation_function = (
	"A" => "modifies",
	"B" => "relative-connector",
	"C" => "conjunction",
	"D" => "determiner",
	"E" => "adverb",
	"F" => "for-prep",
	"G" => "proper-noun",
	"H" => "how",
	"I" => "misc",		# modal, idioms, and "in"
	"K" => "particle",
	"L" => "comparisons",
	"M" => "modified-by",
	"N" => "misc",		# not to aux, number expression, and idioms
	"O" => "has-object",
	"P" => "modal",
	"Q" => "question",
	"R" => "relative",
	"S" => "is-subject",
	"T" => "time-related",
	"U" => "misc",		# kind-of, until, since
	"V" => "verb-of",
	"W" => "misc",		# wall, when, and where
	"X" => "punctuation",
	"Y" => "misc",		# idioms and certain possessives
	"Z" => "as-prep",
	"" => "???"
	);
}


# is_infinitive_relation(relation): indicates whether the relation
# deals with an infinitive
# EX: is_infinitive_relation("TO")
# EX: is_infinitive_relation("I")
sub is_infinitive_relation {
    my($relation) = @_;

    my($infinitive) = &boolean($relation =~ /^((TO)|(I[^D]?))/);
    &debug_print(&TL_VERY_DETAILED, "is_infinitive_relation(@_) => $infinitive\n");

    return ($infinitive);
}


# convert_link_relation(relation): return syntactic relation indicated
# by the given Link Parser relation
# EX: convert_link_relation("Bs") => "subject-of"
#
sub convert_link_relation {
    my($relation) = @_;

    # Convert the relation by first checking for a mapping using the
    # entire relation specification (eg, Xca) and otherwise defaulting to the
    # specification given by the first letter (eg, X).
    &init_link_relations() unless (scalar %fine_link_relation_function);
    my($converted_relation) = &get_entry(\%fine_link_relation_function, $relation, "???");
    if ($converted_relation eq "???") {
	my($coarse_relation) = substr($relation, 0, 1);
	$converted_relation = &get_entry(\%coarse_link_relation_function, $coarse_relation, "???");
    }
    &assert($converted_relation ne "???");
    &debug_print(&TL_VERY_DETAILED, "convert_link_relation(@_) => $converted_relation\n");

    return ($converted_relation);
}


# combine_relations(relations_ref): Combine the raw relations from
# the link parser of the format
#     <source-token, link-relation, target-token>
# into the format 
#     <word-word, syntactic-relation, target-word>,
# where the  syntactic relations are either given by function words
# or by dummy words for common grammatic relations (eg., subj-of, has-obj).
#
# Only relations involving content words for the source and target words
# are returned. The cases involving punctuation or function words are
# ignored.
#
# For example:
#     <n:wine, Ss, v:is>
#     <v:is, Ost, n:juice>
# is combined into
#     <n:wine, v:is, n:juice>
#
# NOTES:
# - If word offsets are used, then the modification relation token
# indicates the offsets of the words related (e.g., mod-5-6)
#
# TODO:
# - represent the special link types in a table (e.g., EA for adverbial modification of adjective)
# - parameterize 'mod' label usage
# - include offset indicator for mod token as well (e.g., at end of sentence)
# - use helper function for formatting the tuples
#
# EX: combine_relations({'n:wine, Ss, v:is' \=\> 1, 'v:is, Ost, n:juice' \=\> 1}) => {'n:wine, v:is, n:juice' \=\> 1}
#
sub combine_relations {
    my($relations_ref) = @_;
    &debug_print(&TL_DETAILED, "combine_relations(@_)\n");
    
    my(%combined_relations, $key1, $key2);
    foreach $key1 (sort(keys(%$relations_ref))) {
	my($source1, $relation1, $target1) = split(/, /, $key1);
	my($weight1) = $$relations_ref{$key1};
	my($num_added) = 0;

	# Ignore relations involving punctuation
	if (&nonword_component($source1) || nonword_component($target1)) {
	    &debug_print(&TL_VERBOSE, "Skipping relation '$key1' due to source or target puntuation\n");
	    next;
	}
	&debug_print(&TL_VERY_DETAILED, "checking relation1 '$key1'\n");

	# Join relations involving functions words or verb is
	#    <source, rel1, function-word> & <function-word, rel2, target>
	# => <source, function-word, target>
	# EX: <2. n:artifact, Ss, 3. v:is> & <3. v:is, Ost, 6. n:object>
	# => <2. n:artifact, 3. v:is, 6. n:object>
	# NOTES:
	# - Relation weight is product of individual weights.
	# - 'to' as infinitive marker will not be conflated
	# TODO: try other ways of combining the weights
	# TODO: handle other common cases (eg, "was")
	if (&content_word($source1)
	    && (! &content_word($target1))) {
	    foreach $key2 (sort(keys(%$relations_ref))) {
		my($source2, $relation2, $target2) = split(/, /, $key2);
		next if (&nonword_component($source2) 
			 || &nonword_component($target2));
		next if (&is_infinitive_relation($relation1) 
			 || &is_infinitive_relation($relation2));
		&debug_print(&TL_VERY_DETAILED, "checking relation2 $key2\n");

		my($weight2) = $$relations_ref{$key2};
		if (($target1 eq $source2)
		    && &content_word($target2)) {
		    my($source) = $source1;
		    my($weight) = $weight1 * $weight2;
		    
		    my($tuple) = sprintf "%s, %s, %s", $source1, $target1, $target2;
		    &incr_entry(\%combined_relations, $tuple, $weight);
		    $num_added++;
		}
	    }
	}
	    
	# Otherwise include the relation using higher-level grammatical
	# relation in place of low-level link relation.
	# If offsets are used, then the offsets are included in relation token.
	# NOTE: the later is in support of disambiguate-parses.perl
	if (($num_added == 0)
	    && &content_word($source1)
	    && &content_word($target1)) {
	    my($syntactic_relation) = &convert_link_relation($relation1);
	    my($offset1) = &parse_word_spec($source1);
	    if ($offset1 > -1) {
		my($offset2) = &parse_word_spec($target1);
		$offset1++;
		$offset2++;
		$syntactic_relation = "${syntactic_relation}-$offset1-$offset2";
	    }
	    
	    my($tuple) = sprintf "%s, %s, %s", $source1, $syntactic_relation, $target1;
	    &incr_entry(\%combined_relations, $tuple, $weight1);
	    $num_added++;
	}
    }
    &debug_out(&TL_VERBOSE, "combine_relations(%s) => %s\n", 
	       stringify($relations_ref), stringify(\%combined_relations));

    return (\%combined_relations);
}


# nonword_component(relation_component): indicates if the relation component
# corresponds to a non-word item (e.g., punctuation)
#
# EX: nonword_component("15. ;") => 1
# EX: nonword_component("9. v:combining") => 0
# EX: nonword_component("/////") => 1
#
sub nonword_component {
    my($component) = @_;
    my($offset, $POS, $word) = &parse_word_spec($component);

    my($OK) = &boolean($word =~ /[^A-Z0-9_\-]/i);
    &debug_print(&TL_VERY_DETAILED, "nonword_component(@_) => $OK\n");

    return ($OK);
}

# content_word(word_spec): indicates if the word is a content word
#
# EX: content_word("1. n:house") => 1
# EX: content_word("7. of") => 0
# EX: content_word("v:is") => 0
# EX: content_word("1. a") => 0
# EX: content_word("18. Aztec") => 1
#
# TODO: treat capitalized words without part-of-speech as content words
#
sub content_word {
    my($word_spec) = @_;
    $word_spec =~ s/^\d+\.\s*//;
    my($OK) = &FALSE;

    if ($word_spec =~ /:/) {
	$OK = (($word_spec =~ /[nvea]:/) && ($word_spec !~ /v:is$/i));
    }
    else {
	## $OK = (($word_spec =~ /^[A-Z]/) || &wn_is_content_word($word_spec));
	$OK = &wn_is_content_word($word_spec);
    }

    &debug_print(&TL_VERBOSE, "content_word(@_) => ", &boolean($OK), "\n");
    return ($OK);
}
