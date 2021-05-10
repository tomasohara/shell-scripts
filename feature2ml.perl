# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/bin/perl -sw
#
# feature2ml.perl: convert from tab-delimited feature specification to format
# used in the ML repository  (c4.5-based). Alternatively, the format used
# by Weka is also supported.
#
# NOTE:
# - Keep changes to options synchronized with client scripts like run-weka.sh.
#
# Sample input (UCI Zoo dataset with spaces here instead of tabs):
#     animal    hair    feathers eggs   milk    airborne aquatic predators toothed backbone breathes venomous  fins    legs    tail    domest  catsize type
#     aardvark  1       0       0       1       0        0       1         1       1       1         0         0       4       0       0       1       1
#     antelope  1       0       0       1       0        0       0         1       1       1         0         0       4       1       0       1       1
#     bass      0       0       1       0       0        1       1         1       1       0         0         1       0       1       0       0       4
#
# TODO:
# - Use process_input_files (see extract_cooccuring_forts.perl).
# - Add brief documentation on the support formats (e.g., c45 & weka).
# - Use more flexible attribute quoting scheme (eg single or double quotes).
# - Have option to store the feature data in a file if too big for memory.
# - Parameterize output_xyz_description routines to eliminate use of globals.
# - Add support for SVM-Light.
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir);
    require 'common.perl';
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
no strict "refs";		# allow for symbolic file handles
use vars qw/$arff $weka $c45 $dataset $nolabels $labels $first $last
    $class_pos $csv $stdout $lin $enumerated_value_labels $generic_value_labels/;


# Parse the command-line arguments
if (!defined($ARGV[0])) {
    my($options) = "options = [-nolabels] [-class_pos] [-first] [-dataset=name] [-preserve]  [-c45 | -arff | -lin] [-csv] [-stdout] [-enumerated_value_labels | -generic_value_labels]";

    my($example) = "Examples:\n\n$script_name compoundString < compoundString.table\n\n";
    ## OLD: $example .= "$0 -d=5 test_english.table\n\n";
    ## OLD: $example .= "$0 multiword.position.table\n\n";
    $example .= "$0 -first -weka ai-restaurant-example.features\n";
    $example .= "less ai-restaurant-example.arff\n\n";
    $example .= "foreach.perl -trace '$0 \$f' *.features >| feature2ml.log 2>&1\n\n";

    my($note) = "Notes:\n\nFor c4.5, creates <dataset_name>.names and <dataset_name>.data\n";
    $note .= "For Weka, creates <dataset_name>..arff file created.\n";
    $note .= "Use -stdout, to send to standard output instead.\n";
    $note .= "The -lin option is for Dekang Lin's maxent utility, see\n";
    $note .= "    http://webdocs.cs.ualberta.ca/~lindek/maxent.tgz\n";
    $note .= "\n";

    print STDERR "\nusage: $script_name [options] dataset_file\n\n$options\n\n$example\n$note";
    &exit();
}

# Check command-line options
&init_var(*arff, &FALSE);	# alias for -weka
&init_var(*weka, $arff);	# use Weka's .arff format
&init_var(*lin, &FALSE);	# use format for Dekang Lin's maxent utility
# TODO: make Weka the default format.
&init_var(*c45, ! ($weka || $lin)); # use C4.5 .names/.data format
&init_var(*dataset, "");	# name of dataset
&init_var(*nolabels, &FALSE);	# no labels in data file
&init_var(*labels, "");		# labels for the features
&init_var(*first, &FALSE);	# class value given first
&init_var(*last, &FALSE);	# class value given last (the default case)
&assert(! ($first && $last));
&init_var(*class_pos, 		# 0-based position of classificaton variable
	  ($first ? 0 : -1));	
my($final_class_pos) = -1;
&init_var(*csv, &FALSE);	# input data is in comma-separated value format
&init_var(*stdout, $weka);	# use standard output instead of separate output file
my($delim_regex) = ($csv ? ",\\s+" : "\t");
my($comma_delim) = ", ";	# for internal feature string vector
&init_var(*generic_value_labels, &FALSE); # use values like Fij rather than feature[i]=value[i,j]
&init_var(*enumerated_value_labels, &FALSE); # variant with all feature values mapped to integer

