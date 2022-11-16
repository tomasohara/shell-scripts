var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":"bats_prefix_lines_for_tap_output() {"},
{"lineNum":"    4","line":"    while IFS= read -r line; do","class":"lineCov","hits":"8","order":"515","possible_hits":"0",},
{"lineNum":"    5","line":"      printf \'# %s\\n\' \"$line\" || break # avoid feedback loop when errors are redirected into BATS_OUT (see #353)","class":"lineCov","hits":"2","order":"516","possible_hits":"0",},
{"lineNum":"    6","line":"    done"},
{"lineNum":"    7","line":"    if [[ -n \"$line\" ]]; then","class":"lineCov","hits":"2","order":"517","possible_hits":"0",},
{"lineNum":"    8","line":"      printf \'# %s\\n\' \"$line\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    9","line":"    fi"},
{"lineNum":"   10","line":"}"},
{"lineNum":"   11","line":""},
{"lineNum":"   12","line":"function bats_replace_filename() {"},
{"lineNum":"   13","line":"  local line","class":"lineCov","hits":"2","order":"518","possible_hits":"0",},
{"lineNum":"   14","line":"  while read -r line; do","class":"lineCov","hits":"4","order":"519","possible_hits":"0",},
{"lineNum":"   15","line":"    printf \"%s\\n\" \"${line//$BATS_TEST_SOURCE/$BATS_TEST_FILENAME}\"","class":"lineCov","hits":"2","order":"520","possible_hits":"0",},
{"lineNum":"   16","line":"  done"},
{"lineNum":"   17","line":"  if [[ -n \"$line\" ]]; then","class":"lineCov","hits":"2","order":"521","possible_hits":"0",},
{"lineNum":"   18","line":"    printf \"%s\\n\" \"${line//$BATS_TEST_SOURCE/$BATS_TEST_FILENAME}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   19","line":"  fi"},
{"lineNum":"   20","line":"}"},
{"lineNum":"   21","line":""},
{"lineNum":"   22","line":"bats_quote_code() { # <var> <code>"},
{"lineNum":"   23","line":"\tprintf -v \"$1\" -- \"%s%s%s\" \"$BATS_BEGIN_CODE_QUOTE\" \"$2\" \"$BATS_END_CODE_QUOTE\"","class":"lineCov","hits":"2","order":"502","possible_hits":"0",},
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
{"lineNum":"   39","line":"  IFS=. read -ra version1_parts <<< \"$1\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   40","line":"  IFS=. read -ra version2_parts <<< \"$2\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   41","line":""},
{"lineNum":"   42","line":"  for i in {0..2}; do","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   43","line":"    if (( version1_parts[i] < version2_parts[i] )); then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   44","line":"      return 0","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   45","line":"    elif (( version1_parts[i] > version2_parts[i] )); then","class":"lineNoCov","hits":"0","possible_hits":"0",},
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
{"lineNum":"   82","line":"  while (( start < end )); do","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   83","line":"    mid=$(( (start + end) / 2 ))","class":"lineNoCov","hits":"0","possible_hits":"0",},
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
{"lineNum":"  100","line":"# store the values in ascending order in result array"},
{"lineNum":"  101","line":"# Intended for short lists!"},
{"lineNum":"  102","line":"bats_sort() { # <result-array-name> <values to sort...>"},
{"lineNum":"  103","line":"  local -r result_name=$1","class":"lineCov","hits":"4","order":"164","possible_hits":"0",},
{"lineNum":"  104","line":"  shift","class":"lineCov","hits":"4","order":"165","possible_hits":"0",},
{"lineNum":"  105","line":""},
{"lineNum":"  106","line":"  if (( $# == 0 )); then","class":"lineCov","hits":"4","order":"166","possible_hits":"0",},
{"lineNum":"  107","line":"    eval \"$result_name=()\"","class":"lineCov","hits":"8","order":"167","possible_hits":"0",},
{"lineNum":"  108","line":"    return 0","class":"lineCov","hits":"4","order":"168","possible_hits":"0",},
{"lineNum":"  109","line":"  fi"},
{"lineNum":"  110","line":""},
{"lineNum":"  111","line":"  local -a sorted_array=()","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  112","line":"  local -i j i=0","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  113","line":"  for (( j=1; j <= $#; ++j )); do","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  114","line":"    for ((i=${#sorted_array[@]}; i >= 0; --i )); do","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  115","line":"      if [[ $i -eq 0 || ${sorted_array[$((i-1))]} < ${!j} ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  116","line":"        sorted_array[$i]=${!j}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  117","line":"        break","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  118","line":"      else"},
{"lineNum":"  119","line":"        sorted_array[$i]=${sorted_array[$((i-1))]}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  120","line":"      fi"},
{"lineNum":"  121","line":"    done"},
{"lineNum":"  122","line":"  done"},
{"lineNum":"  123","line":""},
{"lineNum":"  124","line":"  eval \"$result_name=(\\\"\\${sorted_array[@]}\\\")\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  125","line":"}"},
{"lineNum":"  126","line":""},
{"lineNum":"  127","line":"# check if all search values (must be sorted!) are in the (sorted!) array"},
{"lineNum":"  128","line":"# Intended for short lists/arrays!"},
{"lineNum":"  129","line":"bats_all_in() { # <sorted-array> <sorted search values...>"},
{"lineNum":"  130","line":"  local -r haystack_array=$1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  131","line":"  shift","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  132","line":""},
{"lineNum":"  133","line":"  local -i haystack_length # just to appease shellcheck","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  134","line":"  eval \"local -r haystack_length=\\${#${haystack_array}[@]}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  135","line":""},
{"lineNum":"  136","line":"  local -i haystack_index=0 # initialize only here to continue from last search position","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  137","line":"  local search_value haystack_value # just to appease shellcheck","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  138","line":"  for (( i=1; i <= $#; ++i )); do","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  139","line":"    eval \"local search_value=${!i}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  140","line":"    for ((; haystack_index < haystack_length; ++haystack_index)); do","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  141","line":"      eval \"local haystack_value=\\${${haystack_array}[$haystack_index]}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  142","line":"      if [[ $haystack_value > \"$search_value\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  143","line":"        # we passed the location this value would have been at -> not found"},
{"lineNum":"  144","line":"        return 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  145","line":"      elif [[ $haystack_value == \"$search_value\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  146","line":"        continue 2 # search value found  -> try the next one","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  147","line":"      fi"},
{"lineNum":"  148","line":"    done"},
{"lineNum":"  149","line":"    return 1 # we ran of the end of the haystack without finding the value!","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  150","line":"  done"},
{"lineNum":"  151","line":""},
{"lineNum":"  152","line":"  # did not return from loop above -> all search values were found"},
{"lineNum":"  153","line":"  return 0","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  154","line":"}"},
{"lineNum":"  155","line":""},
{"lineNum":"  156","line":"# check if any search value (must be sorted!) is in the (sorted!) array"},
{"lineNum":"  157","line":"# intended for short lists/arrays"},
{"lineNum":"  158","line":"bats_any_in() { # <sorted-array> <sorted search values>"},
{"lineNum":"  159","line":"  local -r haystack_array=$1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  160","line":"  shift","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  161","line":""},
{"lineNum":"  162","line":"  local -i haystack_length # just to appease shellcheck","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  163","line":"  eval \"local -r haystack_length=\\${#${haystack_array}[@]}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  164","line":""},
{"lineNum":"  165","line":"  local -i haystack_index=0 # initialize only here to continue from last search position","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  166","line":"  local search_value haystack_value # just to appease shellcheck","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  167","line":"  for (( i=1; i <= $#; ++i )); do","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  168","line":"    eval \"local search_value=${!i}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  169","line":"    for ((; haystack_index < haystack_length; ++haystack_index)); do","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  170","line":"      eval \"local haystack_value=\\${${haystack_array}[$haystack_index]}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  171","line":"      if [[ $haystack_value > \"$search_value\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  172","line":"        continue 2 # search value not in array! -> try next","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  173","line":"      elif [[ $haystack_value == \"$search_value\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  174","line":"        return 0 # search value found","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  175","line":"      fi"},
{"lineNum":"  176","line":"    done"},
{"lineNum":"  177","line":"  done"},
{"lineNum":"  178","line":""},
{"lineNum":"  179","line":"  # did not return from loop above -> no search value was found"},
{"lineNum":"  180","line":"  return 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  181","line":"}"},
{"lineNum":"  182","line":""},
{"lineNum":"  183","line":"bats_trim () { # <output-variable> <string>"},
{"lineNum":"  184","line":"  local -r bats_trim_ltrimmed=${2#\"${2%%[![:space:]]*}\"} # cut off leading whitespace","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  185","line":"  # shellcheck disable=SC2034 # used in eval!"},
{"lineNum":"  186","line":"  local -r bats_trim_trimmed=${bats_trim_ltrimmed%\"${bats_trim_ltrimmed##*[![:space:]]}\"} # cut off trailing whitespace","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  187","line":"  eval \"$1=\\$bats_trim_trimmed\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  188","line":"}"},
{"lineNum":"  189","line":""},
{"lineNum":"  190","line":"# a helper function to work around unbound variable errors with ${arr[@]} on Bash 3"},
{"lineNum":"  191","line":"bats_append_arrays_as_args () { # <array...> -- <command ...>"},
{"lineNum":"  192","line":"  local -a trailing_args=()","class":"lineCov","hits":"8","order":"155","possible_hits":"0",},
{"lineNum":"  193","line":"  while (( $# > 0)) && [[ $1 != -- ]]; do","class":"lineCov","hits":"24","order":"156","possible_hits":"0",},
{"lineNum":"  194","line":"    local array=$1","class":"lineCov","hits":"8","order":"157","possible_hits":"0",},
{"lineNum":"  195","line":"    shift","class":"lineCov","hits":"8","order":"158","possible_hits":"0",},
{"lineNum":"  196","line":""},
{"lineNum":"  197","line":"    if eval \"(( \\${#${array}[@]} > 0 ))\"; then","class":"lineCov","hits":"16","order":"159","possible_hits":"0",},
{"lineNum":"  198","line":"      eval \"trailing_args+=(\\\"\\${${array}[@]}\\\")\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  199","line":"    fi"},
{"lineNum":"  200","line":"  done"},
{"lineNum":"  201","line":"  shift # remove -- separator","class":"lineCov","hits":"4","order":"160","possible_hits":"0",},
{"lineNum":"  202","line":""},
{"lineNum":"  203","line":"  if (( $# == 0 )); then","class":"lineCov","hits":"4","order":"161","possible_hits":"0",},
{"lineNum":"  204","line":"    printf \"Error: append_arrays_as_args is missing a command or -- separator\\n\" >&2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  205","line":"    return 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  206","line":"  fi"},
{"lineNum":"  207","line":""},
{"lineNum":"  208","line":"  if (( ${#trailing_args[@]} > 0 )); then","class":"lineCov","hits":"4","order":"162","possible_hits":"0",},
{"lineNum":"  209","line":"    \"$@\" \"${trailing_args[@]}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  210","line":"  else"},
{"lineNum":"  211","line":"    \"$@\"","class":"lineCov","hits":"4","order":"163","possible_hits":"0",},
{"lineNum":"  212","line":"  fi"},
{"lineNum":"  213","line":"}"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "bats", "date" : "2022-10-25 17:18:24", "instrumented" : 106, "covered" : 22,};
var merged_data = [];