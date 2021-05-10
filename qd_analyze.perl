# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# qd_analyze.perl: quick & dirty analysis of Spanish text
#
# This script is intended to support a translation assistant, in lines with
# Martin Kay's suggestion for the "translator's amanuensis". Therefore, the
# text is analyzed to produce all the possible word translations and to
# provide suggestions for likely
#
# Currently, the user interface is in Visual Basic (see trans_assist.mak).
# So, to avoid doing any real programming in Basic, Perl scripts are used
# for the translation assistant proper.
#
# TODO:
#    Have option to extract corpus samples for each of the word translations.
#
#    Consider converting everything into Java.
#
# REFS:
#    Kay, Martin (1997), ``The Proper Place of Men and Machines in
#    Language Translation'', {\em Machine Translation} 12: 3-23, reprinted
#    from 1980 Xerox PARC Working Paper.
#

# Load in the common module, making sure the script dir is in Perl's lib path
$dir = `dirname $0`; chop $dir; unshift(@INC, $dir);
require 'common.perl';

# Check the command-line arguments
#

&init_var(*for_trans_assist, &FALSE);

if (!defined($ARGV[0])) {
    $options = "options = [-for_trans_assist=0|1]";
    $example = "ex:\nnice  +19 $script_name -for_trans_assist=1 sospechoso.text\n >&! sospechoso.log";

    die "\nusage: $script_name [options] spanish_text\n\n$options\n\n$example\n\n";
}

$file = $ARGV[0];
$base = &basename($file, ".text");

# Run through part-of-speech tagger (result = $base.post)
# TODO: develop perl script for this
&issue_command("tag_spanish.sh $file");

# Lookup all the word translations (result = $base.list)
&run_perl("qd_trans_spanish.perl $file > $base.wtrans");

# Try to disambiguate the word translations.
# As a by-product, the lexical relations for each sense of a given source
# word are produced.
&run_perl("disambig_entries.perl -d=5 -base=$base $base.wtrans > $base.disambig &");

# Produce support files for trans_assist.perl
if ($for_trans_assist) {
    ## &copy_file("$base.prep", "$base.source");
    &run_perl("preparse.perl $file > $base.source");

    # Produce separate pretty-printed entries (that is, by word)
    &run_perl("pp_entry.perl -split_output=1 $base.wtrans > $base.pp");

    # Similarly produce separate lex-rel listings (this time, by sense).
    &run_perl("split_lexrels.perl $base.rels");
}


#------------------------------------------------------------------------------


# run_perl(command_line)
#
# Invoke perl to process the specified command-line. Normally, this includes
# the script to run:
#	&run_perl("testit.perl a b c") 
# That is, this is intended as a shortcut to issue_command:
#	&issue_command("perl -Ssw testit.perl a b c");
# 
sub run_perl {
    local($command_line) = @_;
    
    &issue_command("perl -Ssw $command_line");

    return;
}


# copy_file(source_file, destination_file)
#
# Copies the source file to the destination. (OS-independent)
#
sub copy_file {
    local ($source, $destination) = @_;
    local ($text);

    $text = &read_file($source);
    &write_file($destination, $text);

    return;
}
