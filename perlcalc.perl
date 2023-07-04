# !/usr/bin/perl -sw
# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# perlcalc.perl: simple calculator in perl
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir);
    require 'common.perl';
    # Note '()' added to use to avoid global namespace usage, so that all
    # functions need to be fully qualified (e.g., POSIX::ceil).
    ## BAD: use POSIX;
    use POSIX();
    use strict;
    use vars qw/$precision $help/;
}

#...............................................................................
# Helper functions for interactive usge
# TODO:
# - use sub CONST() throughout for constants, and replace &CONST with CONST
# - use common.perl for functions like round()

# PI derived via bc: pi=$(echo "scale=10; 4*a(1)" | bc -l)
#
sub PI() { 3.1415926532 }

# log2(num): logarithm of NUM to base 2
#
sub log2 {
    my($num) = @_;
    return (log($num) / log(2));
}

# log2(num): logarithm of NUM to base 2
#
sub log10 {
    my($num) = @_;
    return (log($num) / log(10));
}

# round_num(number, [precision=3]): rounds NUMBER to PRECISION places
# NOTE: Use -precision=N or PRECISION=N when invoking script for output rounding.
#
sub round_num {
    &debug_print(&TL_DETAILED, "round_num(@_)\n");
    my($number, $places) = @_;
    $places = $precision if (! defined($places));
    &debug_print(&TL_VERBOSE, "n=$number p=$places\n");
    my($result) = sprintf("%.${places}f", $number);
    return $number;
}
#
## TODO: sub round { &round_num($_[0]); }
#
sub round1 { &round_num($_[0], 1); }
sub round2 { &round_num($_[0], 2); }
sub round3 { &round_num($_[0], 2); }
sub round6 { &round_num($_[0], 6); }

# ceil(number): number rounded to nearest integer
#
sub ceil {
    return POSIX::ceil(@_);
}

#...............................................................................

if ((defined($ARGV[0]) && ($ARGV[0] eq "help"))
    || (defined($help) && $help)
    || (!defined($ARGV[0]) && &blocking_stdin())) {
    $options = "options = [-init=expr] [-fmt=printf-format-spec] [-integer | -precision=N] [-args | -]";
    $example = "examples:\n\n";
    $example .=	"$script_name whatever\n";
    $example .= "$script_name -precision=6 '1/10e6'\n";
    die "\nusage: $script_name [options]\n\n$options\n\n$example\n";
}

use vars qw/$args $init $int $integer $fmt/;
&init_var_exp(*init, "");	        # initialization expression
&init_var_exp(*int, &FALSE);	        # alias for -integer
&init_var_exp(*integer, $int);          # show integral results
## OLD: &init_var_exp(*fmt, 		# format for output
##                    $integer ? "%d" : "%g");
my($default_format) = $integer ? "%d" : (sprintf("%%.%df", $precision));
&init_var_exp(*fmt, 		# format for output
	      $default_format);
## OLD: &init_var(*args, &FALSE);	# read expression from command line
# TODO: exclude case when argument is file that exists
my($args_given) = ((defined($ARGV[0]) && ($ARGV[0] ne "-")));
&init_var(*args, $args_given);	# read expression from command line

# Run scripts from temporary file using expression on command line
# note: uses -args=0 to avoid infinite loop in stdin detection
if ($args) {
    print &run_command_over("$0 -args=0", "(@ARGV)\n") . "\n";
    &exit();
}


# Evaluate the initialization expression
if ($init ne "") {
    &debug_print(&TL_VERBOSE, "evaluating initialization '$init'\n");
    eval "$init";
}

&debug_print(&TL_VERY_DETAILED, "checking stdin\n");
while (<>) {
    &dump_line();
    chomp;
    my($expr) = $_;

    # Remove comma's and dollar signs preceding numbers
    # Convert ^'s into **'s.
    # TODO: add other formula preprocessing
    $expr =~ s/[\$,]([0-9])/$1/g;
    $expr =~ s/\^/**/g;

    # Print the results of the current evaluation
    if (&trim($expr) ne "") {
	&debug_print(&TL_VERBOSE, "evaluating expression '$expr'\n");
	printf("$fmt\n", eval "$expr");
    }
}
