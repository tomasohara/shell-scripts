# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -s
#
# k_vec.perl: program to compute k-vectors for use in parallel corpus
# alignment.
#
# This is based on the COLING-94 article by Pascale Fung and Ken Church
# "K-vec: A New Approach for aligning Parallel Texts"
#
# available via the cmp-lng archive
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';


# Set defaults and check for command-line overrides
#
## $word_pattern = "(\\w+)\\W";
## $word_chars = "A-Za-z0-9";
## $word_pattern = "([$word_chars]+)[^$word_chars]";
$word_pattern = "(\\w+)(\\W)";
if (defined($span) && ($span)) {
    ## $word_pattern = "\\W([\\wαινσϊρό]+)\\W";
    $word_chars = "\\wαινσϊρό";
    ## $word_pattern = "[^$word_chars]([$word_chars]+)[^$word_chars]";
    $word_pattern = "([$word_chars]+)([^$word_chars])";
}

$k = 100 unless defined($k);		# use sqrt(N)?
$use_fixed_slots = &TRUE unless defined($use_fixed_slots);
@sentence_slots = ();

# For each word in the text, compute the frequency and note the offsets
# at which it occurs.
#

$num = 0;
$offset = 0;
$ignored = 0;
$file_len = 0;
$in_line_num = 0;

&debug_out(3, "checking for words matching /$word_pattern/i\n");
while (<>) {
    &dump_line($_);
    $file_len += length($_);
    $text = $_;
    while ($text ne "") {
	if ($text =~ /$word_pattern/i) {
	    &debug_out(6, "\nignoring nonword chars: \'$`\' & \'$2\'\n");
	    $ignored += (length($`) + length($2));
	    $offset += length($`);
	    $word = $1;
	    &debug_out(5, "$word; ");
	    $word =~ tr/A-Z/a-z/;
	    $count{$word} = $count{$word} + 1;
	    $offsets{$word} .= "$offset\t";
	    $slot_num{$offset} = $in_line_num;
	    $num = $num + 1;
	    $text = $';
	    $offset += length($&);
	}
	else {
	    &debug_out(5, "\nignoring: \'$text\'");
	    $ignored += length($text);
	    $offset += length($text);
	    $text = "";
	}
    }

    $sentence_slot[$in_line_num] = $offset;
    $in_line_num++;
}
&debug_out(3, "$num words found\n");
&debug_out(4, "file_len=$file_len ignored=$ignored\n");
&assert($file_len == $offset);
if ($use_fixed_slots == &FALSE) {
    $k = $in_line_num;
}


# Display the word frequencies and offsets
#

foreach $word (keys(%count)) {
    if ($count{$word} != 0) {
        &debug_out(5, "$count{$word}\t${word}\t$offsets{$word}\n");
    	}
}


# Compute the k-vectors for each word by seeing whether the Kth partition 
# contains the word.
#
$bin_size = $offset / $k;
print "# word\tfreq\tk-vector\n";

foreach $word (keys(%count)) {
    # Blank out the k-vector
    @k_vec = ();
    for ($i = 0; $i < $k; $i++) {
	$k_vec[$i] = 0;
	}

    # Tally each offset into the corresponding k-vector slot
    # TODO: try variation where each slot is actually a count not a flag
    &debug_out(5, "$word\n");
    foreach $offset (split(/\t/, $offsets{$word})) {
	$slot = &get_slot_num($offset);
	$k_vec[$slot]++;
	}
    &debug_out(5, "\n");

    print "$word\t$count{$word}\t@k_vec\n";
}


sub get_slot_num {
    local ($offset) = @_;
    local ($slot);

    if ($use_fixed_slots == &TRUE) {
        ## $slot = floor($offset / $k);
	## $slot = ($offset / $k) - ($offset % $k);
	$slot = sprintf "%d", $offset / $bin_size;
    }
    else {
	&assert(defined($slot_num{$offset}));
	$slot = $slot_num{$offset};
    }
    &debug_out(5, "$slot; ");

    return ($slot);
}

