#! /bin/bash
#
# run-program-variations.: script for invoking a program or script over a variety
# of parameter settings to find an optimal solution
# NOTE: previously called correlation-runner.sh as designed originally for scoring metrics
# TODO: rework using evolutionary programming or another efficient optimization framework
#
# Up to 5 parameters can be varied.
#
# TODO: add support for generating range of numeric parameters (e.g., given min/max/incr)
#

# Uncomment following line(s) for tracing:
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#  
## set -o xtrace
## set -o verbose

# TODO: Show usage statement
#
if [ "$1" = "" ]; then
    echo ""
    echo "usage: `basename $0` [options]"
    echo ""
    echo 'options: [--program name] [--options="list"] [--arguments="list"]'
    echo '   [--param1 label] "value-list"]'
    echo '   ...'
    echo '   [--param5 label] "value-list"]'
    echo ""
    echo "ex: `basename $0`" 'temporal-word-repetition.rb --param1 repetition-increment "10 20 30 40 50" --param2 repetition-decrement "1 5 10 15 20" --param3 repetition-threshold "25 50 75 100"  --param4 min-rank "-1 5 10 20 25" --param5 max-rank "-1 50 100 500 5000"'
    echo ""
    echo "Notes:"
    echo "- The --options are for options indicated by dash keywords (e.g., --max-count)."
    echo "- The --arguments are for options not indicated by dash keywords (e.g., training-essays)."
    echo ""
    exit
fi

# TODO: Parse command-line options
#
moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
#
program="unknown"
options=""
param1_name=""; param1_values="n/a";
param2_name=""; param2_values="n/a";
param3_name=""; param3_values="n/a";
param4_name=""; param4_values="n/a";
param5_name=""; param5_values="n/a";
arguments=""
#
while [ "$moreoptions" = "1" ]; do
    if [ "$1" = "--trace" ]; then
	set -o xtrace;
    elif [ "$1" = "--program" ]; then
	program="$2"
	shift 1;
    elif [ "$1" = "--options" ]; then
	options="$2"
	shift 1;
    elif [ "$1" = "--param1" ]; then
	param1_name="$2"
        param1_values="$3"
	shift 2;
    elif [ "$1" = "--param2" ]; then
	param2_name="$2"
        param2_values="$3"
	shift 2;
    elif [ "$1" = "--param3" ]; then
	param3_name="$2"
        param3_values="$3"
	shift 2;
    elif [ "$1" = "--param4" ]; then
	param4_name="$2"
        param4_values="$3"
	shift 2;
    elif [ "$1" = "--param5" ]; then
	param5_name="$2"
        param5_values="$3"
	shift 2;
    elif [ "$1" = "--arguments" ]; then
	arguments="$2"
	shift 1;
    else
	echo "ERROR: Unknown option: $1";
	exit;
    fi
    shift 1;
    moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
done

# Display settings
echo "Params: $param1_name,  $param2_name,  $param3_name,  $param4_name,  $param5_name"
echo ""

# Test each of the settings
count=1
for param1 in $param1_values; do
    for param2 in $param2_values; do
	for param3 in $param3_values; do
	    for param4 in $param4_values; do
		for param5 in $param5_values; do
		    program_label=`basename $program .rb`
		    # TODO: omit n/a values
		    ## output_file="variation-${program_label}.$param1.$param2.$param3.$param4.$param5.output"
		    echo "Variation $count: $param1, $param2, $param3, $param4, $param5"
		    let count++
		    command_line="$program $options"
		    if [ "$param1" != "n/a" ]; then command_line="$command_line --$param1_name $param1"; fi
		    if [ "$param2" != "n/a" ]; then command_line="$command_line --$param2_name $param2"; fi
		    if [ "$param3" != "n/a" ]; then command_line="$command_line --$param3_name $param3"; fi
		    if [ "$param4" != "n/a" ]; then command_line="$command_line --$param4_name $param4"; fi
		    if [ "$param5" != "n/a" ]; then command_line="$command_line --$param5_name $param5"; fi
		    # Put command arguments last as these might not include option indicators (e.g., dashless)
		    command_line="$command_line $arguments"
		    echo "command: $command_line"
		    $command_line
		    echo "--------------------------------------------------------------------------------"
                    ## TODO: $command_line > $output_file
		done
	    done
	done
    done
done
