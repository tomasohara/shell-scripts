#! /usr/bin/env python
#
# spaccy_ner.py: Runs spaCy for a variety of natural lanuage processing (NLP)
# tasks.
#
# Notes:
# - This is a generalization of spacy_ner.py, which was just for named entity recognition (NER).
# - Unforunately spaCy's document omits important detail that sentiment analysis is not built in!
# - To compensate, sentiment analyzer is based on vader:
#      https://medium.com/swlh/simple-sentiment-analysis-for-nlp-beginners-and-everyone-else-using-vader-and-textblob-728da3dbe33d
# TODO:
# - ** Disable stupid tensorflow warnings (unless feature used): see https://stackoverflow.com/questions/72033928/python-spacy-module-warning-involving-tensorflow-and-libcudart!
# - * Add part-of-speech tagging (see https://spacy.io/api/tagger).
# - Add support for parsing.
# - Integrate state-of-the-art sentiment analysis.
# - Test other sentence splitters besides NLTK and pySBD:
#   ex: Stanford (https://nlp.stanford.edu/software/tokenizer.html).
# - Integrate alternative sentiment analysis modules:
#   ex: https://spacy.io/universe/project/spacy-textblob.
# 

"""Performs various natural lanuage processing (NLP) tasks via spaCy"""

# Standard packages
import re

# Installed packages
import spacy

# Local packages
from mezcla import debug
from mezcla.main import Main, TRACK_PAGES
from mezcla import system
from mezcla import glue_helpers as gh

# Constants (e.g., for arguments)
#
VERBOSE = "verbose"
RUN_NER = "run-ner"
ANALYZE_SENTIMENT = "analyze-sentiment"
## TODO: RUN_POS_TAGGER = "pos-tagging"
## TODO: RUN_TEXT_CATEGORIZER = "text-categorization"
LANG_MODEL = "lang-model"
## TODO: TASK_MODEL = "task-model"
USE_SCI_SPACY = "use-scispacy"
DOWNLOAD_MODEL = "download-model"
SHOW_REPRESENTATION = "show-representation"
## TODO_ARG1 = "TODO-arg1"

# Environment options
COUNT_ENTITIES = system.getenv_bool("COUNT_ENTITIES", False,
                                    "Show counts of entities in verbose output")
SENT_TOKENIZER = system.getenv_text("SENT_TOKENIZER", " ",
                                    "Name of (alternative) sentence tokenizer to use")
USE_PYSBD = system.getenv_bool("USE_PYSBD", (SENT_TOKENIZER.lower() == "pysbd"),
                               "Use pySBD--pragmatic Sentence Boundary Disambiguation")
USE_NLTK = system.getenv_bool("USE_NLTK", (SENT_TOKENIZER.lower() == "nltk"),
                              "Use NLTK--NL Toolkit")

#...............................................................................

# placeholder for optional sentiment module
SentimentIntensityAnalyzer = None

class SentimentAnalyzer(object):
    """Class for analyzing sentiment of sentences or words"""
    # Uses VADER: Valence Aware Dictionary and sEntiment Reasoner
    # Examples:
    # "bad":  {'neg': 1.0, 'neu': 0.0, 'pos': 0.0, 'compound': -0.5423}
    # "good": {'neg': 0.0, 'neu': 0.0, 'pos': 1.0, 'compound': 0.4404}
    analyzer = None
    
    def __init__(self):
        """Class constructor"""
        # Make sure vader is initialized
        global SentimentIntensityAnalyzer
        if not SentimentIntensityAnalyzer:
            debug.trace(2, "dynamic loading of vader")
            # pylint: disable=import-outside-toplevel, import-error
            from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer as sia
            SentimentIntensityAnalyzer = sia
        self.analyzer = SentimentIntensityAnalyzer()

    def get_score(self, text):
        """Return sentiment score for word(s) in text"""
        debug.trace_fmt(5, "get_sentiment({t})", t=text)
        all_scores = self.analyzer.polarity_scores(text)
        debug.trace_fmt(6, "scores={all}", all=all_scores)
        score = all_scores.get("compound", 0)
        debug.trace_fmt(4, "get_sentiment({t}) => {s}", t=text, s=score)
        return score

