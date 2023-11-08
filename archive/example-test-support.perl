# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
# example-test-support.perl: support code for test-perl-examples.perl
#
# This script is used by the dynamically generated testing script (via require):
# see test-perl-example.perl. In particular, the verify_test() function
# is implemented here. It is called for each test extracted from the script.
# The function summarize_tests, also implemented here, is used to output
# the number of good vs. total tests and the accuracy score.
#
# Normally it takes a Perl expression and evaluates it via eval(). However,
# there is an option to test Bash script in which case run_command() is used.
# If aliases are defined, the script must be sourced. In both cases, the
# result is a string that is compared for equality against the evaluated
# value. (Some postprocessing is included, such as to resolute array or
# reference references into expressions.)
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = `dirname '$0'`; chomp $dir; unshift(@INC, $dir);
    require 'common.perl';
    use vars qw/$TEMP/;
    require 'extra.perl';
}

# Uncomment the following to help track down undeclared variables.
# Be prepared for a plethora of warnings. One that is important is
#    'Global symbol "xyz" requires explicit package name'
# when NOT preceded by 'Global symbol "xyz" requires explicit package name'
#
## use strict;
## no strict "refs";		# to allow for symbolic file handles
## use diagnostics;

# Note: does not specify 'use strict;' as strict mode is optional.
# See above for commented out specification (for debugging changes).
#
use vars qw/$verbose $max_failures $bash $source_path/;
#
&init_var(*verbose, &FALSE);		# verbose output mode
&init_var(*max_failures, &MAXINT);	# max failures before abort
&init_var(*bash, &FALSE);               # run test via shell (not perl eval)
&init_var(*source_path, "");            # path of (Bash) script to source
my($failed_tests) = 0; 			# count of failed tests
my($total_tests) = 0;			# total number of tests


# verify_test(test_expression, result): check whether TEST_EXPRESSION evaluates
# to RESULT. If not, issue an error report.
#
# TODO: use Data::Dumper to get ascii representation of result
#
sub verify_test {
    my($test, $desired_result) = @_;
    print STDERR "Testing $test => $desired_result: " if ($verbose);

    # Get the result in format compatible with desired result
    my($test_failed) = &FALSE;
    ## OLD: my($result) = eval $test;
    my($result);
    if (! $bash) {
	$result = eval $test;
    }
    else {
	# note: need to ensure the script is sourced prior to each test
	if ($source_path ne "") {
	    my($temp_command) = &make_path($TEMP, "_command-${total_tests}.list");
	    &write_file($temp_command, "$test\n");
	    $result = &run_command("bash -O expand_aliases -c 'source $source_path > /dev/null 2>&1; source $temp_command'");
	}
	else {
	    $result = &run_command("$test");
	}
    }
    if (! defined($result)) {
	# Use the error code of the failed evaluation as the result
	if ($@ ne "") {
	    $result = $@;
	}
	else {
	    $result = "undef";
	}
	$test_failed = &TRUE;
	
	&debug_print(&TL_VERBOSE, "failure in test evaluation: $result\n");
    }
    else {
	&debug_print(&TL_VERBOSE, "result='$result'\n");
	if ($desired_result =~ /^\s*\(.*\)\s*$/) {
	    # Re-evaluate test expression as list
	    # TODO: Exclude strings with outer parentheses (coordinate with format_unit_tests in test-perl-examples.perl).
	    # NOTE: Separate evaluation required so that error can be detected
	    # via undef since in list environment undef same as empty list.
	    my(@result) = eval $test;

	    # Quote strings elements, and then add comma's in string list
	    @result = map { (isnum($_) ? $_ : ('"' . $_ . '"')) } @result;
	    $result = "(" . join(", ", @result) . ")";
	}
	elsif (!defined($result)) {
	    &debug_print(&TL_VERBOSE, "Warning: test failure due to scalar undef\n");;
	    $result = "undef";
	    $test_failed = &TRUE;
	}
	else {
	    # Treat "" as zero if number expected
	    # TODO: Make this result conversiob optional.
	    $result = 0 if (($result eq "") && (&is_numeric($desired_result)));

	    # Resolve array and hash references
	    if ($result =~ /ARRAY\(0x/) {
		$result = "(" . join(" ", @$result) . ")";
	    }
	    if ($result =~ /HASH\(0x/) {
		my(@values_spec) = map { sprintf "'%s' => %s", $_, $$result{$_}; } keys(%$result);
		$result = "{" . join(",", @values_spec) . "}";
	    }
	}


	# Compare returned result versus expected result, accounting for
	# differences in outer quotes.
	if (! $test_failed) {
	    # Preprocess the desired result
	    my($unquoted_desired_result) = &remove_outer_quotes($desired_result);
	    my($unquoted_result) = &remove_outer_quotes($result);

	    # Compare versus desired result (via eval for extra flexibility).
	    # TODO: Make sure the unqouted-result check doesn't lead to false positives.
	    $test_failed = (($result ne $desired_result)
			    && ($result ne $unquoted_desired_result)
			    && ($unquoted_result ne $desired_result)
			    && ($unquoted_result ne $unquoted_desired_result));
	}
    }

    # Tabulate the results, and display synopsis of the test
    $total_tests++;
    if ($test_failed) {

	print STDERR "$test => $desired_result " unless ($verbose);
	print STDERR "failed [result=$result]\n";
	$failed_tests++;

	# Abort if the number of failures exceeds the threshold
	if ($failed_tests >= $max_failures) {
	    &exit("Maximum number of failures ($max_failures) reached\n");
	}
    }
    else {
	print STDERR "passed\n" if ($verbose);
    }
}


# isnum(text): indicates whether text is numeric: [-]NNN.NNN[e[+-]N]
#
# EX: isnum("89") => 1
# EX: isnum("0.7") => 1
# EX: isnum("0") => 1
# EX: isnum("5.3e10") => 1
# EX: isnum("five") => 0
# EX: isnum("-") => 0
#
# TODO: try to avoid using the non-placeholder grouping regex (?:...)
#
sub isnum {
    my($text) = @_;

    my($OK) = &boolean((length($text) > 0) 
		       && ($text =~ /\d+/)
		                           ## note: (?:pattern) groups without capturing
		       && ($text =~ /^\s*-?\d*\.?\d*(?:e[+-]?\d+)?\s*$/i));
    &debug_print(&TL_VERY_VERBOSE, "isnum(@_) => $OK\n");

    return ($OK);
}


# summarize_tests(): summarize the results of the testing
#
sub summarize_tests {
    my($good_tests) = ($total_tests - $failed_tests);

    my($average) = ($total_tests > 0) ? ($good_tests / $total_tests) * 100: 0;
    printf "%d of %d tests passed: %.3f%%\n", $good_tests, $total_tests, $average;
}


#------------------------------------------------------------------------
# Return successful load indicator
1;
