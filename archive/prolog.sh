#! /bin/csh -f
#
# prolog.sh: wrapper for local prolog interpreter (currently sicstus)
#

# Uncomment (or comment) the following for enabling (or disabling) tracing
## set echo=1

# Parse command-line arguments
if (("$1" == "--help") || ("$1" == "-h")) then
    set script_name = `basename $0`
    echo ""
    echo "usage: `basename $0` [options]"
    echo ""
    echo "ex: `basename $0` whatever"
    echo ""
    exit
endif
while ("$1" =~ -*)
    if ("$1" == "--fu") then
	echo "hey"
    else if ("$1" == "--bar") then
	echo "hey"
    else
	echo "unknown option: $1"
    endif
    shift
end

# Setup the prolog environment
source /local/config/cshrc.sicstus

# Invoke the interpreter
sicstus
