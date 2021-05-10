#! /bin/csh -f
#
# xv.sh: invokes xv_solaris or xv
#

set XV=xv
if ($OSTYPE == "solaris") set XV=xv_solaris
$XV $*


