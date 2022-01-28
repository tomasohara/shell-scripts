#! /usr/bin/env python
# -*- coding: utf-8 -*-
#
# tpo_count_it.py: script to count the occurrences of a pattern in the input
#
# NOTE: This is a simple script that turns out to be very useful
# for a variety of tasks, especially in corpus analysis.
#
# examples:
#
# tabulating most commonly used commands:
#
#   $ history | tpo_count_it.py "^\s*\d+\s*(\S+)" - | less
#   ps_mine 13
#   w       11
#   gr      7
#   top     6
#   ...
#
# tabulating part-of-speech usage for particular words
#
#   $ tpo_count_it.py "(outside\/\S+)" ~/OpenMind/data/omcsraw.tag
#   outside/IN	502
#   outside/RB	137
#   outside/NN	53
#   outside/JJ	19
#
# Copyright (c) 2000-2001 Cycorp, Inc.  All rights reserved.
# Portions Copyright (c) 1996-1999 Tom O'Hara (at NMSU).  All rights reserved.


"""
Script to count the occurrences of a pattern in the input

examples:\n\nls | tpo_count_it.py '\\.([^\\.]+)$'\n\n
tpo_count_it.py '(outside\\/\\S+)' omcsraw.tag\n\n
tpo_count_it.py '(.)' - < wiki-lang-info/utf8/da  >| /tmp/da.freq\n\n
tpo_count_it.py -restore='{match.group(3)}' '((\\S+\\s+)((\\S+\\s+){2}\\S+))' time-tracking-aug21.list | head\n\n
"""


# Standard packages
# TODO: replace re by the local implementation my_re
import re


# Third party module
import unidecode


# Local packages
from mezcla.main import Main
from mezcla import debug
from mezcla import system
from mezcla import misc_utils


# Command-line labels constants
IGNORE_SHORT      = 'i'                 # ignore case in the pattern matching
IGNORE_LONG       = 'ignore_case'       # alias for --i option
FOLDCASE          = 'foldcase'          # fold (convert) text to lowercase
FOLD              = 'fold'              # alias for --foldcase
PRESERVE          = 'preserve'          # preserve the case of text matching pattern
PARA              = 'para'              # apply the pattern to paragraphs not lines
SLURP             = 'slurp'             # apply the pattern to entire files
FREQ_FIRST        = 'freq_first'        # put frequency counts first (ie, <freq><tab><data>)
ALPHA             = 'alpha'             # alphabetical sort
COMPACT           = 'compact'           # compact all whitespace sequences
CUMULATIVE        = 'cumulative'        # include column for cumulative counts
OCCURRENCES       = 'occurrences'       # the tags being counted are actually occurrence counts
OCCURRENCE_FIELD  = 'occurrence_field'  # field giving occurrence count (e.g., 1 for $1)
PERCENTS          = 'percents'          # shows the relative percents
MIN2              = 'min2'              # alias for --nonsingletons
MULTIPLE          = 'multiple'          # alias for --nonsingletons
NONSINGLETON      = 'nonsingleton'      # alias for --nonsingletons
NONSINGLETONS     = 'nonsingletons'     # omit cases that occur once
MIN_FREQ          = 'min_freq'          # min frequency show to show in output
TRIM              = 'trim'              # trim whitespace in matched text
UNACCENT          = 'unaccent'          # remove accent marks from input
PATTERN           = 'pattern'           # regex pattern to check for
CHOMP             = 'chomp'             # strip newline at end
RESTORE           = 'restore'           # portion of matching text to be restored
MULTI_PER_LINE    = 'multi_per_line'    # count multiple instance of the pattern per line (even when ^ and $ are specified)
ONE_PER_LINE      = 'one_per_line'      # only count one instance of the pattern per line
VERBOSE           = 'verbose'           # verbose output mode
# TODO: add optional extended help with examples for misc. options


