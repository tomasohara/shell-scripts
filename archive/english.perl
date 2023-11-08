# english.perl: module for processing English text
#
# NOTE: this module should be able to co-exist w/ spanish.perl
#
# TODO:
# - reconcile with spanish.perl (eg, via generic-language-support.perl
# - add support for CRL resources (eg, Collins English-Spanish dictionary)
# - use a package (or class)
#

require 'wordnet.perl';

# Global variables (with command-line overrides):
#
$eng_word_chars = "\\w";
$eng_word_pattern = "([$eng_word_chars]+)([^$eng_word_chars])";
$eng_dict = get_env(ENGLISH_DICT, "c:\\Spanish\\Dictionary\\dict1.list")
    unless defined($eng_dict);
$eng_verb{"<conj>:<tense>"} = "<1ps> <2ps> <3ps> <1pp> <2pp> <3pp>";
$eng_trans{"<english_phrase>"} = "<spanish_translation>";
$eng_use_collins = &FALSE unless defined($eng_use_collins);
$eng_remove_diacritics = &TRUE unless defined($eng_remove_diacritics);
$eng_options = "[-eng_dict=file] [-eng_use_collins=0|1] [-_remove_diacritics=0|1]";

# Options for pretty printing (TODO: cleanup interface)
#
&init_var(*trans_listing, &FALSE);
&init_var(*ignore_phrasals, &FALSE);
&init_var(*just_once, &FALSE);
&init_var(*repeat_len, 40);
&init_var(*simple, &FALSE);		# don't show pronunciation, etc.
&init_var(*first_sense, &FALSE);	# just show first sense
&init_var(*first_trans, &FALSE);	# just show first translation
#
&init_var(*eng_trans_listing, $trans_listing);
&init_var(*eng_ignore_phrasals, $ignore_phrasals);
&init_var(*eng_just_once, $just_once);
&init_var(*eng_repeat_len, $repeat_len);
$eng_prefix = ($eng_trans_listing ? "\t" : "");



# eng_init(): initialize the english module
#
# The main task is to initialize the associae array giving verb conjugations.
#
sub eng_init {
    &debug_out(4, "eng_init(@_)\n");

    @eng_verb_suffixes = ("ed:", "es:", "ing:", "s:");
    @eng_adj_suffixes = ("er:", "ier:y", "est:", "iest:y");
    @eng_adv_suffixes = ("ly:");
}


# read_english_dict([dict]): Read in the English dictionary (derived from
# The Languages of the World CD from NTC) into an associative array. This 
# dictionary must have been preprocessed (see filter_dict.cxx & makehead.perl),
# so that the format is as follows:
#
#     key<TAB>phrase<TAB>translation
#
# sample:
#
# abadia	abadÌa		f. Abbey. 2 abbacy. 3 abbotship.1
# abajeno, -na	abajeÒo, -Òa 	adj. (Am.) lowland. 2 n. (Am.) lowlander.
# abajo		abajo		adv. down: boca ~abajo, face down; ...
#
# TODO: 
#     handle phrase expansion (eg, "boca ~" => "boca abajo")
#     add support for Collins English-Spanish dictionary
#

sub eng_read_dict {
    local ($dict) = @_;
    &debug_out(4, "eng_read_dict(@_)\n");

    # The collins dictionary is too large for practical in-memory usage
    # Therefore, lookup's are via external command invocations (see below)
    if ($eng_use_collins) {
	return;
    }

    $dict = $eng_dict unless (defined($dict));
    open (DICT, "<$dict") || die ("ERROR: unable to open $dict ($!)\n");
    while (<DICT>) {
	dump_line($_, 7);
	chop;

	($key, $phrase, $translation) = split(/\t/, $_);
	$phrase =~ s/\(to\)$//;
	$phrase =~ s/  *$//;
	$phrase = &eng_to_lower($phrase);

	# split phrase into subphrases based on alternate suffixes
	#     "ambulatorio, -ria"   adj. med. ambulatory.
	## $trans{$phrase} = $translation;
	@subphrases = split(/, */, $phrase);
	foreach $subphrase (@subphrases) {
	    if ($subphrase =~ /^\-(.*)/) {
		$suffix = $1;

		# When the suffix corresponds to an equal-sized suffix of the
		# main entry (eg, "rojo, -ja"), a direct replacement is made.
		# Otherwise, a partial replacement is done (eg, "actor, -ra").
		$len = length($subphrases[0]) - length($suffix);
		if (substr($subphrases[0], $len, 1) ne substr($suffix, 0, 1)) {
		    $len++;
		}
		$subphrase = substr($subphrases[0], 0, $len) . $suffix;
	    }
	    &eng_add_entry($subphrase, $translation);
	}
    }

    # Reset the file tracing (TODO: have common.perl do it automatically)
    &reset_trace();
}



