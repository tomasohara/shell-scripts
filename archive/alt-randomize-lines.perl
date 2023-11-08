# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# alt-randomize-lines.perl: randomize the contents of a file line-by-line
#
# NOTES:
# - For testing purposes,
#      perl -e  'print "1\n2\n3\n4\n5\n";' | randomize-lines.perl -

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = $0; $dir =~ s/[^\\\/]*$//; unshift(@INC, $dir);
    require 'common.perl';
    use vars qw/$script_name/;
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
use vars qw/$timeseed $seed/;

# Show a usage statement if no arguments given
# NOTE: By convention - is used when no arguments are required
if (!defined($ARGV[0])) {
    my($options) = "main options = [-seed=real] [-timeseed]";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "examples:\n\n$script_name example\n\n";  # TODO: example
    ## $example .= "$0 example2\n\n";		   	     # TODO: 2nd example
    my($note) = "";
    ## $note .= "notes:\n\nSome usage note.\n";		     # TODO: usage note

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n$note";
}

&init_var(*timeseed, &FALSE);	# use current time for seed
&init_var(*seed, 		# random seed to use
	  ($timeseed ? time : 0));

# Read the entire file
my @file = <ARGV>;
my($num_lines) = scalar @file;
&debug_out(&TL_VERY_VERBOSE, "file={@file}\n");

# Optionally, seed the random number generator
if ($seed != 0) {
    srand($seed);
}

# Randomly swap each of the lines
# Rework in terms on N random swaps
for (my $i = 0; $i <= $#file; $i++) {
    # Randomly select another line to swap with current one
    my $pos = (rand() * $num_lines);
    my $temp_line = $file[$pos];
    $file[$pos] = $file[$i];
    $file[$i] = $temp_line;
}

# Print the new file
for (my $i = 0; $i <= $#file; $i++) {
    print "$file[$i]";
}

&exit();
