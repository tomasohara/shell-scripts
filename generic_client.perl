# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# generic_client.perl: client for accessing the MSBN inteface (DSC) remotely
#
# Based on Bayesian network client developed for NMSU's GraphLing project, 
# itself based on socket client script from Perl man pages (sockets section).
#

require 5.002;

# Load in the common module, making sure the script dir is in Perl's lib path
BEGIN { 
    my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); 
    require 'common.perl';

    # Load in the other modules
    require 'generic_protocol.perl';

    use Socket;
}

# Use strict type checking but allow symbolic references for handles
use strict;
no strict "refs";
use vars qw /$port $server $be_polite/;

# Parse command-line options
#
if (!defined($ARGV[0])) {
    my($options) = "options = [-port=N] [-server=hostname]";
    my($example) = "ex: $script_name ~/.netscape/bookmarks.html\n";
    $example .= "\n$script_name SHUTDOWN\n";
    $example .= "\n$script_name - < client_script.text\n";

    print STDERR "\nusage: $script_name [options] [- | commands ...]\n\n$options\n\n$example\n\n";
    &exit;
}

&init_var(*port, 2345);
&init_var(*server, "chloride.nmsu.edu");
&init_var(*be_polite, &FALSE);

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
my($server);
socket($server, PF_INET, SOCK_STREAM, $proto) 
    || die "ERROR in socket: $!";
connect($server, $paddr) 
    || die "ERROR in connect: $!";
select($server); $| = 1; select(STDOUT);

# Get the connection response
if ($be_polite) {
    my($request) = <$server>;
    &assert('($request =~ /^INFO/)');
    &process_request($server, $request);
}

my(@commands) = @ARGV;
if ($ARGV[0] eq "-") {
    @commands = <STDIN>;
}

# Interpret each command. (Commands with arguments given on the command-line
# should be encloded in quotes: generic_client.perl "SEND_FILE it.list").
#
foreach my $entire_command (@commands) {
    my($command, @arguments) = split(/\s+/, $entire_command);
    my($command_data) = "@arguments";
    $command = "" if (!defined($command));
    $command_data = "" if (!defined($command_data));
    next if ($command =~ /^\s*$/);

    &debug_print(&TL_DETAILED, "processing $command $command_data\n");
    my($ending_request) = "DONE";

    # Check for the special shutdown command
    if ($command =~ /AUTHENTICATE/i) {
	&send_command($server, "AUTHENTICATE", $command_data);
	&process_requests($server, "INFO");
    }

    elsif ($command =~ /SHUTDOWN/i) {
	&send_command($server, "SHUTDOWN", "pronto!");
    }

    # Check for the special shutdown command
    elsif ($command =~ /GET_LOG_FILE/i) {
	&send_command($server, "GET_LOG_FILE", "n/a");
	&process_requests($server, "END_FILE");
    }

    # Check for command for executing shell commands
    elsif ($command =~ /RUN_COMMAND/) {
	&send_command($server, "RUN_COMMAND", $command_data);
	&process_requests($server, "END_FILE");
    }

    # Check for command for sending files to server
    elsif ($command =~ /SEND_FILE/) {
	my($file_name) = $command_data;
	my($file_data) = &read_file($file_name);
	&send_file($server, $file_name, $file_data);
    }

    # Check for command for receiving files from server
    elsif ($command =~ /RECEIVE_FILE/) {
	my($file_name) = $command_data;
	&send_command($server, "REQUEST_FILE", "$file_name");
	&process_requests($server, "END_FILE");
    }

    # Otherwise complain about an unknown command
    else {
	my($file_name) = $command;
	my($file_data) = &read_file($file_name);
	&send_file($server, $file_name, $file_data);
    }
}


# Clean up shop
#
close ($server)            
    or &exit("ERROR in close: $!");
&exit;


#------------------------------------------------------------------------------

# process_requests(socket, ending_request)
#
# Process a series of requests from the server until the specified request
# is encountered.
#
sub process_requests {
    my($socket, $ending_request) = @_;
    my($request);
    
    # Wait until the results are ready
    do {
	$request = <$socket>;
	$request = "<Unexpected EOF>\n" if (! defined($request));
	chomp $request;
	my($ok) = &process_request($socket, $request);
	if (($request =~ /^ERROR/) || (! $ok)) {
	    die "ERROR $request\n";
	}
    } while ($request !~ /^($ending_request)/);

    return;
}
