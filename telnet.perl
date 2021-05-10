# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# telnet.perl: simple telnet client that assumes single line responses
# or a series of lines ended by a sentinel (e.g., ".")
#
# NOTES:
# - works around problem invoking telnet with input from stdin
# - based on code from http://www.perlmonks.org/?node_id=529812
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = $0; $dir =~ s/[^\\\/]*$//; unshift(@INC, $dir);
    require 'common.perl';
    use vars qw/$verbose/;
    use IO::Socket::INET;
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
## TODO: use strict;
use vars qw/$port $server $sentinel/;

# Show a usage statement if no arguments given.
# NOTE: By convention '-' is used when no arguments are required.
if (!defined($ARGV[0])) {
    my($options) = "main options = [-port-N] [-server=host]";
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
## &init_var(*fu, &FALSE);		# TODO: add command-line options
&init_var(*port, 22);
&init_var(*server, "localhost");
&init_var(*sentinel, ".");		# string signalling end of transmission


# Determine the server's internet address to use
#
if ($port =~ /\D/) { 
    $port = getservbyname($port, 'tcp')
}
&exit("No port") unless $port;
## my($iaddr);
## $iaddr = inet_aton($server)
##    or &exit("no host: $server");
## print "iaddr=$iaddr\n" if ($verbose);

# Connect to serber
my $socket = IO::Socket::INET->new(PeerAddr => $server,
                                   PeerPort => $port,
                                   Proto    => 'tcp',
                                   ## Blocking => 0
                                   Blocking => 1
    );
if (! defined($socket)) {
    &exit("Unable to create socket: $!\n");
}

printf "Processing input\n" if ($verbose);
#
while (<>) {
    &dump_line();

    # Send line
    print $socket, $_;

    # Process reply
    if ($_ eq $sentinel) {
	&print_reply();
    }
}

# The end
&exit();

#------------------------------------------------------------------------

# print_reply(): show reply from socket server
#
sub print_reply {
    &debug_print(&TL_DETAILED, "print_reply");
    while (<$socket>) {
	chomp;
	&dump_line("server: $_\n");
	print $_;
	last if ($_ eq $sentinel);
    }
}
