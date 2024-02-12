#! /bin/csh -f
#! /usr/local/bin/tcsh -f
#
# do_rcsdiff.sh: compare current files versus those in RCS directory
#
# NOTE: rcsdiff lists the rcs file before the current version, as in 
#           diff RCS_file file
# TODO:
# - Handle cases where there isn't an RCS subdirectory (e.g., all files
#   are put in the current directory).
# - Reconcile with do_diff.sh (at least keep in synch put perhaps combine).
# - Add sample input and output comments.
# - Have option to specify different version of rcsdiff.
#

# Uncomment the following for script tracing/debugging
## set echo=1
## echo "${0}: $*"

set quiet_option = "-q"
set rcs_file_pattern = ""
set use_current_dir = 0
set brief = "0"
set rcsdiff = "cmd.sh rcsdiff"

# Show usage statement if insufficient arguments given
if ("$1" == "") then
    set script = `basename $0`
    echo ""
    echo "usage: `basename $0` [-v] [-c] [--brief] [-p file_pattern] [-f] file ..."
    echo ""
    echo "examples:"
    echo ""
    echo "$script Makefile"
    echo ""
    echo "$script \* >| _rcs.diff 2>&1"
    echo ""
    echo "$script *.[ch] >| _rcs.diff 2>&1"
    echo ""
    echo "NOTES:"
    echo "- Patterns are relative to the RCS subdirectory"
    echo "- The rcsdiff command lists the rcs file before the current one, as in:"
    echo "      diff RCS-file file"
    echo ""
    exit
endif

# Show usage statement if insufficient arguments given
while ("$1" =~ -*)
    if ("$1" == "-v") then
	set quiet_option = ""
    else if ("$1" == "-f") then
	shift
	set rcs_file_pattern = "$*"
	break
    else if ("$1" == "-p") then
	set rcs_file_pattern = "RCS/*$2*"
	shift
    else if ("$1" == "-c") then
	set use_current_dir = 1
    else if ("$1" == "--brief") then
	set brief = "1"
    else
	echo "ERROR: unknown option: $1"
	exit
    endif
    shift
end

# Show the command 


# Process special option for checking each file in the current directory
# and then exit.
#
if ($use_current_dir) then
    foreach current_file (*)
	set rcs_file = "RCS/${current_file},v"
	if (-e $rcs_file) then
	    echo $rcs_file vs. $current_file
	    $rcsdiff $quiet_option $current_file
	endif
    end
    exit
endif


# Convert filename arguments into patterns over RCS files
#
while ("$1" != "")
    if (-e "$1") then
	set rcs_file_pattern = "$rcs_file_pattern RCS/$1,v"
    else if ("$1" =~ .*) then
	set rcs_file_pattern = "$rcs_file_pattern RCS/*$1,v"
    else
	set rcs_file_pattern = "$rcs_file_pattern RCS/*$1*,v"
    endif
    shift
end
if ("$rcs_file_pattern" == "") set rcs_file_pattern = "RCS/*,v"

# Compare each file specified
#
foreach rcs_file ($rcs_file_pattern)
    set current_file = `basename $rcs_file ,v`

    if ($brief == "0") then
	echo $rcs_file vs. $current_file

	# Show the timestamps if the files differ
	$rcsdiff --brief $current_file
	if ($? == 1) then
	    ls -l $rcs_file
	    ls -l $current_file
	endif
    endif
	
    $rcsdiff $quiet_option $current_file
end