# eng_add_entry(phrase, translation): add the translation to the dictionary
#
sub eng_add_entry {
    local ($phrase, $translation) = @_;

    &debug_out(7, "adding ($phrase, $translation)\n");
    if (defined($eng_trans{$phrase})) {
	$eng_trans{$phrase} .= "; $translation";
    }
    else {
	$eng_trans{$phrase} = $translation;
    }
}



# eng_lookup_word: lookup the translation for a word
#
# For the NTC-based dictionary, an associative array is used.
# For Collins, an external command is used, which can be very slow.
#
sub eng_lookup_word {
    local($word) = @_;
    local($translation) = "";

    if ($eng_use_collins) {
	# Invoke eng_lookup.perl to get the results. Ex:
	#    % english_lookup.perl hola
	#    hola	(hola) hullo!; hullo!, hey!, I say!; hullo?
	#
	$translation = &run_command("english_lookup.perl $word");
	$translation =~ s/\n/; /g;
	$translation =~ s/$word\t//g;
    }
    else {
	# Get the translation from the associative array.
	$translation = &eng_lookup_word_as_is($word);
	$translation = &eng_lookup_noun($word) unless ($translation ne "");
	$translation = &eng_lookup_verb($word) unless ($translation ne "");
	$translation = &eng_lookup_adj($word) unless ($translation ne "");
	$translation = &eng_lookup_adv($word) unless ($translation ne "");
	$translation = &eng_lookup_any($word) unless ($translation ne "");
    }
    &debug_out(5, "eng_lookup_word(@_) => %.20s...\n", $translation);

    return ($translation);
}


# eng_lookup_word_xyz(word): helper functions for lookup_word
#
# Lookup the word in the associative array, with optional stemming.
# First the word is checked as is. It is then stemmed is the initial 
# lookup fails.
# TODO: return multiple translations (eg, both verb & noun cases)
#

sub eng_lookup_word_as_is {
    local($word) = @_;
    local($translation) = "";
    &debug_out(6, "lookup_word_as_is(@_)\n");

    if (defined($eng_trans{$word})) {
	$translation = $eng_trans{$word};
    }

    return ($translation);
}

sub eng_lookup_verb {
    local($word) = @_;
    local($translation) = "";
    &debug_out(6, "eng_lookup_verb(@_)\n");

    ($root, $tense) = &eng_stem_verb($word);
    if (($root ne "") && (defined($eng_trans{$root}))) {
	$translation = "($root $tense) $eng_trans{$root}";
    }

    return ($translation);
}


sub eng_lookup_noun {
    local($word) = @_;
    local($translation) = "";
    &debug_out(6, "eng_lookup_noun(@_)\n");

    ($root, $person) = &eng_stem_noun($word);
    if (($root ne "") && (defined($eng_trans{$root}))) {
	$translation = "($root $person) $eng_trans{$root}";
    }

    return ($translation);
}


sub eng_lookup_adj {
    local($word) = @_;
    local($translation) = "";
    &debug_out(6, "eng_lookup_adj(@_)\n");

    ($root, $extra) = &eng_stem_adj($word);
    if (($root ne "") && (defined($eng_trans{$root}))) {
	$translation = "($root $extra) $eng_trans{$root}";
    }

    return ($translation);
}


sub eng_lookup_adv {
    local($word) = @_;
    local($translation) = "";
    &debug_out(6, "eng_lookup_adv(@_)\n");

    ($root, $extra) = &eng_stem_adv($word);
    # TODO: use my here are other places not declaring root
    if (($root ne "") && (defined($eng_trans{$root}))) {
	$translation = "$eng_trans{$root}";
    }

    return ($translation);
}



# eng_lookup_any(wordform): looks up wordform in the English->Spanish dictionary
# using WordNet to find the root wordform
#
sub eng_lookup_any {
    local($word) = @_;
    local($translation) = "";
    &debug_out(6, "eng_lookup_any(@_)\n");

    my($root) = &wn_get_root($word);
    if (($root ne "") && (defined($eng_trans{$root}))) {
	$translation = "$eng_trans{$root}";
    }

    return ($translation);
}



