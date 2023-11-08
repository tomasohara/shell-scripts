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
# This works by extracting tests of the following form:
#    # EX: test_expression => result
# The Perl expression is evaluated via eval() in the context of the script, and
# the valued is compared against the result text. (There is an option to
# evaluated tests in bash scripts, in which case the expression is a Bash command
# that is evaluated via run_command()).
#
# Example usage:
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
# - The &init function is optionally invoked to perform initialization.
#
#--------------------------------------------------------------------------------
# Detailed Example:
#
# - input (plus1.perl):
#
#   while (<>) {
#       chomp;
#       printf("%d\n", &plus1("$_"));
#   }
#
#   # EX: plus1(2) => 3
#   # EX: plus1("fubar") => 1
#   sub plus1 {
#     my($num) = @_;
#     return ($num + 1);
#   }
#
# - output (test-perl-examples.perl  _plus1.perl)
#     2 of 2 tests passed: 100.000%
#
# - generated code (/tmp/temp_test_plus1.perl)
#
#    require 'example-test-support.perl';
#
#    # Run the tests and then show the good/total statistics
#    &do_unit_tests();
#    &summarize_tests();
#    exit;
#
#    # ... [same as in input section above]
#
#    sub do_unit_tests {
#        &verify_test("plus1(2)", "3");
#     }
#
#--------------------------------------------------------------------------------
# TODO:
# - Fix processing of list arguments and results
# - Add support for other scripting languages (e.g., Python).
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN {
    my $dir = $0; $dir =~ s/[^\\\/]*$//; unshift(@INC, $dir);
    require 'common.perl';
    use vars qw/$TEMP $verbose $script_name $script_dir/;
}


use strict;
use vars qw/$strict $no_refs $init $first $max_failures/;
use vars qw/$bash $common $magic $source_path/;

# Show a usage statement if no arguments given
# NOTE: By convention - is used when no arguments are required
if (!defined($ARGV[0])) {
    my($options) = "main options = [-init=init-routine] [-strict] [-first] [-max_failures=N]";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "examples:\n\n$0 common.perl\n\n";
    $example .= "$script_name -verbose \$UTILITIES/graphling.perl\n\n";

    my($note) = "";
    $note .= "notes:\n\nMinimal error checking is performed.\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n$note";
}
my($script) = $ARGV[0];

$verbose = &TRUE if (&VERBOSE_DEBUGGING);
&init_var(*init, "init");               # name of initialization routine
&init_var(*strict, &FALSE);             # use strict var checking
&init_var(*no_refs, &FALSE);            # allow for references under strict
&init_var(*first, &FALSE);              # fail on first error
&init_var(*max_failures,                # maximum failures to allow
          ($first ? 1 : &MAXINT));
&init_var(*bash, &FALSE);               # test over bash script
&init_var(*utf8, &FALSE);               # use UTF-8 for I/O
&init_var(*magic, &FALSE);              # put perl magic at top
&init_var(*source_path, "");            # path of (Bash) script to source

