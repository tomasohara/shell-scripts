#! /usr/bin/env python
#
# Use scikit-learn to perform probabilistic grid search for number of hidden
# layers and number of units per layer.
#
# This extends the following brute-force approach to be both probabilistic
# and to handle hidden layer optimization:
#    https://machinelearningmastery.com/grid-search-hyperparameters-deep-learning-models-python-keras/
# It is also based on the multiclass support from the following:
#    https://machinelearningmastery.com/multi-class-classification-tutorial-keras-deep-learning-library
#
# TODO:
# - Parameterize the following options:
#   activation, num_layers, num_units, ...
# - Fix random seed initialization.
# - Work out the stupid keras/tensorflow incompatibilies issues.
#

"""Keras for probabilistic grid search via scikit-learn"""

## TEST: try to set random number seed for TensorFlow (to get deterministic results)
## import numpy
## numpy.random.seed(7919)
## import tensorflow
## BAD: tensorflow.set_random_seed(7919)
## tensorflow.random.set_seed(7919)

# Standard packages
import re
import sys
from collections import OrderedDict

# Installed packages
# TODO: install kera dynamically???
## TEST: sys.stderr.write("here\n")
## BAD:
from keras.models import Sequential
## See https://stackoverflow.com/questions/55496289/how-to-fix-attributeerror-module-tensorflow-has-no-attribute-get-default-gr
## TEST: from tensorflow.keras.models import Sequential

## OLD:
##
from keras.layers import Dense
##
from keras.wrappers.scikit_learn import KerasClassifier
##
## TEST:
## from tensorflow.keras.layers import Dense
## from tensorflow.keras.wrappers.scikit_learn import KerasClassifier
##
from keras.utils import np_utils

## TEST: sys.stderr.write("there\n")
## TODO: import numpy
import pandas
from pandas.core.frame import DataFrame
from sklearn.model_selection import cross_val_score, GridSearchCV, KFold, RandomizedSearchCV
from sklearn.preprocessing import LabelEncoder

## NOTE: This takes too long to load so postponed, in case usage just shown.
## OLD: import tensorflow as tf
## TEST: tf = None

# Local packages
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla import system
from mezcla import text_utils
from mezcla.text_utils import getenv_ints

# Note: python 3.6+ format strings are used
assert((sys.version_info.major >= 3) and (sys.version_info.minor >= 6))

#...............................................................................
# Constants (e.g., based on environment)

