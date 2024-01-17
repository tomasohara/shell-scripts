# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# tally.perl: Tallies up the entries with the same key. The input must
# have two columns: one for the key and the other for the value.
#
# Sample input:
#
#    noun:lemon#1	0.750
#    noun:lemon#1	0.000
#    noun:lemon#1	0.000
#    noun:lemon#2	0.100
#    noun:lemon-feeble#1	 0.000
#    noun:lemon#2	0.100
#    noun:lemon#3	0.000
#    noun:lemon-drink#1	  0.000
#    noun:lemon#3	0.050
#
# Sample output:
#
#    noun:lemon#1	0.750
#    noun:lemon#2	0.200
#    noun:lemon#3	0.050
#    noun:lemon-feeble#1	 0.000
#    noun:lemon-drink#1	  0.000
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

if ((defined($ARGV[0]) && ($ARGV[0] eq "help"))
    || (!defined($ARGV[0]) && &blocking_stdin())) {
    $options = "options = n/a";
    $example = "ex: $script_name toddies.empirical\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
}

local(%tally);


# Scan each line for a key/value pair (tab delimited)
#
while (<>) {
    &dump_line();
    chop;

    # Skip spaces and comments
    next if (/^\s*$/ || /^\s*\#/);

    # Extract the key and value
    local($key, $value) = ($_ =~ /(.*)\t(\S+)/);
    if (!defined($value)) {
	&error_out("Unexpected input: $_\n");
	next;
    }

    # Add the value to the key's current tally
    &incr_entry(*tally, $key, $value);
}


# Display all the tally's sorted by key
#
foreach $key (sort(keys(%tally))) {
    printf "%s\t%g\n", $key, $tally{$key};
}
