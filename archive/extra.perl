# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/bin/perl -sw
#
# extra.perl: common module with extraneous but occasionally useful functions
#
#........................................................................
# NOTES:
#
# from http://search.cpan.org/~jhi/perl-5.8.1/ext/Data/Dumper/Dumper.pm:
#
# $Data::Dumper::Indent or $OBJ->Indent([NEWVAL]) 
# 
# Controls the style of indentation. It can be set to 0, 1, 2 or
# 3. Style 0 spews output without any newlines, indentation, or spaces
# between list items. It is the most compact format possible that can
# still be called valid perl. Style 1 outputs a readable form with
# newlines but no fancy indentation (each level in the structure is
# simply indented by a fixed amount of whitespace). Style 2 (the
# default) outputs a very readable form which takes into account the
# length of hash keys (so the hash value lines up). Style 3 is like
# style 2, but also annotates the elements of arrays with their index
# (but the comment is on its own line, so array output consumes twice
# the number of lines). Style 2 is the default.
# TODO: cut down on this description
#

# Load in the common module, making sure the script dir is in the Perl lib path
# TODO: handle interactive usage (e.g., perl -e 'require "Extra.perl"; ...').
BEGIN { 
    my $dir = `dirname '$0'`; chomp $dir; unshift(@INC, $dir);
    ## TODO: my $dir = `dirname '$0' 2> /dev/null`; chomp $dir; unshift(@INC, $dir);
    require 'common.perl';
    ## use HotKey;		# reads single character from input without blocking
    ## OLD: require 'timelocal.pl';	# perl library for time functions
    use Time::Local;
    *timelocal::cheat = \&Time::Local::cheat;

    ## OLD: use Data::Dumper;	# stringifies perl data structures for printing and eval 
}

# Uncomment the following to check for undeclared variables.
# NOTES:
# - This is commented out until client programs can be made more strict.
# - Strict refs not used to allow for file handle string references.
## use strict;
## no strict "refs";

use vars qw/$TOPN $topN_options $hotbot $altavista $use_MI $use_dice $null_eof $numeric_format $stringify_indent $default_random $seed/;
our(%months, %weekdays, %month_names, @month_names);

# init_extra(): initialize extra.perl module
# EX: init_extra() => 1
#
sub init_extra {
    &debug_print(&TL_VERBOSE, "init_extra(@_)\n");

    $topN_options  = "[-TOPN=num]";
    &init_var(*TOPN, 5);
    
    # options for Web frequency checks
    &init_var(*hotbot, (! $altavista));
    &init_var(*altavista, &FALSE);
    &init_var(*use_MI, &FALSE);
    &init_var(*use_dice, (! $use_MI));
    &init_var(*null_eof, &FALSE);
    &init_var(*numeric_format, "%.3f");	# numeric format for rounding and normalization
    &init_var(*stringify_indent, 0);
    
    # Associative arrays for abbreviations
    %months = ("january", "jan",
    	   "february", "feb",
    	   "march", "mar",
    	   "april", "apr",
    	   "may", "may",
    	   "june", "jun",
    	   "july", "jul",
    	   "august", "aug",
    	   # "september", "sept",
    	   "september", "sep",
    	   "october", "oct",
    	   "november", "nov",
    	   "december", "dec");
    %weekdays = ("sunday", "sun",
    	     "monday", "mon",
    	     "tuesday", "tues",
    	     "wednesday", "wed",
    	     "thursday", "thurs",
    	     "friday", "fri",
    	     "saturday", "sat");
    
    # Alternative format for converting months into indices
    @month_names = ("\tjanuary\tjan\t",
    	   "\tfebruary\tfeb\t",
    	   "\tmarch\tmar\t",
    	   "\tapril\tapr\t",
    	   "\tmay\tmay\t",
    	   "\tjune\tjun\t",
    	   "\tjuly\tjul\t",
    	   "\taugust\taug\t",
    	   "\tseptember\tsep\t",
    	   "\toctober\toct\t",
    	   "\tnovember\tnov\t",
    	   "\tdecember\tdec\t");

    # Optionally initialize random number with 100,000th prime (1318699.
    # NOTE: Using default seed allows for reproducibility since random numbers differ between runs otherwise.
    &init_var(*default_random, &FALSE);		# use default random number seed
    &init_var(*seed, 1318699);			# random number seed (0 none)
    if ($default_random) {
	&debug_print(&TL_BASIC, "Setting random number seed to $seed\n");
        srand($seed);
    }

    return (1);
}

#------------------------------------------------------------------------------

# routines for maintaining a list of the N best (key, value) pairs
#
# sample usage:
#
#     require 'extra.perl'
#     ...
#
#     my(@max_label, @max_value);
#     &init_topN(5);
#     &clear_topN(\@max_label, \@max_value);
#     ...
#     while (...) {
#         &revise_topN(\@max_label, \@max_value, $label, $value);
#     }
#     ...
#     &show_topN(\@max_label, \@max_value);
#

