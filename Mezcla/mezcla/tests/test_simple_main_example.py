#! /usr/bin/env python
#
# Test(s) for ../test_simple_main_example.py
#
# Notes:
# - For debugging the tested script, the ALLOW_SUBCOMMAND_TRACING environment
#   option shows tracing output normally suppressed by  unittest_wrapper.py.
# - This can be run as follows:
#   $ PYTHONPATH=".:$PYTHONPATH" python ./mezcla/tests/test_simple_main_example.py
#

"""Tests for simple_main_example module"""

# Standard packages
## NOTE: this is empty for now

# Installed packages
import pytest

# Local packages
from mezcla import debug

# Note: Two references are used for the module to be tested:
#    THE_MODULE:	    global module object
import mezcla.simple_main_example as THE_MODULE

class TestSimpleMainExample:
    """Class for testcase definition"""

    @pytest.mark.xfail
    def test_whatever(self):
        assert(False)


if __name__ == '__main__':
    debug.trace_current_context()
    pytest.main([__file__])
