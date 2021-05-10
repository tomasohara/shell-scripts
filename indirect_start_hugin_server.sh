#! /bin/csh -f
#
# indirect_start_hugin_server.sh: start the hugin server indirectly by invoking
# the start_hugin_server.sh script on the server machine (eg., dominica)
#
# note: the indirection is needed since some of the parallel node machines (eg, wb2)
# can only invoke commands on the host machine (eg, medusa)
#

# Uncomment (or comment) the following for enabling (or disabling) tracing
# set echo=1

# Parse arguments
set extra_options = ""
if ("$1" == "") then
    echo "usage: $0 [--pc-solaris] server"
    echo ""
    echo "example:"
    echo ""
    echo "$0 --pc-solaris hilbert"
    echo
    echo "$0 typhoon"
    echo
    exit
endif
while ("$1" =~ -*)
    if ("$1" =~ --pc*) then
	set extra_options = "$extra_options --pc-solaris"
    else
	echo "ERROR: unknown option: $1"
	exit
    endif
    shift
end
set server = $1

set dir = `dirname $0`

if ($?HOST == 0) setenv HOST "???"
if ("$HOST" =~ wb*) then
    echo "WARNING: rsh to medusa not supported under $HOST"
    ## rsh -n medusa $dir/indirect_start_hugin_server.sh $extra_options $server
else
    echo "[$HOST] Invoking $dir/start_hugin_server.sh on $server"
    rsh -n $server $dir/start_hugin_server.sh $extra_options
endif
