#! /bin/csh -f
#
# get_collocations.sh: Produce the lists of collocations that are used
# to implement features for statistical classification. See getfmc6.1.c
# for where these are used. This is a helper script to run_experiment.sh.
#
# The collocations should only be based on the training data. Therefore,
# during cross-fold validation, a sentence ID file is maintained for each
# fold and each dataset type (e.g., SIDFILE.train0 and SIDFILE.test0).
# The variable sidfile indicates the file to use and is set by
# run_experiment.sh.
#
# NOTES: 

# This is sourced within run_experiment.sh to avoid having to pass paramaters.
#
# See get_wsd_collocations.sh for a streamlined version (easier to follow).
#
# The following variables are assumed:
#     file                full pathname
#     base                base of file name
#     colls_anywhere      1 for anywhere in sentence
#     colls_within        1 for within-X
#     colls_pattern       1 to use syntactic patterns
#     use_new_CI          1 to use new CI method
#     use_g2_test         1 to use G^2 test for collocations
#     sidfile             name of current SIDFILE (eg, SIDFILE.train2)
#     do_word_sense       feature classification is word sense not POV
#     organization        feature organization to use (PC1, PC2, OR1, OR2)
#
# TODO:
# - Rename 'collset_adj_' to 'collset_adjacency_'.
# - reorganize around the four main groups for the experiments
# (OR-1 OR-2 PC-2 PC-2) as follows:
# 
# 	Test	Collocations		Features     Number of Vaules
# 
# OR-1	G^2	v_collset(10 words)     F48	     11	       
# 		a_collset(10 words)	F49	     11
#  		n_collset(10 words)	F50	     11
# 
# OR-2	G^2	g2collset(21 words)	21 features  binary	     
# 
# 
# PC-1	CI	collset_other		F33	     binary
# 		collset_ps		F34	     binary
# 		collset_psevent		F35	     binary
# 		collset_se.ds		F36	     binary
# 		collset_se.ms		F37          binary
# 		collset_se.o		F38	     binary
# 
# PC-2	CI	v_C (6 sets)		F45	     7
# 		a_C (6 sets)		F46	     7
# 		n_C (6 sets)		F47	     7
# 
# NOTES:
# - This above table is somewhat misleading for PC-1 & PC2. 
#   See run_experiment.sh for a revised version.
# - For details on the collocation schemes, see
#      Wiebe, Janyce, Kenneth McKeever, and Rebecca Bruce (1998), "Mapping
#      collocational properties into machine learning features", In Proc. 
#      6th Workshop on Very Large Corpora (WVLC-98), pages 225-233, Montreal.
# - Getting Collocations by Conditional Independence (CI) Test
#   
#   In each case the following steps are performed:
#      - Extract the collocations from the preprocessed file
#      - Sort the extracted output list by classification value
#      - Create individual files by class category (eg, n_ps, n_se.o, etc.)
#        with the collocations above a certain association threashold.
#  
#   The end result for each type of collocation is a set of files where
#   all the collocations for a given category are contained in one file.
#   For instance, for "Collocations anywhere in the sentence" there will
#   be six files (collset_other, collset_ps, ... collset_psevent), where
#   each file gives the list of words associated with the corresponding
#   category. An example for the private-state-or-event category follows:
#  
#       collset_psevent:
#       erupt
#       flashpoint
#       proponent
#       skirmish
#       unprecedented
#

if ($DEBUG_LEVEL > 3) set echo = 1

# Determine the script to use for determing the collocations lists,
# and initialize the common arguments for the scripts.
#
set choose_all_script = "choose_all_coll.prl"
set choose_all_script2 = "choose_all_coll2.prl"
set choose_all_arg = ""
if ($use_new_CI == 1) then
    set choose_all_script = "new_choose_all_coll.prl"
    set choose_all_script2 = "new_choose_all_coll2.prl"
    set choose_all_arg = "${base}.t0_est_probabilities"
