#! /usr/bin/env python
#
# Convenience class for regex searching, providing simple wrapper around
# static match results.
#
# Note: This provides tracing for commonly used functions (e.g., search and sub),
# with aliasing used for miscellaneous others (e.g., subn).
#
# Example usage:
#
#    from my_regex import my_re
#    ...
#    if (my_re.search(r"^(\d+)\:?(\d*)\s+(\d+)\:?(\d*)\s+\S.*", line)):
#        (start_hours, start_mins, end_hours, end_mins) = my_re.groups()
#
#--------------------------------------------------------------------------------
# TODO:
# - Add examples for group(), groups(), etc.
# - Clean up script (e.g., regex => regex_wrapper).
# - Add perl-inspired accessors (e.g., PREMATCH, POSTMATCH).
#

"""Wrapper class for regex match results"""

# Standard packages
import re
## TODO: from re import *

# Installed packages
import six

# Local packages
from mezcla import debug
from mezcla import system

# Expose public symbols from re package, plus the wrapper class and global instance
## OLD:
## # Expose public symbols from re package,
## __all__ = re.__all__
## DEBUG: system.print_error("checking SKIP_RE_ALL")
RE_ALL = (not system.getenv_bool("SKIP_RE_ALL", False,
                                 "Don't use re.__all__: for sake of pylint"))
__all__ = ['regex_wrapper', 'my_re']
if RE_ALL:
    ## TODO: __all__ = re.__all__ + ['regex_wrapper', 'my_re']
    __all__ += re.__all__
    pass
else:
    debug.trace(4, "Omitting use of re __all__")

REGEX_TRACE_LEVEL = system.getenv_int("REGEX_TRACE_LEVEL", debug.QUITE_DETAILED,
                                      "Trace level for my_regex")
    
## TODO # HACK: make sure regex can be used as plug-in replacement 
## from from re import *

## TEST: Attempts to work around Python enum extension limitation
##
## OLD: class regex_wrapper(object):
## HACK: inherit from RegexFlag, so pylint not confused by attrib copying
## NOTE: Maldito python!
##    class regex_wrapper(re.RegexFlag):
##    => TypeError: Cannot extend enumerations
## via https://stackoverflow.com/questions/33679930/how-to-extend-python-enum:
##    Subclassing an enumeration is allowed only if the enumeration does not define any members.
##
##
## HACK2: try via multiple inheritance
##
## class TraceLevel(object):
##     """Simple class with trace level
##     Note: this is just used to work around issue subclassing enums"""
##     # TODO: rework trace level in debug module to be class based
##     TRACE_LEVEL = debug.QUITE_DETAILED
##
## class regex_wrapper(TraceLevel, re.RegexFlag):
##     ...
##
## 
## class MalditoPython(re.RegexFlag):
##     """Just what it says"""
##     pass
##

