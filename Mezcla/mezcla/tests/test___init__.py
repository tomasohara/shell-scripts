#! /usr/bin/env python
#
# Test(s) for ../__init__.py
#
# Notes:
# - Fill out TODO's below. Use numbered tests to order (e.g., test_1_usage).
# - TODO: If any of the setup/cleanup methods defined, make sure to invoke base
#   (see examples below for setUp and tearDown).
# - For debugging the tested script, the ALLOW_SUBCOMMAND_TRACING environment
#   option shows tracing output normally suppressed by  unittest_wrapper.py.
# - This can be run as follows:
#   $ PYTHONPATH=".:$PYTHONPATH" python ./mezcla/tests/test___init__.py
#

"""Tests for __init__ module"""

# Standard packages
import re

# Installed packages
import pytest

# Local packages
from mezcla.unittest_wrapper import TestWrapper
from mezcla import debug
## TODO: from mezcla import system
from mezcla.my_regex import my_re

# Note: Two references are used for the module to be tested:
#    THE_MODULE:                  global module object
#    TestTemplate.script_module:  path to file
import mezcla.__init__ as THE_MODULE
#
# Note: sanity test for customization (TODO: remove if desired)
if not re.search(__file__, r"\btemplate.py$"):
    debug.assertion("mezcla.template" not in str(THE_MODULE))

## TODO:
## # Environment options
## # Note: These are just intended for internal options, not for end users.
## # It also allows for enabling options in one place.
## #
## FUBAR = system.getenv_bool("FUBAR", False,
##                            description="Fouled Up Beyond All Recognition processing")


class TestIt(TestWrapper):
    """Class for testcase definition"""
    script_module = TestWrapper.get_testing_module_name(__file__)
    @pytest.mark.xfail                   # TODO: remove xfail
    def test_data_file(self):
        """Makes sure TODO works as expected"""
        debug.trace(4, f"TestIt.test_data_file(); self={self}")
        output = self.run_script("", self.temp_file)
        assert(not output.strip())
        return

class TestIt2:
    """Another class for testcase definition
    Note: Needed to avoid error with pytest due to inheritance with unittest.TestCase via TestWrapper"""

    def test_version(self):
        """Test version string"""
        debug.trace(5, f"test_version(); self={self}")
        assert(hasattr(THE_MODULE, "__VERSION__"))
        assert(my_re.match(r"^\d+.\d+\.\d+.*", THE_MODULE.__VERSION__))


#------------------------------------------------------------------------

if __name__ == '__main__':
    debug.trace_current_context()
    pytest.main([__file__])
