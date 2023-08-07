#! /usr/bin/env python
#
# gensim_test.py: Tests features of gensim document processing, such ad TF/IDF-based term vector
# representation and documented similarity computations. This takes as input a text file where each
# line represents a separate document.
#
# Notes:
# - gensim is short for 'generate similar' (see http://radimrehurek.com/gensim/about.html)
# - Based on http://radimrehurek.com/gensim/tut1.html.
# - This handles the conversion into gensim's vector representation from raw text.
# - See perform_lsa.py for script that performs latent semantic analsis using gensim.
# - The output dictionary is compressed by default (via bzip2) as with Gensim script
#   for wikipedia formatting.
# - See google_word2vec.py for script that supports term similarity instead of document similarity.
#
# TODO:
# - Use token quoting consistent with Gensim topic display (i.e., double).
# - Work around quirk requiring the model to be saved prior to similarity calculations.
# 

"""Interface into Gensim package for vector-based text analysis (e.g., document similarity)"""

# Standard packages
import argparse
import logging
from collections import OrderedDict
import os
import re
import sys
import tempfile

# Installed packages
from gensim import corpora, models, similarities

# Local packages
from mezcla import system
import mezcla.tpo_common as tpo
from mezcla import debug
import mezcla.glue_helpers as gh

# Environment options
# Note: These are for internal options not intended for end users (e.g., for default values).
# This also allows for defining options in one place rather than say 3+ for argparse.
# TODO: XYZ => DEFAULT_XYZ
MAX_SIMILAR = tpo.getenv_integer("MAX_SIMILAR", 10)
DOCID_FILENAME = tpo.getenv_value("DOCID_FILENAME", None)
# TODO: default to number of CPU's
PARALLEL_SHARDS = tpo.getenv_integer("PARALLEL_SHARDS", 1)
IN_MEMORY = tpo.getenv_bool("IN_MEMORY", False)
TEMP_BASE = tpo.getenv_text("TEMP_BASE", tempfile.NamedTemporaryFile().name)
#
# The following are for pruning dictionary
MIN_NUM_DOCS = tpo.getenv_integer("MIN_NUM_DOCS", None)
MAX_PCT_DOCS = tpo.getenv_number("MAX_PCT_DOCS", None)
MAX_NUM_TOKENS = tpo.getenv_integer("MAX_NUM_TOKENS", None)

#------------------------------------------------------------------------

