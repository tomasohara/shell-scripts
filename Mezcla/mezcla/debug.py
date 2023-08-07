#! /usr/bin/env python
#
# Functions for debugging, such as console tracing. This is for intended
# for verbose tracing not suitable for the logging facility.
#
# Notes:
# - These are no-op's unless __debug__ is True.
# - Running python with the -O (optimized) option ensures that __debug__ is False.
# - So that other local packages can use tracing freely, this only
#   imports standard packages. In particular, system.py is not imported,
#   so functionality must be reproduced here (e.g., _to_utf8).
# - Gotta hate Pythonista's who prevailed in Python3 breaking lots of Python2
#   code just for the sake of simplicity, a la manera moronista (i.e., only one moronic way to do things)!
# - A few functions from system are re-implemented here without tracing to
#   avoid circular dependencies (e.g., _to_utf8).
# - For f-string syntax, see following:
#   https://docs.python.org/3/tutorial/inputoutput.html
#   https://www.python.org/dev/peps/pep-0498
#
# Usage examples:
#
#   - casual usage (quick-n-dirty debugging)
#
#     from mezcla import debug
#     debug.trace_expr(4, dir())
#
#   - long-term usuage (e.g., symbolic constants for consistency across scripts)
#
#     from mezcla import debug
#     TL = debug.TL
#     debug.trace(TL.DEFAULT, "Shown by default")
#     ...
#     debug.trace(TL.USUAL, f"Look ma: TL.VERBOSE={int(TL.VERBOSE)}")
#
#   - use DEBUG_LEVEL env. var. to set level
#
#     python -c 'from mezcla import debug; debug.trace(debug.DEFAULT + 1, "Not visible")'
#     DEBUG_LEVEL=3 python -c 'from mezcla import debug; debug.trace(3, "Visible")'
#
# TODO1:
# - Add sanity check to trace_fmt for when keyword in kaargs unused.
#
# TODO:
# - * Add sanity checks for unused environment variables specified on command line (e.g., FUBAR=1 python script.py ...)!
# - Rename as debug_utils so clear that non-standard package.
# - Add exception handling throughout (e.g., more in trace_object).
# - Apply format_value consistently.
#
#

"""Debugging functions (e.g., tracing)"""

# Standard packages
import atexit
from datetime import datetime
import enum
import inspect
from itertools import zip_longest
import logging
import os
from pprint import pprint
import re
## OLD: from xml.dom.minidom import Element
import six
import sys
import time

# Local packages
# note: The following redefines sys.version_info to be python3 compatible;
# this is used in _to_utf8, which should be reworked via six-based wrappers.
import mezcla.sys_version_info_hack      # pylint: disable=unused-import


# Constants for pre-defined tracing levels
#
class TraceLevel(enum.IntEnum):
    """Constants for use in tracing"""
    ALWAYS = 0
    ERROR = 1
    WARNING = 2                         # typically always shown
    DEFAULT = WARNING
    USUAL = 3                           # usual in sense of debugging purposes
    DETAILED = 4
    VERBOSE = 5
    QUITE_DETAILED = 6                  # detailed I/O
    QUITE_VERBOSE = 7
    MOST_DETAILED = 8
    MOST_VERBOSE = 9                    # for internal debugging
#
TL = TraceLevel
ALWAYS = TL.ALWAYS
ERROR = TL.ERROR
WARNING = TL.WARNING
DEFAULT = TL.DEFAULT
USUAL = TL.USUAL
DETAILED = TL.DETAILED
VERBOSE = TL.VERBOSE
QUITE_DETAILED = TL.QUITE_DETAILED
QUITE_VERBOSE = TL.QUITE_VERBOSE
MOST_DETAILED = TL.MOST_DETAILED
MOST_VERBOSE = TL.MOST_VERBOSE

# Other constants
UTF8 = "UTF-8"
STRING_TYPES = six.string_types
# note: INDENT0 is left margin and INDENT1 is normal indent
INDENT0 = ""
INDENT1 = "    "
INDENT = INDENT1
MISSING_LINE = "???"

# Globals
max_trace_value_len = 512

