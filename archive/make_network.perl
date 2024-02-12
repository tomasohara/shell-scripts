# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# make_network.perl: produce a series of belief networks given a list
# lexical relation files
#
# NOTE:
# - If no lexical relation files specified via -lexical_relations_file
#   (or -lexrel_file), dso_wn_noun.rels must exist as well as the supporting
#   files needed for lexrel2network.perl (eg, noun.freq, verb.freq, etc.).
#
# TODO:
# - Remove dependencies upon DSO data (at least in the confusing comments).
# - Reconcile -lexical_relations_file with -lexrel_file (see lexrel2networki.pel).
#
# Copyright (c) 2004 Tom O'Hara and New Mexico State University.
# Freely available via GNU General Public License (see GNU_public_license.txt).
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN {
    my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir);
    require 'common.perl';
    require 'belief_network.perl';
    use vars qw/$use_BELIEF $use_NETICA $use_NONAME $script_dir $belief_format/;
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var calls).
use strict;
use vars qw/$skip_tagger $ignore_lexrels $lexrel_file $lexical_relations_file/;


if (!defined($ARGV[0])) {
    my($bn_options) = &belief_network_options;
    my($example) = "$0 -hugin dj*.tag >| make.log 2>&1\n\n";
    $example .= "nice +19 $script_name -use_NONAME dso_*.tag >&! make4.log\n";

    print STDERR "\nusage: $script_name $bn_options DSO_data_file ...\n\nex:\n$example\n\n";
    &exit();
}

my($ext) = &get_belief_extension();
my($base_options) = "-show_vectors=0 -produce_belief_net=1 -belief_format=$belief_format ";
&init_var(*skip_tagger, &TRUE);		# skip part of speech tagger?
&init_var(*ignore_lexrels, &FALSE);	# don't include lexical relations?
&init_var(*lexrel_file, "");		# alias for -lexical_relations_file
&init_var(*lexical_relations_file,	# file defining the lexical relations
	  "dso_wn_noun.rels");

# Set environment settings for helper scripts
# TODO: develop init_env_var() function
$ENV{"wn_cache_dir"} = $script_dir unless (defined($ENV{"wn_cache_dir"}));
$ENV{"DEBUG_LEVEL"} = &DEBUG_LEVEL;

foreach my $file (@ARGV) {
    my($base) = &basename($file, ".tag");
    &debug_print(&TL_USUAL, "processing $file\n");

    # Determine the list of root words for which to build the network
    &issue_command("perl -Ssw derive_roots.perl $file > ${base}.roots");

    # Tag the text file
    # TODO: rename post to .pos (to be more consistent with rest of GraphLing)???
    if (($skip_tagger == &FALSE) 
	|| (! -s "$base.post")
	|| (&file_mtime("$base.tag") > &file_mtime("$base.post"))) {
	&issue_command("perl -Ssw strip_tags.perl $file > $base.text");
	&issue_command("run_brill_tagger.sh $base.text > $base.post");
    }

    # Create version of the taggings using the #-convention for senses
    if (! -s "$base.sense") {
	&perl("sgml2sense.perl $file > $base.sense");
    }

    # Contruct the belief network (normally in BNJ format)
    my($options) = "$base_options -inclusion_file=\"${base}.roots\" -context_file=\"\"";
    my($data) = "-";
    if ((! $ignore_lexrels) && ($lexrel_file eq "")) {
	$data = $lexical_relations_file;
    }
    &debug_print(&TL_VERBOSE, "options='$options' data='$data' base='$base' ext='$ext'\n");
    &issue_command("perl -Ssw lexrel2network.perl $options $data > ${base}$ext");

    # Create a simplified version of the belief network and produce dot graph.
    # This also outputs a dependency file (useful for comparison).
    # TODO: reformat the dependency to drop 'P(', etc. and to show weights
    if (! $use_NONAME) {
	my($plain_options) = "$options -belief_format=NONAME";
	my($plain_file) = "${base}.bnet";
	my($dot_file) = "${base}.dot";
	my($dependency_file) = "${base}.dependency";

	&issue_command("perl -Ssw lexrel2network.perl $plain_options $data > $plain_file");
	&issue_command("perl -Ssw ascii2network.perl -show_graph $plain_file > $dot_file");
	&issue_command("grep '^P' $plain_file | perl -pe 's/ =.*//;' >| $dependency_file");
    }

    # Do special-case handling for certain formats
    # This currently is related to specifying the evidence (e.g., the words)
    if ($use_BELIEF) {
	# Create the update-specification for BELIEF1.2
	# TODO: have an interface program that does this at run-time
	my($evidence_nodes) = &read_file("${base}.evidence");
	$evidence_nodes =~ s/\n/ /g;
	&issue_command("perl -Ssw update_belief.perl $evidence_nodes > ${base}.update");
    }

    # If using NETICA, make sure all node names are under 31 characters
    # TODO: have option to use surrougate variable names (eg, node1, node2, ...)
    if ($use_NETICA) {
	&cmd("perl -p -i.bak -e 's/_noun_/_n_/; s/_verb_/_v_/;' $base.evidence");
    }
}

&exit();

#------------------------------------------------------------------------------

# file_mtime(file_name)
#
# TODO: generalize into getting any stat field of interest
#
sub file_mtime {
    my($filename) = @_;
    &debug_print(&TL_VERBOSE, "file_mtime(@_)\n");

    # Do a stat on the file
    my($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
       $atime,$mtime,$ctime,$blksize,$blocks) = stat($filename);
    &debug_print(&TL_VERY_DETAILED, "($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks)\n");

    return ($mtime);
}
