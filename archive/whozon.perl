# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#! /usr/local/bin/perl -sw
#
# whozon.perl: script to list the remote users along with the full names.
# This just augments the "rusers -l" output with the real-life name from 
# the finger command.
#
# sample "rusers -l" output:
#
# hhuang   sioux:console         Jul  4 16:01      22 (:0)
# kalt     sioux:pts/3           Jun 23 08:10   73:45 (pima)
# dliao    sioux:pts/6           Jul  4 16:12      36 (chaperito)
# pmamnani sioux:pts/9           Jul  4 16:20    1:19 (i090.px.extremez)
# rmathur  sioux:pts/1           Jun 24 03:35   45:36 (talk)
# aluru    titanic:console       Jun 30 08:58   27:42 (:0)
# fsevilge titanic:dtremote      Jul  1 13:23   43:40 (taos:0)
# srikant  shakti:ttyq0          Jun 25 15:06  218:51 (:0.0)
# srikant  shakti:ttyq1          Jun 25 15:06  188:43 (:0.0)
# jbarnden silicon:console       Jul  4 08:24        
# ...
# daraiza  aztec:ttyp4           Jun 26 12:59   77:46 (san-jose:0.0)
# tomohara aztec:ttyp5           Jul  4 14:38    3:09 (:0.0)
# tomohara aztec:ttyp6           Jul  4 14:40       5 (:0.0)
# tomohara aztec:ttyp7           Jul  4 14:49         (:0.0)
# 

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

&init_var(*OSTYPE, "???");
&init_var(*finger_cmd, $OSTYPE ne "solaris" ? "finger" : "/usr/ucb/finger");
$user_name{"# <id>"} = "<full name>";
$db_changed = &FALSE;

# Read in the list of user fullnames
#
open (USER_DB, "<$script_dir/users.list");
while (<USER_DB>) {
    &dump_line($_);
    chop;

    ($id, $name) = split(/\t/, $_);
    $user_name{$id} = $name;
}
close(USER_DB);
&reset_trace();


# Get the list of active users
#
open (USERS, "rusers -l|");
## open (USERS, "test_whozon.list");
debug_out(3, "whozon ...\n");


# Print the fullname plus the w-style info for each user
#
while (<USERS>) {
    &dump_line($_);
    chop;

    ## ($user, $host_console, $mon, $date, $time1, $time2, $login_host) 
    ## 	= split(/ +/, $_);
    ## &debug_out(4, "u=$user, h=$host_console, m=$mon, d=$date, t1=$time1, t2=$time2, lh=$login_host\n");
    ($user, $host_console, @rest) = split(/ +/, $_);
 
    $real_name = "???";
    if (defined($user_name{$user})) {
	$real_name = $user_name{$user};
    }
    else {
	$user_info = &run_command("${finger_cmd} $user");
	if (($user_info =~ /In real life: (.*)\n/i)
	    || ($user_info =~ /Name: (.*)\n/i)) {
	    $real_name = $1;
	    $user_name{$user} = $real_name;
	    $db_changed = &TRUE;
	}
    }

    ## printf "$real_name: $user $host_console $mon $date $time1 $time2 $login_host\n";
    printf "$real_name: $user $host_console @rest\n";
}


# Revise user database if changed
#
if ($db_changed) {
    &debug_out(3, "updating user database\n");
    open (USER_DB, ">$script_dir/users.list");
    foreach $user (sort(keys(%user_name))) {
	$name = $user_name{$user};
	printf USER_DB "$user\t$name\n";
    }
    close(USER_DB);
}

