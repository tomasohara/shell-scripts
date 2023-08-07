#! /usr/bin/env python
#
# text_processing.py: performs text processing (e.g., via NLTK), mainly for
# word tokenization and part-of-speech tagging. To make the part-of-speech
# output easier to digrest, there is an envionment option USE_CLASS_TAGS
# to enable use of class-based tags, such as those used in traditional 
# grammar (e.g., noun for NNS).
# 
#
# Notes:
# - function resulting caching ("memoization") is used via memodict decoration
# - environment variables (env-var) are used for some adhoc options
# - to bypass NLTK (e.g., for quick debugging), set SKIP_NLTK env-var to 0
#
#------------------------------------------------------------------------
# Miscelleneous notes
#
# Penn Tags (used by NLTK part-of-speech tagger)
# 
# CC    Coordinating conjunction
# CD    Cardinal number
# DT    Determiner
# EX    Existential there
# FW    Foreign word
# IN    Preposition or subordinating conjunction
# JJ    Adjective
# JJR   Adjective, comparative
# JJS   Adjective, superlative
# LS    List item marker
# MD    Modal
# NN    Noun, singular or mass
# NNS   Noun, plural
# NNP   Proper noun, singular
# NNPS  Proper noun, plural
# PDT   Predeterminer
# POS   Possessive ending
# PP    Personal pronoun
# PP$   Possessive pronoun ???
# PRP$  Possessive pronoun
# PRP   Personal pronoun
# RB    Adverb
# RBR   Adverb, comparative
# RBS   Adverb, superlative
# RP    Particle
# SYM   Symbol
# TO    to
# UH    Interjection
# VB    Verb, base form
# VBD   Verb, past tense
# VBG   Verb, gerund or present participle
# VBN   Verb, past participle
# VBP   Verb, non-3rd person singular present
# VBZ   Verb, 3rd person singular present
# WDT   Wh-determiner
# WP    Wh-pronoun
# WP$   Possessive wh-pronoun
# WRB   Wh-adverb
#
# See ftp://ftp.cis.upenn.edu/pub/treebank/doc/tagguide.ps.gz for more details.
#------------------------------------------------------------------------
# TODO:
# - Integrate punctuation isolation (see prep_brill.perl).
# - Add usage examples (e.g., part-of-speech tagging).
# - Warn that without NLTK or Enchant, the text processing just checks common cases.
#

"""Performs text processing (e.g., tokenization via NLTK)"""

# Standard packages
import sys                              # system interface (e.g., command line)
import re                               # regular expressions

# Installed packages
# TODO

# Local packages
## TODO: from mezcla import debug
from mezcla import system
from mezcla import glue_helpers as gh
from mezcla import tpo_common as tpo

#------------------------------------------------------------------------
# Globals

# Object for spell checking via enchant
speller = None
word_freq_hash = None
WORD_FREQ_FILE = tpo.getenv_text("WORD_FREQ_FILE", "word.freq")

# Hash for returning most common part of speech for a word (or token)
word_POS_hash = None
WORD_POS_FREQ_FILE = tpo.getenv_text("WORD_POS_FREQ_FILE", "word-POS.freq")

# Misc. options
LINE_MODE = tpo.getenv_boolean("LINE_MODE", False, "Process text line by line (not all all once)")
JUST_TAGS = tpo.getenv_boolean("JUST_TAGS", False, "Just show part of speech tags (not word/POS pair)")
OUTPUT_DELIM = tpo.getenv_text("OUTPUT_DELIM", " ", "Delimiter (separator) for output lists")
INCLUDE_MISSPELLINGS = tpo.getenv_boolean("INCLUDE_MISSPELLINGS", False, "Include spell checking")
SKIP_MISSPELLINGS = tpo.getenv_boolean("SKIP_MISSPELLINGS", not INCLUDE_MISSPELLINGS, "Skip spell checking")
SHOW_MISSPELLINGS = not SKIP_MISSPELLINGS
USE_CLASS_TAGS = tpo.getenv_boolean("USE_CLASS_TAGS", False, "Use class-based tags (e.g., Noun for NNP)")
SKIP_CLASS_TAGS = not USE_CLASS_TAGS
KEEP_PUNCT = tpo.getenv_boolean("KEEP_PUNCT", False, "Use punctuation symbol as part-of-speech label")
TERSE_OUTPUT = tpo.getenv_boolean("TERSE_OUTPUT", JUST_TAGS, "Terse output mode")
VERBOSE = not TERSE_OUTPUT

