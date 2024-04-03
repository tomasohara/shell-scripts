# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# chordie-to-chord.perl: extracts chord specification from Chordie HTML file
# for a song.
#
# Sample input:
#
#    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" 
#       "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
#    <html xmlns="http://www.w3.org/1999/xhtml" lang="en-US" xml:lang="en-US">
#    <head>
#    	<title>Beechwood Park by Zombies - guitar chords, guitar tabs and lyrics - chordie</title>
#    ...
#		<form id="chopro" method="post" action="/chopro.php">
#			<input type="hidden" name="printsong" value="{t:Beechwood Park}
#    {st:Zombies}
#    ...
#    {eot}
#    About your world   Your summer world
#    And [Gm]we would count the [F]evening stars
#    [Eb7]As the day grew [D7+9]dark
#    In Beechwood [Gm]Park [F]    [Eb7]      [D7+9]     
#    #
#    ">
#
# Sample output:
#    TODO
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = $0; $dir =~ s/[^\\\/]*$//; unshift(@INC, $dir);
    require 'common.perl';
    ## TODO: use vars qw/$verbose/;
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
use vars qw/$min_chopro_lines $min_verse_lines/;

# Show a usage statement if no arguments given.
# NOTE: By convention '-' is used when no arguments are required.
if (!defined($ARGV[0])) {
    my($options) = "main options = [-min_chopro_lines=N] [-min_verse_lines=N]";
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
&init_var(*min_chopro_lines, 4);	# minimum chorpro HTML lines to avoid warning
&init_var(*min_verse_lines, 2);		# minimum verse lines to avoid warning
#
my($in_chopro) = &FALSE;
my($chord_text) = "";
my($num_chopro_lines) = 0;
my($num_verse_lines) = 0;

while (<>) {
    &dump_line();
    chomp;

    # Check for start of chopro section
    # ex: ""
    if (/<form id=\"chopro\"/) {
	$in_chopro = &TRUE;
	&debug_print(&TL_DETAILED, "start of chopro section\n");
    }
    #
    # Check for end of chopro section
    elsif ($in_chopro && /^\s*\"\s*>/) {
	$in_chopro = &FALSE;
	&debug_print(&TL_DETAILED, "end of chopro section\n");
    }

    # Collect the chopro lines
    if ($in_chopro) {
	$num_chopro_lines++;

	# Remove comments, etc.
	s/^\s*\<.*//;		# ex: "<input type"
	s/^\s*[\*\#].*//;	# exs: "**submitted by Hirsch Freeman******", "#THE ZOMBIES"
	s/^\s*{\S+}\s*$//; 	# exs: "{sot}", "{eot}"

	# Add to text
	if ($_ ne "") {
	    $num_verse_lines++;
	    $chord_text .= "$_\n";
	}
    }
}

# Perform sanity checks
&debug_print(&TL_USUAL, "Found $num_chopro_lines chopro lines and $num_verse_lines verse lines\n");
if ($num_chopro_lines < $min_chopro_lines) {
    &warning("Only $num_chopro_lines chopro lines found!\n");
}
elsif ($num_verse_lines < $min_verse_lines) {
    &warning("Only $num_verse_lines verse lines found!\n");
}

# Print chopro version
# TODO: remove comments and other exraneous info from chord listing
print "$chord_text\n";

# The end
&exit();
