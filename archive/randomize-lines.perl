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
BEGIN { 
    my $dir = $0; $dir =~ s/[^\\\/]*$//; unshift(@INC, $dir);
    require 'common.perl';
    use vars qw/$help $para/;
}

# Show a usage statement if no arguments given
# NOTE: By convention - is used when no arguments are required
if (!defined($ARGV[0])) {
    my($options) = "main options = [-seed=real] [-timeseed]";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "examples:\n\n$script_name README.txt\n\n";
    $example .= "ls -alR / > $0 -para - > _random-ls-alR.log\n\n";
    my($note) = "";
    $note .= "notes:\n\n- Use -para for paragraph input mode.\n";
    #note .= - The input is read in memory; use mezcla's randomize_lines.py for memory-efficient version.\n";

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

