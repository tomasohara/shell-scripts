# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# table2xspread.perl: Convert a tab-delimited table into xspread format
#
# Sample input:
#
#
#  # from (Hays 1971), p. 828
#  #
#  # A	B
#  8	1
#  3	7
#  4	9
#  6	10
#  	12
#  #
#  # Hays, William L., and Rovert L. Winler (1971), {\em Statistics: Probability, Inference, and Decision}, New York: Holt, Rinehart and Winston.
#
# Sample output
#
#   format A:Z 10 3
#   leftstring A0 = "#   from (Hays 1971), p. 828"
#   leftstring A1 = "#"
#   leftstring A2 = "#   A"
#   leftstring B2 = "B"
#   let A3 = 8
#   let B3 = 1
#   let A4 = 3
#   let B4 = 7
#   let A5 = 4
#   let B5 = 9
#   let A6 = 6
#   let B6 = 10
#   leftstring A7 = ""
#   let B7 = 12
#   leftstring A8 = "#"
#   leftstring A9 = "#   Hays, William L., and Rovert L. Winler (1971), {\em Statistics: Probability, Inference, and Decision}, New York: Holt, Rinehart and Winston."
#   goto A0
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

if ((defined($ARGV[0]) && ($ARGV[0] eq "help"))
    || (!defined($ARGV[0]) && &blocking_stdin())) {
    $options = "options = n/a";
    $example = "ex: $script_name whatever\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
}

## &init_var(*MAX_COLS, 26);
&init_var(*col_labels, "ABCDEFGHIJKLMNOPQRSTUVWXYZ");
$max_cols = length($col_labels);
&debug_out(6, "max_cols=%d col_labels=%s\n", $max_cols, $col_labels);

# Print Xspread header
printf "# Data file generated by ${script_name}.\n";
printf "\n";
printf "format %s:%s 7 3\n", 
    substr($col_labels, 0, 1), substr($col_labels, $#col_labels, 1);

# Convert each row of table to series of assignment statements
local($row) = 0;
while (<>) {
    &dump_line();
    chop;

    local(@columns) = split(/\t/, $_);
    assert('$#columns < $max_cols');
    local($col) = 0;
    foreach $item (@columns) {
	$col_letter = substr($col_labels, $col, 1);
	$cell_label = sprintf "%s%d", $col_letter, $row;
	if ($item =~ /^\s*-?\d*\.?\d+\s*$/) {

	    printf "let %s = %s\n", $cell_label, $item;
	}
	else {
	    $item =~ s/(^\")|(\"$)//g;
	    # printf "label %s = \"%s\"\n", $cell_label, $item;
	    printf "leftstring %s = \"%s\"\n", $cell_label, $item;
	}

        $col++;
    }

    $row++;
}

# Print Xspread trailer
printf "goto A0\n";
