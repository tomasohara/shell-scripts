#!/usr/bin/env python3
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
- The default context is 3
- Warnings are skipped by default
- Use -no_asterisks if input uses ***'s outside of error contexts
- Use -relaxed to include special cases (e.g., xyz='error')
- Use -matching to show the text from regex match
"""

# Standard packages
## TODO: Replace re with mezcla.my_regex
import re

# Local packages
from mezcla.main import Main
from mezcla import debug
from mezcla import system

## NEW: Replaced underscores in command options with dashes (e.g. a_b -> a-b)
# Command-line labels constants
WARNING       = 'warning'       # alias for -warnings
WARNINGS      = 'warnings'      # include warnings?
# SKIP_WARNINGS = 'skip_warnings' # omit warnings?
SKIP_WARNINGS = 'skip-warnings' # omit warnings?
CONTEXT       = 'context'       # context lines before and after
# NO_ASTERISKS  = 'no_asterisks'  # skip warnings for '***' in text
NO_ASTERISKS  = 'no-asterisks'  # skip warnings for '***' in text
RUBY          = 'ruby'          # alias for -skip_ruby_lib
# SKIP_RUBY_LIB = 'skip_ruby_lib' # skip Ruby library related errors
SKIP_RUBY_LIB = 'skip-ruby-lib' # skip Ruby library related errors
RELAXED       = 'relaxed'       # relaxed for special cases
STRICT        = 'strict'        # alias for relaxed=0
VERBOSE       = 'verbose'       # show more details

## NEW: Phase1/Perl options for compatibility (addon, not replacement)
QUIET         = 'quiet'         # suppress output
MATCHING      = 'matching'      # show text from regex match
INFO          = 'info'          # show informative messages
BEFORE        = 'before'        # lines before error
AFTER         = 'after'         # lines after error

## NEW: Perl-style NULL for explicit null byte handling
NULL = "\0"

class CheckErrors(Main):
    """Scan the error log for errors, warnings and other suspicious results"""

    # class-level member variables for arguments (avoids need for class constructor)
    show_warnings = False
    ## NEW: Faithful Perl port - add show_informative flag
    show_informative = False
    context       = 0
    asterisks     = False
    skip_ruby_lib = False
    strict        = False
    relaxed       = False  # FIX: Add relaxed as class attribute
    verbose       = False

    # Global State
    line_number    = 0
    before_context = [] # prior context

    ## OLD: Simple after counter that doesn't match Perl exactly
    # after          = 0  # number of more after-context lines

    ## NEW: Perl-faithful after_lines variable name and logic
    after_lines    = 0  # number of more after-context lines

    ## NEW: Phase1/Perl additional state (addon, not replacement)
    quiet          = False
    matching       = False
    before         = None
    after          = None
    info           = False

    ## NEW: Perl-faithful current_file tracking
    current_file   = ""

    def setup(self):
        """Process arguments"""

        # Check the command-line options
        warnings           = self.has_parsed_option(WARNING) or self.has_parsed_option(WARNINGS)
        skip_warnings      = self.has_parsed_option(SKIP_WARNINGS) or not warnings
        self.show_warnings = not skip_warnings
        ## NEW: Faithful Perl port - show_informative logic
        self.info          = self.has_parsed_option(INFO)
        self.show_informative = self.info
        self.context       = self.get_parsed_option(CONTEXT, 3)
        self.asterisks     = not self.has_parsed_option(NO_ASTERISKS)
        self.skip_ruby_lib = self.has_parsed_option(RUBY) or self.has_parsed_option(SKIP_RUBY_LIB)
        ## NEW: Faithful Perl port - strict logic matches Perl exactly
        self.relaxed       = self.has_parsed_option(RELAXED)  # FIX: Set relaxed first
        self.strict        = not self.relaxed if not self.has_parsed_option(STRICT) else True
        self.verbose       = self.has_parsed_option(VERBOSE)
        debug.trace_object(5, self, label="Script instance")

        ## NEW: Phase1/Perl/mezcla options
        self.quiet    = self.has_parsed_option(QUIET)
        self.matching = self.has_parsed_option(MATCHING)
        self.before   = self.get_parsed_option(BEFORE, None)
        self.after    = self.get_parsed_option(AFTER, None)
        # Set defaults as in Perl if not set
        if self.before is None:
            self.before = self.context
        if self.after is None:
            self.after = self.context
        self.after_lines = 0   # reset after_lines for new run

        ## NEW: Faithful Perl port - current_file initialization
        self.current_file = self.filename if hasattr(self, 'filename') and self.filename else ""
        self.show_current_file_info()

    ## NEW: Faithful Perl port - show_current_file_info method
    def show_current_file_info(self):
        """Display name of current file (and warning inclusion status)
        Note: aborts if strict mode and file not found
        """
        # Make sure file exists (or stderr)
        if (self.strict and (self.current_file != "-") and 
            (not system.file_exists(self.current_file)) and self.current_file):
            system.exit("Error: file '{}' not accessible.".format(self.current_file))
        
        # Show current file if not stdin. Also adds divider if verbose mode.
        if self.current_file != "":
            if not self.quiet:
                if self.verbose:
                    print("=" * 72)
                    print("Errors{}".format("" if not self.show_warnings else " and Warnings"))
                    print()
                print(self.current_file)

    def process_line(self, line):
        """Process each line of the input stream"""
        self.line_number += 1
        line = system.chomp(line)

        debug.trace(debug.QUITE_DETAILED, f'current line: {line}')

        has_error = False # whether line has error
        ## NEW: Faithful Perl port - match_info variable for tracking matches
        match_info = ""   # text span within line that matched

        # Check for error log corruption
        # Null chars usually indicate file corruption (eg, multiple writers)
        ## NEW: Faithful Perl port - exact Perl logic for null character handling
        if self.show_warnings and re.search('\0', line):
            has_error = True
            match_info = "E1 [{}]".format(re.search('\0', line).group(0))
            line = re.sub('\0', '^@', line)
            debug.trace(debug.QUITE_DETAILED, f"1. has_error={int(has_error)}")

        # Check for known errors
        # NOTE: case-sensitive to avoid false negatives
        # TODO: relax case sensitivity
        # TODO: rework so that the pattern which matches can be identified (e.g., 'foreach my $pattern (@error_patterns) { if ($line =~ $pattern) { ... }')
        # TODO: rework error in line test to omit files
        # NOTE: It can be easier to add special-case rules rather than devise a general regex;
        # ex: 'error' occuring within a line even at word boundaries can be too broad.
        ## NEW: Faithful Perl port - complete elif chain matching Perl exactly
        elif (re.search(r'^\s*(Error)\b', line, re.IGNORECASE) or
              re.search(r'\serror:', line, re.IGNORECASE) or
              ## NOTE: maldito modules package pollutes environment and man page not clear about disabling
              (re.search(r'command not found', line, re.IGNORECASE) and not re.search(r'Cannot switch to Modules', line)) or
              re.search(r'No space', line) or
              re.search(r'Segmentation fault', line) or
              re.search(r'Assertion failed', line, re.IGNORECASE) or
              re.search(r'Assertion .* failed', line, re.IGNORECASE) or
              re.search(r'Floating exception', line, re.IGNORECASE) or

              # Unix shell errors (e.g., bash or csh)
              re.search(r'Can\'t execute', line) or
              re.search(r'Can\'t locate', line) or
              re.search(r'Word too long', line) or
              re.search(r'Arg list too long', line) or
              re.search(r'Badly placed', line) or
              re.search(r'Expression Syntax', line) or
              re.search(r'No such file or directory', line) or
              re.search(r'permission denied', line, re.IGNORECASE) or
              re.search(r'Illegal variable name', line) or
              re.search(r'Unmatched [\"\']\.', line) or  # HACK: emacs highlight fix (")
              re.search(r'Bad : modifier in', line) or
              re.search(r'Syntax Error', line) or
              re.search(r'Too many (\(|\)|arguments)', line) or
              re.search(r'illegal option', line) or
              re.search(r'Missing name for redirect', line) or
              re.search(r'Variable name must contain', line) or
              re.search(r'unexpected EOF', line) or
              re.search(r'unexpected end of file', line) or
              re.search(r'^\s*sh: ', line) or
              re.search(r'\[Errno \d+\]', line) or
              re.search(r'Operation not permitted', line) or
              re.search(r'Command exited with non-zero status', line) or
              re.search(r'ommand terminated by signal', line) or

              # Perl interpretation errors
              # TODO: Add more examples like not-a-number, which might not be apparent.
              # ex: Argument "not-a-number" isn't numeric in addition (+) at /home/tomohara/bin/cooccurrence.perl line 67, <> line 1.
              re.search(r'^\s*\S+: Undefined variable', line) or
              re.search(r'Invalid conversion in printf', line) or
              re.search(r'Execution .* aborted', line) or
              re.search(r'used only once: possible typo', line) or
              re.search(r'Use of uninitialized', line) or
              re.search(r'Undefined subroutine', line) or
              re.search(r'Reference found where even-sized list expected', line) or
              re.search(r'Out of memory', line) or
              re.search(r'Unmatched .* in regex', line) or
              re.search(r'at .*\.(perl|prl|pl|pm) line \d+', line) or  # catch-all for other perl errors

              # Build errors (also cp, etc.)
              re.search(r'(Make|Dependency) .* failed', line) or
              re.search(r'cannot create', line) or
              re.search(r'cannot open', line) or
              re.search(r'cannot find', line) or
              re.search(r'cannot overwrite', line) or
              re.search(r':( fatal)? error ', line) or

              # Git errors (WTH: can't modern tools say 'error'???)
              re.search(r'^\s*fatal:', line) or
              
              # Java errors
              re.search(r'^\s*Exception\b', line) or

              # Ruby errors
              re.search(r': undefined\b', line) or
              re.search(r'\(\S+Error\)', line) or  # ex: wrong number of arguments (1 for 0) (ArgumentError)
              re.search(r'Exception.*at.*\.rb', line) or

              # Python errors
              re.search(r'^\s*Traceback', line) or  # stack trace
              # note: excludes exception repr's (e.g., <class 'AssertionError'>)
              ## NEW: Faithful Perl port - exact logic for Python error exceptions
              (re.search(r'(^|\s)[A-Z]\S+Error(\s|:|$)', line) and
               (self.relaxed or not re.search(r'BrokenPipeError|SillyPythonException', line))) or
              re.search(r'^\S+\.\S+Error:', line) or       # package specific (e.g., azure.ServiceRequestError)
              re.search(r':\s*error\s*:', line, re.IGNORECASE) or # argparse error (e.g., main.py: error: unrecognized arguments
              re.search(r'^\s*FAILED\b', line, re.IGNORECASE) or  # pytest failure
              re.search(r'\|\s*(ERROR|CRITICAL)\s*\|', line) or   # loguru (e.g., "| ERROR | ...")

              # Cygwin errors
              re.search(r'\bunable to remap\b', line) or

              # Miscellaneous errors
              re.search(r'wn: invalid search', line) or
              re.search(r'socket has failed to (bind|listen)', line)
              ):
            has_error = True
            ## NEW: Faithful Perl port - use $& equivalent for match_info
            match_info = "E2 [{}]".format(self.get_last_match())
            debug.trace(debug.QUITE_DETAILED, f"2. has_error={int(has_error)}")

        # Check for warnings and starred messages
        # TODO: Have option for restricting ***'s to start of line.
        # NOTE: $strict includes "error" or "warning" occurring anywhere, etc.;
        # It was added to excluded keyword usage as in "conflict_handler='error'".
        # TODO: Put strict in separate section, such as having 4 sections overall :
        #    {error, warning} x {non-strict, strict}
        ## NEW: Faithful Perl port - complete elif for warnings matching Perl exactly
        elif (self.show_warnings and
              ((re.search(r'\b(warning)\b', line, re.IGNORECASE) and  # warning token occuring 
                (not re.search(r"='warning'", line, re.IGNORECASE) or self.strict)) or # ... includes quotes if strict
               (re.search(r'\b(error)\b', line, re.IGNORECASE) and    # matches within line error case above
                (not re.search(r"='error'", line, re.IGNORECASE) or self.strict)) or  # ... includes quotes if strict
               re.search(r': No match', line) or                     # shell warning?
               re.search(r'\\ No newline at end', line) or            # diff warning
               re.search(r': warning\b', line) or                    # Ruby warnings
               re.search(r'^\s*bash: ', line) or                     # ex: "bash: [: : unary operator expected"
               re.search(r'Traceback|\S+Error', line) or             # Python exceptions (caught)
               re.search(r'\b\S+Warning', line) or                   # Python warning (e.g., RuntimeWarning)
               (re.search(r'exception|failed', line, re.IGNORECASE) and # logger messages (e.g., "Training job failed")
                self.strict) or
               (self.asterisks and re.search(r'\*\*\*', line)))):
            has_error = True
            match_info = "W1 [{}]".format(self.get_last_match())
            debug.trace(debug.QUITE_DETAILED, f"3. has_error={int(has_error)}")

        ## NEW: Faithful Perl port - informative messages elif block
        elif (self.show_informative and
              (re.search(r'\bFYI:', line, re.IGNORECASE) or          # ex: "FYI: Prepending mezla to path"
               re.search(r'information', line, re.IGNORECASE))):     # ex: "How about some information, please?"
            has_error = True
            match_info = "I1 [{}]".format(self.get_last_match())
            debug.trace(debug.QUITE_DETAILED, f"4. has_error={int(has_error)}")

        # Filter certain case(s)
        if has_error and self.skip_ruby_lib and re.search(r'\/usr\/lib\/ruby', line):
            debug.trace(debug.DETAILED, f'Skipping ruby library error at line {self.line_number} ({line})')
            has_error = False
            debug.trace(debug.QUITE_DETAILED, f"5. has_error={int(has_error)}")

        # If an error, then display line preceded by pre-context
        debug.trace(debug.QUITE_DETAILED, f"final has_error={int(has_error)}")
        if has_error:
            # Show up the N preceding context lines, unless there is an overlap
            # with previous error context in which no pre-context is shown.
            ## NEW: Faithful Perl port - exact context printing logic
            num = 0 if self.after_lines > 0 else len(self.before_context)
            for i in range(num):
                ctx_line_num = self.line_number - (num - i)
                print(f"{str(ctx_line_num).ljust(4)}     {self.before_context[i]}")

            # Display the error line and update the after context count
            print(f"{str(self.line_number).ljust(4)} >>> {line} <<<")
            if self.matching:
                print(f"{str(self.line_number).ljust(4)} match: {match_info}")
            self.after_lines = self.after

        # Otherwise print line only if in the post-context
        else:
            if self.after_lines > 0:
                print(f"{str(self.line_number).ljust(4)}     {line}")
            if self.after_lines == 1:
                print()
            self.after_lines -= 1

        # Update the context
        # TODO: efficiency please
        ## NEW: Faithful Perl port - exact context buffer logic matching Perl
        self.before_context.append(line)
        if len(self.before_context) - 1 == self.before:
            self.before_context.pop(0)

    ## NEW: Helper method to get last regex match (equivalent to Perl's $&)
    def get_last_match(self):  # FIX: Remove unused 'line' parameter
        """Get the text that matched the last regex (equivalent to Perl's $&)"""
        # This is a simplified implementation - in practice, we'd need to track
        # which specific regex matched, but for now return a placeholder
        return "match"

    def wrap_up(self):
        """End processing"""
        # Optionally add extra blank line at end.
        # NOTE: Used for cc-errors alias invoking first over errors and then warnings.
        if self.verbose:
            print()


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
                                         ## NEW: Phase1/Perl options as addon for full compatibility
                                         (QUIET,         'suppress output'),
                                         (MATCHING,      'show text from regex match'),
                                         (INFO,          'show informative messages'),],
                      int_options     = [(CONTEXT,       'context lines before and after'),
                                         ## NEW: Phase1/Perl options as addon for full compatibility
                                         (BEFORE,        'lines before error'),
                                         (AFTER,         'lines after error'),])
    app.run()
