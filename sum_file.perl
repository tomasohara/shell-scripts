# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# sum_file.perl: script to sum the first column of numbers in a file
# The numbers are optionally treated as fractions.
#
# TODO:
# - Document all the features better.
# - Add direct support for t-test (i.e., implemented via Perl).
# - Fix problem w/ carriage returns
# - Fix problem w/ running stats over first column w/o have to use -f=1.
# - add better support for doing statistical analyses of differences
#      % sum_file.perl -diff mendenhall_table12.2.data | sum_file.perl -f1=3 -stats -
# - verify that the number of columns is the same for each row
# - add tests to ensure working as expected for given datafiles
# - add mode and percentiles to -stats option output
# - ** Add mode to -stdev option.
#
# EXAMPLEs: 
# $ sum_file.perl -f=2 /home/graphling/DATA/BNC/test-bnc-common-wordform.freq
# 88770678.000
#
# NOTE: The handling of missing values is probably unintuitive: if a dash
# is used then corresponding entries in other columns will be ignored (unless
# the column with the dash is not being anlayzed); but if the entry is empty
# then the corresponding entries in the other columns are still considered
# (blanks should only occur at the end).
# 
# TODO:
# - Support R in addition to xlispstat.
# - Add other summary statistics for use with -stdev (i.e., perl-based).
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir);
    require 'common.perl';
    use vars qw/$verbose &set_init_var_export/;
    require POSIX;
}

use strict;
use vars qw/$fract $diff $labels $headings $f $f1 $f2 $col $col1 $col2 $fix
    $ttest $paired_ttest $paired $anova $mann_whitney $each $interactive $stats
    $stdev $keep_nonnumeric $skip_nonnumeric $cumulative $average $context $flag_index_change $show_sum $dollars $commas $delim/;
use vars qw/$strip $args $append $occurrence $extended/;

# Check options for statistical tests
&init_var(*args, &FALSE);       # get data from arguments (i.,e., command line)
if ($args) {
    &set_init_var_export(&TRUE);
}
&init_var(*ttest, &FALSE);	# perform standard t-test analysis
&init_var(*paired, &FALSE); 	# alias for -paired_ttest
&init_var(*paired_ttest, $paired); # perform paired t-test analys
&init_var(*anova, &FALSE);	# perform ANOVA analysis of the data
&init_var(*mann_whitney, &FALSE); # perform mann-whitney test for independence
my($any_stat_test) = ($ttest || $paired_ttest || $anova || $mann_whitney);

# Check basic command-line options
## &init_var(*f, &FALSE);
## $do_fract = ($f == &TRUE);
&init_var(*fract, &FALSE);	# check for fractions in numbers
&init_var(*diff, &FALSE);	# produce a difference column
&init_var(*labels, &FALSE);	# labels occur in column 1
&init_var(*headings, &FALSE);	# first line provides column headings 
&init_var(*occurrence, &FALSE); # second number gives occurence count
my($needs_two_numbers) = ($any_stat_test || $occurrence);
my($f1_default) = -1;
&init_var(*f, $f1_default);	# alias for -f1
&init_var(*f1, $f);		# 0-based field position for first column
my($f2_default) = ($needs_two_numbers ? ($f1 + 1) : -1);
&init_var(*f2, $f2_default);   	# 0-based field position for second column
&init_var(*col, 		# alias for -col1
	  ($f1 > $f1_default) ? ($f1 + 1) : (1 + $labels));
&init_var(*col1, $col);		# main column of data
&init_var(*col2, 		# other column of data
	  ($f2 > $f2_default) ? ($f2 + 1) : (2 + $labels));
$f1 = ($col1 - 1) if ($f1 == $f1_default);
$f2 = ($col2 - 1) if ($f2 == $f2_default);
&init_var(*fix, &FALSE);	# fix-up column spacing (eg, tabify)
&assert($f1 > -1);
&assert($col1 == ($f1 + 1));
&assert(($col2 == ($f2 + 1)) || ($col2 == -1));
&assert($col1 > 0);
&assert(($col2 > 0) || ($col2 == -1));
&debug_print(&TL_DETAILED, "f1=$f1 f2=$f2 col1=$col1 col2=$col2\n");

