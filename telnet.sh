#! /bin/csh
# 
# telnet.sh: Simple wrapper around telnet command, which also does an xhost.
# This now uses ssh to enforce secure connections when available.
#

if ("$1" == "") then
    echo "usage: $0 host"
    echo ""
    exit
endif

xhost + $1
## telnet $1
ssh $1
## cd .
set_xterm_title.sh $PWD
