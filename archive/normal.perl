# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# normal.perl: program for generating a random normal distribution
#
# The random normal generation is based on the normal approximation to
# the binomial distribution, which is simpler to generate. Specifically,
# each random value of a standard normal distribution is generated by
# determining the corresponding Z value to a random binomial experiment with
# a large number of trials (Z = (B - np)/sqrt(npq)), where B is the number
# of successes in n trials with probability of success p. Then to produce
# the value for a normal distribution, the z-transformation (Z=(x-u)/o) 
# is reversed (u is mean; o is standard deviation).
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';
&debug_out(4, "start: %s\n", scalar(localtime));

&init_var(*num, 100);		# number of samples to generate
&init_var(*sigma, 1);		# population standard deviation
&init_var(*mu, 0);		# population mean
&init_var(*n, 1000);		# number of trials for binomial simulation
&init_var(*p, 0.5);		# probability of success for binomial
&init_var(*seed, time);		# seed for random number generator

# Initialize the (pseudo) random number generator
srand($seed);

# Calculate intermediate values used in binomial approximation
# (Z = (B - np)/sqrt(npq)).
local($np) = $n * $p;
local($sqrt_npq) = sqrt($n * $p * (1 - $p));
&debug_out(5, "np=$np sqrt_npq=$sqrt_npq\n");

local($sum) = 0.0;
local(@x);
local($i);
for ($i = 0; $i < $num; $i++) {
    local($b, $z, $x);

    # Generate binomial for large n and use Z approximation
    #    Z = (B - np)/sqrt(npq)
    $b = &random_binomial($n, $p);
    $z = ($b - $np)/$sqrt_npq;

    # Transform into x by inverting z transformation
    #    Z = (X - $mu)/$sigma;
    $x[$i] = $z * $sigma + $mu;

    # Update sum of x's
    $sum += $x[$i];
    &debug_out(6, "b=%d z=%.3f x=%.3f\n", $b, $z, $x[$i]);

    printf "%.3f ", $x[$i];
}
printf "\n";

# Compute sample mean
local($mean) = $sum / $num;

# Compute sample standard deviation
$sum_sq_mean_diff = 0.0;
for ($i = 0; $i < $num; $i++) {
    $sum_sq_mean_diff += ($x[$i] - $mean) ** 2;
}
local($stdev) = sqrt($sum_sq_mean_diff / ($num - 1));

# Output the results
printf "sample mean = %.3f stdev = %.3f\n", $mean, $stdev;

&debug_out(4, "end: %s\n", scalar(localtime));

#------------------------------------------------------------------------------

# random_binomial(n, p): generate random binomial sample for the number
# of successes in n trials, where the probability of success is p.
#
sub random_binomial {
    local($n, $p) = @_;
    local($i);
    local($successes) = 0;

    for ($i = 0; $i < $n; $i++) {
	$successes++ if (rand() < $p);
    }

    return ($successes);
}