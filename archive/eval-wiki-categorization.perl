# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# eval-wiki-categorization.perl: evaluating AI-categorizer results over 
# category-specific files prepared via download-wiki-entries.perl.
#
# NOTE: Initially designed to automate the following command sequence, but
# later extended to report stardard recall/precision/F-score statistics.
#
# 1. Determine exact-match correctness:
#
#    $ extract_matches.perl -fields=2 -para "dom_\d+\(([^\(]+)-.-en\).*Best category: (\S+)" categorize-geo_cn-samples.nb.log | perl -pe "s/ /_/g;" >| categorize-geo_cn-samples.nb.best.list
#
#    $ perlgrep '^(\S+)\t\1$' categorize-geo_cn-samples.nb.best.list | wc -l
# 34
#
# 2. Determine top-n correctness:
#
#    $ extract_matches.perl -fields=2 -para "dom_\d+\(([^\(]+)-.-en\).*All categories: \(([^\)]+)\)" categorize-geo_cn-samples.nb.log | perl -pe 's/ (.*)\t/_$1\t/g;' >| categorize-geo_cn-samples.nb.all.list
#
#    $ perlgrep '^(\S+)\t.* \1[, ]' categorize-geo_cn-samples.nb.all.list | wc -l
# 34
#
#------------------------------------------------------------------------
# Sample input:
#
#   
#   Categorizing test file "geo_cn-samples/dom_108.txt"
#   Test file header:
#   	category/synset info: S714: [Sset_108-Cgeo_cn-Tdom_108(Taiwan-U-en)(Taiwanese-U-en)(Formosa-U-en)]
#   	URL: en.wikipedia.org/wiki/Taiwan
#   Best category: Taiwan
#   All categories: ( Taiwan )
#   Scores: ( 1 )
#
#   ...
#
#   Categorizing test file "geo_cn-samples/dom_193.txt"
#   Test file header:
#   	category/synset info: S647: [Sset_193-Cgeo_cn-Tdom_193(Corisco Island-U-en)]
#   	URL: en.wikipedia.org/wiki/Corisco
#   Best category: Puerto_Rico
#   All categories: ( Puerto_Rico, Africa )
#   Scores: ( 0.992987143376383, 0.118222257586352 )
#   
# Sample output:
#
#   Number of cases: 406
#   Num correct for best category: 6
#   Num correct for top-n category: 10
#   Num correct for ancestor of best category: 7
#   Num correct for ancestor of top-n category: 14
#   
#   exact evaluation
#   6 of 406 cases classified OK
#   1.000 classifications per case
#   406 total classifications
#   Recall: 0.015
#   Precision: 0.015
#   F Score: 0.015
#   
#   top-n evaluation
#   10 of 406 cases classified OK
#   5.000 classifications per case
#   2030 total classifications
#   Recall: 0.025
#   Precision: 0.005
#   F Score: 0.008
#   
#   exact w/ ancestor evaluation
#   13 of 406 cases classified OK
#   1.000 classifications per case
#   406 total classifications
#   Recall: 0.032
#   Precision: 0.032
#   F Score: 0.032
#   
#   top-n w/ ancestor evaluation
#   24 of 406 cases classified OK
#   5.000 classifications per case
#   2030 total classifications
#   Recall: 0.059
#   Precision: 0.012
#   F Score: 0.020
#
#------------------------------------------------------------------------
# TODO: 
# - Add in verbose output include blurb of document and category
#   (see eval-rware-categorization.perl developed for RWare categorizer).
# - Reconcile with eval-rware-categorization.perl (e.g., using generic-eval-categorization.perl module).
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = $0; $dir =~ s/[^\\\/]*$//; unshift(@INC, $dir);
    require 'common.perl';
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
use vars qw/$node_file $parent_file $node_file $test_key $prune_scores $min_score $posthoc $cat_subdirs $rainbow $topn/;

# Show a usage statement if no arguments given
# NOTE: By convention '-' is used when no arguments are required
if (!defined($ARGV[0])) {
    my($options) = "main options = [-node_file=file] [-parent_file=file] [-test_key=file] [-cat_subdirs] [-rainbow]";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "Examples:\n\n$script_name categorize-geo_cn-samples.log\n\n";
    $example .= "$0 -node_file=geo_cn-terms.data -parent_file=geo_cn-parents.data categorize-geo_cn-samples.log\n\n";
    my($note) = "";
    ## $note .= "Notes:\n\nSome usage note.\n";		     # TODO: usage note

    print STDERR "\nUsage: $script_name [options]\n\n$options\n\n$example\n$note";
    &exit();
}
my $classifier_log_file = $ARGV[0];
my $output_basename = &remove_extension($classifier_log_file);

