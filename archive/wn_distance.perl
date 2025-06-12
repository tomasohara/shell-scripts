# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -s
#
# wn_distance.perl: calculates the "distance" in WordNet between the
# words
# TODO:
# - use wordnet.perl module (especially for caching wn output)
# - include other types of relations
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';
 
if ($ARGV[1] eq "") {
	die("Usage: wn_distance.perl word1 word2\n");
	}
$wn = ($w eq "") ? "wn" : $w;			  # "-w=c:\bin\wn.exe"

$word1 = $ARGV[0];
$word2 = $ARGV[1];

# Get the list of subsumers for each word
#
$subsumers1 = &get_subsumers($word1);
$subsumers2 = &get_subsumers($word2);

$sense1 = 0;
foreach $subsumers_group1 (split(/\t/, $subsumers1)) {
    $sense1++;
    $sense2 = 0;
    foreach $subsumers_group2 (split(/\t/, $subsumers2)) {
	debug_out(5, "subsumers_group1=$subsumers_group1\n");
	debug_out(5, "subsumers_group2=$subsumers_group2\n");
	$sense2++;

	$found = $FALSE;
	@subsumers1 = split(/ /, $subsumers_group1);
	for ($pos1 = 1; $pos1 <= $#subsumers1; $pos1++) {
	    $subsumer1 = $subsumers1[$pos1];
	    $pos2 = 0;
	    @subsumers2 = split(/ /, $subsumers_group2);
	    for ($pos2 = 1; $pos2 <= $#subsumers2; $pos2++) {
		$subsumer2 = $subsumers2[$pos2];
		if ($subsumer1 eq $subsumer2) {
		    $found = $TRUE;
		    printf "$subsumers1[0] vs. $subsumers2[0]\n";
		    printf "pos1=$pos1 pos2=$pos2 found=$found (subsumer1=$subsumer1;subsumer2=$subsumer2)\n";
		    last;
		}
	    }
	    debug_out(5, "pos1=$pos1 pos2=$pos2 found=$found\n");	    
	    if ($found) {
		last;
	    }
	}
	if ($found) {
	    ## whatever
	}
    }
}


# Given a word, return the list its subsumers (i.e., hypernyms or ancestors).
# Note that spaces within the words are replaced by unerscores.
#
# &get_subsumers(plastic) => " solid substance object entity "
#
sub get_subsumers {
    local($word, $sense_spec) = @_;
    local($hyp_list, $subsumer);

    $sense_spec = "";
    if ($word =~ /(.*)#([0-9]+)/) {
	$word = $1;
	$sense_spec = "-n$2";
    }

    &debug_out(3, "Issuing: $wn $word $sense_spec -hypen |\n");
    open(HYP_FILE, "$wn $word $sense_spec -hypen |");

    $hyp_list = "";
    while (<HYP_FILE>) {
	chop;
	# Check for the sense indicator
	if (/^Sense ([0-9]+)/) {
		$sense = $1;
		$_ = <HYP_FILE>;
		chop;
		$synonyms = $_;
		if ($hyp_list ne "") {
			$hyp_list .= "\t";
			}
		$hyp_list .= "$word#$sense: ";
		}
	# Check for the hypernym
	elsif (/=> ([^,]+)/) {
	    # add (first) hypernym to the subsumer list
	    $subsumer = $1;
	    $subsumer =~ tr/ /_/;
	    $hyp_list .= "$subsumer ";
	}
    }
    close(HYP_FILE);
    ## unlink($word.hyper);
    &debug_out(4, "get_subsumers($word) => $hyp_list\n");

    return ($hyp_list);
}


# Given a word, return the list its subsumers (i.e., hypernyms or ancestors).
# Note that spaces within the words are replaced by underscores.
#
# &get_subsumers(plastic) => " solid substance object entity "
#
sub new_get_subsumers {
    local($word) = @_;
    local(@hyp_list, $i, $num, $subsumer);


    &debug_out(3, "Issuing: $wn $word -hypen |\n");
    open(HYP_FILE, "$wn $word -hypen |");

    $num = 0;
    while (<HYP_FILE>) {
	chop;
	# Check for the sense indicator
	if (/^Sense ([0-9]+)/) {
	    $sense = $1;
	    $_ = <HYP_FILE>;
	    chop;
	    $synonyms = $_;
	    $hyp_list[$i] = "$word#$sense";
	}
	# Check for the hypernym
	elsif (/=> ([^,]+)/) {
	    # add (first) hypernym to the subsumer list
	    $subsumer = $1;
	    $subsumer =~ tr/ /_/;
	    $i++;
	    $hyp_list[$i] = "$subsumer";
	}
    }
    close(HYP_FILE);
    &debug_out(4, "get_subsumers($word) => (@hyp_list)\n");

    return (@hyp_list);
}

