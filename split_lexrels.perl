# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# split_lexrels.perl: script for spliting part-of-speech in lexrel's
# note: this is used in qd_analyze.sh
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

if (!defined($ARGV[0])) {
    $options = "options = n/a";
    $example = "ex: $script_name whatever\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
}

*OUT = *STDOUT;
while (<>) {
    &dump_line();
    chop;

    # Start a new output file if a new sense is encountered
    if (/^\s*\# ([^ ]+) : ([^ ]+) : (\d+)/) {
	$POS = $1; $word = $2; $sense = $3;
	$output_file = "${word}_${sense}.rels";
	$output_file = &iso_remove_diacritics($output_file);
	&debug_out(4, "splitting $word/$POS:$sense to $output_file\n");
	close(OUT);
	open(OUT, "> $output_file");
    }

    # Ignore comments
    if (/^\s*\#/) {
	next;
    }

    print OUT "$_\n";
}
close(OUT);
