# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/bin/perl -sw
#
# hexview.perl: displays hexadecimal dump for a file
#    Usage: hexview [file]
# Originally based on xdump (p. 273, Programming Perl); see samples/xdump.perl.
#-------------------------------------------------------------------------------
# Examples:
#
# - input:
#
#     Because I could not stop for Death,
#     He kindly stopped for me;
#     The carriage held but just ourselves
#     And Immortality.
#
# - normal output:
#
#     00000000  42 65 63 61 75 73 65 20 - 49 20 63 6F 75 6C 64 20  Because I could 
#     00000010  6E 6F 74 20 73 74 6F 70 - 20 66 6F 72 20 44 65 61  not stop for Dea
#     00000020  74 68 2C 0A 48 65 20 6B - 69 6E 64 6C 79 20 73 74  th,.He kindly st
#     00000030  6F 70 70 65 64 20 66 6F - 72 20 6D 65 3B 0A 54 68  opped for me;.Th
#     00000040  65 20 63 61 72 72 69 61 - 67 65 20 68 65 6C 64 20  e carriage held 
#     00000050  62 75 74 20 6A 75 73 74 - 20 6F 75 72 73 65 6C 76  but just ourselv
#     00000060  65 73 0A 41 6E 64 20 49 - 6D 6D 6F 72 74 61 6C 69  es.And Immortali
#     00000070  74 79 2E 0A             -                          ty..
#
# - output with forced-newline breaks:
#
#     TODO
#
#-------------------------------------------------------------------------------
# TODO:
# - Reconstruct xdump format using Unix hexdump utility (e.g., od -x ...)
# - Complete conversion from old-style Perl to that used in template.perl.
# - Cut down on redundant code added for forced-newline processing.
# - Isolate the newline processing as a separate script to make the logic
#   easier to follow.
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = $0; $dir =~ s/[^\\\/]*$//; unshift(@INC, $dir);
    require 'common.perl';
    use vars qw/$help/;
}
## use English;				# for $PREMATCH, etc.

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
use vars qw/$width $lines $newline $newlines $help/;
use vars qw/$no_ascii $no_offset $no_hex/;

$width = 16 unless defined($width); 		# number of hexed characters per line
my $half_width = $width / 2;			# width of column
$lines = &FALSE unless (defined($lines));	# alias for -newlines
$newline = &FALSE unless (defined($newline));	# another alias for -newlines
$newlines = ($lines || $newline) unless (defined($newlines));	# end hex section at newlines not just every N chars
&init_var(*no_ascii, &FALSE);                   # omit ascii section (righthand side)
&init_var(*no_offset, &FALSE);                  # omit offset section (lefthand side)
&init_var(*no_hex, &FALSE);                     # omit hex section (middle)
my($show_ascii) = (! $no_ascii);
my($show_offset) = (! $no_offset);
my($show_hex) = (! $no_hex);

my($show_help) = $help;

# Show a usage statement if no arguments given.
# TODO: By convention '-' is used when no arguments are required.
## OLD: printf STDERR "ARGV=(@ARGV)\n";
#
if ($show_help) {
    # Construct usage options spec, notes, examples and notes
    my($options) = "main options = [-newline[s] | -line] [-width=N]";
    $options .= " [-no_ascii] [-no_offset] [-no_hex]";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($note) = "notes:\n";
    $note .= "- Use -newlines to force line breaks at newlines\n";
    $note .= "- Use -width to change the number of bytes shown per line (16 by default)\n\n";
    my($example) = "Example(s):\n\n$script_name /bin/ls | less\n\n";
    $example .= "$script_name -newlines $0 | head -3\n\n";

    # Print the usage (n.b., examples and notes should end in double newlines)
    &assertion(($example =~ /\n\n$/) && ($note =~ /\n\n$/));
    print STDERR "\nUsage: $script_name [options]\n\n$options\n\n$example\n$note";
    &exit();
}

# ptrace([label]): trace label if debugging level detailed (4) or higher.
# Note: This is used for debugging to label the source of printing.
# For example, consider the following sequence:
#    &ptrace("1"); print("abc"); &ptrace("2"); print("def");
# If not detailed debugging, the output is "abcdef"; otherwise, it is "1abc2def".
#
sub ptrace {
    my($label) = @_;
    &debug_print(&TL_DETAILED, $label);
}

# Open input file if specified, reporting any errors when doing so.
open(STDIN, $ARGV[0]) || die "Can't open $ARGV[0]: $!\n"
	if $ARGV[0];

# Make sure that \r\n isn't translated to \n
binmode(STDIN);

