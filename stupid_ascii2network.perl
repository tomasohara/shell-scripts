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
# dependencies must be specified.
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
# BELIEF12's version is even more= complicated:
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
#   P(public_1 | group_1, people_1) = { 0.0, 0.6, 0.4, 1.0 }
#
# NOTES:
#
# Primitive support for multivalued nodes has been added. For now, the
# specification of the probabilites is simply the list of all probabilities
# in "canonical order": prob_(0|0,...,0) prob_(0|0,...,1) prob_(M|N,...,Z)
# Ex:
# 	# need 6 probabilites for P(animal | human, dog)
#       #                        1|1,1  1|1,2  1|1,3  1|2,1  1|2,2  1|2,3
#	P(animal | human, dog) = 1.0    1.0    1.0    1.0    0.0    0.0
#
# The local() declaration is used whenever possible since this is closest
# to the lexical-scoping from traditional languages. However, local() is
# used for arrays to avoid problems with reference parameters.
#
# global variables:
#    node_num_values{<node_name>}	number of values for the node
#    node_value{<name>:<i>}		i'th value for the given node
#    node_evidence{<node_name>}		value of an evidence node
#    node_prior_prob{<node_name>}	prior probabilities of node values
#    node_cond_vars{<node_name>}	list of parents for the node
#    node_cond_prob{<node_name>:<parent_indices>} conditional probabilities
#		for the node given the parent configuration
#
# TODO: have lexrel2network use this as an "internal representation"
#       resolve problem w/ reference parameter passing of local() variables
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';
require 'belief_network.perl';

# NOTE: uncomment the following to help track down undeclared variables.
# Be prepared for a plethora of warnings. One that is important is
#    'Global symbol "xyz" requires explicit package name'
# when NOT preceded by 'Global symbol "xyz" requires explicit package name'
#
# use strict 'vars';


if (!defined($ARGV[0])) {
    local($options) = "options = " . &belief_network_options;
    local($example) = "ex: $main::script_name belief_network_file\n";

    die "\nusage: $main::script_name [options]\n\n$options\n\n$example\n\n";
}

&init_var(*main::prior_node_type, "hypothesis");
&init_var(*main::cond_node_type, "other");
&init_var(*main::simple, &FALSE);

local($prior_node_type) = $main::prior_node_type;
local($cond_node_type) = $main::cond_node_type;
local($simple) = $main::simple;
local(%node_num_values, %node_value, %node_evidence, %node_prior_prob); 
local(%node_cond_vars, %node_cond_prob, %node_children, %node_type, %node_value);
local($first_query);

&print_header("ascii2network");


*determine_conditional_probs = *determine_complex_conditional_probs;
if ($simple) {
    *determine_conditional_probs = *determine_simple_conditional_probs;
}


