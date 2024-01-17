# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -s
#
# qd_trans_english.perl: quick and dirty translation of English text.
# Currently, this is just a dictionary lookup.
#


# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';
require 'english.perl';
use vars qw/$eng_options $eng_word_pattern $d/;

# Set defaults for the dictionary, etc. These can be specified on command
# line, as follows:
#
#    perl -s trans_english.perl -user_dict=test_dict.list < text_file
#
# $user_dict = "" unless defined($user_dict);

# Read in the English dictionary
#
&eng_read_dict();

# Print a header comment
print "# word:  translation\n";

# Get the translations for each word in the text. Output each word with
# its translation on a separate line.
#
while (<>) {
    &dump_line($_);
    $text = $_;
    while ($text =~ /$eng_word_pattern/i) {
	$delim = $`;
	$word = $1;
	$rest = $';

	if ($delim !~ /[\t\n ]*/) {
	    &debug_out(5, "$delim (%X)", $delim);
	    print "$delim\n";
	}
	&debug_out(5, "$word ");

	$word = &eng_to_lower($word);
	$translation = &eng_lookup_word($word);
	print ("$word:\t$translation\n");
	$text = $rest;
    }
    print "$text\n\n";		# print remainder
}
