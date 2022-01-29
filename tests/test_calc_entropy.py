#! /usr/bin/env python
#
# Tests for calc_entropy.py module


"""Tests for calc_entropy.py module"""


# Standart packages
import unittest
import sys


# Local packages
from mezcla.unittest_wrapper import TestWrapper
from mezcla import glue_helpers as gh


# Module being tested
sys.path.append('..')
import calc_entropy


class TestIt(TestWrapper):
    """Class for testcase definition"""
    script_module = TestWrapper.derive_tested_module_name(__file__) + '.py'


    def test_calculate_weight_percentage(self):
        """Test for calculate_weight_percentage(vector)"""
        input_vector  = [5, 10, 15, 20]
        result_vector = [0.100, 0.200, 0.300, 0.400]
        self.assertEqual(calc_entropy.calculate_weight_percentage(input_vector), result_vector)


    def test_class_filter(self):
        """Test for class filter option"""
        input_string    = 'deportive-car\t3\nsedan-car\t3\nconvertible-car\t2\ntruck\t12'
        expected_result = '1.561'
        self.assertEqual(gh.run(f'echo $"{input_string}" |{self.script_module} --class_filter="car" --last  -'), expected_result)


    def test_max_count(self):
        """Test for max_count option"""
        input_string    = 'deportive-car\t3\nsedan-car\t3\nconvertible-car\t2\ntruck\t12'
        expected_result = '1.561'
        self.assertEqual(gh.run(f'echo $"{input_string}" | {self.script_module} --max_count 3 --last  -'), expected_result)


    def test_verbose(self):
        """Test for verbose option"""
        input_string    =  'deportive-car\t3\nsedan-car\t3\nconvertible-car\t2\ntruck\t12'
        expected_result = ('#\t\tclass\tfreq\tprob\t-p lg(p)\n'
                           '#\t\ttruck\t12\t0.600\t0.442\n'
                           '#\t\tdeportive-car\t3\t0.150\t0.411\n'
                           '#\t\tsedan-car\t3\t0.150\t0.411\n'
                           '#\t\tconvertible-car\t2\t0.100\t0.332\n'
                           '#\t\ttotal\t20\t1.000\t1.595\n\n'
                           '# word\tclasses\tfreq\tentropy\tmax_prob\n'
                           'n/a\t4\t20\t1.595\t0.600')
        self.assertEqual(gh.run(f'echo "{input_string}" | {self.script_module} --verbose --last  -'), expected_result)


    def test_get_data_from_files(self):
        """Testing of getting data from files"""
        filename_1      = '/tmp/entropy_test_1.freq'
        filename_2      = '/tmp/entropy_test_2.freq'
        input_data_1    = '.perl\t239\n.sh\t152\n.bash\t22\n.py\t3\n.lisp\t3\n.txt\t2\n.csh\t1\n'
        input_data_2    = '.perl\t123\n.sh\t22\n.bash\t32\n.py\t9\n'
        expected_result = '1.376\n1.407'
        gh.run(f'touch {filename_1} && echo $"{input_data_1}" > {filename_1}')
        gh.run(f'touch {filename_2} && echo $"{input_data_2}" > {filename_2}')
        self.assertEqual(gh.run(f'{self.script_module} --last {filename_1} {filename_2}'), expected_result)


    def test_word(self):
        """Test for word option"""
        # WORK-IN-PROGRESS


    def test_frequencies_last(self):
        """Test for frequencies last options: last, freq_last"""

        input_string    = '.perl\t239\n.sh\t152\n.bash\t22\n.py\t3\n.lisp\t3\n.txt\t2\n.csh\t1'
        expected_result = '1.376'

        self.assertEqual(gh.run(f'echo "{input_string}" | {self.script_module} --last -'), expected_result)
        self.assertEqual(gh.run(f'echo "{input_string}" | {self.script_module} --freq_last -'), expected_result)


    def test_frequencies_first(self):
        """Test for freq_first param"""
        input_string    = '239\t.perl\n152\t.sh\n22\t.bash\n3\t.py\n3\t.lisp\n2\t.txt\n1\t.csh'
        expected_result = '1.376'

        self.assertEqual(gh.run(f'echo "{input_string}" | {self.script_module} --freq_first -'), expected_result)


    def test_just_freq(self):
        """Test for just_freq option"""
        input_string    = '.perl\t239\n.sh\t152\n.bash\t22\n.py\t3\n.lisp\t3\n.txt\t2\n.csh\t1'
        expected_result = '0.566\n0.360\n0.052\n0.007\n0.007\n0.005\n0.002\n'

        self.assertEqual(gh.run(f'echo "{input_string}" | {self.script_module} --just_freq --last -'), expected_result)


    def test_header(self):
        """Test for header related options: header, show_header and skip_header"""
        input_string        = '.perl\t239\n.sh\t152\n.bash\t22\n.py\t3\n.lisp\t3\n.txt\t2\n.csh\t1'
        header = '# word\tclasses\tfreq\tentropy\tmax_prob'

        gral_command = f'echo "{input_string}" | {self.script_module} --last --verbose'

        self.assertTrue(header in gh.run(f'{gral_command} -'))
        self.assertTrue(header in gh.run(f'{gral_command} --header -'))
        self.assertTrue(header in gh.run(f'{gral_command} --show_header -'))
        self.assertFalse(header in gh.run(f'{gral_command} --skip_header -'))


    def test_simple(self):
        """Test for simple option"""
        self.assertEqual(gh.run(f'python {self.script_module} --simple --probabilities ".25 .25 .25 .25" -'), 'Entropy\n2.000')


    def test_label(self):
        """Test for label option"""
        self.assertEqual(gh.run(f'python {self.script_module} --label "foo" --simple --probabilities ".25 .25 .25 .25" -'), '\tEntropy\nfoo\t2.000')


    def test_classes(self):
        """Test for classes related options: classes and show_classes"""
        expected_result = 'Classes\tEntropy\n4\t2.000'
        gral_command = f'python {self.script_module} --simple --probabilities ".25 .25 .25 .25"'
        self.assertEqual(gh.run(f'{gral_command} --classes -'), expected_result)
        self.assertEqual(gh.run(f'{gral_command} --show_classes -'), expected_result)


    def test_fix(self):
        """Test for fix option"""
        input_string    = '.perl  239\n.sh      152\n.bash 22\n.py   3\n.lisp\t3\n.txt\t2\n.csh\t1'
        expected_result = '1.376'

        self.assertEqual(gh.run(f'echo "{input_string}" | {self.script_module} --last --fix -'), expected_result)


    def test_normalize(self):
        """Test for normalize option"""
        self.assertEqual(gh.run(f'python {self.script_module} --simple --normalize --probabilities "95.5 76.4 114.6 95.5" -'), 'Entropy\n1.985')


    def test_alpha(self):
        """Test for alpha option"""
        input_string = 'perl\t239\nsh\t152\nbash\t22\npy\t3\nlisp\t3\ntxt\t2\ncsh\t1'
        alpha_sorted = ('#\t\tbash\t22\t0.052\t0.222\n'
                        '#\t\tcsh\t1\t0.002\t0.021\n'
                        '#\t\tlisp\t3\t0.007\t0.051\n'
                        '#\t\tperl\t239\t0.566\t0.465\n'
                        '#\t\tpy\t3\t0.007\t0.051\n'
                        '#\t\tsh\t152\t0.360\t0.531\n'
                        '#\t\ttxt\t2\t0.005\t0.037\n')

        result = gh.run(f'echo "{input_string}" | {self.script_module} --last --verbose --alpha -')

        self.assertTrue(alpha_sorted in result)


    def test_preserve(self):
        """Test for preserve option"""
        input_string       = 'perl\t239\nsh\t152\nbash\t22\npy\t3\nlisp\t3\ntxt\t2\ncsh\t1'
        preserved_expected = ('#\t\tperl\t239\t0.566\t0.465\n'
                              '#\t\tsh\t152\t0.360\t0.531\n'
                              '#\t\tbash\t22\t0.052\t0.222\n'
                              '#\t\tpy\t3\t0.007\t0.051\n'
                              '#\t\tlisp\t3\t0.007\t0.051\n'
                              '#\t\ttxt\t2\t0.005\t0.037\n'
                              '#\t\tcsh\t1\t0.002\t0.021\n')

        result = gh.run(f'echo "{input_string}" | {self.script_module} --last --verbose --preserve -')

        self.assertTrue(preserved_expected in result)


    def test_cumulative(self):
        """Test for cumulative option"""
        input_string    = 'perl\t239\nsh\t152\nbash\t22\npy\t3\nlisp\t3\ntxt\t2\ncsh\t1'
        expected_result = ('#\t\tclass\tfreq\tprob\t-p lg(p)\n'
                           '#\t\tbash\t22\t0.052\t0.222\n'
                           '#\t\tcsh\t1\t0.055\t0.021\n'
                           '#\t\tlisp\t3\t0.062\t0.051\n'
                           '#\t\tperl\t239\t0.628\t0.465\n'
                           '#\t\tpy\t3\t0.635\t0.051\n'
                           '#\t\tsh\t152\t0.995\t0.531\n'
                           '#\t\ttxt\t2\t1.000\t0.037\n'
                           '#\t\ttotal\t422\t1.000\t1.376\n'
                           '\n'
                           '# word\tclasses\tfreq\tentropy\tmax_prob\n'
                           'n/a\t7\t422\t1.376\t0.566')

        self.assertEquals(gh.run(f'echo "{input_string}" | {self.script_module} --last --verbose --alpha --cumulative -'), expected_result)


    def test_comments(self):
        """Test for strip_comments and no_comments option"""
        # WORK-IN-PROGRESS


if __name__ == '__main__':
    unittest.main()
