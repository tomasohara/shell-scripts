# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -s

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

if (! defined($ARGV[0])) {
    die "usage: rand.pe [-s=seed] [-c=count] [-m=max] -\n";
}

# Command-line parsing
$seed = (defined($s) ? $s : time);	# "-s=3.33"
$count = (defined($c) ? $c : 10);	# "-c=10"
$max = (defined($m) ? $m : 1000);	# "-m=1000"
&debug_out(4, "seed=$seed; count=$count; max=$max\n");

srand($seed);
for ($i = 0; $i < $count; $i++) { 
	$r = int(rand() * $max);
	print "$r ";
	} 
print "\n";
