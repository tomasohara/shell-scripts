# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# memory-hog.perl: tries to consume as much memory as possible
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
# NOTE: By convention - is used when no arguments are required
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

my(%big_hash);
my($big_num) = 2 ** 32;

print("Trying to allocate up to $big_num numbers\n");
for (my $i = 0; $i < $big_num; $i++) {
    if (($i % 1000000) == 0) {
	print "$i\n";
    }
    $big_hash{"N$i"} = 1;
}

&exit();
