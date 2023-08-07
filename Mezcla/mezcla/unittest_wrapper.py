#! /usr/bin/env python
#
# Wrapper class around unittest.TestCase
#
# Notes:
# - Based on template.py used in older test scripts
# - Creates per-test temp file, based on same class-wide temp-base file.
# - To treat temp-base as a subdirectory, set use_temp_base_dir to True in 
#   class member initialiation section.
# - Changes to temporary directory/file should be synchronized with ../main.py.
# - Overriding the temporary directory can be handy during debugging; however,
#   you might need to specify different ones if you invoke helper scripts. See
#   tests/test_extract_company_info.py for an example.
# TODO:
# - * Clarify TEMP_BASE vs. TEMP_FILE usage.
# - Clarify that this can co-exist with pytest-based tests (see tests/test_main.py).
#
#-------------------------------------------------------------------------------
# Sample test (streamlined version of test_simple_main_example.py):
#
#   import unittest
#   from mezcla import system
#   from mezcla.unittest_wrapper import TestWrapper
#
#   class TestIt(TestWrapper):
#       """Class for testcase definition"""
#       script_module = TestWrapper.derive_tested_module_name(__file__)
#  
#       def test_simple_data(self):
#           """Make sure simple data sample processed OK"""
#           system.write_file(self.temp_file, "really fubar")
#           output = self.run_script("--check-fubar", self.temp_file)
#           self.assertTrue("really" in output)
#
#   if __name__ == '__main__':
#      unittest.main()
#-------------------------------------------------------------------------------
# TODO:
# - Add method to invoke unittest.main(), so clients don't need to import unittest.
# - Clarify how ALLOW_SUBCOMMAND_TRACING affects tests that invoke external scripts.
#

"""Unit test support class"""

# Standard modules

import os
import re
import tempfile
import unittest

# Installed modules
## TODO: import pytest

# Local modules

import mezcla
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla import system

# Constants (e.g., environment options)

TL = debug.TL
KEEP_TEMP = system.getenv_bool("KEEP_TEMP", debug.detailed_debugging(),
                               "keep temporary files")
TODO_FILE = "TODO FILE"
TODO_MODULE = "TODO MODULE"

# Note: the following is for transparent resolution of dotted module names
# for invocation of scripts via 'python -m package.module'. This is in support
# of transitioning from the old way of importing packages via 'import module'
# instead of 'import package.module'. (The former required that package be
# explicitly specified in the python path, such as via 'PYTHONPATH=package-dir:...'.)
THIS_PACKAGE = getattr(mezcla.debug, "__package__", None)
debug.assertion(THIS_PACKAGE == "mezcla")

def get_temp_dir(keep=False):
    """Get temporary directory, omitting later deletion if KEEP"""
    if keep is None:
        keep = KEEP_TEMP
    dir_path = tempfile.NamedTemporaryFile(delete=(not keep)).name
    gh.full_mkdir(dir_path)
    debug.trace(5, "get_temp_dir() => {dir_path}")
    return dir_path

