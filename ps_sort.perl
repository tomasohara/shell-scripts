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
# TODO:
# - ** Set unbuffered I/O if batch mode.
# - * Make sure all linux fields handled: this script was started a long time ago!
# - Allow for arbitrary fields
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
use vars qw/$batch $full $once $lines $columns $alpha $time2num/;

# Check the command-line options
# note: OSTYPE needs to be in environment for this to work (see tomohara-aliases.bash)
&init_var(*by, "cpu");
&init_var(*OSTYPE, "???");
## TEST:
## $OSTYPE = "n/a" if ($OSTYPE = "???");
&debug_print(&TL_DETAILED, "OSTYPE=$OSTYPE\n");
## OLD:
## my($is_solaris) = ($OSTYPE =~ "solaris");
## my($is_linux) = ($OSTYPE =~ "linux");
## my($is_mac) = ($OSTYPE =~ "darwin");
my($is_solaris) = ($OSTYPE =~ "solaris") ? 1 : 0;
my($is_linux) = ($OSTYPE =~ "linux") ? 1 : 0;
my($is_mac) = ($OSTYPE =~ ".*darwin.*") ? 1 : 0;
## TODO:
&debug_print(&TL_DETAILED, "is_solaris=$is_solaris is_linux=$is_linux is_mac=$is_mac\n");
&init_var(*ps_options, ($is_solaris ? "-efl" : $is_linux ? "auxgww" : "auxg"));
## OLD: &init_var(*cut_options, ($is_solaris ? "-c1-36,46-52,62-70,79-132" : "-c1-132"));
## OLD: &init_var(*num_times, 60);
&init_var(*once, &FALSE);      # alias for -num_times=1
&init_var(*full, &FALSE);      # disable row/column truncation
&init_var(*num_times, ($once ? 1 : 60));
## HACK: use lowercase lines/columns so that not trumped by environment
## TODO: add option to init_var to disable environment value check
&init_var(*LINES, 42);
&init_var(*COLUMNS, 80);
$lines = ($full ? &MAXINT : $LINES) if ! defined($lines);
$columns = ($full ? &MAXINT : $COLUMNS) if ! defined($columns);
&debug_print(&TL_VERBOSE, "#rows/#colums: ($lines/$columns)\n");
## TODO: &init_var(*lines, ($full ? &MAXINT : $LINES));
## TODO: &init_var(*columns, ($full ? &MAXINT : $COLUMNS));
&init_var(*cut_options, ($is_solaris ? "-c1-36,46-52,62-70,79-132" : "-c1-$columns"));
&init_var(*max_count, $lines - 5);
&init_var(*delay, (($num_times > 1) ? 1: 0));
&init_var(*line_len, $columns - 2);
&init_var(*testing, &FALSE);	# script testing mode
&init_var(*justuser, &FALSE);	# just show current user
&init_var(*USER, "");
&init_var(*username,		# just show this user
	  ($justuser ? $USER : ""));
&init_var(*batch, &FALSE);      # batch mode (don't poll console for early quit)
&init_var(*alpha, &FALSE);      # sort alphabetically (i.e., lexicographic)
&init_var(*time2num, &FALSE);   # convert time to a number for sorting purposes

