#!/usr/bin/perl -sw
#
# NL_support.perl: common routines for various NL-related scripts
# TODO: turn into a proper Perl module
#
# Copyright (c) 2000 - 2001 Cycorp, Inc.  All rights reserved.
#
#........................................................................
# usage:
# require 'NL_support.perl';
# ...
# &init_NL_support();
#

use Cyc;                        # Charles's Perl module
require 'cyc_helper.perl';

&init_var(*NL_support_code,                # lisp code with supporting interface code into Cyc
          &find_library_file("NL_support.lisp"));
&init_var(*support_function, "nl-support-stub"); # function that should be in the file
&init_var(*reload, &FALSE);		# reload the lisp support code
$uncyclify_results = &TRUE;		# set option in cyc_helper.perl
&reference_var($uncyclify_results);	# TODO: use package spec
&init_var(*verbose, &FALSE);		# verbose output mode (as lispish comments)
use vars qw/$verbose $reload/;

&init_var(*POS, "");		# part-of-speech of word to check
&init_var(*just_denots, &FALSE);	 # use only denotation's (not denotationRelatedTo's)
&init_var(*related, (! $just_denots)); # include denotationRelatedTo's in meaning checks
$denotation_type = ($related ? "related" : "denot");
@cyc_POS_list = ("SimpleNoun", "MassNoun", "AgentiveNoun", "ProperMassNoun", "ProperCountNoun", "Verb", "Adverb", "Adjective");	       # default list of Cyc SpeechPart's (revised during initialization)

# init_NL_support([skip_load=0]): Initialize access to Cyc loading in NL-related support
# code and initializing some internal tables.
#
sub init_NL_support {
    my($skip_load) = @_;
    $skip_load = &FALSE unless (defined($skip_load));
    &debug_out(&TL_VERBOSE, "init_NL_support(@_)\n");
    # Initialize the TCL connection to the Cyc server
    &init_cyc();

    # Load in the supporting lisp code if needed
    # NOTE: This is optionally skipped for scripts like show_senses.perl that don't
    # use the extensions in NL_support.lisp.
    if ($skip_load == &FALSE) {
	&load_supporting_code($support_function, $NL_support_code);
    }

    # Initialize support for part-of-speech handling
    &init_POS_mapping();
    &set_cyc_part_of_speech($POS);
}

# end_NL_support(): terminate the NL-specific access to Cyc
#
sub end_NL_support {
    end_cyc();
}

#........................................................................

# is_function_word(word): 
#
# Returns true iff any word unit with a mapping the word form has a part-of-speech
# in a close category (determiner, preposition, pronoun, etc.). This maintains a hash
# table of the results so that a particular word form is only checked via Cyc once.
# 
my(%function_word);

sub is_function_word {
    my($word) = @_;
    my($is_function_word) = $function_word{$word};
    if (!defined($is_function_word)) {
	$is_function_word = (&cyc_function_fmt("(is-function-word \"%s\")", $word) eq "T");
	$function_word{$word} = $is_function_word;
    }

    return ($is_function_word);
}

# is_valid_word(word): 
#
# Returns true iff any word unit exists a mapping for the word form.
# This maintains a hash table of the results so that a particular word
# form is only checked via Cyc once.
#
my(%valid_word);

sub is_valid_word {
    my($word) = @_;
    my($is_valid_word) = $valid_word{$word};
    if (!defined($is_valid_word)) {
	$is_valid_word = (&cyc_function_fmt("(is-valid-word \"%s\")", $word) eq "T");
	$valid_word{$word} = $is_valid_word;
    }

    return ($is_valid_word);
}

#------------------------------------------------------------------------

#  # escape_string(string): Returns string with lisp escape characters as needed
#  #
#  sub escape_string {
#      my($string) = @_;
#      $string =~ s/\\/\\\\/g;
#      $string =~ s/\"/\\\"/g;

#      return ($string);
#  }

# get_word_stem(word): Determine the stem of the word (via Cyc's morphology code)
#
sub get_word_stem {
    my($wordform) = @_;
    my(@word_units);
    &debug_out(&TL_VERBOSE, "get_word_stem(@_)\n");

    # Add escape codes for special characters
    $wordform = &escape_string($wordform);

    my($command) = sprintf "(find-stem \"%s\")", $wordform;
    my($stem) = &cyc_function($command);
    $stem =~ s/\"//g;

    return ($stem);
}

