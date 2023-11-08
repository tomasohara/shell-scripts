# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# Based on demo.pl from AI-Categorizer:
# This script is a fairly simple demonstration of how AI::Categorizer
# can be used.  There are lots of other less-simple demonstrations
# (actually, they're doing much simpler things, but are probably
# harder to follow) in the tests in the t/ subdirectory.  The
# eg/categorizer script can also be a good example if you're willing
# to figure out a bit how it works.
#
# This script reads a training corpus from a directory of plain-text
# documents, trains a Naive Bayes categorizer on it, then tests the
# categorizer on a set of test documents.
#
# TODO:
# - write up complete installation steps:
#   -- cpan install of AI-Categorizer, Algorithm::NaiveBayes, AI::DecisionTree, etc.
#   -- code fixups
#   -- stopwords
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = $0; $dir =~ s/[^\\\/]*$//; unshift(@INC, $dir);
    require 'common.perl';
    require 'extra.perl';
}

use strict;
use vars qw/$weka $j48 $id3 $decision_tree $nb $naive_bayes $demo_example $show_features $save_state $load_state $verbosity $cat_stats $check_test_dir $test_file $show_statistics/;

&init_var(*j48, &FALSE);		# alias for -weka
&init_var(*weka, $j48);			# classify via Weka
&init_var(*id3, &FALSE);		# alias for -decision_tree
&init_var(*decision_tree, $id3);	# use decision tree classifier
&init_var(*nb, 				# alias for -naive_bayes
	  (!$decision_tree && !$weka));
&init_var(*naive_bayes, $nb);		# use Naive Bayes classifier
&init_var(*demo_example, &FALSE);	# test demo example
&init_var(*show_features, &FALSE);	# show the induced feature set
&init_var(*load_state, &FALSE);		# load in previous classifier state
&init_var(*save_state, &FALSE);		# save the classifier state
&init_var(*verbosity, 0);		# AI-Categorizer verbosity level
&init_var(*cat_stats, &FALSE);		# show statistics for eah category
## &init_var(*check_test_dir, (! $load_state));	# test files in ./test
&init_var(*test_file, "");		# file to test
&init_var(*check_test_dir,		# test files in ./test
	  ($test_file eq ""));
&init_var(*show_statistics, 		# show statistics over test files
	  $check_test_dir);

use AI::Categorizer;
use AI::Categorizer::Collection::Files;
use AI::Categorizer::Learner::NaiveBayes;
# Workaround for state-restore problem
use Algorithm::NaiveBayes::Model::Frequency;
use AI::Categorizer::Learner::DecisionTree;
use AI::Categorizer::Learner::Weka;
use File::Spec;

die("Usage: $0 <corpus>\n".
    "  A sample corpus (data set) can be downloaded from\n".
    "     http://www.cpan.org/authors/Ken_Williams/data/reuters-21578.tar.gz\n".
    "  or http://www.limnus.com/~ken/reuters-21578.tar.gz\n")
  unless @ARGV == 1;

my $corpus = shift;

my $training  = File::Spec->catfile( $corpus, 'training' );
my $test      = File::Spec->catfile( $corpus, 'test' );
my $cats      = File::Spec->catfile( $corpus, 'cats.txt' );
my $stopwords = File::Spec->catfile( $corpus, 'stopwords' );

my %params;
if (-e $stopwords) {
  $params{stopword_file} = $stopwords;
} else {
  warn "$stopwords not found - no stopwords will be used.\n";
}

if (-e $cats) {
  $params{category_file} = $cats;
} else {
  die "$cats not found - can't proceed without category information.\n";
}


# For Java-based Weka, TMPDIR needs to be Win32-based
if (&WIN32() && $weka) {
    $ENV{TMPDIR} = ".";
}

# In a real-world application these Collection objects could be of any
# type (any Collection subclass).  Or you could create each Document
# object manually.  Or you could let the KnowledgeSet create the
# Collection objects for you.

$training = AI::Categorizer::Collection::Files->new( path => $training, %params );
$test     = AI::Categorizer::Collection::Files->new( path => $test, %params );

# We turn on verbose mode so you can watch the progress of loading &
# training.  This looks nicer if you have Time::Progress installed!
my($k);
if (! $load_state) {
    print "Loading training set\n" if ($verbosity);
    $k = AI::Categorizer::KnowledgeSet->new( verbose => $verbosity );
    $k->load( collection => $training );
}

