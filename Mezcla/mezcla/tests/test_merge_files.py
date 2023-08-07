#! /usr/bin/env python
#
# Test(s) for ../merge_files.py
#
# Notes:
# - For debugging the tested script, the ALLOW_SUBCOMMAND_TRACING environment
#   option shows tracing output normally suppressed by  unittest_wrapper.py.
# - This can be run as follows:
#   $ PYTHONPATH=".:$PYTHONPATH" python ./mezcla/tests/test_merge_files.py
#

"""Tests for merge_files module"""

# Standard packages
import re

# Installed packages
import pytest

# Local packages
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla import system
from mezcla.unittest_wrapper import TestWrapper

# Note: Two references are used for the module to be tested:
#    THE_MODULE:	    global module object
import mezcla.merge_files as THE_MODULE

class TestMergeFiles(TestWrapper):
    """Class for testcase definition"""
    script_file = TestWrapper.get_module_file_path(__file__)
    script_module = TestWrapper.get_testing_module_name(__file__)
    use_temp_base_dir = True            # treat TEMP_BASE as directory

    @pytest.mark.xfail
    def test_get_timestamp(self):
        """Ensure get_timestamp works as expected"""
        debug.trace(4, f"test_get_timestamp(); self={self}")
        lsb_date = gh.run('date +%F -r /proc/fb').strip().split('-')
        lts_year = lsb_date[0]
        lts_month = lsb_date[1]
        assert re.search(fr"({lts_year})-{lts_month}-\d\d \d\d:\d\d:\d\d", THE_MODULE.get_timestamp("/proc/fb"))

    def test_get_numeric_timestamp(self):
        """Ensure get_numeric_timestamp works as expected"""
        debug.trace(4, f"test_get_numeric_timestamp(); self={self}")
        # Note: /tmp should be newer than /etc
        first_timestamp = THE_MODULE.get_numeric_timestamp("/etc")
        second_timestamp = THE_MODULE.get_numeric_timestamp("/tmp")
        assert first_timestamp is not None
        assert second_timestamp is not None
        assert first_timestamp < second_timestamp

    @pytest.mark.xfail
    def test_simple_merge(self):
        """Make sure simple merge works"""
        debug.trace(4, "test_simple_merge()")
        tmp = self.temp_base
        system.write_lines(f"{tmp}/1.list", list(map(str, [0, 1, 2, 3])))
        gh.full_mkdir(f"{tmp}/backup")
        system.write_lines(f"{tmp}/backup/1.list", list(map(str, ['1', '2', '3'])))
        system.write_lines(f"{tmp}/other-1.list", list(map(str, ['1', '2', '3', '4'])))
        actual = self.run_script(
            env_options="IGNORE_TIMESTAMP=1",
            uses_stdin=True,
            data_file="",
            options=f"{tmp}/1.list {tmp}/other-1.list",
            )
        assert actual.split() == "0 1 2 3 4".split()

if __name__ == '__main__':
    debug.trace_current_context()
    pytest.main([__file__])
