# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# Compute the shortest paths between all pairs of nodes in a graph.
#
# Based on the algorithm from 
#     Cormen, Thomas, Charles E. Leiserson, and Ronald L. Rivest,
#     Introduction to Algorithms, Cambridge, MA: MIT Press, 1990.
#     (see pages 550-555)
#
# The basic algorithm has been extended to measure distance using
# Minkowski's r-metric (a generalization of Euclidean distance),
# as described in
#     Schvaneveldt, Roger W., Francis T. Durso, and Donald W. Dearholt,
#     "Pathfinder: Scaling with Network Structures", MCCS-85-9, CRL.
# 

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';


sub usage {
    select(STDERR);
    print <<USAGE_END;

Usage: $script_name [options] graph_data

options = [-r=r_metric_value] [-l=length_limit] [-sep="text"]


Computes the shortest paths between all pairs of nodes in a graph.
The graph input is as follows:
    #Rows #Columns
    Row1 Data
    ...
    RowN Data

Based on the algorithm from 
    Cormen, Thomas, Charles E. Leiserson, and Ronald L. Rivest,
    Introduction to Algorithms, Cambridge, MA: MIT Press, 1990.
    (see pages 550-555)

The basic algorithm has been extended to measure distance using
Minkowski's r-metric (a generalization of Euclidean distance),
as described in
    Schvaneveldt, Roger W., Francis T. Durso, and Donald W. Dearholt,
    "Pathfinder: Scaling with Network Structures", MCCS-85-9, CRL.

examples: 

$script_name < fig_26_1.data

nice +19 $script_name -r=10 < noun_sample.data >! noun_sample.path


USAGE_END

    exit 1;
}


# If command line arguments are missing, give a usage message.
# $#ARGV = (# of arguments) - 1

if (($#ARGV < 0) && &blocking_stdin()) {
    &usage();
}




&init_var(*r, 1);		# parameter for r-metric 
&init_var(*sep, " ");		# column delimiter for listings

# Read the matrix of distance weights into associative array W
#
&read_array(*W, *n, *m);
&print_array("Weight matrix", *W, $n, $m);

$l = $n unless (defined($l));		# parameter for max path length


# Starting with the distance matrix equal to the weight matrix,
# find the next extension one additional link at a time for each
# pair of nodes.
#
&copy_array(*D, *W, $n, $m);
for ($max_path = 2; $max_path <= $l; $max_path++) {
    &extend_shortest_paths(*D, *W, *new_D, $n);
    &copy_array(*D, *new_D, $n, $m);
    &print_array("D($max_path)", *D, $n, $m);
}

&copy_array(*N, *W, $n, $m);
&prune_array(*N, *D, $n, $m);
&print_array("pruned matrix", *N, $n, $m);

# extend_shortest_paths(D, W, new_D, n)
#
# Given the current distance matrix and the weight matrix, extend
# the distance matrix by one link.
#
# [Cormen, et al. 90] p. 554
#
# NOTE: This has been extended to handle Minkowski's r-metric,
#       which is a generalization of Euclidean distance:
#             D = (sum(d_i ** r)) ** 1/r
#       When r=1 this is the same as the standard shortest path distance
#       metric, which is used instead for efficiency.
#

sub extend_shortest_paths {
    local (*D, *W, *new_D, $n) = @_;
    local ($i, $j, $k);
    &debug_out(5, "extend_shortest_paths(@_)\n");

    for ($i = 0; $i < $n; $i++) {
	for ($j = 0; $j < $n; $j++) {
	    $new_D{"$i:$j"} = $MAXINT;
	    for ($k = 0; $k < $n; $k++) {
		$new_distance = $D{"$i:$k"} + $W{"$k:$j"};
		if ($r > 1) {
		    # TODO: cache the previous sum (equals D[i,j] ^ r)
		    $new_distance = (($D{"$i:$k"} ** $r)
				     + $W{"$k:$j"} ** $r) ** (1 / $r);
		}
		$new_D{"$i:$j"} = &min($new_D{"$i:$j"}, $new_distance);
	    }
	}
    }

    return;
}


# read_array(M, n)
#
# Read a matrix into an associative array.
#
sub read_array {
    local (*matrix, *n, *m) = @_;
    local ($dimension, $line);
    &debug_out(5, "read_array(@_)\n");

    # Read the dimensions of the array
    $dimension = <>;
    $dimension =~ s/^\s+//g;
    ($n, $m) = split(/\s+/, $dimension);

    # Read in the values of the array
    for ($i = 0; $i < $n; $i++) {
	# Read next row of values
	$line = <>;
	$line =~ s/^\s+//g;
	local(@row) = split(/\s+/, $line);

	for ($j = 0; $j < $m; $j++) {
	    if ($row[$j] eq "-") {
		$row[$j] = $MAXINT;
	    }
	    $matrix{"$i:$j"} = $row[$j];
	}
    }

    return;
}


# copy_array(New, Old)
#
# Make a copy of the array (stored in an associative array)
#
sub copy_array {
    local (*New, *Old, $n, $m) = @_;
    local ($i, $j);
    &debug_out(5, "copy_array(@_)\n");

    for ($i = 0; $i < $n; $i++) {
	for ($j = 0; $j < $m; $j++) {
	    $New{"$i:$j"} = $Old{"$i:$j"};
	}
    }

    return;
}


sub print_array {
    local ($label, *matrix, $n, $m) = @_;
    local ($i, $j);
    &debug_out(5, "print_array(@_)\n");
    local ($format) = ($r > 1) ? "%4.1f" : "%4d";

    print "$label:\n";
    for ($i = 0; $i < $n; $i++) {
	for ($j = 0; $j < $m; $j++) {
	    if ($matrix{"$i:$j"} < $MAXINT) {
		printf "$format$sep", $matrix{"$i:$j"};
	    }
	    else {
		printf "   -$sep";
	    }
	}
	print "\n";
    }
    print "\n";

    return;
}


# Given the original weight matirx and the shortest-path matrix,
# derive a pruned version in which links are only present if they
# are on the shortest path.
#
sub prune_array {
    local (*Original, *Shortest, $n, $m) = @_;
    local ($i, $j);
    &debug_out(5, "copy_array(@_)\n");

    for ($i = 0; $i < $n; $i++) {
	for ($j = 0; $j < $m; $j++) {
	    if ($Original{"$i:$j"} > $Shortest{"$i:$j"}) {
		$Original{"$i:$j"} = $MAXINT;
	    }
	}
    }

    return;
}
