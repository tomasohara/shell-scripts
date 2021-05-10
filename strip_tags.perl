# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# strip_tags.perl: strips SGML tags from a file. Optionally the WSJ header
# section is removed.
#
# TODO:
# - add usage

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = $0; $dir =~ s/[^\\\/]*$//; unshift(@INC, $dir);
    require 'common.perl';
    ## TODO: use vars qw/$verbose $TEMP/;
}
## use English;				# for $PREMATCH, etc.

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
use vars qw/$WSJ $drop_at_lines $end_tag_newline $strip/;

# Show a usage statement if no arguments given.
# NOTE: By convention '-' is used when no arguments are required.
if (!defined($ARGV[0])) {
    my($options) = "main options = [-WSJ] [-drop_at_lines] [-strip] [-end_tag_newline]";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "Example(s):\n\n$script_name example\n\n";  # TODO: example
    ## $example .= "$0 example2\n\n";		   	     # TODO: 2nd example
    my($note) = "";
    ## $note .= "Notes:\n\nSome usage note.\n\n";	     # TODO: usage note

    print STDERR "\nUsage: $script_name [options]\n\n$options\n\n$example\n$note";
    &exit();
}

# Check the command-line options
# note: Each variable initialized corresponds to a -var=value commandline option
&init_var(*WSJ, &TRUE);
&init_var(*drop_at_lines, &TRUE);
&init_var(*end_tag_newline, &FALSE);
&init_var(*strip, ! $end_tag_newline);

# process each line of the input stream
while (<>) {
    &dump_line();
    chop;

    # Remove WSJ-specific tags plus the associated text. Example:
    #   <DOCNO>  891101-0166. </DOCNO>
    #   <DD> = 891101 </DD>
    #   <AN> 891101-0166. </AN>
    #   <HL> Correction </HL>
    #   <DD> 11/01/89 </DD>
    #   <SO> WALL STREET JOURNAL (J) </SO>
    #
    if ($WSJ) {
	s/<(DOCNO|DD|AN|HL|SO|CO|DATELINE)>[^<>]+<\/\1>//;
	s/^ *<HL>[^<>]+//;
	# Remove the miscellaneous on lines starting with a @
	#	@  By Matt Moffett
	#	@  Staff Reporter of The Wall Street Journal
	s/^(<s> )?@.*// if ($drop_at_lines);
    }

    # Remove SGML tags
    if ($end_tag_newline) {
	s/<\/[^>]+>/\n/g;
    }
    s/<[^>]+>//g;

    # Collapse multiple spaces, and remove leading space
    if ($strip) {
	s/\s\s+/ /;
	s/^\s+//;
	next if ($_ =~ /^\s*$/);
    }

    # Print the line (n.b. only if non-empty when stripping spaces)
    print "$_\n";
}
