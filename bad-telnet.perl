# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# telnet.perl: simple telnet client
#
# NOTE: works around problem invoking telnet with input from stdin
#

require 5.002;

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = $0; $dir =~ s/[^\\\/]*$//; unshift(@INC, $dir);
    require 'common.perl';
    use vars qw/$verbose/;
    use Socket;
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
## TODO: use strict;
use vars qw/$port $server/;

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

# Initialize the server's internet address to use
#
if ($port =~ /\D/) { 
    $port = getservbyname($port, 'tcp')
}
&exit("No port") unless $port;
my($iaddr);
$iaddr = inet_aton($server)
    or &exit("no host: $server");
my($paddr);
$paddr = sockaddr_in($port, $iaddr);

# Connect to the DSC server (currently running under Windows NT)
#
my($proto);
$proto = getprotobyname('tcp');
printf "Connecting to server $server at port $port\n" if ($verbose);
socket($server, PF_INET, SOCK_STREAM, $proto) 
    || die "ERROR in socket: $!";
connect($server, $paddr) 
    || die "ERROR in connect: $!";
printf "Setting up socket\n" if ($verbose);
# Make non-blocking
# note: ioctrl parameters based on http://www.perlmonks.org/?node_id=529812
my($NONBLOCKING) = 1;
## my($error) = ioctl($server, 0x8004667e, $NONBLOCKING);
&error($error) if defined($error);

# Make non-buffering
select($server); $| = 1; select(STDOUT);

printf "Processing input\n" if ($verbose);
while (<>) {
    &dump_line();
    chomp;

    # Send line
    print $server "$_\n";

    # Display responses until socket would block
    if ($_ eq ".") {
	while (<$server>) {
	    chomp;
	    print "$_\n";
	    last if ($_ eq ".");
	}
    }
}

# The end
&exit();
