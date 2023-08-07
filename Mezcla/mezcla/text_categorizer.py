#! /usr/bin/env python
#
# Class for text categorizer using Scikit-Learn. See tutorial at
#    http://scikit-learn.org/stable/tutorial/text_analytics/working_with_text_data.html
#
# This includes support for running a few different classifiers. However, for
# more classifiers, panda_sklearn.py should be used, espcially as it includes
# Tensorflow and Keras.
#
# NOTES:
# - Calculates accuracy as number of agreements over number of cases:
#   ex:    (tp + tn) / (tp + tn + fp + fn)    for binary classifications
# - See https://en.wikipedia.org/wiki/Evaluation_of_binary_classifiers#Single_metrics.
# - Also see https://en.wikipedia.org/wiki/Accuracy_and_precision.
# - Keep changes in sync with text_categorizer.py (e.g., XGBoost and GPU options).
# - CherryPy Web server based on following tutorial
#     https://simpletutorials.com/c/2165/How%20to%20Create%20a%20Simple%20JSON%20Service%20with%20CherryPy
#
# TODO:
# - Maintain cache of categorization results.
# - Review categorization code and add examples for clarification of parameters.
# - Fix SHOW_REPORT option for training.
# - Put web server in separate module.
#

"""Text categorization support"""

# Standard packages
from itertools import zip_longest
import os
import re
import sys

# Installed packages
import cherrypy
import numpy
import pandas
from sklearn.base import BaseEstimator, ClassifierMixin
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.feature_extraction.text import _document_frequency
from sklearn.naive_bayes import MultinomialNB
from sklearn.linear_model import SGDClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.svm import SVC
from sklearn.pipeline import Pipeline
from sklearn import metrics
from sklearn.utils.multiclass import unique_labels

# Local packages
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla import misc_utils as misc
from mezcla import system
from mezcla.system import (
    getenv_bool, getenv_float, getenv_int, getenv_text,
)

#................................................................................
# Constants (e.g., environment-based options)

SERVER_PORT = system.getenv_integer("SERVER_PORT", 9010,
                                    "TCP port for web interface")
OUTPUT_BAD = system.getenv_bool("OUTPUT_BAD", False)
CONTEXT_LEN = system.getenv_int("CONTEXT_LEN", 512)
VERBOSE = system.getenv_bool("VERBOSE", False)
OUTPUT_CSV = system.getenv_bool("OUTPUT_CSV", False)
BASENAME = system.getenv_text("BASENAME", "textcat")
OMIT_STOPWORDS = system.getenv_bool("OMIT_STOPWORDS", False,
                                    description="Omit stopwords (e.g., from ngrams)")
CLASS_VAR = getenv_text("CLASS_VAR", "_class_",
                        "Label to use for classification variable")
RETAIN_LABELS = getenv_bool("RETAIN_LABELS", False,
                            "Don't encode class labels")
ENCODE_CLASSES = getenv_bool("ENCODE_CLASSES", not RETAIN_LABELS,
                             "Encode classes using enumeration")
TRACE_IMPORTANCES = getenv_bool("TRACE_IMPORTANCES", False,
                                "Trace feature importances")

# Options for Support Vector Machines (SVM)
#
# Descriptions of the parameters can be found at following page:
#    http://scikit-learn.org/stable/modules/generated/sklearn.svm.SVC.html#sklearn.svm.SVC
# note: defaults used for parameters (n.b., the value None is not usable due to
# sklearn constructor limitations).
USE_SVM = system.getenv_bool("USE_SVM", False)
SVM_KERNEL = system.getenv_text("SVM_KERNEL", "rbf")
SVM_PENALTY = system.getenv_float("SVM_PENALTY", 1.0)
SVM_MAX_ITER = system.getenv_int("SVM_MAX_ITER", -1)
SVM_VERBOSE = system.getenv_bool("SVM_VERBOSE", False)

