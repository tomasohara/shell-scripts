#! /bin/bash
#
# Adhoc script for preprocessing text and sending the result thorugh BERT (or ALBERT) for
# pretraining. This works around extreme memory limitations of the BERT preprocessing scripts,
# namely gobbling up most of the available memory.
#
# notes:
# - This script is far from general purpose; however, it should be a useful starting point
#   (e.g., rather than you having to creating a similar script from scratch).
# - My utility scripts need to be installed locally:
#      https://github.com/tomasohara/misc-utility
#   Put them in /usr/local/misc/tomohara-scripts
# - There are a few other directories assumed under /usr/local/misc:
#   programs/python/bert: BERT distribution
#   data/deep-learning/bert: BERT models
# - See ~/python/run_batched_pretraining.py for script that receives the result
#   and then invokes the GPU pretraining.
# - Preprocesses text in batches of 25k lines for subsequent pretraining on GPU server.
# - The 100k size was chosen to allow for good throughput (compared to original 10k sample) while
#   allowing for better restarts compared to 500k (e.g., in case GPU server rebooted mid-stream).
#
# TODO:
# - Convert into Python.
# - Feed into create_pretraining_data.py using "shards" (see https://github.com/google-research/bert).
# - List environment variables used.
#

# Uncomment following line(s) for tracing:
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#  
## echo "$@"
## set -o xtrace
## set -o verbose

# Show usage example if insufficient arguments
if [ "$1" = "" ]; then
    echo "Usage: $0 [options] input-file [output-basename [increment [starting-offset]]]"
    echo "    options: [--albert] [--trace] [--vocab-file file] [--quick]"
    echo ""
    script=$(basename "$0")
    echo "example: $script simplewiki-20201201-pages-articles-multistream.txt simple-english-wiki 100000 0"
    echo ""
    exit
fi
#
bert="bert"
use_albert=0
vocab_file=""
quick_mode="0"
while [[ "$1" =~ ^-+ ]]; do
    if [ "$1" = "--albert" ]; then
        use_albert=1
	bert="albert"
    elif [ "$1" = "--vocab-file" ]; then
        vocab_file="$2"
        shift
    elif [ "$1" = "--quick" ]; then
        quick_mode="1"
    elif [ "$1" = "--trace" ]; then
        set -o xtrace
    fi
    shift
done

