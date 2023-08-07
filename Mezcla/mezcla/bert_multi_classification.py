#! /usr/bin/env python
#
# Uses BERT or ALBERT for multiple-class text classification, based on following blog:
#    https://towardsdatascience.com/beginners-guide-to-bert-for-multi-classification-task-92f5445c2d7c
#
# Notes:
# - Setup instructions:
#   -- sudo pip3 install virtualenv
#   -- virtualenv bertenv
#   -- python3 -m venv bertenv
#   -- source bertenv/bin/activate
#   -- tensorflow >= 1.11.0   # CPU Version of TensorFlow.
#   -- tensorflow-gpu  >= 1.11.0  # GPU version of TensorFlow
# - Format for input files
# - Currently, the input files must use the basename "train", "dev" and optionally "test". CSV import must
#   use the extension .csv, and likewise .tsv for Tab-separated values (TSV).
# - BERT itself requires following format in tab-separated value format (tsv):
#     1. guid: Unique id for the example.
#     2. label: String data. The label of the example. This should be specified for train and evaluate examples, but not for test examples.
#     3. text_b: (Optional) string data. The untokenized text of the second sequence. Only must be specified for sequence pair tasks.
#     4. text_a: String data. The untokenized text of the first sequence. For single sequence tasks, only this sequence must be specified.
#
# - Sample preprocessing
#     - Add unique ID to training and dev-test examples, and make dummy third column.
#       -- The first perl command adds the dummy - column, and the second replaces the
#       leading spaces prior with prefix for line number added by cat. The prefix is
#       based on the size of the training file to ensure ID is unique for dev-test.
#       TODO: drop prefix support as BERT uses file type (e.g., train/dev/test).
#       $: {
#          function convert_to_bert() {
#             local file="$1"
#             local prefix="$2"
#             perl -pe 's/\t/\t-\t/;' "$file" | cat -n | perl -pe "s/^\s*/$prefix/;"
#          }
#          #
#          base=pruned-random-simplewiki-20170720-pages-articles.texts.data
#          convert_to_bert $base.train "" > train.tsv
#          prefix=$(wc -l < train.tsv)
#          convert_to_bert $base.test "$prefix" > dev.tsv
#        }
#     - Add header to dummy testing data
#       echo $'guid\ttext' > test.tsv
#       TODO: create test data by removing cases from other two files
#     - Create category file
#       cut -f2 train.tsv dev.tsv | sort --unique > cats.txt
# - Sample invocation:
#      init-miniconda3
#      source activate albert_py3
#      #
#      export DATA_DIR=$PWD;
#      export MODEL_DIR=/usr/local/misc/data/deep-learning/albert/albert_base;
#      export OUTPUT_DIR=$DATA_DIR/output;
#      export LOWER_CASE=1
#      export TASK_NAME=multi
#      export CLASSIFIER_INVOCATION="$PYTHON -m run_albert_classifier"
#   
#      # Run albert classifier indirection through wrapper script 
#      _base_=bert_multi_classification
#      # TODO: ???
#      let _RL_++; _log_="$DATA_DIR/$_base_-$(todays-date).log$_RL_"; DEBUG_LEVEL=4 USE_TSV_INPUT=1 $PYTHON -m $_base_ > "$_log_" 2>&1; less-tail "$_log_"   
#
# TODO:
# - * Summary evaluation over test set!
# - Use Main class to add in support for argument parsing
# - Generalize to handling other data files.
# - Add options for BERT model and other parameters:
#   ex: train_batch_size, learning_rate, max_seq_length, and num_train_epochs.
# - Convert into calling module for run_classifier.py directly (i.e., without using shell).
# - Rework sample invocation so that environment settings are temporary.
# - Add option for using common defaults (e.g., data in current dir, lowercase, base model, output in ./output, multi-category, using run_albert_classifier.py).
# - Create random split of single input file into train.tsv, dev.tsv and optionally test.tsv (or .csv's).
#

"""Invokes BERT or ALBERT for multiple-class text classification"""

# Standard packages
import csv
import re
import sys

# Installed packages
# Note: imports tensorflow before others due to its stupid exception quirks with sklearn
# See https://github.com/tensorflow/tensorflow/issues/2034 for a similar problem with numpy.
import tensorflow as tf
import pandas as pd
from sklearn.model_selection import train_test_split

# Local packages
from mezcla import debug
from mezcla import system
from mezcla import glue_helpers as gh
from mezcla.text_utils import version_to_number as version_as_float

