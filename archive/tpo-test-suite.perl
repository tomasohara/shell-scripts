# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# tpo-test-suite.perl: simple test suite for testing my perl scripts
#
# TODO: add test for commonly used scripts (e.g., sum_file.perl, cut.perl, paste.perl, count_it.perl, calc_cooccurrence.perl, perlcalc.perl, foreach.perl,  perlgrep.perl)
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

# Show a usage statement if no arguments given
# NOTE: By convention - is used when no arguments are required
if (!defined($ARGV[0])) {
    my($options) = "options = [-quiet]";
    my($example) = "examples:\n\n$script_name -\n\n";
    ## $example .= "$0 example2\n\n";			# TODO: revise example 2
    my($note) = "";
    ## $note .= "notes:\n\nSome usage note.\n";		# TODO: add optional note

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n$note";
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
use vars qw/$quiet/;

# Check the command-line options
# Each variable initialized corresponds to a -var=value command-line option
&init_var(*quiet, &FALSE);		# terse output mode

# Run each of the tests
# TODO: get the test case description from the input
&test_perl_script("calc_entropy.perl",  "-skip_header -simple .25 .25 .25 .25", "2.000");
# note: hexview.perl doesn't require - for when stdin used
&test_perl_script("hexview.perl",  "/dev/null", "");
# TODO: &test_perl_script("hexview.perl",  "/bin/ls", "od -x ... /bin/ls");

# Show the results
printf "%d of %d tests passed\n", &num_tested_ok(), &total_num_tested();

&exit();


#------------------------------------------------------------------------------

# Support for testing scripts
#
# total_num_tested(): number of tests attempted
# num_tested_OK(): number of tests that succeeded
#
our($num_OK) = 0;
our($num_tested) = 0;
#
sub num_tested_ok { $num_OK; }
sub total_num_tested { $num_tested; }

# test_perl_script(script-name, command-line, expected-result)
#
# Tests the perl script using the specied command line to invoke it
# and checking whether the actual results matches the expected results.
#
sub test_perl_script {
    my($script, $command_line, $expected_result) = @_;
    &debug_print(&TL_VERBOSE, "test_script(@_)\n");

    # Run the script with the specified arguments
    print "Issuing: $script ${command_line}\n" unless ($quiet);
    my($actual_result) = &perl("$script ${command_line}");
    $num_tested++;

    # Display status message
    my($OK) = &boolean($actual_result eq $expected_result);
    print "OK: $OK\n" unless ($quiet);
    if ($OK) {
	$num_OK++;
    }
    else {
	print "Expected: $expected_result\n";
	print "Result: $actual_result\n";
    }

    return ($OK);
}
