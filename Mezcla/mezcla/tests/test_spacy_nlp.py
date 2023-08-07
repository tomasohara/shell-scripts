#! /usr/bin/env python
#
# Test(s) for ../spacy_nlp.py
#
# Notes:
# - For debugging the tested script, the ALLOW_SUBCOMMAND_TRACING environment
#   option shows tracing output normally suppressed by  unittest_wrapper.py.
# - This can be run as follows:
#   $ PYTHONPATH=".:$PYTHONPATH" python ./mezcla/tests/test_spacy_nlp.py
#

"""Tests for spacy_nlp module"""

# Standard packages
## NOTE: this is empty for now

# Installed packages
import pytest

# Local packages
from mezcla import debug
from mezcla import glue_helpers as gh

# Note: Two references are used for the module to be tested:
#    THE_MODULE:	    global module object
import mezcla.spacy_nlp as THE_MODULE
from mezcla.unittest_wrapper import TestWrapper


class TestSentimentAnalyzer:
    """Class for testcase definition"""

    @pytest.mark.xfail
    def test_get_score(self):
        """Ensure SentimentAnalyzer.get_score works as expected"""
        debug.trace(4, "test_get_score()")
        sentiment = THE_MODULE.SentimentAnalyzer()
        assert sentiment.get_score('bad') == -0.5423
        assert sentiment.get_score('good') == 0.4404


class TestSpacyNlpUtils:
    """Class for testcase definition"""

    def test_get_char_span(self):
        """Ensure get_char_span works as expected"""
        debug.trace(4, "test_get_char_span()")
        ## TODO: WORK-IN=PROGRESS

    def test_pysbd_sentence_boundaries(self):
        """Ensure pysbd_sentence_boundaries works as expected"""
        debug.trace(4, "test_pysbd_sentence_boundaries()")
        ## TODO: WORK-IN=PROGRESS

    def test_nltk_sentence_boundaries(self):
        """Ensure nltk_sentence_boundaries works as expected"""
        debug.trace(4, "test_nltk_sentence_boundaries()")
        ## TODO: WORK-IN=PROGRESS


class TestSpacy(TestWrapper):
    """Class for testcase definition"""
    script_file = TestWrapper.get_module_file_path(__file__)
    script_module = TestWrapper.get_testing_module_name(__file__)

    ## TODO: WORK-IN-PROGRESS TESTS


if __name__ == '__main__':
    debug.trace_current_context()
    pytest.main([__file__])
