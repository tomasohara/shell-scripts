#! /usr/bin/env python
#
# analyze_tfidf.py: analyze TF/IDF output produced via search_table_file_index.py with
# respect to term differentiation, including support for filtering based on inclusion
# and exclusion lists.
#
# TODO:
# - drop from mezcla (likewise check for other older scripts)
# - add save option
# - show sample I/O
# - have option to add relative frequency to output (for aid in tuning MIN_FREQ/MAX_FREQ)
#

"""TF/IDF analysis built upon search_table_file_index.py"""

import argparse
from collections import defaultdict
import re
import sys

from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla import system
from mezcla import tpo_common as tpo
from mezcla.tpo_common import debug_print, debug_format

MAX_TERMS = tpo.getenv_integer("MAX_TERMS", 10)
MAX_NUM = tpo.getenv_integer("MAX_NUM", system.MAX_INT)
TOP_TERMS = tpo.getenv_integer("TOP_TERMS", 25)
INCLUSION_FILE = system.getenv_value("INCLUSION_FILE", None)
EXCLUSION_FILE = system.getenv_value("EXCLUSION_FILE", None)
INCLUDE_CONTEXT = tpo.getenv_boolean("INCLUDE_CONTEXT", False)
INDEX_DIR = tpo.getenv_text("INDEX_DIR", "table-file-index")
MIN_FREQ = tpo.getenv_number("MIN_FREQ", None)
MAX_FREQ = tpo.getenv_number("MAX_FREQ", None)
DOC_FREQ_FILE = tpo.getenv_value("DOC_FREQ_FILE", None)
FILTER_BY_FREQ = MIN_FREQ or MAX_FREQ or DOC_FREQ_FILE
DOCID_MAPPING_FILE = tpo.getenv_value("DOCID_MAPPING_FILE", None)
OMIT_WEIGHT = tpo.getenv_boolean("OMIT_WEIGHT", False)
USE_SHELVE = tpo.getenv_boolean("USE_SHELVE", False)
if USE_SHELVE:
    import shelve

# TEMP: Allow for rernning with previously produced document frequency file
REUSE_DOC_FREQ = FILTER_BY_FREQ and DOC_FREQ_FILE and gh.non_empty_file(DOC_FREQ_FILE) and USE_SHELVE
if REUSE_DOC_FREQ:
    # Note: Relative min/max frequencies need access to the index (for number of documents)
    # TODO: See if dummy "" token suitable for this.
    gh.assertion(not (0 < MIN_FREQ < 1))
    gh.assertion(not (0 < MAX_FREQ < 1))
else:
    from search_table_file_index import IndexLookup


