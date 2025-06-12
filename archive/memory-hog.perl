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
use vars qw/$buffer_len/;

# Show a usage statement if no arguments given
# NOTE: By convention - is used when no arguments are required
if (!defined($ARGV[0])) {
    my($options) = "main options = [-buffer_len=N]";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "Examples:\n\n$script_name -buffer_len=4096 -\n\n";
    my($note) = "";
    $note .= "Notes:\n\n- Warning: This could make the system crash or be unstable!\n";

    print STDERR "\nUsage: $script_name [options]\n\n$options\n\n$example\n$note";
    &exit();
}

# Check the command-line options
# note: Each variable initialized corresponds to a -var=value commandline option
&init_var(*buffer_len, 1);

my(%big_hash);
my($big_num) = 2 ** 32;

print("Trying to allocate up to $big_num numeric strings\n");
for (my $i = 0; $i < $big_num; $i++) {
    if (($i % 1000000) == 0) {
	print "$i\n";
	if (&DETAILED_DEBUGGING()) {
	    &debug_print(1, &run_command("free --wide --human") . "\n");
	}
    }
    my($buffer) = "_" x ($buffer_len);
    $big_hash{"N$i"} = $buffer;
}

&exit();
