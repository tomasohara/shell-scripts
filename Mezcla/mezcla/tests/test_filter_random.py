#! /usr/bin/env python
#
# Test(s) for ../filter_random.py
#
# Notes:
# - This can be run as follows:
#   $ PYTHONPATH=".:$PYTHONPATH" python ./mezcla/tests/test_filter_random.py
#
# TODO:
# - Use actual data file (e.g., license).
# - Add some more tests.
#

"""Tests for filter_random module"""

# Standard packages
## NOTE: this is empty for now

# Installed packages
import pytest

# Local packages
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.unittest_wrapper import TestWrapper
from mezcla import system

# Note: Two references are used for the module to be tested:
#    THE_MODULE:	    global module object
import mezcla.filter_random as THE_MODULE

class TestFilterRandom(TestWrapper):
    """Class for testcase definition"""
    script_file = TestWrapper.get_module_file_path(__file__)
    script_module = TestWrapper.derive_tested_module_name(__file__)
    use_temp_base_dir = True            # treat TEMP_BASE as directory

    def setUp(self):
        """Per-test setup"""
        debug.trace(6, f"TestFilterRandom.setUp(); self={self}")
        # note: must do parent first (e.g., for temp file support)
        super().setUp()
        num_lines = 10
        data = [str(i) for i in range(num_lines)]
        debug.assertion(self.temp_file)
        gh.write_lines(self.temp_file, data)
        return
    
    def run_data_file_test(self, ratio, data_file_path, expected_output):
        """Run script to include RATIO of DATA_FILE lines with EXPECTED_OUTPUT"""
        debug.trace(5, f"run_data_file_test({self}, {ratio}, {data_file_path}, {expected_output})")
        script_output = self.run_script(options=f"--ratio {ratio} --quiet --seed 13",
                                        data_file=data_file_path)
        actual_output = script_output.strip()
        expected_output = expected_output.strip()
        assert expected_output == actual_output
        return None

    def test_simple_data_file(self):
        """Makes sure simple canned data file works as expected"""
        debug.trace(4, f"TestFilterRandom.test_simple_data_file({self})")
        self.setUp()
        return self.run_data_file_test(0.15, self.temp_file, "6\n9\n")

    def test_filter_all(self):
        """Makes sure all lines are filtered out with ratio 0.0"""
        debug.trace(4, f"TestFilterRandom.test_filter_all({self})")
        self.setUp()
        return self.run_data_file_test(0.0, self.temp_file, "")

    def test_filter_none(self):
        """Makes sure no lines are filtered out with ratio 1.0"""
        debug.trace(4, f"TestFilterRandom.test_filter_none({self})")
        temp_file_contents = system.read_file(self.temp_file)
        self.setUp()
        return self.run_data_file_test(1.0, self.temp_file, temp_file_contents)

#------------------------------------------------------------------------

if __name__ == '__main__':
    debug.trace_current_context()
    pytest.main([__file__])