# Options for Stochastic Gradient Descent (SGD)
#
# Descriptions of the parameters can be found at following page:
#    http://scikit-learn.org/stable/modules/generated/sklearn.linear_model.SGDClassifier.html
# TODO: initialize to None and override only if non-Null
USE_SGD = system.getenv_bool("USE_SGD", False)
SGD_LOSS = system.getenv_text("SGD_HINGE", "hinge")
SGD_PENALTY = system.getenv_text("SGD_PENALTY", "l2")
SGD_ALPHA = system.getenv_float("SGD_ALPHA", 0.0001)
SGD_SEED = system.getenv_float("SGD_SEED", None)
SGD_MAX_ITER = system.getenv_int("SGD_MAX_ITER", 5)
## OLD: SGD_TOLERANCE = system.getenv_float("SGD_TOLERANCE", None)
SGD_VERBOSE = system.getenv_bool("SGD_VERBOSE", False)

# Options for Extreme Gradient Boost (XGBoost)
USE_XGB = system.getenv_bool("USE_XGB", False)
if USE_XGB:
    # pylint: disable=import-outside-toplevel, import-error
    import xgboost as xgb
XGB_BOOSTER = system.getenv_value("XGB_BOOSTER", None)
XGB_USE_GPUS = system.getenv_bool("XGB_USE_GPUS", False)
XGB_VERBOSITY = getenv_int("XGB_VERBOSITY", 0, "Degree of verbosity from 0 to 3")

# Options for Logistic Regression (LR)
# TODO: add regularization
USE_LR = system.getenv_bool("USE_LR", False)

# Options for GPU usage
GPU_DEVICE = system.getenv_value("GPU_DEVICE", None,     # TODO: clarify value to use
                                "Device number for GPU (e.g., shown under nvidia-smi)")

# Options for TFIDF transformation
# Note: these should be None by default to allow for overriding in constructor
# (see TextCategorizer.__init__).
# TODO: add others from sklearn/feature_extraction/text.py
# ex: min/max_df
TFIDF_MAX_TERMS = getenv_int("MAX_TERMS", None,
                             "Maximum number of terms in TF/IDF matrix")
TFIDF_MIN_NGRAM = getenv_int("MIN_NGRAM_SIZE", None)
TFIDF_MAX_NGRAM = getenv_int("MAX_NGRAM_SIZE", None)
TFIDF_MIN_DF = getenv_float("MIN_DF", None)
TFIDF_MAX_DF = getenv_float("MAX_DF", None)
TFIDF_CHAR_NGRAMS = getenv_bool("CHAR_NGRAMS", None)
TFIDF_STOPWORDS = not OMIT_STOPWORDS

# TODO: Options for Naive Bayes (NB), the default
all_use_settings = [USE_SVM, USE_SGD, USE_XGB, USE_LR]
USE_NB = (not any(all_use_settings))
debug.assertion(sum([int(use) for use in all_use_settings]) <= 1)

#................................................................................
# Utility functions

def sklearn_report(actual, predicted, actual_labels, predicted_labels, stream=sys.stdout):
    """Print classification analysis report for ACTUAL vs. PREDICTED indices with original LABELS and using STREAM"""
    stream.write("Performance metrics:\n")
    indices = unique_labels(actual, predicted)
    labels = unique_labels(actual_labels, predicted_labels)
    stream.write(metrics.classification_report(actual, predicted,
                                               labels=indices, target_names=labels))
    stream.write("Confusion matrix:\n")
    # TODO: make showing all cases optional
    confusion = metrics.confusion_matrix(actual, predicted,
                                         labels=indices)
    # TODO: make sure not clipped
    stream.write("{cm}\n".format(cm=confusion))
    debug.trace_object(6, confusion, "confusion")
    return


def create_tabular_file(filename, data):
    """Create tabular FILENAME with SkLearn DATA for use with read_categorization_data"""
    # Note: intended for comparing results here against tutorial (e.g., in ipython shell)
    with system.open_file(filename, "w") as f:
        for i in range(len(data.data)):
            text = system.to_utf8(re.sub("[\t\n]", " ", data.data[i]))
            f.write("{lbl}\t{txt}\n".format(lbl=data.target_names[data.target[i]], txt=text))
    return


