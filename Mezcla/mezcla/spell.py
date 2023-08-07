#! /usr/bin/env python
#
# spell.py: simple spell checker (e.g., via Enchant module)
#
# Note:
# - New languages can be added as follows:
#       sudo apt-get install myspell-ID
#   See https://stackoverflow.com/questions/32712557/pyenchant-italian-and-spanish-languages.
#
# TODO:
# - integrate code for suggestions based on spelling distance
#

"""Basic spell checking"""

# Standard modules
# TODO: sys => system
import sys
import fileinput

# Installed modules
import enchant                  # spell checking

# Local modules
from mezcla import debug
## TODO: from mezcla.main import Main
from mezcla import system
## OLD: from mezcla.my_regex import my_re
from mezcla.text_processing import split_word_tokens


# Environment options
SPELL_LANG = system.getenv_text("SPELL_LANG", "en_US",
                                "Language for spelling")

# Constants
TL = debug.TL

## TEMP:
# pylint: disable=consider-using-f-string

def main():
    """Entry point for script"""
    # Process command line
    # TODO: upgrade to using Main script (see template.py)
    i = 1
    show_usage = (i == len(sys.argv))
    while (i < len(sys.argv)) and (sys.argv[i][0] == "-"):
        if (sys.argv[i] == "--help"):
            show_usage = True
        elif (sys.argv[i] == "-"):
            pass
        else:
            print("Error: unexpected argument '%s'" % sys.argv[i])
            show_usage = True
        i += 1
    if (show_usage):
        print("Usage: %s [options] input-file" % sys.argv[0])
        print("")
        print("Options: [--help]")
        print("")
        print("Examples:")
        print("")
        print("  %s query-keywords.list" % sys.argv[0])
        print("")
        print("  echo 'how now browne cow?' | {prog} -".format(prog=sys.argv[0]))
        print("")
        sys.exit()
    # Discard any used arguments (for sake of fileinput)
    if (i > 1):
        debug.trace(5, f"discarding used args: {sys.argv[1: i]}")
        sys.argv = [sys.argv[0]] + sys.argv[i:]
    
    # Initialize spell checking
    speller = enchant.Dict(SPELL_LANG)
    
    # Check input
    for line in fileinput.input():
        line = line.strip()
        debug.trace_fmt(5, "L{line_num}: {line_text}", line_num=fileinput.filelineno(), line_text=line)
    
        # Extract word tokens and print those not recognized
        ## BAD:
        ## word_tokens = [t.strip() for t in my_re.split(r"\W+", line.lower(), my_re.LOCALE|my_re.UNICODE)
        ##                if (len(t.strip()) > 0)]
        word_tokens = split_word_tokens(line.lower())
        debug.trace(4, f"tokens: {word_tokens}")
        for w in word_tokens:
            if not speller.check(w):
                print(w)

#-------------------------------------------------------------------------------
    
if __name__ == '__main__':
    debug.trace_current_context(level=TL.QUITE_DETAILED)
    debug.trace_fmt(TL.USUAL, "Environment options: {eo}",
                    eo=system.formatted_environment_option_descriptions())
    main()
