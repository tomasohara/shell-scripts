# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
# -*- coding: utf-8 -*-
#!/usr/bin/perl -sw
#
# qd_trans_spanish.perl: quick and dirty translation of Spanish text.
# Currently, this is just a dictionary lookup.
#
# Example invocation (see .emacs.trans-sp):
# - perl -Ssw qd_trans_spanish.perl -maxlen=256 -redirect -sp_remove_diacritics -verbose -
#
# NOTE:
# - via spanish.perl:
#      $sp_word_chars = "\\wáéíóúñü-";
#      $sp_word_pattern = "([$sp_word_chars]+)([^$sp_word_chars])"
# - The UNDER_EMACS environment variable is defined via my ~/.emacs config.
#
# TODO:
# - * Make utf8 the default.
# - Use strict-mode w/ variable-specific import exceptions.
# - Remove verb conjugations during -pretty -first_sense output.
# - Use edit distance to suggest terms when no results (e.g., tearal => teatral).
# - add support for UTF-8 input as done in spanish.perl (also see count_it.perl)
# - Make sure space after semicolons in verb conjugations:
#   ex: +reir => ... Subj. Pres.: ría, rías, ría, ríamos, riáis, rían.
# - Record words looked up in order to find out which words not being learned (i.e., requiring repeated lookups).
# - Make sure global and/or ignore is used for regex changes involving listing optonally with word in pattern.
# - Put word at start of line if past or present participle. For example,
#      "\t1. (subir past_part) intr. to go up"  => "subdir\n\t1. (past_part) intr. to go up"
# - Put verb conjugation on separate line (from last verbal sense). For example,
#      "\t7. to make a slip, to blunder. \ Conjug. like contar." => "\t7. to make a slip, to blunder.\n\tConjug. like contar."
#
# Copyright (c) 2005-2022 Tom O'Hara and New Mexico State University.
# Freely available via GNU General Public License (see GNU_public_license.txt).
#

BEGIN { 
    my $dir = $0; $dir =~ s/[^\\\/]*$//; unshift(@INC, $dir);
    require 'common.perl';
}
require 'spanish.perl';
use vars qw/$sp_options $sp_word_pattern $first_sense $subsenses $redirect $sp_remove_diacritics $verbose $trans_line/;
## OLD: use vars qw/$utf8 $prompt/;
## NOTE: utf8 handled by spanish.perl
## TODO1: straighten out perl utf8 morass
use vars qw/$prompt/;

my($misc_usage_notes) = <<END_MISC_NOTES;
Notes:
- Use special indicators before tokens to modify output
  + for longer lines
  @ for prettyprinting (e.g., verb conjugations)
  & for multi-line output (assumes @)
  * for all of the above
- Other special indicators:
  < entire line translation (i.e., to English)
  > english translation (i.e., to Spanish)
  ! run shell command (with aliases enabled)
END_MISC_NOTES

sub usage {
    local ($program_name) = $0;
    $program_name =~ s/\.?\.?\/.*\///;

    select(STDERR);
    print <<USAGE_END;

Usage: $program_name [options] spanish_file ...

options = $sp_options [-sp_make_dict=0|1] [-pretty] [-brief] [-maxlen=N] [-full] [-multi] [-trans_line] [-prompt=text]

Quick and dirty (word-level) translation for the Spanish text.

Example: 

$program_name luna_y_sol.text >! luna_y_sol.info

USAGE_END

    print($misc_usage_notes);

    &exit();
}


# If command line arguments are missing, give a usage message.
# $#ARGV = (# of arguments) - 1

if ($#ARGV < 0) {
    &usage();
}

&init_var(*brief, &FALSE);	# just show first sense in pretty printing
## OLD: &init_var(*pretty, $brief);	# pretty print the entry
## OLD: &init_var(*maxlen, 512);	# maximum line length for translation output
&init_var(*full, &FALSE);       # show full line (i.e., no truncation at $maxlen)
&init_var(*multi, &FALSE);      # show output on multiple lines
&init_var(*trans_line, &FALSE); # translate entire line
&init_var(*pretty, $multi);	# pretty print the entry
&init_var(*maxlen, ($multi ? 1024 : 512));  # maximum length for translation output
# Note: Special processing for prompt to support usage under Emacs shell
# (n.b, UNDER_EMACS must be set explicitly).
# TODO: just default to "> " regardless
## TEST
## my($prompt_default) = (&get_env("UNDER_EMACS") ? "> " : "");
## &init_var(*prompt, $prompt_default);       # prompt for input
## TODO: disable buffering
&init_var(*prompt, "");          # prompt for input
&init_var(*debug_level, &DEBUG_LEVEL);  # workaround for quirk under Emacs

