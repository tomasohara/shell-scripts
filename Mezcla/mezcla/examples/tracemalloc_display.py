#! /usr/bin/env python
#
# Based on following:
#   https://stackoverflow.com/questions/552744/how-do-i-profile-memory-usage-in-python
#
# TODO:
# - Add muiltithreading support.
#

"""Illustration of tracemalloc module (for reading word list)"""

# Standard modules
from collections import Counter
import linecache
import os
import tracemalloc

# Local modules
from mezcla import debug
from mezcla.main import Main
from mezcla import system

NUM_ITEMS = system.getenv_int("NUM_ITEMS", 10,
                              "Number ot items to display")
PREFIX_LEN = system.getenv_int("PREFIX_LEN", 3,
                               "Prefix length for item display")
WORDLIST_FILE = system.getenv_text("WORDLIST_FILE", "/usr/share/dict/american-english",
                                   "File with word list")

class TraceMalloc:
    """Wrapper class around tracemalloc"""

    def __init__(self, limit=None):
        """Class intiializer"""
        debug.trace(4, "TraceMalloc.__init__()")
        self.snapshot = None
        self.limit = limit
        tracemalloc.start()
    
    
    def display_top(self, key_type=None, limit=None):
        """Show top usages"""
        debug.trace(4, f"TraceMallocdisplay_top([{key_type}, {limit}])")
        if key_type is None:
            key_type = 'lineno'
        if limit is None:
            limit = (self.limit or NUM_ITEMS)
        snapshot = self.snapshot.filter_traces((
            tracemalloc.Filter(False, "<frozen importlib._bootstrap>"),
            tracemalloc.Filter(False, "<unknown>"),
        ))
        top_stats = snapshot.statistics(key_type)
    
        print("Top %s memory allocations" % limit)
        for index, stat in enumerate(top_stats[:limit], 1):
            frame = stat.traceback[0]
            # replace "/path/to/module/file.py" with "module/file.py"
            filename = os.sep.join(frame.filename.split(os.sep)[-2:])
            print("#%s: %s:%s: %.1f KiB"
                  % (index, filename, frame.lineno, stat.size / 1024))
            line = linecache.getline(frame.filename, frame.lineno).strip()
            if line:
                print('    %s' % line)
    
        other = top_stats[limit:]
        if other:
            size = sum(stat.size for stat in other)
            print("%s other: %.1f KiB" % (len(other), size / 1024))
        total = sum(stat.size for stat in top_stats)
        print("Total allocated size: %.1f KiB" % (total / 1024))

    def take_snapshot(self):
        """Take snapshot or memory usage"""
        self.snapshot = tracemalloc.take_snapshot()
    
    def display(self, limit=None):
        """Display current snapshot"""
        debug.trace(3, "TraceMalloc.display()")

        if not self.snapshot:
            self.take_snapshot()
        self.display_top(limit=limit)

#-------------------------------------------------------------------------------
        
def main():
    """Entry point for script"""
    debug.trace(4, "main()")

    # Show simple usage if --help given
    dummy_app = Main(description=__doc__, skip_input=False, manual_input=False)
    debug.assertion(dummy_app.parsed_args)

    trace_malloc = TraceMalloc(limit=NUM_ITEMS)
    
    counts = Counter()
    fname = WORDLIST_FILE
    with system.open_file(fname) as wordlist_file:
        words = list(wordlist_file)
        for word in words:
            prefix = word[:PREFIX_LEN]
            counts[prefix] += 1
    print('Top prefixes:', counts.most_common(3))

    trace_malloc.display()
    
#-------------------------------------------------------------------------------

if __name__ == '__main__':
    main()
