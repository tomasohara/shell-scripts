# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl

# Display dictionary data files from Languuages of the World

$/ = 0xDC;			# entry separator

binmode STDIN;
$num = 0;
while (<>) {
    $num++;
    ## substitute ISO characters for the accents
    ## s/\x//;

    print "$num\t$_";
    print "\n\n";
}
