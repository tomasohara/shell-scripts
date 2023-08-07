#! /usr/bin/env python
#
# Tests for train_language_model module
#
# Notes:
# - This can be run as follows:
#   $ PYTHONPATH=".:$PYTHONPATH" python ./mezcla/tests/test_train_language_model.py
#

"""Tests for train_language_model module"""

# Standard modules
## NOTE: this is empty for now

# Installed modules
import pytest

# Local modules
from mezcla import debug

# Note: Rreference are used for the module to be tested:
#    THE_MODULE:	    global module object
import mezcla.train_language_model as THE_MODULE

class TestTrainLanguageModel:
    """Class for testcase definition"""

    ## TODO: TESTS WORK-IN-PROGRESS


if __name__ == '__main__':
    debug.trace_current_context()
    pytest.main([__file__])