# Note: the defaults are unintuitive, but they match the blog article.
MODEL_DIR = system.normalize_dir(system.getenv_text("MODEL_DIR", "./model"))
## TODO: BERT_DIR = system.normalize_dir(system.getenv_text("BERT_DIR", MODEL_DIR))
DATA_DIR = system.normalize_dir(system.getenv_text("DATA_DIR", "./dataset"))
OUTPUT_DIR = system.normalize_dir(system.getenv_text("OUTPUT_DIR", "./bert_output"))
TASK_NAME = system.getenv_text("TASK_NAME", "cola")
USE_TSV_INPUT = system.getenv_bool("USE_TSV_INPUT", False)
CLASSIFIER_INVOCATION = system.getenv_text("CLASSIFIER_INVOCATION", "run_bert_classifier.py")
# Note: USE_TSV_INPUT implies you use a tab-separated format properly formatted for BERT,
# so set BERT_FORMATTED False (e.g., USE_TSV_INPUT=1 BERT_FORMATTED=0 bert_multi_classification.py ...)
BERT_FORMATTED = system.getenv_bool("BERT_FORMATTED", USE_TSV_INPUT)
LOWER_CASE = system.getenv_bool("LOWER_CASE", False)
USE_ALBERT_DEFAULT = ("albert" in CLASSIFIER_INVOCATION)
USE_ALBERT = system.getenv_bool("USE_ALBERT", USE_ALBERT_DEFAULT)
BERT_NAME = "bert" if (not USE_ALBERT) else "albert"
CONFIG_FILE_DEFAULT = system.form_path(MODEL_DIR, "{b}_config.json".format(b=BERT_NAME))
BERT_CONFIG_FILE = system.getenv_text("BERT_CONFIG_FILE", CONFIG_FILE_DEFAULT)
SAVE_CHECKPOINTS_STEPS = system.getenv_int("SAVE_CHECKPOINTS_STEPS", 10000,
                                           "Number of tensorflow steps before checkpoints are written")

# Get label list and split into columns
INPUT_LABELS = system.getenv_text("INPUT_LABELS", "id, label, text")
## TODO: INPUT_LABEL_LIST = re.split(r"\s, *", INPUT_LABELS)
# Labels to use for ID, CLASS_VALUE, and TEXT
INPUT_LABEL_LIST = re.split(r",", INPUT_LABELS)
debug.assertion(len(INPUT_LABEL_LIST) == 3)
ID_COL = INPUT_LABEL_LIST[0]
LABEL_COL = INPUT_LABEL_LIST[1]
TEXT_COL = INPUT_LABEL_LIST[2]

#-------------------------------------------------------------------------------
# Helper function(s) specific to BERT

def ensure_bert_data_frame(data_frame, is_test=False):
    """Ensures data frame is in BERT format from input DATA_FRAME, using dummy values for alpha
    column.
    Notes:
    - See comments in blog mentioned in header above.
    - Uses global constant BERT_FORMATTED."""
    # TODO: add parameter mapping input column names to ones assumed here (i.e., id, label, & text)
    debug.trace_fmt(5, "ensure_bert_data_frame({df})", df=data_frame)
    df_bert = None
    if BERT_FORMATTED:
        df_bert = data_frame
    else:
        try:
            first_sentence = data_frame[TEXT_COL][0]
            debug.trace_fmt(5, "First sentence: {s}", s=first_sentence)
            # Ignore header column if given (TODO, add parameter to make this optional)
            # Note: This assumes single word tokens without punctuation can't be a sentence.
            if re.search(r"^\w+$", first_sentence):
                debug.trace(3, "Removing presumed header row of (test) data frame")
                debug.assertion(is_test)
                data_frame = data_frame.drop(data_frame.index[0])
                
            data_hash = {'guid': data_frame[ID_COL],
                         'alpha': (['-'] * data_frame.shape[0]),
                         'text': data_frame[TEXT_COL]}
            if not is_test:
                data_hash['label'] = data_frame[LABEL_COL]
                
            df_bert = pd.DataFrame(data_hash)
        except:
            debug.raise_exception(5)
            system.print_stderr("Exception converting data frame to BERT format: {exc}",
                                exc=sys.exc_info())
    debug.trace_fmt(4, "ensure_bert_data_frame(_) => {r}", r=df_bert)
    return df_bert

#--------------------------------------------------------------------------------

# Note: BERT works well with tensorflow version 1.15
debug.assertion(version_as_float("1.11") <= version_as_float(tf.version.VERSION) < version_as_float("2.0"))

#-------------------------------------------------------------------------------