use vars qw/@uid @xyz @line @line_index @user @pid @cpu @mem @sz @rss @tt @stat @f @s @ppid @pri @ni @stime @time @cmd/;
use vars qw/@vsz @command @tty @start/;
# TODO: local => our
local(@line, @line_index);
local(@user, @pid, @cpu, @mem, @sz, @rss, @tt, @stat);
local(@f, @s, @ppid, @pri, @ni, @stime, @time, @cmd);
# note: additional fields for linux
local(@vsz, @command, @tty, @start);
local(*xyz) = *line;
local(*uid) = *user;
## TODO: my($xyz_ref = \@line; my($uid_ref) = \@user;
&debug_out(&TL_VERBOSE, "\$#uid = %d\n", $#uid);

## TEMP: &debug_print(&TL_VERBOSE, "is_solaris=$is_solaris is_linux=$is_linux is_mac=$is_mac\n");

# Show a usage statement if no arguments given
# NOTE: By convention - is used when no arguments are required
if (!defined($ARGV[0])) {
    my($options) = "main options = [-by=FIELD] [-username=user] [-num_times=N] [-max_count=N] [-delay=N] [-justuser]";
    # TODO: show defaults
    $options .= " [-batch] [-once] [-full] [-alpha] [-time2num]";
    if ($is_solaris) {
	$options .= "\nfield = [f|s|uid|pid|ppid|c|pri|ni|addr|sz|wchan|stime|tty|time|cmd]";
    }
    elsif ($is_linux || $is_mac) {
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
    $example .= "LINES=1000 $script_name -num_times=1 -by=time - | less\n\n";
    $example .= "$script_name -once -full -by=command -\n\n";

    my($note) = "";
    $note .= "Notes:\n";
    $note .= "- Use -num_times for number of iterations.\n";
    $note .= "- Use -max_count for number of process listing entries.\n";
    $note .= "- Use -once and -full for stdout: uses -num_times=1 and no row/col truncation).\n";
    $note .= "- Use -time2num for converting time field to seconds when sorting\n";
    $note .= "- env-var LINES determines number of entries.\n";
    $note .= "- env-var COLUMNS determines width.\n";

    # Note: Removes extraneous newline in last example, so that the examples
    # can be reordered without having to worry about newline convention.
    if ($example =~ /\n\n/) {
	chomp $example;
    }
    die "\nusage: $script_name [options]\n\n$options\n\n$example\n$note\n";
}

PS_LOOP:
## TODO (resolve stupid perl strict-mode warning regarding $t):
##    for (my $t = 1; $t <= $num_times; $t++) { ... }
##
## TEST1:
## my($t);
## for ($t = 1; $t <= $num_times; $t++) {
## TEST2: local($t);
use vars qw/$t/;
for ($t = 1; $t <= $num_times; $t++) {
	
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
	    # TODO: Make sure fields recognized.
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
	elsif ($is_linux || $is_mac) {
	    ## OLD:
	    ## ($user[$i], $pid[$i], $cpu[$i], $mem[$i], $vsz[$i], $rss[$i], 
	    ##  $tt[$i], $stat[$i], $stime[$i], $time[$i], $command[$i]) = split;
	    ($user[$i], $pid[$i], $cpu[$i], $mem[$i], $vsz[$i], $rss[$i], 
	     $tty[$i], $stat[$i], $start[$i], $time[$i], $command[$i]) = split;

	    # Make sure hour is two digits (internally) for proper sorting
	    # Note: it is still printed as is
	    if (($by eq "time") && ($time[$i] =~ /^\d:/)) {
		$time[$i] = ("0" . $time[$i]);
		&debug_print(7, "Made hour two digit: $time[$i]\n");
	    }
	    # Convert time (internally) to numeric seconds for sorting purposes
	    # note: fraction optionally included as is (*e.g., under macos)
	    if ($time2num) {
		# examples:    306:25.88    0:04.36
		if ($time[$i] =~ /^((\d+):)?((\d+):)?(\d+)(\.\d+)?/) {
		    # groups:      1  2     3  4     5      6
		    my($hour) = defined($2) ? $2 : 0;
		    my($min) = defined($4) ? $4 : 0;
		    my($sec) = $5;
		    my($fract) = defined($6) ? $6 : "";
		    $time[$i] = ($hour * 3600 + $min * 60 + $sec + $fract);
		    &debug_print(5, "Converted time to seconds $time[$i]\n");
		}
		else {
		    &debug_print(5, "Warning: unable to parse time field: $time[$i]\n");
		}
	    }
	}
	else {
	    # note: based on SunOS (TODO: what else valid for?)
	    ($user[$i], $pid[$i], $cpu[$i], $mem[$i], $sz[$i], $rss[$i], 
	     $tt[$i]) = split;
	}
	$i++;
    }
    close(PS);

    
    # Determine the array to sort by
    #
    # *by_xyz = ($by eq "cpu" ? *by_cpu :
    #	         $by eq "mem" ? *by_mem :
    #	         $by eq "sz" ? *by_sz :
    #	         $by eq "rss" ? *by_rss :
    #	         *by_default);
    #
    # Note: See by_xyz function below.
    #
    &debug_print(&TL_VERBOSE, "eval \"*xyz = *$by\"\n");
    eval "*xyz = *$by";
    ## OLD: *xyz = *cpu if (!defined($xyz[0]));
    if (!defined($xyz[0])) {
	print STDERR "Error: bad sort field ($by): using cpu\n";
	*xyz = *cpu;
    }

    # Print the information sorted in proper order
    if ($num_times > 1) {
	&cmd("clear -x") unless ($batch);
	print "update $t of $num_times\n";
	&debug_out(&TL_DETAILED, "%s\n", &get_time());
    }
    printf "%s\n", substr($header, 0, $line_len);
    my $count = 0;
    foreach my $index (sort by_xyz @line_index) {
	printf "%s\n",  substr($line[$line_index[$index]], 0, $line_len);
	last if ($count++ == $max_count);
    }

    # See if the user wants to quit
    # TODO: restructure loop (e.g., with helpers for pause)
    if ($batch) {
	sleep($delay);
    }
    else {
        #
        for (my $i = 0; $i < $delay; $i++) {
	    if (&get_console_char() eq "q") {
		last PS_LOOP;
	    }
    
	    sleep(1);
        }
    }
}

#------------------------------------------------------------------------------

# Sort routines for the processor status arrays
# TODO: add support for time
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

    # Do reverse comparison (for numbers if numeric).
    # Otherwise, uses ascending sort.
    # TODO: Add option to override.
    my($comparison) = 0;
    ## OLD: if (&is_numeric($value_b) && &is_numeric($value_a)) {
    if ((! $alpha) && (&is_numeric($value_b) && &is_numeric($value_a))) {
	&debug_print(&TL_MOST_VERBOSE, "Using (descending) numeric sort\n");
	$comparison = ($value_b <=> $value_a);
    }
    else {
	&debug_print(&TL_MOST_VERBOSE, "Using (ascending) lexicographic sort\n");
	$comparison = ($value_a cmp $value_b);
    }
    &debug_print(&TL_MOST_DETAILED, "by_xyz() => $comparison\n");

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
    # TODO?: &debug_out(7, "flags=%08x result=%08x\n", $flags, $result);
    $result = fcntl(STDIN, &F_SETFL, $flags);
    if (defined($result)) {
	## TODO: drop /but true/ hack
	$result =~ s/but true//;
    }
    else {
	$result = "";
    }
    ## OLD:
    ## &debug_out(&TL_VERBOSE, "fcntl(STDIN, &F_SETFL, %08x) => %08x\n",
    ##  	  $flags, $result);
    &debug_out(&TL_VERBOSE, "fcntl(STDIN, &F_SETFL, %08x) => %s\n",
	       $flags, $result);

    return;
}
