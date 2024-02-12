# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# strip_word_tags.perl: strip Penn Treebank word sense tags from text.
# This optionally removes other tagging specific to Rebecca Bruce's 
# tagged data.
#
# sample input:
#
#   $$
#   ====================================== [ integra/NP ] ,/, [ which/WDT ] own
#   s/VBZ and/CC operates/VBZ [ hotels/NNS ] ,/, said/VBD that/IN [ hallwood/NP
#   group/NP inc./NP ] has/VBZ agreed_1/VBN to/TO exercise/VB [ any/DT rights/
#   NNS ] [ that/WDT ] are/VBP n't/RB exercised/VBN by/IN [ other/JJ 
#   shareholders/NNS ] ./. 


# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';


# Check for special command-line vairables
#
&init_var(*rebeccas_data, &TRUE);
&init_var(*remove_sense, &FALSE);


# Define the Penn Treebank tags
#
$penn_tags = "CC CD DT EX FW IN JJ JJR JJS LS MD NN NNS NNP NNPS PDT POS PRP PRP\$ PP PP\$ RB RBR RBS RP SYM TO UH VB VBD VBG VBN VBP VBZ WDT WP WP\$ WPZ WRB , \. : \" \# \$ \' ( ) ";

if ($rebeccas_data) {
    $penn_tags .= "AB DTP NPP NPP\$ XE ";
}

debug_out(5, "penn_tags=$penn_tags\n");


# process each line of the input stream
#
while (<>) {
    dump_line($_);
    chop;
    
    $text = $_;
    $text =~ s/<[^>]+>//g;	# remove SGML tags
    $term = "\n";

    # Remove the brill tags, being careful not to remove the original text
    #
    $new = "";
    while ($text =~ /\/([^ \/]*) ?/) {
	$new .= $`;
	$tag = $1;
	$text = $';
	debug_out(6, "tag='$tag'\n");
	if (index($penn_tags, "$tag ") != -1) {
	    $new .= " ";	# remove Brill POS tags
	}
	else {
	    $new .= "/$tag ";	# keep this tag
	}
    }
    $new .= $text;
    $text = $new;

    # Substitutions specific to Rebecca Bruce's word-sense tagging
    #
    if ($rebeccas_data) {
	$text =~ s/\*x\*x(.*)x\*x\*//; # remove Treebank header
	$text =~ s/\[ *//g;	# remove phrase brackets ("[ Judge Curry ]")
	$text =~ s/ *\]//g;

	$text =~ s/===* *//g;	# remove delimiters ("================== ")

	# Transform 
	if ($remove_sense) {
	    $text =~ s/_[0-9]//g;	# remove the sense tag
	}
	else {
	    # Transform sense indicator into SGML tag
	    # example: 'interest_4' => '<sense 4>interest</sense>'
	    # TODO: perl -n -e 'chop; print "<s>$_</s>\n";' xyz
	    ## $text =~ s/([a-z]+)_([0-9])/<word sense=$2>$1<\/word>/i;
	    $text =~ s/([a-z]+)_([0-9])/<wf sense=$2>$1<\/wf>/i;
	}

	$text =~ s/\\([\/])/$1/g; # remove escape character ('\')

	$text =~ s/``\/`` ?/"/g;
	$text =~ s/ ?''\/''/"/g;

	if ($text =~ /\$\$/) {
	    $text = "";		# remove sentence delimiters
	}
	else {
	    $text =~ s/ *$//g;
	    $term = " ";
	}
    }

    # Do some more common substitutions
    #
    $text =~ s/ ([:.?,!%'])/$1/g; # remove space before punctuation
    $text =~ s/([\$]) /$1/g;    # remove space after others

    print "$text$term";		# print revised text
}
