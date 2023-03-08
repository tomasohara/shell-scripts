import subprocess
import pytest

#Use 'pytest bash2python_test.py -k "not skip"' to skip the tests that cover functions not yet implemented.
def test_variable_substitution():
    bash_script = "echo $foo"
    expected_python_script = "run(f'echo {foo}')"
    assert (
        subprocess.check_output(["python3", "bash2python", "--script", bash_script])
        .decode()
        .strip()
        == expected_python_script
    )


def test_operator_substitution():
    bash_script = "if [ 1 -gt 0 -lt 2]; then echo Hello; fi"
    expected_python_script = "if  1 > 0 < 2:\n    run('echo Hello')"
    assert (
        subprocess.check_output(["python3", "bash2python", "--script", bash_script])
        .decode()
        .strip()
        == expected_python_script
    )


def test_comments_1():
    bash_script = "# This is a comment"
    expected_python_script = "# This is a comment"
    assert (
        subprocess.check_output(["python3", "bash2python", "--script", bash_script])
        .decode()
        .strip()
        == expected_python_script
    )


def test_while_loop():
    bash_script = "while [ $i -le 5 ]; do echo $i; done"
    expected_python_script = "while  {i} <= 5 :\n    run(f'echo {i}')"
    assert (
        subprocess.check_output(["python3", "bash2python", "--script", bash_script])
        .decode()
        .strip()
        == expected_python_script
    )


def test_command_substitution():
    bash_script = "echo $(ls)"
    expected_python_script = "run('echo $(ls)', skip_print=False)"
    assert (
        subprocess.check_output(["python3", "bash2python", "--script", bash_script])
        .decode()
        .strip()
        == expected_python_script
    )


def test_command_pipe():
    bash_script = "ls | grep test | wc -l"
    expected_python_script = "run('ls | grep test | wc -l')"
    assert (
        subprocess.check_output(["python3", "bash2python", "--script", bash_script])
        .decode()
        .strip()
        == expected_python_script
    )


def test_comments_2():
    bash_script = "echo $foo # Another comment"
    expected_python_script = "run(f'echo {foo} ') #  Another comment"
    assert (
        subprocess.check_output(["python3", "bash2python", "--script", bash_script])
        .decode()
        .strip()
        == expected_python_script
    )


def test_variable_assignment():
    bash_script = "name='John Doe'; echo $name"
    expected_python_script = "name = 'John Doe'\n run(f'echo {name}')"
    assert (
        subprocess.check_output(["python3", "bash2python", "--script", bash_script])
        .decode()
        .strip()
        == expected_python_script
    )


def test_arithmetic_expression():
    bash_script = "echo $((2+3*4))"
    expected_python_script = "run('echo $((2+3*4))', skip_print=False)"
    assert (
        subprocess.check_output(["python3", "bash2python", "--script", bash_script])
        .decode()
        .strip()
        == expected_python_script
    )


def test_double_quotes():
    bash_script = 'echo "Hello world"'
    expected_python_script = "run('echo \"Hello world\"')"

    assert (
        subprocess.check_output(["python3", "bash2python", "--script", bash_script])
        .decode()
        .strip()
        == expected_python_script
    )


##This 2 tests will be fail with the actual code because they respond to non-implemented functions yet
@pytest.mark.skip
def test_for_loop():
    bash_script = "for i in {1..5}; do echo $i; done"
    expected_python_script = "for i in range(1, 6):\n run(f'echo {i}')"
    assert (
        subprocess.check_output(["python3", "bash2python", "--script", bash_script])
        .decode()
        .strip()
        == expected_python_script
    )


@pytest.mark.skip
def test_if_else_condition():
    bash_script = "if [ $a -eq $b ]; then echo 'Equal'; else echo 'Not Equal'; fi"
    expected_python_script = (
        "if a == b:\n run('echo 'Equal'')\nelse:\n run('echo 'Not Equal'')"
    )
    assert (
        subprocess.check_output(["python3", "bash2python", "--script", bash_script])
        .decode()
        .strip()
        == expected_python_script
    )

