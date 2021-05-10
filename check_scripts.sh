#! /bin/csh -f

set verbosity = 0
if ("$1" == "--verbose") then
    set verbosity = 1
    shift
endif

# Make sure each of the scripts have the -f option
set bad_scripts = `grep '/bin/csh *$' *.sh`
if ("${bad_scripts}" != "") then
    echo "*** The following scripts don't have the fast load option:"
    echo $bad_scripts | sed -e "s/:[^ ]*/ /g"
endif

if ($verbosity == 1) then
    echo ""
    set good_scripts = `grep '/bin/csh *-f' *.sh`
    if ("${good_scripts}" != "") then
	echo "The following scripts are ok:"
	echo $good_scripts | sed -e "s/:[^:]*-f/ /g"
    endif
    echo ""
endif