endif
set args="-word_sense=${do_word_sense}"

## First, estimate the prior probabilities for the classes
perl -sw ${script_dir}/est_probabilities.prl $file $sidfile > ${base}.t0_est_probabilities
cat ${base}.t0_est_probabilities

# Determine which of the collocation organization schemes to use
# TODO: Disable usage in case the corresponding features are not being used,
# as is the case when just hypernym collocations are being used.
set PC1 = ($organization == "PC1")
set PC2 = ($organization == "PC2")
set OR1 = ($organization == "OR1")
set OR2 = ($organization == "OR2")
if ($organization =~ OR*) set use_g2_test = 1

set just_content_words = `printenv just_content_words`
if ("$just_content_words" == "") set just_content_words = 1

if ($PC1 && $colls_anywhere) then
    # Get collocations anywhere in the sentence
    # end result: collset_x for each {other, ps, se.o, se.ds, se.ms, psevent}

    ## ci_coll_all $file ${base}.t1_ci_coll_all 2 $sidfile
    perl -sw ${script_dir}/get_POS_anywhere.perl -just_content_words=$just_content_words $args $file $sidfile ANY > ${base}.t1_ci_coll_all 
    sort +1 ${base}.t1_ci_coll_all -o ${base}.t2_ci_coll_all_sort
    # TODO: make sure the collocations are sorted by the metric
    perl -sw ${script_dir}/${choose_all_script} $args ${base}.t2_ci_coll_all_sort $choose_all_arg
endif


if ($PC1 && $colls_within) then
    # Get collocations within 5 words around the main verb
    # end result: collset_x for each {other, ps, se.o, se.ds, se.ms, psevent}

    ci_coll_all5 $file ${base}.t1_ci_coll_all 2 $sidfile
    sort +1 ${base}.t1_ci_coll_all -o ${base}.t2_ci_coll_all_sort
    perl ${script_dir}/${choose_all_script} ${base}.t2_ci_coll_all_sort $choose_all_arg
endif

if ($PC2 && $colls_anywhere) then
    # Get collocations anywhere arranged by property type (eg, verb)
    # end result: [van]_{class}

    # Verb collocations
    # end result: v_x for each {other, ps, se.o, se.ds, se.ms, psevent}
    get_VerbAny $file ${base}.t3_get_VerbAny 2 $sidfile
    sort +1 ${base}.t3_get_VerbAny -o ${base}.t4_get_VerbAny_sort
    perl ${script_dir}/${choose_all_script2} ${base}.t4_get_VerbAny_sort v $choose_all_arg

    # Adjective collocations
    # end result: a_x for each {other, ps, se.o, se.ds, se.ms, psevent}
    get_AdjAny ${file} ${base}.t5_get_AdjAny 2 $sidfile
    sort +1 ${base}.t5_get_AdjAny -o ${base}.t6_get_AdjAny_sort
    perl ${script_dir}/${choose_all_script2} ${base}.t6_get_AdjAny_sort a $choose_all_arg

    # Noun collocations
    # end result: n_x for each {other, ps, se.o, se.ds, se.ms, psevent}
    get_NounAny $file ${base}.t7_get_baseNounAny 2 $sidfile
    sort +1 ${base}.t7_get_baseNounAny -o ${base}.t8_get_baseNounAny_sort
    perl ${script_dir}/${choose_all_script2} ${base}.t8_get_baseNounAny_sort n $choose_all_arg
endif

