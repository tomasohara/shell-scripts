# *-*-perl-*-*
eval 'exec perl -Ssw $0 "$@"'
    if 0;
#!/usr/local/bin/perl -ws
#!/usr/local/Gnu/bin/perl -ws
#!/usr/bin/perl -ws
# Perl options:   -w code warnings; -s cmdline vars
#
# extract_lex_rels.perl: given a part-of-seech tagged file of dictionary
# definitions extract the lexical relations implied, using pattern matching
# (eg., 'GenusNP PASTPART ... by NP => (agent NP)').
#
# Comments on the relations (see dso_defs.annot for more details):
#
# Note the relations are specified on lines following the sense definition
# in the following format:
#	<TAB>relation-name  relation-object  [confidence-factor]
#
# The relation goes from the sense to the relation object, so the above is
# interpreted as (word#sense-num relation-name relation-object)
#
# Common relations used (all binary of the form (entry relation object)):
#	attr		object is an attribute of the sense being defined
#	attr-not	object is an attribute specifically not of the sense
# 	genus           object is the genus class for the entry
#	genus-spec	object is a specialization of the word's genus
#	genus-attr	object is an attribute of the word's genus
#	result-of	entry is event resulting from specified action
#	state-of	entry is in state described by the object
#	required-for	entry is requirement for object
#	action-recipient  the entry is an action with specified recipient
#
# Ad hod relations:
#	<verb>		entry does <verb> to the object
#	<prep>		entry is in relation <prep> to the object
#
#
# NOTES:
# - See TPO's thesis proposal for more discussion:
#       http://www.cs.nmsu.edu/~tomohara/proposal
# - This code is an obsolete prototype for differentia analysis that is
#   now performed by extract-differntia.perl. The latter is more empirical
#   than knowledge based, as discussed in TPO's thesis:
#       http://www.cs.nmsu.edu/~tomohara/thesis
# - Examples are from WordNet unless otherwise stated
#
# TODO:
# - Eliminate the old-style rules that apply over the tagged definition.
# - Add rule identifiers to the output for evaluating accuracy.
# - Extract the ancestor list in the preprocessing phrase (when the
#   definitions are part-of-speech tagged).
# - Prepare analysis scripts. Ex:
#   count_it "\tattr (.*)" dso_ldoce_nouns.rels | sort -rn | less
#


# Load in the common module, making sure the script dir is in the Perl lib path
BEGIN { my $dir = `dirname $0`; chomp $dir; unshift(@INC, $dir); }
require 'common.perl';
require 'wordnet.perl';


sub usage {
    select(STDERR);
    print <<USAGE_END;

Usage: $script_name [options] definition_POS_listing ...

options = [-POS=noun|verb|adj|adv] [-include_cat=0|1]

Given POS-tagged definition text, this will extract lexical relations
implicit in the definition.

NOTE: Use get_tagged_defs.perl to produce the listing

examples: 

$script_name dso_wn_nouns.post >! dso_wn_nouns.rels

$script_name dso_ldoce.post >! dso_ldoce.rels

$script_name -d=5 noun_samples.post |& less

$script_name -d=5 -POS=verb verb_samples.post |& less

$script_name -POS=verb dso_wn_verbs.post >! dso_wn_verbs.rels

$script_name -include_cat=1 noun_samples.post >! noun_samples.rels

get_tagged_defs.perl -use_ldoce -words="mess" | $script_name >! ldoce_mess.rels

USAGE_END

    exit 1;
}


# If command line arguments are missing, give a usage message.
# $#ARGV = (# of arguments) - 1

