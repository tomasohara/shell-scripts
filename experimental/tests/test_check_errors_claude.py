#! /usr/bin/env python3
# TODO: # -*- coding: utf-8 -*-
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
# - This can be run as follows (e.g., from root of repo):
#   $ pytest ./mezcla/tests/test_<module>.py
#
# Warning:
# - The use of run_script as in test_01_data_file is an older style of testing.
#   It is better to directly invoke a helper class in the script that is independent
#   of the Script class based on Main. (See an example of this, see python_ast.py
#   and tests/tests_python_ast.py.)
# - Moreover, debugging tests with run_script is complicated because a separate
#   process is involved (e.g., with separate environment variables.)
# - See discussion of SUB_DEBUG_LEVEL in unittest_wrapper.py for more info.
# - TODO: Feel free to delete this warning as well as the related one below.
#


## TODO1: [Warning] Make sure this template adhered to as much as possible. For,
## example, only delete todo comments not regular code, unless suggested in tip).
## In particular, it is critical that script_module gets initialized properly.

"""TODO: Tests for <module> module"""

# Standard modules
## TODO: from collections import defaultdict

# Installed modules
import pytest

# Local modules
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.my_regex import my_re
from mezcla import system
from mezcla.unittest_wrapper import TestWrapper, invoke_tests

# Note: Two references are used for the module to be tested:
#    THE_MODULE:               module object (e.g., <module 'mezcla.main' ...>)
#    TestIt.script_module:     dotted module path (e.g., "mezcla.main")
THE_MODULE = None
try:
    import check_errors_claude as THE_MODULE
except:
    system.print_exception_info("<module> import") 
## 
## TODO: make sure import above syntactically valid
#
# Note: sanity test for customization (TODO: remove if desired)
if not my_re.search(r"\btemplate.py$", __file__):
    debug.assertion("mezcla.template" not in str(THE_MODULE))

## TODO:
## # Environment options
## # Note: These are just intended for internal options, not for end users.
## # It also allows for enabling options in one place.
## #
## FUBAR = system.getenv_bool(
##     "FUBAR", False,
##     description="Fouled Up Beyond All Recognition processing")

PERL_SCRIPT = "check_errors.perl"
OTHER_SCRIPT = system.getenv_text(
    "OTHER_SCRIPT", PERL_SCRIPT,
    desc=f"Other script to check such as {PERL_SCRIPT}")
PERL_SCRIPT_PATH = gh.resolve_path(PERL_SCRIPT, heuristic=True)
OTHER_SCRIPT_PATH = gh.resolve_path(OTHER_SCRIPT, heuristic=True)
VERBOSE_MODE = system.getenv_bool(
    "VERBOSE_MODE", False,
    desc="Show verbose info about tests")

#------------------------------------------------------------------------

