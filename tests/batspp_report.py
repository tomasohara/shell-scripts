#!/usr/bin/env python3
#
# SCRIPT_NAME: batspp_report.py
# DESCRIPTION: Test automation & report generation for ipynb test files (for BatsPP 1.5.X).
# BatsPP files are generated by default (stored at ./batspp-only).
#
# TODO2:
# - use gh.form_path instead of f"{dir}/{file}" (for sake of Windows users).
#

"""
  Test automation & report generation for BatsPP test files for Bash.
  The files can be generated from Jupyter .ipynb files (see ./batspp-only).
"""

# Standard modules
import math

# Installed modules
import yaml

# Local modules
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla import system
msy = system
from mezcla.main import Main
from mezcla.my_regex import my_re

# Constants
TL = debug.TL

## TEMP
## pylint: disable=f-string-without-interpolation

IPYNB = ".ipynb"
BATSPP = ".batspp"
BATS = ".bats"
TXT = ".txt"
NOBATSPP = "NOBATSPP"
OUTPUTPP = ".outputpp"

OUTPUT_DIR = system.getenv_text("OUTPUT_DIR", ".",
                                "Directory for output files such as .batspp test specs")

BATSPP_STORE = gh.form_path(OUTPUT_DIR, "batspp-only")
BATS_STORE = gh.form_path(OUTPUT_DIR, "bats-only")
BATS_STORE = BATSPP_STORE
TXT_STORE = gh.form_path(OUTPUT_DIR, "txt-reports")
KCOV_STORE = gh.form_path(OUTPUT_DIR, "kcov-output")
BATSPP_OUTPUT_STORE = gh.form_path(OUTPUT_DIR, "batspp-output")

ESSENTIAL_DIRS = [BATSPP_STORE, BATS_STORE, KCOV_STORE, TXT_STORE, BATSPP_OUTPUT_STORE]
## TODO:
## ESSENTIAL_DIRS = map(gh.form_path(TMP, filename)
##                      for filename in [BATSPP_STORE, BATS_STORE, KCOV_STORE, TXT_STORE, BATSPP_OUTPUT_STORE])
ESSENTIAL_DIRS_present = all(gh.file_exists(dir) for dir in ESSENTIAL_DIRS)
THRESHOLDS_FILE = "thresholds.yaml"
DEFAULT_MIN_SCORE = 50

# Environment options
# Note: These are just intended for internal options, not for end users.
# It also allows for enabling options in one place rather than four
# (e.g., [Main member] initialization, run-time value, and argument spec., along
# with string constant definition).
#

HOME = system.getenv_text("HOME", "~",
                          "Home directory for user")
DOCKER_HOME = "/home/shell-scripts"
UNDER_DOCKER = ((HOME == DOCKER_HOME) or system.file_exists(DOCKER_HOME))

TEST_REGEX = system.getenv_value("TEST_REGEX", None,
                                 "Regex for tests to include; ex: 'c.*' for debugging")
SINGLE_STORE = system.getenv_bool("SINGLE_STORE", False,
                                  f"Whether to just use {BATSPP_OUTPUT_STORE} for all store dirs except kcov")
CLEAN_DEFAULT = system.getenv_bool("CLEAN_OUTPUT", not debug.detailed_debugging(),
                                   f"Whether to clean existing output by remove entire directories")
TEST_DIR = system.getenv_value("TEST_DIR", None,
                               "Directory with BatsPP test definitions")
## NOTE: the code needs to be thoroughly revamped (e.g., currently puts .batspp in same place as .bats)
if SINGLE_STORE:
    BATSPP_STORE = BATS_STORE = TXT_STORE = BATSPP_OUTPUT_STORE
    debug.trace(3, f"FYI: Using single store for text-based output files, etc.: {BATSPP_STORE}")

#-------------------------------------------------------------------------------

def load_thresholds(filename):
    """Load test failure thresholds from a YAML file."""
    # TODO: put in utility module
    result = {}
    with open(filename, "r", encoding="utf-8") as yamlfile:
        result = yaml.safe_load(yamlfile)
    debug.trace(5, f"load_thresholds({filename}) => {result}")
    return result

#-------------------------------------------------------------------------------
# NOTE: *** This function is too monolithinc: it should be structured like kcov_result.py ***
# TODO2: Convert batspp-proper logic into a class with a separate method for each step; the
#    __init__ method can take one argument per command-line option to facilitate conversion).
#

