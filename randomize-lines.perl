# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# randomize-lines.perl: randomize the contents of a file line-by-line
#
# NOTES:
# - For testing purposes,
#      perl -e  'print "1\n2\n3\n4\n5\n";' | randomize-lines.perl -

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

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
$num_lines = scalar @file;
&debug_print(&TL_VERY_VERBOSE, "file={@file}\n");

# Optionally, seed the random number generator
# NOTE: Perl's rand() function will call srand implicitly unless srand called.
if ($seed != 0) {
    &debug_print(&TL_DETAILED, "Initializing random seed with $seed\n");
    srand($seed);
}

# Randomly print lines one at a time
for (my $i = 0; $i <= $#file; $i++) {
    # Randomly select next line from file and print it
    my $pos = (rand() * $num_lines);
    while (!defined($file[$pos])) {
	$pos = rand() * $num_lines;
    }
    print "$file[$pos]";

    # Make the line as used
    $file[$pos] = undef;
}

&exit();

