# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/bin/perl -sw
#
# tuple2lexrel.perl: Converts relational tuple output from link grammar
# (see extract_linkages.perl) into format assumed by lexrel2network.perl.
# The link grammar output is a flat list of relational tuples. The
# dependency tree is reconstructed from this and then converted into
# a listing with tab-based indentation, as illustrated in the sample below.
#
# NOTES:
# - The input format produced by parse_wordnet_deds.perl is required
# - By default the frequency file used is that based on the wordforms in the
#   BNC corpus that have occurred 10 or more times (123K tokens).
# - The frequency filtering interfers with the proper relation formatting
#   so it should not be used (use filtering with lexrel2network instead).
#
# TODO:
# - Convert into dependency tree and use this to produce relations
#   with proper indentation
# - Modify lexrel2network.perl so that relations at level greater than 1
#   are applied to a new concept-node representing the complex attribute
#   (e.g., 'man-made object').
# - Make the output format more standard.
# - Make sure that no Link Grammar specific code is still here: but any
#   in extract_linkages.perl (to allow for modularity).
# - Fix frequency filtering wrt missing nested parent relations (e.g., 'n/a').
# - Handle input without headword indicator (eg, 'noun:artifact#1:').
#------------------------------------------------------------------------
# Sample input:
#
# parse_ID: N00015787
# sense: noun:artifact#1
# definition: An artifact is a man-made object  .
# linkages:
# <1. a, 2. n:artifact, 3. v:is>: 0.250
# <2. n:artifact.n, 3. v:is, 6. n:object>: 0.250
# <5. man-made, modifies, 6. n:object>: 0.500
#
# Sample output:
#
# noun:artifact#1:
#	verb:is n:object (0.25)
#		attribute man-made (0.50)
#
# Copyright (c) 2004 Tom O'Hara and New Mexico State University.
# Freely available via GNU General Public License (see GNU_public_license.txt).
#

