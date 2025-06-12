# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# wordnet.perl: module for accessing the WordNet knowledge base
# (i.e., WordNet access functions)
#
# NOTE: this assumes a customized version of 'wn' that adds sense
#       indicators and disables morphological transformations
# TPO: sense indicators now part of wn (but not morphological transformations)
#
# Global variables:
#	$wn			name of the WordNet command-line executable
#	$wn_ancestors{<word>}	(cached) list of hypernyms for a word
#       $wn_synsets{<word>}     (cached) list of synsets for a word
#
# 
# Notes:
# 
# WordNet top-level synsets
# entity#1	event#1		abstraction#6	psychological_feature#1	
# state#2	phenomenon#1	human_action#1	grouping#1	
# possession#1	shape#2	        location#1
#
#
# The wordnet cache can be very very confusing. Use with care. It should
# perhaps, just be restricted to debugging purposes.
#
# TODO:
# - convert into a class (and have a Perl4 wrapper module)
# - comment all the functions
# - develop a test suite
# - add in code from wn_distance.perl
# - add error checking in case the word has embedded double quotes
# - add EX tests with some of the optional arguments set (see wn_get_defs)
# - verify data and index file extraction code (here and elsewhere)
# - add function to centralize the data file parsing
# - add function to centralize word preprocessing (eg, adding single quotes)
# - add debug tracing for all functions and verify not inadvertant duplicates
#
# Portions Copyright (c) 1997 - 1999 Tom O'Hara
# Portions Copyright (c) 1999 - 2001 Cycorp, Inc.  All rights reserved.
# Portions Copyright (c) 2002 Tom O'Hara
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { 
    my $dir = `dirname '$0'`; chomp $dir; unshift(@INC, $dir);
    require 'common.perl';
    require 'extra.perl';
}

# Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
use strict;
use vars qw/$wn_use_cache $wn_cache $wn_cache_dir $wn $wn_show_sense $WNSEARCHDIR $synset_freq_file/;

# Initialize globals
#
my($sense_arg) = ($wn_show_sense ? "-s" : "");
my($wn_init) = &FALSE;
my(%wn_ancestors, %wn_descendants, %wn_children, %wn_synsets);

# Variables for command-line arguments
#
our($wn_use_cache);	# whether the results should be cached
our($wn_cache);		# basename for WordNet cache files
our($wn_cache_dir);	# directory to store the cache
our($wn);		# command to use for WordNet
our($wn_show_sense);	# show sense indicator
&init_var(*WNSEARCHDIR, "");	# WordNet dictionary directory
## $wn = "wn" if (!defined($wn));
&init_var(*wn, &find_program_file("wn", "$WNSEARCHDIR/../bin"));
our($default_synset_freq_file); # frequecies for synsets (from SemCor)
$default_synset_freq_file = "$WNSEARCHDIR/../semcor/synset.freq";

# wn_init([cached]): initialize the WordNet access module
# EX: wn_init() => 1
#
sub wn_init {
    my($cached) = @_;
    &debug_print(&TL_DETAILED, "wn_init()\n");
    $cached = $wn_use_cache if (!defined($cached));
    &wn_init_morph();

# TODO: eliminate redundant initialization
&init_var(*WNSEARCHDIR, "");	# WordNet dictionary directory
&init_var(*wn, &find_program_file("wn", "$WNSEARCHDIR/../bin"));
$default_synset_freq_file = "$WNSEARCHDIR/../semcor/synset.freq";

    if ($wn_init == &FALSE) {

        # Set defaults for the module options
	# TODO: use $WNSEARCHDIR as default for wn_cache_dir
        #
	&assert($WNSEARCHDIR ne "");
        &init_var(*wn_use_cache, &TRUE);
        &init_var(*wn_cache, "wn_cache");
        &init_var(*wn_cache_dir, ".");
        &init_var(*wn_show_sense, &TRUE);

	&init_var(*synset_freq_file, 	# frequency of synsets in SEMCOR annotations
		  $default_synset_freq_file);
	# Set up sense-inclusion support
	# note; WN_ADDSENSE used by customized wn interface for version 1.5
	$ENV{WN_ADDSENSE} = $wn_show_sense;
	$sense_arg = ($wn_show_sense ? "-s" : "");

	## $ENV{WN_NOMORPH} = 1; # TODO: specify on a per-case basis
	## $wn = "wn" unless (defined($wn));		# "-wn=c:\bin\wn.exe"
	if ($cached) {
	    &wn_read_synsets("${wn_cache_dir}/$wn_cache.synsets");
	    &wn_read_ancestors("${wn_cache_dir}/$wn_cache.ancestors");
	    &wn_read_descendants("${wn_cache_dir}/$wn_cache.descendants");
	    &wn_read_children("${wn_cache_dir}/$wn_cache.children");
	    $wn_use_cache = &TRUE;
	}
	$wn_init = &TRUE;
    }

    return ($wn_init);
}


# wn_cleanup(): cleans-up the WordNet access module
# EX-todo: wn_cleanup() => 1
#
sub wn_cleanup {
    &debug_print(&TL_DETAILED, "wn_cleanup()\n");

    if ($wn_init == &TRUE) {
	if ($wn_use_cache) {
	    &wn_save_synsets("${wn_cache_dir}/$wn_cache.synsets");
	    &wn_save_ancestors("${wn_cache_dir}/$wn_cache.ancestors");
	    &wn_save_descendants("${wn_cache_dir}/$wn_cache.descendants");
	    &wn_save_children("${wn_cache_dir}/$wn_cache.children");
	}
	$wn_init = &FALSE;
    }

    return (! $wn_init);
}


# init_synset_frequency(): Initialize support for synset frequenciues
# NOTE: this is based on SemCor annotations
#
my(%synset_frequency);
#
# EX: init_synset_frequency() => 1
#
sub init_synset_frequency {
    &debug_print(&TL_DETAILED, "init_synset_frequency(@_)\n");
    # Read in the synset frequencies
    &read_frequencies($synset_freq_file, \%synset_frequency, &TRUE);

    return (&TRUE);
}

# get_synset_frequency(synset_ID): return frequency of synset given ID
# (based on SemCor annotations)
#
# EX: get_synset_frequency("V01573675") => 17
# EX: get_synset_frequency("N08119778") => 1
#
# TODO: reconcile with get_synset_freq that uses the synset spec not ID
#
sub get_synset_frequency {
    my($synset) = @_;
    my($freq) = &get_frequency(\%synset_frequency, $synset);
    &debug_print(&TL_VERBOSE, "get_synset_frequency(@_) => '$freq'\n");

    return ($freq);
}


# wn_parse_sense_spec(synset_word)
#
# Parses the synset word having an optional sense indicator (eg, "dog#3")
# into the word proper and the sense. Also, determines the word sense 
# indicator for the wn command line.
#
# EX: wn_parse_sense_spec("dog#3") => ("dog", 3, "-n3")
# 
sub wn_parse_sense_spec {
    my($word) = @_;
    my($sense, $sense_spec) = (0, "");

    $sense_spec = "";
    if ($word =~ /(.*)#([0-9]+)/) {
	$word = $1;
	$sense = $2;
	if ($sense == 0) {
	    # TODO: fix bug w/ wordnet hack
	    $sense = 1;
	}
	$sense_spec = "-n$sense";
    }

    return ( ($word, $sense, $sense_spec) );
}

