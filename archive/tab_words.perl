# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -s
#
# tab_words.perl: tabulate word occurrences in a text; includes support for Spanish
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

$word_pattern = "\\W(\\w+)\\W";
if (defined($span)) {
    $word_pattern = "\\W([\\wαινσϊρό]+)\\W";
}

&issue_command("perl -Ss count_it.pe -i \"${word_pattern}\" @ARGV | gsort -rn");
