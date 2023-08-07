#! /usr/bin/env python
#
# Test(s) for ../pandas_sklearn.py
#
# Notes:
# - For debugging the tested script, the ALLOW_SUBCOMMAND_TRACING environment
#   option shows tracing output normally suppressed by  unittest_wrapper.py.
# - This can be run as follows:
#   $ PYTHONPATH=".:$PYTHONPATH" python ./mezcla/tests/test_pandas_sklearn.py
#

"""Tests for pandas_sklearn module"""

# Standard packages
import re

# Installed packages
import pytest

# Local packages
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.unittest_wrapper import TestWrapper

# Note: Two references are used for the module to be tested:
#    THE_MODULE:	    global module object
import mezcla.pandas_sklearn as THE_MODULE

# Constants
EXAMPLES = f'{gh.dir_path(__file__)}/../examples'
RESOURCES = f'{gh.dir_path(__file__)}/resources'
IRIS_EXAMPLE = f'{EXAMPLES}/iris.csv'
IRIS_OUTPUT = f'{RESOURCES}/iris_output.txt'

class TestPandasSklearnUtils:
    """Class for testcase definition"""

    def test_create_feature_mapping(self):
        """Ensure create_feature_mapping works as expected"""
        debug.trace(4, "test_create_feature_mapping()")
        assert THE_MODULE.create_feature_mapping(['c', 'b', 'b', 'a']) == {'c':0, 'b':1, 'a':2}

    def test_show_ablation(self):
        """Ensure show_ablation works as expected"""
        debug.trace(4, "test_show_ablation()")
        ## TODO: WORK-IN-PROGRESS

    def test_show_precision_recall(self):
        """Ensure show_precision_recall works as expected"""
        debug.trace(4, "test_show_precision_recall()")
        ## TODO: WORK-IN-PROGRESS

    def test_show_average_precision_recall(self):
        """Ensure show_average_precision_recall works as expected"""
        debug.trace(4, "test_show_average_precision_recall()")
        ## TODO: WORK-IN-PROGRESS


