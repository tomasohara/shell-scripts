# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw

# Merge a word-sense tagged file (w/ SID's) into a preprocessed file
# with SID's.
#
# Usage: merge_word_sense.perl preprocessed_master_file labelled_word_sense_file
#
# ex: merge_word_sense.perl w9_1tb.preprocess rebecca.sense_num
#
# Sample preprocessed_master_file input:
# <p pnum=1>
# <s snum=1 s_id=891101-0146_1_1>
# <wf pos=DT>The</wf>
# <wf pos=NN>key</wf>
# <wf pos=NNP>U.S.</wf>
# <wf pos=CC>and</wf>
# <wf pos=JJ>foreign</wf>
# <wf pos=JJ>annual</wf>
# <wf pos=NN>interest</wf>
# <wf pos=NNS>rates</wf>
# <wf pos=IN>below</wf>
# ...
#
# Sample rebecca.sense_num input:
# <s s_id=891101-0146_1_1>  Wednesday, November 1, 1989 The key U.S. and 
# foreign annual <wf sense=6>interest</wf> rates 
# ...
#
# Sample output:
# <p pnum=1>
# <s snum=1 s_id=891101-0146_1_1>
# <wf pos=DT>The</wf>
# <wf pos=NN>key</wf>
# <wf pos=NNP>U.S.</wf>
# <wf pos=CC>and</wf>
# <wf pos=JJ>foreign</wf>
# <wf pos=JJ>annual</wf>
# <wf pos=NN sense=6>interest</wf>
# <wf pos=NNS>rates</wf>
# <wf pos=IN>below</wf>
#
# Started: 24 Apr 96 by Tom O'Hara
#
# TODO:
# - generalize this to handle the other merge tasks (eg, mergepn)
# - add a bunch more sanity checks (e.g., sense tags not merged)
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

sub usage {
    local ($program_name) = $0;
    $program_name =~ s/\.?\.?\/?.*\///;	# drop path (opt. prefix ./ or ../)

    printf STDERR <<USAGE_END;

Usage: $program_name preprocessed_master_file labelled_word_sense_file

ex: $program_name w9_1tb.preprocessed rebecca.sense_num

USAGE_END

    exit 1;
}


# Parse the command-line arguments
if ($#ARGV != 1) {
    &debug_out(5, "#ARGV = $#ARGV; ARGV = %s\n", @ARGV);
    &usage;
}
$master_file = shift @ARGV;
open(MASTER_FILE, "< $master_file") || die "Unable to open $master_file!\n";
$sense_file = shift @ARGV;
open(SENSE_FILE, "< $sense_file") || die "Unable to open $sense_file!\n";

&assert('&main::sid_gt("891101-0157_12_35", "891101-0156_6_15")');
&assert('&main::sid_gt("891101-0157_0_10", "891101-0157_0_2")');

# Read in each line from the revision file and merge the new tags 
# into the corresponding line in the master file.
# NOTE: the input files are assumed to be ordered by SID
$master_line_num = 0;
$sense_line_num = 0;

# Get the first line from the master file
# NOTE: The reads are interleaved between the master and master file
# TODO: Read both files into memory
$_ = <MASTER_FILE>;
$_ = "\n" if (!defined($_));
chop;
&debug_out(6, "master L%d: %s\n", $master_line_num++, $_);
$master_line = $_;

