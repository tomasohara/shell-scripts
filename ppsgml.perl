# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -s

#  Prettyprint an SGML source file by separating tag onto
#  different lines. This facilitates comparisons.

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

## printf STDERR "TRUE=$TRUE\n";
## printf STDERR "FALSE=$FALSE\n";
## printf STDERR "Common::TRUE=$Common::TRUE\n";
## printf STDERR "Common::FALSE=$Common::FALSE\n";

# process each line of the input stream
while (<>) {
    &dump_line();
    chop;
    $text = $_;

    # check for SGML starting or ending tag
    while ($text =~ /<\/?\w+[^>]*>/) {
        $previous = $`;		# `
	$match = $&;
	$rest = $';		# '
	&debug_print(6, "previous=$previous\nmatch=$match\n");
        $previous_len = length($previous);
	$fresh = &FALSE;
        if (($previous_len > 0) 
            && (substr($previous, $previous_len - 1, 1) ne "\n")) {
	    $fresh = &TRUE;
	}
	$match =~ s/\n/ /g;	# todo: use a join?
	print $previous;
	print "\n" if ($fresh == $TRUE);
	print $match, "\n"; 	# isolate the matching tag pair
	$text = $rest;		# resume test on rest of the line
    }

    # Include rest of line with newline, if nonempty
    if ($text ne "") {
	print "$text\n";
    }
}
