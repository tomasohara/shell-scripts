#!/usr/bin/env python3
# coding: utf-8
# TODO:
# - Fix env-spec above and put coding on same line.
# - Verify the fixup for PEP-0479 didn't break anything in Python 2 (e.g., for regression testing).
# - *** Remove Python2-specific code!
#

"""Pre-processing step for text.

Example:
    >>> from mezcla.tfidf.preprocess import Preprocessor
    >>> p = Preprocessor(gramsize=2)
    >>> sorted(list([k.text for k in p.yield_keywords("a b c")]))
    ["a b", "b c"]
"""
# TPO: TODO: 
# - add logging
# - replace all_ngrams with min_ngram_size
# - add test set and check explicitly with multi-threaded access
from __future__ import absolute_import, with_statement

# Standard modules
from collections import namedtuple
import re
import sys  # python2 support
from threading import RLock
import html

# Installed modules
## TODO: find better documented memoization package
from cachetools import LRUCache, cached  # python2 support
from nltk.stem import SnowballStemmer
## OLD: from six.moves.html_parser import HTMLParser  # python2 support
from sklearn.feature_extraction.text import CountVectorizer
from stop_words import get_stop_words

# Local modules
from mezcla import debug
from mezcla import system
from mezcla.tfidf.dockeyword import DocKeyword

## OLD: unescape = HTMLParser().unescape
unescape = html.unescape


# TPO: Allow word splitting pattern to be overwritten.
# TODO: Get WORD_REGEX from environment.
# TODO: Have option to ignore words with specific punctuation (or to include).
# TODO: strip period to allow for ngrams with abbreviations (e.g., "Dr. Jones").
SPLIT_WORDS = system.getenv_bool("SPLIT_WORDS", False,
                                 "Split by word token instead of whitespace")
BAD_WORD_PUNCT_REGEX = system.getenv_text("BAD_WORD_PUNCT_REGEX", r"[^a-zA-Z0-9_'$ -]",
                                          "Regex for punctuation not in words")
SKIP_WORD_CLEANING = system.getenv_bool("SKIP_WORD_CLEANING", False,
                                        "Omit word punctuation cleanup")
## OLD:
## SKLEARN_TOKENIZER = system.getenv_bool("SKLEARN_TOKENIZER", False,
##                                        "Use sklearn CountVectorizer for ngrams")
USE_SKLEARN_COUNTER = system.getenv_bool("USE_SKLEARN_COUNTER", False,
                                         "Use sklearn CountVectorizer for ngrams")


if SPLIT_WORDS:
    debug.trace(2, "FYI: Splitting by word token (not whitespace)\n")
    ## BAD: True
WORD_REGEX = r'\w+' if SPLIT_WORDS else r'\S+'

def handle_unicode(text):
    """Needed for the description fields."""
    if re.search(r'\\+((u([0-9]|[a-z]|[A-Z]){4}))', text):
        text = text.encode('utf-8', 'ignore').decode('unicode-escape', 'ignore')
    text = re.sub(r'\\n', '\n', text)
    text = re.sub(r'\\t', '\t', text)
    return text


def handle_html_unquote(text):
    """Detect if there are HTML encoded characters, then decode them."""
    if re.search(r'(&#?x?)([A-Z]|[a-z]|[0-9]){2,10};', text):
        text = unescape(text)
    return text


def handle_mac_quotes(text):
    """Handle the unfortunate non-ascii quotes OSX inserts."""
    text = text.replace(u'“', u'"').replace(u'”', u'"')\
        .replace(u'‘', u"'").replace(u'’', u"'")
    return text


def handle_text_break_dash(text):
    """Convert text break dashes into semicolons to simplify things.

    Example:
        "She loved icecream- mint chip especially"
        "She loved icecream - mint chip especially"
        both convert to
        "She loved icecream; mint chip especially"

        However,
        "The 27-year-old could eat icecream any day"
        will not be changed.
    """
    return re.sub(r'\s+-\s*|\s*-\s+', ';', text)


