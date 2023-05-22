# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -s
#
# spanish.perl: module for processing Spanish text
#
# NOTE:
# - This module should be able to co-exist w/ english.perl.
# - POS is an abbreviation for part-of-speech (and part of speech).
#
# TODO:
# - add support for CRL-like resources (eg, Collins Spanish-English dictionary)
# - use a package (or class)
# - drop collocation indicators in heads (eg, "rojo (mar)" => "rojo")
#   $ perlgrep "\) *\t" $SPANISH_DICT | wc
#   105    1085    6952
#   $ wc $SPANISH_DICT
#   38242  417246 2920560 /e/tom/MultiLingual/Spanish/spanish_english.dict
# - handle adverbs as in the english version (english.perl)
# - handle z pluralization (eg "raíz" => "raices")
# - use freuquency to detect unlikely translations (e.g., English freq.)
# - fix pretty printing of adjectives
# - fix problem w/ carino (just carenar 1ps shown) and carinosa (diacritic related? cariño & cariñosa work OK)
# -  expand conjugated-like entries (e.g., 'detener tr. to detain ... Conjug. like tener.')
# - track down problem looking up 'pies' (just shows verb)
# - handle z -> c for plurals (e.g., nuez/nueces and pez/peces)
# - fix problem with 'está' (pronoun)
# - fix huyen => huir lookup
# - Add translation of pronoun suffix (e.g., hablalo => hablar (pres_ind:3ps) & lo (him)).
#
# Copyright (c) 2005-2019 Tom O'Hara and New Mexico State University.
# Freely available via GNU General Public License (see GNU_public_license.txt).
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';
use vars qw/$utf8/;

# HACK: add optional utf8 decoding support (modelled after count_it.perl)
if ($utf8) {
    use Encode 'decode_utf8';
}

# Global variables (with command-line overrides):
# TODO: strictify this module
#
$sp_word_chars = "\\wáéíóúñü-";
$sp_word_pattern = "([$sp_word_chars]+)([^$sp_word_chars])";
@number_indicator = ("n/a", "1ps", "2ps", "3ps", "1pp", "2pp", "3pp");
$sp_verb{"<conj>:<tense>"} = "<1ps> <2ps> <3ps> <1pp> <2pp> <3pp>";
$sp_trans{"<spanish_phrase>"} = "<english_translation>";
&init_var(*sp_suffix, &FALSE);	# allow suffixes
## OLD: $sp_use_collins = &FALSE unless defined($sp_use_collins);
&init_var(*sp_use_collins, &FALSE);
## OLD: $sp_remove_diacritics = &FALSE unless defined($sp_remove_diacritics);
&init_var(*sp_remove_diacritics, &FALSE);
$sp_options = "[-sp_dict=file] [-sp_suffix] [-sp_use_collins=0|1] [-sp_remove_diacritics=0|1]";
## OLD: $sp_test = &FALSE unless (defined($sp_test));
&init_var(*sp_test, &FALSE);

# Options for pretty printing (TODO: cleanup interface)
#
&init_var(*trans_listing, &FALSE);
&init_var(*ignore_phrasals, &FALSE);
&init_var(*just_once, &FALSE);
&init_var(*repeat_len, 40);
#
&init_var(*sp_trans_listing, $trans_listing);
&init_var(*sp_ignore_phrasals, $ignore_phrasals);
&init_var(*sp_just_once, $just_once);
&init_var(*sp_repeat_len, $repeat_len);
&init_var(*simple, &FALSE);		# don't show pronunciation, etc.
&init_var(*first_sense, &FALSE);	# just show first sense
&init_var(*first_trans, &FALSE);	# just show first translation
&init_var(*subsenses, &FALSE);		# isolate subsenses 
#
$sp_prefix = ($sp_trans_listing ? "\t" : "");
&init_var(*show_suffix, &FALSE);	# show stem; TODO: use sp_show_suffix
&init_var(*sp_skip_irreg_verb, &FALSE); # skip irregular verb inflections
&init_var(*strip_conj, &FALSE);		# remove (irregular) verb conjugation info

# If suffixes are allowed (e.g., "-amos") then grep a dummy word for
# the dash
# see sp_stem_verb_aux
if ($sp_suffix) {
    $sp_trans{"-"} = "<suffix>";
    $sp_trans{"-ar"} = "";
    $sp_trans{"-er"} = "";
    $sp_trans{"-ir"} = "";
}

