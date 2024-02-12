# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
# Module for implementing a client/server protocol. This is based on the 
# DSC server used in the GraphLing project at NMSU.
#
# old PROTOCOL: 
#	note: <- indicates data from server; -> indicates data fom client
#	The general format of a request is <command>:<data>. All spacing
#	past the semicolon is considered part of the data.
#
#	1. Establish socket connection (streams-based) to server.
#	   The server will send informational text
#	<-	INFO:Connected to DSC Server ...
#
#	2. Send MSBN network in BNIF format, alogn with supporting files
#	   such as the list of evidence nodes.
#	->	FILE:<filename>.dsc
#	->	LINE_COUNT:<N>
#	->	LINE:line1_text
#	->	LINE:line2_text
#	->	...
#	->      LINE:lineN_text
#	->	END_FILE:
#	->	FILE:<filename>.evidence
#	->	LINE_COUNT:<N>
#	->	LINE:line1_text
#	->	LINE:line2_text
#	->	...
#	->      LINE:lineN_text
#	->	END_FILE:
#
#	  Acknowledgements are sent back for each line (OK or NOT_OK).
#
#	3. Send request to interpret the network and wait for results
#	->	RUN_NETWORK <filename>.dsc
#
#	4. Receive results from the server
#	<-	FILE:<filename>.log
#	<-	LINE_COUNT <N>
#	<-	LINE:line1_text
#	<-	LINE:line2_text
#		...
#	<-	LINE:lineN_text
#	<-	FILE:<filename>.output
#	<-	END_FILE:
#	<-	LINE_COUNT:<N>
#	<-	LINE:line1_text
#	<-	LINE:line2_text
#		...
#	<-	LINE:lineN_text
#	<-	END_FILE:
#	<-	DONE:
#
#........................................................................
# Server commands:
#
# AUTHENTICATE <user> <password>
# FILE <filename>
# LINE <line-of-text>
# END_FILE
# RUN_COMMAND <command-line>
# REQUEST_FILE <file-name>
# SHUTDOWN
# GET_LOG_FILE
# ERROR <error-information>
# DONE <status-information>
#
#........................................................................
# Global variables:
#    $file_name		name of current file being received
#    $file_lines	number of lines in the file
#    $file_text		contents of the file being received
#    $is_server		flag indicating role the host is playing
#

require 5.002;

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir);
    require 'common.perl';
    if ($under_WIN32) {
        require 'win32.perl';
    }
    else {
        require 'unix.perl';
    }
}

# Use strict type checking but allow symbolic references for handles
use strict;
no strict "refs";
use vars qw /$ignore_ack $server_dir $data_dir $normal_priority $loose_wait/;

our($file_name) = "";
our($file_text) = "";
our($file_lines) = 0;
our($is_server) = &FALSE;
our($do_shutdown) = &FALSE;
our($authenticated) = &FALSE;
our($send_ack) = &TRUE;

&init_var(*ignore_ack, &TRUE);
&init_var(*server_dir, $script_dir);
&init_var(*data_dir, ".");
&init_var(*normal_priority, &FALSE);
&init_var(*loose_wait, &FALSE);

# process_request(socket, request_text)
#
# Processes a request from the other host (DSC client or server)
#
# NOTE: Since there is much overlap in the commands for the DSC client
#       and server, both are handled in one routine.
#
# Returns TRUE if command processed ok, otherwise FALSE.
#

