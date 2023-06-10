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
#
## Temp: Tom's notes (TODO: delete when reviewed)
## - Add comments as tests are creatred because it is harder to add after the face. You just need to cover
##   the intention of the test not the specifics.
## - Add helper function for following sequence (n.b., in general avoid significant duplication of code):
##      subprocess.check_output(["python3", "bash2python.py", "--script", bash_script])
##        .decode()
##        .strip()
##        == expected_python_script
## - Please avoid putting function-level comments before the function, as this disrupts quickly
##   scanning the file. Instead, put them after the docstring as with my revision to test_for_loop.
## - Please run pylint for anything I expressed interest in modifying, including tests. You can filter out
##   nitpicking ones as in the the the python-lint alias(es) from tomohara-aliases.bash. (See my
##   python-lint example at bottom in case you have trouble sourcing it.)
## - Put tests in ./tests subdirectory as with tests/test_check_errors.py (n.b., in general follow the
##   convention of the repo).
##

"""Tests for bash2python.py"""

import subprocess
import pytest

def test_variable_substitution():
    """TODO add brief high-level comment"""
    bash_script = "echo $foo"
    expected_python_script = "run(f'echo {foo}')"
    assert (
        subprocess.check_output(["python3", "bash2python.py", "--script", bash_script])
        .decode()
        .strip()
        == expected_python_script
    )


def test_operator_substitution():
    """TODO add brief high-level comment"""
    bash_script = "if [ 1 -gt 0 -lt 2]; then echo Hello; fi"
    expected_python_script = "if  1 > 0 < 2:\n    run('echo Hello')"
    assert (
        subprocess.check_output(["python3", "bash2python.py", "--script", bash_script])
        .decode()
        .strip()
        == expected_python_script
    )


def test_comments_1():
    """TODO add brief high-level comment"""
    bash_script = "# This is a comment"
    expected_python_script = "# This is a comment"
    assert (
        subprocess.check_output(["python3", "bash2python.py", "--script", bash_script])
        .decode()
        .strip()
        == expected_python_script
    )


def test_while_loop():
    """TODO add brief high-level comment"""
    bash_script = "while [ $i -le 5 ]; do echo $i; done"
    expected_python_script = "while  {i} <= 5 :\n    run(f'echo {i}')"
    assert (
        subprocess.check_output(["python3", "bash2python.py", "--script", bash_script])
        .decode()
        .strip()
        == expected_python_script
    )


def test_command_substitution():
    """TODO add brief high-level comment"""
    bash_script = "echo $(ls)"
    expected_python_script = "run('echo $(ls)', skip_print=False)"
    assert (
        subprocess.check_output(["python3", "bash2python.py", "--script", bash_script])
        .decode()
        .strip()
        == expected_python_script
    )


def test_command_pipe():
    """TODO add brief high-level comment"""
    bash_script = "ls | grep test | wc -l"
    expected_python_script = "run('ls | grep test | wc -l')"
    assert (
        subprocess.check_output(["python3", "bash2python.py", "--script", bash_script])
        .decode()
        .strip()
        == expected_python_script
    )


def test_comments_2():
    """TODO add brief high-level comment"""
    bash_script = "echo $foo # Another comment"
    expected_python_script = "run(f'echo {foo} ') #  Another comment"
    assert (
        subprocess.check_output(["python3", "bash2python.py", "--script", bash_script])
        .decode()
        .strip()
        == expected_python_script
    )


def test_variable_assignment():
    """TODO add brief high-level comment"""
    bash_script = "name='John Doe'; echo $name"
    expected_python_script = "name = 'John Doe'\n run(f'echo {name}')"
    assert (
        subprocess.check_output(["python3", "bash2python.py", "--script", bash_script])
        .decode()
        .strip()
        == expected_python_script
    )


def test_arithmetic_expression():
    """TODO add brief high-level comment"""
    bash_script = "echo $((2+3*4))"
    expected_python_script = "run('echo $((2+3*4))', skip_print=False)"
    assert (
        subprocess.check_output(["python3", "bash2python.py", "--script", bash_script])
        .decode()
        .strip()
        == expected_python_script
    )


def test_double_quotes():
    """Make sure double quotes escaped inside run calls"""
    bash_script = 'echo "Hello world"'
    expected_python_script = "run('echo \"Hello world\"')"

    assert (
        subprocess.check_output(["python3", "bash2python.py", "--script", bash_script])
        .decode()
        .strip()
        == expected_python_script
    )


