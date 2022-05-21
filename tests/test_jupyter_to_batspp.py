#! /usr/bin/env python
#
# Tests for jupyter_to_batspp.py module
#


"""Tests for jupyter_to_batspp.py module"""


# Standard packages
import unittest


# Local packages
from mezcla.unittest_wrapper import TestWrapper
from mezcla import glue_helpers as gh
from mezcla import debug


class TestIt(TestWrapper):
    """Class for testcase definition"""
    script_module = TestWrapper.derive_tested_module_name(__file__) + '.py'
    maxDiff       = None


    def test_jupyter_to_batspp(self):
        """End test for jupiter_to_batspp.py"""
        debug.trace(4, 'test.test_jupyter_to_batspp()')

        expected = gh.read_file('./tests/samples/result_jupyter_to_batspp_test.batspp')
        ## TODO: add exception when expected is empty.

        expected += f'Resulting Batspp tests saved on {self.temp_file}.batspp'

        actual = gh.run(f'python3 {self.script_module} --output {self.temp_file}.batspp ./tests/samples/jupyter_batspp_test.ipynb')
        self.assertEqual(expected, actual)


if __name__ == '__main__':
    unittest.main()