# Skip use of NLTK and/or ENCHANT packages (using simple versions of functions)
# TODO: make misspellings optional (add --classic mode???)
SKIP_NLTK = tpo.getenv_boolean("SKIP_NLTK", False, "Omit usage of Natural Language Toolkit (NLTK)")
SKIP_ENCHANT = tpo.getenv_boolean("SKIP_ENCHANT", SKIP_MISSPELLINGS, "Omit usage of Enchant package for spell checking")
DOWNLOAD_DATA = system.getenv_bool("DOWNLOAD_DATA", False,
                                   "Download data from NLTK")

# List of stopwords (e.g., high-freqency function words)
stopwords = None

#------------------------------------------------------------------------
# Optional libraries

# NLP toolkit
if not SKIP_NLTK:
    import nltk            # pylint: disable=ungrouped-imports
    if DOWNLOAD_DATA:
        ## TODO: nltk.download('all')
        nltk.download(['punkt', 'averaged_perceptron_tagger'])
# spell checking
if not SKIP_ENCHANT:
    import enchant         # pylint: disable=ungrouped-imports

#------------------------------------------------------------------------
# Functions

def split_sentences(text):
    """Splits TEXT into sentences"""
    # EX: split_sentences("I came. I saw. I conquered!") => ["I came.", "I saw.", "I conquered!"]
    # EX: split_sentences("Dr. Watson, it's elementary. But why?") => ["Dr. Watson, it's elementary.", "But why?"]
    if SKIP_NLTK:
        # Split around sentence-ending punctuation followed by space,
        # but excluding initials (TODO handle abbreviations (e.g., "mo.")
        #
        # TEST: Replace tabs with space and newlines with two spaces
        ## text = re.sub(r"\t", " ", text)
        ## text = re.sub(r"\n", "  ", text)
        # 
        # Make sure ending punctuaion followed by two spaces and preceded by one
        text = re.sub(r"([\.\!\?])\s", r" \1  ", text)
        #
        # Remove spacing added above after likely abbreviations
        text = re.sub(r"\b([A-Z][a-z]*)\s\.\s\s", r"\1. ", text)
        #
        # Split sentences by ending punctuation followed by two spaces
        # Note: uses a "positive lookbehind assertion" (i.e., (?<=...) to retain punctuation 
        sentences = re.split(r"(?<=[\.\!\?])\s\s+", text.strip())
    else:
        sentences = nltk.tokenize.sent_tokenize(text)
    return sentences


def split_word_tokens(text):
    """Splits TEXT into word tokens (i.e., words, punctuation, etc.) Note: run split_sentences first (e.g., to allow for proper handling of periods).
    By default, this uses NLTK's PunktSentenceTokenizer."""
    # EX: split_word_tokens("How now, brown cow?") => ['How', 'now', ',', 'brown', 'cow', '?']
    tpo.debug_print("split_word_tokens(%s); type=%s" % (text, type(text)), 7)
    if SKIP_NLTK:
        tokens = [t.strip() for t in re.split(r"(\W+)", text) if (len(t.strip()) > 0)]
    else:
        tokens = nltk.word_tokenize(text)
    tpo.debug_print("tokens: %s" % [(t, type(t)) for t in tokens], 7)
    return tokens


def label_for_tag(POS, word=None):
    """Returns part-of-speech label for POS, optionally overriden based on WORD (e.g., original token if punctuation)"""
    label = POS
    if KEEP_PUNCT and word and re.match(r"\W", word[0]):
        label = word
        tpo.debug_format("label_for_tag({t}, {w}) => {l}", 5, t=POS, w=word, l=label)
    return label


