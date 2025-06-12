# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# compare_similarity.perl: using the LSI data for the text, compute a sliding
# window comparison of the N sentences before and after each sentence to see
# whether the current one might be a segment break
#
# TODO: sort -n -t= +1 sim.log | less
#
# TODO: script for producing graph use in evaluating segmentation
#	grep -v '^$' w9_test.text | cat -n >! w9_test.list
#       grep '<>' w9_test.list | cut -f1 | perl -pn -e 's/$/\t1/;' > article.data
#	sed -e "s/.*=//" sim.log > ! sim.data
#	gnuplot
#	> set output "sim.ps"
#	> set termninal postscript
#	> plot "segment.data" with impulses, "sim.data" with lines
#	> exit
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

&init_var(*window, 10);
&init_var(*include_right, &TRUE);

# Determine the number of documents from the RUN_SUMMARY file
if (!defined($num_docs) && (-e "RUN_SUMMARY")) {
    $doc_info = &run_command("grep NDOCS RUN_SUMMARY");
    if ($doc_info =~ /NDOCS="(\d+)"/) {
	$num_docs = $1;
    }
}
$num_docs = 100 unless defined($num_docs);

# Print comment header
$left_window = $include_right ? int(($window+1)/2) : $window;
$right_window = $window - $left_window;
printf "# num_docs=$num_docs; left_window=$left_window right_window=$right_window\n";
printf "# doc#:\tmean_sim\n";

# Calculate and print the average pairwise similarity over a window
# of k sentences for each of the sentences
#
for ($i = 1; $i <= $num_docs; $i++) {
    $start = &max($i - $left_window, 1);
    $end = &min($i + $right_window, $num_docs);

    # Determine the mean similarity between adjoining sentences
    $total_sim = 0.0;
    for ($j = $start, $num = 0; $j < $end; $j++, $num++) {
	$k = $j + 1;

	# Compute the cosine of the vectors for document j vs j+1
	$result = &run_command("syn -S -d $j -S -d $k\n");
	($doc1, $doc2, $sim) = split(/\s+/, $result);
	$total_sim += $sim;
	&debug_out(4, "$doc1 vs. $doc2: $sim\n");
    }
    $mean_sim = ($num > 0) ? $total_sim / $num  : 0.0;
    ## printf "doc$i: mean_sim=%.4f\n", $mean_sim;
    printf "$i\t%.4f\n", $mean_sim;
}

#------------------------------------------------------------------------------

sub old_min {
    local ($x, $y) = @_;

    return ($x < $y ? $x : $y);
}


sub old_max {
    local ($x, $y) = @_;

    return ($x > $y ? $x : $y);
}
