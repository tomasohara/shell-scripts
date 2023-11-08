# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# testwn.perl: script for testing the WordNet access module
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';
use vars qw/$TEMP/;

# Load in other modules
&reference_vars($wn_cache, $wn_cache_dir, $wn_use_cache);
&init_var(*wn_cache, "testwn");
&init_var(*wn_cache_dir, $TEMP);
&init_var(*uncached, &FALSE);		# should cached data be skipped
&init_var(*wn_use_cache, ! $uncached);	# whether the results should be cached
require 'wordnet.perl';

&init_var(*POS_list, "noun verb adjective adverb");
@POS = split(/[ \t]+/, $POS_list);
&init_var(*isa, &FALSE);		# show isa hierarchy
&init_var(*add_syns, &TRUE);		# include synonyms
&init_var(*all_hypernyms, ! $isa);	# include all hypernyms (i.e., all entries in hypernym synset)
&init_var(*simple, ! $isa && !all_hypernyms); # use simple display routines
&init_var(*simpler, &FALSE);		# use simpler display routines
&init_var(*simplest, &FALSE);		# use simplest display routines
&init_var(*just_children, &FALSE);	# hyponym listing just shows children

&init_var(*include_all, &FALSE);	# show all types of information
&init_var(*include_defs, $isa || $include_all); # include definition
&init_var(*include_hypernyms, $isa || $include_all); # include ancestors
&init_var(*include_hyponyms, $include_all); # include descendants
&init_var(*include_synonyms, $include_all); # include synonyms (words in same synset)
&init_var(*polysemy, $include_all);	# alias for -include_polysemy
&init_var(*include_polysemy, $polysemy); # show polysemy count for the word
$num_types = ($include_defs + $include_hypernyms + $include_hyponyms
	       + $include_synonyms + $include_polysemy);
if ($num_types == 0) {
    $include_hypernyms = &TRUE;
    $num_types++;
}

&init_var(*show_synsets, &FALSE);	# show the synset information
&init_var(*just_quotes, &FALSE);	# only include definition samples
&init_var(*keep_quotes, &FALSE);	# exclude definition samples
&init_var(*intersect, &FALSE);		# show intersection of ancestors

if (!defined($ARGV[0])) {
    $options = "[-add_syns=b] [-all_hypernyms=b] [-include_all=b] [-include_defs=b]\n";
    $options .= "\t[-include_hypernyms=b] [-include_hyponyms] [-isa] [-simple]\n";
    $options .= "\t[-POS_list='p1 ... pn'] [-uncached]";
    $example = "examples:\n\n$script_name -isa dog\n\n";
    $example .= "$script_name -POS=noun -polysemy cat\n";

    die "\nusage: $script_name [options] word ...\n\n$options\n\n$example\n\n";
}

# Initialize access to WordNet
&debug_print(5, "wn_cache=$wn_cache\n");
## &wn_read_synsets("testwn.synsets");
## &wn_read_ancestors("testwn.ancestors");
&wn_init();

$add_labels = ($num_types > 1);

*display_hypernyms = 
    $simplest ? *simplest_display_hypernyms :
    $simpler ? *simpler_display_hypernyms :
    $simple ? *simple_display_hypernyms :
    *complex_display_hypernyms;
$wn_get_hyponyms_fn = ($just_children ? \&wn_get_children: \&wn_get_descendants);

for ($i = 0; $i <= $#ARGV; $i++) {
    local($word) = $ARGV[$i];
    local($word2) = "";
    if ($intersect) {
	$word2 = $ARGV[$i + 1];
	$i++;
    }

    printf "[$word]\n";
    foreach $POS (@POS) {
	printf "$POS\n";

	&display_defs($word) if ($include_defs);
	&display_synonyms($word) if ($include_synonyms);
	&display_hypernyms($word) if ($include_hypernyms);
	&display_hyponyms($word) if ($include_hyponyms);
	&display_polysemy($word) if ($include_polysemy);
	if ($intersect) {
	    &intersect_hypernyms($word, $word2) if ($include_hypernyms);
	}
	printf "\n";
    }
    printf "\n";
}



# Cleanup access to WordNet
#
&wn_cleanup();



#------------------------------------------------------------------------------


sub display_defs {
    local ($word) = @_;
    local ($def);

    $def = &wn_get_defs($word, $POS, 
			$show_synsets, $just_quotes, $keep_quotes);
    printf "$def\n";
}


