# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
# unix.perl: Module for Unix-specific code

# run_process(command_line, [time_limit_in_secs])
#
# Invoke a separate process and wait for it to finish or for the specified
# time-out to elapse.
#
sub run_process {
    local($command_line, $time_limit) = @_;

    # TODO: use fork and waitpid
    &issue_command($command_line);
    return;
}

#------------------------------------------------------------------------------

# Tell Perl we loaded ok
1;