if __debug__:    

    # Initialize debug tracing level
    # TODO: mark as "private" (e.g., trace_level => _trace_level)
    DEBUG_LEVEL_LABEL = "DEBUG_LEVEL"
    trace_level = TL.DEFAULT            # typically same as TL.WARNING (2); TODO: global_trace_level
    output_timestamps = False           # prefix output with timestamp
    last_trace_time = time.time()       # timestamp from last trace
    use_logging = False                 # traces via logging (and stderr)
    debug_file = None                   # file for log output
    debug_file_hack = False             # work around concurrent writes by reopening after each trace
    para_mode_tracing = False           # multiline tracing adds blank line (e.g., for para-mode grep)
    #
    try:
        trace_level_text = os.environ.get(DEBUG_LEVEL_LABEL, "")
        if trace_level_text.strip():
            trace_level = int(trace_level_text)
    except:
        ## sys.stderr.write("Warning: Unable to set tracing level from {v}: {exc}\n".
        ##                  format(v=DEBUG_LEVEL_LABEL, exc=sys.exc_info()))
        pass


    def set_level(level):
        """Set new trace level"""
        global trace_level
        trace_level = level
        return


    def get_level():
        """Get current tracing level"""
        # Note: ensures result is integer (not enum)
        # EX: (get_level() >= 0)
        # EX: type(get_level() == int)
        ## OLD:
        ## ## global trace_level
        ## return trace_level
        level = 0
        try:
            ## OLD: assertion(isinstance(level, int))
            level = int(trace_level)
        except:
            _print_exception_info("get_level")
        return level

    def get_output_timestamps():
        """Return whether outputting timestamps"""
        return output_timestamps


    def set_output_timestamps(do_output_timestamps):
        """Enable for disable the outputting of timestamps"""
        global output_timestamps
        output_timestamps = do_output_timestamps


    def _to_utf8(text):
        """Convert TEXT to UTF-8 (e.g., for I/O)"""
        # Note: version like one from system.py to avoid circular dependency
        result = text
        if ((sys.version_info.major < 3) and (isinstance(text, unicode))):  # pylint: disable=undefined-variable
            result = result.encode("UTF-8", 'ignore')
        return result


    def _to_unicode(text, encoding=None):
        """Ensure TEXT in ENCODING is Unicode, such as from the default UTF8"""
        # TODO: rework from_utf8 in terms of this
        if not encoding:
            encoding = UTF8
        result = text
        if ((sys.version_info.major < 3) and (not isinstance(result, unicode))): # pylint: disable=undefined-variable
            result = result.decode(encoding, 'ignore')
        return result


    def _to_string(text):
        """Ensure TEXT is a string type"""
        result = text
        if (not isinstance(result, STRING_TYPES)):
            # Values are coerced using % operator for proper Unicode handling,
            # except for tuples which are converted recursively. This avoids a
            # type error due to arguments not being converted (e.g., second 
            # tuple constituent, etc.), as in ("%s" % (9, 1)).
            if isinstance(result, tuple):
                result = "(" + ", ".join([_to_string(v) for v in result]) + ")"
            else:
                result = "%s" % result
        return result

    def do_print(text, end=None):
        """Print TEXT to stderr and optionally to DEBUG_FILE"""
        print(text, file=sys.stderr, end=end)
        if debug_file:
            print(text, file=debug_file, end=end)
    
    def trace(level, text, empty_arg=None, no_eol=False, indentation=None):
        """Print TEXT if at trace LEVEL or higher, including newline unless SKIP_NEWLINE"""
        # TODO: add option to use format_value
        # Note: trace should not be used with text that gets formatted to avoid
        # subtle errors
        ## DEBUG: sys.stderr.write("trace({l}, {t})\n".format(l=level, t=text))
        if (trace_level >= level):
            if indentation is None:
                indentation = INDENT0
            # Prefix trace with timestamp w/o date
            if output_timestamps:
                # Get time-proper from timestamp (TODO: find standard way to do this)
                timestamp_time = re.sub(r"^\d+-\d+-\d+\s*", "", timestamp())
                if detailed_debugging():
                    global last_trace_time
                    diff = round(1000.0 * (time.time() - last_trace_time), 3)
                    timestamp_time += f" diff={diff}ms"
                    last_trace_time = time.time()
                do_print(indentation + "[" + timestamp_time + "]", end=": ")
            # Print trace, converted to UTF8 if necessary (Python2 only)
            # TODO: add version of assertion that doesn't use trace or trace_fmtd
            ## TODO: assertion(not(re.search(r"{\S*}", text)))
            end = "\n" if (not no_eol) else ""
            do_print(indentation + _to_utf8(text), end=end)
            if use_logging:
                # TODO: see if way to specify logging terminator
                logging.debug(indentation + _to_utf8(text))
            if debug_file_hack:
                reopen_debug_file()
        if empty_arg is not None:
            sys.stderr.write("Error: trace only accepts two positional arguments (was trace_expr intended?)\n")
        return


    def trace_fmtd(level, text, **kwargs):
        """Print TEXT with formatting using optional format KWARGS if at trace LEVEL or higher, including newline"""
        # Note: To avoid interpolated text as being interpreted as variable
        # references, this function does the formatting.
        # TODO: weed out calls that use (level, text.format(...)) rather than (level, text, ...)
        if (trace_level >= level):
            max_len = kwargs.get('_max_len') or kwargs.get('max_len')
            try:
                try:
                    # TODO: add version of assertion that doesn't use trace or trace_fmtd
                    ## TODO: assertion(re.search(r"{\S*}", text))
                    ## OLD: assertion("{" in text)
                    ## OLD: trace(level, text.format(**kwargs))
                    ## OLD: kwargs_unicode = {k: _to_unicode(_to_string(v)) for (k, v) in list(kwargs.items())}
                    kwargs_unicode = {k: format_value(_to_unicode(_to_string(v)), max_len=max_len)
                                      for (k, v) in list(kwargs.items())}
                    trace(level, _to_unicode(text).format(**kwargs_unicode))
                except(KeyError, ValueError, UnicodeEncodeError):
                    raise_exception(max(VERBOSE, level + 1))
                    sys.stderr.write("Warning: Problem in trace_fmtd: {exc}\n".
                                     format(exc=sys.exc_info()))
                    # Show arguments so trace contents recoverable
                    sys.stderr.write("   text=%r\n" % _to_utf8(clip_value(text)))
                    ## OLD: kwargs_spec = ", ".join(("%s:%r" % (k, clip_value(v))) for (k, v) in kwargs.iteritems())
                    kwargs_spec = ", ".join(("%s:%r" % (k, clip_value(v))) for (k, v) in list(kwargs.items()))
                    sys.stderr.write("   kwargs=%s\n" % _to_utf8(kwargs_spec))
            except(AttributeError):
                # Note: This can occur when profile_function set
                raise_exception(max(VERBOSE, level + 1))
                sys.stderr.write("Error: Unexpected problem in trace_fmtd: {exc}\n".
                                 format(exc=sys.exc_info()))
        return


    STANDARD_TYPES = (int, float, dict, list)
    SIMPLE_TYPES = (bool, int, float, type(None), str)
    #
    def trace_object(level, obj, label=None, show_all=None, show_private=None, show_methods_etc=None, indentation=None, pretty_print=None, max_value_len=max_trace_value_len, max_depth=0, regular_standard=False):
        """Trace out OBJ's members to stderr if at trace LEVEL or higher.
        Note: Optionally uses output LABEL, with INDENTATION, SHOWing_ALL members, and PRETTY_PRINTing.
        TODO: Use SHOW_PRIVATE to display private members and SHOW_METHODS_ETC for methods.
        Unless REGULAR_STANDARD, object like lists and dicts treated specially.
        If MAX_DEPTH > 0, this uses recursion to show values for instance members."""
        # HACK: Members for STANDARD_TYPES omitted unless show_all.
        # TODO: Make REGULAR_STANDARD True by default
        # Notes:
        # - This is intended for arbitrary objects, use trace_values for objects known to be lists or hashes.
        # - Support for show_private and show_methods_etc is not yet implemented (added for sake of tpo_common.py).
        # - See https://stackoverflow.com/questions/383944/what-is-a-python-equivalent-of-phps-var-dump.
        # TODO: support recursive trace; specialize show_all into show_private and show_methods
        # TODO: handle tuples
        ##                                       r=(trace_level < level)))
        trace_fmt(MOST_VERBOSE, "trace_object({dl}, {obj}, label={lbl}, show_all={sa}, indent={ind}, pretty={pp}, max_d={md})",
                  dl=level, obj=object, lbl=label, sa=show_all, ind=indentation, pp=pretty_print, md=max_depth)
        if (trace_level < level):
            return
        if (pretty_print is None):
            pretty_print = (trace_level > level)
        type_id_label = str(type(obj)) + " " + hex(id(obj))
        if label is None:
            ## BAD: label = str(type(obj)) + " " + hex(hash(obj))
            ## OLD: label = str(type(obj)) + " " + hex(id(obj))
            label = type_id_label
        elif verbose_debugging():
            label += " [" + type_id_label + "]"
        else:
            pass
        outer_indentation = ""
        if indentation is None:
            indentation = INDENT1
        else:
            # TODO: rework via indent_level arg
            outer_indentation = indentation[:len(indentation)-len(INDENT)]
        if show_all is None:
            show_all = (show_private or show_methods_etc)
        if para_mode_tracing:
            trace(ALWAYS, "")
        trace(ALWAYS, outer_indentation + label + ": {")
        ## OLD: for (member, value) in inspect.getmembers(obj):
        member_info = []
        try:
            member_info = inspect.getmembers(obj)
        except:
            trace_fmtd(QUITE_VERBOSE, "Warning: Problem getting member list in trace_object: {exc}",
                       exc=sys.exc_info())
        ## HACK: show standard type value as special member
        if (isinstance(obj, STANDARD_TYPES) and (not regular_standard)):
            member_info = [("(value)", obj)] + [(("__(" + m + ")__"), v) for (m, v) in member_info]
            trace_fmtd(QUITE_VERBOSE, "{ind}Special casing standard type as member {m}",
                       ind=indentation, m=member_info[0][0])
        for (member, value) in member_info:
            # If high trace level, output the value as is
            # TODO: value = clip_text(value)
            trace_fmtd(MOST_DETAILED, "{i}{m}={v}; type={t}", i=indentation, m=member, v=value, t=type(value))
            value_spec = format_value(value, max_len=max_value_len)
            if (trace_level >= MOST_VERBOSE):
                do_print(indentation + member + ": ", end="")
                if pretty_print:
                    pprint(value_spec, stream=sys.stderr)
                    if debug_file:
                        pprint(value_spec, stream=debug_file)
                else:
                    do_print(value_spec)
                if use_logging:
                    logging.debug(_to_utf8((indentation + member + ": " + value_spec)))
                continue
            # Include unless special member (or if no filtering)
            ## DEBUG: trace_expr(QUITE_VERBOSE, member.startswith("__"), re.search(r"^<.*(method|module|function).*>$", value_spec))
            include_member = (show_all or (not (member.startswith("__") or 
                                                re.search(r"^<.*(method|module|function).*>$", value_spec))))
            # Optionally, process recursively (TODO: make INDENT an env. option)
            is_simple_type = isinstance(value, SIMPLE_TYPES)
            if ((max_depth > 0) and include_member and (not is_simple_type)):
                # TODO: add helper for formatting type & address (for use here and above)
                member_type_id_label = (member + " [" + str(type(value)) + " " + hex(id(value)) + "]")
                trace_object(level, value, label=member_type_id_label, show_all=show_all,
                             indentation=(indentation + INDENT), pretty_print=None,
                             max_depth=(max_depth - 1), max_value_len=max_value_len,
                             regular_standard=regular_standard)
                continue
            # Otherwise, derive value spec. (trapping for various exceptions)
            ## TODO: pprint.pprint(member, stream=sys.stderr, indent=4, width=512)
            try:
                try:
                    ## OLD: value_spec = format_value("%r" % ((value),), max_len=max_value_len)
                    if is_simple_type and not isinstance(value, str):
                        value_spec = value
                    else:
                        value_spec = format_value("%r" % ((value),), max_len=max_value_len)
                except(TypeError, ValueError):
                    trace_fmtd(QUITE_VERBOSE, "Warning: Problem in tracing member {m}: {exc}",
                               m=member, exc=sys.exc_info())
                    value_spec = "__n/a__"
            except(AttributeError):
                # Note: This can occur when profile_function set
                trace_fmtd(QUITE_VERBOSE, "Error: unexpected problem in trace_object: {exc}",
                           exc=sys.exc_info())
                value_spec = "__n/a__"
            if include_member:
                do_print(indentation + member + ": ", end="")
                if pretty_print:
                    # TODO: remove quotes from numbers and booleans
                    pprint(value_spec, stream=sys.stderr, indent=len(indentation))
                else:
                    do_print(_to_utf8(value_spec))
                if use_logging:
                    logging.debug(_to_utf8((indentation + member + ":" + value_spec)))
        trace(ALWAYS, indentation + "}")
        if para_mode_tracing:
            trace(ALWAYS, "")
        return


    def trace_values(level, collection, label=None, indentation=None, use_repr=None, max_len=None):
        """Trace out elements of array or hash COLLECTION if at trace LEVEL or higher"""
        trace_fmt(MOST_VERBOSE, "trace_values(dl, {coll}, label={lbl}, indent={ind})",
                  dl=level, lbl=label, coll=collection, ind=indentation)
        if (trace_level < level):
            return
        if para_mode_tracing:
            trace(ALWAYS, "")
        if not isinstance(collection, (list, dict)):
            if hasattr(collection, '__iter__'):
                trace(level + 1, "Warning: [trace_values] consuming iterator")
                collection = list(collection)
            else:
                trace(level + 1, "Warning: [trace_values] coercing input into list")
                collection = [collection]
        if indentation is None:
            indentation = INDENT1
        if label is None:
            ## BAD: label = str(type(collection)) + " " + hex(hash(collection))
            label = str(type(collection)) + " " + hex(id(collection))
            ## OLD: indentation = INDENT1
        if use_repr is None:
            use_repr = False
        trace(ALWAYS, label + ": {")
        keys_iter = list(collection.keys()) if isinstance(collection, dict) else range(len(collection))
        for k in keys_iter:
            try:
                value = format_value(_to_utf8(collection[k]))
                if use_repr:
                    value = repr(value)
                trace_fmtd(ALWAYS, "{ind}{k}: {v}", ind=indentation, k=k,
                           v=format_value(value, max_len=max_len))
            except:
                trace_fmtd(QUITE_VERBOSE, "Warning: Problem tracing item {k}",
                           k=_to_utf8(k), exc=sys.exc_info())
        trace(ALWAYS, indentation + "}")
        if para_mode_tracing:
            trace(ALWAYS, "")
        return


    def trace_expr(level, *values, **kwargs):
        """Trace each of the arguments (if at trace LEVEL or higher), using introspection
        to derive label for each expression. By default, the following format is used:
           expr1=value1; ... exprN=valueN
        Notes:
        - Warning: introspection fails to resolve expressions if statement split across lines.
        - For simplicity, the values are assumed to separated by ', ' (or expression _SEP)--barebones parsing applied.
        - Use DELIM to specify delimiter; otherwise '; ' used;
          if so, NO_EOL applies to intermediate values (EOL always used at end).
        - Use USE_REPR=False to use tracing via str instead of repr.
        - Use _KW_ARG for KW_ARG in case of conflict, as in following:
          trace_expr(DETAILED, term, _term="; ")
        - Use MAX_LEN to specify maximum value length.
        - Use PREFIX to specify initial trace output
        - See misc_utils.trace_named_objects for similar function taking string input, which is more general but harder to use and maintain"""
        trace_fmt(MOST_VERBOSE, "trace_expr({l}, a={args}, kw={kw}); debug_level={dl}",
                  l=level, args=values, kw=kwargs, dl=trace_level)
        ## DEBUG:
        ## trace_fmt(1, "(global_trace_level:{g} < level:{l})={v}",
        ##           g=trace_level, l=level, v=(trace_level < level))
        if (trace_level < level):
            # note: Short-circuits processing to avoid errors about known problem (e.g., under ipython)
            return
        # Note: checks alternative keyword first, so False ones not misintepretted
        sep = kwargs.get('_sep') or kwargs.get('sep')
        delim = kwargs.get('_delim') or kwargs.get('delim')
        no_eol = kwargs.get('_no_eol') or kwargs.get('no_eol')
        in_no_eol = no_eol
        use_repr = kwargs.get('_use_repr') or kwargs.get('use_repr')
        max_len = kwargs.get('_max_len') or kwargs.get('max_len')
        prefix = kwargs.get('_prefix') or kwargs.get('prefix')
        if sep is None:
            sep = ", "
        if no_eol is None:
            no_eol = (delim and ("\n" in delim))
        if delim is None:
            delim = "; "
            if in_no_eol is None:
                no_eol = True
        if use_repr is None:
            use_repr = True
        if prefix is None:
            prefix = ""
        trace(9, f"sep={sep!r}, del={delim!r}, noe={no_eol}, rep={use_repr}, len={max_len}, pre={prefix}")
        # Get symbolic expressions for the values
        # TODO: handle cases split across lines
        try:
            # TODO: rework introspection following icecream (e.g., using abstract syntax tree)
            caller = inspect.stack()[1]
            ## OLD: (_frame, filename, line_number, _function, _context, _index) = caller
            (_frame, filename, line_number, _function, context, _index) = caller
            trace(9, f"filename={filename!r}, context={context!r}")
            statement = read_line(filename, line_number).strip()
            if statement == MISSING_LINE:
                ## OLD: statement = str(context).replace(")\\n']", "")
                statement = str(context).replace("\\n']", "")
            # Extract list of argument expressions (removing optional comment)
            statement = re.sub(r"#.*$", "", statement)
            statement = re.sub(r"^\s*\S*trace_expr\s*\(", "", statement)
            # Remove trailing paren with optional semicolon
            statement = re.sub(r"\)\s*;?\s*$", "", statement)
            # Remove trailing comma (e.g., if split across lines)
            statement = re.sub(r",?\s*$", "", statement)
            # Skip first argument (level)
            ## BAD: expressions = statement.split(sep)[1:]
            expressions = re.split(", +", statement)[1:]
            trace(9, f"expressions={expressions!r}\nvalues={values!r}")
        except:
            trace_fmtd(ALWAYS, "Exception isolating expression in trace_vals: {exc}",
                       exc=sys.exc_info())
            expressions = []
        trace(level, prefix, no_eol=no_eol)
        for expression, value in zip_longest(expressions, values):
            try:
                # Exclude kwarg params
                match = re.search(r"^(\w+)=", str(expression))
                if (match and match.group(1) in kwargs):
                    continue
                assertion((not ((value is not None) and (expression is None))),
                          "Warning: Likely problem resolving expression text (try reworking trace_expr call)")
                value_spec = format_value(repr(value) if use_repr else value,
                                          max_len=max_len)
                trace(level, f"{expression}={value_spec}{delim}", no_eol=no_eol)
            except:
                trace_fmtd(ALWAYS, "Exception tracing values in trace_vals: {exc}",
                       exc=sys.exc_info())            
        ## OLD: if no_eol:
        if (no_eol and (delim != "\n")):
            trace(level, "", no_eol=False)
        return

    
    def trace_current_context(level=QUITE_DETAILED, label=None, 
                              show_methods_etc=False):
        """Traces out current context (local and global variables), with output
        prefixed by "LABEL context" (e.g., "current context: {\nglobals: ...}").
        Notes: By default the debugging level must be quite-detailed (6).
        If the debugging level is higher, the entire stack frame is traced.
        Also, methods are omitted by default."""
        frame = None
        if label is None:
            label = "current"
        try:
            frame = inspect.currentframe().f_back
        except (AttributeError, KeyError, ValueError):
            trace_fmt(VERBOSE, "Exception during trace_current_context: {exc}",
                      exc=sys.exc_info())
        if para_mode_tracing:
            trace(level, "")
        trace_fmt(level, "{label} context: {{", label=label)
        prefix = INDENT
        if (get_level() - level) > 1:
            trace_object((level + 2), frame, "frame", indentation=prefix,
                         show_all=show_methods_etc)
        else:
            trace_fmt(level, "frame = {f}", f=frame)
            if frame:
                trace_object(level, frame.f_globals, "globals", indentation=prefix,
                             show_all=show_methods_etc)
                trace_object(level, frame.f_locals, "locals", indentation=prefix,
                             show_all=show_methods_etc)
        trace(level, "}")
        if para_mode_tracing:
            trace(level, "")
        return


    ## TODO
    ## def trace_stack(level=VERBOSE):
    ##     """Output stack trace to stderr (if at trace LEVEL or higher)"""
    ##     system-ish.print_full_stack()
    ##     return


    def trace_exception(level, task):
        """Trace exception information regarding TASK (e.g., function) at LEVEL"""
        # Note: Conditional output version of system's print_exception_info.
        # ex: trace_exception(DETAILED, "tally_counts")
        trace_fmt(level, "Exception during {t}: {exc}".
                  format(t=task, exc=sys.exc_info()))
        # TODO: include full stack trace (e.g., at LEVEL + 2)
        ## system.trace_stack(level + 2)
        return

    
    def raise_exception(level=1):
        """Raise an exception if debugging (at specified trace LEVEL)"""
        # Note: For producing full stacktrace in except clause when debugging.
        # TODO: elaborate
        if __debug__ and (level <= trace_level):
            raise                       # pylint: disable=misplaced-bare-raise
        return


    def assertion(expression, message=None, assert_level=None):
        """Issue warning if EXPRESSION doesn't hold, along with optional MESSAGE
        Note:
        - Warning: introspection fails to resolve expression if split across lines.
        - This is a "soft assertion" that doesn't raise an exception (n.b., provided the test doesn't do so).
        - The optional ASSERT_LEVEL overrides use of ALWAYS.
        - Returns expression text or None if not triggered.
        """
        # EX: assertion((2 + 2) != 5)
        # TODO: have streamlined version using sys.write that can be used for trace and trace_fmtd sanity checks about {}'s
        # TODO: trace out local and globals to aid in diagnosing assertion failures; ex: add automatic tarcing of variables used in the assertion expression)
        expression_text = None
        if (assert_level is None):
            assert_level = ALWAYS
        if (trace_level < assert_level):
            # note: Short-circuits processing to avoid extraneous warnings (e.g., trace_expr under ipython)
            return expression_text
        if (not expression):
            try:
                # Get source information for failed assertion
                trace_fmtd(MOST_VERBOSE, "Call stack: {st}", st=inspect.stack())
                caller = inspect.stack()[1]
                ## OLD: (_frame, filename, line_number, _function, _context, _index) = caller
                (_frame, filename, line_number, _function, context, _index) = caller
                trace(8, f"filename={filename!r}, context={context!r}")
                # Read statement in file and extract assertion expression
                # TODO: handle #'s in statement proper (e.g., assertion("#" in text))
                statement = read_line(filename, line_number).strip()
                if statement == MISSING_LINE:
                    ## OLD: statement = str(context).replace(")\\n']", "")
                    statement = str(context).replace("\\n']", "")
                # Format expression and message
                # note: removes comments, along with the assertion call prefix and suffix
                statement = re.sub("#.*$", "", statement)
                statement = re.sub(r"^(\S*)assertion\(", "", statement)
                expression = re.sub(r"\);?\s*$", "", statement)
                expression = re.sub(r",\s*$", "", statement)
                expression_text = expression
                qualification_spec = (": " + message) if message else ""
                # Output information
                # TODO: omit subsequent warnings
                trace_fmtd(ALWAYS, "Assertion failed: {expr} (at {file}:{line}){qual}",
                           expr=expression, file=filename, line=line_number, qual=qualification_spec)
            except:
                trace_fmtd(ALWAYS, "Exception formatting assertion: {exc}",
                           exc=sys.exc_info())
                trace_object(ALWAYS, inspect.currentframe(), "caller frame", pretty_print=True)
        return expression_text

    def val(level, value):
        """Returns VALUE if at trace LEVEL or higher otherwise None
        Note: inspired by Lisp's convenient IF form without an explicit else: (if test value-if-true)"""
        # EX: (101 if ((get_level() == 1) and val(1, 101)) else None) => 101
        # EX: ((not __debug__) and val(trace_level, 101))) => None
        # TODO: rename as cond_value???
        return (value if (trace_level >= level) else None)


    def code(level, no_arg_function):
        """Execute NO_ARG_FUNCTION if at trace LEVEL or higher
        Notes:
        - Use call() for more flexible invocation (e.g., can avoid lambda function)
        - Given the quirks of Python syntax, a two-step process is required:
           debug.code(4, { line1; line2; ...; lineN })
               =>
           def my_stupid_block_workaround(): 
               if __debug__:
                   line1; line2; ...; lineN
           debug.code(4, my_stupid_block_workaround)
        - Lambda functions can be used for simple expression-based functions"""
        trace(VERBOSE, f"code({level}, {no_arg_function})")
        result = None
        if (trace_level >= level):
            trace(QUITE_DETAILED, f"Executing {no_arg_function}")
            result = no_arg_function()
        return result

    
    def call(level, function, *args, **kwargs):
        """Invoke FUNCTION with ARGS and KWARGS if at trace LEVEL or higher
        Note: Use code() for simpler invocation (e.g., via lambda function)
        """
        trace(VERBOSE, f"call({level}, {function}, a={args}, kw={kwargs})")
        result = None
        if (trace_level >= level):
            trace(QUITE_DETAILED, f"Executing {function}")
            result = function(*args, **kwargs)
        return result

