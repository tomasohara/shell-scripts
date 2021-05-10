# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# get_OED_SAMPLE.perl: retrieve OED's word of the day
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

if (defined($ARGV[0]) && ($ARGV[0] eq "help")) {
    $options = "options = n/a";
    $example = "ex: $script_name whatever\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
}

&init_var(*output_dir, ".");

&debug_out(5, "today is %s\n", &get_MDY());

# Retrive the text and remove extraneous form-related stuff
#
## $result = &run_command("lynx -dump http://www.oed.com/SAMPLES/oedrand.html");
$result = &run_command("lynx -dump http://proto.oed.com/SAMPLES/oedrand.html");
if ($result !~ /Oxford/) {
    &run_command("assertion.tcl Unexpected OED output");
}

# Keep the extraneous stuff for now. A separate script can do the
# filtering, so that nothing inadvertently gets losts
#
## $result =~ s/(.|\n)*Following Entry//;
## $result =~ s/Find the OED(.|\n)*//;

$MDY = &get_MDY();
$MDY =~ s/\///g;

&write_file("${output_dir}/OED_$MDY.list", $result);

#------------------------------------------------------------------------------

# get_MDY(): returns current date in MM/DD/YY format
#
sub get_MDY {
    &debug_out(4, "get_MDY()\n");

    # Get the local time structure
    local($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) 
	= localtime(time);
    &debug_out(6, "($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)\n");

    # Format it as MM/DD/YY 
    local($MDY) = sprintf "%02d\/%02d\/%02d", ($mon + 1), $mday, $year;

    return ($MDY);
}
