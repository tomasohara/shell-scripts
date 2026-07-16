# Agent Instructions

AI agent instructions for arbitrary repos. This is based on instructions designed for Python, so adapt it accordingly to Bash code, etc.

## Key Conventions

*   **Style**:
    *   **Do NOT use Black**. It is explicitly blacklisted for regular use as too opinionated.
		Exceptions are for when re-factoring code or during separate code normalization.
    *   Pylint is used with specific exclusions handled via command-line arguments or aliases (not a config file).
	    Make sure python-lint alias lists no issues: use pylint if alias not defined.
    *   Code style is "R&D focused" rather than strict "Pythonic production" code.
	    Nonetheless, use good software engineering practices, such as using single return calls and adding sanity checks via assert (preferably debug.assertion).
	*   Make sure the code is well documented with a focus on capturing intention rather than describing the low-level implementation details. The model header should provide sufficient detail of the context (e.g., via pointers to Wikipedia), so that documentation for classes and functions can focus on the implementation specifics. Lastly, the code comments should be more like guideposts to facilitate skimming.
	    <!-- TODO2: add specific examples to clarify the types of documentation expected -->
	. For example, 
	*   Use defensive programming such as via debug-only sanity checks and ample tracing:
	    see usages of debug.assertion and debug.trace (e.g., see trace level conventions below).
	*   Readability is important. For example, make sure dynamic imports are not buried without an indication that used at top (e.g., via comment in modules section).
	* Similarly, make sure all functions and methods use docstrings. They can be brief for inherited methods.
*   **License**: Code is licensed under **LGPLv3**.
*   **Imports**: The package is designed to be installed or used with `PYTHONPATH` set to include the root directory (handled automatically by `run_tests.bash`).

## General code agent guidelines

0. Review the main modules first and follow the conventions there:
   debug, html_utils, main, my_regex, system, glue_helpers, template

0. Add or revise tests whenever making non-trivial changes. In addition, when
   revising tests don't remove @xfail tags without confirmation.

0. Similarly for when adding tests, review the following:
   unittest_wrapper, tests/template.py, tests/test_debug, tests/test_system, etc.

0. Retain the existing code as much as possible. In particular, don't remove TODO comments that address the change you are making. 

0. Avoid pre-function comments in Python and similar languages: place them below the docstring.

0. Don't delete code without explicit confirmation. Instead, comment it out and add a block prefix of '## OLD:' as follows (n.b., only one OLD per block):

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

Some variations follow. For single-line changes, just use "## OLD: statement ..." (i.e., one comment not two). When fixing bugs, it is good to replace '## OLD' with '## BAD'. This way, the code can be reviewed later to help derive new tests.

0. When making significant changes, create a new git branch based on development, using a task-specific name such as 'refine-type-hints' or 'fix-poe-client'. The intention is to minimize conflicts without a proliferation of miscellaneous branches.

0. After making a group of commits, push the changes and make sure the remove upstream branch gets set. In general, the remote should be kept updated except when testing tentative changes locally.

0. Don't make edits outside of code directory without confirmation.

0. Don't check-in code without permission (e.g., get confirmation before making commits): I wish to review code before updating git.

0. Don't do any code refactoring without confirmation.

0. Similarly, don't address TODO notes without confirmation.

0. In general, wait for me to assign a task. I will explicitly ask for suggested code changes.

0. When making changes, try to keep the code differences from the previous version as minimal as
possible. This will facilitate reviewed the code. When the requested change requires a substantial
revision, request clarification about how to proceed.

0. Follow the repo code conventions:
   * Avoid putting function definitions inside of other code (e.g., use bottom for Perl and top for Python). Exceptions would be for small functions incorporating context (e.g., sorting helper function).
   * Use full extension names (e.g., ".perl" instead of ".pl").

0. Name temporary files with leading `_` (e.g., `_test_regex.perl`).

0. Make sure your in-line code comments abstract from the implementation to cover intention. If needed,
   added separate comments with special implementation notes.
 
   # Merge and sort the input data
   # note: currently uses simple merge sort
   my_merge(list1, list2)

0. Avoid embedded functions except in cases requiring local context: this facilitates testing.

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

Similarly, add something like this via a inline comment in the source you modify. If
the changes are substantial, add a section to the module header as well.
