# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -s

# Split a portion of a file, base on inclusion regions.
#
# usage: split_subfile.perl [start] [end]
# ex: split_subfile.perl "    FUNCTION" "    DESCRIPTION" < clman.data
#
# TODO:
# - reconcile w/ extract_subfile.pe
# - default extension to .txt (not "" as with Unix split).
# - have option for Unix split compatibility (eg, no extension)
# - add regression tests in case any uses relied upon old if/elif/else structure.
# - create simpler script for splitting by lines
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir);
    require 'common.perl';
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
## TODO: 
use strict;
use vars qw/$include_start $include_end $ext $file_pattern $skip_start $file_base $base $header $trailer $start_num/;

# Show a usage statement if no arguments given
# NOTE: By convention - is used when no arguments are required
if (!defined($ARGV[0])) {
    my($options) = "main options = [-skip_start] [-include_end] [-ext=label] [-file_base=label] [-file_pattern=regex]";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "examples:\n\n$0 -skip_start FUNCTION DESCRIPTION clman.data\n\n";
    $example .= "$script_name -ext='.xml' -base='genia-' -include_end -header='<?xml version=\"1.0\" encoding=\"UTF-8\"?>' '<article>' '</article>' ../GENIAcorpus3.02.xml\n\n";
    my($note) = "";
    $note .= "notes:\n\nRegular expressions can be used start and end.\n";

    print STDERR "\nusage: $script_name split_subfile.perl [start] [end] [file]\n\n$options\n\n$example\n$note";
    &exit();
}

# Check the command-line options
# note: Each variable initialized corresponds to a -var=value commandline option
&init_var(*skip_start, &FALSE);	# line matching start region not output
&init_var(*include_start, ! $skip_start); # whether to output first line in region
&init_var(*include_end, &FALSE);  # whether to output last line in region
&init_var(*ext, "");		# file extension with '.'
&init_var(*file_pattern, "");	# regex for determining file name from start text
my($use_file_pattern) = ($file_pattern ne "");
&init_var(*file_base, 		# basename prefix for subfile
    ($use_file_pattern ? "" : "split"));
&init_var(*header, "");		# additional text added at start
&init_var(*trailer, "");	# additional text added at end
&init_var(*start_num, 1);		# starting value for filename

# Make sure the optional file pattern has placeholder parentheses
# TODO: use more flexible pattern as in count_it.perl
if ($use_file_pattern && ($file_pattern !~ /\(/)) {
    $file_pattern = "(" . $file_pattern . ")";
}

# Set defaults
my($start) = "";
my($end) = "^\\s*\$";
if (($header ne "") && ($header !~ /\n/)) {
    $header .= "\n";
}
if (($trailer ne "") && ($trailer !~ /\n/)) {
    $trailer .= "\n";
}

if (defined($ARGV[0])) {
    $start = shift @ARGV;
}
if (defined($ARGV[0])) {
    $end = shift @ARGV;
}

&debug_print(&TL_DETAILED, "Start pattern (inclusive=$include_start): /${start}/\n");
&debug_print(&TL_DETAILED, "End pattern (inclusive=$include_end) : /${end}/\n");
&debug_print(&TL_DETAILED, "File pattern: $file_pattern\n");

my($next_num) = $start_num;

# Process each line of the input stream 
my($include) = $FALSE;
while (<>) {
    &dump_line();
    my($at_start) = &FALSE;
    my($at_end) = &FALSE;

    # check for start of inclusion region
    if (/$start/
	&& (($include == $FALSE) || ($start eq $end))) {
	&debug_print(&TL_DETAILED, "start of inclusion region at line $.\n");
	$at_start = &TRUE;
	my($file) = "${file_base}${next_num}$ext";
	if ($use_file_pattern) {
	    if ((/$file_pattern/) && defined($1)) {
		$file = "${file_base}$1$ext";
	    }
	    else {
		&warning("Unable to determine file name from pattern at line $.: $_\n");
	    }
	}
	&debug_print(&TL_DETAILED, "opening $file\n");
	open(OUTPUT, ">$file")
	    or &exit("Unable to create file $file: $!\n");
	$next_num++;

	print OUTPUT $header if ($header ne "");
	print OUTPUT $_ if ($include_start);
	$include = $TRUE;
    }

    # check for end of inclusion region
    if (($include == $TRUE) && /$end/) {
	&debug_print(&TL_DETAILED, "end of inclusion region at line $.\n");
	$at_end = &TRUE;
	print OUTPUT $_ if ($include_end && (! $at_start));
	print OUTPUT $trailer if ($trailer ne "");
	close(OUTPUT);
        $include = $FALSE;
    }

    # print the text if within the inclusion region
    if ($include && (! $at_start) && (! $at_end)) {
	&debug_print(&TL_VERBOSE, "including line\n");
	print OUTPUT $_;
    }

    # otherwise ignore the text
    else {
	&debug_print(&TL_VERBOSE, "ignoring line\n");
    }
}
printf "Split %d subfiles\n", ($next_num - 1);

# Cleanup
if ($include) {
    print OUTPUT $trailer if ($trailer ne "");
    close(OUTPUT);
}

&exit();
