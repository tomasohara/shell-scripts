# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# extract-differentia.perl: Analyzes dictionary definitions to extract
# and optionally refine the differentia (distinguishing
# properties). This uses a dependency parser to determine the
# syntactic relations represented in the definitions. Then this
# information is refined by disambiguating the relation-indicating
# words (eg, prepositions) as well as the source and target terms.
#
# Relations are weighted based on the notion of cue-validities from
# pyschology. This basically is a conditional probability measure
# that indicates how indicative certain features are of a given
# category with respect to sibling categories. Relations are also
# weighted based on the occurrence of certain qualifying terms in
# the definitions (e.g., 'typically').
#
# This is currently a stand-alone script that is used to produce
# lexical-relation files that are used as input for lexrel2network.perl,
# one of the key components in the Bayesian network system for WSD
# (see bn_wsd_classifier.perl).
#
# NOTES:
# - Most of the work is done by other scripts: see parse_wordnet_defs.perl,
#   disambiguate-parses.perl, tuple2lexrel.perl, and est_cue_validities.perl.
# - The definitions usually come from the WordNet synset glosses.
# - The source and target terms are assumed to be already disambiguated,
#   with the result taken from a data file.
# - The relation-indicating word disambiguation uses the Bayesian classifier
#   developed for the GraphLing system.
# - When the input is taken from the wn interface hypernym or hyponym listings
#   the sense indicator needs to be included as well (-s) as the gloss (-g).
#
# TODO:
# - Develop an empirical methodology for weighting qualifying terms found
#   in dictionary definitions (e.g., based on correlation with Cyc relations).
# - Look into using the manually-corrected WordNet parses produced for
#   the Extended WordNet project at UT Dallas.
# - Weed out the WordNet dependencies.
# - Add optional step for the cue-validity relation weighting.
#
#........................................................................
# Sample input:
#
#   
#   Synonyms/Hypernyms (Ordered by Estimated Frequency) of noun artifact
#   
#   1 sense of artifact
#   
#   Sense 1
#   artifact#1, artefact#1 -- (a man-made object taken as a whole)
#
# Sample output:
#
#   noun:artifact#1:
#           n/a     noun:artifact (1.000)
#           verb:is noun:object (0.028)
#                   modified-by-6-7 verb:taken (0.167)
#                           as      noun:whole (0.028)
#
#........................................................................
# Alternative sample input (WN data file):
#
#    00015787 03 n 02 artifact 0 artefact 0 045 @ 00013067 n 0000 @ 00002664 n 0000 ! 00013738 n 0101 ~ 00016679 n 0000 ~ 02350518 n 0000 ~ 02355534 n 0000 ~ 02370598 n 0000 ~ 02480558 n 0000 ~ 02676958 n 0000 ~ 02688135 n 0000 ~ 02717448 n 0000 ~ 02723466 n 0000 ~ 02758693 n 0000 ~ 02759699 n 0000 ~ 02857437 n 0000 ~ 02862537 n 0000 ~ 02876994 n 0000 ~ 02883498 n 0000 ~ 02888347 n 0000 ~ 02923142 n 0000 ~ 02931560 n 0000 ~ 03113632 n 0000 ~ 03115433 n 0000 ~ 03183675 n 0000 ~ 03196719 n 0000 ~ 03242357 n 0000 ~ 03313450 n 0000 ~ 03352256 n 0000 ~ 03373941 n 0000 ~ 03454512 n 0000 ~ 03559589 n 0000 ~ 03649665 n 0000 ~ 03725783 n 0000 ~ 03740351 n 0000 ~ 03741520 n 0000 ~ 03781699 n 0000 ~ 03783785 n 0000 ~ 03801477 n 0000 ~ 03856227 n 0000 ~ 03891343 n 0000 ~ 03976508 n 0000 ~ 03982050 n 0000 ~ 03985470 n 0000 ~ 12493216 n 0000 ~ 12662987 n 0000 | a man-made object taken as a whole
#
# TODO: show current actual output format (not ideal)
#
# Copyright (c) 2004 Tom O'Hara and New Mexico State University.
# Freely available via GNU General Public License (see GNU_public_license.txt).
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir);
    require 'common.perl';
    use vars qw/$TEMP $d/;
    require 'graphling.perl';
    use vars qw/$reuse/;		# used by helper scripts
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
# NOTE: strict refs not used to allow for file handle string references
use strict;
no strict "refs";
use vars qw/$classification_dir $skip_refine $skip_cv $cv $all_defs/;

# Show a usage statement if no arguments given
# NOTE: By convention - is used when no arguments are required
if (!defined($ARGV[0])) {
    my($options) = "main options = [-skip_refine]";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "examples:\n\n$script_name - < \$WNSEARCHDIR/data.noun\n\n";
    $example .= "wn dog -treen -s -g | $script_name -skip_refine -all_defs -d=4 - >| wn-dogs.rels 2>| wn-dogs.log\n\n";
    $example .= "export batched_disambiguation=1; $script_name -reuse -d=5 dso-v-training.wn-data >| dso-v-training.log 2>&1 &\n\n";

    my($note) = "";
    $note .= "notes:\n\nThis script can take long to run given that the input is parsed via the Link Grammar\n";
    $note .= "and then the syntactic relations classified via GraphLing\n\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n$note";
}
my($file) = $ARGV[0];
my($base) = &basename_proper($file);
$base = "classification" if ($base eq "-");
my($temp_base) = "$TEMP/temp-differentia-$$";

# Check the command-line options
# note: Each var. initialized corresponds to a -var=value commandline option
&init_var(*classification_dir, "temp-$base");
&init_var(*skip_refine, &FALSE);	# skip the refinement step
&init_var(*skip_cv, &FALSE);		# omit cue-validity weighting step
&init_var(*cv, ! $skip_cv);		# use cue validities to revise weights
&init_var(*all_defs, &FALSE);		# use all hyponyms (in parse_wordnet_defs.perl)
my($refine) = (! $skip_refine);

# Parse the definitions into syntactic relational tuples
# TODO: have option for using parse from previous run
&write_file("${temp_base}.input", &read_entire_input("ARGV"));
&perl("parse_wordnet_defs.perl ${temp_base}.input >| ${temp_base}.parse");

# Disambiguate the source and target terms in the parses
if ($refine) {
    &perl("disambiguate-parses.perl -classification_dir=${classification_dir} ${temp_base}.parse >| ${temp_base}.differentia");
}
else {
    &debug_out(&TL_USUAL, "Skipping refinement step\n");
    &cmd("cp ${temp_base}.parse ${temp_base}.differentia");
}

# Convert relation tuples into lexical-relation format for GraphLing BN system
# TODO: filter out high-frequency terms
&perl("tuple2lexrel.perl ${temp_base}.differentia >| ${temp_base}.lexrels");

# Optionally, reweight the relations based on cue validities (CV's)
# TODO: work out a better extension scheme for temporary files
if ($cv) {
    &cmd("mv ${temp_base}.lexrels ${temp_base}.lexrels.BAK");
    &perl("est_cue_validities.perl -by_freq ${temp_base}.lexrels.BAK >| ${temp_base}.cv");
    &perl("reweight_relations.perl -normalize ${temp_base}.cv ${temp_base}.lexrels.BAK >| ${temp_base}.lexrels");
}

# Output the lexical relations representing the differentia
print &read_file("${temp_base}.lexrels");

# Cleanup temporary files, etc.
&run_command("rm ${temp_base}.*") unless (&DETAILED_DEBUGGING);

&exit();
