#! /usr/bin/env python
#
# Tests for tomohara-aliases.bash aliases
#
# NOTE: make sure that tomohara-aliases.bash
#       was previusly sourced.


"""Tests for tomohara-aliases.bash aliases"""


# Standart packages
import unittest


# Local packages
from mezcla.unittest_wrapper import TestWrapper
from mezcla import glue_helpers as gh


class TestIt(TestWrapper):
    """Class for testcase definition"""
    script_name = TestWrapper.derive_tested_module_name(__file__) + '.bash'


    def test_copy_with_file_date(self):
        """Test for copy-with-file-date alias"""

        filepath = gh.run('echo /tmp/copy-test-"$$".txt')

        # Create file
        gh.run(f'touch {filepath}')
        new_filepath = gh.run(f'python filenames.py --free-with-date --base {filepath}')

        # Run
        gh.run(f'copy-with-file-date {filepath}')
        self.assertTrue(new_filepath in gh.run(f'ls {new_filepath}')) # TODO: gh.file_exist() not working.


if __name__ == '__main__':
    unittest.main()