if ($sp_test) {
    ## OLD: $sp_dict = "${script_dir}/sp_test.dict" unless defined($sp_dict);
    ## OLD: $sp_irreg_dict = "${script_dir}/sp_test_irreg.dict" unless defined($sp_irreg_dict);
    &init_var(*sp_dict, "${script_dir}/sp_test.dict");
    &init_var(*sp_irreg_dict, "${script_dir}/sp_test_irreg.dict");
}
else {
    ## OLD: $sp_dict = &get_env(SPANISH_DICT, "${script_dir}/spanish_english.dict") unless defined($sp_dict);
    ## OLD: $sp_irreg_dict = &get_env(SPANISH_IRREG_DICT, "${script_dir}/spanish_irregular.dict") unless defined($sp_irreg_dict);
    &init_var(*sp_dict, &get_env(SPANISH_DICT, "${script_dir}/spanish_english.dict"));
    &init_var(*sp_irreg_dict, &get_env(SPANISH_IRREG_DICT, "${script_dir}/spanish_irregular.dict"));
}

# sp_init(): initialize the spanish module
#
# The main task is to initialize the associate array giving verb conjugations.
# TODO: have alternative verb conjugations
# TODO: add support for irregular verbs
#
sub sp_init {
    &debug_print(4, "sp_init(@_)\n");

    @sp_verb_tenses = ("pres_ind", "pret_ind", "fut_ind", "imp_ind", 
		       "pres_cond", "pres_subj", "fut_subj",  "imp_subj");

    $sp_verb{"ar:pres_ind"} = "o as a amos áis an";
    $sp_verb{"ar:pret_ind"} = "é aste ó amos asteis aron";
    $sp_verb{"ar:imp_ind"} = "aba abas aba ábamos abais aban";
    ## $sp_verb{"ar:imp_ind"} =  "ía ías ía íamos íais ían";
    $sp_verb{"ar:fut_ind"} = "aré arás ará aremos aréis arán";
    $sp_verb{"ar:pres_cond"} =  "aría arías aría aríamos aríais arían";
    $sp_verb{"ar:pres_subj"} = "e es e emos 'eis en";
    $sp_verb{"ar:imp_subj"} = "ara aras ara áramos arais aran";
    $sp_verb{"ar:fut_subj"} = "are ares are áremos areis aren";

    $sp_verb{"er:pres_ind"} = "o es e emos éis en";
    $sp_verb{"er:pret_ind"} = "í iste ió imos isteis ieron";
    $sp_verb{"er:imp_ind"} = "ía ías ía íamos íais ían";
    $sp_verb{"er:fut_ind"} = "eré erás erá eremos eréis erán";
    $sp_verb{"er:pres_cond"} =  "ería erías ería eríamos eríais erían";
    $sp_verb{"er:pres_subj"} = "a as a amos áis an";
    $sp_verb{"er:imp_subj"} = "iera ieras iera iéramos ierais ieran";
    $sp_verb{"er:fut_subj"} = "iere ieres iere iéremos iereis ieren";

    $sp_verb{"ir:pres_ind"} = "o es e imos ís en";
    $sp_verb{"ir:pret_ind"} = "í iste ió imos isteis ieron";
    $sp_verb{"ir:imp_ind"} = "ía ías ía íamos íais ían";
    $sp_verb{"ir:fut_ind"} = "iré irás irá iremos iréis irán";
    $sp_verb{"ir:pres_cond"} =  "iría irías iría iríamos iríais irían";
    $sp_verb{"ir:pres_subj"} = "a as a amos áis an";
    $sp_verb{"ir:imp_subj"} = "iera ieras iera iéramos ierais ieran";
    $sp_verb{"ir:fut_subj"} = "iere ieres iere iéremos iereis ieren";

    $sp_verb{"ar:past_part"} = "ado ada ados adas";
    $sp_verb{"er:past_part"} = "ido ida idos idas";
    $sp_verb{"ir:past_part"} = "ido ida idos idas";

    $sp_verb{"ar:pres_part"} = "ando";
    $sp_verb{"er:pres_part"} = "iendo";
    $sp_verb{"ir:pres_part"} = "iendo";

    # Specify list of irregular verbs that shouldn't be derived via 
    # conjugation rules;
    # TODO: flush out the list; also, make sure all the inflections are
    # specified in the irregular dictionary
    $sp_irreg_verbs = ($sp_skip_irreg_verb ? " dar ir ser " : "");

    # TODO: handle pronouns separately
    # $sp_verb{":refl"} = "me te le nos os se";
    @sp_pronouns = split(/ /, "me te le lo la se nos os los las se les");
}


# sp_read_dict([dict]): Read in the Spanish dictionary (derived from
# The Languages of the World CD from NTC) into an associative array. This 
# dictionary must have been preprocessed (see filter_dict.cxx & makehead.perl),
# so that the format is as follows:
#
#     key<TAB>phrase<TAB>translation
#
# sample:
#
# abadia	abadía		f. Abbey. 2 abbacy. 3 abbotship.1
# abajeno, -na	abajeño, -ña 	adj. (Am.) lowland. 2 n. (Am.) lowlander.
# abajo		abajo		adv. down: boca ~abajo, face down; ...
#
# TODO: 
#     handle phrase expansion (eg, "boca ~" => "boca abajo")
#     add support for Collins Spanish-English dictionary
#