# Check the command-line options
# note: Each variable initialized corresponds to a -var=value commandline option
&init_var(*test_key, "");		# key with categories for test files
&init_var(*cat_subdirs, &FALSE);	# directory for document gives category
&init_var(*node_file, "");		# node-synset data file
&init_var(*parent_file, "");		# child-parent data file for nodes
&init_var(*prune_scores, &FALSE);	# prune low scores (e.g., less than 1E-6)
&init_var(*topn, -1);			# number of top scores to use
&init_var(*min_score, 1e-6);		# minimum score to include
&init_var(*posthoc, &FALSE);		# check for posthoc evaluation
&init_var(*rainbow, &FALSE);		# evaluate output from rainbow
my $include_ancestors = ($parent_file ne "");
my $resolve_node_terms = ($node_file ne "");
my $resolve_category = ($test_key ne "");
my $check_synset_for_cat = (! ($resolve_category || $cat_subdirs));

# Globals for node information
our %parent_of;		# hash from child category node to parent
our %node_synset;	# hash from category node to synset (term)
our %node_for_name;	# hash from category name to node id

# Global variables for tabulating results, saving state about current document, etc.
our $num_cases = 0;			# number of documents being categorized
our $num_exact_correct = 0;		# num matches for best answer
our $num_topn_correct = 0;		# num matches in top-n answers
our $num_topn_answers = 0;		# num top-n answers
our $num_ancestor_correct = 0;		# num matches for ancestor of best answer (when mismatch)
our $num_topn_ancestor_correct = 0;	# num matches in ancestors of top-n answers (when mismatch)
our $node = "";
our @node_ancestors;
our $top = "top-n";
## our $topn = -1;
## our $best_match = &FALSE;
our $top_categories = "";
our $eval_info = "";

# Read in node-synset file for use with ancestor check
# TODO: prepare parent data file with names already resolved.
if ($resolve_node_terms) {
    &debug_print(&TL_DETAILED, "Reading node synset term information\n");
    foreach my $node_info (split(/\n/, &read_file($node_file))) {
	my($node, $synset_term) = split(/\t/, $node_info);
	$synset_term =~ s/ /_/g;
	$node = &to_lower($node);
	$synset_term = &to_lower($synset_term);
	&set_entry(\%node_synset, $node, $synset_term);
	&set_entry(\%node_for_name, $synset_term, $node);
    }
    &trace_assoc_array(\%node_synset, &TL_VERY_DETAILED, "node_synset");
    &trace_assoc_array(\%node_for_name, &TL_VERY_DETAILED, "node_for_name");
}

# Read in the parent relationship data file
# TODO: allow for more than one parent
if ($include_ancestors) {
    &debug_print(&TL_DETAILED, "Reading category parent information\n");
    foreach my $parent_info (split(/\n/, &read_file($parent_file))) {
	my($category, $parent) = split(/\t/, $parent_info);
	if ($resolve_node_terms) {
	    $category = &get_entry(\%node_synset, $category, $category);
	    $parent = &get_entry(\%node_synset, $parent, $parent);
	}
	$category = &to_lower($category);
	$parent = &to_lower($parent);
	&set_entry(\%parent_of, $category, $parent);
    }
    &trace_assoc_array(\%parent_of, &TL_VERY_DETAILED, "parent_of");
}

# Read in test key
our(%file_category);
if ($resolve_category) {
    &debug_print(&TL_DETAILED, "Reading test key information\n");
    foreach my $key_info (split(/\n/, &read_file($test_key))) {
	my($file, $cat) = split(/\t/, $key_info);
	&set_entry(\%file_category, $file, $cat);
    }
}