fallback_POS_class = {  # classes for parts-of-speech not covered by rules (see class_for_tag)
    "CC": "conjunction",        # Coordinating conjunction
    "CD": "number",             # Cardinal number
    "DT": "determiner",         # Determiner
    "EX": "pronoun",            # Existential there
    "FW": "noun",               # Foreign word
    "IN": "preposition",        # Preposition or subordinating conjunction
    "JJ": "adjective",          # Adjective
    "JJR": "adjective",         # Adjective, comparative
    "JJS": "adjective",         # Adjective, superlative
    "LS": "punctuation",        # List item marker
    "MD": "auxiliary",          # Modal
    "PDT": "determiner",        # Predeterminer
    "POS": "punctuation",       # Possessive ending
    "SYM": "punctuation",       # Symbol
    "TO": "preposition",        # to
    "UH": "punctuation",        # Interjection
    "WDT": "determiner",        # Wh-determiner
    "WP": "pronoun",            # Wh-pronoun
    "WP$": "pronoun",           # Possessive wh-pronoun
    "WRB": "adverb",            # Wh-adverb
}


def class_for_tag(POS, word=None, previous=None):
    """Returns class label for POS tag, optionally over WORD and for PREVIOUS tag. Note: most cases are resolved without previous tag for context, except for gerunds and past participles which are considered nouns unless previous is auxiliary. Similarly, the word is only considered for special cases like punctuation."""
    # EX: class_for_tag("NNS") => "noun"
    # EX: class_for_tag("VBG") => "verb"
    # EX: class_for_tag("VBG", previous="MD") => "verb"
    # EX: class_for_tag("NNP", word="(") => "punctuation"
    tag_class = "unknown"
    if (POS == "VBG") and previous and ((previous[:2] == "VB") or (previous == "MD")):
        tag_class = "verb"
    elif (POS == "VBP") and previous and ((previous[:2] == "VB") or (previous == "MD")):
        tag_class = "verb"
    elif word and re.match(r"\W", word[0]):
        tag_class = "punctuation"
    # TODO: use prefix-based lookup table for rest (e.g., {"NN": "noun", ...})?
    elif POS[:2] == "NN":
        tag_class = "noun"
    elif POS[:2] == "JJ":
        tag_class = "adjective"
    elif POS[:2] == "VB":
        tag_class = "verb"
    elif POS[:2] == "RB":
        tag_class = "adverb"
    elif (POS[:2] == "PR") or (POS[:2] == "PP"):
        tag_class = "pronoun"
    else:
        tag_class = fallback_POS_class.get(POS, tag_class)
    tpo.debug_format("class_for_tag({t}, {p}) => {c}", 5, t=POS, p=previous, c=tag_class)
    return tag_class


def tag_part_of_speech(tokens):
    """Return list of part-of-speech taggings of form (token, tag) for list of TOKENS"""
    # EX: tag_part_of_speech(['How', 'now', ',', 'brown', 'cow', '?']) => [('How', 'WRB'), ('now', 'RB'), (',', ','), ('brown', 'JJ'), ('cow', 'NN'), ('?', '.')]
    if SKIP_NLTK:
        part_of_speech_taggings = [(word, get_most_common_POS(word)) for word in tokens]
    else:
        part_of_speech_taggings = []
        previous = None
        raw_part_of_speech_taggings = nltk.pos_tag(tokens)
        tpo.debug_print("raw tags: %s" % [t for (_w, t) in raw_part_of_speech_taggings], 3)
        for (word, POS) in raw_part_of_speech_taggings:
            tag = label_for_tag(POS, word) if SKIP_CLASS_TAGS else class_for_tag(POS, word, previous)
            part_of_speech_taggings.append((word, tag))
            previous = POS
    tpo.debug_format("tag_part_of_speech({tokens}) => {tags}", 6, 
                     tokens=tokens, tags=part_of_speech_taggings)
    return part_of_speech_taggings


def tokenize_and_tag(text):
    """Run sentence(s) and word tokenization over text and then part-of-speech tag it"""
    # TODO: return one list per sentence not just one combined list
    tpo.debug_print("tokenize_and_tag(%s)" % text, 7)
    text = tpo.ensure_unicode(text)
    text_taggings = []
    for sentence in split_sentences(text):
        tpo.debug_print("sentence: %s" % sentence.strip(), 3)
        tokens = split_word_tokens(sentence)
        tpo.debug_print("tokens: %s" % tokens, 3)
        taggings = tag_part_of_speech(tokens)
        tpo.debug_print("taggings: %s" % taggings, 3)
        # TODO: use append
        text_taggings += taggings
    return text_taggings


