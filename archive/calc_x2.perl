# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -s
#
# Calculates a simple X^2 (chi-square) independence test for a 
# 2x2 contingency table
#
#	# The Swiss bigram contingency table [Dunning 93]
#	110	2442
#	111	29114
#
# Note: For readability the steps have been kept separate.
# Therefore, it might be desireable to combine them later for
# efficiency.
#
#------------------------------------------------------------------------
# Statistics covered:
#
#   chi-square:
#	sum(ij) { (Fobs[ij] - Fexp[ij])^2 / Fexp[ij] }
#
#   G^2:
#	2 * sum(ij) { Fexp[ij] * log(Fobs[ij] / Fexp[ij]) }
#
#   mutual information:
#	log2(P(X=1,Y=1) / P(X=1) * P(Y=1))
#
#   the Dice coefficient:
#	Dice(X,Y) = 2 * p(X=1,Y=1)/(p(X=1) + p(Y=1))
#
# TODO:
#   joint probabilitiy:
#       P(X=1,Y=1)
#
#   the Jaccard measure
#       Jaccard(X,Y) = A / (A + B + C)
#                    = f(X=1, Y=1) / (f(X=1 Y=1) + f(X=1,Y=0) + f(X=1,Y=1))
#
#   avg mutual information:
#	sum(x) sum(y) { P(X=x,Y=y) * log2(P(X=x,Y=y) / P(X=x) * P(Y=y)) }
#
# - use cooccurrence.perl module
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

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

&init_var(*terse, &FALSE);
&init_var(*verbose, ! $terse);		# verbose output mode
&init_var(*MAX_ROW, 10);		# max row dimension (TODO: derive automatically)
## &init_var(*MAX_COL, 10);		# max column dimension

## $n_plus_i = 0;
## $n_j_plus = 0;
$n_plus_plus = 0;
$est_plus_plus = 0;

# Initialize the tallies
#
for ($i = 0; $i < $MAX_ROW; $i++) {
    $n_plus_i{"$i"} = 0;
    $n_j_plus{"$i"} = 0;
    $est_plus_i{"$i"} = 0;
    $est_j_plus{"$i"} = 0;
}

# Read in the data
#
my($comments) = "";
$i = 0;
while (<>) {
    &dump_line($_);

    # Skip comments
    if (/^\s*#/) {
	$comments .= $_;
	next;
    }

    # Extract the numbers
    $j = 0;
    $text = $_;
    $n_plus_i{"$i"} = 0;
    while ($text =~ /([0-9]+)/) {
	$n_i_j{"$i:$j"} = $1;
	$n_plus_i{"$i"} += $1;
	$n_j_plus{"$j"} += $1;
	$n_plus_plus += $1;
	$text = $';
	$j++;
    }
    $num_cols = $j;
    $i++;
}
$num_rows = $i;



# Display the tallies
#
if ($verbose) {
    print "original contigency table:\n";
    for ($i = 0; $i < $num_rows; $i++) {
	for ($j = 0; $j < $num_cols; $j++) {
	    printf "%10.3f\t", $n_i_j{"$i:$j"};
	}
	printf "%10.3f\n", $n_plus_i{"$i"};
    }
    for ($j = 0; $j < $num_cols; $j++) {
	printf "%10.3f\t", $n_j_plus{"$j"}; 
    }
    printf "%10.3f\n", $n_plus_plus;
    print "\n";
}

# Calculate the estimated freqiencies
#
print "contigency table under independence assumption:\n" if ($verbose);
for ($i = 0; $i < $num_rows; $i++) {
    for ($j = 0; $j < $num_cols; $j++) {
	$est_i_j{"$i:$j"} = $n_plus_i{"$i"} * $n_j_plus{"$j"} / $n_plus_plus;
	printf "%10.3f\t", $est_i_j{"$i:$j"} if ($verbose);
	## printf "%d\t", $est_i_j{"$i:$j"} if ($verbose);

	# Determine the marginals for the estimates (should match originals)
	$est_plus_i{"$i"} += $est_i_j{"$i:$j"};
	$est_j_plus{"$j"} += $est_i_j{"$i:$j"};
	$est_plus_plus += $est_i_j{"$i:$j"};
    }
    printf "%10.3f\n", $est_plus_i{"$i"} if ($verbose);
}
if ($verbose) {
    for ($j = 0; $j < $num_cols; $j++) {
	## printf "%d\t", $est_j_plus{"$j"}; 
	printf "%10.3f\t", $est_j_plus{"$j"}; 
    }
    printf "%10.3f\n", $est_plus_plus;
    print "\n";
}

