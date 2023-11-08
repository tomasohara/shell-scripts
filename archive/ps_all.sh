#! /bin/csh -f
#
# ps_mine.sh: show processes belonging to particular user
#

set user = `whoami`
if ("$1" == "--all") set user = ""

if ($OSTYPE == solaris) then
	ps -ef | grep "^$user" 
else
	ps -auxgww | grep "^$user"
endif
