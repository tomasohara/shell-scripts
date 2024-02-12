#! /bin/csh -f
#
# invokes ical with proper environment (e.g., gcc libs)
#

# Uncomment (or comment) the following for enabling (or disabling) tracing
## set echo=1

# Run ical directly from the source directory
# note: under solaris gcc is made active
if ("$OSTYPE" == "solaris") then
    source /local/config/cshrc.gcc
    ~/old-tomohara/src/ical-2.2/ical $*
else 
    ~/src/ical-2.2/ical $*
endif


