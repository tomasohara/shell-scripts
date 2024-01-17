# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -s
#
# l_vec.perl: program to compute l-vectors for use in parallel corpus
# alignment.
#
# An "l-vector" is just an index of all the lines in which the word occurs.
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

&init_var(*use_keys, &FALSE);
&init_var(*key_file, "key.list");

%key_pos = ();
$max_pos = 0;

# Set defaults and check for command-line overrides
#
$word_pattern = "([\\w-]+)(\\W)";
if (defined($span) && ($span)) {
    ## $word_pattern = "\\W([\\wαινσϊρό]+)\\W";
    $word_chars = "\\wαινσϊρό-";
    ## $word_pattern = "[^$word_chars]([$word_chars]+)[^$word_chars]";
    $word_pattern = "([$word_chars]+)([^$word_chars])";
}

&init();

# For each word in the text, compute the frequency and note the offsets
# at which it occurs.
#

$num = 0;
$in_line_num = 1;

&debug_out(3, "checking for words matching /$word_pattern/i\n");
while (<>) {
    &dump_line($_);
    chop;
    local($id) = $in_line_num;
    $text = $_;
    if ($use_keys && ($text =~ /^(\S+)\t/)) {
	$id = $1;	# use key from start of line (eg, "dan_2:2<TAB>")
	$text = $';
	$id = &resolve_key($id);
    }
    while ($text ne "") {
	if ($text =~ /$word_pattern/i) {
	    &debug_out(6, "\nignoring nonword chars: \'$`\' & \'$2\'\n");
	    $word = $1;
	    &debug_out(5, "$word; ");
	    $word =~ tr/A-Z/a-z/;

	    # Update the word's count, signature, and l_vector
	    # The signature is just the sum of all the line numbers
	    if (!defined($l_vector{$word})) {
		$l_vector{$word} = "";
		$count{$word} = 0;
		$signature{$word} = 0;
	    }
	    $count{$word} = $count{$word} + 1;
	    $l_vector{$word} .= "$id ";
	    $signature{$word} += $in_line_num;

	    $num = $num + 1;
	    $text = $';
	}
	else {
	    &debug_out(5, "\nignoring: \'$text\'");
	    $text = "";
	}
    }

    $in_line_num++;
}
&debug_out(3, "$num words found\n");


# Output the l-vectors
#

print "# word\tfreq\tsignature\tl-vector\n";

foreach $word (keys(%count)) {
    print "$word\t$count{$word}\t$signature{$word}\t$l_vector{$word}\n";
}

#------------------------------------------------------------------------------

sub init {

    # Read in the optional sorted list of keys. The position will be used
    # instead of the key itself.
    %key_pos = ();
    local($pos) = 1;
    if ($use_keys) {
	local($key_data) = &read_file($key_file);
	foreach $key (split(/\n/, $key_data)) {
	    $key_pos{$key} = $pos++;
	}
    }
    $max_pos = $pos;

    return;
}


sub resolve_key {
    local($key) = @_;

    if (!defined($key_pos{$key})) {
	$key_pos{$key} = $max_pos++;
    }
    
    return ($key_pos{$key});
}
