#!/bin/sh
#
# wn.sh: simple wrapper around wn command
#
# examples:
#
# $ export wn_options="-s"
# $ wn.sh -synsn boat
# Synonyms/Hypernyms (Ordered by Frequency) of noun boat
# 
# 2 senses of boat                                                        
#
# Sense 1
# boat#1
#        => vessel#2, watercraft#2
# 
# Sense 2
# gravy boat#1, sauceboat#1, boat#2
#        => dish#1
# 

# Uncomment the following line to trace the script
## set -o xtrace

other_options="$wn_options"
options=""

moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
while [ "$moreoptions" = "1" ]; do
    if [ "$1" = "--usage" ]; then
	show_usage=1;
    elif [ "$1" = "--basic" ]; then
	other_options="";
    else
	options="$options $1"
    fi
    shift 1;
    moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
done

# Parse command-line arguments
# NOTE: at least one word must be specified
if [ "$1" = "" ]; then show_usage=1; fi
if [ "$show_usage" = "1" ]; then
    echo ""
    echo "usage: `basename $0` [--usage | --basic] word ..."
    echo ""
    echo "ex: `basename $0` -synsn -g boat"
    echo ""
    echo "notes:"
    echo " - The wn_options environment variable specified default options"
    echo ""
    exit
fi

## OLD: if [ "$WNSEARCHDIR" = "" ]; then export WNSEARCHDIR=/opt/local/pkg/wordnet-1.6/dict; fi;
## OLD: if [ "$wn" = "" ]; then wn=/opt/local/pkg/wordnet-1.6/Linux-2-x86/bin/wn; fi;
if [ "$wn" = "" ]; then wn="wn"; fi;
if [ "$options" = "" ]; then options="-over"; fi
"$wn" $* $other_options $options