if ($PC2 && $colls_within) then
    # Get collocations within X arranged by property type (eg, verb)

    # Verb collocations
    # end result: v_x for each {other, ps, se.o, se.ds, se.ms, psevent}
    get_VerbWin $file ${base}.t3_get_VerbWin 2 $sidfile
    sort +1 ${base}.t3_get_VerbWin -o ${base}.t4_get_VerbWin_sort
    perl ${script_dir}/${choose_all_script2} ${base}.t4_get_VerbWin_sort v $choose_all_arg

    # Adjective collocations
    # end result: a_x for each {other, ps, se.o, se.ds, se.ms, psevent}
    get_AdjWin ${file} ${base}.t5_get_AdjWin 2 $sidfile
    sort +1 ${base}.t5_get_AdjWin -o ${base}.t6_get_AdjWin_sort
    perl ${script_dir}/${choose_all_script2} ${base}.t6_get_AdjWin_sort a $choose_all_arg

    # Noun collocations
    # end result: n_x for each {other, ps, se.o, se.ds, se.ms, psevent}
    get_NounWin $file ${base}.t7_get_baseNounWin 2 $sidfile
    sort +1 ${base}.t7_get_baseNounWin -o ${base}.t8_get_baseNounWin_sort
    perl ${script_dir}/${choose_all_script2} ${base}.t8_get_baseNounWin_sort n $choose_all_arg
endif

if (($PC1 || $PC2) && $colls_pattern) then
    # Get collocations within syntactic patterns.

    # Verb collocations
    # end result: v_x for each {other, ps, se.o, se.ds, se.ms, psevent}
    get_MVColPat $file ${base}.t3_get_MVColPat 2 $sidfile 2
    sort +1 ${base}.t3_get_MVColPat -o ${base}.t4_get_MVColPat_sort
    perl ${script_dir}/choose_all_coll2.prl ${base}.t4_get_MVColPat_sort v

    # Adjective collocations
    # end result: a_x for each {other, ps, se.o, se.ds, se.ms, psevent}
    get_AdjColPat ${file} ${base}.t5_get_AdjColPat 2 $sidfile 2
    sort +1 ${base}.t5_get_AdjColPat -o ${base}.t6_get_AdjColPat_sort
    perl ${script_dir}/choose_all_coll2.prl ${base}.t6_get_AdjColPat_sort a

    # Noun collocations
    # end result: n_x for each {other, ps, se.o, se.ds, se.ms, psevent}
    get_baseNounColPat $file ${base}.t7_get_baseNounColPat 2 $sidfile
    sort +1 ${base}.t7_get_baseNounColPat -o ${base}.t8_get_baseNounColPat_sort
    perl ${script_dir}/${choose_all_script2} ${base}.t8_get_baseNounColPat_sort n $choose_all_arg
endif


