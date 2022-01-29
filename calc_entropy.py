#! /usr/bin/env python
#
# calc_entropy.py: calculates entropy of a class using the output of a
# frequency tabulation program (in particular tpo_count_it.py).
#
# sample input:
#
#    # Frequency of 'between' in Penn Treebank II WSJ annotations
#    24      pp-clr
#    6       pp-dir
#    4       pp-ext
#    35      pp-loc
#    2       pp-nom
#    7       pp-prd
#    42      pp-tmp
#
# sample output:
#
#    # word  classes freq    entropy max_prob
#    between 7       120     2.230   0.350
#
#
# sample usage (simplified input):
#    $ calc_entropy.py -simple .25 .25 .25 .25
#    2.000
#
# TODO:
# - Remove assumptions about word-oriented data.
# - Move just_freq code into separate script (new calc_relative_frequency.perl).
# - Add usgae example using relative frequency usgae:
#      $ calc_entropy.py -verbose -last coca-w1.data > coca-w1.rfreq
#      $ cut -f3,5 > coca-w1.coca-w1.rfreq
#


 # TODO: put notes before examples as with other scripts
"""
calculates entropy of a class using the output of a frequency tabulation program

examples:
calc_entropy.py -d=5 -class_filter=\"pp-bnf pp-dir pp-mnr pp-prp pp-tmp pp=ext pp-loc\" as.freq
calc_entropy.py -verbose -simple .47 .42 .06 .05
calc_entropy.py -freq_last all-fe.freq
ls /etc | count_it.perl '\\w+' | calc_entropy.py -last -verbose -

file=bridge-over-troubled-waters.chords
count_it.py '^(\\S+)\\t' file >| file.freq
calc_entropy.py -no_comments -verbose -last file.freq | cut.perl -f='3,5' - >| file.rfreq\n

\nusage: calc_entropy.py [options]\n
notes:
- The -strip_comments option is an alias for old -no_comments=0.
- Use -verbose for more details.
"""


# Standard packages
import sys
import re
import math


# Local packages
from mezcla.main import Main
from mezcla      import debug
from mezcla      import system
from mezcla      import misc_utils   as mu
from mezcla      import glue_helpers as gh


# Command-line labels constants
PROBABILITIES  = 'probabilities'  # probabilities array
CLASS_FILTER   = 'class_filter'   # only keep class names that contains a specific word
MAX_COUNT      = 'max_count'      # maximum number of cases to process
LABEL          = 'label'          # label for entropy display
WORD           = 'word'           # word over which distribution is made
LAST           = 'last'           # alias for -freq_last
FREQ_LAST      = 'freq_last'      # frequency occurs last in the data
FREQ_FIRST     = 'freq_first'     # frequency occurs first in the data
JUST_FREQ      = 'just_freq'      # just output relative frequency
HEADER         = 'header'         # alias for show_header
SHOW_HEADER    = 'show_header'    # display comment header?
SKIP_HEADER    = 'skip_header'    # should the header be skipped?
CLASSES        = 'classes'        # alias for -show_classes
SHOW_CLASSES   = 'show_classes'   # display class information?
SIMPLE         = 'simple'         # data just contains the probabilities
FIX            = 'fix'            # ensure tab-delimited input
NORMALIZE      = 'normalize'      # normalize the probabilities?
ALPHA          = 'alpha'          # show keys alphabetized
PRESERVE       = 'preserve'       # preserve order of keys
CUMULATIVE     = 'cumulative'     # show cumulative probability
STRIP_COMMENTS = 'strip_comments' # alias for (confusing) --no_comments=0
NO_COMMENTS    = 'no_comments'    # used to bypass comment stripping
VERBOSE        = 'verbose'        # more details


