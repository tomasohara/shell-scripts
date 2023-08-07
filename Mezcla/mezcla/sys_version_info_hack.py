#! /usr/bin/env python
#
# sys_version_info_hack.py: hack for redefining sys.version_info to be python3 compatible
#
# python3:
# >>> sys.version_info
# sys.version_info(major=3, minor=6, micro=5, releaselevel='final', serial=0)
# >>> type(sys.version_info)
# <class 'sys.version_info'>
#
# python2 (pre 2.7):
# In [11]: sys.version_info
# Out[11]: (2, 6, 7, 'final', 0)
# In [12]: type(sys.version_info)
# Out[12]: tuple
#
# usage:
#    import sys_version_info_hack
#

"""Redefines sys.version_info to be python3 compatible"""

# Standard packages
import os
import re
import sys

# Installed packages
# n/a

# Local packages
# None (since most rely upon debug.py)
## OLD: import debug


if sys.version_info[0] < 3:
    
    SYS_VERSION_INFO_OLD = sys.version_info
    
    class sys_version_info(object):
        """Class to mimic Python3 version_info"""
    
        def __init__(self, major=SYS_VERSION_INFO_OLD[0],
                     minor=SYS_VERSION_INFO_OLD[1],
                     micro=SYS_VERSION_INFO_OLD[2],
                     releaselevel=SYS_VERSION_INFO_OLD[3],
                     serial=SYS_VERSION_INFO_OLD[4]):
            """Constructor"""
            self.sys_version_info_old = SYS_VERSION_INFO_OLD
            self.major = major
            self.minor = minor
            self.micro = micro
            self.releaselevel = releaselevel
            self.serial = serial
    
        def __getitem__(self, index):
            """Return old-style INDEX into sys.version_info"""
            return  self.sys_version_info_old[index]
    
    # Replace old-style sys.version_info with new-style
    ## OLD: if isinstance(sys.version_info, tuple):
    if type(sys.version_info) == tuple:   # pylint: disable=unidiomatic-typecheck
        ## OLD: debug.trace(4, "Warning: replacing sys version_info w/ python3-like version")
        if re.match(r"[1-9]+", os.environ.get("DEBUG_LEVEL")):
            sys.stderr.write("Warning: replacing sys version_info w/ python3-like version\n")
        sys.version_info = sys_version_info()

#-------------------------------------------------------------------------------

## OLD: def main(args):
def main(_args):
    """Supporting code for command-line processing"""
    ## OLD: debug.trace(2, "Warning: not intended for command-line use")
    sys.stderr.write("Warning: not intended for command-line use\n")

if __name__ == '__main__':
    main(sys.argv)
