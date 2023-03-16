#!/usr/bin/env python3
#
# TODO: Refine overview comments (e.g., notes and technique used)
# Note: no need to get detailed. Just write down main intention and some ideas how it will work.
#
# This script converts from Bash snippets to Python. This is not intended as a general purpose
# conversion utility, which is a major undertaking given the complexities of Bash syntax.
# Instead, this is intended to capture commonly used constructs, such as by Tom O'Hara
# during shell interactions.
#
# Notes:
# - This just outputs the Python code, along with import for helper module and initialization.
#   The user might have to do some minor fixup's before the code will run properly.
# - Simple Bash statements get converted into shell invocation calls (a la os.system).
#     pushd ~/; cp -f .[a-z]* /tmp; popd     =>  run("pushd ~/; cp -f .[a-z]* /tmp; popd")
# - Simple variable assignments get translated directly, but complex runs are converted into echo command.
#     log="run-experiment.log";              =>  log = "run-experiment.log"
#     today=$(date '+%d%b%y')                =>  today = run("echo \"date '+%d%b%y'\"")
# - Simple loops get converted into Python loops, namely for-in and while:
#     for v in abc def: do echo $v; done     =>  for v in ["abc", "def"]: gh.run("echo {v}")
# - Unsupported or unrecognized constructs are flagged as runtime errors:
#     for (( i=0; i<10; i++ )); do  echo $i; done
#         =>
#     # not supported:  for (( i=0; i<10; i++ )); do  echo $i; done
#     raise NotImplementedError()
#
# TODO:
# - Flag constructs not yet implemented:
#   -- C-style for loops (maybe use cursed-for module)
#   -- Bash arrays and hashes #Tana-note: Working on this in a separate file
# - Add more sanity checks (e.g., via debug.assertion).
#

# TODO refine a little
"""Bash snippet to Python conversion"""

# Standard modules
from collections import defaultdict
import os
import re
import subprocess
# Installed modules
import click
import openai

# Local modules
import mezcla
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.main import Main
from mezcla.my_regex import my_re
from mezcla import system
from mezcla.text_utils import version_to_number

## OLD: from mezcla.glue_helpers import run_via_bash as run

# Version check
debug.assertion(version_to_number("1.3.4") <= version_to_number(mezcla.__version__))

# Environment constants
USER = system.getenv_text("USER", "unknown-user",
                          "User ID")
USE_MEZCLA = system.getenv_bool("USE_MEZCLA", (USER == "tomohara"),
                                "Whether to use mezcla support")
INIT_FILE = system.getenv_value("INIT_FILE", None,
                                "File to source before running Bash command")
OPENAI_API_KEY = system.getenv_value("OPENAI_API_KEY", None,
                                     "API key for OpenAI")
JUST_CODEX = system.getenv_bool("JUST_CODEX", False,
                                "Only do conversion via Codex")
USE_CODEX = system.getenv_bool("USE_CODEX", (OPENAI_API_KEY or JUST_CODEX),
                               "Whether to use codex support")

# Global settings
if USE_MEZCLA:
    re = my_re

## TEMP:
## NOTE: Eventually most pylint issues should be resolved (excepting nitpicking ones)
## pylint: disable=no-self-use,unneeded-not

PYTHON_HEADER = """# Output from bash2python.py
'''Python code from Bash snippet'''
from mezcla.glue_helpers import run_via_bash
from mezcla import system

INIT_FILE = system.getenv_value("INIT_FILE", None,
                                "File to source before running Bash command")

def run(command, skip_print=False):
    '''Runs COMMAND and return output. Also, prints non-empty output unless SKIP_PRINT'''
    result = run_via_bash(command, init_file=INIT_FILE)
    if (not skip_print) and result:
       print(result)
    return result
"""


def get_bash_var_hash():
    """Return a lookup hash for checking whether Bash variable is defined
    Note: this includes environment variables as well as regular ones"""
    # Sample listing from Bash set command:
    #   ANACONDA_HOME=/
    #   BASH=/bin/bash
    #   ...
    #   zless ()
    #   {
    #       zcat "$@" | $PAGER
    #   }

    # Extract variables from set command output
    var_hash = defaultdict(bool)
    bash_variable_listing = gh.run_via_bash("set", init_file=INIT_FILE)
    for line in bash_variable_listing.splitlines():
        if my_re.search(r"^([A-Za-z0-9_]+)=", line):
            var_hash[my_re.group(1)] = True

    # Run sanity checks
    if debug.debugging():
        env_vars = sorted(list(os.environ.keys()))
        bash_vars = sorted(list(var_hash.keys()))
        ## TODO: debug.trace_expr(5, bash_vars, env_vars, max_len=2048, sep="\n")
        debug.trace_expr(5, bash_vars, max_len=4096)
        debug.trace_expr(5, env_vars, max_len=4096)
        debug.assertion(not system.difference(env_vars, bash_vars))
        debug.assertion(sorted(system.intersection(env_vars, bash_vars)) == env_vars)
    debug.trace(6, f"get_bash_var_hash() => {var_hash}")
    return var_hash


