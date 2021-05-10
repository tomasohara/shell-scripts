#! /bin/csh -f
#
# get_wsd_collocations.sh: Produce the lists of collocations that are used
# to implement WSD features for statistical classification. See getfmc6.1.c
# for where these are used.
#
# NOTE: This is sourced within run_experiment.sh to avoid having to
# pass paramaters. This is like get_collocations.sh, except that it is
# streamlined for the WSD experiments.
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

if ($DEBUG_LEVEL > 3) set echo = 1

set choose_all_script = "choose_all_coll.prl"
set choose_all_script2 = "choose_all_coll2.prl"
set choose_all_arg = ""
if ($use_new_CI == 1) then
    set choose_all_script = "new_choose_all_coll.prl"
    set choose_all_script2 = "new_choose_all_coll2.prl"
    set choose_all_arg = "${base}.t0_est_probabilities"
endif
set args="-word_sense=${do_word_sense}"

set PC1 = ($organization == "PC1")
set PC2 = ($organization == "PC2")
set OR1 = ($organization == "OR1")
set OR2 = ($organization == "OR2")
set per_class = ($PC1 || $PC2)
set over_range = ($OR1 || $OR2)

# First, estimate the prior probabilities for the classes
#
perl -sw ${script_dir}/est_probabilities.prl $args $file $sidfile > ${base}.t0_est_probabilities
cat ${base}.t0_est_probabilities


# Per-class organization w/ collocation selection by Conditional Independence
# 
# In each case the following steps are performed:
#    - Extract the collocations from the preprocessed file
#    - Sort the extracted output list by classification value
#    - Create individual files by class category (eg, n_ps, n_se.o, etc.)
#      with the collocations above a certain association threashold.
#
# The end result for each type of collocation is a set of files where
# all the collocations for a given category are contained in one file.
# For instance, for "Collocations anywhere in the sentence" there will
# be six files (collset_other, collset_ps, ... collset_psevent), where
# each file gives the list of words associated with the corresponding
# category. An example for the private-state-or-event category follows:
#
#     collset_psevent:
#     erupt
#     flashpoint
#     proponent
#     skirmish
#     unprecedented
#

if ($per_class && $colls_anywhere) then
    # Get collocations anywhere in the sentence
    # end result: collset_c for each class value c
    # collset.list will contain the list of collocation files
    # TODO: add support for part-of-speech specific collocations

    ci_coll_all $file ${base}.t1_ci_coll_all 2 $sidfile
    sort +1 ${base}.t1_ci_coll_all -o ${base}.t2_ci_coll_all_sort
    perl -sw ${script_dir}/${choose_all_script} $args ${base}.t2_ci_coll_all_sort $choose_all_arg
endif


if ($per_class && $colls_within) then
    # Get collocations within 5 words around the target word
    # end result: collset_c for each class value c
    # collset.list will contain the list of collocation files
    # TODO: add support for part-of-speech specific collocations

    ci_coll_all5 $file ${base}.t1_ci_coll_all5 2 $sidfile
    sort +1 ${base}.t1_ci_coll_all5 -o ${base}.t2_ci_coll_all5_sort
    perl ${script_dir}/${choose_all_script} ${base}.t2_ci_coll_all5_sort $choose_all_arg
endif


if ($per_class && $colls_pattern) then
    # Get collocations within syntactic patterns.

    echo "ERROR: *** No syntactic patterns currently defined for WSD"
endif



# Over-range organization w/ collocation selection by G^2 test
#
# end result: v_collset, n_collset, a_collset, g2collset
#
# NOTE: By default, up to 10 collocations are produces for {van}_collset
# and up to 100 for g2collset. These can be overridden by setting the
# environment variable MAX_<collset_name> (eg, MAX_g2collset).
#
if ($over_range) then
    set pos_all = "3"		# code for prepare_bigram_xxx programs
    # TODO: add support for part-of-speech specific collocations

    # Determine the collocation words
    if ($colls_anywhere == 1) then
        # Get collocations anywhere in the sentence
        prepare_bigram_any $file ${base}.t9_bigram $sidfile $pos_all
    else if ($colls_within == 1) then
        # Get collocations within 5 words around the main verb
        prepare_bigram_all5 $file ${base}.t9_bigram $sidfile $pos_all
    else if ($colls_pattern == 1) then
        # Get collocations within syntactic patterns
        prepare_bigram_pat $file ${base}.t9_bigram $sidfile $pos_all
    else
        # Get collocations anywhere in the sentence
        prepare_bigram_all $file ${base}.t9_bigram $sidfile $pos_all
    endif

    # Perform G^2 test for independence
    sort ${base}.t9_bigram -o ${base}.t10_bigram_sort1
    sort +1 ${base}.t9_bigram -o ${base}.t11_bigram_sort2
    g2test2 ${base}.t10_bigram_sort1 ${base}.t11_bigram_sort2 ${base}.t12_g2test2
    sort -r -n ${base}.t12_g2test2 -o ${base}.t13_g2test2_sort

    # Choose the collocations. For the V/N/A collocations, the top ten
    # collocations are used. For the combined set, the top 100. 
    #
    set num_collocates = 10
    set collset_file = "g2collset"
    if (`printenv MAX_${collset_file}` =~ [0-9]*) then
        set num_collocates = `printenv MAX_${collset_file}`
    endif

    # Get the top-most collocate words by the G^2 test score
    # TODO: apply a threshold to ensure a minimum G^2 score
    cut -f2 -d' ' ${base}.t13_g2test2_sort | grep '^[-_a-z0-9]*$' | head -${num_collocates} > $collset_file

    # Produce the lists of the collocation files (used in getfmc6.1.c)
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


#------------------------------------------------------------------------------
# Get ad-hoc collocations.
#
# NOTE: These are those that currently don't fall under any organization
# scheme
#
# TODO: Use a more flexible scheme of checking collocation group usage,
# rather than grep'ing through feature.ini.
#

# Group20 (WS verb-object relation) collocations
# NOTE: files start with the prefix "collset_VO"
#
# end_result: collset_VO.list, collset_VO_<s1>, collset_VO_<s2>, ...
#
set group20_collocations = `grep '^G2[02]=1' feature.ini`
if ("$group20_collocations" != "") then
    # Get collocation for verb-object pattern, and sort the result by class
    perl -sw ${script_dir}/get_POS_anywhere.perl -word_sense=1 -pattern='VB( RB)*( DT)?( JJ)* NN @ $' -collocate_tag="VB" $file $sidfile ANY > ${base}.t_g20_get_POS_anywhere
    sort +1 ${base}.t_g20_get_POS_anywhere -o ${base}.t_g20_get_POS_anywhere_sort

    # Select the indicative collocations for each class
    perl -sw ${script_dir}/${choose_all_script} $args -collset_base=collset_VO ${base}.t_g20_get_POS_anywhere_sort $choose_all_arg
endif
