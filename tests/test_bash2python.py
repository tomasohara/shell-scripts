#!/usr/bin/env python
#
# Simple test suite for bash2python.py. Coming up with general tests will be difficult,
# given the open-ended nature of the task. So just concentrate on the conversion of
# simple examples that should be converted for each of the main supported features
# (e.g., assignments, loops, and environment support).
#
# Notes:
# - Use 'pytest test_bash2python.py -k "not skip"'
# - To skip the tests that cover functions not yet implemented., use
#     pytest -k "not skip" tests/test_bash2python.py
# - To treat xfail-marked tests as failure, use
#     pytest --runxfail tests/test_bash2python.py
# - For OpenAI key specification, see
#      https://platform.openai.com/docs/api-reference/introduction?lang=python
# - Debug tracing might cause problems for the tests, so disable as follows:
#      DEBUG_LEVEL=0 pytest tests/test_bash2python.py
#
# Tips:
# - ** See bash2python.py for important coding tips.
#
# TODO2:
# - * Err on the side of adding more tests!
#
# TODO3:
# - Convert """-based-string input to include indentation that gets stripped prior to test invocation:
#   so that not flush left in source.
#

"""Tests for bash2python.py"""

# Standard modules
import json
import subprocess

# Installed modules
import pytest

# Local modules
from bash2python import Bash2Python as B2P, OPENAI_API_KEY
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.my_regex import my_re
from mezcla import system

# Constants
RUN_SLOW_TESTS = system.getenv_bool("RUN_SLOW_TESTS", False,
                                    "Run tests that can a while to run")

#-------------------------------------------------------------------------------
# Helper functions

def run_bash(bash, python):                # Note: run_bash no longer used
    """Helper for call to bash2python"""
    output = (
        subprocess.check_output(["python", "bash2python.py", "--script", bash])
        .decode()
        .strip()
    )
    assert output == python


def normalize_whitespace(text):
    """Perform normalization of TEXT to facilitate comparisons: carriage returns changed to newlines, spaces and newlines are collapsed, and outer whitespace is stripped"""
    # EX: normalize("Hey  Joe\r\n!") => Hey Joe\n!"                                    
    result = text.strip()
    result = my_re.sub(r"\r", "\n", result)
    result = my_re.sub(r"\s+\n+\s+", "\n", result)
    result = my_re.sub(r"  +", " ", result)
    debug.trace(7, f"normalize({text!r}) => {result!r}")
    return result


def bash2py_helper(bash, expect, skip_normalize=False, keep_comments=False):
    """Helper for call bash2python as a module
    Notes:
    - Applies whitespace normalization unless SKIP_NORMALIZE
    - Omits conversion comments unless KEEP_COMMENTS (for sake of simpler matching)
    """
    debug.trace(6, f"bash2py{(bash, expect, skip_normalize, keep_comments)}")
    debug.trace_expr(5, bash, expect, delim="\n")
    b2p = B2P(bash, skip_comments=(not keep_comments))
    actual = b2p.convert_snippet(False)
    if not skip_normalize:
        actual = normalize_whitespace(actual)
        expect = normalize_whitespace(expect)
    debug.trace_expr(5, actual, expect, delim="\n")
    assert actual == expect

#-------------------------------------------------------------------------------
# Tests proper
    
@pytest.mark.skipif(not OPENAI_API_KEY, reason='OPENAI_API_KEY not set')
def test_codex():
    """Simple test for codex using an very standard input"""
    bash = "echo Hello World"
    b2p = B2P(bash, skip_comments=True)
    actual = b2p.convert_snippet(True)
    expect = 'print("Hello World")'
    #
    actual = normalize_whitespace(actual)
    expect = normalize_whitespace(expect)
    #
    if actual == '# internal error':
        print("Usually a problem with OPENAI_API_KEY")
    assert actual in expect


def test_variable_substitution():
    """Test to check if a simple echo $foo variable is ported"""
    bash = "echo $foo"
    python = "run(f'echo {foo}')"
    bash2py_helper(bash, python)


