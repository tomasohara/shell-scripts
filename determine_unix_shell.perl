# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# determine_unix_shell.perl: determines which interactive shell the current
# process is running under. This uses output from the PS command, so it is 
# Unix specific (and perhaps Linux specific as well).
#
# This is intended for use in shells in which example usage statements
# differ depending on the governing shell such as for standard error
# redirection (e.g., 'command >& file' vs. 'command > file 2&1')
#
#........................................................................
# Sample output from PS command:
#
#   F   UID   PID  PPID PRI  NI   VSZ  RSS WCHAN  STAT TTY        TIME COMMAND
# 100  2222 20967 20966   9   0  1640 1104 read_c S    pts/0      0:00 bash
# 000  2222 21037 20967   9   0  9496 7540 do_sel S    pts/0      0:00 emacs
# 100  2222 21104 21101   8   0  1732 1160 read_c S    pts/1      0:00 bash
# 000  2222 21167 21104  10   0  9432 7732 do_sel S    pts/1      0:10 emacs /home
# /graphling/UTILITIES
# 100  2222 21248 21245  18   0  1632 1072 wait4  S    pts/2      0:00 bash
# 000  2222 21666 21248  18   0  2780 1128 -      R    pts/2      0:00 ps lxgww
# 040  2222 21667 21248  18   0  1632 1072 rpc_ex D    pts/2      0:00 bash
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

if (!defined($ARGV[0])) {
    $options = "options = n/a";
    $example = "ex: $script_name \$\$\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
}

my($pid) = $ARGV[0];
&init_var(*OSTYPE, "???");	# operating system type (eg. Linux)

# Complain if we aren't running under Linux
# TODO: support Solaris someday
if ($OSTYPE != "Linux") {
    &debug_out(&TL_DETAILED, "$0 only supports Linux\n");
    print("???\n");
}

# Get process status output
# ps options: a for all terminal processes; l for long format; x for nonterminal processes; w for wide output
my($ps_output) = &run_command("ps alxw");

# Determine parent ID of the process
# example: 000  2222 21356 21104   9   0  2336 1120 pipe_w S    pts/1      0:00 /bin/csh -
my($parent_pid) = ($ps_output =~ /\n\d+\s+\d+\s+$pid\s+(\d+)/);
if (! defined($parent_pid)) {
    &debug_out(&TL_DETAILED, "WARNING: Unable to find parent process for pid $pid\n");
    &exit();
}

# Determine the type of shell for the parent
# example: 100  2222 21104 21101   9   0  1728 1152 wait4  S    pts/1      0:00 bash
# note: tcsh will be considered as csh
my($parent_command) = ($ps_output =~ /\n\d+\s+\d+\s+${parent_pid} .*\s+\d:\d\d (.*)/);
if (! defined($parent_command)) {
    &debug_out(&TL_DETAILED, "WARNING: Unable to find command for parent process ${parent_pid}\n");
    &exit();
}
my($shell) = "unknown";
if ($parent_command =~ /bash/) {
    $shell = "bash";
}
elsif ($parent_command =~ /csh/) {
    $shell = "csh";
}

# Display the results
&debug_out(&TL_DETAILED, "parent_pid=$parent_pid\nparent_command=$parent_command\n");
print "$shell\n";

&exit();
