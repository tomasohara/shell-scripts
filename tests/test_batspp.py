#! /usr/bin/env python
#
# Tests for batspp.py module
#


"""Tests for batspp.py module"""


# Standard packages
import unittest
import sys
import re


# Local packages
from mezcla.unittest_wrapper import TestWrapper
from mezcla import glue_helpers as gh
from mezcla import debug


# Module being tested
sys.path.append('..')
import batspp


class TestIt(TestWrapper):
    """Class for testcase definition"""
    script_module     = TestWrapper.derive_tested_module_name(__file__) + '.py'
    use_temp_base_dir = True
    maxDiff           = None


    def setUp(self):
        """Per-test setup"""
        debug.trace(debug.QUITE_DETAILED, f"TestIt.setUp(); self={self}")
        super().setUp()
        gh.write_file(self.temp_file, 'some content')
        debug.assertion(self.temp_file)
        gh.run(f'chmod +x {self.temp_file}')


    def test_extract_test_data(self):
        """Test for extract_test_data()"""
        debug.trace(debug.DETAILED, f"TestIt.test_extract_test_data({self})")

        text = ('# Test setup and title\n'
                '# $ filepath=$(echo $TMP/testfile-"$$")\n'
                '# $ echo "this is a file content to run an example test" | sudo tee $filepath\n'
                '# $ cat $filepath\n'
                '# this is a file content to run an example test\n'
                '# Continue\n'
                '# $ cat $filepath | wc -c\n'
                '# 46\n'
                '#\n\n')

        expected = [('title', 'setup and title'),
                    ('setup', 'filepath=$(echo $TMP/testfile-"$$")'),
                    ('setup', 'echo "this is a file content to run an example test" | sudo tee $filepath'),
                    ('assert_eq', 'cat $filepath', 'this is a file content to run an example test'),
                    ('assert_eq', 'cat $filepath | wc -c', '46')]

        # pattern used: https://regex101.com/r/a4psxP/1
        pattern = r'^# *(?:(?:\$ *(?P<setup>[^\n]+) *$\n(?=(?:^# \$ *[^\n]+)?$\n))|(?:(?P<assert_eq>\$) *(?P<actual>[^\n]+) *$\n(?=^# *\w+))|(?:(?:[Tt]est +(?P<title>.+?)$\n)|[Cc]ontinue|[Cc]ontinuation|[Ss]etup)|(?:(?P<expected>[^\n]+)$\n))'
        flags   = re.DOTALL | re.MULTILINE

        self.assertEqual(batspp.extract_test_data(pattern, flags, text), expected)


    def test_format_bats_test(self):
        """Test for format_bats_test()"""
        debug.trace(debug.DETAILED, f"TestIt.test_format_bats_test({self})")

        data = [('title', 'setup and title'),
                ('setup', 'filepath=$(echo $TMP/testfile-"$$")'),
                ('setup', 'echo "this is a file content to run an example test" | sudo tee $filepath'),
                ('assert_eq', 'cat $filepath', 'this is a file content to run an example test'),
                ('assert_eq', 'cat $filepath | wc -c', '46')]
        expected = ('@test "setup and title" {\n'
                    '\ttest_folder=$(echo /tmp/setup-and-title-$$)\n'
                    '\tmkdir $test_folder && cd $test_folder\n\n'
                    '\tfilepath=$(echo $TMP/testfile-"$$")\n'
                    '\techo "this is a file content to run an example test" | sudo tee $filepath\n'
                    '\tactual=$(setup-and-title-3-actual)\n'
                    '\texpected=$(setup-and-title-3-expected)\n'
                    '\techo "========== actual =========="\n'
                    '\techo "$actual" | hexview.perl\n'
                    '\techo "========= expected ========="\n'
                    '\techo "$expected" | hexview.perl\n'
                    '\techo "============================"\n'
                    '\t[ "$actual" == "$expected" ]\n\n'
                    '\tactual=$(setup-and-title-4-actual)\n'
                    '\texpected=$(setup-and-title-4-expected)\n'
                    '\techo "========== actual =========="\n'
                    '\techo "$actual" | hexview.perl\n'
                    '\techo "========= expected ========="\n'
                    '\techo "$expected" | hexview.perl\n'
                    '\techo "============================"\n'
                    '\t[ "$actual" == "$expected" ]\n\n'
                    '}\n\n'
                    'function setup-and-title-3-actual () {\n'
                    '\tcat $filepath\n'
                    '}\n'
                    'function setup-and-title-3-expected () {\n'
                    '\techo -e \'this is a file content to run an example test\'\n'
                    '}\n'
                    'function setup-and-title-4-actual () {\n'
                    '\tcat $filepath | wc -c\n'
                    '}\n'
                    'function setup-and-title-4-expected () {\n'
                    '\techo -e \'46\'\n'
                    '}\n\n')

        self.assertEqual(batspp.format_bats_test(data), expected)


    def test_get_bash_function(self):
        """Test get_bash_function()"""
        debug.trace(debug.DETAILED, f"TestIt.get_bash_function({self})")

        name     = 'fibonacci'
        content  = ('result=""\n'
                    'a=0\n'
                    'b=1\n'
                    'for (( i=0; i<=$1; i++ ))\n'
                    'do\n'
                    '\tresult="$result$a "\n'
                    '\tfn=$((a + b))\n'
                    '\ta=$b\n'
                    '\tb=$fn\n'
                    'done\n'
                    'echo $result')
        expected = (f'function {name} () {{\n'
                    '\tresult=""\n'
                    '\ta=0\n'
                    '\tb=1\n'
                    '\tfor (( i=0; i<=$1; i++ ))\n'
                    '\tdo\n'
                    '\t\tresult="$result$a "\n'
                    '\t\tfn=$((a + b))\n'
                    '\t\ta=$b\n'
                    '\t\tb=$fn\n'
                    '\tdone\n'
                    '\techo $result\n'
                    '}\n')

        self.assertEqual(batspp.get_bash_function(name, content), expected)


    def test_replace_tags(self):
        """Test replace_tags(TAGS, test)"""
        debug.trace(debug.DETAILED, f"TestIt.process_tags({self})")
        tags     = [('<blank>', ' '),
                    ('<blank-line>', '\n')]
        text     = ('#<blank>Tests<blank>with<blank>simple<blank>"#"\n'
                    '#<blank>on<blank>.batspp<blank>files<blank>are<blank>ignored\n'
                    '<blank-line>'
                    '$<blank>echo<blank>"this<blank>is<blank>a<blank>ignored<blank>test"<blank>|<blank>wc<blank>-c\n'
                    '15\n'
                    '<blank-line>')
        expected = ('# Tests with simple "#"\n'
                    '# on .batspp files are ignored\n'
                    '\n'
                    '$ echo "this is a ignored test" | wc -c\n'
                    '15\n'
                    '\n')

        self.assertEqual(batspp.replace_tags(tags, text), expected)


    def test_simple_assert(self):
        """End to end test for simple assert"""
        debug.trace(debug.DETAILED, f"TestIt.test_simple_assert({self})")

        ## TODO: WORK-IN-PROGRESS

        test_file   = self.temp_file + '.batspp'
        result_file = self.temp_file + '.result'

        content = ('$ echo "hello world"\n'
                   'hello<blank>world\n\n')

        gh.write_file(test_file, content)
        gh.run(f'python {self.script_module} --output {result_file} {test_file}')

        result   = gh.read_file(result_file)
        expected = ('')
        ## self.assertEqual(result, expected)


    def test_multiple_assertion(self):
        """End to end test for multiple assertion"""
        debug.trace(debug.DETAILED, f"TestIt.test_multiple_assertion({self})")
        ## TODO: set specific pattern.
        ## TODO: WORK-IN-PROGRESS

        ## OLD
        ##test_content = (f'#! ./{self.script_module}\n'
        ##                'test "some test" { assert_equals 10 10; }\n'
        ##                'test "another test" {\n'
        ##                '    assert_not_equals 123 543\n'
        ##                '}\n')
        ##gh.write_file(self.temp_file, test_content)
        ##expected_result = '1..2\nok 1 some test\nok 2 another test'
        ##self.assertEqual(gh.run(f'{self.temp_file}'), expected_result)


    def test_assert_eq(self):
        """End to end test for assertion: [actual] eq [value]"""
        debug.trace(debug.DETAILED, f"TestIt.test_assert_eq({self})")
        ## TODO: WORK-IN-PROGRESS
        ## TODO: set specific pattern.

        test_file   = f'{self.temp_base}/test.batspp'
        result_file = f'{self.temp_base}/result.bats'

        test_content = ('# Test assert_eq\n'
                        '$ echo "helloworld"\n'
                        'helloworld\n')
        expected     = ('@Test "assert_eq" {\n'
                        '\tactual'
                        ''
                        '')

        gh.write_file(test_file, test_content)
        gh.run(f'python {self.script_module} --output {result_file} {self.temp_file}')
        ## self.assertEqual(gh.read_file(result_file), expected)


    def test_assert_ne(self):
        """End to end test for assertion: [actual] ne [value]"""
        debug.trace(debug.DETAILED, f"TestIt.test_assert_ne({self})")
        ## TODO: WORK-IN-PROGRESS
        ## TODO: set specific pattern.


    def test_directives(self):
        """End to end directives Title, Setup and Continuation"""
        debug.trace(debug.DETAILED, f"TestIt.test_title_directive({self})")

        test_file   = self.temp_file + '.bash'
        result_file = self.temp_file + '.result'

        test_content = ('# Setups can be done with command lines too without output\n'
                        '# and you can also add optional titles:\n'
                        '#\n'
                        '# Test setup and title\n'
                        '# $ filepath=$(echo $TMP/testfile-"$$")\n'
                        '# $ echo "this is a file content to run an example test" | sudo tee $filepath\n'
                        '#\n'
                        '# If you want to append another assertions or setup to the last test\n'
                        '# you can use Setup, Continuation or Continue tags, for example:\n'
                        '#\n'
                        '# Continue\n'
                        '# $ cat $filepath | wc -m\n'
                        '# 46\n'
                        '#\n')

        gh.write_file(test_file, test_content)
        gh.run(f'python {self.script_module} --output {result_file} {test_file}')
        result = gh.read_file(result_file)

        ## TODO: WORK-IN-PROGRESS
        ## self.assertTrue('@test "setup and title"' in result)
        ## self.assertTrue('\tfilepath=$(echo $TMP/testfile-"$$")' in result)
        ## self.assertTrue('\techo "this is a file content to run an example test" | sudo tee $filepath' in result)
        ## self.assertTrue('\tcat $filepath | wc -m' in result)
        ## self.assertTrue('\techo -e \'46\'' in result)


    def test_local_setup(self):
        """End to end test local setups for tests"""
        debug.trace(debug.DETAILED, f"TestIt.test_local_setup({self})")
        ## TODO: WORK-IN-PROGRESS


    def test_source(self):
        """End to end test for source"""
        debug.trace(debug.DETAILED, f"TestIt.test_source({self})")
        ## TODO: WORK-IN-PROGRESS


    def test_temporal_test_folder(self):
        """End to end test for temporal test folder"""
        debug.trace(debug.DETAILED, f"TestIt.test_temporal_test_folder({self})")
        ## TODO: WORK-IN-PROGRESS


    def test_ignore_tests(self):
        """End to end test ignore tests using # for test files and ## for shell scripts files"""
        debug.trace(debug.DETAILED, f"TestIt.test_ignore_tests({self})")
        ## TODO: WORK-IN-PROGRESS


    def test_execution_path(self):
        """Test for execution file paths"""
        debug.trace(debug.DETAILED, f"TestIt.test_execution_path({self})")
        ## TODO: WORK-IN-PROGRESS

        ## OLD
        ##source_filename = self.temp_base + '/source_file.bash'
        ##alias_name      = 'test-alias-' + str(random.randint(0000000, 9999999))
        ##alias_message    = 12312313
        ##gh.write_file(source_filename, f'alias {alias_name}="echo {alias_message}"')

        ## OLD
        ##test_content = (f'#! ./{self.script_module}\n'
        ##                f'setup() {{ shopt -s expand_aliases\nsource {source_filename}; }}\n'
        ##                f'test "test alias from source file" {{ assert_equals $({alias_name}) "{alias_message}"; }}')
        ##gh.write_file(self.temp_file, test_content)

        ## OLD
        ##expected_result = '1..1\nok 1 test alias from source file'
        ##self.assertEqual(gh.run(f'{self.temp_file}'), expected_result)


if __name__ == '__main__':
    unittest.main()
