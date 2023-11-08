# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#
#!/usr/bin/perl -sw
#
# diagnose-collocations.perl: Performs diagnosis of the collocation
# features used in a GraphLing WSD experiment in order to determine
# cases that might be over-generating, etc. For example, the entropy
# of the collocation features values is compared versus that of the
# classification variable and the relative entropy calculated
# (Kullback-Leibler divergence).
#
#------------------------------------------------------------------------
# Notes:
#
# - This assumes that the current directory is output from GraphLing's WSD
#   system.
# - This automates the following processing:
#
# $ pwd
# /home/graphling/EXPERIMENTS/SENSEVAL2/NEW-NAIVE-BAYES/DAY
# 
# $ foreach.perl 'cut -f$f table1 | count_it.perl \"\\S+\"' 7 8 9 10 11 12 | extract_matches.perl "^1\t(\S+)" - | normalize.perl -
# 0.769 0.142 0.012 0.012 0.016 0.049
# 
# $ calc_entropy.perl -simple 0.769 0.142 0.012 0.012 0.016 0.049
# 1.153
# 
# $ calc_entropy.perl -last day.est_probabilities
# 1.555
# 
# temp-nouns $ calc_divergence.perl '0.677 0.146 0.024 0.028 0.076 0.049' '0.769 0.142 0.012 0.012 0.016 0.049'
# 0.110
# 
#------------------------------------------------------------------------
# TODO:
# - Generalize to handling other types of features (e.g., part of speech).
# - Check how often conflicts lead to misclassifications (e.g., via SAMPLE0.EVALTST).
#
#------------------------------------------------------------------------
# Copyright (c) 2005 Tom O'Hara and New Mexico State University.
# Freely available via GNU General Public License (see GNU_public_license.txt).
#


# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir);
    require 'common.perl';
    use vars qw/$script_name/;
    require 'extra.perl';
    require 'graphling.perl';
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
use vars qw/$collset_prefix $basename $related $hypernym $differentia $word $testing $training $regular $terse $conflicts $agreements $all/;

# Show a usage statement if no arguments given
# NOTE: By convention - is used when no arguments are required
if (!defined($ARGV[0])) {
    my($options) = "main options = [-word=w] [-related|-hypernym|-differentia] [-testing|-training] [-terse]";
    $options .= "\nother options = " . &COMMON_OPTIONS;
    my($example) = "examples:\n\n$script_name -\n\n";
    $example .= "$0 -related -\n\n";
    $example .= "$script_name -all -conflicts -agreements -\n\n";
    my($note) = "";
    ## $note .= "notes:\n\nSome usage note.\n";		     # TODO: usage note

    print STDERR "\nusage: $script_name [options] dir\n\n$options\n\n$example\n$note";
    &exit();
}

# Check the command-line options
# note: Each variable initialized corresponds to a -var=value commandline option
&init_var(*related, &FALSE);	# check related-word collocations
&init_var(*differentia, &FALSE); # check differentia collocations
&init_var(*hypernym, &FALSE);	# check for hypernym collocations
&init_var(*regular, &FALSE);	# regular collocations (CI)
&init_var(*collset_prefix, 	# prefix for collocation vars in description
	  $related ? "related_collset_" :
	  $hypernym ? "hyper_collset_" :
	  $differentia ? "differentia_collset_" :
	  $regular ? "collset_" : 
	  "");
&init_var(*all, &FALSE);	# check all prefixes
&init_var(*conflicts, &FALSE);	# analyze conflicting collocation values
&init_var(*agreements, &FALSE);	# analyze agreeing collocation values
&init_var(*word, "");		# alias for -basename
&init_var(*basename, $word);	# basename for experiment files
&init_var(*testing, &FALSE);	# compare versus test data distribution
&init_var(*training, ! $testing); # compare versus training data
&init_var(*terse, &FALSE);	# just basic output
#
## my($show_relative_entropy) = ($collset_prefix ne "");
my(@per_class_collocations) = qw/collset_ hyper_collset_ differentia_collset_ related_collset_/;
my(@collset_prefixes) = ($all ? @per_class_collocations : ($collset_prefix));
&trace_array(\@collset_prefixes, &TL_DETAILED, "prefixes");
my($analyze_conflicts) = ($conflicts || $agreements);
#
my(%collset_names) = ( "collset" => "Word-Coll",
		       "hyper_collset" => "Hyper-Coll",
		       "related_collset" => "Related-Coll",
		       "differentia_collset" => "Dict-Coll",
		       );

