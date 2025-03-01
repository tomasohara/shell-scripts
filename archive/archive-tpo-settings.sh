#! /bin/bash
#
# make-tpo-settings.sh: ad-hoc script for creating tar archive with TPO's
# scripts and settings
#
# TODO:
# - Remove drive specification (e.g., c:/tom/ => tom/).
#

# Uncomment following line(s) for tracing:
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#  
## set -o xtrace
## set -o verbose

# TODO: Show usage statement
#
if [ "$1" = "" ]; then
    echo ""
    echo "usage: `basename $0` [options]"
    echo ""
    echo "ex: `basename $0` whatever"
    echo ""
    exit
fi

# TODO: Parse command-line options
#
moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
while [ "$moreoptions" = "1" ]; do
    if [ "$1" = "--trace" ]; then
	set -o xtrace;
    elif [ "$1" = "--fubar" ]; then
	echo "fubar";
    elif [ "$1" = "--" ]; then
	break;
    else
	echo "ERROR: Unknown option: $1";
	exit;
    fi
    shift 1;
    moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
done
#
base="tpo-scripts-settings-etc"
tom="c:/tom"
tomas="c:/cartera-de-tomas"

# Generate list of files to include
find $tomas -maxdepth 1 -type f -name '.*' > $TEMP/$base.list
ls c:/cygwin/*.bat >> $TEMP/$base.list
ls $tomas/*.bash >> $TEMP/$base.list
ls -d $tomas/bin >> $TEMP/$base.list
ls -d $tom/ssh $tom/perl $tom/multilingual/Dicts >> $TEMP/$base.list

# Create the tar archive
tar cvfzT $TEMP/$base.tar.gz $TEMP/$base.list >| $TEMP/$base.log 2>&1
