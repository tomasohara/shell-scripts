# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# intersection.perl: show the word overlap (or difference) of two files
# TODO: add options for non-overlap since difference is directional
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
use vars qw/$diff $do_diff $line $single_line $i $trim/;

&init_var(*diff, &FALSE);	# use set difference instead of intersection
&init_var(*do_diff, $diff);	# alias for -diff
&init_var(*line, &FALSE);	# do line-level intersection (not word)
&init_var(*single_line, &FALSE); # use single-line for output
&init_var(*i, &FALSE); 		# ignore case differences
&init_var(*trim, &FALSE);	# trim whitespace from lines
our($ignore_case) = $i;

# Do some sanity checks
if (&DEBUG_LEVEL >= &TL_VERBOSE) {
    my(@l1) = ("a", "b", "c");
    my(@l2) = ("b");
    ## BAD:
    ## &debug_out(4, "diff(l1, l2) = %s\n", &difference(\@l1, \@l2));
    ## &debug_out(4, "int(l1, l2) = %s\n", &intersection(\@l1, \@l2));
    my(@diff) = &difference(\@l1, \@l2);
    my(@inter) = &intersection(\@l1, \@l2);
    &debug_print(4, "diff(l1, l2) = @diff\n");
    &debug_print(4, "inter(l1, l2) = @inter\n");
    &assertion((scalar @diff) > (scalar @inter));
}

# Determine which set function to use
my($set_operation_fn) = ($do_diff ? \&difference : \&intersection);

# Check the command-line for the names of the two files
#
if (!defined($ARGV[1])) {
    die "usage: $0 [-diff] [-line] file1 file2\n";
}
my($file1) = shift @ARGV;
my($file2) = shift @ARGV;


# Read in the files, and determine their intersecton (difference)
#
my(@file1) = ($line ? &get_file_lines($file1) : &get_file_words($file1));
&trace_array(\@file1);
my(@file2) = ($line ? &get_file_lines($file2) : &get_file_words($file2));
&trace_array(\@file2);
my(@file3) = &$set_operation_fn(\@file1, \@file2);

# Display the results of the intersection
#
my($delim) = $single_line ? " " : "\n";
&debug_print(&TL_VERBOSE, "*set_operation($file1, $file2):\n");
printf "%s\n", join($delim, @file3);


#------------------------------------------------------------------------------

# get_file_words(file-name): returns list of word tokens from the file
# note: this converts the tokens to lowercase
#
sub get_file_words {
    my($file) = @_;
    my($text) = &read_file($file);

    if ($ignore_case) {
	$text = &to_lower($text);
    }

    return (&tokenize($text));
}

# get_file_lines(file-name): returns list of lines from the file
# NOTE: Lines optionally converted to lowercase and/or whitespace trimmed.
#
sub get_file_lines {
    my($file) = @_;
    my($text) = &read_file($file);

    if ($ignore_case) {
	$text = &to_lower($text);
    }
    my @lines = split(/\n/, $text);
    if ($trim) {
	@lines = map { &trim($_); } @lines;
    }

    return (@lines);
}
