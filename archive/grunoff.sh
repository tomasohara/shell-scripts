#! /bin/sh
##! /bin/sh -x
############################################################################
#
# Copyright (c) 1988 Computing Research Lab
# 12 May 1988
# Jeff Harris, Ted Dunning and Rick Brode
# 6 April 1992
# Mark Leisher
#
############################################################################
# This program is comprised of bits and pieces of AT&T's ditroff package,
# Adobe's transcript, devps, and Sun standard documentation tools such as 
# eqn, tbl, and refer.
#
# To rebuild runoff from scratch, first install ditroff.  The only programs
# that are being used from it are troff_p and pic.  Then install devps.  Both
# devps and the directory /usr/local/lib/laser are used.  Lastly, install
# transcript.  The only use made of transcript is that the filters are used
# in /etc/printcap.  No transcript stuff is actually used in this script.
############################################################################


if [ $# = 0 ]; then
    echo "
    Usage:  grunoff [-j | -s ] [-L | -land] [-man | -me]
               [-#copies | -c copies] [-h] [-opage_list] [-p] [-ascii] files

        Note: use "-" for standard input.
              [-L | -land] must be listed before other options.
    "
    echo "
    examples:

    pod2man Cyc.pm | grunoff.sh -man -p -
    "

    exit 1
fi

# The PATH variable should be modified to refer to local directories.
## PATH=/usr/local/bin/groff:/usr/bin:/usr/ucb:/usr/local/bin:/usr/local/bin/X11
## export PATH
PATH=$PATH:/usr/local/bin/groff
export PATH

LD_LIBRARY_PATH=/usr/local/lib/X11:/usr/openwin/lib
export LD_LIBRARY_PATH

NLSPREP="gnlsprep"

if [ "$GROFF" = "" ]; then 
    GROFF="groff"
fi
MACRO="-ms"
#
# By default all groff preprocessors are used:
#      -s   Preprocess with gsoelim.
#      -t   Preprocess with gtbl.
#      -e   Preprocess with geqn.
#      -p   Preprocess with gpic.
#
OPTIONS="-step"
GROPS_OPTIONS=""
LPR_OPTIONS=
NLSTMP="/usr/tmp/gnlsp.$$"
TMPFILE="/usr/tmp/LW.$$"
PTMP="/usr/tmp/gprv.$$"
ILANG=""
PREVIEW=""
OFILE=""
ASCII="0"

trap 'rm -f $TMPFILE $NLSTMP $PTMP' 1 2 3 4 5 6 7 8 10 12 13 14 15 16

#
# If the user doesn't have their PRINTER variable set, establish a default.
#
if [ -z "$PRINTER" ]; then
   PRINTER=fido
   export PRINTER
fi

if [ -z "$DISPLAY" ]; then
   DISPLAY="unix:0"
   export DISPLAY
fi

while [ $# != 0 ]
do
    case "$1" in
             -P*) PRINTER=`echo $1 | sed 's/-P//'`
                  echo "Printer is set to $PRINTER"
                  export PRINTER;;
        -L|-land) GROPS_OPTIONS="$GROPS_OPTIONS -P-l"
                  echo "Printing in landscape mode";;
             -o*) OPTIONS="$OPTIONS $1";;
             -#*) num_copies=`echo $1 | sed  's/-#//'`
		  GROPS_OPTIONS="$GROPS_OPTIONS -P-c$num_copies"
                  echo "Generating $num_copies copies";;
              -c) GROPS_OPTIONS="$GROPS_OPTIONS -P-c$2"
                  echo "Generating $2 copies"
                  shift;;
              -h) LPR_OPTIONS="$LPR_OPTIONS -h";;
            -man) MACRO="-man";;
             -me) MACRO="-me";;
             -mm) MACRO="-mm";;
              -O) shift
                  OFILE="$1";;
           -N|-n) ILANG="-n";;
           -S|-s) ILANG="-s";;
           -T|-t) ILANG="-t";;
           -J|-j) ILANG="-j";;
              -p) PREVIEW="yes";;
         -ascii)  ASCII="1"
                  PREVIEW="yes"
		  OPTIONS="$OPTIONS -Tascii";;
        -display) shift
                  DISPLAY="$1"
                  export DISPLAY;;
               *) list="$list $1"
                  if [ "$list" = " $1" ]; then
                      name=$1
                  fi;;
    esac
    shift
done

if [ -z "$PREVIEW" -a -z "$OFILE" ]; then
  case $PRINTER in
    times | roman )
	echo 'Printing on printer in mailroom';;

    *)
        echo "warning: unknown printer: $PRINTER"
        ## exit;;
  esac
fi

if [ "$PREVIEW" != "" ]; then
  echo $0 'previewing on display' $DISPLAY
fi

if [ "$OFILE" != "" ]; then
  echo $0 'sending output to file' $OFILE
fi