class TestPandasSklearn(TestWrapper):
    """Class for testcase definition"""
    script_file = TestWrapper.get_module_file_path(__file__)
    script_module = TestWrapper.get_testing_module_name(__file__)

    def test_main_without_args(self):
        """Ensure main without args works as expected"""
        debug.trace(4, "test_main_without_args()")
        log_file = gh.get_temp_file()
        self.run_script(data_file='', log_file=log_file)
        assert 'Usage:' in gh.read_file(log_file)

    def test_normal_usage(self):
        """Ensure normal usage works as expected"""
        debug.trace(4, "test_normal_usage()")
        output = self.run_script(data_file=IRIS_EXAMPLE)
        assert output

        # Check line per line avoiding flaky numbers that always change
        for expected_line, actual_line in zip(gh.read_lines(IRIS_OUTPUT), output.splitlines()):
            expected_line = re.sub(r' +', ' ', expected_line)
            actual_line = re.sub(r' +', ' ', actual_line)
            if re.search(r'[0-9] +[0-9\.]+ +[0-9\.]+ +[0-9\.]+ +[0-9\.]+ +[a-zA-Z]+-[a-zA-Z]+', expected_line):
                continue
            assert actual_line == expected_line

    def test_verbose(self):
        """Ensure verbose works as expected"""
        debug.trace(4, "test_normal_usage()")
        output = self.run_script(env_options='VERBOSE=true', data_file=IRIS_EXAMPLE)
        assert 'Development test classification report:' in output
        expected_confusion_matrix = (
            'Development test set confusion matrix:\n'
            '[[3 0 0]\n'
            ' [0 5 0]\n'
            ' [0 1 3]]\n'
        )
        assert expected_confusion_matrix in output

    def test_show_ablation(self):
        """Ensure show_ablation works as expected"""
        debug.trace(4, "test_normal_usage()")
        expected_ablation_acc = (
            '[0.5, 0.43333333333333335, 0.5333333333333333,'
            ' 0.5, 0.5, 0.6, 0.6333333333333333, 0.6333333333333333,'
            ' 0.6333333333333333, 0.6333333333333333, 0.6333333333333333,'
            ' 0.6, 0.6, 0.6333333333333333, 0.6333333333333333,'
            ' 0.6333333333333333, 0.8666666666666667, 0.8333333333333334,'
            ' 0.9666666666666667, 0.9666666666666667, 0.9666666666666667,'
            ' 0.9666666666666667, 0.9333333333333333, 0.9333333333333333,'
            ' 0.9333333333333333, 0.9666666666666667, 0.9666666666666667,'
            ' 0.9666666666666667, 0.9333333333333333, 0.9333333333333333,'
            ' 0.9333333333333333, 0.9666666666666667, 0.9333333333333333,'
            ' 0.9333333333333333, 0.9333333333333333, 0.9333333333333333,'
            ' 0.9666666666666667, 0.9666666666666667, 0.9333333333333333,'
            ' 0.9333333333333333, 0.9333333333333333, 0.9333333333333333,'
            ' 0.9333333333333333, 0.9333333333333333, 0.9333333333333333,'
            ' 0.9333333333333333, 0.9333333333333333, 0.9333333333333333,'
            ' 0.9333333333333333, 0.9333333333333333, 0.9333333333333333,'
            ' 0.9333333333333333, 0.9333333333333333, 0.9333333333333333,'
            ' 0.9333333333333333, 0.9333333333333333, 0.9333333333333333,'
            ' 0.9333333333333333, 0.9333333333333333, 0.9333333333333333,'
            ' 0.9333333333333333, 0.9333333333333333, 0.9333333333333333,'
            ' 0.9333333333333333, 0.9333333333333333, 0.9333333333333333,'
            ' 0.9333333333333333, 0.9333333333333333, 0.9333333333333333,'
            ' 0.9333333333333333, 0.9333333333333333, 0.9333333333333333,'
            ' 0.9666666666666667, 0.9666666666666667, 1.0, 1.0, 1.0, 1.0,'
            ' 1.0, 0.9333333333333333, 0.9333333333333333, 0.9333333333333333,'
            ' 0.9333333333333333, 0.9333333333333333, 0.9666666666666667,'
            ' 0.9666666666666667, 0.9666666666666667, 1.0, 1.0, 1.0, 1.0,'
            ' 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,'
            ' 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]'
        )
        output = self.run_script(env_options='SHOW_ABLATION=true', data_file=IRIS_EXAMPLE)
        assert 'ablation accuracy:' in output 
        assert expected_ablation_acc in output

    def test_precision_recall(self):
        """Ensure precision_recall works as expected"""
        output = self.run_script(env_options='PRECISION_RECALL=true', data_file=IRIS_EXAMPLE)
        expected_content = (
            'precision:\n'
            '\t[]\n'
            'recall:\n'
            '\t[]\n'
            'thresholds:\n'
            '\t[]'
        )
        assert expected_content in output

    @pytest.mark.xfail
    def test_micro_average(self):
        """Ensure micro_average works as expected"""
        output = self.run_script(env_options='PRECISION_RECALL=true MICRO_AVERAGE=true', data_file=IRIS_EXAMPLE)
        expected_content = (
            'precision:\n'
            '\t[array([0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0.,\n'
            '       0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 1.])]\n'
            'recall:\n'
            '\t[array([1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1.,\n'
            '       1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 1., 0.])]\n'
            'thresholds:\n'
            '\t[array([7.13244554e-07, 1.87247554e-06, 3.51830227e-06, 4.18437007e-06,\n'
            '       6.44055641e-06, 8.99674077e-06, 1.03440695e-05, 1.33689339e-05,\n'
            '       5.65187581e-05, 8.06494481e-05, 6.66272967e-04, 1.19852249e-03,\n'
            '       1.93827217e-03, 2.30446715e-03, 5.68442555e-03, 6.21033670e-03,\n'
            '       1.15435434e-02, 1.86664414e-02, 2.75429206e-02, 1.36287126e-01,\n'
            '       9.43769992e-01, 9.43998991e-01, 9.50485768e-01, 9.63739944e-01,\n'
            '       9.66857292e-01, 9.71692022e-01, 9.72315717e-01, 9.72823159e-01,\n'
            '       9.73851932e-01, 9.84123197e-01])]\n'
            'average precision:\n'
            '\t[0.0]\n'
            'average recall:\n'
            '\t[1.0]'
        )
        # Replace very small numbers to avoid flaky results
        pattern = r'\d\d\d\d\de-'
        substitute = '00000e-'
        expected_content = re.sub(pattern, substitute, expected_content)
        output = re.sub(pattern, substitute, output)
        assert expected_content in output


if __name__ == '__main__':
    debug.trace_current_context()
    pytest.main([__file__])
