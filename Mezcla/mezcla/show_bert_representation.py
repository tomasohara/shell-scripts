#! /usr/bin/env python
# 
# Show what the BERT model representation is for a pair of sentences. This is based on the following:
#    https://github.com/google-research/bert/blob/master/README.md
# This includes an option to compute cosine distance matrix for the tokens in the feature vectors, This follows the approach from the following article:
#    https://medium.com/thelocalminima/are-bert-features-interbertible-250a91eb9dc
#
# Sample input (sentences 1 & 2):
#
#    "april july"
#    "spring summer"
#
# Sample output:
#
#    - Cosine matrix:
#
#            [CLS]   april   july    [SEP]   spring  summer  [SEP]
#    [CLS]   1.0    *0.344   0.336   -0.025  0.34    0.341   0.011
#    april           1.0     0.514   0.047  *0.606   0.414   0.062
#    july                    1.0     0.045   0.366   0.683   0.054
#    [SEP]                           1.0     0.094   0.064  *0.908
#    spring                                  1.0    *0.599   0.107
#    summer                                          1.0     0.082
#    [SEP]                                                  *1.0
#
#    - Feature representation:
#
#    {
#      "linex_index" : 0,
#      "features" : [
#         {
#            "layers" : [
#               {
#                  "index" : -1
#                  "values" : [
#                     -0.460937, 0.192811, -0.473121, -0.254216, 0.077836, -0.139587, 0.613976, 0.932992, ...
#                  ],
#               },
#               {
#                  "index" : -2
#                  "values" : [
#                     -0.89061, -0.080438, -0.519494, -0.280097, 0.936842, -0.11848, -0.204586, 1.619458, ...
#                  ],
#               },
#               {
#                  "index" : -3
#                  "values" : [
#                     -0.83093, 0.116799, -0.590249, -0.312695, 0.330304, -0.166485, 0.380528, 1.59396, ...
#                  ],
#               },
#               {
#                  "index" : -4,
#                  "values" : [
#                     -0.833253, 0.129633, -0.721126, -0.315408, 0.435143, 0.018215, 0.090608, 0.985256, ...
#                  ]
#               }
#            ],
#            "token" : "[CLS]"
#         },
#         {
#            "token" : "april",
#            "layers" : [
#               {
#                  "index" : -1
#                  "values" : [
#                     -0.86163, -0.03601, -0.080842, -0.166804, -0.272864, -0.062401, 0.226085, 0.556695, ...
#                  ],
#               },
#               {
#                  "index" : -2
#                  "values" : [
#                     -0.643406, -0.383428, -0.145636, 0.390536, -0.157737, -0.209778, 0.100278, 0.810878, ...
#                  ],
#               },
#               {
#                  "index" : -3,
#                  "values" : [
#                     -0.568553, -0.327431, 0.032729, 0.634031, -0.089157, -0.165046, 0.454916, 0.643462, ...
#                  ]
#               },
#               {
#                  "index" : -4,
#                  "values" : [
#                     -0.428569, -0.138098, -0.508629, 0.325682, -0.215687, -0.293736, 0.453519, 0.44138, ...
#                  ]
#               }
#            ]
#         },
#         ...
#    }
#
#................................................................................
# Notes:
# - To get context-insensitive vectors, the script should be run separately
#   for each word.
# - To show cosine similarity for complex vector terms (e.g., king - man + woman),
#   get the individual work vectors and manually combine vectors (e.g., ipython)
#   before invoking show_cosine_distances.
#................................................................................
# TOOD:
# - Add option to average the vectors rather than using last (i.e., index 3).
#

"""Show the representation of a BERT model for a sentence or pair (see BERT README.md)"""

# Standard packages
import json
import os
import re
import sys

# Installed packages
import numpy as np
import scipy.spatial.distance
try:
    tf = None
    if ("--help" not in sys.argv):
        import tensorflow as tf
except:
    ## TODO: system.print_exception_info("tensorflow import")
    sys.stderr.write(f"Problem importing tensorflow: {sys.exc_info()}")
if not tf:
    ## TODO: tf = object(); move into supporting module (e.g., misc_utils)
    class Fubar:
        """Fouled-up, etc."""
        pass
    f_inner = Fubar()
    tf = Fubar()
    ## TODO: tf = json.loads('{"version": {"VERSION": "-1"}}')
    setattr(f_inner, "VERSION", "-1")
    setattr(tf, "version", f_inner)

