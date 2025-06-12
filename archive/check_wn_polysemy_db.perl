# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# check_wn_polysemy_db.perl: check's polysemy for word in WordNet using
# database created by create_wn_polysemy_db.perl
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir);
    require 'common.perl';
}

# Use module for automatic DB selection
use Fcntl;
use AnyDBM_File;

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
use vars qw/$WNSEARCHDIR/;
no strict "subs";

# Show a usage statement if no arguments given
# NOTE: By convention - is used when no arguments are required
if (!defined($ARGV[0])) {
    my($options) = "main options = []";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "examples:\n\n$script_name wn-adverb-polysemy.data happily\n\n";
    ## $example .= "$0 example2\n\n";		   	     # TODO: 2nd example
    my($note) = "";
    ## $note .= "notes:\n\nSome usage note.\n";		     # TODO: usage note

    print STDERR "\nusage: $script_name [options] datafile word ... \n\n$options\n\n$example\n$note";
    &exit();
}
my($database) = shift @ARGV;

# Check the command-line options
# note: Each variable initialized corresponds to a -var=value commandline option
## &init_var(*fu, &FALSE);		# TODO: add command-line options

# Open database for the polysemy information
my(%wn_polysemy);
tie %wn_polysemy, AnyDBM_File, $database, (O_RDONLY), 0755
    or &exit("Cannot open database file '$database' ($!)");

# Check polysemy of each word given on the command line

foreach my $word (@ARGV) {
    my($polysemy) = &get_entry(\%wn_polysemy, $word, 0);
    print "Polysemy of '$word' in WordNet is $polysemy\n";
}

&exit();
