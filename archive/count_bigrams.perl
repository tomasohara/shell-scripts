# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# count_bigrams.perl: count bigrams (and n-grams) in a file
# NOTE: This is quite an inefficient implementation.
#
# TODO:
# - rename to reflect n-gram'ness???
# - make much more efficent
# - perform stemming on the words
# - don't allow bigrams split by punctuation
# - prune entries below occurrence threshold before sort
#
# NOTE: tokens must be space delimited
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir);
    require 'common.perl';
    use vars qw/$script_name/;
}

require 'extra.perl';

use strict;
use vars qw/$n $N $freq_first $count_first $preserve $min $utf8 $sep/;

if (!defined($ARGV[0])) {
    my($options) = "options = [-N=n] [-min=n] [-freq_first] [-preserve]";
    my($example) = "ex: $script_name -N=1 brown.text >! brown.uni\n";

    print STDERR "\nusage: $script_name [options] file ...\n\n$options\n\n$example\n\n";
    &exit()
}

&init_var(*n, 2);			# alias for -N
&init_var(*N, $n);			# length of sequence to check
&init_var(*freq_first, &FALSE);		# should the frequency be displayed first
&init_var(*count_first, $freq_first);	# alias for -freq_first
&init_var(*preserve, &FALSE);		# should case be preserved
&init_var(*min, 1);			# minimun count to display
&init_var(*sep, ":");			# token separator for bigram listing

my(@context) =("n/a") x $N;		# context of N previous tokens
my(%count);				# count of each N-token sequence seen

while (<>) {
    if ($utf8) {
	$_ = decode_utf8($_);
    }
    my($text) = $_;

    while ($text =~ /(\S+)/) {
	my($word) = $1;
	$text = $';		# '

	# Convert to lowercase
	if ($preserve == &FALSE) {
	    $word = &to_lower($word);
	}

	# Increment the count for the entry
	# TODO: have option for the token separator
	my($context) = join($sep, @context);
	&incr_entry(\%count, $context);

	# Update the context
	push (@context, $word);
	shift @context;
    }
}

# Display the frequencies for the token sequences seen
#
my($total) = 0;
foreach my $pair (&sorted_hash_keys_reverse_numeric(\%count)) {
    last if ($count{$pair} < $min);
    if ($count_first) {
	print "$count{$pair}\t$pair\n";
    }
    else {
	print "$pair\t$count{$pair}\n";
    }
    $total += $count{$pair};
}
&debug_print(&TL_DETAILED, "total frequency is $total\n");
