# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# archive_file.perl: move file into archive folder based on first letter 
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = $0; $dir =~ s/[^\\\/]*$//; unshift(@INC, $dir);
    require 'common.perl';
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
use vars qw/$base/;

# Show a usage statement if no arguments given
# NOTE: By convention - is used when no arguments are required
if (!defined($ARGV[0])) {
    my($options) = "main options = []";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "Examples:\n\n$script_name -base=/c/tom/misc/archive paypal-transfer-3dec05.mht\n\n";
    ## $example .= "$0 example2\n\n";		   	     # TODO: 2nd example
    my($note) = "";
    ## $note .= "Notes:\n\nSome usage note.\n";		     # TODO: usage note

    print STDERR "\nUsage: $script_name [options]\n\n$options\n\n$example\n$note";
    &exit();
}

# Check the command-line options
# note: Each variable initialized corresponds to a -var=value commandline option
&init_var(*base, ".");		# base directory for archive directory

my($file) = $ARGV[0];
$file =~ s/\.\///;		# drop relative path (e.g., "./hello.txt")
my($subdir) = &to_lower(substr($file, 0 , 1));
$subdir = "_" if ($subdir !~ /[a-z]/);
&issue_command("mv \"$file\" $base/$subdir", &TL_BASIC);
