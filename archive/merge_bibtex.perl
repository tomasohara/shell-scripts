# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# merge_bibtex.perl: merges bibtex files, accounting properly for cross references
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

# Show a usage statement if no arguments given
# NOTE: By convention - is used when no arguments are required
if (!defined($ARGV[0])) {
    my($options) = "main options = []";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "examples:\n\n$script_name example\n\n";  # TODO: example
    ## $example .= "$0 example2\n\n";		   	     # TODO: 2nd example
    my($note) = "";
    ## $note .= "notes:\n\nSome usage note.\n";		     # TODO: usage note

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n$note";
}

# Check the command-line options
# note: Each variable initialized corresponds to a -var=value commandline option
## &init_var(*fu, &FALSE);		# TODO: add command-line options

my(%entry);
my(%cross_referenced);

# Set paragraph input mode
# TODO: check for violations of paragraph mode
$/ = "";

while (<>) {
    &dump_line();
    chomp;

    # Extract the next bibliograhy record
    if (/^@\S+\{(\S+),/) {
	my($key) = $1;
	my($record) = $_;
	$entry{$key} = "" if (!defined($entry{$key}));

	# Append the record to the entry unless the same
	$key = &trim($key);
	$record = &trim($record);
	if ($entry{$key} ne "$record\n\n") {
	    &debug_out(&TL_VERBOSE, "adding entry for $key\n");
	    $entry{$key} .= $record . "\n\n";
	}
	else {
	    &debug_out(&TL_VERBOSE, "ignoring duplicate entry for $key\n");
	}

	# Check for cross references
	while ($record =~ /crossref\s*=\S*{(\S+)}/) {
	    $cross_referenced{$1} = &TRUE;
	    $record = $';
	}
    }
    else {
	&debug_out(&TL_VERBOSE, "ignoring line $_\n")
    }
}

# Sort the entries alphabetically, printing cross-references items last
foreach my $key (sort(keys(%entry))) {
    my($record) = $entry{$key};
    print "$record\n\n\n" unless (defined($cross_referenced{$key}));
}
foreach my $key (sort(keys(%entry))) {
    my($record) = $entry{$key};
    print "$record\n\n\n" unless (!defined($cross_referenced{$key}));
}

&exit();
