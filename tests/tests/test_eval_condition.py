#! /usr/bin/env python
#
# Test(s) for ../eval_condition.py
#

"""Tests for eval_condition module"""

# Installed packages
import pytest

# Local packages
from mezcla.unittest_wrapper import TestWrapper
from mezcla import debug

# Note: Two references are used for the module to be tested:
#    THE_MODULE:	    global module object
## TODO: template => new name
import eval_condition as THE_MODULE


class TestEvalCondition(TestWrapper):
    """Class for testcase definition"""
    script_file = TestWrapper.get_module_file_path(__file__)
    script_module = TestWrapper.get_testing_module_name(__file__)

    def test_eval_true(self):
        """Make sure eval_condition() returns True"""
        debug.trace(4, "test_eval_true()")
        assert THE_MODULE.CondEval().eval_condition("2+2==4")

    def test_eval_false(self):
        """Make sure eval_condition() returns False"""
        debug.trace(4, "test_eval_false()")
        assert not THE_MODULE.CondEval().eval_condition("2+2==5")

    def test_eval_exception(self):
        """Make sure eval_condition() returns None"""
        debug.trace(4, "test_eval_exception()")
        assert THE_MODULE.CondEval().eval_condition("2+2=4") is None

#------------------------------------------------------------------------

if __name__ == '__main__':
    debug.trace_current_context()
    pytest.main([__file__])
