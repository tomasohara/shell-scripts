#! /usr/bin/env python
#
# Adhoc docstring tests for mezcla.
#
# Notes:
# - The doctest comparison is picky, so you might need to account for whitespace
#   trivial differences.
#

r"""
Miscellaenous docstring tests for mezcla modules

#...............................................................................
# Initialization

## TODO?
## >>> import re

#...............................................................................
# __init__.py

>>> from mezcla import *

>>> int(TL.DEFAULT)
2

>>> int(TL.DETAILED)
4

>>> (len(set(["debug", "mezcla", "system"]).intersection(dir())) >= 3)
True

>>> mezcla_dir = mezcla.__path__[0]

#................................................................................
# main.py

# Make sure default temp_file under $TMP/main-...
# main.dummy_app.temp_file 
# '/home/tomohara/temp/tmp/main-y8c4o3vx'

>>> from mezcla.main import dummy_app

>>> (isinstance(dummy_app.temp_file, str) and (len(dummy_app.temp_file) > 0))
True

>>> re.sub(r"-[^\\-]+$", "-...",
...        re.sub(system.getenv_text('TMP', '???'), "<TMP>",
...               dummy_app.temp_file))
'<TMP>/main-...'

## TEST:
## >>> gh.run("bash -i -c 'BRIEF_USAGE=0 main.py 2>&1'")
## ...

>>> system.setenv("BRIEF_USAGE", "0")

>>> gh.run("main.py 2>&1")
Warning: /home/tomohara/python/Mezcla/mezcla/main.py is not intended to be run standalone
usage: main.py [-h] [filename]

TODO: what the script does

positional arguments:
  filename    Input filename

optional arguments:
  -h, --help  show this help message and exit

#................................................................................
# debug.py

>>> temp_temp_dir = ""

>>> def init_temp_temp_dir():
...     '''adhoc function'''
...     global temp_temp_dir
...     temp_temp_dir = dummy_app.temp_file + "-temp-dir"

>>> debug.code(1, init_temp_temp_dir)

>>> (len(temp_temp_dir) > 0)
True

#................................................................................
# glue_helpers.py
#
# note: shameless hack used below (effing dostests rigidity)
#

>>> gh.full_mkdir(temp_temp_dir)

## TEST:
## >>> gh.run(f"bash -i -c \"cd '{temp_temp_dir}'; touch 1 3 5; ls\"")
##

>>> gh.run(f"cd '{temp_temp_dir}'; touch 1 3 5; ls")
1
3
5

"""

# Standard packages
import doctest
import re
import sys

# Local packages
from mezcla import debug
from mezcla import system

# Constants
TL = debug.TL

#-------------------------------------------------------------------------------

def main():
    """Entry point"""
    debug.trace(TL.USUAL, f"main(): filename={system.real_path(__file__)}")

    # Show usage if insuffient command line
    # TODO: add real argument processing
    command_line = str(sys.argv)
    show_usage = ((len(sys.argv) <= 1)
                  or (re.search(r"--help\b", command_line)))
    if show_usage:
        system.print_error(f"Usage: {sys.argv[0]} [--help] [--verbose | --quiet] [--diff]")
        system.print_error("")
        system.print_error("Note: See test_doctest.py for plenty of example tests:")
        system.print_error("    https://github.com/python/cpython/blob/main/Lib/test/test_doctest.py")
        system.print_error("")
        system.print_error("Examples:\n\n")
        system.print_error(f"{sys.argv[0]} --quiet\n\n")
        system.print_error(f"{sys.argv[0]} --verbose 2>&1 | less\n\n")
        sys.exit()
    debug.trace_expr(4, command_line, show_usage)
                           
    # Run tests, optionally in verbose
    verbose = re.search(r"--verbose\b", command_line)
    debug.trace_expr(4, verbose)
    options = doctest.NORMALIZE_WHITESPACE
    if re.search(r"--diff\b", command_line):
        options |= doctest.REPORT_CDIFF
    debug.trace(5, f"doctest options: {options}; {doctest.OPTIONFLAGS_BY_NAME}")
    doctest.testmod(verbose=verbose,
                    optionflags=options)
                           

if __name__ == "__main__":
    main()
