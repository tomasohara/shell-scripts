#! /usr/bin/env python
# 
# Based on following:
#   https://scikit-learn.org/stable/auto_examples/ensemble/plot_forest_importances.html.
#

"""
==========================================
Feature importances with a forest of trees
==========================================

This example shows the use of a forest of trees to evaluate the importance of
features on an artificial classification task. The blue bars are the feature
importances of the forest, along with their inter-trees variability represented
by the error bars.

As expected, the plot suggests that 3 features are informative, while the
remaining are not.

"""

# Standard modules
import time

# Installed modules
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from sklearn.datasets import make_classification
from sklearn.ensemble import RandomForestClassifier
from sklearn.inspection import permutation_importance
from sklearn.model_selection import train_test_split

# Local modules
from mezcla import debug
from mezcla import system
from mezcla.system import getenv_bool, getenv_int, getenv_text, getenv_value

# Constants
TL = debug.TL
INTERACTIVE_PLOT =  getenv_bool("INTERACTIVE_PLOT", False,
                                "Show interactive plot")
DEFAULT_OUTBASE = (system.remove_extension(__file__) or "plot_forest_importance")
OUTPUT_BASE = getenv_text("OUTPUT_BASE", DEFAULT_OUTBASE,
                          "Base for output files")
# note: four different individual seeds are used in order to reproduce original example;
# but, for convenience, a single seed can be used
RANDOM_SEED = getenv_value("RANDOM_SEED", None,
                           "Global seed for convenient randomization")
SEPARATE_SEEDS = (RANDOM_SEED is None)
DATASET_SEED = getenv_int("DATASET_SEED", (0 if SEPARATE_SEEDS else None),
                          "Random seed for dataset generation via make_classification")
SPLIT_SEED = getenv_int("SPLIT_SEED", (42 if SEPARATE_SEEDS else None),
                        "Random seed for dataset split")
FOREST_SEED = getenv_int("FOREST_SEED", (0 if SEPARATE_SEEDS else None),
                         "Random seed for forest generation")
PERMUTATION_SEED = getenv_int("PERMUTATION_SEED", (42 if SEPARATE_SEEDS else None),
                              "Random seed for permutation")

#-------------------------------------------------------------------------------

