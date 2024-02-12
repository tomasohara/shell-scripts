# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# similarity-example.perl: example of Text::Document aimilarity comparisons
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = $0; $dir =~ s/[^\\\/]*$//; unshift(@INC, $dir);
    require 'common.perl';
    ## TODO: use vars qw/$verbose/;
    require 'extra.perl';
    use Text::Document;
    use Text::DeDuper;
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
## use vars qw/$fu $bar/;

# Show a usage statement if no arguments given.
# NOTE: By convention '-' is used when no arguments are required.
if (!defined($ARGV[0])) {
    my($options) = "main options = []";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "Example(s):\n\n$script_name example\n\n";  # TODO: example
    ## $example .= "$0 example2\n\n";		   	     # TODO: 2nd example
    my($note) = "";
    ## $note .= "Notes:\n\nSome usage note.\n\n";	     # TODO: usage note

    print STDERR "\nUsage: $script_name [options]\n\n$options\n\n$example\n$note";
    &exit();
}

# From Document.pm

print "Example 1 (with case insensitivity)\n";

my $t_terms = "foo bar baz foo barbaz";
my $t = Text::Document->new();
$t->AddContent($t_terms);
## printf "t freqs: {%s}\n", join(", ", $t->KeywordFrequency());
printf "t terms: $t_terms\n";
&debug_out(&TL_DETAILED, "t: %s\n", &stringify($t));

my $u = Text::Document->new();
my $u_terms = "fu BAR BAZ foo Barbaz";
$u->AddContent($u_terms);
## printf "u freqs: {%s}\n", join(", ", $u->KeywordFrequency());
printf "u terms: $u_terms\n";
&debug_out(&TL_DETAILED, "u: %s\n", &stringify($u));

my $sj = $t->JaccardSimilarity( $u );
my $sc = $t->CosineSimilarity( $u );
## BAD: my $wsc = $t->WeightedCosineSimilarity( $u, \&MyWeight, $rock );

printf "Jaccard: %s\n", &round($sj);
printf "Cosine: %s\n", &round($sc);
## BAD: printf "Weighted Cosine: %s\n", &round($wsc);

print "\n";

# My example: handling of character vectors

print "Example 2 (character tokens)\n";

my $doc1_terms = join(" ", split(//, "Text::Document"));
my $doc1 = Text::Document->new();
$doc1->AddContent($doc1_terms);
print "doc1 terms: $doc1_terms\n";
&debug_out(&TL_DETAILED, "doc1: %s\n", &stringify($doc1));

my $doc2_terms = join(" ", split(//, "Tex::Docment"));
my $doc2 = Text::Document->new();
$doc2->AddContent($doc2_terms);
print "doc2 terms: $doc2_terms\n";
&debug_out(&TL_DETAILED, "doc2: %s\n", &stringify($doc2));

my $jaccard = $doc1->JaccardSimilarity($doc2);
my $cosine = $doc1->CosineSimilarity($doc2);

printf "Jaccard: %s\n", &round($jaccard);
printf "Cosine: %s\n", &round($cosine);

print "\n";

# Test of Text::DeDuper
my(@flea_docs) = (
#
    "dog has fleas",
    "my has fleas",
    "my fleas have dog", 
    "I bought a dog at the flea market",
#
    "my dog has fleas"
    );
#
print "Flea docs:\n";
map { print "\t$_\n"; } @flea_docs;
#
my($deduper) = new Text::DeDuper(ngram_size => 2);
for (my $i = 0; $i < $#flea_docs; $i++) {
    $deduper->add_doc("doc$i", $flea_docs[$i]);
}
#
my(@similar_docs) = $deduper->find_similar($flea_docs[$#flea_docs]);
print "similar to last: @similar_docs\n";

# The end
&exit();
