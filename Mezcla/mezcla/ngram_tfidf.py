#! /usr/bin/env python
#
# Support for performing Term Frequency (TF) Inverse Document Frequency (IDF)
# using ngrams. This is provides a wrapper class around the tfidf package
# by elzilrac (https://github.com/elzilrac/tf-idf).
#
# For details on computations, see following Wikipedia pages:
#    https://en.wikipedia.org/wiki/Tf-idf
#    https://en.wikipedia.org/wiki/N-gram.
#
# Note:
# - This provides the wrapper class ngram_tfidf_analysis around tfidf for use
#   in applications like Visual Diff Search (VDS) that use text from external sources.
# - See compute_tfidf.py for computing tfidf over files.
#
# TODO:
# - Add filtering (e.g., subsumption, all numbers).
# - Isolate ngram support into separate module.
# - Reconcile with compute_tfidf.py (e.g., subsumption here with overlap there).
#

"""TF-IDF using phrasal terms via ngram analysis"""
## TODO: fix description (e.g., add pointer to VDS code)

# Standard packages
## import math
## import os
import re
import sys

# Installed packages
from sklearn.feature_extraction.text import CountVectorizer

# Local packages
from mezcla import debug
from mezcla import system
from mezcla import tpo_common as tpo
from mezcla import tfidf
from mezcla.compute_tfidf import terms_overlap
from mezcla.tfidf.corpus import Corpus as tfidf_corpus
from mezcla.tfidf.preprocess import Preprocessor as tfidf_preprocessor
from mezcla.tfidf import preprocess as tfidf_preprocess

PREPROCESSOR_LANG = system.getenv_text("PREPROCESSOR_LANG", "english",
                                       "Language for ngram preprocessor")
# NOTE: MIN_NGRAM_SIZE (e.g., 2) is alternative to deprecated ALL_NGRAMS (implies 1)
MAX_NGRAM_SIZE = system.getenv_int("MAX_NGRAM_SIZE", 4)
# TODO: add descriptions to all getenv options
MIN_NGRAM_SIZE = system.getenv_int("MIN_NGRAM_SIZE", 2)
ALL_NGRAMS = system.getenv_boolean("ALL_NGRAMS", False)
USE_NGRAM_SMOOTHING = system.getenv_boolean("USE_NGRAM_SMOOTHING", False)
DEFAULT_TF_WEIGHTING = 'basic'
TF_WEIGHTING = system.getenv_text("TF_WEIGHTING", DEFAULT_TF_WEIGHTING)
DEFAULT_IDF_WEIGHTING = 'smooth' if USE_NGRAM_SMOOTHING else 'basic'
IDF_WEIGHTING = system.getenv_text("IDF_WEIGHTING", DEFAULT_IDF_WEIGHTING)
MAX_TERMS = system.getenv_int("MAX_TERMS", 100)
ALLOW_NGRAM_SUBSUMPTION = system.getenv_boolean("ALLOW_NGRAM_SUBSUMPTION", False,
                                                "Allow ngram subsumed by another--substring")
ALLOW_NGRAM_OVERLAP = system.getenv_boolean("ALLOW_NGRAM_OVERLAP", False,
                                            "Allows ngrams to overlap--token boundariese")
ALLOW_NUMERIC_NGRAMS = system.getenv_boolean("ALLOW_NUMERIC_NGRAMS", False)
## OLD: DEFAULT_USE_CORPUS_COUNTER = (not tfidf_preprocessor.USE_SKLEARN_COUNTER)
DEFAULT_USE_CORPUS_COUNTER = (not tfidf_preprocess.USE_SKLEARN_COUNTER)
USE_CORPUS_COUNTER = system.getenv_boolean("USE_CORPUS_COUNTER", DEFAULT_USE_CORPUS_COUNTER,
                                           "Use slow tfidf package ngram tabulation")

try:
    # Note major and minor revision values are assumed to be integral
    major_minor = re.sub(r"^(\d+\.\d+).*", r"\1", tfidf.__version__)
    TFIDF_VERSION = float(major_minor)
except:
    TFIDF_VERSION = 1.0
    system.print_stderr("Exception in main: " + str(sys.exc_info()))
