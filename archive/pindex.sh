#!/bin/sh
# Copyright (c) 1990 Bell Communications Research, Inc. All Rights Reserved
#          Proprietary - Use With Bellcore Written Permission Only         
#
# pindex	Do everything related to a SVD run.
#
#######
#
#	Set up defaults for shell variables.
#

me=`basename $0`
USAGE="Usage: $me options, where options are:
	-c file			stop words (common words) file
	-d name			run name
	-D			use existing keys database
	-e string		extra characters to be considered as part
				of a word for mkey
	-k[dg] n		threshold for document or global frequency
	-hb			keeps hb (harwell boeing) matrix around; needed for svd
	-l n			minimum keyword length
	-m n			keyword truncation length
	-M n			maximum line length for mkey
	-n n			number of factors
	-ni n			maximum iterations in new svd (las2) 
	-nc n			number of stop words to use
	-nd			normalize document length 
	-N			include numbers as keys
	-o file			optional log file for weight
	-p file			use 'file' as svd binary*
	-P			use 'svd' as svd binary*
	-q			produce no summary output
	-w local [global]	where 'local' is 'log', 'tf' or 'binary',
				and 'global' is 'normal', 'idf', 'idf2', or 'entropy'
	-v			output summary

* Options '-p' and '-P' cause svd to be run"

#
#	Flags
#

VERBOSE=1					# -q | -v
keephb=0					# -hb to keep hb matrix; default removes it

#
#	Numeric options
#

DF=1						# -kd n
GF=1						# -kg n
MAXLINE=10000					# -M n
MAXLEN=20					# -m n
MINLEN=2					# -l n
NCOMMON=1000					# -nc n
NFACT=100					# -n n
MAXITER=0					# -ni n



#
#	String options and variables
#

#BIN=${BIN-/afs/pitt.edu/usr76/pfoltz/infoscale-sun/bin}
BIN=${BIN-/home/language_tools/IR/lsi/bin}
#ETC=${ETC-/afs/pitt.edu/usr76/pfoltz/infoscale-sun/etc}
ETC=${ETC-/home/language_tools/IR/lsi/etc}
mkey=${mkey-$BIN/mkey}
weight=${weight-$BIN/weight}
mkkeydb=${mkkeydb-$BIN/mkkeydb}
getkeydb=${getkeydb-$BIN/getkeydb}
rbc=${rbc-$BIN/rbc}
berryfmt=${berryfmt-$BIN/berryfmt}
las2=${las2-$BIN/las2}
make_matrix=${make_matrix-$BIN/make_matrix}

CHARS=""					# -e string
## COMMON="/home/language_tools/IR/lsi/common_words"			# -c file
COMMON="/home/language_tools/IR/lsi/etc/common_words"	# -c file
GLOBAL=""					# -w local global
LOCAL="tf"					# -w local
MNFLAG=""					# -N
NORMALDOC=""					# -nd to normalize document length before svd

TEMP=`cd ..;pwd`
NAME=`basename $TEMP`

#
#	Process the command line
#
if (echo "$@" | egrep -s -e '-\?')
then
	echo "$USAGE"
	exit 1
fi

if (echo "$@" | egrep -s -e '-D')
then
	CREATEDB=0

	PATTERN="-c|-e|-kd|-kg|-l|-N|-m|-nc|-w"

	if (echo "$@" | egrep -s -e "$PATTERN")
	then
		echo "Attempt to change parameters in existing database aborted."
		exit 1
	else
		. ./RUN_SUMMARY
	fi
else
	CREATEDB=1

	if [ -f keys.dir ]
	then
		/bin/echo -n "Remove existing keys database? [yq] " >&2
		read yesno
		case $yesno in
		y|Y|yes|Yes)	rm keys.dir keys.pag;;
		*)		echo "bye"; exit 1;;
		esac
	fi

	if [ -f RUN_SUMMARY ]
	then
		/bin/echo -n "Get default values from RUN_SUMMARY? [yn] " >&2
		read yesno
		case $yesno in
		y|Y|yes|Yes)	. ./RUN_SUMMARY;;
		*)		;;
		esac
	fi
