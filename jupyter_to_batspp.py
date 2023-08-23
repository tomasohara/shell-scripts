#! /usr/bin/env python
#
# Jupyter to Batspp tests module
#
# This converts Jupyter to Batspp tests
#
#-------------------------------------------------------------------------------
# Sample input:
#
#    {
#     "cells": [
#      {
#       "cell_type": "code",
#       "execution_count": 3,
#       "id": "9bddc194",
#       "metadata": {},
#       "outputs": [],
#       "source": [
#        "# Dummy test file for debugging purposes\n",
#        "# For use with BatsPP."
#       ]
#      },
#      {
#       "cell_type": "code",
#       "execution_count": 4,
#       "id": "abb31f9a",
#       "metadata": {},
#       "outputs": [
#        {
#         "name": "stdout",
#         "output_type": "stream",
#         "text": [
#          "dummy\n"
#         ]
#        }
#       ],
#       "source": [
#        "# This test will pass\n",
#        "echo dummy"
#       ]
#      },
#       ...
#     ],
#     "metadata": {
#      "kernelspec": {
#       "display_name": "Bash",
#       "language": "bash",
#       "name": "bash"
#      },
#      "language_info": {
#       "codemirror_mode": "shell",
#       "file_extension": ".sh",
#       "mimetype": "text/x-sh",
#       "name": "bash"
#      }
#     },
#     "nbformat": 4,
#     "nbformat_minor": 5
#    }
#
#--------------------------------------------------------------------------------
# Sample output:
#
#    # Dummy test file for debugging purposes
#    # For use with BatsPP.
#    
#    # This test will pass
#    $ echo dummy
#    dummy
#    
#    # This test will fail: the time will be different when tested
#    $ date
#    Wed Jun 21 06:30:51 CDT 2023
#    
#


"""
Jupyter to Batspp

This converts Jupyter to Batspp tests

usage example:
$ python3 jupyter_to_batspp.py tests/hello-world.ipynb
"""


# Standard packages
import json
## OLD: import re


# Local packages
from mezcla import debug
from mezcla.main import Main
from mezcla.my_regex import my_re
from mezcla import system


# Command-line labels constants
JUPYTER_FILE = 'jupyter-file'
OUTPUT       = 'output'
VERBOSE      = 'verbose'
STDOUT       = 'stdout'
JUST_CODE    = 'just-code'

# Other constants
JUPYTER_EXTENSION = 'ipynb'
BATSPP_EXTENSION  = 'batspp'
TL = debug.TL


class JupyterToBatspp(Main):
    """This convert Jupyter tests into Batspp tests"""

    # Class-level member variables for arguments (avoids need for class constructor)
    jupyter_file = ''
    output       = ''
    verbose      = None
    stdout       = None
    just_code    = None


    def setup(self):
        """Process arguments"""

        # Check the command-line options
        self.jupyter_file = self.get_parsed_argument(JUPYTER_FILE, self.jupyter_file)
        self.output       = self.get_parsed_argument(OUTPUT, self.output)
        self.stdout       = self.get_parsed_argument(STDOUT, not self.output)
        self.just_code    = self.get_parsed_argument(JUST_CODE, not self.just_code)
        self.verbose      = self.get_parsed_option(VERBOSE, not self.stdout)

        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")


    def run_main_step(self):
        """Process main script"""

        # Get Jupyter content
        # TODO: add explicit error handling
        jupyter_content = system.read_file(self.jupyter_file)
        debug.trace_expr(5, jupyter_content)
        debug.assertion(jupyter_content != '',
                        f'Error: {self.jupyter_file} not found or is empty')
        is_jupyter_notebook = (self.jupyter_file.endswith(JUPYTER_EXTENSION) or
                               '"cells":' in jupyter_content)
        debug.assertion(is_jupyter_notebook,
                        f'the file {self.jupyter_file} must be an Jupyter notebook')

        # Format Jupyter string into JSON
        try:
            jupyter_json = json.loads(jupyter_content)
        except:
            system.print_exception_info("loading json")
            system.exit("Error: unable to load jupter notebook")
        debug.trace(7, f'jupyter content found: {jupyter_json!r}')

        # Process cells
        batspp_content  = ''
        for c, cell in enumerate(jupyter_json['cells']):

            # Process code cells
            if cell['cell_type'] == 'code':
                is_setup = False

                # Append source lines
                for l, line in enumerate(cell['source']):
                    line_spec = f"cell {c + 1} line {l + 1}"
                    if not line or line.isspace():
                        debug.trace(6, f"Ignoring empty line at {line_spec}")
                        continue

                    if line.lower() == '# setup\n':
                        is_setup = True
                    elif line.lower() in ['# continuation\n', '# continue\n', '# test']:
                        is_setup = False

                    # Check if line is a comment or command
                    if not line.startswith('#'):
                        debug.trace(6, f"Adding shell prompt '$' to {line_spec}")
                        batspp_content += '$ '

                    batspp_content += ensure_new_line(line)

                # Append output lines
                try:
                    cell_output = [ensure_new_line(l) for output in cell['outputs']
                                   if (output["output_type"] == "stream") for l in output['text']]
                except:
                    cell_output = ""
                    system.print_exception_info(f"extraction of output for cell {c}: {cell}")
                if (not (is_setup or self.just_code)):
                    batspp_content += "".join(cell_output)
                else:
                    debug.trace(4, f"Ignoring cell output  [cell {c + 1}]:\n\t{cell_output}")

            # Markdown cells are considered as comments or directives
            elif cell['cell_type'] == 'markdown':
                for line in cell['source']:
                    batspp_content += ensure_new_line(f'# {line}')

            # Add blank line between cells
            batspp_content += '\n'

        debug.trace(7, f'derived batspp content: {batspp_content!r}')

        # Set Batspp filename
        if ((not self.output) and (not self.stdout)):
            self.output = my_re.sub(fr'\.{JUPYTER_EXTENSION}$', f'.{BATSPP_EXTENSION}',
                                    self.jupyter_file)
        # Save Batspp file
        if self.output:
            system.write_file(self.output, batspp_content)

        # Print output
        if self.verbose or self.stdout:
            print(batspp_content)

        if self.verbose:
            final_stdout = f'Resulting Batspp tests saved on {self.output}'
            system.print_stderr('=' * len(final_stdout))
            system.print_stderr(final_stdout)


def ensure_new_line(string):
    """Append new line to end if this STRING does not have it"""
    return string if string.endswith('\n') else f'{string}\n'

def main():
    """Entry point"""
    app = JupyterToBatspp(
        description          = __doc__,
        positional_arguments = [(JUPYTER_FILE, 'Test file path')],
        text_options         = [(OUTPUT,      f'Target output .{BATSPP_EXTENSION} file path')],
        boolean_options      = [(VERBOSE,      'Show verbose debug'),
                                (JUST_CODE,    'Omit output cells'),
                                (STDOUT,      f'Print to standard output (default unless --{OUTPUT}')],
        manual_input         = True)
    app.run()

#-------------------------------------------------------------------------------

if __name__ == '__main__':
    debug.trace_current_context(level=TL.QUITE_VERBOSE)
    main()
