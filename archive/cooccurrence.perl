# perl library routines for cooccurrence statistics
# based on code in align_words.perl
#

# get_cooccurrence_metrics(): Returns lists of co-occurrence metrics
# returned by calc_cooccurrence.
sub get_cooccurrence_metrics {
    return ("joint", "dice", "jaccard", "MI", "x2", "g2", "avg-MI", "CI-ab", "CI-ba");
}

# calc_occurrence_from_totals(count1, count2, cooccur, total)
#
# Helper to calc_cooccurrence that first fills out the contingency table
# from the specified marginal counts.
#
sub calc_occurrence_from_totals {
    my($f_AB) = $cooccur;
    my($f_A_notB) = $count1 - $f_AB;
    my($f_notA_B) = $count2 - $f_AB;
    my($f_notA_notB) = $total - ($f_AB + $f_A_notB + $f_notA_B);
    
    &return (&calc_cooccurrence($f_AB, $f_A_notB, $f_notA_B, $f_notA_notB));
}

# calc_cooccurrence(f_AB, f_A_notB, f_notA_B, f_notA_notB)
#
# Calculate various statistics for the cooccurrence of two tokens,
# given their occurrence counts.
#
#      B    +      -
#    ----------------
#    A  + | AB    A~B
#       - | ~AB  ~A~B
#
# This produces a vector of metrics:
#
#   joint probabilitiy:
#       P(X=1,Y=1)
#
#   the Dice coefficient:
#	Dice(X,Y) = 2 * p(X=1,Y=1)/(p(X=1) + p(Y=1))
#
#   the Jaccard measure
#       Jaccard(X,Y) = XY / (XY + X~Y + ~XY)
#                    = f(X=1, Y=1) / (f(X=1 Y=1) + f(X=1,Y=0) + f(X=0,Y=1))
#
#   mutual information:
#	log2(P(X=1,Y=1) / P(X=1) * P(Y=1))
#
#   avg mutual information:
#	sum(x) sum(y) { P(X=x,Y=y) * log2(P(X=x,Y=y) / P(X=x) * P(Y=y)) }
#
#   chi-square:
#	sum(ij) { (obs[ij] - exp[ij])^2 / exp[ij] }
#
#   G^2 (log likelihood ratio):
#	2 * sum(ij) { exp[ij] * log(obs[ij] / exp[ij]) }
#
# Returns (joint, dice, AvgMI, MI, x2, G^2)
#
sub calc_cooccurrence {
    my($f_AB, $f_A_notB, $f_notA_B, $f_notA_notB) = @_;
    &debug_print(&TL_DETAILED, "calc_cooccurrence(@_)\n");

    # Calcuate the individual probabilities as well as the joint
    #
    my($total) = ($f_AB + $f_A_notB + $f_notA_B + $f_notA_notB);
    if ($total == 0) {
	return ();
    }
    my($prob_A, $prob_B, $prob_AB) = &calc_marginal_probabilities($f_AB, $f_A_notB, $f_notA_B, $f_notA_notB);

    # Calculate the Dice coefficient
    #	Dice(X,Y) = 2 * p(X=1,Y=1)/(p(X=1) + p(Y=1))
    #
    my($dice) = 2 * $prob_AB / ($prob_A + $prob_B);

    # Calculate the Jaccard measure
    #   Jaccard(X,Y) = A / (A + B + C)
    #                = f(X=1, Y=1) / (f(X=1 Y=1) + f(X=1,Y=0) + f(X=1,Y=1))
    my($jaccard) = $f_AB / ($f_AB + $f_A_notB + $f_notA_B);

    # Calculate the conditional indepence metric
    # note: this metric is asymmetric unlike the others
    my($prob_A_given_B) = $prob_AB / $prob_B;
    my($CI_ab) = ($prob_A_given_B - $prob_A);
    my($prob_B_given_A) = $prob_AB / $prob_A;
    my($CI_ba) = ($prob_B_given_A - $prob_B);

    # Determine the expected frequencies (assuming independence)
    my(@f_obs) = ($f_AB, $f_A_notB, $f_notA_B, $f_notA_notB);
    my(@f_exp) = ($prob_A * $prob_B * $total, 
		  $prob_A * (1 - $prob_B) * $total,
		  (1 - $prob_A) * $prob_B * $total,
		  (1 - $prob_A) * (1 - $prob_B) * $total);

    # Calculate the chi-squared statistic:
    #	sum((f_obs[ij] - f_exp[ij])^2 / f_exp[ij])
    #
    my($x2) = &calc_x2(\@f_obs, \@f_exp);

    # Calculate mutual information:
    #    log2(P(1,2) / P(1) * P(2))
    my($AvgMI) = calc_avg_mutual_info(@f_obs);
    my($MI) = calc_mutual_info($f_AB, $f_A_notB, $f_notA_B, $f_notA_notB);

    # Calculate the G^2 statistic:
    #    2 * sum(f_obs[ij] * log(f_obs[ij] / f_exp[ij]))
    my($g2) = calc_g2(\@f_obs, \@f_exp);

    # Combine the metrics into a single vector
    &debug_print(&TL_VERBOSE, "observation: @f_obs\n");
    &debug_out(&TL_VERBOSE, "   expected: %s\n", join(" ", &round_all(@f_exp)));
    &debug_out(&TL_DETAILED, "@f_obs # (%.3f %.3f; %.3f %.3f) %.3f %.3f %.3f %.3f\n",
	       $prob_A, $prob_B, $prob_AB, $prob_A * $prob_B, $MI, $AvgMI, $x2, $g2);
    my(@result) = ($prob_AB, $dice, $jaccard, $MI, $x2, $g2, $AvgMI, $CI_ab, $CI_ba);

    return (@result);
}

