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
        gh.run(f'touch {self.temp_file} && echo "{input_string}" > {self.temp_file}')
        self.assertEqual(gh.run(f'{self.script_module} "^\\s*(\\S+)" {self.temp_file}'), expected_result)


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


    def test_n_per_line(self):
        """test one_per_line and multi_per_line options"""
        input_string      = 'there are one cement truck and two oil truck\nthere are three truck and one car'
        expected_single   = "truck\ntruck"
        expected_multiple = 'truck\ntruck\ntruck'
        self.assertEqual(gh.run(f'echo "{input_string}" | {self.script_module} --single "truck"'), expected_single)
        self.assertEqual(gh.run(f'echo "{input_string}" | {self.script_module} --one_per_line "truck"'), expected_single)
        self.assertEqual(gh.run(f'echo "{input_string}" | {self.script_module} --multi_per_line "truck"'), expected_multiple)


    def test_max_count(self):
        """test max_count option"""
        input_string    = ' dog cat whale hamster cat cat dog'
        expected_result = 'dog\ncat\nwhale\nhamster'
        self.assertEqual(gh.run(f'echo "{input_string}" | {self.script_module} --max_count 4 "\\w+"'), expected_result)


    def test_ignore_case(self):
        """test ignore_case option"""
        input_string       = 'there are one cement truck and two oil tRuck\nthere are three Truck and one car'
        expected_ignore    = 'truck\ntruck\ntruck'
        self.assertNotEqual(gh.run(f'echo "{input_string}" | {self.script_module} "truck"'), expected_ignore)
        self.assertEqual(gh.run(f'echo "{input_string}" | {self.script_module} --i "truck"'), expected_ignore)


    def test_preserve(self):
        """test preseve option"""
        input_string    = 'there are one cement tRucK'
        expected_result = 'tRucK'
        self.assertEqual(gh.run(f'echo "{input_string}" | {self.script_module} --i --preserve "truck"'), expected_result)


    def test_chomp(self):
        """test strip newline at end with option: chomp"""
        ## WORK-IN-PROGRESS


if __name__ == '__main__':
    unittest.main()
