#! /usr/bin/env python
#
# TODO: Test(s) for ../jupyter_to_batspp.py
#
# Note:
# - For debugging the tested script, the ALLOW_SUBCOMMAND_TRACING environment
#   option shows tracing output normally suppressed by unittest_wrapper.py.
# - This can be run as follows:
#   $ PYTHONPATH=".:$PYTHONPATH" python .tests/test_jupyter_to_batspp.py
#
#--------------------------------------------------------------------------------
# Sample input for testing (excerpted from dummy-test.ipynb):
#
#   {
#    "cells": [
#     {
#      "cell_type": "code",
#      "outputs": [],
#      "source": [
#       "# Dummy test for debugging purposes\n",
#       "# For use with BatsPP."
#      ]
#     },
#     {
#      "cell_type": "code",
#      "outputs": [
#       {
#        "name": "stdout",
#        "output_type": "stream",
#        "text": [
#         "dummy\n"
#        ]
#       }
#      ],
#      "source": [
#       "# This test will pass\n",
#       "echo dummy"
#      ]
#     },
#     {
#      "cell_type": "code",
#      "outputs": [
#       {
#        "name": "stdout",
#        "output_type": "stream",
#        "text": [
#         "Sun Aug  6 11:08:23 PM +0545 2023\n"
#        ]
#       }
#      ],
#      "source": [
#       "# This test will fail: the time will be different when tested\n",
#       "date"
#      ]
#     }
#    ],
#    "metadata": {
#     ...
#   }
#
#
#................................................................................
# Sample output:
#
#   # Dummy test for debugging purposes
#   # For use with BatsPP.
#   
#   # This test will pass
#   $ echo dummy
#   dummy
#   
#   # This test will fail: the time will be different when tested
#   $ date
#   Wed Jun 21 06:30:51 CDT 2023
#

"""Tests for jupyter_to_batspp module"""

# Standard packages
import json

# Installed packages
import pytest

# Local packages
from mezcla.unittest_wrapper import TestWrapper
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.my_regex import my_re
from mezcla import system

# Note: Two references are used for the module to be tested:
#    THE_MODULE:                  global module object
#    TestTemplate.script_module:  path to file
import jupyter_to_batspp as THE_MODULE
#
# Note: sanity test for customization (TODO: remove if desired)
if not my_re.search(__file__, r"\btemplate.py$"):
    debug.assertion("mezcla.template" not in str(THE_MODULE))


# Constants
DUMMY_TEST = "dummy-test.ipynb"

class TestIt(TestWrapper):
    """Class for command-line based testcase definition"""
    script_module = TestWrapper.get_testing_module_name(__file__, THE_MODULE)
    data_file = gh.resolve_path(DUMMY_TEST)
    #
    # TODO: use_temp_base_dir = True            # treat TEMP_BASE as directory
    # note: temp_file defined by parent (along with script_module, temp_base, and test_num)

    @pytest.mark.xfail                   # TODO: remove xfail
    def test_valid_notebook(self):
        """Make sure valid json file"""
        debug.trace(4, f"TestIt.test_valid_notebook(); self={self}")

        notebook = {}
        try:
            notebook = json.loads(system.read_file(self.data_file))
        except:
            assert False, f"Notebook {self.data_file} should be in json format"
        assert "cells" in notebook
        assert "metadata" in notebook
        return


    @pytest.mark.xfail                   # TODO: remove xfail
    def test_data_file(self):
        """Makes sure dummy-test converted as expected"""
        debug.trace(4, f"TestIt.test_data_file(); self={self}")
        output = self.run_script(options="--stdout", data_file=self.data_file)
        assert not(my_re.search(r"cell_type|outputs|source|metadata", output))
        assert not(my_re.search(r"[\[\{\}\]]", output))
        assert my_re.search(r"^dummy$", output.strip(), flags=my_re.MULTILINE)
        assert my_re.search(r"^\$ date$", output.strip(), flags=my_re.MULTILINE)
        return

#------------------------------------------------------------------------

if __name__ == '__main__':
    debug.trace_current_context()
    pytest.main([__file__])
