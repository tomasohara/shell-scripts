#! /usr/bin/env python
#
# Derives a language model over the input text by tabulating n-grams in the text and
# then applying smoothing to the resulting counts. This is designed for the KenLM toolkit:
#    http://kheafield.com/code/kenlm
#
# This automates the following steps:
# 1. Apply sentence and word tokenization
#        $ ../tpo_text_processing.py --lowercase --just-tokenize outbox-2013-06-part-00000.desc.txt >| outbox-2013-06-part-00000.tokenized.txt
# 2. Create the language model using 3-grams
#        $ ~/programs/kenlm/bin/lmplz --memory '25%' --order 3 < outbox-2013-06-part-00000.desc.tokenized.txt >| outbox-2013-06-part-00000.desc.3gram.arpa
#
# Notes:
# - The memory mapped format should be created under a native directory.
# - Under VirtualBox, a non-native directory can be checked via disk free (df):
#   $ df .
#   Filesystem     1K-blocks      Used Available Use% Mounted on
#   none           422983676 418510272   4473404  99% /media/sf_D_DRIVE
#

"""Derive language model by tabulating n-grams"""

# Standard modules
import argparse
import os
import sys

# Local modules
from mezcla import debug
from mezcla import tpo_common as tpo
from mezcla import glue_helpers as gh

# Environment options
SKIP_TOKENIZATION = tpo.getenv_boolean("SKIP_TOKENIZATION", False)
if SKIP_TOKENIZATION:
    tpo.print_stderr("SKIP_TOKENIZATION no longer supported")
MAX_NGRAM = tpo.getenv_integer("MAX_NGRAM", 3, "maximum n-gram size to collect")
USE_MMAP = tpo.getenv_boolean("USE_MMAP", False, "produce memory mapped version of language model file")
NGRAM_EXT = tpo.getenv_text("NGRAM_EXT", str(MAX_NGRAM) + "gram")


def usage(program=sys.argv[0]):
    """Show program options and other usage notes"""
    debug.trace(6, f"usage{program}")
    # TODO: add option for output directory
    print(tpo.format("""
Usage: {program} source-file.txt

Example:

{program} keyword-query-count.query.list
echo $'administrative assistant\\nprogramming assistant\\n' | LM=keyword-query-count.query.list.3gram.arpa SKIP_SENT_TAGS=1 kenlm_example.py -

Notes:
- The output is put in source-file.Ngram.arpa and source-file.Ngram.mmap.

- *** When --mmap is used under VirtualBox VM, make sure the files reside on a native directory
  (not one for a shared folder). ***
    """.format(program=program)))
    return


def main():
    """Entry point for script"""
    # Check command-line arguments
    parser = argparse.ArgumentParser(description="Create ngram-based language model from input")
    parser.add_argument("--usage-notes", default=False, action='store_true', help="Show detailed usage notes")
    parser.add_argument("--output-basename", default="", help="Basename to use for output (by default input file without .txt extension)")
    parser.add_argument("--tokenize", default=False, action='store_true', help="Run tokenization (and lowercasing)")
    parser.add_argument("--verbose", default=False, action='store_true', help="Verbose output mode")
    parser.add_argument("--mmap", default=USE_MMAP, action='store_true', help="Output memory-mapped version of model")
    parser.add_argument("--interpolate-unigrams", default=False, action='store_true', help="Interpolate the unigrams (unlike SRI's LM utility)")
    #
    # note: filename is positional argument
    parser.add_argument("filename", nargs='?', default="-", help="Input data filename (or basename when loading previously saved model)")
    debug.trace_object(6, parser)
    args = vars(parser.parse_args())
    tpo.debug_print("args = %s" % args, 5)
    if (args["usage_notes"]):
        usage()
        sys.exit()
    filename = args['filename']
    verbose = args['verbose']
    tokenize = args['tokenize']
    output_mmap = args['mmap']
    output_basename = args['output_basename']
    if (output_basename == ""):
        output_dir = os.path.dirname(filename)
        output_basename = os.path.join(output_dir, gh.basename(filename, ".txt")) 
        output_basename += tpo.format(".{NGRAM_EXT}")

    # Apply optional sentence and word tokenization
    if (tokenize):
        gh.run("python  -m tpo_text_processing  --lowercase --just-tokenize {filename} >| {output_basename}.tokenized.txt 2>| {output_basename}.tokenized.log")
        filename = output_basename + ".tokenized.txt"

    # Create the language model using 3-grams by default (via ~/programs/kenlm/bin/lmplz)
    lm_options = ""
    if args['interpolate_unigrams']:
        lm_options += " --interpolate_unigrams"
    gh.run("lmplz --memory '50%' --order {MAX_NGRAM} {lm_options} < {filename} >| {output_basename}.arpa 2>| {output_basename}.arpa.log")
    if verbose:
        print(tpo.format("Text-based output is in {output_basename}.arpa"))

    # Optionally converts textual output into memory mapped (binary) format.
    # Note: Warns if using VirtualBox shared folder (see header comments).
    if output_mmap:
        gh.assertion("/media/sf" not in gh.run("df ."))
        gh.run("build_binary  -w mmap  trie  {output_basename}.arpa  {output_basename}.mmap >| {output_basename}.mmap.log 2>&1")
        if verbose:
            print(tpo.format("Binary output is in {output_basename}.mmap"))
    return

#------------------------------------------------------------------------

if __name__ == '__main__':
    main()
