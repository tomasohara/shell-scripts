#! /usr/bin/env python
#
# Test(s) for ../compute_tfidf.py
#
# Notes:
# - For debugging the tested script, the ALLOW_SUBCOMMAND_TRACING environment
#   option shows tracing output normally suppressed by  unittest_wrapper.py.
# - This can be run as follows:
#   $ PYTHONPATH=".:$PYTHONPATH" python ./mezcla/tests/test_compute_tfidf.py
#

"""Tests for compute_tfidf module"""

# Standard packages
## NOTE: this is empty for now

# Installed packages
import pytest

# Local packages
from mezcla import debug

# Note: Two references are used for the module to be tested:
#    THE_MODULE:	    global module object
import mezcla.compute_tfidf as THE_MODULE

class TestComputeTfidf:
    """Class for testcase definition"""

    def test_show_usage_and_quit(self):
        """Ensure show_usage_and_quit works as expected"""
        debug.trace(4, "test_show_usage_and_quit()")
        ## TODO: WORK-IN=PROGRESS

    def test_get_suffix1_prefix2(self):
        """Ensure get_suffix1_prefix2 works as expected"""
        debug.trace(4, "test_get_suffix1_prefix2()")
        assert THE_MODULE.get_suffix1_prefix2(["my", "dog"], ["dog", "has"]) == ["dog"]
        assert THE_MODULE.get_suffix1_prefix2(["a", "b", "c"], ["b", "d"]) == []

    def test_terms_overlap(self):
        """Ensure terms_overlap works as expected"""
        debug.trace(4, "test_terms_overlap()")
        assert THE_MODULE.terms_overlap("ACME Rocket Research", "Rocket Research Labs") == "Rocket Research"
        assert not THE_MODULE.terms_overlap("Rocket Res", "Rocket Research")

    def test_is_subsumed(self):
        """Ensure is_subsumed works as expected"""
        debug.trace(4, "test_is_subsumed()")
        assert THE_MODULE.is_subsumed("White House", ["The White House", "Congress", "Supreme Court"])
        assert THE_MODULE.is_subsumed("White House", ["White Houses"])

    ## TODO: Add tests for main()

if __name__ == '__main__':
    debug.trace_current_context()
    pytest.main([__file__])
