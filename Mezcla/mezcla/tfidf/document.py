#!/usr/bin/env python3

"""A document object used for the "term frequency" (TF) in TF-IDF.

Example:
    >>> from mezcla.tfidf.document import Document
    >>> from mezcla.tfidf.preprocess import Preprocessor
    >>> input_text = '''Mary had a little lamb, his fur was white as snow
            Everywhere the child went, the lamb, the lamb was sure to go'''
    >>> d = Document(input_text, Preprocessor(stemmer=lambda x: x))
    >>> d__gramsize 
    1
    >>> d.tf_freq('lamb')
    3
    >>> d.tf_raw('lamb')
    0.04411764705882353

"""
# HACK: Attempt at fixing up a very stale example!
# TODO: Make sure the tf_raw calculation revision is correct.
# TODO1: revise docstrings wrt preferred keywords (i.e., not deprecated)

from __future__ import absolute_import, division

# Standard packages
import math
## OLD: import os
import random
## OLD: import sys

# Installed packages
from mezcla import debug
from mezcla import system

# Local packages
## OLD: from .preprocess import clean_text
from mezcla.tfidf.preprocess import clean_text, Preprocessor

# TPO: environment option for weight singleton occurrences low
PENALIZE_SINGLETONS = system.getenv_boolean("PENALIZE_SINGLETONS", False,
                                            "Ignore singleton ngrams")
if PENALIZE_SINGLETONS:
    system.print_stderr("FYI: Penalizing singleton ngrams")


