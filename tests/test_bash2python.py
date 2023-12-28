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
# - Add variations throughout with constructs intended to throw off parsing (e.g., comments with syntax).
# - Look into synthetic test sets (e.g., via Codex translation of bash test suite)!
#
# TODO4:
# - Add tests to make sure formatting changes not required (e.g., via black).
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
NEWLINE = "\n"                          # for use in regex's
RUN_SLOW_TESTS = system.getenv_bool("RUN_SLOW_TESTS", False,
                                    "Run tests that can a while to run")
TEST_UNSUPPORTED = system.getenv_bool("TEST_UNSUPPORTED", False,
                                      "Run tests for unsupported features like arrays and hashes")
NORMALIZE_LOOSE = system.getenv_bool("NORMALIZE_LOOSE", False,
                                     "Use loose normalization such as collapsinng all whitespace")

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


def normalize_whitespace(text, loose=None):
    """Perform normalization of TEXT to facilitate comparisons: carriage returns changed to newlines, spaces and newlines are collapsed, and outer whitespace is stripped"""
    # EX: normalize("Hey  Joe\r\n!") => Hey Joe\n!"
    if loose is None:
        loose = NORMALIZE_LOOSE
    result = text.strip()
    if loose:
        result = my_re.sub("[\v\f\t\r]", " ", result)
        result = my_re.sub("( \n)|(\n )", "\n", result)
        ## TEMP
        result = my_re.sub("\n", " ", result)
        ## HACK: result = my_re.sub("\\n", " ", result)
        result = result.replace("\n", " ")
        result = result.replace("\\n", " ")
        debug.trace_expr(7, result)
    result = my_re.sub("\r", "\n", result)
    result = my_re.sub(fr"\s+{NEWLINE}+\s+", "\n", result)
    result = my_re.sub(r"  +", " ", result)
    debug.trace(7, f"normalize_whitespace({text!r}) => {result!r}")
    return result


def bash2py_helper(bash, expect, skip_normalize=False, keep_comments=False, strip_input=None, init_vars=False):
    """Helper for call bash2python as a module
    Notes:
    - Applies whitespace normalization unless SKIP_NORMALIZE
    - Omits conversion comments unless KEEP_COMMENTS (for sake of simpler matching)
    - Optionally STRIPS_INPUT of blank lines and comments
    - Optionally INITs_VARS (omitted to simplify test specs)
    """
    debug.trace(6, f"bash2py{(bash, expect, skip_normalize, keep_comments)}")
    b2p = B2P(bash, skip_comments=(not keep_comments), strip_input=strip_input,
              skip_var_init=(not init_vars))
    actual = b2p.convert_snippet(False)
    if not skip_normalize:
        actual = normalize_whitespace(actual)
        expect = normalize_whitespace(expect)
    debug.trace_expr(5, actual, expect, delim="\n")
    assert actual == expect

#-------------------------------------------------------------------------------
# Tests proper
    
@pytest.mark.skipif(not OPENAI_API_KEY, reason='OPENAI_API_KEY not set')
def test_1_codex():
    """Simple test for codex using an very standard input"""
    debug.trace(5, "test_1_codex()")
    bash = "echo Hello1 World"
    b2p = B2P(bash, skip_comments=True)
    actual = b2p.convert_snippet(True)
    expect = "print('Hello1 World')"
    #
    actual = normalize_whitespace(actual)
    expect = normalize_whitespace(expect)
    #
    if actual == '# internal error':
        print("Usually a problem with OPENAI_API_KEY")
    assert actual in expect


def test_2_variable_substitution():
    """Test to check if a simple echo $foo variable is ported"""
    debug.trace(5, "test_2_variable_substitution()")
    bash = "echo $foo"
    python = 'run(f"echo {foo}")'
    bash2py_helper(bash, python)


def test_3_operator_substitution():
    """Test if simple operators are substituted in a if statement"""
    debug.trace(5, "test_3_operator_substitution()")
    bash = """
if [ 1 -gt 0 ]; then
    if [ 0 -lt 2 ]; then
        echo "HELL"
    fi
fi
    """
    # TODO2: test for warning separately (e.g., strip comments); also, use valid bash input
    python = r"""
if 1 > 0:
    if 0 < 2:
        run("echo \"HELL\"")
    """
    bash2py_helper(bash, python)


def test_4_comments_1():
    """Test if comments maintain their integrity, expected same input as output"""
    debug.trace(5, "test_4_comments_1()")
    bash = "# This is a comment"
    python = "# This is a comment"
    bash2py_helper(bash, python, keep_comments=True, strip_input=False)


def test_5_comments_2():
    """Checks in-line comments to ensure integrity"""
    debug.trace(5, "test_5_comments_2()")
    bash = "echo $foo2 # Another comment"
    python = 'run(f"echo {foo2}")# Another comment'
    bash2py_helper(bash, python, keep_comments=True, strip_input=False)


