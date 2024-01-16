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
from mezcla import system

# Note: Two references are used for the module to be tested:
#    THE_MODULE:	                global module object
#    TestIt.script_module:              path to file
try:
    import tests.eval_condition as THE_MODULE
except:
    system.print_exception_info("loading eval_condition.py")
    THE_MODULE = None

class TestEvalCondition(TestWrapper):
    """Class for testcase definition"""
    script_module = TestWrapper.get_testing_module_name(__file__, THE_MODULE)

    @pytest.mark.xfail                   # TODO: remove xfail
    def test_stdin(self):
        """Make sure special variable stdin used properly in test"""
        debug.trace(4, "test_stdin()")
        system.write_lines(self.temp_file, ["l1", "l2"])
        # note: need to put expression in quotes due to special shell tokens (e.g., '<')
        output = self.run_script("'1 < len(stdin) < 7'",
                                 uses_stdin=True, data_file=self.temp_file)
        assert output == "True"
        output = self.run_script("'stdin == \"l1 l2\"'", data_file=self.temp_file)
        assert output == "False"

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
