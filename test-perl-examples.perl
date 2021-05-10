# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# test-perl-examples.perl: Script for performing unit tests on functions in 
# perl scripts by checking for examples flagged with 'EX:' in the function
# header.
#
# Example:
#
#   # fubar(list): permutates list
#   # EX: fubar("1", "2", "3") => ("3", "2", "1")
#   sub fubar {
#   ...
#   }
#
# This works by creating a wrapper perl script which includes the script to
# be tested as well as a new function &do_unit_tests() derived by combining
# all the example function invocations.
#
# NOTE:
# - The 'EX:' comment is assumed to reside on a single line, so that detailed
#   parsing is not required.
#
# TODO:
# - Work out a way to invoke the main body of the script preior to performing
#   tests, in case initializations are needed.
# - Fix processing of list arguments and results
# - tally up the number of correct tests
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN {
    my $dir = $0; $dir =~ s/[^\\\/]*$//; unshift(@INC, $dir);
    require 'common.perl';
    use vars qw/$TEMP $verbose $script_name $script_dir/;
}


use strict;
use vars qw/$strict $no_refs $init $first $max_failures/;

# Show a usage statement if no arguments given
# NOTE: By convention - is used when no arguments are required
if (!defined($ARGV[0])) {
    my($options) = "main options = [-init=init-routine] [-strict] [-first] [-max_failures=N]";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "examples:\n\n$0 common.perl\n\n";
    $example .= "$script_name -verbose \$UTILITIES/graphling.perl\n\n";

    my($note) = "";
    ## $note .= "notes:\n\nSome usage note.\n";		     # TODO: usage note

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n$note";
}
my($script) = $ARGV[0];

## &init_var(*verbose, &VERBOSE_DEBUGGING); # verbose testing mdoe
$verbose = &TRUE if (&VERBOSE_DEBUGGING);
&init_var(*init, "init");		# name of initialization routine
&init_var(*strict, &FALSE);		# use strict var checking
&init_var(*no_refs, &FALSE);		# allow for references under strict
&init_var(*first, &FALSE);		# fail on first error
&init_var(*max_failures, 	 	# maximum failures to allow
	  ($first ? 1 : &MAXINT));

# Read in the script and extract the EX comments
#
my(@old_lines) = split(/\n/, &read_file($script));
my(@tests) = grep { $_ =~ m/^\s*\#\s*EX:.*/i; } @old_lines;
&trace_array(\@tests, &TL_VERBOSE, "tests");


# Create wrapper script with unit-testing subroutine
#
my($new_script) = "";

$new_script .= "use strict;\n"	if ($strict);
$new_script .= "no strict \"refs\";\n"	if ($no_refs);

$new_script .= <<END_HEADER;

    BEGIN {
        unshift(\@INC, "$script_dir");
        require 'example-test-support.perl';
    }

    # Invoke the script's initializations routine
    eval { &${init}() };
    
    # Run the tests and then show the good/total statistics
    &do_unit_tests();
    &summarize_tests();
    exit;
    
END_HEADER


# Add in the original script contents followed by the supporting functions
# for performing units tests
$new_script .= join("\n", @old_lines);
$new_script .= <<END_TRAILER;

    
    #========================================================================
    
    sub do_unit_tests {
    
END_TRAILER


# Add the body of the unit-testing function
#
$new_script .= &format_unit_tests(@tests);
## $new_script .= &new_format_unit_tests(@tests);
$new_script .= "    }\n";

# Write the script to a temporary file for the wrapper script and
# then evaluate the wrapper script to run the tests
# NOTE: the file permission is set to read-only to avoid inadvertant
# modification (eg, modifying testing version instead of original script).
#
my($new_script_name) = &make_path($TEMP, "temp_test_" . &remove_dir($script));
&cmd("chmod +w $new_script_name") unless (! -f $new_script_name);
&write_file($new_script_name, $new_script);
&cmd("chmod -w $new_script_name");
&cmd("perl -s $new_script_name -verbose=$verbose");

&exit();


#------------------------------------------------------------------------------

# format_unit_tests(list_of_tests): creates perl code for evaluating the
# tests specified in the list and comparing vs. the specified result
#
# EX: format_unit_tests("# EX: plus1(5) \=\> 6", "# EX: max(2,3) \=\> 3") => "        &verify_test(\"plus1(5)\", \"6\");\n        &verify_test(\"max(2,3)\", \"3\");\n"
# EX: format_unit_tests("# EX: parse_word_spec(\"5. a\") \=\> (4, \"\", \"a\")") => "        &verify_test(\"parse_word_spec(\\\"5. a\\\")\", \"(4, \\\"\\\", \\\"a\\\")\");\n"
#
# TODO:
# - fix '&verify_test("parse_word_spec(\"5. a\")", "(4, \"", \"a\")");'
# - rework &verify_test so that TEST and RESULT are not specified as strings
# - handle single quotes as well as double quotes (eg, remove enclosing ones from result)
#
sub format_unit_tests {
    my(@tests) = @_;
    &debug_print(&TL_VERBOSE, "format_unit_tests(@_)\n");
    my($test_code) = "";

    foreach my $test (@tests) {
	if ($test =~ /^\s*\#\s*EX:\s*(.*)\s*=>\s*(.*)\s*/i) {
	    my($evaluation, $result) = ($1, $2);

	    # Preprocess evaluation:
	    # - Escape special characters in test (e.g., to avoid unwanted interpolation)
	    # - remove extraneous space (special case for final comparison of tests in comments above)
	    # NOTE: existing escaped quote are doubly escaped
	    $evaluation =~ s/\\=\\>/=>/g;		# '\=\>' => '\=>'
	    $evaluation =~ s/\\\"/\\\\\\\"/g;	     	# \" => \\\"
	    $evaluation =~ s/([^\\])\"/$1\\\"/g;	# " => \"
	    $evaluation =~ s/([^\\])\"/$1\\\"/g;     	# twice for good measure
	    $evaluation =~ s/([^\\])\\([^\\\$\'\"])/$1\\\\$2/g;	# '\' => '\\' unless part of escape
	    $evaluation =~ s/([\$\@])/\\$1/g;		# '$' or '@' to '\$' or '\@'
	    $evaluation = &trim($evaluation);

	    # Preprocess the result
	    # - Remove sounding quote since added below
	    # - add proper escapes for the result
	    # TODO:
	    # - check whether result should be a list (and call verify_test accordingliy)
	    $result =~ s/^\s*\"//;			# remove leading quote
	    $result =~ s/\"\s*$//;			# remove trailing quote
	    $result =~ s/([^\\])\"/$1\\\"/g;		# " => \"
	    $result =~ s/([^\\])\"/$1\\\"/g;	     	# again, twice for good measure
	    $result =~ s/([\$\@])/\\$1/g;               # '$' or '@' to '\$' or '\@'


	    # Add a function call to verify the test
	    $test_code .= "        &verify_test(\"$evaluation\", \"$result\");\n";
	}
	else {
	    &warning("Problem creating test for '$test'\n");
	}
    }

    return ($test_code);
}
