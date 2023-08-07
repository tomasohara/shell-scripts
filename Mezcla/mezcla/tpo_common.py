#! /usr/bin/env python
# tpo_common.py: Python module with common utilities mostly for debugging,
# mostly superceded by debug.py, system.py, and misc_util.py """
#
# sample usage:
#    from mezcla import tpo_common as tpo
#    tpo.debug_print("start: " + tpo.debug_timestamp(), 3)
#
#------------------------------------------------------------------------
#
# Note:
# - *** Obsolete: use system.py, debug.py, etc. instead.
# - Use Emacs's query-replace-regexp (e.g., via M-#) to interative convert debug_format to debug.trace_fmt: 
#     from: debug_format(\(\"[^\"]*\"\), \([0-9]*\),
#       to: debug.trace_fmt(\2, \1,")
# - The TPO prefix was used originally to avoid conflicts. Some of the older scripts
#   rely upon this, but it will be eventually phased out.
# - This redefines some built-in functions (e.g., format and exit), so
#   you shouldn't import using 'import *'.
# - Debugging output and error messages are converted to UTF8 before output
#   via s=unicode(s, "utf8"), which is same as s=codecs.encode(s, "utf8").
# - Debugging code is "conditionally compiled" to avoid overhead of passing
#   arguments to functions that do nothing in release code.
# - Includes support for overriding stderr (e.g., for use with embedded apps as in adhoc/optimize_company_extraction.py's invocation of extract_company_info.py).
#
# TODO:
# - Change all functions to using docstrings for comments already!!!
# - Add support for using pprint module
# - Put a version of assertion() here (i.e., from glue_helpers.py).
# - Extend getenv support to indicate user-vs-devel options.
# - Remove obsolete functions (e.g., get_current_function_name).
# - Use debug_trace in place of debug_print in code run often.
#
#------------------------------------------------------------------------
#

"""Common utility functions"""

# Load required libraries
#
# - For Debugging timestamp purposes (e.g., OUTPUT_DEBUG_TIMESTAMPS support)
## OLD:
## from datetime import datetime
## import atexit
#
# - The usuals:
import sys
import os
import re
# - Others
import inspect
import logging
import pickle
from six import string_types
## OLD: import time
## OLD: import types

# Load OrderedDict (added in Python 2.7)                                       
try:
    from collections import OrderedDict
except ImportError:
    try:
        from ordereddict import OrderedDict
    except ImportError:
        def OrderedDict():
            """Legacy stub"""
            assert False, "requires ordereddict package (or python 2.7+)"

# Local packages
from mezcla import debug
from mezcla.debug import trace_level as debug_level
from mezcla import system
            
# Defaults for globals
## OLD:
## debug_level = 0                          # level at which debug tracing occurs
## output_timestamps = False                # whether to prefix output with timestamp
## use_logging = False                      # traces via logging facility (and stderr)
skip_format_warning = False              # skip warning about format w/o namespace
stderr = sys.stderr                      # file handle for error messages 

# Constants for use with debug_print, etc.
LEVEL1 = 1
LEVEL2 = 2
LEVEL3 = 3
LEVEL4 = 4
LEVEL5 = 5
LEVEL6 = 6
# Aliases for debugging levels (by convention)
ALWAYS = 0
CRITICAL = ALWAYS
ERROR = 1
WARNING = 2
USUAL = 3
DETAILED = 4
VERBOSE = 5
QUITE_DETAILED = 6
QUITE_VERBOSE = 7
DEFAULT_DEBUG_LEVEL = ALWAYS

# Other constants
# TODO: use sys.version_info.major, etc.
USE_SIMPLE_FORMAT = (sys.version_info[0] <= 2) and (sys.version_info[1] <= 5)

#------------------------------------------------------------------------
# Debugging functions
#
# Notes:
# - These are no-op's unless __debug__ is True.
# - Running python with the -O (optimized) option ensures that __debug__ is False.
#

