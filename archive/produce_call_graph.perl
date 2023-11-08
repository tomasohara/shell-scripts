# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# produce_call_graph.perl: Produce call graph for specified scripts.
# The result is a graph in dot format (see /home/graphling/TOOLS/GRAPHVIZ).
#
# NOTE:
# - This is not a general dependency analyzer. It relies upon calling
#   conventions in the GraphLingf
#
# TODO:
# - partition the graph into components
# - exclude known Unix commands (e.g., setenv)
# - skip through examples in the script
#   ex:     echo "nice +9 $script_name setenv_DSO_training.sh community.tag >| community.log 2>&1"
# - generalize to handling arbitrary scripts
# - add option for skipping certain scripts
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

if (!defined($ARGV[0])) {
    $options = "options = [-full_size] [-recursive] [-skiplist=files]";
    $example = "Examples:\n\n";
    $example .= "$script_name *.sh *.prl *.perl >! call_graph.dot\n\n";
    $example .= "$script_name --recursive bn_wsd_classify.sh >| bn_wsd_classify.dot\n";

    die "\nusage: $script_name [options] script\n\n$options\n\n$example\n\n";
}

&init_var(*full_size, &FALSE);	# full-page specification for GraphViz
&init_var(*recursive, &FALSE);	# recursively process call graphs
&init_var(*strict, &FALSE);	# verify script exists before adding to graph
&init_var(*skiplist, "");	# list of scripts to skip

# Isolate script names with tabs
# TODO: properly handle embedded spaces
$skiplist =~ s/([^\\]) /$1\t/g;
## $skiplist =~ s/ /\t/g;
$skiplist = "\t$skiplist\t";

# Print the GraphViz header (eg, global attributes and opening brace)
&print_graph_header("call_graph");

# Add script dependencies for each script specified on comannd line
foreach $file (@ARGV) {
    &produce_call_graph($file);
}

# Print the GraphViz trailer (eg, closing brace)
&print_graph_trailer("call_graph");

#------------------------------------------------------------------------------

# produce_call_graph(script_name, [full_path])
#
# Scan through the script to extract references to other scripts and
# command invocations. Add these as entries in the overall call graph.
#
local($script_num) = 0;
local(%processed);
#
sub produce_call_graph {
    my($name, $full_path) = @_;
    &debug_print(&TL_DETAILED, "produce_call_graph(@_)\n");
    $full_path = $name if (!defined($full_path));

    # Make sure the script hasn't already been processed
    if (defined($processed{$name})) {
	&debug_print(&TL_VERBOSE, "$name already processed\n");
	return;
    }
    $processed{$name} = &TRUE;

    # Try to open the script file
    # TODO: ignore binary files
    my($script_handle) = sprintf "SCRIPT%d", $script_num++;
    if (!open($script_handle, "<$full_path")) {
	&warning("Unable to open $full_path ($!)\n");
	return;
    }

    # Make sure the parent's ID is added to the table (in case no children)
    &get_id($name);

    # Check each line of the script for a potential reference
    # TODO: use a trace file to verify command executes
    #
    while (<$script_handle>) {
	&dump_line();
	chop;
	my($child) = "";
	s/\#.*//;		# remove comments

	# Check for shell script reference to another script
	# ex: 'nice +19 perl -Ssw ${script_dir}/bn_wsd_classify.perl $args'
	if (/(([-a-z_0-9]+)\.(perl|prl|bash|sh))\s/i) {
	    $child = $1;
	}

	# Check for perl script invocation of a command
	# ex: '&cmd("cleanup_exp.sh $WORD");'
	elsif (/(cmd|command|system|perl)\(\"([-a-z_0-9]+)/) {
	    $child = $2;
	}

	# Optionally, make sure the script exists
	# TODO: check path for script
	my($child_path) = $child;
	if ($strict) {
	    $child_path = &find_library_file($child);
	    if ($strict && (! -e $child_path)) {
		&debug_out(&TL_DETAILED, "non-existent script $child\n");
		next;
	    }
	}

	# Remove path names, etc.
	$child = &remove_dir($child_path);
	$child = &trim($child);

	# Don't process scripts on the stop list
	if ($skiplist =~ /\t$child\t/) {
	    &debug_print(&TL_DETAILED, "skipping skiplist'd script $child\n");
	    next;
	}

	# Add the reference to the call graph
	if (($child ne "") && ($child ne $name)) {
	    &print_graph_entry($name, $child);
	    if ($recursive) {
		&produce_call_graph($child, $child_path);
	    }
	}
    }
    close($script_handle);

    return;
}


# print_graph_header(graph_name)
#
# Prints the graph header needed for the dot utility.
#
sub print_graph_header {
    my($name) = @_;
    &debug_print(&TL_DETAILED, "print_graph_header(@_)\n");

    $node_id = 0;		# global id number
    print "digraph $name \{\n";

    if ($full_size == &FALSE) {
	print "\tsize=\"7.5,10\";\t\t/* fit on 8.5x11 page: margin is .5 by default */\n";
    }
    
    return;
}


# print_graph_trailer(graph_name)
#
# Prints the graph trailer needed for the dot utility.
#
sub print_graph_trailer {
    my($name) = @_;
    &debug_print(&TL_DETAILED, "print_graph_header(@_)\n");

    print "\}\n";
    return;
}


# get_id(label)
#
# Returns a graph node ID for the given label, creating an entry in the
# ID table if necessary.
#
sub get_id {
    my($label) = @_;
    &debug_print(5, "get_id(@_)\n");

    # Get the ID from the table. If not found, add a new one for the label,
    # and print the node specification.
    my($id) = &get_entry(*node_id, $label, "");
    if ($id eq "") {
	$node_id++;
	$id = sprintf "prog%d", $node_id;
	&set_entry(*node_id, $label, $id);
	printf "\t%s [label=\"%s\"];\n", $id, $label;
    }

    return ($id);
}


# print_graph_entry(parent_label, child_label)
#
# A directed link from the parent to the child is added to the graph
# (in dot format).
#
sub print_graph_entry {
    my($parent, $child) = @_;
    &debug_print(&TL_DETAILED, "print_graph_entry(@_)\n");

    # Print the link unless it was already printed
    if (&get_entry(*link, "$parent\t$child") == &FALSE) {
	printf "\t%s -> %s;\n", 
	       &get_id($parent), &get_id($child);
	&set_entry(*link, "$parent\t$child", &TRUE);
    }

    return;
}
