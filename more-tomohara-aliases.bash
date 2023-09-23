# more-tomohara-aliases.bash: Additional aliases (& functions) that arern't
# used on a regular basis. This supplements tomohara-aliases.bash.
#
# Note: OBSOLETE and besides TOM-IDIOSYNCRATIC
#

function derive-ngram-frequency() {
    file="$1"
    ngram_size="$2"
    if [ "$file" = "" ]; then
        echo "Usage: $0 file [ngram-size]"
    fi
    #
    in_base=$(basename "$file" .txt)
    out_base="$in_base.${ngram_size}gram.freqs.tfidf"
    NUM_TOP_TERMS=1000 NGRAM_SIZE=$ngram_size compute_tfidf.py --show-frequency "$file" > "$out_base.list"
    freq-sort "$out_base.list" > "$out_base.freq"
}

function check-grammar () {
    file="$1"
    base=$(basename "$file" .txt)
    ## OLD:
    ## local language_tool_home="$LANGUAGE_TOOL_HOME"
    ## if [ "$language_tool_home" = "" ]; then language_tool_home="/c/Program-Misc/OpenOffice/LanguageTool-2.1"; fi
    # TODO: upgrade the version to be much more modern
    local language_tool_home=${LANGUAGE_TOOL_HOME:-"$HOME/programs/misc/OpenOffice/LanguageTool-2.1"}
    LANGUAGE_TOOL_HOME="$language_tool_home" python -m check_grammar "$file" > "$base.grammar.list"
}

function parse-text () {
    file="$1"
    base=$(basename "$file" .txt)
    ## OLD:
    ## local stanford_parser_home="$STANFORD_PARSER_HOME"
    ## if [ "$stanford_parser_home" = "" ]; then stanford_parser_home="/c/Program-Misc/stanford-parser-2013-04-05"; fi
    # TODO: upgrade the version to be much more modern
    local stanford_parser_home=${STANFORD_PARSER_HOME:-"$HOME/programs/java/stanford-parser-2013-04-05"}
    STANFORD_PARSER_HOME="$stanford_parser_home" run-stanford-parser.sh "$file" > "$base.parse" 2> "$base.parse.log"
}

#-------------------------------------------------------------------------------
# File format conversion
#
# TODO:
# - ** add generic abc-to-def function for converting from base.abc to base.def
# - add option for forcing overwrite (rather than making that the default)
#

function json-to-yaml {      # Convert BASE
    local base file
    for file in "$@"; do
        base=$(basename "$file" .json)
        DEBUG_LEVEL=1 VERBOSE=0 python -c 'import json, yaml; from mezcla.main import dummy_app;  print(yaml.dump(json.loads(dummy_app.read_entire_input())));' < "$file" >| "$base.yaml";
    done
}

function yaml-to-json {
    local base file
    for file in "$@"; do
        base=$(basename "$file" .ymal)
        DEBUG_LEVEL=1 VERBOSE=0 python -c 'import json, yaml; from mezcla.main import dummy_app;  print(json.dumps(yaml.safe_load(dummy_app.read_entire_input())));' < "$file" >| "$base.json";
    done
}


#--------------------------------------------------------------------------------
#

# remove-extension(filename): remove extension from filename
# ex: remove-extension fubar.list => fubar
function remove-extension { echo "$1" | perl -pe 'chomp; s/\.[^\.]+$/$1\n/;'; }

#--------------------------------------------------------------------------------
# Source control

# git-blame-plus(filename): show revision info for file
# Notes:
# - provides info suitable for blaming another programmer ;)
# - Uses pager with formatted temp filename (unlike git-blame-alias).
#
# sample line annotations:
# 257087c2 (Tom O'Hara        2022-11-27 18:31:19 -0600 363)         debug.trace(6, f"in process_simple({line!r})")
#
function git-blame-plus { 
    local file="$1"
    local log
    log="$TMP/$base.$(T).blame.list"
    base="$(remove-extension "$file")"
    git blame "$file" > "$log"
    $PAGER "$log"
}
# bluetooth-indicator(): pull up Ubuntu system tray item for bluetooth
alias-fn bluetooth-indicator '/usr/lib/x86_64-linux-gnu/indicator-bluetooth/indicator-bluetooth-service & true'
