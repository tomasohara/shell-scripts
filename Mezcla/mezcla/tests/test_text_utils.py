#! /usr/bin/env python
#
# Test(s) for ../text_utils.py
#
# Notes:
# - For debugging the tested script, the ALLOW_SUBCOMMAND_TRACING environment
#   option shows tracing output normally suppressed by  unittest_wrapper.py.
# - This can be run as follows:
#   $ PYTHONPATH=".:$PYTHONPATH" python ./mezcla/tests/test_text_utils.py
#

"""Tests for text_utils module"""

# Standard packages
import re
import os

# Installed packages
import pytest

# Local packages
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla import system

# Note: Two references are used for the module to be tested:
#    THE_MODULE:	    global module object
import mezcla.text_utils as THE_MODULE

HTML_FILENAME = "./resources/simple-window-dimensions.html"

EXPECTED_TEXT = """
   Simple window dimensions

   Simple window dimensions

      Legend:
        Screen dimensions:    ???
        Browser dimensions:   ???

   JavaScript is required
"""
#
# NOTE: Whitespace and punctuation gets normalized
# TODO: restore bullet points (e.g., "* Screen dimensions")

MS_WORD_FILENAME = "./resources/spanish-accents.docx"

MS_WORD_TEXT = "Tío Tomás\t\t\t\tUncle Tom\n\n¡Buenos días!\t\t\t\tGood morning\n\nçãêâôöèäàÃëÇÂîòïÔìðÊÅåùÀŠý\t\tcaeaooeaaAeCAioiOioEAauASy"


def normalize_text(text):
    """Trim excess whitespace and convert punctuation to <PUNCT>"""
    # EX: normalize_test_text("   h  e y?! ") => "h e y<PUNCT>"
    result = text.strip()
    result = re.sub(r"\s+", " ", result)
    result = re.sub(r"[^\w\s]+", "<PUNCT>", result)
    debug.trace(4, f"normalize_test_text({text}) => {result}")
    return result


