# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# calc_entropy.perl: calculates entropy of a class using the output of a
# frequency tabulation program (in particular count_it.perl).
#
# sample input:
# 
#    # Frequency of 'between' in Penn Treebank II WSJ annotations
#    24      pp-clr
#    6       pp-dir
#    4       pp-ext
#    35      pp-loc
#    2       pp-nom
#    7       pp-prd
#    42      pp-tmp
#    
# sample output:
#
#    # word  classes freq    entropy max_prob
#    between 7       120     2.230   0.350
#
#
# sample usage (simplified input):
#    $ calc_entropy.perl -simple .25 .25 .25 .25
#    2.000
#
# TODO:
# - Remove assumptions about word-oriented data.
# - Move just_freq code into separate script (new calc_relative_frequency.perl).
# - Add usgae example using relative frequency usgae:
#      $ calc_entropy.perl -verbose -last coca-w1.data > coca-w1.rfreq
#      $ cut -f3,5 > coca-w1.coca-w1.rfreq
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir);
    require 'common.perl';
    use vars qw/$verbose $precision/;
    require 'extra.perl';
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
no strict "refs";		# allow for symbolic file handles
use vars qw/$class_filter $max_count $label $word $last $freq_last
    $freq_first $header $show_header $skip_header $classes $show_classes
    $simple $normalize $fix $alpha $preserve $cumulative $just_freq $no_comments/;
use vars qw /$strip_comments $first $class_width/;


if (! defined($ARGV[0])) {
    my($options) = "options = [-max_count=N] [-word=w] [-class_filter=\"list\"] [-simple] [-normalize] [-cumulative] [-no_comments] [-verbose]";
    $options .= "[-[freq_]first] [-[freq_]last] [-label=text] [-[show_|skip_]header] [-[show_]classes] [-alpha] [-preserve] [-just_freq] [-class_width=N]";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "ex: $script_name -d=5 -class_filter=\"pp-bnf pp-dir pp-mnr pp-prp pp-tmp pp=ext pp-loc\" as.freq\n\n";
    $example = "examples:\n\n$script_name -verbose -simple .47 .42 .06 .05\n\n";
    $example .= "$script_name -freq_last all-fe.freq\n\n";
    $example .= "ls /etc | count_it.perl '\\w+' | $script_name -last -verbose -\n\n";
    #
    $example .= "file=bridge-over-troubled-waters.chords\n";
    $example .= "count_it.perl '^(\\S+)\\t' \$file >| \$file.freq\n";
    $example .= "$script_name -no_comments -verbose -last \$file.freq | cut.perl -f='3,5' - >| \$file.rfreq\n\n";

    print STDERR "\nusage: $script_name [options]\n\n$options\n\n$example";
    # TODO: put notes before examples as with other scripts
    print STDERR "notes:\n";
    print STDERR "- The -strip_comments option is an alias for old -no_comments=0.\n";
    print STDERR "- Use -verbose for more details.\n";
    if ($verbose) {
	# TODO: move into common.perl as new function
	my($detailed_usage) = &run_command("extract_matches.perl -fields=2 'init_var\\(\\*(\\w+).*\\s# (.*)' '$0'");
	$detailed_usage =~ s/^/  /mg;
	$detailed_usage =~ s/\t/: /g;
	print STDERR "- Option descriptions:\n$detailed_usage\n";	
    }
    
    &exit();
}

&init_var(*class_filter, "");
if ($class_filter ne "") {
    $class_filter = &to_lower(" $class_filter ");
}
&init_var(*max_count, &MAXINT);		# maximum number of cases to process
&init_var(*label, "");			# label for entropy display
&init_var(*word, "n/a");		# word over which distribution is made
&init_var(*last, &FALSE);		# alias for -freq_last
&init_var(*freq_last, $last);		# frequency occurs last in the data
&init_var(*freq_first, ! $freq_last);	# frequency occurs first in the data
&init_var(*just_freq, &FALSE);		# just output relative frequency
&init_var(*header, (! $just_freq));	# alias for show_header
&init_var(*show_header, $header);	# display comment header?
&init_var(*skip_header, ! $show_header); # should the header be skipped?
&init_var(*classes, &FALSE);		# alias for -show_classes
&init_var(*show_classes, $classes);	# display class information?
&init_var(*simple, &FALSE);		# data just contains the probabilities
&init_var(*fix, &FALSE);		# ensure tab-delimited input
&init_var(*normalize, &FALSE);		# normalize the probabilities?
&init_var(*alpha, &FALSE);		# show keys alphabetized
&init_var(*preserve, &FALSE);		# preserve order of keys
&init_var(*cumulative, &FALSE);		# show cumulative probability
## OLD: &init_var(*no_comments, &FALSE);	# used to bypass comment stripping
&init_var(*strip_comments, &FALSE);     # alias for (confusing) -no_comments=0
&init_var(*no_comments, ! $strip_comments); # used to bypass comment stripping
&init_var(*class_width, 0);            # width to use for label (if > 0)

my($LOG2) = log(2);

## DEBUG: printf "round(4.00078) => %s\n", round(4.00078);

