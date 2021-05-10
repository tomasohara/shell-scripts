# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# spost2penn.perl: convert from CRL's spost output into the Penn Treebank
#                  style (w/ associated tags)
#
# Read in the part-of-speech tagger listing
# Currently this assumes CRL's Spanish POST (SPOST)
#
# Example:
# [17,17,'empleado','empleado',noun(masculine,singular), pos].
# [18,18,'de','de',preposition, pos].
# [19,19,'una','una',article(feminine,indefinite,singular), pos].
# [20,20,'tienda','tienda',noun(feminine,singular), pos].
#
# TODO: use the SPOST additional type information to provide more
#       specific Penn tags
#       ex: for <'diciendo','decir',verb(morphology(present_part,none),[])>
#           use VBG instead of just VB
#
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';
require 'spanish.perl';

while (<>) {
    &dump_line($_, 7);
    chop;

    # Fix up the proper_noun tagging, which just about labels everything
    # in capitals.
    if (/proper_noun\(([^\(\)]+)[\(\)]/ && ($1 ne "unknown")) {
    ## if (/proper_noun\(([a-z_]+)[()]/ && ($1 ne "unknown")) {
	$real_type = $1;
	&assert('length($real_type) > 0');
	s/proper_noun/$real_type/;
	&debug_out(4, "proper_noun($real_type => $real_type($real_type\n");
    }

    # Remove the type qualifications (anything in parenthesis)
    s/\(.*\)//;			# remove parentheses and bracketted text
    s/[\[\]]//g;		# remove the square brackets
    s/,',',/,'<COMMA>',/g;	# use special tag for comma's (see split below)
    s/,',',/,'<COMMA>',/g;	# patterns might overlap so try again

    # Split the line into the fields
    ($start, $end, $word, $word_alt, $POS, $type) = split(/,/, $_);
    &debug_out(6, "s=$start e=$end w=$word a=$word_alt p=$POS t=$type\n");
    &assert('defined($type)');

    # Remove the quotes from the word
    # NOTE: The case is retained since this is a useful clue for proper name
    #       recognition, etc.
    $word =~ s/\'//g;
    if ($word eq "**single_quote**") {
	$word = "'";
    }
    if ($word eq "**open_paren**") {
	$word = "(";
    }
    if ($word eq "**closed_paren**") {
	$word = ")";
    }
    $word =~ s/<COMMA>/,/g;
    ## $word = &sp_to_lower($word);

    # Skip punctuation
    if ($POS eq "punc") {
	print "$word/$word ";
	next;
    }

    # Convert some of the tags
    $penn_tag = &convert_spost_tag($POS);

    # Each word in Multiple-word taggings gets same tag
    $word =~ s/ /\/$penn_tag /g;

    print "\n" if ($start == 1);
    print "$word/$penn_tag ";
}
print "\n";


# init_tags(): initialize correspondences between post and penn tags
#
sub init_tags {

    %penn_tag = ("", "",
		 "adjective", "JJ",
		 "adverb", "RB",
		 "article", "DT",
		 "auxiliary", "VB",
		 "complementizer", "IN",
		 "conjunction", "CC",
		 "noun", "NN",
		 "number", "CD",
		 "preposition", "IN",
		 "pronoun", "PP",
		 "proper_noun", "NNP",
    		 "verb", "VB",
		 );
    return;
}


# convert_spost_tag(POS_tag)
#
# Convert from the tag conventions of CRL's SPOST into Penn Treebank's.
#
sub convert_spost_tag {
    local ($tag) = @_;
    local ($penn_tag) = "UNK";
    init_tags() if (!defined($penn_tag{"verb"}));
    &assert('defined($penn_tag{"verb"})');

    if (defined($penn_tag{$tag})) {
	$penn_tag = $penn_tag{$tag};
    }
    &debug_out(5, "convert_spost_tag($tag) => $penn_tag\n");

    return ($penn_tag);
}


