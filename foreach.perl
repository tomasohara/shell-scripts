# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#! /usr/local/bin/perl -s
#
# foreach.perl: Evaluate a command for each argument. The special variable
# $f will be replaced by the current file. Other variables are as follows:
#	$f	fully-specified file name
#	$d	directory name
#	$b	file w/o directory
#	$B	same but also without file extensions
#	$h	host name
#       $n	alias for $f (for use with -count option)
# These can also be referred to a &f, etc.
# ex: foreach.perl 'echo $f' *.c
#
# NOTE: Remote execution is now supported. This will run each command in the
# on one of the hosts given by -hostlist. See the script
# /home/graphling/WORD_SENSE/SYNSET_FREQUENCY/est_POS_freq.sh for an example
# of doing this for a particular command. It was the basis for the support
# included here.
#
# TODO:
# - add additional placeholders (eg, $t for current time)
# - alternative add eval option to support adhoc needs -eval='($t = scalar)time;'
# - decompose main loop into subroutines and add EX unit-tests
# - properly escape double quotes (e.g., to avoid having to use \" within single quotes on command line)
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); 
    require 'common.perl';
    use vars qw/$d $script_dir $script_name $ssh/;
}

# Be strict about variable usage (unless if -nostrict specified)
use vars qw/$nostrict/;
if (! defined($nostrict)) {
    use strict;
}

use vars qw/$kill $status $remote $no_files $pause $all $busy_load $trace
            $quote $noquote $nonfile $from $to $step $count $DOMAINNAME $HOST $hostlist $f $F $h $b $B $d $n/;

