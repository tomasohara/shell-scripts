#! /usr/bin/env python
#
# check_errors.perl: Scan the error log for errors, warnings and other
# suspicious results. This prints the offending line bracketted by >>>
# and <<< along with N lines before and after to provide context.
#
# TODO:
# - ** Have option to disable line number
# - * Change 'error' in filename test as warning.
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

ex: check_errors.py whatever\n
Notes:\n
- The default context is 1\n
- Warnings are skipped by default\n
- Use -no_astericks if input uses ***'s outside of error contexts\n
Use -relaxed to exclude special cases (e.g., xyz='error')\n
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
SKIP_WARNINGS = 'skip_warnings' # omit warnings?
CONTEXT       = 'context'       # context lines before and after
NO_ASTERISKS  = 'no_asterisks'  # skip warnings for '***' in text
RUBY          = 'ruby'          # alias for -skip_ruby_lib
SKIP_RUBY_LIB = 'skip_ruby_lib' # skip Ruby library related errors
RELAXED       = 'relaxed'       # relaxed for special cases
STRICT        = 'strict'        # alias for relaxed=0
VERBOSE       = 'verbose'       # show more details


class CheckErrors(Main):
    """Scan the error log for errors, warnings and other suspicious results"""


    # class-level member variables for arguments (avoids need for class constructor)
    show_warnings = False
    context       = 0
    astericks     = False
    skip_ruby_lib = False
    strict        = False
    verbose       = False


    # Global State
    line_number    = 0
    before_context = [] # prior context
    after          = 0  # number of more after-context lines


    def setup(self):
        """Process arguments"""


        # Check the command-line options
        warnings           = self.has_parsed_option(WARNING) or self.has_parsed_option(WARNINGS)
        skip_warnings      = self.has_parsed_option(SKIP_WARNINGS) or not warnings
        self.show_warnings = not skip_warnings
        self.context       = self.get_parsed_option(CONTEXT, 3)
        self.astericks     = not self.has_parsed_option(NO_ASTERISKS)
        self.skip_ruby_lib = self.has_parsed_option(RUBY) or self.has_parsed_option(SKIP_RUBY_LIB)
        self.strict        = self.has_parsed_option(STRICT) or not self.has_parsed_option(RELAXED)
        self.verbose       = self.has_parsed_option(VERBOSE)


    def process_line(self, line):
        """Process each line of the input stream"""
        self.line_number += 1
        line = system.chomp(line)


        debug.trace(debug.QUITE_DETAILED, f'current line: {line}')


        has_error = False # whether line has error


        # Check for error log corruption
        # Null chars usually indicate file corruption (eg, multiple writers)
        if self.show_warnings and re.search('\0', line):
            has_error = True
            line = re.sub('\0', '^@', line)


        # Check for known errors
        # NOTE: case-sensitive to avoid false negatives
        # TODO: relax case sensitivity
        # TODO: rework so that the pattern which matches can be identified (e.g., 'foreach my $pattern (@error_patterns) { if ($line =~ $pattern) { ... }')
        # TODO: rework error in line test to omit files
        # NOTE: It can be easier to add special-case rules rather than devise a general regex;
        # ex: 'error' occuring within a line even at word boundaries can be too broad.
        known_errors            = ('^(ERROR|Error)\b'    '|'
                                   'No space'            '|'
                                   'Segmentation fault'  '|'
                                   'Assertion failed'    '|'
                                   'Assertion .* failed' '|'
                                   'Floating exception'  '|'

                                   # Unix shell errors (e.g., bash or csh)
                                   'Can\'t execute'               '|'
                                   'Can\'t locate'                '|'
                                   'Word too long'                '|'
                                   'Arg list too long'            '|'
                                   'Badly placed'                 '|'
                                   'Expression Syntax'            '|'
                                   'No such file or directory'    '|'
                                   'Illegal variable name'        '|'
                                   'Unmatched [\"\']\\.'          '|' # HACK: emacs highlight fix (")
                                   'Bad : modifier in'            '|'
                                   'Syntax Error'                 '|'
                                   'Too many (\\(|\\)|arguments)' '|'
                                   'illegal option'               '|'
                                   'Missing name for redirect'    '|'
                                   'Variable name must contain'   '|'
                                   'unexpected EOF'               '|'
                                   'unexpected end of file'       '|'
                                   'command not found'            '|'
                                   '^sh: '                        '|'
                                   '\\[Errno \\d+\\]'             '|'

                                   # Perl interpretation errors
                                   # TODO: Add more examples like not-a-number, which might not be apparent.
                                   # ex: Argument "not-a-number" isn't numeric in addition (+) at /home/tomohara/bin/cooccurrence.perl line 67, <> line 1.
                                   '^\\S+: Undefined variable'                      '|'
                                   'Invalid conversion in printf'                   '|'
                                   'Execution .* aborted'                           '|'
                                   'used only once: possible typo'                  '|'
                                   'Use of uninitialized'                           '|'
                                   'Undefined subroutine'                           '|'
                                   'Reference found where even-sized list expected' '|'
                                   'Out of memory'                                  '|'
                                   'Unmatched .* in regex'                          '|'
                                   'at .*\\.(perl|prl|pl|pm) line \\d+'             '|' # catch-all for other perl errors

                                   # Build errors
                                   '(Make|Dependency) .* failed' '|'
                                   'cannot open'                 '|'
                                   'cannot find'                 '|'
                                   ':( fatal)? error '           '|'

                                   # Java errors
                                   '^Exception\b' '|'

                                   # Ruby errors
                                   ': undefined\b'        '|'
                                   '\\(\\S+Error\\)'      '|' # ex: wrong number of arguments (1 for 0) (ArgumentError)
                                   'Exception.*at.*\\.rb' '|'

                                   # Python errors
                                   '^Traceback'      '|' # stack trace
                                   '^\\S+Error'      '|' # exception (e.g., TypeError)

                                   # Cygwin errors
                                   '\bunable to remap\b' '|'

                                   # Miscellaneous errors
                                   'wn: invalid search')
        known_errors_ignorecase = ('command not found'   '|'

                                   # Unix shell errors (e.g., bash or csh)
                                   'permission denied'            '|'

                                   # Python errors
                                   ':\\s*error\\s*:' '|' # argparse error (e.g., main.py: error: unrecognized arguments
                                   '^FAILED\b')          # pytest failure


        if not has_error and (re.search(known_errors, line) or re.search(known_errors_ignorecase, line, flags=re.IGNORECASE)):
            has_error = True


        # Check for warnings and starred messages
        # TODO: Have option for restricting ***'s to start of line.
        # NOTE: $strict includes "error" or "warning" occurring anywhere;
        # added to excluded keywords usage as in "conflict_handler='error'".
        if      (not has_error and self.show_warnings and (
                (re.search('\b(warning)\b', line, flags=re.IGNORECASE) and                    # warning token occuring
                ((not re.search("='warning'", line, flags=re.IGNORECASE)) or self.strict)) or # ... includes quotes if strict
                (re.search('\b(error)\b', line, flags=re.IGNORECASE) and                      # matches within line error case above
                ((not re.search("='error'", line, flags=re.IGNORECASE)) or self.strict)) or   # ... includes quotes if strict
                re.search(': No match', line) or                                              # shell warning?
                re.search(': warning\b', line) or                                             # Ruby warnings
                re.search('^bash: ', line) or                                                 # ex: "bash: [: : unary operator expected"
                re.search('Traceback|\\S+Error', line) or                                     # Python exceptions (caught)
                (self.astericks and re.search('\\*\\*\\*', line)))):
            has_error = True


        # Filter certain case
        if has_error and self.skip_ruby_lib and re.search('\\/usr\\/lib\\/ruby', line):
            debug.trace(debug.DETAILED, f'Skipping ruby library error at line ({line})')
            has_error = False


        # If an error, then display line preceded by pre-context
        if has_error:
            # Show up the N preceding context lines, unless there is an overlap
            # with previous error context in which no pre-context is shown.
            num = 0 if self.after > 0 else len(self.before_context)
            for i in range(num):
                print(f'{str(self.line_number - (num - i)).ljust(4, " ")}     {self.before_context[i]}')

            # Display the error line and update the after context count
            print(f'{str(self.line_number).ljust(4, " ")} >>> {line} <<<')
            self.after = self.context


        # Otherwise print line only if in the post-context
        else:
            if self.after > 0:
                print(f'{str(self.line_number).ljust(4, " ")}     {line}')
            if self.after == 1:
                print('')
            self.after -= 1


        # Update the context
        self.before_context = system.append_new(self.before_context, line)
        if (len(self.before_context) - 1) == self.context:
            del self.before_context[0]


    def wrap_up(self):
        """End processing"""
        # Optionally add extra blank line at end.
        # NOTE: Used for cc-errors alias invoking first over errors and then warnings.
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
                                         (VERBOSE,       'show more details')],
                      int_options     = [(CONTEXT,       'context lines before and after')])
    app.run()