class CorpusData(object):
    """Class for processing corpora with gensim (based on MyCorpus from gensim samples)"""
    # Note: Corpora can be too large for main memory, so designed around iterators.
    # TODO: Add option for using all available memory.
    # TODO: isolate class into separate module

    def __init__(self, text=None, directory=None, in_memory=None):
        """Constructor: initialize dictionary mapping for terms"""
        tpo.debug_print("CorpusData.__init__(%s)" % text, 6)
        # TODO: self.text => self.filename
        debug.assertion(not (text and directory))
        self.text = text        # file representing entire corpus: one line per document
        self.directory = directory      # directory with corpus files
        self.mm = None          # matrix market format (see http://math.nist.gov/MatrixMarket/formats.html)
        if in_memory is None:
            in_memory = IN_MEMORY
        self.in_memory = in_memory      # keep matrix in memory
        ## OLD:
        ## if (self.text):              # mapping from words to token IDs
        ##     self.dictionary = create_dictionary(self.text)
        self.dictionary = None
        if (self.text or self.directory):
            self.create_gensim_dictionary()
        return

    def load(self, basename):
        """Load corpus model and dictionary from disk using BASENAME"""
        tpo.debug_print("CorpusData.load(%s)" % basename, 6)
        ## OLD: assert(self.text is None)
        debug.assertion((self.text is None) and (self.directory is None))
        self.dictionary = corpora.Dictionary.load_from_text(basename + '.wordids.txt.bz2')
        # TODO: make sure the document index gets loaded (for random access)
        self.mm = corpora.MmCorpus(basename + '.bow.mm')
        tpo.trace_object(self.mm, 7, "mm")
        return

    ## TODO: convert save support from client code below
    ## def save(self):
    ##   ...
    
    def read_corpus_from_file(self, filename):
        """Interates through the corpus a document at a time based on lines in FILENAME (i.e., combined data file)"""
        debug.trace_fmt(5, "read_corpus_from_file([file={f}])", f=filename)
        # Notes: old-style input; this uses previously specified text unless overridden because 
        # the main representation for corpus is the matrix (i.e., self.mm).

        # Use previous contents if not specified
        if filename is not None:
            self.text = filename
            self.directory = None

        # Read each logical file returning entire lowercased contents
        for line in system.open_file(self.text):
            # note: assumes there's one document per line with tokens separated by whitespace
            file_tokenized = re.split(r"\W+", line.lower())
            debug.trace_fmt(6, "yielding tokens: len={l}", l=len(file_tokenized))
            ## BAD: yield self.dictionary.doc2bow(file_tokenized, allow_update=update_dict)
            yield file_tokenized
        return

    def read_corpus_from_directory(self, filename):
        """Iterates through the corpus a document at a time using files in directory FILENAME. 
        Note: the files are added in lexicographical order"""
        debug.trace_fmt(5, "read_corpus_from_directory([dir={d}])", d=filename)
        # Notes: As with read_corpus_from_file, the directory name is reused in later calls.
        # Each individual file is assumed to fit in memory.

        # Use previous directory if not specified
        if filename is not None:
            self.directory = filename
            self.text = None
            
        # Read each physical file returning entire lowercased contents
        # TODO: use new system.get_directory_filenames()
        for dir_filename in sorted(system.read_directory(self.directory)):
            full_path = gh.form_path(self.directory, dir_filename)
            if not system.is_directory(full_path):
                file_tokenized = re.split(r"\W+", system.read_entire_file(full_path).lower())
                debug.trace_fmt(6, "yielding tokens: len={l}", l=len(file_tokenized))
                ## BAD: yield self.dictionary.doc2bow(file_tokenized, allow_update=update_dict)
                yield file_tokenized
        return

    def read_corpus_files(self):
        """Read corpus either from single file or directory"""
        debug.trace(5, "read_corpus_files()")
        file_arg = self.directory if self.directory else self.text
        corpus_input_fn = self.read_corpus_from_directory if self.directory else self.read_corpus_from_file
        for i, file_contents in enumerate(corpus_input_fn(file_arg)):
            ## BAD: debug.trace_fmt(6, "file contents {n}: {contents}", n=(i + 1), contents=gh.elide(file_contents))
            debug.trace_fmt(6, "yielding baw of words for file {n}: len={l}", n=(i + 1), l=len(file_contents))
            yield file_contents
        return

    def create_gensim_dictionary(self):
        """Create dictionary with word mappings and frequencies from input source (see read_corpus_files)"""
        # Note: The vectors are only retained if in-memory usage.
        # This is just done for the side effect (see gensim's dictionary.py).
        debug.trace(5, "create_gensim_dictionary()")
        self.dictionary = corpora.Dictionary()
        if self.in_memory:
            self.mm = []
        for file_contents in self.read_corpus_files():
            vector = self.dictionary.doc2bow(file_contents, allow_update=True)
            if self.in_memory:
                self.mm.append(vector)
        return
    
    def __iter__(self):
        """Returns iterator over vectors in corpus"""
        ## OLD: """Returns iterator over vectors in corpus or over lines in input text"""
        tpo.debug_print("CorpusData.__iter__()", 6)
        if (self.mm):
            for vector in self.mm.__iter__():
                yield vector
        else:
            debug.trace(4, "Warning: re-reading corpus for iter--use load() so that mm defined.")
            for file_contents in self.read_corpus_files():
                yield self.dictionary.doc2bow(file_contents, allow_update=False)
        return

    def __len__(self):
        """Returns number of documents in corpus"""
        ## OLD: num_docs = len(self.mm) if self.mm else self.text_length()
        num_docs = -1
        if (self.mm):
            num_docs = len(self.mm)
        else:
            debug.trace(4, "Warning: re-reading corpus for len--use load() so that mm defined.")
            num_docs = self.text_length()
        tpo.debug_print("CorpusData.__len__() => %d" % num_docs, 7)
        return (num_docs)

    def text_length(self):
        """Returns number of documents in corpus (n.b., re-reads the corpus data)
        Note: Result is number of lines in self.text or number of regular files in self.directory."""
        ## OLD: """Returns number of documents (i.e., lines) in text"""
        length = 0
        ## OLD: for _line in open(self.text):
        for _line in self.read_corpus_files():
            length += 1
        tpo.debug_print("CorpusData.text_length() => %d" % length, 7)
        return (length)

    def __getitem__(self, index):
        """Returns corpus item at INDEX (0-based)"""
        result = None
        try:
            result = self.mm[index]
        except RuntimeError:
            tpo.print_stderr("Warning: falling back to linear document access (i.e., not random access): make sure index file exists")
            result = None
            for i, value in enumerate(self.mm):
                if (i == index):
                    result = value
                    break
        return (result)

