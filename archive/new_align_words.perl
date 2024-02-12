# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -s
#
# align_words.perl: given two lists of words and their associated l-vectors,
# this script tries to align the words based on a mutual information metric,
# as well as other association measures.
# Note that an l-vector is just an index of the line #'s the word occurs
# in. This is a "sparse vector" representation of the k-vector"
#
# This program was inspired by the paper
#    Pascale Fung and Ken Church (1994),
#    "K-vec: A New Approach for aligning Parallel Texts", COLING-94
#
# Note: this uses k-vectors that represent occurrence counts with each
# partition, not just a binary occurrence indicator. Use the -binary=1
# option to use the version described in the paper
#
# TODO: Make sure all local variables are declared.
#       Put common statistic code in a separate module so that this and
#       the older align_words.perl are easier to maintain.
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';


sub usage {
    local ($program) = $0;
    $program =~ s/\.?\.?\/?.*\///;

    select(STDERR);
    print <<USAGE_END;

Usage: $program [options] lang1.l_vector lang2.l_vector [word1 word2 ...]

   options = [-min_freq=num -max_freq=num]

   lang1.l_vector: file w/ l-vectors for corpus of language 1
   lang2.l_vector: file w/ l-vectors for corpus of language 2
   word1, word2: word pair for mutual information details


Aligns the words from the two corpuses based on maximizing mutual information
computed over the pairs of l-vectors. See l_vec.perl to derive the l-vectors
from each corpus. Alignments are also calculated by maximizing the joint
probability and by maximizing the G^2 statistic.


examples: 

$program temp_english.lvec temp_spanish.lvec

nice +19 $program -min_freq=50 temp_english.lvec temp_spanish.lvec >&! align.log &

USAGE_END

    exit 1;
}



# Give usage information if insufficient number of arguments
#
if ($ARGV[1] eq "") {
    &usage();
}


## $threshold = 10 unless defined($threshold);
$min_freq = 3 unless defined($min_freq);
$max_freq = $MAXINT unless defined($max_freq);
$max_diff = 500 unless (defined($max_diff));
$same_lang = &FALSE unless (defined($same_lang));
$TOPN = 5 unless (defined($TOPN));
$NUM_METRICS = 7;

# Determine the lists for the subset of each language to consider
# These are tab-delimited lists with (arbitrary) sentinels "^" & "$"
if (defined($subset1) && ($subset1 ne "")) {
    $subset1 = join("\t", split(/[ \t]+/, "^ $subset1 \$"));
}
else {
    $subset1 = "";
}
$subset2 = "";
if (defined($subset2) && ($subset2 ne "")) {
    $subset2 = join("\t", split(/[ \t]+/, "^ $subset2 \$"));
}
else {
    $subset2 = "";
}


# Get the required arguments
#
$language1 = shift @ARGV;
$language2 = shift @ARGV;
@word_pairs = @ARGV;

$max1 = &read_l_vec(*language1, $language1);
$max2 = &read_l_vec(*language2, $language2);


# Just show the mutual information calculations for each word pair
#
for ($i = 0; $i <= $#word_pairs; $i += 2) {
    $word1 = $word_pairs[$i];
    $word2 = $word_pairs[$i + 1];
    ($freq1, $sign1, $l_vec1) = split(/\t/, $language1{$word1});
    ($freq2, $sign2, $l_vec2) = split(/\t/, $language2{$word2});
    &calc_association($word1, $l_vec1, $max1, $word2, $l_vec2, $max2);
}
if ($i > 0) {
    exit;
}


&align_words(*language1, *language2);
print "\n\n";

&align_words(*language2, *language1);


# Find the mutual information of each pair of words. Since mutual 
# information is unreliable for small counts, require frequencies
# above 3.
#
# NOTE: This now includes six other metrics for comparison purposes.
#       In addition, the top-n associations are maintained.

