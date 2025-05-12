# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/local/bin/perl -sw
#
# qd_trans_latin.perl: quick and dirty Latin translation of text
#
# NOTE: This is just a word-by-word translation of the text. It uses
# the Latin lookup program (words.exe) developed by William Whitaker.
#

## OLD: require 'common.perl';

BEGIN { 
    my $dir = $0; $dir =~ s/[^\\\/]*$//; unshift(@INC, $dir);
    require 'common.perl';
    use vars qw/$unix/;
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's below).
use strict;
use vars qw/$by_sentence $HOME $multiling_dir $LATIN_DIR $latin_lookup/;


if (!defined($ARGV[0])) {
    my($options) = "options = [-by_sentence] [-LATIN_DIR=dir] [-latin_lookup=program]";
    my($example) = "ex: echo 'affirmo' | $script_name -\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
}

&init_var(*by_sentence, &FALSE);
# TODO: add MULTILING_DIR environment variable
## OLD: &init_var(*multiling_dir, "c:/tom/MultiLingual");
&init_var(*HOME, "~");
&init_var(*multiling_dir, "$HOME/MultiLingual");
&init_var(*LATIN_DIR, $multiling_dir . "/Latin");
my($wine_prefix) = ($unix ? "wine " : "");
&init_var(*latin_lookup, "${wine_prefix}$LATIN_DIR/Latin-Words.exe");

# Preprocess the text prior to translation
my($text) = "";
while (<>) {
    &dump_line();
    chop;

    # Convert blank lines into special code (words.exe ignores punctuation)
    s/^\s*$/-----\./;

    # Add to text to be translated
    $text .= "$_\n";
}
if ($by_sentence) {
    $text =~ s/([^\.!?]) *\n/$1 /g; 	# remove return in middle of sentence
    $text =~ s/([\.!?]) *([^\n])/$1\n$2/g; 	# add return at end of sentence
}
$text .= "\n";			# blank line to signal end

# Run the word-translation program over the text
my($temp_source) = "/tmp/temp_$$.text";
&write_file($temp_source, $text);
chdir $LATIN_DIR;
my($trans) = &run_command("${latin_lookup} < $temp_source");

# Pretty print the results (sort-of)
$trans =~ s/^[^\000>]+=>/=>/;	# remove the header
our($word) = "";
our($last_word) = "";
our($word_trans) = "";
our($word_syntax) = "";
our($root_and_ending) = "";
foreach $_ (split(/\n/, $trans)) {
    &dump_line();
    s/\r//;
    my($new_root_and_ending) = "";
    my($syntax_info) = "";
    if (/^(\S+).*===.*UNKNOWN/) {
	$new_root_and_ending = $1;
	if ($word_trans ne "") {
	    &output_entry();
	}
	$word = $new_root_and_ending;
	$word_trans = "Unknown entry";
	&output_entry();
    }
    elsif (/^=>/) {
	# Ignore the original text
	print "\n";
	$last_word = "";
    }
    elsif (/^(\S+\.[aeiou]\S*)\s+(\S.*)/ || /^(\S+)     *(\S.*)/) {
	$new_root_and_ending = $1; $syntax_info = $2;

	## &assert('($root_and_ending eq "") || ($root_and_ending eq $new_root_and_ending)');
	$root_and_ending = $new_root_and_ending 
	    unless ($root_and_ending ne "");
	$word = $new_root_and_ending;
	$word =~ s/\.//;
	$word_syntax .= "$syntax_info;";
    }
    else {
	# Add the text to the word's meaning
	$word_trans .= "$_";

	# If the syntax has already been given, then output the entry
	if ($word_syntax ne "") {
	    &output_entry();
	}
    }
}
&assert('$word_syntax eq ""');
&assert('$word_trans eq ""');
if ($word_trans ne "") {
    &output_entry();
}

# Cleanup things
unlink $temp_source unless (&DEBUGGING);

#------------------------------------------------------------------------------

# output_entry(): print the word-translation entry
#
sub output_entry {
    &debug_print(5, "output_entry(@_)\n");

    $word_trans =~ s/  */ /g;
    $word_syntax =~ s/  */ /g;
    $word_syntax =~ s/;$//;
    my($word_form) = ($word eq $last_word) ? "" : $word;
    printf "%s\t%s", $word_form, $word_trans;
    if ($word_syntax ne "") {
	printf " [%s: %s]", $root_and_ending, $word_syntax;
    }
    printf "\n";

    # Reset variables
    $word_trans = "";
    $word_syntax = "";
    $root_and_ending = "";
    $last_word = $word;

    return;
}

