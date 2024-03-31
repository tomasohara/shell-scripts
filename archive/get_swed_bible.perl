# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#! /usr/local/bin/perl -sw
#
# Downloads each book of the Swedish hypertext bible, where each chapter is at
# a different locaton.
#
# lynx -dump gopher://gopher.lysator.liu.se:70/11/project-runeberg/txt/bibeln/66/01 >> revelations.text
#
# NOTE: *** this script is broken: lynx doesn't seem to handle gopher addresses
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

$base_location = "gopher://gopher.lysator.liu.se:70/11/project-runeberg/txt/bibeln/";
$chapter_file = "chapter.list" unless defined($chapter_file);
$start = 1 unless defined($start);
$end = 66 unless defined($end);

# TODO: fill in the number of chapters per book
$num_sections{"66"} = 22;

# Enumerate through the chapters
#
for ($chapter = $start; $chapter <= $end; $chapter++) {
    &issue_command("echo > sw_$chapter.text");
    $num = defined($num_sections{$chapter}) ? $num_sections{$chapter} : 0;
    for ($section = 1; $section < $num; $section++) {
	$location = "$base_location/$chapter/$section";
	&issue_command("lynx -dump $location >> sw_$chapter.text");
    }
}

