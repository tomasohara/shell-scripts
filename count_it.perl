# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/bin/perl -sw
#
# count_it.perl: script to count the occurrences of a pattern in the input
#
# NOTE: This is a simple script that turns out to be very useful
# for a variety of tasks, especially in corpus analysis.
#
# examples:  
#
# tabulating most commonly used commands:
#
#   $ history | count_it.perl "^\s*\d+\s*(\S+)" - | less
#   ps_mine 13
#   w       11
#   gr      7
#   top     6
#   ...
# 
# tabulating part-of-speech usage for particular words
#
#   $ count_it "(outside\/\S+)" ~/OpenMind/data/omcsraw.tag 
#   outside/IN	502
#   outside/RB	137
#   outside/NN	53
#   outside/JJ	19
#
# Copyright (c) 2000-2001 Cycorp, Inc.  All rights reserved.
# Portions Copyright (c) 1996-1999 Tom O'Hara (at NMSU).  All rights reserved.
#
# TODO:
# - Add more descriptions of options to usage text.
# - Add automatic carriage return removal to avoid problems such as CR being pulled in for "([^;]+)" (see ~/fast/port-notes.txt).
# - Add paratheses to print calls.
# - Fix bug with backslash-style references:
#   ¢ echo "abba" | count-it -d=6 -restore='\2' '(.(.))' - 2>&1 | grep restoring | head
#   restoring 'SCALAR(0xa5c900)' to current text
#   restoring 'SCALAR(0xd32d70)' to current text
#   ...
#   restoring 'SCALAR(0xa5caf8)' to current text
#

# Load in the common module, making sure the script dir is in Perl's lib path
BEGIN {
    my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir);
    require 'common.perl';
    use vars qw/$utf8 $BOM $verbose/;
    require 'extra.perl';
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict "refs";			# allow string deferencing (for -occurrences support)
use vars qw/$utf8 $i $ignore_case $i $ignore_case $foldcase $fold $preserve 
            $para $slurp $multi_per_line $one_per_line $freq_first $alpha $compact $cumulative
            $occurrences $occurrence_field $percents $multiple $nonsingletons $min2 $min_freq $trim $unaccent $pattern_file $pattern $locale $chomp/;
use vars qw/$nonsingleton $restore $field $show_zeros/;

# Check the command-line options
# Each variable initialized corresponds to -var=value commandline option
&init_var(*i, &FALSE);			# ignore case in the pattern matching
&init_var(*ignore_case, $i);		# alias for -i option
&init_var(*foldcase, $i);		# fold (convert) text to lowercase
&init_var(*fold, $i);			# alias for -foldcase
&init_var(*preserve, ! ($foldcase || $fold));	# preserve the case of text matching pattern
&init_var(*para, &FALSE);		# apply the pattern to paragraphs not lines
&init_var(*slurp, &FALSE);		# apply the pattern to entire files
&init_var(*freq_first, &FALSE);		# put frequency counts first (ie, <freq><tab><data>)
&init_var(*alpha, &FALSE);		# alphabetical sort
&init_var(*compact, &FALSE);		# compact all whitespace sequences
&init_var(*cumulative, &FALSE);		# include column for cumulative counts
&init_var(*occurrences, &FALSE);	# the tags being counted are actually occurrence counts
&init_var(*occurrence_field, 		# field giving occurrence count (e.g., 1 for $1)
	  $occurrences ? $occurrences + 1 : 0);
&init_var(*field, 1);	                # field number to use for pattern
&init_var(*percents, &FALSE);		# shows the relative percents
&init_var(*min2, &FALSE);		# alias for -nonsingletons
&init_var(*multiple, $min2);		#   "
&init_var(*nonsingleton, $multiple);	#   "
&init_var(*nonsingletons, $nonsingleton); # omit cases that occur once
&init_var(*show_zeros, &FALSE);         # initialize pattern's count to 0
my($min_freq_default) = ($show_zeros ? 0 : ($nonsingletons ? 2 : 1));
&init_var(*min_freq, 			# min frequency to show in output
	  $min_freq_default);
&init_var(*trim, &FALSE);		# trim whitespace in matched text
&init_var(*unaccent, &FALSE);		# remove accent marks from input
&init_var(*pattern_file, "");		# file with pattern (to circumvent shell UTF8 issues)
my($default_pattern) = (($pattern_file ne "") ? &read_file($pattern_file) : "");
&init_var_exp(*pattern, $default_pattern); # regex pattern to check for
&init_var_exp(*locale, &FALSE);		# honor environment locale settings
&init_var(*chomp, &FALSE);		# strip newline at end (TODO make default unless \n in pattern)
&init_var(*restore, "");		# portion of matching text to be restored