def clean_text(raw_text):
    """Strip text of non useful characters.
    Note: This is no-op if SKIP_WORD_CLEANING (global).
    """
    # TODO: rework so SKIP_WORD_CLEANING applied elsewhere
    text = raw_text

    
    if not SKIP_WORD_CLEANING:
        # Must strip HTML tags out first!
        text = re.sub('<[^<]+?>', ' ', text)
        text = handle_unicode(text)
        text = handle_html_unquote(text)
        text = handle_mac_quotes(text)
        text = handle_text_break_dash(text)
        text = text.lower()

        ## BAD: regex_subs = ['\t', '\n', '\r', '\s+', '&']
        regex_subs = ['\t', '\n', '\r', r'\s+', '&']
        for regex_sub in regex_subs:
            text = re.sub(regex_sub, ' ', text)
    debug.trace(8, "clean_text({raw_text}) => {text}")
    return text


def create_stemmer(language):
    """Return wordform stemmer for LANGUAGE (via SnowBall)"""
    stemmer = SnowballStemmer(language)
    
    # Define the stemmer for the particular language
    def stem_wordform(wordform):
        """Returned root of WORDFORM"""
        root = stemmer.stem(wordform)
        debug.trace_fmt(9, "stem_wordform({wf}) => {r}", wf=wordform, r=root)
        return root

    # Do sanity check
    if (language == "english"):
        debug.assertion(stem_wordform("running") == "run")

    return stem_wordform


