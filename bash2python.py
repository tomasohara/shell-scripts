#!/usr/bin/env python
#
# Tana-TODO: Refine overview comments (e.g., notes and technique used)
# Note: no need to get detailed. Just write down main intention and some ideas how it will work.
#
# This script converts from Bash snippets to Python. This is not intended as a general purpose
# conversion utility, which is a major undertaking given the complexities of Bash syntax.
# Instead, this is intended to capture commonly used constructs, such as by Tom O'Hara
# during shell interactions. For such constructs, see header commments in following:
#    https://github.com/tomasohara/shell-scripts/blob/main/template.bash
#
# There is support for doing the converion via OpenAI's Codex, which was trained on
# Github. See bash2python_diff.py for code that invokes both the regex approach
# and the Codex approach, showing the conversions in a side-by-side diff listing.
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
# - stuff for code linters
#   # pylint: disable=eval-used
# - OpenAI API reference: https://platform.openai.com/docs/api-reference
#
# Tips:
# - *** Err on the side of special case code rather than general purpose. For example,
#   one of the updates clobbered special case conversion of for-in loops with support for array values.
# - ** Always add new test cases when making significant changes.
# - ** Avoid regular string searching or replacements (e.g., "done" in line => re.search('\bdone\b', line).
# - * Be liberal with variables (e.g., don't reuse same variable for different purpose and make name self explanatory)@.
#
# Tana-TODO1:
# - Add a bunch of more sanity checks (e.g., via debug.assertion).
# TODO2:
# - Make sure pattern matching accounts for word boundaries (e.g., line.replace("FOR", ...) => re.sub(r"\bFOR\b", "...", line).
# - Also make sure strings excluded from matches (e.g., "# This for loop ..." =/=> "# This FOR loop").
# - Use bashlex and/or shlex for sanity checks on the regex parsing used here.
# TODO3:
# - Flag constructs not yet implemented:
#   -- C-style for loops (maybe use cursed-for module)
#   -- Bash arrays and hashes #Tana-note: Working on this in a separate file
#

# Tana-TODO refine a little
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
## TEMP: nuclear option to disable Codex
SKIP_CODEX = system.getenv_bool("USE_CODEX", (not USE_CODEX),
                                "Temporary hack to ensure codex not invoked")
INCLUDE_ORIGINAL = system.getenv_bool("INCLUDE_ORIGINAL", False,
                                      "Include original code as comment")
SKIP_HEADER = system.getenv_bool("SKIP_HEADER", False,
                                 "Omit header with imports and run definition")
INCLUDE_HEADER = (not SKIP_HEADER)
SKIP_COMMENTS = system.getenv_bool("SKIP_COMMENTS", False,
                                   "Omit comments from generated code")

# Global settings
if USE_MEZCLA:
    re = my_re

## TEMP:
## NOTE: Eventually most pylint issues should be resolved (excepting nitpicking ones)
## pylint: disable=unneeded-not, line-too-long, fixme

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
    if debug.detailed_debugging():
        env_vars = sorted(list(os.environ.keys()))
        bash_vars = sorted(list(var_hash.keys()))
        ## TODO: debug.trace_expr(5, bash_vars, env_vars, max_len=2048, sep="\n")
        debug.trace_expr(5, bash_vars, max_len=4096)
        debug.trace_expr(5, env_vars, max_len=4096)
        debug.assertion(not system.difference(env_vars, bash_vars))
        debug.assertion(sorted(system.intersection(env_vars, bash_vars)) == env_vars)
    debug.trace(6, f"get_bash_var_hash() => {var_hash}")
    return var_hash


def embedded_in_quoted_string(subtext, text):
    """Whether SUBTEXT of TEXT in contained in a quote"""
    # ex: embedded_in_quoted_string("#", "echo '#-sign'")
    # ex: not embedded_in_quoted_string("#", 'let x++     # incr x w/ init')
    result = (my_re.search(fr"'[^']*{subtext}[^']*'", text) or
              my_re.search(rf'"[^"]*{subtext}[^"]*"', text))
    debug.trace(7, f"embedded_in_quoted_string{(subtext, text)} => {result}")
    return result


