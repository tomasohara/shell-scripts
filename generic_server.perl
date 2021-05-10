# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
#!/usr/local/bin/perl -Tsw
# perl options: 
# -s ("special") variable initialization
# -w issue plenty of warnings on Perl usage
# -T forces ``taint'' checks to be turned on so you can test them. 
#    Ordinarily these checks are done only when running setuid or setgid.
#
# TODO: find out why -T affects the search for lib's (eg, common.perl)
#
# generic_server.perl: server for transferring files and running commands
#
# Based on Bayesian network server developed for NMSU's GraphLing project, 
# itself based on socket server script from Perl man pages (sockets section).
#

require 5.002;

# Load in the common module, making sure the script dir is in Perl's lib path
BEGIN { 
    my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir);
    require 'common.perl';

    # Load in the other modules
    require 'generic_protocol.perl';
    #
    ## use strict;
    ## BEGIN { $ENV{PATH} = '/usr/ucb:/bin' }
    use Socket;
    use Carp;
}

# Use strict type checking but allow symbolic references for handles
use strict;
no strict "refs";
use vars qw /$port $be_polite $fork/;

# Parse command-line options
#
if (!defined($ARGV[0])) {
    my($options) = "options = [-port=N] [-fork]";
    my($example) = "ex: $script_name -port=1666";

    die "\nusage: $script_name [options] -\n\n$options\n\n$example\n\n";
}

&init_var(*port, 2345);			# TCP service port
&init_var(*be_polite, &FALSE);		# send connection acknowledgement
## &init_var(*server_dir, ".");
&init_var(*fork, &FALSE);		# use fork for processing requests

# Set up the socket for receiving requests
#
my($proto, $ok);
$proto = getprotobyname('tcp');
$ok = socket(Server, PF_INET, SOCK_STREAM, $proto)        || die "socket: $!";
&debug_out(6, "socket(S,%d,%d,%d) => $ok\n", PF_INET, SOCK_STREAM, $proto);
setsockopt(Server, SOL_SOCKET, SO_REUSEADDR,
	   pack("l", 1))   || die "setsockopt: $!";
bind(Server, sockaddr_in($port, INADDR_ANY))        || die "bind: $!";
listen(Server,SOMAXCONN)                            || die "listen: $!";

our($is_server);
our($do_shutdown);
$is_server = &TRUE;		# TODO: use accessor function
$do_shutdown = &FALSE;
our($authenticated) = &FALSE;

# Process connection requests until time to quit
#
## chdir $server_dir;
&logmsg ("server started on port $port");
my $paddr;
my $client;
my $child_pid;


while (($paddr = accept($client,Server))) {
    my($port,$iaddr) = sockaddr_in($paddr);
    &debug_out(5, "port=%s; iaddr=%s\n", $port, unpack("x4", $iaddr));
    my $name = gethostbyaddr($iaddr,AF_INET) || "???";
    &logmsg("connection from $name [" . inet_ntoa($iaddr) . "] at port $port");

    # If multiprocessing desired, spawn off child process to carry out
    # the request, having it exit afterwards.
    if ($fork) {
	$child_pid = fork();
	if (!defined($child_pid)) {
	    &error("Problem issuing fork ($!)\n");
	    $child_pid = -1;
	}

	# If this is the child process, then process the request
	if ($child_pid == 0) {
	    &process_client_request($client);
	    &exit();
	}
    }

    # Otherwise, just carry out the requests directly
    else {
	&process_client_request($client);
    }

    close $client;
    undef $client;
    last if ($do_shutdown);
}


# Clean up shop
#
&exit;


#------------------------------------------------------------------------------

# process_client_request(socket)
#
# Process all of the requests that are received via the socket
#
sub process_client_request {
    select($client); $| = 1; select(STDOUT);
    &send_command($client, "INFO", "Connected to Generic Server: " . localtime)
	if ($be_polite);

    $authenticated = &FALSE;
    while (<$client>) {
	chomp;
	&process_request($client, "$_");
	last if ($do_shutdown);
    }
}

# logmsg(message): write message to the log file with timestamp included
#
sub logmsg { 
    &debug_out(2, "$0 $$: @_ at %s\n", scalar localtime, "\n");
}

# global(variable_name)
#
# Dummy subroutine used for declaring variables as globals.
#
sub global {
}
