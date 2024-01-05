# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# process_network.perl: Process a belief network from scratch.
# Specifically, this does the following:
#
# 1) Create the network given the extracted lexical relations
# for the DSO (training) words of interest (the "main words").
#
# 2) Interpret the network to determine probabilities of the
# word senses for the main words.
#
# 3) Evaluate the results by tabulating the number of times that
# the correct sense would be chosen by always selecting the sense
# with the highest probability.
# TODO: look into making the selection itself probabilistic
#
# The Bayesian network is constructed from information contained in WordNet.
# Therefore, any empirical evidence must be in terms of the sense distinctions
# that it provides. Otherwise, a mapping is required before and after the
# network is constructed and interpreted. Both steps are handled below.
#
# NOTE: The lexical relations for the DSO words must be extracted 
# beforehand (eg, by using extract_lex_rels.perl). In addition,
# estimated frequencies are required for the WordNet synsets
# (see estimate_wn_freq.perl).
#........................................................................
# TODO:
# - document the intermediate files (see run_network.perl)
# - make the output file creation less adhoc
# - integrate count_undecidables.perl into evaluation
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';
require 'belief_network.perl';

if (!defined($ARGV[0])) {
    $options = "options = [-skip_make=0|1] [-skip_run=0|1] [-skip_tagger=0|1]";
    $example = "examples:\n\nnice +19 $script_name dso_*.tag >&! process2.log";
    $example .= "\nnice +19 $script_name -belief_format=BELIEF dso_*.tag >&! process3.log";
    $example .= "\nnice +9 $script_name DJ*/dj*.tag >&! process.log";
    die "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
}

&init_var(*skip_make, &FALSE);
&init_var(*skip_run, &FALSE);
&init_var(*include_analytic_eval, &FALSE);
&debug_out(5, "sd=$script_dir; bf=$belief_format\n");

$ext = &get_belief_extension();

# Set environment settings for helper scripts
$ENV{"wn_cache_dir"} = $script_dir unless (defined($ENV{"wn_cache_dir"}));
$ENV{"DEBUG_LEVEL"} = &DEBUG_LEVEL;

## &debug_out(4, "start $script_name: %s\n", &get_time());
foreach $file (@ARGV) {
    $base = &basename($file, ".tag");

    # Build the Bayesian network file
    if ($skip_make == &FALSE) {
	# Make sure empirical support is based on WordNet sense distinctions
	if (-e "$base.sense_map") {
	    &map_senses("$base.sense_map", "$base.empirical", "$base.wn_empirical");
	    $ENV{"empirical_support_file"} = "$base.wn_empirical";
	}

	# Do the actual network construction
	$ENV{"belief_format"} = $belief_format;
	&perl("make_network.perl $file");
    }

    # Interpret the Bayesian network
    if ($skip_run == &FALSE) {
	# If analyzing the analytical component by itself, run the network
	# with the evidence being instantiated.
	if ($include_analytic_eval) {
	    &debug_out(3, "running and evaluating network w/o evidence\n");
	    &perl("run_network.perl -include_evidence=0 $base$ext");
	    if (-e "$base.sense_map") {
		&remap_senses("$base.sense_map", "$base.bn-out", "$base.anal_out");
	    }
	    else {
		&copy_file("$base.bn-out", "$base.anal_out");
	    }
	    &perl("eval_network.perl $base.bn-out > $base.anal_eval");
	}

	# Run the network with the evidence instantiated
	&debug_out(3, "running and evaluating net w/ empirical evidence\n");
	&perl("run_network.perl $base$ext");
	if (-e "$base.sense_map") {
	    &remap_senses("$base.sense_map", "$base.bn-out", "$base.comb_out");
	}
	else {
	    &copy_file("$base.bn-out", "$base.comb_out");
	}

	# Evaluate the results (combined = analytical + empirical evidence)
	&perl("eval_network.perl $base.output > $base.comb_eval");
    }
}
## &debug_out(4, "end $script_name: %s\n", &get_time());

&cleanup_common();

#-----------------------------------------------------------------------------

sub old_get_time {
    local ($time_string);

    $time_string = localtime;

    return ($time_string);
}


# map_senses(input_file, result_file)
#
# Convert the sense distinctions in the file using the mapping from
# the sense mapping table.
#
# NOTE: This handles many-to-one mappings by invoking tally-unique.perl to sum
#       items having the same key value after the mapping.
#
# TODO: Rework the clumsy handling of the different formats for
# sense distinctions ([<POS>:]<word>#<sense> vs [<POS>:]<word>\t<sense>).
#
sub map_senses {
    local($mapping_file, $file, $result) = @_;
    &debug_out(4, "map_senses(@_)\n");

    # Convert the sense distinctions
    &cmd("perl -Ssw convert_sense_IDs.perl -mapping_file=$mapping_file $file | perl -Ssw tally-unique.perl - > $result");

    return;
}

# remap_senses(mapping_file, input_file, result_file)
#
# Revert the sense distinctions in the file using the mapping from the
# given table.
# NOTE: This handles many-to-one mappings by invoking tally-unique.perl to sum
#       items having the same key value after the mapping.
# TODO: reconcile with map_senses
#
sub remap_senses {
    local($mapping_file, $file, $result) = @_;
    &debug_out(4, "remap_senses(@_)\n");

    # Revert the sense distinctions
    &cmd("perl -Ssw convert_sense_IDs.perl -revert -mapping_file=$mapping_file $file | perl -Ssw tally-unique.perl - > $result");

    return;
}
