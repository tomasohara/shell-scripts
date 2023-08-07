#! /usr/bin/env python
# Example for using the KenLM language modeling utility (based on sample):
#     http://kheafield.com/code/kenlm
# This assumes the language model has already been created via lmplz
#
#--------------------------------------------------------------------------------
# Note: Build steps for C-based utility (based on https://github.com/kpu/kenlm)
# - Requirements:
#   sudo apt install build-essential cmake libboost-system-dev libboost-thread-dev libboost-program-options-dev libboost-test-dev libeigen3-dev zlib1g-dev libbz2-dev liblzma-dev
# - Main code:
#   mkdir -p build
#   cd build
#   cmake ..
#   make -j 4
#   sudo make install
# - Python code:
#   pip install https://github.com/kpu/kenlm/archive/master.zip
# - For more info, see following:
#   https://github.com/kpu/kenlm
#   https://github.com/kpu/kenlm/blob/master/BUILDING
#--------------------------------------------------------------------------------
#
# TODO:
# - Add lint comment disabling extraneous lint warning (or modify python
#   interface to initialize it):
#     Module 'kenlm' has no 'LanguageModel' member (no-member)
#

"""Example for using the KenLM language modeling utility"""

import os
import kenlm
import sys

from mezcla.system import getenv_boolean, getenv_text
from mezcla import glue_helpers as gh
from mezcla import tpo_common as tpo

# Initialize globals, including adhoc options via environment variables
DEFAULT_LM_FILE = os.path.join(os.path.dirname(__file__), '..', 'lm', 'test.arpa')
LM = getenv_text("LM", DEFAULT_LM_FILE)
SENT_DELIM = getenv_text("SENT_DELIM", "\n", "Delimiter for sentence splitting")
VERBOSE = getenv_boolean("VERBOSE", False, "Verbose output")

# Sanity check
show_usage = (len(sys.argv) > 1) and ("--help" in sys.argv[1])
if (not show_usage) and (not gh.non_empty_file(LM)):
    print("Unable to find usable language model file '%s'" % LM)
    show_usage = True
if show_usage:
    print("Usage: %s [--help] [sentence | -]" % sys.argv[0])
    print("")
    print("Example:")
    print("  kenlm=~/programs/kenlm")
    print("  export PATH=$kenlm/bin:$PATH")
    print("  export LM=$kenlm/test.arpa")
    print("  %s" % __file__)
    print("")
    print("Notes:")
    print("- Use LM environment varaiable to specify alternative language model (see lmplz)")
    print("- Use SENT_DELIM to specify setence delimiter (default is newline)")
    print("- To use standard input, specify - for sentence above.")
    print("- Use the following environment options to customize processing")
    print("\t" + tpo.formatted_environment_option_descriptions())
    sys.exit()

# Load model from ARPA-format file
model = kenlm.LanguageModel(LM)
print('{0}-gram model'.format(model.order))

# Define helper function used when checking that total full score equals direct score
def summed_constituent_score(s):
    """Return sum of scores for ngrams for sentence S"""
    ## OLD: return sum(prob for (prob, _) in model.full_scores(s))
    return sum(prob for (prob, _len, _oov) in model.full_scores(s))

# Read input
sentences = 'language modeling is fun .'
if (len(sys.argv) > 1):
    sentences = " ".join(sys.argv[1:])
if (sentences == "-"):
    sentences = sys.stdin.read()

# Check each sentence (or phrase)
# TODO: rework sto avoid reading sentences entirely into memory (e.g., via generic iterator)
for sentence in sentences.split(SENT_DELIM):
    if not sentence.strip():
        continue
    print("sentence: %s" % sentence)
    print("model score: %s" % tpo.round_num(model.score(sentence)))
    normaized_score = (model.score(sentence) / len(sentence.split()))
    print("normalized score: %s" % tpo.round_num(normaized_score))
    ## TODO: gh.assertion(abs(summed_constituent_score(sentence) - model.score(sentence)) < 1e-3)

    # Print diagnostics in verbose mode
    if VERBOSE:
        words = ['<s>'] + sentence.split() + ['</s>']

        # Show scores and n-gram matches
        print("Constituent ngrams")
        ## OLD: print("Offset\tProb\tLength\tWords")
        ## OLD: for i, (prob, length) in enumerate(model.full_scores(sentence)):
        print("Offset\tProb\tLength\tUnseen\tWords")
        for i, (prob, length, unseen) in enumerate(model.full_scores(sentence)):
            start = i + 2 - length
            end = start + length
            ## OLD: print('{0}\t{1}\t{2}\t{3}'.format(i, tpo.round_num(prob), length, ' '.join(words[start : end])))
            unseen_spec = "*" if unseen else ""
            print('{0}\t{1}\t{2}\t{3}\t{4}'.format(i, tpo.round_num(prob), length, unseen_spec, ' '.join(words[start : end])))

        # Find out-of-vocabulary words
        print("out-of-vocabulary words: %s" % [w for w in words if (not w in model)])