assert(TFIDF_VERSION > 1.0)

            
class ngram_tfidf_analysis(object):
    """Class for performing TF-IDF over ngrams and returning sorted list"""

    def __init__(self, pp_lang=PREPROCESSOR_LANG, min_ngram_size=MIN_NGRAM_SIZE, max_ngram_size=MAX_NGRAM_SIZE, 
                 *args, **kwargs):
        """Class constructor: initialize corpus object (with PP_LANG, MIN_NGRAM_SIZE, and MAX_NGRAM_SIZE)"""
        # TODO: add option for stemmer; add all_ngrams and min_ngram_size to constructor
        debug.trace_fmtd(4, "ngram_tfidf_analysis.__init__(lang={pl}, min={minsz}, max={maxsz})",
                         pl=pp_lang, minsz=min_ngram_size, maxsz=max_ngram_size)
        debug.trace_fmtd(5, "\targs={a} kwargs={k}", a=args, k=kwargs)
        if pp_lang is None:
            pp_lang = PREPROCESSOR_LANG
        self.min_ngram_size = min_ngram_size
        self.max_ngram_size = max_ngram_size
        self.pp = tfidf_preprocessor(language=pp_lang,
                                     gramsize=self.max_ngram_size,
                                     min_ngram_size=self.min_ngram_size,
                                     all_ngrams=ALL_NGRAMS,
                                     stemmer=lambda x: x)
        self.corpus = tfidf_corpus(gramsize=self.max_ngram_size,
                                   min_ngram_size=self.min_ngram_size,
                                   all_ngrams=ALL_NGRAMS,
                                   language=pp_lang,
                                   preprocessor=self.pp)
        super().__init__(*args, **kwargs)

    def add_doc(self, text, doc_id=None):
        """Add document TEXT to collection with key DOC_ID, which defaults to order processed (1-based)"""
        if doc_id is None:
            doc_id = str(len(self.corpus) + 1)
        self.corpus[doc_id] = text

    def get_doc(self, doc_id):
        """Return document data for DOC_ID"""
        return self.corpus[doc_id]

    def get_top_terms(self, doc_id, tf_weight=TF_WEIGHTING, idf_weight=IDF_WEIGHTING, limit=MAX_TERMS,
                      allow_ngram_subsumption=ALLOW_NGRAM_SUBSUMPTION,
                      allow_ngram_overlap=ALLOW_NGRAM_OVERLAP, allow_numeric_ngrams=ALLOW_NUMERIC_NGRAMS):
        """Return list of (term, weight) tuples for DOC_ID up to LIMIT count, using TF_WEIGHT and IDF_WEIGHT schemes
        Notes:
        - TF_WEIGHT in {basic, binary, freq, log, norm_50}
        - IDF_WEIGHT in {basic freq, max, prob, smooth}
        - The top ngrams omit blanks and other relics of tokenization
        - Lower weighted ngrams are omitted if subsumed by higher (or vice versa) unless ALLOW_NGRAM_SUBSUMPTION;
          likewise, in the case of ngram overlap unless ALLOW_NGRAM_OVERLAP
        """
        # Get objects for top terms
        # ex: top_terms=[CorpusKeyword(term=<tfidf.dockeyword.DocKeyword object at 0x7f08b43bf550>, ngram=u'patuxent river', score=0.0015548719642054984), ... CorpusKeyword(term=<tfidf.dockeyword.DocKeyword object at 0x7f08b43cf110>, ngram=u'afognak native corporation', score=0.0009894639772216809)]
        # Get twice as many top terms to display to account for filtering
        # TODO: keep track of how often too few terms shown
        debug.trace(6, (f"get_top_terms({doc_id}, tfw:{tf_weight}, idfw:{idf_weight}, lim={limit},"
                        f"allow_sub={allow_ngram_subsumption}, allow_over={allow_ngram_overlap},"
                        f"allow_num={allow_numeric_ngrams})"))
        top_terms = self.corpus.get_keywords(document_id=doc_id,
                                             tf_weight=tf_weight,
                                             idf_weight=idf_weight,
                                             limit=(2 * limit))
        debug.trace_fmtd(7, "top_terms={tt}", tt=top_terms)
        # Skip empty tokens due to spacing and to punctuation removal (e.g, " ")
        temp_top_term_info = [(k.ngram, k.score) for k in top_terms if k.ngram.strip()]
        # Put spaces around ngrams to aid in subsumption tests
        check_ngram_overlap = (not (allow_ngram_subsumption and allow_ngram_overlap))
        if check_ngram_overlap:
            spaced_ngrams = [(" " + ngram + " ") for (ngram, _score) in temp_top_term_info]
            debug.trace_fmtd(7, "spaced_ngrams={sn}", sn=spaced_ngrams)
        top_term_info = []
        for (i, (ngram, score)) in enumerate(temp_top_term_info):
            
            if (not ngram.strip()):
                debug.trace_fmt(5, "Omitting invalid ngram '{ng}'", ng=ngram)
                continue
            ## OLD:
            ## if ((not allow_numeric_ngrams) and all([tpo.is_numeric(token) for token in ngram.split()])):
            ##     debug.trace_fmt(5, "Omitting numeric ngram '{ng}'", ng=ngram)
            ##     continue
            if ((not allow_numeric_ngrams) and any([tpo.is_numeric(token) for token in ngram.split()])):
                debug.trace_fmt(5, "Omitting ngram with numerics '{ng}'", ng=ngram)
                continue
            
            # Check for subsumption (e.g., "new york" in "new york city") and overlap (e.g. "new york" and "york city")
            ## TODO: record ngram offsets to facilitate contiguity tests
            include = True
            if check_ngram_overlap:
                for (j, other_spaced_ngram) in enumerate(spaced_ngrams):
                    is_subsumed = ((not allow_ngram_subsumption) and
                                   ((spaced_ngrams[i] in other_spaced_ngram)
                                     or (other_spaced_ngram in spaced_ngrams[i])))
                    has_overlap = ((not allow_ngram_overlap) and
                                   terms_overlap(spaced_ngrams[i], other_spaced_ngram))
                    if ((i > j) and (is_subsumed or has_overlap)):
                        include = False
                        label = ("in subsumption" if is_subsumed else "overlapping")
                        debug.trace_fmt(5, "Omitting lower-weigted ngram '{ng2}' {lbl} with '{ng1}'",
                                        ng1=other_spaced_ngram, ng2=spaced_ngrams[i], lbl=label)
                        break
            if not include:
                continue

            # OK
            top_term_info.append((ngram, score))
            if (len(top_term_info) == limit):
                break
        # Sanity check on number of terms displayed
        num_terms = len(top_term_info)
        if (num_terms < limit):
            debug.trace_fmt(3, "Warning: only {n} terms shown (of {m} max)",
                            n=num_terms, m=limit)
        debug.trace_fmtd(6, "top_term_info={tti}", tti=top_term_info)
        return top_term_info

    def old_get_ngrams(self, text):
        """Returns generator with ngrams in TEXT"""
        ## NOTE: Now returns the ngrams
        ## BAD return self.pp.yield_keywords(text)
        ngrams = []
        gen = self.pp.yield_keywords(text)
        more = True
        while (more):
            ## DEBUG: debug.trace_fmtd(6, ".")
            try:
                ## OLD: ngrams.append(gen.next().text)
                ngrams.append(next(gen).text)
            except StopIteration:
                more = False
        debug.trace_fmt(6, "ngram_tfidf_analysis.old_get_ngrams({t}) [self={s}] => {nl}", 
                        t=text, s=self, nl=ngrams)
        return ngrams

    def get_ngrams(self, text):
        """Returns ngrams in TEXT (from size MIN_NGRAM_SIZE to MAX_NGRAM_SIZE)"""
        # Based on https://stackoverflow.com/questions/13423919/computing-n-grams-using-python.
        ## OLD: vectorizer = CountVectorizer(ngram_range=(MIN_NGRAM_SIZE, MAX_NGRAM_SIZE))
        if USE_CORPUS_COUNTER:
            return self.old_get_ngrams(text)
        if self.corpus:
            ## OLD: debug.trace(2, "Warning: not using tfidf corpus object")
            debug.trace(6, "Note: not using tfidf corpus object")
        vectorizer = CountVectorizer(ngram_range=(self.min_ngram_size, self.max_ngram_size))
        analyzer = vectorizer.build_analyzer()
        ngram_list = analyzer(text)
        debug.trace_fmt(6, "ngram_tfidf_analysis.get_ngrams({t}) [self={s}] => {nl}", 
                        t=text, s=self, nl=ngram_list)
        return ngram_list