# Hash tables used in calculating global recall/precision statistics
my(%overall_collset_correct);
my(%overall_collset_positive);
my($overall_num_instances) = 0;
#
my(%overall_unique_collset_contributions);
my(%overall_correct_unique_collset_contributions);
#

# Use separate $verbose indicator to avoid conflict with calc_entropy
# leading to too much extraneous output
my($verbose) = (! $terse);	


foreach my $dir (@ARGV) {
    # Change the current directory if necessary
    my($last_dir) = &pwd;
    if (($dir ne ".") && ($dir ne "-")) {
        chdir $dir;
    }
    &diagnose_collocations();
    chdir $last_dir;
}


# Show overall recall/precision stats
# TODO: include more of what's shown for each experiment (e.g., conflicts)
if ($analyze_conflicts && ((scalar @ARGV) > 1)) {
    print "-" x 72, "\n";
    print "\n";
    print "Overall Statistics\n";
    print "\n";
    print "Instances: $overall_num_instances\n";
    print "\n";

    # Show how often each collset-type provide unique information
    print "Unique collset contributions:\n";
    print "Collset Name\tCorrect\tTotal\tAccuracy\n";
    my(@unique_contributors) = sort(keys(%overall_unique_collset_contributions));
    foreach my $collset (@unique_contributors) {
	my($unique) = &get_entry(\%overall_unique_collset_contributions, $collset, 0);
	my($correct) = &get_entry(\%overall_correct_unique_collset_contributions, $collset, 0);
	my($accuracy) = ($unique > 0) ? &round($correct / $unique) : 0;
	print "$collset\t$correct\t$unique\t$accuracy\n";
    }
    print "n/a\n" if ((scalar @unique_contributors) == 0);
    print "\n";
	
    print "Collset Name\tCorrect\tAnswers\tRecall\tPrec.\tF-score\n";
    foreach my $collset (sort(keys(%overall_collset_positive))) {
	my($correct) = &get_entry(\%overall_collset_correct, $collset, 0);
	my($positive) = &get_entry(\%overall_collset_positive, $collset, 0);
	my($recall) = ($correct / $overall_num_instances);
	my($precision) = ($positive > 0) ? ($correct / $positive) : 0;
	my($f_score) = 0;
	if (($precision + $recall) > 0) {
	    $f_score = (2 * $precision * $recall) / ($precision + $recall);
	}
	printf "%s\t%d\t%d\t%.3f\t%.3f\t%.3f\n", $collset, $correct, $positive, $recall, $precision, $f_score;
    }
    print "\n";
}

# Cleanup, etc.
#
&exit();

#------------------------------------------------------------------------