# Derive the dataset name from the file if not given
if ($dataset eq "") {
    $dataset = $ARGV[0];
    if ($dataset =~ /^(.*)\.(table|features?)$/) {
	# Use the basename of the table file as the dataset name
	$dataset = $1;
    }
}
&debug_print(&TL_DETAILED, "dataset=$dataset\n");

# Globals describing the feature data
our(@labels);			# feature labels including classification variable
our($num_features) = 0;		# number of features
our(@value_hashes);		# array of hashes each from feature_value -> value_freq (or value_pos for -enumerated_value_labels)
our(@feature_data);		# original feature specification (i.e., array of string vectors)

# Extract the feature values for each training instance, making note of the
# values that occur for each feature variable.
#
my($count) = 0;
READ_DATA:
while (<>) {
    &dump_line();
    chomp;

    # Ignore comments and blank lines
    # Note: comments must start with ';' in first column and not be followed 
    # by a tab (eg, ';<TAB><COL2>' might be part of a feature spec). They
    # can also start with '#' in first column.
    s/\r//;
    s/^;[^\t].*//;
    s/^#.*//;
    next if (/^\s*$/);		

    # Extract features
    my(@features) = split(/$delim_regex/, $_);
    $count++;
    if ($class_pos < 0) {
	$class_pos = $#features;
	&debug_print(&TL_VERBOSE, "class_pos: $class_pos\n");
    }
    if ($final_class_pos < 0) {
    	$final_class_pos = ($lin ? 0 : $#features);
	&debug_print(&TL_VERBOSE, "final_class_pos: $final_class_pos\n");
    }

    # Reorganize the feature values, so that the class value occurs last (or first for -lin)
    if ($lin && ($class_pos != 0)) {
	my($class_value) = $features[$class_pos];
	splice(@features, $class_pos, 1);
	unshift(@features, $class_value);
    }
    elsif ($class_pos != $#features) {
	my($class_value) = $features[$class_pos];
	splice(@features, $class_pos, 1);
	push(@features, $class_value);
    }

    # Assign the labels if first line
    if ($count == 1) {
	# Usually, the first row specifies the feature labels
	if ($nolabels == &FALSE) {
	    &init_features(@features);
	    next;
	}
	# If not, use the labels specified on command-line (or a generic "Fn" label)
	else {
	    my(@temp_labels) = &tokenize($labels);
	    for (my $i = 0; $i <= $#features; $i++) {
		$temp_labels[$i] = sprintf "F%d", $i unless defined($temp_labels[$i]);
	    }
	    &init_features(@temp_labels);
	}
    }

    # Make note of the feature values used
    # TODO: account for embedded single quotes
    for (my $i = 0; $i < $num_features; $i++) {
	if (!defined($features[$i])) {
	    &error("Incomplete feature set at line $. (i=$i): $_\n");
	    next READ_DATA;
	}

	# Quote features that contain spaces or punctuation
	# NOTE: single quotes are converted to double quotes
	$features[$i] =~ s/\'/\"/g;
	$features[$i] = "\'" . $features[$i] . "\'" if ($features[$i] !~ /^\w+$/);

	&add_feature_value($i, $features[$i]);
    }

    # Add the feature values to the accumulated data 
    # TODO: just store the array of features instead of a string list
    my($data_spec) = join($comma_delim, @features);
    push(@feature_data, $data_spec);
}

# Prepare output data file(s)
#
if ($weka) {
    &output_arff_description();
}
elsif ($c45) {
    &output_c45_description();
}
elsif ($lin) {
    &output_lin_description();
}
else {
    &error("ERROR: one of -c45, -weka, or -lin must be specified\n");
}


&exit();

#------------------------------------------------------------------------

# init_features(label_array_ref)
#
# Initialize the anonymous associative arrays in @values_hashes used
# for storing the values encountered for each feature.
#
sub init_features {
    my(@features) = @_;
    debug_print(5, "init_features(@_)\n");

    @labels = @features;
    $num_features = (1 + $#labels);
    ## @value_hashes = ({ }) x $num_features;
    for (my $i = 0; $i < $num_features; $i++) {
	$value_hashes[$i] = { };
    }
    &trace_array(\@value_hashes);
}

# add_feature_value(feature_pos, value)
#
# Add the value to the table of values for the feature. This uses the
# anonymous associative arrays stored in @value_hashes.
# Note: By default, the associative array value is the feature value frequency but is unused.
# But, for the -enumerated_value_labels option, it is the 0-based insertion-order position
# (used in output_lin_description below).
#
sub add_feature_value {
    my($pos, $value) = @_;
    &debug_print(6, "add_feature_value(@_)\n");

    my($hash_ref) = $value_hashes[$pos];
    if ($enumerated_value_labels) {
	my($position) = &get_entry($hash_ref, $value, -1);
	if ($position == -1) {
	    ## BAD: my($num_values) = (scalar %$hash_ref);
	    my($num_values) = (scalar keys(%$hash_ref));
	    &debug_print(&TL_VERY_DETAILED, "Position $num_values for value $value of feature $pos\n");
	    &set_entry($hash_ref, $value, $num_values);
	}
    }
    else {
	&incr_entry($hash_ref, $value);
    }
}

# get_feature_values(feature_pos)
#
# Return a list of the values that occured for the feature. Again,
# this uses the anonymous associative arrays stored in @value_hashes.
#
sub get_feature_values {
    my($pos) = @_;
    &debug_print(6, "get_feature_values(@_)\n");
    my(@values);

    my($hash_ref) = $value_hashes[$pos];
    if (defined($hash_ref)) {
	@values = keys(%$hash_ref);
    }

    return (@values);
}

# get_feature_value_pos(feature_pos, value)
#
# Returns position of feature in the hash for the given feature (or -1 if not applicable).
# Note: this only applies when -enumerated_value_labels in effect.
#
sub get_feature_value_pos {
    my($feature_pos, $value) = @_;
    &debug_print(6, "get_feature_value_pos(@_)\n");
    &assert($enumerated_value_labels);
    my($hash_ref) = $value_hashes[$feature_pos];
    return (&get_entry($hash_ref, $value, -1));
}

# output_c45_description(): produces .names and .data file for C4.5
# TODO: add support for creating a .test file as well
#
sub output_c45_description {
    &debug_print(4, "output_c45_description(@_)\n");    

    # Prepare the feature description file (<dataset>.names)
    #
    my($description) = "";
    $description .= sprintf "%s.\n", join(",", &get_feature_values($final_class_pos));
    for (my $i = 0; $i < $num_features; $i++) {
	if ($i != $final_class_pos) {
	    $description .= sprintf "%s: %s.\n", 
	    $labels[$i], join($comma_delim, &get_feature_values($i));
	}
    }
    &write_file("$dataset.names", $description);

    # Output the data file (<dataset>.data)
    #
    ## my($data) = join("\n", @feature_data) . "\n";
    ## &write_file("$dataset.data", $data);
    # TODO: prepare a variant of write_file that takes a reference to the
    # lines for efficiency
    #
    open(DATA, ">$dataset.data") or
	die ("Unable to create data file $dataset.data ($!)\n");
    map { print DATA "$_.\n"; } @feature_data;
    close(DATA);

    # Print notification to standard output of files created
    print "Output created in C4.5 format:\n";
    print "$dataset.names describes the features\n";
    print "$dataset.data contains the data\n";
}


# output_arff_description(): produces .arff file for Weka. This is a custom CSV representation with
# features specified at the top via @attribute lines.
#
sub output_arff_description {
    &debug_print(4, "output_arff_description(@_)\n");    

    # Output the data file (<dataset>.arff)
    if (! $stdout) {
	open(ARFF, ">$dataset.arff") or
	    die ("Unable to create Weka data file $dataset.arff ($!)\n");
    }
    ## BAD: my $handle = eval ($stdout ? "STDOUT" : "ARFF");
    my $handle = ($stdout ? "STDOUT" : "ARFF");
    &debug_print(&TL_DETAILED, "handle=$handle\n");
    print $handle "\@relation $dataset\n";

    # Output the attribute specification
    for (my $i = 0; $i < $num_features; $i++) {
	if ($i != $final_class_pos) {
	    printf $handle "\@attribute %s { %s }\n", $labels[$i], join($comma_delim, &get_feature_values($i));
	}
    }
    printf $handle "\@attribute class { %s }\n", join($comma_delim, &get_feature_values($final_class_pos));

    # Output the data points
    print $handle "\@data\n";
    map { print $handle "$_\n"; } @feature_data;
    if (! $stdout) {
	close(ARFF);
 
	print "Output created in Weka ARFF format:\n";
	print "$dataset.arff contains the data and also the feature specification\n";
    }
}


# output_lin_description(): produces .all file for Dekang Lin's maxent utility. This is a space
# delimited represention, in which feature values must be unique. There is a separate model
# file using the following format:
#     <exponential_prior> <GIS_threshold> <max_iterations>
#     <num_classses> <class1> ... <classN>
#
# Example output (with spaces in place of tabs):
#  [zoo.model]
#     0.1 0 5
#     7 c1 c2 c3 c4 c5 c6 c7
#  [zoo.data]
#     c1 f2_1 f3_0 f4_0 f5_1 f6_0 f7_0 f8_1 f9_1 f10_1 f11_1 f12_0 f13_0 f14_4 f15_0 f16_0 f17_1
#     c1 f2_1 f3_0 f4_0 f5_1 f6_0 f7_0 f8_0 f9_1 f10_1 f11_1 f12_0 f13_0 f14_4 f15_1 f16_0 f17_1
#     c4 f2_0 f3_0 f4_1 f5_0 f6_0 f7_1 f8_1 f9_1 f10_1 f11_0 f12_0 f13_1 f14_0 f15_1 f16_0 f17_0
#
sub output_lin_description {
    &debug_print(4, "output_lin_description(@_)\n");    

    # Get values for classification variable
    my(@class_values) = sort(&get_feature_values($final_class_pos));
    my($num_classes) = (scalar @class_values);

    # Convert class values into label=value format
    my(@mapped_class_values);
    my($class_label) = $labels[$final_class_pos];
    for (my $c = 0; $c < $num_classes; $c++) {
	my($class_value) = $class_values[$c];
	if ($enumerated_value_labels) {
	    ## TODO: my($class_value_pos) = &get_feature_value_pos($c, $class_value);
	    $mapped_class_values[$c] = ("c" . ($c + 1));
	}
	elsif ($generic_value_labels) {
	    $mapped_class_values[$c] = "c_" . $class_value;
	}
	else {
	    $mapped_class_values[$c] = "$class_label=$class_value";
	}
    }

    # Output the model file (<dataset>.model)
    # TODO: have options to specify prior, threshold and iterations
    my($model_spec) = "0.1\t0.01\t100\n";
    $model_spec .= "$num_classes\t" . join("\t", @mapped_class_values) . "\n";
    &write_file("$dataset.model", $model_spec);

    # Output the data file (<dataset>.data)
    open(DATA, ">$dataset.data") or
	die ("Unable to create data file $dataset.data ($!)\n");
    for (my $row = 0; $row <= $#feature_data; $row++) {
	my(@feature_values) = split($comma_delim, $feature_data[$row]);
	for (my $f = 0; $f < $num_features; $f++) {
	    my($feature_label) = $labels[$f];
	    my($feature_value) = $feature_values[$f];
	    my($feature_value_spec) = "";
	    if ($enumerated_value_labels) {
		my($feature_value_pos) = &get_feature_value_pos($f, $feature_value);
		$feature_value_spec = "f" . ($f + 1) . "_" . $feature_value_pos;
		if ($f == $final_class_pos) {
		    $feature_value_spec = "c" . (1 + $feature_value_pos);
		}
	    }
	    elsif ($generic_value_labels) {
		$feature_value_spec = "f" . ($f + 1) . "_" . $feature_value;
		if ($f == $final_class_pos) {
		    $feature_value_spec = "c_" . $feature_value;
		}
	    }
	    else {
		$feature_value_spec = "$feature_label=$feature_value";
	    }	    
	    print DATA "\t" unless ($f == 0);
	    print DATA $feature_value_spec;
	}
	print DATA "\n";
    }
    close(DATA);

    # Print notification to standard output of files created
    print "Output created in format for Dekang Lin's maxent:\n";
    print "$dataset.model describes the classification\n";
    print "$dataset.data contains the data\n";
}