def read_categorization_data(filename):
    """Reads table with (non-unique) label and tab-separated value. 
    Note: label made lowercase; result returned as tuple (labels, values)"""
    debug.trace_fmtd(4, "read_categorization_data({f})", f=filename)
    labels = []
    values = []
    with system.open_file(filename) as f:
        for (i, line) in enumerate(f):
            line = system.from_utf8(line)
            items = line.split("\t")
            if len(items) == 2:
                labels.append(items[0].lower())
                values.append(items[1])
            else:
                debug.trace_fmtd(4, "Warning: Ignoring item w/ unexpected format at line {num}: items: len={l} first={f} second={s}",  l=len(items), f=gh.elide(items[0]), s=gh.elide(items[0]),
                                 num=(i + 1))
    debug.trace_values(7, zip(labels, values), "table")
    return (labels, values)


def int_if_whole(num):
    """Return integral type if NUM is a whole number"""
    # EX: int_if_whole(2.0) => 2
    # EX: int_if_whole(2.999) => 2.999
    result = int(num) if (round(num) == num) else num
    debug.trace_fmt(7, "int_if_whole({n}) => {r}", n=num, r=result)
    return result


def param_or_default(param_value, default_value):
    """Returns PARAM_VALUE if non-null else DEFAULT_VALUE"""
    # Note: this avoid awkward initialization sequences in constructor
    # - verbose version:
    #   if param_value in None:
    #      param_value = default_value
    #   self.member = param_value
    # - long-line version
    #   self.member = param_value if (param_value is not None) else default_value
    # - streamlined version
    #   self.member = param_or_default(param, default)
    result = param_value if (param_value is not None) else default_value
    return result

#...............................................................................

class ClassifierWrapper(BaseEstimator, ClassifierMixin):
    """Wrapper around arbitrary categorizer object, originally used for the sake of tracing the feature vectors derived via pipelines"""
    ## TODO: rework by specializing one classifier (e.g., MultinomialNB) so that fit() only needs to be defined

    def __init__(self, classifier):
        """Constructor: records CLASSIFIER"""
        debug.trace_fmt(6, "{cl}.__init__(clf={c})", c=classifier, cl=str(type(self)))
        self.classifier = classifier
        self.tfidf_vectorizer = None

    def _get_param_names(self):
        """Get parameter names for the estimator"""
        # TODO: drop method
        # Note: This is not class method as in BaseEstimator.
        # pylint: disable=protected-access
        return self.classifier._get_param_names()

    def get_params(self, deep=True):
        """Return list of parameters supported"""
        return self.classifier.get_params(deep=deep)

    def fit(self, training_x=None, training_y=None):
        """Delegates fit() invocation to classifier, after outputing CSV if desired"""
        if OUTPUT_CSV:
            self.output_csv(training_x, training_y, BASENAME)
        if TRACE_IMPORTANCES:
            debug.trace_fmt(1, "Feature importances: {imp}",
                            imp=self.extract_feature_importance())
        ## DEBUG: debug.trace_object(6, self.tfidf_vectorizer)
            
        return self.classifier.fit(training_x, training_y)

    def predict(self, sample):
        """Return predicted class for each SAMPLE (returning vector)"""
        if OUTPUT_CSV:
            self.output_csv(sample, (["n/a"] * sample.shape[0]), BASENAME + ".test")
        return self.classifier.predict(sample)

    def score(self, X, y, sample_weight=None):
        """Return average accuracy of prediction of X matrix vs Y vector"""
        return self.classifier.score(X, y, sample_weight=sample_weight)
    
    def predict_proba(self, sample):
        """Return probabilities of outcome classes predicted for each SAMPLE (returning matrix)"""
        return self.classifier.predict_proba(sample)

    def output_csv(self, x, y, basename):
        """Output features in X and Y to BASENAME.csv"""
        # TODO: move into TextCategorizer; put pickle and IDF support in separate method
        debug.trace(6, f"output_csv(_, _, {basename}); self={self}")
        debug.reference_var(self)

        ## NOTE: save in pickle format for debugging
        if debug.verbose_debugging():
            system.save_object(basename + ".x.csv.pickle", x)
            system.save_object(basename + ".y.csv.pickle", y)
        ##
        df_x = pandas.DataFrame(x.toarray())
        df_y = pandas.DataFrame(y)
        
        ## HACK: use global pipeline to get feature names
        def normalize(feature_name):
            """Normalize FEATURE_NAME"""
            return feature_name.replace(" ", "_")
        ##
        features = [normalize(f) for f in self.tfidf_vectorizer.get_feature_names()]
        df_x.to_csv(basename + ".x.csv.list", header=features, index=False)
        df_y.to_csv(basename + ".y.csv.list", header=[CLASS_VAR], index=False)
        gh.run("paste --delimiters=',' {b}.x.csv.list {b}.y.csv.list > {b}.csv.list",
               b=basename)
        # TODO: combine into single dataframe and use to_csv over that; use .csv instead of .csv.list (and make sure not to overwrite)
        debug.assertion(system.file_exists(basename + ".csv.list"))

        # Trace out the IDF values
        ## TODO: debug.trace_value(6, zip(features, tfidf_vectorizer._idf_diag), "ngram idf's")
        if debug.debugging(6):
            # pylint: disable=protected-access
            df = _document_frequency(x)
            sorted_features = sorted(zip(features, self.tfidf_vectorizer.idf_, df),
                                     key=lambda f_idf: f_idf[1], reverse=True)
            debug.trace_values(6, sorted_features, "ngram idf's & df's")
        return
    
    def extract_feature_importance(self):
        """Returns list of (name, weight) for important features"""
        # TODO: move into TextCategorizer
        debug.trace(6, f"extract_feature_importance(); self={self}")
        result = []
        try:
            feature_names = (self.tfidf_vectorizer.get_feature_names() or [])
            sorted_scores = sorted(zip_longest(feature_names, self.classifier.feature_importances_,  fillvalue="F?"),
                                   key=lambda name_score: name_score[1],
                                   reverse=True)
            result = [(f, s) for (f, s) in sorted_scores if s > 0]
        except:
            system.print_exception_info("extract_feature_importance")
        debug.trace(5, f"extract_feature_importance() => {result}")
        return result

