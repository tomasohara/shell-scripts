#!/usr/bin/env python
#
# SCRIPT_NAME: batspp_report.py
# DESCRIPTION: Test automation & report generation for ipynb test files (for BatsPP 1.5.X).
# BatsPP files are generated by default (stored at ./batspp-only).
#

"""
  Test automation & report generation for BatsPP test files for Bash.
  The files can be generated from Jupyter .ipynb files (see ./batspp-only).
"""

# Standard modules
## TODO: import json

# Installed modules
## TODO: import batspp

# Local modules
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla import system
from mezcla.main import Main
from mezcla.my_regex import my_re

# Constants
TL = debug.TL

## TEMP
## pylint: disable=f-string-without-interpolation

IPYNB = ".ipynb"  # pylint: disable=invalid-name
BATSPP = ".batspp"  # pylint: disable=invalid-name
BATS = ".bats"  # pylint: disable=invalid-name
TXT = ".txt"  # pylint: disable=invalid-name
NOBATSPP = "NOBATSPP"  # pylint: disable=invalid-name
OUTPUTPP = ".outputpp"  # pylint: disable=invalid-name

BATSPP_STORE = "batspp-only"  # pylint: disable=invalid-name
BATS_STORE = "bats-only"  # pylint: disable=invalid-name
BATS_STORE = BATSPP_STORE  # pylint: disable=invalid-name
TXT_STORE = "txt-reports"  # pylint: disable=invalid-name
KCOV_STORE = "kcov-output"  # pylint: disable=invalid-name
BATSPP_OUTPUT_STORE = "batspp-output"  # pylint: disable=invalid-name

ESSENTIAL_DIRS = [
    BATSPP_STORE,
    BATS_STORE,
    KCOV_STORE,
    TXT_STORE,
    BATSPP_OUTPUT_STORE,
]  # pylint: disable=invalid-name
ESSENTIAL_DIRS_present = all(
    gh.file_exists(dir) for dir in ESSENTIAL_DIRS
)  # pylint: disable=invalid-name
msy = system

# Environment options
# Note: These are just intended for internal options, not for end users.
# It also allows for enabling options in one place rather than four
# (e.g., [Main member] initialization, run-time value, and argument spec., along
# with string constant definition).
#

TEST_REGEX = system.getenv_value(
    "TEST_REGEX", None, "Regex for tests to include; ex: 'c.*' for debugging"
)
SINGLE_STORE = system.getenv_bool(
    "SINGLE_STORE",
    False,
    f"Whether to just use {BATSPP_OUTPUT_STORE} for all store dirs except kcov",
)
## NOTE: the code needs to be thoroughly revamped (e.g., currently puts .batspp in save place as .bats) # pylint: disable=line-too-long

if SINGLE_STORE:
    BATSPP_STORE = BATS_STORE = TXT_STORE = BATSPP_OUTPUT_STORE
    debug.trace(3, f"FYI: Using single store for text-based output files, etc.")

# -------------------------------------------------------------------------------
# NOTE: *** This function is too monolithinc: it should be structured like kcov_result.py ***
# TODO2: Convert batspp-proper logic into a class with a separate method for each step; the
#    __init__ method can take one argument per command-line option to facilitate conversion).
#