# wn_parse_word_spec(word_spec): parses the word specification into part
# of speech, and word proper components.
#
# EX: wn_parse_word_spec("n:artifact") => ("noun", "artifact")
# EX: wn_parse_word_spec("noun:window") => ("noun", "window")
# EX: wn_parse_word_spec("a") => ("", "a")
#
sub wn_parse_word_spec {
    my($word_spec) = @_;
    my($POS) = "";
    my($word) = "";

    if ($word_spec =~ /(([^:]+):)?([^:]+)/i) {
	#              12         3
	($POS, $word) = ($2, $3);
	$POS = "" if (!defined($POS));
	$POS = &wn_convert_POS($POS);
    }
    &debug_print(&TL_VERBOSE, "wn_parse_word_spec(@_) => ($POS, $word)\n");

    return ($POS, $word);
}


# wn_get_num_senses(word, part_of_speech)
#
# Determine the number of senses for the word wuth the given part-of-speech.
# 
# EX: wn_get_num_senses("dog", "noun") => 6
# EX: wn_get_num_senses("verb:dog") => 1
# TODO:
# - cache this information somewhere
# - return an error code if word not found
#
sub wn_get_num_senses {
    my($word, $POS) = @_;
    ($POS, $word) = &wn_parse_word_spec($word) unless defined($POS);

    # Determine the number of synsets for the word
    # NOTE: the ancestor information is cached from MIA call
    my($ancestors) = &wn_get_ancestors($word, $POS);
    my(@ancestors) = split(/\n/, $ancestors);
    my($num_senses) = ($#ancestors + 1);
    $num_senses = 1 if ($num_senses == 0);
    &debug_print(&TL_VERY_VERBOSE, "wn_get_num_senses(@_) => $num_senses\n");

    return ($num_senses);
}


# wn_get_num_children(synset)
#
# Determine the number of direct hyponym synsets (ie, children) for the synset.
# EX: wn_get_num_children("noun:bounder#1") => 1
# EX: wn_get_num_children("noun:mouse#1") => 5
#
sub wn_get_num_children {
    my($synset, $POS) = @_;
    my(@children) = split(/\t/, &wn_get_children($synset, $POS));
    return ((scalar @children));

}

# wn_get_num_parents(synset)
#
# Determine the number of direct hyponym synsets (ie, children) for the synset.
# EX: wn_get_num_parents("noun:person#1") => 2
# EX: wn_get_num_parents("noun:entity#1") => 0
#
sub wn_get_num_parents {
    my($synset, $POS) = @_;

    # First get all ancestors with depth-indicator and then
    # extract those which have depth 1 (ie, immediate ancestor).
    # TODO: create wn_get_parents subroutine based on this fragment
    my(@ancestors) = split(/\t/, &wn_get_ancestors($synset, $POS));
    my(@parents) = grep { /^1:/ } @ancestors;

    return ((scalar @parents));

}

# Constants for use with wn_get_ancestors and wn_get_children
#
sub ALL_HYPS	{ &TRUE; }	# constant for All-Hypernyms option
sub ADD_SYNS	{ &TRUE; }	# constant for Add-Synonyms option
sub SKIP_DEPTH	{ &TRUE; }	# constant for Skip-Depth option

# wn_get_ancestors(word, POS, [add_synsets=0], [all_hypernyms=0], [skip_depth=0])
#
# Given a word, return the list its ancestors (i.e., hypernyms or ancestors).
# Note that spaces within the words are replaced by underscores.
#
# The result is a string with the different senses separated by newlines,
# the hypernym sets separated by tabs, and the synset words separated by
# spaces. This way the entire set of words can be extracted by splitting
# at whitespace:
#     @words = split(/[ \t\n], $ancestors);
# 
# The synsets for the word can optionally be included in the listing
# (add_synsets=1). They would appear as the first set of ancestors. In
# addition, all the words in the parent synset can optionally be included
# (all_hypernyms=1). Also, the depth indicator is optionally omitted.
#
# examples:
#
# &wn_get_ancestors(mouse, noun, 1, 1, 1) => 
#     mouse#1 <tab>
#     rodent#1 gnawer#1 gnawing_animal#1 <tab>
#     placental_mammal#1 eutherian#1 eutherian mammal#1 <tab>
#     mammal#1 <tab>
#     vertebrate#1 craniate#1 <tab>
#     chordate#1 <tab>
#     animal#1 animate_being#1 beast#1 brute#2 creature#1 fauna#2 <tab>
#     life_form#1 organism#1 being#2 living thing#1 <tab>
#     entity#1 <newline>
#     mouse#2 <tab>
#     electronic_device#1 <tab>
#     device#1 <tab>
#     instrumentality#3 instrumentation#1 <tab>
#     artifact#1 artefact#1 <tab>
#     object#1 inanimate_object#1 physical object#1 <tab>
#     entity#1
#
# NOTE: A depth indicator can optionally be added to allow for detecting
#       multiple paths.
#
# EX: wn_get_ancestors("plastic", "noun") => "1: solid#1\t2: substance#1\t3: entity#1"
# EX: wn_get_ancestors("plastic#2", "adjective") => "1: elastic#1"
# EX: wn_get_ancestors("adj:plastic#2") => "1: elastic#1"
# 
# TODO:
# - Split apart the adjective/adverb support (i.e., hack).
# - Return blank lines for senses not appearing in result???
# - treat derived-from adjectives as parents for adverbs???
# - add EX tests with some of the optional arguments set
# - add support for part-of-speech prefix (eg, "verb:act#5")
# - create wn_get_parents for special non-recursive case
#
sub wn_get_ancestors {
    my($word, $POS, $add_syns, $all_hyps, $skip_depth, $immediate) = @_;
    ($POS, $word) = &wn_parse_word_spec($word) unless defined($POS);
    $add_syns = &FALSE if (!defined($add_syns));
    $all_hyps = &FALSE if (!defined($all_hyps));
    $skip_depth = &FALSE if (!defined($skip_depth));
    my($hyp_list, $sense, $sense_spec, $hypernyms);
    &debug_print(&TL_VERY_DETAILED, "wn_get_ancestors($word, $POS, $add_syns, $all_hyps, $skip_depth)\n");
    &assert($wn_init);

    # Extract the optional sense indicator
    ($word, $sense, $sense_spec) = &wn_parse_sense_spec($word);

    my($check_satellites) = &FALSE;
    my($is_satellite) = &FALSE;
    my($ignore_links) = &FALSE;

    my($POS_letter) = &wn_letter_for_POS($POS);
    my($wn_search_type) = "-hype${POS_letter}";
    if ($POS =~ /(^(adv|adj))|(^(a|r)$)/) {
	# Treat the satellite synsets as children
	$wn_search_type = "-syns${POS_letter}";
	$check_satellites = &TRUE;
	# assume satellite unless indicator "(vs. xyz)" found in sense list
	$is_satellite = &TRUE;
    }

    # Escape special characters (e.g., single quotes)
    $word =~ s/\'/\\\'/g;

    # Use the cached version if available
    # TODO: rework so that the cache contents stay the same regardless of
    #       the add_syns or all_hyps parameters
    if (defined($wn_ancestors{"$word:$POS$sense_spec"})) {
	$hypernyms = $wn_ancestors{"$word:$POS$sense_spec"};
    }
    else {
	$hypernyms = &run_command("\"$wn\" \"$word\" $sense_arg $wn_search_type $sense_spec", 8);
	$hypernyms .= "\n";
	$hypernyms =~ s/\n\n/\n/g;
	$wn_ancestors{"$word:$POS$sense_spec"} = $hypernyms;
	$wn_ancestors{"_MODIFIED_"} = &TRUE;
    }
    &assert(defined($wn_ancestors{"$word:$POS$sense_spec"}));

    $hyp_list = "";
    my($num_sets) = 0;
    while ($hypernyms =~ /.*\n/) {
	$_ = $&;
	$hypernyms = $';	# (') for emacs 
	&debug_print(&TL_MOST_DETAILED, "wn: $_");
	chop;

	# Check for the sense indicator
	if (/^Sense ([0-9]+)/) {
	    $sense = $1;
	    $hyp_list .= "\n" if ($hyp_list ne "");
	    ## $hyp_list .= "$word#$sense: " if ($add_syns == &FALSE);
	    $num_sets = 0;
	}

	# Ignore the "Synonyms/Hypernyms (Ordered by Frequency)" line
	elsif (/^((Hypernyms)|(Similarity)|(Synonyms))/) {
	}

	# Ignore rest of cross-category entries
	elsif (/Participle of verb ->/i) {
	    &debug_print(&TL_VERBOSE, "Ignoring rest of cross-category entry (verb participle)\n");
	    last;
	}

	# Check for the synsets (i.e., the start of a new sense)
	elsif (/^([a-z].*)( *--)?/i) {
	    my($synsets) = $1;
	    if ($check_satellites) {
		if ($synsets =~ /\(vs. [-a-z ]+(\#\d+)?\)/) {
		    $is_satellite = &FALSE;
		}
		else {
		    $is_satellite = &TRUE;
		}
	    }
	    if ($add_syns) {
		# drop parentheticals (indicates antonyms & adj. positions)
		$synsets =~ s/ *\([^\)]+\) *//g;
		# Convert synset delimiters (', ') to spaces
		# And, convert phrase spaces to underscore
		$synsets =~ s/, /,/g;
		$synsets =~ s/ /_/g;
		$synsets =~ s/,/ /g;
		# If only the first hypernym is desired, remove the rest
		if ($all_hyps == &FALSE) {
		    ## $synsets =~ s/ .*//;
		    $synsets = "$word#$sense";  # ensure that the word appears
		}
		# Add optional depth indicator
		if ($skip_depth == &FALSE) {
		    $hyp_list .= "0: ";
		}
		$hyp_list .= $synsets;
		$num_sets++;
	    }
	    $ignore_links = &FALSE;
	}

	# Skip pertainyms
	elsif (/^\s*Pertains to noun /) {
	    &debug_print(&TL_VERBOSE, "Ignoring rest of cross-category pertainyms\n");
	    last;
	}

	# Check for the hypernyms
	elsif ((/=> (.*)( *--)?/) && ($ignore_links == &FALSE)) {
	    # add all hypernyms to the ancestor list
	    my($ancestors) = $1;
	    my($include) = &TRUE;
	    my($depth) = int(length($`) / 4);
	    if ($check_satellites) {
		$include = &FALSE;
		if ($is_satellite) {
		    # If this is a satellite, then the "parent" head synsets
		    # are just displayed in the link section. Include them.
		    &assert(&boolean($ancestors =~ /\(vs\. [-a-z ]+(\#\d+)?\)/));
		    $include = &TRUE;
		}
		# elsif ($ancestors =~ /\(vs. [-a-z ]+\)/) {
		#     $include = &TRUE;
		# }
	    }
	    if ($include) {
		# drop parentheticals (indicates antonyms & adj. positions)
		$ancestors =~ s/ *\([^\)]+\) *//g;
		# Convert synset delimiters (', ') to spaces
		# And, convert phrase spaces to underscore
		$ancestors =~ s/, /,/g;
		$ancestors =~ s/ /_/g;
		$ancestors =~ s/,/ /g;
		# If only the first hypernym is desired, remove the rest
		if ($all_hyps == &FALSE) {
		    $ancestors =~ s/ .*//;
		}
		$hyp_list .= "\t" if ($num_sets > 0);
		# Add optional depth indicator
		if ($skip_depth == &FALSE) {
		    $hyp_list .= "$depth: ";
		    }
		# Finally add the hypernyms at this level
		$hyp_list .= "$ancestors";
		$num_sets++;
	    }
	}
	elsif (/Participle of verb/) {
	    # TODO: determine what else indicates links to ignores
	    $ignore_links = &TRUE;
	}
	else {
	    &debug_print(&TL_VERY_DETAILED, "ignoring wn '$_'\n") if ($_ !~ /^ *$/);
	}
    }
    &debug_print(&TL_MOST_DETAILED, "wn_get_ancestors() => $hyp_list\n");

    return ($hyp_list);
}

# wn_get_ancestor_list(word, POS): returns list of ancestors (without depth indicator)
#
# NOTE: wn_get_ancestors(word, POS, [add_synsets=0], [all_hypernyms=0], [skip_depth=0])
#
# EX: wn_get_ancestor_list("noun:plastic") => ("solid#1", "substance#1", "entity#1")
#
sub wn_get_ancestor_list {
    my($word, $POS) = @_;
    ($POS, $word) = &wn_parse_word_spec($word) unless defined($POS);
    my($ancestors) = &wn_get_ancestors($word, $POS, &FALSE, &FALSE, &TRUE);
    my(@ancestors) = &tokenize($ancestors);

    return (@ancestors);
}

# wn_get_synonyms(word, part_of_speech)
#
# Returns the list of words in the synset(s) for the word.
# EX: wn_get_synonyms("lawyer", "noun") => "lawyer#1 attorney#1"
# EX; wn_get_synonyms("fool's_gold") => "pyrite#1, iron pyrite#1, fool's gold#1"
#
sub wn_get_synonyms {
    my($word, $POS) = @_;
    ($POS, $word) = &wn_parse_word_spec($word) unless defined($POS);
    my($syn_list, $sense, $sense_spec, $synonyms);
    &debug_print(&TL_VERBOSE, "wn_get_synonyms($word, $POS)\n");
    &assert($wn_init);

    # Extract the optional sense indicator
    ($word, $sense, $sense_spec) = &wn_parse_sense_spec($word);

    # Escape special characters (e.g., single quotes)
    ## $word =~ s/\'/\\\'/g;

    my($POS_letter) = &wn_letter_for_POS($POS);
    my($wn_search_type) = "-syns${POS_letter}";
    $synonyms = &run_command("\"$wn\" \"$word\" $sense_arg $wn_search_type $sense_spec", 8);
    $synonyms .= "\n";

    $syn_list = "";
    while ($synonyms =~ /.*\n/) {
	$_ = $&;
	$synonyms = $';		# (') for emacs 
	&debug_print(&TL_MOST_DETAILED, "wn: $_");
	chop;

	# Check for the sense indicator
	if (/^Sense ([0-9]+)/) {
	    $sense = $1;
	    $syn_list .= "\n" if ($syn_list ne "");
	    ## $syn_list .= "$word#$sense: " if ($add_syns == &FALSE);
	}
	# Ignore the "Synonyms/Hypernyms (Ordered by Frequency)" line
	elsif (/^(Synonyms)|(Similarity)/) {
	}
	# Check for the synsets
	elsif ((/^([a-z].*)( *--)?/i)) {
	    my($synsets) = $1;
	    $synsets =~ s/ *\([^\)]+\) *//g; # remove parentheticals
	    # Convert synset delimiters (', ') to spaces
	    # And, convert phrase spaces to underscore
	    $synsets =~ s/, /,/g;
	    $synsets =~ s/ /_/g;
	    $synsets =~ s/,/ /g;
	    $syn_list .= "\t" if ($syn_list ne "");
	    $syn_list .= "$synsets";
	}
    }
    &debug_print(&TL_VERY_DETAILED, "wn_get_synonyms() => $syn_list\n");

    return ($syn_list);
}

# Wrappers for reading/saving the WordNet caches
#
# wn_save_XYZ(file-name): save XYZ-type cache to file
# wn_read_XYZ(file-name): read in XYZ-type cache from file
#
# wn_save_ancestors/wn_read_ancestors
# wn_save_descendants/wn_read_descendants
# wn_save_children/wn_read_children
# wn_save_synsets/wn_read_synsets
#
# TODO: look into using database mapping via tie instead
#
#
sub wn_save_ancestors {
    my($file) = @_;
    &wn_save_cache(\%wn_ancestors, $file);
}
#
sub wn_read_ancestors {
    my($file) = @_;
    &wn_read_cache(\%wn_ancestors, $file);
}

#
sub wn_save_descendants {
    my($file) = @_;
    &wn_save_cache(\%wn_descendants, $file);
}
#
sub wn_read_descendants {
    my($file) = @_;
    &wn_read_cache(\%wn_descendants, $file);
}
#
sub wn_save_children {
    my($file) = @_;
    &wn_save_cache(\%wn_children, $file);
}
#
sub wn_read_children {
    my($file) = @_;
    &wn_read_cache(\%wn_children, $file);
}

#
sub wn_save_synsets {
    my($file) = @_;
    &wn_save_cache(\%wn_synsets, $file);
}
#
sub wn_read_synsets {
    my($file) = @_;
    &wn_read_cache(\%wn_synsets, $file);
}


# wn_save_cache(cache_name, output_file)
#
# Read the cached information to a file (eg, synset data)
#
#
sub wn_save_cache {
    my($wn_cache_ref, $file) = @_;
    my($word);
    &debug_print(&TL_DETAILED, "wn_save_cache(@_)\n");

    # Only save if the cache was modified
    if (!defined($$wn_cache_ref{"_MODIFIED_"})) {
	&debug_print(&TL_VERBOSE, "cache not modified, so not saved\n");
	return;
    }

    if (!open(WN_CACHE, ">$file")) {
	&error_out("Unable to create wn cache file $file\n");
	return;
    }
    &lock("WN_CACHE");
    foreach $word (sort(keys(%$wn_cache_ref))) {
	# Remove blank lines from the cache
	$$wn_cache_ref{$word} =~ s/^\s*\n//;
	$$wn_cache_ref{$word} =~ s/\n\s*\n/\n/g;
	&debug_out(&TL_ALL, "$word={\n%s}\n", $$wn_cache_ref{$word});
	
	print WN_CACHE "[$word]\n";
	print WN_CACHE "$$wn_cache_ref{$word}\n";
	print WN_CACHE "\n";
    }
    &unlock("WN_CACHE");
    close(WN_CACHE);

    return;
}


# wn_read_cache(cache_name, input_file)
#
# Read the cached information from a file (eg, ancestor data)
#
sub wn_read_cache {
    my($wn_cache_ref, $file) = @_;
    my($para_mode) = $/;
    &debug_print(&TL_DETAILED, "wn_read_cache(@_)\n");

    if (!open(WN_CACHE, "<$file")) {
	&debug_print(&TL_DETAILED, "Warning: Unable to read wn cache file $file\n");
	return;
    }
    &lock("WN_CACHE");

    &reset_trace();
    $/ = "";			# paragraph input mode
    while (<WN_CACHE>) {
	&dump_line($_, 99);
	if (/\[(.*)\]/) {
	    my($word) = $1;
	    my($data) = $';	# (') for emacs 
	    $data =~ s/^\s+//;	# remove leading whitespace

	    if (defined($data)) {
		$$wn_cache_ref{$word} = $data;
	    }
	}
    }
    $/ = $para_mode;		# restore input mode
    &unlock("WN_CACHE");
    close(WN_CACHE);

    return;
}


# wn_get_children(word, POS, [add_synsets=0], [all_hyponyms=0], [skip_depth=0], [include_descendants=0])
#
# Given a word/synset, return a string list with its children (i.e., hyponyms).
# Note that spaces within the words are replaced by underscores.
# Words can have an optional sense indicator (eg, "village#2").
#
# The synsets for the word can optionally be included in the listing
# (add_synsets=1). They would appear as the first set of descendants. In
# addition, all the words in the child synset can optionally be included
# (all_hyponynw=1). Also, the depth indicator is optionally omitted.
#
# EX: wn_get_children("monster#1",noun,0,0,&TRUE) => "bogeyman#1 bugbear#1 bugaboo#1 boogeyman#1 booger#1\tmythical_monster#1 mythical_creature#1"
# TODO: have wn_get_children_basic for above case (i.e., w/o depth indicator)
#
# EX: wn_get_children("greyhound", "noun") => "1: Italian_greyhound#1\t1: whippet#1"
#
# TODO:
# - add EX tests with some of the optional arguments set
#
sub wn_get_children {
    my($word, $POS, $add_syns, $all_hyps, $skip_depth, $descendants) = @_;
    ($POS, $word) = &wn_parse_word_spec($word) unless defined($POS);
    $add_syns = &FALSE if (!defined($add_syns));
    $all_hyps = &FALSE if (!defined($all_hyps));
    $skip_depth = &FALSE if (!defined($skip_depth));
    $descendants = &FALSE if (!defined($descendants));
    my($child_list, $sense, $sense_spec);
    &debug_print(&TL_VERY_DETAILED, "wn_get_children($word, $POS, $add_syns, $all_hyps, $skip_depth, $descendants)\n");
    &assert($wn_init);
    my($wn_hyponyms_ref) = ($descendants ? \%wn_descendants : \%wn_children);

    # Extract the optional sense indicator
    ($word, $sense, $sense_spec) = &wn_parse_sense_spec($word);
    my($check_satellites) = &FALSE;
    my($is_satellite) = &FALSE;

    # First, see if a cached copy exists. If so return it.
    if (defined($$wn_hyponyms_ref{"$word:$POS$sense_spec"})) {
	$child_list = $$wn_hyponyms_ref{"$word:$POS$sense_spec"};
	&debug_print(&TL_MOST_DETAILED, "wn_get_children($word) => $child_list\n");

	return ($child_list);
    }

    my($POS_letter) = &wn_letter_for_POS($POS);
    my($wn_search_type) = ($descendants ? "-tree${POS_letter}" : "-hypo${POS_letter}");
    if ($POS =~ /^(adv)|(adj)/) {
	# Treat the satellite synsets as children
	$wn_search_type = "-syns${POS_letter}";
	$check_satellites = &TRUE;
	# assume satellite unless indicator "(vs. xyz)" found in sense list
	$is_satellite = &TRUE;
    }

    # Escape special characters (e.g., single quotes)
    $word =~ s/\'/\\\'/g;

    # Invoke WordNet to get the hyponyms for the synset
    # Parse the hyponym output to get the list of children synsets
    #
    $child_list = "";
    my($wn_listing) = &run_command("\"$wn\" \"$word\" $sense_arg $wn_search_type $sense_spec", 8);
    $wn_listing .= "\n";
    my($next_sense) = 1;


    my($num_sets) = 0;
    while ($wn_listing =~ /.*\n/) {
	$_ = $&;
	$wn_listing = $';	# (') for emacs 
	&debug_print(&TL_MOST_DETAILED, "wn: $_");
	chop;

	# Check for the sense indicator
	if (/^Sense ([0-9]+)/) {
	    $sense = $1;

	    # Add a sense grouping delimiter (ie, '\n') for this sense and
	    # any preceding ones omitted from the listing.
	    my($i);
	    for ($i = $next_sense; $i <= $sense; $i++) {
		$child_list .= "n/a" if ($i < $sense);
		$child_list .= "\n" if ($i > 1);
	    }
	    $next_sense = (1 + $sense);
	    ## $child_list .= "$word#$sense: " if ($add_syns == &FALSE);
	    $num_sets = 0;
	}

	# Ignore the "Hyponyms of" line
	elsif (/^((Hyponyms)|(Similarity)|(Synonyms))/) {
	}

	# Ignore rest of cross-category entries
	elsif (/Participle of verb ->/i) {
	    &debug_print(&TL_VERBOSE, "Ignoring rest of cross-category entry\n");
	    last;
	}

	# Check for the synsets
	elsif ((/^([a-z].*)( *--)?/i)) {
	    my($synsets) = $1;
	    if ($check_satellites) {
		if ($synsets =~ /\(vs. [-a-z ]+(\#\d+)?\)/) {
		    $is_satellite = &FALSE;
		}
		else {
		    $is_satellite = &TRUE;
		}
	    }
	    if ($add_syns) {
		# drop parentheticals (indicates antonyms & adj. positions)
		$synsets =~ s/ *\([^\)]+\) *//g;
		# Convert synset delimiters (', ') to spaces
		# And, convert phrase spaces to underscore
		$synsets =~ s/, /,/g;
		$synsets =~ s/ /_/g;
		$synsets =~ s/,/ /g;
		# Add optional depth indicator
		if ($skip_depth == &FALSE) {
		    $child_list .= "0: ";
		}
		$child_list .= $synsets;
		$num_sets++;
	    }
	}

	# Check for the hyponyms
	elsif (/=> (.*)$/) {
	    # Add hyponyms to the list (replacing spaces w/ underscores)
	    my($children) = $1;
	    &debug_print(&TL_MOST_VERBOSE, "children=$children\n");
	    my($include) = &TRUE;
	    my($depth) = int(length($`) / 4);
	    if ($check_satellites) {
		if ($is_satellite) {
		    # If this is a satellite, then the "parent" head synsets
		    # are just displayed in the link section. Ignore them.
		    &assert(($children =~ /\(vs. [-a-z ]+(\#\d+)?\)/));
		    $include = &FALSE;
		}
		elsif ($children =~ /\(vs. [-a-z ]+(\#\d+)?\)/) {
		    # Ignore co-heads (e.g., inhumane#1 & painful#1)
		    $include = &FALSE;
		}
	    }
	    if ($include) {
		$children =~ s/ *\([^\)]+\) *//g; # drop parentheticals
		# Convert synset delimiters (', ') to spaces
		# And, convert phrase spaces to underscore
		$children =~ s/, /,/g;
		$children =~ s/ /_/g;
		$children =~ s/,/ /g;
		$child_list .= "\t" if ($num_sets > 0);
		# Add optional depth indicator
		if ($skip_depth == &FALSE) {
		    $child_list .= "$depth: ";
		    }
		$child_list .= "$children";
		$num_sets++;
	    }
	}
    }
    &debug_print(&TL_MOST_DETAILED, "wn_get_children($word) => $child_list\n");

    # Update the cache
    $$wn_hyponyms_ref{"$word:$POS$sense_spec"} = $child_list;
    $$wn_hyponyms_ref{"_MODIFIED_"} = &TRUE;

    return ($child_list);
}

# wn_get_descendants(word, POS, [add_synsets=0], [all_hypernyms=0], [skip_depth=0])
#
# Given a word, return a string list with its descendants (i.e., hyponym tree).
# Note that spaces within the words are replaced by underscores.
# Words can have an optional sense indicator (eg, "village#2").
#
# EX: wn_get_descendants("barrister", "noun") => "1: Counsel_to_the_Crown#1\t2: King's_Counsel#1\t2: Queen's_Counsel#1\t1: serjeant-at-law#1 serjeant#1 sergeant-at-law#1 sergeant#3"
# TODO:
# - add EX tests with some of the optional arguments set
#
sub wn_get_descendants {
    my($word, $POS, $add_syns, $all_hyps, $skip_depth) = @_;
# $' (for emacs); TODO: figure out why required here
    ($POS, $word) = &wn_parse_word_spec($word) unless defined($POS);
    &debug_print(&TL_VERY_DETAILED, "wn_get_descendants($word, $POS, $add_syns, $all_hyps, $skip_depth)\n");

    return (&wn_get_children($word, $POS, $add_syns, $all_hyps, $skip_depth, &TRUE));
}

# wn_get_defs(word, $POS, [show_synsets, just_quotes, keep_quotes]): 
#
# Retrieve a list of WordNet definitions for the word. The result is a newline
# delimited string.
#
# EX: wn_get_defs("hound", "noun") => "hound#1: any of several breeds of dog used for hunting typically having large drooping ears\nhound#2: someone who is morally reprehensible"
# TODO:
# - have option to omit the sense specifier
# - create init_local_var for non-commandline variables
# - add EX tests with some of the optional arguments set
#
sub wn_get_defs {
    my($word, $POS, $show_synsets, $just_quotes, $keep_quotes) = @_;
    ($POS, $word) = &wn_parse_word_spec($word) unless defined($POS);
    &init_var(\$show_synsets, &FALSE);
    &init_var(\$just_quotes, &FALSE);
    &init_var(\$keep_quotes, &FALSE);
    &assert($wn_init);

    # Extract the optional sense indicator
    my($sense, $sense_spec);
    ($word, $sense, $sense_spec) = &wn_parse_sense_spec($word);

    # Initialize defaults
    my($defs, $num) = ("", 0);
    my($POS_letter) = &wn_letter_for_POS($POS);
    my($wn_search_type) = "-syns${POS_letter}";

    # Get the synset listing, using a cached version if available
    my($synset_listing) = "";
    if (defined($wn_synsets{"$word:$POS$sense_spec"})) {
	$synset_listing = $wn_synsets{"$word:$POS$sense_spec"};
    }
    else {
	$synset_listing = &run_command("\"$wn\" \"$word\" $sense_arg $wn_search_type -g $sense_spec", 8);
	$synset_listing .= "\n";
	$synset_listing =~ s/\n\n/\n/g;
	$wn_synsets{"$word:$POS$sense_spec"} = $synset_listing;
	$wn_synsets{"_MODIFIED_"} = &TRUE;
    }

    while ($synset_listing =~ /.*\n/) {
	$_ = $&;		# set default input and pattern-searching space
	chop;
	$synset_listing = $';	# (') for emacs 

	# Extract the sense number indicator
	if (/^Sense (\d+)/) {
	    $sense = $1;
	    $num++;
	}

	# Ignore miscelleanous status lines
	# example: Synonyms/Hypernyms (Ordered by Frequency) of noun money
	elsif (/^((Synonyms)|([0-9]+ senses of)|(Similarity of))/) {
	}

	# Extract the definition and optionally the other synset words
	elsif ((/^([a-z].*) -- \((.*)\)/i)
	       || (/^([a-z].*)/i)) {
	    my($synsets) = $1;
	    my($orig_def) = $2;
	    my($def) = (defined($orig_def) ? $orig_def : "");

	    my($synset_spec) = "";
	    if ($show_synsets == &TRUE) {
		$synsets =~ s/$word#$sense,? ?//;
		$synsets =~ s/,\s+$//;
		if ($synsets !~ /^\s*$/) {
		    $synsets =~ s/([^,]) /$1_/g;	# spaces to underscores
		    $synsets =~ s/-/_/g;		# dashes as well
		    $synset_spec = " (also $synsets)";
		}
	    }
	    if ($just_quotes == &TRUE) {
		# TODO: handle cases with quotes in the definition proper
		$def =~ s/^[^\"]+(\")?/$1/;
	    }
	    elsif ($keep_quotes == &FALSE) {
		$def = &wn_strip_quotes($def);
	    }

	    &assert($num > 0);
	    if ($def =~ /^ *$/) {
		$def = "n/a" unless ($just_quotes == &TRUE);
	    }
	    $defs .= "\n" if ($defs ne "");
	    $defs .= "$word#$sense:$synset_spec $def";
	}
    }
    &debug_print(&TL_VERBOSE, "wn_get_defs($word, $POS, $show_synsets, $just_quotes, $keep_quotes) => {\n$defs}\n");

    return ($defs);
}

# wn_get_related_adjectives(word, POS): get the adjectes related to the
# word in specified speech-part (currently just adverb). The result
# is a newline delimited list, one line per sense.
#
# EX: wn_get_related_adjectives("quickly", "adverb") => "quick#1\nquick#1\nquick#2"
#
sub wn_get_related_adjectives {
    my($word, $POS) = @_;
    ($POS, $word) = &wn_parse_word_spec($word) unless defined($POS);
    my($rel_list, $sense, $sense_spec, $synonyms);
    &debug_print(&TL_VERBOSE, "wn_get_related_adjectives($word, $POS)\n");
    &assert(($POS =~ /^adv/));
    &assert($wn_init);

    # Extract the optional sense indicator
    ($word, $sense, $sense_spec) = &wn_parse_sense_spec($word);

    my($POS_letter) = &wn_letter_for_POS($POS);
    my($wn_search_type) = "-syns${POS_letter}";
    $synonyms = &run_command("\"$wn\" \"$word\" $sense_arg $wn_search_type $sense_spec", 8);
    $synonyms .= "\n";

    $rel_list = "";
    while ($synonyms =~ /.*\n/) {
	$_ = $&;
	$synonyms = $';		# (') for emacs 
	&debug_print(&TL_MOST_DETAILED, "wn: $_");
	chop;

	# Check for the sense indicator
	if (/^Sense ([0-9]+)/) {
	    $sense = $1;
	    $rel_list .= "\n" if ($rel_list ne "");
	}

	# Ignore the "Synonyms/Hypernyms (Ordered by Frequency)" line
	elsif (/^(Synonyms)|(Similarity)/) {
	}

	# Check for the related adjectives
	elsif (/Derived from adj *(->)? +([^\(]+) \(Sense/) {
	    my($related_adj) = $2;
	    $related_adj =~ s/ /_/g;		# spaces to underscores
	    $rel_list .= "\t" if ($rel_list != /\n$/);
	    $rel_list .= "$related_adj";
	}
    }
    &debug_print(&TL_VERY_DETAILED, "wn_get_related_adjectives() => $rel_list\n");

    return ($rel_list);
}


# wn_strip_quotes(definition)
#
# Get rid of quotations in the WordNet definition text
#
# TODO:
# - Handle quoted definition text (eg, '(usually "the stage")')
# - Optionally restrict the quotations to the word in question
#   (quotes for each word in the synset may be present).
#
# NOTES:
#   Unfortunately, quotes can be interspersed with the def's:
#	   work#18 find the solution to (a problem or question):
#	   "did you solve the problem?"; understand the meaning of; 
#	   "did you get it?"; "Did you get my meaning?"
#
#         delim quote1   optional quotes
#
# TODO: 
#  remove author attributions after quotations (eg, an essential and distinguishing attribute of something or someone; "the quality of mercy is not strained"--Shakespeare)
#
# EX: wn_strip_quotes('pursue or chase relentlessly; "The hunters traced the deer into the woods"') => "pursue or chase relentlessly"
#
# EX: wn_strip_quotes('a low or downcast state; "each confession brought her into an attitude of abasement"- H.L.Menchken') => "a low or downcast state"
#
sub wn_strip_quotes {
    my($def) = @_;
    my($orig_def) = $def;

    # Remove names cited after quotes
    # example: "the harder the conflict the more glorious the triumph"--Thomas Paine; "police tried ..."
    #    to    "the harder the conflict the more glorious the triumph"; "police tried ..."
    $def =~ s/\"\s*\-\-?\s*[^;\"]+/\";/g;

    # Remove double-quoted text
    $def =~ s/\", etc. *$//;	# ???
    $def =~ s/[,;: ] ?"[^\"]+"([;, ]? ?"[^\"]+")?//g;
    $def =~ s/^ *"[^\"]+" *$//;

    # Handle special cases
    #
    # example: also metaphorical, as in "This brings me to the main point"
    $def =~ s/(also [a-z]+, )?as in *"[^\"]+"//;
    #
    # example: "I know it's hard," he continued, "but there is no choice."
    $def =~ s/"[^\"]+," [a-zA-Z]+ [a-z]+, "[a-z][^\"]+"//;

    # If extraneous quotes, then revert to original up to first quote
    if ($def =~ /\"/) {
	&debug_print(&TL_VERBOSE, "WARNING: *** extra quote(s) in def: '$orig_def'\n");
	$def = $orig_def;
	$def =~ s/\".*$//;
    }
    $def =~ s/ *[:;] *$//g;
    &debug_print(&TL_VERY_DETAILED, "wn_strip_quotes('$orig_def') => '$def'\n");

    return ($def);
}

#------------------------------------------------------------------------------

# wn_get_root(word, [part_of_speech]): get the morphological root for the word
#
# EX: wn_get_root("parties") => "party"
#
#
# example:
#   wn beagles
#	No information available for noun beagles
#
#	Information available for noun beagle
#           -hypen          Hypernyms
#	...
#
# NOTE: Preference is given to the basic form over derivatives.
#       For instance, WordNet has entries for both steps and step,
#       so the latter would be preferred.
# TODO: allow sense-spec input???
#
sub wn_get_root {
    my($word, $POS) = @_;
    ($POS, $word) = &wn_parse_word_spec($word) unless defined($POS);
    $POS = "\\S+" if ($POS eq "");
    my($root) = $word;
    my($use_first) = ($POS ne "noun");
    &debug_print(&TL_VERY_DETAILED, "wn_get_root(@_)\n");

    # Get the listing of the applicable entries for the word
    $word = &trim(&iso_lower($word));
    ## $word =~ s/ /_/g;
    my($morph) = "";
    if ($word ne "") {
	$morph = &run_command("\"$wn\" \"$word\"", 8);
    }

    # Find the last entry of the given part-of-speech that applies
    # to the word. Note that the plurals are given first in WordNet.
    while ($morph =~ /Information available for $POS (.*)\n/) {
	$root = $1;
	$morph = $' || "";		# (') for emacs 

	$root =~ s/_/ /g;
	&debug_print(&TL_VERY_DETAILED, "Possible root for $word: $root\n");
	last if ($use_first);
    }

    return ($root);
}


# wn_has_word(wordform): returns true if the word (ie, wordform) is in WordNet
#
# EX: wn_has_word("winnow") => 1
# EX: wn_has_word("fubar") => 0
#
sub wn_has_word {
    my($word) = @_;
    &debug_print(&TL_VERY_DETAILED, "wn_has_word(@_)\n");

    # Get the listing of the applicable entries for the word
    $word = &iso_lower($word);
    my($info) = &run_command("\"$wn\" \"$word\"", 8);
    my($has_word) = &FALSE;

    # Find the last entry of the given part-of-speech that applies
    # to the word. Note that the plurals are given first in WordNet.
    if ($info =~ /Information available for/) {
	$has_word = &TRUE;
    }

    return ($has_word);
}


# wn_get_polysemy(word, POS): get the polysemy count (familiarity) for the
# word in the given part-of-speech
#
# EX: wn_get_polysemy("hound", "noun") => 2
# EX: (wn_get_polysemy("set", "verb") > 20) => 1
#
sub wn_get_polysemy {
    my($word, $POS) = @_;
    ($POS, $word) = &wn_parse_word_spec($word) unless defined($POS);
    my($polysemy) = 0;
    &debug_print(&TL_VERY_DETAILED, "wn_get_polysemy(@_)\n");

    # Extract the optional sense indicator
    my($sense, $sense_spec);
    ($word, $sense, $sense_spec) = &wn_parse_sense_spec($word);

    # Initialize defaults
    my($defs, $num) = ("", 0);
    my($POS_letter) = &wn_letter_for_POS($POS);
    my($wn_search_type) = "-faml${POS_letter}";

    my($wn_listing) = &run_command("\"$wn\" \"$word\" $wn_search_type $sense_spec", 8);
    if ($wn_listing =~ /\(polysemy count\s*=\s*(\d+)/) {
	$polysemy = $1;
    }

    return ($polysemy);
}

# wn_convert_POS_letter(letter): returns grammatical category given the
# part of speech letter
#
# EX: wn_convert_POS_letter("v") => "verb"
# EX: wn_convert_POS_letter("s") => "adjective"
#
my(%wn_POS_letter_mapping);
#
sub wn_convert_POS_letter {
    my($letter) = @_;

    # Initialize association from letter to part of speech
    # TODO: do this initialization elsewhere
    if (!defined($wn_POS_letter_mapping{'n'})) {
	%wn_POS_letter_mapping = ("n", "noun",
				  "v", "verb",
				  "a", "adjective",
				  "s", "adjective",
				  "r", "adverb"
				  );
    }

    # Get the part of speech for the letter
    my($POS) = &get_entry(\%wn_POS_letter_mapping, $letter, "");
    &debug_print(&TL_VERBOSE, "wn_convert_POS_letter(@_) => $POS\n");

    return ($POS);
}

# wn_letter_for_POS(part_of_speech): return WN letter for the part of speech
#
# EX: wn_letter_for_POS("noun") => "n"
# EX: wn_letter_for_POS("adv") => "r"
#
sub wn_letter_for_POS {
    my($POS) = @_;
    my($letter) = ($POS =~ /^adv/i) ? "r" : substr($POS, 0, 1);
    &debug_print(&TL_VERY_VERBOSE, "wn_letter_for_POS(@_) => '$letter'\n");

    return ($letter);
}

# wn_convert_POS: convert part-of-speech abbreviation to full form
# EX: wn_convert_POS("n") => "noun"
# EX: wn_convert_POS("x") => ""
# TODO: use something like 'unknown-part-of-speech" rather than ""
# TODO: reconcile with version in graphling (have latter call this?)
#
my(%POS_abbrevs);
#
sub wn_convert_POS {
    my($in_POS) = @_;

    # Make sure part-of-speech associations in place
    if (! (scalar %POS_abbrevs)) {
	&wn_init_POS_abbrevs();
    }
    &assert($POS_abbrevs{"n"} eq "noun");

    # Return the full form for the POS label
    return (&get_entry(\%POS_abbrevs, $in_POS, ""));
}


# init_POS_abbrevs(): initialize the hash with part-of-speech abbreviations
# EX: wn_init_POS_abbrevs() => 1
# 
sub wn_init_POS_abbrevs {
    %POS_abbrevs = ("n", "noun",
		    "noun", "noun",
		    "v", "verb",
		    "verb", "verb",
		    "adj", "adjective",
		    "adjective", "adjective",
		    "adv", "adverb",
		    "adverb", "adverb"
		    );
    return (&TRUE);
}


# wn_parts_of_speech(word): return parts-of-speech list for word from
# WordNet
# EX: wn_parts_of_speech("set") => ("noun", "verb", "adjective")
# EX: wn_parts_of_speech("fubar") => ()
# TODO: add caching as above (eg, wn_get_ancestors)
#
sub wn_parts_of_speech {
    my($word) = @_;
    my(@wn_POS_list);

    my($wn_POS);
    foreach $wn_POS ("noun", "verb", "adverb", "adjective") {
	my($POS_letter) = &wn_letter_for_POS($wn_POS);
	my($wn_info) = &run_command("\"$wn\" \"$word\" -o -syns${POS_letter} -g");
	if ($wn_info ne "") {
	    push(@wn_POS_list, $wn_POS);
	}
    }
    &debug_print(&TL_VERBOSE, "wn_parts_of_speech(@_) => (@wn_POS_list)\n");

    return (@wn_POS_list);
}

# wn_has_part_of_speech(wordform, POS): returns 1 iff the word has the part of speech
#
# EX: wn_has_part_of_speech("set", "adverb") => 0
# EX: wn_has_part_of_speech("hound", "verb") => 1
#
sub wn_has_part_of_speech {
    my($wordform, $POS) = @_;
    ($POS, $wordform) = &wn_parse_word_spec($wordform) unless defined($POS);
    my(@word_POS) = &wn_parts_of_speech($wordform);

    return (&find(\@word_POS, $POS) != -1);
}

# wn_resolve_sense_num(synset_offset, word, POS): Returns the sense number for 
# word used when in the given synset.
#
#   $ wn hat -o -synsn
#   
#   Synonyms/Hypernyms (Ordered by Estimated Frequency) of noun hat
#   
#   2 senses of hat
#   
#   Sense 1
#   {03047763} hat, chapeau, lid
#       => {03052257} headdress, headgear
#   
#   Sense 2
#   {00544283} hat
#       => {00543761} function, office, part, role
#   
# EX: wn_resolve_sense_num("00544283", "hat", "noun") => 2
# EX: wn_resolve_sense_num("01347414", "belly dance", "verb") => 1
# EX: wn_resolve_sense_num("66666666", "devil", "noun") => 0
# EX: wn_resolve_sense_num("00643045", "basal_body_temperature_method_of_family_planning", "noun") => 1
#
# TODO: have version that does't require speech-part and just uses the wn overview output to determine the sense, as illustrated below:
#   $ wn keyboard -over -o
#   Overview of noun keyboard
#   
#   The noun keyboard has 2 senses (first 1 from tagged texts)
#   
#       1. (4) {03148285} keyboard -- (device consisting of a set of keys on a piano or organ or typewriter or typesetting machine or computer or the like)
#       2. {03148151} keyboard -- (holder consisting of an arrangement of hooks on which keys or locks can be hung)   
#
#
sub wn_resolve_sense_num {
    my($offset, $word, $POS) = @_;
    ($POS, $word) = &wn_parse_word_spec($word) unless defined($POS);
    my($sense) = 0;
    &assert($offset !~ /^[nvra]/i);
    my($POS_letter) = &wn_letter_for_POS($POS);

    my($synset_info) = &run_command("\"$wn\" \"$word\" -syns${POS_letter} -o");
    if ($synset_info =~ /Sense (\d+)\n\{$offset\}/) {
	$sense = $1;
    }
    # Special case for handling wn error with large headwords
    elsif ((length($word) > 20) && ($synset_info =~ /1 sense of/)) {
	$sense = 1;
    }
    &debug_print(&TL_VERBOSE, "wn_resolve_sense_num(@_) => $sense\n");

    return ($sense);
}

# get_synset_ID(synset_spec): return offset-based ID for the synse3t
# EX: get_synset_ID("noun:dog#2") => N08300330
#
sub get_synset_ID {
    my($synset, $POS) = @_;
    ($POS, $synset) = &wn_parse_word_spec($synset) unless defined($POS);
    my($word, $sense, $sense_spec) = &wn_parse_sense_spec($synset);
    my($ID) = "";

    my($POS_letter) = &wn_letter_for_POS($POS);
    my($synset_info) = &run_command("\"$wn\" \"$word\" -syns${POS_letter} -o");
    if ($synset_info =~ /Sense $sense\n\{(\d+)\}/) {
        $ID = &to_upper($POS_letter . $1);
    }
    &debug_print(&TL_VERBOSE, "get_synset_ID(@_) => '$ID'\n");

    return ($ID);
}

# get_synset_freq(synset_spec, POS): return offset-based ID for the synse3t
# EX: get_synset_freq("noun:dog#4") => 1
# EX: get_synset_freq("noun:dog#1") => 39
#
sub get_synset_freq {
    my($synset, $POS) = @_;
    ($POS, $synset) = &wn_parse_word_spec($synset) unless defined($POS);
    my($ID) = &get_synset_ID($synset, $POS);
    my($freq) = &get_frequency(\%synset_frequency, $ID);
    &debug_print(&TL_VERBOSE, "get_synset_freq(@_) => $freq\n");

    return ($freq);
}

#------------------------------------------------------------------------
# Basic morphology support

# TODO: move to separate module file (e.g., extra.perl)
#       develop support for a persistent cache

my(%word_root, %is_content_word);

# wn_init_morph(): initialize simple morphology module based on WordNet
# TODO: flesh out the stop list of function words
#
sub wn_init_morph {
    &debug_print(&TL_DETAILED, "wn_init_morph(@_)\n");

    my($word);
    my(@stop_list) = ("a", "an", "any", "as", "in", "the", "", "with");
    foreach $word (@stop_list) {
	$is_content_word{$word} = &FALSE;
    }
}


# wn_get_root_any(word): returns root form of the word in any part-of-speech
# EX: wn_get_root_any("dogs") => "dog"
#
sub wn_get_root_any {
    my ($word) = @_;
    &debug_print(&TL_DETAILED, "wn_get_root_any(@_)\n");

    # First, check the cache to see if the word was already checked
    my($root) = $word_root{$word};
    if (!defined($root)) {
	foreach my $POS (("noun", "verb", "adj", "adv")) {
	    $root = &wn_get_root($word, $POS);
	    last if ($root ne $word);
	}
	$word_root{$word} = $root;
    }
    &debug_print(&TL_VERY_VERBOSE, "wn_get_root_any($word) => $root\n");

    return ($root);
}


# wn_is_content_word(word): indicates if word is a content word (wrt WordNet)
# EX: is_content_word("man-made") => 1
#
sub wn_is_content_word {
    my ($word) = @_;
    &debug_print(&TL_DETAILED, "wn_is_content_word(@_)\n");
    my($is_content_word) = &FALSE;
 
    &trace_assoc_array(\%is_content_word, &TL_VERY_VERBOSE, "is_content_word");
    if (defined($is_content_word{$word})) {
	$is_content_word = $is_content_word{$word};
    }
    elsif (&wn_has_word($word)) {
	$is_content_word = &TRUE;
	$is_content_word{$word} = &TRUE;
    }
    &debug_print(&TL_VERY_VERBOSE, "wn_is_content_word($word) => $is_content_word\n");

    return ($is_content_word);
}

#------------------------------------------------------------------------

## require this to be manual since a large cache might get read in 
## &wn_init();

# Return a nonzero success code for the package loading
1;
