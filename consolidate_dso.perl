# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#! /usr/local/bin/perl -sw
#
# consolidate_all.perl: consolidate all the DSO annotations for particular 
# files
#
# input: (result of  count_it.perl "^(.*db \#\d+) " *.[vn] | sort -rn)
#
#	171543 patterns found
#	30	ch09.db #005
#	14	ch09.db #002
#	13	dj11.db #771
#	13	ch08.db #044
#	12	cj49.db #008
#	12	cc06.db #011
#	11	dj24.db #212
#	11	dj01.db #230
#	11	cp09.db #023
#	11	cj53.db #028
#	11	cj47.db #029
#	11	cj30.db #031
#	11	ch28.db #099
#	11	ch12.db #007
#	11	ch04.db #013
#	11	cg33.db #036
#	11	cb26.db #054
#	11	ca44.db #060
#	10	dj42.db #1378
#	10	cl03.db #038
#	

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

&init_var(*max_num, 100);

$num = 0;
while (<>) {
    if (/patterns found/) {
	next;
    }
    if ($num++ == $max_num) {
	last;
    }

    # Determine the next sentence to consolidate
    ($count, $database, $sent_num) = split;
    $file = "${database}${sent_num}.data";
    $file =~ s/\.db/_/;
    $file =~ s/\#//;

    $command = "grep '$database $sent_num ' *.[vn] | dso2sgml.perl > $file";
    &issue_command($command, &TL_DETAILED);
}