while (<SENSE_FILE>) {
    chop;
    &debug_out(6, "sense L%d: %s\n", $sense_line_num++, $_);
    $sense_line = $_;

    # If this is a new sentence, then try to find merge revisions
    if ($sense_line =~ /<s [^<>]*s_id=([^>]+)>/i) {
	$sid_2 = $1;

	# Find the next sentence in the master-file that matches
	local($done) = &FALSE;
	while (!$done) {
	    if ($master_line =~ /<s [^<>]*s_id=([^>]+)>/i) {
		$sid_1 = $1;

		# If the 1st SID is before the second, the revision can't
		# be resolved properly, so issue an warning message and ignore
		# NOTE: The SID's are in ascending order.
		if (&sid_gt($sid_1, $sid_2)) {
		    &debug_print(2, "WARNING: unable to merge revision for $sid_2\n");
		    last;
		}

		# If the ID's are equal, merge in the next tags and stop
		elsif ($sid_1 eq $sid_2) {
		    $master_line = &merge_tags($master_line, $sense_line);
		    $done = $TRUE;
		}

		# The master SID is greater than the revision. Therefore,
		# the revision applies later in the file.
		else {
		    &debug_print(5, "master line not merged: $master_line\n");
		}
	    }
	    print "$master_line\n";
	    $master_line = "";

	    # Get the next line from the master file
	    if (eof(MASTER_FILE)) {
		$done = &TRUE;
	    }
	    else {
		$_ = <MASTER_FILE>;
		$_ = "\n" if (!defined($_));
		chop;
		&debug_out(6, "master L%d: %s\n", $master_line_num++, $_);
		$master_line = $_;
	    }
	}
    }

    # Otherwise, ignore the revision line
    else {
	&debug_print(5, "ignoring revision line '$sense_line'\n");
    }
}


# Print any remainder from the master-file
print $master_line if ($master_line ne "");
while (<MASTER_FILE>) {
    &debug_out(6, "master remainder L%d: %s", $master_line_num++, $_);
    print;
}


# merge_tags(master_line, revision_line): Merge in the revised tags from the
# revision file (eg, sense-file) into the current sentence from the
# master file (eg, preprocessed file).
#
# This first reads all the tagged words for the current sentence of the 
# preprocessed file, which are on separate lines for readability.
# Then the revision line(s) for the corresponding sentence are read in
# (not necessariliy one tag per line). For each tagged word of the revision,
# the tag attributes are extracted and merged in with the tags for the 
# corresponding attributes from the master. Note that new words aren't
# merged in, only attributes.
#
# NOTE: implemented by a special-purpose merge with following assumptions:
#     line1 contains the master set of wf tags (one per word; all words tags)
#     line2 contains set of tags to be merged (one per new tagging)
#
# TODO: use a more standard merge, rather than relying on pattern matching
#