# Load in the common module, ensuring script dir is first in Perl's lib path
BEGIN { 
    my($dir) = `dirname $0`; chop $dir; unshift(@INC, $dir);
    require 'common.perl';
    require 'extra.perl';
    require 'graphling.perl';
    use vars qw/$default_word_frequency_file/;
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
use vars qw/$min_term_freq $max_term_freq $freq_file $syns $add_syns/;

## my($default_frequency_file) = "/home/graphling/DATA/BNC/bnc-common-wordform.freq";

if (!defined($ARGV[0])) {
    # TODO: define and use $graphling_options and $extrac_options
    my($options) = "options = [-add_syns] [-min_term_freq=N] [-word_freq_file=file]";
    my($example) = "examples:\n\ngrep 'man\-made object' \$WNSEARCHDIR/data.noun | perl -Ssw parse_wordnet_defs.perl - | $script_name -\n\n";
    my($note) = "note: By default the frequencies are taked from\n\t${default_word_frequency_file}\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n\n$note\n";
}

&init_var(*min_term_freq, 0);        # minimum frequency of headword for relation
&init_var(*max_term_freq, &MAXINT);	# maximum frequency of terms in relation
## &init_var(*freq_file,           # frequency file for words to be considered
##          $default_frequency_file);
&init_var(*syns, &FALSE);	# alias for -add_syns
&init_var(*add_syns, $syns);	# add separate entries for synonyns of headword

my($sense) = 0;
my($count) = 0;
my(@headwords);
my(@relations);
my($POS) = "";

# Read in the term frequencies (ie, wordform frequencies)
## my(%word_frequency);
## &read_frequencies($freq_file, \%word_frequency);
&init_term_freq();

while (<>) {
    &dump_line();
    chop;

    # Ignore comments
    next if (/^\s*\#/);

    # Normalize the format of the relations (e.g., part of speech)
    if (/^\</) {
	# Remove offset indicators
	# ex: "<1. lemon.n, 2. is.v, 6. flavor.n>" => "<lemon.n, is.v, flavor.n>"
	s/(\d+)\. //g;

	# Remove unknown part-of-speech indicators
	s/\[\?\]//g;

	# Make sure the part-of-speech uses spelled-out prefix labels
	# example: object.n => noun:object
	# NOTE: The convertsion from link-grammar speech-part suffixes 
	# to prefixes, etc. is usually done in extract_linkages.perl
	# TODO: straighten out problem in extract_linkages.perl
	## &assert(! m/\b(n|v|a|p|s|g):/);
	s/([^<>, ]+)\.(n|v|a|p|s|g)\b/$2:$1/g;
	s/\ba:/adj:/g;
	s/\be:/adv:/g;
	s/\bv:/verb:/g;
	s/\bn:/noun:/g;
	s/\bs:/noun:/g;		# substantive to noun
	s/\bg:/verb:/g;		# gerund to verb
	s/\bp://g;		# drop .p suffix (prep's & plurals)
    }

    # Check for the word being defined
    if (/^sense: (((\S+):)?(\S+)\#(\S+))/) {
	# $'s:  123       4      5
	my($headword) = $1;
	## my($headword_proper) = $3;
	$POS = $3;
	# Output the previous set of relations
	if ($count++ > 0) {
	    &output_relations(\@headwords, \@relations);
	    @headwords = ();
	    @relations = ();
	}

	push(@headwords, $headword);
    }

    # Check for synonyms of the word
    elsif ($add_syns && (/^synonyms: (.*)/)) {
	my($synonym_list) = $1;

	my($synonym);
	foreach $synonym (&tokenize($synonym_list, ",\\s*")) {
	    $synonym = "$POS:$synonym" unless ($POS eq "");
	    push(@headwords, $synonym);
	}
    }

    # Check for the next relation and add to list
    elsif (/^\</) {
	push(@relations, $_);
    }

    # Otherwise ignore the line
    else {
	&debug_print(&TL_VERBOSE, "ignoring line: $_\n");
    }

}

# Output the last set of relations
if ($#headwords > -1) {
    &output_relations(\@headwords, \@relations);
    @headwords = ();
    @relations = ();
}
	    
&exit();

#------------------------------------------------------------------------

# add_flat_relation(relation_array_ref, relation, target, weight): adds the relation 
# specification to the list using the following format:
#    <TAB> <relation-name> <SP> <target-term> <SP> '(' <weight> ')'
# NOTE: if target term occurrs too frequenty the case is ignored
# 
# EX: my(@rels); add_flat_relation(\@rels, "attr", "small", 0.75); $rels[0] => "\tattr small (0.75)"
# TODO:
# - rename to reflect use of implicit source
#
sub add_flat_relation {
    my($relations_ref, $relation, $target, $weight) = @_;
    &debug_print(&TL_DETAILED, "add_flat_relation(@_)\n");

    my($target_frequency) = &get_term_freq($target);
    if ($target_frequency < $max_term_freq) {
	push(@$relations_ref, "\t$relation $target ($weight)");
    }
    else {
	&debug_print(&TL_DETAILED, "omitting relational target $target since freq ($target_frequency) > max ($min_term_freq); pos=$POS; sense=$sense\n");
    }
}

# format_relationships(relationship_list): Convert relations from tuple format
# to nested lexrel format
# TODO: handle problems due to frequency filtering (e.g., extraneous 'n/a' relations)
#
sub format_relationships {
    my(@relationships) = @_;
    &debug_print(&TL_VERBOSE, "format_relationships(@_)\n");
    my($result) = "";
    my(%depth);

    foreach my $relationship (@relationships) {
	my($source, $relation, $target, $weight) = &parse_relationship($relationship);
	# TODO: check synset freq if disambiguated; filter out low-freq as well
	if ((&get_term_freq($source) > $max_term_freq) 
	    || (&get_term_freq($target) > $max_term_freq)) {
	    &debug_print(&TL_DETAILED, "omitting relationship involving frequent term: $relationship\n");
	    next;
	}

	my($old) = $source;
	my($other) = $target;
	my($old_depth) = &get_entry(\%depth, $old, 0);

	if (&get_entry(\%depth, $target, 0) > 0) {
	    $old = $target;
	    $other = $source;
	    $old_depth = &get_entry(\%depth, $target, 0);
	}
	elsif (&get_entry(\%depth, $source, 0) == 0) {
	    $result .= "\tn/a\t$source (1.000)\n";
	    &set_entry(\%depth, $old, 1);
	    $old_depth = 1;
	}
	
	$result .= sprintf("%s%s\t%s (%s)\n", 
			   "\t" x $old_depth, $relation, $other, $weight);
	&set_entry(\%depth, $other, 1 + $old_depth);
    }

    return ($result);
}


# output_relations(headwords_ref, relations_ref): Given the references to a list
# of headwords and relations, display the relations in lexrel format under each
# headword.
#
sub output_relations {
    &debug_print(&TL_DETAILED, "output_relations(@_)\n");
    my($headwords_ref, $relations_ref) = @_;
    my($headword);
    &debug_print(&TL_VERBOSE, "headwords=(@$headwords_ref); relations=(@$relations_ref)\n");

    # Format the relations in lexrel
    my($formatted_relations) = &format_relationships(@$relations_ref);

    # Output the relations separately under each headword
    foreach $headword (@$headwords_ref) {

	# Make sure the headword meets the frequency constraints
	if (&get_term_freq($headword) < $min_term_freq) {
	    &debug_out(&TL_DETAILED, "skipping headword $headword since freq (%d) < min ($min_term_freq); pos=$POS; sense=$sense\n", &get_term_freq($headword));
	    next;
	}

	# Print the relation in lexrel format
	print "$headword:\n";
	print "$formatted_relations\n";
	print "\n";
    }
}