sub process_request {
    my($socket, $request) = @_;
    my($ok) = &TRUE;
    &debug_print(6, "process_request on socket $socket: $request\n");
    $send_ack = &TRUE;
    my($command) = $request;
    my($data) = "";

    ## ($command, $data) = split(/:/, $request);
    if ($command =~ /^([^:]+):/) {
	$command = $1;
	$data = $';		# ' (for Emacs)
    }
    $data = "" if (!defined($data));

    if ($command eq "AUTHENTICATE") {
	# Authenticate the user
        $send_ack = &FALSE;
        &send_acknowledgement($socket, $ok);
	$authenticated = &FALSE;
	my($user, $password) = split(/\s+/, $data);
	my($key) =  &read_file("${server_dir}${delim}key.text");
	chomp $key;
	## my($valid) = &issue_command("validate_password $user $password");
	my($valid) = ($password eq $key);
	if ($valid) {
	    $authenticated = &TRUE;
	    &send_command($socket, "INFO", "authentication ok");
	}
	else {
	    &send_command($socket, "ERROR", "authentication failed");
	}
    }
    elsif ($is_server && ($authenticated == &FALSE)) {
        $send_ack = &FALSE;
        &send_acknowledgement($socket, $ok);
	&send_command($socket, "ERROR", "authentication required");
    }
    elsif ($command eq "FILE") {
	$data =~ s/\s+$//;
	$file_name = "${data_dir}${delim}$data";
	$file_text = "";
	$file_lines = 0;
    }
    elsif ($command eq "LINE_COUNT") {
	$file_lines .= $data;
    }
    elsif ($command eq "LINE") {
	$file_text .= $data;
	$file_text .= "\n";
	$file_lines--;
    }
    elsif ($command eq "END_FILE") {
	&assert('$file_lines == 0');
	&write_file("$file_name", $file_text);
    }
    elsif ($command eq "RUN_COMMAND") {
	# Run the specified command
	&process_run_command($socket, $data);
	}
    elsif ($command eq "REQUEST_FILE") {
        &send_acknowledgement($socket, $ok);
        $send_ack = &FALSE;
	my($file_name) = $data;
	&send_file($socket, $file_name);
	}
    elsif ($command eq "SHUTDOWN") {
	$do_shutdown = &TRUE;
    }
    elsif ($command eq "GET_LOG_FILE") {
	# TODO: add msdndsc.log as well
        &send_acknowledgement($socket, $ok);
        $send_ack = &FALSE;
	&send_file($socket, "generic_server.log");
    }
    elsif ($command eq "INFO") {
        # Ignore informational items
	&debug_print(4, "$data\n");
    }
    elsif ($command eq "ERROR") {
        # Ignore informational items
	print STDERR "*** ERROR: $data\n";
    }
    elsif ($command eq "DONE") {
        # Ignore miscellaneous status items
    }
    else {
	&error(2, "*** unrecognized request '$request'\n");
	$ok = &FALSE;
    }

    # Send the acknowledgement
    if ($send_ack) {
	&send_acknowledgement($socket, $ok);
    }

    return ($ok);
}


# run_command(command_line)
#
# Run's the command and sends the result back to the user as result.log
#
sub process_run_command {
    my($socket, $command) = @_;
    my($ok) = &TRUE;
    &assert($is_server);

    # Acknowledge the request
    &send_acknowledgement($socket, $ok);
    $send_ack = &FALSE;

    # Run the command and get the output
    my($result_text) = &issue_command($command);

    # Send the results to the client
    &send_file($socket, "command_result.log", $result_text);
    &send_command($socket, "DONE", "");
}


# send_file(socket, $file_name, $file_data)
#
# Send the file to the recipient using the protocol established for the
# DSC server.
#
sub send_file {
    my($socket, $file_name, $data) = @_;
    &debug_print(4, "send_file($socket, $file_name, _)\n");

    # Read in the file
    if (!defined($data)) {
	$data = &read_file($file_name);
    }
    my(@lines) = split(/\n/, $data);
    my($num_lines) = ($#lines + 1);

    # Send the file header
    my($plain_file_name) = &remove_dir($file_name);
    &send_command($socket, "FILE", $plain_file_name);
    &send_command($socket, "LINE_COUNT", $num_lines);

    # Send it line-by-line
    my($i);
    for ($i = 0; $i <= $#lines; $i++) {
	&send_command($socket, "LINE", $lines[$i]);
	if ($normal_priority && (($i % 1000) == 0)) {
	   sleep(1);
	   }
    }

    # Send the file trailer
    &send_command($socket, "END_FILE", "");
}


sub request_file {
    my($socket, $file_name) = @_;
    &debug_print(4, "request_file($socket, $file_name)\n");

    # Send the file request command
    &send_command($socket, "FILE_REQUEST", $file_name);
}


# send_command(socket, command_name, command_data)
#
# Send a command to the recipient using the protocol established for
# the DSC server
#
sub send_command {
    my($socket, $command, $data) = @_;
    &debug_print(6, "send_command($socket, $command, $data)\n");

    # Send the command and data to the recipient
    printf $socket "%s:%s\n", $command, $data;

    # Wait for the acknowledgement (either OK or NOT_OK)
    &receive_acknowledgement($socket);

    return;
}


# send_acknowledgement(socket, ok)
#
# Send an acknowledgement on the socket.

sub send_acknowledgement {
    my($socket, $ok) = @_;
    my($ack) = ($ok ? "OK" : "NOT_OK");
    &debug_print(6, "send_acknowledgement(@_)\n");

    printf $socket "$ack\n" unless ($ignore_ack);
}


# receive_acknowledgement(socket)
#
# Wait to receive an acknowledgement on the socket.

sub receive_acknowledgement {
    my($socket) = @_;
    &debug_print(6, "receive_acknowledgement(@_)\n");
    if ($ignore_ack) {
	return;
    }
    my($ack) = <$socket>;

    $ack = "" if (!defined($ack));
    if ($ack !~ "OK") {
	&debug_print(2, "*** warning: unrecognized acknowledgement: $ack\n");
    }
    &debug_print(7,"ack=$ack");
}


#------------------------------------------------------------------------------

# Tell Perl the module loaded ok
1;
