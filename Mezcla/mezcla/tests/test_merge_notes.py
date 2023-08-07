#! /usr/bin/env python
#
# Test(s) for ../merge_notes.py
#
# Notes:
# - For debugging the tested script, the ALLOW_SUBCOMMAND_TRACING environment
#   option shows tracing output normally suppressed by  unittest_wrapper.py.
# - This can be run as follows:
#   $ PYTHONPATH=".:$PYTHONPATH" python ./mezcla/tests/test_merge_notes.py
#

"""Tests for merge_notes module"""

# Standard packages
## NOTE: this is empty for now

# Installed packages
import pytest
import datetime

# Local packages
from mezcla import debug

# Note: Two references are used for the module to be tested:
#    THE_MODULE:	    global module object
import mezcla.merge_notes as THE_MODULE

class TestMergeNotes:
    """Class for testcase definition"""

    def test_resolve_date(self):
        """Ensure resolve_date works as expected"""
        debug.trace(4, "test_resolve_date()")
        assert THE_MODULE.resolve_date("1 Jan 00") == datetime.datetime(2000, 1, 1, 0, 0)
        assert THE_MODULE.resolve_date("0 Jan 00", datetime.datetime(2000, 1, 1, 0, 0)) == datetime.datetime(2000, 1, 1, 0, 0)
        assert THE_MODULE.resolve_date("Sun 18 Jul 2021") == datetime.datetime(2021, 7, 18, 0, 0)

    ## TODO: test main script


if __name__ == '__main__':
    debug.trace_current_context()
    pytest.main([__file__])
