#! /bin/sh
#
# print.sh: customization of CRL's front-end print script using a2ps
#
# options:
#	-v	view with ghostview instead of printing
#	-Pname	printer to use (default set by PRINTER environment)
#	-dup	use duplex
#	-c	lpr option for using a copy of the file to be printed
#	-	use stdin for input
#       -note	use common settings for notes (Tom's hack)
#       -r      send to remote printer on CS domain
#
# a2ps options:
# TODO: update to version 4.13
#	-#num (number of copies to print)
#	-?    (print this information)
#	-f    (fold lines too large)
#	-fnum (font size, num is a float number)
#	-h    (print this information)
#	-i    (interpret tab, bs and ff chars)
#	-n    (number line files)
#       now: --line-numbers=N    (number every N line of files)
#	-p    (print in portrait mode)
#	-r    (restart page number after each file)
#	-tn   (set tab size to n)
#	-v    (show non-printing chars in a clear form)
#	-w    (print in wide format)
#	-nb   (don't force printing binary files)
#	-nf   (don't fold lines)
#	-nh   (don't print the header)
#	-ni   (don't interpret special chars)
#	-nn   (don't number output lines)
#	-np   (don't print in portrait format)
#	-nr   (don't restart page number)
#	-ns   (don't print surrounding borders)
#	-nv   (replace non-printing chars by space)
#	-nw   (don't print in wide format)
#
# examples:
#
#   print.sh common.c
#       uses default (small font; line numbers; two columns)
#
#   print.sh -v -f16 -nn -w rebecca_eval.list
#       preview; 16pt font; no numbers; wide fromat
#
#   print.sh -v -n -p ../lexrel2network.perl
#
#
#   print.sh -r -f11 -nn -p misc_14apr.list
#   print.sh -v -note misc_14apr.list
#

LPR_OPTIONS=
## A2PS_ARGS=-n
A2PS_ARGS="--line-numbers=1 --output=-"
VIEW=0
## REMOTE=0
REMOTE=1
## PRINTER=lexdraft
ghostview=""

if [ -z "$PRINTER" ]; then
    ## PRINTER=gizmo
    PRINTER=lexdraft
fi

if [ $# = 0 ]; then
    cat <<EOF

Usage: $0 [options] {file | -} ...

options = [-v] [-p] [-dup] [-note] [-r] [a2s_options]


options:
	-v	view with ghostview instead of printing
	-Pname	printer to use (default set by PRINTER environment)
	-dup	use duplex
	-c	lpr option for using a copy of the file to be printed
	-note	use common settings for notes (Tom's hack)
	-r      send to remote printer on CS domain
        --ghostview command   (also -gv) command to use for ghoostview
	-	use stdin for input
	
a2ps options:
	-#num (number of copies to print)
	-?    (print this information)
	-f    (fold lines too large)
	-fnum (font size, num is a float number)
	-h    (print this information)
	-i    (interpret tab, bs and ff chars)
	--line-numbers=N    (number every N line of files)
	-p    (print in portrait mode)
	-r    (restart page number after each file)
	-tn   (set tab size to n)
	-v    (show non-printing chars in a clear form)
	-w    (print in wide format)
	-nb   (don't force printing binary files)
	-nf   (don't fold lines)
	-nh   (don't print the header)
	-ni   (don't interpret special chars)
	-nn   (don't number output lines)
	-np   (don't print in portrait format)
	-nr   (don't restart page number)
	-ns   (don't print surrounding borders)
	-nv   (replace non-printing chars by space)
	-nw   (don't print in wide format)

examples:
    print.sh common.c
	uses default (small font; line numbers; two columns)

    print.sh -v -f16 -nn -w rebecca_eval.list
	preview; 16pt font; no numbers; wide fromat

    print.sh -r -f11 -nn -p misc_14apr.list
    print.sh -v -note misc_14apr.list

new:
    print.sh --view --line-numbers=0 --font-size=11 xyz.cpp

EOF
    exit
fi

while [ $# != 0 ]; do
	case "$1" in
	-P*)	PRINTER=`echo $1 | sed 's/-P//'`;;
	-h)	LPR_OPTIONS="$LPR_OPTIONS -h";;
	-dup*)	if [ "$PRINTER" = "vannevar" -o "$PRINTER" = "bush_vannevar" ]; then
			PRINTER="duplex_$PRINTER"
		else
			PRINTER="duplex_rover"
		fi;;
	-c)	LPR_OPTIONS="$LPR_OPTIONS -c";;
	-v)     VIEW=1;;
	--view) VIEW=1;;
	--ghostview | -gv)
		ghostview="$2"
		shift
		;;
	-r)     REMOTE=1; PRINTER=lexdraft;;
	-)      ;;
	-note)  A2PS_ARGS="$A2PS_ARGS -f11 -nn -p ";;
	*\ *)	A2PS_ARGS="$A2PS_ARGS '$1'";;
	*)	A2PS_ARGS="$A2PS_ARGS $1";;
	esac
	shift
