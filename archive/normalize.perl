# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# normalize.perl: normalize the vector given on the command line
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

if (!defined($ARGV[0])) {
    $options = "options = [-format=spec]";
    $example = "ex: $script_name 5 10 15 20\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
}

&init_var(*format, "%.3f");

if ($ARGV[0] eq "-") {
    @ARGV = &tokenize(join(" ", <STDIN>));
}
printf "%s\n", join(" ", &normalize(@ARGV));

#------------------------------------------------------------------------------

sub normalize {
    local (@vector) = @_;
    local($i);

    local($sum) = 0.0;    
    for ($i = 0; $i <= $#vector; $i++) {
	$sum += $vector[$i];
    }
    if ($sum != 0) {
	for ($i = 0; $i <= $#vector; $i++) {
	    local($new_value) = ($vector[$i] / $sum);
	    $vector[$i] = sprintf $format, $new_value;
	}
    }

    return (@vector);
}
