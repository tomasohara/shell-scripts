#! /bin/csh -f
#
# run-all-experiments.sh: run all of the speech part classification
# experiments remotely on separate hosts
#
# TODO:
# - add preprocessing step
#

# Uncomment (or comment) the following for enabling (or disabling) tracing
## set echo=1

# Initialize the defaults
set hosts = (bw1 bw2 bw3 bw4 bw5 bw6 bw7 bw8)
set terms = 256
set trace = 0
set test = 0
set debug = 0
set all_exps = 0
set port = 40
set opencyc = 0
set preprocess = 1

# Parse command-line arguments
if ("$1" == "") then
    set script_name = `basename $0`
    echo ""
    echo "usage: `basename $0` [--collocates N] [--local] [--hosts h1 ... h8]"
    echo "   other options = [--preprocess] [--port NN] [--opencyc] [--all] [--debug] [--trace]"
    echo ""
    echo "examples: "
    echo ""
    echo "`basename $0` -"
    echo ""
    echo "$0 --preprocess --opencyc --trace --debug -"
    echo ""
    echo "$0 --all --trace --debug --bw9 -"
    echo ""
    exit
endif
while ("$1" =~ -*)
    if ("$1" == "--hosts") then
        shift
	while ("$1" =~ -*)
	    set hosts = ($hosts $1)
	    shift
	end
    else if ("$1" == "--terms") then
	set terms = "$2"
	shift
    else if ("$1" == "--port") then
	set port = "$2"
	shift
    else if ("$1" == "--opencyc") then
	set opencyc = 1
    else if ("$1" == "--preprocess") then
	set preprocess = 1
    else if ("$1" == "--debug") then
	set debug = 1
    else if ("$1" == "--all") then
	set all_exps = 1
    else if ("$1" == "--bw1") then
	set hosts = (bw1 bw2 bw3 bw4 bw5 bw6 bw7 bw8)
    else if ("$1" == "--bw9") then
	set hosts = (bw9 bw10 bw11 bw12 bw13 bw14 bw15 bw16)
    else if ("$1" == "--trace") then
	set trace = 1
    else if ("$1" == "--test") then
	set test = 1
    else if ("$1" == "-") then
	echo no-op > /dev/null
    else if ("$1" == "--local") then
	set hosts = ("" "" "" "" "" "" "" "")
	shift
    else
	echo "ERROR: unknown option: $1"
	exit
    endif
    shift
end

# Determine the full path of the script directory
set script_dir = `dirname $0`
if ($script_dir !~ /*) set script_dir = "$PWD/$script_dir"

# Determine the rsh commands to use (or none if running local)
set rshcmds = ("" "" "" "" "" "" "" "")
set redir = ("" "" "" "" "" "" "" "")
set i = 1
while ($i <= $#hosts)
    if ("$hosts[$i]" != "") then
	set rshcmds[$i] = "rsh -n $hosts[$i]"
	set redir[$i] = ">&! $PWD/exp$i.log &"
    else
	set rshcmds[$i] = ""
	set redir[$i] = ""
    endif
    if ($test) set rshcmds[$i] = "echo $rshcmds[$i]"
    @ i++
end

# Display option information
if ($trace == 1) then
    echo "#terms = $terms"
    echo "#hosts = $#hosts"
    echo "hosts = $hosts"
    echo "#rshcmds = $#rshcmds"
    echo "rshcmds = $rshcmds"
    echo "#redir = $#redir"
    echo "redir = $redir"
    echo "script_dir = $script_dir"
endif

# Optionally preprocess the data
if ($preprocess) then
    echo "Preprocessing the lexical data ..."
    set options = "--port $port"
    if ($opencyc) set options = "$options --opencyc"
    if ($trace) set options = "$options --trace"
    ${script_dir}/preprocess-lexical-data.sh $options preprocess-lexical-data.log
endif

# Run each of the experiments on a separate host (8 total)
#     3 mass/count experiments: headword baseline; suffix baseline; regular 256 terms
#     3 all-speech-parts experiments: headword baseline; suffix baseline; regular 256 terms
#     2 WordNet experiments: regular 256 terms for both mass/count and all speech parts
#
echo "Invoking classification experiments ..."
set options = "--dir $PWD"
if ($debug) set options = "$options --debug"
if ($trace) set options = "$options --trace"
if ($all_exps) set options = "$options --all"
#
# Mass noun experiments
$rshcmds[1] ${script_dir}/run-lexicalization-POS-experiments.sh $options --mass --headword 0 freq   $redir[1]
$rshcmds[2] ${script_dir}/run-lexicalization-POS-experiments.sh $options --mass --suffixes 0 freq   $redir[2]
$rshcmds[3] ${script_dir}/run-lexicalization-POS-experiments.sh $options --mass $terms freq   $redir[3]
#
# General speech part experiments
$rshcmds[4] ${script_dir}/run-lexicalization-POS-experiments.sh $options --headword 0 freq   $redir[4]
$rshcmds[5] ${script_dir}/run-lexicalization-POS-experiments.sh $options --suffixes 0 freq   $redir[5]
$rshcmds[6] ${script_dir}/run-lexicalization-POS-experiments.sh $options $terms freq   $redir[6]
#
# WordNet experiments
$rshcmds[7] ${script_dir}/run-lexicalization-POS-experiments.sh $options --wordnet --mass $terms freq   $redir[7]
$rshcmds[8] ${script_dir}/run-lexicalization-POS-experiments.sh $options --wordnet $terms freq   $redir[8]
