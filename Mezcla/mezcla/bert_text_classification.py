#! /usr/bin/env python
# 
# Text categorized based on BERT model. This allows for multiclass categorization. The
# input is a tabbed delimited file of the format:
#     category<TAB>token1<DELIM>token2<DELIM>...tokenN
# where DELIM is either whitespace and/or punctuation (e.g., ' ' or '. ' or ' $').
# The tokens are alphanumeric as well as including dashes and underscores.
#
# Notes:
# - This is based on following online article:
#       https://analyticsindiamag.com/step-by-step-guide-to-implement-multi-class-classification-with-bert-tensorflow
# - Godawful code organization (e.g., doubly embedded functions).
# - Default text categories:
#      Politics: 0
#      Technology: 1
#      Entertainment: 2
#      Business: 3
#
# - Data Preprocessing
#
#   The BERT model accepts only a specific type of input and the datasets are usually structured to have have the following four features:
#      guid : A unique id that represents an observation.
#      text_a : The text we need to classify into given categories
#      text_b: It is used when we're training a model to understand the relationship between sentences and it does not apply for classification problems.
#      label: It consists of the labels or classes or categories that a given text belongs to.
#
#  In our dataset we have text_a and label. The code will create objects for each of the above mentioned features for all the records in our dataset using the InputExample class provided in the BERT library.
#
# - To cache the tensorflow hub version of the BERT data, use the following steps,
#   based on https://medium.com/@xianbao.qian/how-to-run-tf-hub-locally-without-internet-connection-4506b850a915:
#       import hashlib
#       from mezcla import glue_helpers as gh
#       model = "uncased_L-12_H-768_A-12"
#       # -or-: model = "uncased_L-8_H-512_A-8"
#       BERT_MODEL_HUB = f"https://tfhub.dev/google/{model}/1"
#       # take 2:
#       #    model = "bert_uncased_L-8_H-512_A-8"
#       #    BERT_MODEL_HUB = f"https://tfhub.dev/google/small_bert/{model}/2
#       temp_dir = "/tmp"
#       # -or-: temp_dir = f"{os.environ.get('HOME', '.')}/temp"
#       local_hub_dir = f"{temp_dir}/tf-hub"
#       gh.issue(f"mkdir {local_hub_dir}")
#       os.environ["TFHUB_CACHE_DIR"] = local_hub_dir
#       cache_subdir = hashlib.sha1(BERT_MODEL_HUB.encode("utf8")).hexdigest()
#       gh.issue(f"mkdir {local_hub_dir}/{cache_subdir}")
#       tf_hub_url = (BERT_MODEL_HUB.                                                        \
#                         replace("https://tfhub.dev/google/",                               \
#                                 "https://storage.googleapis.com/bert_models/2020_02_20/"). \
#                         replace("/1", ".zip").replace("/2", ".zip").                       \
#                         replace("/google", "").replace("/small_bert", "))
#       temp_archive = f"{temp_dir}/{model}.zip"
#       gh.issue(f"curl {tf_hub_url} > {temp_archive}")
#       gh.issue(f"cd {local_hub_dir}/{cache_subdir}; unzip {temp_archive}")
#       print([BERT_MODEL_HUB, local_hub_dir, cache_subdir, temp_archive])
#   =>
#   ['https://tfhub.dev/google/uncased_L-12_H-768_A-12/1', '/tmp/tf-hub', '627e8a1af062e84ad50e5e82c59b0f86c3a5f3df', '/tmp/uncased_L-12_H-768_A-12.zip']
#   TODO: convert replace sequence to re.sub
#
#  For hub instance "https://tfhub.dev/google/uncased_L-12_H-768_A-12/1",
#  this downloads https://storage.googleapis.com/tfhub-modules/2020_02_20/uncased_L-12_H-768_A-12.zip"
#  and places the zipped contents in /tmp/tf-hub.
#
#--------------------------------------------------------------------------------
# TODO:
# - Determine the depencies between the versions of TensorFlow and BERT. This
#   doesn't work with TensorFlow 2.0 and BERT from 2018.
#

"""Run text categorization over input file (or Predict the News Category Hackathon)"""

# Standard packages
from datetime import datetime
## OLD: import hashlib
## OLD: import os