fi

while [ $# -gt 0 ]
do
	case $1 in
	-c)	COMMON="$2";		shift;;
	-D)				;;
	-d)	NAME="$2";		shift;;
	-e)	CHARS="$2";		shift;;
	-hb)	keephb=1		;;
	-kd)	DF="$2";		shift;;
	-kg)	GF="$2";		shift;;
	-l)	MINLEN="$2";		shift;;
	-M)	MAXLINE="$2";		shift;;
	-m)	MAXLEN="$2";		shift;;
	-N)	MNFLAG="-N"		;;
	-n)	NFACT="$2";		shift;;
	-ni)	MAXITER="$2";		shift;;
	-nc)	NCOMMON="$2";		shift;;
	-nd)	NORMALDOC="cos"		;;
	-o)	weight="$weight $1 $2";	shift;;
	-p)	svd="$2";		shift;;
	-P)	svd=${svd-$BIN/svd}	;;
	-q)	VERBOSE=0		;;
	-v)	VERBOSE=1		;;
	-w)	case $2 in
		tf|log|binary)	LOCAL="$2"
				case ${3-null} in
				entropy|idf|idf2|normal)
					GLOBAL="$3"
					shift;;
				*)	;;
				esac;;
		entropy|idf|idf2|normal)
				GLOBAL="$2";;
		*)		echo "$me: invalid weight $2"; exit 0;;
		esac
		shift;;
	-\?)	echo "$USAGE"
		exit 1;;
	-*)	echo "$me: invalid argument \"$1\""
		echo "$USAGE"
		exit 1;;
	*)	if [ -n "$FILES" ]
		then
			echo "$USAGE"
			exit 0
		fi
		if [ -n "$FILE" ]
		then
			OLDFILE=$FILE
		fi
		FILE=$1
		FILES=1;;
	esac
	shift
done

#
#	Put together shell variables that are pieced together
#	out of defaults plus command line options, and make
#	sure that all of the options made sense.
#

if [ -z "$FILE" ]
then
	FILE=../docs
fi

weight="$weight -kd $DF -kg $GF"

#
#	I need the docs file if I'm either creating a new keys
#	database or running SVD.
#

if [ ! -f $FILE -a '(' $CREATEDB = 1 -o -n "$svd" ')' ]
then
	echo "$me: Can't find $FILE"
	exit 0
fi

#
#	Set up the arguments for mkey
#

mkey="$mkey	-k100000	\
		-s		\
		$MNFLAG		\
		-c $COMMON	\
		-n$NCOMMON	\
		-l$MINLEN	\
		-m$MAXLEN	\
		-M$MAXLINE	\
"

if [ -n "$CHARS" ]
then
	mkey="$mkey -e $CHARS"
fi

#######
#
#	Create a new keys database (if -D option was *not* given.)
#

if [ $CREATEDB = 1 ]
then
	if [ -f keys.dir ]
	then
		/bin/echo -n "Remove existing keys database? [yq] " >&2
		read yesno
		case $yesno in
		y|Y|yes|Yes)	rm keys.dir keys.pag;;
		*)		echo "bye"; exit 1;;
		esac
	fi

	echo running mkey --- `date`
	echo "	$mkey $FILE $ADDITIONS > /usr/tmp/p$$"
	$mkey $FILE $ADDITIONS > /usr/tmp/p$$
	## cp /usr/tmp/p$$ mkey.out

	echo running weight and mkkeydb --- `date`
	echo "	$weight $LOCAL $GLOBAL < /usr/tmp/p$$ | $mkkeydb -w $LOCAL $GLOBAL -d `wc -l < /usr/tmp/p$$` -"
	$weight $LOCAL $GLOBAL < /usr/tmp/p$$ |
	   $mkkeydb -w $LOCAL $GLOBAL -d `wc -l < /usr/tmp/p$$` -

## tpo: output full version of matrix
	make_matrix -o < /usr/tmp/p$$ | sed -e "s/.0000//g" > full_matrix.list
	gzip full_matrix.list
