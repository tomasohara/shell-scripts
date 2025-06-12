# !/bin/csh -f
#
# ls: post-filter for the ls command, which cuts out the owner name
# and number of hard links
#
# 123456789-123456789-123456789-123456789-123456789-
# total 5568
# -rw-rw-r--  1 tomohara        4 Sep 23  1996 +.CKP
# -rw-rw-r--  1 tomohara        0 May 20  1997 -dir=bin
# -rw-rw-r--  1 tomohara     2142 Apr 23  1997 Common.pm
# -rw-rw-r--  1 tomohara     5464 Jan 24  1997 Makefile
#

if ($?LS == 0) setenv LS /usr/bin/ls
if ("$*" == "-altG") then
    $LS $* | cut -c1-11,24-133
else
    $LS
endif