class TestIt(TestWrapper):
    """Class for command-line based testcase definition"""
    # note: script_module used in argument parsing sanity check (e.g., --help)
    script_module = TestWrapper.get_testing_module_name(__file__, THE_MODULE)
    #
    # TODO: use_temp_base_dir = True    # treat TEMP_BASE as dir (e.g., for simpler organization with many tests)
    # note: temp_file defined by parent (e.g., also temp_base and test_num)

    ## TODO: optional setup methods
    ##
    ## @classmethod
    ## def setUpClass(cls, filename=None, module=None):
    ##     """One-time initialization (i.e., for entire class)"""
    ##     debug.trace(6, f"TestIt.setUpClass(); cls={cls}")
    ##     # note: should do parent processing first
    ##     super().setUpClass(filename, module)
    ##     ...
    ##     debug.trace_object(5, cls, label=f"{cls.__class__.__name__} instance")
    ##     return
    ##
    ## def setUp(self):
    ##     """Per-test setup"""
    ##     #
    ##     # Warning: *** to minimize capsys contamination due to pre-test tracing, 
    ##     # use the following context (TODO: feel free to delete warning):
    ##     #    with self.capsys.disabled():
    ##     #       debug.trace(...)
    ##     #       ...
    ##     # See https://docs.pytest.org/en/7.1.x/how-to/capture-stdout-stderr.html
    ##     #
    ##     debug.trace(6, f"TestIt.setUp(); self={self}")
    ##     # note: must do parent processing first (e.g., for temp file support)
    ##     super().setUp()
    ##     ...
    ##     # TODO: debug.trace_current_context(level=debug.QUITE_DETAILED)
    ##     return

    @pytest.mark.xfail                   # TODO: remove xfail
    def test_01_data_file(self):
        """Tests run_script w/ data file"""
        # Warning: see notes above about potential issues with run_script-based tests.
        debug.trace(4, f"TestIt.test_01_data_file(); self={self}")
        data = ["TODO1", "TODO2"]
        system.write_lines(self.temp_file, data)
        ## TODO: add use_stdin=True to following if no file argument
        output = self.run_script(options="", data_file=self.temp_file)
        self.do_assert(my_re.search(r"TODO-pattern", output.strip()))
        return

    @pytest.mark.xfail                   # TODO: remove xfail
    def test_02_something_else(self):
        """Test for something_else: TODO..."""
        debug.trace(4, f"TestIt.test_02_something_else(); self={self}")
        self.do_assert(False, "TODO: implement")
        ## ex: self.do_assert(THE_MODULE.TODO_function() == TODO_value)
        return

    @pytest.mark.xfail                   # TODO: remove xfail
    def test_03_whatever(self):
        """TODO: flesh out test for whatever (capsys-like)"""
        # Note: you might need to disable tracing during setUp (see notes above).
        debug.trace(4, f"TestIt.test_03_whatever(); self={self}")
        THE_MODULE.show_current_file_info()
        captured = self.get_stderr()
        self.do_assert("whatever" in captured, "TODO_whatever trace")
        return

    ## TODO: get pytest.mark.parametrize inside of class
    ## NOTE: See workaround with test_global_01_table below
    ## @pytest.mark.parametrize(
    ##     "TODO_arg1, TODO_arg2",
    ##     [ (2, 1),
    ##       (1, 2) ]
    ##     )
    ## @staticmethod
    ## def test_04_table(TODO_arg1, TODO_arg2):
    ##     """TODO_Tabular test"""
    ##     debug.trace(4, f"TestIt.test_04_table({arg1}, {arg2})")
    ##     assert arg1 < arg2
    ##
    ## TODO2: -or- define helper with use with global (see below)
    ## def check_table_args(TODO_arg1, TODO_arg2):
    ##     """TODO_Tabular test"""
    ##     debug.trace(4, f"TestIt.test_04_table({arg1}, {arg2})")
    ##     assert arg1 < arg2

    ## TODO: optional cleanup methods
    ##
    ## def tearDown(self):
    ##     debug.trace(6, f"TestIt.tearDown(); self={self}")
    ##     super().tearDown()
    ##     ...
    ##     return
    ##
    ## @classmethod
    ## def tearDownClass(cls):
    ##     debug.trace(6, f"TestIt.tearDownClass(); cls={cls}")
    ##     super().tearDownClass()
    ##     ...
    ##     return


    def check_other_message(self, message):
        """Helper to check that other script matches this script for MESSAGE"""
        debug.trace(5, f"TestIt.check_other_message({message!r})")
        temp_file = self.create_temp_file(message)

        # Check for error targetting specifica message.
        # Note: just checks word tokens by using .* for non-word chars
        #   ex: "Can\'t locate" => "Can.*t locate"
        # TODO2: add support for alternatives (e.g., stripping alternatives
        #    ex: "at .*\.(perl|prl|pl|pm) line \d+" => "at.*perl.*line.*d"
        # Warning: not all cases can readily be transformed so this is heuristic test,
        # which sacrifices simplicity for coverage (i.e., a la quick and dirty check).
        message_regex = my_re.sub(r"\W+", ".*", message)
        this_flagged = my_re.search(f">>> {message_regex} <<<", self.run_script(data_file=temp_file))
        that_flagged = my_re.search(f">>> {message_regex} <<<", gh.run(f"{OTHER_SCRIPT} {temp_file}"))
        debug.trace_expr(6, this_flagged, that_flagged)
        ok = (bool(this_flagged) == bool(that_flagged))
        return ok

    @pytest.mark.xfail                   # TODO: remove xfail
    def test_versus_other_script(self):
        """Make sure script matches 90% of other script"""
        debug.trace(4, f"TestIt.test_versus_other_script(); self={self}")
        num_ok = 0
        num_total = 0
        perl_script_code = system.read_file(PERL_SCRIPT_PATH)
        ## DEBUG: for message in gh.extract_matches_from_text("(.*)", perl_script_code):
        for message in gh.extract_matches_from_text("/(.*)/", perl_script_code):
            num_total += 1
            if self.check_other_message(message):
                num_ok += 1
            else:
                debug.trace(5, f"FYI: Problem checking message {message!r}")
        threshold = 90
        pct_ok = (num_ok / num_total * 100) if num_total else 0
        if VERBOSE_MODE:
            print(f"{num_ok=} {num_total=} {pct_ok=} {threshold=}")
        assert(pct_ok >= threshold)

    
## TODO: define optional tests with tabular input
## #................................................................................
## # Global tests
## #
## # Note: @pytest.mark.parametrize doesn't seem to be compatible with classes
## # based on TestWrapper (or classes in general).
## # See https://stackoverflow.com/questions/38729007/parametrize-class-tests-with-pytest
## 
## @pytest.mark.parametrize(
##     "TODO_arg1, TODO_arg2",
##     [ (2, 1),
##       (1, 2) ]
## )
## def test_global_01_table(TODO_arg1, TODO_arg2):
##     """TODO_Tabular test"""
##     debug.trace(4, f"TestIt.test_global_01_table({arg1}, {arg2})")
##     assert arg1 < arg2
## TODO2: -or- use helper in test class (see above)
## def test_global_01_table(TODO_arg1, TODO_arg2):
##     """TODO_Tabular test"""
##     debug.trace(4, f"TestIt.test_global_01_table({arg1}, {arg2})")
##     TestIt().check_table_args(TODO_arg1, TODO_arg2))
##

#------------------------------------------------------------------------

if __name__ == '__main__':
    debug.trace_current_context()
    invoke_tests(__file__)
