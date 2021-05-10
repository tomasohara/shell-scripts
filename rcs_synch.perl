# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# rcs_synch.perl: recursively syncronizes the directories against the RCS
# source
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

if ((defined($ARGV[0]) && ($ARGV[0] eq "help"))
    || (!defined($ARGV[0]) && &blocking_stdin())) {
    &usage();
}

&init_var(*force, &FALSE);	# force overwrites
## &init_var(*read_only, &TRUE);	# only processes read-only files
&init_var(*subdirs, &FALSE);	# include subdirectories

local($dirname) = $ARGV[0];
if (-d $dirname) {
    &synchronize($dirname);
}
else {
    &error_out("must provide a directory name for the base\n");
    &usage();    
}

#------------------------------------------------------------------------------

sub usage {
    $options = "options = [-force] [-subdirs]";
    $example = "ex: $script_name -subdirs .\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
}

sub synchronize {
    local ($dir) = @_;
    &debug_out(4, "synchronize(@_)\n");
    &assert('(-d $dir)');
    local($current_dir) = &pwd();

    # Get into the directory
    chdir $dir;

    # Synchonize each file that has an RCS file
    # TODO: Also get new versions of RCS files not in current directory.
    local($file);
    foreach $file (glob("* .*")) {
	&debug_out(6, "file=$file\n");
	if (-l $file) {
	    &debug_out(5, "skipping link '$file'\n");
	    next;
	}

	# Only synchronize plain files
	# NOTE: This just affects read-only files unless -force specified
	if ((-f $file) && ((! -w $file) || $force)) {
	    # Verify that the file is under RCS
	    local($rcs_file) = &run_command("cmd.sh rlog -R $file");
	    if ($rcs_file =~ /No such file/i) {
		&debug_out(5, "skipping non-RCS file '$file'\n");
		next;
	    }
	    # Don't update files that haven't changed
	    local($rcs_diff) = &run_command("cmd.sh rcsdiff -q $file"); 
	    if ($rcs_diff eq "") {
		&debug_out(4, "RCS file '$file' hasn't changed\n");
		next;		
	    }

	    # Update the current version of the file
	    &debug_out(4, "Synchronizing RCS file '$file'\n");
	    local($options) = "-M"; 	# -M uses timestamp of RCS file
	    $options .= " -f" if ($force);
	    &cmd("co $options $file");
	}

	# Recursively process directories that aren't symbolic links
	elsif (($subdirs) && (-d $file) && (! (-l $file))) {
	    &synchronize($file) unless (($file eq ".") || ($file eq ".."));
	}
    }

    # Restore directory
    chdir $current_dir;

    return;
}

