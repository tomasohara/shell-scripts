#! /bin/csh -f
#
# name.sh: explanation
# TODO: fill out the TODO's below
#
## TODO:
## - Update template based on more recent scripts (e.g., start.sh).
## - Add brief meta-commment comment (e.g., "## comments are meta comments for version control, etc.").
#

# Uncomment (or comment) the following for enabling (or disabling) tracing
## echo "$*"
## set echo=1

# Parse command-line arguments
## TODO: Revise with respect to more current scripts (e.g., start.sh).
if ("$1" == "") then
    set script_name = `basename $0`
    ## set log_name = `echo "$script_name" | perl -pe "s/.sh/.log/;"`
    echo ""
    echo "usage: `basename $0` [options]"
    echo ""
    # TODO: example (e.g., replace whatever)"
    echo "ex: `basename $0` whatever"
    echo ""
    exit
endif
while ("$1" =~ -*)
    if ("$1" == "-") then
	echo "Using default options"
    else if ("$1" == "--trace") then
	set echo = 1
    else if ("$1" == "--fubar") then
	echo "fubar"
    else
	echo "ERROR: unknown option: $1"
	exit
    endif
    shift
end

# TODO: Do whatever
echo whatever

#E TODO: Cleanup things
## if ($?DEBUG_LEVEL == 0) set DEBUG_LEVEL=0
## if ($DEBUG_LEVEL < 5) rm $aux_base*