while (<>) {
    &dump_line();
    chop;
    if (/^\s*\#/) {
	next;			# skip comments
    }

    # Parse the prior probability specification
    if (/P\(([^ ]+)\) = (\d+(\.\d+)?)/i) {
	local($node_name, $prior_prob, $rest) = ($1, $2, $');
	local(@prob_values);

	local($type) = &get_entry(*node_type, $node_name, "binary");
	if ($type eq "binary") {
	    &print_node_declaration($node_name, $prior_node_type);
	    &print_prior_probability($node_name, $prior_prob);
	    @prob_values = (1 - $prior_prob, $prior_prob);
	}
	else {
	    local($prob_values) = "$prior_prob $rest";
	    $prob_values =~ s/[\(\)\{\}]//g;
	    $prob_values =~ s/,/ /g;
	    &print_node_declaration($node_name, $prior_node_type, $type);

	    # Determine the probability of the unmarked case (at index 0)
	    local($sum) = 0.0;
	    local($num);
	    foreach $num (split(/\s+/, $prob_values)) {
		$sum += $num;
	    }
	    if ($sum < 1.0) {
		local($value) = 1 - $sum;
		$prob_values = "$value $prob_values";
	    }

	    # Print the probaility specification
	    &print_prior_probability($node_name, $prob_values);
	}
	$node_prior_prob{"${node_name}"} = "@prob_values";
    }

    # Parse the conditional probability specification
    elsif (/P\(([^ ]+) \| ([^\(\)]+)\) = /i) {
	local($node_name, $cond_vars) = ($1, $2);
	$_ = $';

	&determine_conditional_probs($node_name, $cond_vars, $_);
    }

    # Check for the optional type-specification
    elsif (/T\((\S+)\)\s+=\s+(.*)/i) {
	local($node_name, $type_values) = ($1, $2);

	# Extract the values for the type
	$type_values =~ s/[\(\)\{\}]//g;
	$type_values =~ s/,/ /g;
	$type_values = &trim($type_values);

	# Determine the number of types
	local(@type_values) = split(/\s+/, &trim($type_values));
	local($num_types) = ($#type_values + 1);
	&debug_out(5, "$node_name: values=@type_values; num=$num_types\n");

	# Store each of the values in the array keyed by the name & index
	# note: this is one of those times when you hate Perl for its
	#       impoverished handling complex data types
	$node_num_values{$node_name} = $num_types;
	$node_type{$node_name} = $type_values;
	local($i);
	for ($i = 0; $i < $num_types; $i++) {
	    $node_value{"$node_name:$i"} = $type_values[$i];
	}
    }

    # Check for an evidence node specification
    elsif (/E\((\S+)\)\s+=\s+(\S+)/i) {
	local($node_name, $node_value) = ($1, $2);

	# Record the evidence for later use in queries
	&debug_out(3, "setting evidence of $node_name to $node_value\n");
	$node_evidence{$node_name} = $node_value;
    }

    # Check for a query command
    elsif (/Q\((\S+)\)/i) {
	local($node_name) = $1;

	local(@dist) = &query_probability($node_name);
	&debug_out(2, "The distribution of $node_name is (@dist)\n");
    }

    # Otherwise relegate to the bit bucket
    else {
	&debug_out(2, "ignoring $_\n") unless (/^\s*$/);
    }
}

&print_trailer("ascii2network");


#------------------------------------------------------------------------------


# determine_conditional_probs(node_name, given_variables, probabilities)
#
# Determine the form of the conditional probability specification for the
# node and its conditioning variables, given previous specifications about
# the variable values.
#
sub determine_simple_conditional_probs {
    local($node_name, $cond_vars, $probs) = @_;
    local(@cond_vars, @cond_prob);

    $cond_vars =~ s/\s//g;
    @cond_vars = split(/,/, $cond_vars);
    local($num_vars) = ($#cond_vars + 1);
    local($num_entries) = (2 ** $num_vars);

    # Read in the conditional dependencies. This just reads in the
    # next N numbers, where N = 2^|vars|.
    local($i) = 0;
    local($more_needed) = &TRUE;
    $_ = $probs;
    ## do {
	while (/(\d+(\.\d+)?)/) {
	    $cond_prob[$i++] = $1;
	    $_ = $';
	    $more_needed = &FALSE;
	    last if ($i == $num_entries);
	}
    ## } while ($more_needed && <>);

    # Now, create the sucker
    &output_simple_conditional_prob($node_name, *cond_vars, *cond_prob);
}


sub determine_complex_conditional_probs {
    local($node_name, $cond_vars, $probs) = @_;
    local(@cond_vars, @cond_prob);
    &debug_out(5, "determine_complex_conditional_probs(@_)\n");

    $cond_vars =~ s/\s//g;
    @cond_vars = split(/,/, $cond_vars);
    local($num_vars) = ($#cond_vars + 1);
    local($num_entries) = &get_entry(*node_num_values, $node_name, 2) - 1;
    local($var);
    foreach $var (@cond_vars) {
	local($var_values) = &get_entry(*node_num_values, $var, 2);
	$num_entries *= $var_values;
    }
    &debug_out(4, "checking for $num_entries entries\n");

    # Read in the conditional dependencies. This just reads in the
    # next N numbers, where N = |Values_1| x |Values_2| x ... |Values_N|.
    local($i) = 0;
    local($more_needed) = &TRUE;
    $_ = $probs;
    ## do {
	while (/(\d+(\.\d+)?)/) {
	    $cond_prob[$i++] = $1;
	    $_ = $';
	    $more_needed = &FALSE;
	    last if ($i == $num_entries);
	}
    ## } while ($more_needed && <>);

    # Now, create the sucker
    ## &output_complex_conditional_prob($node_name, *cond_vars, *cond_prob);
    local(@temp_cond_vars) = @cond_vars;
    local(@temp_cond_probs) = @cond_prob;
    &output_complex_conditional_prob($node_name, *temp_cond_vars, *temp_cond_probs);
}


# output_conditional_prob(node_name, given_variables, conditional_probabilities)
#
# Output the conditional probability specification for the node conditioned
# on the given variables.
#
sub output_simple_conditional_prob {
    local($node_name, *cond_vars, *cond_probs) = @_;
    &debug_out(5, "output_simple_conditional_prob(@_)\n");
    ## &debug_out(6, "cond_vars=(@cond_vars); cond_probs=(@cond_probs)\n");
    local($num_vars) = ($#cond_vars + 1);
    local($num_entries) = ($#cond_probs + 1);
    local($is_xor) = &FALSE;

    &print_node_declaration($node_name, $cond_node_type);
    &print_cond_prob_header($node_name, *cond_vars, $is_xor);
    $node_cond_vars{$node_name} = "@cond_vars";

    # Print the truth-table style entries
    #
    local($i, $j);
    for ($i = 0; $i < $num_entries; $i++) {
	local($num) = $i;
	local(@index);

	# Determine the index values for the current table entry, which
	# is equivalent to the binary representation of the current table
	# entry index.
	#
	for ($j = $num_vars - 1; $j >= 0; $j--) {
	    $index[$j] = $num % 2;
	    $num = int($num / 2);
	}

	# Print the current entry
	## &print_cond_prob_entry($cond_probs[$i], *index, $is_xor);
	local(@probs) = (1 - $cond_probs[$i], $cond_probs[$i]);
	print_cond_prob_entry(*probs, *index, $is_xor);
	$node_cond_prob{"${node_name}:@index"} = "@probs";
    }   

    &print_cond_prob_trailer($node_name, $is_xor);

    return;
}


sub output_complex_conditional_prob {
    local($node_name, *cond_vars, *cond_probs) = @_;
    local($num_vars) = ($#cond_vars + 1);
    local($num_entries) = ($#cond_probs + 1);
    local($is_xor) = &FALSE;
    &debug_out(5, "output_complex_conditional_prob(@_)\n");
    &debug_out(6, "cond_vars=(@cond_vars); cond_probs=(@cond_probs)\n");

    local($type) = &get_entry(*node_type, $node_name, "binary");
    if ($type eq "binary") {
	&print_node_declaration($node_name, $cond_node_type);
	$node_value{"$node_name:0"} = "0";
	$node_value{"$node_name:1"} = "1";
    }
    else {
	&print_node_declaration($node_name, $cond_node_type, $type);
    }
    &print_cond_prob_header($node_name, *cond_vars, $is_xor);
    $node_cond_vars{$node_name} = "@cond_vars";

    # Print the truth-table style entries
    #
    local($i, $j, $k);
    local(@value_pos);
    local($num_values) = &get_entry(*node_num_values, $node_name, 2);
    local($num_indices) = $num_entries / ($num_values - 1);
    &debug_out(4, "num_values=$num_values num_indices=$num_indices\n");

    # Print the probabilities for each set of indices
    for ($i = 0; $i < $num_vars; $i++) {
	$value_pos[$i] = 0;
    }
    for ($i = 0; $i < $num_indices; $i++) {

	# Determine the index labels
	local(@index);
	for ($j = 0; $j < $num_vars; $j++) {
	    ## local($key) = "$cond_vars[$j]:$value_pos[$j]";
	    ## $index[$j] = &get_entry(*node_value, $key, "");
	    $index[$j] = $value_pos[$j];
	}

	# Determine the probabilites
	local(@probs) = ();
	local($total) = 0.0;
	for ($k = 1; $k < $num_values; $k++) {
	    # tally the totals
	    $probs[$k] = $cond_probs[$num_indices * ($k - 1) + $i];
	    $total += $probs[$k];
	}
	$probs[0] = (1.0 - $total);

	# Print the entry
	&print_cond_prob_entry(*probs, *index, $is_xor);
	$node_cond_prob{"${node_name}:@index"} = "@probs";

	# Increment the index values position indicators from right to left.
	# If an index wraps-around, continue with one to the left.
	for ($j = ($num_vars - 1); $j >= 0; $j--) {
	    local($var) = $cond_vars[$j];
	    local($pos) = $value_pos[$j];
	    # Update the index position
	    local($num_values) = $node_num_values{$var} || 2;
	    $value_pos[$j] = (1 + $pos) % $num_values;
	    last if ($value_pos[$j] > 0);
	}
    }
    &print_cond_prob_trailer($node_name, $is_xor);

    return;
}



sub my_split {
    local($text) = @_;
    local(@list) = split(/\s+/, &trim($text));

    return (@list);
}


#------------------------------------------------------------------------------

# query_probability(node_name)
#
# Determine the probability distribution for the specified node using
# the algorithm from [Russell & Norvig 95].
#
# NOTE: This currently only handles polytrees, which are singly-connected
# graphs (i.e., single path between any two nodes).
#
sub query_probability {
    local($node_name) = @_;

    # Initialize a few things
    $first_query = &TRUE if (!defined($first_query));
    if ($first_query) {
	local($node, $parent);
	foreach $node (keys(%node_cond_vars)) {
	    foreach $parent (split(/\s+/, $node_cond_vars{$node})) {
		$node_children{$parent} = "" if (!defined($node_children{$parent}));
		$node_children{$parent} .= "$node ";
	    }
	}
	$first_query = &FALSE;
    }

    return (&support_except($node_name, ""));
}


# support_except(node_name, exclusion_node)
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
    local($node, $exclude_node) = @_;
    &debug_out(4, "support_except(@_)\n");

    local($num_values) = &get_entry(*node_num_values, $node, 2);
    local(@dist) = (1/$num_values) x $num_values;

    # If evidence exists for the node, the result is a distribution
    # with P(X=evidence_value) = 1.0 and P(X<>evidence_value) = 0.0
    local($i, $j);
    local($value) = &get_entry(*node_evidence, $node, "");
    if ($value ne "") {
	@dist = (0) x $num_values;
	for ($i = 0; $i < $num_values; $i++) {
	    if ($value == &get_entry(*node_value, "${node}:$i", "")) {
		$dist[$i] = 1.0;
		last;
	    }
	}
    }

    # Otherwise calculate support from the node's parents
    else {
	local($total) = 0;
	local(@evidence) = &evidence_except($node, $exclude_node);
	local($parents) = &get_entry(*node_cond_vars, $node, "");

	# If no parents, just incorporate priors for the node values
	if ($parents eq "") {
	    local(@prob) = &my_split(&get_entry(*node_prior_prob, $node, ""));
	    for ($i = 0; $i < $num_values; $i++) {
		&debug_out(6, "$i: $evidence[$i] * $prob[$i]\n");
		$dist[$i] = $evidence[$i] * $prob[$i];
		$total += $dist[$i];
	    }
	}

	else {
	    local(@node_prob) = &parent_support($node, $num_values, $parents,
					     "", 0);

	    # Form the distribution of the node values
	    for ($i = 0; $i < $num_values; $i++) {
		&debug_out(6, "$i: $evidence[$i] * $node_prob[$i]\n");
		$dist[$i] = $evidence[$i] * $node_prob[$i];
		$total += $dist[$i];
	    }
	}

	# Normalize the probabilities
	## &assert('$total > 0');
	for ($i = 0; $i < $num_values; $i++) {
	    $dist[$i] /= $total;
	}
    }
    &debug_out(5, "support_except(@_) => (@dist)\n");

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
#             calculate P(Z_ij | E_{Z_ij}) = Support-Except(Z_ij, Y_i)
#     return beta \product_i \sum_{y_i} P(E-_{Y_i}|Y_i) 
#                 \sum_{z_i} P(y_i|X,z_i) \product_j P(z_ij | E_{Z_ij\Y_i})
#
sub evidence_except {
    local($node_name, $exclude_node) = @_;
    &debug_out(4, "evidence_except(@_)\n");
    local($i, $j);

    local($num_values) = &get_entry(*node_num_values, $node_name, 2);
    local(@dist);
    ## local(@X) = ($node_name);

    # If evidence exists for the node, the result is a distribution
    # with P(X=evidence_value) = 1.0 and P(X<>evidence_value) = 0.0
    local($i, $j);
    local($value) = &get_entry(*node_evidence, $node_name, "");
    if ($value ne "") {
	@dist = (0) x $num_values;
	for ($i = 0; $i < $num_values; $i++) {
	    if ($value == &get_entry(*node_value, "${node_name}:$i", 1)) {
		$dist[$i] = 1.0;
		last;
	    }
	}

	&debug_out(5, "evidence_except(@_) => (@dist)\n");
	return (@dist);
    }

    local(@Y) = &my_split(&get_entry(*node_children, $node_name, ""));
    local(@exclude) = ($exclude_node);
    @Y = &difference(*Y, *exclude) if ($#Y >= 0);
    local($num_children) = $#Y + 1;
    if ($num_children == 0) {
	@dist = (1/$num_values) x $num_values;
    }
    else {
	@dist = (1) x $num_values;
	local($child);
	foreach $child (@Y) {
	    local($num_child_values) = &get_entry(*node_num_values, $child, 2);
	    local(@evidence) = &evidence_except($child, "");
	    local($parents) = &get_entry(*node_cond_vars, $child, "");

	    # Form the distribution of the node values
	    for ($i = 0; $i < $num_values; $i++) {
		local(@node_prob) = &parent_support($child, $num_child_values,
						 $parents, $node_name, $i);

		# Form the distribution of the node values
		local($child_support) = 0;
		for ($j = 0; $j < $num_child_values; $j++) {
		    &debug_out(6, "$i,$j: $evidence[$j] * $node_prob[$j]\n");
		    $child_support += $evidence[$j] * $node_prob[$j];
		}
		$dist[$i] *= $child_support;
	    }
	}
    }
    &debug_out(5, "evidence_except(@_) => (@dist)\n");

    return (@dist);
}


# sub parent_support(node, #values, parents, fixed_node, fixed_value_index)
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
sub parent_support {
    local($node, $num_values, $parents, $fixed_node, $fixed_value_pos) = @_;
    local($i,$j,$p);
    &debug_out(4, "parent_support(@_)\n");

    local(%node_support);
    local(@node_prob) = (0) x $num_values;
    local(@index);
    local(@num_values);

    # Get the information about each parent
    local(@parents) = &my_split($parents);
    local($fixed_node_pos) = -1;
    local($num_parents) = $#parents + 1;
    local($total_entries) = 1;
    for ($p = 0; $p < $num_parents; $p++) {
	local($parent) = $parents[$p];
	$index[$p] = 0;
	$num_values[$p] = &get_entry(*node_num_values, $parent, 2);
	if ($parent eq $fixed_node) {
	    $fixed_node_pos = $p;
	    $index[$p] = $fixed_value_pos;
	    $num_values[$p] = 1;
	}
	else {
	    local(@support) = &support_except($parent, $node);
	    for ($i = 0; $i <= $#support; $i++) {
		$node_support{"$parent:$i"} = $support[$i];
	    }
	}
	$total_entries *= $num_values[$p];
    }
    $index[$fixed_node_pos] = $fixed_value_pos if ($fixed_node_pos != -1);

    # Combine the support of each configuration of parent values
    local($entry);
    for ($entry = 0; $entry < $total_entries; $entry++) {
	local(@prob) = &my_split(&get_entry(*node_cond_prob, 
					    "${node}:@index", ""));
	# Calculate the joint distrubution of parent configuration
	local($parent_prob) = 1;
	for ($i = 0; $i < $num_parents; $i++) {
	    next if ($i == $fixed_node_pos);
	    $parent_prob *= &get_entry(*node_support, 
				       "$parents[$i]:$index[$i]", 0);
	}

	# Calculate probability of each value for the node given
	# the parent configuration
	for ($i = 0; $i < $num_values; $i++) {
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
    &debug_out(5, "parent_support(@_) => (@node_prob)\n");

    return (@node_prob);
}
