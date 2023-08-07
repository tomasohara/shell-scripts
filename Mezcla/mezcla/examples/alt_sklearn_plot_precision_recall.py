#! /usr/bin/env python
#
# Example of how to plot multiclass precision/recall curves with sklearn
# (via "binarizing" of output).
#
# Notes:
# - Based on https://stackoverflow.com/questions/56090541/how-to-plot-precision-and-recall-of-multiclass-classifier.
# - Also see https://scikit-learn.org/1.0/auto_examples/model_selection/plot_precision_recall.html.
#
# TODO:
# - Have option to take confusion matrix as input (e.g., to reproduce Vertex AI results).
#...............................................................................
# Original example from Stack Overflow:
#
# 1. general settings, learning and prediction
# 
#   from sklearn.datasets import fetch_mldata
#   from sklearn.model_selection import train_test_split
#   from sklearn.ensemble import RandomForestClassifier
#   from sklearn.multiclass import OneVsRestClassifier
#   from sklearn.metrics import precision_recall_curve, roc_curve
#   from sklearn.preprocessing import label_binarize
#
#   import matplotlib.pyplot as plt
#   #%matplotlib inline
#
#   mnist = fetch_mldata("MNIST original")
#   n_classes = len(set(mnist.target))
#
#   Y = label_binarize(mnist.target, classes=[*range(n_classes)])
#
#   X_train, X_test, y_train, y_test = train_test_split(mnist.data,
#                                                       Y,
#                                                       random_state = 42)
#
#   clf = OneVsRestClassifier(RandomForestClassifier(n_estimators=50,
#                                max_depth=3,
#                                random_state=0))
#   clf.fit(X_train, y_train)
#
#   y_score = clf.predict_proba(X_test)
# 2. precision-recall curve
# 
#   # precision recall curve
#   precision = dict()
#   recall = dict()
#   for i in range(n_classes):
#       precision[i], recall[i], _ = precision_recall_curve(y_test[:, i],
#                                                           y_score[:, i])
#       plt.plot(recall[i], precision[i], lw=2, label='class {}'.format(i))
#
#   plt.xlabel("recall")
#   plt.ylabel("precision")
#   plt.legend(loc="best")
#   plt.title("precision vs. recall curve")
#   plt.show()
#   enter image description here
#
# 3. ROC curve
#
#   # roc curve
#   fpr = dict()
#   tpr = dict()
#
#   for i in range(n_classes):
#       fpr[i], tpr[i], _ = roc_curve(y_test[:, i],
#                                     y_score[:, i]))
#       plt.plot(fpr[i], tpr[i], lw=2, label='class {}'.format(i))
#
#   plt.xlabel("false positive rate")
#   plt.ylabel("true positive rate")
#   plt.legend(loc="best")
#   plt.title("ROC curve")
#   plt.show()
#
#...............................................................................
#
"""Example from https://stackoverflow.com/questions/56090541/how-to-plot-precision-and-recall-of-multiclass-classifier"""

# Standard packages
import re

# Installed packages
import pandas as pd
from sklearn.datasets import fetch_openml
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.multiclass import OneVsRestClassifier
from sklearn.metrics import precision_recall_curve, roc_curve
from sklearn.preprocessing import label_binarize
#
from mezcla import data_utils as du
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.main import Main
from mezcla import system
from mezcla import text_utils

# Constants
DATASET_NAME = system.getenv_text("DATASET_NAME", "mnist_784",
                                  ## TODO: "MNIST ???" (see https://www.openml.org/d/554)
                                  "Name of OpenML dataset or basename of local CSV file")
USE_OPENML_DEFAULT = not system.file_exists(DATASET_NAME)
USE_OPENML = system.getenv_bool("USE_OPENML", USE_OPENML_DEFAULT,
                                "Whether DATASET_NAME refers to OpenML dataset")
SKIP_PLOT = system.getenv_bool("SKIP_PLOT", False,
                               "Don't show plot: just output data")
SHOW_PLOT = not SKIP_PLOT
INTERACTIVE_PLOT = system.getenv_bool("INTERACTIVE_PLOT", False,
                                      "Use interactive plot via matplotlib.plot")