def safe_eval(expression):
    """Evaluates expression returning as a string
    Note: returns input as is if there is an error
    """
    result = expression
    try:
        result = eval(expression)       # pylint: disable=eval-used
    except:
        debug.trace_exception(7, f"safe_eval({expression}")
    return result

    
class Bash2Python:
    """Returns a Python-like file based on Bash input"""
    KEYWORD_MAP = {
        "function": "def",
        "true": "pass"}
    LOOP_CONTROL = ["break", "continue"]

    ## Tana-TODO: simplify initializer (e.g., make bash command and shell option optional)
    ##
    def __init__(self, bash, shell, skip_comments=None):
        self.cmd = bash
        self.exec = shell
        self.bash_var_hash = get_bash_var_hash()
        self.variables = []             # TODO: obsolete???
        if skip_comments is None:
            skip_comments = SKIP_COMMENTS
        self.skip_comments = skip_comments
        debug.trace_object(5, self, label=f"{self.__class__.__name__} instance")

    def perlregex(self, bash_snippet):
        """Simple method to get perl regex detection of embedded for loops"""
        # TODO: rename to something like contains_embedded_for
        file = (system.open_file(bash_snippet).read() if system.file_exists(bash_snippet)
                    else bash_snippet)
        debug.trace_expr(7, file)
        # TODO: strip comments and quoted strings
        command = f"echo '{file}' | perl -0777 -ne 's/.*/\\L$&/; s/\\bdone\\b/D/g; print(\"embedded for: $&\n\") if (/\\bfor\\b[^D]*\\bfor\\b/m);'"
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
        """Tana-TODO: Deprecated? Check if necessary or delete"""
        # ex: for v in a b c; do echo $v; done
        if my_re.search(r"for .* in (.* )", line):
            value = my_re.group(1)
            values = value.replace(" ", ", ")
            values = f"[{values}]"
            line = line.replace(value, values)
        # ex: for n in {1..9}; do echo $n; done
        if my_re.search(r"\{([0-9]*)\.\.([0-9]*)\}", line):
            values = my_re.group(0)
            numberone, numbertwo = my_re.group(1, 2)
            line = line.replace(values, f"range({numberone}, {numbertwo})")
        return line

    def codex_convert(self, line):
        """Uses OpenAI Codex to translate Bash to Python"""
        # Tana-TODO1: eliminate the extraneus invocations
        if SKIP_CODEX:
            return "# internal warning (SKIP_CODEX set)"
        debug.assertion(USE_CODEX)
        if not USE_CODEX:
            return "# internal error (USE_CODEX not set)"

        # Make sure OpenAI key set
        # note: Apply for an API Key at https://beta.openai.com
        debug.assertion(OPENAI_API_KEY)
        if (not (OPENAI_API_KEY or "").strip()):
            return "# OPENAI_API_KEY not set"        
        openai.api_key = OPENAI_API_KEY

        # Define the code generation prompt
        TARGET_LANG = system.getenv_text("TARGET_LANG", "Python",
                                         "Target language for Codex")
        prompt = f"Convert this Bash snippet to a one-liner {TARGET_LANG} snippet: {line}"
        
        # Call the Codex API
        # TODO: cache the result (e.g., for debugging)
        comment = ""
        try:
            # Submit request
            response = openai.Completion.create(
                engine="text-davinci-002",
                prompt=prompt,
                max_tokens=3 * len(line),
                n=1,
                stop=None,
                temperature=0.6,  # more of this makes response more inestable
            )
            debug.trace_expr(5, response, max_len=4096)

            # Extract text for first choice and convert into single-line comment
            ## BAD: comment = "#" + response
            comment = "#" + response["choices"][0]["text"].replace("\n", " ").strip()
        except:
            system.print_exception_info("codex_convert")
        return comment

    def var_replace(self, line, other_vars=None, indent=None, is_condition=False, is_loop=False):
        # Tana-note: I'm not convinced this is the best way to do this but it works for now
        """Replaces bash variables with python variables and also derive run call for LINE
        Notes:
        - Optional converts OTHER_VARS in line.
        - Use INDENT to overide the line space indentation.
        """
        # Note: is_condition is no longer used

        in_line = line
        if indent is None:
            indent = ""
        var_pos = ""
        variable = ""
        var_replace_call = f"var_replace({in_line!r}, othvar={other_vars} ind={indent} cond={is_condition})"

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
                result = " = ".join(line)
                debug.trace(5, f"[early exit 1] {var_replace_call} => {result!r}")
                return result
            if variable != "":
                line = variable
        debug.trace(6, f"line1={line}")

        # Derive indentation
        if my_re.search(r"^(\s+)(.*)", line):
            if not indent:
                indent = my_re.group(1)
            line = my_re.group(2)
            debug.trace(6, f"line2={line}")

        # Handle arithmetic expansion (n.b., creates f-string for sake of string concatenation as in echo statement)
        # - ex: $(( x + y )) => f"{x + y}"
        while my_re.search(r"(.*)\$\(\( *(.*) *\)\)(.*)", line):
            # TODO: Handle multiple occurrences
            debug.trace(4, "processing arithmetic expansion")
            (pre, expression, post) = my_re.groups()
            ## OLD:  line = f"{pre} ({expression}) {post}"
            # Note: converts expression to f-string
            ## BAD:
            line = pre + 'f"{' + expression + '}"' + post
            ## TODO?: line = pre + safe_eval(expression) + post
        debug.trace(6, f"line3={line}")

        # Check variable references and $(...) constructs
        bash_commands = re.findall(r'\$\(.*\)', line)  # finds all bash commands
        bash_vars_with_defaults = re.findall(r'\$\{\w+:-[^\}]+\}', line)  # finds all bash variables with default values
        bash_vars = re.findall(r'\$\w+', line)                            # finds the rest of normal bash variables
        bash_commmon_special_vars = re.findall(r'\$[\?\@]', line)         # finds commonly used special variables
        if other_vars:
            bash_vars += other_vars
        # Replace $var references with Python {var}, excluding Bash and environment variables
        has_bash_var = False
        has_default = False
        for var in bash_vars + bash_vars_with_defaults + bash_commmon_special_vars:
            converted = False
            if var in bash_vars_with_defaults:
                var_name = re.search(r'\$\{(\w+):-[^\}]+\}', var).group(1)
                var_default = re.search(r'\$\{\w+:-(.*)\}', var).group(1)
                line = line.replace(var, f"{{{var_name} if {var_name} is not None else '{var_default}'}}")
                has_bash_var = True
                has_default = True
            elif (var in bash_commmon_special_vars):
                if is_loop:
                    line = line.replace(var, f"run(echo '{var}')")
                    debug.trace(4, f"Special case handling of Bash special variable {var}: line={line!r}")
                converted = True
            elif (var[1:] in self.bash_var_hash) and (var not in self.variables):
                debug.trace(4, "Excluding Bash-defined variable {var}")
            else:
                pass
            if ((not converted)):
                if is_loop:
                    # HACK: drop $-prefix in loop (n.b., assumes test with local variable)
                    line = my_re.sub(fr"\${var[1:]}\b", var[1:], line)
                else:
                    line = my_re.sub(fr"\${var[1:]}\b", "{" + var[1:] + "}", line)
                    has_bash_var = True
        debug.trace(6, f"line4={line}")
        
        # Early exit for conditions
        if is_condition:
            # note: change quoted string with {var} to f-string
            line = re.sub(r"(([\'\"]).*\{\S+}.*\2)", r"f\1", line)
            debug.trace(5, f"[early exit 2] {var_replace_call} => {line!r}")
            return line
        # Early exit for loops
        if is_loop:
            if var_pos == 1:
                line = f"{static}f{line}"
            if var_pos == 0:
                line = f"f{line}{static}"
            debug.trace(5, f"[early exit 3] {var_replace_call} => {line!r}")
            return line

        # Do special processing for single statement lines
        is_compound_statement = ((";" in line) and
                                 (not re.search(r"""^(['"])[^\1]*;\1$""", line)))
        if is_compound_statement:
            debug.assertion(not embedded_in_quoted_string(";", line))
        else:
            # Make sure line has outer single quotes, with any internal ones quoted
            if "'" in line:
                # note: Bash $'...' strings allows for escaped single quotes unlike '...'
                # The regex (?<...) is for negative lookbehind
                # OLD: line = re.sub(r"[^\\]'", r"\\\\'", line)
                line = re.sub(r"(?<!\\)(')", r"\\\\\1", line)
                line = f'"{line}"'
            else:
                line = f"'{line}'"
            debug.trace(6, f"line5={line}")
            debug.assertion(re.search(r"""^(['"]).*\1$""", line))
                                                    #
            # Use f-strings if local Python variable to be resolved
            if has_bash_var:
                line = "f" + line
            debug.assertion(re.search(r"""^f?(['"]).*\1$""", line))

        # Derive run invocation, with output omitted for variable assignments
        has_assignment = (variable != "")
        comment = ""
        if (has_assignment and ("$" not in line)):
            # Remove outer quotes (e.g., '"my dog"' => "my dog" and '123' => 123)
            line = re.sub(r"^'(.*)'$", r"\1", line)
        elif bash_commands:
            # Note: uses echo command with $(...) unless line already uses one
            # TODO: handle arithmetic expansions (e.g., "echo $(( x + y ))
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
        debug.trace(6, f"line6={line}")

        # Special case fixup's
        # echo statement not converted
        # ex: 'echo "a + b  = " f"{a + b}"' => 'run(echo "a + b  = " f"{a + b}")'
        if my_re.search(r"^\s*echo .*", line):
            debug.trace(5, "Special case unconverted-echo fixup")
            ## TODO: convert from inner f-strings to a single outer one
            ## if my_re.search(r'\bf".*"', line):
            ##     debug.trace(6, f"Resolving f-strings in line {line!r}")
            ##     line = eval(repr(line))
            ##     debug.trace_expr(6, line)
            line = my_re.sub(r'\bf"', '"', line)
            line = f"run(f{line!r})"
        
        debug.trace(5, f"{var_replace_call} => {line!r}")
        return line

    def operators(self, line):
        """Returns line with operators converted to Python equivalents"""
        # Dictionary with Bash operators and their Python equivalents
        operators = {" = ": " == ",
                     " != ": " != ",
                     " ! ": "not ",
                     "-eq ": " == ",
                     "-e": " os.path.exists ",    # TODO3: fix parentheses below
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
        # TODO3: use regex replacement and account for token boundaries (e.g., make sure [ or ] not in string)
        for bash_operator, python_equivalent in operators.items():
            line = re.sub(fr"(\S*) *{bash_operator} *(\S*)",
                          fr"\1{python_equivalent}\2", line).replace("[", "").replace("]", "")
            
        # Replace Bash true/false statements with Python equivalent
        line = re.sub(r"\[ 1 \]", "True", line)
        line = re.sub(r"\[ 0 \]", "False", line)
        debug.trace(5, f"operators({in_line!r}) => {line!r}")
        return line

    def process_keyword_statement(self, line):
        """Process simple built-in keyword statement (e.g., true to pass)"""
        debug.trace(6, f"in process_keyword_statement({line!r})")
        in_line = line
        converted = False
        line = self.map_keyword(line)
        if (line != in_line):
            converted = True
        debug.trace(7, f"process_keyword_statement({in_line!r}) => ({converted}, {line!r})")
        return (converted, line)

    def process_simple(self, line):
        """Process simple statement conversion for LINE"""
        debug.trace(6, f"in process_simple({line!r})")
        in_line = line
        converted = False
        # Convert miscellenous commands
        # - break
        # TODO: continue (dont think this is needed)
        debug.trace(6, "checking miscellenous statements")
        if (line.strip() == "break"):
            debug.trace(4, "processing break")
            converted = True
        # - arithmetic expression
        #       (( expr ))
        # note: this is treated like a statement, unlike $((...) in var_replace
        if my_re.search(r"^(\s*)\(\( (.*) \)\)\s*$", line):
            debug.trace(4, "processing arithmetic expression")
            indent = my_re.group(1)
            expression = my_re.group(2)
            line = (indent + expression)
            converted = True
        # - variable assignments
        # - Tana-TODO: review (I added \blet\s+)
        # - ex: let v++
        if re.search(r"\blet\s+(\S*)", line):
            debug.trace(4, "processing let")
            line = re.sub(r"\blet\s+(\S*)", r"\1", line)
            # HACK: convert postfix increment to += 1
            # TODO: hanbdle more common variants (e.g., prefix)
            line = re.sub(r"\b(\w+)\+\+", r"\1 += 1", line)
            line = re.sub(r"\b(\w+)\-\-", r"\1 -= 1", line)
            converted = True
        debug.trace(7, f"process_simple({in_line!r}) => ({converted}, {line!r})")
        return (converted, line)

    def process_compound(self, line, cmd_iter):
        """Process compound statement conversion for LINE"""
        # Tana-TODO: document the general idea of the conversion
        # Declare loop and statements as a tuple
        # format: (START, MIDDLE, END)
        for_loop = ("for", " do ", "done")
        while_loop = ("while", "do", "done")
        if_loop = ("if", "then", "fi")
        elif_loop = ("elif", "then", "fi")
        else_loop = ("else", "", "fi")  # Else statements do not have a keyword so None
        loops = (elif_loop, for_loop, while_loop, if_loop, else_loop)
        dummy_loop = ("dummy-start", "dummy-middle", "dummy-end")
        debug.trace_values(7, loops, "loops")
        # note: (?:...) is for a non-capturing group: see www.rexegg.com/regex-quickstart.html
        start_keyword_regex = "(?:" + "|".join([l[0] for l in loops]) + ")"
        middle_keyword_regex = "(?:" + "|".join([l[1] for l in loops]) + ")"
        end_keyword_regex = "(?:" + "|".join([l[2] for l in loops]) + ")"
        body = ""
        last_body = None
        loop_count = 0
        compound_stack = []             # OLD: loopy
        actual_loop = ()
        debug.trace(6, f"actual_loop0:{actual_loop}")
        converted = False
        # Tane-TODO: rename "loop" => "compound"
        loop_line = line
        indent = ""
        max_loop_count = 0
        loop_iterations = 0
        MAX_LOOP_ITERATIONS = 100
        saw_middle = False
        remainder = ""
        # Emulates a do while loop in python
        do_while = True
        while ((loop_count > 0) or do_while):
            debug.trace_expr(5, loop_line, loop_count, compound_stack, actual_loop, remainder)
            debug.trace_expr(6, body)
            # Stop upon end of compound command iteration (or some internal error)
            debug.assertion(body != last_body)
            debug.assertion(loop_iterations < MAX_LOOP_ITERATIONS)
            if ((not loop_line) or (body == last_body) or (loop_iterations == MAX_LOOP_ITERATIONS)):
                break
            loop_iterations += 1
            last_body = body
            loop_line = loop_line.strip()
            do_while = False
            if loop_count > max_loop_count:
                max_loop_count = loop_count
            # Handle comments and blank lines
            if ((loop_line == "") or (my_re.search(r"^\s*#", loop_line))):
                debug.trace(5, f"Ignoring compound blank line or comment ({loop_line!r}")
                body += indent + "    " + loop_line + "\n"
            # Handle simple for-in loop
            elif my_re.search(r"^\s*for\s+(\w+)\s+in\s+([^;]+);\s+do\b(.*)$", loop_line):
                (loop_var, values_spec, remainder) = my_re.groups()
                debug.trace(5, f"Processing compound for-in: var={loop_var} values={values_spec}")
                loop_count += 1
                indent = "    " * (loop_count - 1)
                saw_middle = True
                compound_stack.append("for_loop")
                actual_loop = for_loop
                debug.trace(6, f"actual_loop1:{actual_loop}")
                quoted_values = ('["' + '", "'.join(values_spec.split()) + '"]')
                new_body = f"for {loop_var} in {quoted_values}:\n"
                body += new_body
                debug.trace(5, f"Conversion of for-in clause; new body={new_body!r}")
            # General compound: warning this code is overly general, making it brittle!)
            elif my_re.search(
                ## OLD: fr"^(?!\*)\s*({loops[0][0]}|{loops[1][0]}|{loops[2][0]}|{loops[3][0]})\s+(\S.*)((?=;))",
                ## note: (?!...) is negative lokahead and (?=...) is positive lookahead
                ## TEST: fr"^(?!\*)\s*({loops[0][0]}|{loops[1][0]}|{loops[2][0]}|{loops[3][0]})\s+(\S.*)((?=\n))",
                fr"^(?!\*)\s*({start_keyword_regex})\s+([^;]+);\s*({middle_keyword_regex}|\n)(.*)$",
                    loop_line + "\n"):
                (start_keyword, test_expression, middle_keyword, remainder) = my_re.groups()
                debug.trace(5, f"Processing compound start/continuation: start={start_keyword}; expr={test_expression} middle={middle_keyword!r}")
                saw_middle = (middle_keyword != "\n")
                if start_keyword != "elif":
                    loop_count += 1
                    indent = "    " * (loop_count - 1)
                compound_stack.append(start_keyword + "_loop")
                var = self.var_replace(test_expression, is_loop=True)
                var = self.operators(var)
                # TODO1: rework to avoid need for eval!
                actual_loop = (eval(compound_stack[-1]) if compound_stack else dummy_loop)
                debug.trace(6, f"actual_loop2:{actual_loop}")
                var = var.replace(";" + actual_loop[1], "").strip()
                new_body = f"{indent}{actual_loop[0]} {var}:\n"
                body += new_body
                debug.trace(5, f"Conversion of {compound_stack[-1]} clause; new body={new_body!r}")
                # Sanity check for the above hairy code (Tana-TODO: document better)
                debug.assertion(len(loops) == 5)
                debug.assertion(loops[4][0] == "else")
            elif loop_line == "else":
                new_body = indent + loop_line.strip() + ":\n"
                body += new_body
                debug.trace(5, f"Processing compound else; new body={new_body!r}")
                loop_count += 1
            else:
                debug.trace(6, "Processing compound misc.")
                if not actual_loop:
                    debug.trace(4, "Not a compound statement")
                    debug.assertion(loop_count == 0)
                    return False, line
                    ## OLD: break
                if my_re.search(fr"^\s*{actual_loop[1]}\b(.*)", loop_line):
                    debug.trace(5, f"Processing compound inner {actual_loop[1]}")
                    loop_line = my_re.group(1)
                    debug.assertion(not saw_middle)
                    saw_middle = True
                if loop_line == actual_loop[1].strip():
                    debug.trace(5, f"[alt] Processing compound inner {actual_loop[1]}")
                    loop_line = ""
                    debug.assertion(not saw_middle)
                    saw_middle = True
                elif actual_loop[2] == loop_line.strip():
                    debug.trace(5, f"Processing compound close {actual_loop[2]}")
                    loop_line = ""
                    loop_count -= 1
                    compound_stack.pop()
                    try:
                        ## OLD: actual_loop = eval(compound_stack[-1])
                        actual_loop = (eval(compound_stack[-1]) if compound_stack else dummy_loop)
                        debug.trace(6, f"actual_loop3:{actual_loop}")
                    except IndexError:
                        break
                if loop_line.strip() in self.LOOP_CONTROL:
                    debug.trace(5, "Processing compound loop control")
                    body += loop_line + "\n"
                    body += self.map_keyword(loop_line) + "\n"
                elif loop_line.strip():
                    debug.trace(5, "Processing compound body statement")
                    if (my_re.search(fr"^(.*); ({end_keyword_regex}\b.*)", loop_line)):
                        (loop_line, remainder) = my_re.groups()
                        debug.trace(5, f"Isolated compound end statement: remainder={remainder!r}")
                    # First tries to convert simple statements and then falls back to variable reference checks
                    (converted, loop_line) = self.process_keyword_statement(loop_line)
                    if not converted:
                        (converted, loop_line) = self.process_simple(loop_line)
                    if converted:
                        body += indent + "    " + loop_line + "\n"
                    else:
                        debug.assertion(not my_re.search(fr"{start_keyword_regex}.*;.*{middle_keyword_regex}", loop_line))
                        body += "" + self.var_replace(loop_line.strip("\n"),
                                                indent="    " * loop_count) + "\n"
                else:
                    debug.trace(5, f"Warning: unexpected condition: blank loop line {loop_line!r}")
                converted = True
            # Use remaining text if anyl; otherwise get next line
            if (len(remainder) > 0):
                loop_line = remainder.strip()
            else:
                loop_line = next(cmd_iter, None)
        debug.trace_expr(6, body)
        comment = ""
        if not self.skip_comments:
            comment = f"#b2py: Founded loop of order {max_loop_count}. Please be careful\n"
        body = comment + body
        debug.trace(7, f"process_compound() => ({converted}, {body!r}")
        return converted, body

    def format(self, codex):
        """Convert self.cmd into python, returning text           # Tana-TODO: refine comments
        Note: Optionally does conversion via OpenAI CODEX"""  
        debug.trace(6, "{self.__class__.__name__}.format({codex})")
        # Tom-Note: This will need to be restructured. I preserved original for sake of diff.
        python_commands = []
        cmd_iter = (system.open_file(self.cmd) if system.file_exists(self.cmd)
                    # TODO1: use better command splitting (e.g., in case ';' embedding in string)
                    ## BAD: else iter(self.cmd.replace(";", "\n").splitlines(keepends=True)))
                    ## NOTE: semicolons needed for proper compound statement parsing
                    ## TODO:
                    else iter(self.cmd.splitlines(keepends=True)))
        if cmd_iter:
            for i, bash_line in enumerate(cmd_iter):  # for each line in the script
                debug.trace_expr(5, bash_line)
                if INCLUDE_ORIGINAL:
                    python_commands.append(f"# L{i + 1}: {bash_line}")
                # Tane-TODO: what's with the { and }???
                if (any([(not bash_line.strip()), re.search(r"^\s*#", bash_line),
                         bash_line.startswith("{"), bash_line.startswith("}")])):
                    python_commands.append(bash_line.strip("\n"))
                    continue
                bash_line = bash_line.strip("\n")
                # if comment line, skip
                comment = ""
                # Tana-TODO: ignore #'s within strings
                if "#" in bash_line:
                    debug.assertion(not embedded_in_quoted_string("#", bash_line))
                    bash_line, comment = bash_line.split("#", 1)
                if codex:
                    python_line = self.codex_convert(bash_line)
                    python_commands.append(python_line)
                    continue
                (converted, python_line) = self.process_compound(bash_line, cmd_iter)
                if not converted:
                    # note: handles statements involving no variables
                    (converted, python_line) = self.process_keyword_statement(bash_line)
                if not converted:
                    (converted, python_line) = self.process_simple(bash_line)
                    python_line = self.var_replace(python_line)
                # Adhoc fixups
                if (comment and not self.skip_comments):
                    python_line += f" # {comment}"
                python_commands.append(python_line)
        return "\n".join(python_commands)

    def header(self):
        """Returns Python header to use for converted snippet code"""
        debug.trace(6, "{self.__class__.__name__}.header()")
        return PYTHON_HEADER


# -------------------------------------------------------------------------------
@click.command()
# Tana-TODO: separate script option into separate ones (e.g., script-file and script-text arguments)
# For example, line-numbers option currently only works for former.
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
            -For loops")
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
    #
    if not bash_snippet:
        print("No script or snippet specified. Use --help for usage or --script to specify a script")
        return

    # HACK: override global flag
    global USE_CODEX
    if codex and not USE_CODEX:
        USE_CODEX = codex

    # If just converting via Codex, show the result and stop.
    if JUST_CODEX:
        b2p = Bash2Python(None, None)
        print(b2p.codex_convert(bash_snippet))
        return

    # Optionally add line numbers
    # Tana-TODO: put this above (before script => bash_snippet support);
    # Tana-TODO: use a temporary file (e.g., /tmp/filename-numbered), not filename.b2py
    if line_numbers:
        debug.assertion(not system.file_exists(script))
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

    # Convert and print snippet
    debug.trace_expr(6, bash_snippet)
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
        # TODO; print(gh.run("python " + write_temp_file(cmd)))
        print(safe_eval(str(cmd)))
    else:
        if INCLUDE_HEADER:
            print(b2p.header())
        print(b2p.perlregex(bash_snippet))
        print(b2p.format(codex))


# -------------------------------------------------------------------------------
if __name__ == '__main__':
    # pylint: disable=no-value-for-parameter
    main()
