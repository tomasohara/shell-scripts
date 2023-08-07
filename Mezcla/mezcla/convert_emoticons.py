#! /usr/bin/env python
# -*- coding: utf-8 -*-
#
# Convert emoticons into names (or just strips them)
#
# Example Input:
#   Nothing to do 😴
#
# Example output:
#   Nothing to do [sleeping face]
#

"""
Replace emoticons with name (or remove entirely)

Sample usage:

   echo 'github-\U0001F634_Transformers' | {script} -
"""                          # 🤗 (HuggingFace logo)

# Standard modules
import unicodedata

# Intalled module
# TODO: import numpy as np

# Local modules
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.main import Main
## TODO: from mezcla.my_regex import my_re
from mezcla import system
## TODO2: streamline imports by exposing common functions, etc. in mezcla

# Constants
TL = debug.TL
STRIP_OPT = "strip"

## TODO:
## # Environment options
## # Notes:
## # - These are just intended for internal options, not for end users.
## # - They also allow for enabling options in one place rather than four
## #   when using main.Main (e.g., [Main member] initialization, run-time
## #   value, and argument spec., along with string constant definition).
## #
## ENABLE_FUBAR = system.getenv_bool("ENABLE_FUBAR", False,
##                                   description="Enable fouled up beyond all recognition processing")

#-------------------------------------------------------------------------------

OTHER_SYMBOL = 'So'
#
def convert_emoticons(text, replace=None, strip=None):
    """Either REPLACE emotions with Unicode name or STRIP them entirely"""
    # EX: convert_emoticons("✅  Success") => "[checkmark] Success"
    # EX: convert_emoticons("¿Hablas español?") => "¿Hablas español?" # Spanish for "Do you speak Spanish"
    # EX: convert_emoticons("天気") => "天気"   # Japanese for weather
    debug.trace(6, f"convert_emoticons(_, [r={replace}], [s={strip}])")
    debug.assertion(not (replace and strip))
    if replace is None:
        replace = not strip
    in_text = text
    chars = []
    for ch in text:
        if unicodedata.category(ch) == OTHER_SYMBOL:
            ch = f"[{unicodedata.name(ch).lower()}]" if replace else ""
        chars.append(ch)
    text = "".join(chars)
    level = (4 if (text != in_text) else 6)
    debug.trace(level, f"convert_emoticons({in_text}) => {text}")
    return text


def main():
    """Entry point"""
    debug.trace(TL.USUAL, f"main(): script={system.real_path(__file__)}")

    # Parse command line options, show usage if --help given
    # TODO: manual_input=True; short_options=True
    main_app = Main(description=__doc__.format(script=gh.basename(__file__)),
                    boolean_options=[(STRIP_OPT, "Strip emoticon entirely, instead of replacing with name")],
                    skip_input=False)
    debug.assertion(main_app.parsed_args)
    strip_entirely = main_app.get_parsed_option(STRIP_OPT)

    for line in main_app.read_entire_input().splitlines():
        print(convert_emoticons(line, strip=strip_entirely))
    return

#-------------------------------------------------------------------------------

if __name__ == '__main__':
    debug.trace_current_context(level=TL.QUITE_VERBOSE)
    main()
