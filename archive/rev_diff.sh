#! /bin/csh -f

if ("$1" == "") then
    echo "usage rev_diff.sh [--prev revisions_back] file"
    exit
endif

set dir=`dirname $0`
set rev_spec = ""
set previous_revision = 0
## set echo = 1
set vdiff = tkdiff
set ostype = `printenv OSTYPE`
if (($ostype == cygwin) || ($ostype == posix)) set vdiff = cygwin-tkdiff.sh
if ($?VDIFF) then
    set vdiff = "$VDIFF"
endif

if ("$1" == "--prev") then
    set previous_revision = $2
    shift
    shift
endif

if ($previous_revision > 0) then
    set revision = `$dir/get_last_revision.sh $1`
    set rev_major = ` echo $revision | sed -e 's/\..*//' `
    set rev_minor = ` echo $revision | sed -e 's/.*\.//' `
    @ rev_minor -= $previous_revision
    set rev_spec = "-r${rev_major}.${rev_minor}"
endif

set echo = 1
$vdiff $rev_spec $1 &

