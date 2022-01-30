#! /usr/bin/env python
#
# Tests for extract_matches.py module


"""Tests for extract_matches.py module"""


# Standart packages
import unittest


# Local packages
from mezcla.unittest_wrapper import TestWrapper
from mezcla import glue_helpers as gh


class TestIt(TestWrapper):
    """Class for testcase definition"""
    script_module = TestWrapper.derive_tested_module_name(__file__) + '.py'


    def test_extract_matches(self):
        """test extract file matches"""
        input_string    = 'acl.sh add_arrows.sh add_frequencies.perl adhoc-rainbow-test.sh ai-cat-guesser.perl all_script_alias.sh alt-randomize-lines.perl'
        expected_result = 'acl.sh\nadd_arrows.sh\nadhoc-rainbow-test.sh\nall_script_alias.sh'
        self.assertEqual(gh.run(f'echo "{input_string}" | tr " " "\\n" | {self.script_module} "^(.*\\.(sh|lisp))"'), expected_result)


    def test_extract_matches_two(self):
        """test extract matches"""
        input_string    = '  cat\n  dog\n  cat\n  whale'
        expected_result = 'cat\ndog\ncat\nwhale'
        filename        = '/tmp/test_file.txt '
        gh.run(f'touch {filename} && echo "{input_string}" > {filename}')
        self.assertEqual(gh.run(f'{self.script_module} "^\\s*(\\S+)" {filename}'), expected_result)


    def test_auto_pattern(self):
        """test auto pattern"""
        input_string    = 'acl.sh add_arrows.sh add_frequencies.perl adhoc-rainbow-test.sh ai-cat-guesser.perl all_script_alias.sh alt-randomize-lines.perl'
        expected_result = gh.run(f'echo "{input_string}" | tr " " "\n"')
        self.assertEqual(gh.run(f'echo "{input_string}" | {self.script_module} "-"'), expected_result)


    def test_replacement(self):
        """test replacement option"""
        input_string    = '13 dog, 45 cat, 1 whale, 34 cows'
        expected_result = 'animal:dog\tquantity:13\nanimal:cat\tquantity:45\nanimal:whale\tquantity:1\nanimal:cows\tquantity:34'
        self.assertEqual(gh.run(f'echo "{input_string}" | {self.script_module} --replacement "animal:{{{{match.group(2)}}}}\tquantity:{{{{match.group(1)}}}}" "(\\d+) (\\w+)"'), expected_result)


    def test_restore(self):
        """test restore option"""
        ## WORK-IN-PROGRESS


    def test_fields(self):
        """test fields option"""
        input_string    = '13 dog, 45 cat, 1 whale, 34 cows'
        expected_result = '13\tdog\n45\tcat\n1\twhale\n34\tcows'
        self.assertEqual(gh.run(f'echo "{input_string}" | {self.script_module} --fields 2 "(\\d+) (\\w+)"'), expected_result)


    def test_one_per_line(self):
        """test one_per_line option"""
        ## WORK-IN-PROGRESS


    def test_multi_per_line(self):
        """test one_per_line option"""
        ## WORK-IN-PROGRESS


    def test_max_count(self):
        """test max_count option"""
        input_string    = ' dog cat whale hamster cat cat dog'
        expected_result = 'dog\ncat\nwhale\nhamster'
        self.assertEqual(gh.run(f'echo "{input_string}" | {self.script_module} --max_count 4 "\\w+"'), expected_result)


    def test_ignore_case(self):
        """test ignore_case option"""
        ## WORK-IN-PROGRESS


    def test_preserve(self):
        """test preseve option"""
        ## WORK-IN-PROGRESS


    def test_chomp(self):
        """test strip newline at end with option: chomp"""
        ## WORK-IN-PROGRESS



if __name__ == '__main__':
    unittest.main()