# diagnose_collocations(): perform the mondo collocation diagnosis
# TODO: decompose, decompose, decompose!
#
sub diagnose_collocations {
    &debug_print(&TL_DETAILED, "diagnose_collocations(@_)\n");

    # Derive base name for experiment files
    my($dirname) = &remove_dir(&pwd());
    $basename = &to_lower($dirname) unless ($basename ne "");
    if ($verbose) {
        printf "%s\n", "-" x 72;
        printf "Experiment dir: %s\n", &pwd();
	print "\n";
    }
    
    # Make sure the experiment distribution file exists
    if (! -e "$basename.est_probabilities") {
        $basename =~ s/_DEBUG$//i;
        $basename =~ s/[\-\.](N|V|A|ADJ|ADV)$//i;
    }
    
    # Read in the distribution of classification values:
    #    class_values: labels for each class category
    #    class_freq:   frequency count for each class
    #    class_dist:   prior probability for each class
    # NOTE: read from <basename>.est_probabilities (or .test.est_probabilities)
    #
    my($distribution_file) = ($training ? "$basename.est_probabilities" : "$basename.test.est_probabilities");
    my($data_type) = ($training ? "training" : "testing");
    #
    # Read class-value distribution file, filtering out extraneous information
    #
    my(@class_dist_data) = split(/\n/, &read_file($distribution_file));
    ## TODO: figure out stupid emacs formatting problem w/ following
    my(@class_dist_info) = grep { (! m/(^\#)|(^\s*$)|(total data)/) } @class_dist_data;

    #
    # Split information into three groups as indicated above.
    #
    my(@class_values) = map { m/^(\S+)/ } @class_dist_info;
    my(@class_freq) = map { m/^\S+\s+(\S+)/ } @class_dist_info;
    my(@class_dist) = map { m/(\S+)$/ } @class_dist_info;
    &trace_array(\@class_dist, &TL_VERBOSE, "class_dist");
    if ((scalar @class_dist) == 0) {
	&error("Unable to extract class distribution from '$distribution_file'\n");
	return;
    }
    printf "%d class values\n", (scalar @class_values);
    print "labels: @class_values\n";
    print "freq ($data_type data): @class_freq\n";
    print "dist: @class_dist\n";
    printf "class entropy: %s\n", &perl("calc_entropy.perl -simple @class_dist");
    print "\n" if ($verbose);
    
    # Read in the feature descriptions including column indicator
    my(@feature_desc) = split(/\n/, &read_file("table.doc"));
    
    # Determine the latest table 
    # NOTE: table.doc might differ between folds (due to unused collocations)
    my(@tables) = &tokenize(&run_command("ls -t table[0-9]"));
    if ((scalar @tables) == 0) {
	&error("Unable to find feature table (e.g., table9)\n");
	return;
    }
    my($tablename) = $tables[0];
    
    #.........................................................................
    # Diagnostic 1: Compare relative entropy of specified collocation type
    # versus the prior probabilities
    #
    # TODO: automatically do this for all types of collocations
    
    foreach my $collset_prefix (@collset_prefixes) {
	next if ($collset_prefix eq "");
	&debug_print(&TL_DETAILED, "analyzing distribution for $collset_prefix\n");

	
	# Determine the positions of the collocation variables
	my(@collset_desc) = grep {/\t$collset_prefix/} @feature_desc;
	if ((scalar @collset_desc) == 0) {
	    &debug_print(&TL_DETAILED, "WARNING: Unable to extract '$collset_prefix' descriptions from table.doc\n");
	    next;
	}
	## &assert((scalar @collset_desc) == (scalar @class_dist));
	&trace_array(\@collset_desc, &TL_VERBOSE, "collset_desc");
	
	# Determine the relative frequency of positive values for each collocation var
	my(@collset_dist);
	for (my $i = 0; $i <= $#class_values; $i++) {
	    # Determine collocation variable corresponding to class value
	    # TODO: use a subroutine for class value file name normalization
	    my($value) = $class_values[$i];
	    $value =~ s/[\/\\\:\#\-\+\=\|\(\)\<\>\{\}\[\]]/_/g;
	    my(@desc) = grep { /${collset_prefix}$value$/ } @collset_desc;
	    ## &assert((scalar @desc) == 1);
	    my($freq) = 0;
	    my($desc) = (defined($desc[0]) ? $desc[0] : "");
	
	    # Determine frequency of collocation positive values      
   	    # TODO: read all available tables
	    if ($desc ne "") {
		my($var) = ($desc =~ /^(.)\t/);
		my($col) = 1 + &get_coco_column_number($var);
		my($table) = ($testing ? "$tablename.test" : "$tablename.train");
		$freq = &run_command("cut -f$col $table | perl -Ssw count_it.perl '\\b(1)\\b' | cut -f2");
		$freq = 0 if (! &is_numeric($freq));
	    }
	
	    $collset_dist[$i] = $freq;
        }
    
        # Get pretty name for the collocation type
        # TODO: use a separate routine for performing the mapping
        ## print "collset prefix: $collset_prefix\n";			  
        my($collset) = $collset_prefix;
	$collset =~ s/_$//;
        $collset = &get_entry(\%collset_names, $collset, $collset);

	# Display collset distribution, entropy and divergence information
        print "collset: $collset\n";
        print "collset freq ($data_type data): @collset_dist\n";
        @collset_dist = &round_all(&normalize_numeric_array(@collset_dist));
        #
        print "collset dist: @collset_dist\n";
        printf "collset entropy: %s\n", &perl("calc_entropy.perl -simple @collset_dist");
        ## print "\n" if ($verbose);
        
        ## print "experiment: $basename\n" if ($verbose);
        printf "divergence: %s\n", &perl("calc_divergence.perl '@class_dist' '@collset_dist'");
        print "\n";
    }
    
    #........................................................................
    # Diagnostic 2: Count how often there are collocation conflicts
    #
    # NOTES:
    # - This only handles per-class collocations.
    # - This assumes collocations are named in the following format:
    #        [<prefix>_]collset_<class>
    # eg: collset_2, hyper_collset_2, related_collset_2, and differentia_collset_2
    #
    # TODO:
    # - Cut down on common code with diagnostic #1.
    # - Count how often classes have no positive indicators.
    # - Count how often the collocations are correct.
    # - Determine recall, etc. for each collocation type.
    #
    
    if ($analyze_conflicts) {
	&debug_print(&TL_DETAILED, "analyzing conflicts\n");

        my($num_classes) = (scalar @class_values);
        #
        my(%class_conflicts);
        my($total_conflicts) = 0;
        my($distinct_conflicts) = 0;
        my(%collset_conflicts);
        #
        my(@class_agreements) = (0) x $num_classes;
        my($total_agreements) = 0;
        my($distinct_agreements) = 0;
        my(%collset_agreements);
        #
        my($total_values) = 0;
        my($positive_values) = 0;
        #
        my(%within_collset_conflicts);
        my(%cross_collset_conflicts);
        my(%unique_collset_contributions);
        my(%correct_unique_collset_contributions);
        #
        my(%collset_correct);
        my(%collset_positive);
        #
        my($nonpositive_instances) = 0;
	
        # Read in the feature tables as a matrix
        my(@instance_data);
        my($feature_listing) = &read_file("$tablename");
        foreach my $line (split(/\n/, $feature_listing)) {
	    my(@data) = split(/\t/, $line);
	    push(@instance_data, \@data);
        }
        my($num_instances) = (scalar @instance_data);
        &assert($num_instances > 0);
	$overall_num_instances += $num_instances;
	
        # Count the agreements & conflicts for each class
        for (my $i = 0; $i <= $#instance_data; $i++) {
	    my($instance_ref) = $instance_data[$i];
	    &trace_array($instance_ref, &TL_VERBOSE, "instance $i");
	    
	    # Count the agreements on current instance for each class
	    my($instance_agreements) = 0;
	    my(@agreement_classes);
	    #
	    for (my $c = 0; $c < $num_classes; $c++) {
		my($class) = $class_values[$c];
		$class =~ s/[\/\\\:\#\-\+\=\|\(\)\<\>\{\}\[\]]/_/g;
		
		# Get the per-class collocation feature variables for the class
		my(@class_collsets_desc) = grep {/\t\S+_$class/} @feature_desc;
		if ((scalar @class_collsets_desc) == 0) {
		    &debug_print(&TL_DETAILED, "WARNING: unable to determine collocation variables for class '$class'\n");
		}
		
		
		# Check each collocation value involving the class
		my($num_positive) = 0;
		my(@positive_collsets);
		foreach my $desc (@class_collsets_desc)  {
		    # Determine 0-based column number for the feature variable
		    my($var) = ($desc =~ /^(.)\t/);
		    my($col) = &get_coco_column_number($var);
		    my($collset) = ($desc =~ /\t(\S+)_$class/);
		    $collset = &get_entry(\%collset_names, $collset, $collset);
		    
		    # Get value from the table
		    my($value) = $$instance_ref[$col];
		    &assert(defined($value));
		    $value = "" if (!defined($value));
		    &assert($value =~ /^[01]$/);
		    &debug_print(&TL_VERBOSE, "value=$value var=$var col=$col collset=$collset class=$class\n");
		    
		    # If positive, increment total and add collset type to list
		    $total_values++;
		    if ($value eq "1") {
			$num_positive++;
			$positive_values++;
			
			&assert(defined($collset));
			push(@positive_collsets, $collset);
		    }
		}
		
		# If multiple positive, increment agreement indicators
		if ($num_positive > 1) {
		    $class_agreements[$c]++;
		    $instance_agreements++;
		    push(@agreement_classes, $class);
		    
		    # Increment collset-specific indicator
		    map { &incr_entry(\%collset_agreements, $_); } @positive_collsets;
		}
	    }
	    
	    # Update the global tabulators
	    &debug_print(&TL_DETAILED, "instance $i: $instance_agreements agreements (@agreement_classes)\n");
	    if ($instance_agreements > 0) {
		$total_agreements += $instance_agreements;
		$distinct_agreements++;
	    }
	    
	    # Get correct answer
	    my($correct_answer) = $$instance_ref[0];
	    
	    # Count the conflicts for current instance
	    my(@all_collsets_desc) = grep {/\t\S*collset_/} @feature_desc;
	    my(@positive_classes);
	    my(%class_collsets);
	    my(%collset_counts);
	    #
	    foreach my $desc (@all_collsets_desc)  {
		# Exclude adjacency collocations
		next if ($desc =~ /\tcollset_adj_[+-]\d/);
		
		# Determine 0-based column number for the feature variable
		my($var) = ($desc =~ /^(.)\t/);
		my($col) = &get_coco_column_number($var);
		my($collset) = ($desc =~ /\t(\S*_?collset)_/);
		$collset = &get_entry(\%collset_names, $collset, $collset);
		my($class) = ($desc =~ /collset_(\S+)/);
		
		# Get value from the table
		my($value) = $$instance_ref[$col];
		&assert(defined($value));
		$value = "" if (!defined($value));
		&assert($value =~ /^[01]$/);
		&debug_print(&TL_VERBOSE, "value=$value var=$var col=$col collset=$collset class=$class\n");
		
		# If positive, increment total and add collset type to list
		if ($value eq "1") {
		    &incr_entry(\%collset_counts, $collset);
		    &pushnew(\@positive_classes, $class);
		    &append_entry(\%class_collsets, $class, " $collset");
		    
		    # Tabulate recall/precision stats
		    &incr_entry(\%collset_positive, $collset);
		    if ($class eq $correct_answer) {
			&incr_entry(\%collset_correct, $collset);
		    }
		}
	    }
	    
	    # Update total number of within-collset conflicts
	    foreach my $collset (keys(%collset_counts)) {
		if (&get_entry(\%collset_counts, $collset, 1) > 1) {
		    &incr_entry(\%within_collset_conflicts, $collset);
		}
	    }
	    
	    # Update total number of across-collset conflicts
	    my($num_positive_classes) = (scalar @positive_classes);
	    if ($num_positive_classes > 1) {
		my($instance_conflicts) = ($num_positive_classes - 1);
		&debug_print(&TL_DETAILED, "instance $i: $instance_conflicts conflicts: (@positive_classes)\n");
		$total_conflicts += $instance_conflicts;
		$distinct_conflicts++;
		
		foreach my $class (@positive_classes) {
		    &incr_entry(\%class_conflicts, $class);
		    my($class_collsets) = &get_entry(\%class_collsets, $class, "");
		    foreach my $collset (&tokenize($class_collsets)) {
			&incr_entry(\%cross_collset_conflicts, $collset);
		    }
		}
	    }
	    elsif ($num_positive_classes == 1) {
		my($class) = $positive_classes[0];
		my($class_collsets) = &get_entry(\%class_collsets, $class, "");
		foreach my $collset (&tokenize($class_collsets)) {
		    &incr_entry(\%unique_collset_contributions, $collset);
		    if ($class eq $correct_answer) {
			&incr_entry(\%correct_unique_collset_contributions, $collset);
		    }
		}
	    }
	    else {
		$nonpositive_instances++;
	    }
        }
	
	
        # Show instance-level statistics
        print "Instances: $num_instances\n";
        print "Non-positive instances: $nonpositive_instances\n";
	
        # Display agreement information
        if ($agreements) {
	    print "\n";
	    print "Collocation values: $total_values\n";
	    print "Positive values: $positive_values\n";
	    print "\n";
	    
	    # Show agreement information
	    print "Total agreements: $total_agreements\n";
	    print "Distinct agreements: $distinct_agreements\n";
	    print "\n";
	    #
	    print "Class-specific agreements:\n";
	    for (my $c = 0; $c < $num_classes; $c++) {
		printf "%s\t%d\n", $class_values[$c], $class_agreements[$c];
	    }
	    print "\n";
	    
	    print "Collocation-specific agreements:\n";
	    foreach my $collset (sort(keys(%collset_agreements))) {
		printf "%s\t%d\n", $collset, &get_entry(\%collset_agreements, $collset);
	    }
        }
	
        # Show conflict information
        if ($conflicts) {
	    print "\n";
	    print "Total conflicts: $total_conflicts\n";
	    print "Distinct conflicts: $distinct_conflicts\n";
	    print "\n";
	    #
	    print "Class-specific conflicts:\n";
	    foreach my $class (sort(keys(%class_conflicts))) {
		my($conflicts) = &get_entry(\%class_conflicts, $class, 0);
		print "$class\t$conflicts\n";
	    }
	    print "\n";
	    
	    print "Within-collocation conflicts:\n";
	    foreach my $collset (sort(keys(%within_collset_conflicts))) {
		my($conflicts) = &get_entry(\%within_collset_conflicts, $collset, 0);
		print "$collset\t$conflicts\n";
	    }
	    print "\n";
	    
	    print "Cross-collocation conflicts:\n";
	    foreach my $collset (sort(keys(%cross_collset_conflicts))) {
		my($conflicts) = &get_entry(\%cross_collset_conflicts, $collset, 0);
		print "$collset\t$conflicts\n";
	    }
	    print "\n";
        }
	
        # Show how often each collset-type provide unique information
        print "Unique collset contributions:\n";
	print "Collset Name\tCorrect\tTotal\tAccuracy\n";
        my(@unique_contributors) = sort(keys(%unique_collset_contributions));
        foreach my $collset (@unique_contributors) {
	    my($unique) = &get_entry(\%unique_collset_contributions, $collset, 0);
	    my($correct) = &get_entry(\%correct_unique_collset_contributions, $collset, 0);
	    my($accuracy) = ($unique > 0) ? &round($correct / $unique) : 0;
	    print "$collset\t$correct\t$unique\t$accuracy\n";

	    # Update the overall accumaltors
	    &incr_entry(\%overall_unique_collset_contributions, $collset, $unique);
	    &incr_entry(\%overall_correct_unique_collset_contributions, $collset, $correct);
        }
        print "n/a\n" if ((scalar @unique_contributors) == 0);
        print "\n";
	
        # Show recall/precision stats
        print "Collset Name\tCorrect\tAnswers\tRecall\tPrec.\tF-score\n";
        foreach my $collset (sort(keys(%collset_positive))) {
	    my($correct) = &get_entry(\%collset_correct, $collset, 0);
	    my($positive) = &get_entry(\%collset_positive, $collset, 0);
	    my($recall) = ($correct / $num_instances);
	    my($precision) = ($positive > 0) ? ($correct / $positive) : 0;
	    my($f_score) = 0;
	    if (($precision + $recall) > 0) {
		$f_score = (2 * $precision * $recall) / ($precision + $recall);
	    }
	    printf "%s\t%d\t%d\t%.3f\t%.3f\t%.3f\n", $collset, $correct, $positive, $recall, $precision, $f_score;

	    # Update overall accumulators
	    &incr_entry(\%overall_collset_correct, $collset, $correct);
	    &incr_entry(\%overall_collset_positive, $collset, $positive);
        }
        print "\n";
    }    
}
