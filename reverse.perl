#!/usr/bin/perl -sw
# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# reverse.perl: reverses the lines in a file
#
#-------------------------------------------------------------------------------
# Note:
# - via perlvar(1) manpage:
#     Setting $/ to a reference to an integer, scalar containing an
#     integer, or scalar that's convertible to an integer will
#     attempt to read records instead of lines, with the maximum
#     record size being the referenced integer number of characters.
# - Use Unix tac utility (reverse cat) instead unless character mode required.
#-------------------------------------------------------------------------------
# TODO:
# - use @lines = <STDIN>; printf "%s\n", join("\n", rev(@lines));
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = $0; $dir =~ s/[^\\\/]*$//; unshift(@INC, $dir);
    require 'common.perl';
    use vars qw/$delim/;
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
use vars qw /$chars $path/;

# Show a usage statement if no arguments given.
# NOTE: By convention '-' is used when no arguments are required.
if (!defined($ARGV[0])) {
    my($options) = "options = [-chars | -path]";
    my($example) = "Examples:\n\n";
    $example .= "$script_name ~/organizer/todo_list.text | head\n\n";
    $example .= "echo abcdefghijklmnopqrstuvwxyz | $script_name -chars -\n\n";
    $example .= "echo \$PWD | $script_name -path -\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n";
}

my($record_delim) = "\n";
my($default_record_delim) = $/;

# If path being reversed set input record separator to path separator
if ($path) {
    $/ = $delim;
    $record_delim = $delim;
}

# If character input mode, set size of input buffer to 1 (n.b., via setting
# input record separator to refernce of integer 1).
if ($chars) {
    $/ = \1;
    $record_delim = "";
}


# Collect the inout record into a buffer. This is normally lines, but it
# can also be characters or path elements.
# TODO: @line => @buffer
#
my(@line) = ();
while (<>) {
    &dump_line();

    # Remove trailing newline or other record delimiter (unless character mode)
    if (! $chars) {
	chomp;
    }

    # HACK: Remove trailing path separator and ignore empty components, such
    # as when processing "//etc".
    if ($path) {
	$_ =~ s/$default_record_delim$//;
	if ($_ eq "") {
	    next;
	}
    }

    # Add current record to end of buffer
    $line[$#line + 1] = $_;
}
&trace_array(\@line, &TL_VERY_VERBOSE, "line");

# Print the buffer in reverse.
#
for (my $i = $#line; $i >= 0; $i--) {
    print($line[$i] . $record_delim);
}
if ($record_delim ne "\n") {
    print("\n");
}

