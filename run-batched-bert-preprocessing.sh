#! /bin/bash
#
# Adhoc script for preprocessing text and running the result through BERT (or ALBERT) for
# pretraining. This works around extreme memory limitations of the BERT preprocessing scripts,
# namely gobbling up most of the available memory.
#
# Notes:
# - This script is far from general purpose; however, it should be a useful starting point
#   (e.g., rather than you having to creating a similar script from scratch).
# - My utility scripts need to be installed locally:
#      https://github.com/tomasohara/misc-utility
#   Make sure they are in the shell's path or put them in following directory:
#      /usr/local/misc/programs/bash/shell-scripts
# - There are a few other directories assumed under /usr/local/misc:
#   programs/python/bert: BERT distribution
#   data/deep-learning/bert: BERT models
# - See ~/python/run_batched_pretraining.py for script that receives the result
#   and then invokes the GPU pretraining (TODO: add to repo).
# - Preprocesses text in batches (e.g., 25k lines) and invokes BERT pretraining.
# - The 100k size was chosen to allow for good throughput (compared to original 10k sample) while
#   allowing for better restarts compared to 500k (e.g., in case GPU server rebooted mid-stream).
# - By default, pretraining is done from scratch (unless INIT_CHECKPOINT set, see below).
# - Following shellcheck warnings selectively ignored:
#     SC2004: $/${} is unnecessary on arithmetic variables
#     SC2012: Use find instead of ls to better handle non-alphanumeric filenames
#     SC2086: Double quote to prevent globbing and word splitting
#     SC2089: Quotes/backslashes will be treated literally. Use an array
#     SC2090: Quotes/backslashes in this variable will not be respected.
#--------------------------------------------------------------------------------
# Sample startup sequence:
#
#   export PATH="/usr/local/misc/programs/anaconda3/envs/tensorflow-gpu-cuda8-py3-6/bin:$PATH"
#   export CODE_DIR=$HOME/programs/python/bert          
#   filename="random-PDF-text.txt"
#   in_base=$(basename "$filename" .txt)                
#   out_base="_run-${in_base}"                          
#   export INPUT_FILE="$filename"                       # input text file
#   export OUTPUT_BASE="$out_base"                      # result of preprocessing
#   export OUTPUT_DIR="$out_base"                       # result of pretraining
#   export PROJECT_DIR="."                              # where ./temp is placed
#   pkg_dir="$HOME/$USER/.conda/pkgs"                   
#   export LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:/usr/lib/nvidia-450:/usr/local/cuda-11.1/lib64:$pkg_dir/cudatoolkit-10.1.243-h6bb024c_0/lib:$pkg_dir/cudnn-7.6.5-cuda10.1_0/lib:/usr/local/misc/lib/cuda-repo-ubuntu1604-10-0-local-10.0.130-410.48_1.0-1:/usr/local/cuda/extras/CUPTI/lib64"       
#   export TRAIN_BATCH_SIZE=48 MAX_SEQ_LENGTH=128       
#   export NUM_TRAIN_INCRS="100000"         
#   export TF_FORCE_GPU_ALLOW_GROWTH=true     
#   export CUDA_VISIBLE_DEVICES="0"           
#   export NVIDIA_VISIBLE_DEVICES="0"         
#   export SAVE_CHECKPOINTS_STEPS="100"       
#   export KEEP_CHECKPOINT_MAX="10"           
#   export BERT_DIR=/usr/local/misc/data/deep-learning/bert/bert_medium          
#
#   line_incr=100000
#   run-batched-bert-preprocessing.sh --trace "$INPUT_FILE" "$OUTPUT_BASE" "$line_incr"
#   
#--------------------------------------------------------------------------------
# TODO:
# - ** rename (e.g. run-batched-bert-pretraining.sh).
# - Convert into Python.
# - Feed into create_pretraining_data.py using "shards" (see https://github.com/google-research/bert).
# - List environment variables used.
# - Clarify output_base vs. OUTPUT_DIR (e.g., preprocessing vs. pretraining).
# - Specify KEEP_CHECKPOINT_MAX in terms of increments???
#

