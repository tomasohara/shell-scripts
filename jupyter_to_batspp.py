#! /usr/bin/env python
#
# Jupyter to Batspp tests module
#
# This converts Jupyter to Batspp tests
#


"""
Jupyter to Batspp

This converts Jupyter to Batspp tests

usage example:
$ python3 jupyter_to_batspp.py TODO
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
        jupyter_content = gh.read_file(self.jupyter_file)
        if not jupyter_content:
            print(f'Error: {self.jupyter_file} not founded or is empty')


        # Format Jupyter string into JSON
        jupyter_json = json.loads(jupyter_content)
        debug.trace(7, f'jupiter_to_batspp.py - jupyter content founded: {jupyter_json}')


        # Process cells
        batspp_content  = ''
        for cell in jupyter_json['cells']:

            print('>>>', cell)

            # Process code cells
            if cell['cell_type'] == 'code':

                # Append source lines
                for line in cell['source']:

                    if not line or line.isspace():
                        continue

                    # Check if line is a comment or command
                    if not line.startswith('#'):
                        batspp_content += '$ '

                    batspp_content += ensure_new_line(line)

                # Append output lines
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
        batspp_file = ''
        if self.output:
            batspp_file = self.output
        else:
            batspp_file = re.sub(r'\.ipynb$', '.batspp', self.jupyter_file)

        ## TODO: set batspp file if not provided on output path

        # Save Batspp file
        gh.write_file(batspp_file, batspp_content)


        # Print output
        if self.verbose:
            print(batspp_content)
        print(f'Resulting Batspp tests saved on {self.output}')


def ensure_new_line(string):
    """Append new line to end if this STRING does not have it"""
    return string if string.endswith('\n') else f'{string}\n'


if __name__ == '__main__':
    app = JupyterToBatspp(description          = __doc__,
                          positional_arguments = [(JUPYTER_FILE, 'test file path')],
                          text_options         = [(OUTPUT,   'target output .batspp file path')],
                          boolean_options      = [(VERBOSE,  'show verbose debug')],
                          manual_input         = True)
    app.run()