## TODO: changes to BERT run_classifier.py code for different label sets
## NOTE: not needed if running one of GLUE tasks with support built into classifier (e.g., CoLA)
## def get_labels(self):
##     return ["0", "1"]
## def get_labels(self):
##    return ["0", "1", "2", "3", "4"]
## def get_labels(self):
##    return ["POSITIVE", "NEGATIVE"]

def main():
    """Entry point for script"""
    ## sudo apt-get install python3-pip
    ## a550d    1    a    To clarify, I didn't delete these pages.kcd12    0    a    Dear god this site is horrible.7379b    1    a    I think this is not appropriate.cccfd    2    a    The title is fine as it is.
    ## guid     textcasd4    I am not going to buy this useless stuff.3ndf9    I wanna be the very best, like no one ever was
    ## pip install pandas
    ## pip install sklearn
    ## id,text,labelsadcc,This is not what I want.,1cj1ne,He seriously have no idea what it is all about,0123nj,I don't think that we have any right to judge others,2
    in_separator = ","
    in_ext = ".csv"
    in_quoting = csv.QUOTE_MINIMAL
    if USE_TSV_INPUT:
        in_separator = "\t"
        in_ext = ".tsv"
        in_quoting = csv.QUOTE_NONE
    debug.trace_expr(5, in_separator, in_ext, in_quoting)
    df_train = pd.read_csv(gh.form_path(DATA_DIR, "train" + in_ext), sep=in_separator, names=INPUT_LABEL_LIST, quoting=in_quoting)
    df_bert_train = ensure_bert_data_frame(df_train)

    ## BAD: df_bert_train.to_csv(gh.form_path(DATA_DIR, 'train.tsv'), sep='\t', index=False, header=False)
    ## TODO: df_train.to_csv(gh.form_path(DATA_DIR, 'train.tsv'), sep='\t', index=False, header=False)

    # Read source data from csv file
    test_columns = [INPUT_LABEL_LIST[0], INPUT_LABEL_LIST[2]]
    df_test = pd.read_csv(gh.form_path(DATA_DIR, "test" + in_ext), sep=in_separator, names=test_columns, quoting=in_quoting)
    df_bert_test = ensure_bert_data_frame(df_test, is_test=True)

    ## TODO: alternative version
    ## #create a new dataframe for train, dev data
    ## df_bert = pd.DataFrame({'guid': df_train['id'],
    ##                         'label': df_train['label'],
    ##                         'alpha': ['a']*df_train.shape[0],
    ##                         'text': df_train['text']})

    # Optionally split into test, dev
    # NOTE: skipped if no dev.tsv file exists
    dev_file = gh.form_path(DATA_DIR, "dev" + in_ext)
    if system.file_exists(dev_file):
        df_dev = pd.read_csv(dev_file, sep=in_separator, names=INPUT_LABEL_LIST, quoting=in_quoting)
        df_bert_dev = ensure_bert_data_frame(df_dev)
    else:
        df_bert_train, df_bert_dev = train_test_split(df_bert_train, test_size=0.01)  
        
    ## ALT: create new dataframe for test data
    ## df_bert_test = ensure_bert_data_frame(df_test)
    ## pd.DataFrame({'guid': df_test['id'],
    ##               'text': df_test['text']})

    # Output tsv file, no header for train and dev
    if not USE_TSV_INPUT:
        df_bert_train.to_csv(gh.form_path(OUTPUT_DIR, 'train.tsv'), sep='\t', index=False, header=False)
        df_bert_dev.to_csv(gh.form_path(OUTPUT_DIR, 'dev.tsv'), sep='\t', index=False, header=False)
        df_bert_test.to_csv(gh.form_path(OUTPUT_DIR, 'test.tsv'), sep='\t', index=False, header=True)

    # Sanity checks
    debug.assertion(system.file_exists("cats.txt"))
    #
    ## TODO: work example error from run_classifier.py customization into assertion
    ## label_id = label_map[example.label]
    ## KeyError: '2'`

    ## TODO: Run NVIDIA CUDA utility and make sure capable of running TensorFlow w/ GPU's.
    ## Also, warn if graphics memory is too low.
    ## nvidia-smi
    system.setenv("BERT_BASE_DIR", MODEL_DIR)
    ##CUDA_VISIBLE_DEVICES=0
    ## python script.py
    print("Make sure your GPU Processor has sufficient memory, besides adequate number of units")
    print(gh.run("nvidia-smi"))
    # Make sure tensorflow doesn't grab all the GPU memory
    if system.getenv("TF_FORCE_GPU_ALLOW_GROWTH") is None:
        system.setenv("TF_FORCE_GPU_ALLOW_GROWTH", "true")
    # note: 0 is the order, not the total number
    if system.getenv("CUDA_VISIBLE_DEVICES") is None:
        system.setenv("CUDA_VISIBLE_DEVICES", "0")
    if system.getenv("NVIDIA_VISIBLE_DEVICES") is None:
        system.setenv("NVIDIA_VISIBLE_DEVICES", "0")
    # TODO: use run [?] and due sanity checks on output; u[???}
    is_lower_case = system.to_string(LOWER_CASE).lower()
    # TODO: use form_path here and below
    bert_proper_args = ("--vocab_file={md}/vocab.txt".format(md=MODEL_DIR) if (not USE_ALBERT) else "--spm_model_file={md}/albert.model".format(md=MODEL_DIR))
    # TODO: add more env params: MAX_SEQ_LENGTH, TRAIN_BATCH_SIZE, LEARNING_RATE, NUM_TRAIN_EPOCHS
    # TODO: specify checkpoint separately: {md}/{bn}_model.ckpt => MODEL_CHECKPOINT
    ## OLD: gh.issue("{ci} {bpa} --task_name={t} --do_train=true --do_eval=true --do_predict=true --data_dir={dd}  --{bn}_config_file={bcf} --init_checkpoint={md}/{bn}_model.ckpt --max_seq_length=64 --train_batch_size=2 --learning_rate=2e-5 --num_train_epochs=3.0 --output_dir={od} --do_lower_case={lc} --save_checkpoints_steps={scs}", ci=CLASSIFIER_INVOCATION, bpa=bert_proper_args, t=TASK_NAME, dd=DATA_DIR, md=MODEL_DIR, od=OUTPUT_DIR, lc=is_lower_case, bn=BERT_NAME, bcf=BERT_CONFIG_FILE, scs=SAVE_CHECKPOINTS_STEPS)
    ## Uses: defaults for following: train_batch_size (32); learning_rate (5e5); max_seq_length (128); num_train_epochs (3)
    ## See run_bert_classifier.py for other options (e.g., --iterations_per_loop).
    gh.issue("{ci} {bpa} --task_name={t} --do_train=true --do_eval=true --do_predict=true --data_dir={dd}  --{bn}_config_file={bcf} --init_checkpoint={md}/{bn}_model.ckpt --output_dir={od} --do_lower_case={lc} --save_checkpoints_steps={scs}", ci=CLASSIFIER_INVOCATION, bpa=bert_proper_args, t=TASK_NAME, dd=DATA_DIR, md=MODEL_DIR, od=OUTPUT_DIR, lc=is_lower_case, bn=BERT_NAME, bcf=BERT_CONFIG_FILE, scs=SAVE_CHECKPOINTS_STEPS)
    ## sample output:
    ## eval_accuracy = 0.96741855 eval_loss = 0.17597112 global_step = 236962 loss = 0.17553209
    ## checkpoint file: model_checkpoint_path: "model.ckpt-236962" all_model_checkpoint_paths: "model.ckpt-198000" all_model_checkpoint_paths: "model.ckpt-208000"  all_model_checkpoint_paths: "model.ckpt-218000"  all_model_checkpoint_paths: "model.ckpt-228000"  all_model_checkpoint_paths: "model.ckpt-236962"
    
    ## alternative run
    ## CUDA_VISIBLE_DEVICES=0 python run_classifier.py --task_name=cola --do_predict=true --data_dir=./dataset --vocab_file=./model/vocab.txt --bert_config_file=./model/bert_config.json --init_checkpoint=./bert_output/model.ckpt-236962 --max_seq_length=64 --output_dir=./bert_output/
    ## 1.4509245e-05 1.2467547e-05 0.999946361.4016414e-05 0.99992466 1.5453812e-051.1929651e-05 0.99995375 6.324972e-063.1922486e-05 0.9999423 5.038059e-061.9996814e-05 0.99989235 7.255715e-064.146e-05 0.9999349 5.270801e-06
    ## alternative input
    ## # read the original test data for the text and id
    ## df_test = pd.read_csv(gh.form_path(OUTPUT_DIR, 'test.tsv'), sep='\t')
    ## # read the results data for the probabilities
    ## df_result = pd.read_csv('bert_output/test_results.tsv', sep='\t', header=None)
    ## # create a new dataframe
    ## df_map_result = pd.DataFrame({'guid': df_test['guid'],
    ##                               'text': df_test['text'],
    ##                               'label': df_result.idxmax(axis=1)})
    ## # view sample rows of the newly created dataframe
    ## df_map_result.sample(10)
    return

#------------------------------------------------------------------------

if __name__ == '__main__':
    main()