class CountIt(Main):
    """Count the occurrences of a pattern class"""


    ## class-level member variables for arguments (avoids need for class constructor)
    ignore_case      = False
    preserve         = False
    freq_first       = False
    alpha            = False
    compact          = False
    cumulative       = False
    occurrences      = 0
    occurrence_field = 0
    percents         = False
    min_freq         = 0
    trim             = False
    unaccent         = False
    pattern          = ""
    chomp            = False
    restore          = ""
    verbose          = False
    one_per_line     = False
    multi_per_line   = False
    paragraph_mode   = False # paragraph mode
    file_input_mode  = False # aka file slurping


    ## Global State
    count_dict  = {} # assoc. dic for pattern counting


    def setup(self):
        """Process arguments"""

        # Check the command-line options
        # Each variable corresponds to one or more --var=value commandline options
        self.ignore_case      = (self.has_parsed_option(IGNORE_SHORT) or
                                 self.has_parsed_option(IGNORE_LONG))
        foldcase              = (self.has_parsed_option(FOLD) or
                                 self.has_parsed_option(FOLDCASE) or
                                 self.ignore_case)
        self.preserve         = (self.has_parsed_option(PRESERVE) or
                                 not foldcase)
        self.paragraph_mode   =  self.has_parsed_option(PARA)
        self.file_input_mode  =  self.has_parsed_option(SLURP)
        self.freq_first       =  self.has_parsed_option(FREQ_FIRST)
        self.alpha            =  self.has_parsed_option(ALPHA)
        self.compact          =  self.has_parsed_option(COMPACT)
        self.cumulative       =  self.has_parsed_option(CUMULATIVE)

        self.occurrences      =  self.has_parsed_option(OCCURRENCES)
        self.occurrence_field =  1 if self.occurrences else 0
        self.occurrence_field =  self.get_parsed_option(OCCURRENCE_FIELD, self.occurrence_field)

        self.percents         =  self.has_parsed_option(PERCENTS)
        nonsingletons         = (self.has_parsed_option(MIN2) or
                                 self.has_parsed_option(MULTIPLE) or
                                 self.has_parsed_option(NONSINGLETON) or
                                 self.has_parsed_option(NONSINGLETONS))
        self.min_freq         =  2 if nonsingletons else 1
        self.min_freq         =  self.get_parsed_option(MIN_FREQ, self.min_freq)

        self.trim             =  self.has_parsed_option(TRIM)
        self.unaccent         =  self.has_parsed_option(UNACCENT)

        self.pattern          =  self.get_parsed_argument(PATTERN, "")
        self.pattern          =  system.read_file(self.pattern) if system.file_exists(self.pattern) else self.pattern # check if is a file with pattern (to cirvumvent shell UTF8 issues)

        self.chomp            = (self.has_parsed_option(CHOMP) or
                                 not re.match('\\n', self.pattern))

        self.restore          =  self.get_parsed_argument(RESTORE, "")
        self.verbose          =  self.get_parsed_option(VERBOSE)


        # See if regex has line achor (^ or $)
        # NOTE: Escaped $ are ignored.
        has_line_anchor     = re.search(r'^\^|[^\\]\$$', self.pattern)
        self.one_per_line   = self.has_parsed_option(ONE_PER_LINE) or has_line_anchor         # only count one instance of the pattern per line
        self.multi_per_line = self.has_parsed_option(MULTI_PER_LINE) or not self.one_per_line # count multiple instance of the pattern per line (even when ^ and $ are specified)
        debug.assertion(not (self.one_per_line and self.multi_per_line))


        # Sanity check for whether one-per-line option might be needed
        # NOTE: checks against pattern need to occur prior to modification (e.g., paren addition)
        # TODO: handle multiple patterns per line (e.g., set line break to null); likewise check for multiple end-of-line matching
        if re.search(r'^\^.*[^\$\n]$', self.pattern) and not self.multi_per_line:
            debug.trace(debug.USUAL, 'You might want to specify -multi_per_line if you want ^ and/or $ interpretted after match removal.')


        # Put grouping parenthesis around pattern, if none present
        # NOTE: Escaped parentheses are ignored.
        if not re.search(r'^\(|[^\\]\(.*[^\\]\)', self.pattern):
            self.pattern = '(' + self.pattern + ')'


        debug.trace(debug.DETAILED, f'searching for pattern "{self.pattern}"; one_per_line="{self.one_per_line}"; ignore_case={self.ignore_case}...')
        debug.trace(debug.VERBOSE, f'restore={self.restore}')


    def process_line(self, line):
        """Process each line of the input stream"""
        line = system.to_utf8(line)


        if self.unaccent:
            line = remove_diacritics(line)


        # NOTE: a chop isn't performed by default to allow for using the newline in a pattern.
        # This is often more convenient than using $ (e.g., when using csh).
        # TODO: add sanity check about DOS carriage returns screwing up pattern matching
        if self.chomp:
            line = system.chomp(line)
        debug.trace(debug.QUITE_DETAILED, f'{line}')


        # Perform optional transformations
        # - All whitespace sequences to single spaces
        if self.compact:
            line = re.sub(r'\s+', ' ', line)


        while not (line and line == r'\n'):
            debug.trace(debug.QUITE_DETAILED, f'text={line}')


            # Try to extract match from the line
            if self.ignore_case:
                match = re.search(self.pattern, line, flags=re.IGNORECASE)
            else:
                match = re.search(self.pattern, line)


            if match:
                # Try to extract group of match
                tag_name = ''
                if self.occurrence_field:
                    tag_name = match.group(self.occurrence_field)
                else:
                    tag_name = match.group(1)
                debug.trace(debug.QUITE_DETAILED, f'tag name: {tag_name}')


                if not self.preserve:
                    tag_name = tag_name.lower()


                if self.trim:
                    tag_name = trim_whitespaces(tag_name)


                # Update the dictionary of the patterns
                debug.trace(debug.QUITE_DETAILED, f"adding: {tag_name}\n\t\\$\\&='{match}'")
                self.count_dict[tag_name] = self.count_dict.get(tag_name, 0) + 1


                # Update the current line being matched
                postmatch = line[match.end():]
                if self.restore:
                    ## Tom: restore will require an evaluation environment (e.g., misc_utils.eval_expression as illustrated below)
                    restore_text = misc_utils.eval_expression(f'f"{self.restore}"')
                    debug.trace(debug.DETAILED, f"restoring '{self.restore}' to current text")
                    line = restore_text + postmatch
                    debug.trace(debug.VERBOSE, f"current text='{line}'")
                else:
                    line = postmatch


            # Stop when not match or if just one match per line
            if (not match) or self.one_per_line:
                break


    def wrap_up(self):
        """End processing"""
        debug.trace(debug.VERBOSE, f'{len(self.count_dict)} patterns found')
        debug.trace_values(debug.VERBOSE + 2, self.count_dict)


        # calculate count of occurrences
        total_count = sum(self.count_dict.values())


        if self.occurrences:
            print(f'total occurrence count is {total_count}')


        if self.verbose:
            print(f'Frequency of {self.pattern}')


        # Sort
        if self.alpha:
            self.count_dict = sorted(self.count_dict.items())
        else:
            self.count_dict = misc_utils.sort_weighted_hash(self.count_dict)


        # Show results
        cumulative_tag_count = 0
        for tag_name, tag_count in self.count_dict:
            if tag_count < self.min_freq:
                continue

            if tag_count:
                output = ''
                tag_name = re.sub(r'\n$', '', tag_name)

                if self.freq_first:
                    output += str(tag_count) + '\t' + tag_name
                else:
                    output += tag_name + '\t' + str(tag_count)

                if self.percents:
                    output += '\t' + str(system.round_num(tag_count / total_count, 3))

                # Show optional cumulative count column
                if self.cumulative:
                    cumulative_tag_count += tag_count
                    output += '\t' + str(cumulative_tag_count)
                    if self.percents:
                        output += '\t' + str(system.round_num(cumulative_tag_count / total_count, 3))

                print(output)


