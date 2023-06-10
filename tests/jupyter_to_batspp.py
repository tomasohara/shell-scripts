#! /usr/bin/env python
#
# Jupyter to Batspp tests module
#
# This converts Jupyter to Batspp tests
# NOTE: Doesn't suppport mezcla>=1.3.1


"""
Jupyter to Batspp
This converts Jupyter to Batspp tests
usage example:
$ python3 --output ./result.batspp jupyter_to_batspp.py
"""


# Standard packages
import json
import re


# Local packages
from mezcla.main import Main
from mezcla import debug
from mezcla import glue_helpers as gh


# Command-line labels constants
JUPYTER_FILE = 'jupyter_file'
OUTPUT       = 'output'
VERBOSE      = 'verbose'


# Constants
JUPYTER_EXTENSION = 'ipynb'
BATSPP_EXTENSION  = 'batspp'


class JupyterToBatspp(Main):
    """This convert Jupyter tests into Batspp tests"""


    # Class-level member variables for arguments (avoids need for class constructor)
    jupyter_file = ''
    output       = ''
    verbose      = True


    def setup(self):
        """Process arguments"""

        # Check the command-line options
        self.jupyter_file = self.get_parsed_argument(JUPYTER_FILE, self.jupyter_file)
        self.output       = self.get_parsed_argument(OUTPUT, self.output)
        self.verbose      = self.has_parsed_option(VERBOSE) or self.verbose

        debug.trace(7, (f'jupyter_to_batspp.setup({self}) -'
                        f'jupyter_file={self.jupyter_file},'
                        f'output={self.output},'
                        f'verbose={self.verbose}'))


    def run_main_step(self):
        """Process main script"""

        # Get Jupyter content
        assert self.jupyter_file.endswith(JUPYTER_EXTENSION), f'the file {self.jupyter_file} must be an Jupyter notebook'
        jupyter_content = gh.read_file(self.jupyter_file)
        assert jupyter_content != '', f'Error: {self.jupyter_file} not founded or is empty'


        # Format Jupyter string into JSON
        jupyter_json = json.loads(jupyter_content)
        debug.trace(7, f'jupiter_to_batspp.py - jupyter content founded: {jupyter_json}')


        # Process cells
        batspp_content  = ''
        for cell in jupyter_json['cells']:

            # Process code cells
            if cell['cell_type'] == 'code':

                is_setup = False

                # Append source lines
                for line in cell['source']:

                    if not line or line.isspace():
                        continue

                    if line.lower() == '# setup\n':
                        is_setup = True
                    elif line.lower() in ['# continuation\n', '# continue\n', '# test']:
                        is_setup = False

                    # Check if line is a comment or command
                    if not line.startswith('#'):
                        batspp_content += '$ '

                    batspp_content += ensure_new_line(line)

                # Append output lines
                if not is_setup:
                    for output in cell['outputs']:

                        for line in output['text']:
                            batspp_content += ensure_new_line(line)

            # Markdown cells are considered as comments or directives
            elif cell['cell_type'] == 'markdown':

                for line in cell['source']:
                    batspp_content += ensure_new_line(f'# {line}')

            batspp_content += '\n'

        debug.trace(7, f'jupiter_to_batspp.py - batspp content founded: {batspp_content}')


        # Set Batspp filename
        self.output = self.output if self.output else re.sub(fr'\.{JUPYTER_EXTENSION}$', f'.{BATSPP_EXTENSION}', self.jupyter_file)


        # Save Batspp file
        gh.write_file(self.output, batspp_content)


        # Print output
        if self.verbose:
            print(batspp_content)

        final_stdout = f'Resulting Batspp tests saved on {self.output}'
        print('=' * len(final_stdout))
        print(final_stdout)


def ensure_new_line(string):
    """Append new line to end if this STRING does not have it"""
    return string if string.endswith('\n') else f'{string}\n'


if __name__ == '__main__':
    app = JupyterToBatspp(description          = __doc__,
                          positional_arguments = [(JUPYTER_FILE, 'test file path')],
                          text_options         = [(OUTPUT,      f'target output .{BATSPP_EXTENSION} file path')],
                          boolean_options      = [(VERBOSE,      'show verbose debug')],
                          manual_input         = True)
    app.run()

