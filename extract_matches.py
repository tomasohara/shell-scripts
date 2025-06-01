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
use {match.group(N)} in --replacement as pointer to N match group.
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
PATTERN = "pattern"  # regex pattern to check for
REPLACEMENT = "replacement"  # pattern for replacement (e.g, \1-\2-method)
RESTORE = "restore"  # portion of matching text to be restored
PARA = "para"  # paragraph input mode
SLURP = "slurp"  # alias for -file
FILE = "file"  # entire file input mode
FIELDS = "fields"  # number of output fields
SINGLE = "single"  # alias for -one_per_line
ONE_PER_LINE = "one_per_line"  # only count one instance of the pattern per line
MULTI_PER_LINE = "multi_per_line"  # multiple matches per line
MAX_COUNT = "max_count"  # maximum number of matches per line
IGNORE = "i"  # ignore case
PRESERVE = "preserve"  # preserve case (when -i in effect)
CHOMP = "chomp"  # strip newline at end

## Remaining labels
MULTI_LINE_MATCH = "multi_line_match"
UTF8 = "utf8"
LOCALE = "locale"
VERBOSE = "verbose"


class ExtractMatches(Main):
    """Extract text in a file matching a particuar pattern"""

    ## class-level member variables for arguments (avoids need for class constructor)
    pattern = ""
    replacement = ""
    restore = ""
    paragraph_mode = False
    file_input_mode = False
    fields = 0
    one_per_line = False
    multi_per_line = False
    max_count = 0
    ignore_case = False
    preserve = False
    chomp = False
    multi_line_match = False
    utf8_mode = False
    locale_mode = False
    total_matched = 0
    verbose_mode = False

    def setup(self):
        """Process arguments"""
        # Check the command-line options
        # Replace deprecated method calls
        self.pattern = self.get_parsed_argument(PATTERN, "")
        self.replacement = self.get_parsed_option(REPLACEMENT, "")
        self.restore = self.get_parsed_option(RESTORE, "")
        self.paragraph_mode = self.get_parsed_option(PARA, False)
        self.file_input_mode = (self.get_parsed_option(SLURP, False) or 
                              self.get_parsed_option(FILE, False))
        self.fields = self.get_parsed_option(FIELDS, 1)
        self.one_per_line = (self.get_parsed_option(ONE_PER_LINE, False) or 
                           self.get_parsed_option(SINGLE, False))
        # OLD: self.multi_per_line = self.get_parsed_option(MULTI_PER_LINE, False)
        self.multi_per_line = not self.one_per_line
        self.max_count = self.get_parsed_option(MAX_COUNT, 
                                              system.MAX_INT if self.multi_per_line else 1)
        self.ignore_case = self.get_parsed_option(IGNORE, False)
        self.preserve = self.get_parsed_option(PRESERVE, False)
        self.chomp = self.get_parsed_option(CHOMP, False)
        self.multi_line_match = self.get_parsed_option(MULTI_LINE_MATCH, False)
        self.utf8_mode = self.get_parsed_option(UTF8, False)
        self.locale_mode = self.get_parsed_option(LOCALE, False)
        self.total_matched = 0
        self.verbose_mode = self.get_parsed_option('verbose', 0)        
        
        if not self.preserve:
            debug.trace(debug.DETAILED, f"Note: --{PRESERVE} not implemented")

        auto_pattern = False  # automatically derive pattern (for tab-delimited fields)
        if self.pattern == "-":
            auto_pattern = True
            self.pattern = "(\\S+)" if self.fields > 1 else "(.*)"

        # Enforce a single pattern per line when beginning-of-line pattern (^) used
        if my_re.search(r"^\^.*|.*\$$", self.pattern):
            self.max_count = 1
        debug.trace(debug.QUITE_DETAILED, f"max_count={self.max_count}")

        # For multiple-field patterns, generate a replacement with tab separated fillers
        # note: this assumes that replacement is same as "{match.group(1)}" default
        fix_replacement = not self.replacement
        if fix_replacement:
            self.replacement = "$1"
        for i in range(2, self.fields + 1):
            if fix_replacement:
                self.replacement += "\t" + f"${i}"
            if auto_pattern:
                self.pattern += "\t(\\S+)"

        # Put grouping parenthesis around pattern, if none present
        # NOTE: Escaped parentheses are ignored.
        ## OLD: if not my_re.search(r"^\(|[^\\]\(.*[^\\]\)", self.pattern):
        if not my_re.search(r"\(.*\)", self.pattern):
            self.pattern = "(" + self.pattern + ")"

        debug.trace(
            debug.QUITE_DETAILED,
            f"pattern={self.pattern}; replacement={self.replacement}; restore={self.restore}",
        )
        debug.trace_object(5, self, label="Script instance")
    
        ## New: Includes the fix for file handling
        # if self.paragraph_mode or self.file_input_mode



    def process_line(self, line):
        """Process each line of the input stream"""
        line = system.to_utf8(line)

        if self.chomp:
            line = system.chomp(line)
        debug.trace(debug.QUITE_DETAILED, f"{line}")

        count = 0
        flags = my_re.IGNORECASE if self.ignore_case else 0
        while match := my_re.search(self.pattern, line, flags=flags):
            matching_text = match.group(0)
            debug.trace(debug.QUITE_DETAILED, f"\nmatching text: '{matching_text}'")

            debug_output = ""
            for i in range(len(match.groups()) + 1):
                try:
                    debug_output += f"{i} = '{match.group(i)}'; "
                except IndexError:
                    debug_output += f"{i} = None; "
            debug.trace(debug.QUITE_DETAILED, debug_output)

            postmatch = line[match.end():]
            if self.restore:
                try:
                    restore_text = self.restore
                    for i in range(len(match.groups()), 0, -1):
                        restore_text = restore_text.replace(f'${i}', match.group(i))
                    debug.trace(debug.DETAILED, f"restoring {restore_text} to line")
                    line = restore_text + postmatch
                except Exception as e:
                    debug.trace(debug.DETAILED, f"Error in restore evaluation: {e}")
                    line = postmatch
            else:
                line = postmatch

            if self.replacement:
                replacement_text = self.replacement
                for i in range(len(match.groups()), 0, -1):
                    replacement_text = replacement_text.replace(f'${i}', match.group(i))
            else:
                replacement_text = match.group(0)

            print(replacement_text)

            count += 1
            if count >= self.max_count:
                break

        if count == 0:
            single_line_input = not (self.paragraph_mode or self.file_input_mode)
            line_display = line if single_line_input else f"{{ {line} }}"
            debug.trace(debug.QUITE_VERBOSE, f"line not matched: {line_display}")

if __name__ == "__main__":
    app = ExtractMatches(
        description=__doc__,
        boolean_options=[
            (PARA, "paragraph input mode"),
            (SLURP, "alias for -file"),
            (FILE, "entire file input mode"),
            (SINGLE, "alias for -one_per_line"),
            (ONE_PER_LINE, "only count one instance of the pattern per line"),
            (MULTI_PER_LINE, "multiple matches per line"),
            (MULTI_LINE_MATCH, "multiple line matching"),
            (IGNORE, "ignore case"),
            (PRESERVE, "preserve case (when -i in effect)"),
            (CHOMP, "strip newline at end"),
        ],
        positional_arguments=[(PATTERN, "regex pattern to check for")],
        int_options=[
            (FIELDS, "number of output fields"),
            (MAX_COUNT, "maximum number of matches per line"),
        ],
        text_options=[
            (REPLACEMENT, "pattern for replacement (e.g, \1-\2-method)"),
            (RESTORE, "portion of matching text to be restored"),
        ],
    )
    app.run()