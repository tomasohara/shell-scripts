# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# make-ai-categorizer-data.perl: create training/testing data needed 
# for AI-Categorizer. This takes as input a directory structure with a
# subdirectory for each category with data files for the given category.
# The output is a separate directory structure with just two subdirectories,
# training and test, with the original data files randomly partitioned
# (normally 10% test and 90% training). The output directory also contains
# the file cats.txt with the assignment of data files to categories.
#
# There is an option to balance the training data, which is done according
# to the mean and stardard deviation of the word counts for the files per category.
# Categories below one standard deviation of the mean are pruned entirely.
# For those above one stardard deviation, the smallest files are removed until
# within.
#
# TODO:
# - Rework so that files can have more than one category.
# - Rework so that balancing creates new category-specific file with word counts
#   based on mean and stdev of original assignment, rather than using the original
#   data files as is.
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = $0; $dir =~ s/[^\\\/]*$//; unshift(@INC, $dir);
    require 'common.perl';
    use vars qw/$default_random/;
    $default_random = &TRUE;
    require 'extra.perl';
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
use vars qw/$in_dir $out_dir $test_percent $min_test $min_training $cat_file $stopwords_file $overwrite $balanced/;

# Show a usage statement if no arguments given
# NOTE: By convention '-' is used when no arguments are required
if (!defined($ARGV[0])) {
    my($options) = "main options = [-in_dir=path] [-out_dir=path] [-min_test=N] [-min_training=N] [-test_percent=N] [-overwrite]";
    $options .= "\nother options = [-test_percent=n] [-cat_file=name] [-stopwords_file=path]" . &COMMON_OPTIONS;
    my($example) = "Examples:\n\n$script_name -in_dir=geo_cn-data -out_dir=geo_cn-classifer -\n\n";
    ## $example .= "$0 example2\n\n";		   	     # TODO: 2nd example
    my($note) = "";
    ## $note .= "Notes:\n\nSome usage note.\n";		     # TODO: usage note

    print STDERR "\nUsage: $script_name [options]\n\n$options\n\n$example\n$note";
    &exit();
}

# Check the command-line options
# note: Each variable initialized corresponds to a -var=value commandline option
&init_var(*in_dir, ".");		# dir with category-specific subdirs
&init_var(*out_dir, ".");		# dir with 'training' and 'test' subdirs
$out_dir = &make_full_path($out_dir);
&init_var(*overwrite, &FALSE);		# overwrite old data directories
&init_var(*test_percent, 10);		# (integral) percentage of test files
&assert(($test_percent >= 0) && ($test_percent <= 100));
$test_percent /= 100;
&init_var(*min_test,			# minimum testing file per category
	  ($test_percent > 0) ? 1 : 0);
&init_var(*min_training, 1);		# minimum training file per category
&init_var(*cat_file, "cats.txt");	# categories assigned to each data file
my($default_stopwords_file) = &find_library_file("stopwords.list");
&init_var(*stopwords_file,		# list of words to be omitted as features
	  $default_stopwords_file);
&init_var(*balanced, &FALSE);		# ensure balanced data (e.g., same number of words per category)

my(%file_cats);				# categories per data file
my(%cat_word_counts);			# number of words in files for each category
my($total_words);

# Make sure output directory exists
my($trainig_dir) = "$out_dir/training";
my($test_dir) = "$out_dir/test";
if ($overwrite) {
    &issue_command("/bin/rm -r $trainig_dir $test_dir");
}
#
if ((-d $trainig_dir) || (-d $test_dir)) {
    &exit("Output training and/or test directories exist: please delete beforehand");
}
&issue_command("mkdir -p $trainig_dir $test_dir");
#
if ($stopwords_file ne "") {
    &copy_file($stopwords_file, "$out_dir/stopwords");
}

# Read in list of category subdirectories
chdir $in_dir;
my(@cat_subdirs) = glob("*");
&trace_array(\@cat_subdirs, &TL_DETAILED, "cat_subdirs");

