# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -s
#
# calc_cooccurrence.perl: Calculate co-occurrence statistics for the input,
# each line of which represents a 2x2 contingency table.
#
# example input; [Dunning 93]
#
#      # k(AB) k(A~B) k(~AB) k(~A~B)  w1  w2
#          110   2442    111   29114  the swiss
#           29     13    123   31612  can be
#
# This is a streamlined version of calc_multi_x2.perl that just displays
# the data formatted as a table.
#
# sample output:
#
# joint   dice    jaccard MI      x2       g2      avg-MI  term1  term2
# 0.003   0.079   0.041   2.632   525.021  270.722 0.006   the     swiss
# 0.001   0.299   0.176   7.173   4153.695 263.897 0.006   can     be
#
# NOTES:
# - Dunning, T. (1993) "Accurate Methods for the Statistics of Surprise and Coincidence", Computational Linguistics.
# - Output also includes "conditional independence" metrics (from GraphLing):
#      CI-ab:  P(A|B) - P(B)
#      CI-ba:  P(B|A) - P(A)
#
# TODO:
# - Add options for disabling particular metrics.
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = $0; $dir =~ s/[^\\\/]*$//; unshift(@INC, $dir);
    require 'common.perl';
    use vars qw/$verbose $precision/;
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
use vars qw/$totals $standard $min_freq $skip_comments $terms_first/;

# Load in other modules
require 'cooccurrence.perl';

# Check command-line arguments
if (!defined($ARGV[0])) {
    my($options) = "options = [-standard | -totals] [-min_freq=N] [-terms_first] [ data | - ]";
    my($example) = "examples:\n\n";
    $example .=  "echo 110 2442 111 29114 the swiss | $0 -\n\n";
    my($note) = "";
    $note .= "notes:\n";
    $note .= "- Calculate co-occurrence statistics for pairs of terms (A & B)\n";
    $note .= "- The input format is AB A~B ~AB ~A~B  A B   # comment \n";
    $note .= "- Use -precision=N to increase decision places (defaults to 3)\n";
    $note .= "- The -terms_first option affects the output (not the input)\n";
    $note .= "- The -totals option uses input format A B AB N\n";
    $note .= "- The -min_freq option filters by minimum joint frequency (i.e., AB)\n";

    die "\nusage: $0 [options]\n\n$options\n\n$example\n$note\n";
}
&init_var(*totals, &FALSE);		# input gives totals: A B AB N
&init_var(*standard, ! $totals);	# standard input: AB A_~B B_~A ~A_~B
&init_var(*min_freq, 1);		# minimum joint frequency (i.e., AB)
&init_var(*skip_comments, &FALSE);	# remove comments from text
&init_var(*terms_first, &FALSE);        # put terms before metrics

# Display the table header
my(@term_labels) = ("term1", "term2");
my(@header_labels) = ();
my(@freq_labels) = ("AB", "A_~B", "B_~A", "~A_~B");
push(@header_labels, @term_labels) if ($terms_first);
push(@header_labels, &get_cooccurrence_metrics());
push(@header_labels, @freq_labels) if ($verbose);
push(@header_labels, @term_labels) if (! $terms_first);
print "# ", join("\t", @header_labels);
print "\n";

# If data given on the command line, process it and exit
if (defined($ARGV[0]) && ($ARGV[0] =~ /^\d+$/)) {
    &calc_coccur_helper(" @ARGV ");
    &exit();
}

# Process each line of input as a separate 2x2 contingency table
#
while (<>) {
    &dump_line($_);
    chomp;

    # Skip comments and blank lines
    if ($skip_comments) {
	s/\b#.*//g;
    }
    if (/^\s*$/) {
	next;
    }

    # Extract counts and calculate statistics
    &calc_cooccur_helper($_);
}

#------------------------------------------------------------------------------

# calc_coccur_helper(line_of_data)
# 
# Read each of k(AB) k(A~B) k(~AB) and k(~A~B); also read the bigram terms
# Note: the Perl variables use '_' instead of ~
#      \d: matches numeric         \D: matches non-numeric
#      \w: matches alphanumeric    \W: matches non-alphanumeric
#
sub calc_cooccur_helper {
    &debug_print(&TL_DETAILED, "calc_cooccur_helper(@_)\n");
    my($data) = @_;

    if ($data =~ /(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/) {
	my($AB, $A_B, $_AB, $_A_B) = ($1, $2, $3, $4);
	my($rest) = $';		# ' (hush emacs)
	if (! $standard) {
	    $AB = $1;
	    my($A) = $2;
	    my($B) = $3;
	    my($N) = $4;

	    $A_B = $A - $AB;
	    $_AB = $B - $AB;
	    $_A_B = $N - ($AB + $A_B + $_AB);
	}

	# Show metrics unless frequency constraint not met
	if ($AB >= $min_freq) {

	    # Check for the bigram word or phrases
	    my($bigram1) = "";
	    my($bigram2) = "";
	    ($bigram1, $rest) = &parse_token($rest);
	    ($bigram2, $rest) = &parse_token($rest);

	    # Calculate the co-occurrence statistics
	    my(@metrics) = &calc_cooccurrence($AB, $A_B, $_AB, $_A_B, 
					      $bigram1, $bigram2);
	    my(@freqs) = ($AB, $A_B, $_AB, $_A_B);
	    my(@terms) = ($bigram1, $bigram2);
	    my(@values) = ();
	    push(@values, @terms) if ($terms_first);
	    push(@values, &round_all(@metrics));
	    push(@values, &round_all(@freqs)) if ($verbose);
	    push(@values, @terms) if (! $terms_first);
	    print join("\t", @values);
	    print "\n";
	}
    }
    else {
	&debug_print(&TL_WARNING, "Warning: Ignoring data '$_'\n");
    }
}

#------------------------------------------------------------------------

# parse_token(text): Parse a token that optionally is quoted.
# The token is returned along with the remainder of the text.
#
# EX: parse_token(" '(SonOf Sam)' Julie ") => ("(SonOf Sam)", " Julie ")
#
sub parse_token {
    my($text) = @_;
    my($token) = "";
    my($rest) = "";

    # First check for quoted string
    if ($text =~ /^\s*([\'\"])([^\1]*)\1/) {
	$token = $2;
	$rest = $';	# ' (hush emacs)
    }

    # Otherwise check for nonblank token
    elsif ($text =~ /^\s*(\S+)/) {
	$token = $1;
	$rest = $';	# ' (hush emacs)
    }
    &debug_print(&TL_VERY_VERBOSE, "parse_token(@_) => ($token, $rest)\n");

    return ($token, $rest);
}
