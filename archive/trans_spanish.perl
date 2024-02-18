# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -s
#
# trans_spanish.perl: quick and dirty translation of Spanish text.
# Currently, this is just a dictionary lookup.
#
# Copyright (c) 2005-2019 Tom O'Hara and New Mexico State University.
# Freely available via GNU General Public License (see GNU_public_license.txt).
#
# NOTE:
# - Obsolete version: use qd_trans_spanish.perl instead.
#


# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';
require 'spanish.perl';

# Set defaults for the dictionary, etc. These can be specified on command
# line, as follows:
#
#    perl -s trans_spanish.perl -user_dict=test_dict.list < text_file
#
# $user_dict = "" unless defined($user_dict);

# Read in the Spanish dictionary
#
&read_spanish_dict();

# Get the translations for each word in the text. Output each word with
# its translation on a separate line.
#
while (<>) {
    &dump_line($_);
    $text = $_;
    while ($text =~ /$word_pattern/i) {
	$delim = $`;
	$word = $1;
	$rest = $';

	if ($delim !~ /[\t\n ]*/) {
	    &debug_out(5, "$delim (%X)", $delim);
	    print "$delim\n";
	}
	&debug_out(5, "$word ");

	## $word =~ tr/A-Z ÁÉÍÓÚÑÜ/a-záéíóúñü/;
	$word = &to_lower($word);
	$translation = "n/a";
	if (defined($trans{$word})) {
	    $translation = $trans{$word};
	}
	else {
	    ($root, $tense) = &stem_verb($word);
	    if (($root ne "") && (defined($trans{$root}))) {
		$translation = "($root $tense) $trans{$root}";
	    }
	    else {
		($root, $person) = &stem_noun($word);
		if (($root ne "") && (defined($trans{$root}))) {
		    $translation = "($person) $trans{$root}";
		}
	    }
	}
	print ("$word:\t$translation\n");
	$text = $rest;
    }
    print "$text\n\n";		# print remainder
}


# check_word: lookup the translation for a word
#
sub check_word {
    local($word) = @_;
    local($verb, $tense) = &stem_verb($word);
    local($noun, $person) = &stem_noun($word);

    if ($verb ne "") {
	print "$word:\t($verb, $tense)\t$trans{$verb}\n";
    }
    if ($noun ne "") {
	print "$word:\t($noun, $person)\t$trans{$noun}\n";
    }
}
