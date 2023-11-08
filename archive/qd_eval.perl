# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# qd_eval.perl: quick & dirty evaluation of align_word.perl results
#
# NOTE: Mark Davis has serious misgivings about this type of evaluation
#
# sample input (condensed somewhat):
# 
# word1		 joint	 	  dice	 	    MI	 	    g2	 
# after	después	 0.013	después	 0.391	después	 0.037	después  3.582	
#	cuando	 0.003	días	 0.087	días	 0.002	días	 1.509	
#	todo	 0.003	esto	 0.064	oh	 0.001	esto	 0.902	
#	días	 0.003	fue	 0.060	esto	 0.001	fueron	 0.839	
#	una	 0.003	fueron	 0.060	fueron	 0.000	fue	 0.608	
# again	diciendo 0.002	diciendo 0.071	diciendo 0.001	después	 1.335	
#	después	 0.002	después	 0.063	después	 0.001	diciendo 1.316	
#	mí	 0.001	vino	 0.048	vino	 0.000	vino 	 1.240	
#	jesús	 0.001	jesús	 0.047	jesús	 0.000	luego	 1.045	
#	qué	 0.001	mí	 0.045	palabra	 0.000	palabra	 0.997	
#
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';
require 'spanish.perl';
require 'english.perl';


sub usage {
    local ($program_name) = $0;
    $program_name =~ s/\.?\.?\/.*\///;

    select(STDERR);
    print <<USAGE_END;

Usage: $program_name [options] word_list ...

options = [-spanish=0|1] $sp_options $eng_options 

Evaluates the results of the word alignment.

example: 

nice +19 perl -Ssw $program_name -spanish=0 eng2span.list >&! eng2span.eval &

USAGE_END

    exit 1;
}


# If command line arguments are missing, give a usage message.
# $#ARGV = (# of arguments) - 1

if (($#ARGV < 0) && &blocking_stdin()) {
    &usage();
}

$spanish = &FALSE unless defined($spanish);
$TOPN = 5 unless defined($TOPN);
$NUM_METRICS = 7 unless defined($NUM_METRICS);


# Initialize the array used for the counts by rank and metric
#
#   $ok{<rank_metric>}	count of successful matches at rank i for metric m
#   $accum[<metric>]	accumulation of successful matches over all ranks
#
for ($m = 1; $m <= $NUM_METRICS; $m++) {
    $accum[$m] = 0;
    for ($r = 1; $r <= $TOPN; $r++) {
	$ok{"$r:$m"} = 0;
    }
}



# Read in both the Spanish-English & English-Spanish dictionaries
# NOTE: this is a no-op if smorph/collins used

&sp_read_dict();
&eng_read_dict();
$sp_stop_list = " a de del en el él la las les lo los que un una si su y ";
$eng_stop_list = " a and he him his i in is no of that the to was which who with ";
if ($spanish) {
    $stop_list = $sp_stop_list;
    $other_stop_list = $eng_stop_list;
    $word_chars = $eng_word_chars;
}
else {
    $stop_list = $eng_stop_list;
    $other_stop_list = $sp_stop_list;
    $word_chars = $sp_word_chars;
}

## @ok = (0, 0, 0, 0, 0);
$count = 0;
$ignored = 0;
local($word1, $translation) = ("", "");
$rank = 1;
while (<>) {
    &dump_line($_, 5);
    if (/ *#/) {
	print;
	next;
    }

    ## local ($word1, $joint, $MI, $old_MI, $x2, $g2) = split(/\t/, $_);
    @results = split(/\t/, $_);

    # Lookup the word's translation in the dictionary
    if (defined($results[0]) && ($results[0] ne "")) {
	$word1 = $results[0];
	$translation = &lookup_word($word1);
	$rank = 1;
	$count++;
    }
    else {
	$rank++;
	&assert('$rank <= $TOPN');
    }

    # If the word is on the stop list, then ignore it
    if ($stop_list =~ /" $word1 "/) {
	&debug_out(4, "Ignorning stop-list word $word1\n");
	$ignored++;
	next;
    }

    # For each metric see if the best word occurs in the translation
    # The metric score is ignored (TODO: strip from the input beforehand)
    $ok_str = ($rank == 1) ? "$word1" : "";
    for ($i = 1, $m = 1; $i < $#results; $i += 2, $m++) {
	$word2 = $results[$i];
	
	# Try to find any of the plausible stems for the given translation
	# in the actual translation
	$found = &FALSE;
	foreach $stem (split(/[ ]+/, &stem_other($word2))) {
	    &debug_out(5, "checking stem=$stem\n");

	    # The translation is good if its stem is not on the stop list
	    # and it occurs within the definition for the phrase.
	    # TODO: try to account for translations that are on stop list
	    if ((index($other_stop_list, " $stem ") == -1)
		&& ($translation =~ /[^$word_chars]$stem[^$word_chars]/)) {
		$found = &TRUE;
		last;
	    }
	}

	$ok_str .= "\t$word2\t$found";
	if ($found) {
	    &debug_out(5, "$word1 to $word2 ok; r=$rank m=$m\n");
	    $ok{"$rank:$m"}++;
	}
	else {
	    &debug_out(5, "$word1 to $word2 bad\n");
	}
    }

    print "${ok_str}\n";
}

# Display the overall results
#
debug_out(3, "count=$count; ignored=$ignored\n");
for ($r = 1; $r <= $TOPN; $r++) {
    print "$r\t"; 
    for ($m = 1; $m <= $NUM_METRICS; $m++) {
	$accum[$m] += $ok{"$r:$m"};
	printf "\t%.3f (%.3f)", 
	       ($ok{"$r:$m"} / $count), ($accum[$m] / $count);
    }
    print "\n";
}


#------------------------------------------------------------------------------


sub lookup_word {
    local($word) = @_;
    local($translation) = "";

    if ($spanish) {
	$translation = &sp_lookup_word($word);
    }
    else {
	$translation = &eng_lookup_word($word);
    }

    return ($translation);
}


sub stem_other {
    local($word) = @_;
    local($stems) = "";

    if ($spanish) {
	$stems = &eng_stem_word($word);
    }
    else {
	$stems = &sp_stem_word($word);
    }

    return ($stems);
}
