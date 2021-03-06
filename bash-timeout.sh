#Newsgroups: comp.unix.admin,comp.unix.solaris,comp.unix.shell
#From: gwc@root.co.uk (Geoff Clare)
#Subject: Re: timeout -t <sec> <unix command> (Re: How to give rsh a shorter timeout?)
#Message-ID: <EoBxrs.223@root.co.uk>
#Date: Fri, 13 Feb 1998 18:23:52 GMT

#
# Conversion to bash v2 syntax done by Chet Ramey <chet@po.cwru.edu
# UNTESTED
#

prog=${0##*/}
usage="usage: $prog [-signal] [timeout] [:interval] [+delay] [--] <command>"

SIG=-TERM	# default signal sent to the process when the timer expires
timeout=60	# default timeout
interval=15	# default interval between checks if the process is still alive
delay=2		# default delay between posting the given signal and
		# destroying the process (kill -KILL)

while :
do
	case $1 in
	--)	shift; break ;;
	--time-out)	timeout=$2; shift;;
	-*)	SIG=$1 ;;
	[0-9]*)	timeout=$1 ;;
	:*)	EXPR='..\(.*\)' ; interval=`expr x"$1" : "$EXPR"` ;;
	+*)	EXPR='..\(.*\)' ; delay=`expr x"$1" : "$EXPR"` ;;
	*)	break ;;
	esac
	shift
done

case $# in
0)	echo "$prog: $usage" >&2 ; exit 2 ;;
esac

(
	for t in $timeout $delay
	do
		while (( $t > $interval ))
		do
			sleep $interval
			kill -0 $$ || exit
			t=$(( $t - $interval ))
		done
		sleep $t
		kill $SIG $$ && kill -0 $$ || exit
		SIG=-KILL
	done
) 2> /dev/null &

exec "$@"
