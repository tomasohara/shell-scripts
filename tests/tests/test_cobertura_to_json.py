#! /usr/bin/env python3

"""Tests for cobertura_to_json module"""

# Local modules
from mezcla import debug
from mezcla.unittest_wrapper import TestWrapper, invoke_tests

import tests.cobertura_to_json as THE_MODULE


class TestIt(TestWrapper):
    """Test case definitions"""
    script_module = TestWrapper.get_testing_module_name(__file__, THE_MODULE)

    def test_01_find_uncovered_method(self):
        """Tests identification of methods without line coverage."""
        debug.trace(4, f"TestIt.test_01_find_uncovered_method(); self={self}")
        cobertura_xml = """<coverage><packages><package><classes>
            <class name="Example"><methods>
                <method name="covered" signature="()" line-rate="1.0"/>
                <method name="uncovered" signature="(x)" line-rate="0.0"/>
            </methods></class>
        </classes></package></packages></coverage>"""
        root = THE_MODULE.ET.fromstring(cobertura_xml)
        uncovered = THE_MODULE.CoverageHelper("")._find_uncovered_methods(root)
        self.do_assert(uncovered == [{"class": "Example", "method": "uncovered",
                                      "signature": "(x)"}],
                       "Unexpected uncovered-method analysis")
        return


if __name__ == '__main__':
    invoke_tests(__file__)