class TestWrapper(unittest.TestCase):
    """Class for testcase definition"""
    script_file = TODO_FILE             # path for invocation via 'python -m coverage run ...' (n.b., usually set via get_module_file_path)
    script_module = TODO_MODULE         # name for invocation via 'python -m' (n.b., usuually set via derive_tested_module_name)
    temp_base = system.getenv_text("TEMP_BASE",
                                   tempfile.NamedTemporaryFile().name)
    check_coverage = system.getenv_bool("CHECK_COVERAGE", False,
                                        "Check coverage during unit testing")
    ## TODO: temp_file = None
    ## TEMP: initialize to unique value independent of temp_base
    ## OLD: temp_file = tempfile.NamedTemporaryFile().name
    temp_file = None
    use_temp_base_dir = None
    test_num = 1
    
    ## TEST:
    ## NOTE: leads to pytest warning. See
    ##   https://stackoverflow.com/questions/62460557/cannot-collect-test-class-testmain-because-it-has-a-init-constructor-from
    ## def __init__(self, *args, **kwargs):
    ##     debug.trace_fmtd(5, "TestWrapper.__init__({a}): keywords={kw}; self={s}",
    ##                      a=",".join(args), kw=kwargs, s=self)
    ##     super().__init__(*args, **kwargs)
    ##    debug.trace_object(5, self, label="TestWrapper instance")
    ##
    ## __test__ = False                 # make sure not assumed test
        
    @classmethod
    def setUpClass(cls):
        """Per-class initialization: make sure script_module set properly"""
        debug.trace_fmtd(5, "TestWrapper.setupClass(): cls={c}", c=cls)
        super(TestWrapper, cls).setUpClass()
        debug.trace_object(5, cls, "TestWrapper class")
        debug.assertion(cls.script_module != TODO_MODULE)
        if cls.script_module:
            # Try to pull up usage via python -m mezcla.xyz --help
            help_usage = gh.run("python -m '{mod}' --help", mod=cls.script_module)
            debug.assertion("No module named" not in help_usage,
                            f"problem running via 'python -m {cls.script_module}'")
            # Warn about lack of usage statement unless "not intended for command-line" type warning issued
            # OLD: (re.search(r"not intended.*(command|standalone)", help_usage))
            # TODO: standardize the not-intended wording
            if (not ((re.search(r"warning:.*not intended", help_usage,
                                re.IGNORECASE))
                     or ("usage:" in help_usage.lower()))):
                system.print_stderr("Warning: script should implement --help")

        # Optionally, setup temp-base directory (normally just a file)
        if cls.use_temp_base_dir is None:
            cls.use_temp_base_dir = system.getenv_bool("USE_TEMP_BASE_DIR", False)
            # TODO: temp_base_dir = system.getenv_text("TEMP_BASE_DIR", " "); cls.use_temp_base_dir = bool(temp_base_dir.strip()); ...
        if cls.use_temp_base_dir:
            ## TODO: pure python
            ## TODO: gh.full_mkdir
            gh.run("mkdir -p {dir}", dir=cls.temp_base)

        return

    @staticmethod
    def derive_tested_module_name(test_filename):
        """Derive the name of the module being tested from TEST_FILENAME. Used as follows:
              script_module = TestWrapper.derive_tested_module_name(__file__)
        Note: *** Deprecated method *** (see get_testing_module_name)
        """
        debug.trace(3, "Warning: in deprecrated derive_tested_module_name")
        module = os.path.split(test_filename)[-1]
        module = re.sub(r".py[oc]?$", "", module)
        module = re.sub(r"^test_", "", module)
        debug.trace_fmtd(5, "derive_tested_module_name({f}) => {m}",
                         f=test_filename, m=module)
        return (module)

    @staticmethod
    def get_testing_module_name(test_filename, module_object=None):
        """Derive the name of the module being tested from TEST_FILENAME and MODULE_OBJECT
        Note: used as follows (see tests/test_template.py):
            script_module = TestWrapper.get_testing_module_name(__file__)
        """
        # Note: Used to resolve module name given THE_MODULE (see template).
        module_name = os.path.split(test_filename)[-1]
        module_name = re.sub(r".py[oc]?$", "", module_name)
        module_name = re.sub(r"^test_", "", module_name)
        package_name = THIS_PACKAGE
        if module_object is not None:
           package_name = getattr(module_object, "__package__", "")
           debug.trace_expr(4, package_name)
        if package_name:
            full_module_name = package_name + "." + module_name
        else:
            full_module_name = module_name
        debug.trace_fmtd(4, "get_testing_module_name({f}, [{mo}]) => {m}",
                         f=test_filename, m=full_module_name, mo=module_object)
        return (full_module_name)

    @staticmethod
    def get_module_file_path(test_filename):
        """Return absolute path of module being tested"""
        result = system.absolute_path(test_filename)
        result = re.sub(r'tests\/test_(.*\.py)', r'\1', result)
        debug.assertion(result.endswith(".py"))
        debug.trace(7, f'get_module_file_path({test_filename}) => {result}')
        return result

    def setUp(self):
        """Per-test initializations
        Notes:
        - Disables tracing scripts invoked via run() unless ALLOW_SUBCOMMAND_TRACING
        - Initializes temp file name (With override from environment)."""
        # Note: By default, each test gets its own temp file.
        debug.trace(4, "TestWrapper.setUp()")
        if not gh.ALLOW_SUBCOMMAND_TRACING:
            gh.disable_subcommand_tracing()
        # The temp file is an extension of temp-base file by default.
        # Opitonally, if can be a file in temp-base subdrectory.
        if self.use_temp_base_dir:
            default_temp_file = gh.form_path(self.temp_base, "test-")
        else:
            default_temp_file = self.temp_base + "-test-"
        default_temp_file += str(TestWrapper.test_num)
        self.temp_file = system.getenv_text("TEMP_FILE", default_temp_file)
        gh.delete_existing_file(self.temp_file)
        TestWrapper.test_num += 1

        debug.trace_object(5, self, "TestWrapper instance")
        return

    def run_script(self, options=None, data_file=None, log_file=None, trace_level=4,
                   out_file=None, env_options=None, uses_stdin=False):
        """Runs the script over the DATA_FILE (optional), passing (positional)
        OPTIONS and optional setting ENV_OPTIONS. If OUT_FILE and LOG_FILE are
        not specifed, they  are derived from self.temp_file.
        Notes:
        - issues warning if script invocation leads to error
        - if USES_STDIN, requires explicit empty string for DATA_FILE to avoid use of - (n.b., as a precaution against hangups)"""
        debug.trace_fmtd(trace_level + 1,
                         "TestWrapper.run_script({env}, {opts}, {df}, {lf}, {of}",
                         opts=options, df=data_file, lf=log_file, 
                         of=out_file, env=env_options)
        if options is None:
            options = ""
        if env_options is None:
            env_options = ""

        # Derive the full paths for data file and log, and then invoke script.
        # TODO: derive from temp base and data file name?;
        # TODO1: derive default for uses_stdin based use of filename argment (e.g., from usage)
        data_path = ("" if uses_stdin else "-")
        if data_file is not None:
            data_path = (gh.resolve_path(data_file) if len(data_file) else data_file)
        if not log_file:
            log_file = self.temp_file + ".log"
        if not out_file:
            out_file = self.temp_file + ".out"
        # note: output is redirected to a file to preserve tabs

        # Set converage script path and command spec
        coverage_spec = ''
        if self.check_coverage:
            debug.assertion(self.script_file)
            self.script_module = self.script_file
            coverage_spec = 'coverage run'
        else:
            debug.assertion(not self.script_module.endswith(".py"))

        gh.issue("{env} python -m {cov_spec} {module}  {opts}  {path} 1> {out} 2> {log}",
                 env=env_options, cov_spec=coverage_spec, module=self.script_module,
                 opts=options, path=data_path, out=out_file, log=log_file)
        output = system.read_file(out_file)
        # note; trailing newline removed as with shell output
        if output.endswith("\n"):
            output = output[:-1]
        debug.trace_fmtd(trace_level, "output: {{\n{out}\n}}",
                         out=gh.indent_lines(output))

        # Make sure no python or bash errors. For example,
        #   "SyntaxError: invalid syntax" and "bash: python: command not found"
        log_contents = system.read_file(log_file)
        error_found = re.search(r"(\S+error:)|(no module)|(command not found)",
                                log_contents.lower())
        debug.assertion(not error_found)
        debug.trace_fmt(trace_level + 1, "log contents: {{\n{log}\n}}",
                        log=gh.indent_lines(log_contents))

        # Do sanity check for python exceptions
        traceback_found = re.search("Traceback.*most recent call", log_contents)
        debug.assertion(not traceback_found)

        return output

    def tearDown(self):
        """Per-test cleanup: deletes temp file unless detailed debugging"""
        debug.trace(4, "TestWrapper.tearDown()")
        if not KEEP_TEMP:
            gh.run("rm -vf {file}*", file=self.temp_file)
        return

    @classmethod
    def tearDownClass(cls):
        """Per-class cleanup: stub for tracing purposes"""
        debug.trace_fmtd(5, "TestWrapper.tearDownClass(); cls={c}", c=cls)
        if not KEEP_TEMP:
            ## TODO: use shutil
            if cls.use_temp_base_dir:
                gh.run("rm -rvf {dir}", dir=cls.temp_base)
            else:
                gh.run("rm -vf {base}*", base=cls.temp_base)
        super(TestWrapper, cls).tearDownClass()
        return
    
#-------------------------------------------------------------------------------
    
if __name__ == '__main__':
    debug.trace_current_context(level=TL.QUITE_DETAILED)
    debug.trace(TL.USUAL, "Warning: not intended for command-line use\n")
