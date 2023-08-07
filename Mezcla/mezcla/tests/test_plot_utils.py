#! /usr/bin/env python
#
# Test(s) for ../plot_utils.py
#
# Notes:
# - For debugging the tested script, the ALLOW_SUBCOMMAND_TRACING environment
#   option shows tracing output normally suppressed by  unittest_wrapper.py.
# - This can be run as follows:
#   $ PYTHONPATH=".:$PYTHONPATH" python ./mezcla/tests/test_plot_utils.py
#

"""Tests for plot_utils module"""

# Standard packages
## NOTE: this is empty for now

# Installed packages
import pytest

# Local packages
from mezcla import debug

# Note: Two references are used for the module to be tested:
#    THE_MODULE:	    global module object
import mezcla.plot_utils as THE_MODULE

class TestPlotUtils:
    """Class for testcase definition"""

    @pytest.mark.skip
    def test_something(self):
        """TODO: flesh out test for something"""
        debug.trace(4, "TestIt.test_something()")
        assert False
        return

    @pytest.mark.xfail
    def test_something_else(self):
        """TODO: flesh out test for something else"""
        debug.trace(4, "TestIt.test_something_else()")
        assert False
        return

if __name__ == '__main__':
    debug.trace_current_context()
    pytest.main([__file__])