# calc_marginal_probabilities(f_AB, f_A_notB, f_notA_B, f_notA_notB)
# Returns P(A), P(B), P(AB)
#
sub calc_marginal_probabilities {
    my($f_AB, $f_A_notB, $f_notA_B, $f_notA_notB) = @_;
    my($total) = ($f_AB + $f_A_notB + $f_notA_B + $f_notA_notB);
    my($prob_A) = ($f_AB + $f_A_notB) / $total;
    my($prob_B) = ($f_AB + $f_notA_B) / $total;
    my($prob_AB) = $f_AB / $total;

    return ($prob_A, $prob_B, $prob_AB);
}

# calc_x2(F_observed_ref, F_expected_ref)
#
# Calculate the chi-square statistic over a 2x2 contingency table,
# and the table of expected freuqencies.
#
sub calc_x2 {
    &debug_print(&TL_VERBOSE, "calc_x2(@_)\n");
    my($f_obs_ref, $f_exp_ref) = @_;
    my(@f_obs) = @$f_obs_ref;
    my(@f_exp) = @$f_exp_ref;

    # Calculate the X^2 statistic
    #	sum((f_obs[ij] - f_exp[ij])^2 / f_exp[ij])
    my($x2) = 0.0;
    for ($i = 0; $i < 4; $i++) {
	if ($f_exp[$i] > 0) {
	    my($difference) = ($f_obs[$i] - $f_exp[$i]);
	    $x2 += ($difference * $difference / $f_exp[$i]);
	}
    }

    return ($x2);
}


# calc_g2(F_observed_ref, F_expected_ref)
#
# Calculate the G-squared statistic (G^2 or log likelihood ratio) over 
# a 2x2 contingency table, and the table of expected freuqencies.
#
sub calc_g2 {
    &debug_print(&TL_VERBOSE, "calc_g2(@_)\n");
    my($f_obs_ref, $f_exp_ref) = @_;
    my(@f_obs) = @$f_obs_ref;
    my(@f_exp) = @$f_exp_ref;

    # Calculate the G^2 statistic:
    #    2 * sum(f_obs[ij] * log(f_obs[ii] / f_exp[ij]))
    my($g2) = 0.0;
    my($i);
    for ($i = 0; $i < 4; $i++) {
	if (($f_obs[$i] > 0) && ($f_exp[$i] > 0)) {
	    $g2 += $f_obs[$i] * log($f_obs[$i] / $f_exp[$i]);
	}
    }
    $g2 *= 2;

    return ($g2);
}

