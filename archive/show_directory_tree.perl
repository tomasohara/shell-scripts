# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# show_directory_tree: recursively traverses the directory structure,
# displaying the subdirectory names.
#
# The result is a graph in dot format (see /home/graphling/TOOLS/GRAPHVIZ).
#
# This uses code for DOT graphs taken from produce_call_graph.perl
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

if ((defined($ARGV[0]) && ($ARGV[0] eq "help"))
    || (!defined($ARGV[0]) && &blocking_stdin())) {
    &usage();
}

&init_var(*max_depth, &MAXINT);
&init_var(*skip_graph, &FALSE);
&init_var(*full_size, &FALSE);
&init_var(*skip_links, &FALSE);

local($dirname) = $ARGV[0];
if (-d $dirname) {
    &print_graph_header("GraphLing") unless ($skip_graph);
    &show_dir_tree($dirname, $dirname, 0);
    &print_graph_trailer("GraphLing") unless ($skip_graph);
}
else {
    &error_out("must provide a directory name for the base\n");
    &usage();    
}



#------------------------------------------------------------------------------

sub usage {
    $options = "options = [-max_depth=N] [-skip_graph] [-full_size] [-skip_links]";
    $example = "ex: $script_name -max_depth=3 .\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
}

sub show_dir_tree {
    local ($dir, $path, $depth) = @_;
    &debug_out(4, "show_dir_tree(@_)\n");

    # Don't process directories that are too deep in the hierarchy
    if ($depth > $max_depth) {
	return;
    }

    # Get into the directory
    local($current_dir) = &pwd(); 	# save current directory name
    local($ok);
    &assert('(-d $dir)');
    $ok = chdir $dir;
    if (! $ok) {
	&error_out("Unable to chdir into $dir ($!)\n");
	return;
    }

    # Synchonize each file that has an RCS file
    # TODO: Also get new versions of RCS files not in current directory.
    local($file);
    foreach $file (glob("* .*")) {
	&debug_out(6, "file=$file\n");

	# Display the directory name (including symbolic links to dir's)
	if (-d $file) {
	    next if (($file eq ".") || ($file eq ".."));

	    local($tag) = "";
	    if (-l $file) {
		next if ($skip_links);
		$tag = "@";
	    }
	    if ($skip_graph) {
		printf "%s%s%s\n", ("   " x $depth), $file, $tag;
	    }
	    else {
		&print_graph_entry($dir, $path, $file,"$path/$file" );
	    }

	    # Recursively process directories that aren't symbolic links
	    if (! (-l $file)) {
		&show_dir_tree($file, "$path/$file", $depth + 1);
	    }
	}
    }

    # Restore directory
    chdir $current_dir;

    return;
}

#------------------------------------------------------------------------
# support for AT&T's DOT graph drawing utility
# TODO: cerate a separate module for this


# print_graph_header(graph_name)
#
# Prints the graph header needed for the dot utility.
#
sub print_graph_header {
    local($name) = @_;
    &debug_out(4, "print_graph_header(@_)\n");

    print "digraph $name \{\n";
    $node_id = 0;		# global id number
    if ($full_size == &FALSE) {
	print "\tsize=\"7.5,10\";\t\t/* fit on 8.5x11 page */\n";
    }
    
    return;
}


# print_graph_trailer(graph_name)
#
# Prints the graph trailer needed for the dot utility.
#
sub print_graph_trailer {
    local($name) = @_;
    &debug_out(4, "print_graph_header(@_)\n");

    print "\}\n";
    return;
}


# get_id(label)
#
# Returns a graph node ID for the given label, creating an entry in the
# ID table if necessary.
#
sub get_id {
    local($unique_name, $label) = @_;
    &debug_out(5, "get_id(@_)\n");

    # Get the ID from the table. If not found, add a new one for the label,
    # and print the node specification.
    local($id) = &get_entry(*node_id, $unique_name, "");
    if ($id eq "") {
	$node_id++;
	$id = sprintf "node%d", $node_id;
	&set_entry(*node_id, $unique_name, $id);
	printf "\t%s [label=\"%s\"];\n", $id, $label;
    }

    return ($id);
}


# print_graph_entry(parent, parent_id, child, child_id)
#
# A directed link from the parent to the child is added to the graph
# (in dot format).
#
sub print_graph_entry {
    local($parent, $parent_id, $child, $child_id) = @_;
    &debug_out(4, "print_graph_entry(@_)\n");

    # Print the graph link
    printf "\t%s -> %s;\n", &get_id($parent_id, $parent), 
            &get_id($child_id, $child);

    return;
}
