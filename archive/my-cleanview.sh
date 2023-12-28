#!/bin/bash
#
#  cleanview.sh  -  Clean private files from a CCase view
#

# Uncomment following line(s) for tracing:
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#  
## set -o xtrace
## set -o verbose

if [ ! $CLEARCASE_ROOT ] ; then
   echo "Looks like you are not running CCase."
   echo "Set to the CCase view you want to clean and try again."
   exit 1
fi

# Optionally enable verbose tracing
RM=/usr/bin/rm
if [ ! -f "$RM" ]; then RM=/bin/rm; fi
if [ "$1" = "--verbose" ]; then
    RM="$RM -v";
    shift 1;
fi

# Show usage if insufficient arguments given
if [ "$1" = "" ] ; then
   script_name=`basename $0`
   echo " "
   echo "Pass VOB name to cleanview.sh script:"
   echo "  $0 [--verbose] VOB"
   echo ""
   echo "Examples:"
   echo ""
   echo "'$script_name [args] rware' or '$script_name all'"
   echo ""
   log="/tmp/cleanview-$$.log"
   echo "echo y | $script_name --verbose rware >| $log; less $log 2>&1"
   echo ""
   exit 1
else
   VOBN=$1
fi

VOB=/vobs/${VOBN}
VIEWN=`echo ${CLEARCASE_CMDLINE} | sed "s/setview //g"`


if [ ${VOBN} != "rware" -a ${VOBN} != "spider" -a ${VOBN} != "cat" -a ${VOBN} != "doc" -a ${VOBN} != "test" -a ${VOBN} != "demos" -a ${VOBN} != "ce" -a ${VOBN} != "all" ] ; then
   echo " "
   echo "Pass VOB name to cleanview.sh script"
   echo "  valid VOB names are rware, spider, cat, ce, or doc"
   echo "  eg. 'cleanview.sh rware' or 'cleanview.sh all'"
   exit 1 
fi

if [ ${VOBN} = "all" ] ; then
echo "Are you SURE you want to remove all private files in"
echo "${VIEWN} view in all VOBs?  (Checkouts will remain)  y/[n]: "
read resp
if [ "$resp" != "y" ] ; then
  echo "User aborted"
  exit 1
fi

else

echo "Are you SURE you want to remove all private files in"
echo "${VIEWN} view, /vobs/${VOBN}?  (Checkouts will remain)  y/[n]: "
read resp
if [ "$resp" != "y" ] ; then
  echo "User aborted"
  exit 1
fi
fi

if [ ${VOBN} = "all" -o ${VOBN} = "rware" ] ; then

cd /vobs/rware
if [ -d "protos" ] ; then
   $RM -rf protos
fi
if [ -d "data" ] ; then
   $RM -rf data
fi
if [ -d "alternate_indexes" ] ; then
   $RM -rf alternate_indexes
fi
if [ -d "sun4os5" ] ; then
   $RM -rf sun4os5
fi
if [ -d "nt" ] ; then
   $RM -rf nt
fi
if [ -d "hpux" ] ; then
   $RM -rf hpux
fi
if [ -d "alpha" ] ; then
   $RM -rf alpha
fi
# End all or rware target
fi

if [ ${VOBN} = "all" -o ${VOBN} = "cat" ] ; then
cd /vobs/cat
if [ -d "sun4os5" ] ; then
   $RM -rf sun4os5
fi
if [ -d "hpux" ] ; then
   $RM -rf hpux
fi
if [ -d "alpha" ] ; then
   $RM -rf alpha
fi

cd /vobs/cat/bin
if [ -d "sun4os5" ] ; then
   $RM -rf sun4os5
fi
if [ -d "hpux" ] ; then
   $RM -rf hpux
fi
if [ -d "alpha" ] ; then
   $RM -rf alpha
fi

cd /vobs/cat/lib
if [ -d "sun4os5" ] ; then
   $RM -rf sun4os5
fi
if [ -d "hpux" ] ; then
   $RM -rf hpux
fi
if [ -d "alpha" ] ; then
   $RM -rf alpha
fi
# End all or cat target
fi

cd /vobs/rware
if [ ${VOBN} = "all" ] ; then
/usr/atria/bin/cleartool lspriv > privs
echo "Not removing your checked out files, listed:"
grep checkedout privs

grep -v checkedout privs > privso

while read line; do
   $RM -rf ${line}
done < privso
$RM -f privs*
echo done removing all private files from your view
exit 1
fi

/usr/atria/bin/cleartool lspriv -invob ${VOB} > privs
echo "Not removing your checked out files, listed:"
grep checkedout privs

grep -v checkedout privs > privso

while read line; do
   $RM -rf ${line}
done < privso
$RM -f privs*
echo done removing all private files from ${VOB}

