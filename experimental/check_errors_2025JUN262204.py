#! /usr/bin/env python
#
# check_errors.py: Scan the error log for errors, warnings and other
# suspicious results. This prints the offending line bracketted by >>>
# and <<< along with N lines before and after to provide context.
#
# NOTE:
# - To facilitate testing this and other scripts converted from Perl,
#   the environment variable PERL_SWITCH_PARSING can be used (see main.py).
#
# TODO:
# - ** Have option to disable line number
# - * Change 'error' in filename test as warning.
# - * Fix comments to reflect Python option spec. (e.g., -opt => --opt).
# - Update overview comments to reflect current version.
# - Don't reproduce lines in case of overlapping context regions.
# - Have option to make search case-insensitive.
# - Add option to show which case is being violated (since context display can be confusing, especially when control characters occur in context [as with output form linux script command]).
# - Convert into python.
# - Have option to skip filenames in input.
# - Add codes for error types for convenient filtering (a la pylint).
#

"""
Scan the error log for errors, warnings and other suspicious results.
This prints the offending line bracketted by >>> and <<< along with N
lines before and after to provide context.

ex: check_errors.py whatever

Notes:
- The default context is 1
- Warnings are skipped by default
- Use -no_asterisks if input uses ***'s outside of error contexts
- Use -relaxed to exclude special cases (e.g., xyz='error')
"""

# Standard packages
import re

# Local packages
from mezcla.main import Main
from mezcla import debug
from mezcla import system

# Command-line labels constants
WARNING       = 'warning'       # alias for -warnings
WARNINGS      = 'warnings'      # include warnings?
SKIP_WARNINGS = 'skip-warnings' # omit warnings?
CONTEXT       = 'context'       # context lines before and after
NO_ASTERISKS  = 'no-asterisks'  # skip warnings for '***' in text
RUBY          = 'ruby'          # alias for -skip_ruby_lib
SKIP_RUBY_LIB = 'skip-ruby-lib' # skip Ruby library related errors
RELAXED       = 'relaxed'       # relaxed for special cases
STRICT        = 'strict'        # alias for relaxed=0
VERBOSE       = 'verbose'       # show more details

# Phase1/Perl options for compatibility (addon, not replacement)
QUIET         = 'quiet'         # suppress output
MATCHING      = 'matching'      # show text from regex match
INFO          = 'info'          # show informative messages
BEFORE        = 'before'        # lines before error
AFTER         = 'after'         # lines after error

# Perl-style NULL for explicit null byte handling
NULL = "\0"

