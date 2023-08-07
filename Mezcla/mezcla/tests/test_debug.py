#! /usr/bin/env python
#
# Simple tests for debug.py, based on following:
#     https://stackoverflow.com/questions/16039463/how-to-access-the-py-test-capsys-from-inside-a-test
#
# Notes:
# - This can be run as follows:
#   $ SKIP_ATEXIT=1 PYTHONPATH=".:$PYTHONPATH" python ./mezcla/tests/test_debug.py
# - For tests that capture standard error, see
#       https://docs.pytest.org/en/6.2.x/capture.html
# - This uses capsys fixture mentioned in above link.
#................................................................................
# TODO:
# - make sure trace_fmt traps all exceptions
#   debug.trace_fmt(1, "fu={fu}", fuu=1)
#                           ^^    ^^^
#

"""Tests for debug module"""

# Standard packages
import sys

# Installed packages
import pytest

# Local packages
## TODO: make sure atexit support disabled unless explcitly requested
##   import os; os.environ["SKIP_ATEXIT"] = os.environ.get("SKIP_ATEXIT", "1")
from mezcla import debug
from mezcla.my_regex import my_re

# Note: Two references are used for the module to be tested:
#    THE_MODULE:	    global module object
import mezcla.debug as THE_MODULE # pylint: disable=reimported