def test_operator_substitution():
    """Test if simple operators are substituted in a if statement"""
    ## OLD: bash = "if [ 1 -gt 0 -lt 2 ]; then echo Hello; fi"
    ## NOTE: above made into xfail one below
    bash = """
if [ 1 -gt 0 ]; then
    if [ 0 -lt 2 ]; then
        echo "Hello"
    fi
fi
    """
    # TODO2: test for warning separately (e.g., strip comments); also, use valid bash input
    ## OLD: python = """#b2py: Founded loop of order 1. Please be careful\nif  1 > 0 < 2:\n    run('echo Hello')\n"""
    python = """
if 1 > 0:
    if 0 < 2:
        run('echo "Hello"')
    """
    bash2py_helper(bash, python)


def test_comments_1():
    """Test if comments maintain their integrity, expected same input as output"""
    bash = "# This is a comment"
    python = "# This is a comment"
    bash2py_helper(bash, python)


def test_comments_2():
    """Checks in-line comments to ensure integrity"""
    bash = "echo $foo # Another comment"
    python = "run(f'echo {foo}')# Another comment"
    bash2py_helper(bash, python, keep_comments=True)


def test_while_loop():
    """Test a simple while loop convertion"""
    debug.trace(4, "test_while_loop()")
    bash = """
c=3
while [ $c -le 5 ]; do
    echo $c
    let c++
done
"""
    ## OLD: python = "#b2py: Founded loop of order 1. Please be careful\nwhile i <= 5 :\n    run(f'echo {i}')\n"
    python = """
c = 3
while c <= 5:
    run(f'echo {c}')
    c += 1
"""
    bash2py_helper(bash, python)


def test_command_substitution():
    """Checks if commands are correctly converted adding run()"""
    bash = "echo $(ls)"
    python = "run('echo $(ls)', skip_print=False)"
    bash2py_helper(bash, python)


def test_command_pipe():
    """Makes sure a simple pipe is ported"""
    bash = "ls | grep test | wc -l"
    python = "run('ls | grep test | wc -l')"
    bash2py_helper(bash, python)


def test_variable_assignment():
    """Tests a simple case of variable assignment in two lines"""
    ## OLD: bash = "name='John Doe'; echo $name"
    ## NOTE: need newline so echo resolved properly (old test moved below as xfail)
    bash = "name='John Doe'\necho $name"
    python = "name = 'John Doe'\nrun(f'echo {name}')"
    bash2py_helper(bash, python)


def test_arithmetic_expression():
    """Checks if arithmetics are working correctly"""
    bash = "echo $((2+3*4))"
    ## OLD: python = "run('echo $((2+3*4))', skip_print=False)"
    python = "run('echo f\"{2+3*4}\"')"
    bash2py_helper(bash, python)


def test_double_quotes():
    """Make sure double quotes escaped inside run calls"""
    bash = 'echo "Hello world"'
    python = "run('echo \"Hello world\"')"
    bash2py_helper(bash, python)


def test_embedded_for_not_supported():
    """Make sure that embedded FOR issues warning about not being supported"""
    bash = """
for i in 1 2 3; do
    for j in a b c; do
        echo "$i vs. $j"
    done
done 
    """
    ## OLD: python = "embedded for: for i in 1 2 3; do"
    ## TODO: call directly
    python = "embedded for"
    debug.trace_expr(5, bash, python, delim="\n") 
    actual = (
        subprocess.check_output(["python", "bash2python.py", "--script", bash])
        .decode()
        .strip()
    )
    debug.trace_expr(4, python)
    assert python in actual


@pytest.mark.xfail
def test_if_else_condition():
    """TODO3 flesh out comment: test if/else"""
    bash = """
if [ -f "$1" ]; then
    echo "$1 exists and is a regular file."
elif [ -e "$1" ]; then
    echo "$1 exists but is not a regular file."
else
    echo "$1 does not exist."
fi
    """
    python = (
        "if a == b:\n run('echo 'Equal'')\nelse:\n run('echo 'Not Equal'')"
    )
    bash2py_helper(bash, python)