# Uncomment following line(s) for tracing:
# - xtrace shows arg expansion (and often is sufficient)
# - verbose shows source commands as is (but usually is superfluous w/ xtrace)
#  
## echo "$@"
## set -o xtrace
## set -o verbose

#..............................................................................

# Helper functions
#

function show_usage {
    echo "Usage: $0 [options] input-file [output-basename [increment [starting-offset]]]"
    echo "    options: [--albert] [--trace] [--vocab-file file] [--verbose] [--quick] [--]"
    echo ""
    script=$(basename "$0")
    echo "example: $script simplewiki-20201201-pages-articles-multistream.txt simple-english-wiki 100000 0"
    echo ""
    # TODO: add notes (e.g., --quick and also use of sentence piece for Albert)
    echo "Notes:"
    echo "- Use - for vocabulary file to auto-generate (--albert only);"
    echo "  otherwise existing voabulary file used (e.g., from repo)."
    echo "- The --quick option re-uses existing preprocessed files."
    echo "- Environment variables:"
    echo "-   OUTPUT_DIR: directory for intermediate and final output files"
    echo "-   CODE_DIR: base directory for installed programs, etc."
    echo "-   PROJECT_DIR: base directory for pretraining project"
    echo "-   BERT_CONFIG_FILE: customized [al]bert_config.json"
    echo "-   CODE_DIR: BERT code directory"
    echo "-   BERT_DIR: BERT data directory"
    echo "-   MAX_TRACED: number of eamples to show"
    echo "-   NUM_TRAIN_STEPS: number of training steps"
    echo "-   NUM_TRAIN_INCRS: numbers of training steps ub each batch"
    echo "-   TRAIN_BATCH_SIZE: Number of batches per training step"
    echo "-   MAX_SEQ_LENGTH: size of context window"
    echo "-   KEEP_CHECKPOINT_MAX: Number of checkpoint files (.ckpt) to preserve"
    echo "-   VOCAB_SIZE_K: size of vocabulary in 1000s (albert only)"
    echo "-   See run_pretraining.py from BERT distribution"
    echo "- Temporary filed are placed in $PROJECT_DIR/temp:"
    echo "    ex: /usr/local/misc/temp"
}

