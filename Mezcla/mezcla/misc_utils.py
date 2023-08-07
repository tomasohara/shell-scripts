#! /usr/bin/env python
#
# Miscellaneous functions not suitable for other modules (e.g., system.py).
#
# TODO:
# - Separate list related functions (e.g., as list_utils.py).
#

"""Misc. utility functions"""

# Standard packages
import datetime
from difflib import ndiff
import inspect
import math
import re
import sys

# Installed packages
import more_itertools

# Local packages
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla import system
from mezcla import text_utils

# Constants
ELLIPSIS = "\u2026"                 # Horizontal Ellipsis
TYPICAL_EPSILON = system.getenv_float("TYPICAL_EPSILON", 1e-6,
                                      description="Traditional floating-point error factor")
VALUE_EPSILON = system.getenv_float("VALUE_EPSILON", 1e-3,
                                    description="Epsilon for floating-point comparison")
debug.assertion(TYPICAL_EPSILON < VALUE_EPSILON)


def transitive_closure(edge_list):
    """Computes transitive close for graph given by EDGE_LIST (i.e., makes indirect links explicit)"""
    # ex: transitive_closure([(1,2),(2,3),(3,4)]) => set([(1, 2), (1, 3), (1, 4), (2, 3), (3, 4), (2, 4)])
    # notes; based on https://stackoverflow.com/questions/8673482/transitive-closure-python-tuples
    closure = set(edge_list)
    while True:
        new_relations = set((x, w) for x, y in closure for q, w in closure if q == y)

        closure_until_now = closure | new_relations
        if closure_until_now == closure:
            break

        closure = closure_until_now

    return closure


def read_tabular_data(filename):
    """Reads table with (unique) key and tab-separated value. 
    Note: key made lowercase"""
    debug.trace_fmtd(4, "read_tabular_file({f})", f=filename)
    table = {}
    with system.open_file(filename) as f:
        for (i, line) in enumerate(f):
            line = system.from_utf8(line)
            items = line.split("\t")
            if len(items) == 2:
                debug.assertion(items[0].lower() not in table)
                table[items[0].lower()] = items[1]
            else:
                debug.trace_fmtd(4, "Ignoring item w/ unexpected format at line {num}",
                                 num=(i + 1))
    ## debug.trace_fmtd(7, "table={t}", t=table)
    debug.trace_values(7, table, "table")
    return table


def extract_string_list(text):
    """Extract a list of values from text using spaces and/or commas as delimiters"""
    # EX: extract_string_list("1  2,3") => [1, 2, 3]
    trimmed_text = re.sub("  +", " ", text.strip())
    values = trimmed_text.replace(" ", ",").split(",")
    debug.trace_fmtd(5, "extract_string_list({t}) => {v}", t=text, v=values)
    return values


def is_prime(num):
    """Moderately efficient function for testing whether a number is prime
    Notes:
    - Based on https://en.wikipedia.org/wiki/Primality_test.
    - The intuition is that primes > 3 are of form (6k +/- 1).
    """
    ## EX: FIRST_100_PRIMES = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229, 233, 239, 241, 251, 257, 263, 269, 271, 277, 281, 283, 293, 307, 311, 313, 317, 331, 337, 347, 349, 353, 359, 367, 373, 379, 383, 389, 397, 401, 409, 419, 421, 431, 433, 439, 443, 449, 457, 461, 463, 467, 479, 487, 491, 499, 503, 509, 521, 523, 541]; (len(FIRST_100_PRIMES) == 100)
    ## EX: all([is_prime(n) for n in FIRST_100_PRIMES])
    ## EX: all([(not is_prime(n)) for n in range(FIRST_100_PRIMES[-1])  if n not in FIRST_100_PRIMES])
    ##
    debug.trace_fmt(5, "in is_prime({n})", n=num)
    is_prime_num = True

    # First, check primes below 4 (only 2)
    if (num <= 3):
        is_prime_num = (num > 1)
        if not is_prime_num:
            debug.trace_fmt(4, "{n} not prime as less than 3 and not 2.", n=num)
        return is_prime_num

    # Next, make sure not divisible by 2 or 3
    if ((num % 2 == 0) or (num % 3 == 0)):
        debug.trace_fmt(4, "{n} not prime as divisible by 2 or 3.", n=num)
        return False

    # Otherwise, check (6k +/- 1) values to see if divisible by 2 or 3,
    # stopping when value exceeds sqrt(n).
    last_possible = math.ceil(math.sqrt(num))
    i = 5
    while (i <= last_possible):
        if (((num % i) == 0) or ((num % (i + 2)) == 0)):
            debug.trace_fmt(4, "{n} not prime as (6k +/- 1) divisible by 2 or 3 for some k.", n=num)
            is_prime_num = False
            break
        i += 6

    debug.trace_fmt(5, "is_prime({n}) => {ip}", n=num, ip=is_prime_num)
    return is_prime_num