# 2. Get collocations by G^2 test 
#
# end result: v_collset, n_collset, a_collset, g2collset
#
# NOTE: By default, up to 10 collocations are produces for {van}_collset
# and up to 100 for g2collset. These can be overridden by setting the
# environment variable MAX_<collset_name> (eg, MAX_g2collset).
#
if ($use_g2_test) then
    set g2_prefix = ("v" "n" "a" "all")
    set pos = 0
    if ($do_word_sense) set pos = 3
    while ($pos < 4)
	# Determine the collocation words
	if ($colls_anywhere == 1) then
	    # G2: Get collocations anywhere in the sentence
	    ## prepare_bigram_any $file ${base}.t9_bigram.$pos $sidfile $pos
	    prepare_bigram_all $file ${base}.t9_bigram.$pos $sidfile $pos
	else if ($colls_within == 1) then
	    # G2: Get collocations within 5 words around the main verb
	    prepare_bigram_all5 $file ${base}.t9_bigram.$pos $sidfile $pos
	else if ($colls_pattern == 1) then
	    # Get collocations within syntactic patterns
	    prepare_bigram_pat $file ${base}.t9_bigram.$pos $sidfile $pos
	else
	    # G2: Get collocations anywhere in the sentence
	    prepare_bigram_all $file ${base}.t9_bigram.$pos $sidfile $pos
	endif

	# Perform G^2 test for independence
	sort ${base}.t9_bigram.$pos -o ${base}.t10_bigram_sort1.$pos
	sort +1 ${base}.t9_bigram.$pos -o ${base}.t11_bigram_sort2.$pos
	g2test2 ${base}.t10_bigram_sort1.$pos ${base}.t11_bigram_sort2.$pos ${base}.t12_g2test2.$pos
	sort -r -n ${base}.t12_g2test2.$pos -o ${base}.t13_g2test2_sort.$pos

	# Choose the collocations. For the V/N/A collocations, the top ten
	# collocations are used. For the combined set, the top 100. 
	#
	## perl ${script_dir}/choose_g2_colls.prl ${base}.temp_g2test2_sort.$pos g2collset 1.5
	## TODO: have a parameter for the cutoff size
	set i = $pos
	@ i++
	set POS_name = ${g2_prefix[$i]}
	set num_collocates = 10
	set collset_file = "${POS_name}_collset"
	if ($pos == 3) then
	    set num_collocates = 100
	    set collset_file = "g2collset"
	endif
	if (`printenv MAX_${collset_file}` =~ [0-9]*) then
	    set num_collocates = `printenv MAX_${collset_file}`
	endif

	# Get the top-most collocate words by the G^2 test score
	# TODO: apply a threshold to ensure a minimum G^2 score
	## head -${num_collocates} ${base}.t13_g2test2_sort.$pos | cut -f2 -d' ' > $collset_file
	# TODO: determine why the grep '^[-_a-z0-9]*$' restriction was added
	cut -f2 -d' ' ${base}.t13_g2test2_sort.$pos | grep '^[-_a-z0-9]*$' | head -${num_collocates} > $collset_file
	@ pos++
    end
    mv all_collset g2collset

    # For the WSD experiments, only the overall collset file is used
    # TODO: don't produce the other files if not being used
    if ($do_word_sense) then
	if ($OR1) then
	    # For over-range-enumerated the collocation set is one file
	    echo "g2collset" > g2collset.list
	else
	    # For over-range-binary there is a collocation set for each word
	    rm g2collset.list
	    set suffix = 0
	    foreach word (`cat g2collset`)
		echo $word > g2collset_$suffix.list
		echo "g2collset_$suffix.list" >> g2collset.list
		@ suffix++
	    end
	endif
    endif
endif

#------------------------------------------------------------------------------
# Get ad-hoc collocations.
#
# NOTE: These are those that currently don't fall under any organization
# scheme
#
# TODO: Use a more flexible scheme of checking collocation group usage,
# rather than greping through feature.ini.
#

# Group20 (WS verb-object relation) collocations
# NOTE: files start with the prefix "collset_VO"
#
# end_result: collset_VO.list, collset_VO_<s1>, collset_VO_<s2>, ...
#
set group20_colls = `grep '^G2[02]=1' feature.ini`
echo $group20_colls
if ("${group20_colls}" != "") then
    # Get collocation for verb-object pattern, and sort the result by class
    perl -sw ${script_dir}/get_POS_anywhere.perl -word_sense=1 -pattern='VB( RB)*( DT)?( JJ)* NN @ $' -collocate_tag="VB" $file $sidfile ANY > ${base}.t_g20_get_POS_anywhere
    sort +1 ${base}.t_g20_get_POS_anywhere -o ${base}.t_g20_get_POS_anywhere_sort

    # Select the indicative collocations for each class
    perl -sw ${script_dir}/${choose_all_script} $args -collset_base=collset_VO ${base}.t_g20_get_POS_anywhere_sort $choose_all_arg
endif

