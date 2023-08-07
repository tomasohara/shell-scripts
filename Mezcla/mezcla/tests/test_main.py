#! /usr/bin/env python
#
# Test(s) for ../main.py
#
# Notes:
# - This can be run as follows:
#   $ PYTHONPATH=".:$PYTHONPATH" python ./mezcla/tests/test_main.py
# For tips on pytest monkeypatch, see
#   https://stackoverflow.com/questions/38723140/i-want-to-use-stdin-in-a-pytest-test
#

"""Unit tests for main module"""

# Standard packages
from argparse import ArgumentParser
import io
import sys

# Installed packages
import pytest

# Local packages
from mezcla import debug
from mezcla import tpo_common as tpo
from mezcla.unittest_wrapper import TestWrapper

# Note: Two references are used for the module to be tested:
#    THE_MODULE:	    global module object
import mezcla.main as THE_MODULE

class MyArgumentParser(ArgumentParser):
    """Version of ArgumentParser that doesn't exit upon failure"""

    def __init__(self, *args, **kwargs):
        """Constructor (relegating all to parent)"""
        super().__init__(*args, **kwargs)

    def exit(self, status=0, message=None):
        """Version of exit that doesn't really exit"""
        if message:
            self._print_message(message, sys.stderr)


class TestMain(TestWrapper):
    """Class for testcase definition"""
    script_module = TestWrapper.derive_tested_module_name(__file__)
    ## HACK: globals for use in embedded classes (TODO: move into Test class below)
    input_processed = None
    main_step_invoked = None
    process_line_count = -1

    def test_script_options(self):
        """Makes sure script option specifications are parsed OK"""
        debug.trace(4, f"in test_script_options(); self={self}")
        class Test(THE_MODULE.Main):
            """"Dummy test class"""
            argument_parser = MyArgumentParser
            ## TODO: rename as TestMain?

        # note: format is ("option", "description", "default"), or just "option"
        app = Test(text_options=[("name", "Full name", "John Doe")],
                   boolean_options=[("verbose", "testing verbose option", True)],
                   )
        #
        assert app.parsed_args.get("name") == "John Doe"
        assert app.parsed_args.get("verbose")

    @pytest.mark.xfail
    def test_script_without_input(self):
        """Makes sure script class without input doesn't process input and that
        the main step gets invoked"""
        debug.trace(4, f"in test_script_without_input(); self={self}")

        # This avoids flaky stderr due to other tests
        tpo.restore_stderr()

        # Create scriptlet checking for input and processing main step
        # TODO: rework with external script as argparse exits upon failure
        class Test(THE_MODULE.Main):
            """"Dummy test class"""
            argument_parser = MyArgumentParser

            def setup(self):
                """Post-argument parsing processing: just displays context"""
                tpo.debug_format("in setup(): self={s}", 5, s=self)
                TestMain.process_line_count = 0
                tpo.trace_current_context(label="Test.setup", 
                                          level=tpo.QUITE_DETAILED)
                tpo.trace_object(self, tpo.QUITE_DETAILED, "Test instance")
            #
            def process_line(self, line):
                """Dummy input processing"""
                tpo.debug_format("in Test.process_line({l}): self={s}", 5,
                                 l=line, s=self)
                TestMain.input_processed = True
                TestMain.process_line_count += 1

            #
            def run_main_step(self):
                """Dummy main step"""
                tpo.debug_format("in Test.run_main_step()): self={s}", 5,
                                 s=self)
                TestMain.main_step_invoked = True

        # Test scriptlet with test script as input w/ and w/o input enabled
        TestMain.input_processed = None
        app1 = Test(skip_input=False, runtime_args=[__file__])
        try:
            app1.run()
        except:
            tpo.print_stderr("Exception during run method: {exc}",
                             exc=tpo.to_string(sys.exc_info()))
        assert TestMain.input_processed
        #
        TestMain.input_processed = None
        app2 = Test(skip_input=True, runtime_args=[__file__])
        try:
            app2.run()
        except:
            tpo.print_stderr("Exception during run method: {exc}",
                             exc=tpo.to_string(sys.exc_info()))
        assert not TestMain.input_processed

        # Test scriptlet w/ input disabled and wihout arguments
        # note: auto_help disabled so that no arguments needed
        TestMain.main_step_invoked = None
        app3 = Test(skip_input=True, manual_input=True, auto_help=False, runtime_args=[])
        try:
            app3.run()
        except:
            tpo.print_stderr("Exception during run method: {exc}",
                             exc=tpo.to_string(sys.exc_info()))
        assert TestMain.main_step_invoked

    @pytest.mark.xfail
    def test_perl_arg(self):
        """Make sure perl-style arg can be parsed"""
        # TODO: create generic app-creation helper
        debug.trace(4, f"in test_perl_arg(); self={self}")
        class Test(THE_MODULE.Main):
            """"Dummy test class"""
            argument_parser = MyArgumentParser

        # Test with and without Perl support
        app = Test(boolean_options=[("verbose", "testing verbose option")],
                   perl_switch_parsing=True)
        #
        assert app.parsed_args.get("verbose") == 0
        #
        app = Test(boolean_options=[("verbose", "testing verbose option")],
                   perl_switch_parsing=False)
        # NOTE: this ensures that is None and not 0
        assert app.parsed_args.get("verbose") is None


