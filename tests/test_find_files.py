#! /usr/bin/env python
#
# Tests for find_files.py module


"""Test find_files.py module"""


# Standart packages
import unittest
import re


# Local packages
from mezcla.unittest_wrapper import TestWrapper
from mezcla import glue_helpers as gh


class TestIt(TestWrapper):
    """Class for testcase definition"""
    script_module     = TestWrapper.derive_tested_module_name(__file__) + '.py'


    def test_find_files(self):
        """Test for find_files option"""

        # Setup test folders and files
        test_folder = gh.run('echo test-find-files-$$')
        foldernames = [test_folder, f'{test_folder}/another_folder']
        filenames  = ['arrows.bash', 'numeric.py', 'calc_entropy.c']

        for folder in foldernames:
            gh.run(f'mkdir /tmp/{folder}')
            for filename in filenames:
                gh.run(f'touch /tmp/{folder}/{filename}')

        # Run twice to test the backup folder
        result = ''
        for _ in range(2):
            result = gh.run(f'python {self.script_module} --find-files --path "/tmp/{test_folder}"').split('\n')

        # Check output
        self.assertEqual(len(result), 4)

        for line in result:
            self.assertTrue(bool(re.search(r"[drwx-]+\s+\d+\s+\w+\s+\w+\s+\d+\s+\w+\s+\d+\s+\d\d:\d\d\s+[\w/]+", line)))

        # Setup expected new files
        new_long_file  = 'ls-R.list'
        new_short_file = 'ls-alR.list'

        expected_new_files  = [new_long_file, new_short_file]
        expected_new_files += [new_file + '.log'         for new_file in expected_new_files]
        expected_new_files += ['backup' + new_file + '.' for new_file in expected_new_files]

        # Check if new files exist
        file_list = gh.run(f'ls -R /tmp/{test_folder}')

        for expected_file in expected_new_files:
            expected_file = expected_file.replace('backup/', '')
            self.assertTrue(filename in file_list)

        # Check content of created files
        for new_file in expected_new_files:
            if '.log' not in new_file:
                for line in gh.run(f'cat /tmp/{test_folder}/{filename}'):
                    self.assertTrue(bool(re.search(r"[drwx-]+\s+\d+\s+\w+\s+\w+\s+\d+\s+\w+\s+\d+\s+\d\d:\d\d\s+[\w/]+", line)))


if __name__ == '__main__':
    unittest.main()
