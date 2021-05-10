# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# ascii2network.perl: create a belief network from an ascii representation
#
# This is intended for quick and dirty construction of belief networks
# for testing purposes. Since the syntax of the formats required for
# BELIEF12 or MSBN is sufficiently complex, creating simple networks
# is awkward. For instance, the full set of indices for conditional
# dependencies must be specified, whereas the default case can be
# inferred from the others (e.g., for binary nodes only positive case
# probabilities need be specified).
#
#
# For instance, here's a basic conditional dependency in MSBN:
#
#   probability(public_1 | group_1, people_1)
#   {
#       (0, 0): 1.000, 0.000;
#       (0, 1): 0.400, 0.600;
#       (1, 0): 0.600, 0.400;
#       (1, 1): 0.000, 1.000;
#   }
#
# BELIEF12's version is even more complicated (but it handles more
# general belief functions [Almond 95]):
#
#   (defpotcond _public_1 (public_1 :given group_1 people_1)
#       :ps-list
#       ({(:F :F)} (1.000 {(:F)}) (0.000 {(:T)}) )
#       ({(:F :T)} (0.400 {(:F)}) (0.600 {(:T)}) )
#       ({(:T :F)} (0.600 {(:F)}) (0.400 {(:T)}) )
#       ({(:T :T)} (0.000 {(:F)}) (1.000 {(:T)}) )
#       )
#
# Instead, this can be given as:
# 
#                                       FF   FT   TF   TT
#   P(public_1 | group_1, people_1) = { 0.0, 0.6, 0.4, 1.0 }
#
#
# NOTES:
#
# - Binary nodes use the values 0 for false and 1 for true.
#
# - Support for exact evaluation has been added through an implementation
# of the algorithm for polytrees in [Russell and Norvig 95].
#
# - Support for stochastic simulation has been added through an implementation
# of the method described in [Pearl 87] and [Hrycej 90].
#
#
# - Primitive support for multivalued nodes has been added. For now, the
# specification of the probabilites is simply the list of all probabilities
# in "canonical order": prob_(0|0,...,0) prob_(0|0,...,1) prob_(M|N,...,Z)
# Ex:
#       #                        1|1,1  1|1,2  1|1,3  1|2,1  1|2,2  1|2,3
#	P(animal | human, dog) = 1.0    1.0    1.0    1.0    0.0    0.0
#
#       T(Earthquake) = {None, Mild, Severe}
#       #                                   FN    FM   FS   TN   TM   TS
#       P(Alarm | Burglary, Earthquake) =   0.001 0.10 0.30 0.90 0.95 0.99 
#
# - The my() declaration is used whenever possible since this is closest
# to the lexical-scoping from traditional languages. However, local() is
# used for arrays to avoid problems with reference parameters.
#
# - global variables usage:
#    node_num_values{<node_name>}	number of values for the node
#    node_value{<name>:<i>}		i'th value for the given node
#    node_evidence{<node_name>}		value of an evidence node
#    node_prior_prob{<node_name>}	prior probabilities of node values
#    node_cond_vars{<node_name>}	list of parents for the node
#    node_cond_prob{<node_name>:<parent_indices>} conditional probabilities
#		for the node given the parent configuration
#    node_children{<node_name>}	        list of children for each node
#    node_index{<name>}			current index for node in simulation
#
# REFS:
# 
# Almond, Russell G. (1995), {\em Graphical Belief Modeling},
# London: Chapman \& Hall.
#
# Hrycej, Tomas (1990), "Gibbs Sampling in Bayesian Networks",
# Artificial Intelligence, 46:351-363.
#
# Pearl, Judea (1987), ``Evidential Reasoning Using Stochstic Simulation
# of Causal Models'', {\em Artificial Intelligence}, 32:245-257.
#
# Russell, Stuart and Peter Norvig (1995), {\em Artificial Intelligence: 
# A Modern Approach}, Prentice-Hall: Upper Saddle River, NJ.
#
#
# TODO:
# - have lexrel2network use this as an "internal representation"
# - resolve problem w/ reference parameter passing of my() variables
# - simplify the specification of multiple-valued nodes 
# - eliminate need for continuation lines (e.g. "0.999 \ ... 0.001")
# - rename to reflect generality (or factor out evaluation code)
# - *** implement juncture tree algoritm to support exact evaluation of
#   arbitrary bayesian networks
# - make sure all nodes are declared at (e.g., MSBN requirement?)
# - put comments on TOP indicating the format of the BN and the version
# - decompose more into subroutines and add unit tests for each
# - have option so that the probabilities can be specfied in positive-first
#   order (eg, TT TF FT FF) rather than negative first (eg, FF FT TF TT)
#
# Fall 1997
# Tom O'Hara
# New Mexico State University
#
# Copyright (c) 2004 Tom O'Hara and New Mexico State University.
# Freely available via GNU General Public License (see GNU_public_license.txt).
#

BEGIN {
    require v5.6;

    # Load common module, ensuring script dir is first in Perl's lib path
    my($dir) = `dirname $0`; chop $dir; unshift(@INC, $dir);
    require 'common.perl';
    use vars qw/$d $script_name/;

    # Load in other modules
    require 'belief_network.perl';
    use vars qw/$use_HUGIN $use_MSBN $use_BNIF $use_NETICA $use_BELIEF $belief_format/;
    use vars qw/$hugin $msbn $bnif $netica $belief/;
}

# Specify that strict type-checking is to be applied, except that symbolic
# link variables are allowed (e.g., $handle = "STDIN"; ... print $handle ...).
use strict;
no strict "refs";		# allow symbolic links for file handles
use vars qw/$prior_node_type $cond_node_type $simple $sim $show_graph 
    $skip_net $num_iters $dependency_file $filter_file $filter_list 
    $row_per_value $full_size/;

