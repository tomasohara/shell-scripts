# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# make_lexicon.perl: convert from NTC's Spanish-English dictionary
# (using preprocessed version: see filter_dict.cxx & makehead.perl).
#
# TODO: filter out alphabetic letters
#       add fix-ups

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';
# TODO: require 'spanish.perl';

while (<>) {
    &dump_line($_, 8);
    ($key, $phrase, $def) = split(/\t/, $_);
    &debug_out(7, "k=$key p=$phrase d=$def\n");

    # Remove extraneous text from definition
    $def =~ s/ *\([^\(\)]+\) *//g;  	# Remove parentheticals
    $def =~ s/[a-z]+ //g;		# drop words that aren't abbrev's

    # Remove collocation indicators from the phrase (eg, 
    $phrase =~ s/ \([a-z ]+\)//ig;

    # Determine all the part-of-speech tags that are applicable
    $POS_tags = " ";
    $POS_tags = $POS_tags{$phrase} if (defined($POS_tags{$phrase}));
    $POS = "";
    foreach $sense (split(/[0-9]+\./, $def)) {
	$POS = &extract_POS($POS, $sense);
	$penn_tag = &convert_pos_tag($POS);
	if ($POS_tags !~ / $penn_tag /) {
	    $POS_tags .= "$penn_tag ";
	}
    }
    $POS_tags{$phrase} = $POS_tags;
}

# Print the lexicon:
# word  tags
#
foreach $phrase (sort(keys(%POS_tags))) {
    # Print the word plus all the tags.
    # (Include derived words, such as feminine adjectives.)
    if ($POS_tags{$phrase} =~ /^ *$/) {
	next;
    }
    foreach $subphrase (&expand_subphrases($phrase)) {
	print "$subphrase $POS_tags{$phrase}\n";
    }
}


#------------------------------------------------------------------------------


# extract_POS(current_part_of_speech, sense_definition)
#
# Determines the part of speech for the entry, defaulting to current POS.
#
# TODO: place in spanish.perl
#
sub extract_POS {
    local ($current_POS, $sense_def) = @_;
    local ($POS) = $current_POS;

    # Check for part-of-speech abbreviations (period required)
    $sense_def = " $sense_def";
    if ($sense_def =~ /\W((V)|(Indic)|(vt)|(tr)|(intr)|(Pres)|(Imper))\./) {
	$POS = "verb";
    }
    elsif ($sense_def =~ /\W((adj))\./) {
	$POS = "adjective";
    }
    elsif ($sense_def =~ /\W(pr\. n)\./) {
	$POS = "proper_noun";
    }
    elsif ($sense_def =~ /\W((m)|(f))\./) {
	$POS = "noun";
    }
    elsif ($sense_def =~ /\W((adv))\./) {
	$POS = "adverb";
    }
    elsif ($sense_def =~ /\W((prep))\./) {
	$POS = "preposition";
    }
    elsif ($sense_def =~ /\W((art))\./) {
	$POS = "article";
    }
    elsif ($sense_def =~ /\W((pron))\./) {
	$POS = "pronoun";
    }
    elsif ($sense_def =~ /\W((conj))\./) {
	$POS = "conjunction";
    }
    &debug_out(7, "$POS <= extract_POS($current_POS, $sense_def)\n");

    return ($POS);
}


# init_tags(): initialize correspondences between post and penn tags
#
sub init_tags {

    %penn_tag = ("verb", "VB",
		 "noun", "NN",
		 "adjective", "JJ",
		 "adverb", "RB",
		 "preposition", "IN",
		 "article", "DT",
		 "pronoun", "PP",
		 "proper_noun", "NNP",
		 "conjunction", "CC",
		 "", "");
    return;
}


# convert_pos_tag(POS_tag)
#
# Convert from traditional part-of-speech tag into Penn Treebank's.
# TODO: reconcile with convert_spost_tag from spost2penn.perl
#
sub convert_pos_tag {
    local ($tag) = @_;
    local ($penn_tag) = "UNK";
    init_tags() if (!defined($penn_tag{"verb"}));

    if (defined($penn_tag{$tag})) {
	$penn_tag = $penn_tag{$tag};
    }
    &debug_out(5, "convert_pos_tag($tag) => $penn_tag\n");

    return ($penn_tag);
}


# expand_subphrases(phrase): split multiphrase headwords into subphrases
#
# ex: derive_subphrase("rojo, -ja") => ("rojo", "roja")
#     derive_subphrase("Tomás") => ("Tomás")
#
# TODO: add to spanish.perl
#
sub expand_subphrases {
    local ($phrase) = @_;
    local (@subphrases) = ();

    # split phrase into subphrases based on alternate suffixes
    #     "ambulatorio, -ria"   adj. med. ambulatory.
    $num = 0;
    ## $phrase =~ s/([^,]) -/$1, -/g; 	# fixup alternative spec's
    $phrase =~ s/,? -/,-/g; 		# fixup alternative spec's
    $phrase =~ s/, /,/g;
    foreach $subphrase (split(/[;,]+/, $phrase)) {
	if ($subphrase =~ /^\-(.*)/) {
	    $suffix = $1;

	    # When the suffix corresponds to an equal-sized suffix of the
	    # main entry (eg, "rojo, -ja"), a direct replacement is made.
	    # Otherwise, a partial replacement is done (eg, "actor, -ra").
	    &debug_out(6, "subphr[0]='$subphrases[0]' suffix='$suffix'\n");
	    $len = length($subphrases[0]) - length($suffix);
	    if ((length($suffix) > 1) && (substr($subphrases[0], $len, 1) 
					  ne substr($suffix, 0, 1))) {
		$len++;
	    }
	    $subphrase = substr($subphrases[0], 0, $len) . $suffix;
	}
	$subphrases[$num++] = $subphrase;
    }
    &debug_out(7, "expand_subphrases($phrase) => (@subphrases)\n");

    return (@subphrases);
}
