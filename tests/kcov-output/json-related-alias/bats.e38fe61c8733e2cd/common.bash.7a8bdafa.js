var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":"bats_prefix_lines_for_tap_output() {"},
{"lineNum":"    4","line":"  while IFS= read -r line; do","class":"lineCov","hits":"54","order":"569","possible_hits":"0",},
{"lineNum":"    5","line":"    printf \'# %s\\n\' \"$line\" || break # avoid feedback loop when errors are redirected into BATS_OUT (see #353)","class":"lineCov","hits":"19","order":"570","possible_hits":"0",},
{"lineNum":"    6","line":"  done"},
{"lineNum":"    7","line":"  if [[ -n \"$line\" ]]; then","class":"lineCov","hits":"8","order":"571","possible_hits":"0",},
{"lineNum":"    8","line":"    printf \'# %s\\n\' \"$line\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    9","line":"  fi"},
{"lineNum":"   10","line":"}"},
{"lineNum":"   11","line":""},
{"lineNum":"   12","line":"function bats_replace_filename() {"},
{"lineNum":"   13","line":"  local line","class":"lineCov","hits":"8","order":"572","possible_hits":"0",},
{"lineNum":"   14","line":"  while read -r line; do","class":"lineCov","hits":"27","order":"573","possible_hits":"0",},
{"lineNum":"   15","line":"    printf \"%s\\n\" \"${line//$BATS_TEST_SOURCE/$BATS_TEST_FILENAME}\"","class":"lineCov","hits":"19","order":"574","possible_hits":"0",},
{"lineNum":"   16","line":"  done"},
{"lineNum":"   17","line":"  if [[ -n \"$line\" ]]; then","class":"lineCov","hits":"8","order":"575","possible_hits":"0",},
{"lineNum":"   18","line":"    printf \"%s\\n\" \"${line//$BATS_TEST_SOURCE/$BATS_TEST_FILENAME}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   19","line":"  fi"},
{"lineNum":"   20","line":"}"},
{"lineNum":"   21","line":""},
{"lineNum":"   22","line":"bats_quote_code() { # <var> <code>"},
{"lineNum":"   23","line":"  printf -v \"$1\" -- \"%s%s%s\" \"$BATS_BEGIN_CODE_QUOTE\" \"$2\" \"$BATS_END_CODE_QUOTE\"","class":"lineCov","hits":"8","order":"559","possible_hits":"0",},
{"lineNum":"   24","line":"}"},
{"lineNum":"   25","line":""},
{"lineNum":"   26","line":"bats_check_valid_version() {"},
{"lineNum":"   27","line":"  if [[ ! $1 =~ [0-9]+.[0-9]+.[0-9]+ ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   28","line":"    printf \"ERROR: version \'%s\' must be of format <major>.<minor>.<patch>!\\n\" \"$1\" >&2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   29","line":"    exit 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   30","line":"  fi"},
{"lineNum":"   31","line":"}"},
{"lineNum":"   32","line":""},
{"lineNum":"   33","line":"# compares two versions. Return 0 when version1 < version2"},
{"lineNum":"   34","line":"bats_version_lt() { # <version1> <version2>"},
{"lineNum":"   35","line":"  bats_check_valid_version \"$1\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   36","line":"  bats_check_valid_version \"$2\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   37","line":""},
{"lineNum":"   38","line":"  local -a version1_parts version2_parts","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   39","line":"  IFS=. read -ra version1_parts <<<\"$1\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   40","line":"  IFS=. read -ra version2_parts <<<\"$2\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   41","line":""},
{"lineNum":"   42","line":"  for i in {0..2}; do","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   43","line":"    if ((version1_parts[i] < version2_parts[i])); then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   44","line":"      return 0","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   45","line":"    elif ((version1_parts[i] > version2_parts[i])); then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   46","line":"      return 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   47","line":"    fi"},
{"lineNum":"   48","line":"  done"},
{"lineNum":"   49","line":"  # if we made it this far, they are equal -> also not less then"},
{"lineNum":"   50","line":"  return 2 # use other failing return code to distinguish equal from gt","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   51","line":"}"},
{"lineNum":"   52","line":""},
{"lineNum":"   53","line":"# ensure a minimum version of bats is running or exit with failure"},
{"lineNum":"   54","line":"bats_require_minimum_version() { # <required version>"},
{"lineNum":"   55","line":"  local required_minimum_version=$1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   56","line":""},
{"lineNum":"   57","line":"  if bats_version_lt \"$BATS_VERSION\" \"$required_minimum_version\"; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   58","line":"    printf \"BATS_VERSION=%s does not meet required minimum %s\\n\" \"$BATS_VERSION\" \"$required_minimum_version\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   59","line":"    exit 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   60","line":"  fi"},
{"lineNum":"   61","line":""},
{"lineNum":"   62","line":"  if bats_version_lt \"$BATS_GUARANTEED_MINIMUM_VERSION\" \"$required_minimum_version\"; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   63","line":"    BATS_GUARANTEED_MINIMUM_VERSION=\"$required_minimum_version\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   64","line":"  fi"},
{"lineNum":"   65","line":"}"},
{"lineNum":"   66","line":""},
{"lineNum":"   67","line":"bats_binary_search() { # <search-value> <array-name>"},
{"lineNum":"   68","line":"  if [[ $# -ne 2 ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   69","line":"    printf \"ERROR: bats_binary_search requires exactly 2 arguments: <search value> <array name>\\n\" >&2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   70","line":"    return 2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   71","line":"  fi"},
{"lineNum":"   72","line":""},
{"lineNum":"   73","line":"  local -r search_value=$1 array_name=$2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   74","line":""},
{"lineNum":"   75","line":"  # we\'d like to test if array is set but we cannot distinguish unset from empty arrays, so we need to skip that"},
{"lineNum":"   76","line":""},
{"lineNum":"   77","line":"  local start=0 mid end mid_value","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   78","line":"  # start is inclusive, end is exclusive ..."},
{"lineNum":"   79","line":"  eval \"end=\\${#${array_name}[@]}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   80","line":""},
{"lineNum":"   81","line":"  # so start == end means empty search space"},
{"lineNum":"   82","line":"  while ((start < end)); do","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   83","line":"    mid=$(((start + end) / 2))","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   84","line":"    eval \"mid_value=\\${${array_name}[$mid]}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   85","line":"    if [[ \"$mid_value\" == \"$search_value\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   86","line":"      return 0","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   87","line":"    elif [[ \"$mid_value\" < \"$search_value\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   88","line":"      # This branch excludes equality -> +1 to skip the mid element."},
{"lineNum":"   89","line":"      # This +1 also avoids endless recursion on odd sized search ranges."},
{"lineNum":"   90","line":"      start=$((mid + 1))","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   91","line":"    else"},
{"lineNum":"   92","line":"      end=$mid","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   93","line":"    fi"},
{"lineNum":"   94","line":"  done"},
{"lineNum":"   95","line":""},
{"lineNum":"   96","line":"  # did not find it -> its not there"},
{"lineNum":"   97","line":"  return 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   98","line":"}"},
{"lineNum":"   99","line":""},
{"lineNum":"  100","line":"# store the values in ascending (string!) order in result array"},
{"lineNum":"  101","line":"# Intended for short lists! (uses insertion sort)"},
{"lineNum":"  102","line":"bats_sort() { # <result-array-name> <values to sort...>"},
{"lineNum":"  103","line":"  local -r result_name=$1","class":"lineCov","hits":"32","order":"173","possible_hits":"0",},
{"lineNum":"  104","line":"  shift","class":"lineCov","hits":"32","order":"174","possible_hits":"0",},
{"lineNum":"  105","line":""},
{"lineNum":"  106","line":"  if (($# == 0)); then","class":"lineCov","hits":"32","order":"175","possible_hits":"0",},
{"lineNum":"  107","line":"    eval \"$result_name=()\"","class":"lineCov","hits":"64","order":"176","possible_hits":"0",},
{"lineNum":"  108","line":"    return 0","class":"lineCov","hits":"32","order":"177","possible_hits":"0",},
{"lineNum":"  109","line":"  fi"},
{"lineNum":"  110","line":""},
{"lineNum":"  111","line":"  local -a sorted_array=()","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  112","line":"  local -i i","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  113","line":"  while (( $# > 0 )); do # loop over input values","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  114","line":"    local current_value=\"$1\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  115","line":"    shift","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  116","line":"    for ((i = ${#sorted_array[@]}; i >= 0; --i)); do # loop over output array from end","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  117","line":"      if (( i == 0 )) || [[ ${sorted_array[i - 1]} < $current_value ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  118","line":"        # shift bigger elements one position to the end"},
{"lineNum":"  119","line":"        sorted_array[i]=$current_value","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  120","line":"        break","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  121","line":"      else"},
{"lineNum":"  122","line":"        # insert new element at (freed) desired location"},
{"lineNum":"  123","line":"        sorted_array[i]=${sorted_array[i - 1]}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  124","line":"      fi"},
{"lineNum":"  125","line":"    done"},
{"lineNum":"  126","line":"  done"},
{"lineNum":"  127","line":""},
{"lineNum":"  128","line":"  eval \"$result_name=(\\\"\\${sorted_array[@]}\\\")\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  129","line":"}"},
{"lineNum":"  130","line":""},
{"lineNum":"  131","line":"# check if all search values (must be sorted!) are in the (sorted!) array"},
{"lineNum":"  132","line":"# Intended for short lists/arrays!"},
{"lineNum":"  133","line":"bats_all_in() { # <sorted-array> <sorted search values...>"},
{"lineNum":"  134","line":"  local -r haystack_array=$1","class":"lineCov","hits":"16","order":"191","possible_hits":"0",},
{"lineNum":"  135","line":"  shift","class":"lineCov","hits":"16","order":"192","possible_hits":"0",},
{"lineNum":"  136","line":""},
{"lineNum":"  137","line":"  local -i haystack_length # just to appease shellcheck","class":"lineCov","hits":"16","order":"193","possible_hits":"0",},
{"lineNum":"  138","line":"  eval \"local -r haystack_length=\\${#${haystack_array}[@]}\"","class":"lineCov","hits":"32","order":"194","possible_hits":"0",},
{"lineNum":"  139","line":""},
{"lineNum":"  140","line":"  local -i haystack_index=0         # initialize only here to continue from last search position","class":"lineCov","hits":"16","order":"195","possible_hits":"0",},
{"lineNum":"  141","line":"  local search_value haystack_value # just to appease shellcheck","class":"lineCov","hits":"16","order":"196","possible_hits":"0",},
{"lineNum":"  142","line":"  for ((i = 1; i <= $#; ++i)); do","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  143","line":"    eval \"local search_value=${!i}\"","class":"lineCov","hits":"32","order":"198","possible_hits":"0",},
{"lineNum":"  144","line":"    for (( ; haystack_index < haystack_length; ++haystack_index)); do","class":"lineCov","hits":"64","order":"197","possible_hits":"0",},
{"lineNum":"  145","line":"      eval \"local haystack_value=\\${${haystack_array}[$haystack_index]}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  146","line":"      if [[ $haystack_value > \"$search_value\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  147","line":"        # we passed the location this value would have been at -> not found"},
{"lineNum":"  148","line":"        return 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  149","line":"      elif [[ $haystack_value == \"$search_value\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  150","line":"        continue 2 # search value found  -> try the next one","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  151","line":"      fi"},
{"lineNum":"  152","line":"    done"},
{"lineNum":"  153","line":"    return 1 # we ran of the end of the haystack without finding the value!","class":"lineCov","hits":"16","order":"199","possible_hits":"0",},
{"lineNum":"  154","line":"  done"},
{"lineNum":"  155","line":""},
{"lineNum":"  156","line":"  # did not return from loop above -> all search values were found"},
{"lineNum":"  157","line":"  return 0","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  158","line":"}"},
{"lineNum":"  159","line":""},
{"lineNum":"  160","line":"# check if any search value (must be sorted!) is in the (sorted!) array"},
{"lineNum":"  161","line":"# intended for short lists/arrays"},
{"lineNum":"  162","line":"bats_any_in() { # <sorted-array> <sorted search values>"},
{"lineNum":"  163","line":"  local -r haystack_array=$1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  164","line":"  shift","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  165","line":""},
{"lineNum":"  166","line":"  local -i haystack_length # just to appease shellcheck","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  167","line":"  eval \"local -r haystack_length=\\${#${haystack_array}[@]}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  168","line":""},
{"lineNum":"  169","line":"  local -i haystack_index=0         # initialize only here to continue from last search position","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  170","line":"  local search_value haystack_value # just to appease shellcheck","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  171","line":"  for ((i = 1; i <= $#; ++i)); do","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  172","line":"    eval \"local search_value=${!i}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  173","line":"    for (( ; haystack_index < haystack_length; ++haystack_index)); do","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  174","line":"      eval \"local haystack_value=\\${${haystack_array}[$haystack_index]}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  175","line":"      if [[ $haystack_value > \"$search_value\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  176","line":"        continue 2 # search value not in array! -> try next","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  177","line":"      elif [[ $haystack_value == \"$search_value\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  178","line":"        return 0 # search value found","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  179","line":"      fi"},
{"lineNum":"  180","line":"    done"},
{"lineNum":"  181","line":"  done"},
{"lineNum":"  182","line":""},
{"lineNum":"  183","line":"  # did not return from loop above -> no search value was found"},
{"lineNum":"  184","line":"  return 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  185","line":"}"},
{"lineNum":"  186","line":""},
{"lineNum":"  187","line":"bats_trim() {                                            # <output-variable> <string>"},
{"lineNum":"  188","line":"  local -r bats_trim_ltrimmed=${2#\"${2%%[![:space:]]*}\"} # cut off leading whitespace","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  189","line":"  # shellcheck disable=SC2034 # used in eval!"},
{"lineNum":"  190","line":"  local -r bats_trim_trimmed=${bats_trim_ltrimmed%\"${bats_trim_ltrimmed##*[![:space:]]}\"} # cut off trailing whitespace","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  191","line":"  eval \"$1=\\$bats_trim_trimmed\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  192","line":"}"},
{"lineNum":"  193","line":""},
{"lineNum":"  194","line":"# a helper function to work around unbound variable errors with ${arr[@]} on Bash 3"},
{"lineNum":"  195","line":"bats_append_arrays_as_args() { # <array...> -- <command ...>"},
{"lineNum":"  196","line":"  local -a trailing_args=()","class":"lineCov","hits":"64","order":"164","possible_hits":"0",},
{"lineNum":"  197","line":"  while (($# > 0)) && [[ $1 != -- ]]; do","class":"lineCov","hits":"192","order":"165","possible_hits":"0",},
{"lineNum":"  198","line":"    local array=$1","class":"lineCov","hits":"64","order":"166","possible_hits":"0",},
{"lineNum":"  199","line":"    shift","class":"lineCov","hits":"64","order":"167","possible_hits":"0",},
{"lineNum":"  200","line":""},
{"lineNum":"  201","line":"    if eval \"(( \\${#${array}[@]} > 0 ))\"; then","class":"lineCov","hits":"128","order":"168","possible_hits":"0",},
{"lineNum":"  202","line":"      eval \"trailing_args+=(\\\"\\${${array}[@]}\\\")\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  203","line":"    fi"},
{"lineNum":"  204","line":"  done"},
{"lineNum":"  205","line":"  shift # remove -- separator","class":"lineCov","hits":"32","order":"169","possible_hits":"0",},
{"lineNum":"  206","line":""},
{"lineNum":"  207","line":"  if (($# == 0)); then","class":"lineCov","hits":"32","order":"170","possible_hits":"0",},
{"lineNum":"  208","line":"    printf \"Error: append_arrays_as_args is missing a command or -- separator\\n\" >&2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  209","line":"    return 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  210","line":"  fi"},
{"lineNum":"  211","line":""},
{"lineNum":"  212","line":"  if ((${#trailing_args[@]} > 0)); then","class":"lineCov","hits":"32","order":"171","possible_hits":"0",},
{"lineNum":"  213","line":"    \"$@\" \"${trailing_args[@]}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  214","line":"  else"},
{"lineNum":"  215","line":"    \"$@\"","class":"lineCov","hits":"32","order":"172","possible_hits":"0",},
{"lineNum":"  216","line":"  fi"},
{"lineNum":"  217","line":"}"},
{"lineNum":"  218","line":""},
{"lineNum":"  219","line":"bats_format_file_line_reference() { # <output> <file> <line>"},
{"lineNum":"  220","line":"  # shellcheck disable=SC2034 # will be used in subimplementation"},
{"lineNum":"  221","line":"  local output=\"${1?}\"","class":"lineCov","hits":"8","order":"531","possible_hits":"0",},
{"lineNum":"  222","line":"  shift","class":"lineCov","hits":"8","order":"532","possible_hits":"0",},
{"lineNum":"  223","line":"  \"bats_format_file_line_reference_${BATS_LINE_REFERENCE_FORMAT?}\" \"$@\"","class":"lineCov","hits":"8","order":"533","possible_hits":"0",},
{"lineNum":"  224","line":"}"},
{"lineNum":"  225","line":""},
{"lineNum":"  226","line":"bats_format_file_line_reference_comma_line() {"},
{"lineNum":"  227","line":"  printf -v \"$output\" \"%s, line %d\" \"$@\"","class":"lineCov","hits":"8","order":"534","possible_hits":"0",},
{"lineNum":"  228","line":"}"},
{"lineNum":"  229","line":""},
{"lineNum":"  230","line":"bats_format_file_line_reference_colon() {"},
{"lineNum":"  231","line":"  printf -v \"$output\" \"%s:%d\" \"$@\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  232","line":"}"},
{"lineNum":"  233","line":""},
{"lineNum":"  234","line":"# approximate realpath without subshell"},
{"lineNum":"  235","line":"bats_approx_realpath() { # <output-variable> <path>"},
{"lineNum":"  236","line":"  local output=$1 path=$2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  237","line":"  if [[ $path != /* ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  238","line":"    path=\"$PWD/$path\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  239","line":"  fi"},
{"lineNum":"  240","line":"  # x/./y -> x/y"},
{"lineNum":"  241","line":"  path=${path//\\/.\\//\\/}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  242","line":"  printf -v \"$output\" \"%s\" \"$path\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  243","line":"}"},
{"lineNum":"  244","line":""},
{"lineNum":"  245","line":"bats_format_file_line_reference_uri() {"},
{"lineNum":"  246","line":"  local filename=${1?} line=${2?}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  247","line":"  bats_approx_realpath filename \"$filename\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  248","line":"  printf -v \"$output\" \"file://%s:%d\" \"$filename\" \"$line\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  249","line":"}"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "bats", "date" : "2023-04-06 21:10:54", "instrumented" : 121, "covered" : 35,};
var merged_data = [];
