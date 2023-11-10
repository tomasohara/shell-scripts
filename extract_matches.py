#! /usr/bin/env python
#
# extract_matches.py: simple script for extracting text in a file matching a particular pattern
# This is equivalent to the following bash function
#     function extract_matches () { perl -ne "while (/$1/) { printf \"%s\\n\", \$1; s/$1//; }" $2 }
# See count_it.py for a similar script for counting the frequency of such patterns.
#
# Portions Copyright (c) 2001 Cycorp, Inc.  All rights reserved.
# Portions Copyright (c) 2002-2004 Tom O'Hara  All rights reserved.
#
# TODO:
# - Specify list of fields to output (as in cut.perl).
# - Check for looping due to empty patterns (e.g., '(.*)').
# - Only apply s qualifier when -para or -slurp specified.
#


"""
Script for extracting text in a file matching a particuar pattern

examples:\n\n
ls -l | extract_matches.py \"\\.([^\\.]+\\$)\"\n\n
echo '(trace' `extract_matches.py \"^\\(defun (\\S+)\" init.lisp` ')'\n\n
extract_matches.py --replacement='$1-$2-method' '^\\(def-instance-method \\((\\S+) (\\S+)' /home/tom/cycl/subloop-class-example.lisp\n\n
extract_matches.py --para --replacement='A $1 : $2' 'def\\S+\\s*(\\S+)\\s*[^\\\"]*\\s*\\\"([^\\\"]+)\\\"' parse-template-utilities.lisp\n\n
echo \"a b c d\" | extract_matches.py --restore=$2' --fields=2 \"(\\S) (\\S)\"\n\n

\n\n
Use --restore to simulate look-ahead (see example above).\n
With - for pattern, it defaults to tab-delimited fields (e.g., via --fields=N).\n
use {match.group(N in --replacement as pointer to N match group.
"""


# Standard packages
# TODO: replace re by the local implementation my_re
## OLD: import re


# Local packages
from mezcla.main import Main
from mezcla import debug
from mezcla import system
from mezcla import misc_utils
from mezcla.my_regex import my_re

# Command-line labels constants
PATTERN        = 'pattern'        # regex pattern to check for
REPLACEMENT    = 'replacement'    # pattern for replacement (e.g, \1-\2-method)
RESTORE        = 'restore'        # portion of matching text to be restored
PARA           = 'para'           # paragraph input mode
SLURP          = 'slurp'          # alias for -file
FILE           = 'file'           # entire file input mode
FIELDS         = 'fields'         # number of output fields
SINGLE         = 'single'         # alias for -one_per_line
ONE_PER_LINE   = 'one_per_line'   # only count one instance of the pattern per line
MULTI_PER_LINE = 'multi_per_line' # multiple matches per line
MAX_COUNT      = 'max_count'      # maximum number of matches per line
IGNORE         = 'i'              # ignore case
PRESERVE       = 'preserve'       # preserve case (when -i in effect)
CHOMP          = 'chomp'          # strip newline at end