# Read in the script and extract the EX comments
#
my(@old_lines) = split(/\n/, &read_file($script));
my(@tests) = grep { $_ =~ m/^\s*\#\s*EX:.*/i; } @old_lines;
&trace_array(\@tests, &TL_VERBOSE, "tests");


# Create wrapper script with unit-testing subroutine
#
my($new_script) = "";

$new_script .= "use strict;\n"  if ($strict);
$new_script .= "no strict \"refs\";\n"  if ($no_refs);

# TEST: optionally add magic at top
if ($magic) {
$new_script .= <<END_MAGIC;
# *-*-perl-*-*
eval 'exec perl -Ssw \$0 "\$@"'
    if 0;
END_MAGIC
}

# TEST: optionally enable UTF-8
if ($utf8) {
    $new_script .= <<END_UTF8;
    BEGIN {
        use open ":std", ":encoding(UTF-8)";
    }
END_UTF8
}


# Add header code: loads in script being tested
$new_script .= <<END_HEADER;
    BEGIN {
        unshift(\@INC, "$script_dir");
	# note: indirectly loads common.perl and extra.perl
        require 'example-test-support.perl';
    }
END_HEADER

 # Optionally add invoke init() function
if ($init ne "") {
    $new_script .= <<END_INIT
	# Invoke the script's initializations routine
	eval { &${init}() };
END_INIT
    }

# Add trailer code
$new_script .= <<END_TRAILER;
    # Run the tests and then show the good/total statistics
    &do_unit_tests();
    &summarize_tests();
    exit;   
END_TRAILER

    
# Add in the original script contents followed by the supporting functions
# for performing units tests.
# TODO: use require for original script???   
$new_script .= join("\n", @old_lines);
$new_script .= <<END_TRAILER;

    
    #========================================================================
    
    sub do_unit_tests {
    
END_TRAILER


# Add the body of the unit-testing function, followed by closing brace.
# for the do_unit_tests function.
#
$new_script .= &format_unit_tests(@tests);
## $new_script .= &new_format_unit_tests(@tests);
$new_script .= "    }\n";

# Write the script to a temporary file for the wrapper script and
# then evaluate the wrapper script to run the tests
# NOTE: the file permission is set to read-only to avoid inadvertant
# modification (e.g., modifying testing version instead of original script).
#
my($new_script_name) = &make_path($TEMP, "temp_test_" . &remove_dir($script));
&cmd("chmod +w $new_script_name") unless (! -f $new_script_name);
&write_file($new_script_name, $new_script);
&cmd("chmod -w $new_script_name");
&cmd("perl -s $new_script_name -verbose=$verbose -bash=$bash -source_path=$source_path");

&exit();

#------------------------------------------------------------------------------

# format_unit_tests(list_of_tests): creates perl code for evaluating the
# tests specified in the list and comparing vs. the specified result
#
# EX: format_unit_tests("# EX: plus1(5) \=\> 6", "# EX: max(2,3) \=\> 3") => "        &verify_test(\"plus1(5)\", \"6\");\n        &verify_test(\"max(2,3)\", \"3\");\n"
# EX: format_unit_tests("# EX: parse_word_spec(\"5. a\") \=\> (4, \"\", \"a\")") => "        &verify_test(\"parse_word_spec(\\\"5. a\\\")\", \"(4, \\\"\\\", \\\"a\\\")\");\n"
#
# TODO:
# - Rework &verify_test so that TEST and RESULT are not specified as strings.
# - Handle single quotes as well as double quotes (eg, remove enclosing ones from result).
#
sub format_unit_tests {
    my(@tests) = @_;
    &debug_print(&TL_VERBOSE, "format_unit_tests(@_)\n");
    my($test_code) = "";

    foreach my $test (@tests) {
        if ($test =~ /^\s*\#\s*EX:\s*(.*)\s*=>\s*(.*)\s*/i) {
            my($evaluation, $result) = ($1, $2);

            # Preprocess evaluation:
            # - Escape special characters in test (e.g., to avoid unwanted interpolation).
            # - Remove extraneous space (special case for final comparison of tests in comments above).
            # NOTE: existing escaped quotes are doubly escaped
            $evaluation =~ s/\\=\\>/=>/g;               # '\=\>' => '\=>'
            $evaluation =~ s/\\\"/\\\\\\\"/g;           # \" => \\\"
            $evaluation =~ s/([^\\])\"/$1\\\"/g;        # " => \"
            $evaluation =~ s/([^\\])\"/$1\\\"/g;        # twice for good measure
            $evaluation =~ s/([^\\])\\([^\\\$\'\"])/$1\\\\$2/g; # '\' => '\\' unless part of escape
            $evaluation =~ s/([\$\@])/\\$1/g;           # '$' or '@' to '\$' or '\@'
            $evaluation = &trim($evaluation);

            # Preprocess the result
            # - Remove surrounding quotes since added below.
            # - Add proper escapes for the result.
            # TODO:
            # - Check whether result should be a list (and call verify_test accordingliy).
            $result =~ s/^\s*\"//;                      # remove leading quote
            $result =~ s/\"\s*$//;                      # remove trailing quote
            $result =~ s/([^\\])\"/$1\\\"/g;            # " => \"
            $result =~ s/([^\\])\"/$1\\\"/g;            # again, twice for good measure
	    $result =~ s/^\$\'/\'/;                     # $'...' => '...'
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