# Temp workround
## TODO: &debug_on(3);
if ($debug_level != &DEBUG_LEVEL) {
    &debug_on($debug_level);
}
use vars qw/$preserve_temp/;
&debug_print(3, "preserve_temp=$preserve_temp\n");

# Set stdout unbuffered if prompt used
if ($prompt ne "") {
    &debug_print(&TL_DETAILED, "Setting STDOUT unbuffered\n");
    select(STDOUT); $| = 1;
    ## TEST
    ## select(STDIN); $| = 1;             
    ## select(STDERR); $| = 1;             
}

# Set defaults for the dictionary, etc. These can be specified on command
# line, as follows:
#
#    perl -s trans_spanish.perl -user_dict=test_dict.list < text_file
#
# $user_dict = "" unless defined($user_dict);
&init_var(*sp_make_dict, &FALSE); # for subsetting the bilingual dictionary
if ($brief) {
    $first_sense = &TRUE;
    $subsenses = &TRUE;
}

# Read in the Spanish dictionary
#
&sp_read_dicts();
if ($sp_make_dict == &TRUE) {
    open (TEMP_DICT, ">sp_temp.dict");
}

# Print a header comment
# TODO: reconcile the notes here with the ones in the usage statement.
if ($verbose) {
    print "# qd_trans_spanish\n";
    my($misc_usage_comments) = $misc_usage_notes;
    # note: m modifier treats string as multiple lines.
    $misc_usage_comments =~ s/^/# /gm;
    print($misc_usage_comments);
    ## OLD:
    ## print "# Notes:\n";
    ## print "# - Use + prefix to show entire translation (instead of $maxlen chars).\n";
    ## print "# - Use @ prefix to prettyprint the entry.\n";
    ## print "# - Use & prefix to use multiple lines when prettyprinting.\n";
    print "#\n";
    print "# word:	translation\n";
    print "#\n";
}

