#! /usr/bin/env python
#
# Tests for calc_entropy.py module


"""Tests for calc_entropy.py module"""


# Standart packages
import unittest


# Local packages
from mezcla.unittest_wrapper import TestWrapper
from mezcla import glue_helpers as gh


# On test package
import calc_entropy as ca


## TODO: use gh.resolve_path(SCRIPT) instead of relative path on string
SCRIPT = './../calc_entropy.py'


class TestIt(TestWrapper):
    """Class for testcase definition"""


    def test_calculate_weight_percentage(self):
        """Test for calculate_weight_percentage(vector)"""
        input_vector  = [5, 10, 15, 20]
        result_vector = [0.100, 0.200, 0.300, 0.400]
        self.assertEqual(ca.calculate_weight_percentage(input_vector), result_vector)


    def test_get_data_from_files(self):
        """Testing of getting data from files"""
        # WORK-IN-PROGRESS


    def test_class_filter(self):
        """Test for class filter option"""
        input_string    = 'deportive-car\t3\nsedan-car\t3\nconvertible-car\t2\ntruck\t12'
        expected_result = '1.561'
        self.assertEqual(gh.run(f'echo -e "{input_string}" | calc_entropy.py --class_filter="car" --last  -'), expected_result)


    def test_max_count(self):
        """Test for max_count option"""
        input_string    = 'deportive-car\t3\nsedan-car\t3\nconvertible-car\t2\ntruck\t12'
        expected_result = '1.561'
        self.assertEqual(gh.run(f'echo -e "{input_string}" | calc_entropy.py --max_count 3 --last  -'), expected_result)


    def test_verbose(self):
        """Test for verbose option"""
        input_string    =  'deportive-car\t3\nsedan-car\t3\nconvertible-car\t2\ntruck\t12'
        expected_result = ('#\t\tclass\tfreq\tprob\t-p lg(p)\n'
                           '#\t\tdeportive-car\t3\t0.150\t0.411\n'
                           '#\t\tsedan-car\t3\t0.150\t0.411\n'
                           '#\t\tconvertible-car\t2\t0.100\t0.332\n'
                           '#\t\ttruck\t12\t0.600\t0.442\n'
                           '#\t\ttotal\t20\t1.000\t1.595\n\n'
                           '# word\tclasses\tfreq\tentropy\tmax_prob\n'
                           'n/a\t4\t20\t1.595\t0.600')
        self.assertEqual(gh.run(f'echo "{input_string}" | calc_entropy.py --verbose --last  -'), expected_result)


    def test_word(self):
        """Test fo word option"""
        # WORK-IN-PROGRESS


    def test_frequencies_last(self):
        """Test for frequencies last options: last, freq_last"""

        input_string    = '.perl\t239\n.sh\t152\n.bash\t22\n.py\t3\n.lisp\t3\n.txt\t2\n.csh\t1'
        expected_result = '1.376'

        self.assertEqual(gh.run(f'echo -e "{input_string}" | calc_entropy.py --last -'), expected_result)
        self.assertEqual(gh.run(f'echo -e "{input_string}" | calc_entropy.py --freq_last -'), expected_result)


    def test_frequencies_first(self):
        """Test for freq_first param"""
        # WORK-IN-PROGRESS


    def test_just_freq(self):
        """Test for just_freq option"""
        # WORK-IN-PROGRESS


    def test_header(self):
        """Test for header related options: header, show_header and skip_header"""
        # WORK-IN-PROGRESS


    def test_classes(self):
        """Test for classes related options: classes and show_classes"""
        # WORK-IN-PROGRESS


    def test_simple(self):
        """Test for simple option"""
        self.assertEqual(gh.run(f'python {SCRIPT} --simple --probabilities ".25 .25 .25 .25" -'), 'Entropy\n2.000')


    def test_label(self):
        """Test for label option"""
        self.assertEqual(gh.run(f'python {SCRIPT} --label "foo" --simple --probabilities ".25 .25 .25 .25" -'), '\tEntropy\nfoo\t2.000')


    def test_fix(self):
        """Test for fix option"""
        # WORK-IN-PROGRESS


    def test_normalize(self):
        """Test for normalize option"""
        # WORK-IN-PROGRESS


    def test_alpha(self):
        """Test for alpha option"""
        # WORK-IN-PROGRESS


    def test_preserve(self):
        """Test for preserve option"""
        # WORK-IN-PROGRESS


    def test_cumulative(self):
        """Test for cumulative option"""
        # WORK-IN-PROGRESS


    def test_comments(self):
        """Test for strip_comments and no_comments option"""
        # WORK-IN-PROGRESS


if __name__ == '__main__':
    unittest.main()
