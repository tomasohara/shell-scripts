#! /usr/bin/env python
#
# Tests for find_files module


"""Test find_files module"""


# Standard packages
import unittest
import re

# Installed packages
## NOTE: this is empty for now

# Local packages
from mezcla.unittest_wrapper import TestWrapper
from mezcla import glue_helpers as gh


class TestIt(TestWrapper):
    """Class for testcase definition"""
    script_module     = TestWrapper.derive_tested_module_name(__file__) + '.py'


    def test_find_files(self):
        """Test for find_files option"""
        use_temp_base_dir = True

        # Setup test folders and files
        foldernames = [self.temp_base, f'{self.temp_base}/another_folder']
        filenames  = ['arrows.bash', 'numeric.py', 'calc_entropy.c']

        for folder in foldernames:
            gh.run(f'mkdir {folder}')
            for filename in filenames:
                gh.run(f'touch {folder}/{filename}')

        # Run twice to test the backup folder
        result = ''
        for _ in range(2):
            result = gh.run(f'python {self.script_module} --find-files {self.temp_base}').split('\n')

        # Check output
        self.assertEqual(len(result), 4)

        for line in result:
            self.assertTrue(bool(re.search(r"[drwx-]+\s+\d+\s+\w+\s+\w+\s+\d+\s+\w+\s+\d+\s+\d\d:\d\d\s+[\w/]+", line)))

        # Setup expected new files
        new_long_file  = 'ls-R.list'
        new_short_file = 'ls-alR.list'

        expected_new_files  = [new_long_file, new_short_file]
        expected_new_files += [new_file + '.log' for new_file in expected_new_files]
        expected_new_files += ['backup' + new_file + '.' for new_file in expected_new_files]

        # Check if new files exist
        file_list = gh.run(f'ls -R {self.temp_base}')

        for expected_file in expected_new_files:
            expected_file = expected_file.replace('backup/', '')
            self.assertTrue(filename in file_list)

        # Check content of created files
        for new_file in expected_new_files:
            if '.log' not in new_file:
                for line in gh.run(f'cat {self.temp_base}/{filename}'):
                    self.assertTrue(bool(re.search(r"[drwx-]+\s+\d+\s+\w+\s+\w+\s+\d+\s+\w+\s+\d+\s+\d\d:\d\d\s+[\w/]+", line)))


if __name__ == '__main__':
    unittest.main()
