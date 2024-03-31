# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# round.perl: rounds all numbers in the text (in place)
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

if ((defined($ARGV[0]) && ($ARGV[0] eq "help"))
    || (!defined($ARGV[0]) && &blocking_stdin())) {
    $options = "options = n/a";
    $example = "ex: $script_name whatever\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
}

while (<>) {
    &dump_line();
    chop;

    # do whatever
    $line = $_;
    $new_line = "";
    while ($line =~ /-?\d*(.\d+)?\d(e[+-]\d+)?\b/) {
	$num = $&;
	$line = $';
	$new_line .= $`;

	$num = sprintf "%.3f", $num;
	$new_line .= $num;
    }
    $new_line .= $line;

    print "$new_line\n";
}

&exit();


#------------------------------------------------------------------------------

sub fubar {
    local ($fubar) = @_;
    &debug_out(4, "fubar(@_)\n");

    return;
}

