#! /usr/bin/env python
#
# PYBATS
#
# This process and run custom tests using bats-core.
#
# Assertions:
# - assert_equals     [actual] [expected]
# - assert_not_equals [actual] [expected]
#
# NOTE: It is only necessary to have installed bats-core
#       no need for bats-assertions library.
#
# TODO: pretty result.
#       pretty bats file?.
#       --save PATH?.


"""
BATSPP

This process and run custom tests using bats-core.

Examples
  test "This is a single line test" { assert_equal $((3+7)) 10; }

  test "This is a multiline test" {
  \tfirst_value=9
  \tsecond_value=6
  \assert_equals $(($first_value+$second_value)) 15
  }

Assertions:
  assert_equals     [actual] [expected]
  assert_not_equals [actual] [expected]
"""


# Standard packages
import re


# Local packages
from mezcla.main import Main
from mezcla      import system
from mezcla      import debug
from mezcla      import glue_helpers as gh


# Command-line labels constants
FILENAME = 'filepath'


# Tests constants
EXTENSION         = '.bpp'
ASSERT_EQUALS     = 'assert_equals'
ASSERT_NOT_EQUALS = 'assert_not_equals'


class Batspp(Main):
    """This process and run custom tests using bats-core"""


    # Global States
    filename     = ''
    test_content = ''


    def setup(self):
        """Process arguments"""

        # Check the command-line options
        self.filename     = self.get_parsed_argument(FILENAME, "")
        self.test_content = system.read_file(self.filename)


    def run_main_step(self):
        """Process main script"""


        # Delete comments
        self.test_content = re.sub(r'#.*\n', '', self.test_content)


        # Convert single line tests to multiline
        self.test_content = re.sub(r'{\s+', '{\n', self.test_content)
        self.test_content = re.sub(';', '\n', self.test_content)


        bats_content = '#! /usr/bin/env bats\n\n'


        # Process setup
        test_absolute_dir = gh.dir_path(gh.real_path(self.filename))

        bats_content +=  'setup() {\n'
        bats_content += f'DIR="{test_absolute_dir}/../:$PATH"\n'

        setup_block   = re.match(r'setup\(\)\s+{([^}]+)', self.test_content)
        bats_content += setup_block.group(1) if setup_block else ''

        bats_content +=  '}\n'


        # Process tests
        # TODO: refactor groups, remove 'extra'
		#       solve problem comparing strings.
        #       assert_success.
        #       assert_failure.
        #       assert_output.
        #       refute_output.
        tests   = re.findall(r'test\s+"(.*)"\s+{((.|\n)[^}]+)', self.test_content)
        asserts = [Assert(f'({ASSERT_EQUALS})\\s+([^\\s]+)\\s+([^\n\\s]+)', r'[ \2 -eq \3 ]'),
                   Assert(f'({ASSERT_NOT_EQUALS})\\s+([^\\s]+)\\s+([^\n\\s]+)', r'[ \2 -ne \3 ]')]

        for test_text, test_content, extra in tests:

            # Append test header
            bats_content += '@test "' + test_text + '" {'

            # Append test lines
            for line in test_content.split('\n'):

                assertion_index = [i for i, assertion in enumerate(asserts) if assertion.check_assertion(line)]
                bats_content   += asserts[assertion_index[0]].get_bats_assertion(line) if assertion_index else line
                bats_content   += '\n'

            bats_content += '}\n'


        # TODO: Process teardown


        # Get filepath
        bats_filename = gh.run(f'echo {gh.basename(self.filename, EXTENSION)}-$$.bats')
        bats_filepath = f'/tmp/{bats_filename}'


        # Save and run tests
        gh.write_file(bats_filepath, bats_content)
        gh.run(f'chmod +x {bats_filepath}')
        debug.trace(debug.USUAL, f'pybats - running test {bats_filepath}')
        print(gh.run(f'{bats_filepath}'))


class Assert:
    """Class Assert"""


    # Globals
    assert_pattern = ''
    bats_pattern   = ''


    def __init__(self, assert_pattern, bats_pattern):
        self.assert_pattern = assert_pattern
        self.bats_pattern   = bats_pattern


    def check_assertion(self, assert_text):
        """Retuns if an assertion corresponds to this assert"""
        return bool(re.search(self.assert_pattern, assert_text))


    def get_bats_assertion(self, assert_text):
        """Convert assertion to bats-core style"""
        result = re.sub(self.assert_pattern, self.bats_pattern, assert_text)
        debug.trace(debug.USUAL, f'assert.get_bats_assertion() - replaced {assert_text} by {result}')
        return result


if __name__ == '__main__':
    app = Batspp(description          = __doc__,
                 positional_arguments = [(FILENAME, 'test file path')],
                 manual_input         = True)
    app.run()
