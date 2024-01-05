# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# check_annots.sh: check annotations for possible typo's
#
# TODO: have more options for the attributes to ignore 
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

if (!defined($ARGV[1])) {
    $options = "options = [-ignore_cmt] [-ignore_fact] [-ignore_fcmt]";
    $example = "ex: $script_name w9_1mc.feb5 w9_1mc.feb\n";

    die "\nusage: $script_name [options] old_annotation_file new_annotation_file\n\n$options\n\n$example\n\n";
}

$old = shift @ARGV;
$new = shift @ARGV;

&init_var(*ignore_cmt, &FALSE);
&init_var(*ignore_fact, &TRUE);
&init_var(*ignore_fcmt, &TRUE);

$sed_options = "";
$sed_options .= " -e 's/ cmt=\"[^\"]*\"//g'" if ($ignore_cmt);
$sed_options .= " -e 's/ fact=\"[^\"]*\"//g'" if ($ignore_fact);
$sed_options .= " -e 's/ fcmt=\"[^\"]*\"//g'" if ($ignore_fcmt);

&cmd("sed $sed_options $new > temp_$new");
&cmd("sed $sed_options $old > temp_$old");
&cmd("diff --ignore-all-space temp_$old temp_$new");

&cmd("rm temp_$new temp_$old") unless (&DEBUG_LEVEL > 3);
