# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# reweight_relations.perl: re-calculate the weights of the lexical relations
# in the listing produced by tuple2lexrel.perl using the cue validities
# information produced by est_cue_validities.perl
#
# ........................................................................
# Sample cue validity:
#
#    Cue validities for each concept:
#    noun:abdomen#1 (part#7):        { noun:thorax#1:1.000, noun:abdomen:1.000, noun:region#2:1.000, noun:pelvis#1:1.000, noun:vertebrate#1:1.000, noun:body#1:0.250,  between:0.125, between:0.125, between:0.125, verb:is:0.026, verb:is:0.026, verb    :is:0.026, LOC:0.015, LOC:0.015, n/a:0.014, n/a:0.014 }
#    ...
#    noun:accord#2 (act#2):  { noun:accord:1.000, noun:concurrence:1.000, noun:opinion:1.000, LOC:0.009, n/a:0.006, verb:is:0.006 }
#    ...
#    noun:zinc#1 (substance#1):      { noun:zinc#1:1.000, noun:zinc#1:1.000, noun:sulphide#1:1.000, verb:galvanizing#2:1.000, verb:blende:1.000, wide#1:1.000, lustrous#1:1.000, noun:temperatures#2:1.000, noun:alloys#1:1.000, noun:iron#1:1.000, when:1.000, verb:occurs#1:1.000, noun:sulphide#1:1.000, brittle#1:0.667, brittle#1:0.667, malleable#1:0.500, noun:variety#1:0.500, ordinary#1:0.500, metallic:0.250, MNR:0.200, noun:element:0.182, noun:element:0.182, verb:used#1:0.125, modified-by:0.048, modified-by:0.048, modified-by:0.048, LOC:0.030, LOC:0.030, LOC:0.030, LOC:0.030, LOC:0.030, modifies:0.028, modifies:0.028, modifies:0.028, modifies:0.028, modifies:0.028, has-object:0.024, n/a:0.022, n/a:0.022, n/a:0.022, n/a:0.022, verb:is:0.009 }
#
# Sample relation listing:
#
#    noun:something#1:
#            n/a     something (1.000)
#      verb:is noun:thing (1.000)
#                    of#LOC  noun:kind (1.000)
#    
#    noun:possession#2:
#            n/a     noun:possession (1.000)
#      verb:is anything (4.000)
#            n/a     verb:is (1.000)
#            anything        verb:owned (2.000)
#            anything        verb:possessed (2.000)
#    ...
#    
#    noun:flower#3:
#            n/a     noun:flower (1.000)
#      verb:is noun:period#1 (4.000)
#                    of#LOC  noun:productivity#1 (2.000)
#                    of#LOC  noun:prosperity#1 (2.000)
#    
#    
#    noun:then#1:
#........................................................................
# TODO:
# - generalize to handling other input format
#
# Copyright (c) 2004 Tom O'Hara and New Mexico State University.
# Freely available via GNU General Public License (see GNU_public_license.txt).
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir);
    require 'common.perl';
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
use vars qw/$full_relation $normalize $isolate/;

# Show a usage statement if no arguments given
# NOTE: By convention - is used when no arguments are required
if (!defined($ARGV[1])) {
    my($options) = "main options = []";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "examples:\n\n$script_name example\n\n";  # TODO: example
    $example .= "$0 refined-wn-common-nouns.cv refined-wn-common-nouns.rels >| cv-refined-wn-common-nouns.rels\n\n";
    my($note) = "";
    ## $note .= "notes:\n\nSome usage note.\n";		     # TODO: usage note

    print STDERR "\nusage: $script_name [options] weightfile \n\n$options\n\n$example\n$note";
    &exit();
}
my($weight_file) = shift @ARGV;

# Check the command-line options
# note: Each variable initialized corresponds to a -var=value commandline option
&init_var(*full_relation, &FALSE); # use full relation name
&init_var(*normalize, &FALSE);		# normalize relation weights
&init_var(*isolate, &FALSE);	# isolate relation from object (ie, separate CV's)

# Read in the cue validities listing
# TODO: rework cue-validity format to facilitate parsing
my(%cue_validity);
foreach (split(/\n/, &read_file($weight_file))) {
    # ex: 'noun:wine#1 (substance#1):  { n/a->noun:wine:1.000, verb:is->noun:juice:1.000, ...'
    if (/(\S+) \((\S+)\):\s+{ (.*) }/) {
	my($headword, $category, $features) = ($1, $2, $3);

	foreach my $feature_spec (split(/,\s*/, $features)) {
	    my($feature, $weight) = ($feature_spec =~ /(\S+):([0-9.]+)/);
	    &set_entry(\%cue_validity, "$headword\t$feature", $weight) unless (!defined($weight));
	}
    }
}
&assert((scalar %cue_validity));

# Reweight the input listing
#
my($min_weight) = 0.001;
my(@relationships);
my($max_relation_weight) = 0.0;
my($category) = "";
my($headword) = "";
#
while (<>) {
    &dump_line();
    chomp;

    # Determine the headword and the category for which cue validities
    # are calculated relative to
    # ex: 'noun:reproduction#4:'
    if (/^(\S+):/) {
	$headword = $1;
    }
    elsif (/^(\S+) \((\S+)\):/) {
	$headword = $1;
	$category = $2;
    }

    # Reweight the weapon using the product of the cue-validites for
    # the relation and object term
    if (/(\S+)\t(\S+)\s+\((\S+)\)/) {
	my($relation, $object, $old_weight) = ($1, $2, $3);

	# Drop offset indicators from relation. Also, just use the relation
	# type (i.e., ignore relation word).
	my($relation_type) = $relation;
	$relation_type =~ s/\-\d+\-\d+//;
	$relation_type =~ s/^[^\#]+\#// unless ($full_relation);
	
	# Derive the new weight using one of two methods:
	#
	# 1. Combine separate cue validities for the relation and the object
	my($new_weight);
	if ($isolate) {
	    my($relation_type_weight) = &get_entry(\%cue_validity, "$headword\t$relation_type", $min_weight);
	    my($object_weight) = &get_entry(\%cue_validity, "$headword\t$object", $min_weight);
	    $new_weight = $relation_type_weight * $object_weight * $old_weight;
	}
	#
	# 2. Use single cue validity for the (relation, object) taken together.
	else {
	    my($feature) = "${relation_type}->$object";
	    my($feature_weight) = &get_entry(\%cue_validity, "$headword\t$feature", $min_weight);
	    $new_weight = $feature_weight * $old_weight;
	}

	s/\($old_weight\)/\($new_weight\)/;

	$max_relation_weight = &max($new_weight, $max_relation_weight);
    }

    # Add the input line to the relationship listing
    push(@relationships, $_);
}

# Optionally, normalize the relation weights
# TODO: support local normalization in addition to global normalization
if ($normalize) {
    foreach (@relationships) {
	if (/\S+\t\S+\s+\((\S+)\)/) {
	    my($old_weight) = $1;
	    my($new_weight) = $old_weight / $max_relation_weight;
	    s/\($old_weight\)/\($new_weight\)/;
	}
    }
}

# Print the revised relation listing
map { print "$_\n"; } @relationships;

&exit();