class Bash2Python:
    """Returns a Python-like file based on Bash input"""
    KEYWORD_MAP = {"function": "def"}
    LOOP_CONTROL = ["break", "continue"]

    ## TODO: simplify initializer (e.g., make bash command and shell option optional)
    ##
    def __init__(self, bash, shell):
        self.cmd = bash
        self.exec = shell
        self.bash_var_hash = get_bash_var_hash()
        self.variables = []

    def perlregex(self, bash_snippet):
        """Simple method to get perl regex detection of embedded for loops"""
        file = (system.open_file(bash_snippet).read() if system.file_exists(bash_snippet)
                    else bash_snippet)
        command = f"echo '{file}'| perl -0777 -ne 's/.*/\L$&/; s/done/D/g; print(\"embedded for: $&\n\") if (/for[^D]*for/m);'"
        process = subprocess.Popen(command, stdout=subprocess.PIPE, shell=True)
        output, _ = process.communicate()
        return output.decode()

    def map_keyword(self, line):
        """Perform conversion for single keyword statement"""
        in_line = line
        if my_re.search(r"^(\s*)(\w+)(.*)$", line):
            indent = my_re.group(1)
            keyword = my_re.group(2)
            remainder = my_re.group(3)
            line = indent + self.KEYWORD_MAP.get(keyword, keyword) + remainder
        debug.trace(5, f"map_keyword({in_line!r}) => {line!r}")
        return line

    def for_in(self, line):
        """TODO: handle FOR var IN list loop"""
        ## NOTE: This regex needs to be tightened up (e.g., the .* parts).
        if my_re.search(r"for .* in (.* )", line):
            value = my_re.group(1)
            values = value.replace(" ", ", ")
            values = f"[{values}]"
            line = line.replace(value, values)
        if my_re.search(r"\{([0-9]*)\.\.([0-9]*)\}", line):
            values = my_re.group(0)
            numberone, numbertwo = my_re.group(1, 2)
            line = line.replace(values, f"range({numberone}, {numbertwo})")
        return line

    def codex_convert(self, line):
        """Uses OpenAI Codex to translate Bash to Python"""
        debug.assertion(USE_CODEX)
        if not USE_CODEX:
            return "# internal error"

        # Apply for an API Key at https://beta.openai.com
        ## OLD: openai.api_key = "YOUR_API_KEY"
        openai.api_key = OPENAI_API_KEY
        # Define the code generation prompt
        ## OLD: prompt = f"Convert this Bash snippet to a one-liner Python snippet: {line}"
        TARGET_LANG = system.getenv_text("TARGET_LANG", "Python",
                                         "Target language for Codex")
        prompt = f"Convert this Bash snippet to a one-liner {TARGET_LANG} snippet: {line}"
        # Call the Codex API
        response = openai.Completion.create(
            engine="text-davinci-002",
            prompt=prompt,
            max_tokens=3 * len(line),
            n=1,
            stop=None,
            temperature=0.6,  # more of this makes response more inestable
        )
        debug.trace_expr(5, response, max_len=4096)
        comment = "#" + response
        return comment

    def var_replace(self, line, other_vars=None, indent=None, is_condition=False, is_loop=False):
        # Tana-note: I'm not convinced this is the best way to do this but it works for now
        ## TODO?: Clean up this mess
        """Replaces bash variables with python variables and also derive run call for LINE
        Notes:
        - Optional converts OTHER_VARS in line.
        - Use INDENT to overide the line space indentation.
        """

        in_line = line
        if indent is None:
            indent = ""
        var_pos = ""
        variable = ""

        if "=" in line:
            line = line.replace("[", "").replace("]", "")
            if " = " in line:
                line = line.split(" = ")
            else:
                line = line.split("=")
            if "$" in line[0] and "$" in line[1]:
                line = " = ".join(line)
            elif "$" in line[0]:
                variable = line[0]
                static = " = " + line[1]
                var_pos = 0
            elif "$" in line[1]:
                variable = line[1]
                static = line[0] + " = "
                var_pos = 1
            elif not "$" in line[0] and not "$" in line[1]:
                return " = ".join(line)
            if variable != "":
                line = variable
        # Derive indentation
        if my_re.search(r"^(\s+)(.*)", line):
            if not indent:
                indent = my_re.group(1)
            line = my_re.group(2)

        # Check variable references and $(...) constructs
        bash_commands = re.findall(r'\$\(.*\)', line)  # finds all bash commands
        bash_vars_with_defaults = re.findall(r'\$\{\w+:-[^\}]+\}', line)  # finds all bash variables with default values
        bash_vars = re.findall(r'\$\w+', line)  # finds the rest of bash variables
        if other_vars:
            bash_vars += other_vars
        # Replace $var references with Python {var}, excluding Bash and environment variables
        has_bash_var = False
        has_default = False
        for var in bash_vars + bash_vars_with_defaults:
            if var in bash_vars_with_defaults:
                var_name = re.search(r'\$\{(\w+):-[^\}]+\}', var).group(1)
                var_default = re.search(r'\$\{\w+:-(.*)\}', var).group(1)
                line = line.replace(var, f"{{{var_name} if {var_name} is not None else '{var_default}'}}")
                has_bash_var = True
                has_default = True
            elif (var[1:] in self.bash_var_hash) and (var not in self.variables):
                debug.trace(4, "Excluding Bash-defined variable {var}")
            else:
                line = line.replace(var, "{" + var[1:] + "}")
                has_bash_var = True
        # Early exit for conditions

        if is_condition:
            # note: change quoted string with {var} to f-string
            line = re.sub(r"(([\'\"]).*\{\S+}.*\2)", r"f\1", line)
            debug.trace(5,
                        f"var_replace({in_line!r}, othvar={other_vars} ind={indent} cond={is_condition}) => {line!r}")
            return line
        ## Early exit for loops
        if is_loop:
            if var_pos == 1:
                line = f"{static}f{line}"
            if var_pos == 0:
                line = f"f{line}{static}"
            return line

        # Make sure line has outer single quotes, with any internal ones quoted
        if "'" in line:
            # note: Bash $'...' strings allows for escaped single quotes unlike '...'
            line = re.sub(r"[^\\]'", r"\\\\'", line)
            line = f'"{line}"'
        else:
            line = f"'{line}'"
        debug.assertion(re.search("^'.*'$", line))
        # Use f-strings if local Python variable to be resolved
        if has_bash_var:
            line = "f" + line
        debug.assertion(re.search("^f?'.*'$", line))

        # Derive run invocation, with output omitted for variable assignments
        has_assignment = (variable != "")
        comment = ""
        if (has_assignment and ("$" not in line)):
            # Remove outer quotes (e.g., '"my dog"' => "my dog" and '123' => 123)
            line = re.sub(r"^'(.*)'$", r"\1", line)
        elif bash_commands:
            # Note: uses echo command with $(...) unless line already uses one
            if (not re.search(r"^f?'echo ", line)):
                line = re.sub("'", "'echo ", line, count=1)
            comment = self.codex_convert(line)
            line = f"run({line}, skip_print={has_assignment})"
        elif has_default:
            ## OLD: line = line
            pass
        else:
            comment = self.codex_convert(line)
            line = f"run({line})"
        debug.assertion(not is_condition)
        debug.trace_expr(3, line, comment)

        # Add variable assignment and indentation
        try:
            if var_pos == 1:
                line = f"{static}{line}"
            if var_pos == 0:
                line = f"{line}{static}"
        except:
            pass
        if indent:
            line = indent + line

        debug.trace(5, f"var_replace({in_line!r}, othvar={other_vars} ind={indent} cond={is_condition}) => {line!r}")
        return line

    def operators(self, line):
        """Returns line with operators converted to Python equivalents"""
        # Dictionary with Bash operators and their Python equivalents
        operators = {" = ": " == ",
                     " != ": " != ",
                     " ! ": "not ",
                     "- eq ": " == ",
                     "-e": " os.path.exists ",
                     "-ne": " != ",
                     "-gt": " > ",
                     "-ge": " >= ",
                     "-lt": " < ",
                     "-le": " <= ",
                     "-z": " '' == ",
                     "-n": " '' != ",
                     "&&": " and ",
                     r"\|\|": " or ",  # NOTE: need to escape | for Python
                     }

        in_line = line
        # Iterate over operators and replace them with Python equivalents
        for bash_operator, python_equivalent in operators.items():
            line = re.sub(rf"(\S*) *{bash_operator} *(\S*)", fr"\1{python_equivalent}\2", line).replace("[",
                                                                                                        "").replace("]",
                                                                                                                    "")
        # Replace Bash true/false statements with Python equivalent
        line = re.sub(r"\[ 1 \]", "True", line)
        line = re.sub(r"\[ 0 \]", "False", line)
        debug.trace(5, f"operators({in_line!r}) => {line!r}")
        return line

    def process_simple(self, line):
        """Process simple statement conversion for LINE"""
        debug.trace(6, f"in process_simple({line!r})")
        in_line = line
        converted = False
        # Convert miscellenous commands
        # - break
        # TODO: continue (dont think this is needed)
        debug.trace(6, "checking miscellenous")
        if (line.strip() == "break"):
            debug.trace(4, "processing break")
            converted = True
        # - arithmetic expression
        #   (( expr ))
        if my_re.search(r"^(\s*)\(\( (.*) \)\)\s*$", line):
            debug.trace(4, "processing arithmetic expression")
            indent = my_re.group(1)
            expression = my_re.group(2)
            line = (indent + expression)
            converted = True
        if re.search(r"let \"(\S*)\"", line):
            debug.trace(4, "processing let")
            line = re.sub(r"let \"(\S*)\"", r"\1", line)
            converted = True
        debug.trace(7, f"process_simple({in_line!r}) => ({converted}, {line!r})")
        return (converted, line)

    def process_compound(self, line, cmd_iter):
        """Process compound statement conversion for LINE"""
        # Declare loop and statements as a tuple
        for_loop = ("for", " do ", "done")
        while_loop = ("while", " do ", "done")
        if_loop = ("if", "then", "fi")
        elif_loop = ("elif", "then", "fi")
        else_loop = ("else", "", "fi")  # Else statements do not have a keyword so None
        loops = (elif_loop, for_loop, while_loop, if_loop, else_loop)
        body = ""
        loop_count = 0
        loopy = []
        actual_loop = ()
        converted = False
        loop_line = line
        indent = ""
        comment = ""
        # Emulates a do while loop in python
        do_while = True
        while loop_count > 0 or do_while:
            loop_line = loop_line.strip()
            do_while = False
            if loop_count > 1:
                comment = f"#b2py: Loop founded order {loop_count}. Please be careful\n"
            if not loop_line or loop_line == "\n":
                break
            elif "#" in loop_line:
                body += indent + "    " + loop_line + "\n"
            elif my_re.search(
                fr"^(?!\*)\s*({loops[0][0]}|{loops[1][0]}|{loops[2][0]}|{loops[3][0]})\s+(\S.*)((?=;))",
                    loop_line + "\n"):
                if my_re.group(1) != "elif":
                    loop_count += 1
                    indent = "    " * (loop_count - 1)
                    loopy.append(my_re.group(1) + "_loop")
                else:
                    loopy.append("elif_loop")
                var = self.var_replace(my_re.group(2), is_loop=True)
                var = self.operators(var)
                actual_loop = eval(loopy[-1])
                var = var.replace(";" + actual_loop[1], "")
                body += f"{indent}{actual_loop[0]} {var}:\n"
                debug.trace_expr(5, loop_line)
                debug.trace(4, f"Processing {loopy[0][0]} loop")
            elif loop_line == "else":
                body += indent + loop_line + ":\n"
                loop_count += 1

            else:
                if not actual_loop:
                    return False, line
                    break
                if actual_loop[1] == loop_line:
                    loop_line = ""
                elif actual_loop[2] == loop_line:
                    loop_line = ""
                    loop_count -= 1
                    loopy.pop()
                    try:
                        actual_loop = eval(loopy[-1])
                    except IndexError:
                        break
                if loop_line.strip() in self.LOOP_CONTROL:
                    body += loop_line + "\n"
                    body += self.map_keyword(loop_line) + "\n"
                elif loop_line.strip():
                    (converted, loop_line) = self.process_simple(loop_line)
                    if converted:
                        body += indent + "    " + loop_line + "\n"
                    else:
                        body += "" + self.var_replace(loop_line.strip("\n"),
                                                indent="    " * loop_count) + "\n"
                converted = True
            loop_line = next(cmd_iter, None)
        body = comment + body
        return converted, body

    def format(self, codex):
        """Convert self.cmd into python, returning text"""  # TODO: refine
        # Tom-Note: This will need to be restructured. I preserved original for sake of diff.
        python_commands = []
        cmd_iter = (system.open_file(self.cmd) if system.file_exists(self.cmd)
                    else iter(self.cmd.replace(";", "\n").splitlines(keepends=True)))
        if cmd_iter:
            for line in cmd_iter:  # for each line in the script
                debug.trace_expr(5, line)
                if (not line.strip()) or re.search(r"^\s*#", line) or line.startswith("{") or line.startswith("}"):
                    python_commands.append(line.strip("\n"))
                    continue
                line = line.strip("\n")
                # if comment line, skip
                comment = ""
                if "#" in line:
                    line, comment = line.split("#", 1)
                if codex:
                    line = self.codex_convert(line)
                    python_commands.append(line)
                    continue

                (converted, line) = self.process_compound(line, cmd_iter)
                if not converted:
                    line = self.var_replace(line)
                    (converted, line) = self.process_simple(line)
                # Adhoc fixups
                if comment:
                    line += f" # {comment}"
                python_commands.append(line)
        return "\n".join(python_commands)

    def header(self):
        """Returns Python header to use for converted snippet code"""
        return PYTHON_HEADER


