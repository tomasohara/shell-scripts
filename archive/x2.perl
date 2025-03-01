# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# name.perl: whatever it does
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

if ((defined($ARGV[0]) && ($ARGV[0] eq "help"))
    || (!defined($ARGV[0]) && &blocking_stdin())) {
    $options = "options = n/a";
    $example = "ex: $script_name observations_CR_expected_CR_file\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
}

# Read in the data. The observations are on the first line, and the
# expected values are on the second. Comments are ignored.
#
@observation = ();
@expected = ();
while (<>) {
    &dump_line();
    next if (/^\s*\#/);
    if ($#observation < 0) {
	@observation = split;
    }
    elsif ($#expected < 0) {
	@expected = split;
    }
}

&debug_out(4, "observations: @observation\n");
&debug_out(4, "expected: @expected\n");

$chi2 = 0.0;
for ($i = 0; $i <= $#observation; $i++) {
    $diff2 = ($observation[$i] - $expected[$i]) ** 2;
    $chi2_value = 0.0;
    if ($expected[$i] > 0) {
	$chi2_value = ($diff2 / $expected[$i]);
    }
    $chi2 += $chi2_value;
    &debug_out(4, "Fo=%.3f Fe=%.3f diff2=%.3f chi2_value=%.3f\n",
	       $observation[$i], $expected[$i], $diff2, $chi2_value);
}
printf "chi^2 = %.3f\n", $chi2;