# Scan through output listing counting number correct for best-match, top-n match,
# as well allowing for matches via ancestor categories.
#
while (<>) {
    &dump_line();
    chomp;

    # Use filename mapped to category as alternative source
    if (/^categorizing test file \"(.*)\"$/i) {
	my $file_path = $1;
	&record_test_file($file_path);
    }

    # Get taxonomy node name
    # NOTE: Testing file header contains category synset information (e.g., '[Sset_116-Cgeo_cn-Tdom_116(Banjul-U-en)]'). See categorize.perl.
    elsif ($check_synset_for_cat && /synset[^\n]+\-T[^\(]+\(([^\(]+)-.-en\)/i) {
	$node = $1;
	$node =~ s/ /_/g;
	&debug_print(&TL_DETAILED, "\nnode=$node\n");
	@node_ancestors = &get_ancestors($node);
	$num_cases++;
    }

    # Count number of exact match categorizations
    elsif (/Best category: (\S+)/i) {
	my $best = $1;
	&eval_best_case($best);
    }

    # Save the top-n categories specification
    elsif (/(All|Top\S*) categories: \(([^\)]+)\)/i) {
	$top_categories = &to_lower(&trim($2));
    }

    # Check for optional posthoc evaluation
    elsif (/Eval: (.*)/i) {
	$eval_info = $1;
    }

    # Count number of top-n categorizations, optionally filtering those with low scores
    elsif (/^Scores: \(([^\)]+)\)/i) {
	my $score_info = $1;
	&debug_print(&TL_DETAILED, "top-n=$top_categories\n");
	&assert($node ne "");
	&assert($top_categories ne "");
	## BAD: next if ($best_match);

	if (($topn == -1) && (/^Top-(\d+)/i)) {
	    $topn = $1;
	    $top = "Top-$topn";
	}

	# Perform the evaluation for current document
	my(@topn_categories) = split(/, /, $top_categories);
	my(@scores) = split(/, /, $score_info);
	&eval_topn_cases(\@topn_categories, \@scores);

	# Clear saved state
	$node = "";
	@node_ancestors = ();
	$top_categories = "";
	$eval_info = "";
    }

    # Check for output from rainbow classifier (via rainbow-stats script)
    # ex: C:\data\reuters-21578\geo_cn-test/Austria/R21120.txt Austria Austria:0.06957631558 Thailand:0.04910733551 Turkey:0.03869066387
    elsif ($rainbow && /^(\S+) (\S+) (((\S+:[0-9E.]+) )+)$/i) {
	my($path, $category, $scores) = ($1, $2, $3);
	&record_test_file($path);
	&assert($node eq &to_lower($category));
	# Perform the evaluation for current document
	my(@topn_categories) = ();
	my(@scores) = ();
	foreach my $score_info (split(/ /, &trim($scores))) {
	    my($category, $score) = split(/:/, $score_info);
	    push(@topn_categories, $category);
	    push(@scores, $score);
	}
	&eval_best_case($topn_categories[0]);
	&eval_topn_cases(\@topn_categories, \@scores);
    }

    # Ignore other lines, including sanity check for un-obsfuscated lines
    else {
	&assert(! /Z[A-Za-z0-9]+Z/);
	&debug_print(&TL_VERY_VERBOSE, "Ignoring line: $_\n");
    }
}

# Display statistics on correctness
print "Number of cases: $num_cases\n";
print "Num correct for best category: $num_exact_correct\n";
print "Num correct for $top category: $num_topn_correct\n";
if ($include_ancestors) {
    print "Num correct for ancestor of best category: $num_ancestor_correct\n";
    print "Num correct for ancestor of $top category: $num_topn_ancestor_correct\n";
}
print "\n";

# Calculate recall, precision, and F score for exact ot top-N with and without ancestors
&calc_recall_precision("exact", $num_exact_correct, $num_cases, $num_cases);
&calc_recall_precision("top-n", $num_topn_correct, $num_topn_answers, $num_cases);
if ($include_ancestors) {
    &calc_recall_precision("exact w/ ancestor", ($num_exact_correct + $num_ancestor_correct), $num_cases, $num_cases);
    &calc_recall_precision("top-n w/ ancestor", ($num_topn_correct + $num_topn_ancestor_correct), $num_topn_answers, $num_cases);
}

&exit();

#------------------------------------------------------------------------------

# calc_recall_precision(label, num_correct, num_answers, num_cases): Calculates
# recall, precision and F score for classification.
# recall: percentage of cases classified OK
# precision: percentage of total classifications made there were OK
# F-score: measure that balances recall and precision via harmonic mean (F=2*P*R/(P + R))
#
sub calc_recall_precision {
    my($label, $num_correct, $num_answers, $num_cases) = @_;
    
    my($recall, $precision, $F_score) = (0, 0, 0);
    print "$label evaluation\n";
    printf "%d of %d cases classified OK\n", $num_correct, $num_cases;
    if ($num_cases > 0) {
	$recall = ($num_correct / $num_cases);
	my($classifications_per_case) = ($num_answers / $num_cases);
	printf "%.3f classifications per case\n", $classifications_per_case;
    }

    printf "%d total classifications\n", $num_answers;
    if ($num_answers > 0) {
	$precision = ($num_correct / $num_answers);
    }
    if (($precision + $recall) > 0) {
	$F_score = (2 * $precision * $recall) / ($precision + $recall);
    }

    printf "Recall: %.3f\n", $recall;
    printf "Precision: %.3f\n", $precision;
    printf "F Score: %.3f\n", $F_score;
    print "\n";
}

# get_ancestors(node): returns list of ancestors for node
# TODO: resolve node names into synset names to facilitate debugging
#
sub get_ancestors {
    my($node) = @_;
    &debug_print(&TL_VERBOSE, "get_ancestors(@_)\n");
    my(@ancestors) = ();

    while ($node ne "") {
	my $parent = &get_entry(\%parent_of, $node, "");
	if ($parent ne "") {
	    push(@ancestors, $parent);
	}
	$node = $parent;
    }
    &debug_out(&TL_DETAILED, "ancestors of @_: %s\n", join(", ", @ancestors));

    return (@ancestors);
}