def main():
    """Entry point for script"""
    if ((len(sys.argv) == 1) or (sys.argv[1] == "--help")):
        usage = "Usage: {prog} [--help] [-]".format(prog=sys.argv[0])
        system.exit(usage)
    
    # Tabulate ngram occurrences
    ngram_analyzer = ngram_tfidf_analysis(min_ngram_size=2, max_ngram_size=3)
    all_text = system.read_entire_file(__file__)
    ## OLD: all_ngrams = ngram_analyzer.old_get_ngrams(all_text)
    all_ngrams = ngram_analyzer.get_ngrams(all_text)
    # pylint: disable=unnecessary-comprehension
    reversed_all_text = " ".join(list(reversed([token for token in all_text.split()])))
    ngram_analyzer.add_doc(all_text, doc_id="doc1")
    ngram_analyzer.add_doc(reversed_all_text, doc_id="rev-doc1")
    top_ngrams = ngram_analyzer.get_top_terms("rev-doc1", allow_ngram_subsumption=False, allow_ngram_overlap=False)

    # Check for common ngrams
    debug.assertion("simple test follows" in all_ngrams)
    debug.assertion("system getenv_boolean" in top_ngrams)
    debug.assertion("system" not in all_ngrams)
    debug.assertion("getenv_boolean" not in all_ngrams)
    
    # Check for filtering based on subsumption and overlap
    debug.assertion("warning not" in top_ngrams)
    debug.assertion("warning not intended" not in top_ngrams)

    # Check for tf/idf values
    # TODO: add assertion for specific tfidf values
    try:
        debug.assertion(ngram_analyzer.corpus.tf_idf("system getenv_boolean", document_id="doc1")
                        == ngram_analyzer.corpus.tf_idf("getenv_boolean system", document_id="rev-doc1"))
    except:
        system.print_exception_info("corpus.tf_idf")

    # Output ngram sample
    SAMPLE_SIZE = 10
    init_ngram_spec = "\n\t".join(all_ngrams[:SAMPLE_SIZE])
    print(f"first 10 ngrams in {__file__}:\n\t{init_ngram_spec}")
    init_top_ngram_spec = "\n\t".join([f"{t}: {tpo.round_num(s, 3)}"
                                       for (t, s) in top_ngrams[:SAMPLE_SIZE]])
    print(f"top ngrams in {__file__}:\n\t{init_top_ngram_spec}")

    
#-------------------------------------------------------------------------------

if __name__ == '__main__':
    system.print_stderr("Warning: not intended for command-line use; simple test follows")
    main()
