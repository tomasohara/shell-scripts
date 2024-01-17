# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# echo.perl: just echoes the arguments
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

printf "arguments: {\n";
for ($i = 0; $i <= $#ARGV; $i++) {
    print "$i: '$ARGV[$i]'\n";
}
printf "}\n\n";
