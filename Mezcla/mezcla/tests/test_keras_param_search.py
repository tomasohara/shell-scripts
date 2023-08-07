#! /usr/bin/env python
#
# Test(s) for ../keras_param_search.py
#
# Notes:
# - For debugging the tested script, the ALLOW_SUBCOMMAND_TRACING environment
#   option shows tracing output normally suppressed by  unittest_wrapper.py.
# - This can be run as follows:
#   $ PYTHONPATH=".:$PYTHONPATH" python ./mezcla/tests/test_keras_param_search.py
#

"""Tests for keras_param_search module"""

# Standard packages
## TODO: import re

# Installed packages
import pytest

# Local packages
from mezcla import debug

# Load module conditionally because not part of default installation.
# Note: Two references are used for the module to be tested:
#    THE_MODULE:	    global module object
try:
    import mezcla.keras_param_search as THE_MODULE
except:
    THE_MODULE = None
    debug.trace_exception(1, "keras_param_search import")

class TestKerasParamSearch:
    """Class for testcase definition"""

    @pytest.mark.skipif(not THE_MODULE, reason="Unable to load module")
    def test_round3(self):
        """Ensure round3 works as expected"""
        debug.trace(4, f"test_round3(); self={self}")
        assert THE_MODULE.round3(1.0001) == 1.000
        assert THE_MODULE.round3(1.001) == 1.001

    @pytest.mark.xfail
    def test_non_negative(self):
        """Ensure non_negative works as expected"""
        debug.trace(4, f"test_non_negative(); self={self}")
        ## TODO: WORK-IN=PROGRESS
        assert(False)

    @pytest.mark.xfail
    def test_create_feature_mapping(self):
        """Ensure create_feature_mapping works as expected"""
        debug.trace(4, f"test_create_feature_mapping(); self={self}")
        assert THE_MODULE.create_feature_mapping(['c', 'b', 'b', 'a']) == {'c':0, 'b':1, 'a':2}

    @pytest.mark.xfail
    def test_create_keras_model(self):
        """Ensure create_keras_model works as expected"""
        debug.trace(4, f"test_create_keras_model(); self={self}")
        ## TODO: WORK-IN=PROGRESS
        assert(False)

    ## TODO: test MyKerasClassifier class
    ## TODO: test main


if __name__ == '__main__':
    debug.trace_current_context()
    pytest.main([__file__])