##

	### std: 1/93 and 2/93
	#
	# create HB format of matrix using new make_matrix pgm and rbc.c
	# run make_matrix -0 and rbc
	# nonz is a file create by weight; it gives the number of nonzeros in data
	if [ -f nonz ]
	   then ELEM=`cat nonz`
	   else echo "cant find file nonz (generated by weight)"
		exit
	fi
	if [ -n "$NORMALDOC" ]			# check to see if we normalize doc length
	   then make_matrix="$make_matrix -n"
	fi
	echo generating matrix.hb --- `date`
	(echo '# junk header'; echo '#junk header'; $make_matrix -O < /usr/tmp/p$$)  | 
		$rbc -e $ELEM | compress > matrix.hb.Z
	#
	###

	trap "rm /usr/tmp/p$$" 0
else
#
#	We were asked to use an existing database.  Do a sanity check.
#
	if [ ! -f keys.dir -o ! -f keys.pag -o ! -f matrix.hb.Z ]
	then
		echo "Some part of database missing - "
		echo "   check for: keys.dir, keys.pag, matrix.hb.Z"
		exit 1
	fi

	if [ -n "$OLDFILE" -a "$OLDFILE" != "$FILE" ]
	then
		STRING="Is $FILE the new name for $OLDFILE? [yq] "
		/bin/echo -n "$STRING" >&2
		read yesno
		case $yesno in
		y|Y|yes|Yes)	;;
		*)		echo "bye"; exit 1;;
		esac
	fi
fi

#######
#
#	Create or modify the RUN_SUMMARY file.
#


R=/usr/tmp/r$$
S=/usr/tmp/s$$

NTERMS=`$getkeydb -k`
NDOCS=`$getkeydb -d`
if [ $NTERMS -gt $NDOCS ]	# set MIN and MAX terms, docs
   then MAXTD=$NTERMS
	MINTD=$NDOCS
   else MAXTD=$NDOCS
	MINTD=$NTERMS
fi

if [ $CREATEDB = 1 ]
then
#
#	Write out variables that have to be set when the
#	database is created.
#

	echo "\
#
#	Variables set when keys database created (i.e. constants):
#
CHARS=`echo \"$CHARS\" | sed 's/./\\\&/g'`
DF=\"$DF\"
GF=\"$GF\"
LOCAL=\"$LOCAL\"
GLOBAL=\"$GLOBAL\"
COMMON=\"$COMMON\"
NTERMS=\"$NTERMS\"
NDOCS=\"$NDOCS\"
NCOMMON=\"$NCOMMON\"
MINLEN=\"$MINLEN\"
MAXLINE=\"$MAXLINE\"
MAXLEN=\"$MAXLEN\"
MNFLAG=\"$MNFLAG\"
NORMALDOC=\"$NORMALDOC\"
#
#	Variables that can be changed when SVD is run.
#\
" > $R

	if [ -f RUN_SUMMARY ]
	then
		grep '##' RUN_SUMMARY
		echo '##'
		echo "## Keys database remade `date`"
	else
		echo '##'
		echo "## Keys database created `date`"
	fi > $S

	cat $R $S > RUN_SUMMARY
	rm $R $S
fi

#
#	Check to see if the number of factors is greater than the
#	number of documents
#

if [ $NFACT -gt $MINTD ]
then
	if [ $VERBOSE -eq 1 ]
	then 
		echo "pindex: Changing number of factors from $NFACT to $MINTD"
	fi
	NFACT=$MINTD
fi

#
#	Write all of the changeable parameters out to
#	RUN_SUMMARY.  Don't lose the settings of other
#	variables, and make sure that the comments (which
#	all begin with "##") stay at the end of the file.
#

egrep -v "^##|NAME|NFACT|FILE|ADDITIONS|^$" RUN_SUMMARY > $R

echo "\
NAME=\"$NAME\"
FILE=\"$FILE\"
NFACT=\"$NFACT\"\
" >> $R

if [ ! -z "$ADDITIONS" ]
then
	echo "ADDITIONS=\"$ADDITIONS\"" >> $R
fi

egrep '##' RUN_SUMMARY >> $R