# Local packages
from mezcla import debug
from mezcla.main import Main
from mezcla import system
from mezcla import glue_helpers as gh
from mezcla import text_utils
from mezcla.system import form_path, getenv_bool, getenv_int, getenv_text, getenv_value, round_num
from mezcla.text_utils import version_to_number as version_as_float, make_fixed_length

# Constants
SENTINEL_TOKENS = ["[CLS]", "[SEP]"]

# Environment constants
PYTHON = getenv_text("PYTHON", "python", 
                     description="Command for invoking script (e.g., /usr/bin/nice 19 python -u)")
PROJECT_DIR = getenv_text("PROJECT_DIR", "/usr/local/misc",
                          description="Base directory for project files")
CODE_DIR = getenv_text("CODE_DIR", form_path(PROJECT_DIR, "programs", "python"),
                       description="Base directory for python scripts")
DATA_DIR = getenv_text("DATA_DIR", form_path(PROJECT_DIR, "data"),
                       description="Base directory for program data")
DEEP_LEARNING_DATA = getenv_text("DEEP_LEARNING_DATA", form_path(DATA_DIR, "deep-learning"),
                                 description="Base directory for deep learning data")
USE_ALBERT = getenv_bool("USE_ALBERT", False,
                         description="Use ALBERT instead of BERT")
## TODO: PRE = "al" if USE_ALBERT else ""
BERT = "albert" if USE_ALBERT else "bert"
BERT_CODE_DIR = getenv_text("BERT_CODE_DIR", form_path(CODE_DIR, BERT),
                            description="Code for BERT specialization (e.g., ALBERT)")
DEFAULT_BERT_DATA_DIR = "albert_base" if USE_ALBERT else "uncased_L-12_H-768_A-12"
BERT_DATA_DIR = getenv_text("BERT_DATA_DIR", 
                            form_path(DEEP_LEARNING_DATA, BERT, DEFAULT_BERT_DATA_DIR),
                            description="Directory for pre-trained data")
BERT_MODEL_DIR = getenv_text("BERT_MODEL_DIR", BERT_DATA_DIR,
                             "Directory for BERT models which can differ from BERT_DATA_DIR if pre-training")
## OLD: DEFAULT_CHECKPOINT_FILE = "model.ckpt" if USE_ALBERT else "bert_model.ckpt"
## TODO: add Python helper to do this via glob.glob, etc.:
# note: Uses the latest checkpoint file in the BERT model directory
DEFAULT_CHECKPOINT_FILE = (gh.run(f"ls -t {BERT_MODEL_DIR}/*ckpt*.index | head -1").replace(".index", ""))
CHECKPOINT_FILE = getenv_text("CHECKPOINT_FILE", DEFAULT_CHECKPOINT_FILE,
                              description="BERT pre-taining model checkpoint")
MAX_SEQ_LENGTH = getenv_value("MAX_SEQ_LENGTH", None,
                             "Maximum sentence token sequence length")
BATCH_SIZE = getenv_value("BATCH_SIZE", None,
                         "Batch size for processing")
NUM_LAYERS = getenv_int("NUM_LAYERS", 4,
                        "Number of layers to extract")
AVERAGE_LAYERS = getenv_bool("AVERAGE_LAYERS", False,
                             "Take average of layers rather than last one")
FIELD_WIDTH = getenv_int("FIELD_WIDTH", None,
                         "Width of fields for cosine matrix")

# Option names
MODEL = "model"
SENTENCE1 = "sentence1"
SENTENCE2 = "sentence2"
COSINE = "cosine"
VECTORS = "vectors"
LAYER = "layer"
ALL_TOKENS = "all-tokens"
VERBOSE = "verbose"
FILTER = "filter"
INCLUDE = "include"

def cosine_distance(vector1, vector2):
    """Compute cosine distance between VECTOR1 and VECTOR2"""
    # EX: cosine_distance([1, 0, 0], [0, 0, 1]) => 1.0
    # EX: cosine_distance([1, 0, 0], [2, 0, 0]) => 0.0
    # EX: cosine_distance([1, 0, 0, 0], [1, 1, 1, 1]) => 0.5
    dist = scipy.spatial.distance.cosine(vector1, vector2)
    debug.trace_fmt(5, "cosine_distance({v1}, {v2}) => {d})",
                    v1=vector1, v2=vector2, d=dist)
    return dist


