#! /usr/bin/env python
#
# This script groups several tools to deal with numerical systems and more.
# This can be used as command-line tool or as module.
#
## TODO:
## - review PRECISION on calls to system.round_num(args), if should be passed as param or env. var.
#
## Tom: here are some comments
## - These are low priority so just review them briefly to keeo in mind for future scripts.
##   Right now the priority is getting the alias test suite in place.
##
## Tom: Useful to show examples from revised tomohara-aliases.bash (e.g., in header comments)
##
## function hex2dec { numeric_tools.py --hex2dec $1; }
## function dec2hex { numeric_tools.py --dec2hex $1; }
## function bin2dec { numeric_tools.py --bin2dec $1; }
## function dec2bin { numeric_tools.py --dec2bin $1; }
## function comma-ize-number () { python numeric_tools.py --comma-ize; }
## function apply-numeric-suffixes () { numeric_tools.py --suffix; }
## function apply-usage-numeric-suffixes () { numeric_tools.py --usage-suffix; }
##
## done
## Tom: The following is failing
##   $ echo 1234 987654321 | comma-ize-number
##   1,234 987,654,321
##   current output:
##     1,234 987654,321
##
## Tom: add function tracing throughout
##    ex: debug.trace(5, f"hex2dec({number})")
## This helps when determining flow of control.
##


"""
This script groups several tools to deal with numerical systems and more.

ex:
\t$ python numeric_tools.py --dec2bin 20
\t10100
"""
## (OLD, --i is no more used); Tom (missing --i above): --dec2bin --i 20


# Standard packages
import re
import sys


# Local packages
from mezcla.main import Main
from mezcla import debug
from mezcla import system


# Command-line labels constants
## Tom: good to have --input w/ --i as alias (i.e., general only use one letter
## switches as abbreviations). Note that GNU's convention uses dashes for long
## names and -'s for single letter ones), so --i is a little confusing.
INPUT = 'input'
HEX2DEC = 'hex2dec'
DEC2HEX = 'dec2hex'
BIN2DEC = 'bin2dec'
DEC2BIN = 'dec2bin'
SUFFIX = 'suffix' # convert number to use K/M/G suffixes
SUFFIX_FIRST_ONLY = 'suffix-first'
USAGE_SUFFIX = 'usage-suffix' # factor 1k the first number and then apply suffix
COMMA = 'comma-ize'


class NumericSystem(Main):
    """Argument processing class"""
    ## Tom: misleading comment as really just argument processing
    ## suggestion: """Argument processing class""

    ## class-level member variables for arguments (avoids need for class constructor)
    ## Tom: reserve '##' for temporary comments. I used this in template.py for TODO notes.
    input_string = ''
    hex2dec = False
    dec2hex = False
    bin2dec = False
    dec2bin = False
    suffixes = False
    suffixes_first_only = False
    usage_suffix = False
    comma = False

    def setup(self):
        """Process arguments"""
        debug.trace(5, f"Script.process_line(): self={self}")

        # Process command-line options
        self.input_string = self.get_parsed_argument(INPUT, self.input_string)
        self.hex2dec = self.has_parsed_option(HEX2DEC)
        self.dec2hex = self.has_parsed_option(DEC2HEX)
        self.bin2dec = self.has_parsed_option(BIN2DEC)
        self.dec2bin = self.has_parsed_option(DEC2BIN)
        self.suffixes = self.has_parsed_option(SUFFIX)
        self.suffixes_first_only = self.has_parsed_option(SUFFIX_FIRST_ONLY)
        self.usage_suffix = self.has_parsed_option(USAGE_SUFFIX)
        self.comma = self.has_parsed_option(COMMA)

        ## Tom: good to ensure just one of above used
        ##    debug.assertion((0 < sum([self.hex2dec, ..., self.comma]) <= 1), "Options are mutually exclusive")}
        option_list = [
            self.hex2dec,
            self.dec2hex,
            self.bin2dec,
            self.dec2bin,
            self.suffixes,
            self.suffixes_first_only,
            self.usage_suffix,
            self.comma
        ]
        option_sum = sum(bool(x) for x in option_list)
        debug.assertion(0 < option_sum <= 1, "Options are mutually exclusive")

        ## Tom: trace instance after args parsed
        debug.trace_object(5, self, label="Script instance")

    def run_main_step(self):
        """Process input stream"""
        debug.trace(5, f"Script.run_main_step(): self={self}")

        # Read stdin if not positional input provided
        if not self.input_string:
            ## Tom: use all of stdin (not just first line)
            ## Also, add a function for tracing input as TL.VERBOSE (e.g., system.read_all_stdin)
            self.input_string = system.read_all_stdin().strip()

        debug.assertion(self.input_string, "No value/s entered")

        ## TODO: sanitization of self.input_string.
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
        ## Tom: always good to report unexpected conditions
        else:
            raise NotImplementedError()

        print(result)


