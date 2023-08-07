#! /usr/bin/env python
#
# randomize-lines.py: randomize lines in a file without reading entirely into memory.
# This creates a temporary file with a random number in the first column and
# the original line contents in the second. Then the temporary file is sorted
# and the random number column removed.
#
# Note:
# - Inspired by examples under Stack Overflow (see below).
#
#------------------------------------------------------------------------
# via http://stackoverflow.com/questions/4618298/randomly-mix-lines-of-3-million-line-file
#
# At the shell, use this.
#   python decorate.py | sort | python undecorate.py
#   
# decorate.py:
#   
#   import sys
#   import random
#   for line in sys.stdin:
#       sys.stdout.write( "{0}|{1}".format( random.random(), line ) )
#   
# undecorate.py:
#   
#   import sys
#   for line in sys.stdin:
#       _, _, data= line.partition("|")
#       sys.stdout.write( line )
#
#------------------------------------------------------------------------
# TODO:
# - * Add support for paragraph-mode sorting (e.g., CR-encoding).
# - Rework using main.py
# - Add sanity check for disk space issues.
# - Have streamlined version just using output from sort.
#

"""Randomize lines from stardard input"""

# Standard modules
import argparse
import os
import random
import sys

# Local modules
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.main import Main
from mezcla import tpo_common as tpo
from mezcla import system

RANDOM_SEED = tpo.getenv_integer("RANDOM_SEED", 15485863,
                                 "Integral seed for random number generation (n.b., use ' ' for default [time of day based])")

## TEMP:
## pylint: disable=consider-using-f-string

class Dummy_Main(Main):
    """Class for reading input using Main"""
    
    def __init__(self, input_stream):
        super().__init__(runtime_args=[])
        self.input_stream = input_stream
        self.all_lines = []

    def process_line(self, line):
        self.all_lines.append(line)
        return
        

def main():
    """Entry point for script"""
    tpo.debug_print("main(): sys.argv=%s" % sys.argv, 4)
    ## TODO: assert is_directory("/usr/bin"), "This requires Unix"
    if ("--ignore-case" not in gh.run("sort --help")):
        tpo.print_stderr("Error: This requires a Unix-type version of sort (e.g., GNU).")
        sys.exit()

    # Check command-line arguments
    global RANDOM_SEED
    ## OLD: parser = argparse.ArgumentParser(description="Randomize lines in a file (without reading entirely into memory).")
    parser = argparse.ArgumentParser(description=f"Randomize lines in a file (without reading entirely into memory).The default seed is {RANDOM_SEED}.")
    parser.add_argument("--include-header", default=False, action='store_true', help="Keep first line as headers")
    ## OLD: parser.add_argument("--seed", type=int, default=None, help="random seed (e.g., 122949823, the seven-millionth prime)")
    parser.add_argument("--seed", type=int, default=RANDOM_SEED, help="random seed (e.g., 122949823, the seven-millionth prime)")
    parser.add_argument("filename", nargs='?', default='-', help="Input filename")
    args = vars(parser.parse_args())
    tpo.debug_print("args = %s" % args, 5)
    filename = args['filename']
    input_stream = sys.stdin
    if (filename != "-"):
        assert(os.path.exists(filename))
        input_stream = system.open_file(filename)
        assert(input_stream)
    else:
        debug.trace(5, "Re-opening stdin w/ UTF-8 support")
        ## TODO: figure out proper way to re-open stdin
        STDIN = 0
        input_stream = system.open_file(STDIN)
    ## TODO: cleanup RANDOM_SEED access
    ## OLD:
    ## global RANDOM_SEED
    ## if args['seed']:
    debug.assertion(args['seed'])
    if (args['seed'] is not None):
        RANDOM_SEED = int(args['seed'])
    include_header = args['include_header']

    # Initialize seed for optional random number generator
    if RANDOM_SEED:
        random.seed(RANDOM_SEED)

    # Add column with random number to temporary file
    temp_base = tpo.getenv_text("TEMP_FILE", gh.get_temp_file())
    temp_input_file = temp_base + ".input"
    temp_output_file = temp_base + ".output"
    ## OLD: temp_input_handle = open(temp_input_file, "w")
    temp_input_handle = system.open_file(temp_input_file, mode="w")
    assert(temp_input_handle)
    #
    header = None
    line_num = 0
    # Note: uses main class to allow for reading pages and paragraphs
    main_app = Dummy_Main(input_stream)
    main_app.process_input()
    multi_line_mode = not main_app.is_line_mode()
    #
    for line in main_app.all_lines:
        line_num += 1
        line = line.strip("\n")
        if multi_line_mode:
            # Encode internal newlines so the sort is not thrown off
            line = line.replace("\n", "\\n")
        if (line_num == 1) and include_header:
            header = line
        else:
            temp_input_handle.write("%s\t%s\n" % (random.random(), line))
    num_input_lines = line_num
    temp_input_handle.close()

    # Sort by random-number column (1) and then remove temporary column
    # NOTES:
    # - This needs to ensure that the unix version of sort is used.
    # - The Win32 version of run() doesn't support pipes. 
    ## TODO: Use another way to bypass Windows sort command (e.g., in case sort
    ## is located in a different directory than /usr/bin).
    gh.delete_existing_file(temp_output_file)
    gh.run("sort -n < {in_file} | cut -f2- > {out_file}",
           in_file=temp_input_file, out_file=temp_output_file)

    # Display result
    # TODO: send output of command above to stdout
    ## OLD: temp_output_handle = open(temp_output_file, "r")
    temp_output_handle = system.open_file(temp_output_file, mode="r")
    assert(temp_output_handle)
    line_num = 0
    IO_error = False
    if include_header and header:
        print(header)
        line_num += 1
        tpo.debug_print("HL%d: %s" % (line_num, header), 6)
    for line in temp_output_handle:
        line_num += 1
        line = line.strip("\n")
        if multi_line_mode:
            line = line.replace("\\n", "\n")
        tpo.debug_print("RL%d: %s" % (line_num, line), 6)
        if (include_header and (line == header)):
            tpo.debug_print("Ignoring header at line %d" % (line_num), 5)
            continue
        try:
            print(line)
        except:
            IO_error = True
            tpo.debug_print("Exception printing line %d: %s" % (line_num, str(sys.exc_info())), 4)
            break
    num_output_lines = line_num
    tpo.debug_print("%s input and %d output lines" % (num_input_lines, num_output_lines), 4)
    gh.assertion((num_input_lines == num_output_lines) or IO_error)
    temp_output_handle.close()

    # Cleanup (e.g., removing temporary files)
    if not tpo.detailed_debugging():
        gh.run("rm -vfr {base}*", base=temp_base)
    return

#------------------------------------------------------------------------

if __name__ == '__main__':
    main()
