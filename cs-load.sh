#! /bin/csh -f
#
# cs-load.sh: script to show load on various machines in CS system
#
# Notes:
#
# $ foreach.perl 'echo $f: `rup.sh $f`' `cat /home/grad4/tomohara/cs/cs-undegrad-p3-linux-hosts.list`
# balamb: 4:24pm up 60 days, 12:37, 0 users, load average: 0.00, 0.00, 0.00
# blake: 4:24pm up 47 days, 23:05, 2 users, load average: 0.08, 0.02, 0.01
# cobra: 4:24pm up 42 days, 7:22, 0 users, load average: 0.00, 0.00, 0.00
# dali: 4:24pm up 60 days, 12:35, 0 users, load average: 0.00, 0.00, 0.00
# ...
# vitaly: 4:24pm up 60 days, 12:34, 0 users, load average: 0.00, 0.00, 0.00
# 

# Uncomment (or comment) the following for enabling (or disabling) tracing
## set echo=1

## set hostlist = `cat ~tomohara/public/cs-hosts.list`
set hostlist = ()

# Parse command-line arguments
if ("$1" == "") then
    echo ""
    echo "usage: `basename $0` [--all] [--wb]] [--p4] [--bw] [--half-bw] [host1 ...]"
    echo ""
    echo "ex: `basename $0` --undergrad-p3"
    echo ""
    exit
endif
while ("$1" =~ -*)
    if ("$1" == "--all") then
	set hostlist = (`cat ~tomohara/public/cs-hosts.list`)
    else if ("$1" == "--crl") then
	set hostlist = (`cat ~tomohara/public/crl-hosts.list`)
    else if ("$1" == "--p4") then
	set hostlist = (`cat ~tomohara/public/cs-p4-linux-hosts.list`)
    else if ("$1" == "--wb") then
	set hostlist = (`cat ~tomohara/public/cs-wb-hosts.list`)
    else if ("$1" == "--bw") then
	set hostlist = (`cat ~tomohara/public/cs-bw-hosts.list`)
    else if ("$1" == "--bw1") then
	set hostlist = (`cat ~tomohara/public/cs-bw-hosts-half1.list`)
    else if ("$1" == "--bw2") then
	set hostlist = (`cat ~tomohara/public/cs-bw-hosts-half2.list`)
    else if ("$1" =~ --half*) then
	set hostlist = (`cat ~tomohara/public/cs-half-bw-hosts.list`)
    else
	echo "ERROR: unknown option: $1"
    endif
    shift
end

# If no hosts specified use the command line arguments.
# As a default, use the entire list of hosts
if ($#hostlist == 0) then
    set hostlist = ($*)
endif
if ($#hostlist == 0) then
    set hostlist = (`cat ~tomohara/public/cs-hosts.list`)
endif

# Loop through the host lst showing the load
foreach host ($hostlist)
    # NOTE: This addresses HZ warning for bw_i nodes
    # 
    # $ $ rsh -n bw1 uptime
    # Unknown HZ value! (15) Assume 100.
    # 11:33:52 up 294 days, 19:33,  0 users,  load average: 1.00, 0.83, 0.41
    echo "${host}: `rup.sh $host`" | perl -pe "s/Unknown HZ value[^\.]+\.//;"
end