## OLD:
## if __debug__:
## 
##     def set_debug_level(level):
##         """Set new debugging LEVEL"""
##         global debug_level
##         debug_level = level
##         return
## 
## 
##     def debugging_level():
##         """Get current debugging level"""
##         global debug_level
##         return debug_level
## 
## 
##     def debug_trace_without_newline(text, *args, **kwargs):
##         """Print TEXT without trailing newline, provided at debug trace LEVEL or higher, using ARGS for %-placeholders
##         Notes: ensures text encoded as UTF8 if under Python 2.x;
##         also, exceptions are ignored (to encourage more tracing)."""
##         # Warning: To avoid recursion don't call other user functions here unless
##         # they don't uses tracing (e.g., _normalize_unicode).
##         # TODO: work out shorter name (e.g., debug_trace_no_eol)
##         #
##         global debug_level
##         level = kwargs.get('level', 1)
##         if debug_level >= level:
##             if debug_level >= 96:
##                 stderr.write("debug_trace_without_newline(text=%s, level=%s, args=%s)" % 
##                              (_normalize_unicode(text), level, [_normalize_unicode(v) for v in args]))
##             if args:
##                 try:
##                     text = (text % args)
##                 except (AttributeError, IndexError, NameError, TypeError, ValueError):
##                     print_stderr("Exception in debug_print: " + str(sys.exc_info()))
##                     
##             # Output optional timestamp (e.g., for quick-n-dirty profiling)
##             if output_timestamps:
##                 # Get time-proper from timestamp (TODO: find standard way to do this)
##                 # TODO: make date-stripping optional
##                 timestamp = re.sub(r"^\d+-\d+-\d+\s*", "", debug_timestamp())
##                 stderr.write("[%s] " % timestamp)
##             # Output text, making sure text represented in UTF8 if needed (n.b., via inlined ensure_unicode)
##             text = _normalize_unicode(text)
##             stderr.write(text)
##             if use_logging:
##                 logging.debug(text)
##             ##
##             ## # Sanity check to ensure no instantiatable templates used in text
##             ## # TODO: rework debug_print to safely handle templates by default
##             ## while True:
##             ##     #                   +-pre--++---variable----++--rest-----+
##             ##     match = re.search(r"(^|[^{])({[A-Za-z0-9_]+})(([^}]|$|).*)", text)
##             ##     if not match:
##             ##         break
##             ##     text = match.group(3)
##             ##     var_format = match.group(2)
##             ##     if format(var_format, True, True) != var_format:
##             ##         print_stderr("Warning: template used with instantiated variable; try debug_format instead")
##         return
## 
##     def debug_trace(text, *args, **kwargs):
##         """Prints TEXT (formatted with ARG1, ...) if at LEVEL or higher.
##         Note: To avoid needless evaluation arguments should be specified 
##         as distinct paramaters rather than using string format operator (%)."""
##         # Note: Implemented in terms of debug_trace_without_newline to keep timestamp support in one place.
##         # TODO: add skip_newline option
##         global debug_level
##         debug_trace_without_newline(text, *args, **kwargs)
##         level = kwargs.get('level', 1)
##         # TODO: assertion(isinstance(level, int))
##         if debug_level >= level:
##             stderr.write("\n")
##         return
## 
##     def debug_print_without_newline(text, level=1):
##         """Wrapper around debug_trace_without_newline (q.v.)
##         Note: Consider using debug_trace_without_newline directly."""
##         return debug_trace_without_newline(text, level=level)
## 
##     def debug_print(text, level=1, skip_newline=False):
##         """Print TEXT if at debug trace LEVEL or higher.
##         Notes:
##         - Implemented in terms of debug_print_without_newline to keep timestamp support in one place.
##         - Consider using debug_trace instead (to avoid string interpolation overhead)."""
##         # TODO: assertion(isinstance(level, int))
##         global debug_level
##         debug_trace_without_newline(text, level=level)
##         if (debug_level >= level) and (not skip_newline):
##             stderr.write("\n")
##         return
## 
## 
##     def debug_format(text, level=1, skip_newline=False, **namespace):
##         """Version of debug_print that expands TEXT using format.
##         Note: Exceptions are ignored (to encourage tracing, not discourage)."
##         """
##         # NOTE: String values from namespace need to be in UTF-8 format.
##         # TODO: rename as debug_print_format as not just formatting the text
##         global debug_level
##         assert(isinstance(level, int))
##         if debug_level >= level:
##             ignore_exc = (debug_level < QUITE_DETAILED)
##             debug_print(format(text, indirect_caller=True, 
##                                ignore_exception=ignore_exc, **namespace),
##                         skip_newline=skip_newline)
##         return
## 
## 
##     def debug_timestamp():
##         """Return timestamp for use in debugging traces"""
##         # EX: debug_timestamp() => "2015-01-18 16:39:45.224768"
##         # TODO: use format compatible with logging (e.g., comma in place of period before micrososeconds)
##         return to_string(datetime.now())
## 
## 
##     def debug_raise(level=1):
##         """Raise an exception if debugging at specified trace LEVEL or higher"""
##         # Note: Intended for use in except clause to produce full stacktrace when debugging.
##         # TODO: Have version that just prints complete stacktrace (i.e., without breaking).
##         if debug_level >= level:
##             raise                        # pylint: disable=misplaced-bare-raise
##         return
## 
## 
##     def trace_array(array, level=VERBOSE, label=None):
##         """Output the (list) array to STDERR if debugging at specified trace LEVEL or higher, using LABEL as prefix"""
##         global debug_level
##         assert(isinstance(level, int))
##         if debug_level >= level:
##             trace_output = ("%s: " % label) if label else ""
##             for i, item in enumerate(array):
##                 trace_output += "  " if (i > 0) else ""
##                 trace_output += "%d: %s" % (i, item)
##             debug_print(trace_output)
##         return
## 
## 
##     def trace_object(obj, level=VERBOSE, label=None, show_private=None, show_methods_etc=None, indent="", max_value_len=1024):
##         """Traces out OBJ instance to stderr if at debugging LEVEL or higher, 
##         optionally preceded by LABEL, using INDENT, and limiting value lengths to MAX_VALUE_LEN"""
##         # based on http://stackoverflow.com/questions/192109/is-there-a-function-in-python-to-print-all-the-current-properties-and-values-of
##         debug_format("trace_object(_, lvl={lvl}, lab={lab}, prv={prv}, mth={mth}, ind={ind})", 7,
##                      lvl=level, lab=label, prv=show_private, mth=show_methods_etc, ind=indent)
##         global debug_level
##         assert(isinstance(level, int))
##         if debug_level >= level:
##             debug_print("%s%s: {" % (indent, label if label else obj))
##             if show_private is None:
##                 show_private = (level >= 6)
##             if show_methods_etc is None:
##                 show_methods_etc = (level >= 7)
##             for attr in dir(obj):
##                 # Note: unable to filter properties directly (so try/except handling added)
##                 # See Take1 and Take2 below.
##                 try:
##                     ## TAKE2:
##                     ## if re.search("property|\?\?\?", str(getattr(type(obj), attr, "???"))):
##                     ##     debug_print("%s: property" % attr, 7)
##                     ##     continue
##                     # note: omits internal variables unless at debug level 6+; also omits methods unless at debug level 7+
##                     debug_print("%s\tattr: name: %s" % (indent, attr), 8)
##                     if (attr[0] != '_') or show_private:
##                         attr_value = getattr(obj, attr)
##                         debug_trace("%s\tattr: type: %s",
##                                     indent, type(attr_value), level=8)
##                         method_types = (
##                             types.MethodType, types.FunctionType, 
##                             types.BuiltinFunctionType, types.BuiltinMethodType,
##                             types.ModuleType)
##                         if ((not isinstance(attr_value, method_types))
##                                 or ("method-wrapper" not in str(type(attr_value)))
##                                 or show_methods_etc):
##                             if len(to_string(attr_value)) > max_value_len:
##                                 attr_value = to_string(attr_value)[:max_value_len] + "..."
##                             debug_print("%s\t%s = %r" % (indent, attr, attr_value))
##                 except (KeyError, ValueError, AttributeError):
##                     debug_print("%s\t%s = ???" % (indent, attr))
##             debug_print("%s}" % indent)
##         return
## 
## 
##     def trace_value(value, level=5, label=None):
##         """Traces out VALUE to stderr if at debugging LEVEL or higher with optional '<LABEL>: ' prefix.
##         @Note: If value is an array or dict, each entry is output on a separate line."""
##         global debug_level
##         assert(isinstance(level, int))
##         if debug_level >= level:
##             prefix = ""
##             value_spec = value
##             if label:
##                 prefix = ("%s: " % label)
##             if isinstance(value, list):
##                 value_spec = "{\n" + "\n".join(["\t%s: %s" % (i, v) for (i, v) in enumerate(value)]) + "}\n"
##             elif isinstance(value, dict):
##                 value_spec = "{\n"
##                 for key in value.keys():
##                     # Note: Exception handling used in case value access leads to error,
##                     # such as with hash tables having Mako placeholders for undefined values.
##                     try:
##                         key_value = value[key]
##                         debug_print("key=%s key_value=%s" % (key, key_value), 9)
##                     except NameError:
##                         print_stderr("Exception in trace_value getting value for key %s" % key)
##                         key_value = "n/a"
##                     value_spec += "\t%s: %s\n" % (key, key_value)
##                 value_spec += "}\n"
##             debug_print("%s%s" % (prefix, value_spec))
##         return
## 
## 
##     def trace_current_context(level=QUITE_DETAILED, label=None, 
##                               show_methods_etc=False):
##         """Traces out current context (local and global variables), with output
##         prefixed by "LABEL context" (e.g., "current context: {\nglobals: ...}").
##         Notes: By default the debugging level must be quite-detailed (6).
##         If the debugging level is higher, the entire stack frame is traced.
##         Also, methods are omitted by default."""
##         frame = None
##         if label is None:
##             label = "current"
##         try:
##             frame = inspect.currentframe().f_back
##         except (AttributeError, KeyError, ValueError):
##             debug_print("Exception during trace_current_context: " + 
##                         to_string(sys.exc_info()), 5)
##         debug_format("{label} context: {{", level, label=label)
##         prefix = "    "
##         if (debugging_level() - level) > 1:
##             trace_object(frame, (level + 2), "frame", indent=prefix,
##                          show_methods_etc=show_methods_etc)
##         else:
##             debug_format("frame = {f}", level, f=frame)
##             if frame:
##                 trace_object(frame.f_globals, level, "globals", indent=prefix,
##                              show_methods_etc=show_methods_etc)
##                 trace_object(frame.f_locals, level, "locals", indent=prefix,
##                              show_methods_etc=show_methods_etc)
##         debug_trace("}", level=level)
##         return
## 
## 
##     def during_debugging(expression=True):
##         """Returns True if debugging, optionally conditioned upon EXPRESSION
##          Note: The expression is not considered in non-debug mode"""
##         return (debugging_level() > 0) and expression
## 
## else:
## 
##     def set_debug_level(*_args, **_kwargs):
##         """Non-debug stub"""
##         pass
## 
## 
##     def debugging_level(*_args, **_kwargs):
##         """Non-debug stub"""
##         return 0
## 
## 
##     def debug_trace_without_newline(*_args, **_kwargs):
##         """Non-debug stub"""
##         pass
## 
## 
##     def debug_trace(*_args, **_kwargs):
##         """Non-debug stub"""
##         pass
## 
## 
##     def debug_print_without_newline(*_args, **_kwargs):
##         """Non-debug stub"""
##         pass
## 
## 
##     def debug_print(*_args, **_kwargs):
##         """Non-debug stub"""
##         pass
## 
## 
##     def debug_format(*_args, **_kwargs):
##         """Non-debug stub"""
##         pass
## 
## 
##     def debug_timestamp(*_args, **_kwargs):
##         """Non-debug stub"""
##         return ""
## 
## 
##     def debug_raise(*_args, **_kwargs):
##         """Non-debug stub"""
##         pass
## 
## 
##     def trace_array(*_args, **_kwargs):
##         """Non-debug stub"""
##         pass
## 
## 
##     def trace_object(*_args, **_kwargs):
##         """Non-debug stub"""
##         pass
## 
## 
##     def trace_value(*_args, **_kwargs):
##         """Non-debug stub"""
##         pass
## 
## 
##     def trace_current_context(*_args, **_kwargs):
##         """Non-debug stub"""
##         pass
## 
## 
##     def during_debugging(*_args, **_kwargs):
##         """Non-debug stub"""
##         return False
## 

