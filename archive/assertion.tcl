#!/bin/sh
#-*-tcl-*-
# the next line restarts using wish \
exec wish "$0" -- ${1+"$@"}
#
#!/usr/local/bin/wish -f
#
# assertion.tcl
#
# Simple TK script to display a message box for an assertion.
# This is meant to be invoked from a C or C++ program as follows:
#
#      String msg = "main.c 73: argc >= 1"
#      String cmd = "assertion.tcl " + msg;
#      system(cmd);
#
# TODO: filter the string so that tcl doesn't interpret it
#       add buttons for ignore/retry/cancel etc
#

# Initialize for debugging (or not)
wm title . "Assertion Failed!"
## message .stupid -aspect 10000 -justify center -text "----- $argv -----";
message .stupid -aspect 10000 -justify center -text " $argv ";
pack .stupid

