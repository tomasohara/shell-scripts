# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# make_senseval_report.perl: create report of the WSD taggings for the
# SENSEVAL submission
#
# This is just a simple wrapper around dist2senseval.perl that invokes it
# for all words on the command line.
#
# TODO: combine the two scripts into one???
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

if ((defined($ARGV[0]) && ($ARGV[0] eq "help"))
    || (!defined($ARGV[0]) && &blocking_stdin())) {
    $options = "options = [-mixture]";
    $example = "ex: $script_name bother\n";

    die "\nusage: $script_name [options] word1 ...\n\n$options\n\n$example\n\n";
}

&init_var(*mixture, &FALSE);

$results = ($mixture ? "SAMPLEALL.MIXTURE.DIST" : "SAMPLE.DIST");


foreach $word (@ARGV) {
    &cmd("perl -Ssw dist2senseval.perl -file_ID=$word $word/$results");
}

&exit();