# Installed packages
import pandas as pd
import tensorflow as tf
import tensorflow_hub as hub
from sklearn.model_selection import train_test_split
# Import BERT modules
# note: need to use bert-tenorflow version 1.0.1
import bert
from bert import run_classifier

# Local packages
from mezcla import debug
from mezcla.main import Main
from mezcla import system
from mezcla import glue_helpers as gh

# Show TensorFlow info
# note: 1.15.0 and 0.7.0 for blog example
print("tensorflow version : ", tf.__version__)                # pylint: disable=no-member
print("tensorflow_hub version : ", hub.__version__)

# Set the output directory for saving model file
USER = system.getenv_text("USER", "user")
BASE_DIR = system.getenv_text("BASE_DIR", ".")
TRAINING_FILE = "Data_Train.xls"
TESTING_FILE = "Data_Test.xls"
SUBMISSION_FILE = "submission_bert.xls"
TYPICAL_INPUT_DIR = system.form_path("/home", USER, "data", "hackathon-news-prediction")
DEFAULT_INPUT_DIR = "." if system.file_exists(TRAINING_FILE) else TYPICAL_INPUT_DIR
INPUT_DIR = system.getenv_text("INPUT_DIR", DEFAULT_INPUT_DIR)
TRAINING_PATH = system.form_path(INPUT_DIR, TRAINING_FILE)
TESTING_PATH = system.form_path(INPUT_DIR, TESTING_FILE)
OUTPUT_DIR = system.getenv_text("OUTPUT_DIR",
                                system.form_path(INPUT_DIR, "output"))
SHOW_PLOTS = system.getenv_bool("SHOW_PLOTS", False)
TFHUB_CACHE_DIR = system.getenv_text("TFHUB_CACHE_DIR", "/tmp/tf-hub",
                                     "Directory for cache of models from Tensorflow Hub")
if TFHUB_CACHE_DIR:
    debug.trace_fmt(3, "Using local TensorFlow Hub cache: {c}", c=TFHUB_CACHE_DIR)
BERT_MODEL_HUB = system.getenv_text("BERT_MODEL_HUB", "https://tfhub.dev/google/bert_uncased_L-12_H-768_A-12/1",
                                    "Model to use from Tensorflow Hub")
USER_HOME = system.getenv_text("HOME", ".",
                               "User home directory")
## TODO
## USER = system.getenv_text("USER", "joe",
##                           "User ID")

# Whether or not to clear/delete the directory and create a new one
DO_DELETE = system.getenv_bool("DO_DELETE", False)

# Do sanity check on input files
debug.assertion(system.non_empty_file(TRAINING_PATH))
debug.assertion(system.non_empty_file(TESTING_PATH))

# Delete previous run if desired. The (re-)create the output directory if needed.
debug.assertion(system.is_directory(INPUT_DIR))
if DO_DELETE:
    try:
        gh.issue("/bin/rm --verbose --recursive {od}", od=OUTPUT_DIR)
    except:
        system.print_stderr("Problem deleting dir: {od}", od=OUTPUT_DIR)
if not system.is_directory(OUTPUT_DIR):
    system.create_directory(OUTPUT_DIR)
print('***** Model output directory: {} *****'.format(OUTPUT_DIR))
    

