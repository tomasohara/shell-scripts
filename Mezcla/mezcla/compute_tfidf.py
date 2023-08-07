#! /usr/bin/env python
#
# compute_tfidf.py: compute Term Frequency Inverse Document Frequency (TF-IDF)
# for a collection of documents. See https://en.wikipedia.org/wiki/Tf-idf.
#
# TODO:
# - Show examples.
# - Have option for producing document/term matrix.
# - Add option to omit TF, IDF and IDF fields (e.g., in case just interested in frequency counts).
# - Add option to put term at end, so numeric fields are aligned.
# - -and/or- Have ** max-output-term-length option and right pad w/ spaces.
# - See if IDF calculation should for 0 if just one document occurrence.
# - Reconcile with ngram_tfidf.py (e.g., overlap here with subsumption there).
# - Add simple example(s) to help.
#
# Note:
# - This script is just for running tfidf over text files.
# - See ngram_tfdif.py for a wrapper class around tfidf for use in applications
#   like Visual Diff Search that generate the text dynamically.
#


"""Compute Term Frequency/Inverse Document Frequency (TF-IDF) for a set of documents"""

# Standard packages
import csv
import os
import re
import sys

# Installed packages
# TODO: require version 1.1 with TPO hacks
from mezcla import tfidf
from mezcla.tfidf.corpus import Corpus as tfidf_corpus
from mezcla.tfidf.preprocess import Preprocessor as tfidf_preprocessor

# Local packages
from mezcla import debug
from mezcla import system
from mezcla.system import PRECISION
from mezcla.text_utils import make_fixed_length

# Determine environment-based options
DEFAULT_NUM_TOP_TERMS = system.getenv_int("NUM_TOP_TERMS", 10)
MAX_NGRAM_SIZE = system.getenv_int("MAX_NGRAM_SIZE", 1)
MIN_NGRAM_SIZE = system.getenv_int("MIN_NGRAM_SIZE", MAX_NGRAM_SIZE)
IDF_WEIGHTING = system.getenv_text("IDF_WEIGHTING", "basic")
TF_WEIGHTING = system.getenv_text("TF_WEIGHTING", "basic")
DELIMITER = system.getenv_text("DELIMITER", ",")
CORPUS_DUMP = system.getenv_value("CORPUS_DUMP", None,
                                  "Filename for corpus dump")
PRUNE_SUBSUMED_TERMS = system.getenv_bool("PRUNE_SUBSUMED_TERMS", False)
PRUNE_OVERLAPPING_TERMS = system.getenv_bool("PRUNE_OVERLAPPING_TERMS", False)
SKIP_STEMMING = system.getenv_bool("SKIP_STEMMING", False,
                                   "Skip word stemming (via Snowball)")
INCLUDE_STEMMING = not SKIP_STEMMING
STEMMER_LANGUAGE = system.getenv_value("STEMMER_LANGUAGE", None,
                                       "Language for stemming and stop words--not recommended")
LANGUAGE = (STEMMER_LANGUAGE or "")
TAB_FORMAT = system.getenv_bool("TAB_FORMAT", False,
                                 "Use tab-delimited format--facilitates spreadsheet import")
TERM_WIDTH = system.getenv_int("TERM_WIDTH", 32,
                               "Width of term column in output")
SCORE_WIDTH = system.getenv_int("SCORE_WIDTH", PRECISION + 6,
                                "Width of each score column in output (e.g., up to 12 for default precision of 6 as in 1.855712e-03)")

# Option names and defaults
NGRAM_SIZE_OPT = "--ngram-size"
NUM_TOP_TERMS_OPT = "--num-top-terms"
SHOW_SUBSCORES = "--show-subscores"
SHOW_FREQUENCY = "--show-frequency"
CSV = "--csv"
TSV = "--tsv"

#...............................................................................

def show_usage_and_quit():
    """Show command-line usage for script and then exit"""
    # TODO: make 
    usage = """
Usage: {prog} [options] file1 [... fileN]

Options: [--help] [{ngram_size_opt}=N] [{top_terms_opt}=N] [{subscores}] [{frequencies}] [{csv}]

Notes:
- Derives TF-IDF for set of documents, using single word tokens (unigrams),
  by default. 
- By default, the document ID is the position of the file on the command line (e.g., N for fileN above). The document text is the entire file.
- However, with {csv}, the document ID is taken from the first column, and the document text from the second columns (i.e., each row is a distinct document).
- Use following environment options:
      DEFAULT_NUM_TOP_TERMS ({default_topn})
      MIN_NGRAM_SIZE ({min_ngram_size})
      MAX_NGRAM_SIZE ({max_ngram_size})
      TF_WEIGHTING ({tf_weighting}): {{log, norm_50, binary, basic, freq}}
      IDF_WEIGHTING ({idf_weighting}): {{smooth, max, prob, basic, freq}}
""".format(prog=sys.argv[0], ngram_size_opt=NGRAM_SIZE_OPT, top_terms_opt=NUM_TOP_TERMS_OPT, subscores=SHOW_SUBSCORES, frequencies=SHOW_FREQUENCY, default_topn=DEFAULT_NUM_TOP_TERMS, min_ngram_size=MIN_NGRAM_SIZE, max_ngram_size=MAX_NGRAM_SIZE, tf_weighting=TF_WEIGHTING, idf_weighting=IDF_WEIGHTING, csv=CSV)
    print(usage)
    sys.exit()


