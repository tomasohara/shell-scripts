#! /usr/bin/env python
# -*- coding: utf-8 -*-
#
# Tests for ../adhoc/compare-file-listings.py
#
# Notes:
# - For debugging the tested script, the ALLOW_SUBCOMMAND_TRACING environment
#   option shows tracing output normally suppressed by unittest_wrapper.py.
# - This can be run as follows (e.g., from root of repo):
#   $ pytest ./tests/test_compare_file_listings.py
#

"""Tests for compare_file_listings module"""

# Standard modules
import io

# Installed modules
import pytest

# Local modules
from mezcla.unittest_wrapper import TestWrapper
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.my_regex import my_re
from mezcla import system

# Note: Two references are used for the module to be tested:
#    THE_MODULE:                        global module object
#    TestIt.script_module:              path to file
import adhoc.compare_file_listings as THE_MODULE

#------------------------------------------------------------------------

# Sample ls -alR output for testing
SAMPLE_OLD_LISTING = """\
.:
total 8
drwxr-xr-x  3 root root 4096 Jan  1 10:00 .
drwxr-xr-x  2 root root 4096 Jan  1 10:00 subdir

./subdir:
total 4
-rw-r--r--  1 root root 100 Jan  1 10:00 file1.txt
-rwxr-xr-x  1 alice users 200 Jan  1 10:00 script.sh
"""

SAMPLE_NEW_LISTING = """\
.:
total 8
drwxr-xr-x  3 root root 4096 Jan  2 10:00 .
drwxr-xr-x  2 root root 4096 Jan  2 10:00 subdir

./subdir:
total 4
-rw-r--r--  1 root root 100 Jan  2 10:00 file1.txt
-rwxrwxrwx  1 bob staff 200 Jan  2 10:00 script.sh
"""

#------------------------------------------------------------------------

class TestIt(TestWrapper):
    """Class for command-line based testcase definition"""
    script_module = TestWrapper.get_testing_module_name(__file__, THE_MODULE)
    use_temp_base_dir = True

    def test_01_usage(self):
        """Test run_script with --help to get usage"""
        debug.trace(4, f"TestIt.test_01_usage(); self={self}")
        output = self.run_script(options="--help")
        self.do_assert(my_re.search(r"(usage|Compare two recursive)", output, flags=my_re.IGNORECASE))
        return

    def test_02_permission_change_detection(self):
        """Tests detection of permission changes between old and new listings"""
        debug.trace(4, f"TestIt.test_02_permission_change_detection(); self={self}")
        
        # Create temp files for old and new listings
        old_file = gh.form_path(self.temp_base, "old_listing.txt")
        new_file = gh.form_path(self.temp_base, "new_listing.txt")
        system.write_file(old_file, SAMPLE_OLD_LISTING)
        system.write_file(new_file, SAMPLE_NEW_LISTING)
        
        # Run the script
        output = self.run_script(options="", env_options="", data_file=f"{old_file} {new_file}")
        
        # Should detect permission change on script.sh
        self.do_assert("PERM CHANGED" in output)
        self.do_assert("script.sh" in output)
        self.do_assert("-rwxr-xr-x" in output)  # old perms
        self.do_assert("-rwxrwxrwx" in output)  # new perms
        return

    def test_03_no_changes(self):
        """Tests that identical listings show no changes"""
        debug.trace(4, f"TestIt.test_03_no_changes(); self={self}")
        
        # Create identical old and new listings
        old_file = gh.form_path(self.temp_base, "old_same.txt")
        new_file = gh.form_path(self.temp_base, "new_same.txt")
        system.write_file(old_file, SAMPLE_OLD_LISTING)
        system.write_file(new_file, SAMPLE_OLD_LISTING)  # same as old
        
        # Run the script
        output = self.run_script(options="", data_file=f"{old_file} {new_file}")
        
        # Should not detect any permission changes
        self.do_assert("PERM CHANGED" not in output)
        return

    def test_04_parse_listing(self):
        """Tests Helper.parse_listing() directly"""
        debug.trace(4, f"TestIt.test_04_parse_listing(); self={self}")
        
        # Create a simple listing
        listing = """\
./test:
total 4
-rw-r--r--  1 user group 100 Jan  1 10:00 myfile.txt
"""
        helper = THE_MODULE.Helper(":memory:")
        entries = list(helper.parse_listing(io.StringIO(listing), label="test"))
        
        self.do_assert(len(entries) == 1)
        path, mode, owner, group = entries[0]
        self.do_assert(path == "test/myfile.txt")
        self.do_assert(mode == "-rw-r--r--")
        self.do_assert(owner == "user")
        self.do_assert(group == "group")
        return

    def test_05_owner_group_change(self):
        """Tests detection of owner/group changes"""
        debug.trace(4, f"TestIt.test_05_owner_group_change(); self={self}")
        
        old_listing = """\
./dir:
total 4
-rw-r--r--  1 alice users 100 Jan  1 10:00 data.txt
"""
        new_listing = """\
./dir:
total 4
-rw-r--r--  1 bob staff 100 Jan  2 10:00 data.txt
"""
        old_file = gh.form_path(self.temp_base, "old_owner.txt")
        new_file = gh.form_path(self.temp_base, "new_owner.txt")
        system.write_file(old_file, old_listing)
        system.write_file(new_file, new_listing)
        
        output = self.run_script(options="", data_file=f"{old_file} {new_file}")
        
        # Should detect owner/group change
        self.do_assert("PERM CHANGED" in output)
        self.do_assert("data.txt" in output)
        self.do_assert("alice" in output)
        self.do_assert("bob" in output)
        return

#------------------------------------------------------------------------

if __name__ == '__main__':
    debug.trace_current_context()
    pytest.main([__file__])
