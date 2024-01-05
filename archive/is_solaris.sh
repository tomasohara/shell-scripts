#!/bin/csh -f
set rev=`uname -r`
if ($rev =~ 5*) then
	echo 1
else
	echo 0
endif