#...............................................................................

class TextCategorizer(object):
    """Class for building text categorization"""
    # TODO: add cross-fold validation support; make TF/IDF weighting optional

    def __init__(self, tfidf_max_terms=None, tfidf_min_ngram=None, tfidf_max_ngram=None, tfidf_min_df=None, tfidf_max_df=None, tfidf_stopwords=None, tfidf_char_ngrams=None):
        """Class constructor: initializes classifier and text categoriation pipeline"""
        debug.trace_fmtd(4, "tc.__init__(); self=={s}", s=self)
        self.tfidf_max_terms = param_or_default(tfidf_max_terms, TFIDF_MAX_TERMS)
        self.tfidf_min_ngram = param_or_default(tfidf_min_ngram, TFIDF_MIN_NGRAM)
        self.tfidf_max_ngram = param_or_default(tfidf_max_ngram, TFIDF_MAX_NGRAM)
        self.tfidf_min_df = param_or_default(tfidf_min_df, TFIDF_MIN_DF)
        self.tfidf_max_df = param_or_default(tfidf_max_df, TFIDF_MAX_DF)
        self.tfidf_stopwords = param_or_default(tfidf_stopwords, TFIDF_STOPWORDS)
        self.tfidf_char_ngrams = param_or_default(tfidf_char_ngrams, TFIDF_CHAR_NGRAMS)
        ## TODO: self.member = param_or_default(xyz, XYZ)
        #
        self.keys = []
        self.classifier = None
        classifier = None

        # Derive classifier based on user options
        if USE_SVM:
            classifier = SVC(kernel=SVM_KERNEL,
                             C=SVM_PENALTY,
                             max_iter=SVM_MAX_ITER,
                             verbose=SVM_VERBOSE)
        elif USE_SGD:
            classifier = SGDClassifier(loss=SGD_LOSS,
                                       penalty=SGD_PENALTY,
                                       alpha=SGD_ALPHA,
                                       random_state=SGD_SEED,
                                       ## TODO: max_iter=SGD_MAX_ITER,
                                       verbose=SGD_VERBOSE)
            ## HACK: support old version and new (thanks sklearn!)
            ## TODO: make sure this won't break (e.g., due to visibility)
            num_iter_attribute = "max_iter"
            if (not hasattr(classifier, num_iter_attribute)):
                num_iter_attribute = "n_iter"
            debug.assertion(hasattr(classifier, num_iter_attribute))
            setattr(classifier, num_iter_attribute, SGD_MAX_ITER)
        elif USE_XGB:
            # TODO: rework to just define classifier here and then pipeline at end.
            # in order to eliminate redundant pipeline-specification code.
            # TODO: n_jobs=-1
            misc_xgb_params = {'booster': XGB_BOOSTER, 'verbosity': XGB_VERBOSITY}
            if XGB_USE_GPUS:
                misc_xgb_params.update({'tree_method': 'gpu_hist'})
                misc_xgb_params.update({'predictor': 'gpu_predictor'})
            if GPU_DEVICE:
                misc_xgb_params.update({'gpu_id': GPU_DEVICE})
            debug.trace_fmt(4, 'misc_xgb_params={m}', m=misc_xgb_params)
            classifier = xgb.XGBClassifier(**misc_xgb_params)
        elif USE_LR:
            classifier = LogisticRegression()
        else:
            debug.assertion(USE_NB)
            classifier = MultinomialNB()
        use_classifier_wrapper = (OUTPUT_CSV or TRACE_IMPORTANCES)
        if use_classifier_wrapper:
            classifier = ClassifierWrapper(classifier)
            debug.trace_fmt(4, "Using wrapper ({cl}) for feature tracing hooks", cl=type(classifier))

        # Add classifier to text categorization pipeline]
        tfidf_parameters = {}
        if self.tfidf_max_terms:
            ## TODO: sort by TF/IDF (not TF)
            tfidf_parameters['max_features'] = self.tfidf_max_terms
        if self.tfidf_min_ngram or self.tfidf_max_ngram:
            min_ngram = (self.tfidf_min_ngram or 1)
            max_ngram = (self.tfidf_max_ngram or 1)
            debug.assertion(1 <= min_ngram <= max_ngram)
            tfidf_parameters['ngram_range'] = (min_ngram, max_ngram)
        if self.tfidf_min_df:
            tfidf_parameters['min_df'] = int_if_whole(self.tfidf_min_df)
        if self.tfidf_max_df:
            tfidf_parameters['max_df'] = int_if_whole(self.tfidf_max_df)
        if not self.tfidf_stopwords:
            tfidf_parameters['stop_words'] = 'english'
        if self.tfidf_char_ngrams:
            tfidf_parameters['analyzer'] = 'char'
        self.cat_pipeline = Pipeline(
            [('tfidf', TfidfVectorizer(**tfidf_parameters)),
             ('clf', classifier)])
        if use_classifier_wrapper:
            pipeline_steps = list(self.cat_pipeline._iter())
            debug.assertion(pipeline_steps[0][1] == 'tfidf')
            ## TODO: classifier.tfidf_vectorizer = self.cat_pipeline['tfidf']
            classifier.tfidf_vectorizer = pipeline_steps[0][2]
        debug.trace_object(5, self, "TextCategorizer")
        return

    def train(self, filename):
        """Train classifier using tabular FILENAME with label and text"""
        debug.trace_fmtd(4, "tc.train({f})", f=filename)
        (labels, values) = read_categorization_data(filename)
        label_values = labels
        self.keys = sorted(numpy.unique(labels))
        debug.trace_expr(5, self.keys)
        if ENCODE_CLASSES:
            label_indices = [self.keys.index(l) for l in labels]
            label_values = label_indices
        self.classifier = self.cat_pipeline.fit(values, label_values)
        debug.trace_object(7, self, "TextCategorizer")
        return

    def test(self, filename, report=False, stream=sys.stdout):
        """Test classifier over tabular data from FILENAME with label and text, returning accuracy. Optionally, a detailed performance REPORT is output to STREAM."""
        debug.trace_fmtd(4, "tc.test({f})", f=filename)
        (all_labels, all_values) = read_categorization_data(filename)
        debug.trace_values(6, all_labels, "all_labels")
        debug.trace_values(6, [gh.elide(v) for v in all_values], "all_values")

        # Prune cases with classes not in training data
        # TODO: use hash of positions
        actual_indices = []
        values = []
        labels = []
        for (i, label) in enumerate(all_labels):
            if label in self.keys:
                values.append(all_values[i])
                actual_indices.append(self.keys.index(label))
                labels.append(label)
            else:
                debug.trace_fmtd(4, "Ignoring test label {l} not in training data (line {n})",
                                 l=label, n=(i + 1))

        # Perform classification and determine accuracy
        predicted_values = self.classifier.predict(values)
        if ENCODE_CLASSES:
            predicted_indices = predicted_values
        else:
            predicted_indices = [self.keys.index(label) for label in predicted_values]
        debug.assertion(len(actual_indices) == len(predicted_indices))
        debug.trace_values(6, actual_indices, "actual")
        debug.trace_values(6, predicted_indices, "predicted")
        ## TODO: predicted_labels = [self.keys[i] for i in predicted_indices]
        num_ok = sum([(actual_indices[i] == predicted_indices[i]) for i in range(len(actual_indices))])
        accuracy = float(num_ok) / len(values)

        # Output classification report
        if report:
            debug.assertion(VERBOSE)
            if VERBOSE:
                stream.write("Missed classifications")
                stream.write("\n")
                stream.write("Actual\tPredict\n")
                ## TODO: complete conversion to using actual_index (here and below)
                num_missed = 0
                for (i, actual_index) in enumerate(actual_indices):
                    debug.assertion(actual_index == actual_indices[i])
                    if (actual_indices[i] != predicted_indices[i]):
                        stream.write("{act}\t{pred}\n".
                                     format(act=self.keys[actual_indices[i]],
                                            pred=self.keys[predicted_indices[i]]))
                        num_missed += 1
                if (num_missed == 0):
                    stream.write("n/a")
                stream.write("\n")
            actual_labels = [self.keys[i] for i in actual_indices]
            predicted_labels = [self.keys[i] for i in predicted_indices]
            sklearn_report(actual_indices, predicted_indices, actual_labels, predicted_labels, stream)

        # Show cases not classified OK
        if OUTPUT_BAD:
            bad_instances = "Actual\tBad\tText\n"
            # TODO: for (i, actual_index) in enumerate(actual_indices)
            for (i, actual_index) in enumerate(actual_indices):
                debug.assertion(actual_index == actual_indices[i])
                if (actual_indices[i] != predicted_indices[i]):
                    text = values[i]
                    context = (text[:CONTEXT_LEN] + "...\n") if (len(text) > CONTEXT_LEN) else text
                    # TODO: why is pylint flagging the format string as invalid?
                    bad_instances += "{g}\t{b}\t{t}\n".format(
                        g=self.keys[actual_indices[i]],
                        b=self.keys[predicted_indices[i]],
                        t=context)
            bad_filename = filename + ".bad"
            system.write_file(bad_filename, bad_instances)
            debug.trace_fmt(4, "Result ({f}):\n{r}", f=bad_filename, r=system.read_file(bad_filename))
        return accuracy

    def categorize(self, text):
        """Return category for TEXT"""
        debug.trace(4, "tc.categorize(_)")
        debug.trace_fmtd(6, "\ttext={t}", t=text)
        index = self.classifier.predict([text])[0]
        label = self.keys[index]
        debug.trace_fmtd(6, "categorize() => {r}", r=label)
        return label

    def class_probabilities(self, text):
        """Return probability distribution for TEXT"""
        debug.trace(4, "tc.class_probabilities(_)")
        debug.trace_fmtd(6, "\ttext={t}", t=text)
        class_names = self.keys
        class_probs = self.classifier.predict_proba([text])[0]
        debug.trace_object(7, self.classifier)
        debug.trace_fmtd(6, "class_names: {cn}\nclass_probs: {cp}", cn=class_names, cp=class_probs)
        sorted_scores = misc.sort_weighted_hash(dict(zip(class_names, class_probs)))
        dist=" ".join([(k + ": " + system.round_as_str(s)) for (k, s) in sorted_scores])
        debug.trace_fmtd(5, "class_probabilities() => {r}", r=dist)
        return dist

    def save(self, filename):
        """Save classifier to FILENAME"""
        debug.trace_fmtd(4, "tc.save({f})", f=filename)
        system.save_object(filename, [self.keys, self.classifier])
        return

    def load(self, filename):
        """Load classifier from FILENAME"""
        debug.trace_fmtd(4, "tc.load({f})", f=filename)
        try:
            (self.keys, self.classifier) = system.load_object(filename)
        except (TypeError, ValueError):
            system.print_stderr("Problem loading classifier from {f}: {exc}".
                                format(f=filename, exc=sys.exc_info()))
        return

