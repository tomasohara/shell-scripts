# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# test-telnet.perl: test of Net::Telnet
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = $0; $dir =~ s/[^\\\/]*$//; unshift(@INC, $dir);
    require 'common.perl';
    ## TODO: use vars qw/$verbose/;
    use Net::Telnet;
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
use vars qw/$port $server $sentinel/;

# Show a usage statement if no arguments given.
# NOTE: By convention '-' is used when no arguments are required.
if (!defined($ARGV[0])) {
    my($options) = "main options = []";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "Example(s):\n\n$script_name example\n\n";  # TODO: example
    ## $example .= "$0 example2\n\n";		   	     # TODO: 2nd example
    my($note) = "";
    ## $note .= "Notes:\n\nSome usage note.\n\n";	     # TODO: usage note

    print STDERR "\nUsage: $script_name [options]\n\n$options\n\n$example\n$note";
    &exit();
}

# Check the command-line options
# note: Each variable initialized corresponds to a -var=value commandline option
&init_var(*port, 22);
&init_var(*server, "localhost");
&init_var(*sentinel, ".");		# string signalling end of transmission


use Net::Telnet ();
my $t = new Net::Telnet (Timeout => 10);
$t->open(Host => $server,
	 Port => $port);
while (<>) {
    &dump_line();
    chomp;

    $t->print("$_\n");
    if ($_ eq $sentinel) {
	my($response);
	do {
	   $response = $t->getline;
	   chomp $response;
	   print "$response\n";
	} while ($response ne $sentinel);
    }
}

# The end
&exit();
