#! /usr/bin/env python
#
# Test(s) for ../simple_batspp.py
#
# Notes:
# - For debugging the tested script, the ALLOW_SUBCOMMAND_TRACING environment
#   option shows tracing output normally suppressed by unittest_wrapper.py.
# - This can be run as follows:
#   $ PYTHONPATH=".:$PYTHONPATH" python ./mezcla/tests/test_simple_batspp.py
#

"""Tests for simple_batspp module"""

# Standard packages
## TODO: from collections import defaultdict

# Installed packages
import pytest

# Local packages
from mezcla.unittest_wrapper import TestWrapper
from mezcla.unittest_wrapper import trap_exception
from mezcla import debug
## TODO: from mezcla import glue_helpers as gh
from mezcla.my_regex import my_re
from mezcla import system

# Note: Two references are used for the module to be tested:
#    THE_MODULE:                  global module object
#    TestTemplate.script_module:  path to file
import simple_batspp as THE_MODULE
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

FUBAR_TEST = r"""
    # Fubar test
    
    # Global setup
    $ num_fu=0
    ## TODO: $ alias fubar='let num_fu++; echo num_fu="$(eval echo "\${num_fu}")"'
    $ alias fubar='let num_fu++'
    
    # Setup
    $ num_fu=1
    
    # Test fu
    ## TODO: $ fubar
    ## TEST: 
    ## $ fubar; echo "num_fu=$num_fu"
    ## num_fu=1
    $ fubar; echo fubar
    fubar
    
    # Test fu again
    ## TODO: $ echo $(fubar)
    ## TEST: 
    ## $ fubar; echo "num_fu=$num_fu"
    ## num_fu=2
    $ fubar; echo fubar
    fubar
""".replace("    ", "")

#------------------------------------------------------------------------

class TestIt(TestWrapper):
    """Class for command-line based testcase definition"""
    script_module = TestWrapper.get_testing_module_name(__file__, THE_MODULE)
    #
    # TODO: use_temp_base_dir = True            # treat TEMP_BASE as directory
    # note: temp_file defined by parent (along with script_module, temp_base, and test_num)

    @pytest.mark.xfail                   # TODO: remove xfail
    @trap_exception
    def test_data_file(self):
        """Makes sure TODO works as expected"""
        debug.trace(4, f"TestIt.test_data_file(); self={self}")

        system.write_file(self.temp_file, FUBAR_TEST)
        output = self.run_script(
            options=f"--output {self.temp_file}.batspp",
            env_options="TEST_FILE=1 MATCH_SENTINELS=1 PARA_BLOCKS=1 BASH_EVAL=1",
            data_file=self.temp_file)
        # note: The setup is counted as a no-op test (i.e., ignored)
        self.do_assert("3 tests, 0 failure(s), 1 ignored" in output)
        return

    @pytest.mark.xfail                   # TODO: remove xfail
    @trap_exception
    def test_preprocess_batspp(self):
        """TODO: flesh out test for preprocess_batspp"""
        debug.trace(4, f"TestIt.test_preprocess_batspp(); self={self}")
        contents = ("$ echo hey \\\n" +
                    "you\n")
        self.do_assert("\\" not in THE_MODULE.preprocess_batspp(contents))
        return


#------------------------------------------------------------------------

if __name__ == '__main__':
    debug.trace_current_context()
    pytest.main([__file__])
