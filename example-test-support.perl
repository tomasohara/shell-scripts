# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
# example-test-support.perl: support code for test-perl-examples.perl
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = `dirname '$0'`; chomp $dir; unshift(@INC, $dir);
    require 'common.perl';
    require 'extra.perl';
}

use vars qw/$verbose $max_failures/;
&init_var(*verbose, &FALSE);		# verbose output mode
&init_var(*max_failures, &MAXINT);	# max failures before abort
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
    my($result) = eval $test;
    if (! defined($result) && ($@ ne "")) {
	# Use the error code of the failed evaluation as the result
	$result = $@;
	$test_failed = &TRUE;
	
	&debug_print(&TL_VERBOSE, "failure in test evaluation\n");
    }
    else {
	&debug_print(&TL_VERBOSE, "result='$result'\n");
	if ($desired_result =~ /^\s*\(.*\)\s*$/) {
	    # Re-evaluate test expression as list
	    # TODO: exclude strings with outer parentheses (coordinate with format_unit_tests in test-perl-examples.perl)
	    # NOTE: Separate evaluation required so that error can be detected
	    # via undef since in list environment undef same as empty list.
	    my(@result) = eval $test;

	    # Quote strings elements, and then add comma's in string list
	    @result = map { (isnum($_) ? $_ : ('"' . $_ . '"')) } @result;
	    $result = "(" . join(", ", @result) . ")";
	}
	elsif (!defined($result)) {
	    &debug_print(&TL_VERBOSE, "test failure due to scalar undef\n");;
	    $result = "undef";
	    $test_failed = &TRUE;
	}
	else {
	    # Treat "" as zero is number expected
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

	    # Compare versus desired result (via eval for extra flexibility)
	    # TODO: make sure the unqouted-result check doesn't lead to false positives
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
