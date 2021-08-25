# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/bin/perl -sw
#
# paste.perl: Utility similar to Unix paste command for joining columns.
# This has the additional option of combining columns based on a key value,
# which allows for combining columns with gaps.
#
# TODO:
# - Have option to skip cases with undefined entries (i.e., no intersection).
# - Have option to just use one of the files as the source of the keys:
#   ex: $ paste.perl -keys my-good-wikipedia-categories.list en-categories-article.freq | grep -v n/a | cut -f1,3 >| my-good-wikipedia-categories.freq
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = $0; $dir =~ s/[^\\\/]*$//; unshift(@INC, $dir);
    require 'common.perl';
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
use vars qw/$keys $filter $comments $default $preserve $i $fold_case $preserve_order 
            $preserve_case $labels $undefined $delimiter/;

&init_var(*keys, &FALSE);		# column 1 specifies keys of lines to be joined
&init_var(*filter, "");			# pattern for lines to skip
&init_var(*comments, &FALSE);		# include comments in the result
&init_var(*default, "n/a");		# default value for the rows
&init_var(*preserve, &FALSE);		# preserve both case and key order (from input)
&init_var(*i, &FALSE);			# alias for -fold_case
&init_var(*fold_case, $i);		# convert keys to lowercases
&init_var(*preserve_order, $preserve);
&init_var(*preserve_case,  		# maintain the case of keys
	  ($preserve || (! $fold_case)));
&init_var(*labels, "");			# labels for the column headers
&init_var(*undefined, "");		# value to use for undefined data
&init_var(*delimiter, "\t");		# column delimiter

if (!defined($ARGV[0])) {
    my($options) = "options = [-keys] [-labels=list] [-filter=\"pattern\"] [-default=value] [-fold_case] [-preserve] [-preserve_order]";
    my($example) = "examples:\n\n$script_name -keys eval_061798.report eval_061898.report\n\n";
    ## $example .= "$script_name -keys manufacturing.list construction.list | perl -pe \"s/^([^\\t]+)\\t(.*)/\\2\\t\\1/;\" >| combined.list\n";

    $example .= "$script_name -keys senseval2-all-ci-hyper-eval-040604.report senseval2-both-all-both-eval-040104.report\n";

    die "\nusage: $script_name [options] file1 file2 ...\n\n$options\n\n$example\n\n";
}

my(%all_keys);
my(@ordered_keys);
my($num_cols) = (1 + $#ARGV);
my($max_row) = 0;
my($i);
my(@labels) = ($labels ne "") ? &tokenize($labels) : @ARGV;
my(@col_arrays);

# Read in all the files into separate column arrays
# For keys, these are %col_0, %col_1, ..., otherwise @col_0, @col_1, ....
#
for ($i = 0; $i < $num_cols; $i++) {
    $col_arrays[$i] = ($keys ? {} : []);
    my($num) = &read_columns($ARGV[$i], $col_arrays[$i]);
    $max_row = &max($max_row, $num);
}

# Print the columns row by row. If by key, then the first column is the
# key and a column entry is printed if it corresponds to the key.
# 
#
if ($keys) {
    &print_columns_by_key();
}
else {
    &print_columns_by_row();
}

#------------------------------------------------------------------------------

# read_columns(file_name, column_array_ref)
#
# Read the data in the file and store into the column array. If by-key, then
# the data is assumed to be in two columns with the first providing the key
# and the second the value for the entry column_array<key>. Otherwise,
# the line is stored as colum_array[row].
#
# Returns the number of rows read.
#
sub read_columns {
    my($file, $col_array) = @_;
    &debug_print(4, "read_columns(@_)\n");
    my($num) = 0;

    if (!open(FILE, "<$file")) {
	&exit("Unable to read file $file ($!)\n");
	return;
    }
    if ($utf8) {
	# TODO: use open_file wrapper so binmode can be done automatically
	binmode(FILE, ":utf8");
    }
    while (<FILE>) {
	&dump_line();
	chop;
	$num++;
	next if ((! $comments) && /^\#/);

	# Skip the line if it matches the filter
	if (($filter ne "") && ($_ !~ /$filter/)) {
	    &debug_print(5, "filtering out data: $_\n");
	    next;
	}

	# Add the data to the appropriate array
	if ($keys) {
	    my($key, $data) = ($_ =~ /^([^$delimiter]*)$delimiter(.*)/);
	    $key = $_ if (!defined($key));
	    $key = &to_lower($key) unless ($preserve_case);
	    $data = $undefined if (!defined($data));
	    # make sure extraneous delimiters not included in key
	    &assert(index($key, $delimiter) == -1);
	    $data =~ s/$delimiter/, /g;		# make sure no tabs in data
	    &debug_print(&TL_VERY_VERBOSE, "k='$key' d='$data'\n");
	    if ($preserve_order) {
		push(@ordered_keys, $key) unless defined($all_keys{$key});
	    }
	    $all_keys{$key} = &TRUE;
	    $$col_array{$key} = $data;
	}
	else {
	    my($data) = $_;
	    push(@$col_array, $data);
	}
    }
    close(FILE);

    return ($num);
}


# Print the columns in order corresponding to the sorted list of keys.
# The data for the column entries is in %col_0, %col_1, ....
# globals: %all_keys, @labels
#
sub print_columns_by_key {
    &debug_print(4, "print_columns_by_key(@_)\n");
    my(@keys) = ($preserve_order ? @ordered_keys : sort(keys(%all_keys)));
    my($r, $c);

    
    # Print a comment giving the source of each column
    printf "# key";
    for ($c = 0; $c < $num_cols; $c++) {
	printf "\t%s", defined($labels[$c]) ? $labels[$c] : "?";
    }
    printf "\n";

    # Print the data saved for each key
    for ($r = 0; $r <= $#keys; $r++) {
	printf "%s", $keys[$r];
	for ($c = 0; $c < $num_cols; $c++) {
	    my($col_array) = $col_arrays[$c];
	    printf "\t%s", &get_entry($col_array, $keys[$r], $default);
	}
	printf "\n";
    }	    

    return;
}


# Print the columns in row order.
# The data for the column entries is in @col_0, @col_1, ....
#
sub print_columns_by_row {
    &debug_print(4, "print_columns_by_row(@_)\n");
    my($r, $c);

    for ($r = 0; $r < $max_row; $r++) {
	for ($c = 0; $c < $num_cols; $c++) {
	    my($col_array) = $col_arrays[$c];

	    printf "\t" if ($c > 0);
	    printf "%s", $$col_array[$r] unless (!defined($$col_array[$r]));
	}
	printf "\n";
    }	    

    return;
}
