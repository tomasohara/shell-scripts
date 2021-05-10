# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# is-binary-file.perl: tests file to see if likely a binary file versus ascii
#
# Based on http://lists.gnu.org/archive/html/info-cvs/2000-10/msg00672.html
#

if (!defined($ARGV[0])) {
    my($note) = "Use -q to just set status code if binary\n";
    print STDERR "\nusage: $0 [-quiet] file\n";
    exit(-1);
}
$quiet = 0 unless (defined($quiet));

# Use perl's built-in binary file test to determine if binary
my($is_binary) = (-f $ARGV[0] && -B $ARGV[0]);
if (! $quiet) {
    printf "%s\n", ($is_binary ? "yes" : "no");
}

# Set the status code
exit($is_binary);