def tokenize_text(text):
    """Run sentence and word tokenization over text returning a list of sentence word lists"""
    tokenized_lines = []
    for sentence in split_sentences(text):
        sent_tokens = split_word_tokens(sentence)
        tpo.debug_print("sent_tokens: %s" % sent_tokens, 3)
        tokenized_lines.append(sent_tokens)
    return tokenized_lines


@tpo.memodict
def is_stopword(word):
    """Indicates whether WORD should generally be excluded from analysis (e.g., function word)"""
    # note: Intended as a quick filter for excluding non-content words.
    global stopwords
    if (stopwords is None):
        if SKIP_NLTK:
            stopwords = ['i', 'me', 'my', 'myself', 'we', 'our', 'ours', 'ourselves', 'you', 'your', 'yours', 'yourself', 'yourselves', 'he', 'him', 'his', 'himself', 'she', 'her', 'hers', 'herself', 'it', 'its', 'itself', 'they', 'them', 'their', 'theirs', 'themselves', 'what', 'which', 'who', 'whom', 'this', 'that', 'these', 'those', 'am', 'is', 'are', 'was', 'were', 'be', 'been', 'being', 'have', 'has', 'had', 'having', 'do', 'does', 'did', 'doing', 'a', 'an', 'the', 'and', 'but', 'if', 'or', 'because', 'as', 'until', 'while', 'of', 'at', 'by', 'for', 'with', 'about', 'against', 'between', 'into', 'through', 'during', 'before', 'after', 'above', 'below', 'to', 'from', 'up', 'down', 'in', 'out', 'on', 'off', 'over', 'under', 'again', 'further', 'then', 'once', 'here', 'there', 'when', 'where', 'why', 'how', 'all', 'any', 'both', 'each', 'few', 'more', 'most', 'other', 'some', 'such', 'no', 'nor', 'not', 'only', 'own', 'same', 'so', 'than', 'too', 'very', 's', 't', 'can', 'will', 'just', 'don', 'should', 'now']
        else:
            stopwords = nltk.corpus.stopwords.words('english')
        tpo.debug_print("stopwords: %s" % stopwords, 4)
    return (word.lower() in stopwords)


@tpo.memodict
def has_spelling_mistake(term):
    """Indicates whether TERM represents a spelling mistake"""
    # TODO: rework in terms of a class-based interface
    has_mistake = False
    try:
        if SKIP_ENCHANT:
            global word_freq_hash
            if not word_freq_hash:
                word_freq_path = gh.resolve_path(WORD_FREQ_FILE)
                gh.assertion(gh.non_empty_file(word_freq_path))
                word_freq_hash = read_freq_data(word_freq_path)
            has_mistake = term.lower() not in word_freq_hash
        else:
            global speller
            if not speller:
                speller = enchant.Dict("en_US")
            has_mistake = not speller.check(term)
    except:
        tpo.debug_print("Warning: exception during spell checking of '%s': %s" % (term, str(sys.exc_info())))
    return has_mistake


def read_freq_data(filename):
    """Reads frequency listing for words (or other keys). A hash table is returned from (lowercased) key to their frequency."""
    # Sample input:
    #   # Word      Freq
    #   the 179062
    #   to  123567
    #   is  99390
    #   and 95920
    #   a   76679
    tpo.debug_print("read_freq_data(%s)" % filename, 3)
    freq_hash = {}

    # Process each line of the file
    input_handle = system.open_file(filename)
    line_num = 0
    for line in input_handle:
        line_num += 1
        # Ignore comments
        line = line.strip()
        if (len(line) > 0) and (line[0] == '#'):
            continue

        # Extract the four fields and warn if not defined
        fields = line.split("\t")
        if (len(fields) != 2):
            tpo.debug_print("Ignoring line %d of %s: %s" % (line_num, filename, line), 3)
            continue
        (key, freq) = fields
        key = key.strip().lower()

        # Store in hash
        if key not in freq_hash:
            freq_hash[key] = freq
        else:
            tpo.debug_print("Ignoring alternative freq for key %s: %s (using %s)" 
                        % (key, freq, freq_hash[key]), 6)
        
    return (freq_hash)