class regex_wrapper():
    """Wrapper class over re to implement regex search that saves match results
    note: Allows regex to be used directly in conditions"""
    # TODO: IGNORECASE = re.IGNORECASE, etc.
    # import from RE so other methods supported directly (and above constants)
    TRACE_LEVEL = REGEX_TRACE_LEVEL
    ##
    ## Malditos python & pylint!
    ASCII = re.ASCII
    IGNORECASE = re.IGNORECASE
    LOCALE = re.LOCALE
    MULTILINE = re.MULTILINE
    DOTALL = re.DOTALL
    VERBOSE = re.VERBOSE
    UNICODE = re.UNICODE
    # TODO: add miscellaneous re functions (e.g., subn)
    
    # pylint: disable=super-init-not-called
    #
    def __init__(self, ):
        debug.trace_fmtd(4, "my_regex.__init__(): self={s}", s=self)
        self.match_result = None
        # TODO: self.regex = ""

        # HACK: Import attributes from re class
        # TODO3: see if clean way to do this
        # TODO4: find way to disable pylint no-member warning
        try:
            for var in re.__all__:
                if var not in dir(self):
                    debug.trace(9, f"Copying {var} from re into {self}")
                    setattr(self, var, getattr(re, var))
        except:
            system.print_exception_info("__init__ re.* importation")

    def check_pattern(self, regex):
        """Apply sanity checks to REGEX when debugging
        Note: Added to account for potential f-string confusion"""
        # TODO: Add way to disable check
        debug.reference_var(self)
        check_regex = r"[^{]\{[A-Fa-f0-9][^{}]+\}[^}]"
        if isinstance(regex, bytes):
            check_regex = check_regex.encode()
        if (debug.debugging(1) and re.search(check_regex, regex)):
            system.print_error(f"Warning: potentially unresolved f-string in {regex}")

    def search(self, regex, text, flags=0, base_trace_level=None):
        """Search for REGEX in TEXT with optional FLAGS and BASE_TRACE_LEVEL (e.g., 6)"""
        ## TODO: rename as match_anywhere for clarity
        if base_trace_level is None:
            base_trace_level = self.TRACE_LEVEL
        debug.trace_fmtd((1 + base_trace_level), "my_regex.search({r!r}, {t!r}, {f}): self={s}",
                         r=regex, t=text, f=flags, s=self)
        ## OLD: debug.assertion(isinstance(text, six.string_types))
        debug.assertion(isinstance(text, (str, bytes)) and (type(regex) == type(text)))
        self.check_pattern(regex)
        self.match_result = re.search(regex, text, flags)
        if self.match_result:
            debug.trace_fmt(base_trace_level, "match: {m!r}; regex: {r!r}", m=self.grouping(), r=regex)
        return self.match_result

    def match(self, regex, text, flags=0, base_trace_level=None):
        """Match REGEX to TEXT with optional FLAGS and BASE_TRACE_LEVEL (e.g., 6)"""
        ## TODO: rename as match_start for clarity; add match_all method (wrapper around fullmatch)
        if base_trace_level is None:
            base_trace_level = self.TRACE_LEVEL
        debug.trace_fmtd((1 + base_trace_level), "my_regex.match({r!r}, {t!r}, {f}): self={s}",
                         r=regex, t=text, f=flags, s=self)
        self.check_pattern(regex)
        self.match_result = re.match(regex, text, flags)
        if self.match_result:
            debug.trace_fmt(base_trace_level, "match: {m!r}; regex: {r!r}", m=self.grouping(), r=regex)
        return self.match_result

    def get_match(self):
        """Return match result object for last search or match"""
        result = self.match_result
        debug.trace_fmtd(self.TRACE_LEVEL, "my_regex.get_match() => {r!r}: self={s}",
                         r=result, s=self)
        return result

    def group(self, num):
        """Return group NUM from match result from last search"""
        debug.assertion(self.match_result)
        result = self.match_result and self.match_result.group(num)
        debug.trace_fmtd(self.TRACE_LEVEL, "my_regex.group({n}) => {r!r}: self={s}",
                         n=num, r=result, s=self)
        return result

    def groups(self):
        """Return all groups in match result from last search"""
        debug.assertion(self.match_result)
        result = self.match_result and self.match_result.groups()
        debug.trace_fmt(self.TRACE_LEVEL, "my_regex.groups() => {r!r}: self={s}",
                        r=result, s=self)
        return result

    def grouping(self):
        """Return groups for match result or entire matching string if no groups defined"""
        # Note: this is intended to facilitate debug tracing; see example in search method above
        result = self.match_result and (self.match_result.groups() or self.match_result.group(0))
        debug.trace_fmt(self.TRACE_LEVEL + 1, "my_regex.grouping() => {r!r}: self={s}", r=result, s=self)
        return result

    def start(self, group=0):
        """Start index for GROUP"""
        result = self.match_result and self.match_result.start(group)
        debug.trace_fmt(self.TRACE_LEVEL + 1, "my_regex.start({g}) => {r!r}: self={s}", r=result, s=self, g=group)
        return result

    def end(self, group=0):
        """End index for GROUP"""
        result = self.match_result and self.match_result.end(group)
        debug.trace_fmt(self.TRACE_LEVEL + 1, "my_regex.end({g}) => {r!r}: self={s}", r=result, s=self, g=group)
        return result

    def sub(self, pattern, replacement, string, *, count=0, flags=0):
        """Version of re.sub requiring explicit keyword parameters"""
        # Note: Explicit keywords enforced to avoid confusion
        result = re.sub(pattern, replacement, string, count, flags)
        debug.reference_var(self)
        debug.trace(self.TRACE_LEVEL + 1, f"my_regex.sub({pattern!r}, {replacement!r}, {string!r}, [count=[count]], flags={flags}]) => {result!r}\n")
        self.check_pattern(pattern)
        return result

    def span(self, group=0):
        """Tuple with GROUP start and end"""
        return (self.match_result and self.match_result.span(group))

    def split(self, pattern, string, maxsplit=0, flags=0):
        """Use PATTERN to split STRING, optionally up to MAXSPLIT with FLAGS"""
        result = re.split(pattern, string, maxsplit, flags)
        debug.trace_fmt(self.TRACE_LEVEL, "split{args} => {r!r}",
                        args=tuple([pattern, string, maxsplit, flags]), r=result)
        return result
    
    def findall(self, pattern, string, flags=0):
        """Use PATTERN to split STRING, optionally with specified FLAGS"""
        result = re.findall(pattern, string, flags)
        debug.trace_fmt(self.TRACE_LEVEL, "findall{args} => {r!r}",
                        args=tuple([pattern, string, flags]), r=result)
        return result

    def escape(self, text):
        """Escape special characters in TEXT"""
        result = re.escape(text)
        debug.trace(self.TRACE_LEVEL + 1, f"escape({text!r}) => {result!r}")
        return result
    
#...............................................................................
# Initialization
#
# note: creates global instance for convenience (and backward compatibility)

my_re = regex_wrapper()

if __name__ == '__main__':
    system.print_error("Warning: not intended for command-line use")
    ## Note: truth in advertising:
    ## debug.trace(4, f"mp: {MalditoPython()}")