@pytest.mark.xfail
def test_alt_if_else_condition():
    """Test non-trivial if/then/elif/fi conversion"""
    bash = """
(( x=RANDOM ))                         
if [ $x -eq 0 ]; then
    echo "$x zero"
elif [ $x -lt 0 ]; then
    echo "$x negative"
else
    echo "$x positive"
fi
    """                                 # TODO: x=$(calc-int "rand() * 1024")
    python = """
x = run("echo $RANDOM")
if x == 0:
    run(f'"echo {x} zero"')
elif x < 0:
    run(f'"echo {x} negative"')
else:
    run(f'"echo {x} positive"')
    """
    bash2py_helper(bash, python)


@pytest.mark.xfail                      # note: c-style loops not supported
def test_for_c_style():
    """Tests C-style for loops"""
    bash = "for ((i=0; i < 10; i++)); do  echo $i; done"
    python = "for i in range(10):\n    run(f'print {i}')"
    bash2py_helper(bash, python)


@pytest.mark.xfail
def test_case_statement():
    """Tests if case statement is correctly translated. Not implemented"""
    bash = """
case $var in
    x)
        echo "var is x"
        ;;
    y|z)
        echo "var is y or z"
        ;;
    *)
        echo "var is not x, y or z"
        ;;
esac
    """
    python = """
    if var == 'x':
        run('echo "var is x"')
    elif var in ('y', 'z'):
        run('echo "var is y or z"')
    else:
        run('echo "var is not x, y or z"')
    """
    bash2py_helper(bash, python)


def test_let_command():
    """Test if a let command is converted correctly"""
    bash = 'let "x=1+2"'
    ## TODO: python = "x=1+2"
    python = "x = 1+2"
    bash2py_helper(bash, python)


def test_history_substitution():
    """Tests the history mechanism ($!)"""
    bash = "echo hello && echo world && echo !$"
    python = "run('echo hello && echo world && echo !$')"
    bash2py_helper(bash, python)


@pytest.mark.xfail(reason="Extraenous quotes produced")
def test_echo_to_stderr():
    """Tests if echo to stderr is converted"""
    bash = "echo 'This is an error' >&2"
    ## OLD: python = """run("echo \\\\\'This is an error\\\\\' >&2")"""
    python = """run("echo 'This is an error' >&2")"""
    bash2py_helper(bash, python)


@pytest.mark.xfail(reason="Complex syntax not implemented")
def test_complex_for_loop():
    """Tests complex for loop. Includes some arrays. Doomed to fail"""
    bash = """
files=('file1.txt' 'file2.txt' 'file3.txt' 'file4.txt' 'file5.txt')
for file in "${files[@]}"; do
    echo "Reading file: $file"
    cat $file
done
"""
    python = """
files=['file1.txt', 'file2.txt', 'file3.txt', 'file4.txt', 'file5.txt']
for file in files:
    run("echo \"Reading file: $file\"")
    run(f"cat {file}")
    """
    bash2py_helper(bash, python)


@pytest.mark.xfail
# note: uses xfail for convenience (TODO: have separate version for important tests)
@pytest.mark.parametrize("bash_line, expect_result", [
    # input                             result
    ("""echo $fubar""",                 """run(f'echo {fubar}')"""),      # TODO: print(f"{fubar}")
    # note: results with multiple run's requires var_replace to be incremental (as with process_compound)
    ("""ls; pwd""",                     """run('ls; pwd')"""),
    ("""ls\npwd\n""",                   """run('ls')\nrun('pwd')"""),
    ("""ls\n\npwd\n""",                 """run('ls')\n\nrun('pwd')"""),
    ])
def test_tabular_var_replace(bash_line, expect_result):
    """Tests in tabular format for var_replace. Uses pytest parametrize"""
    debug.trace(6, f"test_tabular_var_replace({bash_line!r}, {expect_result!r})")
    b2p = B2P(None, skip_comments=True)
    (_converted, actual_result, _remainder) = b2p.var_replace(bash_line)
    norm_actual_result = normalize_whitespace(actual_result)
    norm_expect_result = normalize_whitespace(expect_result)
    debug.trace_expr(5, norm_actual_result, norm_expect_result, delim="\n")
    assert(norm_actual_result == norm_expect_result)