# complex_display_hypernyms(word): prints the WordNet hypernym entry 
# with ancestors shown indented by depth on separate lines
#
sub complex_display_hypernyms {
    local ($word) = @_;
    &debug_print(4, "complex_display_hypernyms(@_)\n");
    local($ancestors, @ancestor_list, $ancestor_set, $ancestor);
    local($i, $j, $k, $l);

    print "hypernyms:\n" if ($add_labels);
    $ancestors = &wn_get_ancestors($word, $POS, $add_syns, $all_hypernyms);
    @ancestor_list = split(/\n/, $ancestors);
    for ($i = 0; $i <= $#ancestor_list; $i++) {
	local($indent) = "";
	local($sense) = $word;
	if ($sense !~ /\#/) {
	    $sense = sprintf "%s#%d", $word, ($i + 1);
	}
	print "$sense:";
# 	if ($include_defs) {
# 	    local($def) = &wn_get_defs($sense, $POS);
# 	    $def =~ s/^.*: //;
# 	    $def =~ s/\n//;
# 	    print " $def";
# 	}
	printf "\n";

	foreach $ancestor_set (split(/\t/, $ancestor_list[$i])) {
	    ($depth, $ancestor_set) = split(/: /, $ancestor_set);
	    printf "%s", "\t" x $depth;
	    ## foreach $ancestor (split(/ /, $ancestor_set)) {
	    ##	  printf "%s", $ancestor;
	    ## }
	    print $ancestor_set;
	    if ($include_defs) {
		local($ancestor) = (split(/ /, $ancestor_set));
		local($def) = &wn_get_defs($ancestor, $POS);
		$def =~ s/^.*: //;
		$def =~ s/\n//;
		print ": $def";
	    }

	    printf "\n";
	    ## $indent .= "\t";
	}
	printf "\n";
    }
    printf "\n";
}


# simpler_display_hypernyms(word): prints the WordNet hypernym entry 
# with ancestors shown indented by depth on separate lines
# NOTE: this is a simplication of complex_display_hypernyms that doesn't
# handle definitions
#
sub simpler_display_hypernyms {
    local ($word) = @_;
    &debug_print(4, "simpler_display_hypernyms(@_)\n");
    local($ancestors, $ancestor_list, $ancestor_set, $ancestor, $depth);

    print "hypernyms:\n" if ($add_labels);
    $ancestors = &wn_get_ancestors($word, $POS, $add_syns, $all_hypernyms, 
				   ! &SKIP_DEPTH);
    local(@ancestor_list) = split(/\n/, $ancestors);
    local($i);
    for ($i = 0; $i <= $#ancestor_list; $i++) {
	local($ancestor_list) = $ancestor_list[$i];
	local($sense) = $word;
	if ($sense !~ /\#/) {
	    $sense = sprintf "%s#%d", $word, ($i + 1);
	}
	print "$sense:\n";
	$indent = "";
	foreach $ancestor_set (split(/\t/, $ancestor_list)) {
	    ($depth, $ancestor_set) = split(/: /, $ancestor_set);
	    printf "%s", "\t" x $depth;
	    printf "%s%s\n", $ancestor_set;
	}
    }
    printf "\n";

    return;
}


# simplest_display_hypernyms(word): just prints the WordNet hypernym entry 
# as is
#
sub simplest_display_hypernyms {
    local ($word) = @_;
    &debug_print(4, "simplest_display_hypernyms(@_)\n");
    local($ancestors);

    print "hypernyms:\n" if ($add_labels);
    $ancestors = &wn_get_ancestors($word, $POS, $add_syns, $all_hypernyms);
    printf "%s\n\n", $ancestors;

    return;
}



# simple_display_hypernyms(word): prints the WordNet hypernym entry 
# with each ancestor shown indented by one tab on a separate line
#
sub simple_display_hypernyms {
    local ($word) = @_;
    local($ancestors, $ancestor_list, $ancestor_set);
    &debug_print(4, "simple_display_hypernyms(@_)\n");
    
    print "hypernyms:\n" if ($add_labels);
    $ancestors = &wn_get_ancestors($word, $POS, $add_syns, $all_hypernyms);
    foreach $ancestor_list (split(/\n/, $ancestors)) {
	$indent = "";
	foreach $ancestor_set (split(/\t/, $ancestor_list)) {
	    printf "%s%s\n", $indent, $ancestor_set;
	    ## $indent .= "\t";
	    $indent = "\t";
	}
    }
    printf "\n";
}


