# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# make-categorizer-data.perl: create training/testing data needed for
# AI-Categorizer (or Rainbow). This takes as input a directory structure with a
# subdirectory for each category with data files for the given category.  For
# AI-Categorizer, the output is a separate directory structure with just two
# subdirectories, 'training' and 'test', with the original data files randomnly
# partitioned (normally 10% test and 90% training). The output directory
# contains file cats.txt with the assignment of data files to categories.
# For Rainbow, the category subdirectory structure is maintained, in the
# training and testing directories (e.g., training/cat1/file1).
#
# Optionally, a third subdirectory is used called 'heldout', which is not used
# by AI-Categorizer, but serves as a separate source of testing data for use
# with categorizer.perl.
#
# By default, files are kept intact when creating the training and testing data,
# which can lead to skewed distributions in terms of word counts due to
# differing file sizes.  There is an option to create subfiles from the original
# data with word count percents exactly matching the training/test splits, but
# this makes the testing data less natural.
# 
# Alternatively, there is an option to balance the training data, while still
# using the original files as is, according to the mean and stardard deviation
# of the word counts for the files per category. Categories below one standard
# deviation of the mean are pruned entirely.  For those above one stardard
# deviation, the smallest files are removed until within.
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
use vars qw/$in_dir $out_dir $test_percent $heldout_percent $min_test $min_heldout $min_training $max_cat_files $cat_file $stopwords_file $target_file $overwrite $balanced $subfiles $randomize $rainbow $fixed_training $notsorandom $alpha_split/;

# Show a usage statement if no arguments given
# NOTE: By convention '-' is used when no arguments are required
if (!defined($ARGV[0])) {
    my($options) = "main options = [-in_dir=path] [-out_dir=path] [-test_percent=N] [-heldout_percent=N] [-overwrite] [-fixed_training=N] [-target_file=file] [-max_cat_files=N] [-rainbow]";
    $options .= "\n\nother options = [-cat_file=name] [-balanced] [-subfiles] [-randomize] [-min_test=N] [-min_heldout=N] [-min_training=N] [-stopwords_file=path] [-overwrite] [-notsorandom] [-alpha_split]" . &COMMON_OPTIONS;
    my($example) = "Examples:\n\n$script_name -in_dir=geo_cn-data -out_dir=geo_cn-classifer -\n\n";
    $example .= "$0 -d=4 -rainbow -target_file=common-geo_cn-reuters.list -overwrite -min_test=0 -test_percent=10 -max_cat_files=10 -in_dir=geo_cn-testable-data -out_dir=reuters-geo_cn-testable-rainbow - >| make-reuters-geo_cn-testable-rainbow.log 2>&1\n";
    my($note) = "";
    $note .= "Notes:\n";
    $note .= "- The -fixed_training option gives files per category preassigned to training.\n";
    $note .= "- The -files are sorted by size so that smallest ones pruned w/ -max_cat_files.\n";
    $note .= "- The -target_file option specifies subset of categories to include.\n";
    $note .= "- The max_cat_files option specified maxinum number of files per category.\n";
    $note .= "- The -subfiles option is useful when one training file per category available.\n";

    print STDERR "\nUsage: $script_name [options]\n\n$options\n\n$example\n$note";
    &exit();
}

# Check the command-line options
# note: Each variable initialized corresponds to a -var=value commandline option
&init_var(*in_dir, ".");		# dir with category-specific subdirs
&init_var(*out_dir, ".");		# dir with 'training' and 'test' subdirs
&init_var(*overwrite, &FALSE);		# overwrite old data directories
&init_var(*heldout_percent, 0);		# (integral) percentage of held-out test data
my($use_heldout_data) = ($heldout_percent > 0);
&init_var(*test_percent, 10);		# (integral) percentage of test files
&init_var(*min_test,			# minimum testing file per category
	  ($test_percent > 0) ? 1 : 0);
&init_var(*min_heldout,			# minimum heldout file per category
	  $use_heldout_data ? 1 : 0);
&init_var(*min_training, 1);		# minimum training file per category
&init_var(*max_cat_files, &MAXINT);	# maximum number of files per category
&init_var(*fixed_training, 0);		# number of files non-randomly assigned to training
&init_var(*cat_file, "cats.txt");	# categories assigned to each data file
my($default_stopwords_file) = &find_library_file("stopwords.list");
&init_var(*stopwords_file,		# list of words to be omitted as features
	  $default_stopwords_file);
&init_var(*target_file, "");		# list with subset of categories to target
my $use_filter = ($target_file ne "");
&init_var(*balanced, &FALSE);		# ensure balanced data (e.g., same number of words per category)
&init_var(*subfiles, &FALSE);		# create test files from portion of training (i.e., partition via subfiles not individual files)
&init_var(*randomize, &FALSE);		# randomize subfile test data
&init_var(*rainbow, &FALSE);		# target CMU rainbow categorizer
my $ai_categorizer = (! $rainbow);	# target AI:Categorizer (default)
## &init_var(*notsorandom, &FALSE);	# see random number generator with 0
&init_var(*alpha_split, &FALSE);	# split files alphabetically rather than by size (for experiement reproducibility)

