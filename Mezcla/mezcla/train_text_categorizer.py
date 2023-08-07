#! /usr/bin/env python
#
# Trains text categorizer using Scikit-Learn. See
#    http://scikit-learn.org/stable/tutorial/text_analytics/working_with_text_data.html
#
# Notes:
# - This is a simple wrapper around the code in text_categorizer.py, created
#   to clarify how training is done.
#
# TODO:
# - *** Use sklearn for spliting training data.
# - ** Rework via main.py.
# - Rename to something like apply_text_categorizer.py, as now supports
#   usage with a pre-trained model.
#
#

"""Trains text categorization"""

# Standard packages
import math
import sys

# Local packages
from mezcla import debug
from mezcla import glue_helpers as gh
from mezcla.main import Main
from mezcla import system
from mezcla.text_categorizer import TextCategorizer

# Constants
SHOW_REPORT = system.getenv_bool("SHOW_REPORT", False,
                                 "Show categorization report from Sklearn")
TEST_PERCENT = system.getenv_value("TEST_PERCENT", None,
                                   "Percent of testing data to derive from training")

def usage():
    """Show command-line usage"""
    # TODO: remove path from script filename
    script = (__file__ or "n/a")
    system.print_stderr("Usage: {scr} training-file model-file [testing]".format(scr=script))
    system.print_stderr("")
    system.print_stderr("Notes:")
    system.print_stderr("- Use - to indicate the file is not needed (e.g., existing training model).")
    system.print_stderr("- You need to supply either training file or model file.")
    system.print_stderr("- The testing file is optional when training.")
    system.print_stderr("- Currently, only tab-separated value format is accepted:")
    system.print_stderr("    <label>\t<text>")
    return


def main(args=None):
    """Entry point for script"""
    debug.trace_fmtd(4, "main(): args={a}", a=args)

    # Check command line arguments
    if args is None:
        args = sys.argv
        debug.trace_fmtd(4, "len(args)={l}", l=len(args))
        if (len(args) == 1) and system.getenv_text("ARGS"):
            args += system.getenv_text("ARGS").split()
            debug.trace_fmtd(4, "len(args)={l}; args={a}", l=len(args), a=args)
        if len(args) <= 2:
            usage()
            return
    training_filename = args[1]
    model_filename = args[2]
    testing_filename = None
    if (len(args) > 3):
        testing_filename = args[3]

    # Note: This gets some settings from main, but it is not used directly.
    app = Main(skip_args=True)
        
    # Optionally infer testing data from training data
    # TODO: support randomization
    if TEST_PERCENT:
        debug.assertion((testing_filename is None) or (testing_filename == "-"))
        full_training_filename = training_filename
        total_num_lines = system.to_int(gh.run(f"wc -l < {full_training_filename}"))
        num_testing_lines = int(math.ceil((system.to_float(TEST_PERCENT) / 100.0) * (total_num_lines - 1)))
        num_training_lines = (total_num_lines - num_testing_lines)
        debug.trace_expr(5, total_num_lines, num_testing_lines, num_training_lines)
        
        # Split the training file into training proper and test
        # note: the tail --lines=+2 option ignores the header line
        training_filename = app.temp_base + "train.tsv"
        gh.issue(f"head --lines=1 < {full_training_filename} > {training_filename}")
        gh.issue(f"tail --lines=+2 < {full_training_filename} | head --lines={num_training_lines} >> {training_filename}")
        testing_filename = app.temp_base + "test.tsv"
        gh.issue(f"head --lines=1 < {full_training_filename} > {testing_filename}")
        gh.issue(f"tail --lines=+2 < {full_training_filename} | tail --lines={num_testing_lines} >> {testing_filename}")
        gh.run(f"wc -l {full_training_filename} {app.temp_base}*")
        
    # Train text categorizer and save model to specified file
    text_cat = TextCategorizer()
    new_model = False
    accuracy = None
    try:
        if training_filename and (training_filename != "-"):
            text_cat.train(training_filename)
            new_model = True
        if model_filename and (model_filename != "-"):
            if new_model:
                text_cat.save(model_filename)
            else:
                text_cat.load(model_filename)
        if testing_filename and (testing_filename != "-"):
            accuracy = text_cat.test(testing_filename, report=SHOW_REPORT)
            print("Accuracy over {f}: {acc}".format(acc=accuracy, f=testing_filename))
            debug.trace_fmt(4, "Tested using classifer {clf}",
                            clf=text_cat.classifier.named_steps['clf'].__class__)
    except:
        system.print_exception_info("categorization")
        debug.raise_exception(6)

    # Show usage if nothing actually done (e.g., due to too many -'s for filenames)
    ## OLD: if (not (new_model or accuracy)):
    if (not (new_model or (accuracy is not None))):
        usage()
              
    return

#------------------------------------------------------------------------

if __name__ == '__main__':
    main()