# intersect_hypernyms(word1, word2): returns a list of common hypernyms for the
# two words (or senses)
#
sub intersect_hypernyms {
    local ($word1, $word2) = @_;
    &debug_print(4, "intersect_hypernyms(@_)\n");
    local($ancestors1, @ancestor_list1, @ancestor_set1);
    local($ancestors2, @ancestor_list2, @ancestor_set2);
    local($i, $j);

    print "hypernym intersection:\n" if ($add_labels);
    $ancestors1 = &wn_get_ancestors($word1, $POS, &FALSE, &FALSE, &TRUE);
    @ancestor_list1 = split(/\n/, $ancestors1);
    $ancestors2 = &wn_get_ancestors($word2, $POS, &FALSE, &FALSE, &TRUE);
    @ancestor_list2 = split(/\n/, $ancestors2);

    # Check each combination of senses
    for ($i = 0; $i <= $#ancestor_list1; $i++) {
	for ($j = 0; $j <= $#ancestor_list2; $j++) {
	    # Determine the sense labellings
	    # TODO: use parse_sense from lexrel2network.perl
	    local($sense1) = $word1;
	    if ($sense1 !~ /\#/) {
		$sense1 = sprintf "%s#%d", $word1, ($i + 1);
	    }
	    local($sense2) = $word2;
	    if ($sense2 !~ /\#/) {
		$sense2 = sprintf "%s#%d", $word2, ($j + 1);
	    }

	    # Check intersection with this sense
	    @ancestor_set1 = split(/\t/, $ancestor_list1[$i]);
	    @ancestor_set2 = split(/\t/, $ancestor_list2[$j]);
	    printf "%s vs. %s: ", $sense1, $sense2;
	  intersection_test:
	    for ($k = 0; $k <= $#ancestor_set1; $k++) {
		for ($l = 0; $l <= $#ancestor_set2; $l++) {
		    &debug_print(7, "$ancestor_set1[$k] vs $ancestor_set2[$l]\n");
		    if ($ancestor_set1[$k] eq $ancestor_set2[$l]) {
			local($distance) = 2 + $k + $l;
			printf "%s dist=%d", $ancestor_set1[$k], $distance;
			last intersection_test;
		    }
		}
		&debug_print(7, "\n");
	    }
	    printf "\n";
	}
    }
}


# display_synonyms(word): display the synonyms for the word or sense.
# For each synset the word belongs to, the words in the synset are displayed,
# optionally with the WordNet definition.
#
sub display_synonyms {
    &debug_print(4, "display_synonyms(@_)\n");
    local ($word) = @_;

    print "synonyms:\n" if ($add_labels);
    $synonyms = &wn_get_synonyms($word, $POS);
    foreach $synonym_list (split(/\n/, $synonyms)) {
	printf "$synonym_list\n";
    }
    printf "\n";
}


# display_hyponyms(word); display the descendants for the word or sense.
# For each hyponym synset, the words in the synset are displayed,
# optionally with the WordNet definition.
#
sub display_hyponyms {
    &debug_print(4, "display_hyponyms(@_)\n");
    local ($word) = @_;
    local($descendants, $descendant_list, $descendant_set);
    
    print "hyponyms:\n" if ($add_labels);
    $descendants = &$wn_get_hyponyms_fn($word, $POS, $add_syns, &TRUE, &FALSE);
    foreach $descendant_list (split(/\n/, $descendants)) {
	$indent = "";
	foreach $descendant_set (split(/\t/, $descendant_list)) {
	    printf "%s%s", $indent, $descendant_set;

	    if ($include_defs) {
		local($depth, $sense, @rest) = split(/\s/, $descendant_set);
		local($def) = &wn_get_defs($sense, $POS);
		&reference_vars(@rest);
		$def =~ s/^.*: //;
		$def =~ s/\n//;
		print ": $def";
	    }
	    print "\n";
	    ## $indent .= "\t";
	    $indent = "\t";
	}
    }
    printf "\n";
}


# display_polysemy(word): returns number of senses for word in WordNet
# TODO: drop word and pos if other categories being displayed (eg, -include_all)
#
sub display_polysemy {
    local($word) = @_;
    printf "polysemy:\n", if ($add_labels);
    printf "%s:%s\t%d\n", $word, $POS, &wn_get_polysemy($word, $POS);
}