sub merge_tags {
    local ($master_line, $sense_line) = @_;
    local ($sentence1, $sentence2, $revision, $text);
    ## global ($master_line_num);
    &debug_out(6, "merge_tags('%s', '%s')\n", $master_line, $sense_line);

    $sentence1 = $master_line;
    $revision = "";

    # Read all the tagged-words in the sentence
    # NOTE: all words in wf tags should not start with punctuation
    while (<MASTER_FILE>) {
	chop;
	&debug_out(6, "(merge_tags) master L%d: %s\n", $master_line_num++, $_);

	$sentence1 .= "\n$_";
	last if /<\/s>/;
	if (/<\/p>/) {
	    &warning("Missing <\/s> tag at master file L$master_line_num\n");
	    last;
	}
    }
    local($sentence1_data) = $sentence1;

    # sanity check for invalid punctuation occurring before or after words in wf tags
    # NOTE: exceptions are for dashes and underscores, as well as periods in
    # abbreviations (eg, "U.S.") and single quotes in contractions (eg, "'d")
    # example: "<wf sense=LOC>.In</wf>"
    # TODO: determine a more flexible test for the bad cases
    # NOTE: Mainly a sanity check for the preprocessing (eg, preparse.perl).
    my($other_punct) = "\,\.\:\;\!\@\#\\\$\%\^\&\*\(\)\{\}\[\]\"\/\\\\";
    my($PREPUNCT) = "[${other_punct}]";
    my($POSTPUNCT) = "[\'\.${other_punct}]";
    if (($sentence1 =~ /<wf [^<>]+>\s*$PREPUNCT[a-z0-9\_\-]/i)
	|| ($sentence1 =~ /<wf [^<>]+>\s*[a-z0-9\_\-].*$POSTPUNCT\s*<\/wf/i)) {
	&warning("Unexpected punctuation in wf tagging: $&\n");
    }

    # Determine the new tags from the second-file
    if ($sense_line =~ /<s s_id=([^>]+)>/i) {
	local($rest);
	$rest = $';
	## &assert('$rest eq ""');
	$sense_line = $';
    }
    $text = $sense_line;
    $sentence2 = $sense_line;
    while ($text ne "") {
	local($word);

	# Check for a new tagging to add to the revision.
	# NOTE: This is keyed off of the end tag. Also, all end tags are
	# considered to facilitate the word by word merging.
	# exs: "<wf sense=6>interest</wf>"
	#      " flat-rate capitation charge.  </s>"
	if ($text =~ /(<[^<>]*>)?([^<>]*)?(<\/[^<>]+>)/) {
	    $start_tag = defined($1) ? $1 : "";
	    $phrase = defined($2) ? &trim($2) : "";
	    $end_tag = $3;
	    $pre_text = $`;
	    $text = $';
	    &debug_out(6, "start='%s' phrase='%s' end='%s'\n", 
		       $start_tag , $phrase, $end_tag);

	    # sanity check for punctuation occurring before or after the phrase
	    # example: ";Up over"
	    if (($start_tag eq "wf") &&
		(($phrase =~ /^[^a-z\_\-\'][a-z\_\-]/i)
		 || $phrase =~ /^[a-z\_\-].*[^a-z\_\-\.]$/i)) {
		&warning("Unexpected punctuation in wf tagged phrase: $&\n");
	    }

	    # Stop when the end-of-sentence tag (</s>) is encountered
	    if ($end_tag eq "</s>") {
		## &assert('($start_tag eq "") && ($text eq "")');
		last;
	    }

	    # Insert special non-word tags as-is
	    if ($start_tag =~ /<ID/i) {
		&assert('$phrase eq ""');
		&assert('$end_tag =~ /<\/ID/i');
		$revision .= $start_tag . $end_tag;
		next;
	    }

	    # Skip over the master wf's prior to the current word
	    # TODO: make the matching more-dependent upon order
	    foreach $word (split(/\s+/, $pre_text)) {
		next if ($word !~ /^[a-z\-_]+$/i);
		$word =~ s/\-/\\-/g;
		if ($sentence1_data =~ /<wf ([^>]+)>$word<\/wf>\n/i) {
		    $revision .= $` . $&;
		    $sentence1_data = $';
		}
		elsif ($word !~ /[<>=]/) {
		    &debug_print(2, "WARNING: no wf for '$word' in master\n");
		}
	    }

	    # Note: The sense attribute is now kept as is
	    local($new_tag) = &translate_tag($start_tag);
	    &assert($new_tag !~ / word_sense=/i);

	    # Assign the tag to each word in the phrase
	    local($num_words) = 0;
	    my($tagged) = 0;
	    foreach $word (split(/\s+/, $phrase)) {
		## next if ($word !~ /^[a-z\-_]+$/i);
		$word =~ s/\-/\\-/g;
		if ($sentence1_data =~ /<wf ([^>]+)>$word<\/wf>\n/i) {
		    $num_words++;
		    $existing_tags = $1;
		    $revision .= $`;     # add stuff prior to the match
		    $sentence1_data = $';
		    ## &assert('($num_words == 1) || ($` eq "")');
		    $new_tagging = "<wf $existing_tags $new_tag>$word</wf>\n";
                    &debug_print(6, "$& => $new_tagging\n");
                    $revision .= $new_tagging;
		    $tagged++;
		}
		else {
		    &debug_print(6, "WARNING: untagged merged word: '$word'\n");
		}
	    }
	    &assert($tagged > 0);

	    if (($text eq "") && <SENSE_FILE>) {
		chop;
		&debug_out(6, "(mt) sense L%d: %s\n", $master_line_num++, $_);
		$text .= $_;
		$sentence2 .= $_;
	    }
	}
    }
    $revision .= "$sentence1_data";
    &debug_print(7, "\nrevision: {\n$revision\n}\n");

    # Sanity check: the two lines should be (roughly) equivalent
    &assert('equiv_lines($sentence1, $sentence2, 0.5)');

    return ($revision);
}


