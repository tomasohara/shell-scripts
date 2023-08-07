#! /usr/bin/env python
#
# Based on following:
#   https://stackoverflow.com/questions/6317818/eat-memory-using-python
#

"""Consume all available memory"""

# Standard modules
import os
import psutil

# Local modules
from mezcla import debug
from mezcla import system

PROCESS = psutil.Process(os.getpid())
MEGA = 10 ** 6
MEGA_STR = ' ' * MEGA
GIGA = 10 ** 9

STR_INCR = system.getenv_int("STR_INCR", 10,
                             "Number of MB per increment for string method")
ARRAY_INCR = system.getenv_int("ARRAY_INCR", 1,
                               "Number of MB per increment for array method")

def pmem():
    """Show memory usage"""
    ## OLD: tot, avail, percent, used, free = psutil.virtual_memory()
    tot, avail, percent, used, free = tuple((list(psutil.virtual_memory()))[:5])
    tot, avail, used, free = tot / MEGA, avail / MEGA, used / MEGA, free / MEGA
    ## OLD: proc = PROCESS.get_memory_info()[1] / MEGA
    proc = PROCESS.memory_info()[1] / MEGA
    # pylint: disable=consider-using-f-string
    print('process = %s total = %s avail = %s used = %s free = %s percent = %s'
          % (proc, tot, avail, used, free, percent))

def alloc_max_array():
    """Consume memory using array append"""
    i = 0
    ar = []
    while True:
        debug.trace_expr(7, i)
        if (((i * ARRAY_INCR * MEGA) % GIGA) == 0):
            print(i)
        try:
            ## OLD: ar.append(MEGA_STR)  # no copy if reusing the same string!
            ## OLD: ar.append(ARRAY_INCR * MEGA_STR + str(i))
            ar.append(ARRAY_INCR * MEGA_STR + ' ')
        except MemoryError:
            break
        i += 1
    max_i = i - 1
    print('maximum array allocation:', max_i)
    pmem()

def alloc_max_str():
    """Consume memory using single string"""
    i = 0
    while True:
        debug.trace_expr(7, i)
        if (((i * STR_INCR * MEGA) % GIGA) == 0):
            print(i)
        try:
            a = ' ' * (i * STR_INCR * MEGA)
            del a
        except MemoryError:
            break
        i += 1
    max_i = i - 1
    _ = ' ' * (max_i * 10 * MEGA)
    print('maximum string allocation', max_i)
    pmem()

def main():
    """Entry poit for script"""
    print("initial")
    pmem()
    alloc_max_array()
    alloc_max_str()
    print("final")
    pmem()

#-------------------------------------------------------------------------------

if __name__ == '__main__':
    main()
