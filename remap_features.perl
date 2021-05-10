# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# remap.perl: Converts back from the encoded feature values to the orginal
# values. This uses the MAPPING file created using number.prl.
#
# Example input:
#
#   [SAMPLE.MAPPING]
#   0               9 1
#   1               0 1
#   2               0 1
#   3               1 1
#   4               0 1
#   5               1 1
#   ...
#   10               1 1
#   11              DT 1
#   12              IN 1
#   13              IN 1
#   14              NN 1
#   0               4 2
#   3               0 2
#   9               0 2
#   ...
#
#   [SAMPLE0.JOINT]:
#   0 9
#   0:1 1 1 1 1 2 1 1 1 2 2 7 12 3 8 
#   0:2 1 1 1 1 2 1 1 1 2 2 7 12 3 8 
#   0.792676571963711:3 1 1 1 1 2 1 1 1 2 2 7 12 3 8 
#   0:4 1 1 1 1 2 1 1 1 2 2 7 12 3 8 
#   0.207323428036289:5 1 1 1 1 2 1 1 1 2 2 7 12 3 8 
#   0:1 1 1 1 1 2 1 1 1 2 2 8 5 2 6 
#   ...
#   
# Example output:
#   0 9
#   0:9 0 0 1 0 0 1 0 0 0 0 PO RB NN IN
#   0:4 0 0 1 0 0 1 0 0 0 0 PO RB NN IN
#   0.792676571963711:5 0 0 1 0 0 1 0 0 0 0 PO RB NN IN
#   0:3 0 0 1 0 0 1 0 0 0 0 PO RB NN IN
#   0.207323428036289:2 0 0 1 0 0 1 0 0 0 0 PO RB NN IN
#   0:1 0 0 1 0 0 1 0 0 0 0 PO RB NN IN

#
# TODO: convert this to a subroutine that other scripts can use
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

if (!defined($ARGV[0])) {
    $options = "options = n/a";
    $example = "ex: $script_name SAMPLE.MAPPING ':.*' < SAMPLE0.JOINT\n";
    $note = "note:\n\nDefault feature pattern is \":?[^:]*\$\".\n";

    die "\nusage: $script_name [options] mapfile [feature_pattern] < file \n\n$options\n\n$example\n\n$note\n";
}
$mapping = shift @ARGV;
$feature_pattern = shift @ARGV;
if (!defined($feature_pattern)) {
    $feature_pattern = ":?[^:]*\$";
}
&debug_out(4, "mapping=$mapping feature_pattern=$feature_pattern\n");


# Load mapping data into an array
#
$max_col = 0;
open(MAPPING,"$mapping") 
    || die "Can't open MAPPING file '$mapping' ($!)\n";
while (<MAPPING>) {
    ($col,$old,$new) = split(/\s+/,$_);
    ## $map_array{$col,$new} = $old;
    &set_entry(*map_array, "$col:$new", $old);
    $max_col = &max($col, $max_col);
}
close(MAPPING);
$num_cols = (1 + $max_col);

# Revert the input features to their unencoded values
#
while (<>) {
    &dump_line();
    chop;

    # Convert the feature specification to the original values
    if (/$feature_pattern/) {
	$pre = $`; $post = $'; $features = $&;
	$new_features = "";

	for ($col = 0; ($features =~ /(\d+|_)/); $col++) {
	    $new_features .= $`; $new = $1; $features = $';
	    $new_features .= &get_entry(*map_array, "$col:$new", $new);
	}

	# Require that all columns gets mapped
	if ($col == $num_cols) {
	    $_ = $pre . $new_features . $post;
	}
    }

    print "$_\n";
}