def main():
    """Entry point"""

    # Get files in test definition dir
    # note: uses TEST_DIR or basename of this file, with "." as fallback
    ## OLD: files = msy.read_directory(".")
    test_path = system.real_path(TEST_DIR or ".")
    # note: script should either run in ./tests dir or define TEST_DIR
    debug.assertion(test_path.endswith("tests"))
    files = msy.read_directory(test_path)

    # 0.1) CHECKING IF THE DIRECTORY EXISTS
    if not ESSENTIAL_DIRS_present:
        for dir_path in ESSENTIAL_DIRS:
            gh.full_mkdir(dir_path)

    batspp_count = 0

    # 0.2) Option Parsing
    NO_REPORTS_ARG = "no"
    KCOV_REPORTS_ARG = "kcov"
    TEXT_REPORTS_ARG = "txt"
    ALL_REPORTS_ARG = "all"
    BATSPP_SWITCH_ARG = "switch"
    FORCE_ARG = "force"
    CLEAN_ARG = "clean"
    DEFINITIONS_ARG = "definitions"
    main_app = Main(
        description=__doc__.format(script=gh.basename(__file__)).strip("\n"),
        boolean_options=[
            (NO_REPORTS_ARG, "No reports are generated, testfiles are shown"),
            (KCOV_REPORTS_ARG, f"KCOV (HTML based) reports generated, stored at {KCOV_STORE}"),
            (TEXT_REPORTS_ARG, f"Textfile based reports generated, stored at {TXT_STORE}"),
            (ALL_REPORTS_ARG, "Generates report for all available testfiles (n.b., NOBATSPP testfiles ignored by default)"),
            (FORCE_ARG, "Force running under admin-like account"),
            (CLEAN_ARG, "Remove output from previous runs; *** warning: this removes entire subdirectories"),
            (BATSPP_SWITCH_ARG, "Uses batspp library instead of ../simple_batspp.py script"),
        ],
        text_options=[
            (DEFINITIONS_ARG, "Script with alias definitions to be sourced"),
        ],
        skip_input=False,
        manual_input=False,
        short_options=True,
    )
    #
    debug.assertion(main_app.parsed_args)
    NO_OPTION = main_app.get_parsed_option(NO_REPORTS_ARG)
    TXT_OPTION = main_app.get_parsed_option(TEXT_REPORTS_ARG)
    KCOV_OPTION = main_app.get_parsed_option(KCOV_REPORTS_ARG)
    ALL_OPTION = main_app.get_parsed_option(ALL_REPORTS_ARG)
    FORCE_OPTION = main_app.get_parsed_option(FORCE_ARG, UNDER_DOCKER)
    CLEAN_OPTION = main_app.get_parsed_option(CLEAN_ARG, CLEAN_DEFAULT)
    BATSPP_SWITCH_OPTION = main_app.get_parsed_option(BATSPP_SWITCH_ARG)
    USE_SIMPLE_BATSPP = (not BATSPP_SWITCH_OPTION)
    DEFINITIONS_SCRIPT = main_app.get_parsed_option(DEFINITIONS_ARG)
    debug.trace_expr(4, NO_OPTION, TXT_OPTION, KCOV_OPTION, FORCE_OPTION, CLEAN_OPTION, BATSPP_SWITCH_OPTION, USE_SIMPLE_BATSPP, DEFINITIONS_SCRIPT)
    RUN_BATS = (TXT_OPTION or not NO_OPTION)

    # Do check for adminstrative user and exit unless --force
    is_admin = my_re.search(r"root|admin|adm", gh.run("groups"))
    if is_admin:
        if not FORCE_OPTION:
            msy.exit("Error: running under admin account requires --force option, unless under docker shell-scripts-dev image")
        msy.print_stderr("FYI: not recommended to run under admin account")

    # Cleanup up previous runs
    # Warning: 'rm -rf' is a very dangerous command:
    # it should only be done in temporary directories (e.g., not under repo)
    if CLEAN_OPTION:
        if RUN_BATS:
            gh.run(f"rm -rf {BATSPP_STORE}/*")
            gh.run(f"rm -rf {BATS_STORE}/*")
        
        if not KCOV_OPTION:
            gh.run(f"rm -rf {KCOV_STORE}/*")
    
        if not TXT_OPTION:
            gh.run(f"rm -rf {TXT_STORE}/*")

    def run_batspp(input_file, output_file):
        """Run BatsPP over INPUT_FILE to produce OUTPUT_FILE"""
        # Note: for convenience, output is written to disk and returned by the function
        ## TODO2: add log_file argument for stderr; change output_file to output_script_file
        real_output_file = output_file + ".out"
        log_file = output_file + ".log"
        debug.trace(5, f"run_batspp{(input_file, output_file)}")
        source_spec = (f"--source '{DEFINITIONS_SCRIPT}'" if DEFINITIONS_SCRIPT else "")
        if USE_SIMPLE_BATSPP:
            # note: adds sentinels around paragraph segments for simpler parsing;
            # uses Bash instead of Bats (to bypass need for global setup sections);
            # copies ./tests files into bats test dir (under temp); retains outer
            # quotation marks in output; uses single test directory; passes along --force option
            run_output = gh.run(f"MATCH_SENTINELS=1 PARA_BLOCKS=1 BASH_EVAL=1 COPY_DIR=1 KEEP_OUTER_QUOTES=1 GLOBAL_TEST_DIR=1 FORCE_RUN={FORCE_OPTION} python3 ../simple_batspp.py {input_file} --output {output_file} {source_spec} > {real_output_file} 2> {log_file}")
        else:
            run_output = gh.run(f"batspp {input_file} --save {output_file} {source_spec} 2> {log_file}")
        debug.code(4, lambda: gh.run(f"check_errors.perl {log_file}"))
        debug.assertion(not run_output.strip())
        real_output = system.read_file(real_output_file)
        debug.trace(6, f"run_batspp() => {real_output!r}")
        return real_output

    ## TEST (plan A until COPY_DIR=1 added above)
    ## # 0.9) Making sure input files, etc. accessible in bats directory
    ## # TODO2: use directory for (e.g., ./resources)
    ## debug.trace(4, "Copying over potential input files into bats directory")
    ## gh.run(f"cp -vf *.html *.input* *.yaml *.list *.rst *.txt *.text {BATS_STORE}/")

    # Other initialization

    if system.file_exists(THRESHOLDS_FILE):
        thresholds = load_thresholds(THRESHOLDS_FILE)
        missing_test_files = [f for f in thresholds.keys() if not system.file_exists(f)]
        debug.assertion(not missing_test_files,
                        f"Extranoes file(s) in {THRESHOLDS_FILE}: {missing_test_files}")
    
    # 1) Identifying .ipynb files
    i = 1
    ipynb_array = []
    avoid_array = []
    avoid_count = 0
    success_test_array = []
    failure_test_array = []

    print(f"\n=== BATSPP REPORT GENERATOR (simple_batspp.py / BATSPP 1.5.X) ===\n")

    for file in files:
        is_ipynb = file.endswith(IPYNB)
        if is_ipynb:
            if TEST_REGEX and not my_re.search(fr"{TEST_REGEX}", file):
                debug.trace(3, f"FYI: Ignoring {file} not mathing TEST_REGEX ({TEST_REGEX})")
                continue
            if not ALL_OPTION and NOBATSPP in file:
                debug.trace(4, f"FYI: Ignoring NOBATSPP file: {file}")
                print(f"NOBATSPP File Found [{i}]: {file}")
                avoid_array.append(file)
                avoid_count += 1
                continue
            print(f"JUPYTER Testfile Found [{i}]: {file}")
            ipynb_array.append(file)
            i += 1

    print(f"\nIPYNB Files Found (Total - NOBATSPP): {i-1} - {avoid_count} = {i-avoid_count-1}")

    # 2) Generating .batspp files from .ipynb files
    i = 1
    batspp_array = []
    print(f"\n=== GENERATING BATSPP FILES ===\n")

    for testfile in ipynb_array:
        is_ipynb = testfile.endswith(IPYNB)
        if is_ipynb:
            ## OLD: batspp_from_ipynb = testfile.replace(IPYNB, BATSPP)
            batspp_from_ipynb = gh.form_path(BATSPP_STORE,
                                             gh.basename(testfile.replace(IPYNB, BATSPP)))
            print(f"IPYNB TESTFILE [{i}]: {testfile} => {batspp_from_ipynb}")
            log_file = f"{batspp_from_ipynb}.log"
            gh.run(f"python3 ../jupyter_to_batspp.py {testfile} --output {batspp_from_ipynb} 2> {log_file}")
            # note: uses call to avoid issue with lambda function argument binding
            debug.call(4, gh.run, f"check_errors.perl {log_file}", **{"output": True})
            batspp_array.append(batspp_from_ipynb)
            i += 1
    ipynb_count = i - 1
    debug.trace_expr(5, ipynb_count, batspp_array)
    debug.assertion(ipynb_count == len(batspp_array))

    # 3) Executing batspp files & storing them as bats
    print(f"\n\n==========BATS GENERATED==========\n")
    # TODO3: rename i => num_test_files, total_count_ok => total_ok_tests, and total_count_total to total_num_tests
    i = 1
    total_count_ok = 0
    total_count_total = 0
    total_success_rate = 0
    total_num_successful = 0

    if not RUN_BATS:
        print(f">> SKIPPING BATSPP CHECK (-n ARGUMENT PROVIDED)\n")
    else:
        for batsppfile_path in batspp_array:
            batsppfile = gh.basename(batsppfile_path)
            ipynb_from_batspp = batsppfile.replace(BATSPP, IPYNB)
            bats_from_batspp = batsppfile.replace(BATSPP, BATS)
            output_from_batspp = batsppfile.replace(BATSPP, OUTPUTPP)
            txt_from_batspp = batsppfile.replace(BATSPP, TXT)
            test_extensionless = gh.remove_extension(batsppfile, BATSPP)
            is_batspp = batsppfile.endswith(BATSPP)
            debug.trace_expr(4, batsppfile, ipynb_from_batspp)
            
            if not is_batspp:
                debug.trace(4, f"Ignoring non-batspp file {batsppfile}")
                continue
            print(f"\nBATSPP FILE DETECTED [{i}]: {batsppfile} => {bats_from_batspp}\n")
            i += 1

            if TXT_OPTION:
                output_from_batspp_path = gh.form_path(BATSPP_OUTPUT_STORE, output_from_batspp)
                bats_output = run_batspp(batsppfile_path, output_from_batspp_path)
                
                output_lines = bats_output.splitlines()
                output_lines_filtered = [item for item in output_lines if not item.startswith("#")]
                debug.trace_expr(5, output_lines_filtered)
                if output_lines_filtered:
                    # Ignore the line given the number of tests (e.g., "1..5")
                    header_line = output_lines_filtered.pop(0)
                    debug.trace_expr(5, header_line)
                    debug.assertion(my_re.search(r"^1\.\.\d+", header_line) or (header_line == "0..0"),
                                    f"Unexpected header line for {output_from_batspp_path}: {header_line!r}")
                debug.assertion(len(output_lines_filtered))
                
                count_ok = len([item for item in output_lines_filtered if item.startswith("ok")])
                count_bad = len([item for item in output_lines_filtered if item.startswith("not ok")])
                count_total = (count_ok + count_bad)
                success_rate = (round((count_ok / count_total)*100, 2) if count_total else 0)
                min_score = system.to_float(thresholds.get(ipynb_from_batspp, DEFAULT_MIN_SCORE))
                successful = (success_rate >= min_score)
                debug.trace_expr(4, min_score, count_ok, count_bad, count_total, success_rate, successful)
                SUMMARY_TEXT = f"{count_ok} out of {count_total} successful ({success_rate}%)\nSuccess: {successful}"
                msy.write_file(f"{TXT_STORE}/{txt_from_batspp}", SUMMARY_TEXT)
                print(f"{test_extensionless}: {SUMMARY_TEXT}")
                total_count_ok += count_ok
                total_count_total += count_total
                total_success_rate += success_rate
                total_num_successful += int(successful)

                # Categorizing Tests if they are successful or not
                txt_option_JSON = {}
                txt_option_JSON["test_name"] = test_extensionless
                txt_option_JSON["test_min_score"] = min_score
                txt_option_JSON["test_success_rate"] = success_rate
                if successful:
                    success_test_array.append(txt_option_JSON)
                else:
                    failure_test_array.append(txt_option_JSON)

            else:
                run_batspp(batsppfile_path, f"{BATS_STORE}/{bats_from_batspp}")
                gh.run(f"kcov {KCOV_STORE}/{test_extensionless} bats {BATS_STORE}/{bats_from_batspp}")
                    
                if KCOV_OPTION:
                    KCOV_MESSAGE = f"KCOV REPORT PATH: {KCOV_STORE}/{test_extensionless}/"
                    print(gh.indent(KCOV_MESSAGE, indentation="  >>  ", max_width=512))
                    gh.run(f"kcov {KCOV_STORE}/{test_extensionless} bats {BATS_STORE}/{bats_from_batspp}")

        batspp_count = i - 1 

    # 4) Mentioning any errors in ipynb testfiles
    working_testfiles = []
    sucess_test_array_SORT = sorted(success_test_array, key=lambda x: x["test_success_rate"], reverse = True)
    failure_test_array_SORT = sorted(failure_test_array, key=lambda x: x["test_success_rate"], reverse = True)

    for file in batspp_array:
        is_batspp = file.endswith(BATSPP)

        if is_batspp:
            BI_check = [file.replace(".batspp", ".ipynb")]
            working_testfiles += BI_check

    # 5) Summary Statistics
    set_wt = set(working_testfiles)
    error_testfiles = [tf for tf in ipynb_array if tf not in set_wt]
    faulty_count = ipynb_count - batspp_count

    NaN = math.nan
    print(f"\n======================================================")
    print(f"SUMMARY STATISTICS:\n")
    print(f"simple_batspp.py used: {bool(BATSPP_SWITCH_OPTION)}")
    print(f"No. of IPYNB testfiles: {ipynb_count + avoid_count}")
    print(f"No. of BATSPP files (generated): {batspp_count if RUN_BATS else NaN}")
    print(f"No. of FAULTY testfiles: {faulty_count if RUN_BATS else NaN}")
    print(f"No. of AVOIDED testfiles: {avoid_count}")
    print(f"Total no. of good tests: {total_count_ok}")
    print(f"Total no. of individual tests: {total_count_total}")
    # Note: macro-average is mean of success score, whereas micro-average is based on global counts.
    # See https://datascience.stackexchange.com/questions/15989/micro-average-vs-macro-average-performance-in-a-multiclass-classification-settin
    avg_successful = macro_success_rate = micro_success_rate = NaN
    if batspp_count:
        avg_successful = total_num_successful / batspp_count * 100
        macro_success_rate = total_success_rate / batspp_count
    if total_count_total:
        micro_success_rate = total_count_ok / total_count_total * 100
    print(f"Total no. files OK w/ threshold: {total_num_successful}")
    print(f"Average no. files OK w/ threshold: {system.round3(avg_successful)}%")
    print(f"Macro success score: {system.round3(macro_success_rate)}%")
    print(f"Micro success score: {system.round3(micro_success_rate)}%")
    print("    where successful based on threshold, macro is mean of individual scores, and micro is global metric")

    print(f"\nFAULTY TESTFILES:")
    if faulty_count == 0:
        print("n/a")
    else:
        ## TODO3: what is the intention here (e.g., the '>>')?
        for tf in error_testfiles:
            print(f">> {tf}")
            
    print("\nAVOIDED TESTFILES:")
    if avoid_count == 0:
        print("n/a")
    else:
        for tf in avoid_array:
            print(f">> {tf}")

    if TXT_OPTION:
        print("\nTEST SUCCESS (--txt ENABLED):")
        print(f"No. of Successful Tests:", len(success_test_array))
        print(f"No. of Failure Tests:", len(failure_test_array))
        debug.assertion(len(success_test_array) == total_num_successful)

        def print_test_array(arr):
            """Print summary of test results in ARR"""
            for index, item in enumerate(arr):
                name = item['test_name']
                rate = item['test_success_rate']
                min_score = item['test_min_score']
                print(f"{index + 1}. {name} ({rate}%): threshold={min_score}%")
            if not arr:
                print("n/a")

        print("\nSuccessful Tests:\n---------------------")
        print_test_array(sucess_test_array_SORT)
        print("\nFailure Tests:\n---------------------")
        print_test_array(failure_test_array_SORT)
        
    print(f"======================================================")

    # Return number of failed tests as statues (i.e., OK if 0 failed)
    code = (len(failure_test_array) if success_test_array else -1)
    system.exit(status_code=code)
    
# -------------------------------------------------------------------------------

if __name__ == '__main__':
    debug.trace_current_context(level=TL.QUITE_DETAILED)
    main()