#-------------------------------------------------------------------------------
# CherryPy Web server based on following tutorial
#     https://simpletutorials.com/c/2165/How%20to%20Create%20a%20Simple%20JSON%20Service%20with%20CherryPy
#

# Constants
TRUMP_TEXT = "Donald Trump was President."
DOG_TEXT = "My dog has fleas."

#--------------------------------------------------------------------------------
# Utility function(s)

def format_index_html(base_url=None):
    """Formats a simple HTML page illustrating the categorize and class_probabilities API calls,
    Note: BASE_URL provides the server URL (e.g., http://www.my-categorizer.com:9999)"""
    debug.trace(5, f"format_index_html(base_url={base_url})")
    # TODO: parameterize template generation (e.g., to facilitate usage in derived classes of web_controller
    if (base_url is None):
        base_url = "http://127.0.0.1"
    if (base_url.endswith("/")):
        base_url = system.chomp(base_url, "/")

    # Create index page template with optional examples for debugging
    html_template = """
    <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
    <html lang="en">
        <head>
            <meta content="text/html; charset=UTF-8" http-equiv="content-type">
            <title>Text categorizer</title>
        </head>
        <body>
            Try <a href="categorize">categorize</a> and <a href="class_probabilities">class_probabilities</a>.<br>
            note: You need to supply the <i><b>text</b></i> parameter.<br>
            <br>
            Examples:
            <ul>
                <li>Category for <a href="categorize?text={quoted_trump_text}">"{trump_text}"</a>:<br>
                    {indent}<code>{base_url}/categorize?text={quoted_trump_text}</code>
                </li>
    
                <li>Probability distribution for <a href="class_probabilities?text={quoted_dog_text}">"{dog_text}"</a>:<br>
                    {indent}<code>{base_url}/class_probabilities?text={quoted_dog_text}</code>
                </li>
            </ul>
    """

    if debug.detailed_debugging():
        html_template += """
            <!-- <p> -->
            Other examples (n.b., debug only):
            <ul>
                <li><a href="shutdown">Shutdown</a> the server:<br>
                    {indent}<code>{base_url}/shutdown</code>
                </li>

                <li>Alias for <a href="index">this index page</a>:<br>
                    {indent}<code>{base_url}/index</code>
                </li> 
            </ul>
        """
    #
    # TODO: define text area dimensions based on browser window size
    html_template += """
            <!-- Form for entering text for categorization -->
            <hr>
            <form action="{base_url}/categorize" method="get">
                <label for="textarea1">Categorize</label>
                <br>
                <textarea id="textarea1" rows="10" cols="100" name="text"></textarea>
                <br>
                <input type="submit">
            </form>
            
        </body>
    </html>
    """

    #
    # TODO: define text area dimensions based on browser window size
    html_template += """
            <!-- Form for entering text for categorization -->
            <hr>
            <form action="{base_url}/probs" method="get">
                <label for="textarea1">Probabilities</label>
                <br>
                <textarea id="textarea1" rows="10" cols="100" name="text"></textarea>
                <br>
                <input type="submit">
            </form>
            
        </body>
    </html>
    """

    # Resolve template into final HTML
    index_html = html_template.format(base_url=base_url,
                                      indent="&nbsp;&nbsp;&nbsp;&nbsp;",
                                      trump_text=TRUMP_TEXT,
                                      quoted_trump_text=system.quote_url_text(TRUMP_TEXT),
                                      dog_text=DOG_TEXT,
                                      quoted_dog_text=system.quote_url_text(DOG_TEXT))
    return index_html

