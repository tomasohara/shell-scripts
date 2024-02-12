#! /bin/csh -f
#
# get_last_revision.sh: return the latest revision number for the CVS
# or RCS version-controlled file
#
#........................................................................
# sample output from rlog and cvs log (which uses rlog):
#
# $ rlog wn.sh
# RCS file: RCS/wn.sh,v
# Working file: wn.sh
# head: 1.2
# branch:
# locks: strict
# access list:
# symbolic names:
# keyword substitution: kv
# total revisions: 2;	selected revisions: 2
# description:
# .
# ----------------------------
# revision 1.2
# date: 2000/10/26 21:16:56;  author: tom;  state: Exp;  lines: +1 -0
# .
# ----------------------------
# revision 1.1
# date: 2000/10/17 20:53:29;  author: tom;  state: Exp;
# .
# =============================================================================
#
#
# $ cvs log sme-lexification-wizard.lisp
# RCS file: /cyc/cvs/cycorp/cyc/cyc-lisp/cycl/sme-lexification-wizard.lisp,v
# Working file: sme-lexification-wizard.lisp
# head: 1.48
# branch:
# locks: strict
# access list:
# symbolic names:
#         rkf-2000-06-19: 1.12.0.2
#         rkf-2000-06-19-start: 1.12
# keyword substitution: kv
# total revisions: 48;    selected revisions: 48
# description:
# Version of Lexification Wizard for non-technical users, in particular the subject matter experts (SMEs)
# ----------------------------
# revision 1.48
# date: 2001/11/30 23:27:32;  author: tom;  state: Exp;  lines: +5 -3
# M lex-normalize-string : guards against NIL input
# ...
#
#........................................................................
#
# Uncomment the following line for tracing
# set echo = 1

set terse=1
if ("$1" == "") then
    set script_name = `basename $0`
    ## set log_name = `echo "$script_name" | perl -pe "s/.sh/.log/;"`
    echo ""
    echo "usage: `basename $0` [--verbose]"
    echo ""
    echo "ex: `basename $0` rev_vdiff.sh"
    echo ""
    exit
endif
while ("$1" =~ -*)
    if ("$1" == "--verbose") then
	set terse = 0
    else
	echo "ERROR: unknown option: $1"
	exit
    endif
    shift
end


# Check for a RCS revision 
set revision = `rlog $1 |& grep '^head:' | sed -e '1,1 s/^head: //'`
set header = `rlog $1 |& head -13 | perl -pe "s/\n/\;/g;"`

# If not found, check for a cvs revision
if ("$revision" == "") then
    set revision = `cvs log $1 |& grep '^head:' | sed -e '1,1 s/^head: //'`
    set header = `cvs log $1 |& head -13 | perl -pe "s/\n/\;/g;"`
endif

# If still not found, use "???"
if ("$revision" == "") then
    set revision = "???"
endif

# Display the revision
echo "$revision"
if ($terse == 0) then
    echo "$header"  | perl -pe 's/\;/\n/g;'
endif