@pytest.mark.skip
def test_for_loop():
    """TODO flesh out: test problematic for loop"""
    ## NOTE: This 2 tests will be fail with the actual code because they respond to non-implemented functions yet
    bash_script = "for i in {1..5}; do echo $i; done"
    expected_python_script = "for i in range(1, 6):\n run(f'echo {i}')"
    assert (
        subprocess.check_output(["python3", "bash2python.py", "--script", bash_script])
        .decode()
        .strip()
        == expected_python_script
    )


@pytest.mark.skip
def test_if_else_condition():
    """TODO flesh out: test if/else"""
    bash_script = "if [ $a -eq $b ]; then echo 'Equal'; else echo 'Not Equal'; fi"
    expected_python_script = (
        "if a == b:\n run('echo 'Equal'')\nelse:\n run('echo 'Not Equal'')"
    )
    assert (
        subprocess.check_output(["python3", "bash2python.py", "--script", bash_script])
        .decode()
        .strip()
        == expected_python_script
    )

def test_embedded_for_not_supported():
    """Make sure that embedded FOR issues warning about not being supported"""
    assert(False)

##---------------------------------------------------------------------------------
##TEMP
## Example of Tom's python-lint alias
## $ cmd-trace python-lint backup/bash2python_test.py.~1~ 2>&1 | egrep 'grep|bash2python_test'
## + eval 'python-lint backup/bash2python_test.py.~1~'
## ++ python-lint backup/bash2python_test.py.~1~
## ++ python-lint-work backup/bash2python_test.py.~1~
## ++ command grep --perl-regexp -v '(Exactly one space required)|\((bad-continuation|bad-whitespace|bad-indentation|bare-except|c-extension-no-member|consider-using-enumerate|consider-using-f-string|consider-using-with|global-statement|global-variable-not-assigned|keyword-arg-before-vararg|len-as-condition|line-too-long|logging-not-lazy|misplaced-comparison-constant|missing-final-newline|redefined-variable-type|redundant-keyword-arg|superfluous-parens|too-many-arguments|too-many-instance-attributes|trailing-newlines|useless-\S+|wrong-import-order|wrong-import-position)\)'
## ++ python-lint-full backup/bash2python_test.py.~1~
## ++ command grep --perl-regexp -v '\((bad-continuation|bad-option-value|fixme|invalid-name|locally-disabled|too-few-public-methods|too-many-\S+|trailing-whitespace|star-args|unnecessary-pass)\)'
## ++ command grep --perl-regexp -v '^(([A-Z]:[0-9]+)|(Your code has been rated)|(No config file found)|(PYLINTHOME is now)|(\-\-\-\-\-))'
## ++ nice -19 pylint backup/bash2python_test.py.~1~
## ************* Module bash2python_test.py
## backup/bash2python_test.py.~1~:1:0: C0114: Missing module docstring (missing-module-docstring)
## backup/bash2python_test.py.~1~:5:0: C0116: Missing function or method docstring (missing-function-docstring)
## backup/bash2python_test.py.~1~:16:0: C0116: Missing function or method docstring (missing-function-docstring)
## backup/bash2python_test.py.~1~:27:0: C0116: Missing function or method docstring (missing-function-docstring)
## backup/bash2python_test.py.~1~:38:0: C0116: Missing function or method docstring (missing-function-docstring)
## backup/bash2python_test.py.~1~:49:0: C0116: Missing function or method docstring (missing-function-docstring)
## backup/bash2python_test.py.~1~:60:0: C0116: Missing function or method docstring (missing-function-docstring)
## backup/bash2python_test.py.~1~:71:0: C0116: Missing function or method docstring (missing-function-docstring)
## backup/bash2python_test.py.~1~:82:0: C0116: Missing function or method docstring (missing-function-docstring)
## backup/bash2python_test.py.~1~:93:0: C0116: Missing function or method docstring (missing-function-docstring)
## backup/bash2python_test.py.~1~:104:0: C0116: Missing function or method docstring (missing-function-docstring)
## backup/bash2python_test.py.~1~:118:0: C0116: Missing function or method docstring (missing-function-docstring)
## backup/bash2python_test.py.~1~:130:0: C0116: Missing function or method docstring (missing-function-docstring)
