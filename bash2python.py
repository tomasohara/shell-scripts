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
#   -- C-style for loops
#   -- Bash arrays and hashes
# - Add more sanity checks (e.g., via debug.assertion).
#

# TODO refine a little
"""Bash snippet to Python conversion"""

# Standard modules
from collections import defaultdict
import os
import re

# Local modules
import mezcla
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.main import Main
from mezcla.my_regex import my_re
from mezcla import system
from mezcla.text_utils import version_to_number 

# Version check
debug.assertion(version_to_number("1.3.4") <= version_to_number(mezcla.__version__))

# Environment constants
USER = system.getenv_text("USER", "unknown-user",
                          "User ID")
USE_MEZCLA = system.getenv_bool("USE_MEZCLA", (USER == "tomohara"),
                                "Whether to use mezcla support")
INIT_FILE = system.getenv_value("INIT_FILE", None,
                                "File to source before running Bash command")


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
    """Class for converting Bash statements into Python"""       # TODO: refine docstring
    KEYWORD_MAP = {"function": "def"}
    LOOP_CONTROL = ["break", "continue"]
    
    def __init__(self, bash, executer):
        ## TODO: clarify arguments (e.g., executer); make sure string input accepted as well as file
        self.cmd = bash  # bash script
        self.exec = executer
        self.bash_var_hash = get_bash_var_hash()
        self.variables = []
        ##TODO: self.run(f'bash -n {bash}') # checks if the bash script is valid

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
        
    ## Note: This is not needed: the run function gets defined in the output code.
    ## TODO: drop
    def run(self, cmd):
        """Runs the python script"""
        # TODO: make it work

    ## Note: This is not needed: environment variables are resolved by Bash during run()
    ## TODO: drop
    def envs(self, line):
        """Handles environment variables"""
        # TODO: Almost all. This is just incomplete
        line = line.replace("export", "os.environ")
        line = line.replace("=", " = ")
        line = line.replace("{", "['").replace("}", "']")
        return line

    def boolean(self, line):
        """Handles booleans"""
        # TODO: Make this function more generic
        in_line = line
        ## TODO: handle do-removal below (e.g., in loop parsing code)
        line = line.replace("; do", ": ")
        if "[ 1 ]" in line:  # if the line is a "true" bash statement
            line = line.replace("[ 1 ]", "True")  # replace with python "true" statement
        elif "[ 0 ]" in line:  # if the line is a "false" bash statement
            line = line.replace("[ 0 ]", "False")  # replace with python "false" statement
        ## Tom-note: changed followng form elif to if as more than one possible
        if "||" in line:
            line = line.replace("||", " or ")
        if "&&" in line:
            line = line.replace("&&", " and ")
        if my_re.search(r"(^.*\S+) = (\S+.*$)", line):
            debug.trace(4, "Equality test fixup")
            line = my_re.group(1) + " == " + my_re.group(2)
        debug.trace(5, f"boolean({in_line!r}) => {line!r}")
        return line

    def var_replace(self, line, other_vars=None, indent=None, is_condition=False):
        """Replaces bash variables with python variables and also derive run call for LINE
        Notes:
        - Optional converts OTHER_VARS in line.
        - Use INDENT to overide the line space indentation.
        """
        in_line = line
        if indent is None:
            indent = ""

        # Derive indentation
        if my_re.search(r"^(\s+)(.*)", line):
            if not indent:
                indent = my_re.group(1)
            line = my_re.group(2)

        # Check variable references and $(...) constructs
        variable = ""
        bash_commands = re.findall(r'\$\(.*\)', line)  # finds all bash commands
        bash_vars = re.findall(r'\$\w+', line)         # finds all bash variables
        if other_vars:
            bash_vars += other_vars
        # TODO: Use regex (e.g., re.search(r"^\s*[a-z0-9_]+\s+=", line))
        if ("=" in line) and (not is_condition):       # if the line is a variable declaration
            line = line.split("=")
            variable = line[0]                         # isolates variable name
            line = line[1]                             # isolates the rest of the line
            self.variables.append("$" + variable)

        # Replace $var references with Python {var}, excluding Bash and environment variables
        has_bash_var = False
        for var in bash_vars:
            if (var[1:] in self.bash_var_hash) and (var not in self.variables):
                debug.trace(4, "Excluding Bash-defined variable {var}")
            else:
                line = line.replace(var, "{" + var[1:] + "}")
                has_bash_var = True

        # Early exit for conditions
        # TODO: re-factor code
        if is_condition:
            # note: change quoted string with {var} to f-string
            line = re.sub(r"(([\'\"]).*\{\S+\}.*\2)", r"f\1", line)
            debug.trace(5, f"var_replace({in_line!r}, othvar={other_vars} ind={indent} cond={is_condition}) => {line!r}")
            return line
                
        # Make sure line has outer single quotes, with any internal ones quoted
        if "'" in line:
            # note: Bash $'...' strings allows for escaped single quotes unlike '...'
            line = re.sub(r"[^\\]'", r"\\\\'", line)
            line = f"$'{line}'"
        else:
            line = f"'{line}'"
        debug.assertion(re.search("^'.*'$", line))

        # Use f-strings if local Python variable to be resolved
        if has_bash_var:
            line = "f" + line
        debug.assertion(re.search("^f?'.*'$", line))

        # Derive run invocation, with output omitted for variable assignments
        has_assignment = (variable != "")
        if (has_assignment and ("$" not in line)):
            # Remove outer quotes (e.g., '"my dog"' => "my dog" and '123' => 123)
            line = re.sub(r"^'(.*)'$", r"\1", line)
        elif bash_commands:
            # Note: uses echo command with $(...) unless line already uses one
            if (not re.search(r"^f?'echo ", line)):
                line = re.sub("'", "'echo ", line, count=1)
            line = f"run({line}, skip_print={has_assignment})"
        else:
            line = f"run({line})"
        debug.assertion(not is_condition)

        # Add variable assignment and indentation
        if has_assignment:
            line = variable + " = " + line
        if indent:
            line = indent + line

        debug.trace(5, f"var_replace({in_line!r}, othvar={other_vars} ind={indent} cond={is_condition}) => {line!r}")
        return line

    def process_simple(self, line):
        """Process simple statement conversion for LINE"""
        debug.trace(6, f"in process_simple({line!r})")
        in_line = line
        converted = False
        # Convert miscellenous commands
        # - break
        # TODO: {let, continue}
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
        debug.trace(7, f"process_simple({in_line!r}) => ({converted}, {line!r})")
        return (converted, line)


    def process_compound(self, line, cmd_iter):
        """Process compound statement conversion for LINE using COMMAND_ITERATOR"""
        debug.trace(6, f"in process_compound({line!r})")
        in_line = line
        converted = False

        # Convert simple while loop:
        #    while [ condition ]; do ... done
        # TODO: Change the if statements to a dictionary or a list
        # TODO: ¿Change this to a function?
        bucle = ""
        # TODO: if re.search(r"^\s*while \S+ ", line):
        if "while" in line:  # if the line is a while loop
            debug.trace(4, "processing while loop")
            body = ""
            while not "done" in body:  # while the loop is not finished
                # Adds the next line to the body unless empty
                loop_line = next(cmd_iter, None)
                debug.trace_expr(5, loop_line)
                # Stop when done statement reached (or EOF)
                if (loop_line is None) or (loop_line.strip() == "done"):
                    break
                loop_line = loop_line.strip("\n").strip(";")
                if loop_line.strip() in self.LOOP_CONTROL:
                    body += self.map_keyword(loop_line) + "\n"
                elif loop_line.strip():
                    (converted, loop_line) = self.process_simple(loop_line)
                    if converted:
                        body += loop_line + "\n"
                    else:
                        body += self.var_replace(loop_line.strip("\n"),
                                                 indent="    ") + "\n"
            # Note; 'bucle' is Spanish for loop
            bucle = self.boolean(line)  # calls bucle function
            # TODO: warn that parenthesis stripped;
            # Also, use regex replacement (e.g., re.sub("^(\s+)\(\s*while", r"\1while", bucle))
            bucle = bucle.replace("(while", "while")
            line = body.replace("done)", "")
            line = line.replace("done", "")
            line = bucle + "\n" + line
            converted = True

        # Convert simple for-in loop
        #   for var in value ...; do statement; ... done
        if my_re.search(r"^\s*for (\w+) in ([^;]+); do\s*$", line):
            loop_var = my_re.group(1)
            values = my_re.group(2).split()
            debug.trace(4, "processing for-in loop")

            # Convert body to run() calls with loop variable expansion
            #    for var in ["v1", ... "vn"]: <newline><indent> statement ...
            values = ('["' + '", "'.join(values) + '"]')
            body = f"for {loop_var} in {values}:\n"
            while True:
                loop_line = next(cmd_iter, None)
                debug.trace_expr(5, loop_line)
                # Stop early if EOF reached
                if loop_line is None:
                    break
                loop_line = loop_line.strip("\n").strip(";")
                # Stop when done statement found
                if (loop_line.strip() == "done"):
                    break
                if loop_line.strip() in self.LOOP_CONTROL:
                    body += self.map_keyword(loop_line) + "\n"
                elif loop_line.strip():
                    (converted, loop_line) = self.process_simple(loop_line)
                    if converted:
                        body += loop_line + "\n"
                    else:
                        body += self.var_replace(loop_line.strip("\n"),
                                                 indent="    ") + "\n"
            line = body
            converted = True

        # Convert simple for-in loop
        #   for var in value ...; do statement; ... done
        if my_re.search(r"^\s*for (\w+) in ([^;]+); do\s*$", line):
            loop_var = my_re.group(1)
            values = my_re.group(2).split()
            debug.trace(4, "processing for-in loop")

            # Convert body to run() calls with loop variable expansion
            values = ('["' + '", "'.join(values) + '"]')
            body = f"for {loop_var} in {values}:\n"
            while True:
                loop_line = next(cmd_iter, None)
                debug.trace_expr(5, loop_line)
                # Stop early if EOF reached
                if loop_line is None:
                    break
                loop_line = loop_line.strip("\n").strip(";")
                # Stop when done statement found
                if (loop_line.strip() == "done"):
                    break
                if loop_line.strip() in self.LOOP_CONTROL:
                    body += self.map_keyword(loop_line) + "\n"
                elif loop_line.strip():
                    (converted, loop_line) = self.process_simple(loop_line)
                    if converted:
                        body += loop_line + "\n"
                    else:
                        body += self.var_replace(loop_line.strip("\n"),
                                                 other_vars=["$" + loop_var], 
                                                 indent="    ") + "\n"
            line = body
            converted = True

        # Convert simple-if to python
        #   if [ condition ]; then ... fi
        # TODO: elif's
        # TODO: my_re.search(r"^ if \[ ([^\[\]]+) \]; then (.*)$", line, flags=re.VERBOSE):
        debug.trace(6, "checking if-then")
        if (my_re.search(r"^\s*if\s+\[\s*([^\[\]]+)\s+\];\s+then\s*$", line)
            or my_re.search(r"if.*\[(.*)\];.*then", line)):
            condition = my_re.group(1)
            debug.trace(4, "processing if-then statement")

            # Convert condition to Python syntax
            condition = self.var_replace(self.boolean(condition),
                                         is_condition=True)
            body = f"if {condition}:\n"

            # Add in each block statement to body
            while True:
                block_line = next(cmd_iter, None)
                debug.trace_expr(5, block_line)
                # Stop early if EOF reached
                if block_line is None:
                    break
                block_line = block_line.strip("\n").strip(";")
                # Stop when fi statement found
                if (block_line.strip() == "fi"):
                    break
                if (block_line.strip() == "else"):
                    body += "else:\n"
                elif block_line.strip():
                    (converted, block_line) = self.process_simple(block_line)
                    if converted:
                        body += block_line + "\n"
                    else:
                        body += self.var_replace(block_line.strip("\n"),
                                                 indent="    ") + "\n"
                    
            line = body
            converted = True

        debug.trace(7, f"process_compound({in_line!r}) => ({converted}, {line!r})")
        return (converted, line)
            
    
    def format(self):
        """Convert self.cmd into python, returning text"""    # TODO: refine
        # Tom-Note: This will need to be restructured. I preserved original for sake of diff.
        python_commands = []
        cmd_iter = (system.open_file(self.cmd) if system.file_exists(self.cmd)
               else iter(self.cmd.splitlines(keepends=True)))
        if cmd_iter:
            for line in cmd_iter:  # for each line in the script
                debug.trace_expr(5, line)
                if (not line.strip()) or re.search(r"^\s*#", line):
                    python_commands.append(line.strip("\n"))
                    continue
                # TODO: preserve whitespace (e.g., to allow for embedded loops)
                line = line.strip("\n")
                line = line[:-1] if ";" == line[-1] else line  # remove the ";" last character
                (converted, line) = self.process_compound(line, cmd_iter)
                if not converted:
                    (converted, line) = self.process_simple(line)
                
                # Adhoc fixups
                if " & " in line:  # if the line is a background process
                    # TODO: make this optional
                    line = line.replace(" & ", "")
                if not converted:
                    line = self.var_replace(line)
                if line[0] == "(" and line[-2] == ")":
                    line = line[1:-2]       # removes the parenthesis
                if line[-2] == "&":
                    # TODO: make this optional
                    line = line[:-2]
                python_commands.append(line)
        return "\n".join(python_commands)

    def header(self):
        """Returns Python header to use for converted snippet code"""
        return PYTHON_HEADER

#-------------------------------------------------------------------------------

def main():
    """Entry point"""
    debug.trace(3, f"main(): script={system.real_path(__file__)}")
    bash_snippet = "TODO"

    # Show simple usage if --help given
    if USE_MEZCLA:
        dummy_main_app = Main(description=__doc__, skip_input=False, manual_input=False)
        debug.assertion(dummy_main_app.parsed_args)
        bash_snippet = dummy_main_app.read_entire_input()

    # Convert and print snippet
    b2p = Bash2Python(bash_snippet, "bash -c")
    print(b2p.header())
    print(b2p.format())
    return

#-------------------------------------------------------------------------------

if __name__ == '__main__':
    main()
