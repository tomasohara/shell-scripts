#! /bin/csh -f
# kill_all_graphling_jobs.sh: kills all remote graphling jobs by running the
# kill_em.sh script on each of the remote machines (see foreach.perl for host
# list)
#
# TODO:
# - track down problem with unmatched quote (in kill_em.sh?):
#
#    issuing: rsh -n wb31 /home/graphling/UTILITIES/kill_em.sh --graphling
#    pattern=/(SAMPLE)|(GRAPH)/
#    No processes matched the pattern
#    issuing: rsh -n wb32 /home/graphling/UTILITIES/kill_em.sh --graphling
#    pattern=/(SAMPLE)|(GRAPH)/
#    No processes matched the pattern
#    Unmatched ".
# 

if ("$1" == "") then
    echo ""
    echo "usage: $0 [--for-sure | -]"
    echo ""
    echo "example:"
    echo ""
    echo "$0 - >| kill_all.log 2>&1"
    echo ""
    echo "note: This kills all the remote jobs, using the hostlist determined"
    echo "by foreach.perl. For example, the wbi hosts if on medusa."
    echo ""
    exit
endif

set echo=1
perl -Ssw foreach.perl -busy_load=0.0 -remote -trace '/home/graphling/UTILITIES/kill_em.sh --graphling'

