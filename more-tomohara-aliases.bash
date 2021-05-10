# more-tomohara-aliases.bash: Additional aliases (& functions) that arern't
# used on a regular basis. This supplements tomohara-aliases.bash.
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
    NUM_TOP_TERMS=1000 NGRAM_SIZE=$ngram_size compute_tfidf.py --show-frequency $file > "$out_base.list"
    freq-sort "$out_base.list" > "$out_base.freq"
}

function check-grammar () {
    file="$1"
    base=$(basename $file .txt)
    local language_tool_home="$LANGUAGE_TOOL_HOME"
    if [ "$language_tool_home" = "" ]; then language_tool_home="/c/Program-Misc/OpenOffice/LanguageTool-2.1"; fi
    LANGUAGE_TOOL_HOME="$language_tool_home" python -m check_grammar "$file" > "$base.grammar.list"
}

function parse-text () {
    file="$1"
    base=$(basename "$file" .txt)
    local stanford_parser_home="$STANFORD_PARSER_HOME"
    if [ "$stanford_parser_home" = "" ]; then stanford_parser_home="/c/Program-Misc/stanford-parser-2013-04-05"; fi
    STANFORD_PARSER_HOME="$stanford_parser_home" run-stanford-parser.sh "$file" > "$base.parse" 2> "$base.parse.log"
}