sub sp_read_dicts {
    &sp_read_dict();
    if (-e $sp_irreg_dict) {
	&sp_read_dict($sp_irreg_dict);
    }
    else {
	printf STDERR "Warning: unable to open irregular dict '$sp_irreg_dict'\n";
    }
}

# sp_read_dict(file_name): helper function for sp_read_dicts
#
sub sp_read_dict {
    local ($dict) = @_;
    &debug_print(4, "sp_read_dict(@_)\n");

    # The collins dictionary is too large for practical in-memory usage
    # Therefore, lookup's are via external command invocations (see below)
    if ($sp_use_collins) {
	return;
    }

    $dict = $sp_dict unless (defined($dict));
    open (DICT, "<$dict") || die ("ERROR: unable to open dict '$dict' ($!)\n");
    if ($utf8) {
	eval "use Encode;";
	binmode(DICT, ":utf8");
    }
    &debug_print(5, "reading Spanish dictionary $dict\n");
    while (<DICT>) {
	if ($utf8) {
	    # Note: decode_utf8 chokes if input is already UTF8. See
	    #    https://stackoverflow.com/questions/12994100/perl-encode-pm-cannot-decode-string-with-wide-character
	    if (! utf8::is_utf8($_)) {
		$_ = decode_utf8($_);
	    }
	}
	&dump_line($_, 8);
	chomp;	s/\r//;		# TODO: define my_chomp

	# Extract the lookup-key (ignored), phrase, and translation
	($key, $phrase, $sp_translation) = split(/\t/, $_);
	$phrase =~ s/  *$//;
	$phrase = &sp_to_lower($phrase);

	# Isolate collocations
	if ($phrase =~ / *\((.+)\) *$/) {
	    $sp_translation = "(collocate '$1') $sp_translation";
	    $phrase = $`;
	}

	# split phrase into subphrases based on alternate suffixes
	#     "ambulatorio, -ria"   adj. med. ambulatory.
	## $sp_trans{$phrase} = $sp_translation;
	@subphrases = split(/[;, ]+/, $phrase);
	foreach $subphrase (@subphrases) {
	    if ($subphrase =~ /^\-(.*)/) {
		$suffix = $1;

		# When the suffix corresponds to an equal-sized suffix of the
		# main entry (eg, "rojo, -ja"), a direct replacement is made.
		# Otherwise, a partial replacement is done (eg, "actor, -ra").
		&debug_print(8, "subphr[0]='$subphrases[0]' suffix='$suffix'\n");
		$len = length($subphrases[0]) - length($suffix);
		if ((length($suffix) > 1) && (substr($subphrases[0], $len, 1) 
					      ne substr($suffix, 0, 1))) {
		    $len++;
		}
		$subphrase = substr($subphrases[0], 0, $len) . $suffix;
	    }
	    &sp_add_entry($subphrase, $sp_translation);

	    # Add a version for the word w/o diacritic marks
	    if ($sp_remove_diacritics) {
		$subphrase_wo = &sp_remove_diacritics($subphrase);
		&sp_add_entry($subphrase_wo, "[$subphrase] $sp_translation") 
		    unless ($subphrase_wo eq $subphrase);
	    }
	}
    }

    # Reset the file tracing (TODO: have common.perl do it automatically)
    &reset_trace();
}



# add_entry(phrase, translation): add the translation to the dictionary
#
sub sp_add_entry {
    local ($phrase, $sp_translation) = @_;

    &debug_print(8, "adding ($phrase, $sp_translation)\n");
    if (defined($sp_trans{$phrase})) {
	$sp_trans{$phrase} .= ";\t$sp_translation";
    }
    else {
	$sp_trans{$phrase} = $sp_translation;
    }
}



# lookup_word: lookup the translation for a word
#
# For the NTC-based dictionary, an associative array is used.
# For Collins, an external command is used, which can be very slow.
#
sub sp_lookup_word {
    local($word) = @_;
    local($sp_translation) = "";
    &debug_print(&TL_VERY_DETAILED, "lookup_word(@_)\n");

    if ($sp_use_collins) {
	# Invoke spanish_lookup.perl to get the results. Ex:
	#    % spanish_lookup.perl hola
	#    hola	(hola) hullo!; hullo!, hey!, I say!; hullo?
	#
	$sp_trans = &run_command("spanish_lookup.perl $word");
	$sp_trans =~ s/\n/; /g;
	$sp_trans =~ s/$word\t//g;
    }
    else {
	# Get the translation from the associative array.
	# Verbs are checked last since there as so many possible endings.
	# (This also avoids nouns being misintepreted as verbs.)
	# TODO: what about verbs being misinterpeted as nouns
	$sp_trans0 = &sp_lookup_word_as_is($word);

	# If the entry is for a derived verb without having a definition
	# then add the definition from the base.
	if (($sp_trans0 =~ /[^;]*irr\. v\. ([^.,;: ]+)/i)
	    || ($sp_trans0 =~ /[^;]*[123]p[sp] of ([^.,;: ]+)/i)) {
	    $base = $1; $pattern = $&; $pre = $`; $post = $';	# ' (stupid emacs)

	    $verb_trans = &sp_lookup_word_as_is($base);
	    if ($verb_trans ne "") {
		$sp_trans0 = "$pre($pattern) $verb_trans$post";
	    }
	}
	$sp_trans1 = &sp_lookup_noun($word);
	$sp_trans2 = &sp_lookup_verb($word);
	$sp_trans = $sp_trans0;
	$sp_trans .= ";\t$sp_trans1" 
	    unless (($sp_trans1 eq "") || ($sp_trans1 eq $sp_trans0));
	$sp_trans .= ";\t$sp_trans2" 
	    unless (($sp_trans2 eq "") || ($sp_trans2 eq $sp_trans0));
	$sp_trans =~ s/^;\t//;

	if (($sp_trans eq "") && $sp_remove_diacritics) {
	    # Check w/o diacritic marks
	    # TODO: add support for verbs
	    $word_wo = &sp_remove_diacritics($word);
	    if ($word_wo ne $word) {
		$sp_trans = &sp_lookup_word_as_is($word_wo);
		$sp_trans = &sp_lookup_noun($word_wo)
		    unless ($sp_trans ne "");
	    }
	}
    }
    &debug_out(&TL_VERY_DETAILED, "sp_lookup_word(%s) => %.20s...\n", join(" ", @_), $sp_trans);

    return ($sp_trans);
}


