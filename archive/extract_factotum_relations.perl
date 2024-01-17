# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# extract_factotum_relations.perl: extracts the relations from the Factotum
# knowledge base (by Micra). Factotum is based on Roget's thesarus and includes
# additional links to make explicit many of the semantic relatedness relations.
#
# TODO;
# - get access to ThesView (by Alexander Gelbukh)
# - handle relations with properties (eg '{{has_part(bicycle): wheel[num=2]}}')
# - handle relational terms with slashes (e.g., 'set/run')
# - handle remaining special case relation formatting
#   ex: has_subtype(agreement[to=rule, @R697]   admissibility
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

# Show a usage statement if no arguments given
# NOTE: By convention - is used when no arguments are required
if (!defined($ARGV[0])) {
    my($options) = "main options = []";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "examples:\n\n$script_name fsn.txt >| factotum.relations\n\n";
    ## $example .= "$0 example2\n\n";		   	     # TODO: 2nd example
    my($note) = "";
    ## $note .= "notes:\n\nSome usage note.\n";		     # TODO: usage note

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n$note";
}

# Check the command-line options
# note: Each variable initialized corresponds to a -var=value commandline option
## &init_var(*fu, &FALSE);		# TODO: add command-line options

my($category) = "";

print "# Source\tRelation\tTarget\n";
while (<>) {
    &dump_line();
    chomp;

    # Check for the Roget's category name
    # ex: "	#52. Completeness."
    if (/^\s*\#\d+\w?\.(.*)\.\s*$/) {
	$category = &trim($1);
	&debug_out(&TL_VERBOSE, "current category: $category\n");
	next;
    }

    # Similarly, check for Factoum category name
    # ex: P2.3.1.3.4.2  Poison
    # ex: P2.3.2.3.6.5.46 POSSESSOR  (R779)
    if (/^\w(\d+\.)+\d+\s*([^\(]+)/) {
	$category = &trim($2);
	&debug_out(&TL_VERBOSE, "current category: $category\n");
	next;
    }

    # Don't process unless the first category has been extracted
    next if ($category eq "");

    # Extract the words and phrase in the current 'paragraph'\
    # ex: "{{has_subtype}} volley, shower, storm, cloud"
    #   => ("volley", "shower", "storm", "cloud")
    my(@words);
    if (/([^{}]+)$/) {
	# Remove the qualifiers from the words and then tokenize
	# ex: "Jurassic[180,000,000]" => "Jurassic"
	my($words) = $1;
	$words =~ s/\[[^\]]+\]//g;

	@words = &tokenize($words, "[\,\;]");
    }

    # Extract all the relations for the current category
    while (/{{([^{}]+)}}/) {
	my($relation) = $1;
	$_ = $';
	my($head) = $category;

	# Check for relations specify alternative heads
	# ex: has_subtype(group)
	if ($relation =~ /\((.*)\)/) {
	    $relation = $`;
	    $head = $1;
	}

	# Check for relations that especify additional properties
	# ex: {{has_subtype(perish): die &c. R360}}
	# NOTE: These are ignored for now
	if ($relation =~ /:(.*)/) {
	    &debug_out(&TL_VERBOSE, "ignoring relations with properties: $relation\n");
	    next;
	    ## $relation = $`;
	    ## &assert((scalar @words) == 0);
	    ## @words = &tokenize($1, "[\.\,\;]");
	}

	# Print the relation appied to each word
	# TODO: make sure this is not over-distibuting the words
	my($word);
	foreach $word (@words) {
	    $word = &strip_qualifiers($word);
	    $head = &strip_qualifiers($head);
	    if (($head ne "") && ($word ne "")) {
		print "$head\t$relation\t$word\n";
	    }
	}
    }
}

&exit();


#------------------------------------------------------------------------------

# strip_qualifiers(word): removes qualifiers and relation indicators from the
# word or relation
#
# ex: strip_qualifiers("cartload[obs3]") => "cartload"
# ex: strip_qualifiers("nearness, P1.2.2.2.1.3.3, R197" => "nearness"
#
sub strip_qualifiers {
    my($word) = @_;

    # Remove the various qualifiers
    $word =~ s/\.\s*//;			# oblation.
    $word =~ s/\[.*\]//;		# nihility[obs3]
    $word =~ s/R\d+[a-z]?//;		# fraction, R100a
    $word =~ s/[APM]\d+(\.+\d)*//i;	# person, P2.3.2.3
    $word =~ s/@//g;			# wire, @R205
    $word =~ s/,\s*/ /g;		# universe, R318
    $word = &trim($word);
    &debug_print(&TL_VERBOSE, "strip_qualifiers(@_) => '$word'\n");

    return ($word);
}