# Loop suboptimally through whole file in small chunks
# Notes:
# - This is roughly half as fast as old xdump utility (TODO: from what Unix distribution).
# - The line is stored in $data, and the hex representation in @array.
# TODO: Rename $data to $line_chunk and @array to @chunk_hex.
#
my($len) = 0;
my($offset) = 0;
my($data) = "";
## OLD: my($missing_hex) = "   ";
my($missing_hex) = "  ";
my($middle_div) = "- ";
my($empty_div) = "  ";
#
while (($len = read(STDIN, $data, $width)) > 0) {
    &assertion($len == length($data));

    # Convert data to hex representation
    my(@array) = unpack('C*', $data);

    # Change data non-printable characters to '.' (e.g., control characters and extended ascii).
    $data =~ tr/\0-\37\177-\377/./;
    for (@array) {
	$_ = sprintf('%2.2X', $_);
    }

    # Pad hex with blank placeholders (to fill width)
    push(@array, $missing_hex) while $len++ < $width;
    &assertion(($#array + 1) == $width);

    # Change non-printable characters to '.' (TODO: see why needed, given tr tranformation above)
    $data =~ s/[^ -~]/./g;
    my($line_start) = 0;

    # Output the next width-sized chuck first in hex and then in ascii
    # ex: '00000000  23 20 2A 2D 2A 2D 70 65 - 72 6C 2D 2A 2D 2A 0A    # *-*-perl-*-*.'
    # Notes:
    # - The width is normally 16 bytes, shown in two sections of 8 two-digit hex numbers.
    # - If newlines should force output line-breaks, mutliple loop iterations can occur.
  data_loop:
    for (my $i = 0; (($i < $width) && ($i < length($data))); $i++) {
	# Print the offset as an 8-digit hex number.
	# TODO: Check input size and adapt max width accordingly (also have option for size).
	if ($show_offset) {
	    printf("%8.8lX  ", $offset + $i);
	}
	my($extra_first_half) = min($i, $half_width);
	my($extra_second_half) = max(0, (min($i, $width) - $half_width));
	my($extra_both_halves) = ($extra_first_half + $extra_second_half);

	# Print hexadecimal as two sets of hex pairs separate by a dash
	if ($show_hex) {
    	    
	    # Print indentation to account for non-zero offset due to forced-newline
	    if ($newlines) {
		for (my $j = 0; $j < $extra_first_half; $j++) {
		    &ptrace("1");
		    print("$missing_hex ");
		}
	    }
	    
	    # Print the first half of the hexadecimal representation.
	    my($half_start) = 0;
	    for ($half_start = $i; $i < $half_width; $i++) {
		&ptrace("2");
		print("$array[$i] ");
		
		# Special case processing for newlines
		if ($newlines && ($array[$i] eq "0A")) {
		    
		    # Print spaces for remainder of hex representation
		    for (my $j = 0; $j < ($half_width - $i - 1); $j++) {
			&ptrace("3");
			print("$missing_hex ");
		    }

		    # Middle empty divided (because some blank hex bytes in first half)
		    &ptrace("4");
		    print($empty_div);

		    # Print empty second half of hex representation
		    for (my $j = 0; $j < $half_width; $j++) {
			&ptrace("5");
			print("$missing_hex ");
		    }

		    # Print ascii representation
		    &ptrace("6");
		    print(" ");
		    if ($extra_first_half) {
			&ptrace("7");
			print(" " x $extra_first_half);
		    }
		    &ptrace("8");
		    my($num_chars) = ($i - $half_start + 1);
		    print(substr($data, $line_start, $num_chars), "\n");
		    $line_start += $num_chars;
		    next data_loop;
		}
	    }

	    # Print the dash between the hexadecimal halves (unless forced newline processed).
	    &ptrace("9");
	    print($middle_div);

	    # Print indentation to account for non-zero offset due to forced-newline
	    if ($newlines) {
		for (my $j = 0; $j < $extra_second_half; $j++) {
		    &ptrace("0");
		    print("$missing_hex ");
		}
	    }
	    
	    # Print the second half of the hexadecimal representation.
	    for ($half_start = $i; $i < $width; $i++) {
		&ptrace("!");
		print("$array[$i] ");

		# Special case processing for newlines
		if ($newlines && ($array[$i] eq "0A")) {

		    # Print spaces for remainder of hex representation
		    for (my $j = 0; $j < ($width - $i - 1); $j++) {
			&ptrace("@");
			print("$missing_hex ");
		    }

		    # Print ascii representation
		    &ptrace("#");
		    print(" ");
		    if ($extra_both_halves > 0) {
			&ptrace("\$");
			print(" " x $extra_both_halves);
		    }
		    &ptrace("%");
		    my($num_chars) = $half_width - $extra_first_half + ($i - $half_start) + 1;
		    print(substr($data, $line_start, $num_chars), "\n");
		    $line_start += $num_chars;
		    next data_loop;
		}
	    }

	}
	
	
	# Print the line contents proper.
	# Note: . used for non-printing characters (see tr above).
	if ($show_ascii) {
	    &ptrace("^");
	    print(" ");
	    &ptrace("&");
	    print(" " x $extra_both_halves);
	    &ptrace("*");
	    print(substr($data, $line_start), "\n");
	}
	else {
	    print("\n");
	}
    }
  end_data_loop:

    $offset += $width;
}
