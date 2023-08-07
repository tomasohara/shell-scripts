#! /usr/bin/env python
#
# Test(s) for ../show_bert_representation.py
#
# Notes:
# - For debugging the tested script, the ALLOW_SUBCOMMAND_TRACING environment
#   option shows tracing output normally suppressed by  unittest_wrapper.py.
# - This can be run as follows:
#   $ PYTHONPATH=".:$PYTHONPATH" python ./mezcla/tests/test_show_bert_representation.py
#
# IMPORTANT:
# - this is more like a bureaucratic test file, this module has priority NONE to be tested (for now)

"""Tests for show_bert_representation module"""

# Standard packages
## NOTE: this is empty for now

# Installed packages
import pytest

# Local packages
from mezcla import debug

# Note: Two references are used for the module to be tested:
#    THE_MODULE:	    global module object
import mezcla.show_bert_representation as THE_MODULE

class TestShowBertRepresentation:
    """Class for testcase definition"""

    def test_cosine_distance(self):
        """Ensure cosine_distance works as expected"""
        debug.trace(4, "test_cosine_distance()")
        assert THE_MODULE.cosine_distance([1, 0, 0], [0, 0, 1]) == 1.0 
        assert THE_MODULE.cosine_distance([1, 0, 0], [2, 0, 0]) == 0.0 
        assert THE_MODULE.cosine_distance([1, 0, 0, 0], [1, 1, 1, 1]) == 0.5 

    def test_show_cosine_distances(self):
        """Ensure show_cosine_distances works as expected"""
        debug.trace(4, "test_show_cosine_distances()")
        ## TODO: WORK-IN=PROGRESS

    ## TODO: test ExtractFeatures class
    ## TODO: test Script class

if __name__ == '__main__':
    debug.trace_current_context()
    pytest.main([__file__])