def print_vector(vector, fixed_width=None):
    """Print VECTOR tab-delimited unless FIXED_WIDTH"""
    debug.assertion(all(isinstance(value, str) for value in vector))
    if fixed_width:
        print("".join(make_fixed_length(value, fixed_width)
                      for value in vector))
    else:
        print("\t".join(vector))
    return


def show_cosine_distances(tokens, vectors):
    """Displays the cosine distance matrix (all pairs of tokens)
    Note: prints entries tab-separated unless FIELD_WIDTH global set
    """

    # Calculate distances and display matrix (omitting symmetric cases)
    print_vector([""] + tokens, fixed_width=FIELD_WIDTH)
    for i, token1 in enumerate(tokens):
        info = [token1] + ([""] * i)
        for j in range(i, len(tokens)):
            dist = cosine_distance(vectors[i], vectors[j])
            info.append(str(round_num(dist, 3)))
        print_vector(info, fixed_width=FIELD_WIDTH)
    return


class ExtractFeatures(object):
    """Class for extracting features from BERT model"""

    def __init__(self, model=None):
        """Class constructor with optional MODEL override"""
        if model is None:
            model = CHECKPOINT_FILE
        self.model = model
        debug.assertion(system.file_exists(self.model + ".index"))
        return

    def run(self, sentence1, sentence2, basename=None, other_options=None):
        """Invoke the feature extraction and return JSON result as string"""
        # Set options
        if basename is None:
            basename = "_features"
        if other_options is None:
            other_options = ""
        model_path = self.model
        if not system.file_exists(model_path + ".index"):
            model_path = system.form_path(BERT_MODEL_DIR, self.model)

        # Create input file in correct format from sentences
        SENTENCE_DELIM = "|||"
        debug.assertion(SENTENCE_DELIM not in (sentence1 + sentence2))
        input_filename = basename + ".txt"
        input_text = sentence1
        if sentence2.strip():
             input_text += f" {SENTENCE_DELIM} {sentence2}"
        system.write_file(input_filename, input_text)
        output_filename = basename + ".json"

        # Invoke the feature extraction script
        # TODO: document the options; optionally, include all layers
        D = os.path.sep
        layer_spec = ",".join(str(-i) for i in range(1, NUM_LAYERS + 1))
        command_line = f"""{PYTHON} {BERT_CODE_DIR}{D}extract_features.py  {other_options} \
                       --input_file={input_filename} \
                       --output_file={output_filename} \
                       --vocab_file={BERT_DATA_DIR}{D}vocab.txt \
                       --bert_config_file={BERT_DATA_DIR}{D}{BERT}_config.json \
                       --init_checkpoint={model_path} \
                       --layers={layer_spec}"""
        if MAX_SEQ_LENGTH:
            command_line += f"--max_seq_length={MAX_SEQ_LENGTH}"
        if BATCH_SIZE:
            command_line += f"--batch_size={BATCH_SIZE}"
        gh.run(command_line)
        # TODO: check for common errors (e.g., mismatch in -max_seq_length_

        # Read the JSON representation
        # TODO: pretty print if necessary; add option to prune
        json_representation = system.read_file(output_filename)
        debug.assertion(re.search(r"{.*}", json_representation, re.DOTALL))

        # Cleanup
        if basename and not debug.detailed_debugging():
            # TODO: add helper for this in system
            map(gh.delete_file, gh.get_matching_files(basename + "*"))

        # Return string with features
        return json_representation