done

#
# use this when a printer is non-functional to force output to other printer.
#
if [ "$PRINTER" = "apple2" ]; then
	echo "$PRINTER is down; switching to apple."
	PRINTER=apple
fi

if [ "$ghostview" = "" ]; then export ghostview=gv; fi

if [ $VIEW = 1 ]; then
    echo Issuing: a2ps $A2PS_ARGS \> $TMPDIR/print.ps
    a2ps $A2PS_ARGS > $TMPDIR/print.ps
    echo Issuing: $ghostview -landscape $TMPDIR/print.ps
    $ghostview -landscape $TMPDIR/print.ps &
    ## rm $TMPDIR/print.ps
    exit
fi
if [ $REMOTE = 1 ]; then
    echo Issuing: a2ps $A2PS_ARGS \> $TMPDIR/print.ps
    a2ps $A2PS_ARGS > $TMPDIR/print.ps
    ## echo Issuing: remote_print.perl -printer=$PRINTER $TMPDIR/print.ps
    ## remote_print.perl -printer=$PRINTER $TMPDIR/print.ps
    echo Issuing: lpr -P$PRINTER $TMPDIR/print.ps
    lpr -P$PRINTER $TMPDIR/print.ps
    echo Issuing: lpq -P$PRINTER
    lpq -P$PRINTER
    exit
fi

ECHO=/bin/echo
export PRINTER
case $PRINTER in
    apple | lpa | laserwriter | crl_apple )
	$ECHO -n 'printing on "apple" in room 290 - ';;

    apple2 | crl_apple2 )
	$ECHO -n 'printing on "apple2" in room 286 - ';;

    bowser | crl_bowser )
	$ECHO -n 'printing on "bowser" in room 292 - ';;

    gizmo | crl_gizmo )
	$ECHO -n 'printing on "gizmo" in room 289 - ';;

    fido | crl_fido )
	$ECHO -n 'printing on "fido" in room 294 - ';;

    spot | crl_spot )
	$ECHO -n 'Printing on "spot" - ';;

    rover | crl_rover | real_rover | rover2 )
	$ECHO -n 'Printing on "rover" in room 286 - ';;

    duplex_rover | duplex )
	$ECHO -n 'Printing on "rover" in duplex mode in room 286 - ';;

    vannevar | bush_vannevar )
	$ECHO 'Printing on "vannevar", if you do not know where it is,'
	$ECHO -n 'you should NOT be using this printer - ';;

    duplex_vannevar | duplex_bush_vannevar)
	$ECHO 'Printing on "vannevar" in duplex mode, if you do not know'
	$ECHO -n 'where it is, you should NOT be using this printer - ';;

    choto | crl_choto )
	$ECHO -n 'printing on "choto" in room 294 - ';;

    lexdraft | lexfine | lexquad | lexdual | lexnormal )
        $ECHO -n 'printing on Lex printer in room 169 - ';;
    lex2draft | lex2fine | lex2quad | lex2dual | lex2normal )
        $ECHO -n 'printing on Lex printer in room 134 - ';;
    *)
	$ECHO "WARNING: $PRINTER: unknown printer"
	## exit;;
esac

echo Issuing: a2ps $A2PS_ARGS \| lpr $LPR_OPTIONS -P$PRINTER
a2ps $A2PS_ARGS | lpr $LPR_OPTIONS -P$PRINTER
## $ECHO "done"
lpq -P$PRINTER

echo