# See whether the two "lines" of text are equivalent after removing
# SGML tags. This just checks to see whether the intersection is greater
# than some threshold.
#
sub equiv_lines {
    local ($line1, $line2, $threshold) = @_;

    # Remove SGML tags and put space around punctuation
    $line1 =~ s/<[^<>]+>//g;
    $line1 =~ s/(\S)([,;.:])/$1 $2/g; # add space around certain punctuation
    $line2 =~ s/<[^<>]+>//g;
    $line2 =~ s/(\S)([,;.:])/$1 $2/g; # add space around certain punctuation
    local (@words1) = split(/\s+/, $line1);
    local (@words2) = split(/\s+/, $line2);
    local (@intersect) = &intersection(*words1, *words2);
    local ($ok) = ((1 + $#intersect) >= ((1 + $#words1) * $threshold));
    &debug_out(7, "#intersect = %d; match threshold = %.2f\n", 
	       (1 + $#intersect), ((1 + $#words1) * $threshold));
    &debug_out(7, "%d <= equiv_lines('%s', '%s', %.2f)\n",
	       $ok, join(' ', @words1), join(' ', @words2), $threshold);
    
    return ($ok);
}

# translate_tag(tagging)
#
# Change the attributes from the start tag in the update file to have
# attributes with the surrounding tags removed.
#
# examples: 
#   "<word sense=1>" => sense=1"
#   "<wf sense=1>" => "sense=1"
#   "<wf POS=n sense=1>" => "POS=n sense=1"
#
# TODO: handle tags with multiple attributes (eg, <tag attr1=a attr2=b>)
#

sub translate_tag {
    local ($new_tag) = @_;

    # Drop the tag brackets and remove extraneous spaces
    $new_tag =~ s/<\S+//g;
    $new_tag =~ s/[<>]//g;
    $new_tag =~ s/\s+/ /g;
    $new_tag = &trim($new_tag);

    # Standardize name of special tags (eg, the word sense tags)
    ## $new_tag =~ s/wf_sense/word_sense/ig;
    &debug_print(8, "translate_tag(@_) => $new_tag\n");

    return ($new_tag);
}


# article_gt: determine if the first SID is in a article that occurs
# after the article for the second
# ex: &article_gt("891101-0157_12_35", "891101-0156_6_15") == 1
#     &article_gt("891101-0157_12_35", "891101-0157_6_15") == 0
#
sub article_gt {
    local($sid1, $sid2) = @_;

    # Extract the date and article components from the sentence ID
    $sid1 =~ s/_/-/g;
    $sid2 =~ s/_/-/g;
    local($date1, $article1, $para1, $sent1) = split(/-/, $sid1);
    local($date2, $article2, $para2, $sent2) = split(/-/, $sid2);
    local($gt);

    # Determine if the article for the second ID follows the first
    $gt = (($date1 >= $date2) && ($article1 > $article2))
	? $TRUE : $FALSE;
    &debug_print(8, "article_gt(@_) => $gt\n");
  
    return ($gt);
}


# sid_gt: determine if the first SID is logically greater than the second
# ex: &sid_gt("891101-0157_12_35", "891101-0156_6_15") == 1
#
sub sid_gt {
    local($sid1, $sid2) = @_;

    # Extract the date, article, paragraph and sentences components from 
    # the sentence ID
    $sid1 =~ s/_/-/g;
    $sid2 =~ s/_/-/g;
    local($date1, $article1, $para1, $sent1) = split(/-/, $sid1);
    local($date2, $article2, $para2, $sent2) = split(/-/, $sid2);
    local($gt);

    # Determine if the second sentence ID follows the first. This converts
    # the IDs into a gregorian-style numeric to facilitate the comparison.
    # TODO: develop a more-efficient scheme
    local($id1) = $date1 * 10**9 + $article1 * 10**4 + $para1 * 10**2 + $sent1;
    local($id2) = $date2 * 10**9 + $article2 * 10**4 + $para2 * 10**2 + $sent2;
    &debug_print(9, "comps1=($date1, $article1, $para1, $sent1); id1=$id1\n");
    &debug_print(9, "comps2=($date2, $article2, $para2, $sent2); id2=$id2\n");
    $gt = ($id1 > $id2) ? &TRUE : &FALSE;
    &debug_print(8, "sid_gt(@_) => $gt\n");
  
    return ($gt);
}