class Script(Main):
    """Adhoc script class (e.g., no I/O loop, just run calls)"""
    # This is a path to an uncased (all lowercase) version of BERT
    MAX_SEQ_LENGTH = 128         # Sequences have at most 128 tokens.
    # These hyperparameters are copied from this colab notebook (https://colab.sandbox.google.com/github/tensorflow/tpu/blob/master/tools/colab/bert_finetuning_with_cloud_tpus.ipynb)
    BATCH_SIZE = 32
    LEARNING_RATE = 2e-5
    NUM_TRAIN_EPOCHS = 3.0
    # Warmup is a period of time where the learning rate is small and gradually increases--usually helps training.
    WARMUP_PROPORTION = 0.1
    # Model configs
    SAVE_CHECKPOINTS_STEPS = 1000
    SAVE_SUMMARY_STEPS = 100
    #
    DATA_COLUMN = 'STORY'
    LABEL_COLUMN = 'SECTION'
    # The list containing all the classes (train['SECTION'].unique())
    LABEL_LIST = [0, 1, 2, 3]
    #
    tokenizer = None
    estimator = None

    def setup(self):
        """Check results of command line processing"""
        debug.trace_fmtd(5, "Script.setup(): self={s}", s=self)
        # Make CUDA settings (n.b., very idiosyncratic)
        # Notes:
        # 1. The actual library file are based on the GPU: see NVIDIA SDK.
        # 2. Unfortunately, BERT requires Tensorflow 1.15 which uses old CUDA.
        ## BAD: pkg_dir = gh.form_path(HOME, USER, ".conda", "pkgs")
        pkg_dir = gh.form_path(USER_HOME, ".conda", "pkgs")
        system.setenv("LD_LIBRARY_PATH", f"/usr/lib/x86_64-linux-gnu:/usr/lib/nvidia-450:/usr/local/cuda-11.1/lib64:{pkg_dir}/cudatoolkit-10.1.243-h6bb024c_0/lib:{pkg_dir}/cudnn-7.6.5-cuda10.1_0/lib:/usr/local/misc/lib/cuda-repo-ubuntu1604-10-0-local-10.0.130-410.48_1.0-1:/usr/local/cuda/extras/CUPTI/lib64")
        # Show environment and this object instance
        debug.trace(4, gh.run("printenv"))
        debug.trace_object(5, self, label="Script instance")

    def create_tokenizer_from_hub_module(self):
        """Get the vocab file and casing info from the Hub module."""
        debug.trace(5, "create_tokenizer_from_hub_module()")
        debug.reference_var(self)
        with tf.Graph().as_default():
            bert_module = hub.Module(BERT_MODEL_HUB)
            ## TODO
            ## try:
                # Take 1: Get from Tensorflow Hub server
                ## bert_module = hub.Module(BERT_MODEL_HUB)
            ## except:
                ## raise NotImplementedError()
                ## # Take 2: Get from cache (e.g., /home/tomohara/temp/tf-hub/3843e19587d721e7cfc9d9cfe564ca3da192ffc9)
                ## # TODO: get the module conversion working
                ## cache_subdir = hashlib.sha1(BERT_MODEL_HUB.encode("utf8")).hexdigest()
                ## cache_path = os.path.join(TFHUB_CACHE_DIR, cache_subdir)
                ## bert_module = hub.saved_model_module.create_module_spec_from_saved_model(cache_path)
            tokenization_info = bert_module(signature="tokenization_info", as_dict=True)
            with tf.Session() as sess:
                vocab_file, do_lower_case = sess.run(
                    [tokenization_info["vocab_file"],
                     tokenization_info["do_lower_case"]])
                debug.trace_expr(5, bert_module, vocab_file, do_lower_case)
        tokenizer = bert.tokenization.FullTokenizer(
            vocab_file=vocab_file, do_lower_case=do_lower_case)
        debug.trace(4, f"create_tokenizer_from_hub_module() => {tokenizer}")
        return tokenizer
            

    def create_model(self, is_predicting, input_ids, input_mask, segment_ids,
                     labels, num_labels):
        """Load the BERT model for fine-tuning."""
        debug.trace(5, f"create_model({tuple([is_predicting, input_ids, input_mask, segment_ids, labels, num_labels])})")
        debug.reference_var(self)
        bert_module = hub.Module(
            BERT_MODEL_HUB,
            trainable=True)
        bert_inputs = dict(
            input_ids=input_ids,
            input_mask=input_mask,
            segment_ids=segment_ids)
        bert_outputs = bert_module(
            inputs=bert_inputs,
            signature="tokens",
            as_dict=True)
    
        # Use "pooled_output" for classification tasks on an entire sentence.
        # Use "sequence_outputs" for token-level output.
        output_layer = bert_outputs["pooled_output"]
        hidden_size = output_layer.shape[-1].value
      
        # Create our own layer to tune for politeness data.
        # TODO: Make this optional (probably specific to Hackathon corpus genre)
        output_weights = tf.get_variable(
            "output_weights", [num_labels, hidden_size],
            initializer=tf.truncated_normal_initializer(stddev=0.02))
        output_bias = tf.get_variable(
            "output_bias", [num_labels], initializer=tf.zeros_initializer())
      
        with tf.variable_scope("loss"):
      
            # Dropout helps prevent overfitting
            output_layer = tf.nn.dropout(output_layer, keep_prob=0.9)
      
            logits = tf.matmul(output_layer, output_weights, transpose_b=True)
            logits = tf.nn.bias_add(logits, output_bias)
            log_probs = tf.nn.log_softmax(logits, axis=-1)
      
            # Convert labels into one-hot encoding
            one_hot_labels = tf.one_hot(labels, depth=num_labels, dtype=tf.float32)
      
            predicted_labels = tf.squeeze(tf.argmax(log_probs, axis=-1, output_type=tf.int32))
  
            # If predicting, return predicted labels and the probabiltiies.
            if is_predicting:
                model = (predicted_labels, log_probs)
                debug.trace(5, f"create_model() => {model}; first return")
                return model
      
            # If in train/eval, compute loss between predicted and actual label
            # Note: returns loss, predicted labels, and the log of the label probs.
            per_example_loss = -tf.reduce_sum(one_hot_labels * log_probs, axis=-1)
            loss = tf.reduce_mean(per_example_loss)
            model = (loss, predicted_labels, log_probs)
            debug.trace(5, f"create_model() => {model}; second return")
            return model

    def model_fn_builder(self, num_labels, learning_rate, num_train_steps,
                         num_warmup_steps):
        """Returns `model_fn` closure for TPUEstimator."""
        # model_fn_builder actually creates our model function
        # using the passed parameters for num_labels, learning_rate, etc.
        debug.trace(5, f"model_fn_builder({tuple([num_labels, learning_rate, num_train_steps, num_warmup_steps])})")

        def model_fn(features, labels, mode, params):  # pylint: disable=unused-argument
            """The `model_fn` for TPUEstimator."""
            debug.trace(5, f"model_fn({tuple([features, labels, mode, params])})")
            input_ids = features["input_ids"]
            input_mask = features["input_mask"]
            segment_ids = features["segment_ids"]
            label_ids = features["label_ids"]
            is_predicting = (mode == tf.estimator.ModeKeys.PREDICT)
    
            # TRAIN and EVAL
            if not is_predicting:
                (loss, predicted_labels, log_probs) = self.create_model(   # pylint: disable=unbalanced-tuple-unpacking
                    is_predicting, input_ids, input_mask, segment_ids, label_ids, num_labels)
    
                train_op = bert.optimization.create_optimizer(
                    loss, learning_rate, num_train_steps, num_warmup_steps, use_tpu=False)
    
                # Calculate evaluation metrics. 
                def metric_fn(label_ids, predicted_labels):
                    """Evaluate LABEL_IDS against PREDICTED_LABELS"""
                    debug.trace(5, f"metric_fn({tuple([label_ids, predicted_labels])})")
                    accuracy = tf.metrics.accuracy(label_ids, predicted_labels)
                    true_pos = tf.metrics.true_positives(label_ids,
                                                         predicted_labels)
                    true_neg = tf.metrics.true_negatives(label_ids,
                                                         predicted_labels)   
                    false_pos = tf.metrics.false_positives(label_ids,
                                                           predicted_labels)  
                    false_neg = tf.metrics.false_negatives(label_ids,
                                                           predicted_labels)
              
                    return {
                        "eval_accuracy": accuracy,
                        "true_positives": true_pos,
                        "true_negatives": true_neg,
                        "false_positives": false_pos,
                        "false_negatives": false_neg
                    }
      
                eval_metrics = metric_fn(label_ids, predicted_labels)
      
                if mode == tf.estimator.ModeKeys.TRAIN:
                    return tf.estimator.EstimatorSpec(mode=mode,
                                                      loss=loss,
                                                      train_op=train_op)
                return tf.estimator.EstimatorSpec(mode=mode,
                                                  loss=loss,
                                                  eval_metric_ops=eval_metrics)
            (predicted_labels, log_probs) = self.create_model(
                is_predicting, input_ids, input_mask, segment_ids, label_ids, num_labels)
    
            predictions = {
                'probabilities': log_probs,
                'labels': predicted_labels
            }
            return tf.estimator.EstimatorSpec(mode, predictions=predictions)

        # Return the actual model function in the closure
        return model_fn

    def getPrediction(self, in_sentences):
        """A method to get predictions"""
        debug.trace(5, f"getPrediction({in_sentences})")

        # A list to map the actual labels to the predictions
        labels = ["Politics", "Technology", "Entertainment", "Business"]
      
        # Transforming the test data into BERT accepted form
        input_examples = [run_classifier.InputExample(guid="", text_a=x, text_b=None, label=0) for x in in_sentences] 
        
        # Creating input features for Test data
        input_features = run_classifier.convert_examples_to_features(input_examples, self.LABEL_LIST, self.MAX_SEQ_LENGTH, self.tokenizer)
      
        # Predicting the classes 
        predict_input_fn = run_classifier.input_fn_builder(features=input_features, seq_length=self.MAX_SEQ_LENGTH, is_training=False, drop_remainder=False)
        predictions = self.estimator.predict(predict_input_fn)
        return [(sentence, prediction['probabilities'], prediction['labels'], labels[prediction['labels']]) for sentence, prediction in zip(in_sentences, predictions)]
      
      
    def run_main_step(self):
        """Main processing step"""
        debug.trace_fmtd(5, "Script.run_main_step(): self={s}", s=self)

        # Load the data and also split the training set in to training and validation sets.
        train = pd.read_excel(system.form_path(INPUT_DIR, TRAINING_PATH))
        test = pd.read_excel(system.form_path(INPUT_DIR, TESTING_PATH))
        train, val =  train_test_split(train, test_size=0.2, random_state=100)

        # Show training set sample
        debug.trace_fmt(4, "Train sample:\n{s}", s=train.head(5))
        debug.trace_fmt(4, "Test sample:\n{s}", s=test.head(5))
        print("Training Set Shape :", train.shape)
        print("Validation Set Shape :", val.shape)
        print("Test Set Shape :", test.shape)

        # Features in the dataset
        # ex: Index(['STORY', 'SECTION'], dtype='object')
        debug.trace_fmt(4, "Train columns: {c}", c=train.columns)

        # unique classes
        # ex; array([3, 1, 2, 0])
        debug.trace_fmt(4, "Unique training classes: {c}",
                        c=train['SECTION'].unique())
        
        # Distribution of classes
        # ex: <matplotlib.axes._subplots.AxesSubplot at 0x7ff5921f9ba8>
        if SHOW_PLOTS:
            train['SECTION'].value_counts().plot(kind='bar')

        # Compute train and warmup steps from batch size
        ## BAD: num_train_steps = int(len(train_features) / self.BATCH_SIZE * self.NUM_TRAIN_EPOCHS)
        num_train_steps = int(len(train) / self.BATCH_SIZE * self.NUM_TRAIN_EPOCHS)
        num_warmup_steps = int(num_train_steps * self.WARMUP_PROPORTION)
        
        # Specify output directory and number of checkpoint steps to save
        run_config = tf.estimator.RunConfig(
            model_dir=OUTPUT_DIR,
            save_summary_steps=self.SAVE_SUMMARY_STEPS,
            save_checkpoints_steps=self.SAVE_CHECKPOINTS_STEPS)
        
        # Specify output directory and number of checkpoint steps to save
        run_config = tf.estimator.RunConfig(
            model_dir=OUTPUT_DIR,
            save_summary_steps=self.SAVE_SUMMARY_STEPS,
            save_checkpoints_steps=self.SAVE_CHECKPOINTS_STEPS)

        # Initializing the model and the estimator
        model_fn = self.model_fn_builder(
            num_labels=len(self.LABEL_LIST),
            learning_rate=self.LEARNING_RATE,
            num_train_steps=num_train_steps,
            num_warmup_steps=num_warmup_steps)
        #
        self.estimator = tf.estimator.Estimator(
            model_fn=model_fn,
            config=run_config,
            params={"batch_size": self.BATCH_SIZE})
        
        # Read in training data
        # See 'Data preprocessing' notes in the header comments
        train_InputExamples = train.apply(lambda x:
                                          bert.run_classifier.InputExample(
                                              guid=None,
                                              text_a=x[self.DATA_COLUMN], 
                                              text_b=None, 
                                              label=x[self.LABEL_COLUMN]),
                                          axis=1)
        val_InputExamples = val.apply(lambda x:
                                      bert.run_classifier.InputExample(
                                          guid=None, 
                                          text_a=x[self.DATA_COLUMN], 
                                          text_b=None, 
                                          label=x[self.LABEL_COLUMN]),
                                      axis=1)
        debug.trace_object(5, train_InputExamples, "train_InputExamples")
        debug.trace_fmt(4, "Row 0 - guid of training set: {r}", r=train_InputExamples.iloc[0].guid)
        debug.trace_fmt(4, "__________\nRow 0 - text_a of training set {t}: ", t=train_InputExamples.iloc[0].text_a)
        debug.trace_fmt(4, "__________\nRow 0 - text_b of training set: {t}", t=train_InputExamples.iloc[0].text_b)
        debug.trace_fmt(4, "__________\nRow 0 - label of training set: {l}", l=train_InputExamples.iloc[0].label)

        # Convert to BERT format
        self.tokenizer = self.create_tokenizer_from_hub_module()
        debug.trace_fmt(4, "row 0 tokenized: {t}", t=self.tokenizer.tokenize(train_InputExamples.iloc[0].text_a))

        # Convert train and validation features to InputFeatures that BERT understands.
        train_features = bert.run_classifier.convert_examples_to_features(
            train_InputExamples, self.LABEL_LIST, self.MAX_SEQ_LENGTH, self.tokenizer)

        val_features = bert.run_classifier.convert_examples_to_features(
            val_InputExamples, self.LABEL_LIST, self.MAX_SEQ_LENGTH, self.tokenizer)
        
        # Example on first observation in the training set
        debug.trace_fmt(4, "Sentence: {s}", s=train_InputExamples.iloc[0].text_a)
        debug.trace_fmt(4, "-"*30)
        debug.trace_fmt(4, "Tokens: {t}", t=self.tokenizer.tokenize(train_InputExamples.iloc[0].text_a))
        debug.trace_fmt(4, "-"*30)
        debug.trace_fmt(4, "Input IDs: {i}", i=train_features[0].input_ids)
        debug.trace_fmt(4, "-"*30)
        debug.trace_fmt(4, "Input Masks: {m}", m=train_features[0].input_mask)
        debug.trace_fmt(4, "-"*30)
        debug.trace_fmt(4, "Segment IDs: {i}", i=train_features[0].segment_ids)

        # Initializing the model and the estimator
        model_fn = self.model_fn_builder(
            num_labels=len(self.LABEL_LIST),
            learning_rate=self.LEARNING_RATE,
            num_train_steps=num_train_steps,
            num_warmup_steps=num_warmup_steps)

        self.estimator = tf.estimator.Estimator(
            model_fn=model_fn,
            config=run_config,
            params={"batch_size": self.BATCH_SIZE})

        # Create an input function for training. Use drop_remainder=True when using TPUs.
        train_input_fn = bert.run_classifier.input_fn_builder(
            features=train_features,
            seq_length=self.MAX_SEQ_LENGTH,
            is_training=True,
            drop_remainder=False)

        # Create an input function for validating. Use drop_remainder=True when using TPUs.
        val_input_fn = run_classifier.input_fn_builder(
            features=val_features,
            seq_length=self.MAX_SEQ_LENGTH,
            is_training=False,
            drop_remainder=False)

        # Train the model
        debug.trace(4, "Beginning Training!")
        current_time = datetime.now()
        self.estimator.train(input_fn=train_input_fn, max_steps=num_train_steps)
        debug.trace_fmt(4, "Training took time {t}", t=(datetime.now() - current_time))
        
        # Evaluating the model with Validation set
        self.estimator.evaluate(input_fn=val_input_fn, steps=None)

        # Evaluate over test set
        # note: creates Excel submission file
        pred_sentences = list(test['STORY'])
        predictions = self.getPrediction(pred_sentences)
        debug.trace_expr(4, predictions[0])
        #
        enc_labels = []
        act_labels = []
        for i in range(len(predictions)):
            enc_labels.append(predictions[i][2])
            act_labels.append(predictions[i][3])
        #
        data_file = system.form_path(INPUT_DIR, SUBMISSION_FILE)
        pd.DataFrame(enc_labels, columns=['SECTION']).to_excel(data_file,
                                                               index=False)

        # Classifying random sentences
        tests = self.getPrediction(
            ['Mr.Modi is the Indian Prime Minister',
             'Gaming machines are powered by efficient micro processores and GPUs',
             'That HBO TV series is really good',
             'A trillion dollar economy '
            ])
        debug.trace_object(4, tests, "tests")
        return

#-------------------------------------------------------------------------------
    
if __name__ == '__main__':
    debug.trace_current_context(level=debug.QUITE_DETAILED)
    app = Script(
        description=__doc__,
        skip_input=False,
        manual_input=True,
    )
    app.run()