# lookup_word_xyz(word): helper functions for lookup_word
#
# Lookup the word in the associative array, with optional stemming.
# First the word is checked as is. It is then stemmed if the initial 
# lookup fails.
# TODO: return multiple translations (eg, both verb & noun cases)
#

sub sp_lookup_word_as_is {
    local($word) = @_;
    local($sp_translation) = "";

    if (defined($sp_trans{$word})) {
	$sp_translation = $sp_trans{$word};
	## $sp_translation .= "; ";
    }
    &debug_print(7, "lookup_word_as_is(@_) => $sp_translation\n");

    return ($sp_translation);
}

# sp_lookup_verb(word): Checks whether the word can be interpreted as a verb
# by performing stemming for the various conjugation/tense combinations, as
# well as check a list of irregular verb forms.
# Returns string with alternative translations separated by semilcolons (n.b., first component is for the word, so separated by colon).
#
sub sp_lookup_verb {
    my($word) = @_;
    my($sp_translation) = "";

    foreach my $stem_triple (&sp_stem_verb($word)) {
	my($root, $tense, $suffix) = @$stem_triple;

	# Make sure the root translation exists and is listed as a verb
	# (ie, either "tr." or "intr." for the grammar tag)
	if (&is_spanish_verb($root)) {
	    my($translation) = &get_entry(\%sp_trans, $root, "");
	    my($extra) = ($show_suffix ? " -$suffix" : "");
	    $sp_translation .= "; " unless ($sp_translation eq "");
	    $sp_translation .= "($root $tense$extra) $translation";
	}
    }
    &debug_print(&TL_VERY_DETAILED, "lookup_verb(@_) => $sp_translation\n");

    return ($sp_translation);
}


sub sp_lookup_noun {
    local($word) = @_;
    local($sp_translation) = "";

    my($root, $person, $suffix) = &sp_stem_noun($word);
    if (($root ne "") && (defined($sp_trans{$root}))) {
	my($extra) = ($show_suffix ? " -$suffix" : "");
	$sp_translation = "($root $person$extra) $sp_trans{$root}";
	## $sp_translation = "($person) $sp_trans{$root}; ";
    }
    &debug_print(7, "lookup_noun(@_) => $sp_translation\n");

    return ($sp_translation);
}


# sp_stem_word(word): return list of stems for the word including the word
# itself
#
sub sp_stem_word {
    local ($word) = @_;
    local ($stems) = "$word";
    local ($stem, $extra);

    ($stem, $extra) = &sp_stem_noun($word);
    $stems .= " " . $stem;

    foreach my $stem_triple (&sp_stem_verb($word)) {
	my($root, $tense, $suffix) = @$stem_triple;
	&reference_vars($tense, $suffix);
	$stems .= " " . $stem;
    }

    &debug_print(7, "sp_stem_word(@_) => $stems\n");

    return ($stems);
}