#...............................................................................

pysbd = None
## TODO: PySBDFactory = None

APPLY_SPAN_FIX = system.getenv_bool("APPLY_SPAN_FIX", True,
                                    "Apply pySBD contract-mode fix for char_span")

if USE_PYSBD or USE_NLTK:
    # pylint: disable=import-outside-toplevel, import-error
    import pysbd
    ## TODO: from pysbd.utils import PySBDFactory
    debug.assertion(re.search(r"^[3-9]", spacy.__version__), "spaCy 3+ is required for pysbd")

def get_char_span(doc, start, end):
    """Return character span in DOC from START to END or thereabouts (e.g., END - 1)"""
    # Note: with APPLY_SPAN_FIX, the following fix is used:
    #     https://github.com/nipunsadvilkar/pySBD/pull/97
    debug.trace(6, f"get_char_span(_doc, {start}, {end})")
    if APPLY_SPAN_FIX:
        # Note: With alignment mode "contract", the span of all tokens is completely
        # within the character span.
        debug.trace(6, "trying alignment mode contract")
        span = doc.char_span(start, end, alignment_mode="contract")
    else:
        span = doc.char_span(start, end)

    if not span and APPLY_SPAN_FIX:
        # Note: With alignment mode "expand", the span of all tokens is at least
        # partially covered by the character span)
        debug.trace(6, "retrying with alignment mode expand")
        span = doc.char_span(start, end, alignment_mode="expand")
        
    if not span and APPLY_SPAN_FIX:
        # TODO: make this more systematic and also limit to surrounding boundaries
        for (pre, post) in [(0, 1), (1, 0), (0, 2), (1, 2)]:
            try:
                span = doc.char_span(start - pre, end + post, alignment_mode="expand")
            except:
                span = None
            if span:
                debug.trace(6, f"pysbd hack: adjusted span by {(pre, post)} to {(start - pre, end + post)}")
                break
    debug.assertion(span)
    return span

# Note: requires Spacy 3+
@spacy.Language.component('pysbd_sentence_boundaries')
def pysbd_sentence_boundaries(doc):
    """Pragmatic sentence tokenizer component"""
    # Note: based on pySBD/examples/pysbd_as_spacy_component.py
    debug.trace(6, "pysbd_sentence_boundaries(_)")
    seg = pysbd.Segmenter(language="en", clean=False, char_span=True)
    debug.trace_expr(5, seg)
    custom_sent_char_spans = seg.segment(doc.text)
    debug.trace_expr(5, custom_sent_char_spans)

    # Reconcile with spaCy token character spans
    # Note: this runs into problems when word tokenization differs; see
    #    https://github.com/explosion/spaCy/issues/4531
    #    [char_span not returning spans in some cases #4531]
    ## BAD: char_spans = [doc.char_span(sent_span.start, sent_span.end) for sent_span in custom_sent_char_spans]
    #
    spacy_sent_char_spans = [get_char_span(doc, sent_span.start, sent_span.end) for sent_span in custom_sent_char_spans]
    debug.trace_values(5, spacy_sent_char_spans)

    # Set new-sentence flag for token at each starting offset for sentence
    start_token_ids = [span[0].idx for span in spacy_sent_char_spans if span]
    for token in doc:
        token.is_sent_start = (token.idx in start_token_ids)
    debug.assertion(len(custom_sent_char_spans) == sum(token.is_sent_start for token in doc))
    return doc

#...............................................................................

nltk = None

if USE_NLTK:
    # pylint: disable=import-outside-toplevel, import-error
    import nltk
    from pysbd.utils import TextSpan

