# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -s
#
# calc_multi_x2.perl: Calculate chi-square & G2 statistics for each 
# line of the input, each representing a 2x2 contingency table.
#
# example input; [Dunning 93]
#
#      # k(AB) k(A~B) k(~AB) k(~A~B)  w1  w2
#          110   2442    111   29114  the swiss
#           29     13    123   31612  can be
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

&init_var(*standard, &TRUE);	# standard input format
&init_var(*terse, &FALSE);	# terse output mode
use vars qw/$debug_level $terse/;

# Show a usage statement if no arguments given
# NOTE: By convention - is used when no arguments are required
if (!defined($ARGV[0])) {
    my($options) = "main options = []";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "examples:\n\n$script_name example\n\n";  # TODO: example
    ## $example .= "$0 example2\n\n";		   	     # TODO: 2nd example
    my($note) = "";
    $note .= "notes:\n\nObsolete: use calc_cooccurrence.perl instead.\n\n";

    print STDERR "\nusage: $script_name [options]\n\n$options\n\n$example\n$note";
    &exit();
}

if (defined($ARGV[0]) && ($ARGV[0] =~ /^\d+$/)) {
    &calc_x2_helper(" @ARGV ");
    exit;
}


print "# X2\tG2\tMI\tCoccurrents\n" if ($terse);
while (<>) {
    &dump_line($_);

    # Skip comments
    s/^[\#;].*//g;
    if (/^ *$/) {
	next;
    }

    &calc_x2_helper($_);
}

#------------------------------------------------------------------------------

# calc_x2_helper(line_of_data_)
# 
# Read each of k(AB) k(A~B) k(~AB) and k(~A~B); also read the bigram pair
# Note: the Perl variables use '_' instead of ~
#      \d: matches numeric         \D: matches non-numeric
#      \w: matches alphanumeric    \W: matches non-alphanumeric
#
sub calc_x2_helper {
    local($data) = @_;
    &debug_out(&TL_VERBOSE, "calc_x2_helper(%s)\n", join(" ", @_));

    local($AB, $A_B, $_AB, $_A_B, $bigram_word1, $bigram_word2);
    if ($data =~ /(\d+)\s+(\d+)\s+(\d+)\s+(\d+)(\s+(\S+)\s+(\S+))?/) {
	$bigram_word1 = $6 || "";
	$bigram_word2 = $7 || "";
	if ($standard) {
	    $AB = $1;
	    $A_B = $2;
	    $_AB = $3;
	    $_A_B = $4;
	}
	else {
	    $AB = $1;
	    $A = $2;
	    $B = $3;
	    $N = $4;

	    $A_B = $A - $AB;
	    $_AB = $B - $AB;
	    $_A_B = $N - ($AB + $A_B + $_AB);
	}

	&calc_x2($AB, $A_B, $_AB, $_A_B, $bigram_word1, $bigram_word2);
    }
    else {
	&debug_out(2, "ignoring $_");
    }

}

#------------------------------------------------------------------------------

# calc_x2(AB, A_B, _AB, _A_B, bigram_word1, bigram_word2)
#
# Calculate the chi-square and other independency-tests over the contingency
# data given by the four parameters.
# TODO: use a subroutine to avoid process overhead
#
sub calc_x2 {
    local($AB, $A_B, $_AB, $_A_B, $bigram_word1, $bigram_word2) = @_;
    &debug_out(4, "calc_x2(@_)\n");

    # Invoke the calc_x2.perl script to calculate the values
    print "X^2 & G^2 for \"$bigram_word1 $bigram_word2\":\n" unless ($terse);
    open (CALC_X2, "|perl -Ss calc_x2.perl -d=$debug_level");
    print CALC_X2 "# $bigram_word1 $bigram_word2\n";
    print CALC_X2 "$AB\t$A_B\n";
    print CALC_X2 "$_AB\t$_A_B\n";
    close (CALC_X2);

    return;
}


