# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# model2graph.perl: Creates a undirected graph from a model specification.
# This requires the dot utility from AT&T's GraphViz for displaying the
# results (or converting into postscript).
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';

if (!defined($ARGV[0])) {
    $options = "options = [-name=label] [-key=name]";
    $example = "examples:\n$script_name ABI ACI ADI AEI AFI AGI AHI\n";
    $example .= "$script_name -key=generous.key  ABG AEG AHJ AHL AI AK AM\n";

    die "\nusage: $script_name [options]\n\n$options\n\n$example\n\n";
}

&init_var(*name, "model2graph");
&init_var(*key, "");
&init_var(*size, "7.5,11");	# fit within margins of 8.5 x 11 page

local(%seen, %node_desc);

&read_key($key, *node_desc);

# Print graph header
print "graph \"$name\" {\n";
printf "\t/* model: @ARGV */\n";
$size_desc = $size;
$size_desc =~ s/,/ x /;
printf "\tsize=\"%s\";\t\t/* fit within %s region */\n", $size, $size_desc;

local($num) = 0;
local($clique);
foreach $clique (@ARGV) {
    $num++;
    &debug_out(4, "clique %d: $clique\n", $num);

    # Get the nodes from the clique
    local(@nodes) = split(//, $clique);
    &trace_array(*nodes);
    local($i, $j);

    # Put an undirected link between each node in clique, unless already added
    printf "\t/* clique %s: */\n", $clique;
    for ($i = 0; $i <= $#nodes; $i++) {
	for ($j = $i + 1; $j <= $#nodes; $j++) {
	    # Print optional description for each node
	    &print_node_description($nodes[$i]);
	    &print_node_description($nodes[$j]);

	    # Print the link unless already encountered
	    local($link) = sprintf "%s -- %s", $nodes[$i], $nodes[$j];
	    local($rev_link) = sprintf "%s -- %s", $nodes[$j], $nodes[$i];
	    printf "\t%s;\n", $link
		unless (&get_entry(*seen, $link) || &get_entry(*seen, $rev_link));
	    &incr_entry(*seen, $link);
	}
    }
    print "\n";
}

# Print graph trailer
print "\t}\n";

&exit();


#------------------------------------------------------------------------------

sub read_key {
    local ($file, *desc) = @_;
    &debug_out(4, "read_key(@_)\n");

    if (!open(KEY, "<$file")) {
	&error_out("Unable to open key file $file ($!)\n");
	return;
    }
    while (<KEY>) {
	&dump_line("key: $_");
	chop;

	local($key, $desc) = split(/\t/, $_);
	&set_entry(*desc, $key, $desc);
    }  
    close(KEY);

    return;
}


sub print_node_description {
    local($node) = @_;
    &debug_out(4, "print_node_description(@_)\n");
    local($desc) = &get_entry(*node_desc, $node, ""); 

    if (($desc ne "") && (get_entry(*seen, $node) == 0)) {
	printf "\t%s [label=\"%s\"];\n", $node, $desc;
    }
    &incr_entry(*seen, $node);

    return;
}