DEFAULT_VERBOSITY = ((debug.get_level() + 1) // 2)
VERBOSITY_LEVEL = system.getenv_int("VERBOSITY_LEVEL", DEFAULT_VERBOSITY)
DATA_FILE = system.getenv_text("DATA_FILE", "samples/pima-indians-diabetes.csv")
FIELD_SEP = system.getenv_text("FIELD_SEP", ",")
BRUTE_FORCE = system.getenv_bool("BRUTE_FORCE", False)
RANDOM_OPTIMIZATION = (not BRUTE_FORCE)
SEED = system.getenv_int("SEED", 7919)
OUTPUT_CSV = system.getenv_bool("OUTPUT_CSV", False)

QUICK_SEARCH = system.getenv_bool("QUICK_SEARCH", False)
FULLER_SEARCH = (RANDOM_OPTIMIZATION and not QUICK_SEARCH)

# TODO: Add descriptions for important deep learning parameters (e.g., NUM_EPOCHS and BATCH_SIZE).
# Note: NUM_EPOCHS and BATCH_SIZE not used in grid search (just sample classification)
RUN_SAMPLE =  system.getenv_bool("RUN_SAMPLE", False)
DEFAULT_NUM_EPOCHS = (200 if (not QUICK_SEARCH) else 10)
NUM_EPOCHS = system.getenv_int("NUM_EPOCHS", DEFAULT_NUM_EPOCHS)
BATCH_SIZE = system.getenv_int("BATCH_SIZE", 5)
NUM_FOLDS = system.getenv_int("NUM_FOLDS", 10)
## OLD: NUM_JOBS = system.getenv_int("NUM_JOBS", -1, "Number of parallel jobs (-1 uses all cores)")
NUM_JOBS = system.getenv_int("NUM_JOBS", -1, "Number of parallel jobs: -1 uses all cores")
NUM_ITERS = system.getenv_int("NUM_ITERS", 100)
SCORING_METRIC = system.getenv_text("SCORING_METRIC", "accuracy")
## OLD: USE_ONE_HOT = system.getenv_bool("USE_ONE_HOT", False)
SKIP_ONE_HOT = system.getenv_bool("SKIP_ONE_HOT", False)
USE_ONE_HOT = system.getenv_bool("USE_ONE_HOT", (not SKIP_ONE_HOT))

# note: HIDDEN_UNIT_VALUES is just for grid search
DEFAULT_HIDDEN_UNIT_VALUES = ("0 5 10 25 50 75 100 250 500" if FULLER_SEARCH else "0 10 50 100 250")
HIDDEN_UNIT_VALUES = getenv_ints("HIDDEN_UNIT_VALUES", DEFAULT_HIDDEN_UNIT_VALUES)
DEFAULT_BATCH_SIZE_VALUES = ("5 25 75 100" if FULLER_SEARCH else "5 50")
BATCH_SIZE_VALUES = getenv_ints("BATCH_SIZE_VALUES", DEFAULT_BATCH_SIZE_VALUES)
DEFAULT_NUM_EPOCH_VALUES = ("10 50 100 250 500 1000" if FULLER_SEARCH else "50 250")
NUM_EPOCH_VALUES = getenv_ints("NUM_EPOCH_VALUES", DEFAULT_NUM_EPOCH_VALUES)

MAX_HIDDEN_UNIT_VARS = system.getenv_int("MAX_HIDDEN_UNIT_VARS", 5)
HIDDEN_UNIT_VARS = ["hidden_units{n}".format(n=(v + 1)) for v in range(MAX_HIDDEN_UNIT_VARS)]
# note: DEFAULT_HIDDEN_UNITS is for use outside of grid search
DEFAULT_HIDDEN_UNITS = getenv_ints("HIDDEN_UNITS", "20 30")

#...............................................................................
# Utility functions

def round3(num):
    """Round NUM using precision of 3"""
    return system.round_num(num, 3)

def non_negative(num):
    """Whether integer NUM > -1"""
    return (num > -1)

# TODO: put following in new ml_utils.py module
def create_feature_mapping(label_values):
    """Return hash mapping elements from LABEL_VALUES into integers"""
    # EX: create_feature_mapping(['c', 'b', 'b', 'a']) => {'c':0, 'b':1, 'a':2}
    debug.assertion(isinstance(label_values, list))
    id_hash = {}
    for item in label_values:
        if (item not in id_hash):
            id_hash[item] = len(id_hash)
    debug.trace_fmt(7, "create_feature_mapping({lv}) => {ih}", lv=label_values, ih=id_hash)
    return id_hash

#...............................................................................
# Grid search support

def create_keras_model(num_input_features=None, num_classes=None, hidden_units=None, **kwargs):
    """Create n-layer Keras model, using either the HIDDEN_UNITS vector or via the hidden_unitsN entries of KWARGS"""
    # TODO: put under MyKerasClassifier as __call__
    debug.trace_fmt(5, "create_keras_model(#f={nf}, #c={nc}, hu={hu}, kw={kw})",
                    nf=num_input_features, nc=num_classes, hu=hidden_units, kw=kwargs)

    # Initialize defaults
    if (num_input_features is None):
        debug.trace(2, "Warning: number of features not specified so using 100!")
        num_input_features = 100
    if (num_classes is None):
        debug.trace(2, "Warning: number of classes not specified so using 2!")
        num_classes = 2
    is_binary = (num_classes == 2)
    if (hidden_units is None):
        # note: -1 needs to be specified in the estimator constructor in order for the grid search
        # variable to be recognized, therefore only non-negative counts are considered.
        hidden_unit_counts = [(kwargs.get(v) or -1) for v in HIDDEN_UNIT_VARS]
        num_non_negative = sum([int(non_negative(n)) for n in hidden_unit_counts])
        debug.trace_fmt(5, "hidden_unit_counts={huc} num_non_negative={nnn}", huc=hidden_unit_counts, nnn=num_non_negative)
        if (num_non_negative > 0):
            hidden_units = hidden_unit_counts
            debug.trace_fmt(4, "Using hidden unit counts from kwarg vars: {hu}", hu=hidden_units)
    if (hidden_units is None):
        hidden_units = DEFAULT_HIDDEN_UNITS
        debug.trace_fmt(2, "Warning: neither HIDDEN_UNITS nor any hidden_unitsN specified so using default: {hu}", hu=hidden_units)

    # Create the model with optional hidden layers
    # TODO: parameterize activation fn
    model = Sequential()
    for (i, hidden_unit_count) in enumerate(hidden_units):
        num_inputs = num_input_features if (i == 0) else None
        model.add(Dense(hidden_unit_count, input_dim=num_inputs, activation="relu"))
    # Add output layer
    if is_binary:
        model.add(Dense(1, activation="sigmoid"))
    else:
        model.add(Dense(num_classes, activation="softmax"))

    # Compile model using Adaptive Moment Estimation (Adam) optimizer and cross-entropy loss function.
    # note: one-hot encoding apparently needed for categorical_crossentropy
    debug.assertion(is_binary or USE_ONE_HOT)
    loss_function = "binary_crossentropy" if is_binary else "categorical_crossentropy"
    model.compile(loss=loss_function, optimizer="adam", metrics=[SCORING_METRIC])
    debug.trace_object(5, model, "model")
    debug.trace_fmt(4, "create_keras_model() => {m}", m=model)

    return model


class MyKerasClassifier(KerasClassifier):
    """Defines a version of KerasClassifier that is not so picky about parameters in order 
    to support a dynamic number of hidden unit variables (i.e., without having to explicitly
    enumerate them as in __init_(self, ..., hidden_units1=-1, ... hidden_units10=-1)."""
    class_name = "MyKerasClassifier"     # TODO: derive via introspection

    def __init__(self, **kwargs):
        """Class constructor: record list off keyword arguments"""
        debug.trace_fmt(5, "{cl}.__init__(kw={kw})", cl=self.class_name, kw=kwargs)
        self.params = list(kwargs.keys())
        ## OLD: super(MyKerasClassifier, self).__init__(**kwargs)
        super().__init__(**kwargs)

    def check_params(self, params):
        ok = (not system.difference(list(params.keys()), self.params))
        debug.trace_fmt(6, "{cl}.check_params({p}) => {r}", cl=self.class_name, p=params, r=ok)
        return ok

#................................................................................

def main():
    """Main entry point for script"""
    # TODO: convert into using main.py's Main class
    data_file = None
    args = system.get_args()
    if ((len(args) > 1) and (args[1] == "--help")):
        script = gh.basename(args[0])
        system.print_stderr("Usage: {scr} [--help] [data-file | -]", scr=script)
        system.print_stderr("")
        system.print_stderr("where data-file is in CSV format and - is for default")
        system.print_stderr("")
        ## TODO: show_details = VERBOSE or debug.debugging()
        if debug.debugging(2):
            ## TODO: add legend
            system.print_stderr("\t" + system.formatted_environment_option_descriptions(include_all=True))
        system.exit("")
    if ((len(args) > 1) and (not args[1].startswith("-"))):
        data_file = args[1]
    debug.trace(4, f"data_file={data_file}")
        
    # load dataset
    # TODO: only skip first row if all symbolic
    ## OLD: headers = system.read_entire_file(DATA_FILE).split("\n")[0].split(FIELD_SEP)
    if data_file is None:
        data_file = gh.resolve_path(DATA_FILE)
    headers = system.read_entire_file(data_file).split("\n")[0].split(FIELD_SEP)
    debug.assertion(all(text_utils.is_symbolic(v) for v in headers))
    ## OLD: dataset = numpy.loadtxt(DATA_FILE, delimiter=FIELD_SEP, skiprows=1)
    ## OLD: data_frame = pandas.read_csv(DATA_FILE, sep=FIELD_SEP)
    data_frame = pandas.read_csv(data_file, sep=FIELD_SEP)
    dataset = data_frame.values
    
    # split into input (X) and output (y) variables
    num_features = (dataset.shape[1] - 1)
    debug.assertion(len(headers) == (num_features + 1))
    debug.assertion(num_features > 1)
    ## OLD: X = dataset[:, 0:num_features]
    X = dataset[:, 0:num_features].astype(float)
    y = dataset[:, num_features]
    if OUTPUT_CSV:
        # TODO: drop pandas index column (first one; no header)
        ## OLD: basename = system.remove_extension(DATA_FILE)
        basename = system.remove_extension(data_file)
        ## BAD:
        ## X.to_csv(basename + "-X.csv", sep=FIELD_SEP)
        ## y.to_csv(basename + "-y.csv", sep=FIELD_SEP)
        ## TODO: rework so that X and y kept as data frames; remove extraneous quotes from headers (e.g., """some field""" => "some field")
        DataFrame(X).to_csv(basename + "-X.csv", header=headers[:-1], sep=FIELD_SEP)
        DataFrame(y).to_csv(basename + "-y.csv", header=headers[-1:], sep=FIELD_SEP)
    ## TEST:
    y = list(y)
    debug.trace_fmtd(7, "X={X}\ny={y}", X=X, y=y)
    y_hash = create_feature_mapping(y)
    num_categories = len(y_hash)

    # Encode class values as integers, using one-hot vectors (i.e., one vector per category).
    symbolic_classes = all(text_utils.is_symbolic(v) for v in y)
    modified_y = y
    if symbolic_classes:
        # TODO: use inverse_transform later when analyzing the results
        encoder = LabelEncoder()
        encoder.fit(modified_y)
        modified_y = encoder.transform(y)
        debug.trace_fmtd(7, "encoded_y={ey}", ey=modified_y)
        
        # Convert integers to dummy variables (i.e,. one hot encoded)
        if USE_ONE_HOT:
            modified_y = np_utils.to_categorical(modified_y)
            debug.trace_fmtd(7, "one_hot_y={ohy}", ohy=modified_y)
        debug.trace_fmtd(8, "modified_y={my}", my=modified_y)

    # Create initial model
    dummy_hidden_unit_params = {v:-1 for v in HIDDEN_UNIT_VARS}
    create_model_fn = lambda: create_keras_model(num_input_features=num_features,
                                                 num_classes=num_categories)
    ## OLD: model = KerasClassifier(build_fn=create_model_fn, verbose=VERBOSITY_LEVEL)
    ## TODO: see why batch_size needed for better accuracy
    # Note: all grid-search parameters need to be specified in the classifier constructor call.
    # Therefore, the hidden units are given -1 values.
    model = MyKerasClassifier(build_fn=create_model_fn, epochs=NUM_EPOCHS, batch_size=BATCH_SIZE,
                              verbose=VERBOSITY_LEVEL, **dummy_hidden_unit_params)
    
    # Run standard classificaion
    # note: Used for comparison against samples/keras_multiclass.py.
    ## OLD: estimator = KerasClassifier(build_fn=baseline_model, epochs=200, batch_size=5, verbose=0)
    if RUN_SAMPLE:
        try:
            kfold = KFold(n_splits=NUM_FOLDS, shuffle=True)
            results = cross_val_score(model, X, modified_y, cv=kfold)
            print("{k}-fold cross validation results:".format(k=NUM_FOLDS))
            print("Baseline: mean={m} stdev={s}; num_epochs={ne} batch_size={bs}".format(
                m=round3(results.mean()), s=round3(results.std()), ne=NUM_EPOCHS, bs=BATCH_SIZE))
        except:
            debug.trace_fmtd(2, "Error: Problem during cross_val_score: {exc}", exc=sys.exc_info())
            debug.raise_exception(6)
    else:
        debug.trace(5, "Skipped sample invocation")

    # Define the grid search parameters and then run the search with all cores and
    # 3-fold cross validation.
    debug.assertion(all(isinstance(v, list) for v in [HIDDEN_UNIT_VALUES, BATCH_SIZE_VALUES, NUM_EPOCH_VALUES]))
    hidden_unit_params = {v: HIDDEN_UNIT_VALUES for v in HIDDEN_UNIT_VARS}
    parameters = {"batch_size": BATCH_SIZE_VALUES,
                  "epochs": NUM_EPOCH_VALUES}
    parameters.update(hidden_unit_params)
    debug.trace_fmt(4, "parameters: {p}", p=parameters)

    ## OLD: grid = RandomizedSearchCV(model, parameters, n_jobs=-1, cv=3)
    # Note: much better results with 10-fold cross validation (vs. 3-fold)
    try:
        if BRUTE_FORCE:
            grid = GridSearchCV(model, parameters, n_jobs=NUM_JOBS, cv=NUM_FOLDS, error_score=0, verbose=VERBOSITY_LEVEL)
        else:
            grid = RandomizedSearchCV(model, parameters, n_jobs=NUM_JOBS, n_iter=NUM_ITERS, cv=NUM_FOLDS, error_score=0, verbose=VERBOSITY_LEVEL)
        ## OLD: grid_result = grid.fit(X, y)
        ## OLD2: grid_result = grid.fit(X, dummy_y)
        grid_result = grid.fit(X, modified_y)
        debug.trace_object(5, grid_result, "grid_result")
    except:
        debug.trace_fmtd(2, "Error: Problem during hyperparameter search: {exc}", exc=sys.exc_info())
        debug.raise_exception(6)

    # Summarize (randomized) parameter search results
    try:
        gridsearch_type = "Randomized" if (not BRUTE_FORCE) else "Brute-force"
        print("{gt} gridsearch results:".format(gt=gridsearch_type))
        ## OLD: print("Best: %f using %s" % (grid_result.best_score_, grid_result.best_params_))
        means = grid_result.cv_results_["mean_test_score"]
        stds = grid_result.cv_results_["std_test_score"]
        params = grid_result.cv_results_["params"]
        best_sorted_keys = sorted(grid_result.best_params_.keys())
        print("Best: {score} using {params}",
              score=grid_result.best_score_,
              params=OrderedDict([(k, params[k]) for k in best_sorted_keys]))
        ## OLD: print("Mean\tStdev\tParam")
        print("Metric\t\tParameters")
        header_spec = "\t".join(["Mean", "Stdev"] + best_sorted_keys)
        print(re.sub("(_units|_size)", "", header_spec))
        for mean, stdev, param in zip(means, stds, params):
            ## OLD: print("{m}\t{s}\t{p}".format(m=round3(mean), s=round3(stdev), p=param))
            param_value_spec = "\t".join([str(param[v]) for v in best_sorted_keys])
            # Hack: make sure parameter names have length < 8 (for proper tabbing)
            # TODO: define mapping with optional user override (e.g., "batch_size=>bsize, hidden_units=> hunits")
            print("{m}\t{s}\t{pvs}".format(m=round3(mean), s=round3(stdev), pvs=param_value_spec))
    except:
        debug.trace_fmtd(2, "Error: Problem during summarization: {exc}", exc=sys.exc_info())
        debug.raise_exception(6)

## TEST
## # Load tensorflow
## import tensorflow as tf                 # pylint: disable=import-outside-toplevel, import-error

## OLD:
## if debug.verbose_debugging():
##     logging_level=tf.compat.v1.logging.DEBUG
##     debug.trace_fmt(1, "setting Tensorflow debug logging (level={ll})", ll=logging_level)
##     tf.compat.v1.logging.set_verbosity(logging_level)
##     tf.compat.v1.logging.debug('tf...logging.debug test')

## TEST
# OLD: Initialize random seed for reproducibility
## numpy.random.seed(SEED)
## tf.set_random_seed(SEED)

#...............................................................................

if __name__ == "__main__":
    main()
