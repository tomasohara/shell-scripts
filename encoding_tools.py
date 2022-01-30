#! /usr/bin/env python
#
# This script groups several tools to deal with encodings.
# This can be used as command-line tool or as module.


"""
This script groups several tools to deal with encodings

ex:
"""


# Standard packages
import re


# Local packages
from mezcla.main import Main
from mezcla      import system


# Command-line labels constants
UNICODE_INFO          = 'show-unicode-info'
UNICODE_CONTROL_CHARS = 'show-control-chars'


class EncodingTools(Main):
    """This script groups several tools to deal with encodings"""


    ## class-level member variables for arguments (avoids need for class constructor)
    unicode_info          = False
    unicode_control_chars = False


    def setup(self):
        """Process arguments"""


        # Check the command-line options
        self.unicode_info          = self.has_parsed_option(UNICODE_INFO)
        self.unicode_control_chars = self.has_parsed_option(UNICODE_CONTROL_CHARS)


    def process_line(self, line):
        """Process each line of the input stream"""

        result = ''

        if self.unicode_info:
            result = get_unicode_info(line)
        elif self.unicode_control_chars:
            result = convert_unicode_control_chars(line)

        print(result)


def get_unicode_info(text):
    """Show unicode info"""

    unicode_info = 'char\tord\toffset\tencoding\n'

    text = system.chomp(text)

    unicode_info += f'{text}: {len(text)}\n'

    for offset, char in enumerate(text):
        ord_char  = (hex(ord(char))).replace('0x', '')
        utf8_char = hex(ord(char.encode('utf-8'))).replace('0x', '') # TODO: check this.
        unicode_info += f'{char}\t{ord_char.zfill(4)}\t{offset}\t{utf8_char}\n'

    return unicode_info


def convert_unicode_control_chars(text):
    """Convert ascii control characters to printable Unicode ones"""
    return re.sub(r'([\x00-\x1F])', chr(int(hex(ord("\1")), 16) + int('0x2400', 16)), text)


if __name__ == '__main__':
    app = EncodingTools(description     = __doc__,
                        boolean_options = [(UNICODE_INFO,          'show unicode info'),
                                           (UNICODE_CONTROL_CHARS, 'convert ascii control characters to printable Unicode ones')])
    app.run()
