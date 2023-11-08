# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# remove_sentences.perl: remove instances of the specified sentences from input
#
# TODO: make the command-line invocation more flexible
#       look into ways of speeding up the comparison
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

&init_var(*sentence_file, "sentence.list");
&init_var(*ratio_threshold, 0.75);


if ((defined($ARGV[0]) && ($ARGV[0] eq "help"))
    || (!defined($ARGV[0]) && &blocking_stdin())) {
    $options = "options = [-sentence_file=file] [-ratio=0.NN]";
    $example = "ex: $script_name -sentence_file=dso_dj11_771.stripped government.text\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
}

@sentences = split(/\n/, &read_file($sentence_file));

while (<>) {
    &dump_line();
    chop;
    $include = &TRUE;

    # See whether the current sentence should be removed
    foreach $sentence (@sentences) {
	if (&match_sentences($_, $sentence)) {
	    $include = &FALSE;
	    last;
	}
    }

    # Print the sentence unless filtered out
    print "$_\n" unless ($include == &FALSE);
}

#------------------------------------------------------------------------------

# match_sentences(sentence1, sentence2)
# 
# Determine whether the two sentences match with allowances for slight
# differences (default threshold of 75%).
#
sub match_sentences {
    local ($sent1, $sent2) = @_;
    &debug_print(6, "match(@_)\n");
    local($ok) = &FALSE;

    # Split the sentences into tokens delimited by whitespace
    local(@sent1) = &tokenize($sent1);
    local(@sent2) = &tokenize($sent2);
    if (($#sent1 < 0) ||  ($#sent2 < 0)) {
	return (&FALSE);	# don't match an empty sentence
    }
    
    # Count the number of matching words in each sentence
    local($pos2) = 0;
    local($i, $j);
    for ($i = 0; $i <= $#sent1; $i++) {
	for ($j = $pos2; $j <= $#sent2; $j++) {
	    if ($sent1[$i] eq $sent2[$j]) {
		$ok++;
		$pos2 = $j + 1;
		last;
	    }
	}
    }
    local($ok) = ((($ok / ($#sent1 + 1)) > $ratio_threshold)
		  && (($ok / ($#sent2 + 1)) > $ratio_threshold));

    return ($ok);
}