class TestMain2:
    """Another class for testcase definition
    Note: Needed to avoid error with pytest due to inheritance with unittest.TestCase via TestWrapper"""

    def test_input_modes(self, capsys, monkeypatch):
        """Make sure input processed OK with respect to line/para/file mode"""
        debug.trace(4, f"in test_input_modes({capsys}); self={self}")
        contents = "1\n\n2\n\n\n3\n\n\n\n4\n\n\n\n"
        num_lines = len(contents.split("\n"))
        pre_captured = capsys.readouterr()
        # line input
        monkeypatch.setattr('sys.stdin', io.StringIO(contents))
        main = THE_MODULE.Main(skip_args=True, auto_help=False)
        main.run()
        captured = capsys.readouterr()
        ## TODO: assert(TestMain.process_line_count == num_lines)
        assert num_lines == len(captured.out.split("\n"))
        debug.trace_expr(5, main, num_lines)
        # paragraph input
        monkeypatch.setattr('sys.stdin', io.StringIO(contents))
        main = THE_MODULE.Main(paragraph_mode=True, skip_args=True, auto_help=False)
        main.run()
        captured = capsys.readouterr()
        ## TODO: assert(TestMain.process_line_count == 4)
        assert(num_lines == len(captured.out.split("\n")))
        debug.trace_expr(5, main, num_lines)
        # file input
        monkeypatch.setattr('sys.stdin', io.StringIO(contents))
        main = THE_MODULE.Main(file_input_mode=True, skip_args=True, auto_help=False)
        main.run()
        captured = capsys.readouterr()
        ## TODO: assert(TestMain.process_line_count == 1)
        assert(num_lines == len(captured.out.split("\n")))
        debug.trace_expr(5, main, num_lines, pre_captured)

    def test_missing_newline(self, capsys, monkeypatch):
        """Make sure file with missing newline at end processed OK"""
        debug.trace(4, f"in test_missing_newline({capsys}); self={self}")
        contents = "1\n2\n3"
        num_lines = len(contents.split("\n"))
        _pre_captured = capsys.readouterr()
        monkeypatch.setattr('sys.stdin', io.StringIO(contents))
        main = THE_MODULE.Main(skip_args=True, auto_help=False)
        main.run()
        captured = capsys.readouterr()
        # note: 1 extra line ('') and 1 extra character (final newline)
        assert (1 + num_lines) == len(captured.out.split("\n"))
        assert (1 + len(contents)) == len(captured.out)
        ## TODO: assert TestMain.process_line_count == 3
        debug.trace_expr(5, main, num_lines)

    def test_has_parsed_option_hack(self):
        """Make sure (temporarily hacked) has_parsed_option differs from has_parsed_option_old"""
        debug.trace(4, f"in test_has_parsed_option_hack(); self={self}")
        ok_arg = "ok"
        missing_arg = "missing"
        main = THE_MODULE.Main(skip_args=True, auto_help=False)
        main.parsed_args = {ok_arg: True}
        assert main.has_parsed_option_old(ok_arg) == main.has_parsed_option(ok_arg)
        assert main.has_parsed_option_old(missing_arg) != main.has_parsed_option(missing_arg)

#------------------------------------------------------------------------

if __name__ == '__main__':
    debug.trace_current_context()
    pytest.main([__file__])
