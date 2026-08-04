#! /usr/bin/env python
#
# Test(s) for ../simple_batspp.py
#
# Notes:
# - For debugging the tested script, the ALLOW_SUBCOMMAND_TRACING environment
#   option shows tracing output normally suppressed by unittest_wrapper.py.
# - This can be run as follows:
#   $ PYTHONPATH=".:$PYTHONPATH" python ./mezcla/tests/test_simple_batspp.py
# - Ignores class-internals warning:
#   pylint: disable=protected-access
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
    # Global setup
    $ num_fu=0
    $ alias fubar='let num_fu++; echo num_fu=$num_fu'

    # Test fu
    $ fubar
    num_fu=1
    
    # Test fu again
    $ fubar
    num_fu=2
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

    ## OLD: @pytest.mark.xfail                   # TODO: remove xfail
    @trap_exception
    def test_preprocess_batspp(self):
        """TODO: flesh out test for preprocess_batspp"""
        debug.trace(4, f"TestIt.test_preprocess_batspp(); self={self}")
        contents = ("$ echo hey \\\n" +
                    "you\n")
        self.do_assert("\\" not in THE_MODULE.preprocess_batspp(contents))
        return

    @trap_exception
    def test_convert_to_bats_preserves_single_quotes(self):
        """Make sure debug trace keeps single quotes in expected text"""
        debug.trace(4, f"TestIt.test_convert_to_bats_preserves_single_quotes(); self={self}")
        test_obj = THE_MODULE.CommandTests()
        old_omit_trace = THE_MODULE.OMIT_TRACE
        try:
            THE_MODULE.OMIT_TRACE = False
            test_case = THE_MODULE.TestFieldTypes(
                entire="# Test quote check\n",
                title="quote-check",
                setup="",
                actual="$ echo ok\n",
                expected="Error: Use 'git-update-force' to update with changed files",
            )
            bats_text, _ = test_obj._convert_to_bats(test_case)
            self.do_assert("Use 'git-update-force'" in bats_text)
            self.do_assert('Use "git-update-force"' not in bats_text)
        finally:
            THE_MODULE.OMIT_TRACE = old_omit_trace
        return

    @trap_exception
    def test_convert_to_bats_escapes_double_quote_and_dollar(self):
        """Make sure debug trace escapes shell-sensitive chars in header text"""
        debug.trace(4, f"TestIt.test_convert_to_bats_escapes_double_quote_and_dollar(); self={self}")
        test_obj = THE_MODULE.CommandTests()
        old_omit_trace = THE_MODULE.OMIT_TRACE
        try:
            THE_MODULE.OMIT_TRACE = False
            test_case = THE_MODULE.TestFieldTypes(
                entire="# Test shell escape check\n",
                title="shell-escape-check",
                setup="",
                actual="$ echo ok\n",
                expected='value: "double" $HOME',
            )
            bats_text, _ = test_obj._convert_to_bats(test_case)
            self.do_assert('\\"double\\"' in bats_text)
            self.do_assert('\\$HOME' in bats_text)
        finally:
            THE_MODULE.OMIT_TRACE = old_omit_trace
        return

    @pytest.mark.xfail(reason="TODO: support optional non-elided debug headers for long output")
    @trap_exception
    def test_convert_to_bats_no_elision_for_long_expected(self):
        """Edge-case TODO: allow preserving full long expected text in debug header"""
        debug.trace(4, f"TestIt.test_convert_to_bats_no_elision_for_long_expected(); self={self}")
        test_obj = THE_MODULE.CommandTests()
        old_omit_trace = THE_MODULE.OMIT_TRACE
        old_max_len = THE_MODULE.MAX_ESCAPED_LEN
        try:
            THE_MODULE.OMIT_TRACE = False
            THE_MODULE.MAX_ESCAPED_LEN = 24
            test_case = THE_MODULE.TestFieldTypes(
                entire="# Test long expected\n",
                title="long-expected",
                setup="",
                actual="$ echo ok\n",
                expected="0123456789-abcdefghijklmnopqrstuvwxyz-tail",
            )
            bats_text, _ = test_obj._convert_to_bats(test_case)
            self.do_assert("abcdefghijklmnopqrstuvwxyz-tail" in bats_text)
        finally:
            THE_MODULE.OMIT_TRACE = old_omit_trace
            THE_MODULE.MAX_ESCAPED_LEN = old_max_len
        return


#------------------------------------------------------------------------

if __name__ == '__main__':
    debug.trace_current_context()
    pytest.main([__file__])
