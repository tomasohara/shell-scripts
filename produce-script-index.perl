# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# produce-script-index.perl: produce an index of scripts suitable for incorporation into a HTML directory listing
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir);
    require 'common.perl';
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
## use vars qw/$fu $bar/;

# Show a usage statement if no arguments given
# NOTE: By convention - is used when no arguments are required
if (!defined($ARGV[0])) {
    my($options) = "main options = []";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "examples:\n\n$script_name  ascii2network.perl\n\n";
    ## $example .= "$0 example2\n\n";		   	     # TODO: 2nd example
    my($note) = "";
    ## $note .= "notes:\n\nSome usage note.\n";		     # TODO: usage note

    print STDERR "\nusage: $script_name [options]\n\n$options\n\n$example\n$note";
    &exit();
}

# Check the command-line options
# note: Each variable initialized corresponds to a -var=value commandline option
## &init_var(*fu, &FALSE);		# TODO: add command-line options

# Scan through each file and extract HTML index entry
foreach my $filename (@ARGV) {
    my($comment_char) = "#";
    if ($filename =~ /\.lisp$/) {
	$comment_char = ";";
    }

    # Read entire contents prefixed by newline to simplify pattern matching
    my($data) = "\n" . &read_file($filename);
    &dump_data("original", $data);

    # Strip out script code, leaving just comments
    $data =~ s/\n[ \t]*[^$comment_char][^\n]+/\n/g;
    &dump_data("w/o code", $data);

    # Strip out any DOS-style CR's
    $data =~ s/\r//g;
    &dump_data("w/o CR's", $data);

    # Remove leading comment characters
    $data =~ s/\n[ \t]*$comment_char+[ \t]*/\n/g;
    &dump_data("w/o comment chars", $data);

    # Separate comment blocks (e.g., paragraphs) by CR's
    $data =~ s/\n[ \t]*\n/\r/g;
    &dump_data("separated into blocks by CRs", $data);

    # Find first comment block mentioning filename
    my($description) = "???";
    foreach my $block (split(/\r/, $data)) {
	if ($block =~ /$filename/) {
	    # Use the current comment block as description removing 'filename:<SP>'
	    $description = $block;
	    $description =~ s/^\s*$filename[:]? ?//;
	    last;
	}
    }
    if ($description eq "???") {
	&warning("Unable to find description for script $filename\n");
	next;
    }

    # Only use the first sentence from description
    $description =~ s/\..*$//;
    $description =~ s/\s+/ /g;

    # Print HTML index line
    # TODO: add file statistics
    print "\t<UL><A HREF=\"$filename\">$filename</A>: $description</UL>\n";
}

&exit();


#------------------------------------------------------------------------------

# dump_data(label, text): displays text string along with length and descriptive label
#
sub dump_data {
    my($label, $data) = @_;
    &debug_out(&TL_VERBOSE, "%s: len=%d data={%s}\n\n", $label, length($data), $data);
}