def test_6_while_loop():
    """Test a simple while loop convertion"""
    debug.trace(4, "test_6_while_loop()")
    bash = """
c=3
while [ $c -le 5 ]; do
    echo $c
    let c++
done
"""
    python = """
c = 3
while c <= 5:
    run(f"echo {c}")
    c += 1
"""
    bash2py_helper(bash, python)


def test_7_command_substitution():
    """Checks if commands are correctly converted adding run()"""
    debug.trace(5, "test_7_command_substitution()")
    bash = "echo $(ls here)"
    python = 'run("echo $(ls here)", skip_print=False)'
    bash2py_helper(bash, python)


def test_8_command_pipe():
    """Makes sure a simple pipe is ported"""
    debug.trace(5, "test_8_command_pipe()")
    bash = "ls there | grep test | wc -l"
    python = 'run("ls there | grep test | wc -l")'
    bash2py_helper(bash, python)


def test_9_variable_assignment():
    """Tests a simple case of variable assignment in two lines"""
    debug.trace(5, "test_9_variable_assignment()")
    bash = "name='John Doe'\necho $name"
    python = fr"""name = 'John Doe'{NEWLINE}run(f"echo {{name}}")"""
    bash2py_helper(bash, python)

def test_10_unquoted_arg():
    """Check that unquoted arguments treated consistently"""
    debug.trace(5, "test_10_unquoted_arg()")
    bash = 'echo unquoted-token1'
    python = r'run("echo unquoted-token1")'
    # TODO3?: python = r'run("echo \"unquoted-token1\"")'
    bash2py_helper(bash, python)
    bash = 'echo "quoted-token1"'
    python = r'run("echo \"quoted-token1\"")'
    bash2py_helper(bash, python)
    

def test_11_arithmetic_expression():
    """Checks if arithmetics are working correctly"""
    debug.trace(5, "test_11_arithmetic_expression()")
    bash = 'echo "$((2+3*4))"'
    python = r'''run(f"echo {2+3*4}")'''
    bash2py_helper(bash, python)


def test_12_double_quotes():
    """Make sure double quotes escaped inside run calls"""
    debug.trace(5, "test_12_double_quotes()")
    bash = 'echo "Hello2 mundo"'
    python = r'run("echo \"Hello2 mundo\"")'
    bash2py_helper(bash, python)


@pytest.mark.xfail
def test_13_if_else_condition():
    """Test if/elif/else"""
    debug.trace(5, "test_13_if_else_condition()")
    bash = """
if [ -f "$1" ]; then
    echo "$1 exists and is a regular file."
elif [ -e "$1" ]; then
    echo "$1 exists but is not a regular file."
else
    echo "$1 does not exist."
fi
    """
    python = r'''
if os.path.isfile(f"{arg(1)}"):
    run(f"echo '{arg(1)} exists and is a regular file.'")
elif os.path.exists(f"{arg(1)}"):
    run(f"echo '{arg(1)} exists but is not a regular file.'")
else:
    run(f"echo '{arg(1)} does not exist.'")

    '''
    bash2py_helper(bash, python)
    #
    ## BAD: bash = 'if [ 4 -eq 3 ]; then echo "Equal"; else echo "Not Equal")'
    bash = 'if [ 3 -eq 4 ]; then echo "Equal"; else echo "Not Equal"; fi'
    python = fr'if 3 == 4:{NEWLINE}    run("echo \"Equal\""){NEWLINE}else:{NEWLINE}    run("echo \"Not Equal\"")'
    bash2py_helper(bash, python)
    bash = 'if true; then echo "T"; elif false; then echo "F"; else echo "N"; fi'
    python = fr'if True:{NEWLINE}    run("echo \"T\""){NEWLINE}elif False:{NEWLINE}   run("echo \"F\""){NEWLINE}else:{NEWLINE}    run("echo \"N\"")'
    bash2py_helper(bash, python)


@pytest.mark.skipif(not TEST_UNSUPPORTED, reason='Ignoring unsupported features')
def test_14_alt_if_else_condition():
    """Test non-trivial if/then/elif/fi conversion"""
    debug.trace(5, "test_14_alt_if_else_condition()")
    # Note: Needs support for bash variables
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
    python = r"""
x = run("echo \"$RANDOM\")
if x == 0:
    run(f"echo '{x} zero'")
elif x < 0:
    run(f"echo '{x} negative'")
else:
    run(f"echo '{x} positive'")
    """
    bash2py_helper(bash, python)