# stem_verb(word, [no_verify]): determine the root for the word and the tense
# Returns list of [stem, tense, suffix] triples.
#
# TODO: handle roots that change form (eg, [pod]er => [pued]o)
#       return alternative roots
#       add optional support for smorph.tcl if available
#
sub sp_stem_verb {
    local ($sp_verb, $no_verify) = @_;
    local ($root, $tense, $suffix) = ("", "", "");
    $no_verify = &FALSE unless(defined($no_verify));

    # First, check for verbs without pronoun suffixes
    my(@stem_triples) = &sp_stem_verb_aux($sp_verb, $no_verify);

    # If the search, was unsuccessful, check for object pronouns appended to verb
    # (e.g., hablalo").
    if ((scalar @stem_triples) == 0) {
	foreach $pronoun (@sp_pronouns) {
	    if ($sp_verb =~ /^(.*)$pronoun$/) {
		$sp_verb_proper = $1;
		&debug_print(&TL_VERY_DETAILED, "checking $sp_verb_proper (pronoun=$pronoun)\n");
		my(@pronoun_stem_triples);
		if (($sp_verb_proper =~ /[aei]r$/)
		    && (&is_spanish_verb($sp_verb_proper))) {
		    push(@pronoun_stem_triples, [$sp_verb_proper, "inf", ""]);
		}
		else {
		    push(@pronoun_stem_triples, &sp_stem_verb_aux($sp_verb_proper, $no_verify));
		}
		# Add indication of pronoun usage to the tense and add to master list
		foreach my $stem_triple_ref (@pronoun_stem_triples) {
		    $stem_triple_ref->[2] .= ":$pronoun";
		    push(@stem_triples, $stem_triple_ref);
		}
	    }
	}
    }
    &debug_out(&TL_VERY_DETAILED, "sp_stem_verb(%s, %s) => (%s)\n", 
               $sp_verb, $no_verify, &stringify(@stem_triples));

    return (@stem_triples);
}

# stringify(array): converts the array to a string with embedded references resolved
# TODO: handle the full range of reference (scalar, array, hash, code, glob)
# example:
# stringify(0, [a, b, c], 1) => "(0 (a b c) 1)"
#
sub stringify {
    my($result) = "";
    foreach my $item (@_) {
	my($string) = (ref $item) ? &stringify(@$item) : $item;
	$result .= " " unless ($result eq "");
	$result .= $string;
    }
    
    return ("($result)");
}

# is_spanish_verb(word): determines whether the word has an entry in the
# spanish dictionary as a verb (ie., "tr." or "intr." in the translation).
#
sub is_spanish_verb {
    my($verb) = @_;
    my $is_verb = (&get_entry(\%sp_trans, $verb, "") =~ /(in)?tr\./);
    &debug_print(7, "is_spanish_verb(@_) => $is_verb\n");

    return ($is_verb);
}