def read_word_POS_data(filename):
    """Reads frequency listing for words in particular parts of speech
    to derive dictionay of the most common part-of-speech for words (for quick-n-dirty part-of-speech
    tagging). A hash table is returned from (lowercased) words to their most common part-of-speech."""
    # Sample input:
    #   # Token     POS     Freq
    #   ,           ,       379752
    #   .           .       372550
    #   the         DT      158317
    #   to          TO      122189
    tpo.debug_print("read_word_POS_freq(%s)" % filename, 3)
    global word_POS_hash
    word_POS_hash = {}

    # Process each line of the file
    input_handle = system.open_file(filename)
    line_num = 0
    for line in input_handle:
        line_num += 1
        # Ignore comments
        line = line.strip()
        if (len(line) > 0) and (line[0] == '#'):
            continue

        # Extract the four fields and warn if not defined
        fields = line.split("\t")
        if (len(fields) != 3):
            tpo.debug_print("Ignoring line %d of %s: %s" % (line_num, filename, line), 3)
            continue
        (word, POS, _freq) = fields
        word = word.strip().lower()

        # Store in hash
        if word not in word_POS_hash:
            word_POS_hash[word] = POS
        else:
            tpo.debug_print("Ignoring alternative POS for word %s: %s (using %s)" 
                        % (word, POS, word_POS_hash[word]), 6)
        
    return (word_POS_hash)


def get_most_common_POS(word):
    """Returns the most common part-of-speech label for WORD, defaulting to NN (noun)"""
    # EX: get_most_common_POS("can") => "MD"
    # EX: get_most_common_POS("notaword") => "NN"
    global word_POS_hash
    if not word_POS_hash:
        word_POS_freq_path = gh.resolve_path(WORD_POS_FREQ_FILE)
        gh.assertion(gh.non_empty_file(word_POS_freq_path))
        word_POS_hash = read_word_POS_data(word_POS_freq_path)
    label = "NN"
    word = word.lower()
    if (word in word_POS_hash):
        label = word_POS_hash[word]
    return label

#------------------------------------------------------------------------
# Utility functions
#
# TODO: make POS optional for is_POS-type functions (and use corpus frequencies to guess)
#

def is_noun(_token, POS):
    """Indicates if TOKEN is a noun, based on POS"""
    return (POS[0:2] == "NN")


def is_verb(_token, POS):
    """Indicates if TOKEN is a verb, based on POS"""
    # EX: is_verb('can', 'NN') => False
    return (POS[0:2] == "VB")


def is_adverb(_token, POS):
    """Indicates if TOKEN is an adverb, based on POS"""
    # EX: is_adverb('quickly', 'RB') => True
    return (POS[0:2] == "RB")


def is_adjective(_token, POS):
    """Indicates if TOKEN is an adjective, based on POS"""
    # EX: is_adverb('quick', 'JJ') => True
    return (POS[0:2] == "JJ")


def is_comma(token, POS):
    """Indicates if TOKEN is a comma"""
    return ((token == ",") or (POS[0:1] == ","))


def is_quote(token, _POS):
    """Indicates if TOKEN is a quotation mark"""
    # Note: this includes checks for MS Word smart quotes because in training data
    # TODO: make handled properly with respect to Unicode encoding (e.g., UTF-8)
    return token in "\'\"\x91\x92\x93\x94"

def is_punct(token, POS=None):
    """Indicates if TOKEN is a punctuation symbol"""
    # EX: is_punct('$', '$') => True
    return (re.search("[^A-Za-z0-9]", token[0:1]) or 
            (POS and re.search("[^A-Za-z]", POS[0:1])))

