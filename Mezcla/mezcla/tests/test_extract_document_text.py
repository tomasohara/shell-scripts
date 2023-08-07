#! /usr/bin/env python
#
# Test(s) for ../extract_document_text.py
#
# Notes:
# - For debugging the tested script, the ALLOW_SUBCOMMAND_TRACING environment
#   option shows tracing output normally suppressed by  unittest_wrapper.py.
# - This can be run as follows:
#   $ PYTHONPATH=".:$PYTHONPATH" python ./mezcla/tests/test_extract_document_text.py
#

"""Tests for extract_document_text module"""

# Standard packages
## NOTE: this is empty for now

# Installed packages
import pytest

# Local packages
from mezcla import debug

# Note: Two references are used for the module to be tested:
#    THE_MODULE:	    global module object
import mezcla.extract_document_text as THE_MODULE

class TestExtractDocumentText:
    """Class for testcase definition"""
    
    def test_document_to_text(self):
        """Ensure document_to_text() works as expected"""
        debug.trace(4, "test_document_to_text()")
        ## TODO: WORK-IN-PROGRESS


if __name__ == '__main__':
    debug.trace_current_context()
    pytest.main([__file__])
