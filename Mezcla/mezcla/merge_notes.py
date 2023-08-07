#! /usr/bin/env python
#
# merge_notes.py: merge textual note files based on timestamps
#------------------------------------------------------------------------
# Sample input:
#
# - [some-notes.txt]
#   Thu 13 Nov 14
#
#      wrote great linear sort
#
#   Sat 15 Nov 14
#
#       rewrote not-so-great n log n sort
#
# - [more-notes.txt]
#   Fri 14 Nov 14
#
#      ran unit tests
#
#
# Sample output:
#
#   Thurs 13 Nov 14
#
#      wrote great linear sort
#
#   Fri 14 Nov 14
#
#      ran unit tests
#
#   Sat 15 Nov 14
#
#       rewrote not-so-great n log n sort
#
#-------------------------------------------------------------------------------
# Notes:
# - Includes indicator of original file and line number in output
#      [vm-plata-notes.txt:44]
#      Did this and that
#-------------------------------------------------------------------------------
# TODO:
# - *** Resolve problems with encoding (e.g., UTF-8): see ~/config/_master-note-info.list.08Jul20, such as following:
#      find: ‘/run/user/1000/gvfs’: Permission denied
#            ^ \342\200\230
# - ** Add option for maximum size (e.g., 1000 lines) to avoid inadvertantly incorporating large data files (e.g., sample-patient-notes.txt).
# - Allow for missing day-of-week and day (e.g., "Mar 16" => "Tues 1 Mar 16 [was Mar 16]").
#
#

"""Merge textual notes by dated entries"""

# Standard packages
import argparse
import datetime
import fileinput
import re
import sys
from collections import defaultdict

# Local packages
from mezcla import debug
from mezcla.my_regex import my_re
from mezcla import system

SKIP_BOM = system.getenv_bool("SKIP_BOM", False,
                              "Don't output byte order mark U+FEFF")

## TEMP: quiet picky pylint
# pylint: disable=consider-using-f-string

#...............................................................................

def resolve_date(textual_date, default_date=None):
    """Converts from textual DATE into datetime object (using optional DEFAULT value)"""
    # TODO: """... Supports following date formats: [WWW] dd MMM YY[YY]"
    # ALSO: clarify that default date used after parsing errors
    #
    # Note: Examples use first 5 of 8 of the datetime arguments:
    #     year, month, day, hour, minute
    # EX: resolve_date("1 Jan 00") => datetime.datetime(2000, 1, 1, 0, 0)
    # Note: following uses default date:
    # EX: resolve_date("0 Jan 00", datetime.datetime(2000, 1, 1, 0, 0)) => datetime.datetime(2000, 1, 1, 0, 0)
    # EX: resolve_date("Sun 18 Jul 2021") => datetime.datetime(2021, 7, 18, 0, 0)
    # Note: date component specifiers: %a: abbreviated weekday; %d day of month (2 digits); %b abbreviated month; %y year without century; %Y: year with century
    if default_date:
        debug.assertion(isinstance(default_date, datetime.datetime))
    date = default_date
    resolved = False
    for date_format in ["%a %d %b %y", "%d %b %y", "%a %d %b %Y", "%d %b %Y"]:
        try:
            date = datetime.datetime.strptime(textual_date, date_format)
            resolved = True
            break
        except ValueError:
            pass
    if not resolved:
        debug.trace_fmtd(2, "Warning: Unable to resolve date '{t}'", t=textual_date)
    debug.assertion(isinstance(date, datetime.datetime))
    debug.trace_fmtd(5, "resolve_date({t}, {d}) => {r}",
                     t=textual_date, d=default_date, r=date)
    return date


