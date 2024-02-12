#!/usr/bin/perl -sw
#
# add_frequency.perl: add frequencies 
#

# Make sure script dir is in Perl's lib path
$dir = `dirname $0`; chop $dir; push(@INC, $dir);

require 'common.perl';

if (!defined($ARGV[0])) {
    $options = "options = [-freq=file] [-comment=prefix]\n";
    $example = "examples:\n\nperl -sw $script_name -freq=BNC_verbs.freq coil_verbs.list\n\n";
    $example .= "perl -sw $script_name coil_verbs.list | sort +1 -rn\n\n";
    $example .= "perl -sw $script_name -comment=\"--\" verb_status.list\n\n";
    $example .= "grep \" 9.8 \" $dir/levin_verb_classes.txt | cut -f1 | perl -sw $dir/$script_name - | sort +1 -rn | less\n\n";
    $notes = "notes:\n\nThe default data file is $dir/BNC_verbs.freq.\n\n";
    $notes .= "The result will contain one line for each word followed by it's frequency.\n\n";
    $notes .= "Comments are ignored. By default they start with ';'.\n\n";
    $notes .= "Use '-' for the filename to take input from shell window (standard input).\n\n";
    $notes .= "As shown above, use 'sort +1 -rn' to sort the results by reverse frequency:\n";
    $notes .= "    +1 indicates sort by second column\n";
    $notes .= "    -rn indicates a reverse numeric sort\n\n";

    die "\nusage: $script_name [options] file\n\n$options\n$example\n$notes";
}

&init_var(*freq, "$dir/BNC_verbs.freq");
&init_var(*comment, ";");

# Read in the word frequencies
local(%word_freq);
&read_frequencies($freq, *word_freq);

# Read in the words to be assigned frequencies
&reset_trace();
while (<>) {
    &dump_line();
    s/$comment.*//;		# strip comments
    next if (/^\s*$/);		# ignore blank lines

    foreach $word (&tokenize($_)) {
	$word = &to_lower($word);	# make sure word is lowercase
	local($freq) = &get_entry(*word_freq, $word);
	printf "%s\t%d\n", $word, $freq;
    }
}


#------------------------------------------------------------------------------

# read_frequencies(file, freq_list)
# 
# Read in the frequencies from the frequency file, which has the frequency
# count in the first column followed by the word. The result is stored in 
# the associative array given in the second argument (reference parameter).
#
sub read_frequencies {
    local ($file, *freq_list) = @_;
    &debug_out(4, "read_frequencies(@_)\n");

    open(FREQ, "<$file")
	|| die "unable to open frequency file: $file ($!)\n";

    while (<FREQ>) {
	&dump_line("freq: $_");
	chop;
	s/$comment.*//;			# strip comments
	next if (/^\s*$/);		# ignore blank lines
	## local($count, $word) = split('\t', $_);
	local($word, $count) = split('\t', $_);
	next if (!defined($word));
	$freq_list{$word} = $count;
    }
    close(FREQ);
}