# Group60 (WS hypernym-based) collocations
set group60_colls = `grep '^G60=1' feature.ini`
if ("${group60_colls}" != "") then
    # Get collocation by hypernym, and sort the result by class
    # NOTE: Also produces hypernyms.data file for use in getfmc7.0.c
    perl -sw ${script_dir}/get_POS_anywhere.perl -word_sense -hypernyms $file $sidfile ANY > ${base}.t_g60_get_POS_anywhere
    sort +1 ${base}.t_g60_get_POS_anywhere -o ${base}.t_g60_get_POS_anywhere_sort
    # Produce complete hypernyms.data file for getfmc
    # TODO: use existing hypernym cache with all cases to avoid the need for this here
    mv hypernyms.data hypernyms.training.data
    perl -sw ${script_dir}/get_POS_anywhere.perl -all_sentences -word_sense -hypernyms $file $sidfile ANY > ${base}.t_all_g60_get_POS_anywhere
    

    # Select the indicative collocations for each class
    # NOTE: getfmc7.0.c uses the collset_base prefix for debugging purpose
    perl -sw ${script_dir}/${choose_all_script} $args -collset_base=hyper_collset ${base}.t_g60_get_POS_anywhere_sort $choose_all_arg
endif

# Group90 (WS relatedness-based) collocations
set group90_colls = `grep '^G90=1' feature.ini`
if ("${group90_colls}" != "") then
    # Get related-word collocations, and sort the result by class
    perl -sw ${script_dir}/get_POS_anywhere.perl -word_sense -relatedness $file $sidfile ANY > ${base}.t_g90_get_POS_anywhere
    sort +1 ${base}.t_g90_get_POS_anywhere -o ${base}.t_g90_get_POS_anywhere_sort
    # Select the indicative collocations for each class
    # NOTE: getfmc7.0.c uses the collset_base prefix for debugging purpose
    perl -sw ${script_dir}/${choose_all_script} $args -collset_base=related_collset -CI_MIN_FREQ=5 -CI_MIN_PERC_DIFF=0.3 ${base}.t_g90_get_POS_anywhere_sort $choose_all_arg
endif

# Group25 (WS adjacency-based) collocations; over-range/enum
set group25_colls = `grep '^G25=1' feature.ini`
if ("${group25_colls}" != "") then
    # Get collocation by adjacency, and sort the result by word frequency
    set offsets = `printenv ADJ_OFFSETS`
    if ("$offsets" == "") set offsets = "-2 -1 +1 +2"
    set max_adj_collocates = `printenv MAX_ADJ_COLLOCATES`
    if ("$max_adj_collocates" == "") set max_adj_collocates = 100

    echo -n "" > collset_adj.list
    foreach offset ($offsets)
	# Extract content words at the specified position
	# TODO: use a version of get_POS_anywhere.perl that doesn't group
        # by class
	perl -sw ${script_dir}/get_POS_anywhere.perl -word_sense -adjacency -offset=$offset -just_content_words=$just_content_words $file $sidfile ANY > ${base}.t_g25_adj_${offset}

	# Get the list of the N most frequent content words, excluding
	# those with frequency 1 (example entry: "0.95=54/57	504337	hand")
	# TODO: fix the removal of duplicates to retain up the max number of collocates
	sort +1 -rn -t/ ${base}.t_g25_adj_${offset} | grep -v "/1[^0-9]" | head -${max_adj_collocates} | cut -f3 | sort -u > collset_adj_${offset}

	# Revise list of collocation files
	echo "collset_adj_${offset}" >> collset_adj.list
    end

endif

