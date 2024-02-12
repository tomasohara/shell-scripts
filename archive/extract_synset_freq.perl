# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/bin/perl -sw
#
# extract_synset_freq.perl: Extract the frequency for the WordNet synsets
# from the semantic concordance (SemCor) sense counts (cntlist).
#
# Each line in cntlist is of the form: 
#      tag_cnt sense_key sense_number 
# where
#    tag_cnt is the frequency of the sense in the corresponding semantic concordance
#    sense_key is a WordNet sense encoding (described in senseidx man page)
#    sense_number is a WordNet sense number (likewise)
#

# Load in the common module, making sure the script dir is first in Perl's lib path
BEGIN { $dir = `dirname $0`; chop $dir; unshift(@INC, $dir); }
require 'common.perl';
require 'extra.perl';

# Process the command-line options
if (!defined($ARGV[0])) {
    my($options) = "options = [-senses]";
    my($example) = "examples:\n\n$script_name cntlist\n\n";
    $example .= "cd \$WNSEARCHDIR/../semcor\n";
    $example .= "$0 */cntlist >| synset.freq\n";
    my($note) = "";
    $note .= "notes:\n\nSee WordNet documentation on CNTLIST (e.g., `man 5wn CNTLIST`).\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n$note\n";
}

&init_var(*WNSEARCHDIR, "/opt/local/pkg/wordnet-1.6/dict");
&init_var(*sense_index, &make_path($WNSEARCHDIR, "index.sense"));
&init_var(*senses, &FALSE);

my(%sense_mapping, %synset_words);
&read_index_mapping($sense_index, \%sense_mapping, \%synset_words);

# Read in the frequency information, conflating entries for the same synset
my(%synset_frequency);
while (<>) {
    &dump_line();
    chop;
    next if (/^[\#\;]/);	# ignore comments

    # Extract the key, convert to a synset ID and update the associated count
    ## my($count, $key, undef) = split;
    my($count, $key) = (($_ =~ /^(\S+)\s+(\S+)/));
    if (! defined($key)) {
	&error("Unexpected cntlist entry on line $.: $_\n");
	next;
    }
    ## my($ID) = $sense_mapping{$key} || "?????????";
    my($ID) = &get_entry(\%sense_mapping, $key, "");
    if ($ID eq "") {
	&warning("Unresolved sense key '$key' (freq=$count)\n");
	next;
    }
    &incr_entry(\%synset_frequency, $ID, $count);
}

# Display the frequency information
print "# freq\tsynset ID\twords\n";
my($key);
foreach $key (&sorted_hash_keys_reverse_numeric(\%synset_frequency)) {
    ## printf "%s\t%s\n", $key, $synset_frequency{$key};
    my($synset_words) = &trim($synset_words{$key});
    $synset_words =~ s/ / \| /g;
    printf "%s\t%s\t(%s)\n", $synset_frequency{$key}, $key, $synset_words;
}

&exit();


#------------------------------------------------------------------------------
# for wordnet.perl

# read_index_mapping(sense_index, sense_mapping_ref, [synset_words_ref]):
# Reads in the mapping from lexicographer sense IDs (eg 'person%1:03:00::')
# to synset IDs (eg, N00004123). The result is stored in the associative
# array keyed off of sense ID. In addition, an associative array giving
# the list of words in each synset is optionally returned.
#........................................................................
# Each line is of the form: 
#    sense_key synset_offset sense_number tag_cnt 
# where
#    sense_key is an encoding of the word sense.
#    synset_offset is the byte offset that the synset containing the sense is found at
#    sense_number is a decimal integer indicating the sense number of the word
#    tag_cnt represents the decimal number of times the sense is tagged
#
# sense_key = lemma%ss_type:lex_filenum:lex_id:head_word:head_id 
#    lemma is the ASCII text of the word or collocation
#    ss_type is a one digit decimal integer representing the synset type
#    lex_filenum is a two digit number for the name of the lexicographer file
#    lex_id is a two digit number for uniquely identifying sense, when appended onto lemma
#    head_word is lemma of the first word of the satellite's head (adjectives only)
#    head_id is the lex_id for head_word
#
# Synset type encoding: 
#    1 noun; 2 verb; 3 adjective; 4 adverb; 5 adjective satellite
#
# See senseidx(5) man page for more information
#........................................................................
# Sample input:
# caber%1:06:00:: 02362564 1 0
# cabernet%1:13:00:: 05920110 1 0
# cabernet_sauvignon%1:13:00:: 05920110 1 0
#
sub read_index_mapping {
    my($file, $mapping_ref, $synset_ref) = @_;
    $synset_ref = {} if (!defined($synset_ref));
    &debug_out(&TL_VERBOSE, "read_index_mapping(%s)\n", join(" ", @_));
    my(@POS) = ("", "N", "V", "A", "R", "A");

    if (! open(MAPPING, "$file")) {
	&error_out("Unable to read WordNet sense mapping file '$file' ($!)\n");
	return;
    }
    while (<MAPPING>) {
	my($key, $offset, $sense, $tag) = split;
	my($word, $POS_num) = (($key =~ /(\S+)%(\d)/));
	if ($senses) {
	    $word .= "#$sense";
	}
	my($POS) = $POS[$POS_num] || "?";
	my($ID) = "$POS$offset";
	## ${$mapping_ref}{$key} = $ID;
        &set_entry($mapping_ref, $key, $ID);
        &append_entry($synset_ref, $ID, "$word ");
    }
    close(MAPPING);

    return;
}
