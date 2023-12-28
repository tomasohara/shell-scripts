# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# rcsput.perl: wrapper around rcs ci that handles locking
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

&init_var(*msg, "");
&init_var(*desc, ".");

if ((defined($ARGV[0]) && ($ARGV[0] eq "help"))
    || (!defined($ARGV[0]) && &blocking_stdin())) {
    $options = "options = [-msg=\"whatever changes\"] [-desc=\"brief descirption of file\"]";
    $example = "ex: $script_name whatever\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
}

&cmd("rcs -l @ARGV");
&cmd("ci -u -m\"$msg\" -t-\"$desc\" @ARGV");