#------------------------------------------------------------------------

class UserIdMapping(object):
    """Class for mapping Gensim document ID's into user ID's"""

    def __init__(self, docid_filename):
        """Class constructor"""
        ## OLD: self.docid_mapping = tpo.create_lookup_table(docid_filename, use_linenum=True)
        self.docid_mapping = create_ordered_lookup_table(docid_filename)
        # TODO: just use array indexing (e.g., doc_positions = docid_mapping.values())
        ## OLD: self.reverse_docid_mapping = dict((docid, key) for (key, docid) in list(self.docid_mapping.items()))
        self.reverse_docid_mapping = dict((label, docid) for (docid, label) in list(self.docid_mapping.items()))
        return

    def get_user_id(self, docid):
        """Returns user ID for DOCID (same as input if no mapping exists)"""
        # Note: user_id is user's ID for document (not gensim's)
        if (not isinstance(docid, str)):
            docid = str(docid)
        user_id = self.docid_mapping.get(docid, docid)
        gh.assertion(user_id != docid)
        ## OLD: tpo.debug_format("get_user_id({docid}) => {user_id}", 6)
        debug.trace_fmt(6, "get_user_id({d}) => {u}", d=docid, u=user_id)
        return user_id

    def get_gensim_id(self, docid):
        """Returns gensim ID for DOCID (same as input if no mapping exists)"""
        if (not isinstance(docid, str)):
            docid = str(docid)
        gensim_id = self.reverse_docid_mapping.get(docid, docid)
        gh.assertion(gensim_id != docid)
        ## OLD: tpo.debug_format("get_gensim_id({docid}) => {gensim_id}", 6)
        debug.trace_fmt(6, "get_gensim_id({d}) => {g}", d=docid, g=gensim_id)
        return gensim_id

#------------------------------------------------------------------------