@pytest.mark.skipif(not TEST_UNSUPPORTED, reason='Ignoring unsupported features')
def test_15_for_c_style():
    """Tests C-style for loops"""
    debug.trace(5, "test_15_for_c_style()")
    # Note: Needs support for arithmetic for command
    bash = "for ((i=0; i < 10; i++)); do  echo $i; done"
    python = "for i in range(10):\n    run(f'print {i}')"
    bash2py_helper(bash, python)


@pytest.mark.skipif(not TEST_UNSUPPORTED, reason='Ignoring unsupported features')
def test_16_case_statement():
    """Tests if case statement is correctly translated. Not implemented"""
    debug.trace(5, "test_16_case_statement()")
    # Note: Needs support for case statements
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


def test_17_let_command():
    """Test if a let command is converted correctly"""
    debug.trace(5, "test_17_let_command()")
    bash = 'let "x=1+2"'
    python = "x=1+2"
    bash2py_helper(bash, python)


@pytest.mark.skipif(not TEST_UNSUPPORTED, reason='Ignoring unsupported features')
def test_18_history_substitution():
    """Tests the history mechanism ($!)"""
    debug.trace(5, "test_18_history_substitution()")
    # Note: Needs support for history mechanism, which is very low priority
    bash = """echo hello3 && echo WORLD && echo $!"""
    python = """run("echo hello3 && echo WORLD && echo $!")"""
    bash2py_helper(bash, python)


@pytest.mark.xfail(reason="Extraenous quotes produced")
def test_19_echo_to_stderr():
    """Tests if echo to stderr is converted"""
    debug.trace(5, "test_19_echo_to_stderr()")
    bash = "echo 'This is an error' >&2"
    python = r"""run("echo \"This is an error\" >&2")"""
    bash2py_helper(bash, python)


@pytest.mark.skipif(not TEST_UNSUPPORTED, reason='Ignoring unsupported features')
def test_20_complex_for_loop():
    """Tests complex for loop. Includes some arrays. Doomed to fail"""
    debug.trace(5, "test_20_complex_for_loop()")
    # Note: Needs support for arrays
    bash = """
files=('file1.txt' 'file2.txt' 'file3.txt' 'file4.txt' 'file5.txt')
for file in "${files[@]}"; do
    echo "Reading file: $file"
    cat $file
done
"""
    python = r"""
files=['file1.txt', 'file2.txt', 'file3.txt', 'file4.txt', 'file5.txt']
for file in files:
    run(f"echo 'Reading file: {file}'")
    run(f"cat {file}")
    """
    bash2py_helper(bash, python)


@pytest.mark.xfail
# note: uses xfail for convenience (TODO: have separate version for important tests)
@pytest.mark.parametrize("bash_line, expect_result", [
    # input                             result
    ("""echo $fubar1""",                r'''run(f"echo {fubar1}")'''),      # TODO3: print(f"{fubar}")
    ('''echo "$fubar2"''',              r'''run(f"echo '{fubar2}'")'''),
    # note: results with multiple run's requires var_replace to be incremental (as with process_compound)
    ("""ls hare1; pwd""",               """run("ls hare1"); run("pwd")"""),
    ("""ls harey\npwd\n""",             """run("ls harey")\nrun("pwd")"""),
    ("""ls hare3\n\npwd\n""",           """run("ls hare3")\n\nrun("pwd")"""),
    ])
