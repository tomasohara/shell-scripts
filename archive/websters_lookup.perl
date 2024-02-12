# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# websters_lookup.perl: lookup the word in Webster's New World Dictionary
#
# TODO: derive a pattern for faster searching
#
# NOTES: steps in preparing dictionary 
# 1) get dict.dat from Software Toolwork's Reference Library CD
# 2) separate into smaller files
#    gsplit --lines=40000 dict.dat dict_
# 3) convert new-entry chars (^B) to newlines and remove other special codes
#    perl -i.bak -p -e "s/\x02 */\n/; s/[^\x20-\x7F\x0D\x0A\x09]//g;" dict_a?
# 4) verify files and then remove backup files
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';		# common module
require 'wordnet.perl';		# used for stemming words

if (!defined($ARGV[0])) {
    $options = "[-c=context] [-p=prefix] [-whole=0|1] [-suffix=pattern]";
    die "\nusage: websters_lookup.perl [options] word\n\noptions = $options\n\n";
}

$word = $ARGV[0];
$word =~ tr/A-Z/a-z/;
$file = "";
&init_var(*pre_context, 0);
$post_context = defined($c) ? $c : 75;
$prefix = (defined($p) && ($p == 1)) ? "-" : "";
&init_var(*whole, &TRUE);
&init_var(*phrase, &FALSE);

if (!defined($suffix)) {
    $suffix = ($whole ? "[a-z]*" : "");

    ## $suffix .= "\({[0-9]}\)? [a-z]*\\." unless ($phrase || !$whole);
}

&debug_out(5, "word=$word; prefix=$prefix whole=$whole phrase=$phrase\n");
$word_option = ($whole ? "-w" : "");

## TODO: eliminate boundary words in the data file
if ($word lt "breathalyzer") { $file = "dict_aa"; }
elsif  ($word lt "cut") { $file = "dict_ab"; }
elsif  ($word lt "flabellate") { $file = "dict_ac"; }
elsif  ($word lt "imperial moth") { $file = "dict_ad"; }
elsif  ($word lt "mediation") { $file = "dict_ae"; }
elsif  ($word lt "petri plate") { $file = "dict_af"; }
elsif  ($word lt "rowdily") { $file = "dict_ag"; }
elsif  ($word lt "stress") { $file = "dict_ah"; }
elsif  ($word lt "videlicet") { $file = "dict_ai"; }
else { $file = "dict_aj"; }

&init_var(*HOME, "/home/ch1/tomohara");
&init_var(*info_dir, "$HOME/info");

local($result) = &lookup($word);
if ($result eq "") {
    local($POS, $root);
    foreach $POS ("noun", "verb", "adj", "adv") {
	$root = &wn_get_root($word, $POS);
	if ($root ne $word) {
	    $result = &lookup($root);
	    last if ($result ne "");
	}
    }
}
print "$result\n";


#------------------------------------------------------------------------------


# lookup(word): lookup the word's entry in Webster's, including entries
# surrounding it based on the grep context
# 
sub lookup {
    local($word) = @_;
    local($result);
    &debug_out(5, "lookup(@_)\n");

    $word_pattern = "\"^$prefix$word$suffix\" ";
    $command = "zcat $info_dir/$file | egrep -i $word_option -B$pre_context -A$post_context $word_pattern";

    $result = &run_command($command);
    return ($result);
}


# get_program_dir: returns the directory containing the script
#
sub get_program_dir {
    local ($dir);

    $dir = $0;
    $dir =~ s/\/?[^\/]*$//;
    if ($dir eq "") {
	$dir = ".";
    }

    return ($dir);
}