# -------------------------------------------------------------------------------
@click.command()
@click.option("--script", "-s", help="Script or snippet to convert")
@click.option("--output", "-o", help="Output file")
@click.option("--overview", help="List of what is working for now")
@click.option("--execute", is_flag=True, help="Try to run the code directly (probably brokes somewhere)")
@click.option("--line-numbers", is_flag=True, help="Add line numbers to the output")
@click.option("--codex", is_flag=True, help="Use OpenAI Codex to port all the code. It's SLOW")
@click.option("--stdin", "-i", is_flag=True, help="Get input from stdin")

def main(script, output, overview, execute, line_numbers, codex, stdin):
    """Entry point"""
    if overview:
        print("""Working: 
            -If, elif, else, and while.
            -Variable Assignments, all of them. 
            -Piping to file. (Uses bash for it)
            -All kind of calls to system. 
            -Printing (still using run(echo) for it)
            -AI sugestions using OpenAI GPT-3 Codex (requires API key)
            -Bash defaults
Not working yet: 
            -For loops (there is an untested function)")
            -Writing on / reading files
            -Bash functions
            -Any kind of subprocess
            -C-style loops """)
    debug.trace(3,
                f"main{(script, output, overview, execute, line_numbers, codex, stdin)}: script={system.real_path(__file__)}")
    bash_snippet = script

    # Optionally get script from standard input (stdin)
    if stdin:
        debug.assertion(not bash_snippet)
        dummy_main_app = Main([], description=__doc__, skip_input=False, manual_input=True)
        debug.assertion(dummy_main_app.parsed_args)
        bash_snippet = dummy_main_app.read_entire_input()

    # If just converting via Codex, show the result and stop.
    if JUST_CODEX:
        b2p = Bash2Python(None, None)
        print(b2p.codex_convert(bash_snippet))
        return

    if not bash_snippet:
        print("No script or snippet specified. Use --help for usage or --script to specify a script")
        return

    # HACK: override global flag
    global USE_CODEX
    if codex and not USE_CODEX:
        USE_CODEX = codex

    if line_numbers:
        with open(script, encoding='UTF-8', mode='r') as infile, \
                open(script + ".b2py", encoding='UTF-8', mode='w') as outfile:
            # Loop through each line in the input file
            for i, line in enumerate(infile):
                # Write the modified line to the output file
                if line.startswith("#"):
                    outfile.write(line)
                elif line == "\n":
                    outfile.write(line)
                else:
                    outfile.write(f"{line}#b2py #Line {i}" + "\n")
        bash_snippet = script + ".b2py"

    ## OLD:
    ## # Show simple usage if --help given
    ## if USE_MEZCLA:
    ##     dummy_main_app = Main(description=__doc__, skip_input=False, manual_input=False)
    ##     debug.assertion(dummy_main_app.parsed_args)
    ##     bash_snippet = dummy_main_app.read_entire_input()


    # Convert and print snippet
    b2p = Bash2Python(bash_snippet, "bash -c")
    if output:
        ## BAD: with open(output, "rw") as out_file:
        ## NOTE: easier to use helper like system.write_file (or system.write_lines)
        with open(output, encoding="UTF-8", mode="w") as out_file:
            out_file.write(b2p.header())
            out_file.write(b2p.format(codex))
    if execute:
        cmd = b2p.format(codex)
        print(f"# {cmd}")
        print(eval(str(cmd)))  # pylint: disable=eval-used
    else:
        #print(b2p.header())
        print(b2p.perlregex(bash_snippet))
        print(b2p.format(codex))


# -------------------------------------------------------------------------------
if __name__ == '__main__':
    # pylint: disable=no-value-for-parameter
    main()
