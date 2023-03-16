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


def run_bash_script(bash_script, expected_python_script):
    """Helper for call to bash2python"""
    output = (
        subprocess.check_output(["python3", "bash2python.py", "--script", bash_script])
        .decode()
        .strip()
    )
    assert output == expected_python_script


def test_variable_substitution():
    """Test to check if a simple echo $foo variable is ported"""
    bash_script = "echo $foo"
    expected_python_script = "run(f'echo {foo}')"
    run_bash_script(bash_script, expected_python_script)


def test_operator_substitution():
    """Test if simple operators are substituted in a if statement"""
    bash_script = "if [ 1 -gt 0 -lt 2]; then echo Hello; fi"
    expected_python_script = "if  1 > 0 < 2:\n    run('echo Hello')"
    run_bash_script(bash_script, expected_python_script)


def test_comments_1():
    """Test if comments maintain their integrity, expected same input as output"""
    bash_script = "# This is a comment"
    expected_python_script = "# This is a comment"
    run_bash_script(bash_script, expected_python_script)


def test_while_loop():
    """Test a simple while loop convertion"""
    bash_script = "while [ $i -le 5 ]; do echo $i; done"
    expected_python_script = "while  {i} <= 5 :\n    run(f'echo {i}')"
    run_bash_script(bash_script, expected_python_script)


def test_command_substitution():
    """Checks if commands are correctly converted adding run()"""
    bash_script = "echo $(ls)"
    expected_python_script = "run('echo $(ls)', skip_print=False)"
    run_bash_script(bash_script, expected_python_script)


def test_command_pipe():
    """Makes sure a simple pipe is ported"""
    bash_script = "ls | grep test | wc -l"
    expected_python_script = "run('ls | grep test | wc -l')"
    run_bash_script(bash_script, expected_python_script)


def test_comments_2():
    """Checks in-line comments to ensure integrity"""
    bash_script = "echo $foo # Another comment"
    expected_python_script = "run(f'echo {foo} ') #  Another comment"
    run_bash_script(bash_script, expected_python_script)


def test_variable_assignment():
    """Tests a simple case of variable assignment in two lines"""
    bash_script = "name='John Doe'; echo $name"
    expected_python_script = "name = 'John Doe'\n run(f'echo {name}')"
    run_bash_script(bash_script, expected_python_script)


def test_arithmetic_expression():
    """Checks if arithmetics are working correctly"""
    bash_script = "echo $((2+3*4))"
    expected_python_script = "run('echo $((2+3*4))', skip_print=False)"
    run_bash_script(bash_script, expected_python_script)


def test_double_quotes():
    """Make sure double quotes escaped inside run calls"""
    bash_script = 'echo "Hello world"'
    expected_python_script = "run('echo \"Hello world\"')"

    run_bash_script(bash_script, expected_python_script)


def test_embedded_for_not_supported():
    """Make sure that embedded FOR issues warning about not being supported"""
    bash_script = """for i in 1 2 3; do
    for j in a b c; do
    echo \"$i$j\"
    done
    done 
    """
    expected_python_script = "embedded for: for i in 1 2 3; do"
    output = (
        subprocess.check_output(["python3", "bash2python.py", "--script", bash_script])
        .decode()
        .strip()
    )
    assert expected_python_script in output
@pytest.mark.skip
def test_complex_for_loop():
    """Tests complex for loop. Includes some arrays"""
    bash_script = """
    files=('file1.txt' 'file2.txt' 'file3.txt' 'file4.txt' 'file5.txt')
    for file in "${files[@]}"; do
        echo "Reading file: $file"
        run("cat $file")
    done
    """
    expected_python_script = """
    files=['file1.txt', 'file2.txt', 'file3.txt', 'file4.txt', 'file5.txt']
    for file in files:
        run("echo \"Reading file: $file\"")
        run(f"cat {file}")
        """
    run_bash_script(bash_script, expected_python_script)


@pytest.mark.skip
def test_if_else_condition():
    """TODO flesh out: test if/else"""
    bash_script = 'if [ -f "$1" ]; then echo "$1 exists and is a regular file."; elif [ -e "$1" ]; then echo "$1 exists but is not a regular file."; else; echo "$1 does not exist."; fi'
    expected_python_script = (
        "if a == b:\n run('echo 'Equal'')\nelse:\n run('echo 'Not Equal'')"
    )
    run_bash_script(bash_script, expected_python_script)


@pytest.mark.skip
def test_for_c_style():
    """Tests C-style for loops"""
    bash_script = "for ((i=0; i < 10; i++)); do  echo $i; done"
    expected_python_script = "for i in range(10): \n run(f'print {i}')"
    run_bash_script(bash_script, expected_python_script)

@pytest.mark.skip
def test_case_statement():
    """Tests if case statement is correctly translated"""
    bash_script = """
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
    expected_python_script = """
    if var == 'x':
        run('echo "var is x"')
    elif var in ('y', 'z'):
        run('echo "var is y or z"')
    else:
        run('echo "var is not x, y or z"')
    """
    run_bash_script(bash_script, expected_python_script)


def test_let_command():
    """Test if a let command is converted correctly"""
    bash_script = 'let "x=1+2"'
    expected_python_script = "x = 1+2"
    run_bash_script(bash_script, expected_python_script)

def test_history_substitution():
    """Tests the history mechanism ($!)"""
    bash_script = "echo hello && echo world && echo !$"
    expected_python_script = "run('echo hello && echo world && echo !$')"
    run_bash_script(bash_script, expected_python_script)

def test_echo_to_stderr():
    """Tests if echo to stderr is converted to print statements"""
    bash_script = "echo 'This is an error' >&2"
    expected_python_script = "print('This is an error', file=sys.stderr)"
    run_bash_script(bash_script, expected_python_script)