def main():
    """Entry point for script"""
    debug.trace(4, f"main(): sys.argv={sys.argv}")

    # Check command-line arguments
    parser = argparse.ArgumentParser(description="Analyzes TF/IDF differentiation")
    # parser.add_argument("--TODO-int-arg", type=int, default=SESSION, help="TODO: description")
    parser.add_argument("--verbose", default=False, action='store_true', help="Verbose output")
    parser.add_argument("--save", default=None, help="Filename to save hash with mapping from docid to related keyword information")
    # TODO: parser.add_argument("filename", nargs='?', default=None, help="Input data")
    parser.add_argument("filename", nargs='?', default="-", help="Input data")
    args = vars(parser.parse_args())
    debug_print("args = %s" % args, 5)
    input_file = sys.stdin
    if (args['filename'] != "-"):
        input_file = system.open_file(args['filename'])
    verbose_output = args['verbose'] or INCLUDE_CONTEXT
    save_mapping = args['save']

    # Read supporting files
    inclusion_keywords = exclusion_keywords = None
    if INCLUSION_FILE:
        inclusion_keywords = tpo.create_boolean_lookup_table(INCLUSION_FILE)
    if EXCLUSION_FILE:
        exclusion_keywords = tpo.create_boolean_lookup_table(EXCLUSION_FILE)
    inclusion_filtered = exclusion_filtered = 0
    frequency_filtered = 0
    # note: doc ID mapping assumed to be 0-based list of labels
    docid_mapping_list = None
    if DOCID_MAPPING_FILE:
        docid_mapping_list = gh.read_lines(DOCID_MAPPING_FILE)
    doc_freq_hash = {}
    if (DOC_FREQ_FILE and USE_SHELVE):
        doc_freq_hash = shelve.open(DOC_FREQ_FILE)
    # note: entry for empty string gives total
    doc_freq_hash[""] = 0

    # Open index for when resolving document context
    # TODO: add regular options for this
    index_lookup = None
    if INCLUDE_CONTEXT or FILTER_BY_FREQ:
        index_lookup = IndexLookup(INDEX_DIR) if (INCLUDE_CONTEXT or not REUSE_DOC_FREQ) else None

        # Initialize for frequency-based filtering
        if FILTER_BY_FREQ:
            # Create function with cached results for term frequency in specified index
            def doc_freq(term):
                """Get document frequency for TERM from 'index_lookup' and maintain overall total"""
                if term in doc_freq_hash:
                    freq = doc_freq_hash[term]
                else:
                    freq = index_lookup.doc_freq(term) if index_lookup else 0
                    doc_freq_hash[term] = freq
                    doc_freq_hash[""] += 1
                    tpo.debug_print("doc_freq(%s) => %s" % (term, freq), 6)
                return freq

            # Normalize frequency constraints, supplying defaults and converting percentages to counts
            global MIN_FREQ, MAX_FREQ
            MIN_FREQ = 1 if (not MIN_FREQ) else MIN_FREQ
            MAX_FREQ = index_lookup.get_num_docs() if (not MAX_FREQ) else MAX_FREQ
            if MIN_FREQ < 1:
                MIN_FREQ *= index_lookup.get_num_docs()
            if MAX_FREQ < 1:
                MAX_FREQ *= index_lookup.get_num_docs()
            tpo.debug_print("Applying keyword frequency bounds: [%s, %s]" % (tpo.round_num(MIN_FREQ), tpo.round_num(MAX_FREQ)), 4)
            gh.assertion(MIN_FREQ <= MAX_FREQ)

    # Initialize accumulators
    num_docs = 0
    num_keywords = 0
    keyword_freq = defaultdict(int)
    total_mean_tfidf = 0.0
    all_keywords_freq = defaultdict(int)

    # Scan input for TF/IDF info, updating accumulators
    all_tfidf_info = None
    if save_mapping:
        all_tfidf_info = shelve.open(save_mapping) if USE_SHELVE else {}
    line_num = 0
    for line in input_file:
        line_num += 1
        line = line.strip("\n")
        debug_print("L%d: %s" % (line_num, line), 6)

        # Extract IF/IDF info and apply normalization (e.g., removing quotes)
        # TODO: rework search_table_file_index.py to use JSON formatting
        match = re.search(r"docid=(.*) tfidf=\[(.*)\]", line)
        if (not match):
            debug_print("Ignoring line %d: %s" % (line_num, line), 5)
            continue
        num_docs += 1
        if (num_docs > MAX_NUM):
            num_docs -= 1
            tpo.debug_format("Max entries reached ({MAX_NUM})", 4)
            break
        (docid, tfidf_info) = match.groups()
        tfidf_info = tfidf_info.replace("'", "")
        all_keywords = []

        tfidf_entries = tfidf_info.split(", ")[:MAX_TERMS]
        total_tfidf = 0.0
        num_tfidf = 0
        filtered_tfidf = []
        for tfidf_entry in tfidf_entries:
            tfidf_entry = tfidf_entry.strip("'")
            match = re.match(r"(.*):([0-9\.\-]+)", tfidf_entry)
            if (not match):
                debug_print("Trouble extracting TF/IDF entry (%s) on line %d" % (tfidf_entry, line_num), 4)
                continue
            (keyword, weight) = match.groups()
            debug_format("keyword={keyword} weight={weight}", 6)
            # TODO: have option to perform tabulations over filtered keywords
            num_tfidf += 1
            keyword_freq[keyword] += 1
            num_keywords += 1
            total_tfidf += float(weight)

            # Apply various keyword filters (e.g., explicit or via frequency considerations)
            if inclusion_keywords and (keyword not in inclusion_keywords):
                debug_print("Excluding keyword not in inclusion list: %s" % keyword, 4)
                inclusion_filtered += 1
                continue
            if exclusion_keywords and (keyword in exclusion_keywords):
                debug_print("Excluding keyword in exclusion list: %s" % keyword, 4)
                exclusion_filtered += 1
                continue
            if FILTER_BY_FREQ:
                freq = doc_freq(keyword)
                if (not (MIN_FREQ <= freq <= MAX_FREQ)):
                    debug_print("Excluding keyword '%s' with frequency %s outside bounds" % (keyword, freq), 4)
                    frequency_filtered += 1
                    continue

            tfidf_info = keyword if OMIT_WEIGHT else tfidf_entry
            filtered_tfidf.append(tfidf_info)
            keyword_freq[keyword] += 1
            num_keywords += 1
            total_tfidf += float(weight)
            all_keywords.append(keyword)

        mean_tfidf = (total_tfidf / num_tfidf) if (num_tfidf > 0) else 0.0
        total_mean_tfidf += mean_tfidf
        # TODO: maintain n-gram sequences (i.e., top-grams for n from 2 to MAX_TERMS)
        sorted_keywords = "{" + ", ".join(sorted(all_keywords)) + "}"
        all_keywords_freq[sorted_keywords] += 1
        doc_label = docid_mapping_list[int(docid)] if DOCID_MAPPING_FILE else docid
        if verbose_output:
            if INCLUDE_CONTEXT:
                # TODO: sort by decreasing frequency
                (terms, tfs) = index_lookup.get_doc_terms_and_freqs(int(docid))
                terms_with_freq = [(t + ((":%d" % f) if f > 1 else ""))  for (t, f) in zip(terms, tfs)]
                print("doc=[%s]" % ", ".join(terms_with_freq))
            print("docid=%s tfidf=%s" % (doc_label, filtered_tfidf))
        else:
            debug_print("docid=%s filtered_tfidf=%s" % (doc_label, filtered_tfidf), 4)
        if save_mapping:
            all_tfidf_info[doc_label] = ", ".join(filtered_tfidf)

    # Print a summary
    # TODO: show frequencies for top keywords and top keyword sequences; omit cases with frequency 1
    print("%d documents" % num_docs)
    print("%d keywords; %d distinct" % (num_keywords, len(keyword_freq)))
    top_keywords = sorted(keyword_freq.keys(), reverse=True, key=lambda k: keyword_freq[k])[:TOP_TERMS]
    debug_format("keyword_freq={keyword_freq}", 6)
    print("most common keywords: %s" % top_keywords)
    top_all_keywords = sorted(all_keywords_freq.keys(), reverse=True, key=lambda s: all_keywords_freq[s])[:TOP_TERMS]
    debug_format("all_keywords_freq={all_keywords_freq}", 6)
    print("most common keyword sequences: %s" % top_all_keywords)
    #
    mean_mean_tfidf = (total_mean_tfidf / num_docs) if (num_docs > 0) else 0.0
    print("mean mean TF/IDF: %s" % tpo.round_num(mean_mean_tfidf))
    if INCLUSION_FILE:
        print("%d inclusion-filtered out" % inclusion_filtered)
    if EXCLUSION_FILE:
        print("%d exclusion-filtered out" % exclusion_filtered)
    if FILTER_BY_FREQ:
        print("%d frequency-filtered out" % frequency_filtered)

    # Output mapping
    if save_mapping and (not USE_SHELVE):
        tpo.store_object(save_mapping, all_tfidf_info)
        if DOC_FREQ_FILE:
            tpo.store_object(DOC_FREQ_FILE, doc_freq_hash)

    # Cleanup
    if (input_file != sys.stdin):
        input_file.close()

    return

#------------------------------------------------------------------------

if __name__ == '__main__':
    main()
