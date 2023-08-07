#! /usr/bin/env python
#
# Based on following:
# - Jason Brownlee's blog:
#   https://machinelearningmastery.com/feature-importance-and-feature-selection-with-xgboost-in-python
# - Earlier sklearn scripts:
#   ex: pandas_sklearn.py
#
# Note: another buggy blog.
#

"""Feature Importance and Feature Selection With XGBoost"""

# Standard packages
import re

# Installed packages
# use feature importance for feature selection, with fix for xgboost 1.0.2
## OLD: from numpy import loadtxt
from matplotlib import pyplot as plt
import numpy as np
import xgboost
from xgboost import XGBClassifier
from xgboost import plot_importance
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
from sklearn.feature_selection import SelectFromModel

# Local packages
from mezcla import data_utils as du
from mezcla import debug
from mezcla import glue_helpers as gh
## OLD
## from mezcla.main import Main
## from mezcla.main import dummy_app
from mezcla import system
from mezcla.system import getenv_bool, getenv_float, getenv_int, getenv_text, getenv_value

# Runtime options
USE_WRAPPER_DEFAULT = re.search(r"^1.0", getattr(xgboost, "__version__", "???"))
USE_WRAPPER = getenv_bool("USE_WRAPPER", USE_WRAPPER_DEFAULT,
                          "Use wrapper for XGBClassifier to work around old bug")
USE_LOADTXT = getenv_bool("USE_LOADTXT", False,
                          "Use Numpy's loadtxt to read data")
USE_DATAFRAME = getenv_bool("USE_DATAFRAME", not USE_LOADTXT,
                            "Retain data in Pandas dataframe format")
SKLEARN_PLOT = getenv_bool("SKLEARN_PLOT", False,
                           "Output sklearn-based plot")
XGBOOST_PLOT = getenv_bool("XGBOOST_PLOT", False,
                           "Use Xgboost version of plot")
INTERACTIVE_PLOT =  getenv_bool("INTERACTIVE_PLOT", False,
                                "Show interactive plot")
DEFAULT_DATAFILE = getenv_text("DATA_FILE", "pima-indians-diabetes.csv")
DEFAULT_OUTPUT_BASE = getenv_value("OUTPUT_BASE", "")
RANDOM_SEED = getenv_int("RANDOM_SEED", 7,
                         "Seed for random number generator")
TEST_PERCENT = getenv_float("TEST_PERCENT", 0.33,
                            "Percentage (n.b., ratio) of data for test set")
DUMP_MODEL = getenv_bool("DUMP_MODEL", False,
                         "Dump model tree(s) with split statistics")
FORCE_FLOAT = getenv_bool("FORCE_FLOAT", False,
                          "Force input daya to be floating point")

# define custom class to fix bug in xgboost 1.0.2
class MyXGBClassifier(XGBClassifier):
    """wrapper class"""
    
    @property
    def coef_(self):
        """coefficient for feature importance"""
        ## BAD: return None
        return self.feature_importances_

