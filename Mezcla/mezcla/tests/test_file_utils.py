#! /usr/bin/env python
#
# Test(s) for ../file_utils.py
#
# Notes:
# - This can be run as follows:
#   $ PYTHONPATH=".:$PYTHONPATH" python ./mezcla/tests/test_file_utils.py
#

"""Tests for file_utils module"""

# Standard packages
import json
import re

# Installed packages
import pytest

# Local packages
from mezcla.unittest_wrapper import TestWrapper
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla import system

# Note: Two references are used for the module to be tested:
#    THE_MODULE:	                global module object
#    TestTemplate.script_module:        path to file
import mezcla.file_utils as THE_MODULE

class TestFileUtils(TestWrapper):
    """Class for testcase definition"""
    script_module = TestWrapper.derive_tested_module_name(__file__)
    use_temp_base_dir = True

    def test_get_directory_listing(self):
        """
        Tests for get_directory_listing(path          = 'PATH',
                                        recursive     = False,
                                        long          = False,
                                        readable_size = False,
                                        return_string = True,
                                        make_unicode  = False)
        """

        # Setup files and folders
        folders     = [self.temp_base, gh.form_path(self.temp_base, 'other_folder')]
        filenames   = ['analize.py', 'debug.cpp', 'main.txt', 'misc_utils.perl']

        for foldername in folders:
            ## TODO3: use mezcla wrappers (e.g., gh.full_mkdir)
            gh.run(f'mkdir {foldername}')
            for filename in filenames:
                gh.run(f'touch {gh.form_path(foldername, filename)}')

        # Run Test
        list_result = THE_MODULE.get_directory_listing(f'{self.temp_base}', recursive=True, long=True, return_string=True)

        for line in list_result:
            assert bool(re.search(r"[drwx-]+\s+\d+\s+\w+\s+\w+\s+\d+\s+\w+\s+\d+\s+\d\d:\d\d\s+[\w/]+", line))

    def test_get_information(self):
        """Tests for def get_information(path,
                                         readable = False,
                                         return_string = False)
        """
        gh.run(f'touch {self.temp_file}')

        ls_result = gh.run(f'ls -l {self.temp_file}')
        ls_result = re.sub(r'\s+', ' ', ls_result)

        assert THE_MODULE.get_information(self.temp_file, return_string=True).lower() == ls_result.lower()

    def test_get_permissions(self):
        """Tests for get_permissions(path)"""

        # Setup
        test_file = gh.form_path(self.temp_base, 'some-file.cpp')
        gh.run(f'touch {test_file}')

        # Run
        assert THE_MODULE.get_permissions(test_file) == gh.run(f'ls -l {test_file}')[:10]
        assert THE_MODULE.get_permissions(self.temp_base) == gh.run(f'ls -ld {self.temp_base}')[:10]

    def test_get_modification_date(self):
        """Tests for get_modification_date(path)"""
        gh.run(f'touch {self.temp_file}')
        ls_date = gh.run(f'ls -l {self.temp_file}').lower()
        # Extract date
        ls_date = re.search(r'\w\w\w +\d\d? +\d\d:\d\d', ls_date).group()
        # Remove extra spaces
        ls_date = re.sub(r'\s+', ' ', ls_date)
        assert THE_MODULE.get_modification_date(self.temp_file, strftime='%b %-d %H:%M').lower() == ls_date

    def test_json_to_jsonl(self):
        """Tests for json_to_jsonl"""
        in_file = gh.form_path(self.temp_base, "some-file.json")
        out_file = gh.form_path(self.temp_base, "some-file.jsonl")
        sample_array = [1, 2, 3]
        system.write_file(in_file, f"{sample_array}\n")
        THE_MODULE.json_to_jsonl(in_file, out_file)
        assert(system.read_lines(out_file) == list(map(str, sample_array)))

    def test_jsonl_to_json(self):
        """Tests for jsonl_to_json"""
        in_file = gh.form_path(self.temp_base, "another-file.jsonl")
        out_file = gh.form_path(self.temp_base, "another-file.json")
        sample_array = ["dog", "cat", {"fav": "???"}]
        system.write_lines(in_file, [json.dumps(item) for item in sample_array])
        THE_MODULE.jsonl_to_json(in_file, out_file)
        assert(json.loads(system.read_file(out_file)) == sample_array)


#------------------------------------------------------------------------

if __name__ == '__main__':
    debug.trace_current_context()
    pytest.main([__file__])
