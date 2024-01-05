# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# sqrt.perl: calculates square root using newton's method
#
# Algorithm taken from
#    Russell, Stuart  J., and Peter Norvig, Artificial Intelligence: 
#    A Modern Approach, Prentice-Hall: Upper Saddle River, NJ, p 34.
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir);
    require 'common.perl';
}

foreach $token (@ARGV) {
    printf "sqrt($token) = %g; square_root($token) = %g\n",
          sqrt($token), square_root($token);
}

#------------------------------------------------------------------------------

# square_root(x)
# EX: square_root(16) => 4
#
# Calculates the square root of a number using Netwon's method
# (as given in [Russell & Norvig 95]).
#
sub square_root {
    local($x) = @_;
    local($EPSILON) = 1.0e-15;
    &debug_out(4, "square_root($x)\n");

    local($z) = 1.0;
    while (abs($z ** 2 - $x) >= $EPSILON) {
	$z -= ($z ** 2 - $x) / (2 * $z);
	&debug_out(4, "z = $z\n");
    }

    return ($z);
}