if (($#ARGV < 0) && &blocking_stdin()) {
    &usage();
}
$POS = "noun" unless (defined($POS));
&init_var(*include_cat, &TRUE);

# Initialize supporting modules
#
&init_transform();		# syntactic category transformations
&wn_init();			# initialize WordNet access


%as_relation = ("of", "object",
		"in", "subject-area", 		# subject ?
		"against", "opposed-to",	# just against ?
		"by", "means",
		"for", "purpose");

# Read each line from the input, and derive the lexical rules
#
while (<>) {
    &dump_line();
    chop;

    # Check for the new headword indicator
    # ex: "[fork]/NN"
    if (/^\[(\w+)\]/) {
	next;
    }
    if (/^ *$/ || /^ *;/) {
	next;
    }
    print "$_\n";

    # Check for headword + sense: 
    # ex: "money#2: wealth/NN reckoned/VBN in/IN ..."
    $head_spec = $headword;
    if (/((\w+)\#\S+): */) {
	$headword = $2;
	$head_spec = $1;
	s/(\w+\#\S+): *//;	# remove the headword specifier from pattern
    }
    &assert('$headword ne ""');
    $def = $_;

    &derive_lex_rels($def, $headword, $head_spec);
}

&wn_cleanup();			# cleanup WordNet access


#------------------------------------------------------------------------------


# derive_lex_rels(definition, head-word, head-specification)
#
# Apply all of the lexical-relation patterns to the tagged 
# definition text in order to derive the relations implied in the
# definition.
#
# NOTE: The relations go from a sense to a word, since the dictionary
#       definitions are not disambiguated.
#
sub derive_lex_rels {
    local ($def, $headword, $head_spec) = @_;
    local ($action, $relation, $object, $source);

    # Rules that apply over the tagged text as is.
    # TODO: convert most of these to rules over the transformed text

    # NN used for VBG => noun instrument-for verb 
    #
    if ($def =~ /\w+\/NN[SP]? used\/VBN for\/IN (\w+)\/VBG/) {
	$action = $1;
	&debug_out(4, "$head_spec -[instrument-of]-> $action\n");
    }

    # NN for VBG NN => noun generic-for verb 
    #
    if ($def =~ /\w+\/NN[SP]? for\/IN (\w+)\/VBG (\w+)\/NN/) {
	$action = $1;
	$object = $2;
	&debug_out(4, "$head_spec -[generic-for]-> $action $object\n");
    }

    # NP used to INF NP => noun generic-for verb
    #
    #    implement#1: a/DT piece/NN of/IN equipment/NN or/CC tool/NN used/VBN 
    #    to/TO effect/VB an/DT end/NN 
    #
    if ($def =~ /\w+\/NN[SP]? used\/IN to\/TO (\w+)\/VB/) {
	$action = $1;
	&debug_out(4, "\t-[instrument-in]-> $action\n");
    }

    # Catch all rule: NOUN prep VERB (NOUN)
    # 
    if ($def =~ /(\w+)\/NN[SP]? (\w+)\/IN (\w+)\/VB[DNGP]?( (\w+)\/NN)?/) {
	&debug_out(7, "$head_spec: $&\n");
	$source = $1; $relation = $2; $action = $3;

	$object = defined($4) ? $4 : "";
	&debug_out(4, "\t($source $relation $action $object)\n");
    }

    # Determine the pattern string giving the usual grammatical categories
    #
    $pattern = &transform_tags($head_spec, $def);
    foreach $subpattern (split(/;/, $pattern)) {

	&clear_relations();

	# Lexical-relation inference rules that apply over the transformed
	# version of the POS-tagged dictionary text.
	#
	# The phrases are grouped (as in a "chunker" a la Pangloss) 
	# prior to testing the rules.
	# Note: the main grouping currently must be done first, so for
	# noun definitions, the nouns are grouped before the verbs.
	#
	# TODO: break definition into subdef's and process separately
	#
	if ($POS eq "noun") {
	    $subpattern = &group_noun_phrases($subpattern);
	    $subpattern = &group_verb_phrases($subpattern);
	    &derive_noun_rels($subpattern);
        }
	elsif ($POS eq "verb") {
	    $subpattern = &group_verb_phrases($subpattern);
	    $subpattern = &group_noun_phrases($subpattern);
	    &derive_verb_rels($subpattern);
        }
    }
}


#------------------------------------------------------------------------------

# clear_relations(): remove record of relations derived
#
sub clear_relations {
    %phr_related = ();
}

# add_relation(source_constituent, relation, target_constituent, depth)
#
# Adds the specified relation to the head of the target constituent, unless
# a relation has already been derived for it.
#
# TODO: determine the depth from the source id
#
sub add_relation {
    local ($source, $relation, $target, $depth) = @_;
    $depth = 1 unless (defined($depth));
    &debug_out(5, "add_relation($source, $relation, $target, $depth)\n");
    $TABS = "\t\t\t\t\t\t\t\t\t\t";

    if (!defined($phr_related{$target})) {
        local($head) = $phr_head{$target};
        if ($include_cat && ($head !~ /\//)) {
            # TODO: handle this conversion elsewhere
            $cat = &convert_POS($POS{$target});
            $cat =~ s/FORM//;       # change VERBFORM => VERB, etc
            $cat =~ tr /A-Z/a-z/;   # make lowercase
            $head .= "/$cat";
        }
	## local($suffix) = ($include_cat ? "" : "");
	## printf "%s%s %s%s\n", substr($TABS, 0, $depth), 
	## 	$relation, $phr_head{$target}, $suffix;
	printf "%s%s %s%s\n", substr($TABS, 0, $depth), 
		$relation, $head;
	if (defined($phr_attr{$target})) {
	    ## local($suffix) = ($include_cat ? "/$POS{$target}" : "");
	    ## NOTE: attr's already have the category added
	    $relation = ($target =~ /VP/) ? "manner" : "attr";
	    printf "%s%s %s\n", substr($TABS, 0, $depth + 1), 
	    	"$relation", $phr_attr{$target};
	}
	$phr_related{$target} = &TRUE;
    }    
}


# derive_noun_rels(def_pattern): derive lexical relations for noun entries
#
# TODO: use a routine to add the relations (and mark function words used)
#
sub derive_noun_rels {
    local($pattern) = @_;
    local($relation);
    &debug_out(4, "derive_noun_rels(@_)\n");

    # [[the] act of] PresPart => the PresPart act
    # experimental fixup rule
    #
    &debug_out(7, "checking: [[the] act of] PresPart ...\n");
    #
    if ( #         $n: 12     3         4           5
	($pattern =~ /^(($NP_)($PREP_))?($VERBFORM_)($|$NP_|$PREP_)/)
	&& (!defined($2) || ($phr_head{$2} eq "act"))
	&& (!defined($3) || ($phr_head{$3} eq "of"))) {
	$prep = $words{$3}; $action = $4; $delim = $5; $rest = $';
	$delim = "" if (!defined($delim));

	$id = "NP0_";
	$phr_head{$id} = "$phr_head{$action}-act";
	$POS{$id} = "NN";
	$phr_pattern{$id} ="NN0_$action";
	$pattern = "$id$delim$rest";
	&debug_out(4, "transformed act-of style def into $pattern\n");
    }


    # GenusNOUN => (genus ADJ) [(genus-attr ADJ)]
    #
    # action#3: a/DT military/JJ engagement/NN
    #	genus-attr military
    #
    &debug_out(7, "checking: GenusNOUN\n");
    if ($pattern =~ /^($NP_)/) {
	local($genus_np) = $1;

	&add_relation($head_id, "genus", $genus_np);
    }


    # GenusNP of NP => (genus-spec NP) [(genus-spec-attr NP-adj)]
    #
    # business#7: the/DT volume/NN of/IN business/NN activity/NN
    #	genus-spec activity
    &debug_out(7, "checking: GenusNP of NP\n");
    if (($pattern =~ /^($NP_)($PREP_)($NP_)/)
	&& ($words{$2} eq "of")) {
	$genus = $1; $np2 = $3;

	## &add_relation($head_id, "genus-spec", $np2);
	&add_relation($genus, "spec", $np2, 2);
    }


    # GenusNP of PresPart AdjP => (qual PresPart) (complement AdjP)
    #
    # action#5: the/DT trait/NN of/IN being/VBG active/JJ and/CC energetic/JJ and/CC forceful/JJ
    #
    # TODO: reconcile with "GenusNP for PRESPART (NP)" rule
    #
    &debug_out(7, "checking: GenusNP of being NP\n");
    if ($pattern =~ (/^($NP_)($PREP_)($VERBFORM_)($ADJP_)/) 
	&& ($words{$2} eq "of")) {
	$genus = $1; $action = $3; $adjp = $4;

	&add_relation($genus, "qual", $action);
	&add_relation($action, "complement", $adjp, 2);
    }


    # GenusNP PASTPART ... by NP => (agent NP)
    #
    # land#4: the/DT territory/NN occupied/VBN by/IN a/DT nation/NN
    # head#8: the/DT pressure/NN exerted/VBN by/IN a/DT fluid/NN
    #
    # TODO: restore punctuation into pattern for easier matching
    #       derive feature vector for defining words during preprocessing
    #       keep in synch with the previous rule
    #
    &debug_out(7, "checking: GenusNP PASTPART ... by NP\n");
    if (($pattern =~ /^($NP_)($VERBFORM_)([^;.]*)($PREP_)($NP_)/)
	&& ($words{$4} eq "by")) {
	local($np2) = $5;

	# in wordnet: "causal_agent isa entity"
	$relation = "manner-subj";
	if (has_feature($phr_head{$np2}, "agentive")) {
	    $relation = "agent";
	}

	&add_relation($head_id, $relation, $np2);
    }


    # GenusNP [PASTPART] in NP => (generic-in NP)
    # GenusNP[+concrete] [PASTPART] in NP[+location] => (location NP)
    #
    # room#4: the/DT people/NNS who/WP are/VBP present/JJ in/IN a/DT room/NN
    #
    # TODO: add support for "at"???
    # head#9 (ldoce): a/DT part/NN at/IN the/DT top/NN of/IN an/DT object/NN 
    # which/WDT is/VBZ different/JJ or/CC separate/JJ from/IN the/DT body/NN
    #
    &debug_out(7, "checking: GenusNP [PASTPART] in NP\n");
    if (($pattern =~ /^($NP_)($VERBFORM_)?([^;.]*)($PREP_)($NP_)/)
	&& ($words{$4} eq "in")) {
	$np2 = $5;

	# in wordnet: "causal_agent isa entity"
	$relation = "generic-in";
	if (has_feature($headword, "concrete")
	    && has_feature($phr_head{$np2}, "location")) {
	    $relation = "location";
	}

	&add_relation($head_id, $relation, $np2);
    }

    # Variation on previous that checks for relations to specific senses.
    #
    &debug_out(7, "checking: variation on GenusNP [PASTPART] in NP\n");
    if (($pattern =~ /^($NP_)($VERBFORM_)?([^;.]*)($PREP_)($NP_)/)
	&& ($words{$4} eq "in")) {
	$np2 = $5;

	# in wordnet: "causal_agent isa entity"
	local ($num_rels) = 0;
	if (has_feature($headword, "concrete")) {
	    local($ok, $senses) = has_feature_aux($phr_head{$np2}, "location");
	    foreach $sense (split(/ /, $senses)) {
		&debug_out(4, "\tlocation $sense OR\n");
		$num_rels++;
	    }
	}
	else {
	    $relation = "generic-in";
	}
	if ($num_rels == 0) {
	    &add_relation($head_id, "generic-in", $np2);
	}
    }


    # GenusNP PASTPART PREP NP => (manner PASTPART-PREP) (object NP)
    #
    # church#3: a/DT service/NN conducted/VBN in/IN a/DT church/NN
    #
    &debug_out(7, "checking: GenusNP PASTPART PREP NP\n");
    if ($pattern =~ /^($NP_)($VERBFORM_)($PREP_)($NP_)/) {
	$action = $2; $prep = $words{$3}; $np2 = $4;

	&add_relation($head_id, "manner", $action); 
	&add_relation($head_id, "object", $np2, 2); 

    }


    # GenusNP for PRESPART (NP) => (used-for PRESPART) (object NP)
    #
    # case#5: a/DT portable/JJ container/NN for/IN carrying/VBG 
    #         several/JJ objects/NNS
    #
    &debug_out(7, "checking: GenusNP for PRESPART\n");
    if ($pattern =~ /^($NP_)($PREP_)($VERBFORM_)($NP_)?/) {
	$prep = $2; $action = $3; $object = $4;
	$prep_word = $words{$prep};
	
	$relation = "generic-$prep_word";
	if (defined($as_relation{$prep_word})) {
	    $relation = $as_relation{$prep_word};
	}

	## &add_relation($head_id, "used-for", $action);
	&add_relation($head_id, $relation, $action);
	&add_relation($head_id, "object", $object, 2) if (defined($object));
    }


    # GenusNP for NP [+agentive] => (beneficiary NP)
    # GenusNP for NP => (purpose NP)
    #
    #    air#11: medium/NN for/IN radio/NN broadcasting/NN
    #
    &debug_out(7, "checking: GenusNP for NP [+agentive]\n");
    if (($pattern =~ /^$NP_($PREP_)($NP_)/) 
	&& ($words{$1} eq "for")) {
	$object = $2;

	# Determine the most likely relation
	$relation = "purpose";
	if (has_feature($phr_head{$object}, "agentive")) {
	    $relation = "beneficiary";
	}

	&add_relation($head_id, $relation, $object);
    }


    # GenusNP (PREP) who VERB NP => (attr human) (action VERB NP1)
    #
    # head#9: the/DT educator/NN who/WP has/VBZ executive/JJ authority/NN
    # for/IN a/DT school/NN
    #
    # TODO: reconcile this with the next two pattern rules
    #
    &debug_out(7, "checking: GenusNP (PREP) who VERB NP\n");
    if ($pattern =~ /^($NP_)($PREP_$NP_)?($WHPRON_)($VP_)($NP_)/) {
	$action = $4; $object = $5;

	printf "\tattr human%s\n", ($include_cat ? "/noun" : "");
	&add_relation($head_id, "action", $action);
	&add_relation($head_id, "object", $object, 2);
    }



    # GenusNP (PREP) that VERB NP => (VERB NP1)
    #
    # result#2: a/DT statement/NN that/WDT solves/VBZ a/DT problem/NN
    # 	(solves problem)
    #
    # TODO: merge with the next pattern rule
    #       define $GenusNP as ^($NP_)($PREP_$NP_)?
    #
    &debug_out(7, "checking: GenusNP (PREP) that VERB NP\n");
    if ($pattern =~ /^($NP_)($PREP_$NP_)?($COMP_)($VP_)($NP_)/
	&& ($words{$3} eq "that")) {
	$action = $4; $np2 = $5;

	## $relation = $words{$action};
	## &add_relation($head_id, "'$relation'", $np2);
	&add_relation($head_id, "qual", $action);
	&add_relation($action, "object", $np2, 2);
    }



    # GenusNP that VERB NP to NP => (recipient NP2)
    #
    # action#4: the/DT operating/VBG part/NN that/WDT transmits/VBZ 
    # 	    power/NN to/TO a/DT mechanism/NN 
    # 	(transmits power)
    # 	(recipient mechanism)
    #
    &debug_out(7, "checking: GenusNP that VERB NP to NP\n");
    if ($pattern =~ /^($NP_)($COMP_)$VP_$NP_($PREP_)($NP_)/
	&& ($words{$2} eq "that")
	&& ($words{$3} eq "to")) {
	$np2 = $4;

	&add_relation($head_id, "recipient", $np2);
    }


    # GenusNP with NP => (having NP) [(having-attr NP-adj)]
    # GenusNP[+concrete] with NP[+concrete] => (has-part NP)
    #
    # community#2: an/DT association/NN of/IN people/NNS 
    #		   with/IN similar/JJ interests/NNS
    # table#4: flat/JJ tableland/NN with/IN steep/JJ edges/NNS 
    #
    # TODO: filter out collocational usages such as "concern with":
    #
    # interest#2: a/DT sense/NN of/IN concern/NN with/IN and/CC 
    #		  curiosity/NN about/IN someone/NN or/CC something/NN
    #	
    &debug_out(7, "checking: GenusNP with NP\n");
    if ($pattern =~ (/^$NP_($PREP_$NP_)?($PREP_)($NP_)/) 
	&& ($words{$2} eq "with")) {
	$np2 = $3;

	$relation = "having";
	if (&has_feature($headword, "concrete")
	    && &has_feature($phr_head{$np2}, "concrete")) {
	    $relation = "has-part";
	}

	&add_relation($head_id, $relation, $np2);
    }


    # NP used to INF NP => noun generic-for verb
    #
    #    implement#1: a/DT piece/NN of/IN equipment/NN or/CC tool/NN
    #    	      used/VBN to/TO effect/VB an/DT end/NN 
    #
    # TODO: reconcile with "used for" rule  below
    #
    &debug_out(7, "checking: NP used to INF NP\n");
    if (($pattern =~ /^$NP_($VP_)($PREP_)($VP_)($NP_)?/) 
	&& ($words{$1} eq "used")
	&& ($words{$2} eq "to")) {
	$action = $3; $object = $3;

	&add_relation($head_id, "instrument-in", $action);
	&add_relation($head_id, "object", $object, 2) if (defined($object));
    }


    # (FieldName) GenusNP ... => (field FieldName)
    #
    #	class#7: (biol/NN) a/DT taxonomic/JJ group/NN containing/VBG
    #	one/CD or/CC more/JJR orders/NNS
    #
    # NOTE: usage labels, which have a simple pattern except with an
    #       adjective or adverb, are ignored
    #
    &debug_out(7, "checking: (FieldName) GenusNP\n");
    if ($pattern =~ /^\(($NP_)\)/) {
	$field = $1;

	&add_relation($head_id, "field", $field);
    }


    # GenusNP (Prep [NP])+ => (generic-prep1 NP1) ...
    #
    # Generic rule to get remaining relations to the Genus head
    # NOTE: These relations will only be added if the objects haven't
    #       already been used in a relation just derived
    #
    &debug_out(7, "checking: GenusNP (Prep [NP])+\n");
    $next_pat = "";
    for ($pat = $pattern; $pat =~ /^($NP_)($PREP_)($NP_)/; $pat = $next_pat) {
	$genus_np = $1; $prep = $words{$2}; $np2 = $3;
	$next_pat = $genus_np . $';

	&add_relation($head_id, "generic-$prep", $np2);
    }


}


#------------------------------------------------------------------------------


# derive_verb_rels(def_pattern): derive lexical relations for verb entries
#
sub derive_verb_rels {
    local($pattern) = @_;
    &debug_out(4, "derive_verb_rels(@_)\n");

    # GenusVERB (ADV) (NP) => (genus GenusVERB) [(manner ADV)] [(object NP)]
    #
    # meet#2: come/VB together/RB 
    #	(genus come) (manner together)
    #
    &debug_out(7, "checking: GenusVERB (ADV) (NP)\n");
    if ($pattern =~ /^($VP_)($NP_)?/) {
	$genus_vp = $1; $object = $2;

	&add_relation($head_id, "genus", $genus_vp);
	&add_relation($head_id, "object", $object) if (defined($object));
    }


    # <start> of NP => (example-object NP_head)
    #
    # hold#9: have/VB rightfully/RB ; of/IN rights/NNS and/CC titles/NNS
    #	(example-object rights and titles)
    #
    &debug_out(7, "checking: \n");
    if (($pattern =~ /^($PREP_)($NP_)/) && ($words{$1} eq "of")) {
	$object = $2;

	print "\texample\n";
	&add_relation($head_id, "object", $object, 2);
    }


    # as of NP => (example-object NP_head)
    # as in NP => (example-subject NP_head)
    # as by PresPart => (example-means PresPart_head)
    #
    &debug_out(7, "checking: \n");
    if (($pattern =~ /(^|[,])($PREP_)($PREP_)/) 
	&& ($words{$2} eq "as")) {
	$prep2 = $3; $rest = $';

	# Determine the relation to use
	$prep2_word = $words{$prep2};
	$relation = "object";
	if (defined($as_relation{$prep2_word})) {
	    $relation = $as_relation{$prep2_word};
	}

	# If the object is a noun phrase or verbal, then add the relation
	# to the object.
	if ($rest =~ /^($NP_)/) {
	    $object = $1;
	    print "\texample\n";
	    &add_relation($head_id, $relation, $object, 2);
	}
	elsif ($rest =~ /^($VERBFORM_),?/) {
	    # TODO: handle this via phrase grouping
	    $object = $1;
	    $rest = $';

	    print "\texample\n";
	    &add_relation($head_id, $relation, $object, 2);
	    
	    while ($rest =~ /^($VERBFORM_),?/) {
		$object = $1; $rest = $';

		&add_relation($head_id, $relation, $object, 2);
	    }
	}
    }


    # GenusVP ... PREP NP => (PREP_relation NP_head)
    # GenusVP ... PREP PRES_PART [NP] => (PREP_relation PRES_PART)
    #
    #    appear#3: be/VB issued/VBN or/CC published/VBN , as/IN of/IN news/NN
    #              in/IN a/DT paper/NN , a/DT book/NN , or/CC a/DT movie/NN
    #
    # TODO: restrict what can occur in the "..."
    #
    &debug_out(7, "checking: \n");
    $next_pat = "";
    for ($pat = $pattern; $pat =~ /($PREP_)/; $pat = $next_pat) {
	$prep = $words{$1}; $rest = $';

	$object = undef;
	$attr = undef;
	&debug_out(5, "rest=$rest\n");
	if ($rest =~ /^($NP_)/) {
	    $object = $1;

	    &add_relation($head_id, "generic-$prep", $object);
	}
	elsif ($rest =~ /^($ADV_)?($VERBFORM_)($NP_)?/) {
	    $manner = $1; $action = $2; $object = $3;

	    &add_verb_modifier($action, $manner) if (defined($manner));
	    &add_relation($head_id, "generic-$prep", $action);
	    &add_relation($action, "object", $object, 2) if (defined($object));
	}
	$next_pat = $';
    }

}


# add_modifier(const_id, attr_id);
#
# Add a modifier to the verb, unless it is already attached. This is
# meant to be used by rules that augment the pattern transformation.
# 
sub add_modifier {
    local ($const_id, $attr_id) = @_;
    local ($attr) = $phr_head{$attr_id};

    if (!defined($phr_attr{$const_id})) {
	local($suffix) = ($include_cat ? "/$POS{$attr_id}" : "");
	$phr_attr{$const_id} = "$attr$suffix";
    }
    elsif ($phr_attr{$const_id} ne $attr) {
	local($suffix) = ($include_cat ? "/$POS{$attr_id}" : "");
	$phr_attr{$const_id} .= ";$attr$suffix";
    }

    return;
}


sub add_verb_modifier {
    add_modifier(@_);
}


#------------------------------------------------------------------------------


# init_transform(): initialize the transformation module
#
# global variables:
#	$special_tag{<punct_etc>} = "TAG_NAME"; 
#       $pos_pattern{<cat_name>} = '<pos_regex>';
#
sub init_transform {
    ## local ($special, $cat);
    local ($cat);

    # Create special tags names for punctuation, etc. 
    # NOTE: these mustn't conflict with any of the grammatical category names
    #       (or any other variables ending in an underscore)
    # TODO: just use the punctuation as is since it makes regular expressions simpler
    #
    ## $special_tag{"("} = "PAREN";
    ## $special_tag{")"} = "PAREN";
    ## $special_tag{"."} = "PERIOD";
    ## $special_tag{","} = "COMMA";
    ## $special_tag{";"} = "SEMICOLON";

    ## # Initialize the variable associated with each of the special tags
    ## foreach $special (keys(%special_tag)) {
	## $tag = $special_tag{$special};
	## # initialize the pattern variable (eg, "$PAREN_ = 'PAREN\d+_'")
	## eval "\$${tag}_ = '${tag}\\d+_'";
    ## }

    # Initialize the patterns for converting Penn Treebank POS tags
    #
    # Notes: 
    #	the pattern must cover the entire tag
    #	pronouns are treated as adjectives
    # 	modals are treated as adverbs
    #
    $pos_pattern{"NOUN"} = 'NN[SP]?';
    ## $pos_pattern{"PRON"} = '(PP[\$]?)|(PRP[\$]?)';
    $pos_pattern{"WHPRON"} = '(WP[\$Z]?)';
    $pos_pattern{"VERBFORM"} = 'VB[GN]';
    $pos_pattern{"VERB"} = 'VB[DPZ]?';
    $pos_pattern{"CONJ"} = 'CC';
    $pos_pattern{"COMP"} = '(WDT)';
    $pos_pattern{"DET"} = '(DT)';
    ## $pos_pattern{"ADJ"} = 'JJ[RS]?';
    $pos_pattern{"ADJ"} = '(JJ[RS]?)|(PP[\$]?)|(PRP[\$]?)';
    $pos_pattern{"ADV"} = '(RB[RS]?)|(MD)';
    $pos_pattern{"PREP"} = '(TO)|(IN)';
    $pos_pattern{"ADJP"} = 'N/A';
    $pos_pattern{"NP"} = 'N/A';
    $pos_pattern{"VP"} = 'N/A';

    # Initialize the variable associated with each of the POS pattern
    foreach $cat (keys(%pos_pattern)) {
	# initialize the pattern variable (eg, "$NOUN_ = 'NOUN\d+_'")
	eval "\$${cat}_ = '${cat}\\d+_';";
    }

    # Make explicit references of dynamic variabls to avoid Perl warnings 
    ## &debug_out(9, "$PAREN_ $PERIOD_ $COMMA_ $SEMICOLON_\n");
    &debug_out(9, "$NOUN_ $WHPRON_ $VERBFORM_ $VERB_ $CONJ_ $COMP_ $DET_ $ADJ_ $ADV_ $PREP_ $NP_\n");

    # Specify synsets indicating certain features (see has_feature below)
    #
    # NOTE: This requires the use of a customized version of WordNet
    #       that incorporates the sense indicators.
    #
    # TODO: see if someone has already done a similar mapping
    #
    $feature_synsets{"agentive"} = "causal_agent#1 organization#1 people#1";
    $feature_synsets{"concrete"} = "entity#1 shape#2 region#1 group#1";
    $feature_synsets{"location"} = "location#1 form#6 structure#1";
}


# convert_POS(part-of-speech)
#
# Converts from the part of speech (using Penn Treebank tags) into the
# more traditional categories (eg, NOUN, VERB, PREP).
#
# NOTE: make sure the most specific checks are made first
#
sub convert_POS {
    local ($POS) = @_;
    local ($cat) = "UNK";

    local ($test_cat);
    foreach $test_cat (keys(%pos_pattern)) {
	local($pattern) = $pos_pattern{$test_cat};
	if ($POS =~ /^$pattern$/) {
	    $cat = $test_cat;
	    last;
	}
    }
    &debug_out(7, "convert_POS($POS) => $cat\n");

    return ($cat);
}


# transform_tags(headword-specification, tagged-definition)
#
# Transform the tagged sentence into a string of unique grammatical 
# category ID's for later pattern matching. The ID's can be used to
# index into associative arrays giving the original word and Penn
# Treebank part of speech.
#
# the/DT length/NN of/IN time/NN something/NN ( or/CC someone/NN ) 
# has/VBZ existed/VBN
#
# => 
#
# DET1_NOUN2_PREP3_NOUN4_NOUN5_CONJ6_NOUN7_VERB8_VERB8_
#
# $word{"$DET1"} = "the"; 	$POS{"DET1"} = "DT";
# $word{"$NOUN2"} = "length"; 	$POS{"NOUN2"} = "NN";
# ...
#
# NOTE: The ID's consist of the grammatical category followed by the
#       position of the word/token in the sentence, followed by an
#	    underscore.
#
# TODO: clear the associative arrays before each new sentence
#
# global variables:
#   $words{<ID>}:  hash table from category ID to word at that position
#   $POS{<ID>}:    hash table from category ID to part of speech
#   $words[]:      array of words in the text (for debugging purposes)
#   $head_id:	   dummy category id for the headword
#

sub transform_tags {
    local($head_spec, $text) = @_;
    local($cat, $id);

    # Apply fixup's to tagger quirks
    $text =~ s/one\'s\/NNS/one\'s\/PP\$/;

    # Create dummy entry for the headword (eg, with id NP0_)
    $head_id = sprintf "%s0_", (($POS eq "verb") ? "VP" : "NP");
    $phr_head{$head_id} = "$head_spec";
    $phr_attr{$head_id} = undef;

    local($num) = 1;
    local($pattern) = "";
    @words = ("^");
    while ($text =~ /([\w:;.,()\']+)\/([A-Z\$:;.,()]+)/) {
	local($untagged) = $`;
	local($word) = $1;	# extract word proper
	local($POS) = $2;	# Penn Treebank part of speech
	$text = $';		# remainder of text

	# Add any untagged text to the associative array
	if (defined($untagged) && ($untagged !~ /^\s*$/)) {
	    &debug_out(7, "untagged=$untagged; len=%d\n", length($untagged));
	    &assert('$untagged ne ""');
	    $untagged =~ s/\s+//g;
	    if (defined($special_tag{$untagged})) {
		$id = "$special_tag{$untagged}${num}_";
	    }
	    else {
		$id = "UNK${num}_";
	    }
	    $words{$id} = "$untagged";
	    $words[$num] = $words{$id};
	    $POS{$id} = "???";
	    $pattern .= "$id";
	    $num++;
	    # TODO: convert all usage of $words{} => $phr_head{}
	    $phr_head{$id} = $words{$id};
	    $phr_attr{$id} = undef;
	}

	# Add punctuation to the pattern, as is
	if ($POS =~ /[:;.,()]/) {
	    $pattern .= "$word";
	}

	# Otherwise, add the tagged word to the associative array
	else {
	    $cat = &convert_POS($POS);
	    $id = "${cat}${num}_";
	    $words{$id} = $word;
	    $words[$num] = $words{$id};
	    $POS{$id} = "$POS";
	    $pattern .= "$id";
	    $num++;
	    $phr_head{$id} = $words{$id};
	    $phr_attr{$id} = undef;
	}
    }
    $words[$num] = "\$";
    &debug_out(5, "pattern='$pattern'\n");
    &debug_out(6, "words='%s'\n", join(":", @words));

    # Pattern variables for the traditional grammatical categories. 
    # As indicated above the categories include the sentence position 
    # in order for the token to be unique. (Note the required underscore.)
    #
    # $NOUN_ = 'NOUN\d+_';
    # $VERB_ = 'VERB\d+_';
    # $VERBFORM_ = 'VERBFORM\d+_';
    # $DET_ = 'DET\d+_';
    # $PREP_ = 'PREP\d+_';
    # $COMP_ = 'COMP\d+_';
    # $ADJ_ = 'ADJ\d+_';
    # $NP_ = 'NP\d+_';
    # &debug_out(9, "$NOUN_; $VERB_; $VERBFORM_; $DET_; $PREP_; $COMP_; $ADJ_; $NP_;\n");

    return ($pattern);
}



# group_noun_phrases(POS_pattern)
#
# Group the noun phrases together, and extract the heads.
# The values are placed in the np_head & np_attr arrays.
# NOTE: This is separate from the associative array used above.
#
# Each noun phrase group will be replaced by NPn, 
#    "a/DT military/JJ engagement/NN" => "NP1"
# The index can be used to determine which entry in the
# array holds the corresponding values.
#
# TODO: use co-occurrence counts to decide whether consecutive nouns
#       should be grouped together:
#           and/CC telephone/NN numbers/NNS => (CONJ NOUN NOUN)
#           of/IN time/NN something/NN  => (PREP NOUN) NOUN
#
# NOTE: As with other category ID's, the format is NP<num>_ (and ADJ<num>_)
#
# global variables:
#   $phr_head{<ID>}:    hash table: category ID to noun phrase headword
#   $phr_attr{<ID>}:    hash table: category ID to optional attribute 
#   $phr_pattern{<ID>}: hash table: category ID to constituent pattern
#

sub group_noun_phrases {
    local ($pattern) = @_;
    local ($head, $attr, $num, $id);


    # Group all cases of [Adv] [Adj [conj Adj]] into AdjP
    #
    # NOTE: This treats a PastPart verb as an adjective when it is 
    #       followed by noun or conjunction and another adjective.
    # TODO: simplify the pattern matching
    #
    for ($num = 1; 
		#  $N:    12       3            4
	 (  ($pattern =~ /(($ADV_)?($ADJ_))/)
      || ($pattern =~ /(($ADV_)?($VERBFORM_))($NOUN_|$CONJ_$VERBFORM_$NOUN_)/)
      || ($pattern =~ /(($ADV_)?($VERBFORM_))($NOUN_|$CONJ_$ADJ_)/)
	    );
	 $num++) {
	$phr_pattern = $1; $adv = $2; $adj = $3; # ignores $4

	# Combine the attributes (TODO: allow repetition)
	$head = undef;
	$attr = undef;
	if (defined($adv)) {
	    if ($include_cat) {
		$head = "$words{$adv}/adverb-$words{$adj}/adjective";
		}
	    else {
		$head = "$words{$adv}-$words{$adj}";
		}
	}
	else {
	    $head = $words{$adj};
            $head .= "/adjective" if ($include_cat);
	}

	$id = "ADJP${num}_";
	&add_phrase($id, $head, $attr, $phr_pattern, "adjective");
	$pattern =~ s/$phr_pattern{$id}/$id/;
    }
    &debug_out(6, "temp reduced pattern='$pattern'\n");

    # Combine adjacent AdjP's with optional conjunction
    while ($pattern =~ /($ADJP_)($CONJ_)?($ADJP_)/) {
	$adj1 = $1; $conj = $2; $adj2 = $3;
	$conj_words = (defined($conj) ? $words{$conj} : "");

	$head = "$phr_head{$adj1} $conj_words $phr_head{$adj2}";
	$attr = undef;
	$id = "ADJP${num}_";
	&add_phrase($id, $head, $attr, $&, "adjective");
	$pattern =~ s/$phr_pattern{$id}/$id/;
	$num++;
	}
    &debug_out(5, "reduced pattern='$pattern'\n");

    # Group all cases of [Det] [Adj|VerbForm] Noun
    #
    for ($num = 1;  $pattern =~ /($DET_)?($ADJP_)?($NOUN_)/; $num++) {
	local($adj, $noun) = ($2, $3);

	$head = $words{$noun}; 
	$head .= "/noun" if ($include_cat);
	$attr = (defined($adj) ? $words{$adj} : undef);
        ## $attr .= "/adjective" if ($include_cat && defined($attr));
	$id = "NP${num}_";
	&add_noun_phrase($id, $head, $attr, $&, "noun");
	$pattern =~ s/$phr_pattern{$id}/$id/;
    }
    &debug_out(6, "temp reduced pattern='$pattern'\n");

    # Combine NP's and adjacent Nouns when the relation is unequivocal
    # TODO: look up verb subcategorization & add heuristics for combination
    while ($pattern =~ /($NP_)($CONJ_)?($NP_)/) {
	$np1 = $1; $conj = $2; $np2 = $3; 

	if (defined($conj)) {
	    $head = "$phr_head{$np1} $words{$conj} $phr_head{$np2}";
	    $attr = (defined($phr_attr{$np1}) ? "$phr_attr{$np1};" : "n/a; ");
	    $attr .= (defined($phr_attr{$np2}) ? "$phr_attr{$np2}" : "n/a");
	    $attr = undef if ($attr eq "n/a; n/a");
	}
	else {
	    $head = $phr_head{$np2};
	    $attr = $phr_head{$np1};
	}

	$id = "NP${num}_";
	&add_noun_phrase($id, $head, $attr, $&, "noun");
	$pattern =~ s/$phr_pattern{$id}/$id/;
	$num++;
    }
    &debug_out(5, "reduced pattern='$pattern'\n");

    return ($pattern);
}


# add_noun_phrase(cat_id, noun_cat, attr_cat, np_pattern)
#
# Create an entry for the noun phrase in the associative array(s)
# keyed off of the category id (eg, NP2).
#
sub add_noun_phrase {
    local ($id, $head, $attr, $np_cats, $POS) = @_;
    &debug_out(6, "add_noun_phrase($id, $head, %s, $np_cats, $POS)\n", 
	       &text($attr));

    $phr_head{$id} = $head;
    $phr_attr{$id} = $attr;
    $phr_pattern{$id} = $np_cats;
    $words{$id} = $phr_head{$id}; # TODO: handle other words in the phrase
    $POS{$id} = $POS;
    &assert('defined($phr_head{$id})');

    return;
}



# add_phrase(cat_id, noun_cat, attr_cat, np_pattern, cat)
#
# Create an entry for the phrase in the associative array(s)
# keyed off of the category id (eg, NP2).
#
# TODO: have add_noun_phrase & add_verb_phrase be wrappers around this
#
sub add_phrase {
    local ($id, $head, $attr, $phr_cats, $POS) = @_;
    &debug_out(6, "add_phrase($id, $head, %s, $phr_cats, $POS)\n", 
	       &text($attr));

    $phr_head{$id} = $head;
    $phr_attr{$id} = $attr;
    $phr_pattern{$id} = $phr_cats;
    $words{$id} = $phr_head{$id}; # TODO: handle other words in the phrase
    $POS{$id} = $POS;
    &assert('defined($phr_head{$id})');

    return;
}


# get_attr(constituent, default_value)
#
sub get_attr {
    local ($const, $default) = @_;
    local ($attr) = $default;
    $attr = $phr_attr{$const} if (defined($phr_attr{$const}));
    return ($attr);
}

# group_verb_phrases(POS_pattern)
#
# Group the verb phrases together, and extract the heads. 
# The values are placed in the vp_head & vp_attr arrays.
#
# Each verb phrase group will be replaced by VPn
#    "continue/VB or/CC extend/VB" => "VP1"
# The index can be used to determine which entry in the
# array holds the corresponding values.
#
# Notes: 
#   The arguments are not included in the grouping.
#
#   As with other category ID's, the format is VP<num>_
#
# global variables:
#   $phr_head{<ID>}:    hash table: category ID to verb phrase headword
#   $phr_attr{<ID>}:    hash table: category ID to optional attribute 
#   $phr_pattern{<ID>}: hash table: category ID to constituent pattern
#

sub group_verb_phrases {
    local ($pattern) = @_;
    local ($head, $attr, $num, $id);

    # Remove leading "to" from the pattern since it is assumed
    if (($pattern =~ /^($PREP_)/) && ($words{$1} eq "to")) {
        &debug_out(4, "dropping leading \"to\" in $pattern\n");
        $pattern =~ s/$1//;
    }

    # Fix up problems with leading verb being tagged as a noun
    if ($pattern =~ /^((NOUN|ADJ)(\d+)_)/) {
        local($head) = $1;
	local($word_pos) = $3;		# the position within the sentence
	local($verb_def);
	local($head_word) = $words{$head};
	
	# See if the head is actually a verb
	$verb_def = &wn_get_defs($head_word, "verb");
	if ($verb_def =~ /$head_word#1/) {
	    &debug_out(4, "fixing up mistagged verb: $head_word\n");
	    $id = "VERB${word_pos}_";
	    $pattern =~ s/$head/$id/;
	    $words{$id} = $head_word;
	    $POS{$id} = "VB";
	}
    }

    # Group all cases of Verb [Adverb]
    #
    for ($num = 1;  #  1       2       3       45       6       7
	 ($pattern =~ /($ADV_)?($VERB_)($ADV_)?(($CONJ_)($VERB_)($ADV_)?)?/);
	 $num++) {
	$pre_adv = $1;
	$verb = $2; $adv = $3; $conj = $5; $verb2 = $6; $adv2 = $7;

	# Extract the headword (along with optional conjunct(s))
	assert('!(defined($pre_adv) && defined($adv))');
        $attr =  defined($pre_adv) ? $words{$pre_adv} : 
	         defined($adv) ? $words{$adv} :
	         undef;
	$attr .= "/adverb" if ($include_cat && defined($attr));
	$head = $words{$verb}; 
	$head .= "/verb" if ($include_cat);
	if (defined($verb2)) {
	    $head .= " $words{$conj} $words{$verb2}";
	    $head .= "/verb" if ($include_cat);
	    if (defined($adv2)) {
		$attr = "" if (!defined($attr));
		$attr .=  "n/a; $words{$adv2}";
		$attr .= "/adverb" if ($include_cat);
	    }
	}

	$id = "VP${num}_";
	&add_verb_phrase($id, $head, $attr, $&, "verb");
	$pattern =~ s/$phr_pattern{$id}/$id/;
    }
    &debug_out(6, "temp reduced pattern='$pattern'\n");

    # Combine adjacent VPs (when the relation is unequivocal)
    # TODO: look up verb subcategorization & add heuristics for combination
    while ($pattern =~ /($VP_)(($VP_)|($VERBFORM_))/) {
	$vp1 = $1; $vp2 = $3; $verbform = $4;
	if (defined($vp2)) {
	    # TODO: account for undefined attr values
	    $head = "$phr_head{$vp1}/$phr_head{$vp2}";
	    ## $attr = "$phr_attr{$vp1}/$phr_attr{$vp2}";
	    $attr = sprintf "%s/%s", 
	                    &get_attr($vp1, "-"), &get_attr($vp2, "-");
	}
	else {
	    $head = "$phr_head{$vp1}-$words{$verbform}";
	    $head .= "/verb" if ($include_cat);
	    $attr = $phr_attr{$vp1};
	}
	$id = "VP${num}_";
	&add_verb_phrase($id, $head, $attr, $&, "verb");
	$pattern =~ s/$phr_pattern{$id}/$id/;
	$num++;
    }
    &debug_out(5, "reduced pattern='$pattern'\n");

    return ($pattern);
}


sub text {
    local($string) = @_;
    $string = "<undef>" if (!defined($string));
}


# add_verb_phrase(cat_id, verb_cat, attr_cat, np_pattern, cat)
#
# Create an entry for the verb phrase in the associative array(s)
# keyed off of the category id (eg, VP2).
# TODO: reconcile w/ add_noun_phrase
#
sub add_verb_phrase {
    local ($id, $head, $attr, $vp_cats, $POS) = @_;
    &debug_out(6, "add_verb_phrase($id, $head, %s, $vp_cats, $POS)\n", 
	       &text($attr));

    $phr_head{$id} = $head;
    $phr_attr{$id} = $attr;
    $phr_pattern{$id} = $vp_cats;
    $words{$id} = $phr_head{$id}; # TODO: handle other words in the phrase
    $POS{$id} = $POS;
    &assert('defined($phr_head{$id})');

    return;
}


#----------------------------------------------------------------------------

# has_feature($word, $feature)
#
# Determine whether the word has the indicated feature. This is approximated
# by checking the WordNet hypernym hierarchy for the word for a high-level
# synset indicative of the category. 
#
# NOTE: In order to avoid problems caused by special case senses having
#       the feature (eg, "study#9" isa "causal_agent"), more than 1/4th of 
#       the senses must have the feature.
#
#       The new depth indicator in the ancestor listing is ignored
#       (eg, "1: plastic_art#1  2: art#1 fine_art#1")
#
# TODO: handle negative features
#       Limit the relation to the synsets having the feature
#
# global variables:
#	$feature_synsets{<feature>}	space-delimited list of synsets

sub has_feature {
    local($word, $feature) = @_;

    local($ok, $ok_senses) = &has_feature_aux($word, $feature);
    return ($ok);
}


sub has_feature_aux {
    local($word, $feature) = @_;    
    local($ancestor_list, $num_ancestors, $num_good, $synset, $ok);
    local($ok, $ok_senses) = (0, "");

    # Check each ancestor synset to see if in associated synset indicator list
    # NOTE: get_ancestors returns a list of ancestors per sense
    $num_ancestors = $num_good = 0;
    &assert('defined($feature_synsets{$feature})');
    foreach $ancestor_list (split(/\t/, &wn_get_ancestors($word, $POS))) {
	$num_ancestors++;
	foreach $synset (split(/ /, $feature_synsets{$feature})) {
	    if (index($ancestor_list, $synset) != -1) {
		$num_good++;
		local($sense) = $ancestor_list;
		$sense =~ s/:.*//;
		$ok_senses .= "$sense ";
		last;
	    }
	}
    }
    if (($num_ancestors > 0) && (($num_good / $num_ancestors) >= 0.25)) {
	$ok = &TRUE;
    }

    &debug_out(5, "has_feature($word, $feature) => $ok (%d of %d)\n",
	       $num_good, $num_ancestors,);

    return (($ok, $ok_senses));
}