def get_suffix1_prefix2(subterms1, subterms2):
    """returns any suffix of SUBTERMS1 list that is a prefix of SUBTERMS2 list"""
    # EX: get_suffix1_prefix2(["my", "dog"], ["dog", "has"]) => ["dog"]
    # EX: get_suffix1_prefix2(["a", "b", "c"], ["b", "d"]) => []
    # TODO: support string arguments (e.g., by splitting on whitespace)
    prefix_len = 0
    for subterm1 in subterms1:
        if ((subterm1 in subterms2) and (subterms2.index(subterm1) == prefix_len)):
            prefix_len += 1
        else:
            prefix_len = 0
    prefix = (subterms1[-prefix_len:] if prefix_len else[])
    debug.trace_fmt(7, "get_suffix1_prefix2({st1}, {st2}) => {p}", st1=subterms1, st2=subterms2, p=prefix)
    return prefix
    

def terms_overlap(term1, term2):
    """Whether TERM1 and TERM1 overlap (and the overlapping text if so)
    Note: The overlap must occur at word boundaries
    """
    # EX: terms_overlap("ACME Rocket Research", "Rocket Research Labs") => "Rocket Research"
    # EX: not terms_overlap("Rocket Res", "Rocket Research")
    # TODO: put in text_utils
    subterms1 = term1.strip().split()
    subterms2 = term2.strip().split()
    overlap = ""
    if system.intersection(subterms1, subterms2):
        # pylint: disable=arguments-out-of-order
        overlap = " ".join((get_suffix1_prefix2(subterms1, subterms2) or get_suffix1_prefix2(subterms2, subterms1)))
    debug.trace_fmt(6, "terms_overlap({t1}, {t2}) => {o}", t1=term1, t2=term2, o=overlap)
    return overlap


def is_subsumed(term, terms, include_overlap=PRUNE_OVERLAPPING_TERMS):
    """Whether TERM is subsumed by another term in TERMS, accounting for overlapping terms if INCLUDE_OVERLAP
    Note: subsumption is based on string matching not token matching unlike the overlap check.
    """
    # EX: is_subsumed("White House", ["The White House", "Congress", "Supreme Court"])
    # EX: is_subsumed("White House", ["White Houses"])
    # TODO: Enforce word boundaries as with terms_overlap
    subsumed_by = [subsuming_term for subsuming_term in terms
                   if (((term in subsuming_term) 
                        or (include_overlap and terms_overlap(term, subsuming_term)))
                       and (term != subsuming_term))]
    subsumed = any(subsumed_by)
    debug.trace_fmt(6, "is_subsumed({t}) => {r}; subsumed by: {sb}",
                    t=term, r=subsumed, sb=subsumed_by)
    return subsumed

#...............................................................................