class CalcEntropy(Main):
    """calculates entropy of a class using the output of a frequency tabulation program"""


    # class-level member variables for arguments (avoids need for class constructor)
    probabilities = ''
    class_filter  = ''
    max_count     = 0
    label         = ''
    word          = ''
    freq_first    = False
    just_freq     = False
    skip_header   = False
    show_classes  = False
    simple        = False
    fix           = False
    normalize     = False
    alpha         = False
    preserve      = False
    cumulative    = False
    no_comments   = False
    verbose       = False


    def setup(self):
        """Process arguments"""

        # Check the command-line options
        self.probabilities = self.get_parsed_argument(PROBABILITIES, '')
        self.class_filter  = self.get_parsed_argument(CLASS_FILTER, '').lower()
        self.max_count     = self.get_parsed_option(MAX_COUNT, system.maxint())
        self.label         = self.get_parsed_argument(LABEL, '')
        self.word          = self.get_parsed_argument(WORD, 'n/a')
        last               = self.has_parsed_option(LAST)
        freq_last          = self.has_parsed_option(FREQ_LAST) or last
        self.freq_first    = self.has_parsed_option(FREQ_FIRST) or not freq_last
        self.just_freq     = self.has_parsed_option(JUST_FREQ)
        header             = self.has_parsed_option(HEADER) or not self.just_freq
        show_header        = self.has_parsed_option(SHOW_HEADER) or header
        self.skip_header   = self.has_parsed_option(SKIP_HEADER) or not show_header
        classes            = self.has_parsed_option(CLASSES)
        self.show_classes  = self.has_parsed_option(SHOW_CLASSES) or classes
        self.simple        = self.has_parsed_option(SIMPLE)
        self.fix           = self.has_parsed_option(FIX)
        self.normalize     = self.has_parsed_option(NORMALIZE)
        self.alpha         = self.has_parsed_option(ALPHA)
        self.preserve      = self.has_parsed_option(PRESERVE)
        self.cumulative    = self.has_parsed_option(CUMULATIVE)
        strip_comments     = self.has_parsed_option(STRIP_COMMENTS)
        self.no_comments   = self.has_parsed_option(NO_COMMENTS) or not strip_comments
        self.verbose       = self.has_parsed_option(VERBOSE)


    def run_main_step(self):
        """Process main script"""


        # Check for simplified version of data (i.e., just the probabilities)
        if self.simple:


            data = []


            # See if command-line probabilities should be used
            if self.probabilities:
                data = self.probabilities.split(' ')


            # Otherwise get from standard input
            elif not sys.stdin.isatty():
                data = self.input_stream.readlines()[0].split(' ')


            data = [ float(x) for x in data ]


            if self.normalize:
                data = normalize(data)


            self.simple_calc_entropy(data)


        else:
            # Get and process data from files
            if self.filename and not self.filename == '-':
                for filename in self.parsed_args['filename']:


                    # Read file
                    file_content = gh.read_file(filename)
                    if not file_content:
                        print(f'unable to read {filename}')
                        continue


                    # Get frequencies from entered data
                    frequencies = self.format_frequencies_from_text(file_content)


                    # Check frequencies values are correct
                    if not sum(frequencies.values()):
                        print(f'unexpected distribution for {filename} (all 0)')
                        continue


                    # Sort
                    frequencies = sort_dict(frequencies, by_key=self.alpha, by_value=not self.preserve)


                    # Get word
                    if self.word == 'n/a':
                        self.word = gh.basename(filename, '.freq')


                    self.regular_calc_entropy(frequencies, self.word)


                    self.word = 'n/a'


            # Otherwise get and process data from STDIN
            elif not sys.stdin.isatty():
                data = ''.join(self.input_stream.readlines())

                # Get frequencies
                frequencies = self.format_frequencies_from_text(data)

                # Sort frequencies
                frequencies = sort_dict(frequencies, by_key=self.alpha, by_value=not self.preserve)

                # Process frequencies
                self.regular_calc_entropy(frequencies, self.word)


    def format_frequencies_from_text(self, text):
        """Get frequencies from text"""


        frequencies_extracted = {}


        for i, line in enumerate(text.split('\n')):
            line = system.chomp(line)
            debug.trace(debug.QUITE_DETAILED, f'{line}')


            # Remove comments
            if self.no_comments:
                line = re.sub(r'#.*', '', line)


            # Skip black and empty input
            if re.search(r'^\s*$', line):
                continue


            # Make sure input is tab-delimited
            if self.fix:
                line = re.sub(r'\s+', '\t', line)

            if not re.search('\t', line):
                print(f'unexpected input at line {i} ({line})\nUse --{FIX} if not tab-delimited.')
                continue


            # Get the frequency and class name, skipping items not in the filter
            class_name = frequency = rest = ''

            array_line = line.split('\t')

            if self.freq_first:
                frequency, class_name = array_line
            else:
                class_name, frequency = array_line

            if len(array_line) > 2:
                rest = array_line[2]

            debug.trace(debug.DETAILED, f'class={class_name} frequency={frequency} rest={rest}')


            # See if the item should be ignored
            if not frequency.replace('.', '').replace(',' ,'').isnumeric():
                print(f'unexpected input at line {i} ({line})\nUse --{LAST} if class comes first')
                continue
            frequency = int(frequency)
            if re.search('^total', class_name, flags=re.IGNORECASE) and frequency == sum(frequencies_extracted.values()):
                debug.trace(debug.DETAILED, f"skipping totals class '{class_name}'")
                continue
            if self.class_filter and not (self.class_filter in class_name):
                debug.trace(debug.DETAILED, f"skipping filtered class '{class_name}'")
                continue


            # Tabulate frequency
            frequencies_extracted[class_name] = frequencies_extracted.get(frequency, 0) + frequency


            if i >= self.max_count - 1:
                break


        return frequencies_extracted


    # regular_calc_entropy(data, word): Calculate entropy for the probability distribution.
    # data should be [(class_name, frequency), ...]
    def regular_calc_entropy(self, data, word):
        """Calculate entropy for the probability distribution"""


        result = ''


        # Get total frequency
        total_frequency = sum([frequency for class_name, frequency in data])


        # Check frequencies values
        if total_frequency == 0:
            print('unexpected distribution (all 0)')
            return


        if self.verbose and not self.just_freq:
            result += '#\t\tclass\tfreq\tprob\t-p lg(p)\n'


        entropy     = 0.0
        max_prob    = 0.0
        sum_p       = 0.0
        num_classes = 0


        # TODO: refactor this to avoid duplicated code
        for class_name, frequency in data:
            if not frequency:
                continue

            # Calculations
            prob       = frequency / total_frequency
            sum_p     += prob
            max_prob   = max(prob, max_prob)
            p_lg_p     = -1 * prob * (math.log(prob)/math.log(2)) if prob > 0 else 0
            entropy   += p_lg_p
            prob_value = sum_p if self.cumulative else prob

            # Print
            if self.just_freq:
                if self.verbose:
                    result += 'class\t'
                result += f'{format(prob_value, ".3f")}\n'
            elif self.verbose:
                result += (f'#\t\t{class_name}\t'
                           f'{frequency}\t'
                           f'{format(prob_value, ".3f")}\t'
                           f'{format(p_lg_p, ".3f")}\n')

            num_classes += 1


        if self.just_freq:
            # do nothing
            pass
        elif self.verbose:
            result += (f'#\t\ttotal\t{total_frequency}\t'
                       f'1.000\t'
                       f'{format(entropy, ".3f")}\n\n')
            if not self.skip_header:
                result += f'# word\tclasses\tfreq\tentropy\tmax_prob\n'
            result += (f'{word}\t'
                       f'{num_classes}\t'
                       f'{total_frequency}\t'
                       f'{format(entropy, ".3f")}\t'
                       f'{format(max_prob, ".3f")}')
        else:
            result += str(format(entropy, ".3f"))


        print(result)


    # simple_calc_entropy(data): Calculate entropy for the probability distribution
    def simple_calc_entropy(self, data):
        """Calculate entropy for the probability distribution"""
        debug.trace(debug.VERBOSE, f'simple_calc_entropy({data})')


        result = ''


        entropy  = 0.0
        max_prob = 0.0
        if (self.verbose and not self.just_freq):
            result += '#\tprob\t-p lg(p)    max p\n'
            result += '' # TODO: implement equivalent to: printf "#%s\n", "-" x 32;
        num_classes = len(data)
        sum_p       = 0.0


        # TODO: refactor this to avoid duplicated code
        for prob in data:

            # calculations
            sum_p     += prob
            max_prob   = max(prob, max_prob)
            p_lg_p     = -1 * prob * (math.log(prob)/math.log(2)) if prob > 0 else 0
            entropy   += p_lg_p
            prob_value = sum_p if self.cumulative else prob

            # Print
            if self.verbose and not self.just_freq:
                result += (f'#\t{format(prob_value, ".3f")}\t'
                           f'{format(p_lg_p, ".3f")}\n')
            if self.just_freq:
                result += str(format(prob_value, ".3f")) + '\n'


        if self.verbose and not self.just_freq:
            result += '-' * 32
            if not self.skip_header:
                result += '# word\tclasses\tfreq\tentropy\tmax_prob\n'
            result += (f'#\t{format(sum_p, ".3f")}\t'
                       f'{format(entropy, ".3f")}\t   '
                       f'{format(max_prob, ".3f")}\n')
        debug.trace(debug.VERBOSE, f'simple_calc_entropy({data}) => {entropy}')


        if not self.skip_header:
            if self.label:
                result += '\t'
            if self.show_classes:
                result += 'Classes\t'
            result += 'Entropy\n'


        if not self.just_freq:
            if self.label:
                result += self.label + '\t'
            if self.show_classes:
                result += str(num_classes) + '\t'
            result += str(format(entropy, ".3f"))


        print(result)


