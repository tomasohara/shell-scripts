#! /usr/bin/env python
#
# This script groups several tools to deal with encodings.
# This can be used as command-line tool or as module.
#


"""
This script groups several tools to deal with encodings

ex:
  $ echo "Tomás" | encoding_tools.py --show-unicode-info
  char\tord\toffset\tencoding\n
  Tomás: 5\n
  T\t0054\t0\t54\n
  o\t006F\t1\t6f\n
  m\t006D\t2\t6d\n
  á\t00E1\t3\tc3a1\n
  s\t0073\t5\t73\n

  $ echo -e "this is a tab: \t" | encoding_tools.py --show-control-chars
  this is a tab: ␁

"""


# Standard packages
import re


# Local packages
from mezcla.main import Main
from mezcla      import system
from mezcla      import debug


# Command-line labels constants
UNICODE_INFO          = 'show-unicode-info'
UNICODE_CONTROL_CHARS = 'show-control-chars'


class EncodingTools(Main):
    """Argument processing class"""


    ## class-level member variables for arguments (avoids need for class constructor)
    unicode_info          = False
    unicode_control_chars = False


    def setup(self):
        """Process arguments"""
        debug.trace(5, f"Script.setup(): self={self}")

        # Check the command-line options
        self.unicode_info          = self.has_parsed_option(UNICODE_INFO)
        self.unicode_control_chars = self.has_parsed_option(UNICODE_CONTROL_CHARS)


    def process_line(self, line):
        """Process each line of the input stream"""
        debug.trace(5, f"Script.process_line({line}): self={self}")

        result = ''

        if self.unicode_info:
            result = get_unicode_info(line)
        elif self.unicode_control_chars:
            result = convert_unicode_control_chars(line)

        print(result)


def get_unicode_info(text):
    """Show unicode info"""

    new_text = system.chomp(text)

    info  = 'char\tord\toffset\tencoding\n'
    info += f'{new_text}: {len(new_text)}\n'

    offset = 0

    for char in new_text:
        hex_char = hex(ord(char))[2:].upper()
        utf_char = str(char.encode('utf-8')).replace('b', '').replace('\'', '').replace('\\x', '')

        utf_char = utf_char if len(utf_char) > 1 else hex(ord(utf_char))[2:]

        info   += f'{char}\t{hex_char.zfill(4)}\t{offset}\t{utf_char}\n'
        offset += int(len(utf_char) / 2)

    debug.trace(7, f'get_unicode_info({text}) => {info}')
    return info


def convert_unicode_control_chars(text):
    """Convert ascii control characters to printable Unicode ones"""
    result = re.sub(r'([\x00-\x1F])', chr(int(hex(ord("\1")), 16) + int('0x2400', 16)), text)
    debug.trace(7, f'convert_unicode_control_chars({text}) => {result}')
    return result


if __name__ == '__main__':
    app = EncodingTools(description     = __doc__,
                        boolean_options = [(UNICODE_INFO,          'show unicode info'),
                                           (UNICODE_CONTROL_CHARS, 'convert ascii control characters to printable Unicode ones')])
    app.run()
