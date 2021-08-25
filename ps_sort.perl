# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# ps_sort.perl: sort process status (ps) command output by given column
#
# Notes:
# - mem is %MEM for Linux (resident set size as % of physical memory).
#
#-------------------------------------------------------------------------------
# Examples:
# SunOS:
#   USER       PID %CPU %MEM   SZ  RSS TT STAT START  TIME COMMAND
#   root         0  0.0  0.0    0    0 ?  D    Nov 12  0:47 swapper
#   root         1  0.0  0.0   52    0 ?  IW   Nov 12  0:00 /sbin/init -
#   root         2  0.0  0.0    0    0 ?  D    Nov 12  0:05 pagedaemon
#   tomohara 16031  0.0  0.0 1172    0 p0 IW   08:47   0:05 mailtool
#
# Solaris:
#  F S      UID   PID  PPID  C PRI NI     ADDR     SZ    WCHAN    STIME TTY      TIME CMD
# 19 T     root     0     0  0   0 SY 10414a08      0            Nov 22 ?        0:00 sched
# 8 S tomohara 15655 11319  0  41 20 507bc680    113 5068e246 10:09:13 pts/1    0:00 less
# 8 S     root 15037   128  0  41 20 506ab988    321 508510de 09:59:37 ?        0:00 in.rshd
# 8 S tomohara 15032     1  0  41 20 506aa668    175 50851656 09:59:36 pts/1    0:00 rsh -n boron ni
#
# Linux:
# USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
# tomohara 22421  6.9  0.7 1509060 90032 pts/1   Sl   Oct22  47:13 /usr/bin/python /media/sf_C_DRIVE/cartera-de-tomas/visual-diff/visual_diff_server.py --server
# tomohara 18158  3.5  0.8 1431704 99252 pts/13  Sl   Oct22  45:44 /usr/bin/python /media/sf_C_DRIVE/cartera-de-tomas/python/text_categorizer.py random-simplewiki-20170720-pages-articles.texts.data.full.sdg.model
# tomohara 20257  2.6  5.2 2682472 648664 ?      Sl   Oct22  24:57 /usr/lib/firefox/firefox
# tomohara  3755  1.7  1.0 1718468 126736 ?      Sl   Oct20  72:31 /usr/lib/chromium-browser/chromium-browser --type=renderer --enable-pinch --field-trial-handle=18206849173794148909,...
# 

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = $0; $dir =~ s/[^\\\/]*$//; unshift(@INC, $dir);
    require 'common.perl';
    ## TODO: use vars qw/$verbose/;
    require 'extra.perl';
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
no strict "refs";		# to allow for old-style references to arrays (TODO: use #xyz_ref = \@array)
use vars qw/$by $xyz $ps_options $cut_options $num_times $LINES $COLUMNS $max_count $delay $line_len $testing $justuser $USER $username/;

# Check the command-line options
&init_var(*by, "cpu");
&init_var(*OSTYPE, "???");
my($is_solaris) = ($OSTYPE =~ "solaris");
my($is_linux) = ($OSTYPE =~ "linux");
&init_var(*ps_options, ($is_solaris ? "-efl" : $is_linux ? "auxgww" : "auxg"));
&init_var(*cut_options, ($is_solaris ? "-c1-36,46-52,62-70,79-132" : "-c1-132"));
&init_var(*num_times, 60);
&init_var(*LINES, 30);
&init_var(*COLUMNS, 80);
&init_var(*max_count, $LINES - 5);
&init_var(*delay, (($num_times > 1) ? 1: 0));
&init_var(*line_len, $COLUMNS - 2);
&init_var(*testing, &FALSE);	# script testing mode
&init_var(*justuser, &FALSE);	# just show current user
&init_var(*USER, "");
&init_var(*username,		# just show this user
	  ($justuser ? $USER : ""));