sub align_words {
    local(*lang1, *lang2) = @_;
    local($i);

    debug_out(5, "align_words($lang1, $lang1): subset1='%s'\n", $subset1);

    printf "word1\t\tjoint\t \tdice\t \tjacc\t \tMI\t \tAvgMI\t \tx2\t \t g2\t \n";
    foreach $word1 (sort(keys(%lang1))) {
	&debug_out(7, "$word1 vs ...\n");
	($freq1, $sign1, $l_vec1) = split(/\t/, $lang1{$word1});
	if (&include_word($word1, $freq1, $subset1)) {

	    # Initialize the associative arrays used for the top-n lists
	    for ($i = 0; $i < $NUM_METRICS; $i++) {
		for ($j = 0; $j < $TOPN; $j++) {
		    $max{"$i:$j"} = 0;
		    $best{"$i:$j"} = "n/a";
		}
	    }
	    
	    # Find the word that maximizes the mutual information
	    # based on the overlap in the k vectors
	    foreach $word2 (keys(%lang2)) {
		&debug_out(7, "... $word2\n");
		if ($same_lang && ($word1 eq $word2)) {
		    next;
		}
		($freq2, $sign2, $l_vec2) = split(/\t/, $lang2{$word2});
		if (&include_word($word2, $freq2, $subset2)) {

		    # Frequency filter: diff can be at most half the lesser
		    $freq_diff = abs($freq1 - $freq2);
		    $min_freq12 = ($freq < $freq) ? $freq1 : $freq2;
		    if ($freq_diff > (0.5 * $min_freq12)) {
			next;
		    }

		    ## Signature filter
		    ## $diff = ($sign1 > $sign2) ?
		    ##	  ($sign1 - $sign2) : ($sign2 - $sign1);
		    ## if ($diff > $max_diff) {
		    ##	  next;
		    ## }

		    # Get the set of association measures
		    @current = &calc_association($word1, $l_vec1, $max1,
						 $word2, $l_vec2, $max2);

		    # Update the top-n lists for the word
		    for ($i = 0; $i < $NUM_METRICS; $i++) {
			# Find the position in the list where it belongs
			$pos = -1;
			for ($j = 0; $j < $TOPN; $j++) {
			    if ($current[$i] > $max{"$i:$j"}) {
				$pos = $j;
				last;
			    }
			}
			next if ($pos == -1);

			# Shift the lesser entries down the list
			for ($j = ($TOPN - 1); $j > $pos; $j--) {
			    $k = $j - 1;
			    $max{"$i:$j"} = $max{"$i:$k"};
			    $best{"$i:$j"} = $best{"$i:$k"};
			}
			$max{"$i:$pos"} = $current[$i];
			$best{"$i:$pos"} = $word2;
		    }
		}
	    }
	    
	    # Display the best word association for each measure
	    for ($j = 0; $j < $TOPN; $j++) {
		printf "%s\t", (($j == 0) ? $word1 : "");
		for ($i = 0; $i < $NUM_METRICS; $i++) {
		    printf "%s\t%.3f\t", $best{"$i:$j"}, $max{"$i:$j"};
		}
		printf "\n";
	    }
	}
    }
}


sub include_word {
    local($word, $freq, $subset) = @_;
    local($include);
    
    $include = &FALSE;
    if (($freq >= $min_freq) && ($freq <= $max_freq)) {
	if (($subset eq "") || (index($subset, "\t$word\t") != -1)) {
	    $include = &TRUE;
	}
    }
    
    return ($include);
}


# Read in a file with word/l-vector pairs. The result is stored in 
# an associative array, keyed off of the word. Each value is a frequency
# count followed by the vector.
#
# TODO: change l_vector format to have the frequency tab-delimited
#
# Sample:
#   gloria (6)		0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 1 1 0
#   rubén (1)		0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
#   sangre (12)		1 0 0 0 0 0 1 1 1 0 0 0 1 0 0 1 1 1 0 0 1 0 0 0 0
#   salvación (1)	0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0
#

