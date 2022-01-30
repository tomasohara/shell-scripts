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
        input_string    = 'test'
        expected_result = 'char\tord\toffset\tencoding\ntest: 4\nt\t0074\t0\t74\ne\t0065\t1\t65\ns\t0073\t2\t73\nt\t0074\t3\t74\n'
        self.assertEqual(gh.run(f'echo "{input_string}" | {self.script_module} --show-unicode-info'), expected_result)


    def test_convert_unicode_control_chars(self):
        """test of conver unicode control chars"""
        input_string    = 'this is a tab: \t'
        expected_result = 'this is a tab: ␁'
        self.assertEqual(gh.run(f'echo "{input_string}" | {self.script_module} --show-control-chars'), expected_result)


if __name__ == '__main__':
    unittest.main()
