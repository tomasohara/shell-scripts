#!/usr/bin/env pytest
## TODO (have the script invoke pytest: see mezcla/tests/test_system.py)
#!/usr/bin/env python
#
# Simple test suite for bash2python.py. oming up with general tests will be difficult,
# given the open-ended nature of the task. So just concentrate on the conversion of
# simple examples that should be converted for each of the main supported features
# (e.g., assignments, loops, and environment support).
#
# Notes:
# - Use 'pytest bash2python_test.py -k "not skip"' to skip the tests that cover functions not yet implemented.

"""Tests for bash2python.py"""

import subprocess
import pytest
import bash2python


def run_bash(bash, python):
    """Helper for call to bash2python"""
    output = (
        subprocess.check_output(["python3", "bash2python.py", "--script", bash])
        .decode()
        .strip()
    )
    assert output == python

def bash2py(bash, python):
    """Helper for call bash2python as a module"""
    b2p = bash2python.Bash2Python(bash, None)
    output = b2p.format(False)
    assert output == python

def test_variable_substitution():
    """Test to check if a simple echo $foo variable is ported"""
    bash = "echo $foo"
    python = "run(f'echo {foo}')"
    bash2py(bash, python)


def test_operator_substitution():
    """Test if simple operators are substituted in a if statement"""
    bash = "if [ 1 -gt 0 -lt 2]; then echo Hello; fi"
    python = "if  1 > 0 < 2:\n    run('echo Hello')"
    bash2py(bash, python)


def test_comments_1():
    """Test if comments maintain their integrity, expected same input as output"""
    bash = "# This is a comment"
    python = "# This is a comment"
    bash2py(bash, python)


def test_while_loop():
    """Test a simple while loop convertion"""
    bash = "while [ $i -le 5 ]; do echo $i; done"
    python = "while  {i} <= 5 :\n    run(f'echo {i}')"
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


def test_comments_2():
    """Checks in-line comments to ensure integrity"""
    bash = "echo $foo # Another comment"
    python = "run(f'echo {foo} ') #  Another comment"
    bash2py(bash, python)


def test_variable_assignment():
    """Tests a simple case of variable assignment in two lines"""
    bash = "name='John Doe'; echo $name"
    python = "name = 'John Doe'\n run(f'echo {name}')"
    bash2py(bash, python)


def test_arithmetic_expression():
    """Checks if arithmetics are working correctly"""
    bash = "echo $((2+3*4))"
    python = "run('echo $((2+3*4))', skip_print=False)"
    bash2py(bash, python)


def test_double_quotes():
    """Make sure double quotes escaped inside run calls"""
    bash = 'echo "Hello world"'
    python = "run('echo \"Hello world\"')"

    bash2py(bash, python)


def test_embedded_for_not_supported():
    """Make sure that embedded FOR issues warning about not being supported"""
    bash = """for i in 1 2 3; do
    for j in a b c; do
    echo \"$i$j\"
    done
    done 
    """
    python = "embedded for: for i in 1 2 3; do"
    output = (
        subprocess.check_output(["python3", "bash2python.py", "--script", bash])
        .decode()
        .strip()
    )
    assert python in output

def test_complex_for_loop():
    """Tests complex for loop. Includes some arrays. Doomed to fail"""
    bash = """
    files=('file1.txt' 'file2.txt' 'file3.txt' 'file4.txt' 'file5.txt')
    for file in "${files[@]}"; do
        echo "Reading file: $file"
        run("cat $file")
    done
    """
    python = """
    files=['file1.txt', 'file2.txt', 'file3.txt', 'file4.txt', 'file5.txt']
    for file in files:
        run("echo \"Reading file: $file\"")
        run(f"cat {file}")
        """
    bash2py(bash, python)


@pytest.mark.skip
def test_if_else_condition():
    """TODO flesh out: test if/else"""
    bash = 'if [ -f "$1" ]; then echo "$1 exists and is a regular file."; elif [ -e "$1" ]; then echo "$1 exists but is not a regular file."; else; echo "$1 does not exist."; fi'
    python = (
        "if a == b:\n run('echo 'Equal'')\nelse:\n run('echo 'Not Equal'')"
    )
    bash2py(bash, python)


@pytest.mark.skip
def test_for_c_style():
    """Tests C-style for loops"""
    bash = "for ((i=0; i < 10; i++)); do  echo $i; done"
    python = "for i in range(10): \n run(f'print {i}')"
    bash2py(bash, python)

@pytest.mark.skip
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
    python = "x = 1+2"
    bash2py(bash, python)

def test_history_substitution():
    """Tests the history mechanism ($!)"""
    bash = "echo hello && echo world && echo !$"
    python = "run('echo hello && echo world && echo !$')"
    bash2py(bash, python)

def test_echo_to_stderr():
    """Tests if echo to stderr is converted to print statements"""
    bash = "echo 'This is an error' >&2"
    python = "print('This is an error', file=sys.stderr)"
    bash2py(bash, python)

@pytest.mark.parametrize("bash, python", [
    # Bash. => Python
    ("echo foo", "run('echo foo')"),  # simple control test to check parametrize decorator
    ("let v++", "let_value['v'] += 1; v = let_value['v']"),  # doomed to fail
    ("exit", "run('exit')"),
    ("foo=$bar", "foo = f'{bar}'"),
    ("ls -a", "run('ls -a')"),
    ("echo $bar", "run(f'echo {bar}')")
    ])
def test_tabular_tests(bash, python):
    """Tests in tabular format. Uses pythest parametrize"""
    bash2py(bash, python)
