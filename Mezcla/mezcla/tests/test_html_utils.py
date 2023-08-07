#! /usr/bin/env python
#
# Test(s) for ../html_utils.py
#
# Notes:
# - Fill out TODO's below. Use numbered tests to order (e.g., test_1_usage).
# - TODO: If any of the setup/cleanup methods defined, make sure to invoke base
#   (see examples below for setUp and tearDown).
# - This can be run as follows:
#   $ PYTHONPATH=".:$PYTHONPATH" python ./mezcla/tests/test_html_utils.py
#

"""Tests for html_utils module"""

# Standard packages
import re

# Installed packages
import pytest
import bs4

# Local packages
from mezcla.unittest_wrapper import TestWrapper
from mezcla import debug
from mezcla import system
from mezcla import glue_helpers as gh

# Note: Two references are used for the module to be tested:
#    THE_MODULE:	    global module object
## TODO: template => new name
import mezcla.html_utils as THE_MODULE
#
# Note: sanity test for customization (TODO: remove if desired)
if not re.search(__file__, r"\btemplate.py$"):
    debug.assertion("mezcla.template" not in str(THE_MODULE))

# 
TEST_SELENIUM = system.getenv_bool("TEST_SELENIUM", False,
                                   "Include tests requiring selenium")

class TestHtmlUtils(TestWrapper):
    """Class for testcase definition"""
    script_module = TestWrapper.get_testing_module_name(__file__)
    # TODO: use_temp_base_dir = True            # treat TEMP_BASE as directory
    # note: temp_file defined by parent (along with script_module, temp_base, and test_num)

    def test_get_browser(self):
        """Ensure get_browser() works as expected"""
        debug.trace(4, "test_get_browser()")
        ## TODO: WORK-IN-PROGRESS

    def test_get_url_parameter_value(self):
        """Ensure get_url_parameter_value works as expected"""
        debug.trace(4, "test_get_url_parameter_value()")
        save_user_parameters = THE_MODULE.user_parameters
        THE_MODULE.user_parameters = {}
        assert THE_MODULE.get_url_parameter_value("fubar", None) == None
        assert THE_MODULE.get_url_parameter_value("fubar", None, {"fubar": "fu"}) == "fu"
        THE_MODULE.user_parameters = {"fubar": "bar"}
        assert THE_MODULE.get_url_parameter_value("fubar", None) == "bar"
        assert THE_MODULE.get_url_parameter_value("fubar", None, {"fubar": "fu"}) == "fu"
        THE_MODULE.user_parameters = save_user_parameters
        return

    def test_get_inner_text(self):
        """Verify that JavaScript fills in window dimensions
        Note: requires selenium"""
        debug.trace(4, "test_get_inner_text()")
        if not TEST_SELENIUM:
            debug.trace(4, "Ignoring test_get_inner_text as selenium required")
            return
        html_filename = "simple-window-dimensions.html"
        html_path = gh.resolve_path(html_filename)
        url = ("file:" + system.absolute_path(html_path))
        # TODO: use direct API call to return unrendered text
        unrendered_text = gh.run(f"lynx -dump {url}")
        debug.trace_expr(5, unrendered_text)
        assert re.search(r"Browser dimensions: \?", unrendered_text)
        rendered_text = THE_MODULE.get_inner_text(url)
        debug.trace_expr(5, rendered_text)
        assert re.search(r"Browser dimensions: \d+x\d+", rendered_text)
    
    def test_get_inner_html(self):
        """Verify that JavaScript fills in window dimensions
        Note: requires selenium"""
        debug.trace(4, "test_get_inner_html()")
        if not TEST_SELENIUM:
            debug.trace(4, "Ignoring test_get_inner_html as selenium required")
            return
        html_filename = "simple-window-dimensions.html"
        html_path = gh.resolve_path(html_filename)
        url = ("file:" + system.absolute_path(html_path))
        # TODO: use direct API call to return unrendered text
        unrendered_html = gh.run(f"lynx -source {url}")
        debug.trace_expr(5, unrendered_html)
        assert re.search(
            r"<li>Browser dimensions:\s*<span.*>\?\?\?</span></li>",
            unrendered_html,
            )
        rendered_html = THE_MODULE.get_inner_html(url)
        debug.trace_expr(5, rendered_html)
        assert re.search(
            r"<li>Browser dimensions:\s*<span.*>\d+x\d+</span></li>",
            rendered_html,
            )

    def test_document_ready(self):
        """Ensure document_ready() works as expected"""
        debug.trace(4, "test_document_ready()")
        ## TODO: WORK-IN-PROGRESS

    def test_escape_html_value(self):
        """Ensure escape_html_value() works as expected"""
        debug.trace(4, "test_escape_html_value()")
        # note: this test is the same as system.test_escape_html_text
        assert THE_MODULE.escape_html_value("<2/") == "&lt;2/"
        assert THE_MODULE.escape_html_value("Joe's hat") == "Joe&#x27;s hat"

    def test_unescape_html_value(self):
        """Ensure unescape_html_value() works as expected"""
        debug.trace(4, "test_unescape_html_value()")
        # note: this test is the same as test_system.test_unescape_html_text
        assert THE_MODULE.unescape_html_value("&lt;2/") == "<2/" 
        assert THE_MODULE.unescape_html_value("Joe&#x27;s hat") == "Joe's hat" 

    def test_escape_hash_value(self):
        """Ensure escape_hash_value() works as expected"""
        debug.trace(4, "test_escape_hash_value()")
        hash_table = {
            'content-type': 'multipart/form-data;\n',
            'name': 'description'
        }
        assert THE_MODULE.escape_hash_value(hash_table, 'content-type') == 'multipart/form-data;<br>'

    def test_get_param_dict(self):
        """Ensure get_param_dict() works as expected"""
        debug.trace(4, "test_get_param_dict()")
        THE_MODULE.user_parameters = {
            'https-port': '443',
            'not-found-status': '404',
            'redirect-status': '302'
        }
        assert THE_MODULE.get_param_dict('not-found-status') == 'not-found-status'
        assert THE_MODULE.get_param_dict() == THE_MODULE.user_parameters

    def test_set_param_dict(self):
        """Ensure set_param_dict() works as expected"""
        debug.trace(4, "test_set_param_dict()")
        THE_MODULE.user_parameters = {
            'not-found-status': '404',
            'redirect-status': '302'
        }
        new_user_parameters = {'https-port': '443'}
        THE_MODULE.issued_param_dict_warning = False
        THE_MODULE.set_param_dict(new_user_parameters)
        assert THE_MODULE.user_parameters == new_user_parameters
        assert THE_MODULE.issued_param_dict_warning

    def test_get_url_param(self):
        """Ensure get_url_param() works as expected"""
        debug.trace(4, "test_get_url_param()")
        THE_MODULE.user_parameters = {
            'not-found-status': '404',
            'redirect-status': '302',
            'default-body': "Joe's hat"
        }
        assert THE_MODULE.get_url_param('redirect-status') == '302'
        assert THE_MODULE.get_url_param('bad-request-status', default_value='400') == '400'
        assert THE_MODULE.get_url_param('default-body', escaped=True) == 'Joe&#x27;s hat'

    def test_get_url_param_checkbox_spec(self):
        """Ensure get_url_param_checkbox_spec() works as expected"""
        debug.trace(4, "test_get_url_param_checkbox_spec()")
        ## TODO: WORK-IN-PROGRESS

    def test_get_url_parameter_bool(self):
        """Ensure get_url_parameter_bool() works as expected"""
        debug.trace(4, "test_get_url_parameter_bool()")
        assert THE_MODULE.get_url_parameter_bool("abc", False, { "abc": "on" })
        assert THE_MODULE.get_url_param_bool("abc", False, { "abc": "True" })

    def test_get_url_parameter_int(self):
        """Ensure get_url_parameter_int() works as expected"""
        debug.trace(4, "test_get_url_parameter_int()")
        ## TODO: WORK-IN-PROGRESS

    def test_fix_url_parameters(self):
        """Ensure fix_url_parameters() works as expected"""
        debug.trace(4, "test_fix_url_parameters()")
        assert THE_MODULE.fix_url_parameters({'w_v':[7, 8], 'h_v':10}) == {'w-v':8, 'h-v':10}

    def test_expand_misc_param(self):
        """Ensure expand_misc_param() works as expected"""
        debug.trace(4, "test_expand_misc_param()")
        misc_dict = {
            'x': 1,
            'y': 2,
            'z': 'a=3, b=4',
        }
        expected = {
            'x': 1,
            'y': 2,
            'z': 'a=3, b=4',
            'a': '3',
            'b': '4',
        }
        assert THE_MODULE.expand_misc_param(misc_dict, 'z') == expected

    def test__read_file(self):
        """Ensure _read_file() works as expected"""
        debug.trace(4, "test__read_file()")
        ## TODO: WORK-IN-PROGRESS

    def test__write_file(self):
        """Ensure _write_file() works as expected"""
        debug.trace(4, "test__write_file()")
        ## TODO: WORK-IN-PROGRESS

    def test_old_download_web_document(self):
        """Ensure old_download_web_document() works as expected"""
        debug.trace(4, "test_old_download_web_document()")
        assert "<!doctype html>" in THE_MODULE.old_download_web_document("https://www.google.com")

    def test_download_web_document(self):
        """Ensure download_web_document() works as expected"""
        debug.trace(4, "test_download_web_document()")
        assert "currency" in THE_MODULE.download_web_document("https://simple.wikipedia.org/wiki/Dollar")
        assert THE_MODULE.download_web_document("www. bogus. url.html") == None 

    def test_test_download_html_document(self):
        """Ensure test_download_html_document() works as expected"""
        debug.trace(4, "test_test_download_html_document()")
        assert "Google" in THE_MODULE.test_download_html_document("www.google.com") 
        assert "Tomás" not in THE_MODULE.test_download_html_document("http://www.tomasohara.trade", encoding="big5")

    def test_download_html_document(self):
        """Ensure download_html_document() works as expected"""
        debug.trace(4, "test_download_html_document()")
        ## TODO: WORK-IN-PROGRESS

    def test_download_binary_file(self):
        """Ensure download_binary_file() works as expected"""
        debug.trace(4, "test_download_binary_file()")
        ## TODO: WORK-IN-PROGRESS

    def test_retrieve_web_document(self):
        """Ensure retrieve_web_document() works as expected"""
        debug.trace(4, "test_retrieve_web_document()")
        assert re.search("Scrappy.*Cito", THE_MODULE.retrieve_web_document("www.tomasohara.trade")) 

    def test_init_BeautifulSoup(self):
        """Ensure init_BeautifulSoup() works as expected"""
        debug.trace(4, "test_init_BeautifulSoup()")
        THE_MODULE.BeautifulSoup = None
        THE_MODULE.init_BeautifulSoup()
        assert THE_MODULE.BeautifulSoup

    def test_extract_html_link(self):
        """Ensure extract_html_link() works as expected"""
        debug.trace(4, "test_extract_html_link()")

        html = (
            '<!DOCTYPE html>\n'
            '<html>\n'
            '<body>\n'
            '<h2>The target Attribute</h2>\n'
            '<div class="some-class">this is a div</div>\n'
            '<div class="some-class another-class">'
            '<a href="https://www.anothersite.io/" target="_blank">another site</a>\n'
            '<a href="https://www.example.com/" target="_blank">Visit Example!</a>\n'
            '<a href="https://www.example.com/sopport" target="_blank">example sopport</a>\n'
            '</div>'
            '<a href="https://www.subdomain.example.com/" target="_blank">Visit subdomain of Example!</a>\n'
            '<a href="https://www.example.com.br/" target="_blank">visit Example Brazil!</a>\n'
            '<p>If target="_blank", this is a link.</p>\n'
            '<a href="www.subdomain.example.com/sitemap.xml" target="_blank">see the sitemap</a>\n'
            '<a href="/home.html" target="_blank">home page</a>\n'
            '</body>\n'
            '</html>\n'
        )

        # NOTE that the last two urls has a extra '/'.
        ## TODO: check if the extra '/' in the last two urls are correct.
        all_urls = [
            'https://www.anothersite.io/',
            'https://www.example.com/',
            'https://www.example.com/sopport',
            'https://www.subdomain.example.com/',
            'https://www.example.com.br/',
            'http:///www.subdomain.example.com/sitemap.xml',
            'https://www.example.com//home.html',
        ]

        # Test extract all urls from html
        assert THE_MODULE.extract_html_link(html, url='https://www.example.com', base_url='http://') == all_urls

        # Test base_url none
        ## TODO: this assertion is returning, need to be solved: 
        ##      https://www.example.com//www.subdomain.example.com/sitemap.xml
        ## assert THE_MODULE.extract_html_link(html, url='https://www.example.com') == all_urls

#------------------------------------------------------------------------

if __name__ == '__main__':
    debug.trace_current_context()
    pytest.main([__file__])