def prime_factorization(num):
    """Return list of primne factors for NUM"""
    ## EX: prime_factors(123) => [3, 41]
    ## EX: prime_factors(127) => [127]
    i = 2
    factors = []
    while i * i <= num:
        if num % i:
            i += 1
        else:
            num //= i
            factors.append(i)
    if num > 1:
        factors.append(num)
    debug.trace(6, f"prime_factorization({num}) => factors")
    return factors


def fibonacci(max_num):
    """Returns Fibonacci sequence with numbers less than MAX_NUM"""
    # EX: fibonacci(10) => [0, 1, 1, 2, 3, 5, 8]
    a, b = 0, 1
    sequence = []
    while (a < max_num):
        sequence.append(a)
        a, b = b, (a + b)
    debug.trace_fmt(9, "fibonacci({m}) => {s}", m=max_num, s=sequence)
    return sequence


def sort_weighted_hash(weights, max_num=None, reverse=None):
    """sorts the entries in WEIGHTS hash, returns list of (key, freq) tuples.
    Note: sorted in REVERSE order by default"""
    if max_num is None:
        max_num = len(weights)
    if reverse is None:
        reverse = True
    sorted_keys = sorted(weights.keys(), reverse=reverse, 
                         key=lambda k: weights[k])
    top_values = [(k, weights[k]) for k in sorted_keys[:max_num]]
    debug.trace_fmt(5, "sort_weighted_hash(_, [max={m}], [rev={r}) => {t}",
                    m=max_num, r=reverse, t=top_values)
    return top_values


def unzip(iterable, num=None):
    """"Inverse of zip operation: returns n lists of i-th elements of input list of tuples. The optional NUM argument ensures that that many values returned (in case of empty input lists)"""
    # See https://stackoverflow.com/questions/19339/transpose-unzip-function-inverse-of-zip.
    # EX: unzip(zip([1, 2, 3], ['a', 'b', 'c'])) => [[1, 2, 3], ['a', 'b', 'c']]
    # EX: unzip(zip([], []), 2) => [[], []]
    result = [list(tupl) for tupl in zip(*iterable)]
    if not result and num:
        result = [[] for _i in range(num)]
    return result


def get_current_frame():
    """Return stack frame"""
    frame = inspect.currentframe().f_back
    debug.trace_fmt(6, "get_current_frame() => {f}", f=frame)
    return frame


def eval_expression(expr_text, frame=None):
    """Evaluate EXPRESSION_given_by_TEXT"""
    # EX: eval_expression("len([123, 321]) == 2")
    result = None
    try:
        if frame is None:
            frame = get_current_frame()
            # Note: need to get caller's frame
            frame = frame.f_back
        # pylint: disable=eval-used
        result = eval(expr_text, frame.f_globals, frame.f_locals)
    except:
        debug.trace_fmt(5, "Exception during eval_expression({expr}): {exc}",
                        expr=expr_text, exc=sys.exc_info())
    debug.trace_fmt(7, "eval_expression({expr}) => {r}",
                    expr=expr_text, r=result)
    return result


def trace_named_object(level, object_name, caller_frame=None):
    """Trace OBJECT_given_by_NAME
    Note: ***use debug.trace_expr instead ***"""
    # EX: trace_named_object(4, "sys.argv")
    if caller_frame is None:
        caller_frame = get_current_frame().f_back
    debug.trace_object(level, eval_expression(object_name,
                                              frame=caller_frame),
                       label=object_name)
    return


