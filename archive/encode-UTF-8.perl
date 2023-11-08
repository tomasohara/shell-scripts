# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# encode-UTF-8.perl: encodes a unicode character in UTF-8 (via Encoder.pm)
#
# Character Range	Bit Encoding
# U+0000 - U+007F	0xxxxxxx
# U+0080 - U+07FF	110xxxxx 10xxxxxx
# U+0800 - U+FFFF	1110xxxx 10xxxxxx 10xxxxxx
# U+10000 - U+10FFFF	11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
#
# TODO:
# - Re-implement via Encode::Encoder.
# - Alternatively, reimplement in term of pack/unpack:
#      $ perl -C -e 'print join(" ", unpack("H*", pack("U", 0x100))), "\n"';
#      c480
#      $ encode-UTF-8.perl U+100
#      U+100 (256): C4 80
# - Extend to support UTF-16 as well.
# - Add option for decoding UTF-8 values.
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

## TODO: use Encoder qw(encoder);

# Show a usage statement if no arguments given
# NOTE: By convention - is used when no arguments are required
if (!defined($ARGV[0])) {
    my($options) = "main options = []";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "Examples:\n\n$script_name U+0590\n\n";
    ## $example .= "$0 example2\n\n";		   	     # TODO: 2nd example
    my($note) = "";
    ## $note .= "Notes:\n\nSome usage note.\n";		     # TODO: usage note

    print STDERR "\nUsage: $script_name [options]\n\n$options\n\n$example\n$note";
    &exit();
}
if ($ARGV[0] eq "-") {
    @ARGV = &tokenize(&read_entire_input());
}

# Check the command-line options
# note: Each variable initialized corresponds to a -var=value commandline option
## &init_var(*fu, &FALSE);		# TODO: add command-line options

foreach my $char_spec (@ARGV) {
    my($code_point) = unicode_value($char_spec);
    ## TODO: my($utf8) = encoder($code_point)->utf8->latin1;
    my($utf8) = rtf8_encoding($code_point);
    printf "%s (%d): %s\n", $char_spec, $code_point, $utf8;
}

&exit();


#------------------------------------------------------------------------------

# unicode_value(string): converts Unicode code point string into decimal
#
sub unicode_value {
    my($code_point) = @_;
    my($value) = 0;
    &debug_print(&TL_VERBOSE, "unicode_value(@_)\n");

    # Normalize the unicode character string representation
    $code_point = &trim($code_point);
    $code_point =~ s/^U[+-]//;

    # Convert from hex string into integer
    # TODO: use a built-in perl function for this
    while ($code_point =~ /^([0-9a-f])/i) {
	$code_point = $';		# '
	my($hex) = &to_upper($1);

	$value *= 16;
	$value += index("0123456789ABCDEF", $hex);
    }

    # Do some sanity checks
    if ($code_point ne "") {
	&error("Invalid code point specification: $code_point\n");
    }

    return ($value);
}

# rtf8_encoding(code_point): Encodes unicode code point using UTF-8 (hex string returned).
#
sub rtf8_encoding {
    my($code_point) = @_;
    my($encoding) = "????";

    if (($code_point > 0x10FFFF) && ($code_point < 0)) {
	&error("Invalid unicode code point: $code_point\n");
    }
    elsif ($code_point > 0x0FFFF) {
	# U+10000 - U+10FFFF	11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
	my($octet1) = ($code_point >> 18) | 0xF0;
	my($octet2) = (($code_point >> 12) & 0x3F) | 0x80;
	my($octet3) = (($code_point >> 6) & 0x3F) | 0x80;
	my($octet4) = ($code_point & 0x3F) | 0x80;
	$encoding = sprintf "%02X %02X %02X %02X", $octet1, $octet2, $octet3, $octet4;
    }
    elsif ($code_point > 0x07FF) {
	# U+0800 - U+FFFF	1110xxxx 10xxxxxx 10xxxxxx
	my($octet1) = ($code_point >> 12) | 0xE0;
	my($octet2) = (($code_point >> 6) & 0x3F) | 0x80;
	my($octet2_alt) = (($code_point >> 6) | 0x80) & 0xBF;
	&assert($octet2 == $octet2_alt);
	my($octet3) = ($code_point & 0x3F) | 0x80;
	$encoding = sprintf "%02X %02X %02X", $octet1, $octet2, $octet3;
    }
    elsif ($code_point > 0x007F) {
	# U+0080 - U+07FF	110xxxxx 10xxxxxx
	my($octet1) = ($code_point >> 6) | 0xC0;
	my($octet2) = ($code_point & 0x3F) | 0x80;
	$encoding = sprintf "%02X %02X", $octet1, $octet2;
    }
    else {
	# U+0000 - U+007F	0xxxxxxx
	$encoding = sprintf "%02X", $code_point;
    }

    return ($encoding);
}
