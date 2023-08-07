#! /usr/bin/env python
#
# format-profile.py: displays the result of python profiling via cProfile
#
# usage example:
#    python -u -m cProfile -o fubar.profile fubar.py
#    format-profile.py fubar.profile >| fubar.profile.list
#------------------------------------------------------------------------
# Notes:
# via http://docs.python.org/3/library/profile.html:
#
# The Stats Class
#
# Analysis of the profiler data is done using the Stats class.
#
# class pstats.Stats(*filenames or profile, stream=sys.stdout)
# ...
# Stats objects have the following methods:
# ...
# 
# sort_stats(*keys)
#
# This method modifies the Stats object by sorting it according to the
# supplied criteria. The argument is typically a string identifying
# the basis of a sort (example: 'time' or 'name').
#
# Valid Arg    Meaning
# 'calls'      call count
# 'cumulative' cumulative time
# 'cumtime'    cumulative time
# 'file'       file name
# 'filename'   file name
# 'module'     file name
# 'ncalls'     call count
# 'pcalls'     primitive call count
# 'line'       line number
# 'name'       function name
# 'nfl'        name/file/line
# 'stdname'    standard name
# 'time'       internal time
# 'tottime'    internal time
#
# Note: following apply to version 2.7 or later
# - cumtime, filename, ncalls, tottime
#

"""Displays result of python profiling"""

#------------------------------------------------------------------------
# Library packages

# Standard packages
import sys
import pstats

# Local packages
from mezcla import debug
## OLD: from tpo_common import *
from mezcla.system import getenv_text, print_stderr

## OLD: PROFILE_KEY = getenv_text("PROFILE_KEY", "cumulative")
PROFILE_KEY = getenv_text("PROFILE_KEY", "cumulative",
                          "Sort key (e.g., calls, cumulative, file, time)")

#------------------------------------------------------------------------
# Functions

def usage():
    """Displays usage notes for script"""
    print_stderr("""

Usage: {program} profile-log

Notes:
- use PROFILE_KEY to over default sorting (cumulative)
- main keys: 
       calls, cumulative, file, time
- other keys: 
       module, pcalls, line, name, nfl, stdname
- 2.7+ keys: 
       cumtime, filename, ncalls, tottime
- unfortunately, memory profiling is not supported
- see http://docs.python.org/3/library/profile.html

Example (assumes bash):
    $ python -m cProfile -o profile.log fubar.py
    $ PROFILE_KEY=calls {program} profile.log

""".format(program=sys.argv[0]))
    return
                

def main():
    """Entry point for script"""
    debug.trace_fmt(5, "main(): args={v}", v=sys.argv)
    if ((len(sys.argv) < 2) or (sys.argv[1] == "--help")):
        usage()
        sys.exit()
    file = sys.argv[1]

    # Generate listing and sort by cumulative time
    p = pstats.Stats(file)
    p.strip_dirs().sort_stats(PROFILE_KEY).print_stats()
    return

#------------------------------------------------------------------------

if __name__ == '__main__':
    main()
