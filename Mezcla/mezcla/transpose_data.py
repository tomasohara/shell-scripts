#! /usr/bin/env python
#
# Takes an input table and transposes the rows and columns. In addition, there
# is support for showing each field value on a separate line prefixed by the
# column name. This is intended to make large table dumps more comprehensible,
# such as from databases.
#------------------------------------------------------------------------
# Sample Input:
#
#   i_timestamp   | i_ip_addr1 |             i_session_id                 | i_keyword
#   1384983367.79 | 1138872328 | 003a4a80db5eda5fa5e7359d57afc29ac1fec377 | Staples Retail Office Products
#   1384983366.04 | 1158147302 | 003b7091f121e03a4ca4e6f8b30e052f78fba19f | Quality
#   1384983366.04 | 1158147302 | 003b7091f121e03a4ca4e6f8b30e052f78fba19f | Quality
#   1384948918.84 | 1130098581 | 003bb1e9a137f6cf1ddd58941c6c7a326c9b2c3d | medical assistant
#
# Sample output:
#
#   i_timestamp: 1384983367.79 | 1384983366.04 | 1384983366.04 | 1384948918.84
#   i_ip_addr1: 1138872328 | 1158147302 | . | 1130098581
#   i_session_id: 003a4a80db5eda5fa5e7359d57afc29ac1fec377 | 003b7091f121e03a4ca4e6f8b30e052f78fba19f | . | 003bb1e9a137f6cf1ddd58941c6c7a326c9b2c3d
#   i_keyword: Staples Retail Office Products | Quality | . | medical assistant
#
#   via: ./transpose-data.py --elide --delim=' | ' < sample-transpose-input.data 
#    
# TODO:
# - Have option to disable use of labels alltogether.
# - Have option to prefix values with column number.
# - Ignore (first) header line if same as headers option.
# - Have separate option for output delim (eg., ": ").
# - Rework field extraction using csv package (rather than split).
# - Have option for setting delim to tab to avoid awkward spec under bash (e.g., --delim $'\t').
#

"""Takes an input table and transposes the rows and columns"""

# Standard packages
import csv
import sys
import argparse

# Local packages
## TODO: from mezcla import debug
## OLD: from tpo_common import debug_print, trace_array, print_stderr
from mezcla.tpo_common import debug_print, trace_array
from mezcla.system import print_stderr
## OLD: from glue_helpers import read_lines
from mezcla.glue_helpers import read_lines

def main():
    """Entry point for script"""
    # Check command-line arguments
    parser = argparse.ArgumentParser(description="Transpose a table from input")
    parser.add_argument("--header", help="File with field names")
    parser.add_argument("--delim", help="Delimiter for fields")
    parser.add_argument("--csv", action='store_true', default=False, help="Comma separated value input")
    parser.add_argument("--encode-newlines", action='store_true', default=False, help="Encode embedded newlines as <EOL>")
    parser.add_argument("--dialect", help="CVS dialect (e.g., excel or unix)")
    parser.add_argument("--elide", dest='elide_fields', action='store_true', default=False, help="Replace repeated values by .'s")
    parser.add_argument("--elided-value", help="Value for repeated field")
    parser.add_argument("--single-field", dest='single_field', action='store_true', default=False, help="Only show a single field per output line")
    parser.add_argument("filename", nargs='?', default='-')
    args = vars(parser.parse_args())
    debug_print("args = %s" % args, 5)
    delim = "\t"
    elided_value = "."
    field_names = []
    field_data = []
    single_field = args['single_field']
    elide_fields = args['elide_fields']
    encode_newlines = args['encode_newlines']
    csv_dialect = args['dialect']
    if args['delim']:
        delim = args['delim']
    if args['csv']:
        delim = ","
    if args['elided_value']:
        elided_value = args['elided_value']
    if args['header']:
        lines = read_lines(args['header'])
        ## OLD: field_names = [label.strip() for label in lines[0].split(delim)]
        header_reader = csv.reader(iter(lines), delimiter=delim, quotechar='"', dialect=csv_dialect)
        field_names = header_reader[0]
        trace_array(field_names, 5, "field_names")
        if not single_field:
            field_data = [[] for i in range(len(field_names))]
            trace_array(field_data, 5, "field_data")
        previous_value = [None] * len(field_names)
    input_stream = sys.stdin
    if (args['filename'] and (args['filename'] != "-")):
        input_stream = open(args['filename'])

    # Transpose each line of the table
    num_lines = 0
    csv_reader = csv.reader(iter(input_stream.readlines()), delimiter=delim, quotechar='"', dialect=csv_dialect)
    ## OLD: for line in input_stream:
    for line_data in csv_reader:
        num_lines += 1
        ## OLD:
        ## line = line.strip("\n")
        ## debug_print("L%d: %s" % (num_lines, line), 6)
        ## line_data = [field.strip() for field in line.split(delim)]
        debug_print("R%d: %s" % (num_lines, line_data), 6)
        trace_array(line_data, 5, "line_data")

        # Use first line as field names if not yet defined
        if (len(field_names) == 0):
            field_names = line_data
            if not single_field:
                field_data = [[] for i in range(len(field_names))]
                trace_array(field_data, 5, "field_data")
            previous_value = [None] * len(field_names)
            continue
        ## OLD: elif ((num_lines == 1) and (field_names == line_data)):
        if ((num_lines == 1) and (field_names == line_data)):
            debug_print("Ignoring duplicate header", 5)
            continue

        # Append each field to respective list (of seen values)
        if (len(line_data) != len(field_names)):
            print_stderr("Warning: Found %d fields but expected %d" % (len(line_data), len(field_names)))
            line_data += (['n/a'] * max(0, len(field_names) - len(line_data)))
        for i in range(len(field_names)):
            debug_print("d[%d]: %s" % (i, line_data[i]), 7)
            new_value = line_data[i]
            if encode_newlines:
                new_value = new_value.replace("\n", "<EOL>")
            if "\n" in new_value:
                new_value = '"' + new_value + '"'
            if (elide_fields and (previous_value[i] == line_data[i])):
                new_value = elided_value
            ## OLD: if (single_field):
            if single_field:
                print("%s" % (delim.join([field_names[i], new_value])))
            else:
                field_data[i].append(new_value)
                previous_value[i] = line_data[i]
        if not single_field:
            trace_array(field_data, 8, "field_data")

    # Output the transposed lines
    if not single_field:
        for i in range(len(field_names)):
            print("%s" % delim.join([field_names[i]] + field_data[i]))

    return

#------------------------------------------------------------------------

if __name__ == '__main__':
    main()
