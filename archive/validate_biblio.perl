# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# validate_refs.perl: validate the references in a latex source file
#
# TODO: make sure that all the references follow a specific format
#
#       LastName1, F[irstName1], F[irstName2] LastName2, ...,
#       and F[irstNamen], F[irstNamen] (19nn), Title, 
#       [Publisher: City | Journal, vol(num):x-y | Conference, pp. x-y].
#
# TODO: check web for bibliography validation tools
# 

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir);
    require 'common.perl';
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
use vars qw/$ignore_comments/;

&init_var(*ignore_comments, &TRUE);	# ignore text in latex comments

if (!defined($ARGV[0])) {
    my($options) = "options = [-ignore_comments]";
    my($example) = "ex: $script_name wordnet98.tex\n";

    print STDERR "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
    &exit();
}

my(%referenced);
my(%reference);

my($last_ref) = "        ";

while (<>) {
    &dump_line();
    chop;

    if ($ignore_comments) {
	s/^%.*//;
	s/([^\\])%.*/$1/;
    }

    my($text);
    for ($text = $_; $text =~ /\\cite\{([^\}]+)/; $text = $') {
	foreach my $citation (split(/,/, $1)) {
	    &incr_entry(\%referenced, &trim($citation));
	}
    }
    for ($text = $_; $text =~ /\\shortcite\{([^\}]+)\}/; $text = $') {
	&incr_entry(\%referenced, $1);
    }
    for ($text = $_; $text =~ /\\bibitem.*\{([^\}]+)\}/; $text = $') {
	my($ref) = $1;
	&incr_entry(\%reference, $ref);

	# Check for order of references (just considering first author)
	$ref =~ s/_.*//;	# '_' separates name in my cite keywords
	if ($ref lt $last_ref) {
	    &debug_out(2, "WARNING: bibliography item out of order: $_\n");
	}
	$last_ref = $ref;
    }
}

foreach my $reffed (sort(keys(%referenced))) {
    if (&get_entry(\%reference, $reffed) == 0) {
	printf "No reference defined for citation $reffed\n";
    }
}

foreach my $ref (sort(keys(%reference))) {
    if (&get_entry(\%referenced, $ref) == 0) {
	printf "No citation for reference $ref\n";
    }
}