def main():
    """Entry point"""
    data_filename = 'pima-indians-diabetes.csv'

    # Check command line arguments
    args = system.get_args()
    show_help = ((len(args) > 1) and (args[1] == "--help"))
    show_usage = ((len(args) > 1) and (args[1] == "--usage"))
    if ((len(args) <= 1) or show_help or show_usage):
        script = gh.basename(args[0])
        system.print_stderr("Usage: {scr} [--help | --usage] [data-file | -]", scr=script)
        system.print_stderr("")
        system.print_stderr("Notes:")
        system.print_stderr("- Use - for data-file to use default.")
        system.print_stderr("- Where data-file is in CSV format (or TSV)")
        ## TODO: show_details = VERBOSE or debug.debugging()
        debugging = debug.detailed_debugging()
        if (show_help or debugging):
            ## TODO: add legend
            system.print_stderr("- Environment options:")
            system.print_stderr("\t" + system.formatted_environment_option_descriptions(include_all=debugging))
        system.exit("")
    
    if ((len(args) > 1) and (not args[1].startswith("-"))):
        data_filename = args[1]
    debug.trace(4, f"data_file={data_filename}")
    if data_filename is None:
        data_filename = DEFAULT_DATAFILE
    output_base = DEFAULT_OUTPUT_BASE
    if not output_base:
        output_base = system.remove_extension(data_filename)

    # load data
    ## OLD: data_path = gh.resolve_path('pima-indians-diabetes.csv')
    ## TODO: strip comment line
    data_path = gh.resolve_path(data_filename)
    ## if re.search(r"[A-Za-z]", gh.run("head -1 {data_path}")):
    ##     debug.trace(4, f"Note: stripping header from {data_path}")
    ##     ## dummy_app = Main([])
    ##     gh.run(gh.run("tail --lines=+2 {data_path} > {dummy_app.temp_file}"))
    ##     data_path = dummy_app.temp_file
    ## OLD: dataset = loadtxt(data_path, delimiter=",")
    if USE_LOADTXT:
        dataset = np.loadtxt(data_path, delimiter=",", skiprows=1)
        labels = [f"_F{i + 1}" for i in range(dataset.shape[1])]
    else:
        in_dtype = None if not FORCE_FLOAT else np.float64
        dataset = du.read_csv(data_path, delimiter=",", dtype=in_dtype)
        labels = list(dataset.columns)
        if not USE_DATAFRAME:
            dataset = dataset.values    # pylint: disable=no-member

    class_col = (len(labels) - 1)
    class_var = labels[class_col]
    feature_labels = labels[0: class_col]
    debug.trace_expr(5, dataset, labels, class_col, delim='\n')

    # split data into X and y
    if USE_DATAFRAME:
        X = dataset[feature_labels]
        Y = dataset[[class_var]]
    else:
        X = dataset[:, 0: class_col]
        Y = dataset[:, class_col]
    #
    # split data into train and test sets
    debug.assertion(0 < TEST_PERCENT < 1)
    X_train, X_test, y_train, y_test = train_test_split(
        X, Y, test_size=TEST_PERCENT, random_state=RANDOM_SEED)
    debug.trace_expr(6, X_train, X_test, y_train, y_test)
    
    # Fit model on all training data proper
    classifier = (XGBClassifier if (not USE_WRAPPER) else MyXGBClassifier)
    ## OK:
    model = classifier()
    ## TEST: model = classifier(feature_names=labels)
    ## OK:
    model.fit(X_train, y_train)
    ## TEST:
    ## dtrain = xgboost.DMatrix(X_train, label=y_train, feature_names=feature_labels)
    ## model = xgboost.train({}, dtrain)
    debug.trace_object(6, model, "model")

    # Optionally dump out the tree(s) in the model
    if DUMP_MODEL:
        model.get_booster().dump_model(f"{output_base}-model-dump.list",
                                       with_stats=True)

    # Optionally plot the feature importance values
    if SKLEARN_PLOT:
        plt.bar(range(len(model.feature_importances_)),
                model.feature_importances_, tick_label=feature_labels)
        plt.title("Feature importances")
        plt.figtext(0, 0, "dataset: " + data_filename)
        if INTERACTIVE_PLOT:
            plt.show()
        else:
            plt.savefig(f"{output_base}-sklearn.png")
    if XGBOOST_PLOT:
        # note: based on https://stackoverflow.com/questions/46943314/xgboost-plot-importance-doesnt-show-feature-names
        ## TODO:plot_importance(model).set_yticklabels(feature_labels)
        ## TEST: model.feature_names = feature_labels
        ## model.feature_types = None
        ## TEST: model.feature_names = labels
        ## model.get_booster().feature_names = labels
        ## plot_importance(model.get_booster())
        ## SO-SO: plot_importance(model)
        ax = plot_importance(model)
        ## OK???: ax.set_yticklabels(feature_labels)
        debug.trace_object(6, ax, "plot axis")
        plt.figtext(0, 0, "dataset: " + data_filename)
        if INTERACTIVE_PLOT:
            plt.show()
        else:
            plt.savefig(f"{output_base}-xgb.png")

    # make predictions for test data and evaluate
    predictions = model.predict(X_test)
    accuracy = accuracy_score(y_test, predictions)
    print("Accuracy: %.2f%%" % (accuracy * 100.0))

    # Fit model using each importance as a threshold
    ## TODO: debug.trace_expr(4, zip(labels, model.feature_importances_))
    debug.trace_expr(4, labels, model.feature_importances_, delim="\n")
    thresholds = np.sort(model.feature_importances_)
    for thresh in thresholds:
        # select features using threshold
        selection = SelectFromModel(model, threshold=thresh, prefit=True)
        select_X_train = selection.transform(X_train)

        # train model
        selection_model = XGBClassifier()
        selection_model.fit(select_X_train, y_train)
        #
        # eval model
        select_X_test = selection.transform(X_test)
        predictions = selection_model.predict(select_X_test)
        accuracy = accuracy_score(y_test, predictions)

        # summarize
        print("Thresh=%.3f, n=%d, Accuracy: %.2f%%" % (thresh, select_X_train.shape[1], accuracy*100.0))
            
#-------------------------------------------------------------------------------

if __name__ == "__main__":
    main()
