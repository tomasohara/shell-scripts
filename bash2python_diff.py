#!/usr/bin/env python3
#
# Converts a bash script to python using two approaches, one based on old-school pattern
# matching and the other based on large language models trained over code (e.g., Codex).
#
# Notes:
# - Info on perl paragraph mode [via perlrun manpage]:
#
#   -0[octal/hexadecimal]
#      specifies the input record separator ($/) as an octal or hexadecimal number.
#      ...
#      The special value 00 will cause Perl to slurp files in paragraph mode.
#      [To slurp files whole, use the value 0777.]
#

# Tana-TODO2: something like """Wrapper around bash2python.py showing regex vs codex diff"""
"""Segments a script and makes a diff"""

# Standard modules
import difflib
import subprocess
import sys

# Installed modules
import click

# Local modules
from mezcla import debug
from mezcla import system
import bash2python

# Constants
TL = debug.TL
LABEL_BASH2PYTHON = "b2py"
LABEL_CODEX = "codex"
DIVIDER_PROPER = "----------------------------------------"
SMALL_SEGMENT_DIVIDER = f"#{DIVIDER_PROPER[:-10]}\n"
SEGMENT_DIVIDER = f"#{DIVIDER_PROPER}\n"

# Environment options
# Notes:
# - These are just intended for internal options, not for end users.
# - They also allow for enabling options in one place rather than four
#   when using main.Main (e.g., [Main member] initialization, run-time
#   value, and argument spec., along with string constant definition).
#
STRICT_MODE = system.getenv_bool("STRICT_MODE", False,
                                 description="Run perl in strict mode")
PERL_WARNINGS = system.getenv_bool("PERL_WARNINGS", False,
                                   description="Show perl warnings")

def read_input_file(file):
    """Reads and segments FILE handle"""
    segment_num = 0
    output = ""
    debug.assertion(SEGMENT_DIVIDER.endswith("\n"))
    for line in file:
        if ((line.strip() == "") or (not segment_num)):
            # Print divider for subsequent segments
            if segment_num:
                # note: use two dividiers: one is full length and the other is shortened
                # so not consumed by split (see format() in main script).
                output += f"{SMALL_SEGMENT_DIVIDER}"
                output += f"{SEGMENT_DIVIDER}"
            # Print segment indicator
            segment_num += 1
            output += f"# Segment {segment_num}\n"
        output += line
    return output


def format_bash_to_python(output):
    """Formats file with bash2python"""
    formatted_outputs = []

    for codex in [True, False]:
        b2p = bash2python.Bash2Python(output, None,
                                      segment_divider=SEGMENT_DIVIDER)
        formatted_output = b2p.format(codex)
        formatted_outputs.append(formatted_output.splitlines())
    return formatted_outputs


def print_diff(formatted_outputs):
    """Creates and gives format to a side-by-side diff"""
    diff = list(difflib.ndiff(formatted_outputs[0], formatted_outputs[1]))
    debug.trace_expr(6, diff)

    ## Tana-TODO2: code a simple alternative using 'diff --side-by-side'
    ## NOTE: It is not good to re-invent the wheel.
    ##   temp1 = f"{TMP}/_b2p_diff.codex.list"
    ##   temp2 = f"{TMP}/_b2p_diff.regex.list"
    ##   system.write_file(, formatted_outputs[0])
    ##   system.write_file(, formatted_outputs[1])
    ##   print(gh.run(f"diff --side-by-side {temp1} {temp2}")
    
    HALF_DIFF_MAX = system.getenv_int("HALF_DIFF_MAX", 70,
                                      "Maximum length for one half of the diff")
    ## TEMP: output
    label_spacer = (" " * (HALF_DIFF_MAX - len(LABEL_BASH2PYTHON) - 1))
    print(f"# {LABEL_BASH2PYTHON}{label_spacer}| {LABEL_CODEX}")
    
    for line in diff:
        symbol = line[0]
        content = line[2:]
        debug.assertion(line[1] == " ")

        ## Tana-TODO1: explain what you were trying to do
        if content.strip():  # Check if the content is not an empty string
            content_clipped = content[:HALF_DIFF_MAX]
            blanks = (" " * HALF_DIFF_MAX)
            if symbol == '+':
                ## BAD: print(f"{content:<70} | {'':<70}")
                print(f"{content_clipped:{HALF_DIFF_MAX}} | {blanks}")
            elif symbol == '-':
                ## BAD: print(f"{'':<70}   {content:<70}")
                print(f"{blanks} | {content_clipped}")
            else:
                ## BAD: print(f"{content:<70} | {content:<70}")
                print(content)

@click.command()
@click.option("--perl", is_flag=True, help="Uses perl.")
@click.option("--diff", is_flag=True, help="Print the diff between both files.")
def main(perl, diff):
    """Main function"""
    file = ""

    # Read the input, segmenting into units such as by paragraph (e.,g., Perl style)
    if perl:
        for line in sys.stdin:
            file += line + "\n"
        # Note: See perlgrep.perl for use of $/ (record separator, whihc normally is newline).
        #
        ## OLD: command = 'BEGIN { $seg_num = 1; print "#segment $seg_num\n" } if (/^\s*$/) { $seg_num++; print "#segment $seg_num\n"; } else { print; }'
        ##
        ## TOM: Note that perl uses -00 option for its paragraph mode (see above)
        ##
        # The following code gets executed in a loop (via -ne option)
        command = ""
        if STRICT_MODE:
            command += "use strict;\n"
        command += r"""
            BEGIN { $seg_num = 1; }
            print("#----------------------------------------\n");
            print("# Segment ", $seg_num++, "\n");
            print;
        """

        ## OLD: output_bytes = subprocess.Popen(['perl', '-ne', command], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate(input=file.encode())[0]
        options = ""
        if PERL_WARNINGS:
            options += " -w"
        options = " -00 -ne "
        command_spec = ['perl', options, "'", command, "'"]
        debug.trace_expr(5, command_spec)
        output_bytes = subprocess.Popen(command_spec,
                                        stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE
                                        ).communicate(input=file.encode())[0]
        output = output_bytes.decode()
    else:
        file = sys.stdin
        output = read_input_file(file)
    debug.trace_expr(7, output)
    
    # note: output is script and formatted_outputs converted version (Tana-TODO2: rename both--see 'Tips' in main script)
    formatted_outputs = format_bash_to_python(output)
    
    #If diff function, creates the diff
    # note: diff is side-by-side
    if diff:
        print_diff(formatted_outputs)
    else:
        for index, formatted_output in enumerate(formatted_outputs):
            file_label = LABEL_BASH2PYTHON if index == 0 else LABEL_CODEX
            sys.stdout.write(f"------------{file_label}------------\n")
            for line in formatted_output:
                sys.stdout.write(line + "\n")


if __name__ == "__main__":
    debug.trace_current_context(level=TL.QUITE_DETAILED)
    main()                              # pylint: disable=no-value-for-parameter
