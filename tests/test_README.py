#! /usr/bin/env python
#
# Notes:
# - Simple test(s) for the README file(s).
# - This is mainly intended for debugging the testing infrastructure
#   (see run_tests.bash).
# - This can be run as follows:
#   $ PYTHONPATH=".:$PYTHONPATH" python tests/test_README.py
#

"""Tests for README.md, etc."""

# Standard modules
## TODO: from collections import defaultdict

# Installed modules
import pytest

# Local modules
from mezcla.unittest_wrapper import TestWrapper
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.my_regex import my_re
from mezcla import system

# Constants
MAIN_README_FILE = "README-TESTING.md"

class TestIt:
    """Class for command-line based testcase definition"""
    main_readme_path = gh.resolve_path(MAIN_README_FILE)

    @pytest.mark.xfail                   # TODO: remove xfail
    def test_exists(self):
        """Tests run_script w/ data file"""
        debug.trace(4, f"TestIt.test_exists(); self={self}")
        assert system.file_exists(self.main_readme_path)
        return

    @pytest.mark.xfail                   # TODO: remove xfail
    def test_mentions_jupyter(self):
        """Test for mention of Jupyter notebooks"""
        debug.trace(4, f"TestIt.test_mentions_jupyter(); self={self}")
        assert my_re.search(r"jupyter",
                            system.read_file(self.main_readme_path),
                            flags=my_re.IGNORECASE)
        return

#------------------------------------------------------------------------

if __name__ == '__main__':
    debug.trace_current_context()
    pytest.main([__file__])