DEFAULT_BASENAME = re.sub(r".py\w*$", "", gh.basename(__file__))
BASENAME = system.getenv_text("BASENAME", DEFAULT_BASENAME,
                              "Basename for about files")
CLASS_VAR = system.getenv_value("CLASS_VAR", None,
                                "Name of classification variable if not last")
CLASS_LABELS = system.getenv_value("CLASS_LABELS", None,
                                   "Comma-separated list of class labels")

# Optional packages
if SHOW_PLOT:
    import matplotlib.pyplot as plt
    ## TODO: #%matplotlib inline

## TODO: Constants for switches omitting leading dashes (e.g., DEBUG_MODE = "debug-mode")
## Note: Run following in Emacs to interactively replace TODO_ARG with option label
##    M-: (query-replace-regexp "todo\\([-_]\\)arg" "arg\\1name")
## where M-: is the emacs keystroke short-cut for eval-expression.
TODO_ARG = "TODO-arg"
## ALT_TODO_ARG = "alt-todo-arg"
## TODO_FILENAME = "TODO-filename"

## TODO:
## # Environment options
## # Note: These are just intended for internal options, not for end users.
## # It also allows for enabling options in one place rather than four
## # (e.g., [Main member] initialization, run-time value, and argument spec., along
## # with string constant definition).
## #
## FUBAR = system.getenv_bool("FUBAR", False,
##                            description="Fouled Up Beyond All Recognition processing")

#-------------------------------------------------------------------------------
# Utility functions

def reset_plot():
    """Reset the mathplotlib state"""
    # Note: See https://stackoverflow.com/questions/741877/how-do-i-tell-matplotlib-that-i-am-done-with-a-plot
    # TODO: Make sure no other state retained

    # Clear the axes
    plt.cla()

    # Clear the figure
    plt.clf()
    return

#-------------------------------------------------------------------------------