else:

    trace_level = 0
    
    def non_debug_stub(*_args, **_kwargs):
        """Non-debug stub (i.e., no-op function)"""
        # Note: no return value assumed by debug.expr
        return


    def get_level():
        """Returns tracing level (i.e., 0)"""
        return trace_level


    def get_output_timestamps():
        """Non-debug stub"""
        return False


    set_output_timestamps = non_debug_stub

    trace = non_debug_stub

    trace_fmtd = non_debug_stub

    trace_object = non_debug_stub

    trace_values = non_debug_stub
    
    trace_expr = non_debug_stub
    
    trace_current_context = non_debug_stub

    trace_exception = non_debug_stub
    
    raise_exception = non_debug_stub
    
    assertion = non_debug_stub

    code = non_debug_stub

    call = non_debug_stub

    ## TODO?:
    ## val = non_debug_stub
    ##
    def val(_expression):
        """Non-debug stub for value()--a no-op function"""
        # Note: implemented separately from non_debug_stub to ensure no return value
        return
    ##
    ## OLD: assert val(1) is None, "non-debug val() should not return a non-Null value"
    if val(1) is None:
        system.print_error("Warning: non-debug val() should return Null")

# Aliases for terse functions
    
cond_code = code

cond_val = val
    
# note: adding alias for trace_fmtd to account for common typo
# TODO: alias trace to trace_fmt as well (add something like trace_out if format not desired)
trace_fmt = trace_fmtd

