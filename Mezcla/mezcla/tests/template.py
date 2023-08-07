#! /usr/bin/env python
#
# TODO: Test(s) for ../<module>.py
#
# Notes:
# - Fill out TODO's below. Use numbered tests to order (e.g., test_1_usage).
# - * See test_python_ast.py for simple example of customization.
# - TODO: If any of the setup/cleanup methods defined, make sure to invoke base
#   (see examples below for setUp and tearDown).
# - For debugging the tested script, the ALLOW_SUBCOMMAND_TRACING environment
#   option shows tracing output normally suppressed by unittest_wrapper.py.
# - This can be run as follows:
#   $ PYTHONPATH=".:$PYTHONPATH" python ./mezcla/tests/test_<module>.py
#

"""TODO: Tests for <module> module"""

# Standard packages
## TODO: from collections import defaultdict

# Installed packages
import pytest

# Local packages
from mezcla.unittest_wrapper import TestWrapper
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.my_regex import my_re
from mezcla import system

# Note: Two references are used for the module to be tested:
#    THE_MODULE:                  global module object
#    TestTemplate.script_module:  path to file
## TODO (vvv): change template to new name; *** use commented out template below ***
THE_MODULE = None           ## TODO: remove this line (n.b., used just to avoid syntax problems with <module> in following)
## TODO (^^^): import mezcla.<module> as THE_MODULE
#
# Note: sanity test for customization (TODO: remove if desired)
if not my_re.search(__file__, r"\btemplate.py$"):
    debug.assertion("mezcla.template" not in str(THE_MODULE))

## TODO:
## # Environment options
## # Note: These are just intended for internal options, not for end users.
## # It also allows for enabling options in one place.
## #
## FUBAR = system.getenv_bool("FUBAR", False,
##                            description="Fouled Up Beyond All Recognition processing")


class TestIt(TestWrapper):
    """Class for command-line based testcase definition"""
    script_module = TestWrapper.get_testing_module_name(__file__, THE_MODULE)
    #
    # TODO: use_temp_base_dir = True            # treat TEMP_BASE as directory
    # note: temp_file defined by parent (along with script_module, temp_base, and test_num)

    ## TODO: optional setup methods
    ##
    ## @classmethod
    ## def setUpClass(cls):
    ##     """One-time initialization (i.e., for entire class)"""
    ##     debug.trace(6, f"TestIt.setUpClass(); cls={cls}")
    ##     # note: should do parent processing first
    ##     super().setUpClass()
    ##     ...
    ##     return
    ##
    ## def setUp(self):
    ##     """Per-test setup"""
    ##     debug.trace(6, f"TestIt.setUp(); self={self}")
    ##     # note: must do parent processing first (e.g., for temp file support)
    ##     super().setUp()
    ##     ...
    ##     # TODO: debug.trace_current_context(level=debug.QUITE_DETAILED)
    ##     return

    @pytest.mark.xfail                   # TODO: remove xfail
    def test_data_file(self):
        """Makes sure TODO works as expected"""
        debug.trace(4, f"TestIt.test_data_file(); self={self}")
        data = ["TODO1", "TODO2"]
        system.write_lines(self.temp_file, data)
        ## TODO: add use_stdin=True to following if no file argument
        output = self.run_script(options="", data_file=self.temp_file)
        assert my_re.search(r"TODO-pattern", output.strip())
        return

    @pytest.mark.xfail                   # TODO: remove xfail
    def test_something_else(self):
        """TODO: flesh out test for something else"""
        debug.trace(4, f"TestIt.test_something_else(); self={self}")
        assert False
        ## ex: assert (THE_MODULE.TODO_function() == TODO_value)
        return


    ## TODO: optional cleanup methods
    ##
    ## def tearDown(self):
    ##     debug.trace(6, f"TestIt.tearDown(); self={self}")
    ##     super(TestIt, cls).tearDownClass()
    ##     ...
    ##     return
    ##
    ## @classmethod
    ## def tearDownClass(cls):
    ##     debug.trace(6, f"TestIt.tearDownClass(); cls={cls}")
    ##     super(TestIt, self).tearDown()
    ##     ...
    ##     return

## TODO:
## #...............................................................................
##
## class TestIt2:
##     """Class for API-based testcase definition
##     Note: Separate class avoids error with pytest due to inheritance with unittest.TestCase via TestWrapper"""
##
##     def test_whatever(self):
##         """TODO: flesh out test for whatever"""
##         debug.trace(4, f"TestIt2.test_whatever(); self={self}")
##         assert False, "TODO: code test"
##         ## ex: assert THE_MODULE.fast_sort() == THE_MODULE.slow_sort()
##         return
##

#------------------------------------------------------------------------

if __name__ == '__main__':
    debug.trace_current_context()
    pytest.main([__file__])
