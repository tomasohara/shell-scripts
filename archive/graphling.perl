# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# graphling.perl: common module for GraphLing scripts
#
# TODO:
# - Add 'EX:' throughout here and in other Graphling perl scripts for unit testing
# - Decompose the main script bodies of client script into subroutines to allow for
#   easier testing (e.g., test-perl-examnples)
# - Review client scripts to make sure all pattern matching that should be
#   case-insensitive uses the i qualifier.
# - Add EX-tests to remainder of subroutines (e.g., get_classification_distribution)
# - define $graphling_options for command-line options available
# - handle class-pos spec if more than 26 features
#
# Copyright (c) 2005 Tom O'Hara and New Mexico State University.
# Freely available via GNU General Public License (see GNU_public_license.txt).
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir);
    require 'common.perl';
    require 'extra.perl';
}

# Uncomment the following to check for undeclared variables.
# NOTES:
# - This is commented out until client programs can be made more strict.
# - Strict refs not used to allow for file handle string references.
# TODO: use more standard way of exporting variables
## use strict;
## no strict "refs";
use vars qw/$GRAPHLING_HOME $GRAPHLING $DATA $TOOLS $release_mode $default_POS $reuse $test $WNSEARCHDIR $word_freq_file $GRAPHLING_TRACE/;

our($default_word_frequency_file);
our($default_relatedness_file);

sub RELEASE_MODE { $release_mode; }

our($DUMMY_SENSE);		# dummy sense tag to use for GraphLing classifier
our($UNTAGGED_SENSE);		# the sense tag to use for untagged test data
my(@coco_var_names);		# letter names for CoCo variables by index
my(%coco_var_index);		# index assigned for CoCo variable by name

#------------------------------------------------------------------------------

# init_graphling(): Initializes the GraphLing module.
#
# This initializes the settings overrideable by environment variables or
# command-line options (eg, GRAPHLING dir and its DATA subdir). It also loads in
# the WordNet module with the cache dir set to the DATA dir.
#
# NOTES:
# - the frequency hash is not initialized here in order to decrease load time
#   for scripts that don't use the frequency routine get_freq
# - similary the wordNet module is not initialized.
#
# EX: init_graphling() => 1
#
sub init_graphling {
    &debug_print(&TL_DETAILED, "init_graphling(@_)\n");

    # Intialize options overrideable by environment variables
    &init_var(*GRAPHLING_HOME, "/home/graphling");  # project directory
    &init_var(*GRAPHLING, $GRAPHLING_HOME);	    # alias for $GRAPHLING_HOME
    &init_var(*DATA, "${GRAPHLING_HOME}/DATA");     # data directory
    &init_var(*TOOLS, "${GRAPHLING_HOME}/TOOLS");   # external tools directory
    &init_var(*GRAPHLING_TRACE, &FALSE);	    # trace command execution
    if ($GRAPHLING_TRACE) {
	&debug_print(&TL_ALWAYS, "$0 @ARGV\n");
    }
    $default_word_frequency_file = "$DATA/BNC/bnc-wordform.freq";
    $default_relatedness_file = "$DATA/LIN_SIMILARITY/similarity.data";
    &init_var(*word_freq_file, $default_word_frequency_file);

    # Load in WordNet module, overriding it's command-line options for the cache
    # TODO: put in BEGIN statement above
    &init_var(*WNSEARCHDIR, 		# WordNet dictionary directory
	      "$TOOLS/WORDNET-1.7.1/dict");
    my($default_wn_cache) = $DATA;
    if ($WNSEARCHDIR =~ /WORDNET-((\d+\.)+\d+)/) {
	$default_wn_cache = "$DATA/WORDNET/WN$1";
    }
    &assert((-d $default_wn_cache));
    &init_var(*wn_cache_dir, $default_wn_cache);
    require 'wordnet.perl';
    use vars qw/$wn_cache_dir/;

    # Initialize other command-line options
    &init_var(*default_POS, "noun");
    &init_var(*release_mode, (&DEBUG_LEVEL < 3) ? &TRUE : &FALSE);
    &init_var(*reuse, &FALSE);	# quick mode (eg, reuse reprocessed files)
    &init_var(*test, &FALSE);	# test mode (eg, use smaller datasets)

    # Initialize CoCo variables and name-to-index mapping
    &init_coco_labels();

    # Set up defaults for word-sense tags
    $DUMMY_SENSE = "-1";
    $UNTAGGED_SENSE = "";

    return (&TRUE);
}