def trace_named_objects(level, list_text):
    """Trace objects in LIST_text
    Note: *** use debug.trace_expr instead ***"""
    # EX: trace_named_object(4, "[len(sys.argv), sys.argv]")
    debug.assertion(re.search(r"^\[.*\]$", list_text))
    frame = get_current_frame().f_back
    for name in text_utils.extract_string_list(list_text[1:-1]):
        trace_named_object(level, name, caller_frame=frame)
    return


def exactly1(items):
    """Whether one and only one if ITEMS is true"""
    ok = more_itertools.exactly_n(items, 1)
    debug.trace(4, f"exactly1({items}) => {ok}")
    return ok 


def string_diff(text1, text2):
    """Return diff-style comparison of TEXT1 and TEXT2 with an empty string used for equality"""
    debug.trace(6, f"string_diff({text1}, {text2})")
    # EX: string_diff("one\ntwo\nthree\nfour", "one\ntoo\ntree\nfour") => "  one\n< two\n…  ^\n> too\n…  ^\n< three\n…  -\n> tree\n  four\n"

    # Perform comparison
    diff_result = "n/a"
    try:
        lines1 = (text1 + "\n").splitlines(keepends=True)
        lines2 = (text2 + "\n").splitlines(keepends=True)
        diff_result = "".join(ndiff(lines1, lines2))
    except:
        system.print_exception_info("string_diff compare")

    # Convert to diff-style output, using:
    # < and > instead of - and +
    # … instead of ?
    try:
        diff_result = re.sub(r"^- ", "< ", diff_result, flags=re.MULTILINE)
        diff_result = re.sub(r"^\+ ", "> ", diff_result, flags=re.MULTILINE)
        diff_result = re.sub(r"^\? ", f"{ELLIPSIS} ", diff_result, flags=re.MULTILINE)
    except:
        system.print_exception_info("string_diff postprocess")

    debug.trace(6, f"string_diff() => {diff_result}")
    return diff_result


def elide_string_values(obj, depth=0, max_len=None):
    """Elide the values of all strings in OBJ, which can either be a scalar, a list or a hash"""
    if max_len is None:
        max_len = 32
    MAX_DEPTH = 10
    if isinstance(obj, list) and (depth < MAX_DEPTH):
        obj = [elide_string_values(v, depth=(1 + depth), max_len=max_len) for v in obj]
    elif isinstance(obj, dict) and (depth < MAX_DEPTH):
        obj = {k: elide_string_values(obj[k], depth=(1 + depth), max_len=max_len) for k in obj.keys()}
    elif isinstance(obj, str):
        obj = gh.elide(obj, max_len=max_len)
    else:
        pass
    return obj


def is_close(value1, value2, epsilon=VALUE_EPSILON):
    """Whether VALUE1 and VALUE2 are close (i.e., absolute difference <= epsilon)"""
    # See https://stackoverflow.com/questions/35324893/using-math-isclose-function-with-values-close-to-0
    ## EX: is_close(1.001, 1.002, epsilon=.005)
    ## EX: (not is_close(1.001, 1.002, epsilon=.0005))
    result = math.isclose(value1, value2, abs_tol=epsilon)
    debug.trace(6, f"is_close({value1}, {value2}, [eps={epsilon}]) => {result}")
    return result


def get_date_ddmmmyy(date=None):
    """Return (today's) date in DDMMMYY format (e.g., 10oct22)"""
    ## TODO EX: get_date_ddmmmyy(datetime.date(0)) => "01jan70"
    in_date = date
    if date is None:
        date = datetime.date.today()
    try:
        result = date.strftime("%d%b%y").lower()
    except:
        system.print_exception_info("get_today_ddmmmyy")
        result = "???"
    debug.trace(6, f"get_date_ddmmmyy({in_date}) => {result}")
    return result

#-------------------------------------------------------------------------------

def main(args):
    """Supporting code for command-line processing"""
    debug.trace_fmtd(6, "main({a})", a=args)
    system.print_stderr("Warning: not intended for direct invocation")
    return

if __name__ == '__main__':
    main(sys.argv)
