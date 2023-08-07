#! /usr/bin/env python
#
# Test(s) for ../os_utils.py
#
# Notes:
# - For debugging the tested script, the ALLOW_SUBCOMMAND_TRACING environment
#   option shows tracing output normally suppressed by  unittest_wrapper.py.
# - This can be run as follows:
#   $ PYTHONPATH=".:$PYTHONPATH" python ./mezcla/tests/test_os_utils.py
#

"""Tests for os_utils module"""

# Standard packages
## NOTE: this is empty for now

# Installed packages
import pytest

# Local packages
from mezcla import debug
from mezcla import os_utils

# Note: Two references are used for the module to be tested:
#    THE_MODULE:	    global module object
## TODO: import mezcla.os_utils as THE_MODULE

class TestOsUtils:
    """Class for testcase definition"""

    def test_split_extension(self):
        """Ensure test_split_extension works as expected"""
        assert(os_utils.split_extension("fubar.txt") == ("fubar", ".txt"))


if __name__ == '__main__':
    debug.trace_current_context()
    pytest.main([__file__])
