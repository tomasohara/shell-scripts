# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# wn_polysemy.perl: retrieves the WordNet polysemy for a list of words
#
# The words with optional part-of-speech are taken from standard input.
# The format is "<word>[:<POS>]" (e.g., "dog:verb"). Whitespace delimites
# multiple cases on a line. A polysemy of -1 means that the word wasn't
# found in wordnet in the given part-of-speech.
#
# Tom O'Hara
# June 1999
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir);
    require 'common.perl';
    require 'wordnet.perl';
}

use strict;
use vars qw/$POS/;

# Show usage statement if insufficient arguments
#
if (!defined($ARGV[0])) {
    my($options) = "options = [-POS=type]";
    my($example) = "examples:\n\n$0 - < words.list\n\n";
    $example .= "echo \"verb:scrap\" | $0 -\n\n";
    $example .= "echo \"how now brown cow\" | $0 -POS=verb -\n\n";
    my($note) = <<END_NOTE;

The words with optional part-of-speech are taken from standard input.
The format is

    [<POS>]:<word>	where POS is {noun|verb|adj|adv}

(e.g., "verb:dog", "money", "adverb:happily"). Whitespace delimites
multiple cases on a line. 

A polysemy of -1 means that the word/POS combination wasn\'t found in WordNet.

A file specification of - indicates standard input.

The default part-of-speech is noun.

END_NOTE

    print STDERR "\nusage: $0 [options] filespec\n\n$options\n\n$example\nNOTES:\n$note\n";
    &exit();
}

# Initialize command-line arguments
&init_var(*POS, "noun");

$POS =~ s/adjective/adj/;
$POS =~ s/adverb/adv/;
my($word, $word_with_POS, $word_POS);

# Show polysemy wor each word specified on each line of the input
# TODO: have option to omit the part-of-speech (e.g., if just processing nouns)
printf "# word:POS\tpolysemy\n";
while (<>) {
    chomp;
    foreach $word_with_POS (split) {
	my($word_POS) = $POS;
        my($word) = $word_with_POS;
	if ($word_with_POS =~ /^(\w+):(.*)/) {
	    ($word_POS, $word) = ($1, $2);
	}
	my($polysemy) = &wn_get_polysemy($word, $word_POS);

	printf "%s:%s\t%d\n", $word, $word_POS, $polysemy;
    }
}
