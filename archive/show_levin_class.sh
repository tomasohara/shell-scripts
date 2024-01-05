#!/bin/csh -f
# show the levin classes for each of the verbs on the command line
# TODO:
# - display the actual class name rather than the prototype verb
# - make the base directory (~tomohara/bin/) a variable
#
# NOTES:
#
# Manual extraction for verb "roll":
# 
# $ grep -w roll levin_verb_classes.index
# roll	; 1.1.2.1  1.2.2  1.3  1.4.1  2.1  2.2  2.3.1  2.3.4  2.4.1  2.4.3 	; 2.5.1  2.5.2  2.5.3  2.5.4  2.5.6  6.1  6.2  7.7  7.8  8.3  9.6  11.2 	; 22.3  23.2  26.1  26.3  40.3.2  43.2  51.3.1  51.3.2 
#
# $ foreach.perl -d=2 'grep \"^$f\t\" ~tom/NL/VERB_SEM/levin_verb_classes.contents' 1.1.2.1  1.2.2  1.3  1.4.1  2.1  2.2  2.3.1  2.3.4  2.4.1  2.4.3 2.5.1  2.5.2  2.5.3  2.5.4  2.5.6  6.1  6.2  7.7  7.8  8.3  9.6  11.2 22.3  23.2  26.1  26.3  40.3.2  43.2  51.3.1  51.3.2
# 1.1.2.1	Causative/Inchoative Alternation
# 1.2.2	Understood Body-part Object Alternation
# 1.3	Conative Alternation
# 1.4.1	Location Preposition Drop Alternation
# 2.1	Dative Alternation
# 2.2	Benefactive Alternation
# 2.3.1	Spray/Load Alternation
# 2.3.4	Swarm Alternation
# 2.4.1	Material Products Alternation (transitive)
# 2.4.3	Total Transformation Alternation (transitive)
# 2.5.1	Simple Reciprocal Alternation (transitive)
# 2.5.2	Together Reciprocal Alternation (transitive)
# 2.5.3	Apart Reciprocal Alternation (transitive)
# 2.5.4	Simple Reciprocal Alternation (intransitive)
# 2.5.6	Apart Reciprocal Alternation (intransitive)
# 6.1	There-Insertion
# 6.2	Locative Inversion
# 7.7	Bound Nonreflexive Anaphor as Prepositional Object
# 7.8	Directional Phrases with Nondirected Motion Verbs
# 8.3	Inalienably Possesses Body-Part Object
# 9.6	Coil Verbs
# 11.2	Slide Verbs
# 22.3	Shake Verbs
# 23.2	Split Verbs
# 26.1	Build Verbs
# 26.3	Verbs of Preparing
# 40.3.2	Crane Verbs
# 43.2	Verbs of Sound Emission
# 51.3.1	Roll Verbs
# 51.3.2	Run Verbs
#
# The index doesn't distinguish negative from positive examples for the alternations.
#

set full = 0
set levin_dir=`printenv LEVIN_DATA`
## if ("$levin_dir" == "") set levin_dir=/home/graphling/DATA/LEVIN
if ("$levin_dir" == "") set levin_dir=`dirname $0`

set class_file = "${levin_dir}/levin_verb_classes-index-proper.list"
if ("$1" == "") then
    echo ""
    echo "usage: $0 [--full] {verb}|{class} ..."
    echo ""
    echo "examples: "
    echo ""
    echo "$0 roll"
    echo ""    
    echo "$0 43.2"
    echo ""
    echo "$0 -full rescue"
    echo ""
    echo "$0 -full 2.2" 
    echo ""
    echo "Notes:"
    echo ""
    echo "By default, only the semantic classes are shown."
    echo ""
    echo "Use -full to show alternations as well. See example above."
    echo ""
    exit
endif
if (("$1" == "--full") || (("$1" == "-full"))) then
    set full = 1
    set class_file = "${levin_dir}/levin_verb_classes-index.list"
    shift
endif

# set echo = 1
echo -n "" > /tmp/levin.$$
echo ""
foreach verb ($*)
    if ($verb =~ [0-9]*) then
	echo "Verbs in Levin class $verb":
	set verbs = `grep " $verb " $class_file | cut -f1`
	echo $verbs
    else
	set classes = `grep -i -w $verb  $class_file | grep -v '^;' | perl -p -e "s/^\S+\t\s*;?//"`
	echo "Levin classes for $verb": "$classes"
	foreach class ($classes)
	    echo -n "" > /tmp/levin.$$
	    while ($class != "") 
		grep "^$class	" ${levin_dir}/levin_verb_classes-contents.list >> /tmp/levin.$$
		set class = `echo $class | perl -pe 's/\.?\d+$//;'`
		if ($full == 0) set class = ""
	    end

	    # Print the results in reverse order
	    tac /tmp/levin.$$
	    if ($full) echo ""
	end
    endif
    echo ""
end

# cleanup
rm /tmp/levin.$$