def set_debug_level(level):
    """Set new debugging LEVEL"""
    return debug.set_level(level)


def debugging_level():
    """Get current debugging level"""
    return debug.get_level()


def debug_trace_without_newline(text, *args, **kwargs):
    """Print TEXT without trailing newline, provided at debug trace LEVEL or higher, using ARGS for %-placeholders
    Notes: ensures text encoded as UTF8 if under Python 2.x;
    also, exceptions are ignored (to encourage more tracing)."""
    level = kwargs.get('level', 1)
    if args:
        try:
            text = (text % args)
        except (AttributeError, IndexError, NameError, TypeError, ValueError):
            system.print_exception_info("debug_trace_without_newline")
    return debug.trace(level, text, no_eol=True)


def debug_trace(text, *args, **kwargs):
    """Prints TEXT (formatted with ARG1, ...) if at LEVEL or higher.
    Note: To avoid needless evaluation arguments should be specified 
    as distinct paramaters rather than using string format operator (%)."""
    return debug_trace_without_newline(text + "\n", *args, **kwargs)


def debug_print_without_newline(text, level=1):
    """Wrapper around debug_trace_without_newline (q.v.)
    Note: Consider using debug_trace_without_newline directly."""
    return debug_trace_without_newline(text, level=level)


def debug_print(text, level=1, skip_newline=False):
    """Print TEXT if at debug trace LEVEL or higher.
    Notes:
    - Implemented in terms of debug_print_without_newline to keep timestamp support in one place.
    - Consider using debug_trace instead (to avoid string interpolation overhead)."""
    # TODO: assertion(isinstance(level, int))
    out_text = (text if skip_newline else (text + "\n"))
    return debug_trace_without_newline(out_text, level=level)


def debug_format(text, level=1, skip_newline=False, **namespace):
    """Version of debug_print that expands TEXT using format.
    Note: Exceptions are ignored (to encourage tracing, not discourage)."
    """
    ## TODO: return debug.trace(no_eol=skip_newline, level, text, **namespace)
    # NOTE: String values from namespace need to be in UTF-8 format.
    # TODO: rename as debug_print_format as not just formatting the text
    assert(isinstance(level, int))
    if (debugging_level() >= level):
        ignore_exc = (debugging_level() < QUITE_DETAILED)
        debug_print(format(text, indirect_caller=True, 
                           ignore_exception=ignore_exc, **namespace),
                    skip_newline=skip_newline)
    return


def debug_timestamp():
    """Return timestamp for use in debugging traces"""
    # EX: debug_timestamp() => "2015-01-18 16:39:45.224768"
    # TODO: use format compatible with logging (e.g., comma in place of period before micrososeconds)
    return debug.timestamp()


def debug_raise(level=1):
    """Raise an exception if debugging at specified trace LEVEL or higher"""
    # Note: Intended for use in except clause to produce full stacktrace when debugging.
    # TODO: Have version that just prints complete stacktrace (i.e., without breaking).
    return debug.raise_exception(level)


def trace_array(array, level=VERBOSE, label=None):
    """Output the (list) array to STDERR if debugging at specified trace LEVEL or higher, using LABEL as prefix"""
    return debug.trace_values(level, array, label)


def trace_object(obj, level=VERBOSE, label=None, show_private=None, show_methods_etc=None, indent="", max_value_len=1024):
    """Traces out OBJ instance to stderr if at debugging LEVEL or higher, 
    optionally preceded by LABEL, using INDENT, and limiting value lengths to MAX_VALUE_LEN"""
    return debug.trace_object(level, obj, label, show_private=show_private, show_methods_etc=show_methods_etc, indentation=indent, max_value_len=max_value_len)


def trace_value(value, level=5, label=None):
    """Traces out VALUE to stderr if at debugging LEVEL or higher with optional '<LABEL>: ' prefix.
    @Note: If value is an array or dict, each entry is output on a separate line."""
    assert(isinstance(level, int))
    if (debugging_level() >= level):
        prefix = ""
        value_spec = value
        if label:
            prefix = ("%s: " % label)
        if isinstance(value, list):
            value_spec = "{\n" + "\n".join(["\t%s: %s" % (i, v) for (i, v) in enumerate(value)]) + "}\n"
        elif isinstance(value, dict):
            value_spec = "{\n"
            for key in value.keys():
                # Note: Exception handling used in case value access leads to error,
                # such as with hash tables having Mako placeholders for undefined values.
                try:
                    key_value = value[key]
                    debug_print("key=%s key_value=%s" % (key, key_value), 9)
                except NameError:
                    print_stderr("Exception in trace_value getting value for key %s" % key)
                    key_value = "n/a"
                value_spec += "\t%s: %s\n" % (key, key_value)
            value_spec += "}\n"
        debug_print("%s%s" % (prefix, value_spec))
    return