def main():
    """Entry point for script"""
    args = sys.argv[1:]
    ## NOTE: debug now shows args
    debug.trace_fmtd(4, "main()")
    debug.trace_fmtd(4, "os.environ={env}", env=os.environ)

    # Parse command-line arguments
    i = 0
    max_ngram_size = MAX_NGRAM_SIZE
    num_top_terms = DEFAULT_NUM_TOP_TERMS
    show_subscores = False
    show_frequency = False
    csv_file = False
    while ((i < len(args)) and args[i].startswith("-")):
        option = args[i]
        debug.trace_fmtd(5, "arg[{i}]: {opt}", i=i, opt=option)
        if (option == "--help"):
            show_usage_and_quit()
        elif (option == NGRAM_SIZE_OPT):
            i += 1
            max_ngram_size = int(args[i])
        elif (option == NUM_TOP_TERMS_OPT):
            i += 1
            num_top_terms = int(args[i])
        elif (option == SHOW_SUBSCORES):
            show_subscores = True
        elif (option == SHOW_FREQUENCY):
            show_frequency = True
            # Make sure TF-IDF package supports occurrence counts for TF
            tfidf_version = 1.0
            try:
                # Note major and minor revision values assumed to be integral
                major_minor = re.sub(r"^(\d+\.\d+).*", r"\1", tfidf.__version__)
                tfidf_version = float(major_minor)
            except:
                system.print_stderr("Exception in main: " + str(sys.exc_info()))
            assert(tfidf_version >= 1.2)
        elif (option == CSV):
            csv_file = True 
        elif (option == TSV):
            csv_file = True
            global DELIMITER
            DELIMITER = "\t"
        else:
            sys.stderr.write("Error: unknown option '{o}'\n".format(o=option))
            show_usage_and_quit()
        i += 1
    args = args[i:]
    if (len(args) < 1):
        system.print_stderr("Error: missing filename(s)\n")
        show_usage_and_quit()
    if ((len(args) < 2) and (not csv_file) and (not show_frequency)):
        ## TODO: only issue warning if include-frequencies not specified
        system.print_stderr("Warning: TF-IDF not relevant with only one document")

    # Initialize Tf-IDF module
    debug.assertion(not re.search(r"^en(_\w+)?$", LANGUAGE, re.IGNORECASE))
    # Note: disables stemming
    stemmer_fn = None if INCLUDE_STEMMING else (lambda x: x)
    my_pp = tfidf_preprocessor(language=LANGUAGE, gramsize=max_ngram_size, min_ngram_size=MIN_NGRAM_SIZE, all_ngrams=False, stemmer=stemmer_fn)
    corpus = tfidf_corpus(gramsize=max_ngram_size, min_ngram_size=MIN_NGRAM_SIZE, all_ngrams=False, preprocessor=my_pp)

    # Process each of the arguments
    doc_filenames = {}
    for i, filename in enumerate(args):
        # If CSS file, treat each row as separate document, using ID from first column and data from second
        if csv_file:
            with system.open_file(filename) as fh:
                csv_reader = csv.reader(iter(fh.readlines()), delimiter=DELIMITER, quotechar='"')
                # TODO: skip over the header line
                line = 0
                for row in csv_reader:
                    debug.trace_fmt(6, "{l}: {r}", l=line, r=row)
                    doc_id = row[0]
                    try:
                        doc_text = system.from_utf8(row[1])
                    except:
                        debug.trace_fmt(5, "Exception processing line {l}", l=line)
                        doc_text = ""
                    ## TODO: use defaultdict-type hash
                    if doc_id not in corpus:
                        corpus[doc_id] = ""
                    else:
                        ## TODO: corpus[doc_id] += " "
                        corpus[doc_id] = (corpus[doc_id].text + " ")
                    ## TODO: corpus[doc_id] += doc_text
                    corpus[doc_id] = (corpus[doc_id].text + doc_text)
                    doc_filenames[doc_id] = filename + ":" + str(i + 1)
                    line += 1
        # Otherwise, treat entire file as document and use command-line position as the document ID
        else:
            doc_id = str(i + 1)
            doc_text = system.read_entire_file(filename)
            corpus[doc_id] = doc_text
            doc_filenames[doc_id] = filename
    debug.trace_object(7, corpus, "corpus")
    if CORPUS_DUMP:
        system.save_object(CORPUS_DUMP, corpus)

    # Derive headers
    headers = ["term"]
    if show_frequency:
        headers += ["TFreq", "DFreq"]
    if show_subscores:
        headers += ["TF", "IDF"]
    headers += ["TF-IDF"]
    debug.assertion(headers[0] == "term")

    # Output the top terms per document with scores
    # TODO: change the IDF weighting
    for doc_id in corpus.keys():
        print("{id} [{filename}]".format(id=doc_id, filename=doc_filenames[doc_id]))
        if TAB_FORMAT:
            print("\t".join(headers))
        else:
            term_header_spec = make_fixed_length(headers[0], TERM_WIDTH)
            other_header_spec = " ".join([make_fixed_length(h, SCORE_WIDTH) for h in headers[1:]])
            print(term_header_spec + " " + other_header_spec)

        # Get ngrams for document and calculate overall score (TF-IDF).
        # Then print each in tabular format (e.g., "et al   0.000249")
        top_term_info = corpus.get_keywords(document_id=doc_id,
                                            idf_weight=IDF_WEIGHTING,
                                            limit=num_top_terms)
        # Optionally limit the result to terms that don't overlap with higher weighted ones.
        # TODO: Allow overlap if the terms occur in different parts of the document.
        if PRUNE_SUBSUMED_TERMS:
            top_terms = [term_info.ngram.strip() for term_info in top_term_info]
            top_term_info = [ti for (i, ti) in enumerate(top_term_info) 
                             if (not is_subsumed(ti.ngram, top_terms[0: i]))]
        for (term, score) in [(ti.ngram, ti.score)
                              for ti in top_term_info if ti.ngram.strip()]:
            # Get scores including component values (e.g., IDF)
            # TODO: don't round the frequency counts (e.g., 10.000 => 10)
            scores = []
            if show_frequency:
                scores.append(corpus[doc_id].tf_freq(term))
                scores.append(corpus.df_freq(term))
            if show_subscores:
                scores.append(corpus[doc_id].tf(term, tf_weight=TF_WEIGHTING))
                # TODO; idf_weight=TDF_WEIGHTING
                scores.append(corpus.idf(term))
            scores.append(score)

            # Print term and rounded scores
            if TAB_FORMAT:
                print(term + "\t" + "\t".join(map(system.round_as_str, scores)))
            else:
                rounded_scores = [make_fixed_length(system.round_as_str(s), SCORE_WIDTH) for s in scores]
                term_spec = make_fixed_length(system.to_utf8(term), TERM_WIDTH)
                score_spec = " ".join(rounded_scores)
                print(term_spec + " " + score_spec)
                ## TODO: debug.assertion((len(rounded_scores) * PRECISION) < len(score_spec) < (len(rounded_scores) * (1 + SCORE_WIDTH)))
        print("")

    return

#------------------------------------------------------------------------

if __name__ == '__main__':
    main()