class Script(Main):
    """Input processing class"""
    # TODO: -or-: """Adhoc script class (e.g., no I/O loop, just run calls)"""
    ## TODO: class-level member variables for arguments (avoids need for class constructor)
    todo_arg = False
    ## alt_todo_arg = ""

    # TODO: add class constructor if needed for non-standard initialization
    ## def __init__(self, *args, **kwargs):
    ##     debug.trace_fmtd(5, "Script.__init__({a}): keywords={kw}; self={s}",
    ##                      a=",".join(args), kw=kwargs, s=self)
    ##     super(Script, self).__init__(*args, **kwargs)

    def setup(self):
        """Check results of command line processing"""
        debug.trace_fmtd(5, "Script.setup(): self={s}", s=self)
        ## TODO: extract argument values
        self.todo_arg = self.get_parsed_option(TODO_ARG, self.todo_arg)
        ## self.alt_todo_arg = self.get_parsed_option(alt_todo_arg, self.alt_todo_arg)
        # TODO: self.TODO_filename = self.get_parsed_argument(TODO_FILENAME)
        debug.trace_object(5, self, label="Script instance")
        return

    def run_main_step(self):
        """Main processing step"""
        debug.trace_fmtd(5, "Script.run_main_step(): self={s}", s=self)

        # 1. general settings, learning and prediction
        feature_data = target_data = None
        if USE_OPENML:
            # pylint: disable=no-member
            dataset = fetch_openml(system.quote_url_text(DATASET_NAME))
            feature_data = dataset.data
            target_data = dataset.target
        else:
            dataset_filename = DATASET_NAME if system.file_exists(DATASET_NAME) else (DATASET_NAME + ".csv")
            dataset = du.read_csv(dataset_filename)
            # TODO: add CLASS_POS?
            class_var = CLASS_VAR if CLASS_VAR else dataset.columns[-1]
            # pylint: disable=no-member
            feature_data = dataset.copy()
            feature_data.drop(class_var, axis=1)
            ## OLD: class_index = list(dataset.columns).index(class_var)
            ## BAD: features_indices = dataset.columns[0:class_index] + dataset.columns[class_index + 1:]
            ## BAD2: features_indices = dataset.columns[0:class_index]
            ## BAD2: features_indices.append(dataset.columns[class_index + 1:])
            ## BAD3: features_indices = pd.concat(dataset.columns[0:class_index], dataset.columns[class_index + 1:])
            ## OLD: debug.assertion(class_index == 0)
            ## OLD: features_indices = dataset.columns[class_index + 1:]
            ## OLD2: target_indices = dataset.columns[class_index: class_index + 1]
            ## BAD: target_data = dataset[target_indices].iloc[0]
            target_data = dataset[class_var]
        debug.assertion(isinstance(feature_data, pd.DataFrame))
        debug.assertion(isinstance(target_data, pd.Series))
        n_classes = len(set(target_data))
        ## BAD: Y = label_binarize(target_data, classes=[*range(n_classes)])
        class_labels = target_data.unique()
        Y = label_binarize(target_data, classes=class_labels)
        debug.assertion(not all(list((sum(y) == 0) for y in Y)))
        X_train, X_test, y_train, y_test = train_test_split(feature_data, Y,
                                                            random_state=42)
        debug.trace_expr(4, dataset, n_classes, Y)
        debug.trace_expr(5, X_train, X_test, y_train, y_test)
        # TODO: parameterize (e.g., classifier name and common options)
        clf = OneVsRestClassifier(RandomForestClassifier(n_estimators=50, 
                                                         max_depth=3,
                                                         random_state=0))
        clf.fit(X_train, y_train)
        y_score = clf.predict_proba(X_test)
        debug.trace_object(5, clf)
        debug.trace_expr(6, y_score)

        # 2. precision-recall curve
        reset_plot()
        precision = dict()
        recall = dict()
        thresholds = dict()
        plot_class_labels = class_labels
        if CLASS_LABELS:
            plot_class_labels = text_utils.extract_string_list(CLASS_LABELS)
        for i in range(n_classes):
            precision[i], recall[i], thresholds[i] = precision_recall_curve(y_test[:, i],
                                                                            y_score[:, i])
            plt.plot(recall[i], precision[i], linewidth=2, label=plot_class_labels[i])
            debug.trace_expr(6, precision[i], recall[i], thresholds[i])
        #
        plt.xlabel("recall")
        plt.ylabel("precision")
        plt.legend(loc="best")
        plt.title("precision vs. recall curve")
        debug.trace_object(5, plt)
        output_files = []
        if INTERACTIVE_PLOT:
            plt.show()
        else:
            output_files.append(BASENAME + ".pr-plot.png")
            plt.savefig(output_files[-1])

        # 3. ROC curve
        reset_plot()
        fpr = dict()
        tpr = dict()
        for i in range(n_classes):
            fpr[i], tpr[i], thresholds[i] = roc_curve(y_test[:, i],
                                                      y_score[:, i])
            plt.plot(fpr[i], tpr[i], lw=2, label=plot_class_labels[i])
            debug.trace_expr(6, precision[i], recall[i], thresholds[i])
        #
        plt.xlabel("false positive rate")
        plt.ylabel("true positive rate")
        plt.legend(loc="best")
        plt.title("ROC curve")
        debug.trace_object(5, plt)
        if INTERACTIVE_PLOT:
            plt.show()
        else:
            output_files.append(BASENAME + ".roc-plot.png")
            plt.savefig(output_files[-1])

        # Output status
        if not INTERACTIVE_PLOT:
            print("Output files:\n\t{files}\n\t".format(files="\n\t".join(output_files)))

        return


#-------------------------------------------------------------------------------

if __name__ == '__main__':
    debug.trace_current_context(level=debug.QUITE_DETAILED)
    debug.trace_fmt(4, "Environment options: {eo}",
                    eo=system.formatted_environment_option_descriptions())
    app = Script(
        description=__doc__,
        # Note: skip_input controls the line-by-line processing, which is inefficient but simple to
        # understand; in contrast, manual_input controls iterator-based input (the opposite of both).
        skip_input=False,
        manual_input=True,
        # TODO: Disable inference of --help argument
        ## auto_help=False,
        ## TODO: specify options and (required) arguments
        ## TODO: boolean_options=[(TODO_ARG, "TODO-desc")],
        # Note: FILENAME is default argument unless skip_input
        ## positional_arguments=[FILENAME1, FILENAME2], 
        ## text_options=[(alt_todo_arg, "TODO-desc")],
        # Note: Following added for indentation: float options are not common
        float_options=None)
    app.run()

