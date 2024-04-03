# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# convert_sense_IDs.perl: convert the sense ID's in the text
#
# NOTE:
#
# Two formats of input are supported: straight text with the sense
# indicators given using the #-notation and tabular text with the
# word and sense given in adjacent columns.
#
# Special processing is done for tabular text to ensure that values
# are distributed properly. This accounts for one-to-many mappings,
# as well as one-to-one mappings. It doesn't account for many-to-one
# mappings, which can be handled by running tally.perl afterwards.
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

if ((defined($ARGV[0]) && ($ARGV[0] eq "help"))
    || (!defined($ARGV[0]) && &blocking_stdin())) {
    $options = "options = [-mapping_file=file] [-plain_text] [-revert] [-uniform]";
    $example = "ex: $script_name whatever\n";

    printf STDERR "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
    &exit();
}

&init_var(*mapping_file, "sense_mapping.data");
&init_var(*plain_text, &FALSE);
&init_var(*revert, &FALSE);
&init_var(*uniform, &FALSE);
## &init_var(*separate_sense, &FALSE);

%sense_mapping = ();
&read_sense_mapping(*sense_mapping, $mapping_file);

*convert_entries = $plain_text ? *convert_sense_entries : *convert_tabular_sense_entries;


while (<>) {
    &dump_line();
    chop;

    # Replace all occurences of [<POS>:]<word>#<sense> with the sense
    # distinction found in the mapping file. Note that the word might
    # be remapped as well. Likewise for the first occurrence of
    # [<POS>:]<word><TAB><sense> in the case of tabular input.
    #
    printf "%s\n", &convert_entries($_);
}

&cleanup_common();

#------------------------------------------------------------------------------

# read_sense_mapping(assoc_array, file)
#
# Read the sense mappings from the file into the associative array.
#
sub read_sense_mapping {
    local (*sense_mapping, $file) = @_;
    &debug_out(4, "read_sense_mapping(@_)\n");

    if (!open(SENSE_MAPPING, "<$file")) {
	&error_out("Unable to open sense mapping file '$file' ($!)\n");
	return;
    }
    while (<SENSE_MAPPING>) {
	&debug_out(7, "map $.: $_");
	chop;
	next if (/^\s*$/ || /^\s*\#/);

	local($entry, $replacement) = split(/\t/, $_);
	if ($revert) {
	    ($replacement, $entry) = ($entry, $replacement);
	}
	## &incr_entry(*target_count, $replacement);
	&append_entry(*sense_mapping, $entry, "$replacement\t");
    }
    close(SENSE_MAPPING);

    return;
}


# convert_sense_entries(text)
#
# Convert sense specifications in the text to use the new sense distinctions.
# Senses are indicated by [<POS>:]<word>#<sense>.
# NOTE: Multiple entries per line are handled.
#
sub convert_sense_entries {
    local($text) = @_;

    local($new) = "";
    while ($text =~ /(\S+:)?(\S+\#\S+)/) {
	$new .= $`; $text = $';
	local($full_sense) = $&;
	local($sense) = $2;

	# Check for the mapping: first with part-of-speech; then without
	local($new_sense) = &get_entry(*sense_mapping, $full_sense, "");
	if ($new_sense eq "") {
	    $new_sense = &get_entry(*sense_mapping, $sense, $full_sense);
	}
	if ($new_sense =~ /\t.*/) {
	    &debug_out(3, "WARNING: using first sense of '%s'\n", $new_sense);
	    $new_sense =~ s/\t.*//;
	}
	$new .= $new_sense;
    }
    $new .= $text;

    return ($new);
}


# convert_tabular_sense_entries(text)
#
# Convert a tabular sense specification to use the new sense distinctions.
# For one-to-one mappings, this just replaces the sense specification.
# For one-to-many mappings, this duplicates the tabular entry for each
# occurence, assigning the value either uniformly or proportionately.
#
# Senses are indicated by [<POS>:]<word>\t<sense>. In addition, a 
# subsequent column is assumed for the value associated with the sense
# (eg., a probability). So the entire line is assumed to be either
#      [<POS>:]<word>\t<index>\t<value>
# or
#      [<POS>:]<sense>\t<value>
#
# NOTE: Only one entry per line is assumed.
#
sub convert_tabular_sense_entries {
    local($text) = @_;

    # Fixup the text to use the "proper" full sense specification
    $text =~ s/(adjective|noun|verb|adverb)_/$1:/;

    # Check for a single tabular entry of word + sense + value
    local($category, $word, $index, $value);
    if ($text =~ /^(\S+:)?(\S+)(\t\S+)?\t(\S+)\s*$/) {
	$category = defined($1) ? $1 : "";
	$word = $2; 
	$index = defined($3) ? $3 : "";
	$value = $4;

	# Resolve the sense specification by incorporating the index
	# if necessary.
	# TODO: Have the bayesian network output uses word sense labels.
	$sense = $word;
	if ($sense !~ /\d+$/) {
	    $sense .= $index;
	}

	local($new_text) = "";
	$sense =~ s/\t(\d+)$/\#$1/;	# use #-notation to check mapping
	local($full_sense) = "${category}${sense}";

	# Get the sense or senses which form the replacement set
	local($new_senses) = &get_entry(*sense_mapping, $full_sense, "");
	if ($new_senses eq "") {
	    $new_senses = &get_entry(*sense_mapping, $sense, $full_sense);
	}
	local(@new_sense) = split(/\t/, &trim($new_senses));

	# Make sure one-to-many mappings are done proportionately
	local($num_new_senses) = (1 + $#new_sense);
	&assert('$num_new_senses > 0');
	if ((!$uniform) && ($num_new_senses > 1)) {
	    &debug_out(5, "distributing value $value of $sense among $new_senses\n");
	    $value /= $num_new_senses;
	}
				  
	# Distribute the result to each of the new senses
	local($new_sense);
	foreach $new_sense (@new_sense) {
	    ## $new_sense =~ s/\#/\t/;	# revert from #-notation to tabs 
	    $new_text .= $new_sense . $index . "\t" . $value . "\n";
	}
	chop $new_text;

	# Replace the old line with the new one(s)
	$text = $new_text;
    }

    return ($text);
}