if [ -z "$PREVIEW" ]; then
  if [ -z "$OFILE" ]; then
    if [ -z "$ILANG" ]; then
       $GROFF $MACRO $OPTIONS $GROPS_OPTIONS $list | lpr $LPR_OPTIONS -P$PRINTER
    else
      case $ILANG in
         -N|-n)
          $GROFF $MACRO $OPTIONS $GROPS_OPTIONS $list | lpr $LPR_OPTIONS -P$PRINTER;;
         -j|-J)
          jc -e $list | gnlsprep -j > $NLSTMP
          $GROFF $MACRO $OPTIONS $GROPS_OPTIONS $NLSTMP | lpr $LPR_OPTIONS -P$PRINTER;;
         *)
          gnlsprep $ILANG $list > $NLSTMP
          $GROFF $MACRO $OPTIONS $GROPS_OPTIONS $NLSTMP | lpr $LPR_OPTIONS -P$PRINTER;;
      esac
    fi
  else
    if [ -z "$ILANG" ]; then
       $GROFF $MACRO $OPTIONS $GROPS_OPTIONS $list > $OFILE
    else
      case $ILANG in
         -N|-n)
          $GROFF $MACRO $OPTIONS $GROPS_OPTIONS $list > $OFILE;;
         -j|-J)
          jc -e $list | gnlsprep -j > $NLSTMP
          $GROFF $MACRO $OPTIONS $GROPS_OPTIONS $NLSTMP > $OFILE;;
         *)
          gnlsprep $ILANG $list > $NLSTMP
          $GROFF $MACRO $OPTIONS $GROPS_OPTIONS $NLSTMP > $OFILE;;
      esac
    fi
  fi
else

  # Format the output
  if [ -z "$ILANG" ]; then
   echo $GROFF "$MACRO $OPTIONS $GROPS_OPTIONS $list > $PTMP"
   $GROFF $MACRO $OPTIONS $GROPS_OPTIONS $list > $PTMP
  else
    case $ILANG in
       -N|-n)
        $GROFF $MACRO $OPTIONS $GROPS_OPTIONS $list > $PTMP;;
       -j|-J)
        jc -e $list | gnlsprep -j > $NLSTMP
        $GROFF $MACRO $OPTIONS $GROPS_OPTIONS $NLSTMP > $PTMP;;
       *)
        gnlsprep $ILANG $list > $NLSTMP
        $GROFF $MACRO $OPTIONS $GROPS_OPTIONS $NLSTMP > $PTMP;;
    esac
  fi

  # Display the output
  if [ $ASCII = "1" ];  then
      echo perl -p -e "s/.\x08//g;" $PTMP
      perl -p -e "s/.\x08//g;" $PTMP
  else 
      echo ghostview $PTMP
      ghostview $PTMP
  fi
fi
rm -f $TMPFILE $NLSTMP $PTMP

exit 0

