#!/bin/csh -f
# This first converts the  artwork prolog output file (arg 1) into lisp format 
# (via revert_ILT). Then it creates a simple lisp program that assigns the 
# output to a variable, so that it can be verified by the lisp reader.
#
# see check_lisp.sh for verifying this using Allegro common lisp (cl)
#
# NOTE: this requires the M4 preprocessor that generally is available with
# GNU distributions, if not the host installation

# optionally set command tracing on
if ("" != `printenv DEBUG_LEVEL`) set echo=1

# create a simple Lisp program to load the file
echo "(setq *output* '(include($1)))" > $1.m4_lisp
m4 < $1.m4_lisp > $1.lisp

