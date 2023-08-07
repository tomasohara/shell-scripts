#! /usr/bin/env python
#
# Test(s) for ../ngram_tfidf.py
#
# Notes:
# - For debugging the tested script, the ALLOW_SUBCOMMAND_TRACING environment
#   option shows tracing output normally suppressed by  unittest_wrapper.py.
# - This can be run as follows:
#   $ PYTHONPATH=".:$PYTHONPATH" python ./mezcla/tests/test_ngram_tfidf.py
#

"""Tests for ngram_tfidf module"""

# Standard packages
## NOTE: this is empty for now

# Installed packages
import pytest

# Local packages
from mezcla import debug

# Note: Two references are used for the module to be tested:
#    THE_MODULE:	    global module object
## TODO: fix type object 'Preprocessor' has no attribute 'USE_SKLEARN_COUNTER'
## import mezcla.ngram_tfidf as THE_MODULE

class TestNgramTfidf:
    """Class for testcase definition"""

    ## TODO: TESTS WORK-IN-PROGRESS


if __name__ == '__main__':
    debug.trace_current_context()
    pytest.main([__file__])
