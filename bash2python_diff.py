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
## OLD: import subprocess
import sys

# Installed modules
import click

# Local modules
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla import system
import bash2python

# Constants
TL = debug.TL
LABEL_BASH2PYTHON = "b2py"
LABEL_CODEX = "codex"
DIVIDER_PROPER = "----------------------------------------"
SEGMENT_COMMENT = "#s#"
SMALL_SEGMENT_DIVIDER = f"{SEGMENT_COMMENT}{DIVIDER_PROPER[:-10]}\n"
SEGMENT_DIVIDER = f"{SEGMENT_COMMENT}{DIVIDER_PROPER}\n"

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

def segment_input(file_handle):
    """Reads and segments FILE_HANDLE"""
    debug.trace(6, f"segment_input({file_handle}))")
    segment_num = 0
    output = ""
    debug.assertion(SEGMENT_DIVIDER.endswith("\n"))
    for line in file_handle:
        if ((line.strip() == "") or (not segment_num)):
            # Print divider for subsequent segments
            if segment_num:
                # note: use two dividiers: one is full length and the other is shortened
                # so not consumed by split (see convert_snippet() in main script).
                output += f"{SMALL_SEGMENT_DIVIDER}"
                output += f"{SEGMENT_DIVIDER}"
            # Print segment indicator
            segment_num += 1
            output += f"{SEGMENT_COMMENT} Segment {segment_num}\n"
        output += line
    return output


def bash_to_python(output):
    """Convert BASH with bash2python"""
    debug.trace(6, f"bash_to_python({output!r}))")
    formatted_outputs = []

    for codex in [True, False]:
        b2p = bash2python.Bash2Python(output, None,
                                      segment_prefix=SEGMENT_COMMENT,
                                      segment_divider=SEGMENT_DIVIDER)
        formatted_output = b2p.convert_snippet(codex)
        formatted_outputs.append(formatted_output.splitlines())
    return formatted_outputs


def print_diff(formatted_outputs):
    """Creates and gives format to a side-by-side diff"""
    debug.trace(6, f"print_diff({formatted_outputs!r}))")
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
        if content.strip():             # Check if the content is not an empty string
            content_clipped = content[:HALF_DIFF_MAX]
            blanks = (" " * HALF_DIFF_MAX)
            if symbol == '+':
                print(f"{content_clipped:{HALF_DIFF_MAX}} | {blanks}")
            elif symbol == '-':
                print(f"{blanks} | {content_clipped}")
            else:
                print(content)
    return


def perl_segment_input(file_handle):
    """Segment code from FILE_HANDLE by splitting according to Perl paragraph mode (i.e., separated by blank lines)"""
    debug.trace(7, f"perl_segment_input({file_handle})")
    file_text = ""
    for line in sys.stdin:
        file_text += line + "\n"

    # Note: See perlgrep.perl for use of $/ (record separator, whihc normally is newline).
    #
    ## TOM: Note that perl uses -00 option for its paragraph mode (see above)
    ##
    # The following code gets executed in a loop (via -ne option)
    command = ""
    if STRICT_MODE:
        command += "use strict;\n"
    command += fr"""
        BEGIN {{ $seg_num = 1; }}
        print("{SMALL_SEGMENT_DIVIDER}");
        print("{SEGMENT_DIVIDER}");
        print("# Segment ", $seg_num++, "\n");
        print;
    """

    # Initialize command invocaitn with Perl options for warnings and strict mode
    options = ""
    if PERL_WARNINGS:
        options += " -w"
    options = " -00 -ne "
    ## OLD
    ## command_spec = ['perl', options, "'", command, "'"]
    ## debug.trace_expr(5, command_spec)
    ## output_bytes = subprocess.Popen(command_spec,
    ##                                 stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE
    ##                                 ).communicate(input=file_text.encode())[0]
    ## output = output_bytes.decode()
    temp_filename = gh.create_temp_file(file_text)
    log_filename = f"{temp_filename}.err"
    ## TODO: output = gh.run(f"perl {options} '{command}' < {temp_filename}", namespace={})
    ## TODO: extend gh.run to optionally capture stderr (similalr to gh.issue)
    output = gh.run("perl {opts} '{cmd}' < {temp} 2> {log}",
                    opts=options, cmd=command, temp=temp_filename, log=log_filename)
    debug.trace(6, f"perl_segment_input({file_handle}): => {output}")
    debug.code(6, lambda: debug.trace_fmt(1, "stderr: {log}",
                                          log=system.read_file(log_filename)))
    return output


@click.command()
@click.option("--perl", is_flag=True, help="Uses perl.")
@click.option("--diff", is_flag=True, help="Print the diff between both files.")
def main(perl, diff):
    """Main function"""
    debug.trace(6, f"main({perl}, {diff})")
    file_handle = sys.stdin

    # Read the input, segmenting into units such as by paragraph (e.,g., Perl style)
    if perl:
        output = perl_segment_input(file_handle)
    else:
        output = segment_input(file_handle)
        
    debug.trace_expr(7, output)
    
    # note: output is script text and formatted_outputs converted version (Tana-TODO2: rename both--see 'Tips' in main script)
    formatted_outputs = bash_to_python(output)
    
    # If using diff function, creates the diff
    # note: diff is side-by-side
    if diff:
        print_diff(formatted_outputs)
    else:
        for index, formatted_output in enumerate(formatted_outputs):
            file_label = LABEL_BASH2PYTHON if index == 0 else LABEL_CODEX
            sys.stdout.write(f"------------{file_label}------------\n")
            for line in formatted_output:
                sys.stdout.write(line + "\n")
    return


if __name__ == "__main__":
    debug.trace_current_context(level=TL.QUITE_DETAILED)
    main()                              # pylint: disable=no-value-for-parameter
