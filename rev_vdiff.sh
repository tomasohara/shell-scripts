#! /bin/csh -f
#
# rev_vdiff.sh: compare the current file with a particular revision
# from version control, specified via offset (-1 assumed). The
# result is displayed using a visual diff program like tkdiff
# TODO:
# - add support for other diff programs (including diff itself)
# - add support for directly specifyinh revision spec
#

if ("$1" == "") then
    echo "usage rev_diff.sh [--prev revisions_back] file"
    echo ""
    echo "examples:"
    echo ""
    echo "$0 sme-lexification-wizard.lisp"
    echo ""
    echo "$0 --prev 2 sysdcl.lisp"
    echo ""
    exit
endif

set dir=`dirname $0`
set rev_spec = ""
set previous_revision = 1
## set echo = 1
set diff=tkdiff.tcl

# Parse the command line arguments
if ("$1" == "--prev") then
    set previous_revision = $2
    shift
    shift
endif

# Determine the revision specification to compare the current file against
if ($previous_revision > 0) then
    Echo "RCS Version Info:"
    get_last_revision.sh --verbose $1

    set revision = `$dir/get_last_revision.sh $1`
    set rev_major = ` echo $revision | sed -e 's/\..*//' `
    set rev_minor = ` echo $revision | sed -e 's/.*\.//' `
    @ rev_minor -= $previous_revision

    # Set the revision spec for tkdiff (eg, "-r1.61")
    # NOTE: older versions of tkdiff (eg, 1.1) don't support the -r option for CVS
    # The following works for both RCS and CVS for version 3.05 (and higher?)
    set rev_spec = "-r${rev_major}.${rev_minor}"
endif

# Invoke tkdiff on the file with tracing set on
# ex: tkdiff -r1.161 lexicon-accessors.lisp
# set echo = 1
echo "issuing: $diff $rev_spec $1"
$diff $rev_spec $1 &