# init_topN(num): initialize the topN settings 
# EX: our(@max_label, @max_value); init_topN(7) => 1
# TODO: revise to clear the arrays
#
sub init_topN {
    my($num) = @_;
    
    if (defined($num)) {
	$TOPN = $num;
    }
    &debug_print(&TL_VERBOSE, "init_topN(@_): TOPN=$TOPN\n");

    return (1);
}

# clear_topN(): reset the list of the topN entries
# EX: clear_topN(\@max_label, \@max_value); (scalar @max_label) => 0
#
sub clear_topN {
    my($max_label_ref, $max_value_ref) = @_;
    &debug_print(&TL_VERBOSE, "clear_topN(@_)\n");

    @$max_label_ref = ();
    @$max_value_ref = ();

    return;
}


# revise_topN(top_keys, best_values, key, value)
#
# Revise the list of the top N values and associated keys, given the
# current key and value.
# EX: revise_topN(\@max_label, \@max_value, 'abc', 2); revise_topN(\@max_label, \@max_value, 'xyz', 7); $max_value[0] => 7
#

sub revise_topN {
    my($max_label_ref, $max_value_ref, $label, $value) = @_;
    my($i);
    &debug_print(&TL_VERBOSE, "revise_topN(@_)\n");
    &assert($label ne "");

    # Use as the best one if it is higher
    # Find the position in the list where it belongs
    my($pos) = -1;
    for ($i = 0; $i < $TOPN; $i++) {
	# NOTE: ties might eventually fall off the list
	if ((!defined($$max_value_ref[$i])) 
	    || ($value > $$max_value_ref[$i])) {
	    $pos = $i;
	    last;
	}
    }
    if ($pos == -1) {
	return;
    }

    # Shift the lesser entries down the list
    for ($i = ($TOPN - 1); $i > $pos; $i--) {
	if (defined($$max_value_ref[$i - 1])) {
	    $$max_value_ref[$i] = $$max_value_ref[$i - 1];
	    $$max_label_ref[$i] = $$max_label_ref[$i - 1];
	}
    }
    $$max_value_ref[$pos] = $value;
    $$max_label_ref[$pos] = $label;
    &trace_array($max_label_ref);
    &trace_array($max_value_ref);

    return;
}


# show_topN(top_keys, best_values, [FILE="STDOUT"], [display_format="%s\t%.3f"])
#
# Display the (sorted) list of the top N key/value pairs.
#
sub show_topN {
    my($max_label_ref, $max_value_ref, $FILE, $display_format) = @_;
    $FILE = "STDOUT" if (! defined($FILE));
    $display_format = "%s\t%.3f\n" unless (defined($display_format));
    &debug_print(&TL_VERBOSE, "show_topN(@_)\n");
    my($i);

    for ($i = 0; $i < $TOPN; $i++) {
	printf $FILE $display_format, $$max_label_ref[$i], $$max_value_ref[$i] 
	    unless (!defined($$max_label_ref[$i]));
    }

    return;
}

#------------------------------------------------------------------------------

# abbreviate(text, abbreviations)
#
# Make abbreviations for all occurrences of the keys defined in the
# associative array. Case is not significant.
# EX: abbreviate("Mister President", {Mister => "Mr.", President => "Pres."}) => "Mr. Pres."
#
sub abbreviate {
    my($text, $abbrevs_ref) = @_;
    my($key);
    &debug_print(&TL_VERBOSE, "abbreviate(@_)\n");
    &debug_out(&TL_ALL, "keys(abbrevs_ref) = %s\n", join(' ', keys(%$abbrevs_ref)));

    # Substitute the abbreviation for each key in the table
    foreach $key (keys(%$abbrevs_ref)) {
	my($abbreviation) = &get_entry($abbrevs_ref, $key, "");
	&assert($abbreviation ne "");
	$text =~ s/$key/$abbreviation/ig;
    }

    return ($text);
}


# abbreviate_dates(text)
#
# Abbreviate the date expressions in the text.
# EX: abbreviate_dates("September 11") => "sep 11"
# TODO: preserve capitalization
#
sub abbreviate_dates {
    my($text) = @_;

    $text = &abbreviate($text, \%months);
    $text = &abbreviate($text, \%weekdays);
    return ($text);
}

# month_value(month): Returns numeric value of Month (e.g., July is 7).
# In technical terms, this is the 1-based index.
# EX: month_value("July") => 7
#
sub month_value {
    my($month) = @_;
    my($value) = 0;
    my($i);

    for ($i = 0; $i <= $#month_names; $i++) {
	if (index($month_names[$i], &to_lower("\t$month\t")) != -1) {
	     $value = $i + 1;
	 }
    }
    &debug_print(&TL_VERBOSE, "month_value(@_) => $value\n");

    return ($value);
}

