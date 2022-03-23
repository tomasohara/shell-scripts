================================================================================
Adhoc example-based tests.

See https://pypi.org/project/docshtest,

Usage:
   docshtestndocshtest.rst
================================================================================

Conditional export only defines environment variable if not defined:

## TODO:
##     $ source tomohara-aliases.bash
## 
##     $ export FUBAR=1
## 
##     $ cond-export FUBAR 2
## 
##     $ echo $FUBAR
##     1

## HACK: Uses interactive (-i) flag so that aliases fully resolved.
## This works around quirk with 'bash -O expand_aliases ...'

    $ bash -i -c 'source tomohara-aliases.bash; export FUBAR=1; cond-export FUBAR 2; echo $FUBAR'
    1

