# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw

## require 'stat.pl';
## require 'my_stat.pl';
require 'my_stat.perl';
# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

print ("ST_DEV=$ST_DEV\n");
@file_stat = Stat('test_stat.perl');
printf "%s\n", join(" ", @file_stat);
