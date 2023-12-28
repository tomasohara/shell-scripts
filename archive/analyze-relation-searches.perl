# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# analyze-relation-searches.perl: analyzes the relation web searches to find
# syntactic patterns indicative of the relation in question
#
# The input is assumed to be a listing of the web searches for all instances
# of a single relation type (e.g., is-function-of), where individual relation
# searches are of the form 'source NEAR target'. The result will be a listing
# of the most common patterns used to indicate the relation.
#
# This works by checking for sentences in the resulting search that contain
# both the source and target, and then determining the syntactic relation
# that holds between the source and target term.
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';
require 'extra.perl';

# Show a usage statement if no arguments given
# NOTE: By convention - is used when no arguments are required
if (!defined($ARGV[0])) {
    my($options) = "main options = []";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "examples:\n\n$script_name example\n\n";  # TODO: example
    ## $example .= "$0 example2\n\n";		   	     # TODO: 2nd example
    my($note) = "";
    ## $note .= "notes:\n\nSome usage note.\n";		     # TODO: usage note

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n$note";
}

# Check the command-line options
# note: Each variable initialized corresponds to a -var=value commandline option
&init_var(*max, 5);		# maximum number of patterns to show

my($source) = "";
my($target) = "";
my(@sentences);
my(%patterns);

while (<>) {
    &dump_line();
    chomp;

    # Check for next query
    # ex: http://www.altavista.com/cgi-bin/query?q=Completeness+NEAR+supplementation&pg=ps&sb=bool&nbq=50&stq=50&kl=en
    if (/query\?q=(\S+)\+NEAR\+(\S+)\&pg/) {

	# Analyze the previous batch of sentences
	&analyze_sentences($source, $target, \@sentences, \%patterns);

	# Reset the collection
	$source = $1;
	$target = $2;
	@sentences = ();
	&debug_print(&TL_DETAILED, "new relationship ($source, $target)\n");
	next;
    }
    next if ($source eq "");

    # See if the target and source are mentioned in the same sentence
    # TODO: weed out search-engine specific output
    if (/(\b$source\b.*\b$target\b)|(\b$target\b.*\b$source\b)/) {
	push(@sentences, $_);
    }
}

# Analyze the last batch of sentences
&analyze_sentences($source, $target, \@sentences, \%patterns);

# Print the top-N patterns
print "Relation patterns:\n";
print &format_freq_data(\%patterns, $max);

&exit();


#------------------------------------------------------------------------------

# analyze_sentences(source_term, target_term, sentence_list_ref, pattern_assoc_ref)
#
# Determines the syntactic patterns that relates source term and target term
# in the sentences.
#
sub analyze_sentences {
    my($source, $target, $sentences_ref, $patterns_ref) = @_;
    &debug_print(&TL_VERBOSE, "analyze_sentences(@_)\n");
    my($sentence);

    foreach $sentence (@$sentences_ref) {
	# Filter out garbage sentences
	# TODO: use more principled filtering
	next if ($sentence =~ /( NEAR )|(Search for.*yellow pages)|(search again without a specified language)|(at eBay)|(Comparison shop for )/);
		 

	&debug_print(&TL_DETAILED, "parsing sentence '$sentence'\n");
	my($parse) = &run_command_over("link_parser.sh --limit 1", $sentence);
	&debug_print(&TL_VERBOSE, "parse:{\n$parse\n}\n");
	my($linkages) = &run_command_over("perl -Ssw extract_linkages.perl -raw", $parse);
	my($pattern) = &find_linkage_path($linkages, $source, $target);
	&incr_entry($patterns_ref, $pattern);
    }

    return;
}


# find_linkage_path(linkage_listing, source, target)
#
# Return the linkage path between source and target.
#
sub find_linkage_path {
    my($linkage_listing, $source, $target) = @_;
    my(@linkages) = split(/\n/, $linkage_listing);

    # Accumulate the tokens in the pattern
    my($pattern) = find_linkage_path_aux(\@linkages, $source, $target);
    if ($pattern eq "") {
	$pattern = find_linkage_path_aux(\@linkages, $target, $source);
	$pattern .= "\t<-" if ($pattern ne "");
    }
    &debug_print(&TL_DETAILED, "pattern='$pattern' for ($source, $target)\n");

    return ($pattern);
}


# find_linkage_path_aux(linkages_list_ref, source, target)
#
# Return the linkage path between from source to target. The result
# is a tab-delimited string of the words from the parse omitting the
# part-of-speech indicators.
#
# Example: TODO
#
sub find_linkage_path_aux {
    my($linkages_ref, $source, $target) = @_;
    &debug_print(&TL_VERBOSE, "find_linkage_path_aux(@_)\n");
    my($i);
    my($valid) = &FALSE;
    my(@linkages) = @$linkages_ref;

    my($pattern) = "";
    $source = &regex_escape(&to_lower($source));
    $target = &regex_escape(&to_lower($target));
    for ($i = 0; $i <= $#linkages; $i++) {
	&debug_print(&TL_VERY_DETAILED, "linkage[$i] = ${linkages[$i]}\n");
	$linkages[$i] =~ s/\[.\]//g;
	# TODO: figure out Perl problem in the following
	# ex: Unmatched ) before HERE mark in regex m/<) << HERE (\..)?, \S+, (\S+)(\..)?>/
	## if ($linkages[$i] =~ /\<$source(\..)?, \S+, (\S+)(\..)?\>/i)
	if (($linkages[$i] =~ /\<(\S+)(\..)?, \S+, (\S+)(\..)?\>/)
	    && (&to_lower($1) eq $source)) {
	    my($new_source) = $2;
	    ## &assert(defined($new_source));
	    $new_source = "" if (!defined($new_source));

	    $pattern .= "\t" if ($pattern ne "");
	    $pattern .= $new_source;

	    $source = $new_source;
	}
	## if ($linkages[$i] =~ /, $target(\..)?>/i)
	if (($linkages[$i] =~ /, (\S+)(\..)?>/) 
	    && (&to_lower($1) eq $target)) {
	    $valid = &TRUE;
	    last;
	}
    }
    if (! $valid) {
	$pattern = "";
    }

    return ($pattern);
}


# regex_escape(string): add escape chacaters to the string for use in Perl regular
# expression matching
#
# ex: "What?" => "What\?"
#
# TODO: place in common.perl
#
sub regex_escape {
    my($string) = @_;

    $string =~ s/(\W)/\\$1/g;
    &debug_print(&TL_VERY_VERBOSE, "regex_escape(@_) => '$string'\n");

    return ($string);
}
