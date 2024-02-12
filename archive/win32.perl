# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
# win32.perl: module for interfacing w/ the Win32 module
#

# run_process(command_line, [time_limit_in_secs])
#
# Invoke a separate process and wait for it to finish or for the specified
# time-out to elapse.
#
# Modified from sample in Win32mod.html
#
sub run_process {
    local($command_line, $time_limit) = @_;
    $time_limit = ($MAXINT/1000) if (!defined($time_limit));
    $time_limit_ms = 1000 * $time_limit;	# convert to milliseconds

    #'use' the process module.
    use Win32::Process;
    # theWin32:: module. Includes the Win32 error checking etc.
    # see Win32:: section for included functions.
    use Win32;
 
    local($executable) = $command_line;
    if ($command_line =~ /^(\S+)\s+/) {
	$executable = $1;
    }

    # Create the process object.
    &debug_out(4, "issuing Process::Create for '%s'\n", $command_line);
    $ok = Win32::Process::Create($ProcessObj,	# object to hold process.
                           $executable, $command_line,
			   0,			# no inheritance of handles
                           DETACHED_PROCESS,	# separate process
                           $dsc_dir);		# use server's dir as current dir.
    if ($ok == &FALSE) {
	&debug_out(2, "*** error running $command_line: %s", 
		   &get_last_win32_error());
	return;
    }

    # Set the process priority
    if ($normal_priority) {
	$ProcessObj->SetPriorityClass(NORMAL_PRIORITY_CLASS);
	}
    else {
	$ProcessObj->SetPriorityClass(IDLE_PRIORITY_CLASS);
	}

    # Wait for the process to end.
    &debug_out(4, "waiting for process ...\n");
    if ($loose_wait) {
	sleep($time_limit);
	$ok = $ProcessObj->Kill(666)
	&debug_out(4, "killed the process (ok=$ok): %s", &get_last_win32_error());
    }
    else {
	$ok = $ProcessObj->Wait($time_limit_ms);
	if ($ok == &FALSE) {
	    &debug_out(4, "time-out occurred ($!): %s", &get_last_win32_error());

	    # Time-out occurred, so just kill it
	    $ok = $ProcessObj->Kill(666);
	    &debug_out(4, "killed the process (ok=$ok): %s", &get_last_win32_error());
	}
    }
}


# Get the text for the last Win32 error that occurred
#
sub get_last_win32_error { 
    return (Win32::FormatMessage(Win32::GetLastError()));
}

#------------------------------------------------------------------------------

# Tell Perl we loaded ok
1;
