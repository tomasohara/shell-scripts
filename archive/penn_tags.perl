# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
# penn_tags.perl:
#
# Module for converting between Penn Treebank tags and the traditional
# parts-of-speech.
#
# Global variables:
#   %cat2penn	associative list giving Treebank tag for traditional one
#   %penn2cat	associative list giving traditional tag for Treebank one
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';


# init_penn_tags(): initialize correspondences between Penn Treebank tags
# and traditional parts-of-speech.
# NOTE: see http://www.ling.upenn.edu/courses/ling001/penn_treebank_pos.html
#

sub init_penn_tags {

    %cat2penn = ("", "",
	"adjective", "JJ",
        "adverb", "RB",
        "article", "DT",
        "auxiliary", "MD",
        "complementizer", "IN",
        "conjunction", "CC",
	"determiner", "DT",
        "noun", "NN",
        "number", "CD",
        "preposition", "IN",
        "pronoun", "PP",
        "proper_noun", "NNP",
	"punctuation", "SYM",
        "verb", "VB",
        );
    %penn2cat = ("", "",
	"CC", "conjunction",	# Coordinating conjunction
	"CD", "number",		# Cardinal number
	"DT", "determiner", 	# Determiner
	"EX", "pronoun", 	# Existential there
	"FW", "noun", 		# Foreign word
	"IN", "preposition", 	# Preposition or subordinating conjunction
	"JJ", "adjective", 	# Adjective
	"JJR", "adjective", 	# Adjective, comparative
	"JJS", "adjective", 	# Adjective, superlative
	"LS", "punctuation", 	# List item marker
	## "MD", "verb", 		# Modal
	"MD", "auxiliary", 	# Modal
	"NN", "noun", 		# Noun, singular or mass
	"NNS", "noun", 		# Noun, plural
	"NNP", "noun", 		# Proper noun, singular
	"NNPS", "noun", 	# Proper noun, plural
	"PDT", "determiner", 	# Predeterminer
	"POS", "punctuation", 	# Possessive ending
	"PP", "pronoun", 	# Personal pronoun
	"PP\$", "pronoun", 	# Possessive pronoun ???
	"PRP\$", "pronoun", 	# Possessive pronoun
	"PRP", "pronoun", 	# Personal pronoun
	"RB", "adverb", 	# Adverb
	"RBR", "adverb", 	# Adverb, comparative
	"RBS", "adverb", 	# Adverb, superlative
	"RP", "preposition", 	# Particle
	"SYM", "punctuation", 	# Symbol
	"TO", "preposition", 	# to
	"UH", "punctuation", 	# Interjection
	"VB", "verb", 		# Verb, base form
	"VBD", "verb", 		# Verb, past tense
	"VBG", "verb", 		# Verb, gerund or present participle
	"VBN", "verb", 		# Verb, past participle
	"VBP", "verb", 		# Verb, non-3rd person singular present
	"VBZ", "verb", 		# Verb, 3rd person singular present
	"WDT", "determiner", 	# Wh-determiner
	"WP", "pronoun", 	# Wh-pronoun
	"WP\$", "pronoun", 	# Possessive wh-pronoun
	"WRB", "adverb", 	# Wh-adverb
	);

    return;
}


# convert_cat_to_penn(POS_tag)
#
# Convert from traditional part-of-speech category into Penn Treebank's tag.
# TODO: reconcile with convert_spost_tag from spost2penn.perl
#
sub convert_cat_to_penn {
    local ($cat) = @_;
    local ($penn_tag) = "UNK";
    assert('defined($cat2penn{"verb"})');

    if (defined($cat2penn{$cat})) {
        $penn_tag = $cat2penn{$cat};
    }
    &debug_print(7, "convert_cat_to_penn($cat) => $penn_tag\n");

    return ($penn_tag);
}


sub convert_penn_to_cat {
    local ($penn_tag) = @_;
    local ($cat) = $penn_tag;
    assert('defined($penn2cat{"VB"})');

    if (defined($penn2cat{$penn_tag})) {
        $cat = $penn2cat{$penn_tag};
    }
    if ($cat =~ /^\W+$/) {
	$cat = "punctuation";
    }
    &debug_print(7, "convert_penn_to_cat($penn_tag) => $cat\n");

    return ($cat);
}

# read_pos_tags(file, words, tags, [convert=1])
#
# Read in the part-of-speech tagger listing, in Penn Treebank format
# (eg, produce by Brill tagger). The result is returned in parallel
# lists: one for the words, the other for the tags. (The number of
# tokens read in returned as the function result.)
#
# example:
#
# In/IN addition/NN ,/, the/DT administration/NN agreed/VBD that/IN
# Washington/NN will/MD give/VB schools/NNS more/JJR flexibility/NN in/IN 
# the/DT use/NN of/IN federal/JJ education/NN funds/NNS ,/,
# ...
#

sub read_pos_tags {
    local($file, *words, *tags, $convert) = @_;
    $convert = &TRUE if (!defined($convert));
    local($num) = 0;

    &reset_trace();
    if (!open(POST, "<$file")) {
	&debug_print(3, "warning: unable to read POS $file ($!)\n");
	return (0);
    }
    while (<POST>) {
        &dump_line("post: $_", 7);
 
	local($token);
        foreach $token (split) {
            local($word, $tag) = split('/', $token);
	    if ($convert) {
		$tag = &convert_penn_to_cat($tag);
	    }
	    $words[$num] = $word;
	    $tags[$num] = $tag;
	    $num++;
        }
    }
    close(POST);

    return ($num);
}


#-----------------------------------------------------------------------------

&init_penn_tags();

1;				# tell Perl we loaded OK