# Group26 (WS adjacency-based) collocations; per-class/enum
# TODO: reconcile with the code for group 25 above
set group26_colls = `grep '^G26=1' feature.ini`
if ("${group26_colls}" != "") then
    # Get collocation by adjacency, and sort the result by word frequency
    set offsets = `printenv ADJ_OFFSETS`
    if ("$offsets" == "") set offsets = "-2 -1 +1 +2"
    set max_adj_collocates = `printenv MAX_ADJ_COLLOCATES`
    if ("$max_adj_collocates" == "") set max_adj_collocates = 26

    # Create separate class-specific collocation files for each offset position
    # result: collset_adj_pc_-2_sense1 ... collset_adj_pc_-2_senseN
    #         collset_adj_pc_-1_sense1 ... collset_adj_pc_-1_senseN
    #         collset_adj_pc_+1_sense1 ... collset_adj_pc_+1_senseN
    #         collset_adj_pc_+2_sense1 ... collset_adj_pc_+2_senseN
    echo -n "" > collset_adj_pc.list
    foreach offset ($offsets)
	# Extract content words at the specified position
	perl -sw ${script_dir}/get_POS_anywhere.perl -word_sense -adjacency -offset=$offset $file $sidfile ANY > ${base}.t_g26_adj_${offset}

	# Sort by class value and then create separate collocate set files
	sort +1 ${base}.t_g26_adj_${offset} -o ${base}.t_g26_adj_${offset}_sort
	perl -sw ${script_dir}/${choose_all_script} -collset_base=collset_adj_pc_$offset $args ${base}.t_g26_adj_${offset}_sort $choose_all_arg

	# Update the master collocation set list
	cat collset_adj_pc_$offset.list >> collset_adj_pc.list
    end
endif

# Group 80: G^2 hypernym collocations
set group80_colls = `grep '^G80=1' feature.ini`
if ("${group80_colls}" != "") then
    set pos = 5
    set collset_file = "g2_hyper_collset"
    set num_collocates = 100

    # Produce complete hypernyms.data file for use in getfmc7.0.c
    # NOTE: This is done just to get the hypernym data file
    ## mv hypernyms.data hypernyms.training.data
    perl -sw ${script_dir}/get_POS_anywhere.perl -all_sentences -word_sense -hypernyms $file $sidfile ANY > ${base}.t_all_g60_get_POS_anywhere.full
    
    # G2: Get collocations anywhere in the sentence
    prepare_bigram_all $file ${base}.t9_hyper_bigram.$pos $sidfile $pos

    # Perform G^2 test for independence
    sort ${base}.t9_hyper_bigram.$pos -o ${base}.t10_hyper_bigram_sort1.$pos
    sort +1 ${base}.t9_hyper_bigram.$pos -o ${base}.t11_hyper_bigram_sort2.$pos
    g2test2 ${base}.t10_hyper_bigram_sort1.$pos ${base}.t11_hyper_bigram_sort2.$pos ${base}.t12_hyper_g2test2.$pos
    sort -r -n ${base}.t12_hyper_g2test2.$pos -o ${base}.t13_hyper_g2test2_sort.$pos

    # Choose the collocations. For the V/N/A collocations, the top ten
    # collocations are used. For the combined set, the top 100. 
    #
    if (`printenv MAX_${collset_file}` =~ [0-9]*) then
        set num_collocates = `printenv MAX_${collset_file}`
    endif

    # Get the top-most collocate words by the G^2 test score
    # TODO: apply a threshold to ensure a minimum G^2 score
    # TODO: determine why the grep '^[-_a-z0-9]*$' restriction was added
    ## cut -f2 -d' ' ${base}.t13_hyper_g2test2_sort.$pos | grep '^[-_#a-z0-9]*$' | head -${num_collocates} > $collset_file
    cut -f2 -d' ' ${base}.t13_hyper_g2test2_sort.$pos | grep '^[-_#:A-Za-z0-9]*$' | head -${num_collocates} > $collset_file

    # For the WSD experiments, only the overall collset file is used
    # TODO: don't produce the other files if not being used
    if ($do_word_sense) then
	if ($OR1) then
	    # For over-range-enumerated the collocation set is one file
	    echo "g2_hyper_collset" > g2_hyper_collset.list
	else
	    # For over-range-binary there is a collocation set for each word
	    rm -f g2_hyper_collset.list
	    set suffix = 0
	    foreach word (`cat g2_hyper_collset`)
		echo $word > g2_hyper_collset_$suffix.list
		echo "g2_hyper_collset_$suffix.list" >> g2_hyper_collset.list
		@ suffix++
	    end
	endif
    endif
endif
