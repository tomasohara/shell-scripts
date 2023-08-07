#! /usr/bin/env python
#
# Test(s) for ../cut.py
#
# Notes:
# - For debugging the tested script, the ALLOW_SUBCOMMAND_TRACING environment
#   option shows tracing output normally suppressed by  unittest_wrapper.py.
# - This can be run as follows:
#   $ PYTHONPATH=".:$PYTHONPATH" python ./mezcla/tests/test_cut.py
#

"""Tests for cut module"""

# Standard packages
## NOTE: this is empty for now

# Installed packages
import pytest

# Local packages
from mezcla import debug
from mezcla.unittest_wrapper import TestWrapper
from mezcla import glue_helpers as gh

# Note: Two references are used for the module to be tested:
#    THE_MODULE:	    global module object
import mezcla.cut as THE_MODULE

# Constants
RESOURCES = f'{gh.dir_path(__file__)}/resources'
CSV_EXAMPLE = f'{RESOURCES}/cars.csv'
TSV_EXAMPLE = f'{RESOURCES}/cars.tsv'
CUTTED_TSV_LEN_3 = f'{RESOURCES}/cars-tsv-len-3.txt'
CUTTED_CSV_LEN_3 = f'{RESOURCES}/cars-csv-len-3.txt'
FIELDS_2_3_4 = f'{RESOURCES}/cars-fields-2-3-4.txt'

class TestCutUtils:
    """Class for testcase definition"""

    def test_elide_values(self):
        """Ensure elide_values works as expected"""
        debug.trace(4, "elide_values()")
        assert THE_MODULE.elide_values(["1234567890", 1234567890, True, False], max_len=4) == ["1234...", "1234...", "True", "Fals..."]

    def test_flatten_list_of_strings(self):
        """Ensure flatten_list_of_strings works as expected"""
        debug.trace(4, "test_flatten_list_of_strings()")
        assert THE_MODULE.flatten_list_of_strings([["l1i1", "l1i2"], ["l2i1"]]) == ["l1i1", "l1i2", "l2i1"]

class TestCutScript(TestWrapper):
    """Class for testcase definition"""
    script_file = TestWrapper.get_module_file_path(__file__)
    script_module = TestWrapper.get_testing_module_name(__file__)

    def test_cut_csv(self):
        """Ensure csv files are cutted as expected"""
        script_output = self.run_script(options='--csv --max-field-len 3', data_file=CSV_EXAMPLE)
        assert script_output
        assert script_output + '\n' == gh.read_file(CUTTED_CSV_LEN_3)

    def test_cut_tsv(self):
        """Ensure tsv files are cutted as expected"""
        script_output = self.run_script(options='--tsv --max-field-len 3', data_file=TSV_EXAMPLE)
        assert script_output
        assert script_output + '\n' == gh.read_file(CUTTED_TSV_LEN_3)

    def test_fields(self):
        """Ensure fields parameter works as expected"""
        script_output = self.run_script(options='--csv --fields 2-4', data_file=CSV_EXAMPLE)
        assert script_output
        assert script_output + '\n' == gh.read_file(FIELDS_2_3_4)
        script_output = self.run_script(options='--csv --fields 2,3,4', data_file=CSV_EXAMPLE)
        assert script_output
        assert script_output + '\n' == gh.read_file(FIELDS_2_3_4)


if __name__ == '__main__':
    debug.trace_current_context()
    pytest.main([__file__])