# TODO: alternative to is_punct
## def is_punctuation(token, POS):
##     """Indicates if TOKEN is a punctuation symbol"""
##     # EX: is_punct('$', '$') => True
##     # TODO: find definitive source (or use ispunct-type function)
##     punctuation_chars_regex = r"[\`\~\!\@\#\$\%\^\&\*\(\)\_\-\+\=\{\}\[\]\:\;\"\'\<\>\,\.]"
##     return (re.search(punctuation_chars_regex, token[0:1]) or (POS
## re.search("[^A-Za-z]", POS[0:1]))


#------------------------------------------------------------------------

def usage():
    """Displays command-line usage"""
    usage_note = """
Usage: _SCRIPT_ [--help] [--just-tokenize] [--lowercase] file
Example:

echo "My dawg has fleas" | _SCRIPT_ -

Notes:
- Intended more as a library module
- In standalone mode it runs the text processing pipeline over the file:
     sentence splitting, word tokenization, and part-of-speech tagging
- Set SKIP_NLTK environment variable to 1 to disable NLTK usage.
"""
    # TODO: __file__ => sys.argv[1]???
    tpo.print_stderr(usage_note.replace("_SCRIPT_", __file__))
    return

def main():
    """
    Main routine: parse arguments and perform main processing
    TODO: revise comments
    Note: Used to avoid conflicts with globals (e.g., if this were done at end of script).
    """
    # Initialize
    tpo.debug_print("main(): sys.argv=%s" % sys.argv, 4)

    # Show usage statement if no arguments or if --help specified
    just_tokenize = False
    make_lowercase = False
    show_usage = ((len(sys.argv) == 1) or (sys.argv[1] == "--help"))
    arg_num = 1
    while ((not show_usage) and arg_num < len(sys.argv) and (sys.argv[arg_num][0] == "-")):
        if (sys.argv[arg_num] == "--just-tokenize"):
            just_tokenize = True
        elif (sys.argv[arg_num] == "--lowercase"):
            make_lowercase = True
        elif sys.argv[arg_num] == "-":
            break
        else:
            tpo.print_stderr("Invalid argument: %s" % sys.argv[arg_num])
            show_usage = True
        arg_num += 1
    if (show_usage):
        usage()
        sys.exit()

    # Run the text from each file through the pipeline
    for i in range(arg_num, len(sys.argv)):
        # Input the entire text from the file (or stdin if - specified)
        filename = sys.argv[i]
        input_handle = system.open_file(filename) if (filename != "-") else sys.stdin

        # Analyze the text
        while True:
            text = input_handle.readline() if LINE_MODE else input_handle.read()
            if text == "":
                break
            text = text.strip()
            if just_tokenize:
                # Just tokenize sentence and words
                # Note: text lowercased at end to allow for case clues (e.g., "Dr. Jones")
                for tokenized_line in tokenize_text(text):
                    tokenized_text = " ".join(tokenized_line)
                    if make_lowercase:
                        tokenized_text = tokenized_text.lower()
                    print(tokenized_text)
            else:
                # Show complete pipeline step-by-step
                taggings = tokenize_and_tag(text)
                
                # Show the results
                # TODO: show original tags if class-based; put JUST_TAGS support in tag_part_of_speech
                # TODO: flesh out support for verbose mode
                if VERBOSE:
                    print("text: %s" % text)
                if JUST_TAGS:
                    if VERBOSE:
                        print("tokens: %s" % OUTPUT_DELIM.join([w for (w, _POS) in taggings]))
                        print("tags: %s" % OUTPUT_DELIM.join([POS for (_w, POS) in taggings]))
                    else:
                        print(OUTPUT_DELIM.join([POS for (_w, POS) in taggings]))
                else:
                    gh.assertion(VERBOSE)
                    print("taggings: %s" % taggings)
                if SHOW_MISSPELLINGS:
                    misspellings = [w for (w, POS) in taggings if has_spelling_mistake(w)]
                    gh.assertion(VERBOSE)
                    print("misspellings: %s" % misspellings)
                if VERBOSE:
                    print("")

    # Cleanup
    tpo.debug_print("stop %s: %s" % (__file__, tpo.debug_timestamp()), 3)
    return

#------------------------------------------------------------------------
# Initialization

if __name__ == "__main__":
    main()