class SimilarDocument(object):
    """Base class for finding similar documents via vector-space cosine measure"""
    # TODO: rework so that CorpusData class used to encapsulate both corpus and dictionary

    def __init__(self, corpus=None, dictionary=None, verbose_output=False, max_similar=MAX_SIMILAR, docid_filename=DOCID_FILENAME):
        """Class constructor"""
        ## OLD: tpo.debug_format("SimilarDocument.__init__({corpus}, {dictionary}, {verbose_output}, {max_similar}, {docid_filename})", 6)
        debug.trace_fmt(6, "SimilarDocument.__init__({c}, {d}, {v}, {ms}, {df})", c=corpus, d=dictionary, v=verbose_output, ms=max_similar, df=docid_filename)
        # If specified, override the number of CPUs for parallel processing of shards
        if (PARALLEL_SHARDS > 1):
            similarities.docsim.PARALLEL_SHARDS = PARALLEL_SHARDS
        self.corpus = corpus
        self.dictionary = dictionary
        self.sim_index = None
        if self.corpus:
            ## OLD: gh.assertion(isinstance(self.corpus, corpora.MmCorpus))
            gh.assertion(isinstance(self.corpus, corpora.MmCorpus) or all_lists_of_num_pairs(self.corpus))
        if self.dictionary:
            gh.assertion(isinstance(self.dictionary, corpora.Dictionary))
        self.verbose_output = verbose_output
        self.max_similar = max_similar
        self.docid_mapping = UserIdMapping(docid_filename) if docid_filename else None
        return

    def get_user_id(self, docid):
        """Returns user ID for DOCID (same as input if no mapping exists)"""
        return (self.docid_mapping.get_user_id(docid) if self.docid_mapping else docid)

    def get_gensim_id(self, docid):
        """Returns gensim ID for DOCID (same as input if no mapping exists)"""
        return (self.docid_mapping.get_gensim_id(docid) if self.docid_mapping else docid)

    def find(self, _docid):
        """"Return documents similar to DOCID; result is a list of tuples: (docid, weight)"""
        tpo.debug_format("SimilarDocument.find({d}); self={s}", 6,
                         d=_docid, s=self)
        assert(False)
        return []

    def find_all_similar(self):
        """Iterator for getting list of similar documents for each document: each result is a tuple (docid, similar-doc-list), with similar-doc-list a list of (other-docid, weight) tuples"""
        tpo.debug_print("SimilarDocument.find_all_similar", 5)
        for docid in range(len(self.corpus)):
            yield(docid, self.find(docid))
        return

    def load(self, filename):
        """Loads similarity model from FILENAME"""
        # Note: for interactive usage only
        tpo.debug_print("Loading similiarity index from FILENAME", 4)
        self.sim_index = similarities.Similarity.load(filename)
        return

    def save(self, filename):
        """Saves similarity model to FILENAME"""
        ## OLD: tpo.debug_format("Saving similiarity index to {filename}", 4)
        debug.trace_fmt(4, "Saving similiarity index to {f}", f=filename)
        return (self.sim_index.save(filename))