def trace_current_context(level=QUITE_DETAILED, label=None, 
                          show_methods_etc=False):
    """Traces out current context (local and global variables), with output
    prefixed by "LABEL context" (e.g., "current context: {\nglobals: ...}").
    Notes: By default the debugging level must be quite-detailed (6).
    If the debugging level is higher, the entire stack frame is traced.
    Also, methods are omitted by default."""
    return debug.trace_current_context(level=level, label=label, show_methods_etc=show_methods_etc)


def during_debugging(expression=True):
    """Returns True if debugging, optionally conditioned upon EXPRESSION
     Note: The expression is not considered in non-debug mode"""
    return (debugging_level() > 0) and expression


def debugging(level=(DEFAULT_DEBUG_LEVEL + 1)):
    """Whether running with LEVEL or higher debugging (1 by default)"""
    return debugging_level() >= level


def detailed_debugging():
    """Whether running with detailed debug tracing"""
    return debugging_level() >= DETAILED


def verbose_debugging():
    """Whether running with verbose debug tracing"""
    return debugging_level() >= VERBOSE


#------------------------------------------------------------------------
# General utility functions

def to_string(obj):
    """Returns string rendition of OBJ (i.e., %s-based)"""
    # Note: str() not used in order to properly handle unicode
    # EX: to_string(123) => "123"
    # EX: to_string(u"\u1234") => u"\u1234"
    # EX: to_string(None) => "None"
    # TODO: have specialization that returns "" for None
    result = obj
    ## NOTE: Gotta hate python
    ## if not isinstance(result, types.StringTypes):
    if not isinstance(result, string_types):
        result = "%s" % (obj,)
    return result

def normalize_unicode(text, encoding="utf8"):
    """Converts Unicode TEXT to ENCODING (normally UTF-8) if necessary, such as
    to prepare for output. Note: this is a no-op in Python 3 or higher"""
    result = _normalize_unicode(text, encoding)
    debug_format("normalize_unicode({t}, {e}) => {r}", 10, 
                 t=text, e=encoding, r=result)
    debug_format("\ttypes: in={it} out={ot}", 11, 
                 it=type(text), ot=type(result))
    return result
#
def _normalize_unicode(text, encoding="utf8"):
    """Implementation of normalize_unicode (q.v.)"""
    # EX: normalize_unicode(u'\u1234') => '\xe1\x88\xb4'
    # Note: As this is used in suport for debug_print, no tracing is done.
    # TODO: work out more-untuitive name
    result = text
    if sys.version_info[0] < 3:
        if isinstance(result, unicode):     # pylint: disable=undefined-variable
            result = result.encode(encoding)
    return result


def ensure_unicode(text, encoding="utf8"):
    """Ensures TEXT is encoded as unicode, using ENCODING (e.g., UTF8). Note: this is a no-op in Python 3 or higher"""
    # EX: ensure_unicode('\xe1\x88\xb4') => u'\u1234'
    result = _ensure_unicode(text, encoding)
    debug_format("ensure_unicode({t}) => {r}", 10, 
                 t=text, r=result)
    debug_format("\ttypes: in={it} out={ot}", 11, 
                 it=type(text), ot=type(result))
    return result
#
def _ensure_unicode(text, encoding="utf8"):
    """Implementation of ensure_unicode (q.v.)"""
    # Note: As this used in support for debug_print, no tracing is done.
    result = text
    if sys.version_info[0] < 3:
        # pylint: disable=undefined-variable
        if not isinstance(result, unicode):
            result = unicode(result, encoding)
    return result


def print_stderr(text, **namespace):
    """Output TEXT to standard error (with newline added), using optional
    NAMESPACE for format"""
    # Note: ensures text encoded as UTF8 if under Python 2.x
    if namespace:
        text = format(text, **namespace)
    stderr.write(normalize_unicode(text) + "\n")
    return


def redirect_stderr(filename):
    """Redirects error output to FILENAME"""
    global stderr
    assert(stderr == sys.stderr)
    stderr = system.open_file(filename, "w")
    assert(stderr)


def restore_stderr():
    """Restores error output to system stderr, closing handle for redirection"""
    global stderr
    assert(stderr != sys.stderr)
    stderr.close()
    stderr = sys.stderr


def exit(message, **namespace):    # pylint: disable=redefined-builtin
    """Display error MESSAGE to stderr and then exit, using optional
    NAMESPACE for format"""
    if namespace:
        message = format(message, **namespace)
    print_stderr(message + "\n")
    return sys.exit()


def setenv(var, value):
    """Set environment VAR to VALUE"""
    debug_print("setenv('%s', '%s')" % (var, value), 6)
    os.environ[var] = to_string(value) if value is not None else ""
    return


def chomp(text, line_separator=os.linesep):
    """Removes trailing occurrence of LINE_SEPARATOR from TEXT"""
    # EX: chomp("abc\n") => "abc"
    # EX: chomp("http://localhost/", "/") => "http://localhost"
    result = text
    if result.endswith(line_separator):
        new_len = len(result) - len(line_separator)
        result = result[:new_len]
    debug_format("chomp({t}, {sep}) => {r}", 8,
                 t=text, sep=line_separator, r=result)
    return result

#-------------------------------------------------------------------------------
# Environment accessors and setters

def getenv(var):
    """Return value of environment VAR"""
    value = os.getenv(var)
    debug_print("getenv('%s') => '%s'" % (var, value), 8)
    return value


env_options = {}
env_defaults = {}
#
def register_env_option(var, description, default):
    """Register environment VAR as option with DESCRIPTION and DEFAULT"""
    debug_format("register_env_option({v}, {d})", 7, v=var, d=description)
    global env_options
    global env_defaults
    env_options[var] = (description or "")
    env_defaults[var] = default
    return


def get_registered_env_options():
    """Returns list of environment options registered via register_env_option"""
    option_names = [k for k in env_options if (env_options[k] and env_options[k].strip())]
    debug_format("get_registered_env_options() => {option_names}", 5)
    return option_names


def get_environment_option_descriptions(include_all=None, include_default=None, indent=" "):
    """Returns list of environment options and their descriptions"""
    debug_format("env_options={eo}", 5, eo=env_options)
    debug_format("env_defaults={ed}", 5, ed=env_defaults)
    if include_all is None:
        include_all = verbose_debugging()
    if include_default is None:
        include_default = True
    #
    def _format_env_option(opt):
        """Returns OPT description and optionally default value (if INCLUDE_DEFAULT)"""
        debug_format("_format_env_option({opt})", 7)
        desc_spec = env_options.get(opt, "_")
        default_spec = ""
        if include_default:
            default_value = env_defaults.get(opt, None)
            has_default = (default_value is not None)
            default_spec = ("(%s)" % default_value) if has_default else "n/a"
        default_spec = default_spec.replace("\n", "\\n")
        return (opt, desc_spec + indent + default_spec)
    #
    option_descriptions = [_format_env_option(opt) for opt in env_options if (env_options[opt] or include_all)]
    debug_format("get_environment_option_descriptions() => {od}", 5,
                 od=option_descriptions)
    return option_descriptions


