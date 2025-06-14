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

ex: check_errors.py whatever\n
Notes:\n
- The default context is 1\n
- Warnings are skipped by default\n
- Use -no_asterisks if input uses ***'s outside of error contexts\n
Use -relaxed to exclude special cases (e.g., xyz='error')\n
"""


# Standard packages
import re


# Local packages
from mezcla.main import Main
from mezcla import debug
from mezcla import system
## NEW: Added to replace re library
from mezcla.my_regex import my_re

## NEW: Added missing class variables from Perl script
## DERIVED FROM: Perl lines 34-38 
# # Specify additional diagnostics and strict variable usage, excepting those
# for command-line arguments (see init_var's in &init).
# use strict;
# use vars qw/$warning $warnings $skip_warnings $context $no_asterisks $skip_ruby_lib $ruby/;
# use vars qw/$relaxed $strict $quiet $matching $before $after $info/;

# Command-line labels constants
## OLD: No underscores for command line options
# Replaces the options:
# skip_warnings -> skip-warnings
# no_asterisks -> no-asterisks
# skip_ruby_lib -> skip-ruby-lib 

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
INFO          = 'info'          # show informative messages (e.g., FYI's)
BEFORE        = 'before'        # lines of context before error
AFTER         = 'after'         # lines of context after error  
MATCHING      = 'matching'      # show which regex pattern matched
QUIET         = 'quiet'         # suppress filename output, show only errors


class CheckErrors(Main):
    """Scan the error log for errors, warnings and other suspicious results"""


    # class-level member variables for arguments (avoids need for class constructor)
    show_warnings = False
    context       = 0
    asterisks     = False
    skip_ruby_lib = False
    strict        = False
    verbose       = False
    ## NEW: Add these new class variables
    ## DERIVED FROM: Perl lines 56-77 (my($show_warnings), my($show_informative), etc.)
    show_informative = False  # show informative messages
    before_context_lines = 0  # lines of context before error
    after_context_lines = 0   # lines of context after error
    show_matching = False     # show which regex pattern matched
    quiet_mode = False        # suppress filename output


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
        self.asterisks     = not self.has_parsed_option(NO_ASTERISKS)
        self.skip_ruby_lib = self.has_parsed_option(RUBY) or self.has_parsed_option(SKIP_RUBY_LIB)
        self.strict        = self.has_parsed_option(STRICT) or not self.has_parsed_option(RELAXED)
        self.verbose       = self.has_parsed_option(VERBOSE)
        ## NEW: Add missing option parsing lines
        ## DERIVED FROM: Perl lines 61 (my($show_informative) = $info;)
        self.show_informative = self.has_parsed_option(INFO)
        ## DERIVED FROM: Perl lines 63 (&init_var(*before, $context);)
        self.before_context_lines = self.get_parsed_option(BEFORE, self.context)
        ## DERIVED FROM: Perl lines 64(&init_var(*after, $context);)
        self.after_context_lines = self.get_parsed_option(AFTER, self.context)
        ## DERIVED FROM: Perl lines 72(&quiet(*matching, &FALSE);)
        self.quiet_mode = self.has_parsed_option(QUIET)
        ## DERIVED FROM: Perl lines 73(&init_var(*matching, &FALSE);)
        self.show_matching = self.has_parsed_option(MATCHING)
        debug.trace_object(5, self, label="Script instance")


    def process_line(self, line):
        """Process each line of the input stream"""
        self.line_number += 1
        line = system.chomp(line)


        debug.trace(debug.QUITE_DETAILED, f'current line: {line}')


        has_error = False # whether line has error
        ## NEW: Add match_info tracking for -matching option
        ## DERIVED FROM: Perl line 87 (my($match_info) = "";)
        match_info = ""  # text span within line that matched


        # Check for error log corruption
        # Null chars usually indicate file corruption (eg, multiple writers)
        ## OLD: Replaced re with mezcla.my_regex (my_re)
        # if self.show_warnings and re.search('\0', line):
        if self.show_warnings and my_re.search('\0', line):
            has_error = True
            ## NEW: Add match_info for null character detection
            ## DERIVED FROM: Perl line 93 ($match_info = "E1 [$&]";)
            def get_null_match(line):
                return my_re.search(r'\0', line)

            match = get_null_match(line)
            match_info = f"E1 [{match.group() if match else 'NULL'}]"
            ## OLD: Replaced re with mezcla.my_regex (my_re)         
            # line = re.sub('\0', '^@', line)
            line = my_re.sub('\0', '^@', line)
            debug.trace(debug.QUITE_VERBOSE, f"1. has_error={int(has_error)}")


        # Check for known errors
        # NOTE: case-sensitive to avoid false negatives
        # TODO: relax case sensitivity
        # TODO: rework so that the pattern which matches can be identified (e.g., 'foreach my $pattern (@error_patterns) { if ($line =~ $pattern) { ... }')
        # TODO: rework error in line test to omit files
        # NOTE: It can be easier to add special-case rules rather than devise a general regex;
        # ex: 'error' occuring within a line even at word boundaries can be too broad.
        # TODO1: rework so that individual regex's are used as in Perl version
        # Also see https://stackoverflow.com/questions/18842779/string-concatenation-without-operator.
        
        ## NEW: Add complete regex patterns matching Perl version exactly
        ## DERIVED FROM: Perl lines 105-194 (elsif block with all error patterns)
        known_errors            = (r'^(ERROR|Error)\b'   '|' +
                                   r'\serror:'           '|' +
                                   'No space'            '|' +
                                   'Segmentation fault'  '|' +
                                   'Assertion failed'    '|' +
                                   'Assertion .* failed' '|' +
                                   'Floating exception'  '|' +

                                   # Unix shell errors (e.g., bash or csh)
                                   'Can\'t execute'               '|' +
                                   'Can\'t locate'                '|' +
                                   'Word too long'                '|' +
                                   'Arg list too long'            '|' +
                                   'Badly placed'                 '|' +
                                   'Expression Syntax'            '|' +
                                   'No such file or directory'    '|' +
                                   'Illegal variable name'        '|' +
                                   'Unmatched [\"\']\\.'          '|' +   # HACK: emacs highlight fix (")
                                   'Bad : modifier in'            '|' +
                                   'Syntax Error'                 '|' +
                                   'Too many (\\(|\\)|arguments)' '|' +
                                   'illegal option'               '|' +
                                   'Missing name for redirect'    '|' +
                                   'Variable name must contain'   '|' +
                                   'unexpected EOF'               '|' +
                                   'unexpected end of file'       '|' +
                                   'command not found'            '|' +
                                   '^sh: '                        '|' +
                                   '\\[Errno \\d+\\]'             '|' +
                                   ## NEW: Add missing shell error patterns from Perl
                                   ## DERIVED FROM: Perl lines 137-139
                                   'Operation not permitted'      '|' +
                                   'command exited with non-zero status' '|' +
                                   'command terminated by signal'  '|' +

                                   # Perl interpretation errors
                                   # TODO: Add more examples like not-a-number, which might not be apparent.
                                   # ex: Argument "not-a-number" isn't numeric in addition (+) at /home/tomohara/bin/cooccurrence.perl line 67, <> line 1.
                                   '^\\S+: Undefined variable'                      '|' +
                                   'Invalid conversion in printf'                   '|' +
                                   'Execution .* aborted'                           '|' +
                                   'used only once: possible typo'                  '|' +
                                   'Use of uninitialized'                           '|' +
                                   'Undefined subroutine'                           '|' +
                                   'Reference found where even-sized list expected' '|' +
                                   'Out of memory'                                  '|' +
                                   'Unmatched .* in regex'                          '|' +
                                   'at .*\\.(perl|prl|pl|pm) line \\d+'             '|' +   # catch-all for other perl errors

                                   # Build errors
                                   '(Make|Dependency) .* failed' '|' +
                                   ## NEW: Add missing build error patterns from Perl
                                   ## DERIVED FROM: Perl lines 157-161
                                   'cannot create'               '|' +
                                   'cannot open'                 '|' +
                                   'cannot find'                 '|' +
                                   'cannot overwrite'            '|' +
                                   ':( fatal)? error '           '|' +

                                   ## NEW: Add missing Git error patterns from Perl
                                   ## DERIVED FROM: Perl lines 163-164
                                   # Git errors (WTH: can't modern tools say 'error'???)
                                   '^\\s*fatal:'                 '|' +

                                   # Java errors
                                   r'^Exception\b' '|' +

                                   # Ruby errors
                                   r': undefined\b'       '|' +
                                   '\\(\\S+Error\\)'      '|' +   # ex: wrong number of arguments (1 for 0) (ArgumentError)
                                   'Exception.*at.*\\.rb' '|' +

                                   # Python errors
                                   '^Traceback'      '|' +   # stack trace
                                   ## OLD: Reworked with general exceptions (L252)
                                   # '^\\S+Error'      '|' +   # exception (e.g., TypeError)
                                   ## DERIVED FROM: Perl lines 174-183
                                   '^\\S+\\.\\S+Error:'  '|' +   # package specific (e.g., azure.ServiceRequestError)
                                   '\\|\\s*(ERROR|CRITICAL)\\s*\\|' '|' +  # loguru (e.g., "| ERROR | ...")
                                   '(^|\\s)[A-Z]\\S+Error(\\s|:|$)' '|' +  # general exceptions (e.g., TypeError)
                                   ':\\s*error\\s*:'     '|' +   # argparse errors
                                   '^\\s*FAILED\\b'      '|' +   # pytest failures
                                   ## Note: Would need additional logic to exclude BrokenPipeError/SillyPythonException
                                   ## as the Perl version does with: && ($relaxed || ! /BrokenPipeError|SillyPythonException/)

                                   # Cygwin errors
                                   r'\bunable to remap\b' '|' +

                                   # Miscellaneous errors
                                   ## OLD: Added additional regex cases for misc errors
                                   # 'wn: invalid search')
                                   'wn: invalid search'          '|' +
                                   'socket has failed to (bind|listen)')

        known_errors_ignorecase = ('command not found'   '|' +

                                   # Unix shell errors (e.g., bash or csh)
                                   'permission denied'            '|' +

                                   # Python errors
                                   ':\\s*error\\s*:'              '|' +   # argparse error (e.g., main.py: error: unrecognized arguments
                                   r'^FAILED\b'                   '|' +   # pytest failure
                                   ## NEW: Added logging patterns (perl L183)
                                   '\\|\\s*(ERROR|CRITICAL)\\s*\\|')      # logging patterns


        if not has_error:
            # Check case-sensitive patterns
            match = my_re.search(known_errors, line)
            if match:
                # Special exclusion for command not found
                if not (my_re.search('command not found', line, my_re.IGNORECASE) and my_re.search('Cannot switch to Modules', line)):
                    has_error = True
                    match_info = f"E2 [{match.group()}]"
            
            # Check case-insensitive patterns
            if not has_error:
                match = my_re.search(known_errors_ignorecase, line, flags=my_re.IGNORECASE)
                if match:
                    has_error = True
                    match_info = f"E2 [{match.group()}]"

            debug.trace(debug.QUITE_VERBOSE, f"2. has_error={int(has_error)}")


        # Check for warnings and starred messages
        # TODO: Have option for restricting ***'s to start of line.
        # NOTE: $strict includes "error" or "warning" occurring anywhere;
        # added to excluded keywords usage as in "conflict_handler='error'".
        if  (not has_error and self.show_warnings and
            ## OLD: Replaced re with mezcla.my_regex (my_re)
            #     ((re.search(r'\b(warning)\b', line, flags=re.IGNORECASE) and       # warning token occuring
            #    ((not re.search("='warning'", line, flags=re.IGNORECASE)) or self.strict)) or # ... includes quotes if strict
            #   (re.search(r'\b(error)\b', line, flags=re.IGNORECASE) and         # matches within line error case above
            #    ((not re.search("='error'", line, flags=re.IGNORECASE)) or self.strict)) or   # ... includes quotes if strict
            #   re.search(': No match', line) or                                              # shell warning?
            #   re.search(r': warning\b', line) or                                             # Ruby warnings
            #   re.search('^bash: ', line) or                                                 # ex: "bash: [: : unary operator expected"
            #   re.search('Traceback|\\S+Error', line) or                                     # Python exceptions (caught)
            #   (self.asterisks and re.search('\\*\\*\\*', line)))):
             ((my_re.search(r'\b(warning)\b', line, flags=my_re.IGNORECASE) and       # warning token occuring
               ((not my_re.search("='warning'", line, flags=my_re.IGNORECASE)) or self.strict)) or # ... includes quotes if strict
              (my_re.search(r'\b(error)\b', line, flags=my_re.IGNORECASE) and         # matches within line error case above
               ((not my_re.search("='error'", line, flags=my_re.IGNORECASE)) or self.strict)) or   # ... includes quotes if strict
              my_re.search(': No match', line) or                                              # shell warning?
              my_re.search(r'\\ No newline at end', line) or                                   # git/diff warning
              my_re.search(r': warning\b', line) or                                             # Ruby warnings
              my_re.search('^bash: ', line) or                                                 # ex: "bash: [: : unary operator expected"
              my_re.search('Traceback|\\S+Error', line) or                                     # Python exceptions (caught)
              my_re.search('\\b\\S+Warning', line) or                                          # various Warning types
              (self.strict and my_re.search('exception|failed', line)) or                      # strict mode patterns
              (self.asterisks and my_re.search('\\*\\*\\*', line)))):
            has_error = True
            
            # Determine which warning pattern matched
            ## NEW: Added which warning pattern is matched
            ## DERIVED FROM: Perl lines 218
            # $match_info = "W1 [$&]";
            if my_re.search(r'\b(warning)\b', line, flags=my_re.IGNORECASE):
                match_info = "W1 [warning]"
            elif my_re.search(r'\b(error)\b', line, flags=my_re.IGNORECASE):
                match_info = "W1 [error]"
            elif my_re.search('\\*\\*\\*', line):
                match_info = "W1 [***]"
            else:
                match_info = "W1 [other]"
                
            debug.trace(debug.QUITE_VERBOSE, f"3. has_error={int(has_error)}")


        # Check for informative messages
        if self.show_informative and not has_error:
            if (my_re.search(r'\bFYI:', line, my_re.IGNORECASE) or
                my_re.search(r'information', line, my_re.IGNORECASE)):
                has_error = True
                match_info = "I1 [info]"
                debug.trace(debug.QUITE_VERBOSE, f"4. has_error={int(has_error)}")


        # Filter certain cases (e.g., posthoc fixup)
        ## OLD: Replace re with mezcla.my_regex (my_re)
        # if has_error and self.skip_ruby_lib and re.search('\\/usr\\/lib\\/ruby', line):
        #     debug.trace(debug.DETAILED, f'Skipping ruby library error at line ({line})')
        #     debug.trace(debug.QUITE_VERBOSE, f"4. has_error={int(has_error)}")
        if has_error and self.skip_ruby_lib and my_re.search(r'/usr/lib/ruby', line):
            debug.trace(debug.DETAILED, f'Skipping ruby library error at line {self.line_number} ({line})')
            has_error = False
            debug.trace(debug.QUITE_VERBOSE, f"5. has_error={int(has_error)}")


        # If an error, then display line preceded by pre-context
        debug.trace(debug.QUITE_VERBOSE, f"final has_error={int(has_error)}")
        if has_error:
            # Show up the N preceding context lines, unless there is an overlap
            # with previous error context in which no pre-context is shown.
            num = 0 if self.after > 0 else len(self.before_context)
            for i in range(num):
                print(f'{str(self.line_number - (num - i)).ljust(4, " ")}     {self.before_context[i]}')

            # Display the error line and update the after context count
            print(f'{str(self.line_number).ljust(4, " ")} >>> {line} <<<')
            ## OLD: self.after = self.context
            if self.show_matching:
                print(f'{str(self.line_number).ljust(4, " ")} match: {match_info}')
            self.after = self.after_context_lines


        # Otherwise print line only if in the post-context
        else:
            if self.after > 0:
                print(f'{str(self.line_number).ljust(4, " ")}     {line}')
            if self.after == 1:
                print('')
            self.after -= 1


        # Update the context
        self.before_context = system.append_new(self.before_context, line)
        ## OLD: if (len(self.before_context) - 1) == self.context:
        if (len(self.before_context) - 1) == self.before_context_lines:
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
                                         ## NEW: Added missing boolean options for command line
                                         ## DERIVED FROM: Perl lines 41-43
                                         #  my $options = "options = [-warnings | -info] [-context=N] [-no_astericks] [-skip_ruby_lib]";
                                         # TODO2: split options in main and misc (e.g., [-skip_ruby_lib])
                                         # $options .= " [-relaxed | -strict] [-verbose] [-quiet] [-before=N] [-after=N] [-matching]";
                                         (INFO,          'show informative messages (e.g., FYI\'s)'),
                                         (MATCHING,      'show which regex pattern matched'),
                                         (QUIET,         'suppress filename output, show only errors'),
                                         (VERBOSE,       'show more details')],
                      int_options     = [(CONTEXT,       'context lines before and after'),
                                         ## NEW: Added missing integer options from command line
                                         (BEFORE,        'lines of context before error'),
                                         (AFTER,         'lines of context after error')])
    app.run()
