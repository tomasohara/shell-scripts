# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -sw
#
# disambig_entries.perl: disambiguate translation entries
#
# For each word, the word translations are looked up in a WordNet
# and the definition(s) analyzed for lexical relations. These relations
# are then used to propagate support through a network of synsets.
# Disambiguation is done by selecting the sense which receives the most
# support from ancestor synsets.
#
# TODO:
#     Do the spreading activation in batches and remove the support
#     produced by senses later discarded.
#
#     Have an option to only select the "most informative ancestor" for receiving 
#     the support during the upwards propagation. This should cut down on 
#     extra support being given to the similar synsets on the same path.
#          see lexrel2network.perl for supporting code
#
#     Display the feature vector for each competing sense along with the weighted
#     vector (again see lexrel2network.perl)
#
#     Rename to something like disambiguate-word-translations.perl
#

# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';
require 'spanish.perl';
require 'wordnet.perl';


sub usage {
    select(STDERR);
    print <<USAGE_END;

Usage: $script_name [options] file

options = n/a


Disambiguate translation entries produced by qd_trans_spanish.perl


examples: 

$script_name como_dice.list >! como_dice.ulist

$script_name -base=empleado -skip_tagger=1 -skip_lexrels=1 -d=5 empleado.list | & less

nice +19 $script_name -base=como_dice -d=5 como_dice.list >&! como_dice.log &

nice +19 $script_name -base=empleado -d=5 empleado.list >&! empleado.log &

USAGE_END

    exit 1;
}


# If command line arguments are missing, give a usage message.
# $#ARGV = (# of arguments) - 1

