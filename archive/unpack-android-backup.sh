#! /bin/bash
#
# unpack-android-backup.sh: extracts files from Android backup made with adb
# utility. See
#    https://android.stackexchange.com/questions/28481/how-do-you-extract-an-apps-data-from-a-full-backup-made-through-adb-backup
#
# This workds by creating a standard Zlib file header for a .tar.gz file with
# printf command (0x1F 0x8B is a signature, 0x08 is the compression method, 0x00
# are flags and 4 x 0x00 is timestamp), then appends to this header the contents
# of backup.ab file, starting from offset 25d. Such stream is a valid .tar.gz
# file, and the tar xfvz command recognizes it as such, so it can successfully
# uncompress the stream.
#

# Uncomment following line(s) for tracing:
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#  
## echo "$@"
## set -o xtrace
## set -o verbose

# Parse command-line options
#
tar_op="x"
moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
while [ "$moreoptions" = "1" ]; do
    if [ "$1" = "--trace" ]; then
	set -o xtrace;
    elif [ "$1" = "--view" ]; then
	tar_op="v"
    elif [ "$1" = "--" ]; then
	break;
    else
	echo "ERROR: Unknown option: $1";
	exit;
    fi
    shift;
    moreoptions=0; case "$1" in -*) moreoptions=1 ;; esac
done
archive="$1"

# Show usage statement if insuffient arguments
#
if [ "$archive" = "" ]; then
    echo ""
    echo "usage: `basename $0` [--view] backup-file"
    echo ""
    echo "ex: `basename $0` backup.ab"
    echo ""
    exit
fi



# Extract the archive whatever
( printf "\x1f\x8b\x08\x00\x00\x00\x00\x00" ; tail -c +25 $archive ) |  tar xfvz -
