#! /usr/bin/env python
#
# Tests for encoding_tools.py module


"""Test encoding_tools.py module"""


# Standart packages
import unittest


# Local packages
from mezcla.unittest_wrapper import TestWrapper
from mezcla import glue_helpers as gh


class TestIt(TestWrapper):
    """Class for testcase definition"""
    script_module = TestWrapper.derive_tested_module_name(__file__) + '.py'


    def test_show_unicode_info(self):
        """Test for show_unicode_info"""
        input_string    = 'Tomás'
        expected_result = ('char\tord\toffset\tencoding\n'
                           'Tomás: 5\n'
                           'T\t0054\t0\t54\n'
                           'o\t006F\t1\t6f\n'
                           'm\t006D\t2\t6d\n'
                           'á\t00E1\t3\tc3a1\n'
                           's\t0073\t5\t73\n')
        self.assertEqual(gh.run(f'echo "{input_string}" | {self.script_module} --show-unicode-info'), expected_result)


    def test_convert_unicode_control_chars(self):
        """test of conver unicode control chars"""
        input_string    = 'this is a tab: \t'
        expected_result = 'this is a tab: ␁'
        self.assertEqual(gh.run(f'echo "{input_string}" | {self.script_module} --show-control-chars'), expected_result)


if __name__ == '__main__':
    unittest.main()