def formatted_environment_option_descriptions(sort=False, include_all=None, indent="\t"):
    """Returns string list of environment options and their descriptions (separated by newlines and tabs), optionally SORTED"""
    option_info = get_environment_option_descriptions(include_all)
    if sort:
        option_info = sorted(option_info)
    entry_separator = "\n%s" % indent
    descriptions = entry_separator.join(["%s%s%s" % (opt, indent, (desc if desc else "n/a")) for (opt, desc) in option_info])
    debug_format("formatted_environment_option_descriptions() => {d}", 6,
                 d=descriptions)
    return descriptions


def getenv_value(var, default=None, description=None, export=None):
    """Returns textual value for environment variable VAR; if not set, uses DEFAULT which can be None. If DESCRIPTION given, the variable is added to list of registered options. If EXPORT specified, the environment entry will be created if necessary (useful during sub-script invocation)."""
    # Note: Use one of the specialized variants (e.g., getenv_text, getenv_boolean, or getenv_number).
    value = getenv(var)
    if export is None:
        ## OLD: export = description is not None
        export = False
    if not value:
        debug_print("getenv_value: no value for %s" % var, 7)
        value = default
        if export:
            setenv(var, value)
    register_env_option(var, description, default)
    debug_print("getenv_value('%s') => %s" % (var, value), 6)
    return value


def getenv_text(var, default="", description=None):
    """Returns textual value for environment variable VAR (or string version of DEFAULT unless None)"""
    # Note: This is a simple wrapper around getenv_value using lower tracing level (as former is intended as helper for specialized types given below).
    # TODO: define in terms of system.getenv_text
    value = getenv_value(var, default, description=description)
    text_value = to_string(value) if value is not None else ""
    debug_print("getenv_text('%s', '%s') => '%s'" % (var, default, text_value), 4)
    return text_value


def getenv_bool(var, default=False, description=None):
    """Returns boolean flag based on environment VAR (or DEFAULT value which can be None). Note: "0" or "False" is interpreted as False, and any value as True."""
    bool_value = default
    value_text = getenv_text(var, default, description=description)
    # TODO: gh.assertion(type(default) == bool or default is None)
    if ((default is not None) and (not isinstance(default, bool))):
        print_stderr("Warning: unexpected default type to getenv_boolean: " +
                     "{t} vs. bool or None; var={v}", t=type(default), v=var)
    # TODO: assert(isinstance(value_text, str))
    if value_text:
        bool_value = True
        if (value_text.lower() == "false") or (value_text == "0"):
            bool_value = False
    debug_print("getenv_boolean(%s, %s) => %s" % (var, default, bool_value), 4)
    return bool_value
#
getenv_boolean = getenv_bool


def getenv_number(var, default=-1, description=None, integral=False):
    """Returns number based on environment VAR (or DEFAULT value which can be None)"""
    num_value = default
    value_text = getenv_text(var, default, description=description)
    # TODO: assert(isinstance(value_text, str))
    # TODO: make sure misc_utils version reconciled (and rework tpo_common to use latter!)
    if value_text:
        # Note: safe_int/_float not used so that exception into always displayed
        try:
            num_value = int(value_text) if integral else float(value_text)
        except:
            print_stderr(format("Exception converting env number for {v} ('{val}'): {exc}",
                                v=var, val=value_text, exc=str(sys.exc_info())))
    debug_print("getenv_number(%s, %s) => %s" % (var, default, num_value), 4)
    return num_value


def getenv_int(var, default=-1, description=None):
    """Variant of getenv_number for integers. Note: returns integer unless None is default."""
    return getenv_number(var, default, description=description, integral=True)
#
getenv_integer = getenv_int


def getenv_real(var, default=-1, description=None):
    """Variant of getenv_number for reals (i.e., floating point). Note: (returns float unless None is default)."""
    return getenv_number(var, default, description=description, integral=False)


def getenv_float(var, default=-1, description=None):
    """Alias for getenv_real"""
    return getenv_number(var, default, description=description)


def get_current_function_name():
    """Returns the name of the currently executing function (excluding this function of course)"""
    # Note: Based on http://code.activestate.com/recipes/66062-determining-current-function-name.
    # Also see http://docs.python.org/2/reference/datamodel.html and http://docs.python.org/2/library/inspect.html.
    # TODO: remove as no longer used???
    name = "???"
    try:
        name = sys._getframe(1).f_code.co_name     # pylint: disable=protected-access
    except (AttributeError, ValueError):
        print_stderr("Exception in get_current_function_name: " + str(sys.exc_info()))
    debug_print("get_current_function_name() => %s" % name, 5)
    return name


def get_property_value(obj, property_name, default_value=None):
    """Gets property value for NAME from OBJ, using DEFAULT"""
    # EX: import datetime; (get_property_value(datetime.date.today(), 'year', -1) >= 2012) => True
    # EX: get_property_value(datetime.date.today(), 'minute', -1) => -1
    value = default_value
    if hasattr(obj, property_name):
        value = getattr(obj, property_name)
    debug_print("get_property_value%s => %s" % (to_string((obj, property_name, default_value)),
                                                value), level=4)
    return value


def simple_format(text, namespace):
    """Resolve format-style command argument specifications within TEXT (within angle brackets), using bindings from NAMESPACE"""
    # Note: This only supports evaluation of the text within braces (e.g., format specifiers not handled)
    result = text

    # Replace all placeholders via eval of expression
    while (True):
        # Find next variable reference (uses lookbehind to exclude double braces)
        #                  +no brace+ {expressn} +
        match = re.search("(?:[^{]|^)({([^{}]+)})", result)
        if not match: 
            break
        pattern = match.group(1)
        var = match.group(2)
        # Determine value and update argument
        value = None
        try:
            # note: no global namespace specified (but should be part of local one as with format below)
            value = eval(var, None, namespace)    # pylint: disable=eval-used
        except (IndexError, NameError, SyntaxError, TypeError, ValueError):
            debug_print("Exception during eval: " + str(sys.exc_info()), 6)
        if value is None:
            debug_print("Unable to resolve replacement '%s' in '%s'" % (var, result), 2)
            break
        result = result.replace(pattern, str(value))

    # Handle common escapes
    result = result.replace("{{", "{")
    result = result.replace("}}", "}")

    debug_print("simple_format('%s', [namespace]) => %s" % (text, result), 6)
    debug_print("\tnamespace: %s" % namespace, 7)
    return result


