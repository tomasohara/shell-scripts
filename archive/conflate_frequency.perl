#!/usr/bin/perl -sw
#
# conflate_frequency.perl: conflate the word frequencies in the file, taken from tab separated input
#
# example data (headMedialString-head.freq):
#   22	Breakfast-TheWord
#   21	Stage-TheWord
#   13	Book-TheWord
#   7	Cruise-TheWord
#   7	Clothes-TheWord
# ...
#
# TODO:
# - Have options to average the frequencies (e.g., in case they represent weights) and for including occurrence count field.
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = $0; $dir =~ s/[^\\\/]*$//; unshift(@INC, $dir);
    require 'common.perl';
    require 'extra.perl';
    ## TODO: use vars qw/$verbose/;
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
use vars qw/$first $freq_first $lower $min_count/;

if (!defined($ARGV[0])) {
    my $options = "options = [-first] [-lower] [-min_count=N] [-average] [-show_occurrence]";
    my $example = "examples:\n\n$0 -freq_first multiWordString-head.freq compoundString-head.freq headMedialString-head.freq > multiword-head.freq\n\n";
    my($note) = "Notes\n";
    $note .= "- Use -average to average the frequencies\n";
    $note .= "- Use -occurrence to include column with instance counts\n";

    die "\nusage: $0 [options]\n\n$options\n\n$example\n$note\n";
}

&init_var(*first, &FALSE);		# alias for -freq_first
&init_var(*freq_first, $first);		# put word after the frequency
&init_var(*lower, &FALSE);		# make lowercase
&init_var(*min_count, 0);		# minimum frequency count
&init_var(*average, &FALSE);		# show average frequency
&init_var(*occurrence, &FALSE);	        # include occurrence count column

my(%freq);                              # hack for frequency counts/weights
my(%instances);                         # hash for individual occurrence counts
my($total_count) = 0;                   # total number of occurrences

while (<>) {
    &dump_line();
    chomp;
    my($count, $word);

    # Extract the frequency count and associated label
    # TODO: tabify as with other frequency analysis scripts (e.g., sum_file.perl)
    if ($freq_first && (/^(\S+)\s+(\S+)/)) {
	$count = $1;
	$word = $2;
    }
    elsif (/^([^\t]+)\t(\S+)/) {
	$count = $2;
	$word = $1;
    }
    elsif (/^(\S+)\s+(\S+)/) {
	$count = $2;
	$word = $1;
    }

    # Tabulate the word/phrase frequency
    if (defined($word) && defined($count)) {
	# Perform optional normalization (e.g., make lowercase)
	if ($lower) {
	    $word = &to_lower($word);
	}
	if ($min_count != 0) {
	    $count = max($count, $min_count);
	}
	&assert($count > 0);
	&incr_entry(\%freq, $word, $count);
	if ($average) {
	    $total_count++;
	    &incr_entry(%instances, $word, 1);
	}
    }
    else {
	&debug_print(&TL_DETAILED, "Ignoring line $.: $_\n");
    }
}

# Optionally average the entries
if ($average) {
    foreach my $word (keys(%freq)) {
	&assert(defined($instances{$word}));
	$freq{$word} /= $instances[$word];
    }
}

# Output the combined ("conflated") frequencies
foreach my $word (&sorted_hash_keys_reverse_numeric(\%freq)) {
    $extra = ($occurrence ? $instances{$word} : "");
    if ($freq_first) {
	printf "%s\t%s%s\n", $freq{$word}, $word, $extra;
    }
    else {
	printf "%s\t%s%s\n", $word, $freq{$word}, $extra;
    }
}

&exit();
