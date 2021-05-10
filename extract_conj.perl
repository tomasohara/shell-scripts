# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# extract_conj.perl: extract verb conjugations from dictionary entry
# (assumed to be pretty-printed)
# 
# TODO: make variables local
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';
require 'spanish.perl';

$root = "";
while (<>) {
    &dump_line();
    chop;

    # Get verb headword
    if (/^ *$/) {
	$root = "";
	next;
    }
    if ($root eq "") {
	$root = $_;
	next;
    }

    # Skip sense definitions
    if (/^[0-9]+\./) {
	next;
    }

    # Skip other stuff (TODO: make pp format easier to parse)
    next if ($_ !~ /\t/);

    # Produce irregular verb conjugation entries
    # TODO: rename tense using convention in spanish.perl
    ($tense, $singular, $plural) = split(/\t/, $_);
    &assert('defined($singular)');
    $plural = "" unless (defined($plural));
    @verbs = split(/,/, "$singular,$plural");
    for ($p = 1; $p <= 6; $p++) {
	local($form) = $verbs[$p - 1];
	if (defined($form) && ($form ne "n/a")) {
	    local ($form_alt, $person, $number, $pers_num);
	    $person = ($p < 4) ? $p : ($p - 3);
	    $number = ($p < 4) ? "s" : "p";
	    $pers_num = "${person}p${number}";

	    # Make two entries if alternative form given
	    if ($form =~ /(.*) or (.*)/) {
		$form = $1;
		$form_alt = $2;
	    }

	    # Print the entries
	    $form =~ s/^ *//;	# get rid of extraneous spacing
	    $trans = "$tense $pers_num of $root";
	    &print_dict_entry($form, $trans);
	    if (defined($form_alt)) {
		&print_dict_entry($form_alt, $trans);
	    }
	}
    }
}


# print_dict_entry(word, translation)
#
# Print a dictionary entry for the word in the following format:
#
#     Key<TAB>Word<TAB>Translation
#
# where the key is the word without diacritic marks.
#
sub print_dict_entry {
    local($word, $trans) = @_;
    local($key) = &sp_remove_diacritics($word);

    print "$key\t$word\t$trans\n";
}