# set_cyc_part_of_speech(POS): Set the default part-of-speech for denotation checks
#
# Determine the application part-of-speech types for the POS tag
# TODO: determine if a lexicon utility fucntion provides this or: See
# whether the accessor routines can be revised to take the generic
# part-of-speech keywords, as with denots-of-string&pos. 
#
sub set_cyc_part_of_speech {
    my($POS) = @_;

    my(@new_cyc_POS_list) = ($POS ne "") ? &pos_for_keyword($POS) :  &pos_for_keyword("any");
    if ((scalar @new_cyc_POS_list) > 0) {
	@cyc_POS_list = @new_cyc_POS_list;
    }
    return (@cyc_POS_list);
}

# get_word_denotations(word_unit): Return the list of denotations for the word unit,
# restricted to the current list of part-of-speech types.
#
# NOTES:
#
# (denots-of-word&pos word-unit pos [name-string-default?=nil] [denot-type=:denot] 
#                                   [mts=(relevant-nl-mts)])
# - returns a list of denotations for the unit, optionally creating virtual denotations
#   for proper nouns
#
sub get_word_denotations {
    my($word_unit, $type) = @_;
    $type = $denotation_type if (! defined($type));
    &debug_out(&TL_VERBOSE, "get_word_denotations(@_)\n");

    # Add escape codes for special characters
    $word_unit =~ s/[,\.!@%^&*\(\)\{\}\[\]\"\']//g;

    my($command, @denots, $POS);
    foreach $cyc_POS (@cyc_POS_list) {
	$command = sprintf "(denots-of-word&pos (fort-for-string \"%s\") (fort-for-string \"%s\") nil :%s)", 
	                   $word_unit, $cyc_POS, $type;
	push (@denots, &cyc_meaning_function($command));
    }

    return (@denots);
}

# get_word_semtrans(word_unit): Return the list of sem-trans frames for the word unit,
# restricted to the current list of part-of-speech types.
# TODO: rework the retrieval of the semtrans predicates because duplicates are being
# returned:
#      (semtrans-of-wu&pos #$Member-TheWord #$SimpleNoun) => ((#$hasMembers ?ORG :NOUN))
#      (semtrans-of-wu&pos #$Member-TheWord #$ProperMassNoun) => ((#$hasMembers ?ORG :NOUN))
#
sub get_word_semtrans {
    my($word_unit) = @_;
    &debug_out(&TL_VERBOSE, "get_word_semtrans(@_)\n");

    # Add escape codes for special characters
    $word_unit =~ s/[,\.!@%^&*\(\)\{\}\[\]\"\']//g;

    my($command, @denots, $POS);
    foreach $POS (@cyc_POS_list) {
	$command = sprintf "(semtrans-of-wu&pos (fort-for-string \"%s\") (fort-for-string \"%s\") )", $word_unit, $POS;
	push (@denots, &cyc_meaning_function($command));
    }

    return (@denots);
}

sub get_syntactic_mappings {
    my($word, $POS) = @_;
    &debug_out(&TL_VERY_DETAILED, "get_syntactic_mappings(@_)\n");
    my(@assertions) = grep { /\"/ } &get_lexical_assertions(@_);
    if (defined($POS)) {
	my(@sub_assertions);
	foreach my $pred (&cyc_list_function_fmt("(preds-for-keyword :$POS)")) {
	    push(@sub_assertions, grep { /$pred/ } @assertions);
	}
	@assertions = @sub_assertions;
    }
    return (@assertions);
}

# get_denotation_assertions(word_unit, [cyc_POS]): Return list of denotation assertions for
# the word (optionally restricted to given Cyc part-of-speech).
#
sub get_denotation_assertions {
    my($word, $POS) = @_;
    &debug_out(&TL_VERY_DETAILED, "get_denotation_assertions(@_)\n");
    my(@assertions) = grep { /denotation/ } &get_lexical_assertions(@_);
    if (defined($POS)) {
	my(@sub_assertions);
	foreach my $cyc_POS (&cyc_list_function_fmt("(pos-for-keyword :$POS)")) {
	    push(@sub_assertions, grep { /$cyc_POS/ } @assertions);
	}
	@assertions = @sub_assertions;
    }
    return (@assertions);
}

# get_semtrans_assertions(word_unit, [POS]): Return list of semTrans assertions for the word
#
sub get_semtrans_assertions {
    my($word, $POS) = @_;
    &debug_out(&TL_VERY_DETAILED, "get_semtrans_assertions(@_)\n");
    my(@assertions);
    if (defined($POS)) {
	foreach my $cyc_POS (&cyc_list_function_fmt("(pos-for-keyword :$POS)")) {
	    push(@assertions, &cyc_meaning_function_fmt("(mapcar #'assertion-formula (semtrans-assertion-lookup (fort-for-string \"%s\") (fort-for-string \"%s\")))", $constant, $cyc_POS));
	}
    }
    else {
	@assertions = &old_get_semtrans_assertions($word);
    }
    return (@assertions);
}

sub old_get_semtrans_assertions {
    my($word, $POS) = @_;
    my(@assertions) = grep { /semTrans/i } &get_lexical_assertions(@_);
    if (defined($POS)) {
	@assertions = grep { /$POS/ } @assertions;
    }
    return (@assertions);
}

# get_lexical_assertions(word_unit): Return a list of all the assertions for the word
# TODO: fix problem with the result not being list-ified properly
#
sub get_lexical_assertions {
    my($word_unit) = @_;
    &debug_out(&TL_VERBOSE, "get_lexical_assertions(@_)\n");

    my(@assertions) = &cyc_meaning_function_fmt("(mapcar \#\'assertion-formula (gather-term-assertions (fort-for-string \"%s\") \#\$GeneralEnglishMt))", $word_unit);
    push(@assertions, &cyc_meaning_function_fmt("(mapcar \#\'assertion-formula (gather-term-assertions (fort-for-string \"%s\") \#\$EnglishMt))", $word_unit));
    @assertions = &remove_duplicates(@assertions);
    &debug_out(&TL_VERY_VERBOSE, "get_lexical_assertions => %s\n", join(" ", @assertions));

    return (@assertions);
}

# init_closed_class(data_file): initialize list of close class words
# NOTE: obsolete data_file parameter is now ignored
# 
my(%is_closed_class_word);
sub init_closed_class {
    my(@closed_class_words) = &cyc_string_list_function("(closed-lexical-class-strings)");
    foreach my $word (@closed_class_words) {
	$word = &to_lower($word);
	$is_closed_class_word{$word} = &TRUE;
    }
    $is_closed_class_word{"the"} = &TRUE;
}

# is_closed_class_word(word): returns true if the word is considered a closed class word
#
sub is_closed_class_word {
    my($word) = @_;
    if (!defined($is_closed_class_word{"the"})) {
	&init_closed_class($closed_class_data);
    }
    my($closed) = defined($is_closed_class_word{&to_lower($word)});
    &debug_out(&TL_VERY_VERBOSE, "is_closed_class_word(%s) => %s\n", $word, $closed);
    return ($closed);
}

# init_POS_mapping(): Initialize support for part-of-speech mapping, including
# the list of alternative parts-of-speech.
#
my(%alt_POS_mapping);

sub init_alt_POS_mapping {
    my($POS, $alt_POS) = @_;

    my(@alt_POS) = &tokenize($alt_POS);
    &set_entry(\%alt_POS_mapping, $POS, \@alt_POS);
}

sub init_POS_mapping {
    &init_alt_POS_mapping("noun", "verb adjective");
    &init_alt_POS_mapping("proper-noun", "noun verb adjective");
    &init_alt_POS_mapping("verb", "noun adjective");
    &init_alt_POS_mapping("adjective", "adverb noun verb");
    &init_alt_POS_mapping("adverb", "adverb");
}

# get_alternative_POS(POS): Returns the parts of speech which can possibly serve
# as parts of speech in lexical extensions of a particular sense, such as when
# a verb is coined from a noun.
#
sub get_alternative_POS {
    my($POS) = @_;
    my($alt_POS_ref) = &get_entry(\%alt_POS_mapping, $POS, "");
    my(@alt_POS) = ($alt_POS_ref ne "") ? @$alt_POS_ref : ();
    &debug_out(&TL_VERY_VERBOSE, "get_alternative_POS(@_) => (%s)\n", join(" ", @alt_POS));

    return (@alt_POS);
}

# generate_phrase(cyc_term, [singular=&FALSE]): generate (best) English phrase representing Cyc term
#
sub generate_phrase {
    my($term, $singular) = @_;
    $singular = &FALSE if (!defined($singular));
    my($pred_list) = ($singular ? "'(\#\$singular \#\$agentive-Sg \#\$pnSingular \#\$infinitive)" : "");
    $term =~ s/\"/\\"/g;
    return (&cyc_string_function_fmt("(generate-phrase (fort-for-string \"%s\") %s)", 
				     $term, $pred_list));
}

# get_printstring(term)
#
# Get the QuA printstring for the Cyc term.
# NOTE: generate-phrase signals an error if the fort is is QuA-irrelevant, so ignore-errors
# is used to trap the error.
#
sub get_printstring {
    my($term) = @_;
    &debug_out(&TL_VERBOSE, "get_printstring(@_)\n");

    ## my($command) = sprintf "(compute-printstring 'DIS (list (fort-for-string \"%s\")))", $term;
    $term =~ s/\"/\\"/g;
    my($command) = sprintf "(ignore-errors (generate-printstring (fort-for-string \"%s\")))", 
                           $term;
    my($printstring) = &cyc_string_function($command);
    $printstring = "" if (($printstring eq "NIL") || ($printstring eq "-?-") 
                          || ($printstring =~ /^#\\/));

    return ($printstring);
}

# get_term_description(term): get a brief description for the term, consisting of
# the QuA printstring if available or the English phrase that generates generated for it.
#
sub get_term_description {
    my($term) = @_;

    my($description) = &get_printstring($term);
    if ($description eq "") {
	$description = &generate_phrase($term);
    }
    return ($description);
}

# get_word_variants(word, [POS], [strict]): return list of variant forms for the word,
# optionally restricted to the specific part-of-speech (keyword)
# When strict is set true, more constrained mappings are used.
#
sub get_word_variants {
    my($wordform, $POS, $strict) = @_;
    $POS = "" if (!defined($POS));
    $strict = "" if (!defined($strict));

    $POS = ":$POS" if ($POS =~ /^[^:]/);
    my($POS_spec) = (defined($POS) ? "$POS" : "");
    return &cyc_string_list_function_fmt("(word-variants \"%s\" %s %s)", 
					 $wordform, $POS_spec, $strict);
}

# get_strict_word_variants(word, POS): return variant forms for the word and part of speech
#
sub get_strict_word_variants {
    my($wordform, $POS) = @_;
    return (&get_word_variants($wordform, $POS, &TRUE));
}

# sub pluralize_word(word): returns the pluralized form of word
#
sub pluralize_word {
    return (&cyc_string_function_fmt("(pluralize-word \"%s\")", $_[0]));
}


# sub singularize_word(word): returns the singularized form of word
#
sub singularize_word {
    return (&cyc_string_function_fmt("(singularize-word \"%s\")", $_[0]));
}


# sub find_stem(word): returns the stem of the word (i.e., basic wordform)
#
sub find_stem {
    return (&cyc_string_function_fmt("(find-stem \"%s\")", $_[0]));
}

# sub guess_stem(word): returns the likely stem of the word (i.e., basic wordform)
#
sub guess_stem {
    return (&cyc_string_function_fmt("(guess-stem \"%s\")", $_[0]));
}

# sub find_root_wordform(wordform): returns root form of the word with the variant word form
#
sub find_root_wordform {
    return (&cyc_string_function_fmt("(find-root-wordform \"%s\")", $_[0]));
}

# sub keyword_for_pos(pos): keyword corresponding to the part of speech (eg, #$SimpleNoun -> :noun)
#
sub keyword_for_pos {
    return (&cyc_function_fmt("(keyword-for-pos (fort-for-string \"%s\"))", $_[0]));
}

# sub pos_of_pred(pred): Cyc SpeechPart for the syntactic predicate
#
sub pos_of_pred {
    return (&cyc_function_fmt("(pos-of-pred (fort-for-string \"%s\"))", $_[0]));
}

# words_of_string(wordform,): Return word units with mapping to wordform
#
sub words_of_string {
    my($wordform) = @_;
    return (&cyc_list_function("(remove-duplicates (words-of-string \"$wordform\"))"));
}

# words_of_string_and_pred(wordform, predicate): Return word units with mapping from wordform using the predicate
#
sub words_of_string_and_pred {
    my($wordform, $predicate) = @_;
    return (&cyc_list_function("(remove-duplicates (words-of-string&pred \"$wordform\" (fort-for-string \"$predicate\")))"));
}

# words_of_string_and_pos(wordform, POS_keyword): Return word units with mapping from wordform using the part-of-speech (keyword)
#
sub words_of_string_and_pos {
    my($wordform, $POS) = @_;
    return (&cyc_list_function("(remove-duplicates (words-of-string&pos \"$wordform\" :$POS))"));
}

# words_of_string_and_speech_part(wordform, speech_part): Return word units with mapping from wordform using the speech part
#
sub words_of_string_and_speech_part {
    my($wordform, $speech_part) = @_;
    return (&cyc_list_function("(remove-duplicates (words-of-string&speech-part \"$wordform\" (fort-for-string \"${speech_part}\")))"));
}

# has_wordform_mapping(wordform, predicate): Determine whether a mapping exists for the wordform using the predicate
#
sub has_wordform_mapping {
    my($wordform, $predicate) = @_;
    my(@wordunits) = &words_of_string_and_pred($wordform, $predicate);
    return ($#wordunits != -1);
}

# pos_for_keyword(keyword): returns list of Cyc SpeechPart's corresponding to keyword
#
sub pos_for_keyword {
    return (&cyc_list_function_fmt("(pos-for-keyword :%s)", $_[0]));
}

# first_pred_of_pos(part_of_speech): First syntactic predicate associated with the part of speech
# TODO: ensure that this is the most basic predicate for the SpeechPart
#
sub first_pred_of_pos {
    return (&cyc_function_fmt("(first (preds-of-pos (fort-for-string \"%s\")))", $_[0]));
}

# derive_wordform(word_unit, speech_part): Get main wordform for specified wordunit and Cyc part of speech
#
sub derive_wordform {
    my($word_unit, $speech_part) = @_;
    return (&cyc_string_function("(derive-wordform (fort-for-string \"${word_unit}\") (fort-for-string \"${speech_part}\"))"));
}

# derive_nonplural_wordform(word_unit, speech_part): Get main wordform for specified wordunit and Cyc part of speech
#
sub derive_nonplural_wordform {
    my($word_unit, $speech_part) = @_;
    return (&cyc_string_function("(derive-nonplural-wordform (fort-for-string \"${word_unit}\") (fort-for-string \"${speech_part}\"))"));
}

#------------------------------------------------------------------------
# TODO: move the following to cyc_helper.perl

# sub create_constant(constant): create Cyc constant
#
sub create_constant {
    return (&cyc_function_fmt("(ke-create \"%s\")", $_[0]));
}

# sub create_constant_now(constant): create Cyc constant, bypassing the local queue
#
sub create_constant_now {
    return (&cyc_function_fmt("(ke-create-now \"%s\")", $_[0]));
}

# sub diagnose_formula(formula, mt): return status message if the formula is invalid in mt
# otherwise returns an empty string
#
sub diagnose_formula {
    my($formula, $mt) = @_;
    $formula = &escape_string($formula);
    return (&cyc_string_function_fmt("(invalid-formula? (string-to-formula \"%s\") (fort-for-string \"%s\"))",
			      $formula, $mt));
}

# sub try_assert(formula, mt): Make the assertion in the MT (unless already there)
#
sub try_assert {
    my($formula, $mt) = @_;
    printf ";; asserting $formula in $mt\n" if ($verbose);
    $formula = &escape_string($formula);
    return (&cyc_boolean_function_fmt("(try-assert (string-to-formula \"%s\") (fort-for-string \"%s\"))",
			      $formula, $mt));
}

# sub try_assert_now(formula, mt): Make the assertion in the MT (unless already there)
#
sub try_assert_now {
    my($formula, $mt) = @_;
    printf ";; asserting $formula in $mt\n" if ($verbose);
    $formula = &escape_string($formula);
    return (&cyc_boolean_function_fmt("(try-assert-now (string-to-formula \"%s\") (fort-for-string \"%s\"))",
			      $formula, $mt));
}

# sub try_assert_int(formula, mt): Make the assertion in the MT (unless already there),
# bypassing the local queue
#
sub try_assert_int {
    my($formula, $mt) = @_;
    printf ";; asserting $formula in $mt\n" if ($verbose);
    $formula = &escape_string($formula);
    return (&cyc_boolean_function_fmt("(try-assert-int (string-to-formula \"%s\") (fort-for-string \"%s\"))",
			      $formula, $mt));
}

# sub try_unassert(formula, mt): Delete the assertion in the MT (unless not there)
#
sub try_unassert {
    my($formula, $mt) = @_;
    printf ";; unasserting $formula from $mt\n" if ($verbose);
    $formula = &escape_string($formula);
    return (&cyc_boolean_function_fmt("(try-unassert (string-to-formula \"%s\") (fort-for-string \"%s\"))",
			      $formula, $mt));
}

# sub try_unassert_now(formula, mt): Delete the assertion in the MT (unless not there)
#
sub try_unassert_now {
    my($formula, $mt) = @_;
    printf ";; unasserting $formula from $mt\n" if ($verbose);
    $formula = &escape_string($formula);
    return (&cyc_boolean_function_fmt("(try-unassert-now (string-to-formula \"%s\") (fort-for-string \"%s\"))",
			      $formula, $mt));
}

# sub try_unassert_int(formula, mt): Delete the assertion in the MT (unless not there), 
# bypassing the local queue
#
sub try_unassert_int {
    my($formula, $mt) = @_;
    printf ";; unasserting $formula from $mt\n" if ($verbose);
    $formula = &escape_string($formula);
    return (&cyc_boolean_function_fmt("(try-unassert-int (string-to-formula \"%s\") (fort-for-string \"%s\"))",
			      $formula, $mt));
}

#------------------------------------------------------------------------

# Return successful load status
1;
