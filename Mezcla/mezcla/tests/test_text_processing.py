#! /usr/bin/env python
#
# Test(s) for ../text_processing.py
#
# Notes:
# - For debugging the tested script, the ALLOW_SUBCOMMAND_TRACING environment
#   option shows tracing output normally suppressed by unittest_wrapper.py.
# - This can be run as follows:
#   $ PYTHONPATH=".:$PYTHONPATH" python ./mezcla/tests/test_text_processing.py
#

"""Tests for text_processing module"""

# Standard packages
## NOTE: this is empty for now

# Installed packages
import pytest

# Local packages
from mezcla import debug
from mezcla import glue_helpers as gh

# Note: Two references are used for the module to be tested:
#    THE_MODULE:	    global module object
import mezcla.text_processing as THE_MODULE
from mezcla.unittest_wrapper import TestWrapper

# Constants
RESOURCES = f'{gh.dir_path(__file__)}/resources'
TEXT_EXAMPLE = f'{RESOURCES}/example_text.txt'
TEXT_EXAMPLE_TAGS = f'{RESOURCES}/example_text_tags.txt'
WORD_POS_FREQ_FILE = f'{RESOURCES}/word-POS.freq'

class TestTextProcessing:
    """Class for testcase definition"""

    def test_split_sentences(self):
        """Ensure split_sentences works as expected"""
        debug.trace(4, "test_split_sentences()")
        assert THE_MODULE.split_sentences("I came. I saw. I conquered!") == ["I came.", "I saw.", "I conquered!"]
        assert THE_MODULE.split_sentences("Dr. Watson, it's elementary. But why?") == ["Dr. Watson, it's elementary.", "But why?"]

    def test_split_word_tokens(self):
        """Ensure split_word_tokens works as expected"""
        debug.trace(4, "test_split_word_tokens()")
        assert THE_MODULE.split_word_tokens("How now, brown cow?") == ['How', 'now', ',', 'brown', 'cow', '?']

    def test_label_for_tag(self):
        """Ensure label_for_tag works as expected"""
        debug.trace(4, "test_label_for_tag()")
        ## TODO: WORK-IN=PROGRESS

    def test_class_for_tag(self):
        """Ensure class_for_tag works as expected"""
        debug.trace(4, "test_class_for_tag()")
        assert THE_MODULE.class_for_tag("NNS") == "noun"
        assert THE_MODULE.class_for_tag("VBG") == "verb"
        assert THE_MODULE.class_for_tag("VBG", previous="MD") == "verb"
        assert THE_MODULE.class_for_tag("NNP", word="(") == "punctuation"

    def test_tag_part_of_speech(self):
        """Ensure tag_part_of_speech works as expected"""
        debug.trace(4, "test_tag_part_of_speech()")
        # NOTE:
        #   'brown' tagged as IN is wrong, should be JJ, this is a problem related to NLTK
        #   not the module being tested, so we are ignoring it for now.
        #   Related: https://stackoverflow.com/a/30823202
        assert THE_MODULE.tag_part_of_speech(['How', 'now', ',', 'brown', 'cow', '?']) == [('How', 'WRB'), ('now', 'RB'), (',', ','), ('brown', 'IN'), ('cow', 'NN'), ('?', '.')]

    def test_tokenize_and_tag(self):
        """Ensure tokenize_and_tag works as expected"""
        debug.trace(4, "test_tokenize_and_tag()")
        ## TODO: WORK-IN=PROGRESS

    def test_tokenize_text(self):
        """Ensure tokenize_text works as expected"""
        debug.trace(4, "test_tokenize_text()")
        ## TODO: WORK-IN=PROGRESS

    def test_is_stopword(self):
        """Ensure is_stopword works as expected"""
        debug.trace(4, "test_is_stopword()")
        ## TODO: WORK-IN=PROGRESS

    def test_has_spelling_mistake(self):
        """Ensure has_spelling_mistake works as expected"""
        debug.trace(4, "test_has_spelling_mistake()")
        ## TODO: WORK-IN=PROGRESS

    def test_read_freq_data(self):
        """Ensure read_freq_data works as expected"""
        debug.trace(4, "test_read_freq_data()")
        ## TODO: WORK-IN=PROGRESS

    def test_read_word_POS_data(self): # pylint: disable=invalid-name
        """Ensure read_word_POS_data works as expected"""
        debug.trace(4, "test_read_word_POS_data()")
        ## TODO: WORK-IN=PROGRESS

    def test_get_most_common_POS(self): # pylint: disable=invalid-name
        """Ensure get_most_common_POS works as expected"""
        debug.trace(4, "test_get_most_common_POS()")
        # Testing if word_POS_hash is not none
        THE_MODULE.word_POS_hash = {
            'can': 'MD'
        }
        assert THE_MODULE.get_most_common_POS("notaword") == "NN"
        assert THE_MODULE.get_most_common_POS("can") == "MD"
        # Test reading from freq file
        ## TODO: for some reason this assertion freezes
        ## THE_MODULE.WORD_POS_FREQ_FILE = 'tests/resources/word-POS.freq'
        ## assert THE_MODULE.get_most_common_POS("to") == "TO"

    def test_is_noun(self):
        """Ensure is_noun works as expected"""
        debug.trace(4, "test_is_noun()")
        assert THE_MODULE.is_noun('notaword', 'NN')
        assert not THE_MODULE.is_noun('can', 'MD')

    def test_is_verb(self):
        """Ensure is_verb works as expected"""
        debug.trace(4, "test_is_verb()")
        assert THE_MODULE.is_verb('run', 'VB')
        assert not THE_MODULE.is_verb('can', 'NN')

    def test_is_adverb(self):
        """Ensure is_adverb works as expected"""
        debug.trace(4, "test_is_adverb()")
        assert THE_MODULE.is_adverb('quickly', 'RB')
        assert not THE_MODULE.is_adverb('can', 'MD')

    def test_is_adjective(self):
        """Ensure is_adjective works as expected"""
        debug.trace(4, "test_is_adjective()")
        assert THE_MODULE.is_adjective('quick', 'JJ')
        assert not THE_MODULE.is_adjective('can', 'MD')

    def test_is_comma(self):
        """Ensure is_comma works as expected"""
        debug.trace(4, "test_is_comma()")
        assert THE_MODULE.is_comma('comma', ',')
        assert THE_MODULE.is_comma(',', 'comma')
        assert not THE_MODULE.is_comma('can', 'MD')

    def test_is_quote(self):
        """Ensure is_quote works as expected"""
        debug.trace(4, "test_is_quote()")
        assert THE_MODULE.is_quote('\'', '')
        assert THE_MODULE.is_quote('\"', '')
        assert not THE_MODULE.is_quote('can', 'MD')

    def test_is_punct(self):
        """Ensure is_punct works as expected"""
        debug.trace(4, "test_is_punct()")
        assert THE_MODULE.is_punct('$', '$')
        assert not THE_MODULE.is_punct('can', 'MD')

    def test_usage(self):
        """Ensure usage works as expected"""
        debug.trace(4, "test_usage()")
        ## TODO: WORK-IN=PROGRESS


class TestTextProcessingScript(TestWrapper):
    """Class for testcase definition"""
    script_file = TestWrapper.get_module_file_path(__file__)
    script_module =TestWrapper.get_testing_module_name(__file__)

    def test_all(self):
        """Ensure text_processing without argument works as expected"""
        debug.trace(4, "test_all()")
        output = self.run_script(data_file=TEXT_EXAMPLE)
        assert output == gh.read_file(TEXT_EXAMPLE_TAGS)[:-1]

    def test_just_tokenize(self):
        """Ensure just_tokenize argument works as expected"""
        debug.trace(4, "test_just_tokenize()")
        ## TODO: WORK-IN-PROGRESS

    def test_make_lowercase(self):
        """Ensure make_lowercase argument works as expected"""
        debug.trace(4, "test_make_lowercase()")
        ## TODO: WORK-IN-PROGRESS


if __name__ == '__main__':
    debug.trace_current_context()
    pytest.main([__file__])
