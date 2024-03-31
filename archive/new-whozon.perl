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
# Sample output:
# TODO
# 

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';
use vars qw/$script_dir $verbose/;

&init_var(*OSTYPE, "???");
&init_var(*finger_cmd, $OSTYPE ne "solaris" ? "finger" : "/usr/ucb/finger");
&init_var(*db, "${script_dir}/users.db");	# ascii database of user names
&init_var(*unique, &FALSE);		# only show unique user entries
&init_var(*h, &FALSE);			# -h option for showing usage
my($db_changed) = &FALSE;

# Show a usage statement if no arguments given
# NOTE: By convention - is used when no arguments are required
if ($h) {
    my($options) = "main options = [-unique] [-db=file]";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "examples:\n\n$script_name -verbose\n\n";
    $example .= "$0 -h\n\n";
    my($note) = "";
    ## $note .= "notes:\n\nSome usage note.\n";		     # TODO: usage note

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n$note";
}

# Read in the list of user fullnames
my(%user_db);
my(%processed);
&read_user_db($db, \%user_db);


# Get the list of active users
# NOTE: Since the rusers command takes a while to execute, it is opened
# via s subprocess pipe rather than being invoked all at once.
#
open (USERS, "rusers -l|");
&debug_print(&TL_VERBOSE, "whozon ...\n");


# Print the fullname plus the w-style info for each user
#
while (<USERS>) {
    &dump_line($_);
    chomp;

    # Get user ID and console location
    my($user, $host_console, @rest) = split(/ +/, $_);
    next if ($unique && defined($processed{$user}));
    $processed{$user} = &TRUE;
 
    # First try to resolve the user's full name from the user database
    my($real_name) = &get_entry(\%user_db, $user, "");

    # If that fails, determine the name on the fly
    if ($real_name eq "") {
	# Run the finger command to determine the full name
	my($user_info) = &run_command("${finger_cmd} $user");
	if (($user_info =~ /In real life: (.*)\n/i)
	    || ($user_info =~ /Name: (.*)\n/i)) {
	    $real_name = $1;
	    &set_entry(\%user_db, $user, $real_name);
	    $db_changed = &TRUE;
	}
    }

    # Display the user's full name followed by ID and other info
    my($other_info) = ($verbose ? "@rest" : "");
    printf "$real_name: $user $host_console $other_info\n";
}


# Revise user database if changed
#
if ($db_changed) {
    &write_user_db($db, \%user_db);
}

#........................................................................

# Read in the list of user fullnames
#
sub read_user_db {
    my($file, $db_hash_ref) = @_;
    &debug_print(&TL_VERBOSE, "read_use(@_)\n");

    if (! open (USER_DB, "<$file")) {
	&warning("Unable to open user name database file '$file' ($!)\n");
	return;
    }
    while (<USER_DB>) {
	&dump_line($_);
	chomp;

	my($id, $name) = split(/\t/, $_);
	&set_entry($db_hash_ref, $id, $name);
    }
    close(USER_DB);
}

# Revise the list of user fullnames
#
sub write_user_db {
    my($file, $user_db_ref) = @_;
    &debug_print(&TL_VERBOSE, "write_user_db(@_)\n");

    open (USER_DB, ">$file");
    if ( ! open (USER_DB, ">$file")) {
	&warning("Unable to create user DB file '$file' ($!)\n");
	return;
    }
    print USER_DB "# <id>\t<full name>\n";
    foreach my $user (sort(keys(%$user_db_ref))) {
	my($name) = &get_entry($user_db_ref, $user);
	printf USER_DB "$user\t$name\n";
    }
    close(USER_DB);
}
