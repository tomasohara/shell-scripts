#! /usr/bin/env python
#
# Tests for filenames.py module


"""Test filenames.py module"""


# Standart packages
import unittest
import re


# Local packages
from mezcla.unittest_wrapper import TestWrapper
from mezcla import glue_helpers as gh


class TestIt(TestWrapper):
    """Class for testcase definition"""
    script_module = TestWrapper.derive_tested_module_name(__file__) + '.py'
    maxDiff       = None


    def test_get_free_filename(self):
        """Test for get_free_filename(basename, separation)"""
        basename        =  self.temp_file
        separation      =  '-'
        expected_result = f'{basename}{separation}2'
        gh.run(f'touch {basename} {basename}{separation}1')
        self.assertEqual(gh.run(f'python {self.script_module} --free --base "{basename}" --sep "{separation}"'), expected_result)


    def test_get_name_with_date(self):
        """Test for get_name_with_date(filename)"""
        gh.run(f'touch {self.temp_file}')
        self.assertTrue(re.search(f'{self.temp_file}\\.\\d\\d\\w\\w\\w\\d\\d', gh.run(f'python {self.script_module} --free-with-date --base {self.temp_file}')))


    def test_rename_with_file_date(self):
        """Test for rename_with_file_date(basename, target='./', copy=False)"""

        # Get expected new filename
        gh.run(f'touch {self.temp_file}')
        new_filepath = gh.run(f'python {self.script_module} --free-with-date --base {self.temp_file}')

        # First test: without optional params
        gh.run(f'python {self.script_module} --rename --free-with-date {self.temp_file}')
        self.assertTrue(gh.file_exists(new_filepath))

        # Second tests: copy param
        ## WORK-IN-PROGRESS

        # Third test: target dir
        ## WORK-IN-PROGRESS


    def test_multiple_files(self):
        """Test with multiples filenames input"""
        ## WORK-IN-PROGRESS


    def test_stdin_input(self):
        """Test input via STDIN"""
        ## WORK-IN-PROGRESS


if __name__ == '__main__':
    unittest.main()