# Create classifier-specific object
my $l;
my($classifier) = "";
if ($decision_tree) {
    $classifier = "id3";
    print "Using decision tree (ID3) classifier\n" if ($verbosity);
    $l = AI::Categorizer::Learner::DecisionTree->new( verbose => $verbosity );
}
elsif ($weka) {
    $classifier = "j48";
    print "Using Weka's j4.8 classifier (C4.5 clone)\n" if ($verbosity);
    $l = AI::Categorizer::Learner::Weka->new( verbose => $verbosity, weka_classifier => 'weka.classifiers.j48.J48' );
}
else {
    &assert($naive_bayes);
    $classifier = "nb";
    print "Using Naive Bayes classifier\n" if ($verbosity);
    $l = AI::Categorizer::Learner::NaiveBayes->new( verbose => $verbosity );
}
my($state_file) = "classifier-state-$classifier";

# Either learn new classifier from scratch (over training dir) or load in
# previous state.
if (! $load_state) {
    print "Training categorizer\n" if ($verbosity);
    $l->train( knowledge_set => $k );
}
else {
    print "Restoring categorizer state from $state_file\n" if ($verbosity);
    # NOTE; Following leads to a problem. For discussion, see
    ## $l->restore_state($state_file);
    # Following workaround based on
    #   http://www.mail-archive.com/perl-ai@perl.org/msg00429.html
    # TODO: Find workaround that doesn't require learner-specific loading.
    if ($decision_tree) {
	$l = AI::Categorizer::Learner::DecisionTree->restore_state($state_file);
    }
    elsif ($weka) {
	$l = AI::Categorizer::Learner::Weka->restore_state($state_file);
    }
    elsif ($naive_bayes) {
	$l = AI::Categorizer::Learner::NaiveBayes->restore_state($state_file);
    }
    else {
	$l->restore_state($state_file);
    }
    &debug_out(&TL_VERY_DETAILED, "old state: {\n%s\n}", &stringify_value($l, 1));
}

# Save state of the classifier
# NOTE: Results saved in subdirectory.
if ($save_state) {
    print "Saving categorizer state to $state_file\n" if ($verbosity);
    &debug_out(&TL_VERY_DETAILED, "new state: {\n%s\n}", &stringify_value($l, 1));
    $l->save_state($state_file);
}

# Show features based on training data
if ($show_features) {
    my $features = $k->features()->as_hash();
    print "Features:\n";
    map { printf "\t%s:%s\n", $_, $$features{$_}; } keys %$features;
    print "\n";
}

# Categorize test documents
my($experiment);
if ($check_test_dir) {
    print "Categorizing test set\n" if ($verbosity);
    $experiment = $l->categorize_collection( collection => $test );
}
elsif (-f $test_file) {
    print "Categorizing test file '$test_file'\n" if ($verbosity);
    ## my($doc) = new AI::Categorizer::Document(name => $test_file);
    my($doc) = new AI::Categorizer::Document(content => read_file($test_file));
    my $h = $l->categorize( $doc );
    print "Category: ", $h->best_category, "\n",
}
else {
    &error("Test file '$test_file' not found ($!)\n");
}

# Show micro- and macro-averaged statistics
if ($show_statistics) {
    print $experiment->stats_table;

    # Show per-category statistics
    if ($cat_stats) {
	my $stats = $experiment->category_stats;
	printf "%-32s\tAccur\tRec\tPrec\tF1\n", "Cat";
	while (my ($cat, $value) = each %$stats) {
	    printf "%-32s\t%.4f\t%.4f\t%.4f\t%.4f\n", $cat, $value->{accuracy}, $value->{recall}, $value->{precision}, $value->{F1};
	}
    }
}

# If you want to get at the specific assigned categories for a
# specific document, you can do it like this:
#
if ($demo_example) {
    print "\n";
    my $doc_contents = "Hello, I am a pretty generic document with not much to say.";
    my $doc = AI::Categorizer::Document->new
	( content =>  $doc_contents );

    my $h = $l->categorize( $doc );

    print "For test document:\n",
           "      $doc_contents\n",
	   "  Best category = ", $h->best_category, "\n",
	   "  All categories = ", join(', ', $h->categories), "\n";
}

# Cleanup
&exit();