@pytest.mark.xfail                      # uses xfail for convenience (TODO: have separate version for good tests)
@pytest.mark.parametrize("bash, python", [
    # Bash. => Python
    ("echo foo",
     "run('echo foo')"),  # simple control test to check parametrize decorator
    ("let v++",
     "let_value['v'] += 1; v = let_value['v']"),  # doomed to fail (hash usage)
    ("foo=$bar",
     "foo = f'{bar}'"),
    ("ls -a",
     "run('ls -a')"),
    ("echo $bar",
     "run(f'echo {bar}')"),
    # arithmetic expressions and expansions (latter results in string)
    ("(( z = x + y ))",
     "z = x + y"),
    ("z=$((x + y))",
     'z = f"{x + y}"'),
    ("echo a$((1+2))b",
     "run(f'echo a{1+2}b')"),
    # simple if statement(s)
    ("""if [ $? -eq 0 ]; then echo "Success"; fi""",
     """if run("echo $?") == "0":\n   print("Success")"""),
    ("""if [ 1 -gt 0 ]; then if [ 1 -gt 0 -lt 2 ]; then echo Hello; fi; fi""",   # single line issue
     """if 1 > 0 < 2:\n    run('echo Hello')\n"""),
    # simple for statement(s)
    ("""for i in 1 2 3; do echo "$i"; done""",
     """for i in [1, 2, 3]: print(i)"""),
    # simple while statement(s)
    ("""while [ $i -ge 0 ]; do echo $i; let i--; done""",
     """while i >= 0:\n    print(i)\n    i -= 1"""),
    # variable assignment
    ("""name='John Doe'; echo $name""",                  # semicolon blocks variable conversion
     """name = 'John Doe'\n run(f'echo {name}')"""),
    # consecutive statement execution
    ("""ls; pwd;""",
     """run("ls"); run("pwd")"""),
    ("""ls\npwd\n""",
     """run("ls"); run("pwd")"""),                          # newline getting munged into run call
    # no-op statement
    ("true",
     "pass"),
    ("true;",
     "pass"),          # semicolon needs to be dropped
    # default values (n.b., the support needs to be changed in bash2python.py)
    ("""if [ ${HOME:-n/a} = "n/a" ]; then echo "no HOME"; fi""",
     """if os.getenv("HOME", "n/a") == "n/a":\n    print("no HOME")"""),
    # special test conditions (TODO: rework in terms of tests for operator function)
    ("""if [ 1 ]; then true; fi""",
     """if True:\n    pass"""),
    ("""if [ 0 ]; then true; fi""",
     """if False:\n    pass"""),
    ("""if true; then true; fi""",
     """if True:\n    pass"""),
    ("""if false; then true; fi""",
     """if False:\n    pass"""),
    # operators (TODO: isolate from if/then/fi verbiage)
    ("""if [[ ($? -gt 0) && ($? -lt 0) ]]; then echo "bad status"; fi""",
     """if run("$?") > 0 and run("$?") < 0:\n    print("bad status")"""),
    ("""if [ 1 || 0 ]; then echo "one"; fi""",
     """if 1 or 0:\n    print('one')"""),
    ("""if [ ! 1 = 1 ]; then echo "bug"; fi""",
     """if not 1 == 1:\n    print('bug')"""),
    ("""if [ -z " " ]; then echo "bug"; fi""",
     """if '' == " ":\n    print('bug')"""),
    ("""if [ -n "" ]; then echo "bug"; fi""",
     """if '' != " ":\n    print('bug')"""),
    # file operators (TODO: test for quoting of filenames)
    ("""if [ -f "$HOME/.bashrc" ]; then true; fi""",
     """if os.path.isfile("$HOME/.bashrc"): then pass"""),
    ("""if [ -d "/tmp" ]; then true; fi""",
     """if os.path.isdir("/tmp"): then pass"""),
    ("""if [[ (-d "/tmp") || (-d "$HOME/temp") ]]; then true; fi""",
     """if os.path.isdir("/tmp") or os.path.isdir("$HOME/temp"): then pass"""),
    # Unimplemented operators
    ("""if [[ $fu =~ bar ]]; then true; fi""",       # regex matching
     """if re.search("bar", fu): \n    pass"""),
    # Unimplemented features
    ("""
echo 1 2 \
3""",                                   # line continuation
     """run('echo 1 2 3');"""),
    # Exit statement (n.b., keep last as all bash input converted to script)
    ("exit",
     "run('exit')")
    ])
