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

# TODO: something like """Wrapper around bash2python.py showing regex vs codex diff"""
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
    """Reads and segments file"""
    segment_num = 1
    output = f"#segment {segment_num} \n"
    for line in file:
        if line.strip() == "":
            segment_num += 1
            output += f"##Segment {segment_num} \n"
        else:
            output += line
    return output


def format_bash_to_python(output):
    """Formats file with bash2python"""
    b2p = bash2python.Bash2Python(output, None)
    formatted_outputs = []

    for codex in [True, False]:
        formatted_output = b2p.format(codex)
        formatted_outputs.append(formatted_output.splitlines())
    return formatted_outputs


def print_diff(formatted_outputs):
    """Creates and gives format to a side-by-side diff"""
    diff = list(difflib.ndiff(formatted_outputs[0], formatted_outputs[1]))

    for line in diff:
        symbol = line[0]
        content = line[2:]

        if content.strip():  # Check if the content is not an empty string
            if symbol == '+':
                print(f"{content:<70} | {'':<70}")
            elif symbol == '-':
                print(f"{'':<70}   {content:<70}")
            else:
                print(f"{content:<70} | {content:<70}")


@click.command()
@click.option("--perl", is_flag=True, help="Uses perl.")
@click.option("--diff", is_flag=True, help="Print the diff between both files.")
def main(perl, diff):
    """Main function"""
    file = ""
    if perl:
        for line in sys.stdin:
            file += line + "\n"
        ## OLD: command = 'BEGIN { $seg_num = 1; print "#segment $seg_num\n" } if (/^\s*$/) { $seg_num++; print "#segment $seg_num\n"; } else { print; }'
        ##
        ## TOM: Note that perl uses -00 option for its paragraph mode (see above)
        ##
        command = ""
        if STRICT_MODE:
            command += "use strict;\n"
        command += r"""
                BEGIN{$i=1}
                print "#Segment ", $i++,
                "\n";
                print $_
        """

        ## OLD: output_bytes = subprocess.Popen(['perl', '-ne', command], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate(input=file.encode())[0]
        options = "-00 -ne"
        if PERL_WARNINGS:
            options += " -w"
        output_bytes = subprocess.Popen(['perl', options, command],
                                        stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE
                                        ).communicate(input=file.encode())[0]
        output = output_bytes.decode()
    else:
        file = sys.stdin
        output = read_input_file(file)
    formatted_outputs = format_bash_to_python(output)
    #If diff function, creates the diff
    if diff:
        print_diff(formatted_outputs)
    else:
        for index, formatted_output in enumerate(formatted_outputs):
            file_label = "codex" if index == 0 else "b2py"
            sys.stdout.write(f"------------{file_label}------------\n")
            for line in formatted_output:
                sys.stdout.write(line + "\n")


if __name__ == "__main__":
    debug.trace_current_context(level=TL.QUITE_DETAILED)
    main()                              # pylint: disable=no-value-for-parameter
