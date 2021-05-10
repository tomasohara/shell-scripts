# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# decode-utf8.perl: decodes UTF-8, especially when represented in a URL
#
# ex: 
# http://ar.wikipedia.org/wiki/%D8%A3%D8%B3%D8%A7%D9%85%D8%A9_%D8%A8%D9%86_%D9%84%D8%A7%D8%AF%D9%86
# =>
# 

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = $0; $dir =~ s/[^\\\/]*$//; unshift(@INC, $dir);
    use vars qw/%utf8/;
    $utf8 = 1;
    require 'common.perl';
    ## TODO: use vars qw/$verbose/;
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
use vars qw/$url/;

use English;		# for $PREMATCH, etc.
use Encode qw/decode_utf8/;

# Show a usage statement if no arguments given.
# NOTE: By convention '-' is used when no arguments are required.
if (!defined($ARGV[0])) {
    my($options) = "main options = [-url]";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "Example(s):\n\necho 'http:\\www.my%30space.com' | $script_name -url -\n\n";
    $example .= "echo 'EF BF BD' | $0\n\n";
    my($note) = "";
    ## $note .= "Notes:\n\nSome usage note.\n\n";	     # TODO: usage note

    print STDERR "\nUsage: $script_name [options]\n\n$options\n\n$example\n$note";
    &exit();
}

# Check the command-line options
# note: Each variable initialized corresponds to a -var=value commandline option
&init_var(*url, &FALSE);		# do URL decoding

while (<>) {
    &dump_line();
    chomp;

    # Decode UTL hex escapes
    # TODO: use HTML utility for this
    if ($url) {
	while (/\%([0-9a-f][0-9a-f])/i) {
	    $_ = $PREMATCH . chr(hex($1)) . $POSTMATCH;
	}
    }
    else {
	my $line = "";
	foreach my $char (&tokenize($_)) {
	    $line .= chr(hex($char));
	}
	$_ = decode_utf8($line);
    }

    # print the result
    print "$_\n";
}

&exit();
