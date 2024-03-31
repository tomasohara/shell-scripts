#! /bin/csh -f
#
# ping.sh: simple wrapper around the ping command redirecting stderr to stdout
#

set options = ""
if ($OSTYPE == linux) then
    set options = "-c 1"
endif
ping $options $* >&! temp_$$.log
cat temp_$$.log
rm temp_$$.log