def main():
    """Entry point for script"""
    debug.trace(4, "main(): sys.argv=%s" % sys.argv)

    # Check command-line arguments
    parser = argparse.ArgumentParser(description="Merges ascii notes files")
    parser.add_argument("--ignore-dividers", default=False, action='store_true', help="Ignore lines consisting soley of dashes")
    parser.add_argument("--output-dividers", default=False, action='store_true', help="Output divider lines (80 dashes) betweens sections for different days")
    parser.add_argument("--show-file-info", default=False, action='store_true', help="Include filename and line number of original file in output")
    parser.add_argument("filename", nargs='+', default='-', help="Input filename")
    args = vars(parser.parse_args())
    debug.trace(5, "args = %s" % args)
    ## OLD: input_files = args['filename']
    full_input_files = args['filename']
    ignore_dividers = args['ignore_dividers']
    output_dividers = args['output_dividers']
    show_file_info = args['show_file_info']

    # Initial defaults
    # note: initializes current date to dummy from way back when
    line_num = 0
    notes_hash = defaultdict(str)
    resolved_date = {}
    dummy_date = "1 Jan 1900"
    dummy_hour = "00:00:00"
    resolved_dummy_date = resolve_date(dummy_date)
    debug.assertion(resolved_dummy_date < resolve_date("1 Jan 00"))
    debug.assertion(dummy_hour in str(resolved_dummy_date))
    last_date = dummy_date
    last_resolved_date = resolved_dummy_date
    needs_source_info = True

    # Filter inaccessible files from input file list
    input_files = [f for f in full_input_files if system.file_exists(f)]
    inaccessible_files = system.difference(full_input_files, input_files)
    if inaccessible_files:
        system.print_stderr("Warning: ignoring {n} inaccessible files {fl}",
                            n=len(inaccessible_files), fl=inaccessible_files)
    
    # Read in all the notes line by line, saving text for notes entries keyed by date.
    # TODO: add in the text in groups of lines to allow for de-duplication across files (e.g., same entry from current note file and earlier version in restore directory)
    hook_utf8_replace = None
    if sys.version_info.major > 2:
        hook_utf8_replace = fileinput.hook_encoded('UTF-8', errors='replace')
    has_new_date = False
    for line in fileinput.input(input_files, openhook=hook_utf8_replace):
        line_num += 1
        # Note: strips leading and trailing spaces from line to facilitate regex
        # pattern matching, with raw line saved as original_line.
        ## OLD: line = line.strip("\n")
        original_line = line.strip("\n")
        line = line.strip()
        debug.trace(6, "L%d: %s" % (line_num, line))

        # Reset default date if first line in file
        if fileinput.isfirstline():
            debug.trace_fmtd(4, "new file: {f}", f=fileinput.filename())
            last_date = dummy_date
            last_resolved_date = resolved_dummy_date
            needs_source_info = True
            line_num = 1

        # Optionally ignore section dividers (20 or more dashes)
        if (ignore_dividers and re.search("^--------------------+$", line)):
            debug.trace_fmtd(5, "Ignoring divider at line {n}: {l}",
                             l=original_line, n=line_num)
            continue

        # Look for a new date in format Day dd Mon yy (e.g., "Fri 13 Nov 13")
        # Notes:
        # - Day and Mon are capitalized 3-letter abbreviations (i.e.., Sun, ..., Sat and Jan, ..., Dec)
        # - Source file and line information will be added for each new date
        # TODO: allow for a variety of date formats; allow for optional time
        new_date = last_date
        new_resolved_date = last_resolved_date
        # Ensure days of the week are abbreviated (with no more than 3 letters)
        line = re.sub(r"^(Sun|Mon|Tue|Wed|Thu|Fri|Sat)\w+day", r"\1", line, flags=re.IGNORECASE)
        line = re.sub(r"^(Tue)s (\d)", r"\1 \2", line, flags=re.IGNORECASE)
        line = re.sub(r"^(Thu)rs? (\d)", r"\1 \2", line, flags=re.IGNORECASE)
        # TODO: Ensure months are abbreviated
        ## line = re.sub(r" (\d+) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\w* (\d+)", r" \1 \2 \3", line, flags=re.IGNORECASE)
        ## OLD: if (re.search(r"^([a-z][a-z][a-z] )?\d+ [a-z][a-z][a-z] \d+$", line, flag=re.IGNORECASE)):
        if (my_re.search(r"^([a-z][a-z][a-z] )?\d+ [a-z][a-z][a-z] \d+$", line, re.IGNORECASE)):
            ## OLD: new_date = line.strip()
            new_date = my_re.group(0)
            needs_source_info = True
            has_new_date = True

            # Resolve date format, adding to hash if not already there
            # TODO: if not resolvable, report file and line number
            if new_date not in resolved_date:
                new_resolved_date = resolve_date(new_date, last_resolved_date)
                debug.assertion(dummy_hour in str(new_resolved_date))
                resolved_date[new_date] = new_resolved_date
                # TODO: only add source info if different date
                # needs_source_info = True

            # Update current date
            # note: used for subsequent lines without date specifications
            last_date = new_date
            last_resolved_date = new_resolved_date

            # Trace date resolution
            debug.trace_fmtd(5, "New date at line {n}: raw={raw}; resolved={new}\n", 
                             n=line_num, raw=new_date, new=new_resolved_date)
        else:
            debug.trace_fmt(7, "Ignoring non-date in date check at line {n}", n=line_num)
                            
        # Add optional source indicator to current date
        if show_file_info and needs_source_info:
            notes_hash[new_date] += "[src={f}:{n}]\n".format(f=fileinput.filename(), 
                                                             n=fileinput.filelineno())
            needs_source_info = False
                
        # Add line to notes for current date
        # TODO: use resolved date as key so different specifications for same date output together without new date spec
        debug.assertion((not has_new_date) or (new_date != dummy_date))
        ## notes_hash[new_date] += line + "\n"
        notes_hash[new_date] += original_line + "\n"
        has_new_date = False

    # Print the note entries sorted by resolved date.
    # Note:
    # - The sorting is based on the datetime.datetime type. If an error
    #   occurs, the problem might be due to the resolve_date function
    #   incorrectly returning a string instead of the proper datetime type.
    # - This is used for sake of debugging (e.g., tracing bad comparison input).
    def get_resolved_date(k):
        """Debugging accessor for resolved_date with tracing"""
        r = resolved_date.get(k, resolved_dummy_date)
        debug.trace_fmtd(7, "get_resolved_date({k}) => {r}", k=k, r=r)
        return r
    #
    debug.trace_fmtd(7, "notes_hash keys: {{\n{k}\n}}", 
                     k="\t\n".join([str(v) for v in notes_hash.keys()]))
    #
    # TODO: make byte order mark optional (used so special characters resolved automatically in Emacs)
    if not SKIP_BOM:
        try:
            ## OLD:
            print("\uFEFF")
            ## TEMP: print("\uFEFF".encode("UTF8"))
        except:
            system.print_exception_info("printing BOM")
    #
    for pos, date in enumerate(sorted(notes_hash.keys(), 
                                      key=get_resolved_date)):
        debug.trace_fmtd(6, "outputting notes for date {d} [resolved: {r}]", 
                         d=date, r=resolved_date.get(date))
        if output_dividers and (pos > 0):
            print("-" * 80)
        debug.trace_fmtd(6, "[src={f}:{n}]", skip_newline=True,
                         f=fileinput.filename(), n=fileinput.filelineno())
        ## OLD: print("%s\n\n" % notes_hash[date])
        ## TEMP:
        try:
            ## BAD: print("%s\n\n" % notes_hash[date].encode("UTF8", errors="ignore"))
            print("%s\n\n" % notes_hash[date])
        except:
            system.print_exception_info("printing entry")

    return

#------------------------------------------------------------------------

if __name__ == '__main__':
    main()
