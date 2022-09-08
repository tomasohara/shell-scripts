#! /usr/bin/env python
#
# Tests for numeric_tools module


"""Test numeric_tools module"""


# Standard packages
import unittest
import sys

# Installed packages
## NOTE: this is empty for now

# Local packages
from mezcla.unittest_wrapper import TestWrapper
from mezcla import glue_helpers as gh

sys.path.append('..')
# Note: Two references are used for the module to be tested:
#    THE_MODULE:	    global module object
#    TestIt.script_module   string name
import numeric_tools as THE_MODULE


class TestIt(TestWrapper):
    """Class for testcase definition"""
    script_module = TestWrapper.derive_tested_module_name(__file__) + '.py'

    def test_hex2dec(self):
        """test hex2dec"""
        input_value     = '287a'
        expected_result = 10362
        self.assertEqual(gh.run(f'python {self.script_module} --hex2dec {input_value}'), str(expected_result))
        self.assertEqual(gh.run(f'echo {input_value} | {self.script_module} --hex2dec'), str(expected_result))
        self.assertEqual(THE_MODULE.hex2dec(input_value), expected_result)

    def test_dec2hex(self):
        """test dec2hex"""
        input_value     = 28291
        expected_result = '6e83'
        self.assertEqual(gh.run(f'python {self.script_module} --dec2hex {input_value}'), expected_result)
        self.assertEqual(gh.run(f'echo {input_value} | {self.script_module} --dec2hex'), expected_result)
        self.assertEqual(THE_MODULE.dec2hex(input_value), expected_result)

    def test_bin2dec(self):
        """test bin2dec"""
        input_value     = 1011110101
        expected_result = 757
        self.assertEqual(gh.run(f'python {self.script_module} --bin2dec {input_value}'), str(expected_result))
        self.assertEqual(gh.run(f'echo {input_value} | {self.script_module} --bin2dec'), str(expected_result))
        self.assertEqual(THE_MODULE.bin2dec(input_value), expected_result)

    def test_dec2bin(self):
        """test dec2bin"""
        input_value     = 89922
        expected_result = 10101111101000010
        self.assertEqual(gh.run(f'python {self.script_module} --dec2bin {input_value}'), str(expected_result))
        self.assertEqual(gh.run(f'echo {input_value} | {self.script_module} --dec2bin'), str(expected_result))
        self.assertEqual(THE_MODULE.dec2bin(input_value), expected_result)

    def test_format_bytes(self):
        """test format bytes"""
        self.assertEqual(THE_MODULE.format_bytes(1024), (1, 'K'))
        self.assertEqual(THE_MODULE.format_bytes(1572864), (1.5, 'M'))
        self.assertEqual(THE_MODULE.format_bytes(1073741824), (1, 'G'))

    def test_apply_suffixes(self):
        """test apply suffixes"""
        input_string               = '1024 1572864 1073741824'
        full_expected_result       = '1.0K 1.5M 1.0G'
        only_first_expected_result = '1.0K 1572864 1073741824'
        self.assertEqual(gh.run(f'echo "{input_string}" | {self.script_module} --suffix'), full_expected_result)
        self.assertEqual(gh.run(f'echo "{input_string}" | {self.script_module} --suffix-first'), only_first_expected_result)
        self.assertEqual(THE_MODULE.apply_suffixes(input_string), full_expected_result)

    def test_apply_usage_suffixes(self):
        """test apply usage suffixes"""
        input_string    = '1 1572864 1073741824'
        expected_result = '1.0K 1572864 1073741824'
        self.assertEqual(gh.run(f'echo "{input_string}" | {self.script_module} --usage-suffix'), expected_result)

    def test_comma_ize_number(self):
        """test comma ize number option"""        
        self.assertEqual(gh.run(f'echo 2520878057 | {self.script_module} --comma-ize'), '2,520,878,057')
        self.assertEqual(gh.run(f'echo _1234_ | {self.script_module} --comma-ize'), '_1,234_')


if __name__ == '__main__':
    unittest.main()