# eng_stem_word(word): return list of stems for the word including the word
# itself
#
sub eng_stem_word {
    local ($word) = @_;
    local ($stems) = "$word";
    local ($stem, $extra);

    ($stem, $extra) = &eng_stem_noun($word);
    $stems .= " " . $stem;

    ($stem, $extra) = &eng_stem_verb($word);
    $stems .= " " . $stem;

    ($stem, $extra) = &eng_stem_adj($word);
    $stems .= " " . $stem;

    ($stem, $extra) = &eng_stem_adv($word);
    $stems .= " " . $stem;
    &debug_out(5, "eng_stem_word(@_) => $stems\n");

    return ($stems);
}


# eng_stem_verb(word, [no_verify]): determine the root for the word and the tense
#
# TODO:
# - return alternative roots
# - add optional support for smorph.tcl if available
#
sub eng_stem_verb {
    local ($verb, $no_verify) = @_;
    local ($root, $tense) = ("", "");
    $no_verify = &FALSE unless(defined($no_verify));

    debug_out(99, "eng_verb_suffixes=@eng_verb_suffixes\n");
    ## ($root, $tense) = &eng_stem_generic($verb, *eng_verb_suffixes, $no_verify);
    ($root, $tense) = &eng_stem_generic2($verb, $no_verify, @eng_verb_suffixes);
    &debug_out(6, "eng_stem_verb(@_) => ($root, $tense)\n");

    return ( ($root, $tense) );
}


sub eng_stem_adj {
    local ($adj, $no_verify) = @_;
    local ($root, $extra) = ("", "");
    $no_verify = &FALSE unless(defined($no_verify));

##    ($root, $extra) = &eng_stem_generic($adj, *eng_adj_suffixes, $no_verify);
    ($root, $extra) = &eng_stem_generic2($adj, $no_verify, @eng_adj_suffixes);
    &debug_out(6, "eng_stem_adj(@_) => ($root, $extra)\n");

    return ( ($root, $extra) );
}


sub eng_stem_adv {
    local ($adv, $no_verify) = @_;
    local ($root, $extra) = ("", "");
    $no_verify = &FALSE unless(defined($no_verify));

    ## ($root, $extra) = &eng_stem_generic($adv, *eng_adv_suffixes, $no_verify);
    ($root, $tense) = &eng_stem_generic2($adv, $no_verify, @eng_adv_suffixes);
    &debug_out(6, "eng_stem_adv(@_) => ($root, $extra)\n");

    return ( ($root, $extra) );
}


# eng_stem_generic(word, suffixes [no_verify]): helper function to stem_verb, etc
#
sub eng_stem_generic {
    local ($verb, *suffixes, $no_verify) = @_;
    debug_out(7, "eng_stem_generic($verb, %s, $no_verify)\n", join(@suffixes));
    local ($root, $extra) = ("", "");
    $no_verify = &FALSE unless(defined($no_verify));

    foreach $suffix (@suffixes) {
	if ($verb =~ /^(.+)$suffix$/) {
	    local($stem) = $1;
	    &debug_out(6, "checking $stem\n");
	    if ($no_verify || defined($eng_trans{"$stem"})) {
		return ( ($stem, "$suffix") );
	    }
	    if ($no_verify || defined($eng_trans{"${stem}e"})) {
		return ( ("${stem}e", "$suffix") );
	    }
	}
    }

    return ( ("", "") );
}


sub eng_stem_generic2 {
    local ($verb, $no_verify, @suffixes) = @_;
    debug_out(7, "eng_stem_generic2($verb, $no_verify, @suffixes)\n");
    local ($root, $extra) = ("", "");
    $no_verify = &FALSE unless(defined($no_verify));

    foreach $suffix_pair (@suffixes) {
	local ($suffix, $replacement) = split(/:/, $suffix_pair);
	if ($verb =~ /^(.+)$suffix$/) {
	    local($stem) = $1;
	    &debug_out(6, "checking $stem\n");
	    if ($no_verify || defined($eng_trans{"$stem$replacement"})) {
		return ( ("$stem$replacement", "$suffix") );
	    }
	    if ($no_verify || defined($eng_trans{"${stem}e$replacement"})) {
		return ( ("${stem}e$replacement", "$suffix") );
	    }
	}
    }

    return ( ("", "") );
}


