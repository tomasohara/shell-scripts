# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -s
#
# new_align_all.perl: perform l-vector analysis on the English/Spanish text
# pair. This does text-specific preprocessing, invoked l_vec.perl, and then
# performs the pairwise checks for the best alignment.
#
# Originally the text was assumed to be English/Spanish biblical texts:
#    the first from the Library of the Future CD and the second from the following site
#    http://www.mit.edu:8001/afs/athena.mit.edu/activity/c/csa/www/documents/Spanish/Bible.html
#
# Thus, the built-in preprocessors are customized for this. However, 
# preprocessing can be done beforehand, since it just ensures that each
# sentence on a single line, and punctuation is separated from words 
# (similar to the requirements for the Brill preprocessor).
#
# TODO:
#    perl -pn -e "s/^([^\t]+\t[^\t]+\t).*/\1/;" < temp_english.lvec | gsort +1 -rn  >! english.freq
#
#    Make the language-specific preprocessing support separate.
#	
#    Have better handling of the preprocessed file (eg, temp_english.list)
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';


sub usage {
    local ($program_name) = $0;
    $program_name =~ s/\.?\.?\/?.*\///;

    select(STDERR);
    print <<USAGE_END;

Usage: $program_name [options] lang1_text lang1_text

options: [-skip_prep=0|1 -skip_lvec=0|1] -min_freq=num -max_freq=num]

notes:
    lang1 defaults to English, and lang2 defaults to Spanish
    The other language supported in Swedish, but English "should" work if
    the words are space-delimited.

examples:

$program_name rev_eng.text rev_sp.text

$program_name -min_freq=20 eng_revelations.text sp_revelations.text

nice +19 $program_name -min_freq=3 -max_freq=10 rev_eng.text rev_sp.text > & ! align_all.3.10.log

nice +19 $program_name -min_freq=10 eng_revelations.text sp_revelations.text >&! align_all.log

nice +19 ./new_align_all.perl -skip_prep=1 >&! new_align.log &

nice +19 ./new_align_all.perl -min_freq=10 -skip_prep=1 -skip_lvec=1 >&! new_align.log &

USAGE_END

    exit 1;
}


$min_freq = 3 unless defined($min_freq);
$max_freq = $MAXINT unless defined($max_freq);
$do_align = &TRUE unless defined($do_align);
$skip_prep = &FALSE unless defined($skip_prep);
$skip_lvec = &FALSE unless defined($skip_lvec);
$same_lang = &FALSE unless (defined($same_lang));
$lang1 = "english" unless (defined($lang1));
$lang2 = ($same_lang ? $lang1 : "spanish") unless (defined($lang2));

$text1 = shift @ARGV;
$text2 = shift @ARGV unless ($same_lang);


if (($same_lang && !defined($text1))
    || (!$same_lang && !defined($text2))) {
    &usage();
}

# Do text-specific preprocessing
#
if ($skip_prep == &FALSE) {
    &cmd("perl -Ss prep_$lang1.perl $text1 > temp_$lang1.list");
    &cmd("perl -Ss prep_$lang2.perl $text2 > temp_$lang2.list")
	unless ($same_lang);
} 
else {
    &cmd("cat $text1 > temp_$lang1.list");
    &cmd("cat $text2 > temp_$lang2.list")
	unless ($same_lang);
}

# Invoke the l-vec program
#
if ($skip_lvec == &FALSE) {
    &cmd("perl -Ss l_vec.perl -$lang1=1 temp_$lang1.list > temp_$lang1.lvec");
    if ($debug_level > 3) {
	&cmd("sort temp_$lang1.lvec > temp_$lang1.lvec-sa");
	&cmd("sort +1 -rn temp_$lang1.lvec > temp_$lang1.lvec-sf");
    }

    if (!$same_lang) {
	&cmd("perl -Ss l_vec.perl -$lang2=1 temp_$lang2.list > temp_$lang2.lvec");
	if ($debug_level > 3) {
	    &cmd("sort temp_$lang2.lvec > temp_$lang2.lvec-sa");
	    &cmd("sort +1 -rn temp_$lang2.lvec > temp_$lang2.lvec-sf");
	}
    }
}

# Try to align word pairs
#
# TODO

if ($do_align) {
    $args = "-min_freq=$min_freq -max_freq=$max_freq -same_lang=$same_lang";
    &cmd("perl -Ss new_align_words.perl $args temp_$lang1.lvec temp_$lang2.lvec");
}
