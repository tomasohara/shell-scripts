#!/bin/csh -f
## set echo = 1

setenv WN_ADDSENSE 1
#set DISPLAY=${DISPLAY:-`hostname`:0}
#export DISPLAY

set dir=`dirname $0`
if ( -e $dir/XWordnet ) then
	xrdb -merge $dir/XWordnet.rdb
endif
$dir/xwordnet $*&
