#! /usr/bin/env python
#
# Utility functions for doing data analysis, such as wrappers for functions
# provided by pandas and sklearn.
#
# Note:
# - This started out as way to provide commonly used options for CSV reading
#   with Pandas, along with tracing.
# - It is a little idiosyncratic with a bias towards Unix assumptions
#   (e.g., comments more likely in CSV files).
#
# TODO:
# - Add simple wrapper class for commonly used idioms, such as len(df.columns) for number of columns.
#

"""Utility functions for work with data (e.g., pandas wrappers)"""

# Standard module
import pandas as pd
import csv

# Local modules
from mezcla import debug
from mezcla import system
from mezcla.text_utils import version_to_number as version_as_float

# Constants
# Note: Delim defaults to None so that dialect inference can be used.
# This is a quirk with Pandas compared to the cvs module.
DELIM = system.getenv_value("DELIM", None,
                            "Delimiter for input and output tables")
COMMENT = 'comment'
DIALECT = 'dialect'
EXCEL = 'excel'
DELIMITER = 'delimiter'
SEP = 'sep'

#--------------------------------------------------------------------------------

# Sanity check for version info
MIN_PANDAS_VERSION = "1.3.0"
if (version_as_float(pd.__version__) < version_as_float(MIN_PANDAS_VERSION)):
    system.exit(f"Error: data_utils.py now needs pandas {MIN_PANDAS_VERSION} or higher")

#-------------------------------------------------------------------------------

def read_csv(filename, **in_kw):
    """Wrapper around pandas read_csv
    Note: delimiter SEP defaults to DELIM env. var, dtype to str, and both error_bad_lines & keep_default_na to False. (Override these via keyword paramsters.)
    """
    # EX: tf = read_csv("examples/iris.csv"); tf.shape => (150, 5)
    ## TODO: clarify dtype usage
    kw = {SEP: DELIM, 'dtype': str,
          ## BAD: 'error_bad_lines': False, 'keep_default_na': False}
          'on_bad_lines': 'skip', 'keep_default_na': False}
    # Overide settings based on explicit keyword arguments
    kw.update(**in_kw)
    kw['engine'] = 'python'
    # Turn off quotoing if tab delimited
    if kw[SEP] == "\t":
        kw['quoting'] = csv.QUOTE_NONE
    # Add special processing (n.b., a bit idiosyncratic)
    if ((COMMENT not in kw) and (kw.get(DIALECT) != EXCEL)):
        debug.trace_fmt(4, "Enabling comments in read_csv")
        kw[COMMENT] = "#"
    debug.trace_fmt(5, "read_csv({f}, [in_kw={ikw}])", f=filename, ikw=in_kw)
    debug.trace_fmt(6, "\tkw={k}", k=kw)
    df = None
    try:
        df = pd.read_csv(filename, **kw)
    except:
        debug.trace(4, f"Exception during read_csv: {system.get_exception()}")
    debug.trace(4, f"read_csv({filename}) => {df}")
    return df


def to_csv(filename, data_frame, **in_kw):
    """Wrapper around pandas DATA_FRAME.to_csv with FILENAME
    Note: by default, the index is omitted;
    and, delimiter SEP defaults to DELIM env. var"""
    result = None
    kw = {SEP: DELIM, 'index': False}
    kw.update(**in_kw)
    try:
        result = data_frame.to_csv(filename, **kw)
    except:
        debug.trace(4, f"Exception during write_csv: {system.get_exception()}")
    debug.trace(4, f"to_csv({filename}, {data_frame}) => {result}")
    return result
#
write_csv = to_csv


def lookup_df_value(data_frame, return_field, lookup_field, lookup_value):
    """Return value for DATA_FRAME's RETURN_FIELD given LOOKUP_FIELD value LOOKUP_VALUE"""
    # EX: lookup_df_value(tf, "sepal_length", "petal_length", "3.8") => "5.5"
    ## TODO: rework in terms of Pandas primitives
    value = None
    try:
        # TODO: trace out index location
        matches = [row[return_field] for index, row in data_frame.iterrows() 
                   if (row[lookup_field] == lookup_value)]
        if matches:
            value = matches[0]
    except:
        debug.trace(4, f"Exception during lookup_df_value: {system.get_exception()}")
    debug.trace(7, f"lookup_df_value(_, {return_field}, {lookup_field}, {lookup_value}) => {value}")
    return value


def main():
    """Entry point for script"""
    system.print_stderr("Error: Not intended to being invoked directly")
    return

#-------------------------------------------------------------------------------

if __name__ == '__main__':
    main()
