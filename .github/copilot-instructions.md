# Copilot Instructions for Mezcla

This repository contains miscellaneous Python scripts and utilities for R&D.

## Build, Test, and Lint Commands

### Testing
The primary test runner is a Bash script that wraps `pytest` and a custom test runner.
Normally, you only need to run tests for modules that you change; however, if the
changes are to core modules like main.py or system.py, it is best to rerun 
all tests.

*   **Run specific tests**:
    Use the `TEST_REGEX` environment variable to filter tests by name.
    ```bash
    TEST_REGEX='audio' ./run_tests.bash
    ```

*   **Run all tests**:
    ```bash
    ./run_tests.bash
    ```

*   **Environment Variables**:
    *   `DEBUG_LEVEL`: Integer (0-6) for verbosity.
    *   `TRACE`: Set to `1` for `set -o xtrace`.
    *   `DRY_RUN`: Set to `1` to show commands without executing.
    *   `INVOKE_PYTEST_DIRECTLY`: Set to `1` to bypass the custom wrapper.

### Documentation
Documentation is built with Sphinx.
*   **Build HTML docs**:
    ```bash
    cd docs && make html
    ```

### Packaging
*   Legacy setup: `setup.py`
*   Modern setup: `pyproject.toml` (uses Poetry/Flit hybrid approach).

## High-Level Architecture

*   **`mezcla/`**: The main package containing utility modules.
    *   Modules range from text processing (`text_utils.py`, `tfidf/`) to audio (`audio.py`) and ML (`keras_param_search.py`).
*   **`mezcla/tests/`**: Unit tests for the package.
*   **`mezcla/examples/`**: Example usage scripts.
*   **`tools/`**: Helper scripts for maintenance and testing (e.g., `run_tests.bash`).

## Key Conventions

*   **Style**:
    *   **Do NOT use Black**. It is explicitly blacklisted for regular use as too opinionated.
		Exceptions are for when re-factoring code or during separate code normalization.
    *   Pylint is used with specific exclusions handled via command-line arguments or aliases (not a config file).
	    Make sure python-lint alias lists no issues: use pylint if alias not defined.
    *   Code style is "R&D focused" rather than strict "Pythonic production" code.
	    Nonetheless, use good software engineering practices, such as using single return calls and adding sanity checks via assert (preferably debug.assertion).
	*   Use defensive programming such as via debug-only sanity checks and ample tracing:
	    see usages of debug.assertion and debug.trace (e.g., see trace level conventions below).
	*   Readability is important. For example, make sure dynamic imports are not buried without an indication that used at top (e.g., via comment in modules section).
	* Similarly, make sure all functions and methods use docstrings. They can be brief for inherited methods.
*   **License**: Code is licensed under **LGPLv3**.
*   **Imports**: The package is designed to be installed or used with `PYTHONPATH` set to include the root directory (handled automatically by `run_tests.bash`).

## General code agent guidelines

0. Review the main modules first and follow the conventions there:
   debug, html_utils, main, my_regex, system, glue_helpers, template

1. Similarly for when adding tests, review the following:
   unittest_wrapper, tests/template.py, tests/test_debug, tests/test_system, etc.

0. Retain the existing code as much as possible. In particular, don't remove TODO comments that address the change you are making. 

0. Don't delete code without explicit confirmation. Instead, comment out the code with '## OLD:' block
as follows:

	```
	num /= sum
	print(num)
	
	   =>
	
	## OLD: 
	## num / sum
	## print(num)
	if num > 0: 
		num /= sum
		print(sum)
	else:
		print(f"Error: unexpected condition with {num=} {sum=}")
	```

Of course, this can be awkward for in-depth changes so ask for clarification.

Some variations follow. For single-line changes, just use "## OLD: ...". When fixing bugs, it is good to replace '## OLD' with '## BAD'. This way, the code can be reviewed later to help derive new tests.

0. When making most changes, create a new git branch based on development, using a name such as 'code-conversion'.

0. After making a group of commits, push the changes and make sure the remove upstream branch gets set.

0. Don't make edits outside of code directory without confirmation.

0. Don't check-in code without permission. I wish to review code before updating git.

0. Don't do any code refactoring without confirmation.

0. Similarly, don't address TODO notes without confirmation.

0. In general, wait for me to assign a task. I will explicitly ask for suggested code changes.

0. When making changes, try to keep the code differences from the previous version as minimal as
possible. This will facilitate reviewed the code. When the requested change requires a substantial
revision, request clarification about how to proceed.

## Debug level conventions

```
Try to use trace level values according to following tips (via debug.py):
    ALWAYS = 0              # no filtering; added mainly for completeness
    ERROR = 1               # definite errors; typically shown
    WARNING = 2             # possible errors; typically shown
    DEFAULT = WARNING       # by default just warnings and errors
    USUAL = 3               # usual in sense of debugging purposes
    DETAILED = 4            # info useful for flow of control, etc.
    VERBOSE = 5             # useful stuff for debugging
    QUITE_DETAILED = 6      # detailed I/O
    QUITE_VERBOSE = 7       # usually for I/O, etc. by helper functions
    MOST_DETAILED = 8       # for high-frequency helpers like to_float
    MOST_VERBOSE = 9        # for internal debugging
```

Basically, levels up to 4 are for usual execution, whereas 5+ are for debugging proper.

## Attribution

When making git commits, add a mention that the change was facilitated by yourself. Ideally, this would include the model and any settings is applicable. For example,

```
	Added new widget to the main page.
	Change faciliated by Acme AI Assistant using model X123.
```

Similary, add something like this regarding non-trivial code revisions in the module header block.
