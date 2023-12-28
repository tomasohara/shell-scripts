# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# File Name: check_permissions.perl
# Example: check_permissions.perl /home/sliu/1stdy/372/polynm graphling
#
# This file will check all the files in the
# /home/graphling directory tree to make sure the following conditions
# hold. It should attempt to fix any problems for files that the current
# user owns.
#        - the group is graphling
#                chgrp graphling file
#        - group permissions for files have read access
#                chmod g+r file
#        - group permissions for directories have execute access
#                chmod g+xs dir
#        - the owner is a member of the graphling group 
# 
# change member checker into sub routine
# 


# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

if ((defined($ARGV[0]) && ($ARGV[0] eq "help"))
    || (!defined($ARGV[0]) && &blocking_stdin())) {
    &usage();
}

# Get the working directory
local($dirname) = $ARGV[0];

# Get the group name: graphling is a default group name
local($groupname) = "graphling";
if (defined($ARGV[1])) {
    $groupname = $ARGV[1];
}

# Get the user's ID
local($userid) = &run_command("echo \$USER"); 
print "you are $userid. \n";

# Set disable parameter 
local($undo) = 1;
if (&in_group($userid, $groupname)) {
    $undo = 0;;
}

if ($undo == 1){
    print ("You are not member of $groupname.\n");
    print ("All operations will be automatically disable\n");
   }


if (-d $dirname) {
    print ("The working directory is name :$dirname \n"); 
    &permission($dirname, $undo, $groupname);
    # &permission($dirname, $undo, $groupname);
}

else {
    &error_out("You must provide a directory name for the base\n");
    &usage();    
}

#------------------------------------------------------------------------------
# Give message, if parameters are omited
#
sub usage {
    $options = "option = [group]";
    $example = "ex: $script_name diretoryname apollo\n";
    $default = "If the option is omited, \"graphling\" will be a default group name.\n";
    die "\nusage: $script_name diretory [options]\n\n$options\n\n$example\n\n$default\n\n";
}

#------------------------------------------------------------------------------
# Check a name in a group (return 1) or not (return 0) 
# 
# This version uses the groups command instead of ypcat which isn't updated timely
#

sub in_group {
    local ($your_name, $my_group) = @_;
    &debug_trace(4, "in_group(@_)\n");
    &debug_trace(6, "get your_nam: $your_name, my_group: $my_group\n");

    # See if the group is listed under the groups for the user
    local($groups) = " " . &run_command("groups $your_name") . " ";
    local($in_group) = &FALSE;
    if (index($groups, " $my_group ") != -1) {
	$in_group = &TRUE;
    }

    return ($in_group)
}

#------------------------------------------------------------------------------
# Check a name in a group (return 1) or not (return 0) 
#
# this is the old version using yellow pages

sub old_in_group {
    # Get membership list of the group
    local($group) = &run_command("ypcat group | grep $my_group");
    local(@grouplist) =split(/[:,]/, $group);

    # Remove redundant elements from the list 
    shift (@grouplist);
    shift (@grouplist);
    shift (@grouplist);

    # search the name from the list
    foreach $grouplist (@grouplist) {
 	# print ("\ngrouplist is $grouplist\n"); 
	if ($your_name eq $grouplist) {
	    # print ("\n$your_name is found in $my_group\n"); 
	    return (1);
	}
    }
    # print ("\n$your_name is not found in $my_group\n");  
    return (0);
}

#------------------------------------------------------------------------------


# permission (directory,[disable])
#
# Goto the specified directory, check permissions for member of graphling.
#
# NOTE: Command execution is disabled with $disable commands = 1
#
sub permission {
    local ($dir, $disable, $groupname) = @_;
    $disable = 0 unless (defined($disable));
    local($groupname) = 'graphling' unless (defined($groupname));
    &debug_print(4, "permission(@_)\n");
    &assert('(-d $dir)');
    local($current_dir) = &pwd();

    # Get into the directory
    if (! (chdir $dir)) {
	&error_out("Unable to access directory '$dir'\n");
	return;
    }
    print ("working on dir:$dir\n");

    #Get the my ID
    local($myid) = &run_command("echo \$USER"); 
    
    # Check permission file by file
    local($file);
    foreach $file (glob("* .*")) {
	&debug_print(6, "file=$file\n");
	
	$line = &run_command("ls -dl '$file'");
	# $line = &run_command("ls -al $file |grep -v ' \\.'");
	
	# Capture the features of the file
	
	local($permission, $links, $owner, $group, $bytes, $month, $day, $timeyear, $file) = split(/ +/, $line);
	&debug_print(7, "($permission, $links, $owner, $group, $bytes, $month, $day, $timeyear, $file)\n");
	
	# Capture the permissions of the file
	local($direct,$or,$ow,$ox,$gr,$gw,$gx,$tr,$tw,$tx) = split(//, $permission);
	&debug_print(7, "($direct,$or,$ow,$ox,$gr,$gw,$gx,$tr,$tw,$tx) = split(//, $permission)\n");
	
	# Set I am owner flag 
	if ("$myid" eq "$owner"){
	    local ($i_am_not_owner) = 0;
	    #print ("You are an owner, so you can access $file.\n");
	}
	else {
	    $i_am_not_owner = 1;
	    &debug_print(4, "Not owner! So you can not access following: ");
	    &debug_print(4, "$permission, $owner, $group, $file\n");
	}
		
	# Set in_our_group flag
	$ingroup = 0;
	if (&in_group($owner, $groupname)){
	    $ingroup = 1;
	    # print ("\n$owner is a member of $groupname \n"); 
	}
	print "\n$owner is not in $groupname, skip $file\n" unless ($ingroup); 
		
	# Before changing permission, check the ower is member of group
	if ($ingroup){
	    
	    # Handle truncated "graphling" problem 
	    if ($group eq "graphlin"){
		$group = "graphling";
	    }
	    
	    # Change group name 
	    if ($group ne $groupname){
		print ("group name is not $groupname!\n");

		# To change group name   
		print "$permission, $owner, $group, $file\n";
		&run_command("chgrp $groupname '$file'") unless (($disable || $i_am_not_owner)); 
		}
	    if ((-f $file) && (! (-l $file))){
		# If group not readable, change read permission for the group
		if ($gr ne "r"){
		    print ("group not readable!\n");
		    print "$permission, $owner, $group, $file\n";
		    &run_command("chmod g+r '$file'")  unless (($disable || $i_am_not_owner)); 
		}
	    }
	    # Recursively process directories that aren't symbolic links
	    elsif ((-d $file) && (! (-l $file))) {
		# If group not readable, change read permission for the group
		if ($gr ne "r"){
		    print ("group not readable!\n");
		    print "$permission, $owner, $group, $file\n";
		    &run_command("chmod g+r '$file'")  unless (($disable || $i_am_not_owner)); 
		}
		# If group not executable, change excute permission for the group
		if ($gx eq "-"){
		    print ("group not accessable!\n");
		    &run_command("chmod g+xs '$file'") unless ($disable || ($i_am_not_owner));
		    print "$permission, $owner, $group, $file\n";
		}	
		&permission($file, $disable, $groupname) unless (($file eq ".") || ($file eq ".."));
	    }
	    else {
		print ("non-$groupname owner!\n");
		print "$permission, $owner, $group, $file\n";
	    }
	}
    }
    # Restore directory
    chdir $current_dir;
    
    return;
}

