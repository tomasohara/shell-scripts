# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# make_pos_features.perl: make feature table for inferring part of speech from Cyc
# types
#
# Portions Copyright (c) 2001 Cycorp, Inc.  All rights reserved.
#
# TODO:
# - have an option to filter types by generality estimate (eg, upper and lower bounds)
# - separate the feature specification from the parent extraction, so that the
#   lenghty extraction process needs only be done once
#

# Load in the common module, making sure the script dir is first in Perl's lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';
require 'NL_support.perl';

# Process the command-line options
if (!defined($ARGV[0])) {
    my($options) = "options = [-num_type_features=N] [-max_instances=N]";
    my($example) = "examples:\n\n$script_name .EnglishMt.data\n\n";
    my($note) = "Note: By default, 10 feature buckets are used.";

    die "\nusage: $script_name [options] mt-listing ...\n\n$options\n\n$example\n$note\n";
}

&init_var(*num_type_features, 10);	# number of hashed type feature positions
&init_var(*max_instances, &MAXINT);	# maximum number of instances or cases to output

# Init TCP access to Cyc server and load in supporting lisp code if necessary
&init_NL_support();

# Misc. initializations
my($default_feature_value) = "-";
my(@num_feature_conflicts) = (0) x $num_type_features;
my($instance_count) = 0;

# Check for denotational assertions in MT listing(s) and extract the features
#
while (<>) {
    chomp;
    &dump_line();
    my($assertion) = $_;
    my($pre_head, $headword_unit, $post_head, $speech_part, $term);

    # Extract the term (i.e., denotatum) information from the semantic assertions
    #
    # ex: (multiWordString ("police") Officer-TheWord SimpleNoun LawEnforcementOfficer)
    if ($assertion =~ /\[\S+\] \(multiWordString \(([^\)]+)\) (\S+) (\S+) (.*)\)/) {
	($pre_head, $headword_unit, $speech_part, $term) = ($1, $2, $3, $4);
    }
    # ex: (compoundString System-TheWord ("of" "belief") SimpleNoun BeliefSystem)
    elsif ($assertion =~ /\[\S+\] \(compoundString (\S+) \(([^\)]+)\) (\S+) (.*)\)/) {
	($headword_unit, $post_head, $speech_part, $term) = ($1, $2, $3, $4);
    }
    # ex: (headMedialString ("formal") Code-TheWord ("of" "conduct") SimpleNoun FormalCOC)
    elsif ($assertion =~ /\[\S+\] \(headMedialString \(([^\)]+)\) (\S+) \(([^\)]+)\) (\S+) (.*)\)/) {
	($pre_head, $headword_unit, $post_head, $speech_part, $term) = ($1, $2, $3, $4, $5);
    }
    # ex: (denotation Symposium-TheWord SimpleNoun 0 MeetingTakingPlace)
    elsif ($assertion =~ /\[\S+\] \(denotation (\S+) (\S+) \d+ (.*)\)/) {
	($headword_unit, $speech_part, $term) = ($1, $2, $3);
    }
    next if (!defined($term));
    &debug_print(&TL_DETAILED, "# assertion='$assertion'\n");
    &debug_print(&TL_DETAILED, "# term=$term POS=$speech_part\n");

    # Determine the types associated with the term
    my(@parents) = &term_types($term);
    push(@parents, &term_generalizations($term));
    &debug_out(&TL_DETAILED, "# parents:\t%s\n", join("\t", @parents));

    # Assign each of the parents to the appropriate hash bucket
    my(@features) = ($default_feature_value) x $num_type_features;
    for (my $i = 0; $i <= $#parents; $i++) {
	my($position) = &type_hash_bucket($parents[$i]);
	if ($features[$position] ne $default_feature_value) {
	    &debug_out(&TL_VERBOSE, "conflict at bucket $i: %s replacing %s\n",
		       $parents[$i], $features[$position]);
	    $num_feature_conflicts[$position]++;
	}
	$features[$position] = $parents[$i];
    }

    # Print the feature list
    printf "%s\t%s\n", $speech_part, join("\t", @features);
    last if ($instance_count++ > $max_instances);
}

# Display information on conflicts in feature assignments
&debug_out(&TL_DETAILED, "feature conflict counts:\n\t%s\n",
	   join("\t", @num_feature_conflicts));

&exit();

#------------------------------------------------------------------------

# eval_cyc_meaning_function: Evaluate denotation-type function applied to the term
# (with proper lisp escaping applied, such as for embedded quotes).
#
sub eval_cyc_meaning_function {
    my($function, $term) = @_;
    return (&cyc_meaning_function(&function_over_term($function, $term)));
}

# term_types(term): returns all cyc types associated with term
#
sub term_types {
    return (&eval_cyc_meaning_function("all-isa-in-any-mt", @_));
}

# term_generalizations(term): returns all cyc collections that generalize the cyc term
# note: the term itself is not returned in the list
# TODO: define an efficient function to remove an element from a list
#
sub term_generalizations {
    my($term) = @_;
    my(@generalizations) = &eval_cyc_meaning_function("all-genls-in-any-mt", @_);
    my($discarded_term) = pop(@generalizations);
    &assert($discarded_term eq $term);

    return (@generalizations);
}

# type_hash_bucket(term): return hash value for Cyc type modulo number of buckets
# TODO: implement this in Perl
#
sub type_hash_bucket {
    my($term) = @_;
    $term = &escape_string($term);
    my($hash_bucket) = &cyc_function_fmt("(mod (sxhash \"%s\") %d)",
					 $term, $num_type_features);
    return ($hash_bucket);
}