# Remove diacritic marks from the text
def remove_diacritics(text):
    """Removes diacritic marks from the text"""
    return unidecode.unidecode(text)


# Removes leading and trailing whitespace
def trim_whitespaces(text):
    """Removes leading and trailing whitespace"""
    text = text.lstrip()
    text = text.rstrip()
    return text


if __name__ == '__main__':
    app = CountIt(description = __doc__,
                  boolean_options      = [(IGNORE_SHORT,     'ignore case in the pattern matching'),
                                          (IGNORE_LONG,     f'alias for --{IGNORE_SHORT} option'),
                                          (FOLDCASE,         'fold (convert) text to lowercase'),
                                          (FOLD,            f'alias for --{FOLDCASE}'),
                                          (PRESERVE,         'preserve the case of text matching pattern'),
                                          (PARA,             'reads text in paragraph mode (rather than line)'),
                                          (SLURP,            'reads the entire file at once (for long-distance patterns)'),
                                          (FREQ_FIRST,       'put frequency counts first (ie, <freq><tab><data>)'),
                                          (ALPHA,            'alphabetical sort'),
                                          (COMPACT,          'treat runs of whitespace as single space'),
                                          (CUMULATIVE,       'include column for cumulative counts'),
                                          (OCCURRENCES,      'incorporates count field'),
                                          (PERCENTS,         'shows the relative percents'),
                                          (MIN2,            f'alias for --{NONSINGLETONS}'),
                                          (MULTIPLE,        f'alias for --{NONSINGLETONS}'),
                                          (NONSINGLETON,    f'alias for --{NONSINGLETONS}'),
                                          (NONSINGLETONS,    'ignore item occurring just once'),
                                          (TRIM,             'trim whitespace in matched text'),
                                          (UNACCENT,         'remove accent marks from input'),
                                          (CHOMP,            'strip newline at end'),
                                          (ONE_PER_LINE,     'only count one instance of the pattern per line'),
                                          (MULTI_PER_LINE,   'allows for multple occurrences in a line (assumed unless ^ used)'),
                                          (VERBOSE,          'verbose output mode')],
                  positional_arguments = [(PATTERN,          'regex pattern or file with pattern (to circumvent shell UTF8 issues) to check for')],
                  int_options          = [(OCCURRENCE_FIELD, 'field giving occurrence count'),
                                          (MIN_FREQ,         'min frequency to show in output')],
                  text_options         = [(RESTORE,          'simulate look-ahead')])
    app.run()