# sp_stem_verb_aux(word, [no_verify]): helper function to stem_verb
#
# Given the potential verb, stemming is performed to see which conjugations and
# tense combinations are possible. The result is a list of triples giving the
# root, tense and suffix for the particular interpretation, where each triple is
# an anonymous array.
# Example:
# sp_stem_verb_aux("nadamos") = ([nadar, pres-ind, 4], [nadar, pret-ind, 4])
#
sub sp_stem_verb_aux {
    local ($sp_verb, $no_verify) = @_;
    local ($root, $tense, $suffix) = ("", "", "");
    my(@stem_triples) = ();
    $no_verify = &FALSE unless(defined($no_verify));

    # Check for suffixes from the major tenses for each of the 3 conjugations
    #
    foreach $conj (("ar", "er", "ir")) {
	foreach $tense (@sp_verb_tenses) {
	    @suffixes = split(/ /, $sp_verb{"$conj:$tense"});
	    &debug_print(7, "verb=$sp_verb conj=$conj tense=$tense suffixes=(@suffixes))\n");
	    for ($p = 1; $p <= 6; $p++) {
		$suffix = $suffixes[$p - 1];
		&debug_print(9, "$sp_verb =~ /^(.+)$suffix\$/\n");
		if (($sp_verb =~ /^(.+)$suffix$/)
		    || (&convert_verb($sp_verb) =~ /^(.+)$suffix$/)) {
		    $stem = $1;
		    &debug_print(&TL_VERY_DETAILED, "checking $stem$conj\n");
		    if ($no_verify || &is_spanish_verb("$stem$conj")) {
			$root = "$stem$conj";

			# Return unless an irregular verb
			# TODO: handle verbs that are only partly irregular (e.g., ser)
			my($number) = $number_indicator[$p];
			push(@stem_triples, [$root, "$tense:$number", $suffix])
			    unless ($sp_irreg_verbs =~ / $root /i);
		    }

		    # Transform stem (eq, ue -> o)
		    $stem = &revert_stem($stem);
		    if (((scalar @stem_triples) == 0) && ($stem ne "")) {
			&debug_print(&TL_VERY_DETAILED, "checking (transformed) $stem$conj\n");
			if ($no_verify || &is_spanish_verb("$stem$conj")) {
			    $root = "$stem$conj";
			    my($number) = $number_indicator[$p];
			    push(@stem_triples, [$root, "$tense:$number", $suffix])
				unless ($sp_irreg_verbs =~ / $root /i);
			}
		    }
		}
	    }
	}
    }

    # Check for suffixes from the participles for each of the 3 conjugations
    # TODO: reconcile w/ the above code
    #
    foreach $conj (("ar", "er", "ir")) {
	foreach $part ("past_part", "pres_part") {
	    foreach $suffix (split(/ /, $sp_verb{"$conj:$part"})) {
		if ($sp_verb =~ /^(.+)$suffix$/) {
		    $stem = $1;
		    &debug_print(&TL_VERY_DETAILED, "checking $stem$conj\n");
		    if ($no_verify || &is_spanish_verb("$stem$conj")) {
			$root = "$stem$conj";
			push(@stem_triples, [$root, "$part", $suffix]);
		    }
		}
	    }
	}
    }

    # Trace result
    &debug_print(&TL_VERY_DETAILED, "sp_stem_verb_aux(@_) => @stem_triples");
    
    return (@stem_triples);
}


# Convert verbform to make suitable for matching standard declensions
#
sub convert_verb {
    local ($verb) = @_;
    local ($new_verb) = $verb;

    if ($new_verb =~ /ñ[^i]/) {		# gruñó => gruñió
	$new_verb =~ s/ñ/ñi/;
    }
    elsif ($new_verb =~ /dr/) {		# podrá => poderá
	$new_verb =~ s/dr/der/;
    }
    else {
	$new_verb = "";
    }
    &debug_print(8, "convert_verb($verb) => $new_verb\n");

    return ($new_verb);
}


# revert_stem(verb): revert the stem of the verb to the root form
#
# TODO: qu => sc

sub revert_stem {
    local ($stem) = @_;
    local ($new_stem) = $stem;

    $consonant = "[^aeiou]";
    if ($new_stem =~ /$consonant+ien/) {
        $new_stem =~ s/ie/e/;
    }
    elsif ($new_stem =~ /qu/) {		# ce -> que
	$new_stem =~ s/que/ce/;
    }
    elsif ($new_stem =~ /$consonant+ue/) {
	$new_stem =~ s/ue/o/;
    }
    elsif ($new_stem =~ /$consonant+u/) {
	$new_stem =~ s/u/o/;
    }
    elsif ($new_stem =~ /$consonant+ie/) {	
	$new_stem =~ s/ie/e/;
    }
    elsif ($new_stem =~ /zc/) {
	$new_stem =~ s/zc/c/;
    }
    elsif ($new_stem =~ /ñ[^i]/) {
	$new_stem =~ s/ñ/ñi/;
    }
    elsif ($new_stem =~ /$consonant+i/) {	
	$new_stem =~ s/i/e/;
    }
    else {
	$new_stem = "";
    }
    &debug_print(8, "revert_stem($stem) => $new_stem\n");

    return ($new_stem);
}


# stem_noun(word, [no_verify]): remove plural endings for nouns
#
# TODO: verify words in dictionary
#       add optional support for smorph.tcl if available
#
sub sp_stem_noun {
    local ($noun, $no_verify) = @_;
    local ($root, $person, $suffix) = ("", "", "");
    $no_verify = &FALSE unless(defined($no_verify));
    @noun_suffixes = ("ces", "es", "s");

    foreach $test_suffix (@noun_suffixes) {
	if ($noun =~ /(.*)$test_suffix$/) {
	    $root = $1;
	    if ($no_verify || defined($sp_trans{$root})) {
		$person = "p";
		$suffix = $test_suffix;
		last;
	    }
	    $root = &convert_noun_root($root);
	    if (defined($sp_trans{$root})) {
		$person = "p";
		$suffix = $test_suffix;
		last;
	    }
	}
    }
    &debug_print(&TL_VERY_DETAILED, "sp_stem_noun($noun, $no_verify) => ($root, $person, $suffix)\n");

    return ( ($root, $person, $suffix) );
}


