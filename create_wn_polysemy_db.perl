# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# create_wn_polysemy_db.perl: create database listing the ploysemy counts
# for the words in WordNet
#
# NOTE:
# - This is just a simple script that scans through the Ascii 
# ndex files and accumulates the polysemy values for each word.
# - The database is just used for testing purposes.
#
# ------------------------------------------------------------------------
#  WN 1.6 DB format (see /cyc/nl/external-code/WORDNET/1.6/README.FORMAT)
#
#  synopsis:
#  Index: lemma  pos  poly_cnt  p_cnt  [ptr_symbol...]  sense_cnt  tagsense_cnt   synset_offset  [synset_offset...]
#
#  Data: synset_offset  lex_filenum  ss_type  w_cnt  word  lex_id  [word  lex_id...]  p_cnt  [ptr...]  [frames...]  |  gloss
#
#  example:
#
#  bash$ grep "^mouse n" index.noun
#  mouse n 2 2 @ ~ 2 1 01832174 03020109  
#
#  $ pushd /opt/local/pkg/wordnet-1.6/dict/
#  $ grep -w smoke index.[nva]* | less
#  index.adj:smoke-cured a 1 1 & 1 0 01021112  
#  index.adj:smoke-dried a 1 1 & 1 0 01021112  
#  index.adj:smoke-filled a 1 1 & 1 0 02128498  
#  index.adj:smoke-free a 1 1 & 1 0 02128783  
#  index.noun:smoke n 8 5 @ ~ #s #p %p 8 2 07835271 09739257 05094081 03739574 03249129 02376183 00535462 00068711  
#  index.verb:smoke v 2 4 + @ ~ * 2 1 00815217 01891088  
#
# Copyright (c) 2000 - 2001 Cycorp, Inc.  All rights reserved.
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir);
    require 'common.perl';
}

# Use module for automatic DB selection
use Fcntl;
use AnyDBM_File;

# Process the command line options
if (!defined($ARGV[0])) {
    my($options) = "options = [-WNSEARCHDIR=path] [-POS=label]";
    my($example) = "examples:\n\n$script_name wn_polysemy.data\n\n";
    $example .= "$0 -POS=noun wn_nouns_polysemy.data\n";

    die "\nusage: $script_name [options] output_file\n\n$options\n\n$example\n\n";
}
my($output_file) = $ARGV[0];

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
use vars qw/$WNSEARCHDIR $POS $verbose/;
no strict "subs";

&init_var(*WNSEARCHDIR, 	# WordNet data directory
	  "/home/shared/graphling/TOOLS/WORDNET-2.0/dict");
&init_var(*POS, "all");		# WordNet part-of-speech
&init_var(*verbose, &FALSE);	# verbose output mode
my(@wn_POS_labels) = ($POS eq "all") ? ("noun", "verb", "adj", "adv") : ($POS);

# Initialize the database for the file
my(%wn_polysemy);
tie %wn_polysemy, AnyDBM_File, $output_file, (O_CREAT|O_TRUNC|O_RDWR), 0755
    or die "Error: Cannot create database file '$output_file' ($!)";

# Scan the index files for each part-of-speech, accumulating the polysemy
# for each word.
foreach $POS (@wn_POS_labels) {
    my($file) = &make_path($WNSEARCHDIR, "index.$POS");
    open(INDEX, "<$file") or
	&exit("Unable to open WordNet index file '$file' ($!)\n");
    while (<INDEX>) {
	if (/^(\S+) \S (\d+)/) {
	    my($word, $polysemy) = ($1, $2);
	    &incr_entry(\%wn_polysemy, $word, $polysemy);
	}
    }
    close(INDEX);
}

# Display the polyemy data in tab-delimited format
#   <word><TAB><ploysemy>
if ($verbose) {
    foreach my $word (sort(keys(%wn_polysemy))) {
	printf "%s\t%s\n", $word, $wn_polysemy{$word};
    }
}

&exit();