#................................................................................
# Main class

class web_controller(object):
    """Controller for CherryPy web server with embedded text categorizer"""
    
    def __init__(self, model_filename, *args, **kwargs):
        """Class constructor: initializes search engine server"""
        debug.trace_fmtd(5, "web_controller.__init__(s:{s}, a:{a}, kw:{k})__",
                         s=self, a=args, k=kwargs)
        self.text_cat = TextCategorizer()
        self.text_cat.load(model_filename)
        return

    @cherrypy.expose
    def index(self, **kwargs):
        """Website root page (e.g., web site overview and link to search)"""
        # TODO: add way to override URL (e.g., to force use of known local hostname instead of "localhost")
        debug.trace_fmtd(5, "wc.index(s:{s}, kw:{kw})", s=self, kw=kwargs)
        base_url = cherrypy.url('/')
        debug.trace_fmt(4, "base_url={b}", b=base_url)
        index_html = format_index_html(base_url)
        debug.trace_fmt(6, "html={{\n{h}\n}}", h=index_html)
        return index_html

    @cherrypy.expose
    def categorize(self, text, **kwargs):
        """Infer category for TEXT"""
        debug.trace_fmtd(5, "wc.categorize(s:{s}, _, kw:{kw})", s=self, kw=kwargs)
        return self.text_cat.categorize(text)

    @cherrypy.expose
    def class_probabilities(self, text, **kwargs):
        """Get category probability distribution for TEXT"""
        debug.trace_fmtd(5, "wc.class_probabilities(s:{s}, _, kw:{kw})", s=self, kw=kwargs)
        return self.text_cat.class_probabilities(text)
    #
    probs = class_probabilities

    @cherrypy.expose
    def stop(self, **kwargs):
        """Stops the web search server and saves cached data to disk.
        Note: The command is ignored if not debugging."""
        debug.trace_fmtd(5, "wc.stop(s:{s}, kw:{kw})", s=self, kw=kwargs)
        # TODO: replace stooges with your real server nicknames
        if ((not debug.detailed_debugging()) and (os.environ.get("HOST_NICKNAME") in ["curly", "larry", "moe"])):
            return "Call security!"
        # TODO: Straighten out shutdown quirk (seems like two invocations required).
        # NOTE: Putting exit before stop seems to do the trick. However, it might be
        # the case that the server shutdown.
        cherrypy.engine.exit()
        cherrypy.engine.stop()
        # TODO: Use HTML so shutdown shown in title.
        return "Adios"

    # alias for stop
    shutdown = stop
    # TODO: track down delay in python process termination