warned_about_namespace = {}
#
def format(text, indirect_caller=False, ignore_exception=False, **namespace):    # pylint: disable=redefined-builtin
    """Formats TEXT using local namespace, optionally using additional level or
    indirection. If no keywords NAMESPACE specified, they are taken from local
    environment (which is convenient but un-pythonic and a bit inefficient).
    Exceptions can be ignored (to support debug_format)."""
    # Notes:
    # - Argments need to be in UTF-8 if the template text is an ascii string.
    # - The technique for resolving the locals is based on Stack Overflow:
    #   http://stackoverflow.com/questions/6618795/get-locals-from-calling-namespace-in-python
    # - This conflicts with the format builtin, but that is only a potential
    #   issue if immported via 'from tpo_common import *'. The standard function
    #   can be accessed via __builtin__.format (or via builtins under Python 3).
    # - Encodes text in unicode prior to format proper and then encodes result
    #   into UTF-8.
    # Warning: don't call other user functions except debug_print or helper
    # functions that don't trace (e.g., _ensure_unicode).
    if (debugging_level() >= 99):
        debug_trace("format(%s, %s, %s, %s)",
                    text, indirect_caller, ignore_exception, namespace)
    # TODO: make unicode conversion optional
    ## OLD: text = _ensure_unicode(text)
    frame = None
    result = ""
    try:
        if not namespace:
            frame = inspect.currentframe().f_back
            if indirect_caller:
                frame = frame.f_back
            if not skip_format_warning:
                filename = frame.f_globals.get("__file__", "???")
                if filename.endswith(".pyc"):
                    filename = filename[:-1]
                source_line_key = "{f}:{l}".format(f=filename, l=frame.f_lineno)
                if source_line_key not in warned_about_namespace:
                    debug_trace("Warning: deriving namespace from locals and " +
                                "globals at %s: inefficient and un-pythonic!",
                                source_line_key, level=WARNING)
                    warned_about_namespace[source_line_key] = True
            trace_object(frame, 9, "frame")
            namespace = frame.f_globals.copy()
            namespace.update(frame.f_locals)
        else:
            namespace = namespace.copy()
        if USE_SIMPLE_FORMAT:
            result = simple_format(text, namespace)
        else:
            # Make sure values to output are UTF-8 unless text is unicode
            # Note: only converts strngs, lists, and hashes (e.g., omitting user objects and numbers)
            if sys.version_info[0] < 3:
                debug_trace("type(text)=%s", type(text), level=91)
                debug_trace("namespace=%s", namespace, level=94)
                ## OLD: transform_fn = _normalize_unicode if not type(text) == unicode else _ensure_unicode
                # pylint: disable=undefined-variable
                transform_fn = _normalize_unicode if (not isinstance(text, unicode)) else _ensure_unicode
                for k in namespace:
                    ## BAD: if isinstance(namespace[k], types.StringTypes):
                    if isinstance(namespace[k], string_types):
                        namespace[k] = transform_fn(namespace[k])
                    ## OLD: elif type(namespace[k]) in [list, dict]:
                    elif isinstance(namespace[k], (list, dict)):
                        namespace[k] = transform_fn(to_string(namespace[k]))
            # Do the actual conversion
            result = text.format(**namespace)
    except (AttributeError, KeyError, UnicodeDecodeError, ValueError):
        debug_print("Exception during format(%s,...): %s" % (text, str(sys.exc_info())), 5)
        if not ignore_exception:
            raise
    finally:
        if frame:
            del frame
    ## OLD: result = _normalize_unicode(result)
    debug_trace("txt: " + text, level=91)
    debug_trace("res: " + result, level=91)
    debug_trace("format(%s,...) => %s", text, result, level=91)
    return result


def init_logging():
    """Enable logging with INFO level by default or with DEBUG if detailed debugging"""
    debug_print("init_logging", 4)
    # TODO: use mapping from symbolic LEVEL user option (e.g., via getenv)
    level = logging.DEBUG if detailed_debugging() else logging.INFO
    logging.basicConfig(format='%(asctime)s : %(levelname)s : %(message)s', level=level)
    logging.debug("init_logging")
    return


def load_object(filename):
    """Load object data from FILENAME in pickle format"""
    debug_print("Loading object from %s" % filename, 3)
    object_data = None
    f = system.open_file(filename, 'rb')
    if f:
        object_data = pickle.load(f)
        f.close()
    return object_data


def store_object(filename, object_data):
    """Store OBJECT_DATA in FILENAME using pickle format"""
    debug_print("Saving object to %s" % filename, 3)
    f = system.open_file(filename, 'wb')
    if f:
        pickle.dump(object_data, f)
        f.close()
    return


def dump_stored_object(object_filename, dump_filename, level=1):
    """Traces out object stored in OBJECT_FILENAME to DUMP_FILENAME"""
    # Note: convenience function for interactive usage
    redirect_stderr(dump_filename)
    obj = load_object(object_filename)
    ## OLD: if isinstance(obj, dict) or isinstance(obj, list):
    if isinstance(obj, (dict, list)):
        trace_value(obj, level)
    else:
        trace_object(obj, level)
    restore_stderr()
    return

def create_lookup_table(filename, use_linenum=False):
    """Create lookup hash table from string keys to string values (one pair per line, tab separated), optionally with the line number serving as implicit key. Note: The keys are made lowercase, and lines with multiple tabs are ignored."""
    # TODO: rename as create_lookup_hash? (see ShelveLookup.from_hash in table_lookup.py)
    # TODO: use enumerate(f); refine exception in except
    debug_print("create_lookup_table(%s)" % filename, 4)
    lookup_hash = {} if (not use_linenum) else OrderedDict()
    f = None
    try:
        f = system.open_file(filename)
        line_num = 0
        for line in f:
            line = line.strip("\n")
            line_num += 1
            fields = line.split("\t")
            if len(fields) == 2:
                key = fields[0].lower()
                lookup_hash[key] = fields[1]
            elif (len(fields) == 1) and use_linenum:
                key = line_num
                lookup_hash[key] = fields[0]
            else:
                debug_print("Warning: Ignoring entry at line %d (%s): %s" % (line_num, filename, line), 3)
    except (IOError, ValueError):
        debug_print("Warning: Exception creating lookup table from %s: %s" % (filename, str(sys.exc_info())), 2)
    finally:
        if f:
            f.close()
    debug_print("create_lookup_table => %s" % lookup_hash, 8)
    return lookup_hash


def lookup_key(table, key, default):
    """Looks up KEY in table (ensuring lowercase)"""
    result = table.get(key.lower(), default)
    debug_format("lookup_key(_, {k}, {d}) => {r}", 6,
                 k=key, d=default, r=result)
    return result

def create_boolean_lookup_table(filename):
    """Create lookup hash table from string keys to boolean occurrence indicator. Note: The keys are made lowercase."""
    # TODO: allow for tab-delimited value to be ignored
    debug_print("create_boolean_lookup_table(%s)" % filename, 4)
    lookup_hash = {}
    f = system.open_file(filename)
    for line in f:
        key = line.strip().lower()
        lookup_hash[key] = True
    if f:
        f.close()
    debug_print("create_boolean_lookup_table => %s" % lookup_hash, 8)
    return lookup_hash


