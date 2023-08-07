#! /usr/bin/env python
#
# Test(s) for ../text_categorizer.py
#
# Notes:
# - This can be run as follows:
#   $ PYTHONPATH=".:$PYTHONPATH" python ./mezcla/tests/test_<module>.py
#

"""Tests for text_categorizer module"""

# Standard packages
import re

# Installed packages
import pytest

# Local packages
from mezcla.unittest_wrapper import TestWrapper
from mezcla import debug
## TODO: from mezcla import system
from mezcla import glue_helpers as gh

# Note: Two references are used for the module to be tested:
#    THE_MODULE:	    global module object
import mezcla.text_categorizer as THE_MODULE
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


class TestTextCategorizerUtils(TestWrapper):
    """Class for testcase definition"""

    def test_something_else(self):
        """TODO: flesh out test for something else"""
        debug.trace(4, "test_something_else()")
        ## ex: assert THE_MODULE.TODO_function() == TODO_value

    def test_sklearn_report(self):
        """Ensure sklearn_report works as expected"""
        debug.trace(4, "test_sklearn_report()")
        ## TODO: WORK-IN=PROGRESS

    def test_create_tabular_file(self):
        """Ensure create_tabular_file works as expected"""
        debug.trace(4, "test_create_tabular_file()")
        ## TODO: WORK-IN=PROGRESS

    def test_read_categorization_data(self):
        """Ensure read_categorization_data works as expected"""
        debug.trace(4, "test_read_categorization_data()")
        ## TODO: WORK-IN=PROGRESS

    def test_int_if_whole(self):
        """Ensure int_if_whole works as expected"""
        debug.trace(4, "test_int_if_whole()")
        assert THE_MODULE.int_if_whole(2.0) == 2
        assert THE_MODULE.int_if_whole(2.999) == 2.999

    def test_param_or_default(self):
        """Ensure param_or_default works as expected"""
        debug.trace(4, "test_param_or_default()")
        ## TODO: WORK-IN=PROGRESS

    @pytest.mark.skip(reason="TODO: test not yet implemented")
    def test_data_file(self):
        """Makes sure TODO works as expected"""
        debug.trace(4, "TestTextCategorizer.test_data_file()")
        data = ["TODO1", "TODO2"]
        gh.write_lines(self.temp_file, data)
        output = self.run_script("", self.temp_file)
        assert re.search(r"TODO-pattern", output.strip())
        return

    def test_format_index_html(self):
        """Ensure format_index_html works as expected"""
        debug.trace(4, "test_format_index_html()")
        ## TODO: WORK-IN=PROGRESS

    def test_start_web_controller(self):
        """Ensure start_web_controller works as expected"""
        debug.trace(4, "test_start_web_controller()")
        ## TODO: WORK-IN=PROGRESS


class TestTextCategorizerScript(TestWrapper):
    """Class for testcase definition"""
    script_file = TestWrapper.get_module_file_path(__file__)
    script_module = TestWrapper.get_testing_module_name(__file__)
    # TODO: use_temp_base_dir = True            # treat TEMP_BASE as directory
    # note: temp_file defined by parent (along with script_module, temp_base, and test_num)

    ## TODO: WORK-IN-PROGRESS TESTS


#------------------------------------------------------------------------

if __name__ == '__main__':
    debug.trace_current_context()
    pytest.main([__file__])
