# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# name.perl: whatever it does
# TODO: Address the to-do notes below (search for 'todo')
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = $0; $dir =~ s/[^\\\/]*$//; unshift(@INC, $dir);
    require 'common.perl';
    use vars qw/$help/;
    ## TODO: use vars qw/$help $verbose $TEMP/;
}
## use English;				# for $PREMATCH, etc.
my($show_help) = $help;

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
## use vars qw/$fu $bar/;
## TODO:
## # Customize how init_var works (see common.perl)
## &set_init_var_export(&TRUE);            # treat init_var as init_var_exp
## &block_init_var_via_env(&TRUE);         # block use of env. vars in init_var

# Show a usage statement if no arguments given.
# NOTE: By convention '-' is used when no arguments are required.
# TODO: Add support for -help
if ((!defined($ARGV[0]) || $show_help)) {
    # Construct usage options spec, notes, examples and notes
    my($options) = "main options = [-TODO]";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "Example(s):\n\n$script_name -todo-option TODO-arg\n\n";
    ## $example .= "$0 example2\n\n";		   	     # TODO: 2nd example
    my($note) = "";
    $note .= "Notes:\n\nTODO: Some usage note.\n\n";

    # Print the usage (n.b., examples and notes should end in double newlines)
    &assertion(($example =~ /\n\n$/) && ($note =~ /\n\n$/));
    print STDERR "\nUsage: $script_name [options]\n\n$options\n\n$example$note";
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

# The end
&exit();


#------------------------------------------------------------------------------

# TODO: subroutine101(some_arg): What subroutine101 does
#
sub subroutine101 {
    ## my($arg) = @_;
    &debug_print(&TL_VERBOSE, "subroutine101(@_)\n");

    return;
}