class SimilarDocumentByCosine(SimilarDocument):
    """Class for finding similar documents via vector-space cosine measure"""

    def __init__(self, corpus=None, dictionary=None, index_file=None, verbose_output=False, max_similar=MAX_SIMILAR, docid_filename=DOCID_FILENAME):
        """Class constructor"""
        ## OLD: tpo.debug_format("SimilarDocumentByCosine.__init__({corpus}, {dictionary}, {index_file}, {verbose_output}, {max_similar}, {docid_filename})", 6)
        debug.trace_fmt(6, "SimilarDocumentByCosine.__init__(corp={c}, dict={d}, indf={f}, verb={v}, maxsim={ms}, docfil={df})", c=corpus, d=dictionary, f=index_file, v=verbose_output, ms=max_similar, df=docid_filename)
        # note: index_file serves both as the cache for the similarity object as well as base name for the shards it uses (see gensim's docsim.py)
        # TODO: rework so that corpus and dictionary not needed to retrieve pre-computed similarity results
        SimilarDocument.__init__(self, corpus, dictionary, verbose_output, max_similar, docid_filename)
        ## BAD: if (self.corpus and self.dictionary):
        if ((self.corpus is not None) and (self.dictionary is not None)):
            if index_file is None:
                index_file = TEMP_BASE + "-simindex"
            if (gh.non_empty_file(index_file)):
                self.sim_index = similarities.Similarity.load(index_file)
                # Make sure shard file prefix matches index file
                if self.sim_index.output_prefix != index_file:
                    tpo.debug_format("Updating shard file prefix: {self.sim_index.output_prefix} => {index_file}", 5)
                    self.sim_index.output_prefix = index_file
                    self.sim_index.check_moved()
            else:
                self.sim_index = similarities.Similarity(index_file, self.corpus, len(self.dictionary), max_similar)
            tpo.debug_print("sim_index: type=%s value=%s" % (type(self.sim_index), self.sim_index), 5)
        else:
            ## OLD: tpo.debug_format("c={self.corpus} d={self.dictionary} sim_index={self.sim_index}", 6)
            debug.trace_fmt(5, "c={c} d={d} sim_index={i}", c=self.corpus, d=self.dictionary, i=self.sim_index)
        tpo.trace_object(self, 5, "SimilarDocumentByCosine.self")
        return

    def normalize_score(self, score):
        """Normalized from cosine value in range [-1, 1] to probability-type score in range [0, 1])"""
        # pylint: disable=no-self-use
        MIN_SCORE = -1.0
        MAX_SCORE = 1.0
        EPSILON = 0.001
        gh.assertion(MIN_SCORE-EPSILON <= score <= MAX_SCORE+EPSILON)
        debug.assertion(MIN_SCORE < MAX_SCORE)
        normal_score = (float(score - MIN_SCORE) / (MAX_SCORE - MIN_SCORE))
        ## tpo.debug_format("SimilarDocumentByCosine.normalize_score({score}) => {normal_score}", 6)
        debug.trace_fmt(6, "SimilarDocumentByCosine.normalize_score({s}) => {ns}",
                        s=score, ns=normal_score)
        return (normal_score)

    def find(self, docid):
        """"Return documents similar to DOCID; result is a list of tuples: (docid, weight)"""
        ## tpo.debug_format("SimilarDocumentByCosine.find({docid})", 5)
        debug.trace_fmt(5, "SimilarDocumentByCosine.find({d})", d=docid)
        debug.trace_fmt(5, "corpus/dict/index={c}/{d}/{i}", c=self.corpus, d=self.dictionary, i=self.sim_index)
        gh.assertion(self.corpus and self.dictionary and self.sim_index)
        ## OLD: gensim_docid = self.get_gensim_id(docid)
        gensim_docid = docid
        try:
            similar_gensim_docs = self.sim_index[self.corpus[int(gensim_docid)]]
            similar_docs = [(self.get_user_id(doc), self.normalize_score(score)) for (doc, score) in similar_gensim_docs]
            if self.verbose_output:
                similar_docs = [(docid, score, resolve_terms(docid, self.dictionary)) for (docid, score) in similar_docs]
        except:
            tpo.debug_raise()
            tpo.print_stderr("Exception retrieving similar documents: " + str(sys.exc_info()))
            similar_docs = []
        result = similar_docs
        ## OLD: tpo.debug_format("find({docid}) => {result}", 5)
        debug.trace_fmt(5, "find({d}) => {r}", d=docid, r=result)
        return result

    def derive_all_similarities(self):
        """Precompute similarities, using batch method via chunking (see Gensim documentation in docsim.py)."""
        tpo.debug_format("SimilarDocumentByCosine.derive_all_similarities()", 5)
        _all_sim = list(self.sim_index[self.corpus])
        return

#------------------------------------------------------------------------

def create_dictionary(filename):
    """Create dictionary with mord mappings and frequencies from FILENAME with each line representing a separate document"""
    # Note: Updates the dictionary for each line (to allow for very large corpora files).
    tpo.debug_print("create_dictionary(%s)" % filename, 5)
    dictionary = corpora.Dictionary()
    ## OLD: for line in open(filename):
    for line in system.open_file(filename):
        ## OLD: line_tokenized = [w for w in re.split(r"\W+", line)]
        line_tokenized = re.split(r"\W+", line)
        dictionary.doc2bow(line_tokenized, allow_update=True)
    return (dictionary)


def create_ordered_lookup_table(filename):
    """Create lookup hash table from 0-based line number as string to labels specified in FILENAME
    Note: case is preserved but leading and trailing whitespace is removed"""
    tpo.debug_print("create_ordered_lookup_table(%s)" % filename, 5)
    lookup_hash = OrderedDict()
    f = None
    try:
        f = system.open_file(filename)
        line_num = 0
        for line in f:
            lookup_hash[str(line_num)] = line.strip()
            line_num += 1
    except (IOError, ValueError):
        tpo.debug_print("Warning: Exception creating lookup table from %s: %s" % (filename, str(sys.exc_info())), 2)
    finally:
        if f:
            f.close()
    tpo.debug_print("create_ordered_lookup_table() => %s" % lookup_hash, 6)
    return lookup_hash


