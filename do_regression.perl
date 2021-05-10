# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# do_regression.perl: perl multiple linear regression on the data specified
# in the input
#
# NOTE: This takes the spreadsheet input and assumes the first column
# gives the dependent variable.
#
# sample input:
#
#   "Corr"	"hier"	"sibl"	"text"	"sim"	"child"
#      1	0.429	0.000	0.000	0.478	0.000
#      0	0.105	0.071	0.000	0.205	0.000
#      0	0.118	0.000	0.000	0.327	0.000
#
# sample output:
#
#   Least Squares Estimates:
#  
#   Constant                 -0.224638      (4.358155E-2)
#   hier                      0.815188      (0.133785)
#   sibl                      0.236897      (6.866449E-2)
#   text                      0.975726      (0.175970)
#   sim                       0.332944      (7.712287E-2)
#   child                     0.604833      (0.178927)
#  
#   R Squared:                0.409457    
#   Sigma hat:                0.339256    
#   Number of cases:               341
#   Degrees of freedom:            335
#
# TODO: shown command line for processing above
#
# TODO:
# - Revise sample output to include "Correlation" evaluated after xlisp.
# - Show legend on interpretation tips (e.g., ranges for good correlations).
# - Echo prompt with plot-points filled out (e.g., 'To see scatterplot, issue: (plot-points data1 data2 :variable-labels (list "label1" "label2"))').
# - Have option for label value to replace n/a.
# 

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

if (!defined($ARGV[0])) {
    $options = "options = [-exclusion_list=\"list\"|-inclusion_list=\"list\"] [-row_labels] [-no_col_labels] [-fix]";
    $example = "examples:\n\n$script_name ok_entropy.list\n\n";
    $example .= "$script_name -row_labels -exclusion_list=\"3\" test/resnik_sim.data\n\n";
    $example .= "$script_name -exclusion_list=\"1 2 5\" test/resnik_typicality.data\n\n";
    $notes = "NOTE: The positions are 1-based (i.e., first column = 1)\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n$notes\n";
}

&init_var(*exclusion_list, "");
&init_var(*inclusion_list, "");
&init_var(*order, "");
&init_var(*no_col_labels, &FALSE);
&init_var(*row_labels, &FALSE);		# ignore first column of each row
&init_var(*fix, &FALSE);
&init_var(*interactive, &FALSE);
&init_var(*quiet, &FALSE);		# only display result
local(@order) = &tokenize($order);

local(@data_list, @include);
local(@labels, $first_col);
$first_col = -1;

# Extract the values for the vectors
local($temp_file) = &make_path(&TEMP_DIR, "temp_regression_$$.lisp");
open(REGRESSION, ">$temp_file");