# Convert a noun root to the form that might be in a dictionary.
# For instance, this adds the accents that would be lost due to plural
# suffixes.
#
sub convert_noun_root {
    local ($root) = @_;

    # Convert last occurrence of accentable vowel to accented version
    if ($root =~ /^(.*)([eio])([^eio]+)$/) {
	my($prefix) = $1;
	my($accent_char) = $2;
	my($suffix) = $3;
	
	$accent_char =~ tr/eio/éíó/;
	$root = $prefix . $accent_char . $suffix;
    }

    return ($root);
}


# to_lower($text): convert the text to lowercase, accounting for
# diacritic marks
#

sub sp_to_lower {
    local ($text) = @_;

    # TODO: add utf-8 support to common.perl for making strings lowercase
    ## if ($utf8) {
    ##     return &utf8_lower($text);
    ## }

    $text =~ tr/A-ZÁÉÍÓÚÑÜ/a-záéíóúñü/;

    return ($text);
}


# remove_diacritics($text): remove diacritic marks from the text
# TODO: have separate function for removing [¡!¿?]
#

sub sp_remove_diacritics {
    local ($text) = @_;

    if ($utf8) {
	return &utf8_remove_diacritics($text);
    }

    $text =~ tr/ÁÉÍÓÚÑÜáéíóúñü/AEIOUNOaeiounu/;
    $text =~ s/[¡!¿?]//g;

    return ($text);
}


#------------------------------------------------------------------------------

# sp_init_pp([trans_listing=0], [ignore_phrasals=0])
#
# Initialize the pretty-printing component. The optional argument indicates
# whether the input is from a word translation listing rather than from
# the dictionary.
#
sub sp_init_pp {
    local($trans_listing, $ignore_phrasals) = @_;
    $trans_listing = &FALSE unless(defined($trans_listing));
    $ignore_phrasals = &FALSE unless(defined($ignore_phrasals));
    &debug_print(4, "init_pp($trans_listing, $ignore_phrasals)\n");

    $sp_trans_listing = $trans_listing;
    $sp_ignore_phrasals = $ignore_phrasals;
    $sp_prefix = ($sp_trans_listing == &TRUE) ? "\t" : "";
}


