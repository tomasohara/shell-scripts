# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# pp_websters.perl: pretty-print entry from Webster's New World Dictionary
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

$SPACES = "                                        ";
$extra_spaces = "";
$line_len = 0;
$MAX_LINE = 78;
$num_subsenses = 0;
$new_entry = &TRUE;
while (<>) {
    &debug_out(7, "\n> line_len=$line_len len=%d <\n", length($_) - 1);
    &dump_line();
    chop;

    $sep = "\n";
    if (/^      +/) {
	$sep = " ";
    }
    elsif (/^ +([0-9]+\.)/) {	# sense indicator# 
	$extra_spaces = substr($SPACES, 0, 1 + length($1));
	$num_subsenses = 0;
    }
    elsif (/^$/) {
    	$extra_spaces = "";
    	$num_subsenses = 0;
    }
    elsif (/(n|vi|vt|adj|adv|conj|prep|alt|abbrev)\./) { # new entry or run-on
    	$extra_spaces = "";
    	$num_subsenses = 0;
    }
    elsif (/^--/) {		# grep separator
	print "\n";
	$line_len = length($extra_spaces);
	next;
    }
    elsif ($new_entry == &FALSE) {
	$sep = " "
	}

    # Revise new entry indicator
    if (/^$/) {
	$new_entry = &TRUE;
    }
    else {
	$new_entry = &FALSE;
    }
    s/^ +//;			# drop leading space

    # Revise the line length
    if ($sep =~ /\n/) {		# reset line length if newline is separator
	$line_len = length($extra_spaces);
    }
    $line_len += length($_);	# add in the current text length


    # Separate subsenses onto separate lines
    # TODO: stop futzing with $_ and print on the fly
    while (/(^| )([a-z])\)( ?.*)/) {
	$pre = $`; $subsense = $3; $letter = $2;
	if ($pre =~ /\([^\)]+$/) {
	    last;
	}

	# Keep the first subsense on the same line
	# TODO: skip over cases like "Atlas Mountains ... (4,150 m)"
	if ($num_subsenses == 0) {
	    &assert('($letter eq "a")');
	    $spacing = $extra_spaces;
	    $extra_spaces .= "   ";
	    ## $pre =~ s/ $//;	# drop first subsense's extra leading space
	}
	$num_subsenses++;

	# Print the preceding text, allowing for word-wrap
	$new_line_len = (1 + length($subsense) + length($spacing));
	&debug_out(5, "\nsubsense split: '$pre' and '$subsense'; len=%d newlen=%d\n",
		   $line_len, $new_line_len);

	$line_len -= $new_line_len;
	$_ = "$pre";
	&do_word_wrap() if ($line_len > $MAX_LINE);
	print "$sep$_";
	print "\n$spacing" unless ($num_subsenses == 1);
	print "$letter)";

	# Revise the line to just have the text starting with the subsense
	$sep = "";
	$_ = "$subsense";
        $line_len = $new_line_len;
    }

    # Put example text on a separate line
    if (/(\[[^\.\[\]]+((\].*)|$))/) {
	$pre = $`; $post = $1;
	&debug_out(5, "\nexample split: '$pre' and '$post'; len=%d newlen=%d\n",
		   $line_len, length($post));
	$line_len -= length($post);
	## s/\[/\n$extra_spaces\[/;
	$_ = "$pre";
	&do_word_wrap() if ($line_len > $MAX_LINE);
	print "$sep$_\n";
	$sep = "";
	$_ = "$extra_spaces$post";
        $line_len = length($post) + length($extra_spaces);
    }

    # Print the current text with an optional separator
    # Wrap words if necessary
    &do_word_wrap() if ($line_len > $MAX_LINE);
    print "$sep$_";
}
print "\n";


sub do_word_wrap {
    &debug_out(7, "do_word_wrap(); \$_ = '$_'\n");
    $start = length($_) - ($line_len - $MAX_LINE) - 1;
    &debug_out(6, "splitting line: len=$line_len start=$start\n");
    for ($j = $start; $j >= 0; $j--) {
	if (substr($_, $j, 1) eq " ") {
	    substr($_, $j, 1) = "\n$extra_spaces";
	    $line_len = length($_) - $j - 1;
	    &debug_out(5, "split at pos $j: '%s' and '%s'; newlen=%d\n",
		       substr($_, 0, $j), substr($_, $j + 1), $line_len);
	    last;
	}
    }
    if ($j < 0) {
	$_ = "\n$extra_spaces$_";
	$line_len = length($extra_spaces) + length($_);
    }
    &assert('$line_len <= $MAX_LINE');
}