class Document(object):
    """A document holds text, slices text into ngrams, and calculates tf score.

    Attributes:
        text (list): cleaned text, set on init
    """

    def __init__(self, raw_text, preprocessor):
        """All you need is the text body and gramsize (number words in ngram).

        raw_text
            text string input. Will be run through text preprocessing
        preprocessor
            initalized instance of a preprocessor
        """
        self.id = None
        self.text = clean_text(raw_text)
        self.__keywordset = None
        self.__max_raw_frequency = None
        self.__length = None
        self.preprocessor = preprocessor

    def __contains__(self, ngram):
        """Check if the ngram is present in the document."""
        return ngram in self.keywordset

    def __getitem__(self, ngram):
        """Return the DocKeyword object with occurrences via the stemmed ngram."""
        return self.keywordset[ngram]

    def __len__(self):
        """The length of the document is the number of ngrams."""
        # TODO: rename to __size__??
        if not self.__length:
            self.__length = sum([len(x) for x in self.keywordset])
        return self.__length

    @property
    def max_raw_frequency(self):
        """Max ngram frequency found in document."""
        ## if not self.__max_raw_frequency:
        if self.__max_raw_frequency is None:
            biggest_kw = ''
            for kw in self.keywordset:
                if len(kw) > len(biggest_kw):
                    biggest_kw = kw
            self.__max_raw_frequency = len(biggest_kw)
        return self.__max_raw_frequency

    @property
    def gramset(self):
        """Important for fast check if ngram in document.
        Note: Converts self.keywordset hash to set proper.
        """
        ## NOTE: 
        ## OLD: return set([x for x in self.keywordset])
        ## OLD: return {x for x in self.keywordset}
        return set(self.keywordset)

    @property
    def keywordset(self):
        """Return a set of keywords in the document with all their locations."""
        if not self.__keywordset:
            self.__keywordset = {}
            for kw in self.keywords:
                if kw.text not in self.__keywordset:
                    self.__keywordset[kw.text] = kw
                else:
                    self.__keywordset[kw.text] += kw
        return self.__keywordset

    # Term Frequency weighting functions:
    def tf_raw(self, ngram):
        """The (relative) frequency of an ngram in a document."""
        num_occurrences = len(self[ngram]) if ngram in self else 0
        # HACK: give singletons a max DF to lower IDF score
        if (num_occurrences == 1) and PENALIZE_SINGLETONS:
            num_occurrences = 0
        tf_raw = float(num_occurrences) / len(self)
        debug.trace_fmt(7, "tf_raw({ng}): num_occ={no} len(self)={l} result={r}",
                        ng=ngram, no=num_occurrences, l=len(self), r=tf_raw)
        return tf_raw

    def tf_log(self, ngram):
        """The log frequency of an ngram in a document."""
        # TODO: is this formula right? Wikipedia is often wrong...
        return 1 + math.log(self.tf_raw(ngram))

    def tf_binary(self, ngram):
        """Binary term frequency (0 if not present, 1 if ngram is present)."""
        if ngram in self:
            return 1
        return 0

    def tf_norm_50(self, ngram):
        """Double normalized ngram frequency."""
        term_frequency = self.tf_raw(ngram)
        return 0.5 + (0.5 * (term_frequency / self.max_raw_frequency))

    def tf_freq(self, ngram):
        """Returns frequency count for NGRAM"""
        num_occurrences = len(self[ngram]) if ngram in self else 0
        debug.trace_fmt(7, "tf_freq({ng}): num_occ={no} len(self)={l} result={r}",
                        ng=ngram, no=num_occurrences, l=len(self), r=num_occurrences)
        return num_occurrences
    
    def tf(self, ngram, tf_weight='basic', normalize=False):
        """Calculate term frequency.

        Normalizing (stemming) is slow, so it's assumed you're using the ngram.
        """
        if tf_weight == 'norm':
            tf_weight = 'basic'
        if normalize:
            ## TPO: fix referernce to normalize_term
            ## BAD: ngram = self.normalize_term(ngram)
            ngram = self.preprocessor.normalize_term(ngram)
        ## OLD
        ## if tf_weight == 'log':
        ##     return self.tf_log(ngram)
        ## elif tf_weight == 'norm_50':
        ##     return self.tf_norm_50(ngram)
        ## elif tf_weight == 'binary':
        ##     return self.tf_binary(ngram)
        ## elif tf_weight == 'basic':
        ##     return self.tf_raw(ngram)
        ## # TPO: allow for raw frequency
        ## elif tf_weight == 'freq':
        ##     return self.tf_freq(ngram)
        if tf_weight == 'log':
            return self.tf_log(ngram)
        if tf_weight == 'norm_50':
            return self.tf_norm_50(ngram)
        if tf_weight == 'binary':
            return self.tf_binary(ngram)
        if tf_weight == 'basic':
            return self.tf_raw(ngram)
        # TPO: allow for raw frequency
        if tf_weight == 'freq':
            return self.tf_freq(ngram)
        raise ValueError("Invalid tf_weight: " + tf_weight)

    def randgram(self):
        """Return a random gram. Limited to first 100 ngrams."""
        return self.randkeyword().text

    def randkeyword(self):
        """Return a random keyword. Limited to first 100 ngrams."""
        rand_pos = random.randint(0, min(100, len(self.keywordset) - 1))
        for i, x in enumerate(self.keywordset.values()):
            if i == rand_pos:
                return x
        ## print('uh oh')
        ## print(rand_pos)
        system.print_stderr("Error: unexpected condition in randkeyword; rand_pos={rp}", rp=rand_pos)
        return "n/a"

    @property
    def keywords(self):
        """Use the preprocessor to yield keywords from the source text."""
        return self.preprocessor.yield_keywords(self.text, document=self)


def main():
    """Entry point for script: just runs a simple test"""
    text = "my man fran is not a man"
    d = Document(text, Preprocessor(gramsize=1, stemmer=lambda x: x))
    debug.trace_expr(5, [d.tf_freq(t) for t in text.split()])
    debug.assertion(d.tf_freq("man") > d.tf_freq("fran"))
    
#-------------------------------------------------------------------------------
    
if __name__ == '__main__':
    system.print_stderr(f"Warning: {__file__} is not intended to be run standalone. A simple test willl be run.")
    main()