use vars qw/@uid @xyz @line @line_index @user @pid @cpu @mem @sz @rss @tt @stat @f @s @ppid @pri @ni @stime @time @cmd/;
# TODO: local => our
local(@line, @line_index);
local(@user, @pid, @cpu, @mem, @sz, @rss, @tt, @stat);
local(@f, @s, @ppid, @pri, @ni, @stime, @time, @cmd);
local(*xyz) = *line;
local(*uid) = *user;
## TODO: my($xyz_ref = \@line; my($uid_ref) = \@user;
&debug_out(&TL_VERBOSE, "\$#uid = %d\n", $#uid);

# Show a usage statement if no arguments given
# NOTE: By convention - is used when no arguments are required
if (!defined($ARGV[0])) {
    my($options) = "main options = [-by=FIELD] [-username=user] [-num_times=N] [-max_count=N] [-delay=B] [-justuser]";
    if ($is_solaris) {
	$options .= "\nfield = [f|s|uid|pid|ppid|c|pri|ni|addr|sz|wchan|stime|tty|time|cmd]";
    }
    elsif ($is_linux) {
	$options .= "\nfield = [user|pid|cpu|mem|vsz|rss|tty|stat|start|time|command]";
    }
    else {
	$options .= "\nfield = [pid|cpu|mem|sz|rss|tt|stat|start|time|command]";
    }
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "examples:\n\n$0 -\n\n";
    $example .= "$script_name -by=mem -\n\n";
    $example .= "$script_name -justuser -\n\n";
    $example .= "$script_name -username=cpuhog -\n\n";
    $example .= "$script_name -num_times=1 -by=time -\n\n";

    my($note) = "";
    $note .= "Notes:\n- Use -num_times for iterations.\n";
    $note .= "- Use num_times for number of iterations.\n";
    $note .= "- Use -max_count for number of process listing entries.\n";

    # Note: Removes extraneous newline in last example, so that the examples
    # can be reordered without having to worry about newline convention.
    if ($example =~ /\n\n/) {
	chomp $example;
    }
    die "\nusage: $script_name [options]\n\n$options\n\n$example\n$note\n";
}

PS_LOOP:
for (my $t = 1; $t <= $num_times; $t++) {

    my($header) = "";

    my $i = 0;
    &debug_print(&TL_VERBOSE, "Invoking subprocess: ps $ps_options | cut $cut_options | ...\n");
    open(PS, "ps $ps_options | cut $cut_options |");
    while (<PS>) {
	&dump_line();
	chomp;
	
	# Save the process-info command header
	if (/(^USER)|(^ F)/) {
	    $header = $_;
	    next;
	}

	# Optionally, ignore commands not for desired user
	if (($username ne "") && ($_ !~ $username)) {
	    next;
	}

	# Fill in the process-info arrays from the process-info data
	$line_index[$i] = $i;
	$line[$i] = $_;
	if ($is_solaris) {
	    ($f[$i], $s[$i], $user[$i], $pid[$i], $ppid[$i], $cpu[$i], 
	     $pri[$i], $ni[$i], $sz[$i], $stime[$i], $time[$i], $cmd[$i]) 
		= split;
	    $mem[$i] = $sz[$i];
	}
	elsif ($is_linux) {
	    ($user[$i], $pid[$i], $cpu[$i], $mem[$i], $sz[$i], $rss[$i], 
	     $tt[$i], $stat[$i], $stime[$i], $time[$i], $cmd[$i]) = split;
	}
	else {
	    ($user[$i], $pid[$i], $cpu[$i], $mem[$i], $sz[$i], $rss[$i], 
	     $tt[$i]) = split;
	}
	$i++;
    }
    close(PS);

    
    # Determine the array to sort by
    #
    # *by_xyz = ($by eq "cpu" ? *by_cpu :
    #	       $by eq "mem" ? *by_mem :
    #	       $by eq "sz" ? *by_sz :
    #	       $by eq "rss" ? *by_rss :
    #	       *by_default);
    #
    &debug_print(&TL_VERBOSE, "eval \"*xyz = *$by\"\n");
    eval "*xyz = *$by";
    *xyz = *cpu if (!defined($xyz[0]));

    # Print the information sorted in proper order
    if ($num_times > 1) {
	&cmd("clear");
	print "update $t of $num_times\n";
    }
    printf "%s\n", substr($header, 0, $line_len);
    my $count = 0;
    foreach my $index (sort by_xyz @line_index) {
	printf "%s\n",  substr($line[$line_index[$index]], 0, $line_len);
	last if ($count++ == $max_count);
    }

    # See if the user wants to quit
    for (my $i = 0; $i < $delay; $i++) {
	if (&get_console_char() eq "q") {
	    last PS_LOOP;
	}

	sleep(1);
    }
}

#------------------------------------------------------------------------------

# Sort routines for the processor status arrays
# Notes:
# - The global parameters ($a, $b) give the indices of the index array.
# - The global @xyz is alias to array of values for metric given by global $by.
#
sub by_xyz { 
    &debug_print(&TL_MOST_DETAILED, "by_xyz: a=$a b=$b\n");
    my($value_a) = $xyz[$line_index[$a]];
    my($value_b) = $xyz[$line_index[$b]];
    &debug_print(&TL_MOST_VERBOSE, "$value_a\n$value_b\n");

    # Treat time value into decimal
    # NOTE: conditional on it being a known time field
    if (($by =~ /time/) && ($value_a =~ /:/) && ($value_b =~ /:/)) {
	$value_a =~ tr/:/./;
	$value_b =~ tr/:/./;
	&assert(($value_a !~ /:/) && ($value_b !~ /:/));
    }

    # Do reverse comparison (for numbers if numeric)
    my($comparison) = 0;
    if (&is_numeric($value_b) && &is_numeric($value_a)) {
	$comparison = ($value_b <=> $value_a);
    }
    else {
	$comparison = ($value_b cmp $value_a);
    }
    &debug_print(&TL_MOST_DETAILED, "by_xyz() => comparison\n");

    return $comparison;
}

# sub by_cpu { $cpu[$line_index[$b]] <=> $cpu[$line_index[$a]]; }
#
# sub by_mem { $mem[$line_index[$b]] <=> $mem[$line_index[$a]]; }
#
# sub by_sz { $sz[$line_index[$b]] <=> $sz[$line_index[$a]]; }
#
# sub by_rss { $rss[$line_index[$b]] <=> $rss[$line_index[$a]]; }

sub by_default { $line_index[$b] <=> $line_index[$a]; }



# Get's a character from the console ("" if not ready for input)
# NOTE: this is a test version using ReadTerm
#
sub new_get_console_char {
    return(&get_next_char());
}

# Get's a character from the console ("" if not ready for input).
#
sub get_console_char {
    my($key) = "";

    # If testing, use the new input routine
    if ($testing) {
	return (&new_get_console_char());
    }

    # Read the character after temporarily disabling line input
    # NOTE: This is Unix specific (but the script itself currently is)
    ## &cmd("stty cbreak -echo </dev/tty >/dev/tty 2>&1");
    &cmd("stty -icanon -echo </dev/tty >/dev/tty 2>&1");
    &set_stdin_blocking(&FALSE);
    $key = getc(STDIN) || "";
    &debug_print(&TL_VERY_DETAILED, "key=$key\n");
    &set_stdin_blocking(&TRUE);
    ## &cmd("stty -cbreak echo </dev/tty >/dev/tty 2>&1");
    &cmd("stty icanon echo </dev/tty >/dev/tty 2>&1");

    return ($key);
}


sub set_stdin_blocking {
    my($blocking) = @_;
    my($flags, $result);

    # Stupidity: non-uniform support for fcntl
    if (&under_WIN32) {
        return 0;
    }
    my($perl5) = ($] =~ /^5/);
    eval "use Fcntl;" if ($perl5);
    eval "require 'sys/fcntl.ph';" if (!$perl5);

    # fcntl() performs a variety of functions on open descriptors:
    #
    # F_GETFL        Get descriptor status flags (see fcntl(5) for
    #                definitions).
    #
    $flags = fcntl(STDIN, &F_GETFL, 0);
    ## TODO: /but true/???
    $flags =~ s/but true//;
    &debug_out(&TL_VERBOSE, "fcntl(STDIN, &F_GETFL, 0) => %08x\n", $flags);
    if ($blocking == &FALSE) {
	$flags |= &O_NDELAY;	# set on no-delay bit in flags
    }
    else {
	$flags &= ~&O_NDELAY;	# set off no-delay bit in flags
    }
    &debug_out(7, "flags=%08x\n", $flags);
    $result = fcntl(STDIN, &F_SETFL, $flags);
    ## TODO: drop /but true/ hack
    $result =~ s/but true//;
    &debug_out(&TL_VERBOSE, "fcntl(STDIN, &F_SETFL, %08x) => %08x\n",
	       $flags, $result);

    return;
}