# normalize
#
# this is an adaptation of normalize.perl
# https://github.com/tomasohara/shell-scripts/blob/main/normalize.perl
#
def normalize(values):
    """
    Normalize values
    ex: input  -> [5, 10, 15, 20]
        output -> [0.100, 0.200, 0.300, 0.400]
    """

    total_sum = 0
    for item in values:
        total_sum += item

    normalized_values = []
    for item in values:
        normalized_values.append(item/total_sum)

    return normalized_values


def sort_dict(dictionary, by_key=False, by_value=False):
    """Sort dictionary, always returns array"""

    result = []

    if by_key:
        result = sorted(dictionary.items())
    elif by_value:
        result = mu.sort_weighted_hash(dictionary)
    else:
        result = dictionary.items()

    return result


if __name__ == '__main__':
    app = CalcEntropy(description     = __doc__,
                      boolean_options = [(LAST,           f'alias for --{FREQ_LAST}'),
                                         (FREQ_LAST,       'frequency occurs last in the data'),
                                         (FREQ_FIRST,      'frequency occurs first in the data'),
                                         (JUST_FREQ,       'just output relative frequency'),
                                         (HEADER,          'alias for show_header'),
                                         (SHOW_HEADER,     'display comment header?'),
                                         (SKIP_HEADER,     'should the header be skipped?'),
                                         (CLASSES,        f'alias for --{SHOW_CLASSES}'),
                                         (SHOW_CLASSES,    'display class information?'),
                                         (SIMPLE,          'data just contains the probabilities'),
                                         (FIX,             'ensure tab-delimited input'),
                                         (NORMALIZE,       'normalize the probabilities?'),
                                         (ALPHA,           'show keys alphabetized'),
                                         (PRESERVE,        'preserve order of keys'),
                                         (CUMULATIVE,      'show cumulative probability'),
                                         (STRIP_COMMENTS, f'alias for (confusing) --{NO_COMMENTS}=False'),
                                         (NO_COMMENTS,     'used to bypass comment stripping'),
                                         (VERBOSE,         'show more details')],
                      int_options     = [(MAX_COUNT,       'maximum number of cases to process')],
                      text_options    = [(PROBABILITIES,  f'probabilities for --{SIMPLE} option, must be an array'),
                                         (CLASS_FILTER,    'only keep class names that contains a specific word'),
                                         (LABEL,           'label for entropy display'),
                                         (WORD,            'word over which distribution is made')],
                      multiple_files  =  True,
                      manual_input    =  True,
                      skip_input      =  False)
    app.run()
