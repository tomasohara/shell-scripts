#! /bin/bash
#
# Adhoc script for preprocessing text and sending the result thorugh BERT for pretraining.
# This works around extreme memory limitations of the BERT preprocessing scripts, namely
# gobbling up most of the available memory.
#
# notes:
# - See ~/python/run_batched_pretraining.py for script that receives the result
#   and then invokes the GPU pretraining.
# - Preprocesses text in batches of 25k lines for subsequent pretraining on GPU server.
# - The 100k size was chosen to allow for good throughput (compared to original 10k sample) while
#   allowing for better restarts compared to 500k (e.g., in case GPU server rebooted mid-stream).
#
# TODO:
# - Convert into Python.
# - Feed into create_pretraining_data.py using "shards" (see https://github.com/google-research/bert).
#

# Show usage example if insufficient arguments
if [ "$1" == "" ]; then 
    echo "Usage: $0 input-file [output-basename [starting-offset [increment]]]"
    echo ""
    script=$(basename "$0")
    echo "example: $script simpleenwiki-110120.hgw.txt simple-english-wiki 100000 15000"
    echo ""
    exit
fi

# Extract command-line arguments
input_file="$1"
input_base=$(basename "$input_file" .txt)
#
output_base="$2"
if [ "$output_base" = "" ]; then output_base="$input_base.shard"; fi
#
starting_offset="$3"
if [ "$starting_offset" = "" ]; then starting_offset="0"; fi
#
increment="$3"
if [ "$increment" = "" ]; then increment="25000"; fi

# Initialize
PROJECT_DIR="/usr/local/misc"
export PATH="$PATH:$PROJECT_DIR/scripts/tomohara-scripts"
TEMP_DIR="$PROJECT_DIR/temp"
#
CODE_DIR="$PROJECT_DIR"/programs/python/biobert
DATA_DIR="$PROJECT_DIR"/data/deep-learning
BERT_DIR="$DATA_DIR"/BioBERT/biobert_v1.0_pubmed_pmc
#
TIME_CMD=/usr/bin/time
if [ "$NICE" = "" ]; then NICE="nice -19"; fi
if [ "$PYTHON" = "" ]; then PYTHON="$NICE $TIME_CMD python -u"; fi
#
# TODO: conda-activate-env bert-tensorflow-gpu

# Preprocess in chucks
# TODO: use split
temp_base="$TEMP_DIR/$output_base"
total_lines=$(wc -l < "$input_file")
#
offset="$increment"
while (( $offset < $total_lines )); do
    output_base="$TEMP_DIR/$temp_base.from${offset}.size$offset"
    tail --lines=+$offset "$temp_base.txt" | head --lines=$increment > "$output_base".list
    let offset+=$increment

    # Place sentences on separate lines
    $TIME_CMD perl -Ssw prep_brill.perl -para -retain_punct "$output_base".list > "$output_base".prep.list 2> "$output_base".prep.log

    # Convert input into masked-LM format
    $PYTHON "$CODE_DIR"/create_pretraining_data.py --vocab_file "$BERT_DIR"/vocab.txt --do_lower_case=false --input_file "$output_base".prep.list --output_file "$output_base".bert-pp.list > "$output_base".bert-pp.log 2>&1

    # Send to GPU server (n.b., need to run ssh-agent & then ssh-add beforehand to give passphrase)
    # TODO: scp "$output_base".bert-pp.list  $gpu_server:/temp
done
