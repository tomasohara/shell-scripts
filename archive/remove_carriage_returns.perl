#!/usr/bin/perl -w
# *-*-perl-*-*
eval 'exec perl -Sw $0 "$@"'
    if 0;
#
# remove_carriage_returns.perl: remove carriage return characters from
# sources files (e.g., \r\n => \n). This is to fix files that were editted
# under MS DOS and related operating systems (e.g., Windows) and thus
# use 0xOD 0x0A instead of 0x0A at the end of each line.
#
# Note: to simplify the check-in process, the files are modified only
# if the returns are found.
#
# TODO:
# - Have option to just pipe the output to stdout rather modification in place.
# - Have option to backup the file (e.g., in case in advertantly invoked over PDF file, etc.).
#

use strict;
use Getopt::Long;

# Determine the defaults for the old and new copyright years
my($quiet) = 0;		# don't display warnings
my($all) = 0;		# fix all \r's (not just \r\n sequences)
my($test) = 0;		# just check for CR's, etc.: don't fix
my($force) = 0;		# whether non-ascii files should be converted
my($verbose) = 0;	# show verbose output during progress
my($debug) = 0;		# debug level
my($recursive) = 0;     # recursively process directories


# Show a usage statement if no input is given
if (!defined($ARGV[0])) {
    my($user) = $ENV{"USER"} || "guest";
    my($options) = "options = [-quiet] [-all] [-force] [-test] [-verbose]";
    my($example) = "Examples:\n\n$0 count_it.perl\n\n";
    $example .= "find . -type f -exec $0 {} \\;\n\n";
    $example .= "find . \\( -name '*.lisp' -o -name '*.cl' \\) -exec remove_carriage_returns.perl -all {} \\;\n\n";
    $example .= "find . -name CVS -exec remove_carriage_returns.perl -verbose {} \\;\n\n";
    my($note) = "Notes:\n\n";
    $note .= "- By default, binary files are not converting. Use -force to override this.\n\n";
    $note .= "- The -all option converts all carriage returns not just those in CR/LF's\n";

    die "\nUsage: $0 [options]\n\n$options\n\n$example\n$note\n";
}

# Get the command-line options
&GetOptions("quiet" => \$quiet,
	    "force" => \$force,
	    "test" => \$test,
	    "debug=n" => \$debug,
	    "d=n" => \$debug,
	    "verbose" => \$verbose,
	    "all" => \$all);

# Load in optional module for debugging support
if ($debug) {
    my $dir = $0; $dir =~ s/[^\\\/]*$//; unshift(@INC, $dir);
    require 'common.perl';
    use vars qw/$debug_level/;
    ## eval { &debug_on($debug); };
    eval { $main::debug_level = $debug; };
}


# Scan through each file checking for carriage returns
for (my $i = 0; $i <= $#ARGV; $i++) {
    my($filename) = $ARGV[$i];
    eval { &debug_print(&TL_VERBOSE, "File: $filename\n"); } if ($debug);

    # Ignore . and .. (current and parent pointers)
    if ($filename =~ /^\.\.?$/) {
	next;
    }

    # Expand directories
    if (-d $filename) {
	# TODO: handle dot files (e.g., .emacs)
	## my(@new_files) = glob("$filename/.[^.]* $filename/*");
	if ($recursive) {
	    my(@new_files) = glob("$filename/*");
	    print "Expanded directory ${filename}: @new_files\n" if ($verbose);
	    push (@ARGV, @new_files);
	}
	else {
	    print("Warning: skipping directory ${filename}; use -recursive to include.\n");
	}
	next;
    }
    print "Checking file ${filename}\n" if ($verbose);

    # Make sure the file is ascii
    if ((! $force) && (-B $filename)) {
	print "WARNING: not converting likely binary file ($filename): use -force option to override.\n";
	next;
    }

    # Read in the entire file contents
    my($data) = &read_text_file($filename);

    # Check for <CR> usage and also missing <NL>'s at end-of-file
    # TODO: get regex test to work: ($data =~ /[^\n]$/)
    if (($data =~ /\r\n/) 
	|| (($data ne "") && (substr($data, -1) ne "\n"))
	|| ($all && ($data =~ /\r/))) {

	# Display status message
	if (! $quiet) {
	    print "Fixing file ${filename}\n";
	}

	# Convert <CR><NL> to just <NL>
	$data =~ s/\r\n/\n/g;

	# Check for special cases of <CR> at end of file or missing <newline> at end
	$data =~ s/\r$/\n/g;
	$data .= "\n" unless ($data =~ /\n$/);

	# Handle case when just carriage returns (from Macintosh??)
	$data =~ s/\r/\n/g if ($all);

	# Overwrite the file
	# TODO: have option to create backup first
	&write_text_file($filename, $data) unless ($test);
    }
}


#------------------------------------------------------------------------

# read_text_file(file_name)
#
# Reads in the entire file, and returns the data as a text string.
#
sub read_text_file {
    my($file_name) = @_;
    my($text) = "";

    if (!open(READ_FILE, "<$file_name")) {
	printf STDERR "ERROR: unable to read file $file_name ($!)\n";
	return ($text);
    }

    while (<READ_FILE>) {
	$text .= $_;
    }
    close(READ_FILE);

    return ($text);
}

# write_text_file(file_name, text)
#
# Writes the text to the specified file.
#
sub write_text_file {
    my($file_name, $text) = @_;

    if (!open(WRITE_FILE, ">$file_name")) {
	printf STDERR "ERROR: unable to create file $file_name ($!)\n";
	return;
    }
    print WRITE_FILE $text;
    close(WRITE_FILE);

    return;
}