cp $R RUN_SUMMARY
rm $R

HEADER="$NAME -- $svd run on `hostname` at `date`"

#
#	The summary line goes both to stdout in verbose
#	mode, and is a comment line in the input to svd.
#	Which is passed on to the output file. It should
#	say everything that is important about the run.
#

SUMMARY="wt = `$getkeydb -w`, df > $DF, gf > $GF"
SUMMARY="$SUMMARY; $NFACT factors, `$getkeydb -k` terms, `$getkeydb -d` docs"

if [ $VERBOSE = 1 ]
then
	echo $HEADER >&2
	echo $SUMMARY >&2
fi

#
#	The rest of this is only done if we're actually running
#	svd, i.e. if -p or -P was set.
#

if [ -z "$svd" ]
then
	exit 1
fi

echo "\
##
## $HEADER
##    $SUMMARY\
" >> RUN_SUMMARY

if [ $VERBOSE = 1 ]
then
	echo "Turning off interrupts" >&2
fi

#######
#
# 	create parameter file (lap2) that new svd (las2) needs
#
if [ ! $MAXITER -gt 0 ]			# MAXITER not set on command line
   then MAXITER=`expr 3 \* $NFACT`	# guestimate, 2.5 might be ok
fi
if [ $MAXITER -gt $MINTD ]		# reset to min(ndocs,nterms)
   then if [ $VERBOSE -eq 1 ]
        then 
	    echo "pindex: Changing maxiter from $MAXITER to $MINTD"
        fi
        MAXITER=$MINTD
fi
echo "matrix.hb $MAXITER $NFACT -1.e-30 1.e-30 TRUE 1.e-6 1" > lap2


#######
#
#	Run svd.
#

trap "" 1 15
(
	if [ -f matrix.hb.Z ]
	then
		echo running svd --- `date`
		echo "	zcat matrix.hb.Z | $las2"
		zcat matrix.hb.Z | $las2
		# set up files (svals, header, lvectors, rvectors) for berryfmt5
		echo formatting lsi database --- `date`
		NITEMS=$MAXTD
##		NEIG=`grep NEIG lao2 | 
##			awk '{print substr($0,index($0, "=")+1)}' | tr -d ' '`
		NSIG=`grep NSIG lao2 |  	# NSIG=%3d fmt ... yuk
			awk '{print substr($0,index($0, "=")+1)}' | tr -d ' '`
##		echo user set NFACT=$NFACT  ---  las2 calculated actual NEIG=$NEIG
		echo user set NFACT=$NFACT  ---  las2 calculated actual NSIG=$NSIG
##		tail -$NEIG lao2 > svals
		tail -$NSIG lao2 > svals
		echo "# $HEADER" > header
		echo "#    $SUMMARY" >> header
		if [ $NTERMS -gt $NDOCS ]	# switch labels if NTERMS < NDOCS
		   then
			rm -f lvectors; ln -s lalv2 lvectors
			rm -f rvectors; ln -s larv2 rvectors
		   else
			rm -f lvectors; ln -s larv2 lvectors
			rm -f rvectors; ln -s lalv2 rvectors
		fi
		# las2 done, now reformat into our format
##		$berryfmt -n $NEIG -i $NITEMS
		$berryfmt -n $NSIG -i $NITEMS

#set nfact correctly  --Std's code 11/25/96
		NSIG=`grep NSIG lao2 |  	# NSIG=%3d fmt ... yuk
			awk '{print substr($0,index($0, "=")+1)}' | tr -d ' '`
		echo user set NFACT=$NFACT  ---  las2 calculated actual NSIG=$NSIG
		echo NFACT=\"$NSIG\" >> RUN_SUMMARY

		# clean up
		rm lao2 larv2 lalv2 lap2 header svals rvectors lvectors nonz
		if [ $keephb -eq 0 ]
		   then rm matrix.hb.Z
		fi
		echo indexing documents file --- `date`
		indexdoc $FILE
		# all done
		echo all done --- `date`
	else
		echo "no matrix.hb.Z file; cant run svd"
		exit
	fi
) 