def main():
    """Entry point"""
    debug.trace(TL.USUAL, f"main(): filename={system.real_path(__file__)}")

    # Optionally set global seed
    if (RANDOM_SEED is not None):
        np.random.seed(system.to_int(RANDOM_SEED))

    # %%
    # Data generation and model fitting
    # ---------------------------------
    # We generate a synthetic dataset with only 3 informative features. We will
    # explicitly not shuffle the dataset to ensure that the informative features
    # will correspond to the three first columns of X. In addition, we will split
    # our dataset into training and testing subsets.
    ## OLD
    ## from sklearn.datasets import make_classification
    ## from sklearn.model_selection import train_test_split
    
    X, y = make_classification(
        n_samples=1000,
        n_features=10,
        n_informative=3,
        n_redundant=0,
        n_repeated=0,
        n_classes=2,
        random_state=DATASET_SEED,
        shuffle=False,
    )
    debug.trace_expr(TL.VERBOSE, X, y)

    # Optionally write data to CSV file
    def write_csv_file(X, y, feature_names=None, path=None):
        """Write CSV file using X and Y, optionally using FEATURE_NAMES and PATH"""
        if feature_names is None:
            num_features = len(X[0]) if len(X) else 0
            feature_names = ([f"F{i + 1}" for i in range(num_features)] + ["class"])
        if path is None:
            path = OUTPUT_BASE + ".out.csv"
        lines = []
        lines.append(",".join(feature_names))
        for features, classification in zip(X, y):
            # note: need to use list() to avoid numpy numeric operation
            lines.append(",".join(map(str, list(features) + [classification])))
        system.write_lines(path, lines)
    #
    debug.code(TL.DETAILED, lambda: write_csv_file(X, y))
               
    X_train, X_test, y_train, y_test = train_test_split(X, y,
                                                        stratify=y,
                                                        random_state=SPLIT_SEED)
    debug.trace(4, f"split sizes: train={len(X_train)}; test={len(X_test)}")
    debug.trace_expr(TL.VERBOSE, X_train, X_test, y_train, y_test)
    
    # %%
    # A random forest classifier will be fitted to compute the feature importances.
    ## OLD: from sklearn.ensemble import RandomForestClassifier
    
    feature_names = [f"feature {i}" for i in range(X.shape[1])]
    forest = RandomForestClassifier(random_state=FOREST_SEED)
    forest.fit(X_train, y_train)
    debug.trace_object(TL.VERBOSE, forest, "forest model")
    
    # %%
    # Feature importance based on mean decrease in impurity
    # -----------------------------------------------------
    # Feature importances are provided by the fitted attribute
    # `feature_importances_` and they are computed as the mean and standard
    # deviation of accumulation of the impurity decrease within each tree.
    #
    # .. warning::
    #     Impurity-based feature importances can be misleading for **high
    #     cardinality** features (many unique values). See
    #     :ref:`permutation_importance` as an alternative below.
    ## OLD: import time
    ## OLD: import numpy as np
    
    start_time = time.time()
    importances = forest.feature_importances_
    std = np.std([tree.feature_importances_ for tree in forest.estimators_], axis=0)
    elapsed_time = time.time() - start_time
    
    print(f"Elapsed time to compute the impurity-based importances: {elapsed_time:.3f} seconds")
    
    # %%
    # Let's plot the impurity-based importance.
    ## OLD: import pandas as pd
    
    forest_importances = pd.Series(importances, index=feature_names)
    
    fig, ax = plt.subplots()
    forest_importances.plot.bar(yerr=std, ax=ax)
    ax.set_title("Feature importances using MDI")
    ax.set_ylabel("Mean decrease in impurity (MDI)")
    fig.tight_layout()
    if not INTERACTIVE_PLOT:
        plt.savefig(f"{OUTPUT_BASE}-mdi.png")
    
    # %%
    # We observe that, as expected, the three first features are found important.
    #
    # Feature importance based on feature permutation
    # -----------------------------------------------
    # Permutation feature importance overcomes limitations of the impurity-based
    # feature importance: they do not have a bias toward high-cardinality features
    # and can be computed on a left-out test set.
    ## OLD: from sklearn.inspection import permutation_importance
    
    start_time = time.time()
    result = permutation_importance(
        forest, X_test, y_test, n_repeats=10, random_state=PERMUTATION_SEED, n_jobs=2
    )
    elapsed_time = time.time() - start_time
    print(f"Elapsed time to compute the permutation-based importances: {elapsed_time:.3f} seconds")
    
    forest_importances = pd.Series(result.importances_mean, index=feature_names)
    
    # %%
    # The computation for full permutation importance is more costly. Features are
    # shuffled n times and the model refitted to estimate the importance of it.
    # Please see :ref:`permutation_importance` for more details. We can now plot
    # the importance ranking.
    
    fig, ax = plt.subplots()
    forest_importances.plot.bar(yerr=result.importances_std, ax=ax)
    ax.set_title("Feature importances using permutation on full model")
    ax.set_ylabel("Mean accuracy decrease")
    fig.tight_layout()
    if not INTERACTIVE_PLOT:
        plt.savefig(f"{OUTPUT_BASE}-perm.png")

    # Show both plots
    if INTERACTIVE_PLOT:
        plt.show()

    # %%
    # The same features are detected as most important using both methods. Although
    # the relative importances vary. As seen on the plots, MDI is less likely than
    # permutation importance to fully omit a feature.

    return

#-------------------------------------------------------------------------------
    
if __name__ == '__main__':
    main()