my %file_cats;				# categories per data file
my %cat_word_counts;			# number of words in files for each category
my %include_category;			# hash from category name to inclusion status

# Normalize percentages for testing and heldout data.
&assert(($heldout_percent >= 0) && ($heldout_percent <= 100));
$heldout_percent /= 100;
&assert(($test_percent >= 0) && ($test_percent <= 100));
$test_percent /= 100;
&assert(($test_percent + $heldout_percent) < 1.0);

# Make sure output directory exists
$out_dir = &make_full_path($out_dir);
my $trainig_dir = "$out_dir/training";
my $test_dir = "$out_dir/test";
my $heldout_dir = ($use_heldout_data ? "$out_dir/heldout" : "");
if ($overwrite) {
    &issue_command("/bin/rm -rf $trainig_dir $test_dir $heldout_dir");
}
#
if ((-d $trainig_dir) || (-d $test_dir) 
    || ($use_heldout_data && (-d $heldout_dir))) {
    &exit("Output training and/or test directories exist: please delete beforehand");
}
&issue_command("mkdir -p $trainig_dir $test_dir $heldout_dir");
#
if (($stopwords_file ne "") && ($ai_categorizer)) {
    &copy_file($stopwords_file, "$out_dir/stopwords");
}

# Read in list of categories to include
if ($use_filter) {
    map { &set_entry(\%include_category, &to_lower(&trim($_)), &TRUE); } split(/\n/, &read_file($target_file));
}

# Read in list of category subdirectories
# TODO: filter out regular files here (rather than below)
chdir $in_dir;
my(@cat_subdirs) = glob("*");
&trace_array(\@cat_subdirs, &TL_DETAILED, "cat_subdirs");

# Misc. tracing
&debug_print(&TL_BASIC, "Using alphabetic split\n") if ($alpha_split);

# Optionally make the random number generation predictable
# Note: mainly for debugging purposes.
## if ($notsorandom) {
##    &debug_print(&TL_WARNING, "Initializing random seed with 0\n");
##    srand(0);
## }