&init_var(*kill, &FALSE);
&init_var(*status, &FALSE);
&init_var(*remote, ($kill || $status));
&debug_out(5, "remote=$remote (\$\#ARGV == 0)=%s\n", ($#ARGV == 0));
&init_var(*no_files, $remote && ($#ARGV == 0));
## &init_var(*pause, 60);
&init_var(*pause,               # number of seconds to sleep after issuing command
	  ($remote ? 60 : 0));
my($file_required) = (!($kill || $status));
&init_var(*all, &FALSE);	# use all available host
&init_var(*busy_load, 0.50);
&init_var(*trace, &FALSE);	# display command to be executed
&init_var(*quote, &FALSE);	# put quotes around the $f placeholder
&init_var(*nonfile, &FALSE);	# the $f placeholder is not for a file
&init_var(*noquote, $nonfile);	# don't automatically put quotes around the $f
#
&init_var(*from, 1);		# for loop start value
my($loop_count) = defined($to) ? ($to - $from + 1) : defined($count) ? $count : 0;
&init_var(*to, $from + $loop_count - 1); # for loop end value
&init_var(*count, $loop_count);		# number of times for loop
&init_var(*step, 1);		# loop increment
&init_var(*init_vars, "");	# user variables initialized on command line (e.g., foreach.perl -myvar=77 -init_vars="myvar" ...)

# Reference all of the user init-vars
foreach my $var (&tokenize($init_vars)) {
    printf "$var=%s\n", eval "\$$var";
}

# Initialize the list of hosts to use
# TODO: use crl_machines with filtering out of specific hosts (eg, dodona,
# pylos, helion, etc).
# also restrict hosts used by late-evening users: ilios, orchomenos, etc
# also hosts tied up by netscape, etc.: tenedos, kimmerion, corinth
my($domain_name_command) = (&WIN32 ? "ipconfig | perl -ne 'print \$1 if /DNS Suffix.*:\\s*(\\S+)/;'" 
			    : "domainname");
## &init_var(*DOMAINNAME, &run_command($domain_name_command));
&init_var(*DOMAINNAME, "");
$DOMAINNAME = &run_command($domain_name_command) unless ($DOMAINNAME ne "");
&init_var(*ssh, &FALSE);	# use ssh rather than rsh
my($rsh_options) = ($ssh ? "--ssh" : "");
&init_var(*HOST, "???");	# current host
&init_var(*hostlist,		# list of hosts for remote execution
	  ($remote ? &default_host_list() : "localhost"));
my(@host) = &tokenize($hostlist);
my($num_hosts) = $#host + 1;
&assert($num_hosts > 0);


# Show usage and then exit if insufficient number of arguments
if (($file_required) && (!defined($ARGV[0]))) {
    &usage();
    &exit;
}


# Get the command to execute from the command-line arguments.
## OLD: &trace_array(\@ARGV);
&trace_array(\@ARGV, 4, "ARGV");
my($command) = shift @ARGV;
&debug_out(&TL_VERBOSE, "command='%s'\n", $command);

# Create a dummy file for each host (to execute upon)
# TODO: handle more directly in the loop logic below
if (defined($ARGV[0]) && ($ARGV[0] eq "-")) {
    undef $/;			# set entire-file-mode input
    @ARGV = split(/\n/, <STDIN>);
}
elsif ($no_files) {
    &assert($#ARGV == -1);
    ## @ARGV = ("") x $num_hosts; # create dummy files
    @ARGV = ($remote ? @host : (("") x $num_hosts));
}


# Handle special remote-execution status-related options
# NOTE: This is handled differently from remote so that the same command
# is sent to each possible host (not just one host per file)
if ($kill || $status) {
    my($command_line) = $command;
    if ($kill) {
	# Use a  script to kill the remote job
	$command_line =~ s/\|/\\\|/g;
	&debug_out(6, "command_line=%s\n", $command_line);
	$command_line = "${script_dir}/kill_em.sh -p '$command_line'";
    }
    else {
	# Use a script to show all the user's jobs (on the remote host)
	$command_line = "${script_dir}/ps_mine.sh --verbose";
    }
    foreach my $host (@host) {
	&issue_command("rsh.sh $rsh_options --time-out $host $command_line");
    }
    &exit;
}

# Add the file-name placeholder ($f) to the end if not given (and if
# $b, &F, &B, &h, or $n not given).
if (($command !~ /[\$\&]\{?[fbdBhn]\}?/) && ($no_files == &FALSE)) {
    $command .= " \$f";
    &debug_out(&TL_VERBOSE, "command to run: '%s'\n", $command);
}

# Similate for loop by expanding command-line argument to include index values
if ($count > 0) {
    @ARGV = ();
    for (my $i = $from; $i <= $to; $i += $step) {
	push(@ARGV, "$i");
    }
}

my($host_pos) = 0;
## my($count) = 0;
my($wrap_around) = &FALSE;
my($n) = 0;			# 1-based position in foreach list
&debug_print(7, "pre foreach ARGV: ARGV=(@ARGV)\n");
foreach $f (@ARGV) {
    &debug_print(7, "f=$f\n");
    $F = $f;
    my($command_line) = $command;
    my($host) = "";
    $n++;

    # Handle remote-execution option by converting command into rsh command
    if ($remote) {
	# Pause whenever the host list wraps around
	&debug_out(6, "host_pos=$host_pos wrap_around=$wrap_around\n");
	if ($wrap_around) {
	    &cmd("sleep $pause");
	    $wrap_around = &FALSE;
	}

	# If remote execution is desired, find the next host in the list
	# that is accessible.
	for (my $i = 0; $i < $num_hosts; $i++) {
	    $host = $host[$host_pos];
	    if (++$host_pos == $num_hosts) {
		$host_pos = 0;
		$wrap_around = &TRUE;
	    }

	    # Make sure the host is accessible
	    my($ping_result) = &run_command("ping.sh $host");
	    if (($ping_result eq "") || ($ping_result  =~ /(time.*out)|(unknown)/i)) {
		&debug_out(4, "unable to ping $host\n");
		next;
		}

	    # Make sure the host isn't too busy (e.g., load should be under 1)
	    if ($busy_load > 0.0) {
		my($load_info) = &run_command("rup.sh --time-out $host");
		my(($load_avg)) = ($load_info =~ /load average:\s([^ \t,]+),/);
		if (!defined($load_avg) || ($load_avg >= $busy_load)) {
		    &debug_out(4, "$host too busy (load >= $busy_load): $load_info\n");
		    next;
		}
	    }

	    # Accept this host 
	    last;
	}

	# Add the rsh command for remote execution.
	# NOTE: Done for commands separated by semicolons as well
	$command_line = "rsh.sh $rsh_options $host $command_line";
	$command_line =~ s/; ([^r])/; rsh.sh $rsh_options $host $1/g;

	# Make sure the file name path is fully specified.
	# Otherwise the file might be taken from the user's home directory.
	$f = &make_full_path($f) unless ($nonfile);
    }
    if (($quote || ($f =~ /\s/)) && (! $noquote)) {
	$f = '"' . $f . '"';
    }
    $b = &remove_dir($f);	# $b placeholder for basename
    $B = $b;
    $B =~ s/\..*$//;		# $B placeholder for basename sans extension
    $d = &dirname($f);		# $d placeholder for directory
    $h = $host;			# $h placeholder for remote host name
    ## $n = $f;			# $n placeholder for count
    &debug_out(6, "f=%s d=%s b=%s B=%s h=%s\n", $f, $d, $b, $B, $host);

    # Evaluate and run the command
    # NOTE: This is done in a evaluation environment to allow for placeholder
    # varables (eg, $f for current file)
    # TODO: fix error handling when command has embedded quotes (double, single or back)
    $command_line =~ s/&([dbBfFhn])/\$$1/g;
    &debug_out(&TL_VERBOSE, "issuing: %s\n", $command_line);
    if ($trace) {
	printf STDERR "issuing: %s\n", eval "\"$command_line\"";
	}
    eval("issue_command(\"$command_line\", &TL_DETAILED);");
    if ($pause) {
	&cmd("sleep $pause");
    }
}

&exit();

#------------------------------------------------------------------------------

# default_host_list(): Returns space-delimited string list with the default set
# of hosts to be used for remote execution, based on the hostname and the domainname.
# There is a space before the first and last host to facilitate simple searching.
# TODO: put the hardcoded lists into data files
#
# By default, the Pentium 3 linux hosts are used if under CS, unless if on one
# of the beowolf cluster controllers (medusa and colossus), in which case the
# corresponding parallel node hosts are used ({wb1 .. wb32} or {bw1 .. bw32}).
#
# For current list of NMSU CS hosts, see
#    http://intranet.cs.nmsu.edu/COG/Hardware/hosts.html
# The undergraduatre P3 machines are extracted as follows:
#   $ grep -B1000 ^Graduate cs-hosts.list | grep "Pentium III.*Linux" | cut -d' ' -f4 >| cs-undegrad-p3-linux-hosts.list
#
sub default_host_list ()
{
    my($host_list) = "";
    
    if ($DOMAINNAME eq "crl.nmsu.edu") {
	# note: need to hardcode list to avoid using certain machines
	$host_list = " marathon  tenedos  pramnos  messene  thebes "
	    . " hellespont  temese  lemnos  ismaros  phoenicia "
	    . " troia  amnisos  argos  asteris  ephyre "
	    . " gortyn  kydonia  nericos  pharos  oleada "
	    . " kimmerion  corinth  ilios  orchomenos  krouni "
	    . " kyklopon  kypros  sparta  zakynthos "
	    . "";
    }
    elsif ($DOMAINNAME eq "cs.nmsu.edu") {
	# Check for the old beowolf cluster
	if ($HOST eq "medusa") {
	    $host_list = 
		"   wb1  wb2  wb3  wb4  wb5  wb6  wb7  wb8  wb9  wb10 "
		. " wb11 wb12 wb13 wb14 wb15 wb16 wb17 wb18 wb19 wb20 "
		. " wb21 wb22 wb23 wb24 wb25 wb26 wb27 wb28 wb29 wb30 "
		. " wb31 wb32 "
		. "";
	}
	# Check for the new beowolf cluste
	elsif ($HOST eq "colossus") {
	    $host_list = 
		"   bw1  bw2  bw3  bw4  bw5  bw6  bw7  bw8  bw9  bw10 "
		. " bw11 bw12 bw13 bw14 bw15 bw16 bw17 bw18 bw19 bw20 "
		. " bw21 bw22 bw23 bw24 bw25 bw26 bw27 bw28 bw29 bw30 "
		. " bw31 bw32 "
		. "";
	}
	elsif ($all) {
	    $host_list = " acapulco antwerp bangkok balamb blake cairo calgary caracas "
		. " casablanca chicago clink cobra coleman dakar dali detroit "
		. " duster edsel enzo gremlin hiro hongkong hopkins kinshasa "
		. " lagos lhasa lima lindbulm lummox maverick midgar mini mustang  "
		. " nairobi nergal quito prague raven rio salzburg seoul singapore "
		. " sydney timber utai valencia vegas venice victor vincent vitaly "
		. " waldo tobago aruba gaan-srv rhuidean simone trinidad grenada "
		. " grendel jamaica pippo shenyang trutta tuscan viper scanner "
		. " gato perro salmo medusa ";
	}

	# TODO: Add in other hard-coded lists here
	elsif (&FALSE) {
	    $host_list = " a b c ... z ";
	}

	# Otherwise use a bunch of Pentium IV Linux hosts
	else {
	    $host_list = ""
		. " antwerp bamf bangkok baz beetle clobber cobra coleman countach dart derf "
		. " duster eclipse edsel epoch frob feep glob gremlin hongkong hopkins "
		. " kluge maverick munge nova quine runic scag singapore segv valencia "
		. " viggen yikes zeroth antwerp seoul ";
	}
    }
    else {
	$host_list = " "
	    . &run_command("rup.sh --time-out | sed -e \"s/ up .*//;\" ")
	    . " ";
    }
    &assert($host_list !~ /^\s*$/);
    &assert($host_list !~ /^\sa b c \.\.\. z $/i);

    return ($host_list);	  
}


# Perl constants for use as substitutes for $f, etc.
# note: case is significant in the placeholders
#
sub d { return ($d); }		# current directory
sub b { return ($b); }		# file basename 
sub B { return ($B); }		# basename proper (no directory)
sub f { return ($f); }		# filename
sub h { return ($h); }		# host for remote execution
sub n { return ($n); }		# current count

# usage(): Displays usage statement on stdard error
# TODO: have option for verbose explanation
#
sub usage {
    print STDERR <<END_USAGE;

usage: $script_name [options] 'command' [file ... | -]

options = [-no_files] [-pause=N] [-busy_load=N.NN] [-kill] 
          [-trace] [-remote] [-hostlist='H1 ... Hn'] [-status]
          [-from=N] [-to=N] [-count=N] [-step=N]

Run the command for each of the files. Each time the \$f variable will be 
updated to reflect the current filename. This will also be done for the
other placeholder variables (\$d for directory and \$b for base name).

Examples:

$0 'echo \$f' *.c

$script_name -status -d=4 >| status.log 2>&1

$script_name 'wsd_classify.perl \$f' DJ*/dj*.tag >&! classify4.log &

perl -Ssw $script_name 'ln -s \$b `echo \$b | tr A-Z a-z` ' [A-Z]*

$script_name 'bash -i -c \\\"spanish-lookup \$f\\\"' perro gato

Notes:

With remote execution (-remote option), the commands are run on different
hosts, as specified below:
    $hostlist

Placeholders for use in the command:
    \$F   file name as given
    \$d   directory name
    \$b   file w/o directory
    \$B   same but also without file extensions
    \$h   host name (for use with -remote option)
    \$n   position in the list (1-based)
These can also be referred using &X rather than \$X (e.g., '&B').

END_USAGE
}

## OLD paceholder help:
##     \$f   fully-qualified file name (or \$n if -count specified [obsolete, use $n instead see below])
