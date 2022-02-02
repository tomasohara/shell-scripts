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


## TODO: use gh.resolve_path(SCRIPT) instead of relative path on string
SCRIPT = 'filenames.py'


class TestIt(TestWrapper):
    """Class for testcase definition"""
    script_module = TestWrapper.derive_tested_module_name(__file__) + '.py'


    def test_get_free_filename(self):
        """Test for get_free_filename(basename, separation)"""
        basename        =  '/tmp/testfilename.txt'
        separation      =  '-'
        expected_result = f'{basename}{separation}2'
        gh.run(f'touch {basename} {basename}{separation}1')
        self.assertEqual(gh.run(f'python {self.script_module} --free --base "{basename}" --sep "{separation}"'), expected_result)


    def test_get_name_with_date(self):
        """Test for get_name_with_date(filename)"""
        filename =  'log.txt'
        filepath = f'/tmp/{filename}'
        gh.run(f'touch {filepath}')
        self.assertTrue(re.search(f'{filename}\\.\\d\\d\\w\\w\\w\\d\\d', gh.run(f'python {self.script_module} --free-with-date --base {filepath}')))


    def test_rename_with_file_date(self):
        """Test for rename_with_file_date(basename, target='./', copy=False)"""
        filepath     = '/tmp/date_rename_test.txt'

        # Get expected new filename
        gh.run(f'touch {filepath}')
        new_filepath = gh.run(f'python {self.script_module} --free-with-date --base {filepath}')

        # Remove files from other runnings
        gh.run(f'rm {new_filepath}')

        # First test: without optional params
        gh.run(f'python {self.script_module} --rename --free-with-date --files {filepath}')
        self.assertTrue(gh.file_exists(new_filepath))

        # Second tests: copy param
        # WORK-IN-PROGRESS

        # Third test: target dir
        # WORK-IN-PROGRESS

        # Four test: multiple files
        # WORK-IN-PROGRESS


if __name__ == '__main__':
    unittest.main()