READ_LINE:
while (<>) {
    &dump_line();
    chop;

    # Skip comments (either semicolons or pound signs)
    next if (/^\s*[\#\;]/);

    # Optionally, convert spaces to tabs
    s/ +/\t/g if ($fix);

    # If labels undefined, use first row for them
    if ($#labels < 0) {
	&assign_labels_etc($_);
	next unless $no_col_labels;
    }

    # split the data values by column
    local(@data) = split(/\t/, $_);
    
    &trace_array(*data, 6);
    if ($row_labels) {
	local($case_label) = shift @data;
	&reference_var($case_label);
    }
    &assert('$#data = $#data_list');

    # Reorder the columns if desired (the positions are 1-based as in cut)
    if ($order ne "") {
	&reorder(*data, *order);
    }

    # See if the entry should be ignored
    for ($i = $first_col; $i <= $#data; $i++) {
	if ($include[$i] && ($data[$i] eq "-")) {
	    &debug_print(4, "ignoring entry due to -'s: \"$_\"\n");
	    next READ_LINE;
	}
    }

    # Update the vectors
    for ($i = 0; $i <= $#data_list; $i++) {
	local($datum) = &make_numeric($data[$i], $i);
	$data_list[$i] .= "$datum ";
    }
}

die "ERROR: Insufficient data\n" if ($#data_list < 0);

# Print the array declarations
$correct_list = &trim($correct_list);
print REGRESSION "(def col_$labels[$first_col] (list $data_list[$first_col]))\n\n";
print REGRESSION "(def data\n";
print REGRESSION "\t(list\n" if ($num_included > 2);
local($y_label) = $labels[$first_col];
local($x_label) = "";
for ($i = $first_col + 1; $i <= $#data_list; $i++) {
    if ($include[$i]) {
	local($scores) = &trim($data_list[$i]);
	print REGRESSION "\t(list $scores)\n";
	$x_label = $labels[$i] unless ($x_label ne "");
    }
}
print REGRESSION "\t)\n" if ($num_included > 2);
print REGRESSION "\t)\n";

# Print the regression command
print REGRESSION "(setq RM (regression-model data col_$labels[$first_col]))\n";
if ($interactive && (&DEBUG_LEVEL > 4) && ($num_included == 2)) {
    print REGRESSION "(send RM :plot-residuals)\n";
    printf REGRESSION "(plot-points data %s :title \"%s vs. %s\")\n", 
           $y_label, $y_label, $x_label;
}
print REGRESSION "(exit)\n" unless ($interactive);
close(REGRESSION);
&debug_out(4, "%s: {\n%s\n}\n", $temp_file, &read_file($temp_file));

# Run xlispstat to do the regression
# TODO: streamline $interactive tests
local($redir) = $interactive ? "" : "<";
local($batch) = $interactive ? "" : "-b";
my($non_x) = $interactive ? "" : "--non-X";
&debug_print(6, "[$temp_file]\n%s\n", 
	   &read_file("$temp_file"));
die "need at least two variables for regression!\n" if ($num_included < 2);
$ENV{"USE_XLISP_EXTS"} = 1 unless (defined($ENV{"USE_XLISP_EXTS"}));
&debug_print(&TL_DETAILED, "Issuing: xlispstat.sh $batch $non_x $redir $temp_file\n");
if ($interactive) {
    &cmd("xlispstat.sh $batch $non_x $redir $temp_file");
    $result = "";
}
else {
    $result = &run_command("xlispstat.sh $batch $non_x $redir $temp_file");
}

# Remove miscellaneous output (e.g., xlispstat logo)
$result =~ s/[^\000]+Copyright.*\n//; 	# drop xlisp banner
$result =~ s/\n>.*\n?/\n/g;		# drop command traces
$result =~ s/\n>.*\n?/\n/g;		# drop command traces (redux)
$result =~ s/\n\#<.*\n//g;		# drop object dumps
$result =~ s/; loading .*\n//g;		# drop lisp module load traces
$result =~ s/\n((T)|(NIL))\n/\n/g;	# drop misc lisp results
$result =~ s/\n\s*\n\s*\n/\n\n/g; 	# collapse multiple blank lines
$result =~ s/Least Squares Estimates:/Least Squares Estimates (vs. $labels[$first_col]):/;

# Convert from "Variable 0", etc. to the correct label
for ($i = ($first_col + 1), $v = 0; $i <= $#labels; $i++) {
    if ($include[$i]) {
	$labels[$i] =~ s/\"//g;
	local($extra) = length("Variable 0") - length($labels[$i]);
	local($label) = $labels[$i] . (" " x $extra);
	$result =~ s/Variable $v/$label/;
	$v++;
    }
}

# Display the regression result
print "$result\n" unless ($quiet);

# Display the correlation
if ($result =~ /R Squared:\s*(.*)\n/) {
    local($r_squared) = $1;
    local($correlation) = sqrt($r_squared);

    printf "%-25s %.6f\n", "Correlation ($x_label vs. $y_label):", $correlation;
}
printf "\n" unless ($quiet);

# Cleanup things
unlink $temp_file unless (&DEBUG_LEVEL > 4);

#------------------------------------------------------------------------

# reoder(array, ordering)
#
# Reorders the elements of the array according to the 1-based positions
# given in the order array.
#
sub reorder {
    local(*array, *order) = @_;
    &debug_print(7, "reorder(@_)\n");

    &assert('$#array == $#order');
    local(@new_array, $i);
    for ($i = 0; $i <= $#array; $i++) {
	$new_array[$i] = $array[$order[$i] - 1];
    }
    &trace_array(*new_array, 6);
    @array = @new_array;

    return;
}


# assign_labels_etc(text)
#
# Assign labels based on the text. If no labels are included, then the
# text is used only to determine the number of columns.
#
sub assign_labels_etc {
    local($text) = @_;
    &debug_print(4, "assign_labels_etc(@_)\n");

    # Don't reinitialize if already set
    if ($#labels >= 0) {
	return;
    }

    # Break the text into columns
    $text =~ s/\"//g;
    $text =~ s/ /_/g;
    $text =~ s/\s+/\t/g if ($fix);
    @labels = split(/\t/, $text);
    &trace_array(*labels, 5);
    &trace_array(*order, 5);

    # If no labels are provided, then use generic label names (col1 col2, ...)
    if ($no_col_labels) {
	local($i);
	for ($i = 0; $i <= $#labels; $i++) {
	    $labels[$i] = sprintf "col%d", (1 + $i);
	}
    }

    # Reoder the labels if desired
    if ($order ne "") {
	&reorder(*labels, *order);
    }

    # Allocate space for the other column-specific arrays 
    $NUM_COLS = (1 + $#labels);
    if ($row_labels) {
	shift @labels;
	$NUM_COLS--;
    }
    $correct_list = "";
    @data_list  = ("") x $NUM_COLS;

    # Determine the columns to be included
    # TODO: try to unify the code for inclusion vs. exclusion
    if ($inclusion_list ne "") {
	&assert('$exclusion_list eq ""');
	$first_col = 0;
	@include = (&FALSE) x $NUM_COLS;
	$num_included = 0;
	foreach $pos (&tokenize($inclusion_list)) {
	    if ($row_labels) {
		$pos--;		# the position reflects column before shift
	    }
	    $include[$pos - 1] = &TRUE unless ($pos < 0);
	    if ($first_col == 0) {
		$first_col = $pos - 1;
	    }
	    $num_included++;
	}
    }
    else {
	$first_col = 0;
	@include = (&TRUE) x $NUM_COLS;
	$num_included = $NUM_COLS;
	foreach $pos (&tokenize($exclusion_list)) {
	    if ($row_labels) {
		$pos--;		# the position reflects column before shift
	    }
	    $include[$pos - 1] = &FALSE unless ($pos < 0);
	    if ($first_col == ($pos - 1)) {
		$first_col = $pos;
	    }
	    $num_included--;
	}
    }
    &trace_array(*include, 5);
    &debug_print(5, "num_included=$num_included; first_col=$first_col\n");
    &assert('$first_col >= 0');
    &assert('$first_col < $#data_list');

    return;
}


# make_numeric(value, column)
#
# If the value is numeric, return it as is. Otherwise, return the enumerated
# code for it among the column's values.
#
# NOTE: Maintains two global assoc. arrays: %column_num_values & %column_value
#
sub make_numeric {
    local($value, $col) = @_;
    local($number) = $value;

    # Assign an enumerated code only if non-numeric
    if (&is_numeric($value) == &FALSE) {
	# See if a code already had been assigned
	$number = &get_entry(*column_value, "$col:$value", -1);
	if ($number == -1) {
	    # Assign a new code for the value
	    &incr_entry(*column_num_values, $col);
	    $number = &get_entry(*column_num_values, $col) - 1;
	    &set_entry(*column_value, "$col:$value", $number);
	}
    }
    &debug_print(6, "make_numeric(@_) => $number\n");

    return ($number);
}
