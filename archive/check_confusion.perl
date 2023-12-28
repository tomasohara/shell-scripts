# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# check_confusion.perl: check confusion of the sense
#
# sample input:
#
#   score for "generous-a_700002": 0.000
#    key   = 512277
#    guess = 512309/1.000
#   
#   score for "generous-a_700003": 1.000
#    key   = 512274 512277
#    guess = 512274/1.000
#
#   ...
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

if ((defined($ARGV[0]) && ($ARGV[0] eq "help"))
    || (!defined($ARGV[0]) && &blocking_stdin())) {
    $options = "options = n/a";
    $example = "examples:\n\n$script_name generous-a.score\n";
    $example .= "\n\$script_name -case=onion s-grling-score\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
}

local(%confusion);

&init_var(*min_freq, 1);
&init_var(*case, "");

$/ = "";			# paragraph input mode
while (<>) {
    &dump_line();
    chop;

    # Tabulate the occurrence for the sense pairs
    if (/score for (.*): (\S+)/i) {
	$instance_ID = $1; $result = $2;

	# See if only a particular case is desired
	if (($case ne "") && (index($instance_ID, $case) == -1)) {
	    &debug_out(4, "skipping instance %s\n", $instance_ID);
	    next;
	}

	($key) = ($_ =~ /key\s*=\s*(\d\d\d\d\d\d)/);
	($guess) = ($_ =~ /guess\s*=\s*(\d\d\d\d\d\d)/);
	&debug_out(4, "%s vs. %s\n", $key, $guess) if ($result == 0.000);

	&incr_entry(*senses, $key);
	&incr_entry(*senses, $guess);
	&incr_entry(*confusion, "$key:$guess");
    }

}

# See what senses were used
local(@senses) = (sort(keys(%senses)));
local($num_senses) = (1 + $#senses);
local(@col_sum) = (0) x $num_senses;
local(@row_sum) = (0) x $num_senses;
local($total_sum) = 0;

# Prune senses that don't occur frequently (just for cases w/ many senses)
if ($min_freq > 1) {
    local(@new_senses);
    for ($i = 0; $i < $num_senses; $i++) {
	if (&get_entry(*senses, $senses[$i]) >= $min_freq) {
	    push(@new_senses, $senses[$i]);
	}
    }
    @senses = @new_senses;
    $num_senses = (1 + $#senses);
}

# Print the confusion matrix
printf "\t%s\n", join("\t", @senses);
for ($i = 0; $i < $num_senses; $i++) {
    $key = $senses[$i];
    printf "%s", $key;
    for ($j = 0; $j < $num_senses; $j++) {
	$guess = $senses[$j];
	$count = &get_entry(*confusion, "$key:$guess");
	printf "\t%d", $count;
	$row_sum[$i] += $count;
	$col_sum[$j] += $count;
	$total_sum += $count;
    }
    printf "\t%d\n", $row_sum[$i];
}
for ($j = 0; $j < $num_senses; $j++) {
    printf "\t%d", $col_sum[$j];
}
printf "\t%d\n", $total_sum;

&exit();
