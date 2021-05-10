# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/bin/perl
#
# easy_guesser.pl from AT-Categorizer:
# This script can be helpful for getting a set of baseline scores for
# a categorization task.  It simulates using the "Guesser" learner,
# but is much faster.  Because it doesn't leverage using the whole
# framework, though, it expects everything to be in a very strict
# format.  <cats-file> is in the same format as the 'category_file'
# parameter to the Collection class.  <training-dir> and <test-dir>
# give paths to directories of documents, named as in <cats-file>.

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = $0; $dir =~ s/[^\\\/]*$//; unshift(@INC, $dir);
    require 'common.perl';
}

use strict;
use Statistics::Contingency;

use vars qw/$overall $seed $mostfreq $verbosity/;
&init_var(*overall, &FALSE);		# compute overall accuracy
&init_var(*seed, 0);			# random number seed (0 none; -1 => 1318699)
&init_var(*mostfreq, &FALSE);		# use most frequent category from training data
&init_var(*verbosity, 0);		# verbosity level

die "Usage: $0 <cats-file> <training-dir> <test-dir>\n" unless @ARGV == 3;
my ($cats, $training, $test) = @ARGV;

die "$cats isn't a plain file\n" unless -f $cats;
die "$training isn't a directory\n" unless -d $training;
die "$test isn't a directory\n" unless -d $test;

# Initialize random number, optionally using 100,000th prime (1318699).
$seed = 1318699 if ($seed == -1);
if ($seed > 0) {
    srand($seed);
}

my %cats;
print "Reading category file\n" if ($verbosity);
open my($fh), $cats or die "Can't read $cats: $!";
while (<$fh>) {
    my ($doc, @cats) = split;
    $cats{$doc} = \@cats;
}

my (%freq, $docs);
print "Scanning training set\n" if ($verbosity);
opendir my($dh), $training or die "Can't opendir $training: $!";
while (defined(my $file = readdir $dh)) {
    next if $file eq '.' or $file eq '..';
    unless ($cats{$file}) {
	warn "No category information for '$file'";
	next;
    }
    $docs++;
    $freq{$_}++ foreach @{$cats{$file}};
}
closedir $dh;

print "Calculating probabilities (@{[ %freq ]})\n" if ($verbosity);
my($max_freq) = 0;
my($top_cat) = "";
if ($mostfreq) {
    foreach my $cat (keys %freq) {
	my($freq) = $freq{$cat};
	$freq /= $docs;
	if ($freq > $max_freq) {
	    $max_freq = $freq;
	    $top_cat = $cat;
	}
	$freq{$cat} = $freq;
    }
}
else {
    $_ /= $docs foreach values %freq;
}
my @cats = keys %freq;
if ($mostfreq) {
    print "Top cat: $top_cat; freq=$max_freq\n"  if ($verbosity);
}

print "Scoring test documents\n"  if ($verbosity);
my($num_assignments) = 0;
my($num_correct) = 0;
my($num_cases) = 0;
my $c = Statistics::Contingency->new(categories => \@cats, verbose => $verbosity);
opendir $dh, $test or die "Can't opendir $test: $!";
while (defined(my $file = readdir $dh)) {
    next if $file eq '.' or $file eq '..';
    unless ($cats{$file}) {
	warn "No category information for '$file'";
	next;
    }
    my @assigned;
    foreach (@cats) {
	if ($mostfreq) {
	    push @assigned, $_ if ($_ eq $top_cat);
	}
	else {
	    push @assigned, $_ if rand() < $freq{$_};
	}
    }
    $c->add_result(\@assigned, $cats{$file}, $file);

    # Compute overall accuracy results
    if ($overall) {
	$num_cases++;
	$num_assignments += (scalar @assigned);
	if ((scalar &intersection(\@assigned, $cats{$file})) > 0) {
	    $num_correct++;
	}
    }
}

# Show results (with 4 decimal place precision)
print $c->stats_table(4);
if ($overall) {
    my($precision) = ($num_cases > 0) ? ($num_correct / $num_assignments) : 0.0;
    my($recall) = ($num_assignments > 0) ? ($num_correct / $num_cases) : 0.0;
    my($F1) = ($num_correct > 0) ? (2 * $recall * $precision) / ($recall + $precision) : 0.0;
    print "Overall results\n";
    print "num=$num_cases assignments=$num_assignments; correct=$num_correct\n";
    printf "recall=%.4f precision=%.4f F1=%.4f\n", $recall, $precision, $F1;
}
