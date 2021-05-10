#!/bin/csh -f
#

set echo = 1
## top $*
echo "top >! temp_$$.log" > temp_$$.sh
csh < temp_$$.sh
cat temp_$$.log