def normalize_frequencies(dictionary):
    """Normalize the frequencies in DICTIONARY (i.e., in range [0, 1])"""
    total = 0
    for k in dictionary:
        total += dictionary[k]
    if total > 0:
        for k in dictionary:
            dictionary[k] /= total
    return


def sort_frequencies(dictionary):
    """Returns the keys in DICTIONARY sorted in reverse by frequency"""
    sorted_keys = sorted(dictionary.keys(), reverse=True, 
                         key=lambda k: dictionary[k])
    debug_format("sort_frequencies({d}) => {r}", 7,
                 d=dictionary, r=sorted_keys)
    return sorted_keys


def sort_weighted_hash(weights, max_num=None, reverse=None):
    """sorts the enties in WEIGHTS hash, returns list of (key, freq) tuples.
    Note: sorted in REVERSE order by default"""
    if max_num is None:
        max_num = len(weights)
    if reverse is None:
        reverse = True
    sorted_keys = sorted(weights.keys(), reverse=reverse, 
                         key=lambda k: weights[k])
    top_values = [(k, weights[k]) for k in sorted_keys[:max_num]]
    debug_format("sort_weighted_hash(_, _) => {r}", 5, r=top_values)
    return top_values


def format_freq_hash(freqs, label, max_num=None, prec=0, indent="\t"):
    """Returns formatted string representing top entries in FREQS hash,
    preceded by LABEL, using up to MAX_NUM entries, with numbers rounded to
    PRECISION places
    Note; Result is covertedto UTF-8 if necessary (e.g., for printing)"""
    if max_num is None:
        max_num = len(freqs)
    sorted_keys = sorted(freqs.keys(), reverse=True, key=lambda k: freqs[k])
    top_values = [(indent + k + "\t" + round_num(freqs[k], prec))
                  for k in sorted_keys[:max_num]]
    hash_listing = normalize_unicode(label + '\n' + "\n".join(top_values))
    return hash_listing


def union(list1, list2):
    """"Returns set union of LIST1 and LIST2 (preserving order)"""
    # TODO: rework in terms of built-in set operations???
    result = list1[:]
    for item in list2:
        if item not in list1:
            result.append(item)
    debug_format("union({l1}, {l2}) => {r}", 7, l1=list1, l2=list2, r=result)
    return result


def intersection(list1, list2):
    """Returns set intersection of LIST1 and LIST2. Note: useful for tracing"""
    ## TODO; return system.intersection(list1, list2)
    assert(isinstance(list1, list) and isinstance(list2, list))
    result = list(set.intersection(set(list1), set(list2)))
    debug_format("intersection({l1}, {l2}) => {r}", 7, l1=list1, l2=list2, r=result)
    return result


def is_subset(list1, list2):
    """Returns whether LIST1 is subset of LIST2"""
    # EX: is_subset(['mouse', 'dog'], ['dog', 'cat', 'mouse'])
    result = set(list1).issubset(set(list2))
    debug_format("subset({l1}, {l2}) => {r}", 7, l1=list1, l2=list2, r=result)
    return result


def difference(list1, list2):
    """Returns list of items in LIST1 not in LIST2"""
    # EX: difference([5, 4, 3, 2, 1], [4, 2]) => [1, 3, 5]
    assert(isinstance(list1, list) and isinstance(list2, list))
    diff = list(set(list1).difference(set(list2)))
    debug_format("difference({l1}, {l2}) => {r}", 7, l1=list1, l2=list2, r=diff)
    return diff


def remove_all(list1, list2, ignore_case=False):
    """Removes all members of LIST2 from LIST1, similar to
    difference except that the order is preserverd"""
    # EX: remove_all([5, 4, 3, 2, 1], [4, 2, 0]) => [5, 3, 1]
    if ignore_case:
        list1 = [to_string(v).lower() for v in list1]
        list2 = [to_string(v).lower() for v in list2]
    diff = list1
    for item in list2:
        if item in diff:
            diff.remove(item)
    debug_format("remove_all({l1}, {l2}) => {r}", 7, l1=list1, l2=list2, r=diff)
    return diff


def equivalent(list1, list2):
    """Returns whether LIST1 and LIST2 have same entries (i.e., intersection is
    same as both ignoring duplicates)"""
    assert(isinstance(list1, list) and isinstance(list2, list))
    len1 = len(set(list1))
    len2 = len(set(list2))
    ok = len1 == len2 and len(intersection(list1, list2)) == len1
    debug_format("equivalent({list1}, {list1}) => {ok}", 5)
    return ok


def append_new(in_list, item):
    """Returns copy of LIST with ITEM included unless already in it"""
    result = in_list[:]
    if item not in result:
        result += [item]
    debug_print("append_new(%s, %s) => %s" % (in_list, item, result), 5)
    return result


def extract_list(text):
    """Extract list of values from TEXT, separated by spaces or commas"""
    items = text.replace(",", " ").split()
    debug_format("extract_list({text}) = {items}", 6)
    return items


def is_subsumed(term, other_terms):
    """Whether phrasal TERM is subsumed by a larger phrase in OTHER_TERMS, restricted to word boundaries"""
    # EX: is_subsumed("dog", ["dog house", "catnip"]) => True
    # EX: is_subsumed("cat", ["dog house", "catnip"]) => False
    for other_term in other_terms:
        if (term != other_term) and (" " + term + " ") in (" " + other_term + " "):
            return True
    return False


PRECISION = getenv_int("ROUNDING_PRECISION", 3,
                       "Precision for rounding numbers via round_num, etc.")
#
def round_num(num, precision=None, zero_fill=True):
    """Rounds NUM to PRECISION places (normally 3); returned as a string, optionally zero-filled on the right
    Note: Precision can be overidden wth ROUNDING_PRECISION environment variable"""
    # Note: the g conversion specifier is not used because that can yield exponent notation
    # EX: round_num(15000, 3) => "15000.000"
    # EX: round_num(15000, 3, False) => "15000"
    if precision is None:
        precision = PRECISION
    format_string = "%%.0%df" % precision
    rounded_num = (format_string % num)
    if not zero_fill:
        # Remove trailing zeros and/or trailing decimal place
        while (re.search(r"(\.[0-9]*)0$", rounded_num)):
            old_rounded_num = rounded_num
            rounded_num = re.sub(r"(\.[0-9]*)0+$", "\\1", rounded_num)
            assert(rounded_num != old_rounded_num)
        rounded_num = rounded_num.rstrip(".")
    debug_format("round_num({n}, [prec={p}, zero_fill={z}]]) => {r}", 8,
                 n=num, p=precision, z=zero_fill, r=rounded_num)
    return rounded_num


def round_nums(numbers, precision=None, zero_fill=True):
    """Rounds each of the NUMBERS to PRECISION places (normally 3): returned as list of strings, optionally zero-filled on the right"""
    # EX: round_nums([0.333333, 0.666666, 0.99999]) = ['0.333', '0.667', '1.000']
    return [round_num(v, precision, zero_fill) for v in numbers]


