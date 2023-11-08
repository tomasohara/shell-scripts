#! /bin/csh -f

# Extract a subset of a merged preprocessed file (eg, w9_1tb.t04_merge)
# based on words desired (eg, interest), optionally restricted to
# particular parts of speech.
#
# This is intended to support the merging of Rebecca's word-sense data
# into a preprocessed file. The sentence labelling program is very
# slow when the unlabelled file is sparse compared to the labelled file,
# due to frequent backtracking. Therefore, this script is used to
# extract the subset of the labelled file that is appropriate.
#
# TODO: Convert this into a Perl script since the egrep command below 
#       is getting a little too complicated.

if ("$3" == "") then
    set program = `basename $0`
    echo ""
    echo "usage: $program preprocessed_file word_stem penn_POS_base"
    echo ""
    echo "Extracts a subset of a preprocessed file based on a word desired,
    echo "restricted to a particular parts of speech."
    echo ""
    echo "ex: $program w91f14.preprocess interest NN"
    echo ""
    exit
endif
if (`printenv DEBUG_MODE` != "") set echo = 1  # echo each command and argument

set file = $1
set stem = $2
set POS = $3


# Put all the tags for one sentence on one line
#     <s snum=1 s_id=891101-0165_0_1><wf pos=DT>The</wf><wf pos=NN>luxury</wf><wf pos=NN>auto</wf>...
#
perl -pn -e "s/>\n/>/g; s/<\/s>/<\/s>\n/g; s/(<\/?TXT[^<>]+>)/\n\1\n/; s/(<\/?p[^<>]+>)/\n\1\n/;" < $file > temp_extract_merge1.list

# Get those sentences that contain the word
# This restricts the sentences to those containing the word in the POS.
#
# NOTE: This assumes the wordform tags have the POS attribute prior to the stem
#       <wf pos=NN stem=interest quote=0>interest</wf>
#
# TODO: all for multiple words (???)
#
egrep "((<\/?TXT[^<>]*>)|(<\/?p[^<>]*>)|(pos=${POS}[^>]+stem=$stem))" temp_extract_merge1.list > temp_extract_merge2.list

# Put all words on a single line with their tags
#     <s snum=1 s_id=891101-0165_0_1>
#     <wf pos=DT>The</wf>
#     <wf pos=NN>luxury</wf>
#     <wf pos=NN>auto</wf>
#     ...
perl -pn -e "s/></>\n</g;" < temp_extract_merge2.list