# Check other options
#
# &init_var(*each, $any_stat_test);
&init_var(*each, &FALSE);	# get data from each column
&init_var(*interactive, 	# run xlispstat interactively
	  ($each && (! $any_stat_test)));
&init_var(*stats, 		# show summary statistics
	  ($each || $interactive || $any_stat_test));
#
&init_var(*stdev, &FALSE);	# show stdev for the data
&init_var(*show_sum, ! $stdev);	# show sum at end
#
&init_var(*keep_nonnumeric, &FALSE);
&init_var(*skip_nonnumeric, ! $keep_nonnumeric);
&init_var(*cumulative, &FALSE); # show cumulative sum
#
&init_var(*average, &FALSE);	# show running average
&init_var(*context, &FALSE);	# show original data as contextual comment in cumulative listing
&init_var(*flag_index_change, &FALSE);	# flag when index column changes (e.g., for indentifying boundaries for cumulative sums)
if ($flag_index_change) {
    &assert($col2 > 0);
}
&init_var(*strip, &FALSE);      # strip comma's and dollar signs
&init_var(*dollars, $strip);	# the data contain dollar signs (to be ignored)
&init_var(*commas, $strip);	# the data contain commas (to be ignored)
&init_var(*delim, "\t");        # column separator
&init_var(*append, &FALSE);     # append the difference, etc.
&init_var(*extended, &FALSE);   # include extended statistic (median, mode, percentile)

my($sum) = 0;
my($last_index) = "";
my($sum2) = 0;
my($diff_sum) = 0;
my(@data) = ();
my($total_num) = 0;

if ( !defined($ARGV[0])) {
    my($options) = "[-stats] [-col=N] [-fix] [-paired_ttest] [-anova] [-stdev] [-cumulative [-average] [-delim=S] [-verbose] [-append]";
    if ($verbose) {
	$options .= " [-fract] [-labels] [-headings] [-ttest] [-mann_whitney] [-flag_index_change]] [-context] [-dollars] [-commas] [-extended]";
    }
    my($example) = "Examples:\n\nls -s | $script_name -fix -stdev -\n\n";
    $example .= "sum_file.perl -headings -anova -f1=3 -f2=4 resnik_typicality.data\n\n";
    if ($verbose) {
	$example .= "sum_file.perl -ttest -labels -headings -f=5 -f2=6 eval_naive_bayes_4jul.report\n\n";
	$example .= "sum_file.perl -mann_whitney -fix=0 -f1=2 -f2=4 resnik_brown_object.data\n\n";
	$example .= "sum_file.perl -diff -append -col1=1 -col2=2 old-test/mendenhall_ex13.1.data\n\n";
    }

    my($note) = "Notes:\n- Use -'s for cases with no corresponding data.\n";
    $note .= "- Use empty cells in case one column has more data than another.\n";
    $note .= "- The -f values are 0-based, whereas the -col values are 1-based.\n";
    $note .= "- Use -fix if data not strictly tab-delimited (i.e., just whitespace delimited).\n";
    $note .= "- Use -verbose for more help or to show extracted data.\n";
    if ($verbose) {
	$note .= "- Use -diff to show difference of column 2 versus column 1.\n";
	$note .= "- Use -append to append the difference, etc. to line\n";
	$note .= "- Use -labels if there are row labels (case specific) and -headings for column labels (field specific).\n";
	$note .= "- Use -index to treate -col2 as index (e.g., for tracking cumulative average differences).\n";
	$note .= "  This assumes the data is sorted by the index column.\n";
	$note .= "- Use -dollars and -commas to ignore \$ and , respectively in the data.\n";
	$note .= "- Use -extended for additional statistics (e.g., median, mode and percentile).\n";
    }

    print STDERR "\nUsage: $script_name [options] [- | file ...]\n\n$options\n\n$example\n$note\n";
    &exit();
}

my(@column_data);		# entire data from input (for stat tests)
my(@headings);

# Print header for optional cumulative section
if ($cumulative) {
    print "Cumulative:\n";
    my($optional_header) = "";
    if ($average) {
	$optional_header .= "\tAVG";
    }
    if ($context) {
	$optional_header .= "\t# Input data";
    }

    print "Num\tSum${optional_header}\n";
}