# Helper functions
#
# Return basename for last checkpoint file created (e.g., model.ckpt-100000)
function get-last-checkpoint() {
    last_checkpoint=$(ls -t "$OUTPUT_DIR"/*ckpt*meta | head -1 | perl -pe 's/.meta//;')
    echo "$last_checkpoint"
}

# Extract command-line arguments
input_file="$1"
input_base=$(basename "$input_file" .txt)
#
output_base="$2"
if [ "$output_base" = "" ]; then output_base="$input_base.shard"; fi
#
increment="$3"
if [ "$increment" = "" ]; then increment="25000"; fi
#
starting_offset="$4"
if [ "$starting_offset" = "" ]; then starting_offset="0"; fi

# Initialize
if [ "$PROJECT_DIR" = "" ]; then PROJECT_DIR="/usr/local/misc"; fi
export PATH="$PATH:$PROJECT_DIR/scripts/tomohara-scripts"
TEMP_DIR="$PROJECT_DIR/temp"
#
if [ "$CODE_DIR" = "" ]; then CODE_DIR="$PROJECT_DIR"/programs/python/bert; fi
if [ "$DATA_DIR" = "" ]; then DATA_DIR="$PROJECT_DIR"/data/deep-learning; fi
if [ "$BERT_DIR" = "" ]; then BERT_DIR="$DATA_DIR"/bert/bert_base; fi
if [ "$use_albert" = "1" ]; then
    if [ "$CODE_DIR" = "" ]; then CODE_DIR="$PROJECT_DIR"/programs/python/albert; fi
    if [ "$DATA_DIR" = "" ]; then DATA_DIR="$PROJECT_DIR"/data/deep-learning; fi
    if [ "$BERT_DIR" = "" ]; then BERT_DIR="$DATA_DIR"/albert/albert_base; fi
fi
#
TIME_CMD=/usr/bin/time
if [ "$NICE" = "" ]; then NICE="nice -19"; fi
if [ "$PYTHON" = "" ]; then PYTHON="$NICE $TIME_CMD python -u"; fi
#
# TODO: conda-activate-env bert-tensorflow-gpu
if [ "$OUTPUT_DIR" = "" ]; then OUTPUT_DIR="."; fi

# Derive options not specified
if [ "$vocab_file" = "" ]; then
    if [ "$use_albert" = "0" ]; then vocab_file="$BERT_DIR"/vocab.txt; else vocab_file="$BERT_DIR"/30k-clean.vocab; fi
fi
spm_arg=""
if [ "$use_albert" = "1" ]; then
    # TODO: fix extension substitution to handle spaces in filename
    ## spm_model_file="$(dirname $vocab_file .vocab)$(basename $vocab_file .vocab).model"
    spm_model_file=$(echo $vocab_file | perl -pe 's/\.vocab/\.model/g;')
    spm_arg="--spm_model_file $spm_model_file"
fi

# Generate vocabulary if '-' specified for vocabulary file
# TODO: parameterize vocaulary size (30k), etc.
if [ "$vocab_file" = "-" ]; then
    vocab_base=30k-clean
    if [[ ("$quick_mode" = "0") || ( ! -e "$OUTPUT_DIR/$vocab_base.model") ]]; then
        LD_LIBRARY_PATH=/home/tomohara/programs/sentencepiece-oct20/build/src:$LD_LIBRARY_PATH $TIME_CMD /home/tomohara/programs/sentencepiece-oct20/build/src/spm_train \
            --input "$input_file" --model_prefix="$OUTPUT_DIR/$vocab_base" --vocab_size=30000 \
    	--pad_id=0 --unk_id=1 --eos_id=-1 --bos_id=-1 \
    		   --control_symbols='[CLS],[SEP],[MASK]' \
            --user_defined_symbols="(,),\",-,.,–,£,€" \
    	--shuffle_input_sentence=true --input_sentence_size=10000000 \
            --character_coverage=0.99995 --model_type=unigram \
    	    > "$OUTPUT_DIR/$vocab_base".spm_train.log 2>&1
    fi
    vocab_file="$OUTPUT_DIR/$vocab_base.vocab"
    spm_arg="--spm_model_file $OUTPUT_DIR/$vocab_base.model"
fi

# Get settings from environment
# TODO: convert into argument parsing
if [ "$OUTPUT_DIR" = "" ]; then OUTPUT_DIR="."; fi
#
if [ "$NUM_TRAIN_INCRS" = "" ]; then NUM_TRAIN_INCRS=100000; fi
#
## OLD: if [ "$NUM_TRAIN_STEPS" = "" ]; then NUM_TRAIN_STEPS=1250000; fi
if [ "$NUM_TRAIN_STEPS" = "" ]; then NUM_TRAIN_STEPS=$NUM_TRAIN_INCRS; fi
#
if [ "$TRAIN_BATCH_SIZE" = "" ]; then TRAIN_BATCH_SIZE=64; fi
#
if [ "$MAX_SEQ_LENGTH" = "" ]; then MAX_SEQ_LENGTH=128; fi
#
init_checkpoint_arg=""
if [ "$INIT_CHECKPOINT" = "" ]; then
    # Get most record checkpoint file
    INIT_CHECKPOINT=$(get-last-checkpoint)
    if [ "$INIT_CHECKPOINT" != "" ]; then

	# Determine number of steps that from filename plus increment
	# ex: "model.ckpt-12500" => 13750
	init_checkpoint_arg="--init_checkpoint=$INIT_CHECKPOINT"
        last_num_steps=$(echo "$INIT_CHECKPOINT" | extract_matches.perl "ckpt-(\d+)")
        if [ "$last_num_steps" = "" ]; then
    	    echo "Warning: unable to determine num steps from last checkpoint ($INIT_CHECKPOINT)"
        else
    	    let NUM_TRAIN_STEPS=($last_num_steps + $NUM_TRAIN_INCRS)
        fi
    fi
fi
#
if [ "$SAVE_CHECKPOINTS_STEPS" = "" ]; then SAVE_CHECKPOINTS_STEPS=1000; fi
# TODO: let KEEP_CHECKPOINT_MAX=($NUM_TRAIN_STEPS / $SAVE_CHECKPOINTS_STEPS)
if [ "$KEEP_CHECKPOINT_MAX" = "" ]; then KEEP_CHECKPOINT_MAX=125; fi
#
if [ "$BERT_CONFIG_FILE" = ""  ]; then BERT_CONFIG_FILE=$BERT_DIR/${bert}_config.json; fi

# Preprocess in chunks
# TODO: use split
temp_base="$TEMP_DIR/$output_base"
cp -vp "$input_file" "$temp_base.txt"
total_lines=$(wc -l < "$input_file")
#
offset="$starting_offset"
while (( $offset < $total_lines )); do
    output_base="$temp_base.from${offset}.size$increment"
    tail --lines=+$offset "$temp_base.txt" | head --lines=$increment > "$output_base".list
    let offset+=$increment

    # Place sentences on separate lines
    if [[ ("$quick_mode" = "0") || ( ! -e "$output_base".prep.list) ]]; then
	$TIME_CMD perl -Ssw prep_brill.perl -para -retain_punct "$output_base".list > "$output_base".prep.list 2> "$output_base".prep.log
    fi

    # Convert input into masked-LM format
    if [[ ("$quick_mode" = "0") || ( ! -e "$output_base".bert-pp.list) ]]; then
	$PYTHON "$CODE_DIR"/create_pretraining_data.py --vocab_file "$vocab_file" $spm_arg --do_lower_case=false --input_file "$output_base".prep.list --output_file "$output_base".bert-pp.list --max_seq_length=$MAX_SEQ_LENGTH > "$output_base".bert-pp.log 2>&1
    fi

    # Run pretraining
    misc_options=""
    if [ "$TENSORBOARD_LOG_DIR" != "" ]; then misc_options="$misc_options --tensorboard_log_dir '$TENSORBOARD_LOG_DIR'"; fi
    #
    $PYTHON "$CODE_DIR"/run_pretraining.py --do_train=true --input_file "$output_base".bert-pp.list --output_dir="$OUTPUT_DIR" --${bert}_config_file=$BERT_CONFIG_FILE --num_train_steps=$NUM_TRAIN_STEPS --save_checkpoints_steps=$SAVE_CHECKPOINTS_STEPS --keep_checkpoint_max=$KEEP_CHECKPOINT_MAX --train_batch_size=$TRAIN_BATCH_SIZE --max_seq_length=$MAX_SEQ_LENGTH $init_checkpoint_arg $misc_options > "$output_base".pre-train.log 2>&1
    # TODO:
    ## Send to GPU server (n.b., need to run ssh-agent & then ssh-add beforehand to give passphrase)
    ## scp "$output_base".bert-pp.list  $gpu_server:/temp

    # Update counters, etc. (e.g., checkpoint file)
    last_checkpoint=$(get-last-checkpoint)
    if [ "$last_checkpoint" != "" ]; then
	init_checkpoint_arg="--init_checkpoint=$last_checkpoint"
    fi
    let NUM_TRAIN_STEPS+=$NUM_TRAIN_INCRS
done