# Separate files in each category subdir to training or test dir (or heldout dir)
foreach my $cat (@cat_subdirs) {
    next if ($cat =~ /^\.\.?$/);
    if (! -d "$cat") {
	&debug_print(&TL_DETAILED, "Ignoring non-directory: $cat\n");
	next;
    }
    if ($use_filter && (! &get_entry(\%include_category, &to_lower($cat), &FALSE))) {
	&debug_print(&TL_DETAILED, "Filtering category $cat\n");
	next;
    }

    # Randomly partition each of the files for the category
    # NOTE: The files are sorted by size so that smallest ones pruned w/ -max_cat_files.
    # Optionally, the files are processed alphabetically to allow for reproducibiliity
    # across experiments (e.g., words vs hypernym-lists).
    my(%is_good_cat_file);
    my($ls_option) = ($alpha_split ? "" : "-S");
    my(@subdir_files) = split(/\n/, &run_command("ls $ls_option $cat/*"));
    &trace_array(\@subdir_files, &TL_VERBOSE, "subdir_files");
    my($num_files) = (scalar @subdir_files);
    if ($num_files > $max_cat_files) {
	&debug_print(&TL_DETAILED, "Pruning $cat from $num_files files to $max_cat_files\n");
	@subdir_files = @subdir_files[0 .. ($max_cat_files - 1)];
	$num_files = $max_cat_files;
    }
    my(%is_test_file, %is_heldout_file);
    #
    my($training_count) = $fixed_training;	# number files pre-assigned to training
    #
    for (my $i = 0; $i < (scalar @subdir_files); $i++) {
	my $subdir_file = $subdir_files[$i];
	my($file) = &remove_dir($subdir_file);
	if ($file =~ /\s/) {
	    &warning("Spaces in filenames not supported: '$cat/$file'\n");
	    next;
	}
	&set_entry(\%is_good_cat_file, $file, &TRUE);

	# Determine where to put file based on random number occurrence in following intervals:
	#     [0, test),  [test, test+heldout),  [test+heldout, test+heldout+training].
	#     Training    Test                   Held-out
	# NOTE: Ensures that largest file is used for training (see 'ls -S' above).
	my($random) = (($training_count-- > 0) ? 1.0 : rand());
	&debug_print(&TL_VERBOSE, "random=$random\n");
	if ($random < $test_percent) {
	    &set_entry(\%is_test_file, $file, &TRUE);
	}
	elsif ($random < ($test_percent + $heldout_percent)) {
	    &set_entry(\%is_heldout_file, $file, &TRUE);
	}
    }

    # Optionally maintain word counts per category to support balanced data set
    if ($balanced) {
	my($num_words) = &run_command("cat $cat/* | wc -w");
	&set_entry(\%cat_word_counts, $cat, $num_words);
	&debug_print(&TL_DETAILED, "$num_words words for $cat\n");
    }

    # Exclude categories from master list that don't have sufficient files
    if (! $subfiles) {
	my($test_count) = (scalar (keys %is_test_file));
	my($heldout_count) = (scalar (keys %is_heldout_file));
	my($training_count) = ($num_files - $test_count - $heldout_count);
	&debug_print(&TL_DETAILED, "$cat file counts: $test_count test $training_count training ($heldout_count heldout)\n");
	if (($test_count < $min_test) || ($heldout_count < $min_heldout) || ($training_count < $min_training)) {
	    %is_good_cat_file = ();
	    &debug_print(&TL_DETAILED, "Insufficient data for category $cat\n");
	}
    }

    # Write each data file to appropriate directory.
    # NOTE: Normally, individual files partitioned into the test/heldout/training directories,
    # but option for subfiles (e.g., first 10% test, next 10% heldout, and final 80% training).
    if ($subfiles) {
	# Create single training and test files from portion of input data for category.
	# TODO: make code more compact (e.g., tokenize(run_command("cat $cat/*"))).
	my($cat_text) = &run_command("cat $cat/*");	
	my(@cat_words) = &tokenize($cat_text);
	if ($randomize) {
	    @cat_words = &randomize_list(@cat_words);
	}
	my($num_words) = (scalar @cat_words);
	my($num_test_words) = &round($test_percent * $num_words, 0);
	my($num_heldout_words) = &round($heldout_percent * $num_words, 0);
	my($num_nontraining_words) = $num_test_words + $num_heldout_words;
	my(@test_data) = @cat_words[0 .. ($num_test_words - 1)];
	my(@heldout_data) = @cat_words[$num_test_words .. ($num_nontraining_words - 1)];
	my(@training_data) = @cat_words[$num_nontraining_words .. ($num_words - 1)];
	# NOTE: Separate filenames must be used for training and test files
	my($subdir) = ($rainbow ? $cat : ".");
	my($test_file) = "$out_dir/test/$subdir/$cat-test.txt";
	my($training_file) = "$out_dir/training/$subdir/$cat-training.txt";
	my($heldout_file) = "$out_dir/heldout/$subdir/$cat.txt";
	if ($rainbow) {
	    &cmd("mkdir -p $out_dir/test/$cat $out_dir/training/$cat");
	}
	&write_file($test_file, join(" ", @test_data) . "\n");
	&set_entry(\%file_cats, &remove_dir($test_file), " $cat ");
	&write_file($training_file, join(" ", @training_data) . "\n");
	&set_entry(\%file_cats, &remove_dir($training_file), " $cat ");
	if ($use_heldout_data) {
	    &cmd("mkdir -p $out_dir/heldout/$cat") if ($rainbow);
	    &write_file("$out_dir/heldout/$subdir/$cat.txt", join(" ", @heldout_data) . "\n");
	}
	&debug_print(&TL_DETAILED, "$cat: $num_test_words words (of $num_words) for testing; $num_heldout_words held-out words\n");
    }
    else {
	# Copy over original files as is into assigned directory (test or training).
	foreach my $good_file (keys(%is_good_cat_file)) {
	    &assert(&get_entry(\%is_good_cat_file, $good_file, &TRUE));
	    my($is_test) = &get_entry(\%is_test_file, $good_file, &FALSE);
	    my($is_heldout) = &get_entry(\%is_heldout_file, $good_file, &FALSE);
	    my($training_label) = ($is_test ? "test" : $is_heldout ? "heldout" : "training");
	    if ($rainbow) {
		$training_label .= "/$cat";			
		if (! -d "$out_dir/$training_label") {
		    &issue_command("mkdir $out_dir/$training_label");
		}
	    }
	    if (! $is_heldout) {
		&set_entry(\%file_cats, $good_file, " $cat ");
	    }
	    &copy_file("$cat/$good_file", "$out_dir/$training_label/$good_file");
	}
    }
}

# Determine mean and stdev for words per category and prune training files accordingly.
# TODO: rework creation of training data so post-hoc deletion not needed.
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
	    # Prune files from smallest to largest until near upper limit.
	    # Optionally, the files are processed alphabetically to allow for reproducibiliity
	    # across experiments (e.g., words vs hypernym-lists).
	    # NOTE: If result would be below mean, the file is retained.
	    # TODO: truncate files to allow for more precise balancing
	    my($new_cat_words) = $cat_words;
	    my($ls_option) = ($alpha_split ? "" : "-rS");
	    my(@subdir_files) = &tokenize(&run_command("ls $ls_option $cat/*"));
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
if ($ai_categorizer) {
    my($cat_data) = "";
    foreach my $file (sort(keys(%file_cats))) {
	my($file_cats) = &get_entry(\%file_cats, $file, "");
	next if ($file_cats eq "");
	$cat_data .= "$file   $file_cats\n";
    }
    &write_file("$out_dir/$cat_file", $cat_data);
}

&exit();

#------------------------------------------------------------------------

# randomize_list(array): randomize the order of entries in the list
#
sub randomize_list {
    my(@list) = @_;
    my($last_pos) = $#list;

    for (my $i = 0; $i <= $last_pos; $i++) {
	my $new_pos = &round(rand() * $last_pos, 0);
	my $temp = $list[$new_pos];
	$list[$new_pos] = $list[$i];
	$list[$i] = $temp;
    }

    return (@list);
}
