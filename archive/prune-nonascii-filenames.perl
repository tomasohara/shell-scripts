# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# prune-nonascii-filenames.perl: prunes files and directories with non-ascii
# filenames
#
# NOTES:
# - Used for pruning miscellaneous files from the Wikipedia distribution.
# - *** Warning: This can be very dangerous, so prompts are used unless disabled.
# 
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = $0; $dir =~ s/[^\\\/]*$//; unshift(@INC, $dir);
    require 'common.perl';
    use vars qw/$verbose/;
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
use vars qw/$prune_subdirs $remove_dirs $dont_prompt_for_removal $quiet/;

# Show a usage statement if no arguments given
# NOTE: By convention - is used when no arguments are required
if (!defined($ARGV[0])) {
    my($options) = "main options = [-prune_subdirs] [-remove_dirs] [-dont_prompt_for_removal] [-quiet]";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "Examples:\n\n$script_name -verbose ~/wiki/en\n\n";
    ## $example .= "$0 example2\n\n";		   	     # TODO: 2nd example
    my($note) = "";
    ## $note .= "Notes:\n\nSome usage note.\n";		     # TODO: usage note

    print STDERR "\nUsage: $script_name [options]\n\n$options\n\n$example\n$note";
    &exit();
}

# Check the command-line options
# note: Each variable initialized corresponds to a -var=value commandline option
&init_var(*prune_subdirs, &FALSE);		# recursively process directory
&init_var(*remove_dirs, &FALSE);		# remove directories with nonascii filenames
&init_var(*dont_prompt_for_removal, &FALSE);	# omit verification prompts
&init_var(*quiet, &FALSE);			# omit progress report
$verbose ||= (! $quiet);

foreach my $dir (@ARGV) {
    &prune_nonascii_files($dir);
}

&exit();


#------------------------------------------------------------------------------

# prune_nonascii_files(dir_name): removes all non-ascii filenames from dir
#
sub prune_nonascii_files {
    my($dir) = @_;
    &debug_print(&TL_DETAILED, "prune_nonascii_files(@_)\n");

    # If directory itself has non-ascii filename, remove it entirely
    if (&has_nonascii_filename($dir)) {
	my($do_deletion) = ($dont_prompt_for_removal || &verify_prompt("Remove dir '$dir'?"));
	if ($do_deletion) {
	    print "Removing directory '$dir'\n" if ($verbose);
	    &issue_command("/bin/rm -rf '$dir'");
	}
	return;
    }

    # Read the directory contents
    if (! opendir(DIR, "$dir")) {
	&error("Unable to open directory '$dir' ($!)\n");
	return;
    }
    my(@files) = readdir(DIR);
    closedir(DIR);

    # Remove all files with non-ascii names, recursively processing subdirectories
    foreach my $file (@files) {
	&debug_print(&TL_VERY_VERBOSE, "file: '$file'\n");
	next if (($file eq ".") || ($file eq ".."));
	my($path) = "$dir/$file";

	# Handle subdirectories recursively
	if (-d $path) {
	    &prune_nonascii_files($path);
	}

	# Remove file in non-ascii filename and user agrees
	elsif (&has_nonascii_filename($path)) {
	    my($do_deletion) = ($dont_prompt_for_removal || &verify_prompt("Remove file '$path'?"));
	    if ($do_deletion) {
		print "Removing file '$path'\n" if ($verbose);
		unlink $path;
	    }
	}

	# Otherwise ignore entry
	else {
	    &debug_print(&TL_VERY_DETAILED, "Retaining file '$path'\n");
	}
    }

    return;
}

# has_nonascii_filename(filename): determines whther filename has non-ascii characters
#
sub has_nonascii_filename {
    my $nonascii = ($_[0] =~ /[\x80-\xFF]/) || &FALSE;
    &debug_print(&TL_VERBOSE, "has_nonascii_filename(@_) => $nonascii\n");

    return ($nonascii);
}

# verify_prompt(question): see if user agrees to question
#
sub verify_prompt {
    my($question) = @_;
    print STDERR $question, "\n";

    my($answer) = <> || "";
    my $OK = (&trim($answer) =~ /^Yy$/) || &FALSE;
    &debug_print(&TL_VERY_DETAILED, "verify_prompt(@_) => $OK\n");

    return ($OK);
}