def debug_print(text, level):
    """Wrapper around trace() for backward compatibility
    Note: debug_print will soon be deprecated."""
    return trace(level, text)


def timestamp():
    """Return timestamp for use in logging, etc."""
    return (str(datetime.now()))
    

## OLD: def debugging(level=ERROR):
def debugging(level=USUAL):
    """Whether debugging at specified trace LEVEL (e.g., 3 for usual)"""
    ## BAD: """Whether debugging at specified trace level, which defaults to {l}""".format(l=ERROR)
    ## NOTE: Gotta hate python/pylint (no warning about docstring)
    ## TODO: use level=WARNING (i.e., 2)
    return (get_level() >= level)


def detailed_debugging():
    """Whether debugging with trace level DETAILED (4) or higher"""
    ## BAD: """Whether debugging with trace level at or above {l}""".format(l=DETAILED)
    return (get_level() >= DETAILED)


def verbose_debugging():
    """Whether debugging with trace level VERBOSE (5) or higher"""
    ## BAD: """Whether debugging with trace level at or above {l}""".format(l=VERBOSE)
    return (get_level() >= VERBOSE)


def _getenv_bool(name, default_value):
    """Version of system.getenv_bool w/o tracing"""
    ## EX: os.setenv("FU", "1"); _getenv_bool("FU", False)) => True
    result = default_value
    if (str(os.environ.get(name) or default_value).upper() in ["1", "TRUE"]):
        result = True
    return result