def resolve_terms(vector, dictionary):
    """Return vector with token ID's replaced by the actual tokens"""
    tpo.debug_print("resolve_terms(%s, %s)" % (vector, dictionary), 7)
    term_vector = [(dictionary[token_id], count) for (token_id, count) in vector]
    ## OLD: return sorted(term_vector, reverse=True, key=lambda _term, freq: freq)
    return sorted(term_vector, reverse=True, key=lambda t_f: t_f[1])


def all_num_pairs(l):
    """Whether L is list of tuples (n1, n2)"""
    result = (isinstance(l, list)
              and all(map(lambda t: (len(t) == 2) and tpo.is_numeric(t[0]) and tpo.is_numeric(t[1]),
                          l)))
    debug.trace_fmt(7, "all_num_pairs({v}) => {r}", v=gh.elide(str(l)), r=result)
    return result


def all_lists_of_num_pairs(l):
    """Whether each item in L is a list of numeric tuples"""
    result = isinstance(l, list) and all(map(all_num_pairs, l))
    debug.trace_fmt(6, "all_lists_of_num_pairs({v}) => {r}", v=gh.elide(str(l)), r=result)
    return result

#-------------------------------------------------------------------------------

def main(runtime_args=None):
    """Entry point for script"""
    # Note: Uses sys.argv if no arguments supplied
    ## OLD: tpo.debug_print("main(): args=%s" % sys.argv, 4)
    debug.trace_fmt(5, "main(): args=[{ra}]", ra=runtime_args)
    ## TODO
    ## if (runtime_args is None):
    ##     runtime_args = sys.argv
    ##     debug.trace_fmt(4, "Using sys.argv for args: {ra}", ra=runtime_args)
    if (runtime_args is not None):
        debug.trace_fmt(2, "Warning: Setting sys.argv from args: {ra}", ra=runtime_args)

    # Check command-line arguments
    # TODO: make sure each argument supported via external API
    parser = argparse.ArgumentParser(description="Creates gensim corpus files optionally with TF/IDF weighting (for use with perform_lsa.py. Note: input should be a text file when creating from scratch or the basename of model files if loading existing model(s).")
    #
    parser.add_argument("--save", default=False, action='store_true', help="Save model(s) to disk")
    parser.add_argument("--load", default=False, action='store_true', help="Load model(s) from disk")
    parser.add_argument("--tfidf", default=False, action='store_true', help="Include TF/IDF analysis")
    parser.add_argument("--original", default=False, action='store_true', help="Output original document term matrix (i.e., non-tfidf) when --tfidf specified")
    parser.add_argument("--similarity", default=False, action='store_true', help="Derive similarity data")
    parser.add_argument("--print", default=False, action='store_true', help="Print vectors on standard output")
    parser.add_argument("--expand", default=False, action='store_true', help="Expand corpus in memory")
    parser.add_argument("--verbose", default=False, action='store_true', help="Verbose output mode (e.g., resolve term ID's)")
    parser.add_argument("--normalize", default=True, action='store_true', help="Normalize TF/IDF scores")
    parser.add_argument("--skip-normalize", dest='normalize', action='store_false', help="Normalize TF/IDF scores")
    parser.add_argument("--similar-docs-of", default="", help="Show similar documents for list of document ID's (or * for all); note: currently requires --load")
    parser.add_argument("--max-similar", type=int, default=MAX_SIMILAR, help="Maximum number of similar documents to return")
    parser.add_argument("--output-basename", default="", help="Basename to use for output (by default input file without .txt extension)")
    parser.add_argument("--docid-filename", default=None, help="Filename with document ID's")
    parser.add_argument("--prune-dictionary", default=False, action='store_true', help="Prune dictionary of low/high frequency terms")
    #
    # note: filename is positional argument
    parser.add_argument("filename", default=None, help="Input data filename (or basename when loading previously saved model); use - for stdin")
    #
    ## OLD: args = vars(parser.parse_args())
    args = vars(parser.parse_args(runtime_args))
    tpo.debug_print("args = %s" % args, 5)
    filename = args['filename']
    save = args['save']
    load = args['load']
    perform_tfidf = args['tfidf']
    verbose_output = args['verbose']
    normalize = args['normalize']
    print_vectors = args['print']
    show_original = (args['original'] or (print_vectors and (not perform_tfidf)))
    expand_corpus = args['expand']
    derive_similarity = args['similarity']
    max_similar = args['max_similar']
    source_similar_docs = args['similar_docs_of'].replace(",", " ").split()
    output_basename = args['output_basename']
    docid_filename = args['docid_filename']
    prune_dictionary = args['prune_dictionary']
    temp_file = None

    # Map stdin to temporary file
    # TODO: rework in terms of streaming (e.g., for files > 4gb)
    if (filename == "-"):
        tpo.debug_print("Reading input from stdin", 4)
        ## OLD:
        ## temp_file = tpo.getenv_text("TEMP_FILE", tempfile.NamedTemporaryFile().name)
        temp_file = TEMP_BASE
        filename = temp_file + ".txt"
        gh.write_file(filename, gh.read_file(None))

    # Derive the basename if not given
    # TODO: TFIDF_MODEL_EXT = ".tfidf.mm"
    matrix_ext = ".tfidf.mm" if perform_tfidf else ".bow.mm"
    input_extension = ".txt" if (not load) else matrix_ext
    if not output_basename:
        output_basename = gh.remove_extension(filename, input_extension)
    tpo.debug_print("output_basename=%s" % output_basename, 5)

    # Make sure input file exists
    if (not os.path.exists(filename)) and (not load):
        if (os.path.exists(filename + input_extension)):
            filename += input_extension

    # Enable logging if debugging
    # TODO: tpo.init_logging()
    if (tpo.debugging_level()):
        # TODO: use mapping from symbolic LEVEL user option (e.g., via getenv)
        level = logging.INFO if (tpo.debug_level < 4) else logging.DEBUG
        logging.basicConfig(format='%(asctime)s : %(levelname)s : %(message)s', level=level)

    # Read in corpus, optionally in saved vector format
    # TODO: put load/save support into CorpusData (and isolate as gensim_corpus.py)
    # TODO: bypass loading if TF/IDF version of corpus is being used for document similarity
    if load:
        corpus_basename = tpo.getenv_text("CORPUS_BASENAME", filename)
        corpus_data = CorpusData()
        corpus_data.load(corpus_basename)
    else:
        ## OLD: corpus_data = CorpusData(filename)
        is_dir = system.is_directory(filename)
        corpus_data = CorpusData(directory=filename) if is_dir else CorpusData(text=filename)
    tpo.debug_print("corpus_data: type=%s value=%s" % (type(corpus_data), corpus_data), 5)
    debug.trace_object(5, corpus_data)

    # Optionally prune low and high frequency terms from dictionary
    if (prune_dictionary or MIN_NUM_DOCS or MAX_PCT_DOCS or MAX_NUM_TOKENS):
        tpo.debug_print("Pruning dictionary", 4)
        option_overrides = {}
        if MIN_NUM_DOCS:
            option_overrides['no_below'] = MIN_NUM_DOCS
        if MAX_PCT_DOCS:
            option_overrides['no_above'] = MAX_PCT_DOCS
        if MAX_NUM_TOKENS:
            option_overrides['keep_n'] = MAX_NUM_TOKENS
        corpus_data.dictionary.filter_extremes(**option_overrides)

    # Print the corpus
    if (print_vectors and show_original):
        print("corpus_data: [")
        for docid, vector in enumerate(corpus_data):
            print(docid, vector if not verbose_output else resolve_terms(vector, corpus_data.dictionary))
        print("]")

    # Do optional TF/IDF analysis
    # Note: tfidf represents the transformation and tfidf_corpus the transformed corpus
    # See http://radimrehurek.com/gensim/tut2.html#transformation-interface.
    # TODO: put TFIDF support into CorpusData class
    if (perform_tfidf):
        tpo.debug_print("TF/IDF", 6)
        if load:
            tfidf_corpus = corpora.MmCorpus(output_basename + '.tfidf.mm')
        else:
            mm = list(corpus_data) if expand_corpus else corpus_data
            ## TODO: mm = corpora.MmCorpus(output_basename + '.bow.mm')
            tfidf = models.TfidfModel(mm, id2word=corpus_data.dictionary, normalize=normalize)
            tfidf_corpus = tfidf[corpus_data]
        ## TODO: tfidf = models.TfidfModel(corpus_data)
        tpo.debug_print("tfidf: type=%s value=%s" % (type(tfidf_corpus), tfidf_corpus), 5)

        # Print the TF/IDF version of the corpus
        if (print_vectors):
            print("tfidf corpus: [")
            for docid, vector in enumerate(tfidf_corpus):
                print(docid, vector if not verbose_output else resolve_terms(vector, corpus_data.dictionary))
            print("]")

    # Determine similarity model
    if (derive_similarity or source_similar_docs):
        assert load, "similarity support requires --load (to use Matrix Market format produced by --save)"
        sim_corpus = tfidf_corpus if perform_tfidf else corpus_data.mm
        dictionary = corpus_data.dictionary
        index_filename = tpo.getenv_text("SIM_INDEX", output_basename + ".sim_index")
        sim = SimilarDocumentByCosine(corpus=sim_corpus, dictionary=dictionary, index_file=index_filename, verbose_output=verbose_output, max_similar=max_similar, docid_filename=docid_filename)
        # Precompute similarities
        if not source_similar_docs:
            sim.derive_all_similarities()

    # Show similar documents
    # TODO: have option to save as data file
    if source_similar_docs:
        if (source_similar_docs == ['*']):
            similar_doc_info = sim.find_all_similar()
        else:
            similar_doc_info = []
            for docid in source_similar_docs:
                similar_doc_info.append((docid, sim.find(docid)))
                ## TODO: 
                ## user_docid = sim.get_user_id(docid)
                ## similar_doc_info.append((user_docid, sim.find(docid)))
        if tpo.verbose_debugging():
            similar_doc_info = list(similar_doc_info)
            ## OLD: tpo.debug_format("similar_doc_info={similar_doc_info}")
            debug.trace_fmt(4, "similar_doc_info={sdi}", sdi=similar_doc_info)
        for (docid, similar_docs) in similar_doc_info:
            similar_docs = [(d, tpo.round_num(score)) for (d, score) in similar_docs]
            ## OLD: print("Documents similar to %s: %s" % (docid, similar_docs))
            ## TODO: remove source docid's (i.e., no identity matches)
            user_docid = sim.get_user_id(docid)
            other_similar_docs = [(d, s) for (d, s) in similar_docs if (d != user_docid)]
            print("Documents similar to %s: %s" % (user_docid, other_similar_docs))
            ## TODO: show overlapping terms in verbose mode

    # Optionally save main components to disk
    if (save):
        # TODO: have corpus data save both the dictionary and the matrix
        tpo.debug_print("saving corpora files", 6)
        if ((not load) or (not gh.non_empty_file(output_basename + '.wordids.txt.bz2'))):
            corpus_data.dictionary.save_as_text(output_basename + '.wordids.txt.bz2')
        if ((not load) or (not gh.non_empty_file(output_basename + '.bow.mm'))):
            mm = list(corpus_data) if expand_corpus else corpus_data
            corpora.MmCorpus.serialize(output_basename + '.bow.mm', mm)
        if (perform_tfidf):
            if ((not load) or (not gh.non_empty_file(output_basename + '.tfidf.mm'))):
                corpora.MmCorpus.serialize(output_basename + '.tfidf.mm', tfidf_corpus)
        if (derive_similarity):
            sim.save(output_basename + '.sim_index')

    # Cleanup
    if (temp_file and (not tpo.detailed_debugging())):
        ## OLD: gh.run("rm -vf {temp_file}")
        gh.run("rm -vf {temp_file}*")

    return

#------------------------------------------------------------------------

if __name__ == '__main__':
    ## OLD:
    main()
    ## TODO: main(sys.argv)

## TEST (for testing tests/test_gensim_test.py conditional loading):
## fubar
