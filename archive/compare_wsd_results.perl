# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# compare_results.perl: compare the results of two different WSD experiments
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

&init_var(*visual, &FALSE);

if (!defined($ARGV[1])) {
    $options = "options = [-visual]";
    $example = "ex: $script_name whatever\n";

    die "\nusage: $script_name [options] result1 result2\n\n$options\n\n$example\n\n";
}

$result1 = shift @ARGV;
$base1 = &remove_dir($result1);
$result2 = shift @ARGV;
$base2 = &remove_dir($result2);

&cmd("perl -Ssw cut.perl -f=1,2 -fix $result1 | sort > temp_$base1");
&cmd("perl -Ssw cut.perl -f=1,2 -fix $result2 | sort > temp_$base2");
if ($visual) {
    &cmd("tkdiff.tcl temp_$base1 temp_$base2");
}
else {
    ## local(($date1)) = ($base1 =~ /_(\d+.*)\./);
    ## local(($date2)) = ($base2 =~ /_(\d+.*)\./);
    local(($junk, $report1)) = ($base1 =~ /(eval_)?(.*)\./);
    local(($junk, $report2)) = ($base2 =~ /(eval_)?(.*)\./);
    &cmd("perl -Ssw paste.perl -keys -filter='\\d\\.\\d\\d\\d\\d' temp_$base1 temp_$base2 > temp_${report1}_${report2}.list");
    ## printf "%s", &read_file("temp_${report1}_${report2}.list");
    &cmd("perl -Ssw sum_file.perl -diff -labels temp_${report1}_${report2}.list > ${report1}_${report2}.diff");
    printf "%s", &read_file("${report1}_${report2}.diff");
}
