#! /usr/bin/env python
#
# This script groups several tools to deal with numerical systems and more.
# This can be used as command-line tool or as module.
#
# TODO: sanitization of functions input.


"""
This script groups several tools to deal with numerical systems and more.

ex:
\t$ python numeric_tools.py --dec2bin 20
"""


# Standard packages
import re
import sys


# Local packages
from mezcla.main import Main
from mezcla      import system


# Command-line labels constants
INPUT_SHORT       = 'i'
HEX2DEC           = 'hex2dec'
DEC2HEX           = 'dec2hex'
BIN2DEC           = 'bin2dec'
DEC2BIN           = 'dec2bin'
SUFFIX            = 'suffix'       # convert number to use K/M/G suffixes
SUFFIX_FIRST_ONLY = 'suffix-first'
USAGE_SUFFIX      = 'usage-suffix' # factor 1k the first number and then apply suffix
COMMA             = 'comma-ize'


class NumericSystem(Main):
    """This script groups several tools to deal with numerical systems and more"""


    ## class-level member variables for arguments (avoids need for class constructor)
    input_string        = ''
    hex2dec             = False
    dec2hex             = False
    bin2dec             = False
    dec2bin             = False
    suffixes            = False
    suffixes_first_only = False
    usage_suffix        = False
    comma               = False


    def setup(self):
        """Process arguments"""

        # Process command-line options
        self.input_string        = self.get_parsed_argument(INPUT_SHORT, "")
        self.hex2dec             = self.has_parsed_option(HEX2DEC)
        self.dec2hex             = self.has_parsed_option(DEC2HEX)
        self.bin2dec             = self.has_parsed_option(BIN2DEC)
        self.dec2bin             = self.has_parsed_option(DEC2BIN)
        self.suffixes            = self.has_parsed_option(SUFFIX)
        self.suffixes_first_only = self.has_parsed_option(SUFFIX_FIRST_ONLY)
        self.usage_suffix        = self.has_parsed_option(USAGE_SUFFIX)
        self.comma               = self.has_parsed_option(COMMA)


    def run_main_step(self):
        """Process input stream"""

        # Read stdin if not positional input provided
        if not self.input_string and not sys.stdin.isatty():
            self.input_string = self.input_stream.readlines()[0]


        if self.hex2dec:
            result = hex2dec(self.input_string)
        elif self.dec2hex:
            result = dec2hex(self.input_string)
        elif self.bin2dec:
            result = bin2dec(self.input_string)
        elif self.dec2bin:
            result = dec2bin(self.input_string)
        elif self.suffixes:
            result = apply_suffixes(self.input_string)
        elif self.suffixes_first_only:
            result = apply_suffixes(self.input_string, first_only=True)
        elif self.usage_suffix:
            result = apply_usage_suffixes(self.input_string)
        elif self.comma:
            result = comma_ize_number(self.input_string)


        print(result)


def hex2dec(number):
    """Convert hexadecimal to decimal"""
    return int(str(number), 16)


def dec2hex(number):
    """Convert decimal to hexadecimal"""
    return hex(int(number)).split('x')[-1]


def bin2dec(number):
    """Convert binary to decimal"""
    return int(str(number), 2)


def dec2bin(number):
    """Convert decimal to binary"""
    return int(bin(int(number)).replace('0b', ''))


def comma_ize_number(number):
    """Add commas to number"""
    return re.sub(r'(\d)(\d\d\d)([^\d])', r'\1,\2\3', str(number))


# NOTE: this not has command-line option
def format_bytes(size, precision=1):
    """format number into kilobytes, megabytes, gigabytes or terabytes"""

    # Apply format to bytes
    power = 1024
    n_power = 0
    power_labels = {0 : '', 1: 'K', 2: 'M', 3: 'G', 4: 'T'}
    while size >= power:
        size /= power
        n_power += 1

    return  system.round_num(size, precision), power_labels[n_power]


# apply suffixes: converts numbers to use K/M/G suffixes.
# Notes:
# - K, M, G and T based on powers of 1024.
# - If first_only true, then the substitution is only applied one-time per line.
# - The number must be preceded by a word boundary and followed by whitespace.
# This was added in support of the usage function (e.g., numeric subdirectory names).
# EX: apply_suffixes("1024, 1572864, 1073741824")                  => "1K 1.5M 1G"
# EX: apply_suffixes("1024, 1572864, 1073741824", first_only=True) => "1K 1572864 1073741824"
def apply_suffixes(numbers, first_only=False, precision=1):
    """Convert number to use K/M/G suffixes"""

    # Process entered string
    size_list = numbers.split(' ')

    # Calculate power labels and append results
    result = ''
    for size in size_list:
        size_formated = format_bytes(int(size), precision=precision)
        result += str(size_formated[0]) + str(size_formated[1]) + ' '
        if first_only:
            break

    # Append last numbers if first_only
    if first_only:
        for size in size_list[1:]:
            result += str(size) + ' '

    return result.rstrip()


# apply_usage_suffixes(): factors in 1k blocksize before applying numeric suffixes
def apply_usage_suffixes(numbers, precision=1):
    """Factor 1K blocksize and apply suffixes"""

    numbers          = numbers.split(' ')
    factored_numbers = str(int(numbers[0]) * 1024)
    for number in numbers[1:]:
        factored_numbers += ' ' + number

    return apply_suffixes(factored_numbers, first_only=True, precision=precision)


if __name__ == '__main__':
    app = NumericSystem(description          = __doc__,
                        boolean_options      = [(HEX2DEC,           'convert hexadecimal to decimal'),
                                                (DEC2HEX,           'convert decimal to hexadecimal'),
                                                (BIN2DEC,           'convert binary to decimal'),
                                                (DEC2BIN,           'convert decimal to binary'),
                                                (SUFFIX,            'convert number to use K/M/G suffixes'),
                                                (SUFFIX_FIRST_ONLY, 'suffix only the first number'),
                                                (USAGE_SUFFIX,      'factor 1k the first number and then apply suffix'),
                                                (COMMA,             'add commas to numbers')],
                        text_options         = [(INPUT_SHORT,       'input')],
                        manual_input         = True)
    app.run()
