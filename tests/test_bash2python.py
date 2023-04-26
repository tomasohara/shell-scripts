#!/usr/bin/env python
#
# pylint: disable=line-too-long
# Simple test suite for bash2python.py. oming up with general tests will be difficult,
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
import subprocess

# Installed modules
import pytest
from click.testing import CliRunner

# Local modules
from bash2python import Bash2Python as B2P, OPENAI_API_KEY
from bash2python_diff import main
from mezcla import debug
from mezcla.my_regex import my_re

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


def bash2py(bash, python, skip_normalize=False, keep_comments=False):
    """Helper for call bash2python as a module
    Notes:
    - Applies whitespace normalization unless SKIP_NORMALIZE
    - Omits conversion comments unless KEEP_COMMENTS (for sake of simpler matching)
    """
    debug.trace(6, f"bash2py{(bash, python, skip_normalize, keep_comments)}")
    debug.trace_expr(5, bash, python, delim="\n")
    b2p = B2P(bash, None, skip_comments=(not keep_comments))
    output = b2p.format(False)
    if not skip_normalize:
        output = normalize_whitespace(output)
        python = normalize_whitespace(python)
    debug.trace_expr(5, output, python, delim="\n")
    assert output == python

#-------------------------------------------------------------------------------
# Tests proper
    
@pytest.mark.skipif(not OPENAI_API_KEY, reason='OPENAI_API_KEY not set')
def test_codex():
    """Simple test for codex using an very standard input"""
    bash = "echo Hello World"
    ## OLD: python = b2p.codex_convert(None, bash)
    b2p = B2P(bash, None, skip_comments=True)
    python = b2p.format(True)
    output = 'print("Hello World")'
    #
    output = normalize_whitespace(output)
    python = normalize_whitespace(python)
    #
    if python == '# internal error':
        print("Usually a problem with OPENAI_API_KEY")
    assert output in python


def test_variable_substitution():
    """Test to check if a simple echo $foo variable is ported"""
    bash = "echo $foo"
    python = "run(f'echo {foo}')"
    bash2py(bash, python)


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
    bash2py(bash, python)


def test_comments_1():
    """Test if comments maintain their integrity, expected same input as output"""
    bash = "# This is a comment"
    python = "# This is a comment"
    bash2py(bash, python)


def test_comments_2():
    """Checks in-line comments to ensure integrity"""
    bash = "echo $foo # Another comment"
    python = "run(f'echo {foo}')# Another comment"
    bash2py(bash, python, keep_comments=True)


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
    bash2py(bash, python)


def test_command_substitution():
    """Checks if commands are correctly converted adding run()"""
    bash = "echo $(ls)"
    python = "run('echo $(ls)', skip_print=False)"
    bash2py(bash, python)


def test_command_pipe():
    """Makes sure a simple pipe is ported"""
    bash = "ls | grep test | wc -l"
    python = "run('ls | grep test | wc -l')"
    bash2py(bash, python)


def test_variable_assignment():
    """Tests a simple case of variable assignment in two lines"""
    ## OLD: bash = "name='John Doe'; echo $name"
    ## NOTE: need newline so echo resolved properly (old test moved below as xfail)
    bash = "name='John Doe'\necho $name"
    python = "name = 'John Doe'\nrun(f'echo {name}')"
    bash2py(bash, python)


def test_arithmetic_expression():
    """Checks if arithmetics are working correctly"""
    bash = "echo $((2+3*4))"
    ## OLD: python = "run('echo $((2+3*4))', skip_print=False)"
    python = "run('echo f\"{2+3*4}\"')"
    bash2py(bash, python)


def test_double_quotes():
    """Make sure double quotes escaped inside run calls"""
    bash = 'echo "Hello world"'
    python = "run('echo \"Hello world\"')"
    bash2py(bash, python)


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
    output = (
        subprocess.check_output(["python", "bash2python.py", "--script", bash])
        .decode()
        .strip()
    )
    debug.trace_expr(4, python)
    assert python in output


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
    bash2py(bash, python)


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
    bash2py(bash, python)


@pytest.mark.xfail                      # note: c-style loops not supported
def test_for_c_style():
    """Tests C-style for loops"""
    bash = "for ((i=0; i < 10; i++)); do  echo $i; done"
    python = "for i in range(10):\n    run(f'print {i}')"
    bash2py(bash, python)


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
    bash2py(bash, python)


def test_let_command():
    """Test if a let command is converted correctly"""
    bash = 'let "x=1+2"'
    ## TODO: python = "x=1+2"
    python = "x = 1+2"
    bash2py(bash, python)


