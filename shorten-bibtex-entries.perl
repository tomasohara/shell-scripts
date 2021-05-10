# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# shorten-bibtex-entries.perl: script for shortening bibtex entries via
# short-author vs. full-author, etc. where the short version uses initials
#
# TODO:
# - account for hypenated names (eg, "Cheng-Ming Guo")
# - have topion to just use the first initial
# - account for accent marks (eg, "Fr\'ed\e'rique Segond")
# - account for names written last name first (e.g., "Hovy, Eduard")
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = $0; $dir =~ s/[^\\\/]*$//; unshift(@INC, $dir);
    require 'common.perl';
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
## use vars qw/$fu $bar/;

# Show a usage statement if no arguments given
# NOTE: By convention - is used when no arguments are required
if (!defined($ARGV[0])) {
    my($options) = "main options = []";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "Examples:\n\n$script_name example\n\n";  # TODO: example
    ## $example .= "$0 example2\n\n";		   	     # TODO: 2nd example
    my($note) = "";
    ## $note .= "Notes:\n\nSome usage note.\n";		     # TODO: usage note

    print STDERR "\nUsage: $script_name [options]\n\n$options\n\n$example\n$note";
    &exit();
}

# Check the command-line options
# note: Each variable initialized corresponds to a -var=value commandline option
## &init_var(*fu, &FALSE);		# TODO: add command-line options

# Use paragraph input mode
$/ = "";

while (<>) {
    &dump_line();
    chomp;
    my($record) = $_;

    # HACK: put a CR before each field for convenient matching
    &assert($record !~ /\r/);
    $record =~ s/\n\s*(\w+)\s*=/\r$&/g;

    # check for author or editor line
    while ($record =~ /\n(\s*)(author|editor)(\s*=\s*)([^\r]+)/) {
	my($indent) = $1;
	my($type) = $2;
	my($equals) = $3;
	my($entry) = $4;
	my($pre) = $`;
	my($post) = $';
	my($full_entry) = "${indent}full-$type$equals$entry";
	my($short_entry) = "${indent}short-$type$equals$entry";

	# Don't try to fix authors written with last name first
	if ($entry =~ /,\s*[A-Z]/) {
	    &warning("Lastname-first author entry not supported: $entry\n");
	    last;
	}
	if ($entry !~ /\s/) {
	    &warning("Ignoring author entry w/o spaces: $entry\n");
	    last;
	}
	

	# Remove full first names from the short entry
	# {Patrick Saint-Dizier and Evelyne Viegas}
	# => {P. Saint-Dizier and E. Viegas}
	#
	# ex: 'and Raymond J. Mooney' => 'and R. J. Mooney'
	$short_entry =~ s/and(\s+[A-Z])\w+/and$1\./g;
	# ex: 'M. Teresa Pazienza' => 'M. T. Pazienza'
	$short_entry =~ s/(\s+[A-Z]\.\s+)([A-Z])\w+(\s+[A-Z]\w+)/$1$2\.$3/g;
	# ex: '{Erza Black}' => '{E. Black}'
	$short_entry =~ s/(=\s*[\"\{]\s*)([A-Z])\w+/$1$2\./;
	&debug_print(&TL_DETAILED, "short entry for '$type$equals$entry'\n\t'$short_entry'\n");

	# Revise the record with short-author and full-author fields
	$record = "$pre\n${short_entry}\n${full_entry}$post";
    }

    # Remove CR delim and print the revised entry
    $record =~ s/\r//g;
    print "$record\n\n";
}

&exit();


#------------------------------------------------------------------------------

# TODO: subroutine101(some_arg): What subroutine101 does
#
sub subroutine101 {
    ## my($arg) = @_;
    &debug_print(&TL_VERBOSE, "subroutine101(@_)\n");

    return;
}
