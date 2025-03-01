# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# sort-by-time.perl: sorts input by a time-stamp field
#
# Sample input:
#
# Tue Oct 14 14:38:24 MST 2003	adding debugging support to emacs
# Wed Oct 2 03:14:46 MDT 2002	looking into UT Pan American
# Wed Aug 27 00:33:23 MST 2003	graph theory seminar
#
# Sample output:
#
# Wed Oct 2 03:14:46 MDT 2002	looking into UT Pan American
# Wed Aug 27 00:33:23 MST 2003	graph theory seminar
# Tue Oct 14 14:38:24 MST 2003	adding debugging support to emacs
#
# Sample output:
# TODO:
# - add support for non-tab-delimited input
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir);
    require 'common.perl';
    require 'extra.perl';
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
use vars qw/$f/;

# Show a usage statement if no arguments given
# NOTE: By convention - is used when no arguments are required
if (!defined($ARGV[0])) {
    my($options) = "main options = []";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "examples:\n\n$script_name *time_tracking*.text \n\n";
    ## $example .= "$0 example2\n\n";		   	     # TODO: 2nd example
    my($note) = "";
    ## $note .= "notes:\n\nSome usage note.\n";		     # TODO: usage note

    print STDERR "\nusage: $script_name [options]\n\n$options\n\n$example\n$note";
    &exit();
}

# Check the command-line options
# note: Each variable initialized corresponds to a -var=value commandline option
&init_var(*f, 1);		# sort field
$f -= 1;
&assert($f >= 0);

# Read in all the input at once, and verify that timestamp occurs
my(@input) = <>;
map { &assert(&check_timestamp($_)); } @input;

# Print the lines sorted by timestamp
map { print; } (sort by_time @input);

&exit();


#------------------------------------------------------------------------------

# check_timestamp(line): verify that a timestamp occurs in the sort field
#
# NOTE: Although this duplicates some of the code in by_time, the checks here
# only need to be done once not up to n times (worst case sort scenario).
#
# EX: $f = 1; check_timestamp("testing ssh 	Wed Oct 2 08:11:32 MDT 2002") => 1
# EX: $f = 0; check_timestamp("testing ssh 	Wed Oct 2 08:11:32 MDT 2002") => 0
#
sub check_timestamp {
    my($line) = @_;
    &debug_print(&TL_VERBOSE, "check_timestamp(@_): f=$f\n");
    my($timestamp_OK) = &TRUE;

    # Get the timestamp specification from the input
    my(@fields) = split(/\t/, $line);
&trace_array(\@fields);
    &assert($f <= $#fields);
    my($time_spec) = defined($fields[$f]) ? $fields[$f] : "";
    $timestamp_OK = ($time_spec ne "");

    # Make sure it converts into a valid timestamp value
    my($timestamp) = &derive_time_stamp($time_spec);
    $timestamp_OK = ($timestamp > 0);

    return ($timestamp_OK);
}
# by_time(): sort routine for sorting two lines by the timestamp at a 
# given field ($f)
# NOTE: the field specifier $f is an offset (i.e., 0-based)
#
# EX: $f = 0; $a = "Wed Oct 2 03:14:46 MDT 2002	looking into UT Pan American"; $b = "Wed Aug 27 00:33:23 MST 2003	graph theory seminar"; by_time() => -1
# EX: $f = 1; $a = "just do it	Fri Oct 17 00:02:20 MST 2003"; $b = "think twice	Fri Oct 17 00:02:20 MST 2003"; by_time() => 0
#
our($a, $b);
#
sub by_time {
    my(@a_fields) = split(/\t/, $a);
    my(@b_fields) = split(/\t/, $b);
    my($a_time) = defined($a_fields[$f]) ? $a_fields[$f] : 0;
    my($b_time) = defined($b_fields[$f]) ? $b_fields[$f] : 0;

    my($cmp) = (&derive_time_stamp($a_time) <=> &derive_time_stamp($b_time));
    &debug_print(&TL_VERY_VERBOSE, "by_time(@_): a=$a b=$b; cmp=$cmp\n");

    return ($cmp);
}
