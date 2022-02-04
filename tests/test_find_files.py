#! /usr/bin/env python
#
# Tests for find_files.py module


"""Test find_files.py module"""


# Standart packages
import unittest


# Local packages
from mezcla.unittest_wrapper import TestWrapper
from mezcla import glue_helpers as gh


class TestIt(TestWrapper):
    """Class for testcase definition"""
    script_module     = TestWrapper.derive_tested_module_name(__file__) + '.py'


    def test_find_files(self):
        """Test for find_files option"""

        # Setup test folders and files
        foldernames = ['main_folder', 'main_folder/another_folder']
        filenames  = ['arrows.bash', 'numeric.py', 'calc_entropy.c']

        gh.run(f'rm -rf /tmp/{foldernames[0]}')

        for folder in foldernames:
            gh.run(f'mkdir /tmp/{folder}')
            for filename in filenames:
                gh.run(f'touch /tmp/{folder}/{filename}')
    
        # Run twice to test the backup folder
        for i in range(2):
            gh.run(f'python {self.script_module} --find-files --path "/tmp/{foldernames[0]}"')

        # Check for created files
        file_list = gh.run(f'ls -R /tmp/{foldernames[0]}')
        self.assertTrue('backup' in file_list)
        self.assertTrue('ls-R.list' in file_list)
        self.assertTrue('ls-alR.list' in file_list)
		# TODO: self.assertTrue('ls-R.list.log'in file_list)
        # TODO: self.assertTrue('ls-alR.list.log' in file_list)

        # Check content of created files
        # TODO: change number of words when the .log files are implemented
        self.assertEqual(gh.run(f'cat /tmp/{foldernames[0]}/ls-R.list | wc -m'), '350')
        self.assertEqual(gh.run(f'cat /tmp/{foldernames[0]}/backup/ls-R.list.* | wc -m'), '255')
        # TODO: check why drwxrwxr-x 0 on start of the file
		# self.assertEqual(gh.run(f'cat /tmp/{foldernames[0]}/ls-alR.list | wc -m'), '992')
        # self.assertEqual(gh.run(f'cat /tmp/{foldernames[0]}/backup/ls-alR.list.* | wc -m'), '703')


if __name__ == '__main__':
    unittest.main()