# Get the pattern and options from the command line
# Process the command-line options
if (!defined($ARGV[0])) {
    my($options) = "options = [-i(gnore)] [-alpha] [-freq_first] [-para] [-preserve] [-foldcase]\n";
    $options    .= "          [-compact] [-min_freq=N | -nonsingletons | -min2] [-slurp] [-unaccent] [-chomp]\n";
    $options    .= "          [-occurrences] [-cumulative] [-multi_per_line|-one_per_line] [-restore] [-show_zeros]\n";
    my($example) = "examples:\n\nls | $script_name '\\.([^\\.]+)\$'\n\n";
    $example .= "$0 '(outside\/\\S+)' omcsraw.tag\n\n";
    $example .= "perl -CIOE -Sw $script_name '(.)' - < wiki-lang-info/utf8/da  >| /tmp/da.freq\n\n";
    $example .= "$script_name -restore='\$3' '((\\S+\\s+)((\\S+\\s+){2}\\S+))' time-tracking-aug21.list | head\n\n";
    my($note) = "";
    $note .= "notes:\n\nThe patterns are regular expressions using Perl's extensions\n";
    $note .= "See manual page for details (e.g., 'man perlre')\n\n";
    $note .= "To tabulate only parts of the pattern, use parenthesis as illustrated above.\n\n";
    ## TODO3: show misc options only if -verbose (as in sum_file.perl)
    ## ... $note .= "- Use -verbose for more help or to show extracted data."
    $note .= "Miscellaneous options:\n";
    $note .= "-compact to treat runs of whitespace as single space\n";
    $note .= "-nonsingletons to ignore item occurring just once\n";
    $note .= "-para reads text in paragraph mode (rather than line)\n";
    $note .= "-slurp reads the entire file at once (for long-distance patterns)\n";
    $note .= "-occurrences incorporates count field (\$1 for pattern & \$2 count)\n";
    $note .= "-multi_per_line allows for multple occurrences in a line (assumed unless ^ used)\n";
    $note .= "-restore is used to simulate look-ahead (see example above).\n";
    $note .= "-show_zeros is used to show patterns not matched.\n";
    ## TODO: add optional extended help with examples for misc. options

    ## OLD: die "\nusage: $script_name [options] pattern file ...\n\n$options\n\n$example\n$note\n";
    print STDERR "\nusage: $script_name [options] pattern file ...\n\n$options\n\n$example$note\n";
    &exit();
}
if ($pattern eq "") {
    $pattern = $ARGV[0];
    shift @ARGV;
}

# See if regex has line achor (^ or $)
## TODO: exclude \$ at end of string (e.g., "100\$")
## TODO: add unit test: (echo "12 34 56 78" | count_it.perl '\d{2}' | wc -l) =>  4
my($has_line_anchor) = ((index($pattern, "^") == 0) 
			|| (rindex($pattern, "\$") == length($pattern))); 
&init_var(*one_per_line, $has_line_anchor); # only count one instance of the pattern per line
&init_var(*multi_per_line, ! $one_per_line);	# count multiple instance of the pattern per line (even when ^ and $ are specified)
&assertion(! ($one_per_line && $multi_per_line));

if ($locale) {
    &debug_print(&TL_USUAL, "Enabling locale support\n");
    # note: used for case-insensitive matching
    eval "use locale;'"
}

# Sanity check for whether one-per-line option might be needed
# NOTE: checks against pattern need to occur prior to modification (e.g., paren addition)
# TODO: handle multiple patterns per line (e.g., set line break to null); likewise check for multiple end-of-line matching
if ((&DEBUG_LEVEL > 3) && ($pattern =~ /^\^/) && ($pattern !~ /[\$\n]$/) && (! $multi_per_line)) {
    &warning("You might want to specify -multi_per_line if you want \^ and/or \$ interpretted after match removal.\n");
}

# Initialize count for pattern itself (e.g., non-regex)
# TODO2: add initialization for other patterns (e.g., -entries="red,green,blue")
my(%count);			# assoc. list for pattern counting
if ($show_zeros) {
    &set_entry(\%count, $pattern, 0);
}

# Put grouping parenthesis around pattern, if none present
# NOTE: Escaped parentheses are ignored.
# TODO: (" $pattern " !~ /[^\\]\(.*\)[^\\]/)
if ((($pattern =~ /\\\(.*\\\)/) && ($pattern !~ /[^\\]\(.*\)[^\\]/))
    || ($pattern !~ /\(.*\)/)) {
    $pattern = "(" . $pattern . ")";
}

# Process each line of the input stream
&debug_out(&TL_DETAILED, "searching for pattern '%s'; one_per_line=%d; ignore_case=%d...\n", 
	   $pattern, $one_per_line, $ignore_case);
&debug_print(&TL_VERBOSE, "restore=$restore\n");
my($num) = 0;			# number of distinct cases (pattern instances)

$/ = "" if ($para);		# paragraph input mode
$/ = 0777 if ($slurp);		# complete-file input mode

## OLD:
## # Enable UTF8 I/O
## # TODO2: make this automatic in common.perl
## if ($utf8) {
##     use Encode 'decode_utf8';
## }