class Script(Main):
    """Adhoc script class (e.g., no I/O loop, just run calls)"""
    model = None
    sentence1 = None
    sentence2 = None
    calc_cosine = False
    show_vectors = False
    layer = 3
    use_all_tokens = False
    verbose = False
    include = False
    filter_terms = ""

    def setup(self):
        """Check results of command line processing"""
        debug.trace_fmtd(5, "Script.setup(): self={s}", s=self)
        self.model = self.get_parsed_option(MODEL, self.model)
        self.sentence1 = self.get_parsed_argument(SENTENCE1)
        self.sentence2 = self.get_parsed_argument(SENTENCE2)
        self.layer = self.get_parsed_option(LAYER, self.layer)
        self.calc_cosine = self.get_parsed_option(COSINE, self.calc_cosine)
        self.show_vectors = self.get_parsed_option(VECTORS, self.show_vectors)
        self.use_all_tokens = self.get_parsed_option(ALL_TOKENS, self.use_all_tokens)
        self.verbose = self.get_parsed_option(VERBOSE, self.verbose)
        self.include = self.get_parsed_option(INCLUDE, self.include)
        self.filter_terms = self.get_parsed_option(FILTER, self.filter_terms)
        debug.trace_object(5, self, label="Script instance")
        return

    def run_main_step(self):
        """Main processing step"""
        debug.trace_fmtd(5, "Script.run_main_step(): self={s}", s=self)

        # Make sure number of requested layers doesn't exceed model size
        bert_config_file = gh.form_path(BERT_DATA_DIR, BERT + "_config.json")
        bert_config = json.loads(system.read_file(bert_config_file))
        global NUM_LAYERS
        num_actual_layers = bert_config.get("num_hidden_layers", 1)
        if num_actual_layers < NUM_LAYERS:
            # TODO: only show warning id NUM_LAYERS not the default (4)
            debug.trace(3, f"Warning: only {num_actual_layers} available so not getting {NUM_LAYERS}")
            NUM_LAYERS = num_actual_layers

        # Invoke the helper class to do the actual invocation
        extractor = ExtractFeatures(model=self.model)
        ## OLD: json_repr = extractor.run(self.sentence1, self.sentence2, basename=self.temp_file)
        json_repr = extractor.run(self.sentence1, self.sentence2, basename=self.temp_base)
        tokens = vectors = []
        show_repr = True
        if self.show_vectors or self.calc_cosine:
            (tokens, vectors) = self.extract_vectors(json_repr)
            debug.assertion(len(tokens) == len(vectors))
            show_repr = False
        if self.show_vectors:
            for i, vector in enumerate(vectors):
                if self.verbose:
                    print(tokens[i] + ": ")
                print(vector)
        if self.calc_cosine:
            show_cosine_distances(tokens, vectors)
        if show_repr:
            print(json_repr)
        return

    def extract_vectors(self, json_repr):
        """Extract vectors for each token (from self.layer)"""
        # Filter features/tokens (normally to exclude special ones or to match user list)
        feature_info = json.loads(json_repr)
        all_features = feature_info["features"]
        all_tokens = [h["token"] for h in all_features]
        tokens = all_tokens if self.use_all_tokens else system.difference(all_tokens, SENTINEL_TOKENS)
        if self.filter_terms:
            terms_to_filter = text_utils.extract_string_list(self.filter_terms)
            filter_fn = (system.intersection if self.include else system.difference)
            tokens = filter_fn(tokens, terms_to_filter)
        tokens = sorted(tokens)
        features = [h for (i, h) in enumerate(all_features) if all_tokens[i] in tokens]
        debug.assertion(all((len(h["layers"]) == NUM_LAYERS) for h in features))

        # Either average vectors or take last
        if AVERAGE_LAYERS:
            vectors = []
            for h in features:
                vector = np.array(h["layers"][0]["values"])
                for layer in range(1, NUM_LAYERS):
                    vector += np.array(h["layers"][layer]["values"])
                vector = vector / NUM_LAYERS
                vectors.append(list(vector))
        else:
            vectors = [h["layers"][self.layer]["values"] for h in features]
        return (tokens, vectors)

#-------------------------------------------------------------------------------
    
if __name__ == '__main__':
    debug.trace_current_context(level=debug.QUITE_DETAILED)
    app = Script(
        description=__doc__,
        # Note: skip_input controls the line-by-line processing, which is inefficient but simple to
        # understand; in contrast, manual_input controls iterator-based input (the opposite of both).
        skip_input=True,
        manual_input=True,
        boolean_options=[(ALL_TOKENS, "Include all tokens (e.g., sentinels)"),
                         (COSINE, "Show cosine between vectors"),
                         (VECTORS, "Show feature vectors for all tokens"),
                         (INCLUDE, "Use an inclusion filter"),
                         (VERBOSE, "Verbose output mode")],
        int_options=[(LAYER, "Which layer to use (0-3)")],
        positional_options=[SENTENCE1, SENTENCE2],
        text_options=[(MODEL, "Basename of BERT model file"),
                      (FILTER, "Terms to filter from output")]
        )
    debug.assertion(version_as_float("1.13") <= version_as_float(tf.version.VERSION) < version_as_float("2.0"))
    app.run()