def _getenv_int(name, default_value):
    """Version of system.getenv_int w/o tracing"""
    result = default_value
    try:
        env_value = os.environ.get(name)
        if env_value is not None:
            result = int(env_value)
    except:
        _print_exception_info("_getenv_int")
    return result


def format_value(value, max_len=None, strict=None):
    """Format VALUE for output with trace_values, etc.: truncates if too long and encodes newlines
    Note: With STRICT, MAX_LEN is maximum length for returned string (i.e., including "...") unless OLD_MAX_SPEC
    """
    # EX: format_value("    \n\n\n\n", max_len=11) => "    \\n\\n..."
    # EX: format_value("fubar", max_len=3) => "fub..."
    # EX: format_value("fubar", max_len=3, strict=True) => "..."
    # TODO2: rework with result determined via repr
    trace(1 + MOST_VERBOSE, f"format_value({value!r}, max_len={max_len})")
    if max_len is None:
        max_len = max_trace_value_len
    if strict is None:
        strict = False
    result = value if isinstance(value, str) else str(value)
    result = re.sub("\n", r"\\n", result)
    ellipsis = "..."
    extra = (len(result) - max_len)
    if (extra <= 0):
        pass
    elif not strict:
        result = result[:-extra] + ellipsis
    else:
        l = 2 + MOST_VERBOSE
        trace(l, f"0. {result!r}")
        extra2 = 0
        if (len(result) - extra + len(ellipsis) > max_len):
            extra2 = (len(result) - extra + len(ellipsis) - max_len)
        trace_expr(l, extra, extra2)
        result = result[:-(extra + extra2)]
        trace(l, f"1. {result!r}")
        result += ellipsis
        trace(l, f"2. {result!r}")
        result = result[:max_len]
        trace(l, f"3. {result!r}")
        assertion(len(result) <= max_len)
    trace(MOST_VERBOSE, f"format_value() => {result!r}")
    return result