## OLD: my(%count);			# assoc. list for pattern counting
my($total_count) = 0;
#
while (<>) {
    if ($utf8) {
	$_ = decode_utf8($_);
    }
    if ($unaccent) {
	$_ = ($utf8 ? &utf8_remove_diacritics($_) : &iso_remove_diacritics($_));
    }

    # NOTE: a chop isn't performed by default to allow for using the newline in a pattern.
    # This is often more convenient than using $ (e.g., when using csh).
    # TODO: add sanity check about DOS carriage returns screwing up pattern matching
    if ($chomp) {
	chomp;
	&dump_line("$_\n");
    }
    else {
	&dump_line();
    }

    # Perform optional transformations
    # - In paragraph mode treat newlines as spaces unless mentioned in the pattern.
    # - All whitespace sequences to single spaces
    if ($para && ($pattern !~ /\n/)) {
	s/\n/ /g;
    }
    if ($compact) {
	s/\s+/ /g;
    }

    my($text) = $_;
    while (($text ne "") && ($text ne "\n")) {
	&debug_out(&TL_VERY_VERBOSE, "text=%s\n", $text);
	my($found) = &FALSE;
	my($tag);

	# Try to extract tag from the text
	# NOTE: s qualifier treats string as single line (in case -para specified)
	if (($ignore_case == 1) && ($text =~ /$pattern/si)) {
	    $tag = $1;
	    if ($field > 1) {
		&debug_print(&TL_MOST_VERBOSE, "eval \"\$${field}\"");
		$tag = eval "\$${field}";
	    }
	    $tag = &to_lower($tag) unless ($preserve);
	    ## OLD: $text = $';
	    $found = &TRUE;
	}
	elsif (($ignore_case == 0) && ($text =~ /$pattern/s)) {
	    $tag = $1;
	    ## BAD: $tag = $1 if ($field == 1) else "eval \$${field}";
	    if ($field > 1) {
		&debug_print(&TL_MOST_VERBOSE, "eval \"\$${field}\"");
		$tag = eval "\$${field}";
	    }
	    ## OLD: $text = $';
	    $found = &TRUE;
	}
	#
	# Update the current line being matched
	if ($found && ($restore ne "")) {
	    my($restore_text) = eval "$restore";
	    &debug_print(&TL_DETAILED, "restoring '$restore_text' to current text\n");
	    $text = $restore_text . $';		# '
	    &debug_print(&TL_VERBOSE, "current text='$text'\n");
	}
	else {
	    $text = $';				# '
	}


	# Update the hash table of the patterns
	if ($found) {
	    $tag = &trim($tag) if ($trim);
	    ## TODO: add unit test for differences using optional suffixes vs. lookahead (e.g., '\w{3}((, )|$)' vs. '\w{3}(?=(, )|$)'
	    ## OLD: &debug_print(&TL_VERY_DETAILED, "adding: '$tag'; \$\&='$&'\n");
	    &debug_print(&TL_VERY_DETAILED, "adding: '$tag'\n\t\$\&='$&'\n");
	    $num++;
	    my($count) = 1;
	    if ($occurrence_field) {
		$count = eval "\$${occurrence_field}";
		&debug_print(&TL_VERY_DETAILED, "count: $count\n");
	    }
	    &incr_entry(\%count, $tag, $count);
	    $total_count += $count;
	}

	# Stop when not found or if just one match per line
	if ((! $found) || ($one_per_line)) {
	    $text = "";
	}
    }
}
&debug_print(&TL_VERBOSE, "$num patterns found\n");
## OLD: print("total occurrence count is ${total_count}\n") if ($occurrences);
if ($occurrences || $verbose) {
    print("total occurrence count is ${total_count}\n");
}
&trace_assoc_array(\%count);

print("Frequency of $pattern\n") if ($verbose);
my($sort_function) = ($alpha ? \&sorted_hash_keys_alphabetic : \&sorted_hash_keys_reverse_numeric);
my($cumulative_tag_count) = 0;
foreach my $tag (&$sort_function(\%count)) {
    my($tag_count) = &get_entry(\%count, $tag, 0);
    last if ($tag_count < $min_freq);
    ## TODO3: streamline the above short circuit with below inclusion checks
    ## OLD if ($tag_count != 0) ...
    if (($tag_count != 0) || ($show_zeros)) {
	$tag =~ s/\n$//;
	if ($freq_first) {
	    print $tag_count, "\t", $tag;
	}
	else {
	    print $tag, "\t", $tag_count;
	}
	if ($percents) {
	    print "\t", &round($tag_count / $total_count);
	}

	# Show optional cumulative count column
	if ($cumulative) {
	    $cumulative_tag_count += $tag_count;
	    print "\t${cumulative_tag_count}";
	    if ($percents) {
		print "\t", &round($cumulative_tag_count / $total_count);
	    }
	}
	print "\n";
    }
}