# If -args specified, reformat via stdin
if ($args) {
    &debug_print(&TL_DETAILED, "Re-invoking with stdin; ARGV=(@ARGV)\n");
    my($data) = "@ARGV";
    &debug_print(&TL_VERY_DETAILED, "data: $data\n");
    $data =~ s/ +/\n/g;
    &debug_print(&TL_VERY_DETAILED, "data: $data\n");
    printf "%s\n", &run_command_over("$0 -args=0 -fix - <", $data);
    &exit();
}

# Process each line of the input stream
# Look for a number (or optionally a fraction)
#
my($count) = 0;
while (<>) {
    chomp; s/\r//;		# remove terminating CR or LF
    my($line) = $_;
    &dump_line;
    my($num1, $num2) = ("", "");

    # Skip comments (either semicolons or pound signs)
    next if (/^\s*[\#\;]/);

    # Fix up the data into columns
    # NOTE: multiple tabs are treated as one so - needed if no data
    if ($fix && / /) {
	&assert($delim eq "\t");
	s/^\s+//;
	s/\s+/\t/g;
    }
    if ($dollars) {
 	s/\$//g;
    }
    if ($commas) {
 	s/,//g;
    }

    # Use the first line as the headings if given
    if ($headings && ($#headings < 0)) {
	@headings = split(/$delim/, $_);
	next;
    }

    # Select the specified column
    my(@columns) = split(/\t/, $_);
    # HACK: make sure tables or spaces, etc. don't end up in column data
    # TODO: try to simply split process
    for (my $i = 0; $i <= $#columns; $i++) {
	$columns[$i] = "" if (! defined($columns[$i]));
	$columns[$i] =~ s/^\s+$//;
    }
    &trace_array(\@columns, &TL_VERY_DETAILED, "columns");
    if ($f1 >= 0) {
	$num1 = defined($columns[$f1]) ? $columns[$f1] : "";
	&debug_print(5, "column $col1 = '$num1'; ");
    }
    if (($f2 > -1) && ($f2 != $f1)) {
	$num2 = defined($columns[$f2]) ? $columns[$f2] : "";
	&debug_print(5, "column $col2 = '$num2'; ");
    }
    &debug_print(5, "\n");
    # TODO: get following qoute removal to work
    ## if ($num1 =~ /\"(\d+)\"/) {
    ##    $num1 = $1;
    ## }
    ## if ($num2 =~ /\"(\d+)\"/) {
    ##     $num2 = $1;
    ## }
    # HACK: just strip double quotes from number (TODO, strip single quote)
    $num1 =~ s/\"//g;
    $num2 =~ s/\"//g;
    if (($num1 eq "-") || ($num2 eq "-")) {
	&debug_print(4, "warning: ignoring entry at line $. due to -'s: $_\n");
	next;
    }
    &debug_print(&TL_VERBOSE, "num1=$num1 num2=$num2\n");
    if ($skip_nonnumeric && (! &is_numeric($num1))) {
	&debug_print(&TL_DETAILED, "skipping non-numeric '$num1' at line $.\n");
	next;
    }

    # Collect the data from each column
    if ($each || $stats) {
	my ($i);
	my ($start) = $labels ? 1 : 0;
	my ($num_columns_collected) = 0;
	for ($i = $start; $i <= $#columns; $i++) {
	    my($datum) = (&is_numeric($columns[$i]) || ($columns[$i] eq ""))
		            ? "$columns[$i] " : "\"$columns[$i]\" ";
	    $column_data[$i] .= $datum;
	    $num_columns_collected++;
	}
	&assert(! ($any_stat_test && ($num_columns_collected < 2)));
    }

    # Extract the first number
    # TODO: cut down on redundant code
    my($num) = $num1;
    if (! $fract) {
	if (&is_numeric($num)) {
	    ## OLD:
	    ## $count++;
	    ## $sum += $num1;
	    ## &debug_out(6, "num=$num1; sum=%s\n", &round($sum));
	    ## push(@data, $num);

	    # Regular count (no occurrence field)
	    if (! $occurrence) {
		$count++;
		$sum += $num1;
		&debug_out(6, "num=$num1; sum=%s\n", &round($sum));
		push(@data, $num);
	    }
	    # Factor in occurrence count
	    else {
		$count += $num2;
		$sum += ($num1 * $num2);
		&debug_out(6, "num=$num1; count=$num2 sum=%s\n", &round($sum));
		## TODO: push(@data, [$num1] x $num2;
		for (my $i = 0; $i < $num2; $i++) {
		    push(@data, $num1);
		}
	    }
	}
	else {
	    &debug_out(5, "Warning skipping non-numeric $num\n");
	}
    }
    else {
	# HACK: get remainder from columns past first 1
	&debug_out(6, "\$_ = %s\n", $_);
	$num = ""; 
	my($rem) = "";
	if ($f1 >= 0) {
	    $num = $columns[$f1];
	    $num = "" if (!defined($num));
	    $rem = ($f1 >= $#columns) ? "" :
		join(' ', $columns[($f1 + 1) .. $#columns]);
	}
	elsif (/^ *-?[0-9]+(\.[0-9]+)?/) {
	    $
	    $rem = $';	# ' (emacs color-coding hack)
	}
	&debug_out(6, "num=$num; rem=$rem; sum=%s\n", &round($sum));
	if (&is_numeric($num)) {
	    $count++;
	    $sum += $num;
	    debug_out(7, "sum=%s\n", &round($sum));
	    push(@data, $num);
	    
	    if ($rem =~ /[0-9]+(\.[0-9]+)?/) {
		$num2 = $&;
		$sum2 += $num2;
		my($result) = ($num2 eq 0) ? "err" : $num/$num2;
		## print "$num/$num2 = $result\n";
		# TODO: support -context
		printf("%g/%g = %s\n", $num, $num2, &round($result));
	    }
	    else {
		print STDERR "Error: problem extracting fraction\n";
	    }
	}
	else {
	    &debug_out(5, "Warning skipping non-numeric $num\n");
	}
    }

    # Show current sum if cumulative desired
    if ($cumulative) {
	# TODO: replace total_num with count
	$total_num = $count;
	&debug_out(5, "num=%f n=%d avg=%f\n", $num, $total_num, (1.0 * $num / $total_num));
	my($average_info) = ($average ? ("\t" . &round(1.0 * $sum / $total_num)) : "");
	my($comment) = ($context ? "\t# $line" : "");
	if ($flag_index_change) {
	    &assert($col2 != 0);
	    if ($num2 ne $last_index) {
		$comment .= "\t *** index change ***";
	    }
	    $last_index = $num2;
	}
	printf "%s\t%s%s%s\n", &round($num), &round($sum), $average_info, $comment;
    }

    # If a difference is being produced, extract second num and compute diff
    if ($diff) {
	# Derive the difference
	&assert($col1 <= (scalar @columns));
	&assert($col2 <= (scalar @columns));
	$num2 = $columns[$col2 - 1];
	$num2 = "" if (!defined($num2));
	my($label) = ($labels ? $columns[0] : "");
	my($difference) = "";
	if ($num2 =~ /^[0-9.-]/) {
	    $diff_sum += ($num2 - $num1);
	    $difference = &round($num2 - $num1);
	}

	# Format the remaining data at a string (for final column)
	my $rest = "";
	for (my $c = 0; $c < (scalar @columns); $c++) {
	    if (($c != $col1 - 1) && ($c != $col2 - 1)) {
		$rest .= "\t" if ($rest ne "");
		$rest .= $columns[$c];
	    }
	}

	# Show the two values, their difference, and the remaining data
	if ($append) {
	    printf "%s\t%s\n", $line, $difference;
	}
	else {
	    printf "%s\t%s\t%s\t%s\t%s\n", $label, $num1, $num2, $difference, $rest;
	}
    }
}

# Add separator after optional cumulative section
if ($cumulative) {
    print "\n";
    print "Total\n";
}

# Print the summation total
#
&debug_print(&TL_DETAILED, "num=$count sum=$sum\n");
if ($stats == &FALSE) {
    if ($show_sum) {
        print &round($diff ? $diff_sum : "$sum");
        if ($fract) {
	    my($result) = ($sum2 eq 0) ? "err" : $sum/$sum2;
    	    ## print "/$sum2 = $result\n";
	    printf "/%g = %s\n", $sum2, &round($result);
        }
        print "\n";
    }
    
    # Show count, mean, standard deviation, min and max
    # Note; -stdev is perl-based on -stats xlipstat
    if ($stdev) {
	if ((scalar @data) == 0) {
	    &warning("No data found for -stdev: use -fix?\n");
	    print "num = 0\n";
	}
	else {
	    debug_print(&TL_DETAILED, "data: @data\n");
	    if ($verbose) {
		print("data: @data\n");
	    }
	    printf "num = %d; mean = %s; stdev = %s; min = %s; max = %s; sum = %s\n", (scalar @data), &round(&mean(@data)), &round(&stdev(@data)), &round(&min_item(@data)), &round(&max_item(@data)), &round($sum);
	    if ($extended) {
		my(@sorted_data) = sort { $a <=> $b } @data;
		&debug_print(4, "sorted_data: (@sorted_data)\n");
		my($num_values) = (scalar @data);
		my($median);
		my($middle_pos) = POSIX::floor($num_values / 2);
		&debug_print(4, "num_values=$num_values middle_pos=$middle_pos\n");
		if ($num_values % 2) {
		    &debug_print(4, "Using unique middle\n");
		    $median = $sorted_data[$middle_pos];
		}
		else {
		    &debug_out(4, "Averaging values: %s %s\n",
			       $sorted_data[$middle_pos - 1], $sorted_data[$middle_pos]);
		    $median = ($sorted_data[$middle_pos] + $sorted_data[$middle_pos - 1]) / 2;
		}
		# TODO: definite function for this
		my($mode) = &run_command("echo @data | count_it.perl '\\S+' | head -1 | cut -f1");
		## OLD: my($perc95_pos) = POSIX::floor(0.95 * $num_values);
		## BAD: my($perc95_pos) = &round(0.95 * $num_values, 0);
		my($perc95_pos) = POSIX::ceil(0.95 * ($num_values - 1));
		my($perc95) = $sorted_data[$perc95_pos];
		## OLD: my($perc99_pos) = POSIX::floor(0.99 * $num_values);
		## BAD: my($perc99_pos) = &round(0.99 * $num_values, 0);
		my($perc99_pos) = POSIX::ceil(0.99 * ($num_values - 1));
		my($perc99) = $sorted_data[$perc99_pos];
		&debug_print(4, "perc95_pos=$perc95_pos perc99_pos=$perc99_pos\n");
		print "median = $median; mode = $mode; 95th-% = $perc95; 99th-% = $perc99\n";
	    }
	}
    }
}


# Invoke xlispstat to display statistics about the data
#
if ($stats) {
    &show_statistics();
}

# Ye olde ende
&exit();

#------------------------------------------------------------------------------

# show_statistics(): Invoke xlispstat to display various summary statistics,
# optionally with invocation of anova, t-test, etc. statistical analysis.
# TODO: 
# - Include prompt with command graphics commands (e.g., plot-data, plot-lines, histogram).
# - Check for empty data list (as with -stdev case above).
#
sub show_statistics {
    &debug_print(&TL_VERBOSE, "show_statistics(@_)\n");
    my($temp_file) = "temp_calc_stats_$$.lisp";
    my($lisp_code);
    my($extra) = "";
    my($init) = (&DEBUG_LEVEL < 4) ? "" : "(dribble \"temp_calc_stats_$$.log\")\n";
    my($omit_summary) = (($each || $any_stat_test) && (! $verbose));
    my($summary) = "";
    if (! $omit_summary) {
	my($brief_option) = ($verbose ? "nil" : "t");
	$summary .= "(def data \'($column_data[$f1]))\n";
	$summary .= "(calc-summary-statistics  data $brief_option)\n";
	if ($f2 != -2) {
	    $summary .= "(def other-data \'($column_data[$f2]))\n";
	    $summary .= "(calc-summary-statistics other-data) $brief_option)\n";
	}
    }
    my($exit) = $interactive ? "" : "(exit)";

    # Define the data for each of the columns
    &trace_array(\@column_data, &TL_VERBOSE, "column_data");
    &assert($col1 <= (scalar @column_data));
    &assert($col2 <= (scalar @column_data));
    my($data_list) = "";
    if ($each || $any_stat_test) {
	my ($start) = $labels ? 1 : 0;
	$data_list = "(list";
	for (my $i = $start; $i <= $#column_data; $i++) {
	    my($c) = ($i + 1);
	    $extra .= "(def col$c (list $column_data[$i]))\n\n";
	    $data_list .= " col$c";
	}
	$data_list .= ")";
    }
    if ($ttest) {
	$extra .= sprintf "(do-t-test col%d col%d)\n\n", 
	                  $col1, $col2;
    }
    if ($paired_ttest) {
	$extra .= sprintf "(do-paired-t-test col%d col%d)\n\n", 
	                  $col1, $col2;
    }
    if ($anova && $each) {
	$extra .= sprintf "(do-anova2 $data_list)\n\n";
    }
    elsif ($anova) {
	$extra .= sprintf "(do-anova col%d col%d)\n\n", 
	                  $col1, $col2;
    }
    if ($mann_whitney) {
	$extra .= sprintf "(do-mann-whitney-test col%d col%d)\n\n", 
	                  $col1, $col2;
    }
    if ($anova) {
	# By default, use version of anova from XLispStat extension.
	# See Contributions/anova2.lsp in XLispStat directory.
	$ENV{"USE_XLISP_EXTS"} = 1 unless (defined($ENV{"USE_XLISP_EXTS"}));
    }

    # Output the lisp code for calculating the statistics
    &reference_var($script_dir);
    $lisp_code = $init . "(load \"${script_dir}/misc_xlispstat.lisp\")\n"
	. $summary . $extra . $exit;
    &write_file($temp_file, $lisp_code);
    &debug_out(&TL_DETAILED, "Loading xlispstat code: {\n%s}\n", &indent($lisp_code));

    # Invoke xlispstat
    # NOTE: In interactive mode the file is not redirected from stdin
    my($in_redir) = $interactive ? "" : "<";
    my($out_redir) = $interactive ? "" : "2>&1";
    my($batch) = $interactive ? "" : "-b";
    my($non_x) = $interactive ? "" : "--non-X";
    my($verbose_option) = "";
    if ($verbose || (&DEBUG_LEVEL >= 4)) {
	$verbose_option = "-v";
	$ENV{"XLISP_DEBUG"} = "1";
	}
    if ($interactive) {
	&cmd("xlispstat.sh $verbose_option $batch $non_x $in_redir $temp_file");
    }
    else {
	my($result) = &run_command("xlispstat.sh $verbose_option $batch $non_x $in_redir $temp_file $out_redir", &TL_VERBOSE);
	$result =~ s/[^\000]+Copyright.*\n//; 	# drop xlisp banner
	$result =~ s/.*xlisp_linux: can\'t connect to X server\s*\n//;
	$result =~ s/\n>.*\n?/\n/g;		# drop command traces
	$result =~ s/\n>.*\n?/\n/g;		# drop command traces (redux)
	$result =~ s/\n\#<.*\n//g;		# drop object dumps
	$result =~ s/; loading .*\n//g;		# drop lisp module load traces
	$result =~ s/\n((T)|(NIL))\n/\n/g;	# drop misc lisp results
	$result =~ s/\n\s*\n\s*\n/\n\n/g; 	# collapse multiple blank lines
	if ($anova && ($ENV{"USE_XLISP_EXTS"} == 0)) {
	    # Add some headers to the output (not applicable to anova extension in anova2.lsp).
	    $result =~ s/Group 0/Group                      Coefficient  (std-error)\nGroup 0/;
	    $result =~ s/Group Mean Square/                           Mean Square  (df)\nGroup Mean Square/;
	}
	printf "%s\n", $result;
    }

    # Cleanup things
    if (&DEBUG_LEVEL < 5) {
	unlink $temp_file;
	unlink "temp_calc_stats_$$.log"
    }

    return;
}
