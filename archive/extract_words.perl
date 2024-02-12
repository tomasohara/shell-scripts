# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -s
#
# trans_spanish.perl: quick and dirty translation of Spanish text.
# Currently, this is just a dictionary lookup
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';
require 'spanish.perl';


# Get the dictionary entry for each word in the file

while (<>) {
    &dump_line($_);
    $text = $_;

    # Process the line word by word
    while ($text =~ /$word_pattern/i) {
	$word = $1;
	$remaining_text = $';
	&debug_out(5, "$word ");
	$word = &to_lower($word);
	$key = &remove_diacritics($word);

	# First, lookup the word as is (ie, w/o stemming it)
	$entry = get_dict_entries($key);

	# Determine likely verb and noun stems for the word
	($verb, $tense) = &stem_verb($word, &TRUE);
	if ($verb ne "") {
	    $verb = &remove_diacritics($verb);
	    $entry .= get_dict_entries($verb);
	}
	($noun, $person) = &stem_noun($word, &TRUE);
	if ($noun ne "") {
	    $noun = &remove_diacritics($noun);
	    $entry .= get_dict_entries($noun);
	}

	# As a last resort, search through the dictionary for entries 
	# matching prefixes of the key.
	#   "estamos" then "estamo", "estam", etc.
	while (($entry eq "") && (length($key) > 1)) {
	    $entry = get_dict_entries($key, "");
	    $key = substr($key, 0, length($key) - 1);
	}

	# Print the entry
	debug_out (4, "$word:\t$key: {\n$entry}\n");
	if ($entry eq "") {
	    printf STDERR "No entry found for $word!\n";
	}
	else {
	    print $entry;
	}

	$text = $remaining_text;
    }
}



# get_dict_entries(key): retrieve the entire dictionary entries for words
# matching the key
#
# TODO: match the entire key (not just the prefix)
#

sub get_dict_entries {
    local ($key, $delim) = @_;
    local ($entry);

    $delim = "\t" unless defined($delim);

    $entry = &run_command("grep -i \'^$key$delim\' $spanish_dict");
    $entry .= "\n" unless ($entry eq "");

    return ($entry);
}