def test_tabular_tests(bash, python):
    """Tests in tabular format. Uses pytest parametrize"""
    bash2py_helper(bash, python)


def do_test_external_script(bash_filename, python_filename=None, diff_program=None, diff_threshold=None):
    """Tests external script given by BASH_FILENAME and PYTHON_FILENAME
    using DIFF_PROGRAM to compute score based on DIFF_THRESHOLD"""
    debug.trace(6, f"do_test_external_script{(bash_filename, python_filename, diff_program, diff_threshold)}")
    if python_filename is None:
        python_filename = gh.remove_extension(bash_filename, ".bash") + ".py"
    if diff_program is None:
        diff_program = "char-diff.bash"
    if diff_threshold is None:
        diff_threshold = 0.25

    # Run conversion
    script_dir = gh.form_path(gh.dirname(__file__), "..")
    script = gh.form_path(script_dir, "bash2python.py")
    temp_file = gh.get_temp_file()
    gh.run(f"python {script} --script {bash_filename} > {temp_file}.bash.py 2> {temp_file}.bash.log")

    # Compute diff-based score
    epsilon = 0.001
    num_diffs = system.to_int(gh.run(f"{diff_program} {temp_file}.bash.py {python_filename} | wc -l"))
    num_lines = len(system.read_lines(python_filename))
    score = 100 * (1.0 - min(1, ((num_diffs + epsilon) * 0.25) / (num_lines + epsilon)))
    debug.trace_expr(5, num_diffs, num_lines, score)
    assert(score >= diff_threshold)


def do_test_directory(dir_path, config_file=None):
    """Run test with each mnaually converted file in PATH, using optional CONFIG_FILE
    For each .py file, the corresponding .bash file is the input. 
    In addition, CONFIG_FILE can be used to override the default threshold for comparison
    """
    debug.trace(5, f"do_test_directory({dir_path}, [{config_file}])")
    if config_file is None:
        config_file = gh.form_path(dir_path, "config.json")
    config = {}
    if config_file and system.file_exists(config_file):
        config = json.loads(system.read_file(config_file))
    for filename in gh.get_matching_files(gh.form_path(dir_path, "*.bash")):
        try:
            config_hash = config.get(filename, {})
            threshold = system.to_float(config_hash.get("threshold", 0))
        except:
            system.print_exception_info("test_directory/threshold")
        do_test_external_script(filename, diff_threshold=threshold)


## TAKE1
## @pytest.mark.xfail
## def test_external_scripts():
##     """Test conversion of scripts in external directories"""
##     debug.trace(5, "test_external_scripts()")
##     do_test_directory(gh.resolve_path("bash2py-data"))

@pytest.mark.xfail                      # uses xfail for convenience (TODO: have separate version for good tests)
@pytest.mark.skipif(not RUN_SLOW_TESTS, reason='Ignoring slow tests')
@pytest.mark.parametrize("filename",
                         gh.get_matching_files(gh.form_path(gh.resolve_path("bash2py-data"), "*.bash")))
def test_bash_script(filename):
    """Test conversion of Bash FILENAME againt corresponding .py file"""
    do_test_external_script(filename)

#-------------------------------------------------------------------------------

if __name__ == '__main__':
    debug.trace_current_context()
    pytest.main([__file__])