# eng_stem_noun(word, [no_verify]): remove plural endings for nouns
#
# TODO: verify words in dictionary
#       add optional support for smorph.tcl if available
#
sub eng_stem_noun {
    local ($noun, $no_verify) = @_;
    local ($root, $person) = ("", "");
    $no_verify = &FALSE unless(defined($no_verify));

    if ($noun =~ /(.*)es$/ && ($no_verify || defined($eng_trans{$1}))) {
	$person = "p";
	$root = $1;
    }
    elsif ($noun =~ /(.*)s$/ && ($no_verify || defined($eng_trans{$1}))) {
	$person = "p";
	$root = $1;
    }
    elsif ($noun =~ /(.*)ies$/ 
	   && ($no_verify || defined($eng_trans{"${1}y"}))) {
	$person = "p";
	$root = "${1}y";
    }

    return ( ($root, $person) );
}


# to_lower($text): convert the text to lowercase, accounting for
# diacritic marks
#

sub eng_to_lower {
    local ($text) = @_;

    $text =~ tr/A-Z¡…Õ”⁄—‹/a-z·ÈÌÛ˙Ò¸/;

    return ($text);
}


# eng_remove_diacritics($text): remove diacritic marks from the text
#

sub eng_remove_diacritics {
    local ($text) = @_;

    $text =~ tr/¡…Õ”⁄—‹·ÈÌÛ˙Ò¸/AEIOUNOaeiounu/;
    ## $key =~ s/[°!ø?]//; ???

    return ($text);
}


#------------------------------------------------------------------------------

# eng_init_pp([trans_listing=0], [ignore_phrasals=0])
#
# Initialize the pretty-printing component. The optional argument indicates
# whether the input is from a word translation listing rather than from
# the dictionary.
#
sub eng_init_pp {
    local($trans_listing, $ignore_phrasals) = @_;
    $trans_listing = &FALSE unless(defined($trans_listing));
    $ignore_phrasals = &FALSE unless(defined($ignore_phrasals));
    &debug_out(4, "init_pp($trans_listing, $ignore_phrasals)\n");

    $eng_trans_listing = $trans_listing;
    $eng_ignore_phrasals = $ignore_phrasals;
    $eng_prefix = ($eng_trans_listing == &TRUE) ? "\t" : "";
}


# eng_pp_entry(phrase, dictionary_entry)
#
# Pretty print the entry from the Spanish-English bilingual dictionary.
#
# global_varables:
#    $processed{<word>}		words already processed
#
sub eng_pp_entry {
    local($word, $entry) = @_;
    local($pp_text) = "";

    # Extract the homonym indicator (eg, "ser (2)")
    local($word_spec) = $word;
    if ($entry =~ /^ *(\([0-9]\)) */) {
	$word_spec .= " $1";
	$entry = $';
    }

    # Extract the (irregular) conjugation if present
    # TODO: remove the "Irreg." text
    local($conj) = "";
    if ($entry =~ /(\\ *)?Conjug\.?:? *(.*)/) {
	$entry = $`;
	$conj = $2;
    }
    &assert('defined($conj)');

    # Print the entry header
    $pp_text .= sprintf "${eng_prefix}${word_spec}\n" unless ($eng_trans_listing);


    # If the word was already processed, just show part of the entry
    if ($eng_just_once && defined($processed{$word})) {
	$entry = substr($entry, 0, $eng_repeat_len);
	$entry .= "\n$eng_prefix... (see above for rest)\n";
    }
    $processed{$word} = &TRUE;

    foreach $subentry (split(/;\t/, $entry)) {
	$pp_text .= &eng_pp_entry_aux($word, $subentry);
    }

    return ($pp_text);
}


# eng_pp_entry_aux(word, translation_entry): helper function for pp_entry
#
sub eng_pp_entry_aux {
    local($word, $entry) = @_;
    local($num, $next_num);
    local($pp_text) = "";

    # Print each sense of the word on a separate line
    local ($last_entry) = &FALSE;
    for ($num = 1; (!$last_entry); $num = $next_num) {
	if ($entry =~ /([\.\?\!\;]) *([0-9]+) /) {
	    $sense = $`;
	    $term_punct = ($first_sense ? "" : $1);
	    $next_num = $2;
	    $entry = $';
	    $last_entry = $first_sense;
	}
	else {
	    $sense = $entry;
	    $term_punct = "";
	    $last_entry = &TRUE;
	}
	&debug_out(6, "sense$num='$sense'\n");

	# Optionally, remove subsenses that involve phrasals
	if ($eng_ignore_phrasals) {

	    # Remove the subsenses starting at the phrasal
	    # TODO: make sure none of the subsenses apply to the word itself
	    $sense =~ s/^[^;:,]*~.*//;
	    $sense =~ s/[;:,][^;:,]*~.*//;

	    # See if the entire sense is for a phrasal; if so skip
	    if ($sense =~ /^ *$/) {
		next;
	    }	
	}

	# Remove pronunciation, etc. if simple listing
	if ($simple) {
	    $sense =~ s/\([^\)]+\)//g;	# no usage info (or stem info)
	    $sense =~ s/\[[^\]]+\]//g;	# no pronunciation
	    $sense =~ s/^\s*\w+\. //;		# no part of speech
	}

	# Optionally, remove all but first translation equivalent
	$sense =~ s/[.,:;].*// if ($first_trans);

	my($num_spec) = ($first_sense ? "" : "${num}. ");
	$sense =~ s/\s+/ /;
	$pp_text .= sprintf "${eng_prefix}${num_spec}${sense}${term_punct}\n";
    }

    # Prettyprint the optional conjugation
    $pp_text .= &eng_pp_conj($conj) unless (($conj eq "") || ($eng_trans_listing));

    # Print the entry trailer
    $pp_text .= sprintf "${eng_prefix}\n" unless ($first_sense);

    return ($pp_text);
}


