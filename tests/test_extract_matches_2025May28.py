#! /usr/bin/env python3

"""Tests for extract-matches.py module"""

# Standard modules

# Installed modules
import pytest

# Local modules
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.my_regex import my_re
from mezcla import system
from mezcla.unittest_wrapper import TestWrapper, invoke_tests

script_name = '../extract_matches.py'
SCRIPT = gh.resolve_path(script_name)

## TODO:
## # Environment options
## # Note: These are just intended for internal options, not for end users.
## # It also allows for enabling options in one place.
## #
## FUBAR = system.getenv_bool(
##     "FUBAR", False,
##     description="Fouled Up Beyond All Recognition processing")

#------------------------------------------------------------------------

class TestExtractMatches(TestWrapper):
    """Class for command-line based testcase definition"""
    # note: script_module used in argument parsing sanity check (e.g., --help)
    script_module = TestWrapper.get_testing_module_name(__file__, SCRIPT)
    use_temp_base_dir = True

    @pytest.mark.xfail
    def test_simple_word_match(self):
        """Tests if simple word matching works as expected"""
        debug.trace(4, f"TestExtractMatches.test_simple_word_match(); self={self}")
        test_string = "hello world 12345"
        command = f"echo \"{test_string}\" | {SCRIPT} '\w+'"
        result = gh.run(command)
        self.assertEqual(test_string.replace(" ", "\n"), result)
    
    @pytest.mark.xfail
    def test_option_multi_per_line(self):
        """Tests if --multi_per_line option works as expected"""
        debug.trace(4, f"TestExtractMatches.test_option_multi_per_line(); self={self}")
        test_string = "hello world 12345"
        command = f"echo \"{test_string}\" | {SCRIPT} --multi_per_line '\w+'"
        result = gh.run(command)
        self.assertEqual(test_string.replace(" ", "\n"), result)

    @pytest.mark.xfail
    def test_option_max_count(self):
        """Tests if --max_count option works as expected"""
        debug.trace(4, f"TestExtractMatches.test_option_max_count(); self={self}")
        test_string = "1 2 3 4 5"
        command = f"echo \"{test_string}\" | {SCRIPT} --max_count=3 '(\d+)'"
        result = gh.run(command)
        self.assertEqual("1\n2\n3", result)

    @pytest.mark.xfail
    def test_option_file(self):
        """Tests if file options work as expected"""
        debug.trace(4, f"TestExtractMatches.test_option_file(); self={self}")
        contents = "Hello 123 Content 45 Python"
        temp_file = gh.create_temp_file(contents)
        command = f"{SCRIPT} --file '(\d+)' {temp_file}"
        result = gh.run(command)
        self.assertEqual(result, "123\n45")
    
    @pytest.mark.xfail
    def test_extract_file_matches(self):
        """Tests if file extraction matches as expected"""
        debug.trace(4, f"TestExtractMatches.test_extract_file_matches(); self={self}")
        input_string = 'acl.sh add_arrows.sh extract_matches.perl adhoc-rainbow-test.sh ai-cat-guesser.perl template.sh alt-randomize-lines.perl'
        output_string = "acl.sh\nadd_arrows.sh\nadhoc-rainbow-test.sh\ntemplate.sh"
        command = f'echo "{input_string}" | tr " " "\\n" | {SCRIPT} "^(.*\\.(sh|lisp))"'
        result = gh.run(command)
        self.assertEqual(result, output_string)

    @pytest.mark.xfail
    def test_no_matches(self):
        """Tests if test works for no matches"""
        debug.trace(4, f"TestExtractMatches.test_auto_pattern(); self={self}")
        command = f'echo "no match" | ./extract_matches.py \'(apple)\''
        result = gh.run(command)
        self.assertEqual(result, '')

    @pytest.mark.xfail
    def test_option_replacement(self):
        """Tests if replacement option works as expected"""
        debug.trace(4, f"TestExtractMatches.test_option_replacement(); self={self}")
        input_string = "13 dog, 45 cat, 1 whale, 34 cows"
        expected_result = 'animal:dog\tquantity:13\nanimal:cat\tquantity:45\nanimal:whale\tquantity:1\nanimal:cows\tquantity:34'
        command = f"echo \"{input_string}\" | {SCRIPT} --replacement='animal:$2\tquantity:$1' '(\d+) (\w+)'"
        result = gh.run(command)
        self.assertEqual(result, expected_result)
    
    @pytest.mark.xfail
    def test_option_fields(self):
        """Tests if fields option works as expected"""
        debug.trace(4, f"TestExtractMatches.test_option_fields(); self={self}")
        input_string = "13 dog, 45 cat, 1 whale, 34 cows"
        expected_result = '13\tdog\n45\tcat\n1\twhale\n34\tcows'
        command = f"echo \"{input_string}\" | {SCRIPT} --fields=2 '(\\d+)\\s+(\\w+)'"
        result = gh.run(command)
        self.assertEqual(result, expected_result)
    
    @pytest.mark.xfail
    def test_option_fields_autopattern(self):
        """Tests if fields option works as expected with autopattern enabled"""
        debug.trace(4, f"TestExtractMatches.test_option_fields_autopattern(); self={self}")
        input_string = "apple\tred\nbanana\tyellow"
        command = f"echo \"{input_string}\" | {SCRIPT} --fields=2 '-'"
        result = gh.run(command)
        self.assertEqual(result, input_string)
    
    @pytest.mark.xfail
    def test_option_fields_autopattern_infinite_loop(self):
        """Tests if fields option throws exception for autopattern under fields=1"""
        debug.trace(4, f"TestExtractMatches.test_option_fields_autopattern_infinite_loop(); self={self}")
        input_string = "apple\tred\nbanana\tyellow"
        error_msg = "ValueError: Pattern may cause infinite loop: pattern matches everything."
        command = f"echo \"{input_string}\" | {SCRIPT} --fields=1 '-'"
        result = gh.run(command)
        self.assertIn(error_msg, result)
    
    @pytest.mark.xfail
    def test_option_ignore(self):
        """Tests if ignore option works as expected"""
        debug.trace(4, f"TestExtractMatches.test_option_ignore(); self={self}")
        input_string = "Hello WORLD test"
        expected_output = "WORLD"
        command = f"echo \"{input_string}\" | {SCRIPT} --i 'w(\w+)'"
        result = gh.run(command)
        self.assertEqual(expected_output, result)
    
    @pytest.mark.xfail
    def test_option_chomp(self):
        """Tests if chomp option works as expected"""
        debug.trace(4, f"TestExtractMatches.test_option_chomp(); self={self}")
        input_string = "Hello WORLD test"
        expected_output = "WORLD"
        command = f"echo \"{input_string}\" | {SCRIPT} --i 'w(\w+)'"
        result = gh.run(command)
        self.assertEqual(expected_output, result)
    
#------------------------------------------------------------------------

if __name__ == '__main__':
    debug.trace_current_context()
    invoke_tests(__file__)