@spacy.Language.component('nltk_sentence_boundaries')
def nltk_sentence_boundaries(doc):
    """NLTK sentence tokenizer component
       Note: omits the spacing between sentences (unlike spaCy and pySBD)."""
    # Tokenize sentence and make note of starting/ending offsets
    # note: uses TextSpan from pySBD
    debug.trace(6, "nltk_sentence_boundaries(_)")
    sentence_list = nltk.tokenize.sent_tokenize(doc.text)
    debug.trace_expr(5, sentence_list)
    current_end = -1
    custom_sent_char_spans = []
    last_offset = (len(doc.text) - 1)
    ## TODO: debug.assertion(last_offset >= (sum(len(l) for l in sentence_list) - 1)
    for sent in sentence_list:
        new_start = min(1 + current_end, last_offset)
        new_end =  min(new_start + len(sent), last_offset)
        custom_sent_char_spans.append(TextSpan(sent, new_start, new_end))
        current_end = new_end
    debug.trace_expr(5, custom_sent_char_spans)
    
    # Reconcile with spaCy token character spans
    # Note: works around word tokenization differences as in pysbd_sentence_boundaries
    spacy_sent_char_spans = [get_char_span(doc, sent_span.start, sent_span.end) for sent_span in custom_sent_char_spans]
    debug.trace_values(5, spacy_sent_char_spans)
    
    # Set new-sentence flag for token at each starting offset for sentence
    start_token_ids = [span[0].idx for span in spacy_sent_char_spans if span]
    for token in doc:
        token.is_sent_start = (token.idx in start_token_ids)
    debug.assertion(len(sentence_list) == sum(token.is_sent_start for token in doc))
    return doc

#...............................................................................