def test_history_substitution():
    """Tests the history mechanism ($!)"""
    bash = "echo hello && echo world && echo !$"
    python = "run('echo hello && echo world && echo !$')"
    bash2py(bash, python)


@pytest.mark.xfail(reason="Extraenous quotes produced")
def test_echo_to_stderr():
    """Tests if echo to stderr is converted"""
    bash = "echo 'This is an error' >&2"
    ## OLD: python = """run("echo \\\\\'This is an error\\\\\' >&2")"""
    python = """run("echo 'This is an error' >&2")"""
    bash2py(bash, python)


@pytest.mark.xfail(reason="Complex systax not implemented")
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
    bash2py(bash, python)


@pytest.mark.xfail
# note: uses xfail for convenience (TODO: have separate version for important tests)
@pytest.mark.parametrize("bash_line, expected_result", [
    # input                             result
    ("""echo $fubar""",                 """run(f'echo {fubar}')"""),      # TODO: print(f"{fubar}")
    # note: results with multiple run's requires var_replace to be incremental (as with process_compound)
    ("""ls; pwd""",                     """run('ls; pwd')"""),
    ("""ls\npwd\n""",                   """run('ls')\nrun('pwd')"""),
    ("""ls\n\npwd\n""",                 """run('ls')\n\nrun('pwd')"""),
    ])
def test_tabular_var_replace(bash_line, expected_result):
    """Tests in tabular format for var_replace. Uses pytest parametrize"""
    b2p = B2P(None, None)
    actual_result = b2p.var_replace(bash_line)
    norm_actual_result = normalize_whitespace(actual_result)
    norm_expected_result = normalize_whitespace(expected_result)
    assert(norm_actual_result == norm_expected_result)


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
    # special test conditions (TOOD: rework in terms of tests for operator function)
    ("""if [ 1 ]; then true; fi""",
     """if True:\n    pass"""),
    ("""if [ 1 ]; then true; fi""",
     """if True:\n    pass"""),
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
    bash2py(bash, python)


## TODO1: put bash2python_diff tests in test_bash2python_diff
##
@pytest.mark.skipif(not OPENAI_API_KEY, reason='OPENAI_API_KEY not set')
def test_diff_no_opts():
    """Tests bash2python_diff without flags enabled"""
    debug.trace(5, "test_diff_no_opts()")
    runner = CliRunner(mix_stderr=False)
    # NOTE: disable stderr tracing
    bash = "line1\n\nline2\n"
    result = runner.invoke(main, env={"DEBUG_LEVEL": "0"},
                           input=bash)
    python = result.output
    debug.trace_expr(5, bash, python, delim="\n")
    debug.trace_object(6, result)
    assert result.exit_code == 0
    assert "------------codex------------" in result.output
    assert "------------b2py------------" in result.output
##
@pytest.mark.skipif(not OPENAI_API_KEY, reason='OPENAI_API_KEY not set')
def test_diff_opts():
    """Tests bash2python_diff with all flags enabled"""
    debug.trace(5, "test_diff_opts()")
    runner = CliRunner(mix_stderr=False)
    # NOTE: disable stderr tracing
    bash = "echo Hello World;\nfoo='bar';\n"
    result = runner.invoke(main, args=["--perl", "--diff"], env={"DEBUG_LEVEL": "0"},
                           ## TODO2: input="echo Hello World\n\nfoo='bar'\n",
                           input=bash)
    python = result.output
    debug.trace_expr(5, bash, python, delim="\n")
    debug.trace_expr(6, result.output, max_len=4096)
    debug.trace_object(7, result)
    assert result.exit_code == 0
    ##
    ## OLD
    ## assert 'print("Hello World")' in result.output
    ## assert "foo = 'bar'" in result.output
    ##
    # example output (simplified):
    #   # b2py                           | codex
    #   run('echo "Hello World"')        |
    #                                    | print("Hello World")
    #   fuu='bar'                        |
    #                                    | foo = 'bar'
    assert(my_re.search(r"""# b2py\s+\|\s+codex""", result.output))
    assert(my_re.search(r"""run\(.*echo Hello World.*\).*\|""", result.output))
    # TODO2: assert(my_re.search(r"""run\('echo Hello World'\).*\|""", result.output))
    assert(my_re.search(r"""\|.*print\("Hello World"\)""", result.output))
    assert(my_re.search(r"""foo\s*=\s*['"]bar['"].*\|""", result.output))
    assert(my_re.search(r"""\|.*foo\s*=\s*['"]bar['"]""", result.output))

#-------------------------------------------------------------------------------

if __name__ == '__main__':
    debug.trace_current_context()
    pytest.main([__file__])
