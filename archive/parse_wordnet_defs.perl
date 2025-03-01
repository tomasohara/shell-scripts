# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/bin/perl -sw
#
# parse_wordnet_defs.perl: Parse the definitions from the synsets in the
# specified listing from the wn interface. This currently uses the link
# parser from CMU.
#
# This was designed for use in the lexical-relation extraction system
# based on WordNet differentia (see extract-differentia.perl).
#------------------------------------------------------------------------
# Sample input:
#
# Synonyms/Hypernyms (Ordered by Frequency) of noun wine
#
# Sense 1
# wine, vino -- (fermented juice (of grapes especially))
#        => alcohol, alcoholic beverage, drink, intoxicant, inebriant -- (a liquor or brew containing alcohol as the active agent; "alcohol (or drink) ruined him")
#
# Sample output:
#
# definition:  wine is fermented juice (of grapes especially).
# linkages:
#
# Processed relations:
# <1. wine.n, 2. is.v, 4. juice.n>: 1.000
# <2. is.v, 4. juice.n, 6. of>: 1.000
# <3. fermented.v, mod, 4. juice.n>: 1.000
# <4. juice.n, 6. of, 7. grapes.n>: 1.000
#
# definition:  alcohol is a liquor or brew containing alcohol as the active agent;
#  .
# linkages:
#
# Processed relations:
# <1. alcohol.n, 2. is.v, 6. brew.n>: 0.012
# <11. active.a, mod, 12. agent.n>: 0.111
# <2. is.v, 6. brew.n, 7. containing.v>: 0.012
# <3. a, 6. brew.n, 7. containing.v>: 0.012
# <4. liquor.n, 6. brew.n, 7. containing.v>: 0.012
# <6. brew.n, 7. containing.v, 8. alcohol.n>: 0.012
# <7. containing.v, 8. alcohol.n, 9. as.p>: 0.012
# <8. alcohol.n, 9. as.p, 12. agent.n>: 0.012
#
#........................................................................
# Alternative input sample (raw data format);
#
# 00043865 04 n 03 slip 5 slipup 1 miscue 1 001 @ 00042411 n 0000 | an inadvertent mistake
#
# Output:
#
# parse ID: N00043865
# definition:  wine is fermented juice (of grapes especially).
# linkages:
# TODO: fill in the rest
#
#------------------------------------------------------------------------
# NOTES:
# - Changes to extract_linkages.perl's output format need to be accounted
# here. Likewise, if the (WordNet) parse listing produced by this script
# changes, tuples2lexrel.perl will need to be updated.
#
# - WordNet datafile format (see wndb man page for more info):
#       synset_offset  lexico_filenum  synset_part_of_speech  word_count  word  lex_id  [word  lex_id...]  relation_count  [ptr...]  [frames...]  |  gloss
#
# ex1: 00024491 29 v   01 break a   001  @ 00178565 v   0000 01 + 10 00 | weaken or destroy in spirit or body; "For a hero loves the world till it breaks him"--Yeats
#      offset   df POS WC word1 ID1 #REL R Offset   POS df   frame-info   definition
#
# ex2: 00043865 04 n   03 slip  5   slipup 1   miscue 1   001   @ 00042411 n   0000 | an inadvertent mistake
#      offset   df POS WC word1 ID1 word2  ID2 word3  ID3 #REL  R Offset   POS df     definitions
#
#
#   synset_offset  Byte offset in the file as an 8-digit decimal integer
#    lex_filenum    Two digit integer of lexicographer file for synset
#    ss_type        One character code for synset type (eg, v fo verb)
#    w_cnt          2-digit  hex integer for number of synset words
#    word           ASCII form of word in synset (underscores for spaces)
#    lex_id         1-digit hex integer to uniquely identify sense
#    p_cnt          3-digit integer for number of pointers to other synsets
#    ptr            A pointer from this synset to another of the form
#                        pointer_symbol  synset_offset  pos  source/target
#    frames         for verbs, list of sentence frame numbers
#    gloss          definition and optional example
#
#------------------------------------------------------------------------
# TODO:
# - Standardize the output format with respect to other formats used in
#   computational linguistics (as well as wrt to GraphLing).
# - Expand noun compounds that are not in WordNet into additional relations.
# - Decompose this and other main script bodies into subroutines to allow for
#   easier testing (e.g., test-perl-examnples)
# - Allow for other parsers (e.g., Lin's dependency parser or Collin's statistical parser)
#
# Copyright (c) 2004 Tom O'Hara and New Mexico State University.
# Freely available via GNU General Public License (see GNU_public_license.txt).
#