# Calculate the Chi-Square & G^2 statistics
# 
# Let Fe = expected frequency & Fo = observed frequency
#
#     X^2 = sum{ (Fe - Fo)^2 / Fe }
#
#     G^2 = 2 * sum{ Fe * log(Fo / Fe) }
#
$chi_square = 0.0;
$g_square = 0.0;
for ($i = 0; $i < $num_rows; $i++) {
    for ($j = 0; $j < $num_cols; $j++) {
	$est_i_j{"$i:$j"} = $n_plus_i{"$i"} * $n_j_plus{"$j"} / $n_plus_plus;

	# Calculate the current X^2 value:
	#    (Fe - Fo)^2 / Fe
	$chi_value1 = $est_i_j{"$i:$j"} - $n_i_j{"$i:$j"};
	&debug_out(5, "cv1=$chi_value1 (%d)\n", $chi_value1);
	$chi_value2 = $chi_value1 * $chi_value1;
	&debug_out(5, "cv2=$chi_value2 (%d)\n", $chi_value2);
	$chi_value3 = $chi_value2 / $est_i_j{"$i:$j"};
	&debug_out(5, "cv3=$chi_value3 (%d)\n", $chi_value3);
	$chi_square += $chi_value3;
	&debug_out(5, "(%d - %d)^2 / %d = %7.3f\n",
	     $est_i_j{"$i:$j"}, $n_i_j{"$i:$j"}, $est_i_j{"$i:$j"}, $chi_value3);

	# Calculate the current G^2 value:
	#    Fe * log(Fo / Fe)
	$g_value = $n_i_j{"$i:$j"}/$est_i_j{"$i:$j"};
	if ($g_value > 0) {
	    $g_value = $n_i_j{"$i:$j"} * log($g_value);
	}
	$g_square += $g_value;
    }
}
# The G^2 result is 2 times the summation (sum{ Fe * log(Fo / Fe) })
$g_square =  2.0 * $g_square;

if ($verbose) {
    printf "chi_square = %7.3f\n", $chi_square;
    printf "g_square = %7.3f\n", $g_square;
}

# Calculate the mutual information if this is a 2x2 table
#
my($MI);
if (($num_rows == 2) && ($num_cols == 2)) {
    $MI = &calc_mutual_info($n_i_j{"0:0"}, $n_i_j{"0:1"}, 
			    $n_i_j{"1:0"}, $n_i_j{"1:1"});
    printf "MI = %7.3f\n", $MI if ($verbose);
    my($dice) = &calc_dice_coefficient($n_i_j{"0:0"}, $n_i_j{"0:1"}, 
				       $n_i_j{"1:0"}, $n_i_j{"1:1"});
    printf "dice = %.3f\n", $dice;
}

print "\n" if ($verbose);

# During terse mode just display a single line summary
if ($terse) {
    printf "%.3f\t%.3f", $chi_square, $g_square;
    if (defined($MI)) {
	printf "\t%.3f", $MI;
    }
    print "\t$comments";
}


sub calc_mutual_info {
    local ($a, $b, $c, $d) = @_;

    $total = ($a + $b + $c + $d);
    if ($total == 0) {
	die "ERROR: unexpected contingency counts: ($a, $b, $c, $d)\n";
    }
    my($prob1) = ($a + $b) / ($a + $b + $c + $d);
    my($prob2) = ($a + $c) / ($a + $b + $c + $d);
    my($prob12) = $a / ($a + $b + $c + $d);

    # Calculate the mutual information:
    #    log2(P(1,2) / P(1) * P(2))
    $MI = 0;
    if (($prob1 > 0) && ($prob2 > 0) & ($prob12 > 0)) {
	$MI = log(($prob12) / ($prob1 * $prob2)) / log(2);
    }
    &debug_out(5, "($a $b $c $d) (%.3f %.3f; %.3f %.3f) %.3f\n",
	       $prob1, $prob2, $prob12, $prob1 * $prob2, $MI);

    return ($MI);
}


sub calc_dice_coefficient {
    my($a, $b, $c, $d) = @_;

    # Calculate individual probabilities
    $total = ($a + $b + $c + $d);
    if ($total == 0) {
	die "ERROR: unexpected contingency counts: ($a, $b, $c, $d)\n";
    }
    my($prob1) = ($a + $b) / ($a + $b + $c + $d);
    my($prob2) = ($a + $c) / ($a + $b + $c + $d);
    my($prob12) = $a / ($a + $b + $c + $d);

    # Calculate the Dice coefficient
    #	Dice(X,Y) = 2 * p(X=1,Y=1)/(p(X=1) + p(Y=1))
    #
    my($dice) = 2 * $prob12 / ($prob1 + $prob2);

    return ($dice);
}