# Get the translations for each word in the text. Output each word with
# its translation on a separate line.
#
print($prompt);
outer:
while (<>) {
    chomp;	s/\r//;		# TODO: define my_chomp
    &dump_line();

    # Check for special directives (e.g., '+' for ignoring max-len restriction)
    my($full_line) = $full;
    my($pretty_print) = $pretty;
    my($multi_line) = $multi;
    my($translate_line) = $trans_line;
    my($translate_english) = &FALSE;
    my($log) = (&TEMP_DIR . "_qd_trans_spanish.$$.log");
  inner:
    while ($_ =~ /^[\+@&\*\<\>\!]/) {
	if ($_ =~ /^\+/) {      # mnemonic: longer length
	    $_ = $';		# ' (maldito emacs)
	    $full_line = &TRUE;
	}
	if ($_ =~ /^@/) {       # mnemonic ???: perl @ for "@all" prettyprint?
	    $_ = $';		# ' (maldito emacs)
	    $pretty_print = &TRUE;
	}
	if ($_ =~ /^&/) {       # mnemonic: line AND'ed together w/ newline (not tab)
	    $_ = $';		# ' (maldito emacs)
	    $pretty_print = &TRUE;
	    $multi_line = &TRUE;
	    ## OLD: $full_line = &TRUE;
	}
	if ($_ =~ /^\*/) {       # mnemonic: * wildcard ('.' conflict w/ period)
	    $_ = $';		# ' (maldito emacs)
	    $full_line = &TRUE;
	    $pretty_print = &TRUE;
	    $multi_line = &TRUE;
	}
	if ($_ =~ /^\</) {
	    $_ = $';		# ' (maldito emacs)
	    $translate_line = &TRUE;
	}
	if ($_ =~ /^\>/) {
	    $_ = $';		        # ' (maldito emacs)
	    $translate_line = &TRUE;
	    $translate_english = &TRUE;
	}

	# With ! indicator, run remainder as shell command and resume
	# note: useful for sp-, etc. aliases
	if ($_ =~ /^!/) {               # ' (maldito emacs)
	    my($command) = $';
	    ## OLD: print(&run_command("bash -i -c '$command' 2>| $log"));
	    print(&to_utf8(&run_command("bash -i -c '$command' 2>| $log")));
	    print("\n");
	    debug_out(6, "log: {\n%s}\n", &read_file($log));
	    next outer;
 	}
    }

    # Translate entire line
    # note: doesn't proceed with word lookup (TODO: allow for this along with pruning common terms)
    $text = "$_";
    if ($translate_line) {
	my($from) = ($translate_english ? "en" : "es");
	my($to) = ($translate_english ? "es" : "en");
	&debug_print(5, "running translation: f='$from' t='$to' txt='$text'\n");
	my($env_spec) = "SHOW_ELAPSED=1 FROM=$from TO=$to";
	my($save_trace_level) = &DEBUG_LEVEL;
	&debug_on(3);
        ## TODO3: rework so stdin redirection comes before stderr
        print(&to_utf8(&run_command_over("$env_spec machine_translation.py 2>| $log", 
					 "$text\n", 3)));
	print("\n\n");
	debug_out(6, "log: {\n%s}\n", &read_file($log));
	&debug_on($save_trace_level);
	next;
    }
    
    # Tokenize the line
    $text .= "\n";
    while ($text =~ /$sp_word_pattern/i) {
	$pre_delim = $`;
	$word = $1;
	$post_delim = $2;
	$rest = $';		# ' (maldito emacs)

	if ($pre_delim !~ /^[\t\n ]*$/) {
	    &debug_out(5, "pre: %s (%X)", $pre_delim, $pre_delim);
	    print "$pre_delim\n";
	}
	&debug_print(5, "$word ");

	## $word =~ tr/A-Z ÁÉÍÓÚÑÜ/a-záéíóúñü/;
	$word_lower = &sp_to_lower($word);

	# Get the word translation and truncate if necessary
	$translation = &sp_lookup_word($word_lower);
	if ((length($translation) > $maxlen) && (! $full_line)) {
	    my($end) = index($translation, " ", $maxlen);
	    $end = ($maxlen - 1) if ($end == -1);
	    $translation = substr($translation, 0, $end) . " ...";
	}

	# Fix quirks in the listing (e.g., no space after semicolon)
	# TODO: remove '~' preceding phrasal entries (e.g., "de ~nada" => "de nada"); make this part of sp_lookup_word
	$translation =~ s/;(\S)/; $1/g;

	# Print the entry with optional pretty printing
	# Note: Adds colon after each entry unless ends in one (e.g., 'Verb conjugations:)
	if ($pretty_print) {
	    my($listing) = &sp_pp_entry($word, $translation);
	    &debug_print(6, "listing: $listing\n");
	    ## OLD: $listing =~ s/\n/:\t/g;
	    # Replace newlines with ":<TAB>" and remove colon after last entry
	    $listing =~ s/([^:])\n/$1:\t/g;
	    $listing =~ s/:\t$//;
	    if ($multi_line) {
		# Restore newlines if multi-line output desired (n.b., replaces colons with semi-colons; TODO: retain first colon as used for word itself such as if there are accents added).
		$listing =~ s/:\t/;\n\t/g;
		# HACK: fixup missing tab (TODO: fix upstream)
		$listing =~ s/\n([^\t])/\n\t$1/g;

		# Put indicator of additional entry for word at start of line
		# ex: "ser (1)...\n\t1. (2) subst. v. to be" => "ser(1)...\nser (2):\n\t1. subst. v. to be"
		$listing =~ s/\n\t(\d\.) (\(\d\)) /\n$word $2:\n\t$1 /ig;

		# Similarly put indicator when verb conjugations given, especially after a set of noun definitions
		# Note: should only be one but sp_pp_entry over-generates (e.g., showing verb conjugations 
		# ex: "\t1. (animar pres_ind:2ps) tr. to animate.;" => "animar \t1. (pres_ind:2ps) tr. to animate.;"
		$listing =~ s/\n\t(\d\.) \(([\w]*) ([^\:]+:[^\:]+)\) /\n$2:\n\t$1 ($3) /ig;
		#                  sense    verb    person:POS
		
	    }
	    print "$listing\n";
	}
	else {
	    print "$word:\t$translation\n";
	}

	# Make a version of the Spanish-english dictionary containing just
	# the words encountered.
	if ($sp_make_dict == &TRUE) {
	    print TEMP_DICT "$word\t$word\t$translation\n";
	    }

	if ($post_delim !~ /^[\t\n ]*$/) {
	    &debug_out(5, "post: %s (%X)", $post_delim, $post_delim);
	    print "$post_delim\n";
	}

	$text = $rest;
    }
    print "$text\n";		# print remainder

    print($prompt) if (! eof);
}

# Cleanup
if ($sp_make_dict == &TRUE) {
    close(TEMP_DICT);
}

&exit();

#-------------------------------------------------------------------------------

# check_word: lookup the translation for a word
#
sub check_word {
    local($word) = @_;
    local($verb, $tense) = &sp_stem_verb($word);
    local($noun, $person) = &sp_stem_noun($word);

    if ($verb ne "") {
	print "$word:\t($verb, $tense)\t$sp_trans{$verb}\n";
    }
    if ($noun ne "") {
	print "$word:\t($noun, $person)\t$sp_trans{$noun}\n";
    }
}

# to_utf8 (text): encodes as UTF8 if enabled
#
sub to_utf8 {
    my($text) = @_;
    my($result) = $text;
    if ($utf8) {
	$result = decode_utf8($result);
    }
    &debug_print(&TL_VERBOSE, "to_utf8(@_) => $text\n");
    return ($result);
}
