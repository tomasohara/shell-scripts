#! /usr/bin/env python
# -*- coding: utf-8 -*-
#
# Test(s) for ../convert_emoticons.py
#

"""Tests for convert_emoticons module"""

# Standard packages
## TODO: from collections import defaultdict

# Installed packages
import pytest

# Local packages
from mezcla.unittest_wrapper import TestWrapper
from mezcla import debug
from mezcla.my_regex import my_re
from mezcla import system

# Note: Two references are used for the module to be tested:
#    THE_MODULE:                  global module object
#    TestTemplate.script_module:  path to file
import mezcla.convert_emoticons as THE_MODULE
#
# Note: sanity test for customization (TODO: remove if desired)
if not my_re.search(__file__, r"\btemplate.py$"):
    debug.assertion("mezcla.template" not in str(THE_MODULE))


D = system.path_separator()

class TestIt(TestWrapper):
    """Class for testcase definition"""
    script_module = TestWrapper.get_testing_module_name(__file__, THE_MODULE)
    script_file = my_re.sub(rf"{D}tests{D}test_", f"{D}", __file__)

    @pytest.mark.xfail
    def test_over_script(self):
        """Makes sure works as expected over script itself"""
        debug.trace(4, f"TestIt.test_over_script(); self={self}")
        output = self.run_script(options="", data_file=self.script_file)
        # the example usage should have input emoticon changed to match output
        assert not my_re.search(r"(\[sleeping face\]).*\1", script_contents)
        assert my_re.search(r"(\[sleeping face\]).*\1", output)

        # Make sure no emoticon byte sequences in UTF-8 sequences for script and output
        # note: uses broader UTF8-based tests than Unicdoe character DB used in script
        loose_emoticon_regex = br"[\xE0-\xFF][\x80-\xFF]{1,3}"
        assert (not my_re.search(loose_emoticon_regex, script_contents.encode()))
        assert (my_re.search(loose_emoticon_regex, output.encode()))
        return

    def test_over_script_sans_comments(self):
        """Makes sure works as expected over script itself"""
        debug.trace(4, f"TestIt.test_over_script_sans_comments(); self={self}")
        D = system.path_separator()

        # Strip comments from script and run conversion over it
        script_contents = system.read_file(__file__)
        script_contents = my_re.sub("#.*\n", "\n", script_contents)
        system.write_file(self.temp_file, script_contents)
        output = self.run_script(options="", data_file=self.temp_file)

        # There should be no extended ascii bytes
        assert not my_re.search(b"[\x80-\xFF]", script_contents.encode())
        assert not my_re.search(b"[\x80-\xFF]", output.encode())
        return

class TestIt2:
    """Another class for testcase definition
    Note: Needed to avoid error with pytest due to inheritance with unittest.TestCase via TestWrapper"""
    
    def test_misc(self):
        """Test direct calls for conversion"""
        debug.trace(4, f"TestIt2.test_whatever(); self={self}")
        convert_emoticons = THE_MODULE.convert_emoticons
        cool_smile = "\U0001F60E"        # 😎
        assert (convert_emoticons(cool_smile) == "[smiling face with sunglasses]")
        assert (convert_emoticons(cool_smile, strip=True) == "")
        chinese_age = "\uF9A8"           # 令 ("age" in Chinese)
        assert (convert_emoticons(chinese_age) == chinese_age)         
        return


#------------------------------------------------------------------------

if __name__ == '__main__':
    debug.trace_current_context()
    pytest.main([__file__])