# month_abbrev(month): returns abbreviation of n-th Month (e.g., 7 => jul).
# EX: month_abbrev(8) => "aug"
# TODO: name to something like month_name_abbrev; preserve capitalization
#
sub month_abbrev {
    my($value) = @_;
    my($month) = "???";

    if (($value > 0) && ($value <= ($#month_names + 1))) {
	$month = $month_names[$value - 1];
	$month =~ s/\t\S+\t(\S+)\t/$1/;
    }
    &debug_print(&TL_VERBOSE, "month_abbrev(@_) => $month\n");

    return ($month);
}

# format_assoc_data_aux(sort_routine, hash_ref, [max, freq_delim, entry_delim])
# Returns string representation for data stored in an associative array.
#
# NOTE: This routine is generally not used directly. See format_assoc_data,
# format_freq_data, and format_numeric_assoc_data
#
# EX: format_assoc_data_aux(\&sorted_hash_keys_reverse_numeric, {man => 33, the => 100, cat => 10}, 2, ":", ";") => "the:100;man:33"
# 
sub format_assoc_data_aux {
    my($sort_routine, $freq_assoc_ref, $max, $freq_delim, $entry_delim) = @_;
    &debug_print(&TL_VERBOSE, "format_assoc_data_aux(@_)\n");
    &debug_out(&TL_VERY_VERBOSE, "freq_assoc_ref=>%s\n", stringify($freq_assoc_ref));
    &assert((scalar %$freq_assoc_ref));

    $max = &MAXINT if (!defined($max));
    $freq_delim = "\t" if (!defined($freq_delim));
    $entry_delim = "\n" if (!defined($entry_delim));
    my(@formatted_data);

    my($count) = 0;
    my($key);
    foreach $key (&$sort_routine($freq_assoc_ref)) {
	push (@formatted_data, (sprintf "%s%s%s", $key, $freq_delim, $$freq_assoc_ref{$key}));
	last if (++$count >= $max);
    }

    return (join($entry_delim, @formatted_data));
}


# format_assoc_data(assoc_data_ref, [max, freq_delim, entry_delim])
# Returns string representation for a frequency list stored in a hash.
#
# EX: format_assoc_data({d => "dog", c => "cat", b => "bee"}) => "b\tbee\nc\tcat\nd\tdog"
# EX: format_assoc_data({joe => 87, steve => 101, tom => 55}) => "joe\t87\nsteve\t101\ntom\t55"
#
sub format_assoc_data {
    return (&format_assoc_data_aux(\&sorted_hash_keys_alphabetic, @_));
}


# format_freq_data(assoc_data_ref, [max, freq_delim, entry_delim])
# Returns a string representation for a frequency list stored in an associative array.
# EX: format_freq_data({joe => 87, steve => 101, tom => 55}) => "steve\t101\njoe\t87\ntom\t55"
# 
sub format_freq_data {
    return (&format_assoc_data_aux(\&sorted_hash_keys_reverse_numeric, @_));
}


# format_numeric_assoc_data(assoc_data_ref, [max, number_delim, entry_delim])
# Returns a string representation for a number list stored in an associative array.
# EX: format_numeric_assoc_data({joe => 87, steve => 101, tom => 55}) => "tom\t55\njoe\t87\nsteve\t101"
# 
sub format_numeric_assoc_data {
    return (&format_assoc_data_aux(\&sorted_hash_keys_numeric, @_));
}


# sorted_hash_keys_reverse_numeric(hash_ref): returns the keys of the hash table sorted
# by reverse numeric order of the values
#
# variants:
# sorted_hash_keys_numeric		keys sorted by numeric order of the values
# sorted_hash_keys_alphabetic		keys sorted by alphatic order of value
# sorted_hash_keys_numeric_keys		keys sorted by numeric order of value
#
# EX: sorted_hash_keys_reverse_numeric({joe => 87, steve => 101, tom => 55}) => ("steve", "joe", "tom")
#
sub sorted_hash_keys_reverse_numeric {
    # TODO: rename to sorted_hash_keys_reverse_numeric_value
    my($hash_ref) = @_;
    return sort { $$hash_ref{$b} <=> $$hash_ref{$a} } keys(%$hash_ref);
}

sub sorted_hash_keys_numeric {
    # TODO: rename to sorted_hash_keys_numeric_value
    my($hash_ref) = @_;
    return sort { $$hash_ref{$a} <=> $$hash_ref{$b} } keys(%$hash_ref);
}

sub sorted_hash_keys_alphabetic {
    # TODO: rename to sorted_hash_keys_alphabetic_keys
    my($hash_ref) = @_;
    return sort keys(%$hash_ref);
}

sub sorted_hash_keys_numeric_keys {
    my($hash_ref) = @_;
    return sort { $a <=> $b} keys(%$hash_ref);
}


# get_web_frequency(phrase, [type=""]): returns the web frequency for the phrase
# EX: (get_web_frequency("dog") > 1000000) => 1
# EX: (get_web_frequency("man") > get_web_frequency("gentleman")) => 1
#
sub get_web_frequency {
    my($phrase, $type) = @_;
    $type = "" if (!defined($type));
    my($freq) = 0;

    ## my($options) = "-bare";
    my($options) = "-bare -simple";
    $options .= " -search=$type" unless ($type eq "");
    $options .= " -altavista" if ($altavista);
    # Make sure negative occurrence indicator properly quoted (e.g., "dog -cat" to "dog \-cat").
    $phrase =~ s/((^)|( ))\-/$1\\\-/g;
    my($quote) = (index($phrase, "'") != -1) ? '"' : "'";
    my($result) = &run_command("web_freq.perl $options $quote$phrase$quote");
    if ($result =~ /^(\d+)/) {
	$freq = $1;
    }

    return ($freq);
}


# web_cooccurrence(phrase1, phrase2)
#
# returns measure of co-occurrence for the two terms in web searches, using
# either mutual information or the Dice coefficient
#
#   mutual information:
#	log2(P(X=1,Y=1) / P(X=1) * P(Y=1))
#
#   the Dice coefficient:
#	Dice(X,Y) = 2 * p(X=1,Y=1)/(p(X=1) + p(Y=1))
#
# EX: (web_cooccurrence("close", "proximity") > web_cooccurrence("near", "proximity")) => 1
#
sub web_cooccurrence {
    my($phrase1, $phrase2) = @_;
    &debug_print(&TL_VERBOSE, "web_cooccurrence(@_)\n");

    # Normalize the phrases (eg, convert spaces to AND's)
    $phrase1 =~ s/ \-/ \\\-/g;
    $phrase1 =~ s/\s+/ AND /g;
    $phrase2 =~ s/ \-/ \\\-/g;
    $phrase2 =~ s/\s+/ AND /g;

    # Do individual boolean queries for all combinations of the pair
    ## my($freq_X1_Y1) = &get_web_frequency("($phrase1) AND ($phrase2)", "boolean");
    ## my($freq_X1_Y0) = &get_web_frequency("($phrase1) AND (NOT ($phrase2))", "boolean");
    ## my($freq_X0_Y1) = &get_web_frequency("(NOT ($phrase1)) AND ($phrase2)", "boolean");
    ## my($freq_X0_Y0) = &get_web_frequency("(NOT ($phrase1)) AND (NOT ($phrase2))", "boolean");
    my($freq_X1_Y1) = &get_web_frequency("$phrase1 $phrase2", "all");
    my($freq_X1_Y0) = &get_web_frequency("$phrase1 -$phrase2", "all");
    my($freq_X0_Y1) = &get_web_frequency("-$phrase1 $phrase2", "all");
    # NOTE: Need dummy term to avoid no hits with -p1 -p2
    my($freq_X0_Y0) = &get_web_frequency("a -$phrase1 -$phrase2", "all");

    # Calculate the mutual information metric
    my($total_freq) = $freq_X1_Y1 + $freq_X1_Y0 + $freq_X0_Y1 + $freq_X0_Y0;
    $total_freq = 1 if ($total_freq == 0);
    my($prob_X) = (($freq_X1_Y1 + $freq_X1_Y0) / $total_freq);
    my($prob_Y) = (($freq_X1_Y1 + $freq_X0_Y1) / $total_freq);
    my($prob_XY) = ($freq_X1_Y1 / $total_freq);
    my($metric) = 0;

    # Determine the co-occurrence metric
    if ($use_MI) {
	my($MI) = 0;
	if (($prob_X > 0) && ($prob_Y > 0) && ($prob_XY > 0)) {
	    $MI = log($prob_XY / ($prob_X * $prob_Y)) / log(2);
	}
	$metric = $MI;
    }
    if ($use_dice) {
	my($dice) = 0;
	if (($prob_Y > 0) && ($prob_XY > 0)) {
	    $dice = 2 * $prob_XY / ($prob_X + $prob_Y);
	}
	$metric = $dice;
    }

    # Trace contingency table in format suitable for calc_multi_x2.perl
    if ($verbose) {
	printf "%d %d %d %d %s\n", $freq_X1_Y1, $freq_X1_Y0, $freq_X0_Y1, $freq_X0_Y0, join(" ", @_);
    }

    return ($metric);
}

# print_web_cooccurrence_header(): prints header for verbose information output by web_cooccurrence
# 
sub print_web_cooccurrence_header {
    if ($verbose) {
	printf "+A+B +A-B -A+B -A-B words\n";
    }
}


# read_frequencies(file, freq_list_ref, [freq_first=0])
# 
# Read in the frequencies from the frequency file, which has the key in 
# the first column followed by the count in the second.
#     <key><TAB><count>
# Blank lines are those starting with comments (either '#' or ';') are ignored.
#
# The result is stored in the associative array given in the second argument 
# (reference parameter), and the total frequency is the return value.
#
# NOTES:
# - Case is insignigicant for keys
# - If a key occurs more than once, the sum is used.
#
# EX: our(%freq); read_frequencies("/home/graphling/DATA/BNC/test-bnc-common-wordform.freq", \%freq) => 88770678
# EX: ($freq{"of"} > 1000000) => 1
# EX: ($freq{"of"} > $freq{"with"}) => 1
# EX: read_frequencies("/home/graphling/TOOLS/WORDNET-2.0/semcor/synset.freq", \%freq, &TRUE) => 228986
# EX: get_entry(\%freq, "V02454930") => 0
# EX: get_entry(\%freq, "v02454930") => 390
#
# TODO:
# - define get_frequency function
# - have option to preserve the case of keys
# - use separate tag for EX tests that aren't examples (eg, second two above)
#
sub read_frequencies {
    my($file, $freq_list_ref, $freq_first) = @_;
    $freq_first = &FALSE if (! defined($freq_first));
    &debug_print(&TL_DETAILED, "read_frequencies(@_): freq_first=$freq_first\n");

    if (! open(FREQ, "<$file")) {
        &error("unable to open frequency file: $file ($!)\n");
	return (0);
    }

    my($total_freq) = 0;
    while (<FREQ>) {
        &dump_line("freq: $_", &TL_MOST_VERBOSE);
        chomp;
        s/^[;\#].*//;			# strip comments
        next if (/^\s*$/);		# ignore blank lines
        my($key, $count) = split('\t', $_);
	if ($freq_first) {
	    ($count, $key) = split('\t', $_);
	}
        next if (!defined($key));
	$key = &to_lower($key);		# make sure key is lowercase

	${$freq_list_ref}{$key} = 0 if (!defined(${$freq_list_ref}{$key}));
        ${$freq_list_ref}{$key} += $count;
        $total_freq += $count;
    }
    close(FREQ);
    &debug_print(&TL_DETAILED, "total frequency is $total_freq\n");

    return ($total_freq);
}

# get_frequency(assoc, token, [default]): return frequency of TOKEN in ASSOC
# return DEFAULT (0) if not defined
# NOTE: insensitive case search used for key
#
# EX: our(%top_freq); read_frequencies("/home/graphling/DATA/BNC/top100-bnc-wordform.freq", \%top_freq); (scalar (keys %top_freq)) => 100
# EX: get_frequency(\%top_freq, "the") => 6187927
# EX: get_frequency(\%top_freq, "THE") => 6187927
#
# TODO: reconcile with get_freq in graphling.perl
#
sub get_frequency {
    my($hash_ref, $token, $default) = @_;
    $default = 0 unless (defined($default));

    &assert(scalar %$hash_ref);
    my($freq) = &get_entry($hash_ref, &to_lower($token), $default);
    &debug_print(&TL_VERY_DETAILED, "get_frequency(@_) => $freq\n");

    return ($freq);
}


# hash_key(key, num_buckets): hash function based on internal Perl hashing scheme
#
# from hv.h in Perl source distribution (version 5.6.1-2):
#
#  #define PERL_HASH(hash,str,len) \
#       STMT_START { \
#          register const char *s_PeRlHaSh = str; \
#          register I32 i_PeRlHaSh = len; \
#          register U32 hash_PeRlHaSh = 0; \
#          while (i_PeRlHaSh--) \
#              hash_PeRlHaSh = hash_PeRlHaSh * 33 + *s_PeRlHaSh++; \
#          (hash) = hash_PeRlHaSh + (hash_PeRlHaSh>>5); \
#      } STMT_END
#
# note: this produces too many conflicts perhaps due to faulty overflow handling
#
# EX: my($num_samples)=1000; my($num_buckets)=10; my(@bucket_count) = (0) x $num_buckets; for (my $i = 0; $i < $num_samples; $i++) { my($bucket) = &hash_key(rand() * 100000, $num_buckets); $bucket_count[$bucket]++; } my($stdev_listing) = &run_command_over("perl -Ssw sum_file.perl -stats", join("\n", @bucket_count)); my($stdev) = ($stdev_listing =~ /stdev = (\S+)/); my($mean)=($num_samples/$num_buckets); ($stdev/$mean < 0.125) => 1
#
# TODO:
# - simplify the above test via helper function for stdev
# - figure out a more principled threshold for the coefficient of variation (stdev/mean)
#
sub hash_key {
    my($key, $num_buckets) = @_;
    my($result) = 0;
    &debug_print(&TL_VERY_VERBOSE, "hash_key(@_)\n");

    # Require that all operations (in this block) be done using integer arithmetic
    use integer;

    my ($char);
    foreach $char (split(//, $key)) {
	&debug_out(&TL_VERY_VERBOSE, "temp result=%d ord(char)=%d\n", 
		   $result, ord($char));
	$result = (($result * 33) + ord($char));
	$result += &MAXINT if ($result < 0);
	## $result = -$result if ($result < 0);
    }
    $result += ($result / 32);
    $result += &MAXINT if ($result < 0);
    ## $result = -$result if ($result < 0);
    &debug_print(&TL_VERY_VERBOSE, "result=$result\n");

    return ($result % $num_buckets);
}

# get_user_response(prompt, [wait=1]): Display prompt to the user and return single-key response
# (echoing result to terminal).
# NOTE: This function is incompatible with <STDIN> style input (see sysread in manual).
# Use readline() instead for line input.
# TODO: have a separate function for prompt-less input (see get_next_char)
#
our($get_user_response_init) = &FALSE;
#
sub get_user_response {
    my($prompt, $wait) = @_;
    $wait = &TRUE if (!defined($wait));
    &debug_print(&TL_VERY_VERBOSE, "get_user_response(@_)\n");

    # Initialization so that Hotkey module only loaded if needed
    # note: this avoid problem with background processing of the scripts
    if (! $get_user_response_init) {
	&debug_print(&TL_VERBOSE, "using Hotkey\n");
	eval "use HotKey;";
	$get_user_response_init = &TRUE;
    }

    # Set stardard output, and error to be unbuffered
    # TODO: just do this once
    select(STDERR); $| = 1;
    select(STDOUT); $| = 1;

    # Display the prompt and get single-character response
    print $prompt;
    my($response) = "";
    my($done);
    do {
	$response = readkey();
	$done = &TRUE;

	# If terminal EOF is being ignored, reset the completion flag on null input
	# NOTE: This circumvents problems with readkey() on older Linux configurations
	&debug_out(&TL_MOST_VERBOSE, "readkey() => %s (%d)\n", $response, ord($response));
	if ($null_eof && (ord($response) == 0)) {
	    $done = (! $wait);
	}
    } while (! $done);
    print "$response\n";

    # Issue error and quit if end of file was encountered
    if (ord($response) == 0) {
	&exit("Unexpected end of file\n");
    }

    return ($response);
}

# get_next_char(): Returns next character from input or null if not ready
#
my($get_next_char_init) = &FALSE;
#
sub get_next_char {
    # Initialization so that ReadKey module only loaded if needed
    # note: this avoid problem with background processing of the scripts
    if (! $get_next_char_init) {
	&debug_print(&TL_VERBOSE, "using Term::ReadKey\n");
	eval "use Term::ReadKey;";
	$get_next_char_init = &TRUE;
    }

    # Read the character, defaulting to ""
    &ReadMode('cbreak');
    my($char) = &ReadKey(-1);
    $char = "" if (! defined($char));
    &ReadMode('restore');

    return ($char);
}

# get_boolean_response(prompt): Display yes/no type prompt and return TRUE is Y is
# pressed, requiring the user to enter only Y or N (case insensitive). 
# NOTE: The output is echoed.
#
sub get_boolean_response {
    my($prompt) = @_;
    my($OK) = &FALSE;
    &debug_print(&TL_VERY_VERBOSE, "get_boolean_response(@_)\n");

    for (;;) {
	my($response) = &get_user_response($prompt);
	if ($response =~ /[yn]/i) {
	    $OK = ($response =~ /y/i);
	    last;
	}
	print "\b";
    }

    return ($OK);
}

# get_numeric_response(prompt, min-value, max-value): Display prompt for numeric response
# and return value, requiring the user to enter a value in the specified range. 
# NOTE: The output is echoed.
#
sub get_numeric_response {
    my($prompt, $min, $max) = @_;
    my($choice) = ($min - 1);
    &debug_print(&TL_VERY_VERBOSE, "get_numeric_response(@_)\n");

    for (;;) {
	my($response) = &get_user_response("$prompt ($min-$max): ");
	if ($response =~ /^[0-9]+$/) {
	    if (($response >= $min) && ($response <= $max)) {
		$choice = $response;
		last;
	    }
	}
    }

    return ($choice);
}

# sub readline (prompt)
#
# Displays a prompt and then reads a line of characters from the STDIN, 
# which is return without the newline. The result is echoed to STDOUT.
# NOTE: This circumvents the problem with mixing readkey() and <STDIN>
#
sub readline {
    my($prompt) = @_;
    my($line) = "";
	my($char) = "";

    # Read the line a character at a time
    print $prompt;
    while ($char ne "\n") {
	$char = &readkey();
	$line .= $char;
    }
    chomp $line;
    print "$line\n";

    return ($line);
}

# normalize_numeric_array(list): convert an array of counts into relative percents
# EX: normalize_numeric_array(2, 1, 7) => (0.2, 0.1, 0.7)
# EX: normalize_numeric_array() => ()
#
sub normalize_numeric_array {
    my(@vector) = @_;
    my($sum) = 0.0;    

    for (my $i = 0; $i <= $#vector; $i++) {
	$sum += $vector[$i];
    }
    if ($sum > 0) {
	for (my $i = 0; $i <= $#vector; $i++) {
	    $vector[$i] = $vector[$i] / $sum;
	}
    }

    return (@vector);
}

# calc_entropy(dist_array): Calculate entropy for the distribution of values
# in the array
# EX: calc_entropy(0.5, 0.5) => 1
# EX: calc_entropy(0.1, 0.25, 0.6, 0.05) => 1.49046857073283
# EX: round(calc_entropy(0.1, 0.25, 0.6, 0.05) - 1.49) => 0.000
# EX: calc_entropy(0.0, 0.0, 1.0) => 0
#
sub calc_entropy {
    my(@dist) = @_;
    &debug_print(&TL_VERBOSE, "calc_entropy(@_)\n");
    my($entropy) = 0.0;
    my($max_prob) = 0.0;
    my($p_lg_p);
    my($prob);

    foreach $prob (@dist) {
	$max_prob = &max($prob, $max_prob);
	$p_lg_p = 0;
	if ($prob > 0) {
	    $p_lg_p = - $prob * log2($prob);
	}
	$entropy += $p_lg_p;
	&debug_out(&TL_VERBOSE, "p=%.3f; p lg(p)=%.3f\n", $prob, $p_lg_p);
    }
    &debug_out(&TL_VERBOSE, "entropy=%.3f\n", $entropy);

    return ($entropy);
}

# LN2(): constance for log_e of 2
#
sub LN2 { log(2); }

# log2(num): log_2 of number
#
# EX: log2(8) => 3
#
sub log2 {
    my($num) = @_;
    return (log($num) / LN2);
}

# current_year(): returns current year (e.g., 2005)
# EX: (index(&run_command(&asctime()), current_year()) > 0)
# TODO: use array for accessing localtime result
#
sub current_year {
    my(($second, $minute, $hour, $day, $month, $year, $week_day, $day_of_year, $is_DST)) = localtime();
    $year += 1900;

    &debug_print(&TL_VERY_VERBOSE, "current_year(@_) => $year\n");
    return ($year);
}

# current_timestamp(): alias for time()
# EX: (current_timestamp() > 1116442367)
#
sub current_timestamp {
    my($timestamp) = time();
    
    &debug_print(&TL_VERY_VERBOSE, "current_timestamp(@_) => $timestamp\n");
    return ($timestamp);
}

# derive_time_stamp(date_spec): Derive a time-stamp value from the ascii
# representation of a date.
# Returns number of (non-leapyear) seconds from 00:00:00 UTC, January 1, 1970.
# EX: derive_time_stamp("Sun, 1 Mar 1998 00:30:01 -0700 (MST)") => 888737401
#
# TODO:
# - make sure the patterns are precise as possible to avoid misinterpretation
# - add support for fully-spelled out weekday and month names
# - todo reconcile similar date cases to reduce redundancy
# - replace \w with [\D\S] (see if simpler specification for alphabetic)
#
sub derive_time_stamp {
    my($date) = @_;
    my($weekday, $mon, $mday, $year, $hour, $min, $sec) = (0,0,0,0,0,0,0);
    my($zone) = "";
    &debug_print(&TL_VERY_VERBOSE, "derive_time_stamp(@_)\n");

    # Check for  WWW[,] DD MMM YYYY HH:MM:SS
    # example: 'Sun, 01 Mar 1998 00:56:28'
    $date =~ s/,/ /;
    if ($date =~ /(\w\w\w)\s+(\d+)\s+(\w\w\w)\s+(\d{4}|\d{2})\s+(\d?\d):(\d\d):(\d\d)/) {
	$weekday = $1; $mday = $2; $mon = $3; $year = $4;
	$hour = $5; $min = $6; $sec = $7;
	&debug_print(&TL_VERY_DETAILED, "date format: WWW[,] DD MMM YYYY HH:MM:SS\n");
    }
    # Check for WWW[,] MMM DD HH:MM:SS YYYY
    # example: 'From tomohara@oleada Sun Mar  1 00:56:28 1998'
    elsif ($date =~ /(\w\w\w)\s+(\w\w\w)\s+(\d+)\s+(\d\d):(\d\d):(\d\d)\s+(\d{4})/) {
	$weekday = $1; $mday = $3; $mon = $2; $year = $7;
	$hour = $4; $min = $5; $sec = $6;
	&debug_print(&TL_VERY_DETAILED, "date format: WWW[,] MMM DD HH:MM:SS YYYY\n");
    }
    # Check for DD MMM YYYY HH:MM:SS
    # example: '18 JUL 1963 18:10:10'
    elsif ($date =~ /(\d+)\s+(\w\w\w)\s+(\d{4}|\d{2})\s+(\d?\d):(\d\d):(\d\d)/) {
	$weekday = "???"; $mday = $1; $mon = $2; $year = $3;
	$hour = $4; $min = $5; $sec = $6;
	&debug_print(&TL_VERY_DETAILED, "date format: DD MMM YYYY HH:MM:SS\n");
    }
    # Check for WWW MMM DD HH:MM:SS ZZZ YYYY
    # example: 'Sat Mar 22 13:00:21 MST 2003'
    # TODO: reconcile this with case 2 above
    elsif ($date =~ /(\w\w\w)\s+(\w\w\w)\s+(\d\d?)\s+(\d\d):(\d\d):(\d\d)\s+(\w\w\w)\s+(\d\d\d\d)/) {
	$weekday = $1; $mday = $3; $mon = $2; $year = $8; $zone = $7;
	$hour = $4; $min = $5; $sec = $6;
	&debug_print(&TL_VERY_DETAILED, "date format: WWW MMM DD HH:MM:SS ZZZ YYYY\n");
    }
    # Check for  WWW D+ MMM YY HH:MMxm
    # example: 'Sun 1 Mar 98 12:30am'
    elsif ($date =~ /(\w\w\w)\s+(\d+|\d\d)\s+(\w\w\w)\s+(\d{4}|\d{2})\s+(\d?\d):(\d\d)([ap]m)/i) {
	$weekday = $1; $mday = $2; $mon = $3; $year = $4;
	$hour = $5; $min = $6; my($am_pm) = $7;
	if ($am_pm =~ /PM/i) {
	    $hour += 12;
	}
	elsif ($hour == 12) {
	    $hour = 0;
	}
	&debug_print(&TL_VERBOSE, "date format: WWW D+ MMM YY HH:MMxm\n");
    }
    # Check for MM/DD/YYYY
    elsif ($date =~ /(\d{1,2})\/(\d{1,2})\/(\d{2,4})/i) {
	$mday = $2; $mon = $1; $year = $3;
	$hour = 0; $min = 0; $sec = 0;
	$mday = 1 if (!defined($mday) || !is_numeric($mday));
	&debug_print(&TL_VERY_DETAILED, "date format: MM/DD/YYYY\n");
    }
    # Check for [DD] MMM YYYY
    # TODO: make the time optional in the above patterns
    elsif ($date =~ /(\d*)\s*([a-z]{3,})\s+(\d{4}|\d{2})/i) {
	$mday = $1; $mon = $2; $year = $3;
	$hour = 0; $min = 0; $sec = 0;
	$mday = 1 if (!defined($mday) || !is_numeric($mday));
	&debug_print(&TL_VERY_DETAILED, "date format: [DD] MMM YYYY\n");
    }
    else {
	&error("Unrecognized date format in '$date' (derive_time_stamp)\n");
    }

    # Make sure the values are in the correct ranges (eg, months 1-12; full years)
    if (! &is_numeric($mon)) {
	$mon = &month_value($mon);
    }
    $mon--;
    &assert(($mon >= 0) && ($mon < 12));
    $year -= 1900 if ($year >= 1900);
##     if ($year < 1900) {
## 	# TODO: make option to control how two-digit years are interpretted
## 	if ($year < 50) {
## 	    $year += 2000;
## 	}
## 	else {
## 	    $year += 1900;
## 	}
##     }
    &debug_print(&TL_VERY_VERBOSE, "tf=(weekday, mon, mday, year, hour, min, sec, zone)\n");
    &debug_print(&TL_VERY_DETAILED, "tf=($weekday, $mon, $mday, $year, $hour, $min, $sec, $zone)\n");

    # Convert into a time-stamp value
    my($time) = 0;
    eval { $time = timelocal($sec,$min,$hour,$mday,$mon,$year); };
    $time = 0 if (!defined($time));
    &debug_print(&TL_VERY_DETAILED, "derive_time_stamp(@_) => $time\n");

    return ($time);
}


# stringify_value(value, [indent]): returns ascii representation of Perl value,
# which could include embedded references
# EX: my(@a_b_c) = ('a', 'b', 'c'); stringify_value(\@a_b_c) => "['a','b','c']"
# EX: stringify_value("a\nb\nc") => "a\nb\nc"
# NOTE: The dumper indentation is unset and then restored to current setting.
#
our($stringify_init) = &FALSE;
#
sub stringify_value {
    my($value, $indent) = @_;
    $indent = $stringify_indent if (!defined($indent));

    # Make sure Dumper module loaded
    if (! $stringify_init) {
	&debug_print(&TL_VERBOSE, "using Data::Dumper\n");
	eval "use Data::Dumper";
	$stringify_init = &TRUE;
    }

    # Change indentation
    my($old_indent) = $Data::Dumper::Indent;
    $Data::Dumper::Indent = $indent;

    # Get ascii representation of the value, ignoring variable part of the assignment 
    my($string_value) = Dumper($value);
    &debug_out(&TL_VERY_VERBOSE, "Dumper(%s) => '%s'\n",
	       (defined($value) ? $value : "undef"), $string_value);

    # Ignore 'VARn =' prefix
    $string_value =~ s/^\$VAR\d+ = ([^\000]*);$/$1/;

    # Restore indentation
    $Data::Dumper::Indent = $old_indent;

    return ($string_value);
}


# stringify: alias for stringify_value
# EX: $ENV{FUBAR}="666"; (index(stringify(\%ENV), "'FUBAR' => '666'") > 0) => 1
# EX-TODO: stringify(split(/ /, "a b c")) => ("a", "b", "c")
# NOTE: above doesn't work since Dumper doesn't process array arguments
#
sub stringify {
    return (&stringify_value(@_));
}


# max_label(labels_ref, values_ref, [default, min]): return label for max value
#
# EX: max_label(["a", "b", "c"], [9, 15, 8]) => "b"
# EX: max_label(["panzer", "tiger"], [45, 59]) => "tiger"
#
# TODO:
# - use &MINREAL as default
#
sub max_label {
    my($labels_ref, $values_ref, $default, $min) = @_;
    $default = "" if (!defined($default));
    $min = &MININT if (!defined($min));
    my($label) = $default;
    my($max) = $min;
    &trace_array($labels_ref, &TL_VERY_DETAILED, "labels");
    &trace_array($values_ref, &TL_VERY_DETAILED, "values");
    &assert($#$values_ref == $#$labels_ref);

    # Check each value against current max, updating max and label
    for (my $i = 0; $i <= $#$values_ref; $i++) {
	if ($max < $$values_ref[$i]) {
	    $max = $$values_ref[$i];
	    $label = $$labels_ref[$i];
	}
    }
    &debug_print(&TL_VERY_VERBOSE, "max_label(@_) => \"$label\"\n");

    return ($label);
}

#------------------------------------------------------------------------------


# return successful-load status
&init_extra();
&debug_print(&TL_VERBOSE, "extra.perl loaded OK\n");
1;
