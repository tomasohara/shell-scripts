#! /bin/csh -f
#
# preprocess-lexical-data.sh: Extracts lexical data from the Cyc English
# lexicon and processes it into a format for use in the speech part 
# classification experiments.
#
#........................................................................
# Manual steps that this script handles:
#
# $ export tcp_port=3622
# $ function dump_big_mt () { nice -19 lynx -dump -nolist -width=512 "http://localhost:${tcp_port}/cgi-bin/cyccgi/cg?cb-c-total&"$1 >| .$1.data; lynx -dump -nolist -width=512 "http://localhost:${tcp_port}/cgi-bin/cyccgi/cg?cb-c-ist&"$1 >> .$1.data; less .$1.data 
# }
# $ dump_big_mt GeneralEnglishMt
# $ dump_big_mt EnglishMt
# $ dump_big_mt GeneralLexiconMt
# $ dump_big_mt WordNetMappingMt
#
# $ zcat .EnglishMt.data.gz .GeneralEnglishMt.data.gz .GeneralLexiconMt.data.gz |  perl -Ssw extract_cyc_speech_part_features.perl -separate -d=4 -port=$port - >& extract_cyc_speech_part_full.log
#
# $ zcat extract_cyc_speech_part_full.log.gz | perl -Ssw get_cyc_speech_part_collocations.perl - >| extract_cyc_speech_part_full.cooccur
# $ perl -Ssw calc_cooccurrence.perl -precision=6 extract_cyc_speech_part_full.cooccur >| extract_cyc_speech_part_full.metrics
#
# $ gzip extract_cyc_speech_part_full.log  extract_cyc_speech_part_full.metrics
#
#........................................................................
# TODO:
# - remove temporary files
# - make the output files read-only
#

# Uncomment (or comment) the following for enabling (or disabling) tracing
## set echo=1

# Parse command-line arguments
if ("" == "`printenv port`") setenv port 0
set quick = 0
set trace = 0
set opencyc = 0
set metrics = 0
if ("$1" == "") then
    echo ""
    echo "usage: `basename $0` [--opencyc] [--port N] [--trace] [--metrics]"
    echo ""
    echo "examples: "
    echo "$0 --opencyc --port 20 > preprocess-opencyc-lexical-data.log"
    echo ""
    echo "$0 --port 40 > preprocess-cyc-lexical-data.log"
    echo ""
    echo "Notes:"
    echo ""
    echo "Script options:"
    echo "    -port N		port offset for Cyc server (e.g., 40)"
    echo "    -quick		redo preprocessing without dumping lexical MT's"
    echo ""
    echo "The result will be saved in the following files:"
    echo "    extract_cyc_speech_part_full.log.gz"
    echo "    extract_cyc_speech_part_full.metrics.gz"
    echo "These are used by run-mass-count-experiments.sh to produce the actual"
    echo "classification used in the IWCS-5 paper."
    echo ""
    exit
endif
while ("$1" =~ -*)
    if ("$1" == "--port") then
	setenv port $2
	shift
    else if ("$1" == "--opencyc") then
	set opencyc = 1
    else if ("$1" == "--quick") then
	set quick = 1
    else if ("$1" == "--trace") then
	set trace = 1
    else if ("$1" == "--metrics") then
	set metrics = 1
    else
	echo "unknown option: $1"
    endif
    shift
end

# Make sure the script directory is in the path
set dir = `dirname $0`
setenv PATH "${dir}:$PATH"
if ($?PERLLIB == 0) setenv PERLLIB ""
setenv PERLLIB "${dir}:$PERLLIB"
if ($trace) echo "dir=$dir; PERLLIB=$PERLLIB; PATH=$PATH"

# Display information about the version of Cyc ports being used
@ tcp_port = $port + 3602
echo "Using Cyc at port offset $port; TCP port is $tcp_port"

# Determine the base URL for access to Cyc
set html_base = "http://localhost:${tcp_port}/cgi-bin/cyccgi"
if ($opencyc == 0) set html_base = "http://localhost/cgi-bin/localhost$port/cyccgi"
if ($trace) echo "html_base=${html_base}"

# Download the MT's
echo "Checking lexical MT data"
foreach mt (GeneralLexiconMt GeneralEnglishMt EnglishMt WordNetMappingMt) 
    if ((! $quick) || (-z .${mt}.data.gz)) then
        echo "Extracting $mt"
	if ($trace) set verbose = 1
        lynx -dump -nolist -width=512 "${html_base}/cg?cb-c-total&"${mt} > .${mt}.data
        lynx -dump -nolist -width=512 "${html_base}/cg?cb-c-ist&"${mt} >>.${mt}.data
        gzip -f .${mt}.data
	if ($trace) set verbose = 0
    endif
end

# Download other Cyc data (e.g., quotedCollection's and WordNet mapping)
if ($trace) set verbose = 1
perl -Ssw query_cyc.perl '(quotedCollection ?C)' > quotedCollection.list

# Extract the denotational assertions (denotation and multi-word assertions)
zcat .EnglishMt.data.gz .GeneralEnglishMt.data.gz .GeneralLexiconMt.data.gz |  perl -Ssw extract_cyc_speech_part_features.perl -separate -d=4 -port=$port - >& extract_cyc_speech_part_full.log

# Extract the list of all parent terms and derive mapping into WordNet
# TODO: use different name than cyc_ancestor_list_wordnet_mapping.data
cat extract_cyc_speech_part_full.log | egrep "types=|generalizations=" | perl -pe "s/\t/\n/g;" | egrep -v '(=)|(^$)' | sort -u >| all-reference-terms.list
perl -Ssw produce_cyc_wordnet_mapping.perl all-reference-terms.list > cyc_ancestor_list_wordnet_mapping.data 

# Perform collocation analysis over the associations of speech parts to ancestor terms
# using the denotation assertion listing in extract_cyc_speech_part_full.log
# 
if ((! $quick) && $metrics) then
    zcat extract_cyc_speech_part_full.log.gz | perl -Ssw get_cyc_speech_part_collocations.perl -separate - > extract_cyc_speech_part_full.cooccur
    perl -Ssw calc_cooccurrence.perl -precision=6 extract_cyc_speech_part_full.cooccur > extract_cyc_speech_part_full.metrics
endif

# Compress the files to save space
# -f force zip even if existing; -q be quiet about warnings
gzip -fq extract_cyc_speech_part_full.*