class ExtractMatches(Main):
    """Extract text in a file matching a particuar pattern"""


    ## class-level member variables for arguments (avoids need for class constructor)
    pattern         = ""
    replacement     = ""
    restore         = ""
    paragraph_mode  = False # paragraph mode
    file_input_mode = False # aka file slurping
    fields          = 0
    one_per_line    = False
    multi_per_line  = False
    max_count       = 0
    ignore_case     = False
    preserve        = False
    chomp           = False


    def setup(self):
        """Process arguments"""


        # Check the command-line options
        self.pattern         = self.get_parsed_argument(PATTERN, "")
        self.replacement     = self.get_parsed_argument(REPLACEMENT, "")
        self.restore         = self.get_parsed_argument(RESTORE, "")
        self.paragraph_mode  = self.has_parsed_option(PARA)
        self.file_input_mode = self.has_parsed_option(SLURP) or self.has_parsed_option(FILE)
        self.fields          = self.get_parsed_option(FIELDS, 1)
        single               = self.has_parsed_option(SINGLE)
        self.one_per_line    = self.has_parsed_option(ONE_PER_LINE) or single
        self.multi_per_line  = self.has_parsed_option(MULTI_PER_LINE) or not single
        self.max_count       = system.maxint() if self.multi_per_line else 1
        self.max_count       = self.get_parsed_option(MAX_COUNT, self.max_count)
        self.ignore_case     = self.has_parsed_option(IGNORE)
        self.preserve        = self.has_parsed_option(PRESERVE)
        self.chomp           = (self.has_parsed_option(CHOMP) or
                                not my_re.match('\\n', self.pattern))


        if not self.preserve:
            debug.trace(debug.DETAILED, f'Note: --{PRESERVE} not implemented')


        auto_pattern = False # automatically derive pattern (for tab-delimited fields)
        if self.pattern == '-':
            auto_pattern = True
            self.pattern =  "(\\S+)" if self.fields else "(.*)"


        # Enforce a single pattern per line when beginning-of-line pattern (^) used
        if my_re.search(r'^\^.*|.*\$$', self.pattern):
            self.max_count = 1
        debug.trace(debug.QUITE_DETAILED, f'max_count={self.max_count}')

        # Replace perl-style $N replacements with {match.group(N)}
        placeholder_regex = r'(^|[^\\])\$(\d+)'
        while my_re.search(placeholder_regex, self.replacement):
            old_replacement = self.replacement
            num = system.to_int(my_re.group(2))
            self.replacement = (self.replacement[0: my_re.start() + 1] + f"{{my_re.group({num})}}" + self.replacement[my_re.end():])
            if (self.replacement == old_replacement):
                system.print_error("Error: Unxpected error during replacement $N fix")
                break
            debug.trace(5, f"modified replacement: {old_replacement!r} => {self.replacement!r}")
        debug.trace(4, f"new replacement {self.replacement!r}")

        # For multiple-field patterns, generate a replacement with tab separated fillers
        # note: this assumes that replacement is same as "{match.group(1)}" default
        fix_replacement = not self.replacement
        if fix_replacement:
            self.replacement = '{match.group(1)}'
        for i in range(2, self.fields+1):
            if fix_replacement:
                self.replacement += '\t' + '{match.group(' + str(i) + ')}'
            if auto_pattern:
                self.pattern += '\t(\\S+)'


        # Put grouping parenthesis around pattern, if none present
        # NOTE: Escaped parentheses are ignored.
        if not my_re.search(r'^\(|[^\\]\(.*[^\\]\)', self.pattern):
            self.pattern = '(' + self.pattern + ')'


        debug.trace(debug.QUITE_DETAILED, f'pattern={self.pattern}; replacement={self.replacement}; restore={self.restore}')
        debug.trace_object(5, self, label="Script instance")

    def process_line(self, line):
        """Process each line of the input stream"""
        line = system.to_utf8(line)


        # NOTE: a chop isn't performed by default to allow for using the newline in a pattern.
        # This is often more convenient than using $ (e.g., when using csh).
        # TODO: add sanity check about DOS carriage returns screwing up pattern matching
        if self.chomp:
            line = system.chomp(line)
        debug.trace(debug.QUITE_DETAILED, f'{line}')


        # Print the text instances that matches the pattern, each on a separate line
        # NOTE: s qualifier treats string as single line (in case -para specified)
        # NOTE: glue_helpers.py->extract_matches_from_text() could be used too, but it would be
        #       necessary to implement on this function the params restore and replacement
        count = 0
        ## OLD: while (self.ignore_case and (match := re.search(self.pattern, line, flags=re.IGNORECASE))) or (match := re.search(self.pattern, line)):
        flags = (my_re.IGNORECASE if self.ignore_case else 0)
        while (my_re.search(self.pattern, line, flags=flags)):
            match = my_re.get_match()
            debug.trace(debug.QUITE_DETAILED, f'match={match}')


            debug_output = ''
            for i in range(self.fields):
                debug_output += str(i) + ' = ' + match.group(i) + '; '
            debug.trace(debug.QUITE_DETAILED, debug_output)


            # Update the current line being
            postmatch = line[match.end():]
            if self.restore:
                restore_text = misc_utils.eval_expression(f'f"{self.restore}"')
                debug.trace(debug.DETAILED, f'restoring {restore_text} to line')
                line = restore_text + postmatch
                debug.trace(debug.VERBOSE, f'line={line}')
            else:
                line = postmatch


            # Transform matching text based on replacement pattern (e.g., 'match.group(N)')
            replacement_text = misc_utils.eval_expression(f'f"{self.replacement}"')
            debug.trace(debug.QUITE_DETAILED, f'replacement text: {replacement_text}')

            output_text = match.group(0)
            try:
                output_text = my_re.sub(self.pattern, replacement_text, output_text, flags=flags)
            except:
                system.print_exception_info("replacement_text substitution")

            debug.trace(debug.QUITE_DETAILED, f'resulting text: {output_text}')
            print(output_text)


            # See if limit for displayed matches reached
            debug.trace(debug.QUITE_DETAILED, f'count={count} max_count={self.max_count}')
            count += 1
            if count >= self.max_count:
                break


        if count == 0:
            debug.trace(debug.QUITE_VERBOSE, f'line not matched: {line}')


if __name__ == '__main__':
    app = ExtractMatches(description = __doc__,
                         boolean_options      = [(PARA,           'paragraph input mode'),
                                                 (SLURP,          'alias for -file'),
                                                 (FILE,           'entire file input mode'),
                                                 (SINGLE,         'alias for -one_per_line'),
                                                 (ONE_PER_LINE,   'only count one instance of the pattern per line'),
                                                 (MULTI_PER_LINE, 'multiple matches per line'),
                                                 (IGNORE,         'ignore case'),
                                                 (PRESERVE,       'preserve case (when -i in effect'),
                                                 (CHOMP,          'strip newline at end')],
                         positional_arguments = [(PATTERN,        'regex pattern to check for')],
                         int_options          = [(FIELDS,         'number of output fields'),
                                                 (MAX_COUNT,      'maximum number of matches per line')],
                         text_options         = [(REPLACEMENT,    'pattern for replacement (e.g, \1-\2-method)'),
                                                 (RESTORE,        'portion of matching text to be restored')])
    app.run()