# init_coco_labels(): Initialize the set of labels used for CoCo variables
# and the mapping from Coco variable names to index numbers
#
# This uses as many valid filename characters for the variable names as possible
# since this is the limiting factor for the maximum number of features.
#
# NOTES:
# - Changes here must match getfmc7.0.c (e.g., add_variable_documentation).
# - Additional variable names can be determined as follows:
#   char-name-files $ perl -e 'for ($c = 32; $c < 256; $c++) { $char=chr($c); system("echo '$char' > 'file_$char'"); if (-e "file_$char") { print $char; } } print "\n";' >| file-chars.list
# 
# TODO:
# - make sure these work under Win32 as well
# - make sure the filenames are quoted by the scripts (eg, so that the shell doesn't interpret '[')
# - Use Latin characters used to extend alphanumeric ones:
#   $ echo `man iso_8859_1 | grep -i letter | cut.perl -fix -f=4`
#   À Á Â Ã Ä Å Æ Ç È É Ê Ë Ì Í Î Ï Ð Ñ Ò Ó Ô Õ Ö Ø Ù Ú Û Ü Ý Þ ß à á â ã ä å æ ç è é ê ë ì í î ï ð ñ ò ó ô õ ö ø ù ú û ü ý þ ÿ
#
#
sub init_coco_labels {
    &debug_print(&TL_DETAILED, "init_coco_labels(@_)\n");

    # Assign as many single-letter labels as possible
    my($coco_var_names) = 
	  "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	. "abcdefghijklmnopqrstuvwxzy"
	. "0123456789"
	. "~-_^%@#\$&{}[]"
	# TODO: add Latin characters (requires patch to Coco see test-dprint.c)
	## . "ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ"
	;
    @coco_var_names = split(//, $coco_var_names);

    # Created hash from label to index (for quick lookup)
    my($coco_var_count) = 0;
    map { $coco_var_index{$_} = $coco_var_count++; } @coco_var_names;

    return (&TRUE);
}


# convert_POS: convert part-of-speech abbreviation to full form
# EX: convert_POS("n") => "noun"
# EX: convert_POS("x") => "unknown"
# TODO: return '' instead of 'unknown' if input is empty???
#
my(%POS_abbrevs);
#
sub convert_POS {
    my($in_POS) = @_;

    # Make sure part-of-speech associations in place
    if (! (scalar %POS_abbrevs)) {
	&init_POS_abbrevs();
    }
    &assert($POS_abbrevs{"n"} eq "noun");

    # Return the full form for the POS label
    return (&get_entry(\%POS_abbrevs, $in_POS, "unknown"));
}


# init_POS_abbrevs(): initialize the hash with part-of-speech abbreviations
# EX: init_POS_abbrevs() => 1
# 
sub init_POS_abbrevs {
    %POS_abbrevs = ("n", "noun",
		    "noun", "noun",
		    "v", "verb",
		    "verb", "verb",
		    "adj", "adjective",
		    "adjective", "adjective",
		    "adv", "adverb",
		    "adverb", "adverb",
		    "p", "preposition",
		    "prep", "preposition",
		    );
    return (&TRUE);
}


# parse_POS(headword_spec)
#
# Parse out the part-of-speech from the headword specification (eg, "v:run").
# The result is returned unabbreviated (eg, "verb"), along with the head.
# EX: parse_POS("v:run") => ("verb", "run")
# EX: parse_POS("shirt") => ("noun", "shirt")
# EX: parse_POS(":Jones") => ("unknown", "Jones")
#
sub parse_POS {
    my($head) = @_;
    my($POS) = $default_POS;

    if ($head =~ /^([^:]*):(.*)/) {
	$POS = defined($1) ? $1 : "";
	$head = $2;
	$POS = &convert_POS($POS);
    }
    &debug_print(&TL_VERY_DETAILED, "parse_POS(@_) => ($POS, $head)\n");

    return (($POS, $head));
}


# parse_sense(word_sense_specification, [default_sense_num=1])
# Parse the word-sense specification into base word and sense number.
# EX: parse_sense("dog#2") => ("dog", 2)
# EX: parse_sense("cat__1") => ("cat", 1)
# NOTE: obsolete function; use parse_sense_spec instead
#
sub parse_sense {
    my($word_sense, $default_sense_num) = @_;
    $default_sense_num = 0 if (!defined($default_sense_num));
    my($word, $sense_num) = ($word_sense, $default_sense_num);

    # If the sense indicator (#) is present, remove it from the word
    # and use the following text as the sense number
    if ($word_sense =~ /_?\#(\S+)/) {
	$word = $`;
	$sense_num = $1;
    }
    # Check alternative format of <word>__<sense> (see see lexrel2network.perl)
    # TODO: use a convention to allow for underscores in sense labels (as in some FrameNet semantic roles)
    elsif ($word_sense =~ /^(\S+)__([^_]+)$/) {
	$word = $1;
	$sense_num = $2;
    }
    # Check for similar format but with just one underscore (<word>_<sense>),
    # where the sense is numeric.
    # TODO: make sure this format is weeded out to avoid inadvertant errors
    elsif ($word_sense =~ /^(\S+)_(\d+)$/) {
	$word = $1;
	$sense_num = $2;
    }
    &debug_print(&TL_VERY_DETAILED, "parse_sense(@_) => ($word, $sense_num)\n");

    return (($word, $sense_num));
}


# get_coco_column_label(column_number)
#
# Get the label for the specified column of the data table for CoCo.
# EX: get_coco_column_label(5) => "F"
#
sub get_coco_column_label {
    my($col) = @_;

    my($label) = $coco_var_names[$col];
    $label = "_" if (!defined($label));
    &debug_print(&TL_MOST_DETAILED, "get_coco_column_label(@_) => $label\n");

    return ($label);
}


# get_coco_column_number(column_label)
#
# Get the number for column with the given label (in the data table for CoCo).
# EX: get_coco_column_number("A") => 0
# EX: get_coco_column_number("Z") => 25
# EX: get_coco_column_number("") => -1
#
sub get_coco_column_number {
    my($label) = @_;

    my($col) = $coco_var_index{$label};
    $col = -1 if (!defined($col));
    &debug_print(&TL_MOST_DETAILED, "get_coco_column_number(@_) => $col\n");

    return ($col);
}


# read_relatedness_data([file, assoc]): Read in the file with word relatedness
# weights
# NOTE: input entries with same head are combined
#
my(%default_relatedness_assoc);
#
sub read_relatedness_data {
    my($file, $hash_ref) = @_;
    $file = $default_relatedness_file unless (defined($file));
    $hash_ref = \%default_relatedness_assoc unless (defined($hash_ref));
    &debug_print(&TL_DETAILED, "read_relatedness_data(@_)\n");
			   
    # Read in the word frequencies
    if (! open(RELATEDNESS, $file)) {
	&warning("Unable to open relatedness data file '$file'\n");
	return;
    }
    while (<RELATEDNESS>) {
        &dump_line("relatedness: $_", &TL_MOST_VERBOSE);
	chomp;
	next if (/^\#/);	# skip comments

	# Get head and list of associated values from input
	my($head, @data) = split(/\t/, $_);

	# Add values from existing hash entry if any
	if (&get_entry($hash_ref, $head, "") ne "") {
	    my($list_ref) = &get_entry($hash_ref, $head);
	    push(@data, @$list_ref);	    
	}

	# Set or update the list of associated values
	&set_entry($hash_ref, $head, \@data);
    }
    close(RELATEDNESS);

    return;
}


# get_related_word_info(word, POS, [assoc]): return list of related words for the
# given word along with the relation strength (<word>:<weight>) 
# NOTE: first checks for 'POS:word' in the hash
#
sub get_related_word_info {
    my($word, $word_POS, $hash_ref) = @_;
    &debug_print(&TL_VERY_DETAILED, "get_related_word_info(@_)\n");
    $hash_ref = \%default_relatedness_assoc unless (defined($hash_ref));

    my($data_ref) = &get_entry($hash_ref, "${word_POS}:${word}", "");
    if ($data_ref eq "") {
	$data_ref = &get_entry($hash_ref, $word, []);
    }

    return (@$data_ref);
}


# init_word_freq([file, assoc]): read frequency data from FILE into hash ASSOC,
# returning number of entries read
# EX: init_word_freq() => 96013632
# TODO: extend test-perl-examples.perl to allow for more flexible tests (e.g., x() > 1000000)
#
my(%default_word_freq_assoc);
#
sub init_word_freq {
    my($file, $hash_ref) = @_;
    $file = $word_freq_file unless (defined($file));
    $hash_ref = \%default_word_freq_assoc unless (defined($hash_ref));
    &debug_print(&TL_DETAILED, "init_word_freq(@_)\n");
			   
    # Read in the word frequencies
    return (&read_frequencies($file, $hash_ref));
}


# get_freq(token, [default, assoc]): return frequency of TOKEN in ASSOC
# return DEFAULT (0) if not defined
#
# EX: get_freq("water") => 35078
# EX: get_freq("fubar") => 0
# EX: get_freq("fubar", -1) => -1
#
sub get_freq {
    my($token, $default, $hash_ref) = @_;
    $default = 0 unless (defined($default));
    $hash_ref = \%default_word_freq_assoc unless (defined($hash_ref));

    &assert(scalar %$hash_ref);
    my($freq) = &get_entry($hash_ref, $token, $default);
    &debug_print(&TL_VERY_DETAILED, "get_freq(@_)\n" => $freq);

    return ($freq);
}

# get_word_freq: alias for get_freq
#
sub get_word_freq {
    return (&get_freq(@_));
}


# init_term_freq(): initialize support for checking word-based frequecies
# of terms in the form <POS>:<WORD>#<SENSE>
#
sub init_term_freq {
    return (&init_word_freq(@_));
}


# term_frequency(hash, word_spec): returns number of times term occured in the corpus.
# NOTE: the term can include part-of-speech and sense indicators which are ignored
# TODO:
# - add support for synset freq
#
sub term_frequency {
    my($hash_ref, $term) = @_;

    # Extract the word (ie., without optional part of speech and sense)
    my($POS, $term_proper, $sense) = &parse_sense_spec($term);

    # Return the word frequency
    my($freq) = &get_entry($hash_ref, $term_proper);
    &debug_out(&TL_VERBOSE, "term_frequency(@_) => $freq\n");

    return ($freq);
}


# get_term_freq(term): get wordform frequency for term
#
sub get_term_freq {
    my($term) = @_;
    &debug_out(&TL_VERY_DETAILED, "get_term_freq(@_)\n");
    return (&term_frequency(\%default_word_freq_assoc, $term));
}


# get_classification_distribution(joint_distribution_file, class_labels_ref, class_probs_ref)
#
# Reads the joint distribution (usually in SAMPLE.DIST) for each instance of
# the classification variable. The result is returned via the label and prob
# array refs. It is returned via a single array with "<label>:<prob>" elements.
#
# Sample input (SAMPLE.DIST for sugar from SensEval1):
#
#   # Fold 0
#   0 7
#   1.70488747503637e-14:1.1 NN NN IN PN n/a 0 1 0 0 0 0 0
#   0.998287039456096:1 NN NN IN PN n/a 0 1 0 0 0 0 0
#   1.02725083957528e-19:0 NN NN IN PN n/a 0 1 0 0 0 0 0
#   3.30699491108441e-13:1a NN NN IN PN n/a 0 1 0 0 0 0 0
#   0.0017129605435454:2 NN NN IN PN n/a 0 1 0 0 0 0 0
#   4.27907149518665e-16:4 NN NN IN PN n/a 0 1 0 0 0 0 0
#   1.03611486304496e-14:3 NN NN IN PN n/a 0 1 0 0 0 0 0
#
# Sample Result:
#   1
#   class_labels_ref = [[1.1, 1, 0, 1a, 2, 4, 3]]
#   class_probs_ref = [[0.998, 0.000, 0.000, 0.002, 0.000, 0.000, 0.000]]
#
# TODO:
# - use structure result rather than modifying the params (for easier EX testing)
# - return a single class-labels list since the same for all cases
#
sub get_classification_distribution {
    &debug_print(&TL_VERBOSE, "get_classification_distribution(@_)\n");
    my($file, $class_labels_ref, $class_probs_ref) = @_;

    # Open the joint distribution file (eg, "SAMPLE.DIST")
    if (!open(JOINT, "<$file")) {
	&error_out("Unable to open joint distribution file '$file' ($!)\n");
	return (0);
    }

    # Determine the number of values for the classification variable
    &assert($/ ne "");
    do {
	$_ = <JOINT>;
	chomp;
	&dump_line("<JOINT>: '$_'\n");
	s/#.*$//;		# ignore comments
    } while (($_ =~ /^\s*$/) && !eof(JOINT));
    my($class_pos, $max_values) = &tokenize($_);
    $class_pos = 0 if (!defined($class_pos));
    $max_values = 0 if (!defined($max_values));
    &debug_print(&TL_VERBOSE, "class_pos=$class_pos max_values=$max_values\n");

    # Read in the distributions
    my($num_sets) = 0;
    while (!eof(JOINT)) {
	my(@class_probs, @class_labels, @dist_spec);
	my($count) = 0;

	# Read in the distribution for the first occurrence
	for (my $i = 0; $i < $max_values; $i++) {
	    # Read probability specification for current classification value
	    &assert(!eof(JOINT));
	    while (!eof(JOINT)) {
		$_ = <JOINT>;
		chomp;
		&dump_line("<JOINT>: '$_'\n");
		s/#.*$//;		# ignore comments
		last if ($_ !~ /^\s*$/);
	    }

	    # Assign the current probability and record its label
	    if ($_ !~ /^\s*$/) {
		my($prob, $features) = split(/:/, $_);
		$class_probs[$i] = $prob;

		# Determine label for the class
		my(@features) = &tokenize($features);
		&assert(defined($features[$class_pos]));
		my($class_label) = $features[$class_pos];
		$class_label = "n/a" if (!defined($class_label));
		$class_labels[$i] = $class_label;

		&debug_print(&TL_VERY_DETAILED, "prob=$prob class=$class_label features=$features\n");
		$dist_spec[$i] = "$class_labels[$i]:$prob";
		$count++;
	    }
	}
	&assert($count == $max_values);
	&debug_print(&TL_DETAILED, "dist_spec_${num_sets}: (@dist_spec)\n");

	$$class_labels_ref[$num_sets] = \@class_labels;
	$$class_probs_ref[$num_sets] = \@class_probs;
	$num_sets++;
    }

    # Close the file
    close(JOINT);
    &debug_out(&TL_VERBOSE, "\tclass_labels_ref=%s\n", stringify($class_labels_ref));
    &debug_out(&TL_VERBOSE, "\tclass_probs_ref=%s\n", stringify($class_probs_ref));
    &debug_print(&TL_VERBOSE, "get_classification_distribution(@_) => $num_sets\n");

    return ($num_sets);
}


# get_classification_distribution(joint_distribution_file, class_labels_ref, class_probs_ref)
#
# Read in the J4.8 predictions from Weka's output file, returning only a
# probability for the selected item. The result is returned via the label and
# prob array refs. The number of cases is returned as the function result.
#
# Sample input (DECISION-TREE/table0.train-test.j48.result):
#
#   J48 pruned tree
#   ------------------
#   
#   F1 = up: PATH (523.0/127.0)
#   F1 = unto: GOAL (2.0/1.0)
#   F1 = either
#   |   F52 = 0: CAUSE (2.0/1.0)
#   |   F52 = 1: GOAL (2.0)
#   F1 = low: SOURCE (3.0/2.0)
#   F1 = Sex: CAT (1.0)
#   ...
#   
#   === Predictions ===
#   0 THME 1.0 -1
#   1 THME 0.44886363636363635 -1
#   2 THME 0.44886363636363635 -1
#   3 SOURCE 0.7204968944099379 -1
#   4 CAT 1.0 -1
#   5 AGNT 0.6724137931034483 -1
#   6 AGNT 0.6724137931034483 -1
#   ...
#   178 THME 1.0 -1
#   179 RCPT 1.0 -1
#   180 CHRC 1.0 -1
#   
# Sample Result:
#   181
#   class_labels_ref = [[THME], ..., [CHRC]]
#   class_probs_ref = [[1.0], ... [1.0]]
#
# TODO:
# - Assign non-zero probabilities to non-selected classes.
#
sub get_j48_classification_distribution {
    &debug_print(&TL_VERBOSE, "get_j48_classification_distribution(@_)\n");
    my($file, $class_labels_ref, $class_probs_ref) = @_;

    # Open the joint distribution file (eg, "SAMPLE.DIST")
    if (!open(J48, "<$file")) {
	&error_out("Unable to open J4.8 classifier results '$file' ($!)\n");
	return (0);
    }

    # Read in the predictions
    my($num_sets) = 0;
    my($prediction_section) = &FALSE;
    while (<J48>) {
	&dump_line("<J48>: '$_'\n");
	my(@class_probs, @class_labels);
	my($count) = 0;

	# Check for start of the predictions section
	if (/=== Predictions ===/) {
	    $prediction_section = &TRUE;
	    next;
	}
	next if (! $prediction_section);

	# Extract the selected class and it's probability
	# example: 56 CAT 0.9008810572687225 -1
	if (/^\d+ (\S+) (\S+) \S+\s*$/) {
	    &debug_print(&TL_VERY_DETAILED, "prob=$2 class=$1\n");
	    $class_labels[0] = $1;
	    $class_probs[0] = $2;


	    $$class_labels_ref[$num_sets] = \@class_labels;
	    $$class_probs_ref[$num_sets] = \@class_probs;
	    $num_sets++;
	}
    }

    # Close the file
    close(J48);
    &debug_out(&TL_VERBOSE, "\tclass_labels_ref=%s\n", stringify($class_labels_ref));
    &debug_out(&TL_VERBOSE, "\tclass_probs_ref=%s\n", stringify($class_probs_ref));
    &debug_print(&TL_VERBOSE, "get_j48_classification_distribution(@_) => $num_sets\n");

    return ($num_sets);
}


# parse_relationship(relationship_spec): Return the components of the relational
# tuple, which has the following format:#	'<' source-term ',' relation-type  ',' target-term '>' [':' relation-weight]
# EX: parse_relationship("<2. n:artifact, 3. v:is, 6. n:object>: 0.25") => ("2. n:artifact", "3. v:is", "6. n:object", 0.25)
#
sub parse_relationship {
    my($relationship_spec) = @_;
    my($source, $relation, $target, $weight) = ("", "", "", 1.0);

    if ($relationship_spec =~  /<([^,]+),\s*([^,]+),\s*([^,]+)>(:\s*(\S+))?/) {
	# $n's:                  1          2          3       4    5
	($source, $relation, $target, $weight) = ($1, $2, $3, $5);
	$weight = 1.0 if (!defined($weight));
    }
    &debug_print(&TL_VERBOSE, "parse_relationship(@_) => ($source, $relation, $target, $weight)\n");

    return ($source, $relation, $target, $weight);
}


# format_relationship(source, relation, target, [weight]): format the components of the
# relationship using the tuple notation
#	'<' source-term ',' relation-type  ',' target-term '>' [':' relation-weight]
# EX: format_relationship("2. n:artifact", "3. v:is", "6. n:object", 0.25) => "<2. n:artifact, 3. v:is, 6. n:object>: 0.25"
#
sub format_relationship {
    my($source, $relation, $target, $weight) = @_;

    $weight = 1.0 if (!defined($weight));
    my($relationship) = "<$source, $relation, $target>: $weight";
    &debug_print(&TL_VERY_DETAILED, "format_relationship(@_) => \"$relationship\"\n");

    return ($relationship);
}


# parse_word_spec(word_spec): parses the word specification into offset, part
# of speech, and word proper components.
#
# EX: parse_word_spec("1. n:artifact") => (0, "noun", "artifact")
# EX: parse_word_spec("5. a") => (4, "", "a")
# EX: parse_word_spec("mod-5-6") => (-1, "", "mod-5-6")
# NOTE: an offset of -1 is used if none is given
# TODO: return 'unknown' instead of ''???
#
sub parse_word_spec {
    my($word_spec) = @_;
    my($offset) = -1;
    my($POS) = "";
    my($word) = "";

    if ($word_spec =~ /((\d+).\s*)?(([^:]+):)?([^:]+)/i) {
	#              12          34       5
	($offset, $POS, $word) = ($2, $4, $5);
	$POS = "" if (!defined($POS));
	if (!defined($offset)) {
	    $offset = -1;
	}
	else {
	    $offset -= 1;		# convert to 0-based offset
	}
	$POS = &convert_POS($POS) unless ($POS eq "");
    }
    &debug_print(&TL_VERBOSE, "parse_word_spec(@_) => ($offset, $POS, $word)\n");

    return ($offset, $POS, $word);
}


# parse_sense_spec(sense_spec): parses the word-sense specification into part of
# speech, word proper, and sense components
# NOTE:
# - A sense # of UNTAGGED_SENSE is used if none specified.
#
# EX: parse_sense_spec("n:artifact#1") => ("noun", "artifact", 1)
# EX: parse_sense_spec("run#3") => ("", "run", 3)
# EX: parse_sense_spec("by#MNR") => ("", "by", "MNR")
# EX: parse_sense_spec("(something") => ("", "(something", "")
#
# TODO:
# - reconcile with sense-spec parsing in lexrel2network.perl and tuple2lexrex.perl
# - return 'unknown' instead of ''???
#
sub parse_sense_spec {
    my($sense_spec) = @_;
    my($POS) = "";
    my($word) = $sense_spec;
    my($sense) = $UNTAGGED_SENSE;

    if ($sense_spec =~ /^\s*(([^:]+):)?([^\#]+)(\#([^\#]+))?\s*$/) {
	# $n's:             12         3       4  5
	($POS, $word, $sense) = ($2, $3, $5);
	$POS = "" if (!defined($POS));
	$sense = $UNTAGGED_SENSE if (!defined($sense));
    }
    $POS = &convert_POS($POS) unless ($POS eq "");
    &debug_print(&TL_VERBOSE, "parse_sense_spec(@_) => ($POS, $word, $sense)\n");

    return ($POS, $word, $sense);
}


# format_sense_spec(POS, word, sense): create sense specification given the word,
# part of speech, and sense number
# EX: format_sense_spec("noun", "beagle", 1) => "noun:beagle#1"
# EX: format_sense_spec("", "cup", 3) => "cup#3"
#
sub format_sense_spec {
    my($POS, $word, $sense) = @_;

    my($sense_spec) = "";
    $sense_spec .= "${POS}:" if ($POS ne "");
    $sense_spec .= $word;
    $sense_spec .= "\#${sense}" if ($sense ne "");
    &debug_print(&TL_VERY_DETAILED, "format_sense_spec(@_) => \"$sense_spec\"\n");

    return ($sense_spec);
}


# preparse_sgml_text(): preprocess the text by isolating punctuation, except
# when within SGML tags. Performs special handling for contractions, numbers,
# and abbreviations.
#
# EX: preparse_sgml_text("pagan's worship <wf sense=4>gods</wf>") => "pagan 's worship <wf sense=4>gods</wf>"
#
sub preparse_sgml_text {
    my($text) = @_;
    my($new_text) = "";

    # Convert each run of non-sgml text (i.e., non-tags)
    while ($text =~ /<[^<>]+>/) {
	my($pre) = $`;
	my($tagging) = $&;
	$text = $';

	# Convert text before tag element and add latter as is
	$new_text .= &preparse_text($pre) . $tagging;
    }
    
    # Convert the rest of the text
    $new_text .= &preparse_text($text);
    
    &debug_print(&TL_DETAILED, "preparse_sgml_text(@_)\n" => $text);
    return ($new_text);
}


# preparse_text(): preprocess all text from input by isolating punctuation,
# except for cases involving possessives, abbreviations, etc.
#
# EX: preparse_text("effect: (of a law) having legal validity;") => "effect : ( of a law ) having legal validity ; "
# EX: preparse_text("bestow, esp. officially") => "bestow , esp . officially"
# EX: preparse_text("U.S.A.") => "U.S.A."
# EX: preparse_text("Dr. Wiebe") => "Dr . Wiebe"
#
sub preparse_text {
    &debug_print(&TL_VERBOSE, "preparse_text(@_)\n");
    my($text) = @_;

    # Put space around punctuation (excluding '-' and '_')
    # TODO: reconcile with isolate_punctuation
    ## $text =~ s/([\(\)\:\;,\.\?\@\#\'\"\$\{\}\<\>\/\\\=\+])/ $1 /g;
    $text =~ s/([\~\!\@\#\$\%\^\&\*\(\)\+\`\=\{\}\|\[\]\\\:\"\;\'\<\>\?\,\.\/])/ $1 /g;
    $text = &normalize_preparse_text($text);

    &debug_print(&TL_DETAILED, "preparse_text(@_) => $text");
    return ($text);
}


# normalize_preparse_text(text): normalize the text that has been preprocessed
# to restore certain possessives, abbreviations and other special cases
# involving punctuation
#
# EX: normalize_preparse_text("variable ' s effect") => "variable 's effect"
# EX: normalize_preparse_text("tom's car") => "tom's car"
#
# TODO: restore times (e.g., "10 : 15 pm" => "10:15 pm")
#
sub normalize_preparse_text {
    my($text) = @_;

    # Restore "n't", "'s", "'m", "'d", and "'ve" 
    $text =~ s/n \' t(\W)/n\'t $1/g;
    $text =~ s/\' ve(\W)/\'ve $1/g;
    $text =~ s/\' s(\W)/\'s $1/g;
    $text =~ s/\' m(\W)/\'m $1/g;
    $text =~ s/\' d(\W)/\'d $1/g;

    # Restore numbers
    while ($text =~ /\b(\d+ +[\.\,] +)+\d+\b/) {
	$text = $` . &remove_whitespace($&) . $';
    }

    # Restore abbreviations
    # NOTE: only accounts for single letter abbreviations like U.S.A
    # TODO: simplify regex wrt ^|\b and \b|$
    while ($text =~ /(^|\b)(\w +\. +)+\w +\. +(\b|$)/) {
	$text = $` . &remove_whitespace($&);
	if ($' ne "") {
	    $text .= " " . $';
	}
    }

    # Collapse multiple spaces into single space
    # NOTE: this removes extraneous spaces introduced during conversion
    $text =~ s/  +/ /g;

    &debug_print(&TL_VERBOSE, "normalize_preparse_text(@_) => $text\n");
    return ($text);
}


# remove_whitespace(text): remove all whitespace from the text
# EX: remove_whitespace("from the text") => "fromthetext"
# TODO: fix problem with @_ modification
#
sub remove_whitespace {
    my($text) = @_;
    $text =~ s/\s+//g;

    &debug_print(&TL_VERY_VERBOSE, "remove_whitespace(@_) => $text\n");
    return ($text);
}


#------------------------------------------------------------------------------

# Tell Perl we loaded OK
&init_graphling();
1;
