#! /usr/bin/env python
#
# Tests for batspp.py module


"""Tests for batspp.py module"""


# Standart packages
import unittest
import random


# Local packages
from mezcla.unittest_wrapper import TestWrapper
from mezcla import glue_helpers as gh
from mezcla import debug


class TestIt(TestWrapper):
    """Class for testcase definition"""
    script_module     = TestWrapper.derive_tested_module_name(__file__) + '.py'
    use_temp_base_dir = True


    def setUp(self):
        """Per-test setup"""
        debug.trace(debug.QUITE_DETAILED, f"TestIt.setUp(); self={self}")
        super().setUp()
        gh.write_file(self.temp_file, 'some content')
        debug.assertion(self.temp_file)
        gh.run(f'chmod +x {self.temp_file}')


    def test_assert_equal(self):
        """Test for assert_equal [actual] [value]"""

        # Test assertion
        test_content = (f'#! ./{self.script_module}\n'
                        'test "this should work" { assert_equals 10 10; }\n')
        gh.write_file(self.temp_file, test_content)
        expected_result = '1..1\nok 1 this should work'
        self.assertEqual(gh.run(f'{self.temp_file}'), expected_result)

        # Test assertion fail
        test_content = (f'#! ./{self.script_module}\n'
                        'test "this should not work" { assert_equals 6 78; }\n')
        gh.write_file(self.temp_file, test_content)
        expected_result = '1..1\nnot ok 1 this should not work\n'
        self.assertTrue(expected_result in gh.run(f'{self.temp_file}'))


    def test_assert_not_equal(self):
        """Test for assert_not_equal [actual] [value]"""
        debug.trace(debug.DETAILED, f"TestIt.test_assert_not_equal({self})")

        # Test assertion
        test_content = (f'#! ./{self.script_module}\n'
                        'test "this should work" { assert_not_equals 6 34; }\n')
        gh.write_file(self.temp_file, test_content)
        expected_result = '1..1\nok 1 this should work'
        self.assertEqual(gh.run(f'{self.temp_file}'), expected_result)

        # Test assertion fail
        test_content = (f'#! ./{self.script_module}\n'
                        'test "this should not work" { assert_not_equals 10 10; }\n')
        gh.write_file(self.temp_file, test_content)
        expected_result = '1..1\nnot ok 1 this should not work\n'
        self.assertTrue(expected_result in gh.run(f'{self.temp_file}'))


    def test_multiple_tests(self):
        """Test for multiple tests"""
        debug.trace(debug.DETAILED, f"TestIt.test_multiple_tests({self})")

        test_content = (f'#! ./{self.script_module}\n'
                        'test "some test" { assert_equals 10 10; }\n'
                        'test "another test" {\n'
                        '    assert_not_equals 123 543\n'
                        '}\n')
        gh.write_file(self.temp_file, test_content)
        expected_result = '1..2\nok 1 some test\nok 2 another test'
        self.assertEqual(gh.run(f'{self.temp_file}'), expected_result)


    def test_execution_path(self):
        """Test for execution file paths"""

        source_filename = self.temp_base + '/source_file.bash'
        alias_name      = 'test-alias-' + str(random.randint(0000000, 9999999))
        alias_message    = 12312313
        gh.write_file(source_filename, f'alias {alias_name}="echo {alias_message}"')

        test_content = (f'#! ./{self.script_module}\n'
                        f'setup() {{ shopt -s expand_aliases\nsource {source_filename}; }}\n'
                        f'test "test alias from source file" {{ assert_equals $({alias_name}) "{alias_message}"; }}')
        gh.write_file(self.temp_file, test_content)

        expected_result = '1..1\nok 1 test alias from source file'
        self.assertEqual(gh.run(f'{self.temp_file}'), expected_result)


if __name__ == '__main__':
    unittest.main()