#------------------------------------------------------------------------
# 
# 
# 
# User Commands                                            GROFF(1)
# 
# 
# 
# NAME
#      groff - front end for the groff document formatting system
# 
# SYNOPSIS
#      groff [ -tpeszaivhblCENRSVXZ ] [  -wname  ]  [  -Wname  ]  [
#      -mname  ] [ -Fdir ] [ -Tdev ] [ -ffam ] [ -Mdir ] [ -dcs ] [
#      -rcn ] [ -nnum ] [ -olist ] [ -Parg ] [ files...  ]
# 
# DESCRIPTION
#      groff is a front-end to the groff document  formatting  sys-
#      tem.   Normally it runs the gtroff program and a postproces-
#      sor appropriate for the selected device.  Available  devices
#      are:
# 
#      ps   For PostScript printers and previewers
# 
#      dvi  For TeX dvi format
# 
#      X75  For a 75 dpi X11 previewer
# 
#      X100 For a 100dpi X11 previewer
# 
#      ascii
#           For typewriter-like devices
# 
#      latin1
#           For typewriter-like devices using the ISO Latin-1 char-
#           acter set.
# 
#      The postprocessor to be used for a device  is  specified  by
#      the  postpro  command  in the device description file.  This
#      can be overridden with the -X option.
# 
#      The default device is ps.  It can optionally preprocess with
#      any of gpic, geqn, gtbl, grefer, or gsoelim.
# 
#      Options without an argument can be grouped behind  a  single
#      -.  A filename of - denotes the standard input.
# 
#      The grog command can be used to guess the correct groff com-
#      mand to use to format a file.
# 
# OPTIONS
#      -h   Print a help message.
# 
#      -e   Preprocess with geqn.
# 
#      -t   Preprocess with gtbl.
# 
#      -p   Preprocess with gpic.
# 
#      -s   Preprocess with gsoelim.
# 
# 
# 
# Groff Version 1.10  Last change: 26 June 1995                   1
# 
# 
# 
# 
# 
# 
# User Commands                                            GROFF(1)
# 
# 
# 
#      -R   Preprocess with grefer.  No mechanism is  provided  for
#           passing arguments to grefer because most grefer options
#           have equivalent commands which can be included  in  the
#           file.  See grefer(1) for more details.
# 
#      -v   Make programs run by  groff  print  out  their  version
#           number.
# 
#      -V   Print the pipeline on stdout instead of executing it.
# 
#      -z   Suppress output from gtroff.  Only error messages  will
#           be printed.
# 
#      -Z   Do not postprocess  the  output  of  gtroff.   Normally
#           groff  will  automatically run the appropriate postpro-
#           cessor.
# 
#      -Parg
#           Pass arg to the postprocessor.  Each argument should be
#           passed with a separate -P option.  Note that groff does
#           not prepend - to arg before passing it to the  postpro-
#           cessor.
# 
#      -l   Send the output to a printer.   The  command  used  for
#           this  is  specified  by the print command in the device
#           description file.
# 
#      -Larg
#           Pass arg to  the  spooler.   Each  argument  should  be
#           passed with a separate -L option.  Note that groff does
#           not prepend - to arg before passing it to the  postpro-
#           cessor.
# 
#      -Tdev
#           Prepare output for device dev.  The default  device  is
#           ps.
# 
#      -X   Preview with gxditview instead of using the usual post-
#           processor.   Groff  passes  gxditview  a  -printCommand
#           option which will make the Print action do  what  groff
#           would  have done if the -l option had been given.  This
#           is unlikely to produce good results except with -Tps.
# 
#      -N   Don't allow newlines with eqn delimiters.  This is  the
#           same as the -N option in geqn.
# 
#      -S   Safer mode.  Pass the -S option to gpic and use  the  -
#           -msafer macros with gtroff.
# 
#      -a
#      -b
#      -i
# 
# 
# 
# Groff Version 1.10  Last change: 26 June 1995                   2
# 
# 
# 
# 
# 
# 
# User Commands                                            GROFF(1)
# 
# 
# 
#      -C
#      -E
#      -wname
#      -Wname
#      -mname
#      -olist
#      -dcs
#      -rcn
#      -Fdir
#      -Mdir
#      -ffam
#      -nnum
#           These are as described in gtroff(1).
# 
# ENVIRONMENT
#      GROFF_COMMAND_PREFIX
#           If this is set X, then groff will run Xtroff instead of
#           gtroff.   This also applies to tbl, pic, eqn, refer and
#           soelim.  It does not apply to grops, grodvi, grotty and
#           gxditview.
# 
#      GROFF_TMAC_PATH
#           A colon separated  list  of  directories  in  which  to
#           search for macro files.
# 
#      GROFF_TYPESETTER
#           Default device.
# 
#      GROFF_FONT_PATH
#           A colon separated  list  of  directories  in  which  to
#           search for the devname directory.
# 
#      PATH The search path for commands executed by groff.
# 
#      GROFF_TMPDIR
#           The directory in which temporary files will be created.
#           If  this  is not set and TMPDIR is set, temporary files
#           will be created in that directory.  Otherwise temporary
#           files  will  be  created  in  /tmp.   The  grops(1) and
#           grefer(1) commands can create temporary files.
# 
# FILES
#      /usr/local/share/groff/font/devname/DESC
#           Device description file for device name.
# 
#      /usr/local/share/groff/font/devname/F
#           Font file for font F of device name.
# 
# AUTHOR
#      James Clark <jjc@jclark.com>
# 
# Groff Version 1.10  Last change: 26 June 1995                   3
# 
# User Commands                                            GROFF(1)
# 
# BUGS
#      Report bugs to bug-groff@prep.ai.mit.edu.   Include  a  com-
#      plete,  self-contained example that will allow the bug to be
#      reproduced, and say which version of groff you are using.
# 
# COPYRIGHT
#      Copyright cO 1989, 1990, 1991, 1992 Free Software Foundation,
#      Inc.
# 
#      groff is free  software;  you  can  redistribute  it  and/or
#      modify  it under the terms of the GNU General Public License
#      as published by the Free Software Foundation; either version
#      2, or (at your option) any later version.
# 
#      groff is distributed in the hope that it will be useful, but
#      WITHOUT  ANY  WARRANTY; without even the implied warranty of
#      MERCHANTABILITY or FITNESS FOR A  PARTICULAR  PURPOSE.   See
#      the GNU General Public License for more details.
# 
#      You should have received a copy of the  GNU  General  Public
#      License  along  with  groff;  see the file COPYING.  If not,
#      write to the Free Software Foundation,  59  Temple  Place  -
#      Suite 330, Boston, MA 02111-1307, USA.
# 
# AVAILABILITY
#      The most recent released version of groff is  always  avail-
#      able  for anonymous ftp from prep.ai.mit.edu (18.71.0.38) in
#      the directory pub/gnu.
# 
# SEE ALSO
#      grog(1), gtroff(1), gtbl(1), gpic(1),  geqn(1),  gsoelim(1),
#      grefer(1),  grops(1),  grodvi(1),  grotty(1),  gxditview(1),
#      groff_font(5),     groff_out(5),     groff_ms(7),     me(7),
#      groff_char(7), msafer(7)
# 
# Groff Version 1.10  Last change: 26 June 1995                   4
# 