def hex2dec(number):
    """Convert hexadecimal to decimal"""
    result = int(str(number), 16)
    debug.trace(5, f"hex2dec({number}) => {result}")
    return result


def dec2hex(number):
    """Convert decimal to hexadecimal"""
    result = hex(int(number)).split('x')[-1]
    debug.trace(5, f"dec2hex({number}) => {result}")
    return result


def bin2dec(number):
    """Convert binary to decimal"""
    result = int(str(number), 2)
    debug.trace(5, f"bin2dec({number}) => {result}")
    return result


def dec2bin(number):
    """Convert decimal to binary"""
    result = int(bin(int(number)).replace('0b', ''))
    debug.trace(5, f"dec2bin({number}) => {result}")
    return result


def comma_ize_number(text):
    """Add commas to numbers in text"""
    ## done
    ## Tom: probabily need a loop
    ##   perl -pe 'while (/\d\d\d\d/) { s/(\d)(\d\d\d)([^\d])/\1,\2\3/g; } ';

    # Ensure that the input is a string
    result = str(text)

    while re.search(r'\d\d\d\d', result):
        result = re.sub(r'(\d)(\d\d\d)([^\d]|$)', r'\1,\2\3', result)

    debug.trace(5, f"comma_ize_number({text}) => {result}")
    return result


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

    result = system.round_num(size, precision), power_labels[n_power]

    debug.trace(5, f"format_bytes(size={size}, precision={precision}) => {result}")
    return result


# apply suffixes: converts numbers to use K/M/G suffixes.
# Notes:
# - K, M, G and T based on powers of 1024.
# - If first_only true, then the substitution is only applied one-time per line.
# - The number must be preceded by a word boundary and followed by whitespace.
# This was added in support of the usage function (e.g., numeric subdirectory names).
# EX: apply_suffixes("1024, 1572864, 1073741824")                  => "1K 1.5M 1G"
# EX: apply_suffixes("1024, 1572864, 1073741824", first_only=True) => "1K 1572864 1073741824"
def apply_suffixes(numeric_text, first_only=False, precision=1):
    """Apply K/M/G/T suffixes to NUMBERS, optionally just FIRST_ONLY and using PRECISION"""

    # Process entered string
    ## Tom: use numbers.split(); also rename to something like numeric_text as it would seem to be a list
    size_list = numeric_text.split()

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

    result = result.rstrip()

    debug.trace(5, f"apply_suffixes(numeric_text={numeric_text}, first_only={first_only}, precision={precision}) => {result}")
    return result


# apply_usage_suffixes(): factors in 1k blocksize before applying numeric suffixes
def apply_usage_suffixes(numeric_text, precision=1):
    """Factor 1K blocksize and apply suffixes"""

    numbers_list = numeric_text.split(' ')
    factored_numbers = str(int(numbers_list[0]) * 1024)
    for number in numbers_list[1:]:
        factored_numbers += ' ' + number

    result = apply_suffixes(factored_numbers, first_only=True, precision=precision)

    debug.trace(5, f'apply_usage_suffixes(numeric_text={numeric_text}, precision={precision}) => {result}')
    return result


if __name__ == '__main__':
    app = NumericSystem(
        description = __doc__,
        boolean_options = [
            (HEX2DEC, 'convert hexadecimal to decimal'),
            (DEC2HEX, 'convert decimal to hexadecimal'),
            (BIN2DEC, 'convert binary to decimal'),
            (DEC2BIN, 'convert decimal to binary'),
            (SUFFIX, 'convert number to use K/M/G suffixes'),
            (SUFFIX_FIRST_ONLY, 'suffix only the first number'),
            (USAGE_SUFFIX, 'factor 1k the first number and then apply suffix'),
            (COMMA, 'add commas to numbers'),
        ],
        positional_options = [
            (INPUT, 'input'),
        ] if len(sys.argv) >= 3 else None,
        skip_input = True)
    app.run()