if (($#ARGV < 0) && &blocking_stdin()) {
    &usage();
}


# Initialize the program options unless already specified on the command-line
#
&init_var(*skip_tagger, &FALSE);
&init_var(*skip_lexrels, &FALSE);
&init_var(*base, "temp_disambig");
&init_var(*single_head, &FALSE);
&init_var(*TOPN, 5);
&init_var(*ignore_senses, &TRUE);

# Initialize the WordNet access module
&wn_init();


# Read in the word-translation listing
#
$count = &read_word_translations();
if ($count == 0) {
    die "*** no word translations available!\n";
}


# Read in the part-of-speech listing
#
&read_pos_tags();


# Filter senses that don't apply based on part-of-speech.
# TODO: account for mistaggings
#
&filter_senses();


# TODO: have a version that does the following for each combination
#       of the senses (but only after including more filters)
#

# Get tagged versions of the WordNet definitions for each head
# result: temp_disambig.post
#
if ($skip_tagger == &FALSE) {
    &produce_tagged_definitions();
}


# Derive lexical relations from the tagged definitions for each head
# result: temp_disambig.rels 
#
# TODO: combine relations when the heads are in the same sense def
#       (eg, "to spend, invest (money)") rather than being alternative
#       senses ("employee;clerk;officeholder")
#
if ($skip_lexrels == &FALSE) {
    &derive_lexical_relations();
}


# Read in the lexical relations, convert into numeric weights, and propagate
# support to higher-level synsets.
#
&interpret_lexical_relations();


# Select the combination of word-senses that maximizes the number
# of applicable lexical relations.
#
&select_best_translations();


# Clean up the WordNet access module
&wn_cleanup();


#------------------------------------------------------------------------------
# Main disambigutation routines


# Read in the word-translation listing and extract the headwords for each different
# sense. Also, determine the part-of-speech for each sense.
#
# Returns the number of translations read.
#
sub read_word_translations {
    local($count) = 0;

    &sp_init_pp(&TRUE, &TRUE);	   # init entry pretty printing (+listing, -phrasals)
    while (<>) {
        &dump_line();
        chop;

        # Ignore comments
        if (/^ *\#/) {
	    next;
        }

        if ($_ !~ /:\t/) {
	    print "$_\n";
	    next;
        }
        ($word, $entry) = split(/:\t/, $_);
	$count++;

        # Get the definition for the word and extract the heads for each
        # sense
        $last_POS = "";
        $word[$num_words] = $word;
        if ($entry !~ /^[ \t]*$/) {
	    if (!defined($num_senses{$word})) {
	        $entries = &sp_pp_entry($word, $entry);
	        &debug_out(9, "sp_pp_entry($word, _) = {\n$entries}\n");
	        $entries =~ s/^[^\t]+\t//; # drop the word itself
	        $num = 0;
	        foreach $subentry (split(/\n\n/, $entries)) {
		    foreach $sense (split(/\n/, $subentry)) {
		        next if ($sense =~ /^[ \t]*$/);

		        $POS = &sp_extract_POS($last_POS, $sense);
		        $last_POS = $POS;
		        $heads = &extract_heads($sense);

		        # case 1: each sense is union of heads
		        if ($single_head == &FALSE) {
			    $word_sense = "$word:$num";
			    $sense{$word_sense} = $sense;
			    $POS{$word_sense} = $POS;
			    $heads{$word_sense} = $heads;
			    &debug_out(5, "$word_sense pos=%s heads=%s def=%s\n",
			          $POS{$word_sense}, $heads{$word_sense}, $sense);
			    $num++;
			    next;
		        }

		        # case 2: each sense corresponds to a single head
		        foreach $head (split/\t/, $heads) {
			    $word_sense = "$word:$num";
			    $sense{$word_sense} = $sense;
			    $POS{$word_sense} = $POS;
			    $heads{$word_sense} = $head;
			    &debug_out(5, "$word_sense pos=%s heads=%s def=%s\n",
			          $POS{$word_sense}, $heads{$word_sense}, $sense);
			    $num++;
		        }
		    }
	        }
	        $num_senses{$word} = $num;
	    }
        }
        else {
	    $num_senses{$word} = 0;
	    print "\n";
        }

        $num_words++;
    }

    return ($count);
}


# Filter senses that don't apply (TODO: account for mistaggings)
#

sub filter_senses {

    $total_combinations = 1;
    $num_combinations = 1;
    for ($i = 0; $i < $num_words; $i++) {
        $word = $word[$i];
        $num_senses = $num_senses{$word};
        $num_filtered = 0;
        for ($sense = 0; $sense < $num_senses; $sense++) {
	    $word_sense = "$word:$sense";
	    if ((defined($POS[$i])) && ($POS[$i] ne $POS{$word_sense})) {
	        &debug_out(6, "filtering $word_sense: $sense{$word_sense}\n");
	        $heads{$word_sense} = "n/a";
	        $num_filtered++;
	    }
        }

        &debug_out(4, "$word: num_senses=$num_senses filtered=$num_filtered\n");
        &assert('$num_senses > 0');
        $total_combinations *= $num_senses;
        if ($num_filtered < $num_senses) {
	    $num_combinations *= ($num_senses - $num_filtered);
        }
    }
    &debug_out(4, "combinations=$num_combinations total=$total_combinations\n");

    return;
}


# Get the definitions for the word-translations headwords and then run the
# result through a part-of-speech tagger. This is a preliminary step to extracting
# the lexical relations for each word translation.
#
sub produce_tagged_definitions {

    ## &debug_out(5, "|perl -Ssw get_defs.perl -POS=noun  > $base-n.defs\n");
    ## open(GET_DEFS, "|perl -Ssw get_defs.perl -POS=noun > $base-n.defs")
    ## 	|| die "unable to invoke get_defs.perl! ($!)\n";
    open(GET_DEFS, "> $base-n.list");
    foreach $word_sense (sort(keys(%heads))) {
	if ($POS{$word_sense} eq "noun") {
	    print GET_DEFS "$heads{$word_sense}\n"
		unless ($heads{$word_sense} eq "n/a");
	}
    }
    close(GET_DEFS);
    &issue_command("perl -Ssw get_defs.perl -POS=noun <$base-n.list >$base-n.defs");

    ## &debug_out(5, "|perl -Ssw get_defs.perl -POS=verb > $base-v.defs\n");
    ## open(GET_DEFS, "|perl -Ssw get_defs.perl -POS=verb > $base-v.defs")
    ## 	|| die "unable to invoke get_defs.perl! ($!)\n";
    open(GET_DEFS, "> $base-v.list");
    foreach $word_sense (sort(keys(%heads))) {
	if ($POS{$word_sense} eq "verb") {
	    print GET_DEFS "$heads{$word_sense}\n"
		unless ($heads{$word_sense} eq "n/a");
	}
    }
    close(GET_DEFS);
    &issue_command("perl -Ssw get_defs.perl -POS=verb <$base-v.list >$base-v.defs");

    return;
}


# Derive lexical relations from the tagged definitions for each head
# result: temp_disambig.rels 
#
# TODO: combine relations when the heads are in the same sense def
#       (eg, "to spend, invest (money)") rather than being alternative
#       senses ("employee;clerk;officeholder")
#
sub derive_lexical_relations {

    ## &run_command("echo # POS:noun > $base.rels");
    &run_command("perl -Ssw extract_lex_rels.perl -POS=noun -include_cat=1 $base-n.defs >> $base.rels");
    ## &run_command("echo # POS:verb >> $base.rels");
    &run_command("perl -Ssw extract_lex_rels.perl -POS=verb -include_cat=1 $base-v.defs >> $base.rels");

    return;
}



# Read in the lexical relations, convert into numeric weights, and propagate
# support to higher-level synsets.
#
sub interpret_lexical_relations {

    &reset_trace();
    $word_sense = undef;
    $POS = "";
    open(LEX_RELS, "<$base.rels") 
        || die "unable to open temp_disambig.rels! ($!)\n";
    while (<LEX_RELS>) {
        &dump_line($_, 7);
        chop;

        # Ignore comments (but check for POS indication)
        if (/^ *#/) {
	    # Check for part-of-speech
	    if (/POS:([^ ]+)/) {
	        $POS = $1;
	    }
	    next;
        }

        # Extract the headword. 
        #	ex: "clerk#2: a/DT salesperson/NN in/IN a/DT store/NN"
        #
        if (/^((.*)\#([0-9]+)): .*/) {
	    $word_sense = $1; $head = $2; $sense_ind = $3;
	    &debug_out(6, "word_sense: $word_sense $head $sense_ind\n");
	    $objects{$word_sense} = "";
        }

        # Extract the relation. 
        #   ex: "<tab>generic-in store"
        #
        if (/^\t([^ ]+) (.*)/) {
	    $relation = $1;
	    $object = $2;
	    &debug_out(6, "relation=$relation object=$object\n");

	    &assert('defined($word_sense)');
	    $objects{$word_sense} .= "$object\t";

	    # Add support to the object and each of its ancestors in the
	    # WordNet hierarchy (ignoring the sense distinctions).
	    #
	    local($word);
	    foreach $token (split(/[- ;]+/, $object)) {
	        next if ($token =~ /^((or)|(and)|(n\/a))$/i);
	        ($word, $cat) = split(/\//, $token);
	        $cat = $POS if (!defined($cat));
	        assert('$cat ne ""');
	        local($ancestors) = &wn_get_ancestors($word, $cat, &TRUE, &TRUE);
	        foreach $ancestor_list (split(/\n/, $ancestors)) {
		    $support_incr = 10;
		    foreach $ancestor_set (split/\t/, $ancestor_list) {
		        foreach $synset (split(/[ \t\n]+/, $ancestor_set)) {
			    if ($ignore_senses) {
				    $synset =~ s/\#[0-9]+//g; # drop sense indicators
				    }
			    $support{$synset} = 0 if (!defined($support{$synset}));
			    if ($support_incr > 0) {
			        $support{$synset} += $support_incr
			        }
			    &debug_out(7, "support{$synset}=$support{$synset}\n");
		        }
		        $support_incr--;
		    }
	        }
	    }
        }
    }

    # Display the support for the various synset words
    # TODO: sort by weight
    #       filter out high-frequency synsets (eg, entity, object)
    #
    &debug_out(5, "Support for the synsets words:\n");
    foreach $synset_word (sort(keys(%support))) {
        &debug_out(5, "$synset_word\t$support{$synset_word}\n");
    }

    return;
}


# Select the combination of word-senses that maximizes the number
# of applicable lexical relations.
#
# TODO: 
#	add weights to the relations
#	add statistical preferences (eg, for collocations)
#
sub select_best_translations {
    local($i, $j, $sense);

    for ($i = 0; $i < $num_words; $i++) {
        $word = $word[$i];

        for ($j = 0; $j < $TOPN; $j++) {
	    $max_sense[$j] = -1;
	    $max_support[$j] = -1;
        }
        for ($sense = 0; $sense < $num_senses{$word}; $sense++) {
	    local ($heads) = $heads{"$word:$sense"};
	    $POS = $POS{"$word:$sense"};
 
	    # Exclude filtered senses
	    if ($heads eq "n/a") {
	        next;
	    }

	    # Determine the support for the sense
	    &debug_out(6, "checking support of %s\n", $heads);
	    $support = 0;
	    foreach $head (split(/\t/, $heads)) {

	        # Add in the support from each ancestor, scaled by a distance
	        # factor.
	        # 
	        local($ancestors) = &wn_get_ancestors($head, $POS, &TRUE, &TRUE);
	        foreach $ancestor_list (split(/\n/, $ancestors)) {
		    $support_factor = 1.0;
		    foreach $ancestor_set (split/\t/, $ancestor_list) {
		        foreach $synset (split(/[ \t\n]+/, $ancestor_set)) {
			    if ($ignore_senses) {
				    $synset =~ s/\#[0-9]+//g; # drop sense indicators
				    }
			    if (defined($support{$synset})) {
			        $support += ($support{$synset} * $support_factor);
			    }
		        }
		       $support_factor *= 0.75;
		    }
	        }
	    }

	    # Use as the best one if it is higher
	    # Find the position in the list where it belongs
	    $pos = -1;
	    for ($j = 0; $j < $TOPN; $j++) {
	        if ($support > $max_support[$j]) {
		    $pos = $j;
		    last;
	        }
	    }
	    next if ($pos == -1);

	    # Shift the lesser entries down the list
	    for ($j = ($TOPN - 1); $j > $pos; $j--) {
	        $max_support[$j] = $max_support[$j - 1];
	        $max_sense[$j] = $max_sense[$j - 1];
	    }
	    $max_support[$pos] = $support;
	    $max_sense[$pos] = $sense;

        }

        # Print the selection
        for ($j = 0; $j < $TOPN; $j++) {
	    local($word_sense) = "$word:$max_sense[$j]";
	    $sense_def = ($max_sense[$j] > -1) ? $sense{$word_sense} : "???";
	    &debug_out(4, "$word_sense: max_support[$j]=%d: %s\n",
		       $max_support[$j], $sense_def);
        }
    }

    return;
}


#------------------------------------------------------------------------------
# Supporting code


# extract_heads(sense_definition)
#
# Returns a tab-delimited list of headwords from the definition
#
# examples: 
#
# "m.-f. employee;clerk;officeholder.;"
#     => "employee<tab>clerk<tab>officeholder";
#
# "to spend, invest (money)." => "spend<tab>invest";
#
# TODO: retain the object of the verbs ???
#       tag the translations to facilitate proper extraction
#

sub extract_heads {
    local($sense_def) = @_;
    local($heads) = "";
    local($head);
    
    $sense_def =~ s/\.[;]? *$//;		# drop trailing period
    $sense_def =~ s/^[ \t]*[0-9]+\. //;		# drop sense indicator
    $sense_def =~ s/ *\([^\(\)]+\) *//;  	# Remove parentheticals
    foreach $head (split(/[:;,]/, $sense_def)) {
	&debug_out(8, "potential head=$head\n");
	$new_head = $head;

	# Remove extraneous text from the sense
	$new_head =~ s/[-a-z\.]+\. //g; 	# Remove parts-of-speech, etc.
	$new_head =~ s/^to be ([^ ]+).*/$1/;	# to be X ... => X
	$new_head =~ s/^to ([^ ]+).*/$1/;	# Remove inf. prefix & qual's
	$new_head =~ s/\*//g;			# remove asterisks
	$new_head =~ s/^ *//;			# remove leading space
	$new_head =~ s/ .*$//;			# remove subsequent words

	# Add the head if non-empty
	if ($new_head ne "") {
	    $heads .= "$new_head\t";
	}
    }

    # Remove the extra (final) tab in the list
    chop $heads;
    &debug_out(7, "$heads <= extract_heads($sense_def)\n");

    return ($heads);
}


# read_pos_tags()
#
# Read in the part-of-speech tagger listing, in Penn Treebank format
# (eg, produce by Brill tagger).
#
# Example:
#
# Un/DT sospechoso/NN amenazs/VB al/IN empleado/NN de/IN una/DT tienda/NN
# poniendole/VB una/DT barra/NN de/IN caramelo/NN en/IN la/DT nuca/NN ./.
#

sub read_pos_tags {

    &reset_trace();
    open(POST, "<$base.post");
    $current_word = 0;
    while (<POST>) {
	&dump_line($_, 7);
	chop;

	foreach $token (split) {
	    ($word, $tag) = split('/', $token);
	    $word = &sp_to_lower($word);
	    $POS = &convert_penn_to_cat($tag);

	    # Add to appropriate entry
	    for ($i = $current_word; $i < $num_words; $i++) {
		if ($word[$i] eq $word) {
		    $POS[$i] = $POS;
		    $current_word = ($i + 1);
		    last;
		}
	    }
	    if ($i == $num_words) {
		&debug_out(3, "Warning: Unable to resolve $word from POST\n");
	    }
	}
    }
    close(POST);


    return;
}


# old_read_pos_tags()
#
# Read in the part-of-speech tagger listing
# This version assumes CRL's Spanish POST (SPOST)
#
# Example:
# [17,17,'empleado','empleado',noun(masculine,singular), pos].
# [18,18,'de','de',preposition, pos].
# [19,19,'una','una',article(feminine,indefinite,singular), pos].
# [20,20,'tienda','tienda',noun(feminine,singular), pos].
#

sub old_read_pos_tags {

    &reset_trace();
    open(SPOST, "<$base.spost");
    $current_word = 0;
    while (<SPOST>) {
	&dump_line($_, 7);
	chop;

	# Remove the type qualifications (anything in parenthesis)
	s/\(.*\)//;
	s/[\[\]]//g;		# remove the square brackets

	# Split the line into the fields
	($start, $end, $word, $word_alt, $POS, $type) = split(/,/, $_);
	&debug_out(6, "spost: $start, $end, $word, $word_alt, $POS, $type\n");
	&assert('defined($type)');

	# Skip punctuation
	if ($POS eq "punc") {
	    next;
	}

	# Convert the word to lowercase; and remove the quotes
	$word =~ s/\'//g;
	$word = &sp_to_lower($word);

	# Convert some of the tags
	$POS =~ s/proper_noun/noun/;

	# Add to appropriate entry
	for ($i = $current_word; $i < $num_words; $i++) {
	    if ($word[$i] eq $word) {
		$POS[$i] = $POS;
		$current_word = ($i + 1);
		last;
	    }
	}
	if ($i == $num_words) {
	    &debug_out(3, "Warning: Unable to resolve $word_alt from SPOST\n");
	}
    }
    close(SPOST);


    return;
}


#------------------------------------------------------------------------------
# Code for common.perl


# init_tags(): initialize correspondences between post and penn tags
#
sub init_tags {
    local ($cat, $penn);

    %cat2penn = ("", "",
                 "adjective", "JJ",
                 "adverb", "RB",
                 "article", "DT",
                 "auxiliary", "VB",
                 "complementizer", "IN",
                 "conjunction", "CC",
                 "noun", "NN",
                 "number", "CD",
                 "preposition", "IN",
                 "pronoun", "PP",
                 "proper_noun", "NNP",
                 "verb", "VB",
                 );
    foreach $cat (keys(%cat2penn)) {
	$penn = $cat2penn{$cat};
	$penn2cat{$penn} = $cat;
    }

    return;
}


# convert_cat_to_penn(POS_tag)
#
# Convert from traditional part-of-speech category into Penn Treebank's tag.
# TODO: reconcile with convert_spost_tag from spost2penn.perl
#
sub convert_cat_to_penn {
    local ($cat) = @_;
    local ($penn_tag) = "UNK";
    init_tags() if (!defined($cat2penn{"verb"}));
    assert('defined($cat2penn{"verb"})');

    if (defined($cat2penn{$cat})) {
	$penn_tag = $cat2penn{$cat};
    }
    &debug_out(5, "convert_cat_to_penn($cat) => $penn_tag\n");

    return ($penn_tag);
}


sub convert_penn_to_cat {
    local ($penn_tag) = @_;
    local ($cat) = "UNK";
    init_tags() if (!defined($penn2cat{"VB"}));
    assert('defined($penn2cat{"VB"})');

    if (defined($penn2cat{$penn_tag})) {
	$cat = $penn2cat{$penn_tag};
    }
    &debug_out(5, "convert_penn_to_cat($penn_tag) => $cat\n");

    return ($cat);
}