def test_21_tabular_var_replace(bash_line, expect_result):
    """Tests in tabular format for var_replace. Uses pytest parametrize"""
    debug.trace(6, f"test_21_tabular_var_replace({bash_line!r}, {expect_result!r})")
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
     'run("echo foo")'),                # simple control test to check parametrize decorator
    ("let v++",
     "v += 1"),
    ("foo=$bar",
     'foo = f"{bar}"'),
    ("ls -a hair",
     'run("ls -a hair")'),
    ("echo $bar",
     'run(f"echo {bar}")'),
    # arithmetic expressions and expansions (latter results in string)
    ("(( z = x + y ))",
     "z = x + y"),
    ("z=$((x + y))",
     'z = f"{x + y}"'),
    ("echo a$((1+2))b",
     'run(f"echo a{1+2}b")'),
    # simple if statement(s)
    ("""if [ $? -eq 0 ]; then echo "Success"; fi""",
     fr'''if run("echo $?") == 0:{NEWLINE}   run("echo \"Success\"")'''),
    ("""if [ 1 -gt 0 ]; then if [ 0 -lt 2 ]; then echo "HELL1"; fi; fi""",
     """if 1 > 0:\n    if 0 < 2:\n    run("echo \"HELL1\"")"""),
    # simple for statement(s)
    ("""for i in 1 2 3; do echo "$i"; done""",
     fr'''for i in ["1", "2", "3"]:{NEWLINE}    run(f"echo '{{i}}'")'''),
    # simple while statement(s)
    ("""m=3; while [ $m -ge 0 ]; do echo $m; let m--; done""",
     fr'''m = 3; while m >= 0:{NEWLINE}    run(f"echo '{{m}}'"){NEWLINE}    m -= 1'''),
    ("""n=3; while [ $n -ge 0 ]; do\n    echo $n\n    let n--\ndone""",
     fr'''n = 3; while n >= 0:{NEWLINE}    run(f"echo '{{n}}'"){NEWLINE}    n -= 1'''),
    # variable assignment
    ("""name='Jane1 Doe'\necho $name""",
     fr'''name = 'Jane1 Doe'{NEWLINE}run(f"echo {{name}}")'''),
    ("""name='Jane2 Doe'; echo $name""",                  # issue: semicolon blocks variable conversion
     fr'''name = 'Jane2 Doe'{NEWLINE}run(f"echo {{name}}")'''),
    # consecutive statement execution
    ("""uname; arch""",
     """run("uname"); run("arch")"""),
    ("""uname\narch\n""",
     """run("uname")\nrun("arch")"""),
    # no-op statement
    ("true",
     "pass"),
    ("true;",
     "pass;"),                          # issue: semicolon should be dropped
    # default values (n.b., the support needs to be changed in bash2python.py)
    ("""if [ ${HOME:-n/a} = "n/a" ]; then echo "no HOME"; fi""",
     '''if os.getenv("HOME", "n/a") == "n/a":\n    run("echo \"no HOME\"")'''),
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
     fr'''if (int(run("echo \"$?\"")) > 0) and (int(run("echo \"$?\"")) < 0):{NEWLINE}    run("echo \"bad status\"")'''),
    ("""if [[ 1 || 0 ]]; then echo "one"; fi""",
     fr'''if 1 or 0:{NEWLINE}    run("echo \"one\"")'''),
    ("""if [ ! 1 = 1 ]; then echo "bug1"; fi""",
     fr'''if not 1 == 1:{NEWLINE}    run("echo \"bug1\"")'''),
    ("""if [ -z " " ]; then echo "bug2"; fi""",
     fr'''if "" == " ":{NEWLINE}    run("echo \"bug2\"")'''),
    ("""if [ -n "" ]; then echo "bug3"; fi""",
     fr'''if "" != "":{NEWLINE}    run("echo \"bug3\"")'''),
    # file operators (TODO: test for quoting of filenames)
    ("""if [ -f "$HOME/.bashrc" ]; then true; fi""",
     fr"""if os.path.isfile(f"{{HOME}}/.bashrc"):{NEWLINE}    pass"""),
    ("""if [ -d "/tmp" ]; then true; fi""",
     """if os.path.isdir("/tmp"):\n    pass"""),
    ## TODO3 (omit spaces before closing parens):
    ## ("""if [[ (-d "/tmp") || (-d "$HOME/temp") ]]; then true; fi""",
    ##  """if os.path.isdir("/tmp") or os.path.isdir("{os.getenv(\"HOME\")}/temp"):\n    pass"""),
    ("""if [[ ( -d "/tmp" ) || ( -d "$HOME/temp" ) ]]; then true; fi""",
     """if ( os.path.isdir("/tmp") ) or ( os.path.isdir("{HOME}/temp") ):\n    pass"""),
    # Unimplemented operators
    ("""if [[ $fu =~ bar ]]; then true; fi""",       # regex matching
     """if re.search("bar", fu):\n    pass"""),
    # Unimplemented features
    ("""
echo 1 2 \
3""",                                   # line continuation
     """run("echo 1 2 3");"""),
    # Exit statement (n.b., keep last as all bash input converted to script)
    ("exit",
     'run("exit")')
    ])
def test_22_tabular_tests(bash, python):
    """Tests in tabular format. Uses pytest parametrize"""
    debug.trace(5, "test_22_tabular_tests({bash!r}, {python!r})")
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
## TODO2: add config_file to do_test_external_script

@pytest.mark.xfail                      # uses xfail for convenience (TODO: have separate version for good tests)
@pytest.mark.skipif(not RUN_SLOW_TESTS, reason='Ignoring slow tests')
@pytest.mark.parametrize("filename",
                         gh.get_matching_files(gh.form_path(gh.resolve_path("bash2py-data"), "*.bash")))
def test_23_bash_script(filename):
    """Test conversion of Bash FILENAME againt corresponding .py file"""
    debug.trace(5, "test_23_bash_script()")
    do_test_external_script(filename)

#-------------------------------------------------------------------------------

if __name__ == '__main__':
    debug.trace_current_context()
    # TODO2: work out better warning (e.g., FYI)
    debug.assertion(RUN_SLOW_TESTS)
    debug.assertion(TEST_UNSUPPORTED)
    pytest.main([__file__])