# Optionally, normalize the data and reinvoke over that
if ($normalize && $simple) {
    &debug_print(&TL_DETAILED, "Re-invoking with normalized/simple data\n");
    my($data) = ((defined($ARGV[0]) && ($ARGV[0] ne "-")) ? "@ARGV" : join("\n", <STDIN>));
    my($normalized_data) = &run_command_over("normalize.perl - <", $data);
    printf "%s\n", &run_command_over("$0 -simple -normalize=0 - <", $normalized_data);
    &exit();
}

# Check for simplified version of data (i.e., just the probabilities)
if ($simple) {
    my(@data);
    # See if command line should be used
    if (($#ARGV >= 0) && ($ARGV[0] ne "-")) {
	@data = @ARGV;
    }
    # Otherwise get from standard input
    else {
	@data = &tokenize(join(" ", <STDIN>));
    }
    &simple_calc_entropy(@data);
    &exit();
}

# If no files explicitly given, process standard input
if (!defined($ARGV[0])) {
    &regular_calc_entropy("STDIN", $word);
    &exit();
}

# Process each file on the command line
## OLD: printf "# word\tclasses\tfreq\tentropy\tmax_prob\n" unless ($skip_header);
foreach my $file (@ARGV) {

    if ($word eq "n/a") {
	$word = &remove_dir(&basename($file, ".freq"));
	}
    if (!open(FREQ, "<$file")) {
	&warning("unable to read $file\n");
	next;
    }
    &regular_calc_entropy("FREQ", $word);
    close(FREQ);
    $word = "n/a";
}

#------------------------------------------------------------------------------

# regular_calc_entropy(handle, label): Calculate entropy for the probability distribution,
# taken from input HANDLE for class label (e.g., word).
#
# sample input:
#
#    green	0.5
#    eggs	0.25
#    with	0.125
#    spam	0.125
#
# sample output:
#    #		class	freq	prob	-p lg(p)
#    #		green	0	0.500	0.500
#    #		eggs	0	0.250	0.500
#    #		with	0	0.125	0.375
#    #		spam	0	0.125	0.375
#    #		total	1	1.000	1.750
#
#    # word	classes	freq	entropy	max_prob
#    -	4	1	1.750	0.500
#
sub regular_calc_entropy {
    &debug_print(&TL_VERBOSE, "regular_calc_entropy(@_)\n");
    # TODO: rename word to label
    my($handle, $word) = @_;
    my(%class_frequency);
    my(@keys);

    my($total_freq) = 0;
    my($count) = 0;
    my($max_label) = "";
    my($max_label_len) = 0;
    while (<$handle>) {
	&dump_line();
	chomp;

	# Skip comments and blank lines
	## BAD: s/#.*// unless ($no_comments);
	s/#.*// if ($no_comments);
	next if (/^\s*$/);
	## OLD: s/\s\s+/\t/g if ($fix);		# make sure input is tab-delimited
	s/\s+/\t/g if ($fix);		# make sure input is tab-delimited
	if (! m/\t/) {
	    &warning("unexpected input at line $. ($_)\nUse -fix if not tab-delimited.\n");
	    next;
	}

	# Get the frequency and class name, skipping items not in the filter
	my($freq, $class, $rest);
	if ($freq_first) {
	    ($freq, $class, $rest) = split(/\t/, $_);
	}
	else {
	    ($class, $freq, $rest) = split(/\t/, $_);
	}
	$rest = "" if (!defined($rest));
	&debug_print(&TL_DETAILED, "class='$class' freq='$freq' rest='$rest'\n");

	# Keep track of max label length, etc.
	if (length($class) > $max_label_len) {
	    $max_label_len = length($class);
	    $max_label = $class;
	}

	# See if the item should be ignored
	if (! &is_numeric($freq)) {
	    &warning("unexpected input at line $. ($_)\nUse -last if class comes first\n");
	    ## return;
	    next;
	}
	if (($class =~ /^total/i) && ($freq == $total_freq)) {
	    &debug_print(&TL_DETAILED, "skipping totals class '$class'\n");
	    next;
	}
	if (($class_filter ne "") && (index($class_filter, $class) == -1)) {
	    &debug_print(&TL_DETAILED, "skipping filtered class $class\n");
	    next;
	}
	
	# Tabulate frequency
	push(@keys, $class);
	&incr_entry(\%class_frequency, $class, $freq);
	$total_freq += $freq;
	last if (++$count == $max_count);
    }
    close($handle);

    # Make sure sufficient data and show summary
    if ($total_freq == 0) {
	# TODO: add argument for filename for error message
	&warning("unexpected distribution for $handle (all 0)\n");
	return;
    }
    &debug_print(&TL_VERBOSE, "max label: $max_label; len: $max_label_len\n");
    
    my($entropy) = 0.0;
    my($max_prob) = 0.0;
    my($sum_p) = 0.0;
    ## OLD: print "#\t\tclass\tfreq\tprob\t-p lg(p)\n" if ($verbose && (! $just_freq));
    my($class) = "class";
    my($label_width) = (($class_width > 0) ? $class_width : $max_label_len);
    if (length($class) < $label_width) {
	$class .= (" " x ($label_width - length($class)));
    }
    print("#\t\t$class\tfreq\tprob\t-p lg(p)\n") if ($verbose && (! $just_freq));
    my($num_classes) = 0;
    my(@sorted_keys) = ($alpha ? sort(@keys) : 
			$preserve ? @keys : 
			&sorted_hash_keys_reverse_numeric(\%class_frequency));
    foreach my $class (@sorted_keys) {
	&debug_print(&TL_VERBOSE, "class: $class\n");
	my($freq) = &get_entry(\%class_frequency, $class);
	next if ($freq == 0);
	my($prob) = $freq / $total_freq;
	$sum_p += $prob;
	$max_prob = &max($prob, $max_prob);
	my($p_lg_p) = ($prob > 0) ? (- $prob * (log($prob)/$LOG2)) : 0;
	$entropy += $p_lg_p;
	my($prob_value) = ($cumulative ? $sum_p : $prob);
	if ($just_freq) {
	    print "$class\t" if ($verbose);
	    print &round($prob_value), "\n";
	}
	elsif ($verbose) {
	    ## OLD: printf ("#\t\t%s\t%d\t%s\t%s\n", $class, $freq, &round($prob_value), &round($p_lg_p));
	    my($label_width) = (($class_width > 0) ? $class_width : $max_label_len);
	    &debug_print(&TL_VERBOSE, "width: $label_width\n");
	    ## TEST: printf("#\t\t%.*s%d\t%s\t%s\n", $label_width, $class, $freq, &round($prob_value), &round($p_lg_p));
	    if (length($class) < $label_width) {
		$class .= (" " x ($label_width - length($class)));
	    }
	    printf("#\t\t%s\t%d\t%s\t%s\n", $class, $freq, &round($prob_value), &round($p_lg_p));
	}
	$num_classes++;
    }
    if ($just_freq) {
	# do nothing
    }
    elsif ($verbose) {
	printf ("#\t\ttotal\t%d\t%s\t%s\n", $total_freq, &round(1.0), &round($entropy));
	print "\n";
	printf "# word\tclasses\tfreq\tentropy\tmax_prob\n" unless ($skip_header);
	printf "%s\t%d\t%d\t%s\t%s\n", $word, $num_classes, $total_freq, &round($entropy), &round($max_prob);
    }
    elsif (! $just_freq) {
	print &round($entropy), "\n";
    }
}


# simple_calc_entropy(dist): Calculate entropy for the probability distribution
#
# example input:
#    0.5 0.25 0.125 0.125
#
# example output:
#    1.750
#
sub simple_calc_entropy {
    &debug_print(&TL_VERBOSE, "simple_calc_entropy(@_)\n");
    my(@data) = @_;
    my($label_spec) = ($label ne "") ? "$label\t" : "";
    my($label_header) = ($label ne "") ? "\t" : "";

    my($entropy) = 0.0;
    my($max_prob) = 0.0;
    if ($verbose && (! $just_freq)) {
	printf "#\tprob\t-p lg(p)    max p\n";
	printf "#%s\n", "-" x 32;
    }
    my($num_classes) = (1 + $#data);
    my($sum_p) = 0.0;

    foreach my $prob (@data) {
	$sum_p += $prob;
	$max_prob = &max($prob, $max_prob);
	my($p_lg_p) = ($prob > 0) ? (- $prob * (log($prob)/$LOG2)) : 0;
	$entropy += $p_lg_p;
	my($prob_value) = ($cumulative ? $sum_p : $prob);
	## OLD: printf "#\t%.3f\t%.3f\n", $prob_value, $p_lg_p if ($verbose && (! $just_freq));
	printf "#\t%s\t%s\n", &round($prob_value), &round($p_lg_p) if ($verbose && (! $just_freq));
	print &round($prob_value), "\n" if ($just_freq);
    }
    if ($verbose && (! $just_freq)) {
	printf "#%s\n", "-" x 32;
	printf "# word\tclasses\tfreq\tentropy\tmax_prob\n" unless ($skip_header);
	## OLD: printf "#\t%.3f\t%.3f\t   %.3f\n", $sum_p, $entropy, $max_prob;
	printf "#\t%s\t%s\t   %s\n", &round($sum_p), &round($entropy), &round($max_prob);
    }
    &debug_print(&TL_VERBOSE, "simple_calc_entropy(@data) => $entropy\n");

    if (! $skip_header) {
	print $label_header;
	print "Classes\t" if ($show_classes);
	print "Entropy\n";
    }
    if (! $just_freq) {
	print $label_spec;
	print "${num_classes}\t" if ($show_classes);
	print &round($entropy), "\n";
    }
}

#------------------------------------------------------------------------

# DEBUG: define local version of round
## # round(number, [decimal places])
## #
## # Rounds the number to the specified number of decimal places, usually 3.
## # TODO: see why version from common.perl not used
## #
## sub round {
##     my($number, $places) = @_;
##     $places = $::precision if (!defined($places));
##     my($format) = "%.${places}f";
##     my($result) = sprintf($format, $number);
##     &debug_print(&TL_ALL, "round($number, [$places]) => $result\n");
##     return ($result);
## }
