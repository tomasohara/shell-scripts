#! /usr/bin/env python
#
# Test(s) for ../python_ast.py
#
# Notes:
# - Fill out TODO's below. Use numbered tests to order (e.g., test_1_usage).
# - TODO: If any of the setup/cleanup methods defined, make sure to invoke base
#   (see examples below for setUp and tearDown).
# - For debugging the tested script, the ALLOW_SUBCOMMAND_TRACING environment
#   option shows tracing output normally suppressed by unittest_wrapper.py.
# - This can be run as follows:
#   $ PYTHONPATH=".:$PYTHONPATH" python ./mezcla/tests/test_python_ast.py
#

"""Tests for python_ast module"""

# Standard packages
## TODO: from collections import defaultdict

# Installed packages
import pytest

# Local packages
from mezcla.unittest_wrapper import TestWrapper
from mezcla import debug
from mezcla.my_regex import my_re
from mezcla import system

# Note: Two references are used for the module to be tested:
#    THE_MODULE:                  global module object
#    TestTemplate.script_module:  path to file
import mezcla.python_ast as THE_MODULE


class TestIt(TestWrapper):
    """Class for command-line based testcase definition"""
    script_module = TestWrapper.get_testing_module_name(__file__, THE_MODULE)

    def test_data_file(self):
        """Makes sure comparison converted uainf Compare nodes"""
        debug.trace(4, f"TestIt.test_data_file(); self={self}")
        data = ["2 + 2 == 4"]
        system.write_lines(self.temp_file, data)
        output = self.run_script(options="", data_file=self.temp_file)
        assert my_re.search(r"Compare", output.strip())
        return


class TestIt2:
    """Class for API-based testcase definition"""

    def test_comment_drop(self):
        """Test for comments being dropped"""
        debug.trace(4, f"TestIt2.test_whatever(); self={self}")
        source_code = "print('Hello world')    # ye olde hello world"
        ast = THE_MODULE.PythonAST()
        ast.parse(source_code)
        assert "olde" not in ast.dump()
        return
 

#------------------------------------------------------------------------

if __name__ == '__main__':
    debug.trace_current_context()
    pytest.main([__file__])