# Main class
#
class Script(Main):
    """Input processing class"""
    nlp = None
    type_prefix = ":"
    entity_delim = ", "
    entity_quote = '"'
    spacy_model = "en_core_web_lg"
    analyze_sentiment = False
    run_ner = False
    show_representation = False
    verbose = False
    doc = None
    sentiment_analyzer = None
    use_sci_spacy = False
    download_model = False
    show_reprsentation = False
    ## TODO_arg1 = False
    sent_num = 0

    def setup(self):
        """Check results of command line processing"""
        debug.trace_fmtd(5, "Script.setup(): self={s}", s=self)
        self.spacy_model = self.get_parsed_option(LANG_MODEL, self.spacy_model)
        self.analyze_sentiment = self.get_parsed_option(ANALYZE_SENTIMENT, self.analyze_sentiment)
        self.run_ner = self.get_parsed_option(RUN_NER, self.run_ner)
        self.verbose = self.get_parsed_option(VERBOSE, self.verbose)
        default_use_sci_spacy = re.search(r"\bsci\b", self.spacy_model)
        self.use_sci_spacy = self.get_parsed_option(USE_SCI_SPACY, default_use_sci_spacy)
        self.download_model = self.get_parsed_option(DOWNLOAD_MODEL, self.download_model)
        ## self.TODO_arg1 = self.get_parsed_option(TODO_ARG1, self.TODO_arg1)
        do_specific_task = (self.run_ner or self.analyze_sentiment)
        ## TODO: self.show_representation = self.verbose or (not do_specific_task)
        ## TEST: self.show_representation = (not (do_specific_task or TRACK_PAGES))
        default_show_representation = (not (do_specific_task or TRACK_PAGES))
        self.show_representation = self.get_parsed_option(SHOW_REPRESENTATION, default_show_representation)
        self.doc = None

        # Download model from server
        if self.download_model:
            print(f"Downloading spaCy model: {self.spacy_model}")
            gh.run(f"python -m spacy download {self.spacy_model}")
        
        # Load in external module for sentiment analysis (gotta hate spaCy!)
        if self.analyze_sentiment:
            self.sentiment_analyzer = SentimentAnalyzer()

        # Load spaCy language model (normally large model for English)
        debug.trace_fmt(4, "loading spaCy model {m}", m=self.spacy_model)
        try:
            self.nlp = spacy.load(self.spacy_model)
        except:
            system.print_stderr("Problem loading model {m} via spacy: {exc}",
                                m=self.spacy_model, exc=system.get_exception())
            # If model package not properly installed, the model can be
            # created by the following workaround (n.b., uses specific model for clarity);
            #    nlp = spacy.load("en_core_web_sm")
            #        =>
            #    import en_core_web_sm
            #    nlp = en_core_web_sm.load()
            # TODO: Figure out step needed for proper spaCy bookkeeping after 
            # new package is added to python (e.g., en_core_web_sm under site-packages).
            try:
                debug.trace(3, "Warning: Trying eval hack to load model")
                # pylint: disable=import-outside-toplevel, import-error, eval-used
                if self.use_sci_spacy:
                    import scispacy
                    debug.trace_fmt(4, "dir(scispacy): {d}", d=dir(scispacy))
                exec("import " + self.spacy_model)  # pylint: disable=exec-used
                debug.trace_fmt(4, "dir({m}): {d}", m=self.spacy_model, d=eval("dir(" + self.spacy_model + ")"))
                self.nlp = eval(self.spacy_model + ".load()")
            except:
                system.print_stderr("Problem with alternative load of model {m}: {exc}",
                                    m=self.spacy_model, exc=system.get_exception())
        debug.assertion(self.nlp)

        # Disable pipeline components not needed
        unused = ["parser", "tok2vec"]
        if not self.run_ner:
            unused.append("ner")
        for component in unused:
            try:
                self.nlp.disable_pipe(component)
            except:
                system.print_exception_info(f"disable Spacy pipe component {component}")
        debug.trace(4, f"Pipeline components: {[x[0] for x in self.nlp.pipeline]}")

        # Load in optional SpaCy components
        if USE_PYSBD:
            ## TODO: self.nlp.add_pipe(PySBDFactory(self.nlp))
            self.nlp.add_pipe("pysbd_sentence_boundaries", before="parser")
        elif USE_NLTK:
            self.nlp.add_pipe("nltk_sentence_boundaries", before="parser")
        else:
            debug.assertion(SENT_TOKENIZER.lower() == "spacy")
            # Note: senticize is implicitly used when parser enabled
            self.nlp.add_pipe("sentencizer")
                
        # Sanity checks
        ## OLD: debug.assertion(self.nlp)
        debug.assertion(self.type_prefix != self.entity_delim)
                
        debug.trace_object(5, self, label="Script instance")


    def get_entity_spec(self):
        """Return the named entities tagged in the input as string list of typed entities"""
        ## EX: "PERSON:Trump, ORG:the White House"
        ## TODO: return regular list
        debug.trace_fmt(4, "get_entity_spec(): self={s}", s=self)

        # Collect list of entities (e.g., ["PERSON:Elon Musk,", "ORG:SEC"])
        entity_specs = []
        for ent in self.doc.ents:
            ent_text = ent.text
            debug.assertion(self.type_prefix not in ent.label_)
            if (self.type_prefix in ent_text):
                ent_text = (self.entity_quote + ent_text + self.entity_quote)
            entity_specs.append(ent.label_ + self.type_prefix + ent_text)

        # Convert to string
        entity_spec = self.entity_delim.join(entity_specs)
        debug.trace_fmt(5, "get_entity_spec() => {r}", r=entity_spec)
        return entity_spec

    def get_sentiment_score(self, text=None):
        """Returns the overall sentiment score associated with the TEXT (or entire document)"""
        debug.trace_fmt(4, "get_sentiment_score({t}): self={s}", s=self, t=text)
        if text is None:
            text = system.to_string(self.doc)
        # TODO: show word-level sentiment scores, highlighting cases much
        # different from the overall score
        ## BAD: score = self.doc.sentiment
        score = self.sentiment_analyzer.get_score(text)
        debug.trace_fmt(4, "get_sentiment_score() => {r}", r=score)
        return score
    
    def process_line(self, line):
        """Processes current line from input, showing word/lexeme information by default"""
        # TODO: add entity-type filter
        debug.trace_fmtd(6, "Script.process_line({l})", l=line)

        # Analyze the text in the line
        # TODO: allow for embedded sentences
        ## self.doc = self.nlp(re.sub(r"\S", " ", line))
        line = (re.sub(r"\s", " ", line))
        self.doc = self.nlp(line)
        debug.trace_object(7, self.doc, "doc")
        if self.verbose:
            line_text = re.sub(r"\r?\n", " <newline> ", line)
            print(f"input: {line_text}")
        if TRACK_PAGES and self.verbose:
            print("location info (page/sentence):")
        self.sent_num = 0
        for s in self.doc.sents:
            if (str(s) != "\n"):
                self.sent_num += 1
                self.process_sentence(s)
            else:
                debug.trace_fmtd(5, "Ignoring empty sentence (L{n}:O{o})",
                                 n=self.line_num, o=self.char_offset)

    def process_sentence(self, sentence):
        """Process SENTENCE"""
        sentence_text = re.sub(r"[\r\n]$", "", str(sentence), count=1)
        debug.trace_fmtd(6, "Script.process_sentence({s})", s=sentence_text)
        if (sentence_text.strip() == ""):
            debug.trace_fmtd(5, "Ignoring empty sentence")
            return
        sent_info = self.doc[sentence.start: sentence.end]
        if TRACK_PAGES:
            # Notes: Paragraph numbers are relative to each page; and, likewise
            # sentence numbers are relative to each paragraph.
            # See process_line and Main.read_input.
            ## OLD: print(f"Pg#{self.page_num}/Sent#{self.sent_num}: {sentence_text}")
            if self.verbose:
                print(f"Pg#{self.page_num}/Sent#{self.sent_num}: ", end="")
            print(sentence_text)
            debug.trace(4, f"Offset: {self.char_offset}")

        # Show synopsis of word token representations
        # TODO: have options for specifying attributes to show
        if self.show_representation:
            # Gather the word (lexeme) information
            # Note: Based on vocab/lexemes section of https://spacy.io/usage/spacy-101
            word_attributes = ["text", "is_oov", "is_stop", "sentiment"]
            token_attributes = ["is_sent_start"]
            all_info = []
            for word in sent_info:
                lexeme = self.doc.vocab[word.text]
                info = [getattr(lexeme, a, "") for a in word_attributes]
                if (info[0] == "\n"):
                    info[0] = "\\n"
                token_info = [getattr(word, a, "") for a in token_attributes]
                all_info.append("\t".join([system.to_string(v) for v in info + token_info]))
            # Output the synopsis
            prefix = ("\t".join(word_attributes + token_attributes) + "\n")
            doc_repr = "\n".join(all_info)
            print(prefix + doc_repr)

        # Optionally, invoke NER
        if self.run_ner:
            prefix = ""
            if self.verbose:
                if COUNT_ENTITIES:
                    prefix = "{len} ".format(len=len(sent_info.ents))
                prefix += "entities:"
            print(prefix + self.get_entity_spec())
        # Optionally, do sentiment analysis
        if self.analyze_sentiment:
            prefix = "sentiment: " if self.verbose else ""
            sent_text = str(sentence.text)
            print(prefix + str(self.get_sentiment_score(sent_text)))
        
#-------------------------------------------------------------------------------
    
if __name__ == '__main__':
    debug.trace_current_context(level=debug.QUITE_DETAILED)
    app = Script(
        description=__doc__,
        # Note: skip_input controls the line-by-line processing, which is inefficient but simple to
        # understand; in contrast, manual_input controls iterator-based input (the opposite of both).
        skip_input=False,
        manual_input=False,
        # Paragraph mode is required for proper sentence tokenization
        paragraph_mode=True,
        boolean_options=[RUN_NER, ANALYZE_SENTIMENT, VERBOSE,
                         (DOWNLOAD_MODEL, "Download spaCy model"),
                         (SHOW_REPRESENTATION, "Show final representation (e.g., word & token attributes"),
                         ## (TODO_ARG1, "TODO-desc"),
        ],
        text_options=[(LANG_MODEL, "Language model for NLP")])
    app.run()
