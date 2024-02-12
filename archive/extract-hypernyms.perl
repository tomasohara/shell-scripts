# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# extract-hypernyms.perl: gets the WordNet hypernym listing for all words in a text file
#
# Notes:
# - Normally hypernyms are output in #-notations with underscores for spaces (e.g., dog#4, hunting_dog#1) 
# - The options -roman_senses and -no_underscores are used to workaround limitations of the rainbow tokenization (e.g., numbers and underscores stripped).
#
# TODO:
# - add preprocessing? (e.g., via prep_brill.perl)
# - show sample input and output
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = $0; $dir =~ s/[^\\\/]*$//; unshift(@INC, $dir);
    require 'common.perl';
    use vars qw/$verbose/;
}

# Load in other modules
use vars qw/$wn_cache $wn_cache_dir $uncached $wn_use_cache/;
&init_var(*wn_cache, "extract-hypernyms"); # separate cached used since different wn_get_ancestors settings
&init_var(*wn_cache_dir, $TEMP);
&init_var(*uncached, &FALSE);		# should cached data be skipped
&init_var(*wn_use_cache, ! $uncached);	# whether the results should be cached
require 'wordnet.perl';

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;

# Show a usage statement if no arguments given.
# NOTE: By convention '-' is used when no arguments are required.
if (!defined($ARGV[0])) {
    my($options) = "main options = [-add_syns] [-all_hypernyms]";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "Example(s):\n\necho how now brown cow | $script_name - | less\n\n";  # TODO: example
    ## $example .= "$0 example2\n\n";		   	     # TODO: 2nd example
    my($note) = "";
    ## $note .= "Notes:\n\nSome usage note.\n\n";	     # TODO: usage note

    print STDERR "\nUsage: $script_name [options]\n\n$options\n\n$example\n$note";
    &exit();
}

# Check the command-line options
# note: Each variable initialized corresponds to a -var=value commandline option
use vars qw/$add_syns $all_hypernyms $word_tokens $roman_senses $no_underscores/;
&init_var(*add_syns, &FALSE);		# include synonyms
&init_var(*all_hypernyms, &TRUE);	# include all hypernyms (i.e., all entries in hypernym synset)
&init_var(*word_tokens, &FALSE);	# convert hypernym specification into valid word tokens (e.g., -roman_senses and -no_underscores)
&init_var(*roman_senses, $word_tokens);	# use roman numerals for senses (e.g., hunting_dog#1 => hunting_dog_i)
&init_var(*no_underscores, $word_tokens); # don't include underscores (e.g., hunting_dog#1 => huntingdog#1)

# Initialize access to WordNet
&debug_print(&TL_DETAILED, "wn_cache=$wn_cache\n");
&wn_init();

# Replace each word from stdin with hypernym information from WordNet
#
my($count) = 0;
#
while (<>) {
    &dump_line();
    chomp;
    print "{sentence: $_}\n\n" if ($verbose);

    # Replace each word with its hypernym listing
    foreach my $word (&tokenize($_)) {
	$count++;
	if ($word =~ /^((\d+)|(\W+))$/) {
	    &debug_print(&TL_DETAILED, "skipping non-word token: $word\n");
	    next;
	}
	if ($verbose) {
	    print "--------------------------------------------------------------------------------\n\n" if ($count > 0);
	    print "{word: $word}\n";
	}
	print &get_hypernyms($word), "\n";
    }

    print "================================================================================\n" if ($verbose);
}

# Cleanup access to WordNet
&wn_cleanup();

# The end
&exit();

#------------------------------------------------------------------------------

# get_hypernyms(word): gets the WordNet hypernym entry 
#
sub get_hypernyms {
    my($word) = @_;
    &debug_print(&TL_VERBOSE, "get_hypernyms(@_)\n");

    my($ancestors) = "";
    foreach my $POS ("noun", "verb", "adjective", "adverb") {
	$ancestors .= &wn_get_ancestors($word, $POS, $add_syns, $all_hypernyms);
    }

    # Postprocess the hypernyms
    if ($roman_senses) {
	$ancestors =~ s/\#(\d+)/"_" . ("i" x $1)/eg;
    }
    if ($no_underscores) {
	$ancestors =~ s/_//g;
    }

    return ($ancestors);
}
