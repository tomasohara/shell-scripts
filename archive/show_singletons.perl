# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# show_singletons.perl: list potential cases of a lexical gap, where there
# is a word in one language (the "singleton") that is only translated by
# a phrase in another
#
# examples:
#
# beaker  	s. copa o vaso de boca ancha. 2 quím. vaso de precipitados.
#
# zahorí  	person credited by the popular belief with the power to see hidden things
#
# Sample output:
#
#   [cartulina]	# f=5
#   cartulina#1: light or fine cardboard
#   cartulina#2: Bristol board
#   [casabe]	# f=1
#   casabe#1: cassava flour or bread
#   [casaca]	# f=2
#   casaca#1: old long coat
#   casaca#2: diplomat's coat
#   [casal]	# f=0
#   casal#1: country house
#   casal#2: ancestral mansion
#
# TODO: remove the alternative suffixes (use spanish.perl interface)
#       sort the output bu frequency
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

&init_var(*include_verbs, &FALSE);
&init_var(*spanish, &TRUE);
&init_var(*all_or_nothing, &FALSE);
&init_var(*freq_file, $spanish ? "spanish.freq" : "english.freq");
&init_var(*min_freq, 0);
&init_var(*min_words, 0);


if (defined($ARGV[0]) && ($ARGV[0] eq "help")) {
    $options = "options = [-min_freq=N] [-min_words=N] [-freq_file=name]";
    $example = "ex:\n$script_name -spanish=1 -all_or_nothing=1 >! spanish_singletons.list\n";
    $example .= "\n$script_name -min_freq=5 -min_words=4 -all_or_nothing=1 >! sp_sing.list\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
}


if ($spanish) {
    require 'spanish.perl';
    eval "*pp_entry = *sp_pp_entry";
    eval "*extract_POS = *sp_extract_POS";
    eval "*init_pp = *sp_init_pp";
    eval "*to_lower = *sp_to_lower";
    eval "*read_dict = *sp_read_dict";
    eval "*trans = *sp_trans";
}
else {
    require 'english.perl';
    eval "*pp_entry = *eng_pp_entry";
    eval "*extract_POS = *eng_extract_POS";
    eval "*init_pp = *eng_init_pp";
    eval "*to_lower = *eng_to_lower";
    eval "*read_dict = *eng_read_dict";
    eval "*trans = *eng_trans";
}

&init_pp(&TRUE, &TRUE);		# translation listing & ignore phrasals

&read_dict();
&read_frequencies($freq_file, *frequency);

foreach $phrase (keys(%trans)) {
    $translation_text = $trans{$phrase};

    # Lookup the word's frequency and filter out if lower than threshold
    $word_frequency = &get_entry(*frequency, $phrase, 0);
    &debug_out(6, "p='%s'\tf=%d\tt='%s'\n", 
	       $phrase, $word_frequency, $translation_text);
    if ($word_frequency < $min_freq) {
	next;
    }

    # Drop the optional pronunciation
    #      able    [ei'bl]  adj. que puede: to be ~able, poder. 
    $translation_text =~ s/\[[^\[\]]+\] +//; 

    # Get a pretty-printed version of the translation/definition
    $entries = &pp_entry($phrase, $translation_text);
    &debug_out(9, "pp_entry($phrase, _) = {\n$entries}\n");
    $entries =~ s/^[^\t]+\t//; 		# drop the word itself

    # Check for singletons in each definition
    $last_POS = "";
    $cases = "";
    $sense_num = 0;
check_entries:
    foreach $subentry (split(/\n\n/, $entries)) {
	foreach $sense_def (split(/\n/, $subentry)) {
	    next if ($sense_def =~ /^\s*$/);

	    $POS = &extract_POS($last_POS, $sense_def);
	    $last_POS = $POS;
	    if (($POS eq "verb") && ($include_verbs == &FALSE)) {
		&debug_out(4, "skipping verb sense of $phrase\n");
		next;
	    }

	    $sense_def =~ s/\.[;]? *$//;	# drop trailing period
	    $sense_def =~ s/^[ \t]*[0-9]+\. //;	# drop sense indicator
	    $sense_def =~ s/ *\([^\(\)]+\) *//; # remove parentheticals
	    $sense_def =~ s/:?[^:]+~.*//; 	# ignore phrasals
	    foreach $trans (split(/[:;,]/, $sense_def)) {
		$trans =~ s/\. \./\./g;		# remove extraneous period
		# TODO: have separate transformations for each language
		$trans =~ s/((y )?[-a-z\.]+\. )+//; # remove parts-of-speech, etc.
		$trans =~ s/^to be //;		# to be X ... => X
		$trans =~ s/^to //;		# remove inf. prefix
		&debug_out(5, "trans='%s'\n", $trans);

		# Remove extraneous spaces, and consider as a singleton if
		# the number of words exceeds the threshold
		$trans =~ s/^ +//;		# remove leading space
		$trans =~ s/ +$//;		# remove trailing space
		@words = split(/\s+/, $trans);
		if ($#words >= $min_words) {
		    $sense_num++;
		    $cases .= "${phrase}#${sense_num}: $trans\n";
		}
		else {
		    if ($all_or_nothing) {
			$cases = "";
			last check_entries;
		    }
		}
	    }

	}

    }

    # Output the entry unless empty. Ex:
    #     [sobreceja]	# f=0
    #     sobreceja#1: part of the forehead over the eyebrows
    #
    if ($cases ne "") {
	## printf "%s\t%s\n", $phrase, $cases;
	$key = sprintf "%05d:%s", $word_frequency, $phrase;
	$sing_trans{$key} = $cases;
	## printf "[%s]\t# f=%d\n", $phrase, $word_frequency;
	## printf "%s", $cases;
    }
}

# Display the singleton cases sorted in descending order by frequency
#
foreach $freq_phrase (sort(keys(%sing_trans))) {
    ($freq, $phrase) = split(/:/, $freq_phrase);
    printf "[%s]\t# f=%d\n", $phrase, $freq;
    printf "%s", $sing_trans{$freq_phrase};
}


#------------------------------------------------------------------------------

# read_frequencies(file, assoc_array): read in frequencies from the file
# TODO: put into common
#
sub read_frequencies {
    local($file, *frequency) = @_;
    local($count) = 0;

    if (!open(FREQ, $file)) {
	&debug_out(2, "warning: unable to open $file\n");
	return (0);
    }
    &debug_out(3, "reading frequencies from $file\n");
    while (<FREQ>) {
	local($word, $freq) = split;
	$word = &to_lower($word);
	&incr_entry(*frequency, $word, $freq);
    }
    close(FREQ);

    return ($count);
}