# Load in the common module, ensuring script dir is first in Perl's lib path
BEGIN {
    my($dir) = `dirname $0`; chop $dir; unshift(@INC, $dir);
    require 'common.perl';

    # Load in other modules
    require 'extra.perl';
    require 'graphling.perl';
    use vars qw/$TOOLS $DATA/;
    require 'wordnet.perl';
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
use vars qw/$WNSEARCHDIR $min_synset_freq $default_synset_freq_file $synset_freq_file $raw $all_defs $all_parses/;

# Check command-line arguments
# TODO: put synset-freq code in wordnet.perl
## &init_var(*WNSEARCHDIR, 	# WordNet dictionary directory
## 	  "$TOOLS/WORDNET-1.7.1/dict");
&init_var(*min_synset_freq, 0);	# min synset freq. for definition to be parsed
&init_var(*raw, &FALSE);	# show raw relations produced by link parser
&init_var(*all_defs, &FALSE);	# parse all WordNet definitions (wn i/f input)
&init_var(*all_parses, &FALSE);	# derive relations from all of the parses

# Show usage statement if input not specified
if (!defined($ARGV[0])) {
    my($options) = "options = [-min_synset_freq=N] [-synset_freq_file=file]";
    my($example) = "examples:\n\nwn mouse -synsn -g -o | $script_name -\n\n";
    $example .= "$0 -min_synset_freq=5 \$WNSEARCHDIR/data.noun";
    my($note) = "Notes:\n\nThe default frequency file is in\n\t${default_synset_freq_file}\n";
    $note .= "See extract_synset_freq.perl\n\n";
    ## $note .= "The offsets must be included in input from WordNet interface if\n";
    ## $note .= "synset frequency filtering is desired.\n";

    print "\nusage: $script_name [options]\n\n$options\n\n$example\n\n$note\n";
    &exit();
}

# Initialize wordnet and read in the synsets
&wn_init();
&init_synset_frequency();

# Current part-of-speech and sense
# NOTE: these are used when parsing output from wn interface
my($POS) = "";			# current part of speech
my($sense) = "";		# current sense number
my($raw_data) = &FALSE;		# data file format (eg., $WNSEARCHDIR/data.noun)

while (<>) {
    &dump_line();
    chop;
    my($definition, $word, $synset_ID);
    my(@synset_members, $synset_member_list);

    # Check for part of speech and sense
    if (/of (noun|verb|adj|adv) /) {
	$POS = $1;
    }
    elsif (/^Sense (\d+)/) {
	$sense = $1;
    }

    # Check for raw data format
    # ex1: 00043865 04 n 03 slip 5 slipup 1 miscue 1 001 @ 00042411 n 0000 | an inadvertent mistake
    # ex2: 00024491 29 v 01 break a 001 @ 00178565 v 0000 01 + 10 00 | weaken or destroy in spirit or body; "For a hero loves the world till it breaks him"--Yeats
    # TODO: put parsing code in wordnet.perl
    #
    #      offset    df  POS  WC     word  ID                     #REL [R Offset   POS df   frame-info   definition]
    #
    elsif (/^(\d{8}) \d+ (\S) ([0-9a-f]+) ((\S+) [0-9a-f] (\S+ [0-9a-f] )*)\d{3} .* \| (.*)/i) {
	#    1           2    3     45                    6                            7
	# TODO: extract all the words to allow for defining-words check
	my($offset) = $1;
	my($POS_letter) = $2;
	my($num_words) = hex($3);
	$synset_member_list = $4;
	$word = $5;
	$definition = $7;
	&debug_print(&TL_VERBOSE, "o=$offset POS=$POS_letter \#w=$num_words syn='$synset_member_list' def=$definition\n");
	$raw_data = &TRUE;

	# Convert synset offset to ID and resolve word sense number
	$POS = &wn_convert_POS_letter($POS_letter);
	$synset_ID = &to_upper($POS_letter) . $offset;
	$sense = &wn_resolve_sense_num($offset, $word, $POS);
	&assert($sense ne "0");

	# Remove lexicographer ID from synset words and add in sense indicators
	# ex: "slip 5 slipup 1 miscue " =>  "slip#2 slipup#1 miscue#2"
	$synset_member_list =~ s/(\S+) [0-9a-f]/$1/g;
	@synset_members = &tokenize($synset_member_list);
	&assert($num_words == (1 + $#synset_members));
	$synset_members[0] = sprintf "%s#%d", $word, $sense;
	for (my $i = 1; $i <= $#synset_members; $i++) {
	    my($other_sense) = &wn_resolve_sense_num($offset, $synset_members[$i], $POS);
	    &assert($other_sense ne "0");
	    $synset_members[$i] = sprintf "%s#%d", $synset_members[$i], $other_sense;
	}

	# TODO: Optionally, restore the spaces in the word
	## $word =~ s/_/ /g;
    }

    # Check for wn interface (i/f) output
    # ex: slip, slipup, miscue -- (an inadvertent mistake)
    # TODO: have option to restrict this just to WN interface input
    elsif (/^(\s*)(.*)--(.*)/) {
	# TODO: check for the synset ID (requires -o offset to wn)
	my($indent) = defined($1) ? $1 : "";
	$synset_member_list = $2;
	$definition = $3;
	$synset_member_list =~ s/ *=> //;
	&debug_print(&TL_VERBOSE, "synset={$synset_member_list} def='$definition' indent='$indent'\n");
	&assert(! $raw_data);

	# Skip the hypernym (or hyponym) definitions
	if ((! $all_defs) && ($indent ne "")) {
	    &debug_print(&TL_VERBOSE, "ignoring hypernym/hypoynym case: $_\n");
	    next;
	}

	# Remove the outer parentheses from the definition
	$definition =~ s/^\s*\(//;
	$definition =~ s/\)\s*$//;

	# Extract the first word from the synset 
	# TODO: account for sense indicators in the listing
	$word = $synset_member_list;
	$word =~ s/,.*//;		# remove other words in the synset
	$word =~ s/\(.*\)//;		# remove category parenthetical, such as '(prenominal)'
	$word = &trim($word);
	$word =~ s/ /_/;		# replace spaces w/ underscores
	if ($word =~ /(\S+)\#(\d+)/) {
	    $word = $1;
	    $sense = $2;
	}
	$word = &trim($word);

	# Get the whole list of synonyms in the synset
	@synset_members = &tokenize($synset_member_list);

	# Determione the synset ID corresponding to '<word>#<sense>'
	$synset_ID = &get_synset_ID("$POS:$word\#$sense");
    }

    # Ignore other input (ie, nether raw wordnet nor output from wn interface)
    else {
	&debug_print(&TL_VERBOSE, "ignoring line: '$_'\n");
    }

    # Don't proceed unless definition found
    next if (!defined($definition));

    # Check for the synset frequency constraint
    if ($min_synset_freq > 0) {
	next if (! defined($synset_ID));
	my($freq) = &get_synset_frequency($synset_ID);
	if ($freq < $min_synset_freq) {
	    &debug_print(&TL_DETAILED, "skipping synset $synset_ID ($synset_member_list) since freq ($freq) < min ($min_synset_freq)\n");
	    next;
	}
    }

    # Normalize the form of the head word (e.g., remove single quotes)
    # TODO: convert to a form that can be reconverted back
    if ($word =~ /\'/) {
	&warning("Removing single quotes from head word: $word\n");
	$word =~ s/\'//g;
    }

    # Remove the domain indicator
    # example: '(zoology) having arms or armlike appendages' => 'having arms ...'
    my($domain) = "";
    if ($definition =~ /^\s*\(([^\)]+)\)\s*/) {
	$definition = $';
	$domain = $1;
    }

    # Remove the example (quotation) from the definition, and get rid
    # of terminating/separating punctuation.
    $definition = &wn_strip_quotes($definition);
    $definition =~ s/\s*[;:]\s*$//;
    $definition = &preparse_text($definition);
    if ($definition eq "") {
	# TODO: output empty parse results
	&warning("No definition proper for $POS:$word\#$sense, so ignoring it.\n");
	next;
    }

    # Isolate punctuation in the definition
    # example: 'something done (usually as opposed ...)' => 'something done ( usually as opposed ... )'
    # TODO: use prep_briller.perl or preparse.perl to account for special cases (abbreviations, contractions, etc.)
    $definition =~ s/([();:,.])/ $1 /g;

    # Form a complete sentence with the word and the definition
    my($sentence) = &form_parse_sentence($POS, $word, $definition);

    # Parse the definition using the Link Grammar Parser, and then
    # convert into relational tuple format.
    my($linkages) = &run_link_parser($sentence, $raw);
    $linkages = "n/a" if ($linkages eq "");

    # Determine whether dummy tokens (e.g., mod-3-4) were added to the parse,
    # and add these to the end of the definition
    foreach my $linkage (split(/\n/, $linkages)) {
	if ($linkage =~ /, (mod(\-\d+\-\d+)?), /) {
	    $sentence .= " $1 ";
	}
    }
    
    # Output the parse in relational tuple format preceding by identifying
    # information for the synset along with some other synset information.
    printf "Parse ID: %s\n", $synset_ID if (defined($synset_ID));
    if ($sense ne "") {
	## &assert('$headword eq $word');
	printf "sense: %s:%s#%d\n", $POS, $word, $sense;
	$sense = "";
    }
    if ($#synset_members > 0) {
	printf "synonyms: %s\n", join(", ", @synset_members[1..$#synset_members]);
    }
    if ($domain ne "") {
	print "Domain: $domain\n";
    }
    printf "definition: %s\n", $definition;
    printf "sentence: %s\n", $sentence;
    printf "linkages:\n%s\n", $linkages;
    printf "\n";
}

&exit();


#------------------------------------------------------------------------------

# is_mass_noun(word); indicates whether word is a mass noun
# This just checks for whether the words is in a list of known mass nouns
# (derived from EU project SIMPLE's lexicon for English).
#
# EX: is_mass_noun("anxiety") => 1
# EX: is_mass_noun("bridge") => 0
#
sub is_mass_noun {
    my($word) = @_;
    my($OK);
    my($mass_nouns_data) = "$DATA/SIMPLE/mass-nouns.list";

    $OK = (&run_command("grep -i \"^$word\$\" $mass_nouns_data") ne "");
    &debug_print(&TL_VERBOSE, "is_mass_noun(@_) => $OK\n");

    return ($OK);
}

# form_parse_sentence($POS, $word, $definition);
# Form a complete sentence with the word and the definition
# example: "wine is fermented juice (of grapes especially)."
#
# nouns: <optional-determiner> <word> is <definition>
# verbs: to <word> is to <definition>
# adjectives: <word> things are <definition>
# adjerbs: It happens <definition>.
#
# NOTE: the determiner is omitted if the word is a mass noun
#
# EX: form_parse_sentence("noun", "wine", "fermented juice (of grapes especially)") => "wine is fermented juice (of grapes especially)"
#
sub form_parse_sentence {
    my($POS, $word, $definition) = @_;
    &debug_print(&TL_VERBOSE, "form_parse_sentence(@_)\n");

    my($capitalized_word) = &capitalize($word);
    my($sentence) = "$word means $definition.";
    if ($POS eq "noun") {
	my($def_word) = $word;
	my($determiner) = "";
	if (! &is_mass_noun($word)) {
	    $determiner = ($word =~ /^[aeiou]/i) ? "An" : "A";
	}
	else {
	    $def_word = $capitalized_word;
	}
	# TODO: try "It has <definition>"
	$sentence = "$determiner $def_word is $definition.";
    }
    #
    elsif ($POS eq "verb") {
	# TODO: try "It has to <definition>"
	$sentence = "To $word is to $definition.";
    }
    #
    elsif ($POS eq "adjective") {
	# TODO: try "It is <adjective>"
	$sentence = "$capitalized_word things are $definition.";
    }
    elsif ($POS eq "adverb") {
	# TODO: work out a template that includes the adverb
	$sentence = "It occurs $definition.";
    }

    return ($sentence);
}


# run_link_parser(sentence, [raw]): parse the sentence using the Link Grammar Parser,
# and then convert into relational tuple format.
#
sub run_link_parser {
    my($sentence, $raw) = @_;
    $raw = &FALSE if (!defined($raw));
    &debug_print(&TL_DETAILED, "run_link_parser(@_)\n");

    my($parse_options) = "--verbose --offsets";
    $parse_options .= " --pseudo-batch" if ($all_parses);
    my($parse) = &run_command_over("link_parser.sh $parse_options", $sentence);
    &debug_print(&TL_VERBOSE, "parse:{\n$parse\n}\n");

    my($extract_options) = "-raw=$raw";
    $extract_options .= " -first" if (! $all_parses);
    my($linkages) = &run_command_over("perl -Ssw extract_linkages.perl $extract_options", $parse);
    $linkages = &trim_whitespace($linkages);
    if ($linkages eq "") {
	&warning("Parse of '$sentence' yielded no linkages\n");
    }

    return ($linkages);
}
