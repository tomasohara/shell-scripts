# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
# belief_net.perl: Perl module for producing belief networks in the
# formats required for BELIEF and MSBN (Microsoft Belief Network).
#
# TODO: convert into a class-based repesentation, in order to cut
# down on the redundancies among instances
#
# Fall 1997
# Tom O'Hara
# New Mexico State University
#
# Copyright (c) 2004 Tom O'Hara and New Mexico State University.
# Freely available via GNU General Public License (see GNU_public_license.txt).
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir);
    require 'common.perl';
    use vars qw/$script_name/;
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
no strict "refs";		# to allow for symbolic file handles
#
use vars qw/$belief $use_BELIEF $hugin $use_HUGIN $msbn $use_MSBN
    $bnif $use_BNIF $netica $use_NETICA $noname $use_NONAME $belief_format
    $use_random_coords/;


# Check for option specifying which network format to use
# -xyz or -use_XYZ
# TODO: use the standard argument parsing so that case can be ignored easier
&init_var(*belief, &FALSE);		# alias for -use_BELIEF
&init_var(*hugin, &FALSE); 		# alias for -use_HUGIN
&init_var(*msbn, &FALSE);		# alias for -use_MSBN
&init_var(*bnif, &FALSE);		# alias for -use_BNIF
&init_var(*netica, &FALSE);		# alias for -use_NETICA
&init_var(*noname, &FALSE);		# alias for -use_NONAME
#
&init_var(*use_BELIEF, $belief);	# use Russel Almonds belief format
&init_var(*use_HUGIN, $hugin);		# use Hugin's .net format
&init_var(*use_MSBN, $msbn);		# use Microsoft MSBN format (version 1)
&init_var(*use_BNIF, $bnif);		# use Bayesian Network Interchange Format
&init_var(*use_NETICA, $netica);	# use Netica's format
&init_var(*use_NONAME, $noname);	# use TPO's ascii format
#
&init_var(*belief_format, "");		# one of {BELIEF, HUGIN, ..., NONAME}
	# NOTE: belief format has priority over -use_XYZ

&init_var(*use_random_coords, &TRUE);	# random node placement for Hugin
## $use_BELIEF = &TRUE if (($use_MSBN + $use_BELIEF + $use_HUGIN + $use_NONAME) == 0);

sub belief_network_options { "[-belief_format=BELIEF|HUGIN|MSBN|BNIF|NETICA|NONAME]"; }


# Global variables
#
our(%bn_node_declaration, %bn_node_cond_vars, %bn_node_values, 
    %bn_node_num_values, $last_node_name, %belief_extensions, @max_index);
my($ext);
my($print_header_fn, $print_trailer_fn, $print_node_declaration_fn,
   $print_prior_probability_fn, $print_cond_prob_header_fn, $print_cond_prob_entry_fn,
   $print_cond_prob_trailer_fn);

#------------------------------------------------------------------------------

# init_belief_network(): Initializae belief network support. This first checks
# for the desired format and then created overrides for the generic interface
# into the specified functions (e.g., &print_header -> &print_BNIF_header).
# NOTE: -belief_format has priority over -use_XYZ
#
sub init_belief_network {
    &debug_print(&TL_DETAILED, "init_belief_network(@_)\n");
    %belief_extensions = ("BELIEF",  ".bel",
			  "HUGIN", ".net",
			  "MSBN", ".dsc",
			  "BNIF", ".bif",
			  "NETICA", ".dnet",
			  "NONAME",  ".bnet");
    my(@belief_types) = keys(%belief_extensions);

    my($formats_desired) = ($use_BELIEF + $use_HUGIN + $use_NETICA 
			    + $use_MSBN + $use_BNIF + $use_NONAME);
    if ($belief_format eq "") {
	$use_BNIF = &TRUE if ($formats_desired == 0);
	foreach my $format (keys(%belief_extensions)) {
	    $belief_format = $format if eval "\$use_$format";
	}
	&assert(($use_BELIEF + $use_HUGIN + $use_NETICA + $use_MSBN + $use_BNIF + $use_NONAME) == 1);
    }
    else {
	&assert(find(\@belief_types, $belief_format) != -1);
	eval "\$use_${belief_format} = &TRUE";
    }
    &debug_print(&TL_DETAILED, "belief_format=${belief_format}\n");
    &debug_out(&TL_DETAILED, "use BELIEF/HUGIN/MSBN/BNIF/NETICA/NONAME = %d/%d/%d/%d/%d/%d\n",
	       $use_BELIEF, $use_HUGIN, $use_MSBN, $use_BNIF, $use_NETICA, $use_NONAME);

    # Determine appropiate functions to use for the different "methods"
    # TODO: use Perl's builr-in object-oriented support for this
    $print_header_fn = eval "\\&print_${belief_format}_header";
    $print_trailer_fn = eval "\\&print_${belief_format}_trailer";
    $print_node_declaration_fn = eval "\\&print_${belief_format}_node_declaration";
    $print_prior_probability_fn = eval "\\&print_${belief_format}_prior_probability";
    $print_cond_prob_header_fn = eval "\\&print_${belief_format}_cond_prob_header";
    $print_cond_prob_entry_fn = eval "\\&print_${belief_format}_cond_prob_entry";
    $print_cond_prob_trailer_fn = eval "\\&print_${belief_format}_cond_prob_trailer";
    &debug_print(&TL_VERBOSE, "exit init_belief_network()\n");

    return;
}

# Subroutine wrappers into the appropriat method function for type of network

sub print_header { &$print_header_fn(@_); }

sub print_trailer { &$print_trailer_fn(@_); }

sub print_node_declaration { &$print_node_declaration_fn(@_); }

sub print_prior_probability { &$print_prior_probability_fn(@_); }

sub print_cond_prob_header { &$print_cond_prob_header_fn(@_); }

sub print_cond_prob_entry { &$print_cond_prob_entry_fn(@_); }

sub print_cond_prob_trailer { &$print_cond_prob_trailer_fn(@_); }

#------------------------------------------------------------------------------

# get_belief_extension(): get the file extension for the current belief format
#
sub get_belief_extension {
    $ext = $belief_extensions{$belief_format};
}
	