# calc_avg_mutual_info($f_AB, $f_A_notB, $f_notA_B, $f_notA_notB)
#
# Calculate average mutual information for a 2x2 contingency table
#
sub calc_avg_mutual_info {
    &debug_print(&TL_DETAILED, "calc_avg_mutual_info(@_)\n");    
    my($f_AB, $f_A_notB, $f_notA_B, $f_notA_notB) = @_;

    my(@matrix) = ([$f_AB, $f_A_notB],
		   [$f_notA_B, $f_notA_notB]);

    return (generic_calc_avg_mutual_info(\@matrix, 2, 2));
}

# generic_calc_avg_mutual_info(f_obs_matrix_ref, num_rows, num_cols)
# Calculate average mutual information for an arbirtray contingency table.
# This is the version of mutual information as described in [Pearl 88: pp 321-323]
# not the version usually used in computational linguistics.
#
#   I(T,X) = H(T) - H(T|X) = -sum(x, sum(t, P(t,x) * log(P(t,x) / (P(t) * P(x)))))
#
# Returns the real-valued metric (or undefined for invalid data).
#
sub generic_calc_avg_mutual_info {
    my($f_obs_ref, $rows, $cols) = @_;
    my(@f_obs) = @$f_obs_ref;
    my($i, $j);
    &debug_print(&TL_DETAILED, "generic_calc_avg_mutual_info(@_)\n");

    # Tabulate the margin frequencies
    #
    my($total) = 0;
    my(@row_sums, @col_sums);
    for ($j = 0; $j < $cols; $j++) {
	$col_sums[$j] = 0;
    }
    for ($i = 0; $i < $rows; $i++) {
	$row_sums[$i] = 0;
	for ($j = 0; $j < $cols; $j++) {
	    &debug_out(5, "f_obs[$i][$j] = %s\n", $f_obs[$i][$j]);
	    $row_sums[$i] += $f_obs[$i][$j];
	    $col_sums[$j] += $f_obs[$i][$j];
	}
	$total += $row_sums[$i];
    }
    if ($total == 0) {
	&error_out("Unexpected contingency counts: (@f_obs)\n");
	return undef;
    }

    # Add in the mutual information for each cell in the table
    #
    my($MI) = 0.0;
    for ($i = 0; $i < $rows; $i++) {
	for ($j = 0; $j < $cols; $j++) {
	    my($Pi) = $row_sums[$i] / $total;
	    my($Pj) = $col_sums[$j] / $total;
	    my($Pij) = $f_obs[$i][$j] / $total;
	    my($MI_value) = 0;
	    if (($Pij > 0) && ($Pi > 0) && ($Pj > 0)) {
		$MI_value = log($Pij / ($Pi * $Pj)) / log(2);
	    }
	    &debug_out(&TL_VERBOSE, "MI_value = %.3f; (%.3f %.3f %.3f)\n",
		       $MI_value, $Pi, $Pj, $Pij);
	    $MI += $Pij * $MI_value;
	}
    }
    &debug_print(&TL_VERBOSE, "MI = $MI\n");
    
    return ($MI);
}

# calc_mutual_info(f_AB, f_A_notB, f_notA_B, f_notA_notB)
#
# Calculates mutual information given the frequency counts in the 2x2
# contingency table.
#    log2(P(1,2) / P(1) * P(2))#
# Returns the real-valued metric (or undefined for invalid data).
#
sub calc_mutual_info {
    my($f_AB, $f_A_notB, $f_notA_B, $f_notA_notB) = @_;

    my($total) = ($f_AB + $f_A_notB + $f_notA_B + $f_notA_notB);
    if ($total == 0) {
	&error("Unexpected contingency counts: ($f_AB, $f_A_notB, $f_notA_B, $f_notA_notB)\n");
	return undef;
    }
    my($prob_A, $prob_B, $prob_AB) = &calc_marginal_probabilities($f_AB, $f_A_notB, $f_notA_B, $f_notA_notB);

    # Calculate the mutual information:
    #    log2(P(1,2) / P(1) * P(2))
    my($MI) = 0;
    if (($prob_A > 0) && ($prob_B > 0) & ($prob_AB > 0)) {
	$MI = log(($prob_AB) / ($prob_A * $prob_B)) / log(2);
    }

    return ($MI);
}

#------------------------------------------------------------------------------

# return successful-load status
1;
