# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# show_similarity.perl: using the LSI data for the text, show the N most-similar
# documents for each document
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

# TODO: have a separate module for lsi common code
#
# Determine the number of documents from the RUN_SUMMARY file
if (!defined($num_docs) && (-e "RUN_SUMMARY")) {
    $doc_info = &run_command("grep NDOCS RUN_SUMMARY");
    if ($doc_info =~ /NDOCS="(\d+)"/) {
	$num_docs = $1;
    }
}
$num_docs = 100 unless defined($num_docs);
$topN = 5 unless defined($topN);
$* = 1;				# multi-line matching

# Determine the most similar documents for each document. This just
# uses the syn program provided w/ the lsi package.

for ($i = 1; $i <= $num_docs; $i++) {
    $result = "\t" . &run_command("syn -S -d $i -S -d a | sort +2 -rn | tail +2 | head -$topN\n");
    &debug_out(7, "r={\n$result}\n");
    $result =~ s/\n/\n\t/g;
    $result =~ s/\t$i /\t/g;
    print "doc$i: \n$result\n";
}
