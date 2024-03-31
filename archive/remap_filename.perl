# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# remap_filename.perl: convert from Unix filename into Windows format (DOS)
#
# Example:
#	/f/cartera-de-tomas/organizer/cygwin-tkdiff.tcl:
#	=>
#	f:\cartera-de-tomas\organizer\cygwin-tkdiff.tcl:
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

# Show a usage statement if no arguments given
# NOTE: By convention - is used when no arguments are required
if (!defined($ARGV[0])) {
    my($options) = "main options = [-escape]";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "examples:\n\n$script_name /f/temp/file.list\n\n";
    ## $example .= "$0 example2\n\n";		   	     # TODO: 2nd example
    my($note) = "";
    ## $note .= "notes:\n\nSome usage note.\n";		     # TODO: usage note

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n$note";
}

# Check the command-line options
# note: Each variable initialized corresponds to a -var=value commandline option
&init_var(*noescape, &TRUE);		# don't escape backslashes
&init_var(*escape, ! $noescape);	# escape backslashes

my($backslash) = ($escape ? "\\\\" : "\\");

if ($ARGV[0] ne "-") {
    &issue_command("echo @ARGV | $0 -");
    &exit;
}

# Process the input record by record (eg., by lines)

while (<>) {
    &dump_line();
    chomp;

    # Convert drive directory (/f/...) to driver letter (f:/)
    # NOTE: assumes DOS drives are mounted as /c, /d, etc.
    s#^/(\w)/#$1:/#g;
    s# /(\w)/# $1:/#g;

    # Convert forward slashes (/) to backslashes (\)
    s#/#$backslash#g;

    print "$_\n";
}

&exit();
