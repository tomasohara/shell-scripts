# note: empty file checked in

"""Tests for analyze_cobertura module"""

# Local modules
from mezcla import debug
from mezcla.unittest_wrapper import TestWrapper, invoke_tests

import tests.analyze_cobertura as THE_MODULE


class TestIt(TestWrapper):
    """Test case definitions"""
    script_module = TestWrapper.get_testing_module_name(__file__, THE_MODULE)

    def test_01_parse_cobertura(self):
        """Tests parsing coverage totals from a Cobertura report."""
        debug.trace(4, f"TestIt.test_01_parse_cobertura(); self={self}")
        cobertura_xml = """<coverage><packages><package><classes>
            <class filename="tools/example.py"><lines>
                <line number="1" hits="1"/><line number="2" hits="0"/>
            </lines></class>
        </classes></package></packages></coverage>"""
        report_file = self.create_temp_file(cobertura_xml)
        coverage = THE_MODULE.CoverageHelper("").parse_cobertura(report_file)
        self.do_assert(coverage["example.py"]["covered_lines"] == 1,
                       "Expected one covered line")
        self.do_assert(coverage["example.py"]["total_lines"] == 2,
                       "Expected two total lines")
        return


if __name__ == '__main__':
    invoke_tests(__file__)
