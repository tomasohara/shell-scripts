var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":"set -e","class":"lineCov","hits":"2","order":"126","possible_hits":"0",},
{"lineNum":"    3","line":""},
{"lineNum":"    4","line":"bats_encode_test_name() {"},
{"lineNum":"    5","line":"  local name=\"$1\"","class":"lineCov","hits":"67","order":"147","possible_hits":"0",},
{"lineNum":"    6","line":"  local result=\'test_\'","class":"lineCov","hits":"67","order":"148","possible_hits":"0",},
{"lineNum":"    7","line":"  local hex_code","class":"lineCov","hits":"67","order":"149","possible_hits":"0",},
{"lineNum":"    8","line":""},
{"lineNum":"    9","line":"  if [[ ! \"$name\" =~ [^[:alnum:]\\ _-] ]]; then","class":"lineCov","hits":"67","order":"150","possible_hits":"0",},
{"lineNum":"   10","line":"    name=\"${name//_/-5f}\"","class":"lineCov","hits":"67","order":"151","possible_hits":"0",},
{"lineNum":"   11","line":"    name=\"${name//-/-2d}\"","class":"lineCov","hits":"67","order":"152","possible_hits":"0",},
{"lineNum":"   12","line":"    name=\"${name// /_}\"","class":"lineCov","hits":"67","order":"153","possible_hits":"0",},
{"lineNum":"   13","line":"    result+=\"$name\"","class":"lineCov","hits":"67","order":"154","possible_hits":"0",},
{"lineNum":"   14","line":"  else"},
{"lineNum":"   15","line":"    local length=\"${#name}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   16","line":"    local char i","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   17","line":""},
{"lineNum":"   18","line":"    for ((i = 0; i < length; i++)); do","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   19","line":"      char=\"${name:$i:1}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   20","line":"      if [[ \"$char\" == \' \' ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   21","line":"        result+=\'_\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   22","line":"      elif [[ \"$char\" =~ [[:alnum:]] ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   23","line":"        result+=\"$char\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   24","line":"      else"},
{"lineNum":"   25","line":"        printf -v \'hex_code\' -- \'-%02x\' \\\'\"$char\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   26","line":"        result+=\"$hex_code\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   27","line":"      fi"},
{"lineNum":"   28","line":"    done"},
{"lineNum":"   29","line":"  fi"},
{"lineNum":"   30","line":""},
{"lineNum":"   31","line":"  printf -v \"$2\" \'%s\' \"$result\"","class":"lineCov","hits":"67","order":"155","possible_hits":"0",},
{"lineNum":"   32","line":"}"},
{"lineNum":"   33","line":""},
{"lineNum":"   34","line":"BATS_TEST_PATTERN=\"^[[:blank:]]*@test[[:blank:]]+(.*[^[:blank:]])[[:blank:]]+\\{(.*)\\$\"","class":"lineCov","hits":"2","order":"127","possible_hits":"0",},
{"lineNum":"   35","line":"BATS_TEST_PATTERN_COMMENT=\"[[:blank:]]*([^[:blank:]()]+)[[:blank:]]*\\(?\\)?[[:blank:]]+\\{[[:blank:]]+#[[:blank:]]*@test[[:blank:]]*\\$\""},
{"lineNum":"   36","line":"BATS_COMMENT_COMMAND_PATTERN=\"^[[:blank:]]*#[[:blank:]]*bats[[:blank:]]+(.*)$\"","class":"lineCov","hits":"2","order":"128","possible_hits":"0",},
{"lineNum":"   37","line":"BATS_VALID_TAG_PATTERN=\"[-_:[:alnum:]]+\"","class":"lineCov","hits":"2","order":"129","possible_hits":"0",},
{"lineNum":"   38","line":"BATS_VALID_TAGS_PATTERN=\"^ *($BATS_VALID_TAG_PATTERN)?( *, *$BATS_VALID_TAG_PATTERN)* *$\"","class":"lineCov","hits":"2","order":"130","possible_hits":"0",},
{"lineNum":"   39","line":""},
{"lineNum":"   40","line":"# shellcheck source=lib/bats-core/common.bash"},
{"lineNum":"   41","line":"source \"$BATS_ROOT/lib/bats-core/common.bash\"","class":"lineCov","hits":"2","order":"131","possible_hits":"0",},
{"lineNum":"   42","line":""},
{"lineNum":"   43","line":"extract_tags() { # <tag_type/return_var> <tags-string>"},
{"lineNum":"   44","line":"  local -r tag_type=$1 tags_string=$2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   45","line":"  local -a tags=()","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   46","line":""},
{"lineNum":"   47","line":"  if [[ $tags_string =~ $BATS_VALID_TAGS_PATTERN ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   48","line":"    IFS=, read -ra tags <<< \"$tags_string\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   49","line":"    local -ri length=${#tags[@]}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   50","line":"    for (( i = 0; i < length; ++i )); do","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   51","line":"      local element=\"tags[$i]\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   52","line":"      bats_trim \"$element\" \"${!element}\" 2>/dev/null # printf on bash 3 will complain but work anyways","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   53","line":"      if [[ -z \"${!element}\" && -n \"${CHECK_BATS_COMMENT_COMMANDS:-}\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   54","line":"        printf \"%s:%d: Error: Invalid %s: \'%s\'. \" \"$test_file\" \"$line_number\" \"$tag_type\" \"$tags_string\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   55","line":"        printf \"Tags must not be empty. Please remove redundant commas!\\n\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   56","line":"        exit_code=1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   57","line":"      fi"},
{"lineNum":"   58","line":"    done"},
{"lineNum":"   59","line":"  elif [[ -n \"${CHECK_BATS_COMMENT_COMMANDS:-}\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   60","line":"    printf \"%s:%d: Error: Invalid %s: \'%s\'. \" \"$test_file\" \"$line_number\" \"$tag_type\" \"$tags_string\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   61","line":"    printf \"Valid tags must match %s and be separated with comma (and optional spaces)\\n\" \"$BATS_VALID_TAG_PATTERN\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   62","line":"    exit_code=1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   63","line":"  fi >&2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   64","line":"  if (( ${#tags[@]} > 0)); then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   65","line":"    eval \"$tag_type=(\\\"\\${tags[@]}\\\")\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   66","line":"  else"},
{"lineNum":"   67","line":"    eval \"$tag_type=()\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   68","line":"  fi"},
{"lineNum":"   69","line":"}"},
{"lineNum":"   70","line":""},
{"lineNum":"   71","line":"test_file=\"$1\"","class":"lineCov","hits":"2","order":"132","possible_hits":"0",},
{"lineNum":"   72","line":"tests=()"},
{"lineNum":"   73","line":"test_tags=()"},
{"lineNum":"   74","line":"# shellcheck disable=SC2034 # used in `bats_sort tags`/`extract_tags``"},
{"lineNum":"   75","line":"file_tags=()"},
{"lineNum":"   76","line":"line_number=0","class":"lineCov","hits":"2","order":"133","possible_hits":"0",},
{"lineNum":"   77","line":"exit_code=0","class":"lineCov","hits":"2","order":"134","possible_hits":"0",},
{"lineNum":"   78","line":"{"},
{"lineNum":"   79","line":"  while IFS= read -r line; do","class":"lineCov","hits":"2374","order":"135","possible_hits":"0",},
{"lineNum":"   80","line":"    (( ++line_number ))","class":"lineCov","hits":"1185","order":"136","possible_hits":"0",},
{"lineNum":"   81","line":"    line=\"${line//$\'\\r\'/}\"","class":"lineCov","hits":"1185","order":"137","possible_hits":"0",},
{"lineNum":"   82","line":"    if [[ \"$line\" =~ $BATS_TEST_PATTERN ]] || [[ \"$line\" =~ $BATS_TEST_PATTERN_COMMENT ]]; then","class":"lineCov","hits":"2303","order":"138","possible_hits":"0",},
{"lineNum":"   83","line":"      name=\"${BASH_REMATCH[1]#[\\\'\\\"]}\"","class":"lineCov","hits":"67","order":"143","possible_hits":"0",},
{"lineNum":"   84","line":"      name=\"${name%[\\\'\\\"]}\"","class":"lineCov","hits":"67","order":"144","possible_hits":"0",},
{"lineNum":"   85","line":"      body=\"${BASH_REMATCH[2]:-}\"","class":"lineCov","hits":"67","order":"145","possible_hits":"0",},
{"lineNum":"   86","line":"      bats_encode_test_name \"$name\" \'encoded_name\'","class":"lineCov","hits":"67","order":"146","possible_hits":"0",},
{"lineNum":"   87","line":"      printf \'%s() { bats_test_begin \"%s\"; %s\\n\' \"${encoded_name:?}\" \"$name\" \"$body\" || :","class":"lineCov","hits":"67","order":"156","possible_hits":"0",},
{"lineNum":"   88","line":""},
{"lineNum":"   89","line":"      bats_append_arrays_as_args \\","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   90","line":"                          test_tags file_tags \\"},
{"lineNum":"   91","line":"        -- bats_sort tags"},
{"lineNum":"   92","line":"      if [[ -z \"$BATS_TEST_FILTER\" || \"$name\" =~ $BATS_TEST_FILTER ]]; then","class":"lineCov","hits":"67","order":"171","possible_hits":"0",},
{"lineNum":"   93","line":"        IFS=,","class":"lineCov","hits":"67","order":"172","possible_hits":"0",},
{"lineNum":"   94","line":"        tests+=(\"--tags \'${tags[*]-}\' $encoded_name\")","class":"lineCov","hits":"67","order":"173","possible_hits":"0",},
{"lineNum":"   95","line":"      fi"},
{"lineNum":"   96","line":"      # shellcheck disable=SC2034 # used in `bats_sort tags`/`extract_tags`"},
{"lineNum":"   97","line":"      test_tags=() # reset test tags for next test"},
{"lineNum":"   98","line":"    else"},
{"lineNum":"   99","line":"      if [[ \"$line\" =~ $BATS_COMMENT_COMMAND_PATTERN ]]; then","class":"lineCov","hits":"1119","order":"139","possible_hits":"0",},
{"lineNum":"  100","line":"        command=${BASH_REMATCH[1]}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  101","line":"        case $command in","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  102","line":"          \'test_tags=\'*)"},
{"lineNum":"  103","line":"            extract_tags test_tags \"${command#test_tags=}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  104","line":"          ;;"},
{"lineNum":"  105","line":"          \'file_tags=\'*)"},
{"lineNum":"  106","line":"            extract_tags file_tags \"${command#file_tags=}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  107","line":"          ;;"},
{"lineNum":"  108","line":"        esac"},
{"lineNum":"  109","line":"      fi"},
{"lineNum":"  110","line":"      printf \'%s\\n\' \"$line\"","class":"lineCov","hits":"1117","order":"140","possible_hits":"0",},
{"lineNum":"  111","line":"    fi"},
{"lineNum":"  112","line":"  done"},
{"lineNum":"  113","line":"} <<<\"$(<\"$test_file\")\"$\'\\n\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  114","line":""},
{"lineNum":"  115","line":"for test_name in \"${tests[@]}\"; do","class":"lineCov","hits":"70","order":"174","possible_hits":"0",},
{"lineNum":"  116","line":"  printf \'bats_test_function %s\\n\' \"$test_name\"","class":"lineCov","hits":"70","order":"175","possible_hits":"0",},
{"lineNum":"  117","line":"done"},
{"lineNum":"  118","line":""},
{"lineNum":"  119","line":"exit $exit_code","class":"lineCov","hits":"2","order":"176","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "bats", "date" : "2022-10-19 20:15:42", "instrumented" : 71, "covered" : 35,};
var merged_data = [];
