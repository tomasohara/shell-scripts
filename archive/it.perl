# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# it.perl: whatever it does
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = $0; $dir =~ s/[^\\\/]*$//; unshift(@INC, $dir);
    require 'common.perl';
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
## use vars qw/$fu $bar/;

# Show a usage statement if no arguments given
# NOTE: By convention '-' is used when no arguments are required
if (!defined($ARGV[0])) {
    my($options) = "main options = []";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "Examples:\n\n$script_name example\n\n";  # TODO: example
    ## $example .= "$0 example2\n\n";		   	     # TODO: 2nd example
    my($note) = "";
    ## $note .= "Notes:\n\nSome usage note.\n";		     # TODO: usage note

    print STDERR "\nUsage: $script_name [options]\n\n$options\n\n$example\n$note";
    &exit();
}

# Check the command-line options
# note: Each variable initialized corresponds to a -var=value commandline option
## &init_var(*fu, &FALSE);		# TODO: add command-line options

while (<>) {
    &dump_line();
    chomp;

    # TODO: do whatever

    # TODO: print the result
    ## print "$_\n";
}

&exit();


#------------------------------------------------------------------------------

# TODO: subroutine101(some_arg): What subroutine101 does
#
sub subroutine101 {
    ## my($arg) = @_;
    &debug_print(&TL_VERBOSE, "subroutine101(@_)\n");

    return;
}