#------------------------------------------------------------------------------

sub print_MSBN_header {
    my($name) = @_;
    &debug_print(&TL_VERY_DETAILED, "print_MSBN_header(@_)\n");

    print "belief network \"$name\"\n\n";
    return;
}


sub print_MSBN_trailer {

    return;
}


# print_MSBN_node_declaration(headword, node_label, [node_type=binary])
#
# Print the node declaration for a headword. By default, this declares the
# node as a binary node of the given type (hypothesis or informational).
#
# The node type is either a predefined type name (eg, binary) or a list
# of the value names for the type.
#
sub print_MSBN_node_declaration {
    my($node, $node_label, $node_type) = @_;
    $node_type = "binary" if (!defined($node_type));
    &debug_print(&TL_VERY_DETAILED, "print_MSBN_node_declaration(@_)\n");

    # Derive a node name with punctuation replaced with underscores
    # TODO: use the make_node_name function from lexrel2network.perl
    my($node_name) = $node;
    $node_name =~ s/[\#:-]/_/g;

    if (&get_entry(\%bn_node_declaration, $node_name, -1) >= 0) {
	&debug_print(&TL_DETAILED, "WARNING: second declaration for $node_name ignored\n");
	return;
    }
    &incr_entry(\%bn_node_declaration, $node_name, 1);
    &assert($bn_node_declaration{$node_name} == 1);

    # Determine the list of values for the type
    my(@type_values) = ('"False"', '"True"');
    if ($node_type ne "binary") {
	$node_type =~ s/(\S+)/"$1"/g;
	@type_values = split(/\s+/, $node_type);
    }
    my($type_values) = join(", ", @type_values);
    my($num_values) = (1 + $#type_values);

    # Print the node declaration
    print <<END_NODE_DECL;

node $node_name
{
    name: "$node";
    type: discrete[$num_values] =
    {
	$type_values
    };
    label: $node_label;
}

END_NODE_DECL

    return;
}



# print_MSBN_prior_probability(node_name, node_probability, ...)
#
# Print the MSBN specification for a node's prior probability.
#
# NOTE: this accepts a single probability for backward compatibility
#
sub print_MSBN_prior_probability {
    my($node, $probability) = @_;
    &debug_print(&TL_VERY_DETAILED, "print_MSBN_prior_probability(@_)\n");

    # Determine the list of probabilities from the string spec
    my(@probability) = split(/\s+/, &trim($probability));
    if (!defined($probability[1])) {
	my($inv_probability) = 1.0 - $probability[0];
	$probability[0] = $inv_probability;
	$probability[1] = 1.0 - $inv_probability;
    }
    my($node_name) = $node;
    $node_name =~ s/[\#:-]/_/g;

    # Keep a record for later sanity checks
    &incr_entry(\%bn_node_declaration, $node_name, -1);
    if ($bn_node_declaration{$node_name} != 0) {
	&warning("bad value for node_declaration{$node_name}: %s\n",
		 $bn_node_declaration{$node_name});
    }
    &assert($bn_node_declaration{$node_name} == 0);

    printf "\nprobability($node_name)\n{\n    %s;\n}\n\n",
        join(", ", @probability);

    return;
}


# print_MSBN_cond_prob_header(node, conditional_vars, [is_xor=0])
#
# Prints the MSBN header for a conditional probability. 
#
# ex:   probability(noun_activity_2 | noun_order, noun_weaving)
#
sub print_MSBN_cond_prob_header {
    my($node_name, $cond_var_list_ref, $is_xor) = @_;
    $is_xor = &FALSE if (!defined($is_xor));
    &debug_print(&TL_VERY_DETAILED, "print_MSBN_cond_prob_header(@_)\n");
    my($cond_var_list) = join(', ', @$cond_var_list_ref);

    &incr_entry(\%bn_node_declaration, $node_name, -1);
    if ($bn_node_declaration{$node_name} != 0) {
	&warning("bad value for node_declaration{$node_name}: %s\n",
		 $bn_node_declaration{$node_name});
    }
    &assert($bn_node_declaration{$node_name} == 0);

    print "\n";
    print "probability($node_name | $cond_var_list)\n";
    print "{\n";
    return;
}


# print_MSBN_cond_prob_trailer(node, [is_xor=0])
#
# Prints the MSBN trailer for a conditional probability. 
#
# ex:   }
#
sub print_MSBN_cond_prob_trailer {
    my($node_name, $is_xor) = @_;    
    &debug_print(&TL_VERY_DETAILED, "print_MSBN_cond_prob_trailer(@_)\n");
    $is_xor = &FALSE if (!defined($is_xor));

    print "}\n";
    print "\n";
    return;
}


# print_MSBN_cond_prop_entry(value_list, index_list, [is_xor=0])
#
# Prints one entry of the MSBN conditional probability table.
#
# ex:      (0, 1): 0.909, 0.091;
#
sub print_MSBN_cond_prob_entry {
    my($cond_value_ref, $index_ref, $is_xor) = @_;
    &debug_print(&TL_VERY_DETAILED, "print_MSBN_cond_prob_entry(@_)\n");
    $is_xor = &FALSE if (!defined($is_xor));
    my($cond_value) = join(', ', @$cond_value_ref);
    my($index_spec) = join(', ', @$index_ref);
    &debug_print(&TL_VERY_DETAILED, "cond_value=$cond_value index=$index_spec\n");

    printf "    ($index_spec): $cond_value;\n";
    
    return;
}


#------------------------------------------------------------------------------
# Support for Bayesian network Interchange Format
# note: this is similar to MSBN's format

sub print_BNIF_header {
    my($name) = @_;
    &debug_print(&TL_VERY_DETAILED, "print_BNIF_header(@_)\n");

    print "network $name {\n}\n\n\n";
    return;
}


sub print_BNIF_trailer {

    return;
}


# print_BNIF_node_declaration(headword, node_label, [node_type=binary])
#
# Print the node declaration for a headword. By default, this declares the
# node as a binary node of the given type (hypothesis or informational).
#
# The node type is either a predefined type name (eg, binary) or a list
# of the value names for the type.
#
# Example:
#    variable FanBelt{
#        type discrete[3] { "Ok", "Slipping", "Broken" };
#    }
#
sub print_BNIF_node_declaration {
    my($node, $node_label, $node_type) = @_;
    $node_type = "binary" if (!defined($node_type));
    &debug_print(&TL_VERY_DETAILED, "print_BNIF_node_declaration(@_)\n");

    # Derive a node name with punctuation replaced with underscores
    # TODO: use the make_node_name function from lexrel2network.perl
    my($node_name) = $node;
    $node_name =~ s/[\#:-]/_/g;

    if (&get_entry(\%bn_node_declaration, $node_name, -1) >= 0) {
	&debug_print(&TL_DETAILED, "WARNING: second declaration for $node_name ignored\n");
	return;
    }
    &incr_entry(\%bn_node_declaration, $node_name, 1);
    &assert($bn_node_declaration{$node_name} == 1);

    # Determine the list of values for the type
    # NOTE: extra space added to True for readability
    # TODO: use T and F for better readability
    my(@type_values) = ("False", "True ");
    if ($node_type ne "binary") {
	$node_type =~ s/(\S+)/"$1"/g;
	@type_values = split(/\s+/, $node_type);
    }
    my($type_values) = join(", ", @type_values);
    my($num_values) = (1 + $#type_values);

    # Record node values for later use in prob. tables
    $bn_node_values{$node_name} = $type_values;

    # Store the values individually for later use
    my($i);
    for ($i = 0; $i <= $#type_values; $i++) {
	$bn_node_values{"$node_name:$i"} = $type_values[$i];
    }

    # Print the node declaration
    print <<END_NODE_DECL;

variable $node_name
{
    property name "$node";
    type discrete[$num_values]
    {
	$type_values
    };
}

END_NODE_DECL

    return;
}



# print_BNIF_prior_probability(node_name, node_probability, ...)
#
# Print the BNIF specification for a node's prior probability.
#
# NOTE: this accepts a single probability for backward compatibility
#
# Example:
#     probability ( GasInTank ) {
#         table 0.5 0.5;	// False, True
#     }
#
sub print_BNIF_prior_probability {
    my($node, $probability) = @_;
    &debug_print(&TL_VERY_DETAILED, "print_BNIF_prior_probability(@_)\n");

    # Determine the list of probabilities from the string spec
    my(@probability) = split(/\s+/, &trim($probability));
    if (!defined($probability[1])) {
	my($inv_probability) = 1.0 - $probability[0];
	$probability[0] = $inv_probability;
	$probability[1] = 1.0 - $inv_probability;
    }
    my($node_name) = $node;
    $node_name =~ s/[\#:-]/_/g;

    # Keep a record for later sanity checks
    &incr_entry(\%bn_node_declaration, $node_name, -1);
    if ($bn_node_declaration{$node_name} != 0) {
	&warning("bad value for node_declaration{$node_name}: %s\n",
		 $bn_node_declaration{$node_name});
    }
    &assert($bn_node_declaration{$node_name} == 0);

    printf "\nprobability($node_name)\n{\n    table %s;  // %s\n}\n\n",
        join(", ", @probability), $bn_node_values{$node_name};

    return;
}


# print_BNIF_cond_prob_header(node, conditional_vars, [is_xor=0])
#
# Prints the BNIF header for a conditional probability. 
#
# example:
#     probability(noun_activity_2 | noun_order, noun_weaving) {
#
# NOTE: uses global assoc. array (bn_node_cond_vars) for storing givens
#       uses global last_node_name to store last node encountered
#
sub print_BNIF_cond_prob_header {
    my($node_name, $cond_var_list_ref, $is_xor) = @_;
    $is_xor = &FALSE if (!defined($is_xor));
    &debug_print(&TL_VERY_DETAILED, "print_BNIF_cond_prob_header(@_)\n");
    my($cond_var_list) = join(', ', @$cond_var_list_ref);

    # Do sanity check on declarations and usage
    $last_node_name = $node_name;
    &incr_entry(\%bn_node_declaration, $node_name, -1);
    if ($bn_node_declaration{$node_name} != 0) {
	&warning("bad value for node_declaration{$node_name}: %s\n",
		 $bn_node_declaration{$node_name});
    }
    &assert($bn_node_declaration{$node_name} == 0);

    # Record conditional variables for later use
    # TODO: reconile with code for BELIEF format
    my($i);
    for ($i = 0; $i <= $#$cond_var_list_ref; $i++) {
	$bn_node_cond_vars{"$node_name:$i"} = $$cond_var_list_ref[$i];
    }

    # Print the probability table header
    print "\n";
    print "probability($node_name | $cond_var_list) {\n";
    return;
}


# print_BNIF_cond_prob_trailer(node, [is_xor=0])
#
# Prints the BNIF trailer for a conditional probability. 
#
# example:
#     }
#
sub print_BNIF_cond_prob_trailer {
    my($node_name, $is_xor) = @_;    
    &debug_print(&TL_VERY_DETAILED, "print_BNIF_cond_prob_trailer(@_)\n");
    $is_xor = &FALSE if (!defined($is_xor));

    print "}\n";
    print "\n";
    return;
}


# print_BNIF_cond_prop_entry(value_list, index_list, [is_xor=0])
#
# Prints one entry of the BNIF conditional probability table.
#
# example:
#     (False, True): 0.909, 0.091;
#
# NOTE: uses global assoc. array (bn_node_cond_vars) for storing givens
#       uses global last_node_name to store last node encountered
#
sub print_BNIF_cond_prob_entry {
    my($cond_value_ref, $index_ref, $is_xor) = @_;
    &debug_print(&TL_VERY_DETAILED, "print_BNIF_cond_prob_entry(@_)\n");
    $is_xor = &FALSE if (!defined($is_xor));
    my($cond_value) = join(', ', @$cond_value_ref);
    my($index_spec) = join(', ', @$index_ref);
    &debug_print(&TL_VERY_DETAILED, "cond_value=$cond_value index=$index_spec\n");

    # Convert from the numeric index into the type value
    # TODO: reconile with code for BELIEF format
    my($node_name) = $last_node_name;
    my(@index_spec) = @$index_ref;
    my($i);
    for ($i = 0; $i <= $#index_spec; $i++) {
	my($index) = $index_spec[$i];
	my($var) = &get_entry(\%bn_node_cond_vars, "$node_name:$i", "?");
	$index_spec[$i] = &get_entry(\%bn_node_values, "$var:$index", "?");
    }
    $index_spec = join(', ', @index_spec);
    &debug_print(&TL_VERY_DETAILED, "index=#index_spec\n");
    printf "    ($index_spec) $cond_value;\n";
    
    return;
}


#------------------------------------------------------------------------------

sub print_BELIEF_header {
    my($name) = @_;
    &debug_print(&TL_VERY_DETAILED, "print_BELIEF_header(@_)\n");

## old: (new-rules :lexrel2network :belief t)
##

    print <<END_BELIEF_HEADER;

(new-rules :$name :prob t)
(reset-model)	;; resets model dependent values so that can be reloaded

(setq *hypotheses* nil)

END_BELIEF_HEADER

    return;
}


sub print_BELIEF_trailer {
    my($name) = @_;

    print <<END_BELIEF_TRAILER;

;;; Save graph for later reference
(setq $name *model-graph*)

END_BELIEF_TRAILER

    return;
}


# print_BELIEF_node_declaration(headword, node_type, [node_type=binary])
#
# Print the node declaration for a headword. By default, this declares the
# node as a binary node.
#
# NOTE: uses global assoc. array (node_values) for storing type values
#
# TODO: clean up creation of hypothesis list
#
sub print_BELIEF_node_declaration {
    my($node, $node_label, $node_type) = @_;
    $node_type = "binary" if (!defined($node_type));
    my($node_name) = $node;
    $node_name =~ s/[\#:-]/_/g;

    if (&get_entry(\%bn_node_declaration, $node_name, -1) >= 0) {
	&debug_print(&TL_DETAILED, "WARNING: second declaration for $node_name ignored\n");
	return;
    }
    &incr_entry(\%bn_node_declaration, $node_name, 1);
    &assert($bn_node_declaration{$node_name} == 1);

    # Determine the list of values for the type and make a record for later use
    my($type_values) = ":true-false";
    if ($node_type ne "binary") {
	$type_values = &trim($node_type);
	$type_values =~ s/(\S+)/:$1/g;
	$bn_node_values{$node_name} = $type_values;
	$type_values = "'($type_values)";
    }
    else {
	$bn_node_values{$node_name} = ":F :T";
    }

    # Store the values individually for later use
    my(@type_values) = split(/\s+/, $bn_node_values{$node_name});
    my($i);
    for ($i = 0; $i <= $#type_values; $i++) {
	$bn_node_values{"$node_name:$i"} = $type_values[$i];
    }

    # Finally, print the entry
    print "\n(defatt $node_name $type_values \"$node\")\n";
    if ($node_type eq "hypothesis") {
	print "(push 'node_${node_name} *hypotheses*)\n";
    }
    print "\n";

    return;
}


# print_BELIEF_prior_probability(node_name, node_probability, ...)
#
# Print the BELIEF specification for a node's prior probability.
#
# NOTE: this accepts an single probability for backward compatibility
#
sub print_BELIEF_prior_probability {
    my($node, $probability) = @_;
    &debug_print(&TL_VERY_DETAILED, "print_BELIEF_prior_probability(@_)\n");
    my(@probability) = split(/\s+/, &trim($probability));
    if (!defined($probability[1])) {
	my($inv_probability) = 1.0 - $probability[0];
	$probability[0] = $inv_probability;
	$probability[1] = 1.0 - $inv_probability;
    }

    # Normalize the node name
    my($node_name) = $node;
    $node_name =~ s/[\#:-]/_/g;

    # Perform sanity check on declaration/usage
    &incr_entry(\%bn_node_declaration, $node_name, -1);
    if ($bn_node_declaration{$node_name} != 0) {
	&warning("bad value for node_declaration{$node_name}: %s\n",
		 $bn_node_declaration{$node_name});
    }
    &assert($bn_node_declaration{$node_name} == 0);

    # Format and then output the probability specifications
    my($prob_spec) = "";
    my($i);
    for ($i = 0; $i <= $#probability; $i++) {
	my($value) = &get_entry(\%bn_node_values, "$node_name:$i", "?");

	## $prob_spec .= "$value $probability[$i] ";
	$prob_spec .= "    ($probability[$i] {($value)})\n";
    }
##    printf "\n(defis node_%s  (%s) \n    %s)\n\n",
##           $node_name, $node_name, $prob_spec;
    printf "\n(defpot node_%s  (%s) \n   :ps-list\n%s   )\n\n",
           $node_name, $node_name, $prob_spec;

    return;
}


# print_BELIEF_cond_prob_header(node, conditional_vars, [is_xor=0])
#
# Prints the BELIEF header for a conditional probability using the
# potential format. If the node represents an exclusive-or relationship of 
# the parents then the built-in XOR is used.
# ex:
#     (defpotcond node_effect_1 (effect_1 :given change_2 phenomenon_1)
#         :ps-list
#
# NOTE: uses global assoc. array (bn_node_cond_vars) for storing givens
#       uses global last_node_name to store last node encountered
#
sub print_BELIEF_cond_prob_header {
    my($node_name, $cond_var_list_ref, $is_xor) = @_;
    my($cond_vars) = join(' ', @$cond_var_list_ref);
    &debug_print(&TL_VERY_DETAILED, "print_BELIEF_cond_prob_header(@_)\n");

    # Do sanity check on declarations and usage
    $last_node_name = $node_name;
    &incr_entry(\%bn_node_declaration, $node_name, -1);
    if ($bn_node_declaration{$node_name} != 0) {
	&warning("bad value for node_declaration{$node_name}: %s\n",
		 $bn_node_declaration{$node_name});
    }
    &assert($bn_node_declaration{$node_name} == 0);

    # Record conditional variables for later use
    my($i);
    for ($i = 0; $i <= $#$cond_var_list_ref; $i++) {
	$bn_node_cond_vars{"$node_name:$i"} = $$cond_var_list_ref[$i];
    }

    # Print the header
    if ($is_xor == &FALSE) {
	printf "(defpotcond node_$node_name ($node_name :given $cond_vars)\n";
	printf "    :ps-list\n";
    }
    else {
	printf "(defxor node_$node_name ($cond_vars)\n";
    }

    return;
}


# print_BELIEF_cond_prob_trailer(node, [is_xor=0])
#
# Prints the BELIEF trailer for a conditional probability specification.
# This currently just outputs a closing parenthesis for the Lisp definition.
#
sub print_BELIEF_cond_prob_trailer {
    my($node_name, $is_xor) = @_;    
    $is_xor = &FALSE if (!defined($is_xor));
    &debug_print(&TL_VERY_DETAILED, "print_BELIEF_cond_prob_trailer(@_)\n");

    print "    )\n";
    print "\n";
    return;
}


# print_BELIEF_cond_prop_entry(value_list, index_list, [is_xor=0])
#
# Prints one entry of the BELIEF conditional probability table.
#
# ex:      ({(:T :F)} (0.536 {(:F)}) (0.464 {(:T)}))
#
# NOTE: uses global assoc arrays node_type_value & node_cond_vars
#
# TODO: determine whether all these brackets are really needed
#       add node_name as a parameter
# 
sub print_BELIEF_cond_prob_entry {
    my($cond_value_ref, $index_ref, $is_xor) = @_;
    &debug_print(&TL_VERY_DETAILED, "print_BELIEF_cond_prob_entry(@_)\n");
    $is_xor = &FALSE if (!defined($is_xor));

    # There's no body for XOR's so just do this for normal ones
    if ($is_xor == &FALSE) {
	my($node_name) = $last_node_name;

	# Convert from the numeric index into the type value
	my(@index_spec) = @$index_ref;
	my($i);
	for ($i = 0; $i <= $#index_spec; $i++) {
	    my($index) = $index_spec[$i];
	    my($var) = &get_entry(\%bn_node_cond_vars, "$node_name:$i", "?");
	    $index_spec[$i] = &get_entry(\%bn_node_values, "$var:$index", "?");
	}

	# Format and then output the probability specifications
	my($prob_spec) = "";
	for ($i = 0; $i <= $#$cond_value_ref; $i++) {
	    my($value) = &get_entry(\%bn_node_values, "$node_name:$i", "?");

	    $prob_spec .= "($$cond_value_ref[$i] {($value)}) ";
	}
	&debug_print(&TL_VERY_DETAILED, "prob_spec=$prob_spec index=@index_spec\n");

	printf "    ({(@index_spec)} $prob_spec)\n";
    }

    return;
}


#------------------------------------------------------------------------------

# print_HUGIN_header(name)
#
# Prints a dummy header. It seems that this section is only used for
# miscellaneous properties like the font name and size. The settings
# below were taken from the familyout sample from the Hugin Win95 demo
#
# NOTE: without these settings, the graphical display will be illegible
#       (miniscule nodes all at same location)
# TODO: determine minimal set of these required
#
sub print_HUGIN_header {
    my($name) = @_;
    &debug_print(&TL_VERY_DETAILED, "print_HUGIN_header(@_)\n");

    print <<END_HEADER;

net
{
    node_size = (80 40);
    HRUNTIME_Monitor_InitStates = "5";
    HRUNTIME_Monitor_OpenGraph = "0";
    HRUNTIME_Monitor_GraphPrecision = "100";
    HRUNTIME_Monitor_AutoUpdGraph = "0";
    HRUNTIME_Compile_ApproxEpsilon = "0.00001";
    HRUNTIME_Compile_Approximate = "0";
    HRUNTIME_Compile_Compress = "0";
    HRUNTIME_Compile_TriangMethod = "0";
    HRUNTIME_Propagate_AutoNormal = "1";
    HRUNTIME_Propagate_AutoSum = "1";
    HRUNTIME_Propagate_Auto = "0";
    HRUNTIME_Font_Italic = "0";
    HRUNTIME_Font_Weight = "400";
    HRUNTIME_Font_Size = "-12";
    HRUNTIME_Font_Name = "Arial";
    HRUNTIME_Grid_GridShow = "0";
    HRUNTIME_Grid_GridSnap = "1";
    HRUNTIME_Grid_Y = "10";
    HRUNTIME_Grid_X = "10";
}

END_HEADER

    return;
}


# print_HUGIN_trailer(name)
#
# Prints an empty trailer.
#
sub print_HUGIN_trailer {

    return;
}


# print_HUGIN_node_declaration(headword, node_type)
#
# Print the node declaration for a headword. By default, this declares the
# node as a binary node.
#
# NOTE: A position is needed to avoid having all the nodes at same position
# TODO: determine how to specify "auto-positioning"
#       -or- use AT&T's dot utility (eg, dot -Tplain graph.dot -o graph.plain)
#            for laying out the network (dot is part of graphviz, which is
#            available under CRL at /home/ursa/src/Support/graphviz/)
#
my($x_coord, $y_coord);
#
sub print_HUGIN_node_declaration {
    my($node, $node_label, $node_type) = @_;
    $node_type = "binary" if (!defined($node_type));
    &debug_print(&TL_VERY_DETAILED, "print_HUGIN_node_declaration(@_)\n");
    $x_coord = 0 if (!defined($x_coord));
    $y_coord = 0 if (!defined($y_coord));

    my($node_name) = $node;
    $node_name =~ s/[\#:-]/_/g;

    if (&get_entry(\%bn_node_declaration, $node_name, -1) >= 0) {
	&debug_print(&TL_DETAILED, "WARNING: second declaration for $node_name ignored\n");
	return;
    }
    &incr_entry(\%bn_node_declaration, $node_name, 1);
    &assert($bn_node_declaration{$node_name} == 1);

    # Use random coordinates (to help avoid link overlap)
    if ($use_random_coords) {
	$x_coord = int(rand() * 1000);
	$y_coord = int(rand() * 1000);
    }

    # Determine the list of values for the type
    my(@type_values) = ('"False"', '"True"');
    if ($node_type ne "binary") {
	$node_type =~ s/(\S+)/"$1"/g;
	@type_values = split(/\s+/, &trim($node_type));
    }
    my($type_values) = join(" ", @type_values);

    # Print the node declaration
    print <<END_NODE_DECL;

node $node_name
{
    label = "$node";
    position = ($x_coord $y_coord);
    states = ($type_values);
}

END_NODE_DECL

    # Update the global coordinate values
    $x_coord += 100;
    if ($x_coord > 500) {
        $x_coord = 0;
        $y_coord += 100;
    }

    return;
}



# print_HUGIN_prior_probability(node_name, node_probability)
#
# Print the HUGIN specification for a node's prior probability.
#
# NOTE: this accepts a single probability for backward compatibility
#
sub print_HUGIN_prior_probability {
    my($node, $probability) = @_;
    &debug_print(&TL_VERY_DETAILED, "print_HUGIN_prior_probability(@_)\n");
    my($node_name) = $node;

    # Determine the list of probabilities from the string spec
    my(@probability) = split(/\s+/, &trim($probability));
    if (!defined($probability[1])) {
	my($inv_probability) = 1.0 - $probability[0];
	$probability[0] = $inv_probability;
	$probability[1] = 1.0 - $inv_probability;
    }
    $node_name =~ s/[\#:-]/_/g;

    # Keep a record for later sanity checks
    &incr_entry(\%bn_node_declaration, $node_name, -1);
    if ($bn_node_declaration{$node_name} != 0) {
	&warning("bad value for node_declaration{$node_name}: %s\n",
		 $bn_node_declaration{$node_name});
    }
    &assert($bn_node_declaration{$node_name} == 0);

    printf "\npotential($node_name |)\n{\n    data = ( %s );\n}\n\n",
           join(" ", @probability);

    return;
}


# print_HUGIN_cond_prob_header(node, conditional_vars, [is_xor=0])
#
# Prints the HUGIN header for a conditional probability. 
#
# ex:   potential(verb_state_1 | verb_declare_1 verb_given)
#       {
#           data = (
#
sub print_HUGIN_cond_prob_header {
    my($node_name, $cond_var_list_ref, $is_xor) = @_;
    $is_xor = &FALSE if (!defined($is_xor));
    &debug_print(&TL_VERY_DETAILED, "print_HUGIN_cond_prob_header(@_)\n");
    my($cond_var_list) = join(' ', @$cond_var_list_ref);

    &incr_entry(\%bn_node_declaration, $node_name, -1);
    if ($bn_node_declaration{$node_name} != 0) {
	&warning("bad value for node_declaration{$node_name}: %s\n",
		 $bn_node_declaration{$node_name});
    }
    &assert($bn_node_declaration{$node_name} == 0);

    print "\n";
    print "potential($node_name | $cond_var_list)\n";
    print "{\n";
    print "    data = (\n";
    return;
}


# print_HUGIN_cond_prob_trailer(node, [is_xor=0])
#
# Prints the HUGIN trailer for a conditional probability. 
#
# ex:       )
#       }
#
sub print_HUGIN_cond_prob_trailer {
    my($node_name, $is_xor) = @_;    
    &debug_print(&TL_VERY_DETAILED, "print_HUGIN_cond_prob_trailer(@_)\n");
    $is_xor = &FALSE if (!defined($is_xor));

    print "    );\n";
    print "}\n";
    print "\n";
    return;
}


# print_HUGIN_cond_prob_entry(value, index_list, $is_xor)
#
# Print an entry for the conditional probability tab;e
#
# example of a complete specification:
#
#     potential (A | E B Flood) 
#     {
#        data = ( (( (1 0)       	% 000	yes  yes  yes
#                    (1 0) )     	% 001	yes  yes  no
#                  ( (1 0)       	% 010	yes  no  yes
#                    (0.99 0.01) ))     % 011	yes  no  no
#                 (( (1 0)       	% 100	no  yes  yes
#                    (0.99 0.01) )      % 101	no  yes  no
#                  ( (0.99 0.01)        % 110	no  no  yes
#                    (0.01 0.99) )) );  % 111	no  no  no
#     }
#
# NOTE: There is no need to use wierd bracketting since HUGIN inteprets
#       a flat list in row-major format.
#
sub print_HUGIN_cond_prob_entry {
    my($cond_value_ref, $index_ref, $is_xor) = @_;
    &debug_print(&TL_VERY_DETAILED, "print_HUGIN_cond_prob_entry(@_)\n");
    $is_xor = &FALSE if (!defined($is_xor));

    my($cond_value) = join(' ', @$cond_value_ref);
    my($index_spec) = join(' ', @$index_ref);
    &debug_print(&TL_VERY_DETAILED, "cond_value=$cond_value index=$index_spec\n");
    printf "        $cond_value \t%% $index_spec\n";
    
    return;
}

#------------------------------------------------------------------------------

sub print_NETICA_header {
    my($name) = @_;
    &debug_print(&TL_VERY_DETAILED, "print_NETICA_header(@_)\n");

    printf "// ~->[DNET-1]->~/n";	# required file-type indicator
    printf "\n";
    printf "// file created by %s (%s)\n", $script_name, &asctime();
    printf "\n";
    printf "bnet %s \{\n", $name;
    printf "\n";
    printf "whenchanged = %d;\n", time;
    printf "\n";

    return;
}


sub print_NETICA_trailer {

    printf "\n";
    printf "\};\n";

    return;
}


# print_NETICA_node_declaration(headword, node_label, [node_type=binary])
#
# Print the node declaration for a headword. By default, this declares the
# node as a binary node.
#
# The node type is either a predefined type name (eg, binary) or a list
# of the value names for the type.
#
sub print_NETICA_node_declaration {
    my($node, $node_label, $node_type) = @_;
    $node_type = "binary" if (!defined($node_type));
    &debug_print(&TL_VERY_DETAILED, "print_NETICA_node_declaration(@_)\n");

    my($node_name) = &make_stupid_node_name($node);
    ## $node_name =~ s/[\#:-]/_/g;

    if (&get_entry(\%bn_node_declaration, $node_name, -1) >= 0) {
	&debug_print(&TL_DETAILED, "WARNING: second declaration for $node_name ignored\n");
	return;
    }
    &incr_entry(\%bn_node_declaration, $node_name, 1);
    &assert($bn_node_declaration{$node_name} == 1);

    # Determine the list of values for the type
    my(@type_values) = ('False', 'True');
    if ($node_type ne "binary") {
	$node_type =~ s/(\S+)/s$1/g;
	@type_values = split(/\s+/, $node_type);
    }
    my($type_values) = join(", ", @type_values);
    my($num_values) = (1 + $#type_values);
    $bn_node_num_values{$node_name} = $num_values;

    # Print the node declaration
    &assert(length($node_name) < 30); 	# stupid length restriction
    print <<END_NODE_DECL;

define node C${node_name} {
    kind = NATURE;
    discrete = TRUE;
    states = ($type_values);
    };

END_NODE_DECL

    return;
}



# print_NETICA_prior_probability(node_name, node_probability, ...)
#
# Print the NETICA specification for a node's prior probability.
#
# NOTE: this accepts a single probability for backward compatibility
#
sub print_NETICA_prior_probability {
    my($node, $probability) = @_;
    &debug_print(&TL_VERY_DETAILED, "print_NETICA_prior_probability(@_)\n");

    # Determine the list of probabilities from the string spec
    my(@probability) = split(/\s+/, &trim($probability));
    if (!defined($probability[1])) {
	my($inv_probability) = 1.0 - $probability[0];
	$probability[0] = $inv_probability;
	$probability[1] = 1.0 - $inv_probability;
    }
    $probability = join(", ", @probability);
    my($node_name) = &make_stupid_node_name($node);
    ## $node_name =~ s/[\#:-]/_/g;

    # Keep a record for later sanity checks
    &incr_entry(\%bn_node_declaration, $node_name, -1);
    if ($bn_node_declaration{$node_name} != 0) {
	&warning("bad value for node_declaration{$node_name}: %s\n",
		 $bn_node_declaration{$node_name});
    }
    &assert($bn_node_declaration{$node_name} == 0);

    print <<END_NODE_DECL;

node ${node_name} (C${node_name}) {
    parents = ();
    probs = ($probability);
    };

END_NODE_DECL

    return;
}


# print_NETICA_cond_prob_header(node, conditional_vars, [is_xor=0])
#
# Prints the NETICA header for a conditional probability. 
#
# ex:   probability(noun_activity_2 | noun_order, noun_weaving)
#
# NOTE: uses global array @max_index for storing last index per parent
#
sub print_NETICA_cond_prob_header {
    my($node_name, $cond_var_list_ref, $is_xor) = @_;
    $is_xor = &FALSE if (!defined($is_xor));
    &debug_print(&TL_VERY_DETAILED, "print_NETICA_cond_prob_header(@_)\n");
    my(@cond_vars) = @$cond_var_list_ref;

    $node_name = &make_stupid_node_name($node_name);
    &incr_entry(\%bn_node_declaration, $node_name, -1);
    if ($bn_node_declaration{$node_name} != 0) {
	&warning("bad value for node_declaration{$node_name}: %s\n",
		 $bn_node_declaration{$node_name});
    }
    &assert($bn_node_declaration{$node_name} == 0);


    # Record values of maximal indices for later use in global array
    # TODO: clean up the global usage
    my($i);
    for ($i = 0; $i <= $#cond_vars; $i++) {
	$cond_vars[$i] = &make_stupid_node_name($cond_vars[$i]);
	my($num_values) = &get_entry(\%bn_node_num_values, $cond_vars[$i]);
	&assert($num_values > 1);
	$max_index[$i] = $num_values - 1;
    }
    my($cond_vars) = join(', ', @cond_vars);

    print <<END_NODE_DECL;

node ${node_name} (C${node_name}) {
    parents = ($cond_vars);
    probs = (
END_NODE_DECL

    return;
}


# print_NETICA_cond_prob_trailer(node, [is_xor=0])
#
# Prints the NETICA trailer for a conditional probability. 
#
# ex:   }
#
sub print_NETICA_cond_prob_trailer {
    my($node_name, $is_xor) = @_;    
    &debug_print(&TL_VERY_DETAILED, "print_NETICA_cond_prob_trailer(@_)\n");
    $is_xor = &FALSE if (!defined($is_xor));

    print "    );\n";
    print "};\n";
    print "\n";
    return;
}


# print_NETICA_cond_prop_entry(value_list, index_list, [is_xor=0])
#
# Prints one entry of the NETICA conditional probability table.
# Complications arise due to the stupid bracketing convention (like
# the optional one in HUGIN).
#
# ex:      (0, 1),  // 0.909, 0.091
#
# NOTE: uses global array @max_index for storing last index per parent
#
sub print_NETICA_cond_prob_entry {
    my($cond_value_ref, $index_ref, $is_xor) = @_;
    &debug_print(&TL_VERY_DETAILED, "print_NETICA_cond_prob_entry(@_)\n");
    $is_xor = &FALSE if (!defined($is_xor));
    my($cond_value) = join(', ', @$cond_value_ref);
    my($index_spec) = join(', ', @$index_ref);
    &debug_print(&TL_VERY_DETAILED, "cond_value=$cond_value index=$index_spec\n");

    # Determine amount of extra parenthesis needed for the (stupid) bracketing
    my($pre) = "";
    my($post) = "";
    my($i);
    for ($i = $#$index_ref; ($i > 0) && ($$index_ref[$i] == 0); $i--) {
        $pre .= "(";
    }
    for ($i = $#$index_ref; ($i > 0) && ($$index_ref[$i] == $max_index[$i]); $i--) {
        $post .= ")";
    }

    # Determine whether the comma separator should be added
    my($comma) = ",";
    if (($i == 0) && ($$index_ref[$i] == $max_index[$i])) {
	$comma = " ";
    }

    # Make the pre- and post- sections the same size as max possible
    my($extra);
    $extra = (($#$index_ref + 0) - length($pre));
    $pre = (" " x $extra) . $pre;
    $extra = (($#$index_ref + 0) - length($post));
    $post .= (" " x $extra);

    printf "        $pre ($cond_value) $post$comma	// $index_spec \n";
    
    return;
}


#------------------------------------------------------------------------------

# print_NONAME_header(name)
#
# Prints a dummy header. 
sub print_NONAME_header {
    my($name) = @_;
    &debug_print(&TL_VERY_DETAILED, "print_NONAME_header(@_)\n");

    print <<END_HEADER;

# No-name belief network format for $name

END_HEADER

    return;
}


# print_NONAME_trailer(name)
#
# Prints an empty trailer.
#
sub print_NONAME_trailer {

    return;
}


# print_NONAME_node_declaration(headword, node_label, [node_type=binary])
#
# Print the node declaration for a headword. By default, this declares the
# node as a binary node.
#
sub print_NONAME_node_declaration {
    my($node, $node_label, $node_type) = @_;
    $node_type = "binary" if (!defined($node_type));
    &debug_print(&TL_VERY_DETAILED, "print_NONAME_node_declaration(@_)\n");

    my($node_name) = $node;
    $node_name =~ s/[\#:-]/_/g;

    if (&get_entry(\%bn_node_declaration, $node_name, -1) >= 0) {
	&debug_print(&TL_DETAILED, "WARNING: second declaration for $node_name ignored\n");
	return;
    }
    &incr_entry(\%bn_node_declaration, $node_name, 1);
    &assert($bn_node_declaration{$node_name} == 1);

    if ($node_type ne "binary") {
	printf "T($node_name) = { $node_type } \n";
    }

    return;
}



# print_NONAME_prior_probability(node_name, node_probability)
#
# Print the NONAME specification for a node's prior probability.
#
sub print_NONAME_prior_probability {
    my($node, $probability) = @_;
    &debug_print(&TL_VERY_DETAILED, "print_NONAME_prior_probability(@_)\n");

    # Determine the list of probabilities from the string spec
    my(@probability) = split(/\s+/, &trim($probability));
    if (!defined($probability[1])) {
	&debug_print(&TL_VERBOSE, "WARNING: old prior probability spec: $probability => (@probability)\n");
	my($inv_probability) = 1.0 - $probability[0];
	$probability[0] = $inv_probability;
	$probability[1] = 1.0 - $inv_probability;
    }
    my($node_name) = $node;
    $node_name =~ s/[\#:-]/_/g;

    # Perform sanity check
    &incr_entry(\%bn_node_declaration, $node_name, -1);
    if ($bn_node_declaration{$node_name} != 0) {
	&warning("bad value for node_declaration{$node_name}: %s\n",
		   $bn_node_declaration{$node_name});
    }
    &assert($bn_node_declaration{$node_name} == 0);

    # Print the entry
    my($iggy) = shift @probability;	# ignore probability for default value
    &debug_print(&TL_VERY_VERBOSE, "ignoring prob ($iggy) for default case\n");
    printf "P($node_name) = @probability\n\n";

    return;
}


sub print_NONAME_cond_prob_header {
    my($node_name, $cond_var_list_ref, $is_xor) = @_;
    my($cond_var_list) = join(', ', @$cond_var_list_ref);
    &debug_print(&TL_VERY_DETAILED, "print_NONAME_cond_prob_header(@_)\n");

    &incr_entry(\%bn_node_declaration, $node_name, -1);
    if ($bn_node_declaration{$node_name} != 0) {
	&warning("bad value for node_declaration{$node_name}: %s\n",
		   $bn_node_declaration{$node_name});
    }
    &assert($bn_node_declaration{$node_name} == 0);

    print "P($node_name | $cond_var_list) = { \\\n";
    return;
}


sub print_NONAME_cond_prob_trailer {
    my($node_name, $is_xor) = @_;    
    $is_xor = &FALSE if (!defined($is_xor));

    print "}\n\n";
    return;
}


# print_NONAME_cond_prob_entry(value, index_list, $is_xor)
#
# Print an entry for the conditional probability table
#
# example of a complete specification:
#     P(A | E, B, Flood) = { 0 0 0 0.01   0 0.01 0.01 0.99 }
#
# NOTE: The complexity here comes from making the specification
#       less explicit, since the NONAME format is meant for
#       simplifying manual specification and thus fills in 
#       default cases: the default conditional probability (eg, P(f|t))
#       and the default parent configuration (eg, P(t|f,f)).
#
sub print_NONAME_cond_prob_entry {
    my($cond_value_ref, $index_ref, $is_xor) = @_;
    &debug_print(&TL_VERY_DETAILED, "print_NONAME_cond_prob_entry(@_)\n");
    $is_xor = &FALSE if (!defined($is_xor));
    shift @$cond_value_ref;		# ignore probability for default value
    my($cond_value) = join(' ', @$cond_value_ref);
    my($index_spec) = join(' ', @$index_ref);
    &debug_print(&TL_VERY_DETAILED, "cond_value=$cond_value index=$index_spec\n");

    # Skip the entry for the default case (all parent indices 0)
    if (($index_spec !~ /[1-9]/) && &FALSE) {
	&debug_print(&TL_VERBOSE, "skipping default case ($index_spec): ($cond_value)\n");
    }
    else {
	# NONAME spec's must all be on same "logical" line. For readability,
	# an escape character (\) can be used at the end of a physical line
	# as in csh scripts. Note that comments are removed before the
	# continuation determination, so they can occur afterwards.
	printf "    %s \\ # $index_spec\n", $cond_value;
    }

    return;
}

#------------------------------------------------------------------------------

# make_stupid_node_name(word)
#
# Ensure that the name for the node is compatible both with the
# belief software to be used and with internal conventions used
# for association lists (eg, '|' separates components of names).
#
# This just replaces special characters with underscores. Plus it
# changes noun/verb to n/v etc to accomodate Netica's stupid length
# restrictions.
#
sub make_stupid_node_name {
    my($word) = @_;

    $word =~ s/[\#:\-\~ ]/_/g;
    $word =~ s/noun_/n_/;
    $word =~ s/verb_/v_/;
    &debug_print(&TL_VERY_VERBOSE, "make_stupid_node_name(@_) => $word\n");

    return ($word);
}




#------------------------------------------------------------------------------

# Initialize things
&init_belief_network();

# Tell Perl that we loaded all right
1;