class TestTextUtils:
    """Class for test case definitions"""

    def test_init_BeautifulSoup(self):
        """Ensure init_BeautifulSoup works as expected"""
        debug.trace(4, "test_init_BeautifulSoup()")
        THE_MODULE.BeautifulSoup = None
        THE_MODULE.init_BeautifulSoup()
        assert THE_MODULE.BeautifulSoup is not None

    def test_html_to_text(self):
        """Ensure html_to_text works as expected"""
        # TODO: move into test_html_utils.py
        debug.trace(4, "test_html_to_text()")
        html_path = gh.resolve_path(HTML_FILENAME)
        html = system.read_file(html_path)
        text = THE_MODULE.html_to_text(html)
        assert normalize_text(text) == normalize_text(EXPECTED_TEXT)

    def test_init_textract(self):
        """Ensure init_textract works as expected"""
        debug.trace(4, "test_init_textract()")
        THE_MODULE.textract = None
        THE_MODULE.init_textract()
        assert THE_MODULE.textract is not None

    def test_document_to_text(self):
        """Ensure document_to_text works as expected"""
        debug.trace(4, "test_document_to_text()")
        doc_path = gh.resolve_path(MS_WORD_FILENAME)
        text = THE_MODULE.document_to_text(doc_path)
        assert normalize_text(text) == normalize_text(MS_WORD_TEXT)

    def test_extract_html_images(self):
        """Ensure extract_html_images works as expected"""
        debug.trace(4, "test_extract_html_images()")

        url = 'example.com/'
        html = (
            '<!DOCTYPE html>\n'
            '<html>\n'
            '<body>\n'
            '<h2>The target Attribute</h2>\n'
            '<div class="some-class">this is a div</div>\n'
            '<div class="some-class another-class">'
            '<img src="smiley.gif" alt="Smiley face" width="42" height="42" style="border:5px solid black">\n'
            '<img src="some_image.jpg" alt="Some image" width="42" height="42" style="border:5px solid black">\n'
            '<img src="hidden.jpg" alt="this is a hidden image" width="42" height="42" style="display:none">\n'
            '</div>'
            '</body>\n'
            '</html>\n'
        )
        images_urls = [
            f'{url}/smiley.gif',
            f'{url}/some_image.jpg'
        ]

        result = THE_MODULE.extract_html_images(html, url)
        assert result == images_urls
        assert 'hidden.jpg' not in images_urls

    def test_version_to_number(self):
        """Ensure version_to_number works as expected"""
        debug.trace(4, "test_version_to_number()")

        # Testing simple version text
        assert THE_MODULE.version_to_number("1") == 1
        assert THE_MODULE.version_to_number("") == 0
        assert THE_MODULE.version_to_number("1.11.1") == 1.00110001

        # Testing version with non-numeric components and with new line
        assert THE_MODULE.version_to_number("3.7.6 (default, Jan  8 2020, 19:59:22)<NL>[GCC 7.3.0]\n") == 3.00070006

        # Testing max padding with long and short versions
        assert THE_MODULE.version_to_number("8.12.10143", max_padding=2) == 8.012999
        assert THE_MODULE.version_to_number("15.4.9", max_padding=6) == 15.00000040000009

    def test_extract_string_list(self):
        """Ensure extract_string_list works as expected"""
        debug.trace(4, "test_extract_string_list()")

        # Testing whitespace and commas
        assert THE_MODULE.extract_string_list("") == []
        assert THE_MODULE.extract_string_list(" ") == []
        assert THE_MODULE.extract_string_list(",,") == []
        assert THE_MODULE.extract_string_list("1, 2,3 4") == ['1', '2', '3', '4']
        assert THE_MODULE.extract_string_list("    one,two,   three four   ") == ['one', 'two', 'three', 'four']

        # Testing embedded spaces with quotes
        assert THE_MODULE.extract_string_list("'my dog'  likes  'my  hot  dog'") == ['my dog', 'likes', 'my  hot  dog']
        assert THE_MODULE.extract_string_list("'my dog  likes  my  hot  dog'") == ['my dog  likes  my  hot  dog']

    def test_extract_int_list(self):
        """Ensure extract_int_list works as expected"""
        debug.trace(4, "test_extract_int_list()")

        # Testing normal delimited string
        assert THE_MODULE.extract_int_list("1, 2, 3, 4, 5") == [1, 2, 3, 4, 5]
        assert THE_MODULE.extract_int_list("1   2  3  4   5") == [1, 2, 3, 4, 5]

        # Testing DEFAULT_VALUE
        assert THE_MODULE.extract_int_list("1   2  foobar", default_value=9) == [1, 2, 9]
        assert THE_MODULE.extract_int_list("1   2  3.45", default_value=230) == [1, 2, 230]

    def test_getenv_ints(self, monkeypatch):
        """Ensure getenv_ints works as expected"""
        debug.trace(4, "test_getenv_ints()")
        monkeypatch.setenv("DUMMY-VARIABLE", "0, 1  2  3 4 ", prepend=os.pathsep)
        assert THE_MODULE.getenv_ints("DUMMY-VARIABLE", str(list(range(5)))) == [0, 1, 2, 3, 4]

    def test_is_symbolic(self):
        """Ensure is_symbolic works as expected"""
        debug.trace(4, "test_is_symbolic()")
        assert THE_MODULE.is_symbolic("PI")
        assert not THE_MODULE.is_symbolic("3.14159")
        assert not THE_MODULE.is_symbolic("123")
        assert not THE_MODULE.is_symbolic(123)
        assert not THE_MODULE.is_symbolic(0.1)

    def test_make_fixed_length(self):
        """Ensure make_fixed_length works as expected"""
        debug.trace(4, "make_fixed_length()")
        assert THE_MODULE.make_fixed_length("fubar", 3) == "fub"
        assert THE_MODULE.make_fixed_length("fub", 5) == "fub  "

#------------------------------------------------------------------------

if __name__ == '__main__':
    debug.trace_current_context()
    pytest.main([__file__])
