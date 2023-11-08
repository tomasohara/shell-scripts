# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# matrix2lisp.perl: convert full matrix output from LSI into lisp format
# for lisp_stat
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

$make_square = &FALSE unless (defined($make_square));
$transpose = &FALSE unless (defined($transpose));

$_ = <>;
($docs, $terms) = split(/\s+/, $_);

# Read in all of the data in the matrix into a vector
#
$/ = 0777;			# set record separator to end-of-file
$text = <>;			# read entire file (lines of matrix data)
$text =~ s/^\s+//;		# drop leading space
$text =~ s/\s+$//;		# drop trailing space
@data = split(/\s+/, $text);	# convert data to an array
&debug_out(4, "docs=$docs terms=$terms |data|=%d\n", ($#data + 1));
&assert('($#data + 1) == ($docs * $terms)');


# If the user so desires, make the matrix square by making the number of
# documents (the rows) match the terms (the columns) and filling in the
# entries with 0's.
# NOTE: this is not needed: just transpose the matrix before doing su-decomp
#             % xlisp-stat
#             (setf m '#2a(...))
#             (setf m2 (transpose m))
#             (setf svd (sv-decomp m2))
#
if ($make_square) {
    &assert('$terms >= $docs');
    $docs = $terms;
    $new_num = ($docs * $terms);
    for ($i = ($#data + 1); $i < $new_num; $i++) {
	$data[$i] = "0.0000";
    }
    &debug_out(4, "docs=$docs terms=$terms |data|=%d\n", ($#data + 1));
}


# Print lisp-stat assignment statement
#
print "(setf m '#2a(\n";


# Print data row by row
#
$num = 0;
for ($i = 0; $i < $docs; $i++) {
    $row = " ";
    for ($j = 0; $j < $terms; $j++) {
	$value = $data[$num++];
	&assert('defined($value) && ($value =~ /\d/)');
	$row .= "$value ";
    }
    print "\t($row)\n";
}

# Terminate the statment
#
print "\t))\n";
