#! /bin/bash
#
# unrar.sh: decompress rar archive to stdout
# See https://superuser.com/questions/708877/how-to-unrar-the-stdin
#

# Uncomment following line(s) for tracing:
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#  
## echo "$@"
set -o xtrace
## set -o verbose

# Show usage statement
#
if [ "$1" = "" ]; then
    echo ""
    echo "usage: `basename $0` [options]"
    echo ""
    echo "ex: cat Ubuntu_64Bit.part01.rar | `basename $0` "
    echo ""
    exit
fi

cat /dev/stdin > /tmp/tmp.rar
unrar x /tmp/tmp.rar
rm /tmp/tmp.rar