# record_test_file(path): make note of new file for evaluation, optionally
# resolving the correct category from the file name
# NOTE: uses following globals: %node_for_name
#
sub record_test_file {
    my($file_path) = @_;
    &debug_print(&TL_VERBOSE, "record_test_file(@_)\n");
    my $file_name = &remove_dir($file_path);

    if ($cat_subdirs) {
	# Extract category from parent directory of file
	if ($file_path =~ /[\\\/]([^\\\/]+)[\\\/][^\\\/]+$/) {
	    $node = &to_lower($1);
	    if (! $resolve_node_terms) {
		$node = &get_entry(\%node_for_name, $node, $node);
	    }
	}
	else {
	    &debug_print(&TL_DETAILED, "Warning: Unable to extract category from filename '$file_path'\n");
	}
    }
    elsif ($resolve_category) {
	# Extract category name from key
	$node = &get_entry(\%file_category, $file_name, $file_name);
    }
    else {
	# This case handled via -check_synset_for_cat (see main loop above).
    }

    if ($node ne "") {
	&debug_print(&TL_DETAILED, "\nfile_path=$file_path\nfile_name=$file_name\nnode=$node\n");
	@node_ancestors = &get_ancestors($node);
	$num_cases++;
    }
}


# eval_best_case(best_category): See if known key for current document matches best case returned by system being evaluated.
# NOTE: Globals $node, @node_ancestors, $num_exact_correct, $best_match.
#
sub eval_best_case {
    my($best) = @_;
    &debug_print(&TL_VERBOSE, "eval_best_case(@_)\n");
    
    &assert($node ne "");
    $best = &to_lower($best);
    &debug_print(&TL_DETAILED, "best=$best; node=$node\n");
    if ($node eq $best) {
	$num_exact_correct++;
	## $best_match = &TRUE;
	&debug_print(&TL_VERBOSE, "best match\n");
    }
    elsif (find(\@node_ancestors, $best) != -1) {
	$num_ancestor_correct++;
	## $best_match = &TRUE;
	&debug_print(&TL_VERBOSE, "ancestor match\n");
    }
    else {
	## $best_match = &FALSE;
	&debug_print(&TL_VERBOSE, "mis-match: system $best vs. key $node\n");
    }
}

# eval_topn_cases(topn_categories_ref, score_list_ref): Evaluates test case in terms of exact-match and top-N occurrence
#
sub eval_topn_cases {
    my($topn_categories_ref, $scores_ref) = @_;
    &debug_print(&TL_VERBOSE, "eval_topn_cases(@_)\n");
    my @topn_categories = @$topn_categories_ref;
    my @scores = @$scores_ref;
    &assert((scalar @scores) == (scalar @topn_categories));
    &assert($node ne "");
    &trace_array(\@topn_categories, &TL_VERBOSE, "topn_categories");
    &trace_array(\@scores, &TL_VERBOSE, "scores");

    my(@evals);
    if ($posthoc) {
	@evals = split(/, /, $eval_info);
	&assert((scalar @evals) == (scalar @topn_categories));
    }

    # Filter out cases corresponding to exceptionally low scores
    my $end = -1;
    if ($prune_scores) {
	for (my $i = 0; $i <= $#scores; $i++) {
	    if ($scores[$i] < $min_score) {
		last;
	    }
	    $end = $i;
	}
    }
    elsif ($topn != 0) {
	$end = min($#scores, $topn - 1);
    }
    if ($end != -1) {
	&debug_out(&TL_DETAILED, "Pruning %d low scores\n", ($#scores - $end));
	@topn_categories = @topn_categories[0 .. $end];
	if ($posthoc) {
	    @evals = @evals[0 .. $end];
	}
    }
    
    &debug_out(&TL_VERY_DETAILED, "topn_cats=(@topn_categories) #topn_cats=%d\n", (scalar @topn_categories));
    if ($posthoc) {
	&debug_print(&TL_VERY_DETAILED, "evals=(@evals)\n");
    }
    $num_topn_answers += (scalar @topn_categories);

    foreach my $in_top_category (@topn_categories) {
	my $top_category = &to_lower($in_top_category);
	if ($node eq $top_category) {
	    ## TODO: if (! $best_match) {
	    $num_topn_correct++;
	    &debug_print(&TL_VERBOSE, "top-n match\n");
	    last;
	}
	elsif (find(\@node_ancestors, $top_category) != -1) {
	    $num_topn_ancestor_correct++;
	    &debug_print(&TL_VERBOSE, "ancestor of top-n match\n");
	    last;
	}
	&debug_print(&TL_VERY_DETAILED, "bad category match: $top_category\n");
    }
}
