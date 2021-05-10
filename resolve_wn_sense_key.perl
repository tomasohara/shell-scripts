# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# resolve_wn_sense_key.perl: resolve the synset for the Wordnet
# sensekey (see man page on senseidx)
#
# sample input:
# 
#    stereo%1:06:00::
#
# sample output:
#
#    1
#
#------------------------------------------------------------------------
# Notes:
#
# This is based on an script used for SEMCOR subjectivity analysis that
# printed the definition given the sense ID. By default, this version just 
# prints the ID.
#
# C:\WN16\DICT>grep 'stereo%1:06:00::' sense.idx
# stereo%1:06:00:: 03411597 1 5'
#
# C:\WN16\DICT>wn-nt.exe stereo -synsn -n1 -g
#
# Synonyms/Hypernyms (Ordered by Frequency) of noun stereo
#
# Sense 1
# stereo, stereo system, stereophonic system -- (two microphones feed two or more loudspeakers to give a three-dimensional effect to the sound)
#        => reproducer -- (an audio-system that can reproduce and amplify signals to produce sound)
#
#........................................................................
#
# from senseidx man page:
#
#   The sense index file lists all of the senses in the  Word-
#   Net  database  with each line representing one sense.  The
#   file is in alphabetical order, fields are separated by one
#   space,  and each line is terminated with a newline character.
#
#   Each line is of the form:
#          sense_key  synset_offset  sense_number  tag_cnt
#
#   A sense_key is represented as:
#          lemma%lex_sense
#   where lex_sense is encoded as:
#          ss_type:lex_filenum:lex_id:head_word:head_id
#
#   lemma is the ASCII text of  the  word  or  collocation  as
#   found  in the WordNet database index file corresponding to
#   pos.  lemma is in lower case, and collocations are  formed
#   by joining individual words with an underscore (_) character.
#
#   ss_type is a one digit decimal integer representing the synset
#   type for the sense [eg, 1 for noun, 2 for verb]
#
#   lex_filenum is a two digit decimal integer representing the name
#   of the lexicographer file
#
#   lex_id is a two digit decimal integer [to] uniquely identifies
#   sense within a lexicographer file
#
#   head_word is the lemma of the first word of the adjective
#   satellite's head synset
#
#   head_id is a two digit decimal integer [to] uniquely identifies
#   the sense of head_word
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir);
    require 'common.perl';
    use vars qw/$script_name $under_WIN32 $unix/;
}

use strict;
use vars qw/$WNSEARCHDIR $sense_index $wn $include_def $use_offset/;

if ((defined($ARGV[0]) && ($ARGV[0] eq "help"))
    || (!defined($ARGV[0]) && &blocking_stdin())) {
    my($options) = "options = [-include_def] [-use_offset] [-unix]";
    my($example) = "ex: $script_name 'stereo%1:06:00::'\n";

    print STDERR "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
    &exit();
}

my($win32) = &under_WIN32();
&init_var(*WNSEARCHDIR, $win32 ? "\\wn16\\dict\\" : "/home/graphling/TOOLS/WORDNET-1.6/dict/");
&init_var(*sense_index, 
	  &make_path($WNSEARCHDIR, $unix ? "index.sense" : "sense.idx"));
## &init_var(*wn, $win32 ? "wn.exe" : "wn");
&init_var(*wn, $unix ? "wn" : "wn.exe");
&init_var(*include_def, &FALSE);	# include synset info (synonyms and definition)
&init_var(*use_offset, &FALSE);		# show synset offset not sense number

# Mapping from sense-ID speech-part codes into WordNet's letter speech-part indicators
my(%wordnet_POS_letter) = ( "1" => "n",
			    "2" => "v",
			    "3" => "a",
			    "4" => "r",
			    "5" => "a" );

# Get list of IDs to process
my(@IDs);
if (($#ARGV == 0) && ($ARGV[0] eq "-")) {
    # Assume the IDs are given one per line in the standard input
    @IDs = <STDIN>;
}
else {
    @IDs = @ARGV;
}

my($ID);
foreach $ID (@IDs) {
    $ID = &trim($ID);

    # check for next sense key
    # ex: knight-errant%1:18:00::
    if ($ID =~ /(\S+)%(\d+):\d+:\d+:\S*:\S*/) {
	my($key, $entry, $type) = ($&, $1, $2);
	my($POS_letter) = $wordnet_POS_letter{$type};

	# get the sense number for the entry
	# ex: "knight-errant%1:18:00:: 07359022 1 2" => 1
	my($mapping) = &run_command("grep \"^$key\" ${sense_index}");
	if ($mapping =~ /$key (\d{8}) (\d+) \d+/) {
	    my($synset_offset) = $1;
	    my($sense_num) = $2;
	    my($sense_label) = $sense_num;
	    if ($use_offset) {
		$sense_label = &to_upper($POS_letter) . $synset_offset;
	    }

	    print "$sense_label\n";
	    if ($include_def) {
		my($info) = &run_command("$wn $entry -syns${POS_letter} -n$sense_num -g");
		print "$info\n";
		print "\n";
	    }
	}
	else {
	    &error("Unable to resolve sense ID $ID\n");
	}
    }
    else {
	&error("Unexpected sense ID format: $ID\n");
    }
}