def main():  # pylint: disable=too-many-locals,too-many-branches,too-many-statements
    """Entry point"""
    files = msy.read_directory("./")

    # 0.1) CHECKING IF THE DIRECTORY EXISTS
    if not ESSENTIAL_DIRS_present:
        for dir_path in ESSENTIAL_DIRS:
            gh.full_mkdir(dir_path)

    batspp_count = 0

    # 0.2) Option Parsing
    NO_REPORTS_ARG = "no"  # pylint: disable=invalid-name
    KCOV_REPORTS_ARG = "kcov"  # pylint: disable=invalid-name
    TEXT_REPORTS_ARG = "txt"  # pylint: disable=invalid-name
    ALL_REPORTS_ARG = "all"  # pylint: disable=invalid-name
    BATSPP_SWITCH_ARG = "switch"  # pylint: disable=invalid-name
    FORCE_ARG = "force"  # pylint: disable=invalid-name
    CLEAN_ARG = "clean"  # pylint: disable=invalid-name
    main_app = Main(
        description=__doc__.format(script=gh.basename(__file__)).strip("\n"),
        boolean_options=[
            (NO_REPORTS_ARG, "No reports are generated, testfiles are shown"),
            (
                KCOV_REPORTS_ARG,
                f"KCOV (HTML based) reports generated, stored at ./{KCOV_STORE}",
            ),
            (
                TEXT_REPORTS_ARG,
                f"Textfile based reports generated, stored at ./{TXT_STORE}",
            ),
            (
                ALL_REPORTS_ARG,
                "Generates report for all available testfiles (NOBATSPP testfiles were ignored by default)",
            ),
            (FORCE_ARG, "Force running under adm account"),
            (
                CLEAN_ARG,
                "Remove output from previous runs--warning removes entire directories",
            ),
            (
                BATSPP_SWITCH_ARG,
                "Uses batspp library instead of ../simple_batspp.py script",
            ),
        ],
        skip_input=False,
        manual_input=False,
        short_options=True,
    )
    debug.assertion(main_app.parsed_args)
    #
    debug.assertion(main_app.parsed_args)
    NO_OPTION = main_app.get_parsed_option(
        NO_REPORTS_ARG
    )  # pylint: disable=invalid-name
    TXT_OPTION = main_app.get_parsed_option(
        TEXT_REPORTS_ARG
    )  # pylint: disable=invalid-name
    KCOV_OPTION = main_app.get_parsed_option(
        KCOV_REPORTS_ARG
    )  # pylint: disable=invalid-name
    ALL_OPTION = main_app.get_parsed_option(
        ALL_REPORTS_ARG
    )  # pylint: disable=invalid-name
    FORCE_OPTION = main_app.get_parsed_option(FORCE_ARG)  # pylint: disable=invalid-name
    CLEAN_OPTION = main_app.get_parsed_option(CLEAN_ARG)  # pylint: disable=invalid-name
    BATSPP_SWITCH_OPTION = main_app.get_parsed_option(
        BATSPP_SWITCH_ARG
    )  # pylint: disable=invalid-name
    USE_SIMPLE_BATSPP = not BATSPP_SWITCH_OPTION  # pylint: disable=invalid-name
    debug.trace_expr(
        4,
        NO_OPTION,
        TXT_OPTION,
        KCOV_OPTION,
        FORCE_OPTION,
        CLEAN_OPTION,
        BATSPP_SWITCH_OPTION,
        USE_SIMPLE_BATSPP,
    )

    # Do check for adminstrative user and exit unless --force
    is_admin = my_re.search(r"root|admin|adm", gh.run("groups"))
    if is_admin:
        if not FORCE_OPTION:
            msy.exit("Error: running under admin account requires --force option")
        msy.print_stderr("FYI: not recommended to run under admin account")

    # Cleanup up previous rusn
    # Warning: 'rm -rf' is a very dangerous command:
    # it should only be done in temporary directories (i.e., not under
    if CLEAN_OPTION:
        if not NO_OPTION:
            gh.run(f"rm -rf ./{BATSPP_STORE}/*")
            gh.run(f"rm -rf ./{BATS_STORE}/*")

        if not KCOV_OPTION:
            gh.run(f"rm -rf ./{KCOV_STORE}/*")

        if not TXT_OPTION:
            gh.run(f"rm -rf ./{TXT_STORE}/*")

    def run_batspp(input_file, output_file):
        """Run BatsPP over INPUT_FILE to produce OUTPUT_FILE"""
        # Note: for convenience, output is written to disk and returned by the function
        ## TODO2: add log_file argument for stderr; change output_file to output_script_file
        real_output_file = output_file + ".out"
        log_file = output_file + ".log"
        debug.trace(5, f"run_batspp{(input_file, output_file)}")
        if USE_SIMPLE_BATSPP:
            run_output = gh.run(
                f"MATCH_SENTINELS=1 PARA_BLOCKS=1 COPY_DIR=1 ../simple_batspp.py {input_file} --output ./{output_file} > ./{real_output_file} 2> ./{log_file}"
            )
        else:
            run_output = gh.run(
                f"batspp {input_file} --save ./{output_file} 2> ./{log_file}"
            )
        debug.assertion(not run_output.strip())
        real_output = system.read_file(real_output_file)
        debug.trace(6, f"run_batspp() => {real_output!r}")
        return real_output

    ## TEST (plan A until COPY_DIR=1 added above)
    ## # 0.9) Making sure input files, etc. accessible in bats directory
    ## # TODO2: use directory for (e.g., ./resources)
    ## debug.trace(4, "Copying over potential input files into bats directory")
    ## gh.run(f"cp -vf *.html *.input* *.yaml *.list *.rst *.txt *.text ./{BATS_STORE}/")

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
            if TEST_REGEX and not my_re.match(rf"^{TEST_REGEX}$", file):
                debug.trace(3, f"Ignoring {file}")
                continue
            if not ALL_OPTION and NOBATSPP in file:
                print(f"NOBATSPP File Found [{i}]: {file}")
                avoid_array.append(file)
                avoid_count += 1
            else:
                print(f"JUPYTER Testfile Found [{i}]: {file}")
                ipynb_array.append(file)
            i += 1

    print(
        f"\nIPYNB Files Found (Total - NOBATSPP): {i-1} - {avoid_count} = {i-avoid_count-1}"
    )

    # 2) Generating .batspp files from .ipynb files
    i = 1
    batspp_array = []
    print(f"\n=== GENERATING BATSPP FILES ===\n")

    for testfile in ipynb_array:
        is_ipynb = testfile.endswith(IPYNB)
        if is_ipynb:
            batspp_from_ipynb = testfile.replace(IPYNB, BATSPP)
            print(f"IPYNB TESTFILE [{i}]: {testfile} => {batspp_from_ipynb}")
            gh.run(
                f"./jupyter_to_batspp.py {testfile} --output ./{BATSPP_STORE}/{batspp_from_ipynb}"
            )
            batspp_array.append(batspp_from_ipynb)
            i += 1

    ipynb_count = i - 1

    # 3) Executing batspp files & storing them as bats
    print(f"\n\n==========BATS GENERATED==========\n")
    i = 1

    if NO_OPTION:
        print(f">> SKIPPING BATSPP CHECK (-n ARGUMENT PROVIDED)\n")
    else:
        for batsppfile in batspp_array:
            bats_from_batspp = batsppfile.replace(BATSPP, BATS)
            output_from_batspp = batsppfile.replace(BATSPP, OUTPUTPP)
            txt_from_batspp = batsppfile.replace(BATSPP, TXT)
            test_extensionless = gh.remove_extension(batsppfile, BATSPP)
            is_batspp = batsppfile.endswith(BATSPP)

            if not is_batspp:
                debug.trace(4, f"Ignoring non-batspp file {batsppfile}")
                continue
            print(f"\nBATSPP FILE DETECTED [{i}]: {batsppfile} => {bats_from_batspp}\n")
            i += 1

            if TXT_OPTION:
                bats_output = run_batspp(
                    f"./{BATSPP_STORE}/{batsppfile}",
                    f"./{BATSPP_OUTPUT_STORE}/{output_from_batspp}",
                )

                ## OLD: output_lines = gh.read_lines(f"./{BATSPP_OUTPUT_STORE}/{output_from_batspp}")
                output_lines = bats_output.splitlines()
                output_lines_filtered = [
                    item for item in output_lines if not item.startswith("#")
                ]
                debug.trace_expr(5, output_lines_filtered)
                if output_lines_filtered:
                    # Ignore the line given the number of tests (e.g., "1..5")
                    header_line = output_lines_filtered.pop(0)
                    print(header_line)
                    debug.assertion(my_re.search(r"^1\.\.\d+", header_line))
                debug.assertion(len(output_lines_filtered))

                ## BAD: count_total = len(output_lines_filtered)
                count_ok = len(
                    [item for item in output_lines_filtered if item.startswith("ok")]
                )
                count_bad = len(
                    [
                        item
                        for item in output_lines_filtered
                        if item.startswith("not ok")
                    ]
                )
                count_total = count_ok + count_bad
                count_success_rate = (
                    round((count_ok / count_total) * 100, 2) if count_total else 0
                )
                count_success_rate_bool = count_success_rate >= 50
                debug.trace_expr(
                    4,
                    count_ok,
                    count_bad,
                    count_total,
                    count_success_rate,
                    count_success_rate_bool,
                )
                SUMMARY_TEXT = f"{count_ok} out of {count_total} successful ({count_success_rate}%)\nSuccess: {count_success_rate_bool}"  # pylint: disable=invalid-name
                gh.write_file(f"./{TXT_STORE}/{txt_from_batspp}", SUMMARY_TEXT)
                print(f"{test_extensionless}: {SUMMARY_TEXT}")

                # Categorizing Tests if they are successful or not
                txt_option_JSON = {}  # pylint: disable=invalid-name
                txt_option_JSON["test_name"] = test_extensionless
                txt_option_JSON["test_success_rate"] = count_success_rate
                if count_success_rate_bool:
                    success_test_array.append(txt_option_JSON)
                else:
                    failure_test_array.append(txt_option_JSON)

            else:
                run_batspp(
                    f"./{BATSPP_STORE}/{batsppfile}",
                    f"./{BATS_STORE}/{bats_from_batspp}",
                )
                gh.run(
                    f"kcov ./{KCOV_STORE}/{test_extensionless} bats ./{BATS_STORE}/{bats_from_batspp}"
                )

                if KCOV_OPTION:
                    KCOV_MESSAGE = (  # pylint: disable=invalid-name
                        f"KCOV REPORT PATH: ./{KCOV_STORE}/{test_extensionless}/"
                    )
                    print(gh.indent(KCOV_MESSAGE, indentation="  >>  ", max_width=512))
                    gh.run(
                        f"kcov ./{KCOV_STORE}/{test_extensionless} bats ./{BATS_STORE}/{bats_from_batspp}"
                    )

        batspp_count = i - 1

    # 4) Mentioning any errors in ipynb testfiles
    working_testfiles = []
    sucess_test_array_sort = sorted(
        success_test_array, key=lambda x: x["test_success_rate"], reverse=True
    )  # pylint: disable=invalid-name
    failure_test_array_sort = sorted(
        failure_test_array, key=lambda x: x["test_success_rate"], reverse=True
    )  # pylint: disable=invalid-name
    for file in batspp_array:
        is_batspp = file.endswith(BATSPP)

        if is_batspp:
            ipynb_to_batspp_check = [file.replace(".batspp", ".ipynb")]
            working_testfiles += ipynb_to_batspp_check

    # 5) Summary Statistics
    set_wt = set(working_testfiles)
    error_testfiles = [
        test_file for test_file in ipynb_array if test_file not in set_wt
    ]
    faulty_count = ipynb_count - batspp_count

    print(f"\n======================================================")
    print(f"SUMMARY STATISTICS:\n")
    print(f"simple_batspp.py used: {bool(BATSPP_SWITCH_OPTION)}")
    print(f"No. of IPYNB testfiles: {ipynb_count + avoid_count}")
    print(
        f"No. of BATSPP files (generated): {batspp_count if TXT_OPTION or NO_OPTION != 1 else 'NaN'}"
    )
    print(
        f"No. of FAULTY testfiles: {faulty_count if TXT_OPTION or NO_OPTION != 1 else 'NaN'}"
    )
    print(f"No. of AVOIDED testfiles: {avoid_count}")

    print(f"\nFAULTY TESTFILES:")
    if faulty_count == 0:
        print("NaN")
    else:
        for test_file in error_testfiles:
            print(f">> {test_file}")

    print("\nAVOIDED TESTFILES:")
    if avoid_count == 0:
        print("NaN")
    else:
        for test_file in avoid_array:
            print(f">> {test_file}")

    if TXT_OPTION:
        print("\nTEST SUCCESS (--txt ENABLED):")
        print("No. of Successful Tests (>= 50%):", len(success_test_array))
        print("No. of Failure Tests (< 50%):", len(failure_test_array))

        def print_test_array(arr):
            """Print summary of test results in ARR"""
            for index, item in enumerate(arr):
                print(
                    f"{index + 1}. {item['test_name']} ({item['test_success_rate']}%)"
                )

        print("\nSuccessful Tests:\n---------------------")
        print_test_array(sucess_test_array_sort)
        print("\nFailure Tests:\n---------------------")
        print_test_array(failure_test_array_sort)

    print(f"======================================================")


# -------------------------------------------------------------------------------

if __name__ == "__main__":
    debug.trace_current_context(level=TL.QUITE_DETAILED)
    main()
