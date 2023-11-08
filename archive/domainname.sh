#! /usr/bin/env bash
## OLD: #! /bin/bash
#
# domainname.sh: wrapper around domainname in case under CygWin
#
#
# Uncomment the following line to trace the script
## set -o xtrace

# Parse command-line arguments

# Uncomment (or comment) the following for enabling (or disabling) tracing
set echo=1
name=""

# If under CygWin extract domain name from ipconfig output
#
# TODO: use better detection method for CygWin
## if [[ ((("$OSTYPE" = "cygwin") || ("$TERM" = "cygwin")) && ("$OSTYPE" != "linux"))  ]]; then
#
if [ "$OSTYPE" = "cygwin" ]; then
    name=`command ipconfig | perl -ne 'print "$1\n" if /DNS Suffix.*:\s*(\S+)/;'`
else
    ## OLD: name=`domainname`
    name=$(domainname 2> /dev/null)
fi

if [ "$name" = "" ]; then name="n/a"; fi
echo $name