sub read_l_vec {
    local(*lang, $file) = @_;
    &debug_out(4, "read_l_vec(%s, $file)\n", *lang);
    local($max_line, $last_line);

    $max_line = 0;
    open (FILE, "<$file") || die "unable to open $file\n";
    while (<FILE>) {
	chop;
	&dump_line($_, 7);
	next if (/ *\#/);	# skip comments

	($word, $freq, $signature, $l_vec) = split(/\t/, $_);
	&debug_out(6, "w=$word f=$freq\ts=$signature\tv='$l_vec'\n");
	if (($freq < $min_freq) || ($max_freq < $freq)) {
	    next;
	}
	$lang{$word} = "$freq\t$signature\t$l_vec";
	if ($l_vec =~ /([0-9]+)\s*$/) {
	    $last_line = $1;
	    if ($last_line > $max_line) {
		$max_line = $last_line;
	    }
	}
    }
    close(FILE);

    return ($max_line);
}



# calc_association(word1, l_vector1, $max_line1, word2, l_vector2, $max_line2)
#
# Determine the similarity for two words given their vector
# representations. This returns a vector with a series of metrics:
#
#   joint probabilitiy:
#       P(X=1,Y=1)
#
#   the Dice coefficient:
#	Dice(X,Y) = 2 * p(X=1,Y=1)/(p(X=1) + p(Y=1))
#
#   the Jaccard measure
#       Jaccard(X,Y) = A / (A + B + C)
#                    = f(X=1, Y=1) / (f(X=1 Y=1) + f(X=1,Y=0) + f(X=1,Y=1))
#
#   mutual information:
#	log2(P(X=1,Y=1) / P(X=1) * P(Y=1))
#
#   avg mutual information:
#	sum(x) sum(y) { P(X=x,Y=y) * log2(P(X=x,Y=y) / P(X=x) * P(Y=y)) }
#
#   chi-square:
#	sum(ij) { (Fobs[ij] - Fexp[ij])^2 / Fexp[ij] }
#
#   G^2:
#	2 * sum(ij) { Fexp[ij] * log(Fobs[ij] / Fexp[ij]) }
#
# Returns (joint, dice, AvgMI, MI, x2, G^2)
#

sub calc_association {
    local ($word1, $l_vec1, $max1, $word2, $l_vec2, $max2) = @_;
    local (@l_vec1, @l_vec2);
    local ($a, $b, $c, $d);
    local ($prob1, $prob2, $prob12, $dice, $MI, $AvgMI);
    &debug_out(5, "calc_association($word1, _, $max1, $word2, _, $max2)\n");
    &debug_out(5, "lv1='%s', lv2='%s'\n", $l_vec1, $l_vec2);

    # Convert the string lists to arrays, and append a sentinel
    # to simplify the scanning.
    @l_vec1 = split(/ /, $l_vec1);
    $l_vec1[$#l_vec1 + 1] = $max1 + 1;
    @l_vec2 = split(/ /, $l_vec2);
    $l_vec2[$#l_vec2 + 1] = $max1 + 1;

    # Fill out the contingency table for the occurrence counts
    #
    #    w2    +  -
    #  ------------
    #  w1  + | a  b
    #      - | c  d
    #
    #  1 5 10 11 12 20
    #  5 12 30
    #
    # TODO: fix bug in d calculation
    #
    $a = $b = $c = $d = 0;
    $i = $j = 0;
    $last = $last1 = $last2 = 0;
    for (;;) {
	local ($num1, $num2) = (0, 0);
	&debug_out(5, "a: ($i, $j): $l_vec1[$i] vs $l_vec2[$j]\n");
	for (; ($i <= $#l_vec1) && ($l_vec1[$i] < $l_vec2[$j]); $i++) {
	    $b++;
	    $num1++;
	}
	&debug_out(5, "b: ($i, $j): $l_vec1[$i] vs $l_vec2[$j]\n");
	for (; ($j <= $#l_vec2) && ($l_vec2[$j] < $l_vec1[$i]); $j++) {
	    $c++;
	    $num2++;
	}
	$min = ($l_vec2[$i] < $l_vec1[$i]) ? $l_vec2[$j] : $l_vec1[$i];
	# $delta = ((($l_vec1[$i] - $last1) - $num1)
	#	  + (($l_vec2[$j] - $last2) - $num2));
	$delta = (($min - $last) - $num1 - $num2);
	&debug_out(5, "c: ($i, $j): $l_vec1[$i] vs $l_vec2[$j]; $num1, $num2, $delta\n");
	$d += $delta ; # unless ($delta <= 0);
	if ($l_vec1[$i] == $l_vec2[$j]) {
	    last if ($l_vec1[$i] > $max1);
	    $a++;
	    $i++;
	    $j++;
	}
	$last1 = $l_vec1[$i];
	$last2 = $l_vec2[$j];
	$last = $min;
    }
    ## $d--;			# discount the extra one due to sentinel

    # Calcuate the individual probabilities and the joint one
    #
    $total = ($a + $b + $c + $d);
    if ($total == 0) {
	die "ERROR: unexpected contingency counts: ($a, $b, $c, $d)\n";
    }
    $prob1 = ($a + $b) / $total;
    $prob2 = ($a + $c) / $total;
    $prob12 = $a / $total;

    # Calculate the Dice coefficient
    #	Dice(X,Y) = 2 * p(X=1,Y=1)/(p(X=1) + p(Y=1))
    #
    $dice = 2 * $prob12 / ($prob1 + $prob2);

    # Calculate the Jaccard measure
    #   Jaccard(X,Y) = A / (A + B + C)
    #                = f(X=1, Y=1) / (f(X=1 Y=1) + f(X=1,Y=0) + f(X=1,Y=1))
    $jaccard = $a / ($a + $b + $c);

    # Calculate the expected frequencies under the independence assumption
    #
    $Fo[0] = $a; $Fe[0] = $prob1 * $prob2 * $total;
    $Fo[1] = $b; $Fe[1] = $prob1 * (1 - $prob2) * $total;
    $Fo[2] = $c; $Fe[2] = (1 - $prob1) * $prob2 * $total;
    $Fo[3] = $d; $Fe[3] = (1 - $prob1) * (1 - $prob2) * $total;

    # Calculate the X^2 statistic
    #	sum((Fo - Fe)^2 / Fe)
    $x2 = 0.0;
    for ($i = 0; $i < 4; $i++) {
	if ($Fe[$i] > 0) {
	    $x2 += ($Fo[$i] - $Fe[$i]) * ($Fo[$i] - $Fe[$i]) / $Fe[$i];
	}
    }

    # Calculate mutual information:
    #    log2(P(1,2) / P(1) * P(2))
    $MI = calc_mutual_info(($a, $b, $c, $d), 2, 2);
    $AvgMI = old_calc_mutual_info($a, $b, $c, $d);

    # Calculate the G^2 statistic:
    #    2 * sum(Fo * log(Fo/Fe)
    $g2 = 0.0;
    for ($i = 0; $i < 4; $i++) {
	if (($Fo[$i] > 0) && ($Fe[$i] > 0)) {
	    ## $g2 += $Fo[$i] * log($Fo[$i] / $Fe[$i]) / log(2);
	    $g2 += $Fo[$i] * log($Fo[$i] / $Fe[$i]);
	}
    }
    $g2 *= 2;

    ## &debug_out(4, "$word1 $word2: ($a $b $c $d) (%.3f %.3f; %.3f %.3f) %.3f\n",
    ##	       $prob1, $prob2, $prob12, $prob1 * $prob2, $MI);
    &debug_out(5, "obs: $a $b $c $d exp: %.3f %.3f %.3f %.3f\n",
	       $Fe[0], $Fe[1], $Fe[2], $Fe[3]);
    &debug_out(4, "$a $b $c $d $word1 $word2 # (%.3f %.3f; %.3f %.3f) %.3f %.3f %.3f %.3f\n",
	       $prob1, $prob2, $prob12, $prob1 * $prob2, $MI, $AvgMI, $x2, $g2);

    ## return ($MI);
    @result = ($prob12, $dice, $jaccard, $MI, $x2, $g2, $AvgMI);
    return (@result);
}



sub calc_mutual_info {
    local ($a, $b, $c, $d) = @_;

    $Fo{"0:0"} = $a;
    $Fo{"0:1"} = $b;
    $Fo{"1:0"} = $c;
    $Fo{"1:1"} = $d;
    return new_calc_mutual_info(*Fo, 2, 2)
}


# Calculate mutual information as described in [Pearl 88: pp 321-323]:
#
#   I(T,X) = H(T) - H(T|X) = -sum(x, sum(t, P(t,x) * log(P(t,x) / (P(t) * P(x)))))
#
sub new_calc_mutual_info {
    local (*Fo, $rows, $cols) = @_;
    local ($i, $j);
    local (@row_sums, @col_sums);
    local ($MI, $MI_value);

    # Tabulate the margin frequencies
    #
    $total = 0;
    for ($j = 0; $j < $cols; $j++) {
	$col_sums[$j] = 0;
    }
    for ($i = 0; $i < $rows; $i++) {
	$row_sums[$i] = 0;
	for ($j = 0; $j < $cols; $j++) {
	    $row_sums[$i] += $Fo{"$i:$j"};
	    $col_sums[$j] += $Fo{"$i:$j"};
	}
	$total += $row_sums[$i];
    }
    if ($total == 0) {
	die "ERROR: unexpected contingency counts\n";
    }

    # Add in the mutual information for each cell in the table
    #
    $MI = 0.0;
    for ($i = 0; $i < $rows; $i++) {
	for ($j = 0; $j < $cols; $j++) {
	    $Pi = $row_sums[$i] / $total;
	    $Pj = $col_sums[$j] / $total;
	    $Pij = $Fo{"$i:$j"} / $total;
	    $MI_value = 0;
	    if (($Pij > 0) && ($Pi > 0) && ($Pj > 0)) {
		$MI_value = log($Pij / ($Pi * $Pj)) / log(2);
	    }
	    debug_out(6, "MI_value = %.3f; (%.3f %.3f %.3f)\n",
		      $MI_value, $Pi, $Pj, $Pij);
	    $MI += $Pij * $MI_value;
	}
    }
    &debug_out(6, "MI = $MI\n");
    
    return ($MI);
}



sub old_calc_mutual_info {
    local ($a, $b, $c, $d) = @_;
    local ($MI);

    $total = ($a + $b + $c + $d);
    if ($total == 0) {
	die "ERROR: unexpected contingency counts: ($a, $b, $c, $d)\n";
    }
    $prob1 = ($a + $b) / ($a + $b + $c + $d);
    $prob2 = ($a + $c) / ($a + $b + $c + $d);
    $prob12 = $a / ($a + $b + $c + $d);

    # Calculate the mutual information:
    #    log2(P(1,2) / P(1) * P(2))
    $MI = 0;
    if (($prob1 > 0) && ($prob2 > 0) & ($prob12 > 0)) {
	$MI = log(($prob12) / ($prob1 * $prob2)) / log(2);
    }

    return ($MI);
}