def xor(value1, value2):
    """Whether VALUE1 and VALUE2 differ when interpretted as booleans"""
    # Note: Used to clarify assertions; same as bool(value1) != bool(value2).
    # See https://stackoverflow.com/questions/432842/how-do-you-get-the-logical-xor-of-two-variables-in-python
    # EX: not(xor(0, 0.0))
    result = (bool(value1) ^ bool(value2))
    trace_fmt(QUITE_VERBOSE, "xor({v1}, {v2}) => {r}", v1=value1, v2=value2, r=result)
    return result


def xor3(value1, value2, value3):
    """Whether one and only one of VALUE1, VALUE2, and VALUE3 are true"""
    ## result = (xor(value1, xor(value2m value3))
    ##           and not (bool(value1) and bool(value2) and bool(value3)))
    num_true = sum(int(bool(v)) for v in [value1, value2, value3])
    result = (num_true == 1)
    trace_fmt(QUITE_VERBOSE, "xor3({v1}, {v2}, {v3}) => {r}",
              v1=value1, v2=value2, v3=value3, r=result)
    return result


def init_logging():
    """Enable logging with INFO level by default or with DEBUG if detailed debugging"""
    trace(DETAILED, "init_logging()")
    trace_object(QUITE_DETAILED, logging.root, "logging.root")

    # Set the level for the current module
    # TODO: use mapping from symbolic LEVEL user option (e.g., via getenv)
    level = logging.DEBUG if detailed_debugging() else logging.INFO
    trace_fmt(VERBOSE, "Setting logger level to {ll}", ll=level)
    logging.basicConfig(format='%(asctime)s : %(levelname)s : %(message)s', level=level)
    logging.debug("init_logging()")

    # Optionally make sure logging level applied globally
    if _getenv_bool("GLOBAL_LOGGING", False):
        old_level = logging.root.level
        trace_fmt(VERBOSE, "Setting root logger level from {ol} to {nl}", ol=old_level, nl=level)
        logging.root.setLevel(level)
    return


