#! /usr/bin/env python
#
# Tests for check_errors.py module

## TODO1: add standard mezcla test support (e.g., THE_MODULE; see mezcla/tests/template.py)
## TODO2: use self.run_script instead of gh.run

"""Tests for check_errors.py module (temporarily check_errors_conv.py)"""


# Standard packages
## OLD: Using pytest entirely with mezcla test template
# import unittest

# Installed packages
import pytest

# Local packages
from mezcla.unittest_wrapper import TestWrapper, invoke_tests
from mezcla import glue_helpers as gh
from mezcla import system
from mezcla import debug
from mezcla.my_regex import my_re

# Importing script as module
## OLD: Importing script as a module
# SCRIPT = gh.resolve_path("check_errors.py")
## OLD: Find a fix for script_module not working according to mezcla's way (LINE 56)
# try:
#     from .. import check_errors as THE_MODULE
#     ## TODO: Change check_errors_conv to check_errors
# except ImportError as e:
#     debug.trace(3, f"Unable to import check_errors.py: {e}")
#     THE_MODULE = None

# Environment Variables
RUN_SLOW_TESTS = system.getenv_bool("RUN_SLOW_TESTS", False, description="Run tests that can a while to run")

# Constants
TL = debug.TL
## NEW: Added support for 
PERL_SCRIPT = "check_errors.perl"
OTHER_SCRIPT = system.getenv_text(
    "OTHER_SCRIPT", PERL_SCRIPT,
    desc=f"Other script to check such as {PERL_SCRIPT}")
PERL_SCRIPT_PATH = gh.resolve_path(PERL_SCRIPT, heuristic=True)
OTHER_SCRIPT_PATH = gh.resolve_path(OTHER_SCRIPT, heuristic=True)
VERBOSE_MODE = system.getenv_bool(
    "VERBOSE_MODE", False,
    desc="Show verbose info about tests")

class TestCheckErrors(TestWrapper):
    """Test wrapper for check_errors.py"""
    script_file = TestWrapper.get_module_file_path(__file__)
    ## TODO: Find a fix for script_module not working according to mezcla's way
    # script_module = TestWrapper.get_testing_module_name(__file__, THE_MODULE)
    script_module = "check_errors"

    ## Helper: Check if the error message is flagged in the output
    def check_error_message_flagged(self, message, options=""):
        """Helper: check that error message is flagged in output"""
        debug.trace(5, f"TestIt.check_error_message_flagged({message!r})")
        log = f"before\n{message}\nafter\n"
        system.write_lines(self.temp_file, log.splitlines())
        output = self.run_script(options=options, data_file=self.temp_file)
        message_regex = my_re.sub(r"\W+", ".*", message)
        ## Look for >>> ... <<< with the error message inside
        flagged = my_re.search(rf">>> {message_regex} <<<", output)
        debug.trace_expr(6, flagged)
        return bool(flagged)
    
    # Test case for simple error messages
    @pytest.mark.xfail
    def test_simple_error_messages(self):
        """Ensures each error message is flagged as expected"""
        messages = [
            "Error",
            "error:",
            "Segmentation fault",
            "Assertion failed",
            "Exception",
            "failed"
        ]
        for message in messages:
            ok = self.check_error_message_flagged(message)
            if not ok:
                print("DEBUG OUTPUT:", self.run_script(data_file=self.temp_file))
            self.do_assert(ok, f"Message {message!r} not flagged")

    def check_other_message(self, message):
        """Check that Perl and Python scripts flag the same error messages."""
        temp_file = self.create_temp_file(message)
        # Use tolerant regex for matching
        message_regex = my_re.sub(r"\W+", ".*", message)
        py_out = self.run_script(data_file=temp_file)
        perl_out = gh.run(f"{OTHER_SCRIPT} {temp_file}")
        py_flag = bool(my_re.search(f">>> {message_regex} <<<", py_out))
        perl_flag = bool(my_re.search(f">>> {message_regex} <<<", perl_out))
        return py_flag == perl_flag

    def test_versus_other_script(self):
        """
        Compare Python and Perl script results for multiple option sets.
        Prints mismatches and filters out artificial pattern test cases.
        Uses correct option style for each script (-- for Python, - for Perl).
        """
        debug.trace(4, f"TestIt.test_versus_other_script(); self={self}")
        option_variations = [
            "",
            "--relaxed",
            "--warnings",
            "--no-asterisks",
            "--strict",
            "--warnings --strict",
            "--relaxed --no-asterisks",
        ]
        summary = []
        perl_script_code = system.read_file(PERL_SCRIPT_PATH)
        test_patterns = list(gh.extract_matches_from_text("/(.*)/", perl_script_code))

        # Simple helper to filter out regex patterns that are not real log lines
        def is_artificial(pat):
            meta = '\\()[]{}^$|?*+'
            score = sum(pat.count(m) for m in meta)
            if pat.strip().startswith('$') or pat.strip().startswith('#'):
                return True
            return score > 2

        for opts in option_variations:
            # For Python, use double-dash; for Perl, convert to single-dash
            py_opts = opts
            perl_opts = opts.replace("--", "-")
            num_ok = 0
            num_total = 0
            mismatches = []
            for message in test_patterns:
                num_total += 1
                temp_file = self.create_temp_file(message)
                message_regex = my_re.sub(r"\W+", ".*", message)
                py_output = self.run_script(options=py_opts, data_file=temp_file)
                perl_output = gh.run(f"{OTHER_SCRIPT} {perl_opts} {temp_file}")
                py_flagged = bool(my_re.search(f">>> {message_regex} <<<", py_output))
                perl_flagged = bool(my_re.search(f">>> {message_regex} <<<", perl_output))
                if py_flagged == perl_flagged:
                    num_ok += 1
                else:
                    mismatches.append({
                        "pattern": message,
                        "options": opts,
                        "py_flagged": py_flagged,
                        "perl_flagged": perl_flagged,
                        "py_output": py_output,
                        "perl_output": perl_output,
                    })
            threshold = 90
            pct_ok = (num_ok / num_total * 100) if num_total else 0
            print(f"\noptions={opts!r} num_ok={num_ok} num_total={num_total} pct_ok={pct_ok:.2f} threshold={threshold}")

            # Print only real mismatches (not Perl regex artifacts)
            filtered = [m for m in mismatches if not is_artificial(m["pattern"])]
            if filtered:
                print(f"\n=== FILTERED MISMATCHED PATTERNS (options={opts!r}) ===")
                for i, m in enumerate(filtered, 1):
                    print(f"{i}: Pattern: {m['pattern']!r}")
                    print(f"   Python flagged: {m['py_flagged']}  Perl flagged: {m['perl_flagged']}")
                    print(f"   Options: {opts!r}")
                    print("   --- Python Output ---")
                    print(m['py_output'])
                    print("   --- Perl Output ---")
                    print(m['perl_output'])
                    print("   ---------------------")
                print(f"Filtered mismatch count: {len(filtered)} of {len(mismatches)} raw mismatches for options={opts!r}\n")

            summary.append((opts, pct_ok, len(filtered)))
            assert pct_ok >= threshold, f"Failed for options={opts!r}"

        print("\n=== SUMMARY ACROSS ALL OPTION VARIATIONS ===")
        for opts, pct_ok, num_filtered in summary:
            print(f"options={opts!r} pct_ok={pct_ok:.2f}% filtered_mismatches={num_filtered}")