if (!defined($ARGV[0])) {
    my($options) = "options = " . &belief_network_options . " [-skip_net] [-sim] [-num_iters=N] [-show_graph [-full_size]]";
    my($example) = "examples:\n\nperl -Ssw $script_name earthquake.bnet > earthquake.net\n\n";
    $example .= "$script_name -use_BELIEF=1 -simple=0 earthquake2.bnet > earthquake.bel\n";
    $example .= "\n\nmake_network.perl -use_NONAME=1 dso_dj01_230.tag >&! dso_dj01_230.mlog\n";
    $example .= "nice +19 $script_name -d=4 -sim=1 -num_iters=5000 dso_dj01_230.bnet >&! dso_dj01_230.sim &";

    die "\nusage: $script_name [options] belief_net_desc\n\n$options\n\n$example\n\n";
}

&init_var(*prior_node_type, "hypothesis");
&init_var(*cond_node_type, "other");
&init_var(*simple, &FALSE);
&init_var(*sim, &FALSE);
&init_var(*show_graph, &FALSE);
&init_var(*skip_net, $sim || $show_graph);
&init_var(*num_iters, 1000);
&init_var(*dependency_file, ($sim || !$skip_net) ? "dependency.list" : "");
&init_var(*filter_file, "");
&init_var(*filter_list, ($filter_file ne "" ? &read_file($filter_file) : ""));
&init_var(*row_per_value, &TRUE);
&init_var(*full_size, &FALSE);

my($prior_node_type) = $main::prior_node_type;
my($cond_node_type) = $main::cond_node_type;
my($simple) = $main::simple;
our(%node_num_values, %node_value, %node_evidence, %node_prior_prob); 
our(%node_cond_vars, %node_cond_prob, %node_total_prob, %node_children, %node_type);
my($first_query);

our($name) = "ascii2network";
if (defined($ARGV[0])) {
    $name = &basename($ARGV[0], ".bnet");
    $name =~ s/\.*//;
}

&print_header("ascii2network") unless ($skip_net);

*determine_conditional_probs = *determine_complex_conditional_probs;
if ($simple) {
    *determine_conditional_probs = *determine_simple_conditional_probs;
}


