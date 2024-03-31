# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# para_split.perl: split a file into two (by paragraphs)
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

if (!defined($ARGV[3])) {
    $options = "options = n/a";
    $example = "ex: $script_name whatever\n";

    die "\nusage: $script_name [options] percent file out1 out2 \n\n$options\n\n$example\n\n";
}
$file = $ARGV[0];
$percent = $ARGV[1];
$out1 = $ARGV[2];
$out2 = $ARGV[3];

open(FILE, "<$file") || die "ERROR: can't open $file\n";
open(OUT1, ">$out1") || die "ERROR: can't create $out1\n";
open(OUT2, ">$out2") || die "ERROR: can't create $out2\n";

$/ = "";		# paragraph input mode
@para = <FILE>;		# read in file all at once
&trace_array(*para);
$num_paras = (1 + $#para);
$end1 = ($percent * $num_paras);

for ($i = 0; $i < $end1; $i++) {
    printf OUT1 "%s", $para[$i];
}
for (; $i < $num_paras; $i++) {
    printf OUT2 "%s", $para[$i];
}

&exit();