# Return basename for last checkpoint file created (e.g., model.ckpt-100000)
function get-last-checkpoint() {
    # shellcheck disable=SC2012
    last_checkpoint=$(ls -t "$OUTPUT_DIR"/*ckpt*meta 2> /dev/null | head -1 | perl -pe 's/.meta//;')
    ## OLD: last_checkpoint=$(ls -t "$OUTPUT_DIR"/*ckpt*meta | head -1 | perl -pe 's/.meta//;')
    echo "$last_checkpoint"
}

#................................................................................

# Parse command line arguments
bert="bert"
use_albert=0
vocab_file=""
quick_mode="0"
show_usage="0"
verbose="0"
if [ "$1" = "" ]; then
    show_usage="1";
fi
while [[ "$1" =~ ^-+ ]]; do
    if [ "$1" = "--albert" ]; then
        use_albert=1
	bert="albert"
    elif [ "$1" = "--vocab-file" ]; then
        vocab_file="$2"
        shift
    elif [ "$1" = "--quick" ]; then
        quick_mode="1"
    elif [ "$1" = "--help" ]; then
        show_usage="1"
    elif [ "$1" = "--trace" ]; then
        set -o xtrace
    elif [ "$1" = "--verbose" ]; then
        verbose="1"
    fi
    shift
done

# Show usage example if insufficient arguments
if [ "$show_usage" = "1" ]; then
    show_usage
    exit
fi
#

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

# Validate arguments
if [ ! -e "$input_file" ]; then
    echo "Error: input file not found: $input_file"
    exit
fi

# Showing starting time
date

# Trace out environment
if [ "$verbose" == "1" ]; then
   printenv
fi

# Initialize
## OLD: if [ "$PROJECT_DIR" = "" ]; then PROJECT_DIR="/usr/local/misc"; fi
if [ "$CODE_BASE" = "" ]; then CODE_BASE="/usr/local/misc"; fi
if [ "$PROJECT_DIR" = "" ]; then PROJECT_DIR="."; fi
export PATH="$PATH:$CODE_BASE/programs/bash/shell-scripts"
TEMP_DIR="$PROJECT_DIR/temp"
mkdir -p "$TEMP_DIR"
#
if [ "$CODE_DIR" = "" ]; then CODE_DIR="$CODE_BASE"/programs/python/bert; fi
if [ "$DATA_DIR" = "" ]; then DATA_DIR="$CODE_BASE"/data/deep-learning; fi
if [ "$BERT_DIR" = "" ]; then BERT_DIR="$DATA_DIR"/bert/bert_base; fi
if [ "$use_albert" = "1" ]; then
    if [ "$CODE_DIR" = "" ]; then CODE_DIR="$CODE_BASE"/programs/python/albert; fi
    if [ "$DATA_DIR" = "" ]; then DATA_DIR="$CODE_BASE"/data/deep-learning; fi
    if [ "$BERT_DIR" = "" ]; then BERT_DIR="$DATA_DIR"/albert/albert_base; fi
fi
#
# Make sure $CODE_BASE version of [al]bert used instead of default for environment
export PYTHONPATH="$(realpath $CODE_DIR/..):$PYTHONPATH"
export PATH="$(realpath $CODE_DIR/..):$PATH"
#
TIME_CMD=/usr/bin/time
if [ "$NICE" = "" ]; then NICE="nice -19"; fi
if [ "$PYTHON" = "" ]; then PYTHON="$NICE $TIME_CMD python -u"; fi
#
# TODO: conda-activate-env bert-tensorflow-gpu
if [ "$OUTPUT_DIR" = "" ]; then OUTPUT_DIR="."; fi
mkdir -p "$OUTPUT_DIR"

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
# TOOD: add explicit error check for vocabulary size issue with small files
if [ "$vocab_file" = "-" ]; then
    vocab_size="${VOCAB_SIZE_K:-30}"
    ## OLD: vocab_base=30k-clean
    vocab_base="${vocab_size}k-clean"
    if [[ ("$quick_mode" = "0") || ( ! -e "$OUTPUT_DIR/$vocab_base.model") ]]; then
        ## LD_LIBRARY_PATH=/home/tomohara/programs/sentencepiece-oct20/build/src:$LD_LIBRARY_PATH $TIME_CMD /home/tomohara/programs/sentencepiece-oct20/build/src/spm_train \
	LD_LIBRARY_PATH=$CODE_BASE/programs/sentencepiece-oct20/build/src:$LD_LIBRARY_PATH $TIME_CMD $CODE_BASE/programs/sentencepiece-oct20/build/src/spm_train \
            --input "$input_file" --model_prefix="$OUTPUT_DIR/$vocab_base" --vocab_size="${vocab_size}000" \
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

	# Determine number of steps from filename plus increment
	# ex: "model.ckpt-12500" => 13750
	init_checkpoint_arg="--init_checkpoint=$INIT_CHECKPOINT"
        last_num_steps=$(echo "$INIT_CHECKPOINT" | extract_matches.perl "ckpt-(\d+)")
        if [ "$last_num_steps" = "" ]; then
    	    echo "Warning: unable to determine num steps from last checkpoint ($INIT_CHECKPOINT)"
        else
    	    ## OLD: let NUM_TRAIN_STEPS=($last_num_steps + $NUM_TRAIN_INCRS)
    	    (( NUM_TRAIN_STEPS=(last_num_steps + NUM_TRAIN_INCRS) ))
        fi
    fi
else
    # TODO: make FYI
    echo "Warning: Training from scratch (i.e., no initial checkpoint)"
fi
#
if [ "$SAVE_CHECKPOINTS_STEPS" = "" ]; then SAVE_CHECKPOINTS_STEPS=1000; fi
# TODO: let KEEP_CHECKPOINT_MAX=($NUM_TRAIN_STEPS / $SAVE_CHECKPOINTS_STEPS)
## TEST: if [ "$KEEP_CHECKPOINT_MAX" = "" ]; then KEEP_CHECKPOINT_MAX=125; fi
if [ "$KEEP_CHECKPOINT_MAX" = "" ]; then KEEP_CHECKPOINT_MAX=10; fi
#
if [ "$BERT_CONFIG_FILE" = ""  ]; then BERT_CONFIG_FILE=$BERT_DIR/${bert}_config.json; fi
#
if [ "$MAX_TRACED" = "" ]; then MAX_TRACED=20; fi
#
if [ "$LEARNING_RATE" = "" ]; then LEARNING_RATE=5e-5; fi


# Preprocess in chunks
# TODO: use split
temp_base="$TEMP_DIR/$output_base"
cp -vp "$input_file" "$temp_base.txt"
total_lines=$(wc -l < "$input_file")
#
num_cases=0
offset="$starting_offset"
# shellcheck disable=SC2004
while (( $offset < $total_lines )); do
    output_base="$temp_base.from${offset}.size$increment"
    tail --lines=+$offset "$temp_base.txt" | head --lines=$increment > "$output_base".list
    let offset+=$increment
    let num_cases++

    # Place sentences on separate lines
    if [[ ("$quick_mode" = "0") || ( ! -e "$output_base".prep.list) ]]; then
	$TIME_CMD perl -Ssw prep_brill.perl -para -retain_punct "$output_base".list > "$output_base".prep.list 2> "$output_base".prep.log
    fi

    # Convert input into masked-LM format
    if [[ ("$quick_mode" = "0") || ( ! -e "$output_base".bert-pp.list) ]]; then
	# shellcheck disable=SC2086
	$PYTHON "$CODE_DIR"/create_pretraining_data.py --vocab_file "$vocab_file" $spm_arg --do_lower_case=false --input_file "$output_base".prep.list --output_file "$output_base".bert-pp.list --max_traced="$MAX_TRACED" --max_seq_length=$MAX_SEQ_LENGTH > "$output_base".bert-pp.log 2>&1
    fi

    # Run pretraining
    misc_options=""
    # shellcheck disable=SC2089
    if [ "$TENSORBOARD_LOG_DIR" != "" ]; then misc_options="$misc_options --tensorboard_log_dir '$TENSORBOARD_LOG_DIR'"; fi
    #
    # shellcheck disable=SC2086,SC2090
    $PYTHON "$CODE_DIR"/run_pretraining.py --do_train=true --input_file "$output_base".bert-pp.list --output_dir="$OUTPUT_DIR" --${bert}_config_file="$BERT_CONFIG_FILE" --num_train_steps="$NUM_TRAIN_STEPS" --save_checkpoints_steps="$SAVE_CHECKPOINTS_STEPS" --keep_checkpoint_max="$KEEP_CHECKPOINT_MAX" --train_batch_size="$TRAIN_BATCH_SIZE" --max_seq_length="$MAX_SEQ_LENGTH" --learning_rate="$LEARNING_RATE" $init_checkpoint_arg $misc_options > "$output_base".pre-train.log 2>&1
    out_of_memory=$(grep "Resource exhausted: OOM" "$output_base".pre-train.log)
    if [ "$out_of_memory" != "" ]; then
	echo "Error: insufficient GPU memory"
	break
    fi
    
    # TODO: Make pre-training output read-only (excluding temporary directories)
    # Note: this is so that the checkpoints are not deleted in next increment
    ## chmod -w "$OUTPUT_DIR"/*ckpt*{data,index,meta}*

    # Update counters, etc. (e.g., checkpoint file)
    last_checkpoint=$(get-last-checkpoint)
    if [ "$last_checkpoint" != "" ]; then
	init_checkpoint_arg="--init_checkpoint=$last_checkpoint"
    fi
    let NUM_TRAIN_STEPS+=$NUM_TRAIN_INCRS
done
#
if [ $num_cases -eq 0 ]; then
    echo "Error: no increments run"
fi

# Showing ending time
date