class Preprocessor(object):
    """Prep the text for TF-IDF calculations.

    Fixes some unicode problems, handles HTML character encoding,
    and removes HTML tags.

    Strips some non alphanumeric characters, but keeps ngram boundary
    markers (eg, period (',') and semi-colon (';'))

    If a stopwords file is provided, it will remove stopwords.

    Example:
        >>> processor = Preprocessor('english_stopwords.txt')
        >>> processor.clean('He was an interesting fellow.')
        "was interesting fellow."
    """

    stopwords = set()
    contractions = r"(n't|'s|'re|'ll)$"
    negative_gram_breaks = r'[^:;!^,\?\.\[|\]\(|\)"`]+'
    supported_languages = (
        'danish', 'dutch', 'english', 'finnish', 'french', 'german', 'hungarian',
        'italian', 'kazakh', 'norwegian', 'porter', 'portuguese', 'romanian',
        'russian', 'spanish', 'swedish', 'turkish'
    )

    def __init__(self, min_ngram_size=None, max_ngram_size=None,
                 language=None, stopwords_file=None, stemmer=None,
                 gramsize=None, all_ngrams=None):
        """Preprocessor must be initalized for use if using stopwords.

        stopwords_file (filename): contains stopwords, one per line
        stemmer (function):  takes in a word and returns the stemmed version
        min_ngram_size (int-or-None):
            if integral, gives the lower bound
        max_ngram_size (int-or-None):
            if integral, gives the upper bound
        negative_gram_breaks (regex):
            if a word ends with one of these characters, an
            ngram may not cross that. Expressed as a _negative_ regex.
            Example:
            in the sentence "Although he saw the car, he ran across the street"
            "car he" may not be a bi-gram
        stopwords_file (filename):
            Provide a list of stopwords. If used in addition to "language", the
            provided stopwords file overrides the default.
        stemmer (function):
            A function that takes in a single argument (str) and returns a string
            as the stemmed word. Overrides the default behavior if specified.
            Default None:
                Use the NLTK snowball stemmer for the sepcified language. If
                language is not found, no stemming will take place.
        gramsize (int-or-None): maximum word size for ngrams
            Note: deprecated (use min_ngram_size instead).
        all_ngrams (bool):
            if true, all possible ngrams of length "gramsize" and smaller will
            be examined. If false, only ngrams of _exactly_ length "gramsize"
            will be run.
            Note: deprecated (use min_ngram_size instead).
        """
        self.__stemmer = None
        if language:
            debug.assertion(language in self.supported_languages)
            if language in SnowballStemmer.languages:
                self.__stemmer = create_stemmer(language)
            self.stopwords = get_stop_words(language)
        if stopwords_file:
            self._load_stopwords(stopwords_file)
        if stemmer:
            self.__stemmer = stemmer
        if not self.__stemmer:
            debug.trace(4, "Warning: defining no-op stemmer in Preprocessor")
            self.__stemmer = lambda x: x  # no change to word
        debug.assertion(not (gramsize and max_ngram_size))
        debug.assertion(not (all_ngrams and min_ngram_size))
        ## OLD: self.__gramsize = gramsize
        self.__gramsize = (max_ngram_size or gramsize)
        self.__all_ngrams = all_ngrams
        self.__min_ngram_size = (min_ngram_size or gramsize)

    @property
    def gramsize(self):
        """Number of words in the ngram."""
        return self.__gramsize

    @property
    def all_ngrams(self):
        """True if ngrams of size "gramsize" or smaller will be generated.

        False if only ngrams of _exactly_ size "gramsize" are generated.
        """
        return self.__all_ngrams

    @property
    def min_ngram_size(self):
        """If non-Null, can be used to override all_ngrams (q.v.), so
        ngrams go from [M, N] rather than [1, N]
        """
        return self.__min_ngram_size

    def _load_stopwords(self, filename):
        with open(filename) as f:
            words = []
            for line in f:
                words.append(line.strip())
        self.stopwords = set(words)

    def handle_stopwords(self, text):
        """Remove stop words from the text."""
        out = []
        for word in text.split(' '):
            # Remove common contractions for stopwords when checking list
            check_me = re.sub(self.contractions, '', word)
            if check_me in self.stopwords:
                continue
            out.append(word)
        return ' '.join(out)

    def normalize_term(self, text):
        """Cleans the text characters (optional), removes stopwords, and applies stemming

        Assumes the input is already the number of words you want for the ngram.
        Note: Omits word punctuation cleanup if SKIP_WORD_CLEANING (global).
        """
        text = clean_text(text)
        text = self.handle_stopwords(text)
        return self.stem_term(text)

    ## TODO: do performance tests to select suitable cache size
    @cached(LRUCache(maxsize=100000), lock=RLock())
    def _stem(self, word):
        """The stem cache is used to cache up to 100,000 stemmed words.

        This substantially speeds up the word stemming on larger documents.
        """
        return self.__stemmer(word)

    def stem_term(self, term):
        """Apply the standard word procesing (eg stemming). Returns a stemmed ngram."""
        return ' '.join([self._stem(x) for x in term.split(' ')])

    def yield_keywords(self, raw_text, document=None):
        """Yield keyword objects as mono, di, tri... *-grams.

        Use this as an iterator.

        Will not create ngrams across logical sentence breaks.
        Example:
            s = "Although he saw the car, he ran across the street"
            the valid bigrams for the sentences are:
            ['Although he', 'saw the', 'he saw', 'the car',
            'he ran', 'across the', 'ran across', 'the street']
            "car he" is not a valid bi-gram

        This will also stem words when applicable.
        Example:
            s = "All the cars were honking their horns."
            ['all', 'the', 'car', 'were', 'honk', 'their', 'horn']
        """
        ## TODO: yield_method = self.slow_yield_keywords if not USE_SKLEARN_COUNTER else self.yield_sklearn_keywords
        if USE_SKLEARN_COUNTER:
            result = self.quick_yield_keywords(raw_text, document=document)
        else:
            result = self.full_yield_keywords(raw_text, document=document)
        return result

    def full_yield_keywords(self, raw_text, document=None):
        """Full-featured version of keyword generation, including support for offsets"""
        if sys.version_info[0] < 3:  # python2 support
            if isinstance(raw_text, str):
                raw_text = raw_text.decode('utf-8', 'ignore')
        ## TPO: HACK: support min ngram size
        gramlist = None
        if self.all_ngrams:
            gramlist = range(1, self.gramsize + 1)
        if self.min_ngram_size:
            debug.assertion(not gramlist)
            if gramlist:
                sys.stderr.write("Error: ignoring obsolete all_ngrams and using min_ngram_size\n")
            gramlist = range(self.min_ngram_size, self.gramsize + 1)
        if not gramlist:
            gramlist = [self.gramsize]
        ## DEBUG: sys.stderr.write("gramlist={gl}\n".format(gl=gramlist))
        debug.trace_fmt(8, "gramlist={gl}\n", gl=gramlist)

        for sentence in positional_splitter(self.negative_gram_breaks, raw_text):
            words = positional_splitter(WORD_REGEX, sentence.text)
            # Remove all stopwords
            words_no_stopwords = []
            for w in words:
                # Remove common contractions for stopwords when checking list
                check_me = re.sub(self.contractions, '', w.text)
                if check_me not in self.stopwords:
                    words_no_stopwords.append(w)

            # Make the ngrams
            # TODO: make sure stripped stopwords block ngram (e.g. "dog and cat" =/=> "dog cat")
            for gramsize in gramlist:
                # You need to try as many offsets as chunk size
                # TODO: Allow stopwords in middle of ngram of size 3 or more
                for offset in range(0, gramsize):  # number of words offset
                    data = words_no_stopwords[offset:]
                    text_in_chunks = [data[pos:pos + gramsize]
                                      for pos in range(0, len(data), gramsize)
                                      if len(data[pos:pos + gramsize]) == gramsize]
                    for word_list in text_in_chunks:
                        word_text = ' '.join([self.stem_term(w.text) for w in word_list])
                        if (SPLIT_WORDS or (not re.search(BAD_WORD_PUNCT_REGEX, word_text))):
                            word_global_start = sentence.start + word_list[0].start
                            word_global_end = sentence.start + word_list[-1].end
                            yield DocKeyword(word_text, document=document, start=word_global_start, end=word_global_end)
        return

    def quick_yield_keywords(self, raw_text, document=None):
        """Quick version for yielfing keywords, using sklearn for ngram generation
        Note: the DocKeyword objects don't include offset information"""
        # TODO1: support BAD_WORD_PUNCT_REGEX

        vectorizer = CountVectorizer(ngram_range=(self.min_ngram_size, self.gramsize))
        analyzer = vectorizer.build_analyzer()
        for ngram in analyzer(raw_text):
            yield DocKeyword(ngram, document=document)
        return


PositionalWord = namedtuple('PositionalWord', ['text', 'start', 'end'])

def positional_splitter(regex, text):
    r"""Yield sentence chunks (as defined by the regex) as well as their location.

    NOTE: the regex needs to be an "inverse match"
    Example:
        To split on whitespace, you match:
        r'\S+'  <-- "a chain of anything that's NOT whitespace"
    """
    for res in re.finditer(regex, text):
        ## TODO: drop try/except
        try:
            yield PositionalWord(res.group(0), res.start(), res.end())
        except StopIteration:
            pass
    return


def main():
    """Entry point for script: just runs a simple test"""
    text = "my man fran is not a man"
    p = Preprocessor(gramsize=2)
    debug.trace_object(4, p)
    ngrams = list([p.text for p in p.yield_keywords(text)])
    debug.trace_expr(3, text, ngrams)
    debug.assertion("my man" in ngrams)
    debug.assertion("my man fran" not in ngrams)
    debug.assertion("fran man" not in ngrams)
    
#-------------------------------------------------------------------------------
    
if __name__ == '__main__':
    system.print_stderr(f"Warning: {__file__} is not intended to be run standalone. A simple test will be run.")
    main()
