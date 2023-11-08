# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# calc_divergence.perl: calculate kullback-leibler divergence (aka
# relative entropy)
#
# From (Manning and Schutze 1999):
#
# H(X) = \sum_x p(x) log 1/p(x)
#
# D(p || q) = \sum_x p(x) log p(x)/q(x)
#
#........................................................................
# TODO:
# - Add more flexible input distribution specifications.
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir);
    require 'common.perl';
    require 'extra.perl';
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
## use vars qw/$fu $bar/;

# Show a usage statement if no arguments given
# NOTE: By convention - is used when no arguments are required
if (!defined($ARGV[1])) {
    my($options) = "main options = []";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "examples:\n\n$script_name '0.677 0.146 0.024 0.028 0.076 0.049' '0.723 0.154 0.021 0.014 0.072 0.017'\n\n";
    ## $example .= "$0 example2\n\n";		   	     # TODO: 2nd example
    my($note) = "";
    ## $note .= "notes:\n\nSome usage note.\n";		     # TODO: usage note

    print STDERR "\nusage: $script_name [options] 'dist-1' 'dist-2'\n\n$options\n\n$example\n$note";
    &exit();
}
my(@dist1) = &tokenize($ARGV[0]);
my(@dist2) = &tokenize($ARGV[1]);
&assert((scalar @dist1) == (scalar @dist2));

# Check the command-line options
# note: Each variable initialized corresponds to a -var=value commandline option
## &init_var(*fu, &FALSE);		# TODO: add command-line options

my($sum) = 0;
for (my $i = 0; $i <= $#dist1; $i++) {
    my($log_ratio) = ($dist2[$i] > 0) ? &log2($dist1[$i] / $dist2[$i]) : 0;
    &debug_out(&TL_DETAILED, "p[%d]=%.3f q[%d]=%.3f log(p/q)=%.3f\n",
	       $i, $dist1[$i], $i, $dist2[$i], $log_ratio);
    $sum += $dist1[$i] * $log_ratio;
}
print &round($sum), "\n";

&exit();
