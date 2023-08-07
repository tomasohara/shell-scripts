#! /usr/bin/env python
#
# Test(s) for ../misc_utils.py
#
# Notes:
# - For debugging the tested script, the ALLOW_SUBCOMMAND_TRACING environment
#   option shows tracing output normally suppressed by  unittest_wrapper.py.
# - This can be run as follows:
#   $ PYTHONPATH=".:$PYTHONPATH" python ./mezcla/tests/test_misc_utils.py
#

"""Tests for misc_utils module"""

# Standard packages
## NOTE: this is empty for now

# Installed packages
import pytest

# Local packages
from mezcla import glue_helpers as gh
from mezcla import debug

# Note: Two references are used for the module to be tested:
#    THE_MODULE:	    global module object
import mezcla.misc_utils as THE_MODULE

class TestMiscUtils:
    """Class for test case definitions"""

    def test_transitive_closure(self):
        """Ensure transitive_closure works as expected"""
        debug.trace(4, "test_transitive_closure()")

        actual = THE_MODULE.transitive_closure([(1, 2), (2, 3), (3, 4)])
        expected = set([(1, 2), (1, 3), (1, 4), (2, 3), (3, 4), (2, 4)])
        assert actual == expected

    def test_read_tabular_data(self):
        """Ensure read_tabular_data works as expected"""
        debug.trace(4, "test_read_tabular_data()")
        string_table = (
            'language\tPython\n' +
            'framework\tPytest\n'
        )
        dict_table = {
            'language': 'Python\n',
            'framework': 'Pytest\n',
        }
        temp_file = gh.get_temp_file()
        gh.write_file(temp_file, string_table)
        assert THE_MODULE.read_tabular_data(temp_file) == dict_table

    def test_extract_string_list(self):
        """Ensure extract_string_list works as expected"""
        debug.trace(4, "test_extract_string_list()")
        assert THE_MODULE.extract_string_list("1  2,3") == ['1', '2', '3']

    def test_is_prime(self):
        """Ensure is_prime works as expected"""
        debug.trace(4, "test_is_prime()")

        FIRST_100_PRIMES = [
            2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37,
            41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83,
            89, 97, 101, 103, 107, 109, 113, 127, 131,
            137, 139, 149, 151, 157, 163, 167, 173, 179,
            181, 191, 193, 197, 199, 211, 223, 227, 229,
            233, 239, 241, 251, 257, 263, 269, 271, 277,
            281, 283, 293, 307, 311, 313, 317, 331, 337,
            347, 349, 353, 359, 367, 373, 379, 383, 389,
            397, 401, 409, 419, 421, 431, 433, 439, 443,
            449, 457, 461, 463, 467, 479, 487, 491, 499,
            503, 509, 521, 523, 541,
        ]

        assert all([THE_MODULE.is_prime(n) for n in FIRST_100_PRIMES])
        assert all([(not THE_MODULE.is_prime(n)) for n in range(FIRST_100_PRIMES[-1])  if n not in FIRST_100_PRIMES])

    def test_fibonacci(self):
        """Ensure fibonacci works as expected"""
        debug.trace(4, "test_fibonacci()")
        assert THE_MODULE.fibonacci(-5) == []
        assert THE_MODULE.fibonacci(1) == [0]
        assert THE_MODULE.fibonacci(10) == [0, 1, 1, 2, 3, 5, 8]

    def test_sort_weighted_hash(self):
        """Ensure sort_weighted_hash works as expected"""
        debug.trace(4, "test_sort_weighted_hash()")
        test_hash = {
            'bananas': 3,
            'apples': 1411,
            'peach': 43,
        }
        sorted_hash = [
            ('bananas', 3),
            ('peach', 43),
            ('apples', 1411),
        ]
        reversed_hash = [
            ('apples', 1411),
            ('peach', 43),
            ('bananas', 3),
        ]
        assert THE_MODULE.sort_weighted_hash(test_hash) == reversed_hash
        assert THE_MODULE.sort_weighted_hash(test_hash, reverse=False) == sorted_hash
        assert len(THE_MODULE.sort_weighted_hash(test_hash, max_num=2)) == 2

    def test_unzip(self):
        """Ensure unzip works as expected"""
        debug.trace(4, "test_unzip()")
        assert THE_MODULE.unzip(zip([1, 2, 3], ['a', 'b', 'c'])) == [[1, 2, 3], ['a', 'b', 'c']]
        assert THE_MODULE.unzip(zip([], []), 2) == [[], []]
        assert THE_MODULE.unzip(zip(), 4) == [[], [], [], []]
        assert THE_MODULE.unzip(zip(), 4) != [[], []]

    def test_get_current_frame(self):
        """Ensure get_current_frame works as expected"""
        debug.trace(4, "test_get_current_frame()")
        ## TODO: WORK-IN-PROGRESS

    def test_eval_expression(self):
        """Ensure eval_expression works as expected"""
        debug.trace(4, "test_eval_expression()")
        assert THE_MODULE.eval_expression("len([123, 321]) == 2")
        assert not THE_MODULE.eval_expression("'helloworld' == 2")

    def test_trace_named_object(self, capsys):
        """Ensure trace_named_object works as expected"""
        debug.trace(4, "test_trace_named_object()")
        # With level -1 we ensure that the trace will be printed
        THE_MODULE.trace_named_object(-1, "sys.argv")
        captured = capsys.readouterr()
        assert "sys.argv" in captured.err

    def test_trace_named_objects(self, capsys):
        """Ensure trace_named_objects works as expected"""
        debug.trace(4, "test_trace_named_objects()")
        # With level -1 we ensure that the trace will be printed
        THE_MODULE.trace_named_objects(-1, "[len(sys.argv), sys.argv]")
        captured = capsys.readouterr()
        assert "len(sys.argv)" in captured.err
        assert "sys.argv" in captured.err

    def test_exactly1(self):
        """Ensure exactly1 works as expected"""
        debug.trace(4, "test_exactly1()")
        assert THE_MODULE.exactly1([False, False, True])
        assert not THE_MODULE.exactly1([False, True, True])
        assert not THE_MODULE.exactly1([False, False, False])
        assert not THE_MODULE.exactly1([])

    def test_string_diff(self):
        """Ensure string_diff works as expected"""
        debug.trace(4, "test_string_diff()")

        STRING_ONE = 'one\ntwo\nthree\nfour'
        STRING_TWO = 'one\ntoo\ntree\nfour'
        EXPECTED_DIFF = (
            '  one\n'
            '< two\n'
            '…  ^\n'
            '> too\n'
            '…  ^\n'
            '< three\n'
            '…  -\n'
            '> tree\n'
            '  four\n'
        )

        assert THE_MODULE.string_diff(STRING_ONE, STRING_TWO) == EXPECTED_DIFF

    def test_elide_string_values(self):
        """Ensure elide_string_values works as expected"""
        debug.trace(4, "test_elide_string_values()")
        ## TODO: WORK-IN-PROGRESS


if __name__ == '__main__':
    debug.trace_current_context()
    pytest.main([__file__])
