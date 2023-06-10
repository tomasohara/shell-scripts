#!/bin/csh -f

## examples:
##    my_rexec.sh w
##    grep -B1 load _w_.list | perl -pn -e 's/([a-z])\n/\1/; s/: /:\t/;' | less
##
##    my_rexec.sh ~/bin/crude_benchmark
##    perl -pn -e 's/^([a-z]+)\n/\1\t/; s/: /\t/; s/crude_benchmark//;' _crude_benchmark_.list | sort -rn +1 > crude_benchmark.list
#
# my_rexec.sh top
# egrep -i '((^[a-z]+$)|(memory))' _top_.list | perl -p -e 's/(^[a-z]+)\n/$1\t/; s/Memory: //;' >! ~/info/crl_memory.list
#

## set hosts=(aeolia aigyptos aiaia aiolon corinth crl dodona ephyre hellespont ilios ismaros ithaka kimmerion kypros lemnos lole marathon mykene ogygia orchomenos phoenicia pylos scheria sparta thebes thrinakia troia zakynthos)

set hosts = `/usr/local/bin/crl_machines | sed -e "s/mykene //"`

# set echo=1

set cmd = finger
set result_file = _.lst
set do_kill = 0
if ("$1" == "-k") then 
    set do_kill = 1
    shift
endif
if ("$1" != "") then
	set cmd = "$*"
	## if ("$1" =~ [a-z]) set result_file = _$1.lst
	set result_file = _`basename $1`_.list
endif

set this_host = `hostname`
if (-e $result_file) rm $result_file
foreach host ($hosts)
   if ($host == $this_host) continue
   echo $host >> $result_file
   ## ping $host >& temp_$$.log
   ## set status = `cat temp_$$.log`
   ## if ($status =
   echo "Issuing: rsh" $host $cmd
   if ($do_kill == 1) then
       sleep 15; kill_em.sh rsh $host >>& ~/tmp/kill.list &
   endif
   rsh -n $host $cmd >> $result_file
end
cat $result_file
	      

