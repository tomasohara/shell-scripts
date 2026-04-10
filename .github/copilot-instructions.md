# Copilot Instructions for Mezcla

This repository contains miscellaneous Python scripts and utilities for R&D.

## Build, Test, and Lint Commands

### Testing
The primary test runner is a Bash script that wraps `pytest` and a custom test runner.

*   **Run all tests**:
    ```bash
    ./run_tests.bash
    ```
*   **Run specific tests**:
    Use the `TEST_REGEX` environment variable to filter tests by name.
    ```bash
    TEST_REGEX='audio' ./run_tests.bash
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
    *   **Do NOT use Black**. It is explicitly blacklisted.
    *   Pylint is used with specific exclusions handled via command-line arguments or aliases (not a config file).
    *   Code style is "R&D focused" rather than strict "Pythonic production" code.
*   **License**: Code is licensed under **LGPLv3**.
*   **Imports**: The package is designed to be installed or used with `PYTHONPATH` set to include the root directory (handled automatically by `run_tests.bash`).

## General code agent guidelines

0. Review the main modules first and follow the conventions there:
   debug, html_utils, main, my_regex, system, glue_helpers, unittest_wrapper

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
