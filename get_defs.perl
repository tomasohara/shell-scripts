# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -ws
#!/usr/local/Gnu/bin/perl -w
#!/usr/bin/perl -w
# Perl options:   -w code warnings; -S check PATH for scripts; -s cmdline vars
#
# get_defs.perl: given a list of words, this will look up the 
# dictionary definitions from either WordNet or LDOCE and output the
# result in a common format
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';
require 'wordnet.perl';


sub usage {
    select(STDERR);
    print <<USAGE_END;

Usage: $script_name [options] word_list_file ...

options = [-use_ldoce=0|1] [-words="word_list"]
          [-base=name] [-skip_tagger=0|1] [-POS=noun|verb|adj|adv]
	  [-just_quotes=0|1] [-keep_quotes=0|1] [-show_synsets=0|1]

Given a list of words, this will look up the dictionary definitions
from either WordNet or LDOCE and output the result in a common format.

examples: 

$script_name -words="interest money"

$script_name -base=dso_wn_nouns < dso_noun_training.list >! dso_wn_nouns.post

$script_name -use_ldoce=1 -base=dso_ldoce < dso_noun_training.list >! dso_ldoce.post

$script_name -POS=verb -base=dso_wn_verbs < dso_verb_training.list >! dso_wn_verbs.post

USAGE_END

    exit 1;
}


# Get the command-line arguments (requires perl -s switch)
#
$base = "lex_rels" unless (defined($base));
$use_ldoce = &FALSE unless (defined($use_ldoce));
$words = "" unless (defined($words));
$skip_tagger = &FALSE unless (defined($skip_tagger));
$POS = "noun" unless (defined($POS));
$just_quotes = &FALSE unless (defined($just_quotes));
$keep_quotes = &FALSE unless (defined($keep_quotes));
$show_synsets = &FALSE unless (defined($show_synsets));

# If command line arguments are missing, give a usage message.
# $#ARGV = (# of arguments) - 1

if (($#ARGV < 0) && ($words eq "") && &blocking_stdin()) {
    &usage();
}


# Initialize access to WordNet (eg, read in the hypernym cache)
#
&wn_init() unless ($use_ldoce);


# Get the word definitions, and place into $base.defs
#
# TODO: have get_definitions return a string
#
open (DEFS, ">$base.defs");
if ($words ne "") {
    &get_definitions_from_text($words);
}
else {
    &get_definitions();
}
close (DEFS);

## # Run the Brill tagger over the definition text
## #
## &cmd("perl -S preparse.perl $base.defs > $base.pre") unless ($just_rels);
## &cmd("run_brill_tagger.sh $base.pre > $base.post") unless ($just_rels);
if ($skip_tagger == &FALSE) {
    &cmd("tag_defs.sh $base.defs");
}
else {
    &cmd("cat $base.defs");
}


# Cleanup access to WordNet (eg, write out the hypernym cache)
#
&wn_cleanup() unless ($use_ldoce);


#------------------------------------------------------------------------------

# get_definitions(): get definitions for the words taken from STDIN
#
sub get_definitions {

    while (<>) {
	&dump_line();

	&get_definitions_from_text($_);
    }
}

# get_definitions_from_text(text_string)
#
# Get the definitions for the words in the string. The result is
# printed to STDOUT.
# 
sub get_definitions_from_text {
    local ($text) = @_;

    # Ignore comments
    $text =~ s/\#.*//g;

    # Lookup each space delimited word
    $text .= " ";
    while ($text =~ /(\w+)\W/) {
	$word = $1;
	$text = $';

	$defs = ($use_ldoce 
		 ? &get_ldoce_defs($word)
		 : &wn_get_defs($word, $POS, 
				$show_synsets, $just_quotes, $keep_quotes));
	print DEFS "[$word]\n";
	printf DEFS "%s", $defs;
	print DEFS "\n";
    }
}


# get_ldoce_defs(word): retrieve a list of LDOCE definitions for the word
# The result is returned in a string with one line per definition.
#
sub get_ldoce_defs {
    local ($word) = @_;
    local ($defs, $num, $sense) = ("", 0, 0);
    local ($cat) = "n";

    open(LDOCE_DEFS, "ldoce_lookup.sh $word|");
    while (<LDOCE_DEFS>) {
	&debug_out(5, "ldoce: $_");
	if (/(\w+)_\d+_(\d+) \($cat\)\t(.*)/) {
	    $num++;
	    $sense = $2;
	    local($def) = $3;
	
	    $defs .= "$word#$sense: $def\n";
	}
    }
    close(LDOCE_DEFS);

    return ($defs);
}