class TestDebug:
    """Class for test case definitions"""
    stdout_text = None
    stderr_text = None
    expected_stdout_trace = None
    expected_stderr_trace = None

    def setup_simple_trace(self):
        """Common setup for simple tracing"""
        debug.trace(4, f"setup_common(): self={self}")
        self.stdout_text = "hello"
        self.stderr_text = "world"
        self.expected_stdout_trace = self.stdout_text + "\n"
        self.expected_stderr_trace = self.stderr_text + "\n"

    def test_set_level(self):
        """Ensure set_level works as expected"""
        debug.trace(4, f"test_set_level(): self={self}")
        THE_MODULE.set_level(5)
        assert THE_MODULE.trace_level == 5

    def test_get_level(self):
        """Ensure get_level works as expected"""
        debug.trace(4, f"test_get_level(): self={self}")
        THE_MODULE.trace_level = 5
        assert THE_MODULE.get_level() == 5

    def test_get_output_timestamps(self):
        """Ensure get_output_timestamps works as expected"""
        debug.trace(4, f"test_get_output_timestamps(): self={self}")
        THE_MODULE.output_timestamps = 'some-test-value'
        assert THE_MODULE.get_output_timestamps() == 'some-test-value'

    def test_set_output_timestamps(self):
        """Ensure set_output_timestamps works as expected"""
        debug.trace(4, f"test_set_output_timestamps(): self={self}")
        THE_MODULE.output_timestamps = False
        THE_MODULE.set_output_timestamps('some-test-value')
        assert THE_MODULE.output_timestamps == 'some-test-value'

    def test_trace(self, capsys):
        """Ensure trace works as expected"""
        debug.trace(4, f"test_trace(): self={self}")
        THE_MODULE.output_timestamps = True

        THE_MODULE.trace(-1, 'error foobar', indentation=' -> ')
        captured = capsys.readouterr()
        assert " -> error foobar" in captured.err
        assert not captured.out

        # Test debug_file
        THE_MODULE.debug_file = sys.stdout
        THE_MODULE.trace(-1, 'some text to test debug file')
        captured = capsys.readouterr()
        assert 'some text to test debug file' in captured.out
        THE_MODULE.debug_file = None

        THE_MODULE.output_timestamps = False

    def test_trace_fmtd(self):
        """Ensure trace_fmtd works as expected"""
        debug.trace(4, f"test_trace_fmtd(): self={self}")
        ## TODO: WORK-IN-PROGRESS

    def test_trace_object(self):
        """Ensure trace_object works as expected"""
        debug.trace(4, f"test_trace_object(): self={self}")
        ## TODO: WORK-IN-PROGRESS

    def test_trace_values(self, capsys):
        """Ensure trace_values works as expected"""
        debug.trace(4, f"test_trace_values(): self={self}")
        # Level -1 is used to ensure that always will run

        collection_test = [
            'foobarerror',
            'some-error',
            'another error',
        ]

        # Test normal usage
        THE_MODULE.trace_values(-1, collection_test)
        captured = capsys.readouterr()
        for element in collection_test:
            assert f": {element}" in captured.err

        # Test indentation
        THE_MODULE.trace_values(-1, collection_test, indentation=' -> ')
        captured = capsys.readouterr()
        for i, element in enumerate(collection_test):
            assert f" -> {i}: {element}" in captured.err

        # Test non list collection (string)
        THE_MODULE.trace_values(-1, "somevalue")
        captured = capsys.readouterr()
        for char in "somevalue":
            assert f": {char}" in captured.err

        # Test non list collection (tuple)
        THE_MODULE.trace_values(-1, 123)
        captured = capsys.readouterr()
        assert ": 123" in captured.err

        # Test use_repr parameter
        class Person:
            """Test class"""
            def __init__(self, name):
                self.name = name
            def __repr__(self):
                return f'Person("{self.name}")'
        THE_MODULE.trace_values(-1, [Person("Kiran")], use_repr=True)
        captured = capsys.readouterr()
        assert 'Person("Kiran")' in captured.err

    def test_trace_expr(self, capsys):
        """Make sure trace_expr shows 'expr1=value1; expr2=value2'"""
        var1 = 3
        var2 = 6
        THE_MODULE.trace_expr(debug.get_level(), var1, var2)
        captured = capsys.readouterr()
        assert "var1=3;var2=6" in my_re.sub(r"\s+", "", captured.err)

    @pytest.mark.xfail
    def test_trace_expr_expression(self, capsys):
        """Make sure trace_expr expression resolved when split across lines"""
        var1 = 3
        var2 = 6
        THE_MODULE.trace_expr(debug.get_level(),
                              var1,
                              var2)
        captured = capsys.readouterr()
        assert "var1=3.*var2=6" in my_re.sub(r"\s+", "", captured.err)
        
    def test_trace_current_context(self):
        """Ensure trace_current_context works as expected"""
        debug.trace(4, f"test_trace_current_context(): self={self}")
        ## TODO: WORK-IN-PROGRESS

    def test_trace_exception(self):
        """Ensure trace_exception works as expected"""
        debug.trace(4, f"test_trace_exception(): self={self}")
        ## TODO: WORK-IN-PROGRESS

    def test_raise_exception(self):
        """Ensure raise_exception works as expected"""
        debug.trace(4, f"test_raise_exception(): self={self}")
        ## TODO: WORK-IN-PROGRESS

    def test_assertion(self, capsys):
        """Ensure assertion works as expected"""
        debug.trace(4, f"test_assertion(): self={self}")
        # Not prints in stderr
        THE_MODULE.assertion((2 + 2 + 1) == 5)
        captured = capsys.readouterr()
        assert 'failed' not in captured.err
        # Prints assertion failed in stderr
        THE_MODULE.assertion((2 + 2) == 5)
        captured = capsys.readouterr()
        assert "failed" in captured.err
        assert "(2 + 2) == 5" in captured.err

    @pytest.mark.xfail
    def test_assertion_expression(self, capsys):
        """Make sure assertion expression split across lines resolved"""
        debug.trace(4, f"test_assertion_expression(): self={self}")
        THE_MODULE.assertion(2 +
                             2 ==
                             5)
        captured = capsys.readouterr()
        assert "2+2==5" in my_re.sub(r"\s+", "", captured.err)

    def test_val(self):
        """Ensure val works as expected"""
        debug.trace(4, f"test_val(): self={self}")
        save_trace_level = THE_MODULE.get_level()
        test_value = 22
        THE_MODULE.set_level(5)
        level5_value = THE_MODULE.val(5, test_value)
        THE_MODULE.set_level(0)
        level0_value = THE_MODULE.val(1, test_value)
        THE_MODULE.set_level(save_trace_level)
        assert level5_value == test_value
        assert level0_value is None

    def test_code(self):
        """Ensure code works as expected"""
        debug.trace(4, f"test_code(): self={self}")
        ## TODO: debug.assertion(debug_level, debug.code(debug_level, lambda: (8 / 0 != 0.0)))
        save_trace_level = THE_MODULE.get_level()
        count = 0
        def increment():
            """Increase counter"""
            nonlocal count
            count += 1
        THE_MODULE.set_level(4)
        THE_MODULE.code(4, lambda: increment)
        THE_MODULE.set_level(save_trace_level)
        assert(count == 0)

    def test_debug_print(self):
        """Ensure debug_print works as expected"""
        debug.trace(4, f"test_debug_print(): self={self}")
        ## TODO: WORK-IN-PROGRESS

    def test_timestamp(self):
        """Ensure timestamp works as expected"""
        debug.trace(4, f"test_timestamp(): self={self}")
        ## TODO: WORK-IN-PROGRESS

    def test_debugging(self):
        """Ensure debugging works as expected"""
        debug.trace(4, f"test_debugging(): self={self}")
        THE_MODULE.set_level(4)
        assert THE_MODULE.debugging(2)
        assert THE_MODULE.debugging(4)
        assert not THE_MODULE.debugging(6)

    def test_detailed_debugging(self):
        """Ensure detailed_debugging works as expected"""
        debug.trace(4, f"test_detailed_debugging(): self={self}")
        THE_MODULE.set_level(2)
        assert not THE_MODULE.detailed_debugging()
        THE_MODULE.set_level(4)
        assert THE_MODULE.detailed_debugging()
        THE_MODULE.set_level(6)
        assert THE_MODULE.detailed_debugging()

    def test_verbose_debugging(self):
        """Ensure verbose_debugging works as expected"""
        debug.trace(4, f"test_verbose_debugging(): self={self}")
        THE_MODULE.set_level(2)
        assert not THE_MODULE.verbose_debugging()
        THE_MODULE.set_level(5)
        assert THE_MODULE.verbose_debugging()
        THE_MODULE.set_level(7)
        assert THE_MODULE.verbose_debugging()

    def test_format_value(self):
        """Ensure format_value works as expected"""
        debug.trace(4, f"test_format_value(): self={self}")
        assert(THE_MODULE.format_value("\n    ", max_len=5) == "\\n   ...")
        assert(THE_MODULE.format_value("123456", max_len=7) == "123456")
        assert(THE_MODULE.format_value("123456", max_len=6) == "123456")
        assert(THE_MODULE.format_value("123456", max_len=5) == "12345...")
        assert(THE_MODULE.format_value("123456", max_len=4) == "1234...")
        assert(THE_MODULE.format_value("123456", max_len=3) == "123...")
        assert(THE_MODULE.format_value("123456", max_len=2) == "12...")
        assert(THE_MODULE.format_value("123456", max_len=1) == "1...")
        assert(THE_MODULE.format_value("123456", max_len=0) == "...")

    def test_format_value_strict(self):
        """Ensure format_value w/ strict works as expected"""
        debug.trace(4, f"test_format_value(): self={self}")
        def format_value_strict(value, max_len):
            """Invokes debug.format_value with strict option"""
            return THE_MODULE.format_value(value, max_len=max_len,
                                    strict=True)
        assert(format_value_strict("\n    ", max_len=5) == "\\n...")
        assert(format_value_strict("123456", max_len=7) == "123456")
        assert(format_value_strict("123456", max_len=6) == "123456")
        assert(format_value_strict("123456", max_len=5) == "12...")
        assert(format_value_strict("123456", max_len=4) == "1...")
        assert(format_value_strict("123456", max_len=3) == "...")
        assert(format_value_strict("123456", max_len=2) == "..")
        assert(format_value_strict("123456", max_len=1) == ".")
        assert(format_value_strict("123456", max_len=0) == "")

    def test_xor(self, capsys):
        """Ensure xor works as expected"""
        debug.trace(4, f"test_xor(): self={self}")
        THE_MODULE.set_level(7)
        # Test the XOR table
        assert not THE_MODULE.xor(0, 0.0)
        assert THE_MODULE.xor(0, 1.0)
        assert THE_MODULE.xor(1, 0.0)
        assert not THE_MODULE.xor(1, 1.0)
        # Test stderr
        captured = capsys.readouterr()
        assert "xor" in captured.err

    def test_xor3(self, capsys):
        """Ensure xor3 works as expected"""
        debug.trace(4, f"test_xor3(): self={self}")
        THE_MODULE.set_level(7)
        # Test the XOR table
        assert not THE_MODULE.xor3(0, 0, 0)
        assert THE_MODULE.xor3(0, 0, 1)
        assert THE_MODULE.xor3(0, 1, 0)
        assert not THE_MODULE.xor3(0, 1, 1)
        assert THE_MODULE.xor3(1, 0, 0)
        assert not THE_MODULE.xor3(1, 0, 1)
        assert not THE_MODULE.xor3(1, 1, 0)
        assert not THE_MODULE.xor3(1, 1, 1)
        # Test stderr
        captured = capsys.readouterr()
        assert "xor3" in captured.err

    def test_init_logging(self):
        """Ensure init_logging works as expected"""
        debug.trace(4, f"test_init_logging(): self={self}")
        ## TODO: WORK-IN-PROGRESS

    def test_profile_function(self):
        """Ensure profile_function works as expected"""
        debug.trace(4, f"test_profile_function(): self={self}")
        ## TODO: WORK-IN-PROGRESS

    def test_reference_var(self):
        """Ensure reference_var works as expected"""
        debug.trace(4, f"test_reference_var(): self={self}")
        ## TODO: WORK-IN-PROGRESS

    def test_clip_value(self):
        """Ensure clip_value works as expected"""
        debug.trace(4, f"test_clip_value(): self={self}")
        assert THE_MODULE.clip_value('helloworld', 5) == 'hello...'
        assert THE_MODULE.clip_value('12345678910111213141516', 7) == '1234567...'

    def test_read_line(self):
        """Ensure read_line works as expected"""
        debug.trace(4, f"test_read_line(): self={self}")
        ## TODO: WORK-IN-PROGRESS

    def test_debug_init(self):
        """Ensure debug_init works as expected"""
        debug.trace(4, f"test_debug_init(): self={self}")
        ## TODO: WORK-IN-PROGRESS

    def test_display_ending_time_etc(self):
        """Ensure display_ending_time_etc works as expected"""
        debug.trace(4, f"test_display_ending_time_etc(): self={self}")
        ## TODO: WORK-IN-PROGRESS

    def test_visible_simple_trace(self, capsys):
        """Make sure level-1 trace outputs to stderr"""
        debug.trace(4, f"test_visible_simple_trace({capsys})")
        self.setup_simple_trace()
        if not __debug__:
            self.expected_stderr_trace = ""
        pre_captured = capsys.readouterr()
        save_trace_level = THE_MODULE.get_level()
        THE_MODULE.set_level(4)
        print(self.stdout_text)
        THE_MODULE.trace(3, self.stderr_text)
        THE_MODULE.set_level(save_trace_level)
        captured = capsys.readouterr()
        assert(captured.out == self.expected_stdout_trace)
        assert(captured.err == self.expected_stderr_trace)
        THE_MODULE.trace_expr(6, pre_captured, captured)

    def test_hidden_simple_trace(self, capsys):
        """Make sure level-N+1 trace doesn't output to stderr"""
        debug.trace(4, f"test_hidden_simple_trace({capsys})")
        self.setup_simple_trace()
        ## TEST
        ## capsys.stop_capturing()
        ## capsys.start_capturing()
        pre_captured = capsys.readouterr()
        self.expected_stderr_trace = ""
        save_trace_level = THE_MODULE.get_level()
        THE_MODULE.set_level(0)
        print(self.stdout_text)
        THE_MODULE.trace(1, self.stderr_text)
        captured = capsys.readouterr()
        THE_MODULE.set_level(save_trace_level)
        assert captured.out == self.expected_stdout_trace
        assert captured.err == self.expected_stderr_trace
        THE_MODULE.trace_expr(6, pre_captured, captured)


#------------------------------------------------------------------------

if __name__ == '__main__':
    debug.trace_current_context()
    pytest.main([__file__])
