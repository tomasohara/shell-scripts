# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# sense2sgml.perl: convert from #N style sense indicators to SGML-style
# using <wf sense=N>
#
# sample input:
#
#    He used a noun:board#1 and milk crates as a table#2 .
#
# Sample output:
#
#    He used a <wf POS=noun sense=1>board</wf> and milk crates as a <wf sense=2>table</wf> .
#
# NOTE: This now handles generalized sense indicators, such as decimal 
# numbers with optional letter suffices, as well as symbolic sense indicators
# (e.g., to#Goal).
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

if ((defined($ARGV[0]) && ($ARGV[0] eq "help"))
    || (!defined($ARGV[0]) && &blocking_stdin())) {
    $options = "options = n/a";
    $example = "ex: $script_name whatever\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
}

while (<>) {
    &dump_line();
    chop;

    # convert from POS:word#N to <wf sense=N>word<wf>
    s/(\S+):(\S+)\#([a-z0-9\.\-\_]+)/<wf POS=$1 sense=$3>$2<\/wf>/g;

    # convert from word#N to <wf sense=N>word<wf>
    s/(\S+)\#([a-z0-9\.\-\_]+)/<wf sense=$2>$1<\/wf>/g;

    print "$_\n";
}