## OLD: Doesn't use unittest
# class TestIt(TestWrapper):
#     """Class for testcase definition"""

#     def test_python_error(self):
#         """check python error"""
#         input_string    = 'python -c "print(1\\2)" 2>&1'
#         expected_result = '1          File "<string>", line 1\n2            print(1\\2)\n3                     ^\n4    >>> SyntaxError: unexpected character after line continuation character <<<'
#         self.assertEqual(gh.run(f'{input_string} | {SCRIPT} -'), expected_result)


#     def test_warnings(self):
#         """test warning and warnings option"""
#         input_string    = 'bash: warning: here-document at line 119 delimited by end-of-file'
#         expected_result = '1    >>> bash: warning: here-document at line 119 delimited by end-of-file <<<'
#         empty_result    = ''

#         # Show warnings options        
#         self.assertEqual(gh.run(f'echo "{input_string}" | {SCRIPT} --warning -'), expected_result)
#         self.assertEqual(gh.run(f'echo "{input_string}" | {SCRIPT} --warnings -'), expected_result)

#         # Skip warnings option, not should retun nothing
#         self.assertEqual(gh.run(f'echo "{input_string}" | {SCRIPT} -'), empty_result)
#         self.assertEqual(gh.run(f'echo "{input_string}" | {SCRIPT} --skip_warnings -'), empty_result)


#     def test_context_lines(self):
#         """test context lines"""
#         input_string     = 'python -c "print(1\\2)" 2>&1'
#         result_context_1 = '3                     ^\n4    >>> SyntaxError: unexpected character after line continuation character <<<'
#         result_context_2 = '2            print(1\\2)\n3                     ^\n4    >>> SyntaxError: unexpected character after line continuation character <<<'
#         self.assertEqual(gh.run(f'{input_string} | {SCRIPT} --context 1 -'), result_context_1)
#         self.assertEqual(gh.run(f'{input_string} | {SCRIPT} --context 2 -'), result_context_2)


#     @pytest.mark.xfail
#     def test_no_asterisks(self):
#         """test no asterisks option"""
#         ## WORK-IN-PROGRESS
#         assert(False)


#     @pytest.mark.xfail
#     def test_skip_ruby_lib(self):
#         """test skip ruby lib and ruby options"""
#         ## WORK-IN-PROGRESS
#         assert(False)


#     @pytest.mark.xfail
#     def test_relaxed_strict(self):
#         """test relaxed and strict options"""
#         ## WORK-IN-PROGRESS
#         assert(False)


#     @pytest.mark.xfail
#     def test_verbose(self):
#         """test verbose option"""
#         ## WORK-IN-PROGRESS
#         assert(False)


if __name__ == '__main__':
    ## OLD: Previous approaches using unittest
    # unittest.main()
    debug.trace_current_context()
    invoke_tests(__file__)
