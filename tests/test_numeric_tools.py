#! /usr/bin/env python
#
# Tests for numeric_tools.py module


"""Test numeric_tools.py module"""


# Standart packages
import unittest
import sys


# Local packages
from mezcla.unittest_wrapper import TestWrapper
from mezcla import glue_helpers as gh


# On test package
sys.path.append('..')
import numeric_tools


class TestIt(TestWrapper):
    """Class for testcase definition"""
    script_module = TestWrapper.derive_tested_module_name(__file__) + '.py'


    def test_hex2dec(self):
        """test hex2dec"""
        input_value     = '287a'
        expected_result = 10362
        self.assertEqual(gh.run(f'python {self.script_module} --hex2dec {input_value}'), str(expected_result))
        self.assertEqual(gh.run(f'echo {input_value} | {self.script_module} --hex2dec'), str(expected_result))
        self.assertEqual(numeric_tools.hex2dec(input_value), expected_result)


    def test_dec2hex(self):
        """test dec2hex"""
        input_value     = 28291
        expected_result = '6e83'
        self.assertEqual(gh.run(f'python {self.script_module} --dec2hex {input_value}'), expected_result)
        self.assertEqual(gh.run(f'echo {input_value} | {self.script_module} --dec2hex'), expected_result)
        self.assertEqual(numeric_tools.dec2hex(input_value), expected_result)


    def test_bin2dec(self):
        """test bin2dec"""
        input_value     = 1011110101
        expected_result = 757
        self.assertEqual(gh.run(f'python {self.script_module} --bin2dec {input_value}'), str(expected_result))
        self.assertEqual(gh.run(f'echo {input_value} | {self.script_module} --bin2dec'), str(expected_result))
        self.assertEqual(numeric_tools.bin2dec(input_value), expected_result)


    def test_dec2bin(self):
        """test dec2bin"""
        input_value     = 89922
        expected_result = 10101111101000010
        self.assertEqual(gh.run(f'python {self.script_module} --dec2bin {input_value}'), str(expected_result))
        self.assertEqual(gh.run(f'echo {input_value} | {self.script_module} --dec2bin'), str(expected_result))
        self.assertEqual(numeric_tools.dec2bin(input_value), expected_result)


    def test_format_bytes(self):
        """test format bytes"""
        self.assertEqual(numeric_tools.format_bytes(1024), (1, 'K'))
        self.assertEqual(numeric_tools.format_bytes(1572864), (1.5, 'M'))
        self.assertEqual(numeric_tools.format_bytes(1073741824), (1, 'G'))


    def test_apply_suffixes(self):
        """test apply suffixes"""
        input_string               = '1024 1572864 1073741824'
        full_expected_result       = '1.0K 1.5M 1.0G'
        only_first_expected_result = '1.0K 1572864 1073741824'
        self.assertEqual(gh.run(f'echo "{input_string}" | {self.script_module} --suffix'), full_expected_result)
        self.assertEqual(gh.run(f'echo "{input_string}" | {self.script_module} --suffix-first'), only_first_expected_result)
        self.assertEqual(numeric_tools.apply_suffixes(input_string), full_expected_result)


    def test_apply_usage_suffixes(self):
        """test apply usage suffixes"""
        input_string    = '1 1572864 1073741824'
        expected_result = '1.0K 1572864 1073741824'
        self.assertEqual(gh.run(f'echo "{input_string}" | {self.script_module} --usage-suffix'), expected_result)


    def test_comma_ize_number(self):
        """test comma ize number option"""
        input_number    = '1234 987654321'
        expected_result = '1,234 987654,321'
        self.assertEqual(gh.run(f'echo "{input_number}" | {self.script_module} --comma-ize'), expected_result)


if __name__ == '__main__':
    unittest.main()