# Separate files in each category subdir to training or test dir
foreach my $cat (@cat_subdirs) {
    next if ($cat =~ /^\.\.?$/);
    if (! -d "$cat") {
	&debug_print(&TL_DETAILED, "Ignoring non-directory: $cat\n");
	next;
    }

    # Randomly partition each of the files for the category
    my(%is_good_cat_file);
    my(@subdir_files) = glob("$cat/*");
    my($num_files) = (scalar @subdir_files);
    my(%is_test_file);
    #
    foreach my $subdir_file (@subdir_files) {
	my($file) = &remove_dir($subdir_file);
	if ($file =~ /\s/) {
	    &warning("Spaces in filenames not supported: '$cat/$file'\n");
	    next;
	}
	&set_entry(\%is_good_cat_file, $file, &TRUE);

	# Determine where to put file
	if (rand() < $test_percent) {
	    &set_entry(\%is_test_file, $file, &TRUE);
	}	
    }

    # Optionally maintain word counts for category to support balanced data set
    if ($balanced) {
	my($num_words) = &run_command("cat $cat/* | wc -w");
	&set_entry(\%cat_word_counts, $cat, $num_words);
	$total_words += $num_words;
	&debug_print(&TL_DETAILED, "$num_words words for $cat\n");
    }

    # Exclude categories from master list that don't have sufficient files
    my($test_count) = (scalar (keys %is_test_file));
    my($training_count) = ($num_files - $test_count);
    &debug_print(&TL_DETAILED, "$cat: $test_count test $training_count training\n");
    if ($test_count < $min_test) {
	&debug_print(&TL_DETAILED, "Insufficient test data for category $cat\n");
	%is_good_cat_file = ();
    }
    if ($training_count < $min_training) {
	&debug_print(&TL_DETAILED, "Insufficient training data for category $cat\n");
	%is_good_cat_file = ();
    }

    # Write each data file to appropriate directory
    foreach my $good_file (keys(%is_good_cat_file)) {
	&assert(&get_entry(\%is_good_cat_file, $good_file, &TRUE));
	my($is_test) = &get_entry(\%is_test_file, $good_file, &FALSE);
	my($training_label) = ($is_test ? "test" : "training");
	&set_entry(\%file_cats, $good_file , " $cat ");
    	&copy_file("$cat/$good_file", "$out_dir/$training_label/$good_file");
    }
}

# Determine mean and stdev for words per category and prune files accordingly
# TODO: rework creation of training data so post-hoc deletion not needed
if ($balanced) {
    my(@word_counts) = (values %cat_word_counts);
    my($stdev, $mean) = &stdev(@word_counts);
    my($min_words) = $mean - $stdev;
    my($max_words) = $mean + $stdev;
    my(@pruned_cats);
    &debug_print(&TL_DETAILED, "word stats: mean=$mean stdev=$stdev lower=$min_words upper=$max_words\n");
    foreach my $cat (keys %cat_word_counts) {
	my($cat_words) = $cat_word_counts{$cat};

	if ($cat_words < $min_words) {
	    push(@pruned_cats, $cat);
	    &debug_print(&TL_DETAILED, "Removing category $cat with too few words ($cat_words)\n");
	    next;
	}
	elsif ($cat_words <= $max_words) {
	    &debug_print(&TL_DETAILED, "Retaining category $cat as is ($cat_words words)\n");
	}
	else {
	    # Prune files from smallest to lowest until near upper limit.
	    # NOTE: If result would be below mean, the file is retained.
	    # TODO: truncate files to allow for more precise balancing
	    my($new_cat_words) = $cat_words;
	    my(@subdir_files) = &tokenize(&run_command("ls -S $cat/*"));
	    #
	    foreach my $subdir_file (@subdir_files) {
		my($file_words) = &run_command("cat \"$subdir_file\" | wc -w");
		last if (($new_cat_words - $file_words) <= $mean);
		$new_cat_words -= $file_words;
		my($file) = &remove_dir($subdir_file);
		&set_entry(\%file_cats, $file, "");
		&issue_command("rm -f $out_dir/*/\"$file\"");
		&debug_print(&TL_DETAILED, "Pruned $file from category $cat ($file_words words)\n");
		last if ($new_cat_words <= $max_words);
	    }
	    if ($new_cat_words < $cat_words) {
		&debug_print(&TL_DETAILED, "Pruned category $cat from $cat_words words ($new_cat_words words)\n");
	    }
	}
    }

    # Remove pruned categories from file-to-category hash
    if ((scalar @pruned_cats) > 0) {
	foreach my $file (sort(keys(%file_cats))) {
	    my($file_cats) = &get_entry(\%file_cats, $file, "");
	    foreach my $pruned_cat (@pruned_cats) {
		$file_cats =~ s/ \Q$pruned_cat\E //;
	    }
	    &set_entry(\%file_cats, $file, &trim($file_cats));
	}
    }

}

# Outout the category listing (cats.txt). Format:
#   file1 cat11 cat12 ...
#   ...
#   filen catn1 catn2 ...
my($cat_data) = "";
foreach my $file (sort(keys(%file_cats))) {
    my($file_cats) = &get_entry(\%file_cats, $file, "");
    next if ($file_cats eq "");
    $cat_data .= "$file   $file_cats\n";
}
&write_file("$out_dir/$cat_file", $cat_data);

&exit();