def round(number_or_list, precision=None):    # pylint: disable=redefined-builtin
    """Llke round_num(s) but returning float(s)"""
    # EX: round(15000) => 15000.0
    # EX: round([0.333333, 0.666666, 0.99999]) => [0.333, 0.667, 1.0]
    # Note: This is different from built-in round in that list is allowed and
    # for use of rounding-precision environment option (via round_num).
    rounded_result = 0
    ## OLD: if isinstance(number_or_list, float) or isinstance(number_or_list, int):
    if isinstance(number_or_list, (float, int)):
        rounded_result = float(round_num(number_or_list, precision))
    else:
        rounded_result = [float(s) for s in round_nums(number_or_list, precision)]
    return rounded_result


def normalize(num_list):
    """Returns NUM_LIST normalized to [0, 1] range"""
    # EX: normalize([1, 2, 3]) => [0.0, 0.5, 1.0]
    normalized = num_list
    lower = min(num_list)
    diff = float(max(num_list) - lower)
    if diff > 0:
        normalized = [(x - lower)/diff for x in num_list]
    else:
        normalized = [1.0] * len(num_list)
    debug_format("normalize({l}) => {r}", 7,
                 l=round(num_list), r=round(normalized))
    return normalized


def is_numeric(text):
    """Indicates whether TEXT represents a number (integer or float)"""
    ## TODO: rename as is_number to avoid confusion with English numeric a la numeral (e.g., "two')
    # EX: is_numeric("123") => True
    # EX: is_numeric("one") => False
    numeric = False
    try:
        _value = float(text)
        numeric = True
    except ValueError:
        _value = None
    debug_format("is_numeric({t}) => {n}; value={v}", 8, t=text, n=numeric, v=_value)
    return numeric


def safe_int(numeric, default_value=0, base=10):
    """Returns NUMERIC interpreted as a int, using DEFAULT_VALUE (0) if not
    numeric and interpretting value as optional BASE (10)"""
    try:
        result = int(numeric, base)
    except (TypeError, ValueError):
        debug_format("Warning: Exception converting integer numeric ({num}): {exc}", 4,
                     num=numeric, exc=str(sys.exc_info()))
        result = default_value
    debug_format("safe_int({n}, [{df}, {b}]) => {r})", 7,
                 n=numeric, df=default_value, b=base, r=result)
    return result


def safe_float(numeric, default_value=0.0):
    """Returns NUMERIC interpreted as a float, using DEFAULT_VALUE (0.0) if not numeric"""
    try:
        result = float(numeric)
    except ValueError:
        debug_format("Warning: Exception converting float numeric ({num}): {exc}", 4,
                     num=numeric, exc=str(sys.exc_info()))
        result = default_value
    debug_format("safe_int({n}, {df}) => {r})", 7,
                 n=numeric, df=default_value, r=result)
    return result


def reference_variables(*args):
    """Dummy function used for referencing variables"""
    debug_print("reference_variables%s" % str(args), 9)
    return

#------------------------------------------------------------------------
# Memomization support (i.e., functiona result caching), based on 
#     See http://code.activestate.com/recipes/578231-probably-the-fastest-memoization-decorator-in-the-. [world!]
# This is implemented transparently via Python decorators. See
#     http://stackoverflow.com/questions/739654/understanding-python-decorators
#
# usage example:
#
#    @memodict
#    def fubar(word):
#        result = ...
#        return result
#

def memodict(f):
    """Memoization decorator for a function taking a single argument"""
    class _memodict(dict):
        """Internal class for implementing memoization"""
        #
        def __missing__(self, key):
            """Invokes function to produce value if arg not in hash"""
            ret = self[key] = f(key)
            return ret
    #
    return _memodict().__getitem__

#------------------------------------------------------------------------

def dummy_main():
    """Dummy entry point for script, showing environment variable usage"""
    if detailed_debugging():
        # Create dummy environment opton with description
        _FUBAR = getenv_boolean("FUBAR", True, "Dummy option")
    print("Environment options:")
    desc = formatted_environment_option_descriptions(include_all=True)
    print("\t" + (desc if desc.strip() else "n/a"))
    return


# Do debug-only processing (n.b., for when PYTHONOPTIMIZE not set)
# Note: wrapped in function to keep things clean

if __debug__:

    def debug_init():
        """Debug-only initialization"""
        ## OLD: tpo_common_start = time.time()

        # Override debug level to DEBUG_LEVEL environment variable unless running in optimized mode (i.e., __debug__ is False)
        ## OLD:
        ## env_debug_level = os.getenv("DEBUG_LEVEL")
        ## global debug_level
        ## debug_level = int(env_debug_level) if env_debug_level else ERROR
    
        # Show trace level in effect
        debug_format("starting tpo_common.py at {ts}: "
                     + "debug_level={lvl}; args={args}", level=DETAILED,
                     ts=debug_timestamp(), lvl=debugging_level(), args=sys.argv)

        ## OLD
        ## # Register DEBUG_LEVEL for sake of new users
        ## test_debug_level = getenv_integer("DEBUG_LEVEL", debugging_level(), 
        ##                                   "Debugging level for script tracing")
        ## assert(debugging_level() == test_debug_level)

        # Register function to display ending timestamp
        ## OLD:
        ## def _display_ending_info():
        ##     """Display ending time information"""
        ##     # note: does nothing if stderr closed (e.g., during profiling)
        ##     # TODO: track down problem with pytest
        ##     if sys.stderr.closed:       # pylint: disable=using-constant-test
        ##         return
        ##     trace_object(sys.stderr, level=7)
        ##     tpo_common_end = time.time()
        ##     debug_format("ending tpo_common.py at {time}; elapsed={diff}s", 
        ##                  level=DETAILED, time=debug_timestamp(), 
        ##                  diff=round_num(tpo_common_end - tpo_common_start))
        ## #
        ## if not getenv_boolean("OMIT_ATEXIT", False):
        ##     atexit.register(_display_ending_info)

        # Override globals from environment
        # Note: done after start-up tracing initialization for getenv tracing
        ## OLD:
        ## global output_timestamps
        ## output_timestamps = getenv_boolean("OUTPUT_DEBUG_TIMESTAMPS", 
        ##                                    output_timestamps)
        ## global use_logging
        ## use_logging = getenv_boolean("USE_LOGGING", use_logging)
        ## enable_logging = getenv_boolean("ENABLE_LOGGING", use_logging)
        ## if enable_logging:
        ##     init_logging()
        global skip_format_warning
        skip_format_warning = getenv_boolean("SKIP_FORMAT_WARNING", False)
    
        # Warn about old version of format
        if USE_SIMPLE_FORMAT:
            debug_print("Warning: Using simple format for debug_format", 
                        level=WARNING)

        return
    
    # Do the initialization
    debug_init()
    debug.assertion(debug_level == debug.get_level())

# Warn if invoked standalone
#
if __name__ == '__main__':
    print_stderr("Warning: %s is not intended to be run standalone" % __file__)
    dummy_main()