def _print_exception_info(task):
    """Output exception information to stderr regarding TASK (e.g., function)"""
    # Note: non-tracing version of system's print_exception_info
    sys.stderr.write("Error during {t}: {exc}\n".
                     format(t=task, exc=sys.exc_info()))
    return


def profile_function(frame, event, arg):
    """Function for monitoring function entry and exit (FEE), etc., currently just tracing at level 4. See sys.setprofile.
    # Note: Use a package like viztracer for non-trivial monitoring"""
    # Based on dependency-checking code in PyTorch. See
    #   https://fossies.org/linux/pytorch/torch/package/analyze/trace_dependencies.py.
    # This tries to determine the name of the module that the function is in:
    # 1) Check the global namespace of the frame.
    # 2) Check the local namespace of the frame.
    # 3) To handle class instance method calls, check the attribute named 'name'
    #    of the object in the local namespace corresponding to "self".
    # TODO:
    # - Make tracing level an option (e.g., environment).
    trace_fmt(QUITE_DETAILED, "profile_function(_, {e}, {a})", e=event, a=arg)
    trace_object(QUITE_VERBOSE, frame, "frame")

    # Resolve the names for the function (callable) and module
    name = "???"
    module = "???"
    try:
        name = frame.f_code.co_name
        if name in frame.f_globals:
            module = frame.f_globals[name].__module__
        elif name in frame.f_locals:
            module = frame.f_locals[name].__module__
        elif "self" in frame.f_locals:
            method = getattr(frame.f_locals["self"], name, None)
            module = method.__module__ if method else None
        else:
            trace(QUITE_VERBOSE, "Unable to resolve module")
    except:
        _print_exception_info("profile_function")

    # Trace out the call (with other information at higher tracing levels)
    if event.endswith("call"):
        trace_fmt(DETAILED, "in: {mod}:{func}({a})", mod=module, func=name, a=arg)
    elif event.endswith("return"):
        trace_fmt(DETAILED, "out: {mod}:{func} => {a}", mod=module, func=name, a=arg)
    else:
        trace_fmt(VERBOSE, "profile {mod}:{func} {e}: arg={a}",
                  mod=module, func=name, e=event, a=arg)
    return

def reference_var(*args):
    """No-op function used for referencing variables in ARGS"""
    trace(MOST_VERBOSE, f"reference_var{tuple(args)}")
    return

#-------------------------------------------------------------------------------
# Utility functions useful for debugging (e.g., for trace output)

# TODO: CLIPPED_MAX = system-ish.getenv_int("CLIPPED_MAX", 132)
CLIPPED_MAX = 132
#
def clip_value(value, max_len=CLIPPED_MAX):
    """Return clipped version of VALUE (e.g., first MAX_LEN chars)"""
    # TODO3: replace with format_value
    # TODO: omit conversion to text if already text [DUH!]
    clipped = "%s" % value
    if (len(clipped) > max_len):
        clipped = clipped[:max_len] + "..."
    return clipped

def read_line(filename, line_number):
    """Returns contents of FILENAME at LINE_NUMBER
    Note: returns '???' upon exception
    """
    # ex: "debugging" in read_line(os.path.join(os.getcwd(), "debug.py"), 3)
    # TODO: use rare Unicode value instead of "???"
    try:
        file_handle = open(filename, encoding="UTF-8")
        line_contents = (list(file_handle))[line_number - 1]
        file_handle.close()
    except:
        line_contents = MISSING_LINE
    return line_contents

#-------------------------------------------------------------------------------

def main(args):
    """Supporting/ code for command-line processing"""
    trace_expr(DETAILED, len(args))
    trace(ERROR, "FYI: Not intended for direct invocation. Some tracing examples follow.")
    #
    trace(ALWAYS, "date record for now at trace level 1")
    trace_object(ERROR, datetime.now(), label="now")
    trace(DETAILED, "stack record with max depth 1")
    trace_object(DETAILED, inspect.stack(), label="stack", max_depth=1)
    #
    # Make sure trace_expr traces at proper tracing level
    trace(ALWAYS, "level=N         for N from 0..trace_level ({l})".
          format(l=trace_level))
    for level in range(trace_level):
        level_value = level
        trace_expr(level, level_value)
    #
    # Maker sure trace_expr gets all arguments
    trace(ALWAYS, "n-i=N-i         for N=trace_level ({l}) and i from 1..-1".format(l=trace_level))
    n = trace_level
    i = 1
    ## TODO: for i in range(3, 0, -1):
    trace_expr(ERROR, n+i, n, n+i)
    return