while (<>) {
    &dump_line();
    chomp;

    # strip comments
    s/\#.*$//;
    
    # Combine escaped lines into one
    # NOTE: comments can appear after the escape sequence
    while (/\\\s*$/) {
	my $current = $`;
	my $next = <>;
	&dump_line($next);
	chomp;

	$next =~ s/\#.*$//;		# strip comments
	$_ = $current . $next;
    }
    &debug_print(&TL_VERY_VERBOSE, "line=$_\n");

    # Skip blank lines
    if (/^\s*$/) {
	next;
    }

    # Parse the conditional probability specification
    # TODO: allow flexibility in the specification
    if (/P\((\S+)\s*\|\s*([^\(\)]+)\)\s*=\s*/i) {
	my($node_name, $cond_vars) = ($1, $2);
	$_ = $';

	# Fill-in the node number of values for nodes with default types
	my($type) = &get_entry(\%node_type, $node_name, "binary");
	if ($type eq "binary") {
	    $node_num_values{$node_name} = 2;
	    &set_entry(\%node_value, "$node_name:0", "0");
	    &set_entry(\%node_value, "$node_name:1", "1");
	}

	&determine_conditional_probs($node_name, $cond_vars, $_);
    }

    # Parse the prior probability specification
    elsif (/P\((\S+)\)\s*=\s*[\{\(]?\s*(\S+)/i) {
	my($node_name, $prior_prob, $rest) = ($1, $2, $');
	my(@prob_values, $prob_values);

	my($type) = &get_entry(\%node_type, $node_name, "binary");
	if ($type eq "binary") {
	    $node_num_values{$node_name} = 2;
	    &set_entry(\%node_value, "$node_name:0", "0");
	    &set_entry(\%node_value, "$node_name:1", "1");
	    if ($skip_net == &FALSE) {
		# Declare the node unless already done so
		&print_node_declaration($node_name, $prior_node_type);
		&print_prior_probability($node_name, $prior_prob);
	    }
	    @prob_values = (1 - $prior_prob, $prior_prob);
	    $prob_values = "@prob_values";
	}
	else {
	    $prob_values = "$prior_prob $rest";
	    $prob_values =~ s/[\(\)\{\}]//g;
	    $prob_values =~ s/,/ /g;

	    # Determine the probability of the unmarked case (at index 0)
	    my($sum) = 0.0;
	    my($num);
	    foreach $num (my_split($prob_values)) {
		$sum += $num;
	    }
	    if ($sum < 1.0) {
		my($value) = 1 - $sum;
		$prob_values = "$value $prob_values";
	    }

	    # Print the probaility specification
	    if ($skip_net == &FALSE) {
		# Declare the node unless already done so
		&print_node_declaration($node_name, $prior_node_type, $type);
		&print_prior_probability($node_name, $prob_values);
	    }
	}
	&debug_print(&TL_VERY_DETAILED, "node_prior_prob{$node_name} = $prob_values\n");
	$node_prior_prob{"${node_name}"} = $prob_values;
    }

    # Check for the optional type-specification
    elsif (/T\((\S+)\)\s*=\s*(.*)/i) {
	my($node_name, $type_values) = ($1, $2);

	# Extract the values for the type
	$type_values =~ s/[\(\)\{\}]//g;
	$type_values =~ s/,/ /g;
	$type_values = &trim($type_values);

	# Determine the number of types
	my(@type_values) = &my_split(&trim($type_values));
	my($num_types) = ($#type_values + 1);
	&debug_print(&TL_VERY_DETAILED, "$node_name: values=@type_values; num=$num_types\n");

	# Store each of the values in the array keyed by the name & index
	# note: this is one of those times when you hate Perl for its
	#       impoverished handling complex data types
	$node_num_values{$node_name} = $num_types;
	$node_type{$node_name} = $type_values;
	my($i);
	for ($i = 0; $i < $num_types; $i++) {
	    $node_value{"$node_name:$i"} = $type_values[$i];
	}

	# Print the node declaration
	if ($skip_net == &FALSE) {
	    &print_node_declaration($node_name, $prior_node_type, 
				    $type_values);
	}
    }

    # Check for an evidence node specification
    # TODO: convert True/False to 1/0
    elsif (/E\((\S+)\)\s+=\s+(\S+)/i) {
	my($node_name, $node_value) = ($1, $2);

	# Record the evidence for later use in queries
	&debug_print(&TL_USUAL, "setting evidence of $node_name to $node_value\n");
	$node_evidence{$node_name} = $node_value;
    }

    # Check for a query command
    elsif (/Q\((\S+)\)/i) {
	my($node_name) = $1;

	my(@dist) = &query_probability($node_name);
	&debug_out(&TL_BASIC, "The distribution of $node_name is (%s)\n",
		   &format_numbers(@dist));
    }

    # Otherwise relegate to the bit bucket
    else {
	&debug_print(&TL_BASIC, "WARNING: ignoring $_\n") unless (/^\s*$/);
    }
}

&print_trailer("ascii2network") unless ($skip_net);

# Produce the evidence file if any evidence was given
#
our($evidence) = "";
our($key);
foreach $key (sort(keys(%node_evidence))) {
    my($value) = $node_evidence{$key};
    my($value_pos) = &get_value_index($key, $value);
    $evidence .= sprintf "%s:%d\n", $key, $value_pos;
}
if ($evidence ne "") {
    &write_file("$name.evidence", $evidence);
}

# Optionally, perform a stochastic simulation to determine the distribution.
#
our(%node_value_count, %node_index, @node);
if ($sim) {
    &simulate();
}

# Optionally, display the dependency graph (AT&T's dot format)
#
if ($show_graph) {
    *DEPENDENCY = *STDOUT;
    if ($dependency_file ne "") {
	open(DEPENDENCY, ">$dependency_file")
	    || die "unable to create dependency listing ($dependency_file)\n";
    }
    &display_dependency_graph("DEPENDENCY", $name);
    close(DEPENDENCY) unless ($dependency_file eq "");
}

#------------------------------------------------------------------------------


# determine_simple_conditional_probs(node_name, given_variables, probabilities)
#
# Determine the form of the conditional probability specification for the
# node and its conditioning variables, given previous specifications about
# the variable values. This version just handles binary-valued nodes.
#
sub determine_simple_conditional_probs {
    my($node_name, $cond_vars, $probs) = @_;
    my(@cond_vars, @cond_prob);

    $cond_vars =~ s/\s//g;
    @cond_vars = split(/,/, $cond_vars);
    my($num_vars) = ($#cond_vars + 1);
    my($num_entries) = (2 ** $num_vars);

    # Read in the conditional dependencies. This just reads in the
    # next N numbers, where N = 2^|vars|.
    my($i) = 0;
    $_ = $probs;
    s/[{(})]//g;
    s/,/ /g;
    while (/(\S+)/) {
	$cond_prob[$i++] = $1;
	$_ = $';
	last if ($i == $num_entries);
    }

    # Now, create the sucker
    &output_simple_conditional_prob($node_name, \@cond_vars, \@cond_prob);
}


# determine_complex_conditional_probs(node_name, given_nodes, probabilities)
#
# Determine the form of the conditional probability specification for the
# node and its conditioning variables, given previous specifications about
# the variable values. This version handles multiple-valued nodes.
#
sub determine_complex_conditional_probs {
    my($node_name, $cond_vars, $probs) = @_;
    my(@cond_vars, @cond_prob);
    &debug_print(&TL_VERY_DETAILED, "determine_complex_conditional_probs(@_)\n");

    $cond_vars =~ s/\s//g;
    @cond_vars = split(/,/, $cond_vars);
    my($num_vars) = ($#cond_vars + 1);
    my($num_entries) = &get_entry(\%node_num_values, $node_name, 2) - 1;
    my($var);
    foreach $var (@cond_vars) {
	my($var_values) = &get_entry(\%node_num_values, $var, 2);
	if (($var_values == 2)
	    && (! $skip_net)) {
	    # Make sure binary nodes are declared
	    # TODO: check that node is undeclared first to avoid warning
	    # TODO: handle this in the simple case as well
	    &print_node_declaration($var, $prior_node_type);
	}
 	$num_entries *= $var_values;
    }
    &debug_print(&TL_VERY_DETAILED, "checking for $num_entries entries\n");

    # Read in the conditional dependencies. This just reads in the
    # next N numbers: N = (|Values_1| - 1) x (|Values_2| x ... x |Values_N|).
    my($i) = 0;
    s/[{(})]//g;
    s/,/ /g;
    while (/(\S+)/) {
	$cond_prob[$i++] = $1;
	$_ = $';
	last if ($i == $num_entries);
    }

    # Now, create the sucker (ie, actual conditional probability spec)
    &output_complex_conditional_prob($node_name, \@cond_vars, \@cond_prob);
}


# output_simple_conditional_prob(node_name, given_vars, cond_probs)
#
# Output the conditional probability specification for the node conditioned
# on the given variables. This version handles the case for binary-valued
# nodes.
#
# NOTE: This now also saves the conditional probabilities in a global
# associative array for later use in interpretation.
#    %node_cond_vars{<node_name>}
#    %node_cond_prob{<node_name>:<parent_indices>}
#
sub output_simple_conditional_prob {
    my($node_name, $cond_vars_ref, $cond_probs_ref) = @_;
    &debug_print(&TL_VERY_DETAILED, "output_simple_conditional_prob(@_)\n");
    my($num_vars) = ($#{$cond_vars_ref} + 1);
    my($num_entries) = ($#{$cond_probs_ref} + 1);
    my($is_xor) = &FALSE;

    if ($skip_net == &FALSE) {
	&print_node_declaration($node_name, $cond_node_type);
	&print_cond_prob_header($node_name, $cond_vars_ref, $is_xor);
    }
    $node_cond_vars{$node_name} = "@{$cond_vars_ref}";

    # Print the truth-table style entries
    #
    my($i, $j);
    for ($i = 0; $i < $num_entries; $i++) {
	my($num) = $i;
	my(@index);

	# Determine the index values for the current table entry, which
	# is equivalent to the binary representation of the current table
	# entry index.
	#
	for ($j = $num_vars - 1; $j >= 0; $j--) {
	    $index[$j] = $num % 2;
	    $num = int($num / 2);
	}

	# Print the current entry
	my(@probs) = (1 - ${$cond_probs_ref}[$i], ${$cond_probs_ref}[$i]);
	if ($skip_net == &FALSE) {
	    print_cond_prob_entry(\@probs, \@index, $is_xor);
	}
	$node_cond_prob{"${node_name}:@index"} = "@probs";
    }   

    if ($skip_net == &FALSE) {
	&print_cond_prob_trailer($node_name, $is_xor);
    }

    return;
}


# output_complex_conditional_prob(node, given_nodes, cond_probabilities)
#
# Output the conditional probability specification for the node conditioned
# on the given variables. This version handles the case for multiple-valued
# nodes.
#
# NOTE: This now also saves the conditional probabilities in a global
# associative array for later use in interpretation.
#    node_cond_vars{<node_name>}
#    node_cond_prob{<node_name>:<parent_indices>}
#
sub output_complex_conditional_prob {
    my($node_name, $cond_vars_ref, $cond_probs_ref) = @_;
    my($num_vars) = ($#{$cond_vars_ref} + 1);
    my($num_entries) = ($#{$cond_probs_ref} + 1);
    my($is_xor) = &FALSE;
    &debug_print(&TL_VERY_DETAILED, "output_complex_conditional_prob(@_)\n");
    &debug_print(&TL_VERY_VERBOSE, "cond_vars=(@$cond_vars_ref); cond_probs=(@$cond_probs_ref)\n");

    my($type) = &get_entry(\%node_type, $node_name, "binary");
    if ($type eq "binary") {
	&set_entry(\%node_value, "$node_name:0", "0");
	&set_entry(\%node_value, "$node_name:1", "1");
    }
    if ($skip_net == &FALSE) {
	&print_node_declaration($node_name, $cond_node_type, $type);
	&print_cond_prob_header($node_name, $cond_vars_ref, $is_xor);
    }
    $node_cond_vars{$node_name} = "@$cond_vars_ref";

    # Print the truth-table style entries
    #
    my($i, $j, $k);
    my(@value_pos);
    my($num_values) = &get_entry(\%node_num_values, $node_name, 2);
    my($num_indices) = $num_entries / ($num_values - 1);
    &debug_print(&TL_VERY_DETAILED, "num_values=$num_values num_indices=$num_indices\n");

    # Print the probabilities for each set of indices
    for ($i = 0; $i < $num_vars; $i++) {
	$value_pos[$i] = 0;
    }
    my($entry_pos) = 0;
    for ($i = 0; $i < $num_indices; $i++) {

	# Determine the index labels
	my(@index);
	for ($j = 0; $j < $num_vars; $j++) {
	    $index[$j] = $value_pos[$j];
	}

	# Determine the probabilites
	my(@probs) = ();
	my($total) = 0.0;
	for ($j = 1; $j < $num_values; $j++) {
	    # tally the totals
	    if ($row_per_value) {
		$probs[$j] = ${$cond_probs_ref}[$num_indices * ($j - 1) + $i];
	    }
	    else {
		$probs[$j] = ${$cond_probs_ref}[$entry_pos++];
	    }
	    $total += $probs[$j];
	}
	$probs[0] = (1.0 - $total);

	# Print the entry
	if ($skip_net == &FALSE) {
	    &print_cond_prob_entry(\@probs, \@index, $is_xor);
	}
	$node_cond_prob{"${node_name}:@index"} = "@probs";

	# Increment the index values position indicators from right to left.
	# If an index wraps-around, continue with one to the left.
	for ($j = ($num_vars - 1); $j >= 0; $j--) {
	    my($var) = ${$cond_vars_ref}[$j];
	    my($pos) = $value_pos[$j];
	    # Update the index position
	    my($num_values) = $node_num_values{$var} || 2;
	    $value_pos[$j] = (1 + $pos) % $num_values;
	    last if ($value_pos[$j] > 0);
	}
    }
    if ($skip_net == &FALSE) {
	&print_cond_prob_trailer($node_name, $is_xor);
    }

    return;
}



sub my_split {
    my($text) = @_;
    my(@list) = split(/\s+/, &trim($text));

    return (@list);
}


#------------------------------------------------------------------------------

# query_probability(node_name)
#
# Determine the probability distribution for the specified node using
# the algorithm from [Russell & Norvig 95].
#
# NOTES: 
#
# This currently only handles polytrees, which are singly-connected
# graphs (i.e., single path between any two nodes).
#
sub query_probability {
    my($node_name) = @_;
    &debug_print(&TL_VERBOSE, "query_probability(@_)\n");

    # Initialize a few things (eg, create assoc array for node children)
    &determine_children();

    # Determine the support for the specified node
    return (&support_except($node_name, "", 0));
}


# determine_children(): Determine the children for all nodes in the
# directed graph (belief network).
#
# Result stored in associative array
#	%node_children{<node_name>}
#
sub determine_children {
    my($node, $parent);

    foreach $node (keys(%node_cond_vars)) {
	foreach $parent (&my_split(&get_entry(\%node_cond_vars, $node, ""))) {
	    $node_children{$parent} = "" 
		if (!defined($node_children{$parent}));
	    $node_children{$parent} .= "$node "
		unless ($node_children{$parent} =~ /$node /);
	}
    }

    return;
}


# display_dependency_graph(file_handle, name)
#
# Display the dependency graph for the network. Output goes to the
# specified file.
#
# NOTE: This uses the format for AT&T's dotty package.
#
sub display_dependency_graph {
    my($file_handle, $name) = @_;
    &debug_print(&TL_DETAILED, "display_dependency_graph(@_)\n");
    my($label) = &remove_dir($name);

    print $file_handle "digraph $label {\n";
    if ($full_size == &FALSE) {
	print $file_handle "\tsize=\"7.5,10\";\t\t/* fit on 8.5x11 page */\n";
    }
    &determine_children();
    foreach my $node (keys(%node_cond_vars)) {
	foreach my $parent (&my_split(&get_entry(\%node_cond_vars, $node, ""))) {
	    # See if the link is being filtered
	    if ($filter_list ne "") {
		if ((index($filter_list, $node) < 0) 
		    || (index($filter_list, $parent) < 0)) {
		    next;
		}
	    }

	    print $file_handle "\t$parent -> $node;\n";
	}
    }
    print $file_handle "}\n";

    return;
}

# old_display_dependency_graphL old version of above
# TODO: remove this
sub old_display_dependency_graph {
    my($file_handle) = @_;
    &debug_print(&TL_DETAILED, "old_display_dependency_graph(@_)\n");
    my($node);

    &determine_children();
    foreach $node (keys(%node_cond_vars)) {
	if (&get_entry(\%node_children, $node, "") eq "") {
	    &display_node_parents($file_handle, $node, 0);
	}
    }

    return;
}

# display_node_parents(file_handle, node, depth)
#
# Display the node parents in a tree format suitable for input into xtree.
#
sub display_node_parents {
    my($file_handle, $node, $depth) = @_;
    my($new_depth) = $depth + 1;
    my($parent);

    printf $file_handle "%s$node\n", "\t" x $depth;
    foreach $parent (&my_split(&get_entry(\%node_cond_vars, $node, ""))) {
	&display_node_parents($file_handle, $parent, $new_depth);
    }

    return;
}


# support_except(node_name, exclusion_node, depth)
#
# Returns P(X|E_x\v) or the probability of node X (node_name) given all 
# the evidence except for that connected to X via V (exclusion_node).
# See [Russell & Norvig 95] for an in-depth explanation.
#
# Algorithm:
#
# if Evidence?(X) then 
#    return observed point distribution for X
# else
#    calculate P(E-_{X\V}|X) = Evidence-Except(X,V)
#    U <-- Parents[X]
#    if U is empty then
#       return (alpha x P(E-_{X\V}|X)P(X))
#    else 
#       for each U_i in U
#           calculate and store P(U_i|E_{U_i\X}) = Support-Except(U_i,X)
#       return alpha P(E-_{X\V}) \sum_u P(X|u) \product_i P(u_i|E_{U_i\X})
#
# where alpha is a normalization constant
#
sub support_except {
    my($node, $exclude_node, $depth) = @_;
    my($SP) = "    " x $depth;
    &debug_out(&TL_VERBOSE, "${SP}support_except(n:%s, ex:%s, d:%d)\n", 
	       $node, $exclude_node, $depth);

    my($num_values) = &get_entry(\%node_num_values, $node, 2);
    my(@dist) = (1/$num_values) x $num_values;

    # If evidence exists for the node, the result is a distribution
    # with P(X=evidence_value) = 1.0 and P(X<>evidence_value) = 0.0
    my($i, $j);
    my($value) = &get_entry(\%node_evidence, $node, "");
    if ($value ne "") {
	@dist = (0) x $num_values;
	for ($i = 0; $i < $num_values; $i++) {
	    if ($value eq &get_entry(\%node_value, "${node}:$i", "")) {
		$dist[$i] = 1.0;
		last;
	    }
	}
    }

    # Otherwise calculate support from the node's parents
    else {
	my($total) = 0;
	my(@evidence) = &evidence_except($node, $exclude_node, $depth+1);
	my($parents) = &get_entry(\%node_cond_vars, $node, "");

	# If no parents, just incorporate priors for the node values
	if ($parents eq "") {
	    my(@prob) = &my_split(&get_entry(\%node_prior_prob, $node, ""));
	    &debug_out(&TL_VERBOSE, "${SP}vacuous predictive_support($node) = (%s)\n",
		       &format_numbers(@prob));
	    for ($i = 0; $i < $num_values; $i++) {
		&debug_out(&TL_VERY_DETAILED, "${SP}$i: %.3f * %.3f\n", $evidence[$i], $prob[$i]);
		$dist[$i] = $evidence[$i] * $prob[$i];
		$total += $dist[$i];
	    }
	}

	else {
	    my(@node_prob) = &predictive_support($node, $num_values, $parents,
					     "", 0, $depth + 1);

	    # Form the distribution of the node values
	    for ($i = 0; $i < $num_values; $i++) {
		&debug_out(&TL_VERY_DETAILED, "${SP}$i: %.3f * %.3f\n", $evidence[$i], $node_prob[$i]);
		$dist[$i] = $evidence[$i] * $node_prob[$i];
		$total += $dist[$i];
	    }
	}
	&debug_out(&TL_VERY_DETAILED, "${SP}dist = (%s)\n", &format_numbers(@dist));

	# Normalize the probabilities
	$total = 1 if ($total == 0);
	for ($i = 0; $i < $num_values; $i++) {
	    $dist[$i] /= $total;
	}
    }
    &debug_out(&TL_VERBOSE, "${SP}support_except(@_) => (%s)\n",
	       &format_numbers(@dist));

    return (@dist);
}


# evidence_except(node_name, exclusion_node)
#
# Returns P(X|E-_{X\V}) or the probability of node X (node_name) given
# the evidence connected to X via its children, except for that connected 
# to X via V (exclusion_node).
# See [Russell & Norvig 95] for an in-depth explanation.
#
# Algorithm:
#
# Y <-- Children[X] - V
# if Y is empty then
#     return a uniform distribution
# else 
#     for each Y_i in Y do
#         calculate P(E-_{Y_i}|Y_i) = Evidence-Except(Y_i, null)
#         Z_i <-- Parents[Y_i] - X
#         for each Z_ij in Z_i
#             calculate P(Z_ij | E_{Z_ij} \ Y_i) = Support-Except(Z_ij, Y_i)
#     return beta \product_i \sum_{y_i} P(E-_{Y_i}|Y_i) 
#                 \sum_{z_i} P(y_i|X,z_i) \product_j P(z_ij | E_{Z_ij\Y_i})
#
sub evidence_except {
    my($node_name, $exclude_node, $depth) = @_;
    my($SP) = "    " x $depth;
    &debug_out(&TL_VERBOSE, "${SP}evidence_except(n:%s, ex:%s, d:%d)\n", 
	       $node_name, $exclude_node, $depth);

    my($num_values) = &get_entry(\%node_num_values, $node_name, 2);
    my(@dist);

    # If evidence exists for the node, the result is a distribution
    # with P(X=evidence_value) = 1.0 and P(X<>evidence_value) = 0.0
    my($i, $j);
    my($value) = &get_entry(\%node_evidence, $node_name, "");
    if ($value ne "") {
	@dist = (0) x $num_values;
	for ($i = 0; $i < $num_values; $i++) {
	    if ($value eq &get_entry(\%node_value, "${node_name}:$i", 1)) {
		$dist[$i] = 1.0;
		last;
	    }
	}

	&debug_print(&TL_VERBOSE, "${SP}evidence_except(@_) => (@dist)\n");
	return (@dist);
    }

    my(@Y) = &my_split(&get_entry(\%node_children, $node_name, ""));
    my(@exclude) = ($exclude_node);
    @Y = &difference(\@Y, \@exclude) if ($#Y >= 0);
    my($num_children) = $#Y + 1;
    if ($num_children == 0) {
	@dist = (1/$num_values) x $num_values;
    }
    else {
	@dist = (1) x $num_values;
	my($child);
	foreach $child (@Y) {
	    my($num_child_values) = &get_entry(\%node_num_values, $child, 2);
	    my(@evidence) = &evidence_except($child, "", $depth+1);
	    my($parents) = &get_entry(\%node_cond_vars, $child, "");

	    # Form the distribution of the node values
	    for ($i = 0; $i < $num_values; $i++) {
		my(@node_prob) = &predictive_support($child, 
		      $num_child_values, $parents, $node_name, $i, $depth + 1);

		# Form the distribution of the node values
		my($child_support) = 0;
		for ($j = 0; $j < $num_child_values; $j++) {
		    &debug_out(&TL_VERY_DETAILED, "${SP}$i,$j: %.3f * %.3f\n", $evidence[$j], $node_prob[$j]);
		    $child_support += $evidence[$j] * $node_prob[$j];
		}
		$dist[$i] *= $child_support;
		&debug_out(&TL_VERY_DETAILED, "${SP}P(%s = %s) = %.3f\n",
			   $node_name, &get_entry(\%node_value, "${node_name}:$i", 1), 
			   $dist[$i]);
	    }
	}
# 	for ($i = 0; $i < $num_values; $i++) {
# 	    &debug_out(6, "${SP}P(%s = %s) = %.3f\n",
# 		   $node_name, &get_entry(\%node_value, "${node_name}:$i", 1), 
# 		   $dist[$i]);
# 	}
    }
    &debug_out(&TL_VERBOSE, "${SP}evidence_except(@_) => (%s)\n",
	        &format_numbers(@dist));

    return (@dist);
}


# sub predictive_support(node, #values, parents, fixed_node, fixed_value_index)
#
# Calculates the probability of a node (X) given evidential support for parents
#      \sum_u P(X|u) \product_i P(u_i|E_{U_i\X})
#
#      where u ranges over the configurations for the node's parents
#
#      Ex: X=Alarm: u=(Burglary=b, Earthquake=e) for (b,e) in {00, 01, 10, 11}
#
# One of the parent nodes can be fixed at a given value, in which case the
# summation is over a subset of the parent configurations.
#
#      Ex: Earthquake=0: u=(b,0) (i.e., (b,e) in {00, 10}
#
sub predictive_support {
    my($node, $num_values, $parents, $fixed_node, $fixed_value_pos, $depth) 
	= @_;
    my($i,$j,$p);
    my($SP) = "    " x $depth;
    ## &debug_out(5, "${SP}predictive_support(%s)\n", join(':', @_));
    &debug_out(&TL_VERBOSE, "${SP}predictive_support(n:%s, #v:%d, p:'%s', fn:%s, fvp:%d, d:%d)\n", 
       $node, $num_values, $parents, $fixed_node, $fixed_value_pos, $depth);

    my(%node_support);
    my(@node_prob) = (0) x $num_values;
    my(@index);
    my(@num_values);

    # Get the information about each parent
    my(@parents) = &my_split($parents);
    my($fixed_node_pos) = -1;
    my($num_parents) = $#parents + 1;
    my($total_entries) = 1;
    for ($p = 0; $p < $num_parents; $p++) {
	my($parent) = $parents[$p];
	$index[$p] = 0;
	$num_values[$p] = &get_entry(\%node_num_values, $parent, 2);
	if ($parent eq $fixed_node) {
	    $fixed_node_pos = $p;
	    $index[$p] = $fixed_value_pos;
	    $num_values[$p] = 1;
	}
	else {
	    my(@support) = &support_except($parent, $node, $depth+1);
	    for ($i = 0; $i <= $#support; $i++) {
		$node_support{"$parent:$i"} = $support[$i];
	    }
	}
	$total_entries *= $num_values[$p];
    }
    $index[$fixed_node_pos] = $fixed_value_pos if ($fixed_node_pos != -1);

    # Combine the support of each configuration of parent values
    my($entry);
    for ($entry = 0; $entry < $total_entries; $entry++) {
	my(@prob) = &my_split(&get_entry(\%node_cond_prob, 
					 "${node}:@index", ""));
	# Calculate the joint distrubution of parent configuration
	my($parent_prob) = 1;
	for ($i = 0; $i < $num_parents; $i++) {
	    next if ($i == $fixed_node_pos);
	    $parent_prob *= &get_entry(\%node_support, 
				       "$parents[$i]:$index[$i]", 0);
	}

	# Calculate probability of each value for the node given
	# the parent configuration
	for ($i = 0; $i < $num_values; $i++) {
	    &debug_out(&TL_VERY_DETAILED, "${SP}$i: %.3f * %.3f\n", $prob[$i], $parent_prob);
	    $node_prob[$i] += $prob[$i] * $parent_prob;
	}
	
	# Increment the index values from right to left.
	# If an index wraps-around, continue with one to the left.
	for ($j = $#index; $j >= 0; $j--) {
	    next if ($j == $fixed_node_pos);
	    $index[$j] = (1 + $index[$j]) % $num_values[$j];
	    last if ($index[$j] > 0);
	}
    }
    &debug_out(&TL_VERBOSE, "${SP}predictive_support(@_) => (%s)\n",
	       &format_numbers(@node_prob));

    return (@node_prob);
}


# simulate(): perform stochastic simulation to determine the distribution
# This is based on Pearl's stochastic simulation technique, as described
# in [Hrycej 90] (see [Pearl 87] for an in-depth discussion).
#
# Stochastic Simulation of a Bayesian network:
# Set nonclamped variables to arbitrary values and then iteratively
# 1. Choose a nonclamped variable
# 2. Compute it's probability distribution given the current values
#    of neighbour variables:
#       P(x | w_x) = a P(x | u_x) \product_{j} P[y_j | f_j(x)]
#    where w_x is configuration of nodes excluding node x
#          u_x is the configuration of the node x' parents
#          y_x are the children of node x
#          f_j(x) is configuration of x and other parents of child j (of x)
# 3. Take a random sample from this distribution
# 4. Set the variable to the value sampled
# Then compute the posterior probability of a variable as either
# a) faction of times the variable equals "true" or b) average of
# distributions of step 2.
#
sub simulate {
    &debug_print(&TL_VERBOSE, "simulate()\n");
    my ($i, $j, $num_nodes);

    # Set all the nodes to random initial values (actually indices).
    # Also, initialize counters and supporting data structures.
    &determine_children();
    @node = keys(%node_num_values);
    &assert('$#node > -1');
    $num_nodes = $#node + 1;
    for ($i = 0; $i < $num_nodes; $i++) {
	my($value_pos);
	# If evidence is available, use that for initial value
	my($value) = &get_entry(\%node_evidence, $node[$i], "");
	if ($value ne "") {
	     $value_pos = &get_value_index($node[$i], $value);
	}

	# Otherwise, randomly select a value for the node
	else {
	    my($num_values) = &get_entry(\%node_num_values, $node[$i]);
	    my($index) = int(rand() * $num_values);

	    $value_pos = &get_entry(\%node_index, "$node[$i]:$index");
	}
	$node_index{$node[$i]} = $value_pos;
	&debug_print(&TL_VERBOSE, "Initial node values:\n");
	&debug_print(&TL_VERBOSE, "$node[$i]: $value_pos\n");
    }

    # Perform n iterations of randomly assigning each node a value based
    # on the values of it's neighbors.
    #
    for ($i = 1; $i <= $num_iters; $i++) {
	&debug_out(&TL_VERBOSE, "%s\n", "-" x 78);
	&debug_print(&TL_VERBOSE, "iteration $i\n");

	# Select a new value for each of the variables, excluding
	# evidence nodes.
	for ($j = 0; $j < $num_nodes; $j++) {
	    my($new_value) = &select_new_value($node[$j], \%node_index);

	    &incr_entry(\%node_value_count, "$node[$j]:$new_value");
	    $node_index{$node[$j]} = $new_value;
	}
    }

    # Set each node posterior distribution based on proportions of
    # counts that each of its values received.
    &debug_print(&TL_BASIC, "# Posterior probability via Stochastic Simulation");
    &debug_out(&TL_BASIC, " (%d iterations)\n", $num_iters);
    &debug_print(&TL_BASIC, "#\n");
    &debug_print(&TL_BASIC, "# Node\tIndex\tProb\n");
    my($results_a, $results_b) = ("", "");
    for ($i = 0; $i < $num_nodes; $i++) {
	my(@prob, @prob_b);
	my($num_values) = &get_entry(\%node_num_values, $node[$i]);
	for ($j = 0; $j < $num_values; $j++) {
	    # Determine probability using method A (frequency proportion)
	    my($count) = &get_entry(\%node_value_count, "$node[$i]:$j");
	    push (@prob, $count / $num_iters);
	    &debug_out(&TL_BASIC, "%s\t%d\t%.3f\n", $node[$i], $j, $prob[$j]);

	    # Determine probability using method B (distribution average)
	    my ($total_prob) = &get_entry(\%node_total_prob, "$node[$i]:$j");
	    push (@prob_b, $total_prob / $num_iters);
	}
	$results_a .= "$node[$i] distribution: (@prob)\n";
	$results_b .= "$node[$i] distribution: (@prob_b)\n";
    }

    # Display the results in a alternative format
    &debug_out(&TL_DETAILED, "Method A Simulation:\n%s\n", $results_a);
    &debug_out(&TL_DETAILED, "Method B Simulation:\n%s\n", $results_b);
}


# get_value_index(node_name, value)
#
# Returns the index for the value of the node or -1 if not applicable.
#
sub get_value_index {
    my($node_name, $value) = @_;
    &debug_print(&TL_VERY_DETAILED, "get_value_index(@_)\n");
    my($index) = -1;

    # Iterate through the nodes values checking for a match
    my($num_values) = &get_entry(\%node_num_values, $node_name, 2);
    my($i);
    for ($i = 0; $i < $num_values; $i++) {
	if ("" eq &get_entry(\%node_value, "${node_name}:$i", "")) {
	    $node_value{"${node_name}:$i"} = $i;
	}
	if ($value eq &get_entry(\%node_value, "${node_name}:$i", "")) {
	    $index = $i;
	    last;
	}
    }

    return ($index);
}


# select_new_value(node, node_hash_index_ref)
#
# Randomly select a new value for the node based on the values for
# its neighbors (specifically, its parents).
# TODO: try to reduce redundancies between this and predictive_support()
#
# NOTE: maintains node_total_prob assoc array for method B probability
# estimation
#
sub select_new_value {
    my($node_name, $node_index_ref) = @_;
    &debug_print(&TL_VERY_DETAILED, "select_new_value(@_)\n");
    my(@index);
    my($num_values) = &get_entry(\%node_num_values, $node_name, 2);
    my(@node_prob);

    # Keep the "clamped" value for evidence nodes
    my($current_value) = ${$node_index_ref}{$node_name};
    if (&get_entry(\%node_evidence, $node_name, "") ne "") {
	return ($current_value);
    }

    # Determine the current parent configuration.
    my(@parents) = &my_split(&get_entry(\%node_cond_vars, $node_name, ""));
    my($num_parents) = $#parents + 1;
    my($i);
    for ($i = 0; $i < $num_parents; $i++) {
	$index[$i] = &get_entry($node_index_ref, $parents[$i]);
    }

    # Calculate the distribution for this configuration.
    # The parents are considered as given, so the probability is simply
    # the current entry from the conditional probability table (CPT).
    my(@prob);
    if ($num_parents > 0) {
	@prob = &my_split(&get_entry(\%node_cond_prob, 
				     "${node_name}:@index", ""));
    }
    else {
	@prob = &my_split(&get_entry(\%node_prior_prob, $node_name, ""));
    }
    my(@children) = &my_split(&get_entry(\%node_children, $node_name, ""));
    my($total) = 0.0;
    for ($i = 0; $i < $num_values; $i++) {
	# Calculate the joint distribution for the children configuration
	my($child_prob) = 1.0;
	my($child);
	foreach $child (@children) {
	    $child_prob *= &calc_child_prob($child, $node_index_ref, 
					    $node_name, $i);
	}
	$prob[$i] *= $child_prob;
	$total += $prob[$i];
    }

    # Normalize the probabilities. Also, record for later method B averaging.
    $total += 0.000001 if ($total == 0);
    for ($i = 0; $i < $num_values; $i++) {
	$prob[$i] /= $total;
	&incr_entry(\&node_total_prob, "${node_name}:$i", $prob[$i]);
    }
    &debug_print(&TL_VERY_DETAILED, "$node_name(@index): (@prob)\n");

    # Select the value to use (random value from distribution)
    my($mass) = rand();
    my($cum_prob) = 0.0;
    my($value_pos) = 0;
    for ($i = 0; $i < $num_values; $i++) {
	$cum_prob += $prob[$i];
	if ($cum_prob >= $mass) {
	    $value_pos = $i;
	    last;
	}
    }
    &debug_print(&TL_VERY_DETAILED, "select_new_value($node_name) => $value_pos\n");
    &debug_out(&TL_VERBOSE, "$node_name: %s\n", 
	       &get_entry(\%node_value, "${node_name}:${value_pos}", ""));

    return ($value_pos);
}


# calc_child_prob(node_name, hash_index_ref, parent_node, parent_value_pos)
#
# Calculate the probability of the child node given that one of its
# parents has the specified value (indicated by position).
#
sub calc_child_prob {
    my ($node_name, $node_index_ref, $parent_node, $parent_pos) = @_;
    &debug_print(&TL_VERY_DETAILED, "calc_child_prob(@_)\n");

    # Determine the current parent configuration.
    my(@parents) = &my_split(&get_entry(\%node_cond_vars, $node_name, ""));
    my($num_parents) = $#parents + 1;
    my($i);
    my(@index);
    for ($i = 0; $i < $num_parents; $i++) {
	if ($parents[$i] eq $parent_node) {
	    $index[$i] = $parent_pos;
	}
	else{
	    $index[$i] = &get_entry($node_index_ref, $parents[$i]);
	}
    }
    my(@prob) = &my_split(&get_entry(\%node_cond_prob, 
				     "${node_name}:@index", ""));
    my($pos) = ${$node_index_ref}{$node_name};
    my($prob) = $prob[$pos];
    &debug_out(&TL_VERY_DETAILED, "calc_child_prob($node_name) => %.3f\n", $prob);

    return ($prob);
}

# format_numbers(array): format the array numbers with fixed point precision
# The result is returned as a string.
# TODO: re-implement as 'map { &round } @_;'
#
sub format_numbers {
    my(@array) = @_;
    my($nums) = "";

    # Update the array in place
    foreach my $num (@array) {
	$nums .= sprintf "%.3f ", $num;
    }
    $nums = &trim($nums);

    return ($nums);
}
