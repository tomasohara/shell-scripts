#! /usr/bin/env python
#
# via https://machinelearningmastery.com/how-to-calculate-precision-recall-f1-and-more-for-deep-learning-models/
#
# Note:
# - Sloppy programming by the blogger.
#

"""Illustrates ML metrics using synthetic circles dataset"""

# demonstration of calculating metrics for a neural network model using sklearn
from sklearn.linear_model import LogisticRegression
from sklearn.datasets import make_circles
from sklearn.metrics import accuracy_score
from sklearn.metrics import precision_score
from sklearn.metrics import recall_score
from sklearn.metrics import f1_score
from sklearn.metrics import cohen_kappa_score
from sklearn.metrics import roc_auc_score
from sklearn.metrics import confusion_matrix
from keras.models import Sequential
from keras.layers import Dense

# Local packages
from mezcla import debug
from mezcla import system

# Environment options
USE_KERAS = system.getenv_bool("USE_KERAS", False,
                               "Use Keras deep learning for shites and giggles")
RANDOM_SEED = system.getenv_value("RANDOM_SEED", 15485863,
                                  "Seed to use for random state")

def get_data():
    """generate and prepare the dataset"""
    # generate dataset
    X, y = make_circles(n_samples=1000, noise=0.1, random_state=RANDOM_SEED)
    debug.trace_expr(5, X, y)
    # split into train and test
    n_test = 500
    trainX, testX = X[:n_test, :], X[n_test:, :]
    trainy, testy = y[:n_test], y[n_test:]
    return trainX, trainy, testX, testy


def get_model(trainX, trainy):
    """define and fit the model"""
    # define model
    if USE_KERAS:
        model = Sequential()
        model.add(Dense(100, input_dim=2, activation='relu'))
        model.add(Dense(1, activation='sigmoid'))
        # compile model
        model.compile(loss='binary_crossentropy', optimizer='adam', metrics=['accuracy'])
        # fit model
        model.fit(trainX, trainy, epochs=300, verbose=0)
    else:
        model = LogisticRegression()
        model.fit(trainX, trainy)
    return model


def main():
    """Entry point"""

    # generate data
    trainX, trainy, testX, testy = get_data()
    # fit model
    model = get_model(trainX, trainy)

    # predict probabilities for test set
    if USE_KERAS:
        yhat_probs = model.predict(testX, verbose=0)
    else:
        yhat_probs = model.predict_proba(testX)
    # predict crisp classes for test set
    if USE_KERAS:
        # pylint: disable=no-member
        yhat_classes = model.predict_classes(testX, verbose=0)
    else:
        yhat_classes = model.predict(testX)
    # reduce to 1d array
    yhat_probs = yhat_probs[:, 0]
    ## BAD: yhat_classes = yhat_classes[:, 0]
    if (len(yhat_classes.shape) > 1):
        yhat_classes = yhat_classes[:, 0]
    
    # accuracy: (tp + tn) / (p + n)
    accuracy = accuracy_score(testy, yhat_classes)
    print('Accuracy: %f' % accuracy)
    # precision: tp / (tp + fp)
    precision = precision_score(testy, yhat_classes)
    print('Precision: %f' % precision)
    # recall: tp / (tp + fn)
    recall = recall_score(testy, yhat_classes)
    print('Recall: %f' % recall)
    # f1: 2 tp / (2 tp + fp + fn)
    f1 = f1_score(testy, yhat_classes)
    print('F1 score: %f' % f1)
    
    # kappa
    kappa = cohen_kappa_score(testy, yhat_classes)
    print('Cohens kappa: %f' % kappa)
    # ROC AUC
    auc = roc_auc_score(testy, yhat_probs)
    print('ROC AUC: %f' % auc)
    # confusion matrix
    matrix = confusion_matrix(testy, yhat_classes)
    print(matrix)

#-------------------------------------------------------------------------------

if __name__ == "__main__":
    main()