class CheckErrors(Main):
    """Scan the error log for errors, warnings and other suspicious results"""

    # class-level member variables for arguments (avoids need for class constructor)
    show_warnings = False
    context       = 0
    asterisks     = False
    skip_ruby_lib = False
    strict        = False
    verbose       = False

    # Global State
    line_number    = 0
    before_context = [] # prior context
    after          = 0  # number of more after-context lines

    # Phase1/Perl additional state (addon, not replacement)
    quiet          = False
    matching       = False
    before         = None
    after_lines    = 0
    info           = False

    # Perl-style error_patterns array (addon, not replacement)
    ERROR_PATTERNS = [
        (re.compile(r'^\s*(Error)\b', re.IGNORECASE), "E2"),
        (re.compile(r'\b(ERROR):', re.IGNORECASE), "E1"),
        (re.compile(r'\b(ERROR)\b', re.IGNORECASE), "E2"),
        (re.compile(r'command not found'), "E2"),
        (re.compile(r'(^|\s)[A-Z]\S+Error(\s|:|$)'), "E2"),
        (re.compile(r'socket has failed to (bind|listen)'), "E2"),
    ]

    def __init__(self, *args, **kwargs):
        # Call parent constructor
        super().__init__(*args, **kwargs)
        # Compile known error patterns with IGNORECASE for faithful Perl matching
        self.known_errors_re = re.compile(
            r'^(ERROR|Error)\b|No space|Segmentation fault|Assertion failed|Assertion .* failed|Floating exception|'
            r'Can\'t execute|Can\'t locate|Word too long|Arg list too long|Badly placed|Expression Syntax|'
            r'No such file or directory|Illegal variable name|Unmatched [\"\']\.|Bad : modifier in|Syntax Error|'
            r'Too many (\(|\)|arguments)|illegal option|Missing name for redirect|Variable name must contain|'
            r'unexpected EOF|unexpected end of file|command not found|^sh: |\[Errno \d+\]|'
            r'^\S+: Undefined variable|Invalid conversion in printf|Execution .* aborted|used only once: possible typo|'
            r'Use of uninitialized|Undefined subroutine|Reference found where even-sized list expected|Out of memory|'
            r'Unmatched .* in regex|at .*\.(perl|prl|pl|pm) line \d+|'
            r'(Make|Dependency) .* failed|cannot open|cannot find|:( fatal)? error |'
            r'^Exception\b|: undefined\b|\(\S+Error\)|Exception.*at.*\.rb|'
            r'^Traceback|^\S+Error|\bunable to remap\b|wn: invalid search',
            re.IGNORECASE
        )
        self.known_errors_ignorecase_re = re.compile(
            r'command not found|permission denied|:\s*error\s*:|^FAILED\b',
            re.IGNORECASE
        )

    def setup(self):
        """Process arguments"""

        # Check the command-line options
        warnings           = self.has_parsed_option(WARNING) or self.has_parsed_option(WARNINGS)
        skip_warnings      = self.has_parsed_option(SKIP_WARNINGS) or not warnings
        self.show_warnings = not skip_warnings
        self.context       = self.get_parsed_option(CONTEXT, 3)
        self.asterisks     = not self.has_parsed_option(NO_ASTERISKS)
        self.skip_ruby_lib = self.has_parsed_option(RUBY) or self.has_parsed_option(SKIP_RUBY_LIB)
        self.strict        = self.has_parsed_option(STRICT) or not self.has_parsed_option(RELAXED)
        self.verbose       = self.has_parsed_option(VERBOSE)
        debug.trace_object(5, self, label="Script instance")

        # Phase1/Perl/mezcla options
        self.quiet    = self.has_parsed_option(QUIET)
        self.matching = self.has_parsed_option(MATCHING)
        self.before   = self.get_parsed_option(BEFORE, None)
        self.after    = self.get_parsed_option(AFTER, None)
        self.info     = self.has_parsed_option(INFO)
        # Set defaults as in Perl if not set
        if self.before is None:
            self.before = self.context
        if self.after is None:
            self.after = self.context
        self.after_lines = 0   # reset after_lines for new run

        # self.known_errors_re and self.known_errors_ignorecase_re are now defined in __init__

    def process_line(self, line):
        """Process each line of the input stream"""
        self.line_number += 1
        line = system.chomp(line)

        debug.trace(debug.QUITE_DETAILED, f'current line: {line}')

        has_error = False # whether line has error

        # Check for error log corruption
        if self.show_warnings and re.search('\0', line):
            has_error = True
            line = re.sub('\0', '^@', line)
            debug.trace(debug.QUITE_VERBOSE, f"1. has_error={int(has_error)}")

        # Check for known errors
        if not has_error and (self.known_errors_re.search(line) or self.known_errors_ignorecase_re.search(line)):
            has_error = True
            debug.trace(debug.QUITE_VERBOSE, f"2. has_error={int(has_error)}")

        # Phase1/Perl error_patterns logic (addon, not replacement)
        match_info = ""
        if not has_error:
            for regex, label in self.ERROR_PATTERNS:
                if regex.pattern == r'command not found':
                    if regex.search(line) and not re.search(r'Cannot switch to Modules', line):
                        has_error = True
                        match_info = f"{label} [{regex.search(line).group(0)}]"
                        break
                elif regex.pattern == r'(^|\s)[A-Z]\S+Error(\s|:|$)':
                    m = regex.search(line)
                    if m:
                        blacklist = re.compile(r'BrokenPipeError|SillyPythonException')
                        if self.strict or not blacklist.search(line):
                            has_error = True
                            match_info = f"{label} [{m.group(0)}]"
                            break
                else:
                    m = regex.search(line)
                    if m:
                        has_error = True
                        match_info = f"{label} [{m.group(0)}]"
                        break
            if has_error:
                debug.trace(debug.QUITE_VERBOSE, f"NEW array-based error match: has_error={int(has_error)}")

        # Check for warnings and starred messages
        if  (not has_error and self.show_warnings and
             ((re.search(r'\b(warning)\b', line, flags=re.IGNORECASE) and
               ((not re.search("='warning'", line, flags=re.IGNORECASE)) or self.strict)) or
              (re.search(r'\b(error)\b', line, flags=re.IGNORECASE) and
               ((not re.search("='error'", line, flags=re.IGNORECASE)) or self.strict)) or
              re.search(': No match', line) or
              re.search(r': warning\b', line) or
              re.search('^bash: ', line) or
              re.search('Traceback|\\S+Error', line) or
              (self.asterisks and re.search('\\*\\*\\*', line)))):
            has_error = True
            debug.trace(debug.QUITE_VERBOSE, f"3. has_error={int(has_error)}")

        # Additional warning/informative/strict context from 1:1 Perl conversion
        elif not has_error and self.info:
            m1 = re.search(r'\bFYI:', line, re.IGNORECASE)
            m2 = re.search(r'information', line, re.IGNORECASE)
            if m1 or m2:
                has_error = True
                m = m1 if m1 else m2
                match_info = f"I1 [{m.group(0)}]"
                debug.trace(debug.QUITE_VERBOSE, f"4. has_error={int(has_error)}")

        # Filter certain cases (e.g., posthoc fixup)
        if has_error and self.skip_ruby_lib and re.search('\\/usr\\/lib\\/ruby', line):
            debug.trace(debug.DETAILED, f'Skipping ruby library error at line ({line})')
            debug.trace(debug.QUITE_VERBOSE, f"4. has_error={int(has_error)}")
            has_error = False

        # If an error, then display line preceded by pre-context
        debug.trace(debug.QUITE_VERBOSE, f"final has_error={int(has_error)}")
        if has_error:
            # Show up the N preceding context lines, unless there is an overlap
            num = 0 if self.after_lines > 0 else len(self.before_context)
            for idx in range(num):
                ctx_num = self.line_number - (num - idx)
                ctx_line = self.before_context[idx]
                print(f"{str(ctx_num).ljust(4)}     {ctx_line}")
            print(f"{str(self.line_number).ljust(4)} >>> {line} <<<")
            if self.matching:
                print(match_info)
            self.after_lines = self.after

        # Otherwise print line only if in the post-context
        else:
            if self.after_lines > 0:
                print(f"{str(self.line_number).ljust(4)}     {line}")
                if self.after_lines == 1:
                    print('')
                self.after_lines -= 1

        # Update the context
        self.before_context = system.append_new(self.before_context, line)
        if (len(self.before_context) - 1) == self.before:
            del self.before_context[0]

    def wrap_up(self):
        """End processing"""
        if self.verbose:
            print('')

if __name__ == '__main__':
    app = CheckErrors(description     = __doc__,
                      boolean_options = [(WARNING,       'alias for -warnings'),
                                         (WARNINGS,      'include warnings?'),
                                         (SKIP_WARNINGS, 'omit warnings?'),
                                         (NO_ASTERISKS,  'skip warnings for "***" in text'),
                                         (RUBY,          'alias for -skip_ruby_lib'),
                                         (SKIP_RUBY_LIB, 'skip Ruby library related errors'),
                                         (RELAXED,       'relaxed for special cases'),
                                         (STRICT,        'alias for relaxed=0'),
                                         (VERBOSE,       'show more details'),
                                         (QUIET,         'suppress output'),
                                         (MATCHING,      'show text from regex match'),
                                         (INFO,          'show informative messages'),],
                      int_options     = [(CONTEXT,       'context lines before and after'),
                                         (BEFORE,        'lines before error'),
                                         (AFTER,         'lines after error'),])
    app.run()