# sp_pp_entry(phrase, dictionary_entry)
#
# Pretty print the entry from the Spanish-English bilingual dictionary.
#
# global_varables:
#    $sp_processed{<word>}	words already processed
#
sub sp_pp_entry {
    local($word, $entry) = @_;
    local($pp_text) = "";
    &debug_print(&TL_VERY_VERBOSE, "sp_pp_entry(@_)\n");

    # Extract the homonym indicator (eg, "ser (2)")
    local($word_spec) = $word;
    if ($entry =~ /^ *(\([0-9]\)) */) {
	$word_spec .= " $1";
	$entry = $';		# ' (stupid emacs)
    }

    # Extract the (irregular) conjugation if present
    # TODO: remove the "Irreg." text
    local($conj) = "";
    if ($strip_conj && ($entry =~ /(\\ *)?Conjug\.?:? *(.*)/)) {
	$entry = $`;
	$conj = $2;
    }
    &assert('defined($conj)');

    # Print the entry header
    $pp_text .= sprintf "${sp_prefix}${word_spec}\n" unless ($sp_trans_listing);

    # If the word was already processed, just show part of the entry
    if ($sp_just_once && defined($sp_processed{$word})) {
	$entry = substr($entry, 0, $sp_repeat_len);
	$entry .= "\n$sp_prefix... (see above for rest)\n";
    }
    $sp_processed{$word} = &TRUE;

    # Shown the subentries (lines separated by ";\t"
    foreach $subentry (split(/\;\t/, $entry)) {
	$pp_text .= &sp_pp_entry_aux($word, $subentry);
	last if ($first_sense);
    }

    return ($pp_text);
}


# sp_pp_entry_aux(word, translation_entry): helper function for pp_entry, working on all sense
# entries (i.e., section after part-of-speech)
#
sub sp_pp_entry_aux {
    local($word, $entry) = @_;
    local($num, $next_num);
    local($pp_text) = "";
    &debug_print(&TL_VERY_VERBOSE, "sp_pp_entry_aux(@_)\n");

    # Print each sense of the word on a separate line
    local ($last_entry) = &FALSE;
    $next_num = 2;
    my($subsense_num, $subsense_spec);
    $subsense_num = 0;
    $subsense_spec = "";
    # TODO: my($sense, $term_punct, ...);
    for ($num = 1; (!$last_entry); $num = $next_num) {
	if ($subsenses && ($entry =~ /([\;]) */)) {
	    $sense = $`;
	    $term_punct = ($first_sense ? "" : $1);
	    $entry = $';		# ' (stupid emacs)
	    $last_entry = $first_sense;
	    $subsense_spec = ($first_sense ? "" : chr($subsense_num + ord('a')));
	    $subsense_num++;
	    &debug_print(7, "subsense $subsense_spec\n");
	}
	elsif ($entry =~ /([\.\?\!\;]) *([0-9]+) /) {
	    $sense = $`;
	    $term_punct = ($first_sense ? "" : $1);
	    $next_num = $2;
	    $entry = $';		# ' (stupid emacs)
	    $last_entry = $first_sense;
	    &debug_print(7, "numbered sense: next=$next_num\n");
	    $subsense_spec = "";
	    $subsense_num = 0;
	}
	else {
	    $sense = $entry;
	    $term_punct = "";
	    $last_entry = &TRUE;
	    $subsense_spec = "";
	    &debug_print(7, "entire sense\n");
	}
	&debug_print(&TL_VERY_DETAILED, "sense$num${subsense_spec}='$sense'\n");

	# Optionally, remove subsenses that involve phrasals
	if ($sp_ignore_phrasals) {

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
	    $sense =~ s/^\s*\w+\. //;	# no POS
	}


	# Optionally, remove all but first translation equivalent
	$sense =~ s/[.,:;].*// if ($first_trans);

	# Show current sense definition (and/or specification for verbals, etc.)
	my($num_spec) = ($first_sense ? "" : "${num}. ");
	$sense =~ s/\s+/ /;
	$pp_text .= sprintf "${sp_prefix}${num_spec}${subsense_spec}${sense}${term_punct}\n";
    }

    # Prettyprint the optional conjugation
    $pp_text .= &sp_pp_conj($conj) unless (($conj eq "") 
					   || ($sp_trans_listing) 
					   || ($first_sense));

    # Print the entry trailer
    $pp_text .= sprintf "${sp_prefix}\n";

    return ($pp_text);
}


# sp_pp_conj(conjugation)
#
# Pretty print the verb conjugation,
#
sub sp_pp_conj {
    local($conj) = @_;
    local($pp_text) = "";
    &debug_print(5, "pp_conj(@_)\n");

    # Perform fixup's to remove known consistencies in the entries
    # TODO: check all the tenses for this
    $conj =~ s/(Past\. p.) /$1: /i;
    $conj =~ s/\. (Imper|Past|Fut)/. | $1/gi;

    # Print each tense on a separate line
    $pp_text .= sprintf "${sp_prefix}Verb conjugations:\n";
    ## DEBUG: &debug_print(5, "pp_text: $pp_text\n");
    $subjunctive = &FALSE;
    while ($conj =~ /([^:|]+): ([^|]*)(\| )?/) {
	$tense = $1;
	$verb_forms = $2;
	$conj = $';		# ' (stupid emacs)

	# Make the verb-forms consistent
	#    Separate the singular forms from the plural ones by a tab
	#    ## OLD: Remove ", etc. " and trailing period
	#    TODO: try expanding the etc. cases
	$verb_forms =~ s/;/\t/g;
	## OLD: $verb_forms =~ s/, *etc\.? *[,]?//g;
	$verb_forms =~ s/\.? *$//;
	# Restore period after etc
	$verb_forms =~ s/etc$/etc\./;

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
	$pp_text .= sprintf "${sp_prefix}$tense\t$verb_forms\n";
	## DEBUG: &debug_print(5, "pp_text: $pp_text\n");
    }
    $conj =~ s/like [$sp_word_chars]+\.?//;
    if ($conj ne "") {
	&debug_print(3, "WARNING: extraneous conjugation text: '$conj'\n");
	$pp_text .= sprintf "${sp_prefix}extra: $conj\n";
	## DEBUG: &debug_print(5, "pp_text: $pp_text\n");
    }

    return ($pp_text);
}

#------------------------------------------------------------------------------

# sp_extract_POS(current_part_of_speech, $sense_definition)
#
# Determines the part of speech category for the entry, defaulting to 
# current POS.
#
# NOTE: this uses traditional categories not fine-grained tags (eg, Treebank)
#

sub sp_extract_POS {
    local ($current_POS, $sense_def) = @_;
    local ($POS) = $current_POS;

    # Check for POS abbreviations (period required)
    if ($sense_def =~ /\W((V)|(Indic)|(vt)|(tr)|(intr)|(Pres)|(Imper))\./) {
	$POS = "verb";
    }
    elsif ($sense_def =~ /\W((adj))\./) {
	$POS = "adjective";
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
    &debug_print(7, "$POS <= extract_POS($current_POS, $sense_def)\n");

    return ($POS);
}


#------------------------------------------------------------------------------

# Initialize the module and return 1 for success
&sp_init();
1;