# Do debug-only processing (n.b., for when PYTHONOPTIMIZE not set)
# Note: wrapped in function to keep things clean

if __debug__:

    def open_debug_file():
        """Open external file for copy of trace output"""
        trace(5, "open_debug_file()")
        global debug_file
        assertion(debug_file is None)

        # Open the file
        debug_filename = os.getenv("DEBUG_FILE")
        if debug_filename is not None:
            ## OLD: debug_file = open(debug_filename, mode="w", encoding="UTF-8")
            ## TEST: open unbuffered which requires binary output mode
            ## BAD: debug_file = open(debug_filename, mode="wb", buffering=0, encoding="UTF-8")
            ## note: uses line buffering
            ## OLD: for_append = _getenv_bool("DEBUG_FILE_APPEND", False) or _getenv_bool("DEBUG_FILE_HACK", False)
            for_append = _getenv_bool("DEBUG_FILE_APPEND", True)
            mode = ("a" if for_append else "w")
            trace_expr(5, mode)
            debug_file = open(debug_filename, mode=mode, buffering=1, encoding="UTF-8")
        trace_fmtd(VERBOSE, "debug_filename={fn} debug_file={f}",
                   fn=debug_filename, f=debug_file)
        return

    def reopen_debug_file():
        """Re-open debug file to work around concurrent access issues
        Note: The debug file is mainly used with pytest to work around stderr tracing issues"""
        trace(5, "reopen_debug_file()")
        global debug_file
        assertion(debug_file is not None)

        # Close file if opened
        if debug_file:
            debug_file.close()
            debug_file = None

        # Open fresh
        open_debug_file()
        return
                        

    def debug_init():
        """Debug-only initialization"""
        time_start = time.time()
        trace(DETAILED, f"in debug_init(); {timestamp()}")
        # note: shows command invocation unless invoked via "python -c ..."
        command_line = " ".join(sys.argv)
        assertion(command_line)
        if (command_line and (command_line != "-c") and (command_line != "-m")):
            trace(USUAL, command_line)
        trace_expr(DETAILED, sys.argv)
        open_debug_file()

        # Determine whether tracing include time and date
        global output_timestamps
        ## OLD
        ## output_timestamps = (str(os.environ.get("OUTPUT_DEBUG_TIMESTAMPS", False)).upper()
        ##                      in ["1", "TRUE"])
        output_timestamps = _getenv_bool("OUTPUT_DEBUG_TIMESTAMPS", False)
    
        # Show startup time and tracing info
        module_file = __file__
        trace_fmtd(DETAILED, "[{f}] loaded at {t}", f=module_file, t=timestamp())
        trace_fmtd(DETAILED, "trace_level={l}; output_timestamps={ots}", l=trace_level, ots=output_timestamps)

        # Determine other debug-only environment options
        global para_mode_tracing
        para_mode_tracing = _getenv_bool("PARA_MODE_TRACING", para_mode_tracing)
        global max_trace_value_len
        max_trace_value_len = _getenv_int("MAX_TRACE_VALUE_LEN", max_trace_value_len)
        global use_logging
        use_logging = _getenv_bool("USE_LOGGING", use_logging)
        enable_logging = _getenv_bool("ENABLE_LOGGING", use_logging)
        if enable_logging:
            init_logging()
        monitor_functions = _getenv_bool("MONITOR_FUNCTIONS", False)
        if monitor_functions:
            sys.setprofile(profile_function)
        trace_expr(VERBOSE, para_mode_tracing, max_trace_value_len, use_logging, enable_logging, monitor_functions)

        # Show additional information when detailed debugging
        # TODO: sort keys to facilate comparisons of log files
        pre = post = ""
        if para_mode_tracing:
            pre = post = "\n"
        trace_fmt(DETAILED, "{pre}environment: {{\n\t{env}\n}}{post}",
                  env="\n\t".join([(k + ': ' + format_value(os.environ[k]))
                                   for k in sorted(dict(os.environ))]),
                  pre=pre, post=post)

        # Likewise show additional information during verbose debug tracing
        # Note: use debug.trace_current_context() in client module to show module-specific globals like __name__
        trace_expr(MOST_DETAILED, globals(), max_len=65536)

        # Register to show shuttdown time and elapsed seconds
        # TODO: rename to reflect generic-exit nature
        def display_ending_time_etc():
            """Display ending time information"""
            # note: does nothing if stderr closed (e.g., other monitor)
            # TODO: resolve pylint issue with sys.stderr.closed
            trace_object(QUITE_VERBOSE, sys.stderr)
            if sys.stderr.closed:       # pylint: disable=using-constant-test
                return
            elapsed = round(time.time() - time_start, 3)
            trace_fmtd(DETAILED, "[{f}] unloaded at {t}; elapsed={e}s",
                       f=module_file, t=timestamp(), e=elapsed)
            if monitor_functions:
                sys.setprofile(None)
            global debug_file
            if debug_file:
                debug_file.close()
                debug_file = None
        # note: atexit support is enabled by default unless DEBUG_FILE used (n.b., cleanup issues)
        skip_atexit = _getenv_bool("SKIP_ATEXIT", (debug_file is not None))
        trace_expr(4, skip_atexit)
        if not skip_atexit:
            atexit.register(display_ending_time_etc)
        
        return

    
    # Do the initialization
    debug_init()

#-------------------------------------------------------------------------------

trace_expr(MOST_VERBOSE, 888)
#
if __name__ == '__main__':
    main(sys.argv)
else:
    trace_expr(MOST_VERBOSE, 999)
