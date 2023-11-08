# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# browse-db-file.perl: browse DB_File content (e.g., the KBAE database).
# Based on code from Perl Cookbook (Section 14.1 Making and Using a DBM File):
#   http://www.unix.org.ua/orelly/perl/cookbook/ch14_02.htm
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir);
    require 'common.perl';
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
use vars qw/$db/;

# Show a usage statement if no arguments given
# NOTE: By convention - is used when no arguments are required
if (!defined($ARGV[0])) {
    my($options) = "main options = []";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "examples:\n\n$script_name -db=ontology DOG\n\n";
    $example .= "$0 ALL\n\n";
    my($note) = "";
    ## $note .= "notes:\n\nSome usage note.\n";		     # TODO: usage note

    print STDERR "\nusage: $script_name [options] key\n\n$options\n\n$example\n$note";
    &exit();
}

# Check the command-line options
# note: Each variable initialized corresponds to a -var=value commandline option
&init_var(*db, "");			# file for DB to browse
my(%db);

use DB_File;

tie(%db, 'DB_File', $db, (O_RDONLY))
    or die "Can't open DB_File $db : $!\n";

if ($ARGV[0] eq "-") {
    @ARGV = sort keys %db;
}

foreach my $key (@ARGV) {
    my($info) = $db{$key};
    $info = "???" if (! defined($info));
    print "$key\t$info\n";
}

&exit();