# eng_pp_conj(conjugation)
#
# Pretty print the verb conjugation,
#
sub eng_pp_conj {
    local($conj) = @_;
    local($pp_text) = "";
    &debug_out(5, "pp_conj(@_)\n");

    # Perform fixup's to remove known consistencies in the entries
    # TODO: check all the tenses for this
    $conj =~ s/(Past\. p.) /$1: /i;
    $conj =~ s/\. (Imper|Past|Fut)/. | $1/gi;

    # Print each tense on a separate line
    $pp_text .= sprintf "${eng_prefix}Verb conjugations:\n";
    $subjunctive = &FALSE;
    while ($conj =~ /([^:|]+): ([^|]*)(\| )?/) {
	$tense = $1;
	$verb_forms = $2;
	$conj = $';

	# Make the verb-forms consistent
	#    Separate the singular forms from the plural ones by a tab
	#    Remove ", etc. " and trailing period
	#    TODO: try expanding the etc. cases
	$verb_forms =~ s/;/\t/g;
	$verb_forms =~ s/, *etc\.? *[,]?//g;
	$verb_forms =~ s/\.? *$//;

	# Add "Subj." prefix for subjunctive tenses
	if ($tense =~ /^Subj/i) {
	    $subjunctive = &TRUE;
	}
	if ($subjunctive && ($tense =~ /^(Imper[^f]|Past|Ger)/i)) {
	    $subjunctive = &FALSE;
	}
	if ($subjunctive && ($tense !~ /^Subj/)) {
	    $tense = "Subj. $tense";
	}

	# Split subjunctive-imperfective into two parts
	if ($tense =~ /^Subj.*Imperf/i) {
	    # Make the verb forms look like two entries
	    # TODO: make this cleaner
	    $verb_forms =~ s/ or /\n$tense Alt.\t/;
        } 

        # Make sure the senses each have six entries, except for participles
	if ($tense =~ /^Imper[^f]/i) {
	    $verb_forms = "n/a, $verb_forms";
	}

	# Print the forms for the tense
	$pp_text .= sprintf "${eng_prefix}$tense\t$verb_forms\n";
    }
    $conj =~ s/like [$eng_word_chars]+\.?//;
    if ($conj ne "") {
	&debug_out(3, "WARNING: extraneous conjugation text: '$conj'\n");
	$pp_text .= sprintf "${eng_prefix}extra: $conj\n";
    }

    return ($pp_text);
}


#------------------------------------------------------------------------------


# eng_extract_POS(current_part_of_speech, $sense_definition)
#
# Determines the part of speech category for the entry, defaulting to 
# current POS.
#
# NOTE: this uses traditional categories not fine-grained tags (eg, Treebank)
#

sub eng_extract_POS {
    local ($current_POS, $sense_def) = @_;
    local ($POS) = $current_POS;

    # Check for part-of-speech abbreviations (period required)
    if ($sense_def =~ /\W((V)|(Indic)|(vt)|(tr)|(intr)|(Pres)|(Imper))\./) {
	$POS = "verb";
    }
    elsif ($sense_def =~ /\W((adj))\./) {
	$POS = "adjective";
    }
    elsif ($sense_def =~ /\W((s)|(m)|(f))\./) {
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


# Initialize the module and return 1 for success
&eng_init();
1;