def start_web_controller(model_filename):
    """Start up the CherryPy controller for categorization via MODEL_FILENAME
    Note: The function blocks until server is shutdown"""
    debug.trace(5, "start_web_controller()")

    # Load in CherryPy configuration
    # TODO: use external configuration file
    conf = {
        '/': {
            'tools.sessions.on': True,
            'tools.staticdir.root': os.path.abspath(os.getcwd()),
            ## notes: avoids cross-origin type errrors
            'tools.response_headers.on': True,
            'tools.response_headers.headers': [
                ## TODO: just allow the same host
                ('Access-Control-Allow-Origin', '*'),
            ]
        },
        'global': {
            'server.socket_host': "0.0.0.0",
            'server.socket_port': SERVER_PORT,
            'server.thread_pool': 10,
            }
        }

    # Start the server
    # TODO: trace out all configuration settings
    debug.trace_values(4, cherrypy.response.headers, "default response headers")
    textcat_controller = web_controller(model_filename)
    debug.trace_expr(4, textcat_controller.text_cat.keys)
    cherrypy.quickstart(textcat_controller, config=conf)
    # Note: the following call blocks
    cherrypy.engine.start()
    return


#------------------------------------------------------------------------
# Entry point

def main(args):
    """Supporting code for command-line processing"""
    debug.trace_fmtd(6, "main({a})", a=args)
    # HACK: ignore --tag label (n.b., used for killing via process regex)
    if ((len(args) > 0) and (args[1] == "--tag")):
        args[1:] = args[3:]
    if ((len(args) != 2) or (args[1] == "--help")):
        system.print_stderr("Usage: {p} model".format(p=args[0]))
        return
    model = args[1]
    start_web_controller(model)
    return

if __name__ == '__main__':
    main(sys.argv)
