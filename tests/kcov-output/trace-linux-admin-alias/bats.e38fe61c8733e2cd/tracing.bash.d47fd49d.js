var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":"# shellcheck source=lib/bats-core/common.bash"},
{"lineNum":"    4","line":"source \"$BATS_ROOT/lib/bats-core/common.bash\"","class":"lineCov","hits":"43","order":"227","possible_hits":"0",},
{"lineNum":"    5","line":""},
{"lineNum":"    6","line":"bats_capture_stack_trace() {"},
{"lineNum":"    7","line":"  local test_file","class":"lineCov","hits":"264","order":"337","possible_hits":"0",},
{"lineNum":"    8","line":"  local funcname","class":"lineCov","hits":"264","order":"338","possible_hits":"0",},
{"lineNum":"    9","line":"  local i","class":"lineCov","hits":"264","order":"339","possible_hits":"0",},
{"lineNum":"   10","line":""},
{"lineNum":"   11","line":"  BATS_DEBUG_LAST_STACK_TRACE=()"},
{"lineNum":"   12","line":""},
{"lineNum":"   13","line":"  for ((i = 2; i != ${#FUNCNAME[@]}; ++i)); do","class":"lineCov","hits":"570","order":"340","possible_hits":"0",},
{"lineNum":"   14","line":"    # Use BATS_TEST_SOURCE if necessary to work around Bash < 4.4 bug whereby"},
{"lineNum":"   15","line":"    # calling an exported function erases the test file\'s BASH_SOURCE entry."},
{"lineNum":"   16","line":"    test_file=\"${BASH_SOURCE[$i]:-$BATS_TEST_SOURCE}\"","class":"lineCov","hits":"285","order":"341","possible_hits":"0",},
{"lineNum":"   17","line":"    funcname=\"${FUNCNAME[$i]}\"","class":"lineCov","hits":"285","order":"342","possible_hits":"0",},
{"lineNum":"   18","line":"    BATS_DEBUG_LAST_STACK_TRACE+=(\"${BASH_LINENO[$((i - 1))]} $funcname $test_file\")","class":"lineCov","hits":"285","order":"343","possible_hits":"0",},
{"lineNum":"   19","line":"    case \"$funcname\" in","class":"lineCov","hits":"285","order":"344","possible_hits":"0",},
{"lineNum":"   20","line":"    \"${BATS_TEST_NAME-}\" | setup | teardown | setup_file | teardown_file | setup_suite | teardown_suite)"},
{"lineNum":"   21","line":"      break","class":"lineCov","hits":"242","order":"444","possible_hits":"0",},
{"lineNum":"   22","line":"      ;;"},
{"lineNum":"   23","line":"    esac"},
{"lineNum":"   24","line":"    if [[ \"${BASH_SOURCE[$i + 1]:-}\" == *\"bats-exec-file\" ]] && [[ \"$funcname\" == \'source\' ]]; then","class":"lineCov","hits":"65","order":"345","possible_hits":"0",},
{"lineNum":"   25","line":"      break","class":"lineCov","hits":"22","order":"346","possible_hits":"0",},
{"lineNum":"   26","line":"    fi"},
{"lineNum":"   27","line":"  done"},
{"lineNum":"   28","line":"}"},
{"lineNum":"   29","line":""},
{"lineNum":"   30","line":"bats_get_failure_stack_trace() {"},
{"lineNum":"   31","line":"  local stack_trace_var","class":"lineCov","hits":"11","order":"502","possible_hits":"0",},
{"lineNum":"   32","line":"  # See bats_debug_trap for details."},
{"lineNum":"   33","line":"  if [[ -n \"${BATS_DEBUG_LAST_STACK_TRACE_IS_VALID:-}\" ]]; then","class":"lineCov","hits":"11","order":"503","possible_hits":"0",},
{"lineNum":"   34","line":"    stack_trace_var=BATS_DEBUG_LAST_STACK_TRACE","class":"lineCov","hits":"10","order":"504","possible_hits":"0",},
{"lineNum":"   35","line":"  else"},
{"lineNum":"   36","line":"    stack_trace_var=BATS_DEBUG_LASTLAST_STACK_TRACE","class":"lineCov","hits":"1","order":"618","possible_hits":"0",},
{"lineNum":"   37","line":"  fi"},
{"lineNum":"   38","line":"  # shellcheck disable=SC2016"},
{"lineNum":"   39","line":"  eval \"$(printf \\","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   40","line":"    \'%s=(${%s[@]+\"${%s[@]}\"})\' \\"},
{"lineNum":"   41","line":"    \"${1}\" \\"},
{"lineNum":"   42","line":"    \"${stack_trace_var}\" \\"},
{"lineNum":"   43","line":"    \"${stack_trace_var}\")\""},
{"lineNum":"   44","line":"}"},
{"lineNum":"   45","line":""},
{"lineNum":"   46","line":"bats_print_stack_trace() {"},
{"lineNum":"   47","line":"  local frame","class":"lineCov","hits":"11","order":"506","possible_hits":"0",},
{"lineNum":"   48","line":"  local index=1","class":"lineCov","hits":"11","order":"507","possible_hits":"0",},
{"lineNum":"   49","line":"  local count=\"${#@}\"","class":"lineCov","hits":"11","order":"508","possible_hits":"0",},
{"lineNum":"   50","line":"  local filename","class":"lineCov","hits":"11","order":"509","possible_hits":"0",},
{"lineNum":"   51","line":"  local lineno","class":"lineCov","hits":"11","order":"510","possible_hits":"0",},
{"lineNum":"   52","line":""},
{"lineNum":"   53","line":"  for frame in \"$@\"; do","class":"lineCov","hits":"11","order":"511","possible_hits":"0",},
{"lineNum":"   54","line":"    bats_frame_filename \"$frame\" \'filename\'","class":"lineCov","hits":"11","order":"512","possible_hits":"0",},
{"lineNum":"   55","line":"    bats_trim_filename \"$filename\" \'filename\'","class":"lineCov","hits":"11","order":"518","possible_hits":"0",},
{"lineNum":"   56","line":"    bats_frame_lineno \"$frame\" \'lineno\'","class":"lineCov","hits":"11","order":"520","possible_hits":"0",},
{"lineNum":"   57","line":""},
{"lineNum":"   58","line":"    printf \'%s\' \"${BATS_STACK_TRACE_PREFIX-# }\"","class":"lineCov","hits":"11","order":"522","possible_hits":"0",},
{"lineNum":"   59","line":"    if [[ $index -eq 1 ]]; then","class":"lineCov","hits":"11","order":"523","possible_hits":"0",},
{"lineNum":"   60","line":"      printf \'(\'","class":"lineCov","hits":"11","order":"524","possible_hits":"0",},
{"lineNum":"   61","line":"    else"},
{"lineNum":"   62","line":"      printf \' \'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   63","line":"    fi"},
{"lineNum":"   64","line":""},
{"lineNum":"   65","line":"    local fn","class":"lineCov","hits":"11","order":"525","possible_hits":"0",},
{"lineNum":"   66","line":"    bats_frame_function \"$frame\" \'fn\'","class":"lineCov","hits":"11","order":"526","possible_hits":"0",},
{"lineNum":"   67","line":"    if [[ \"$fn\" != \"${BATS_TEST_NAME-}\" ]] &&","class":"lineCov","hits":"11","order":"529","possible_hits":"0",},
{"lineNum":"   68","line":"      # don\'t print \"from function `source\'\"\","},
{"lineNum":"   69","line":"      # when failing in free code during `source $test_file` from bats-exec-file"},
{"lineNum":"   70","line":"      ! [[ \"$fn\" == \'source\' && $index -eq $count ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   71","line":"      local quoted_fn","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   72","line":"      bats_quote_code quoted_fn \"$fn\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   73","line":"      printf \"from function %s \" \"$quoted_fn\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   74","line":"    fi"},
{"lineNum":"   75","line":""},
{"lineNum":"   76","line":"    local reference","class":"lineCov","hits":"11","order":"530","possible_hits":"0",},
{"lineNum":"   77","line":"    bats_format_file_line_reference reference \"$filename\" \"$lineno\"","class":"lineCov","hits":"11","order":"531","possible_hits":"0",},
{"lineNum":"   78","line":"    if [[ $index -eq $count ]]; then","class":"lineCov","hits":"11","order":"536","possible_hits":"0",},
{"lineNum":"   79","line":"      printf \'in test file %s)\\n\' \"$reference\"","class":"lineCov","hits":"11","order":"537","possible_hits":"0",},
{"lineNum":"   80","line":"    else"},
{"lineNum":"   81","line":"      printf \'in file %s,\\n\' \"$reference\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   82","line":"    fi"},
{"lineNum":"   83","line":""},
{"lineNum":"   84","line":"    ((++index))"},
{"lineNum":"   85","line":"  done"},
{"lineNum":"   86","line":"}"},
{"lineNum":"   87","line":""},
{"lineNum":"   88","line":"bats_print_failed_command() {"},
{"lineNum":"   89","line":"  local stack_trace=(\"${@}\")","class":"lineCov","hits":"22","order":"539","possible_hits":"0",},
{"lineNum":"   90","line":"  if [[ ${#stack_trace[@]} -eq 0 ]]; then","class":"lineCov","hits":"11","order":"540","possible_hits":"0",},
{"lineNum":"   91","line":"    return 0","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   92","line":"  fi"},
{"lineNum":"   93","line":"  local frame=\"${stack_trace[${#stack_trace[@]} - 1]}\"","class":"lineCov","hits":"11","order":"541","possible_hits":"0",},
{"lineNum":"   94","line":"  local filename","class":"lineCov","hits":"11","order":"542","possible_hits":"0",},
{"lineNum":"   95","line":"  local lineno","class":"lineCov","hits":"11","order":"543","possible_hits":"0",},
{"lineNum":"   96","line":"  local failed_line","class":"lineCov","hits":"11","order":"544","possible_hits":"0",},
{"lineNum":"   97","line":"  local failed_command","class":"lineCov","hits":"11","order":"545","possible_hits":"0",},
{"lineNum":"   98","line":""},
{"lineNum":"   99","line":"  bats_frame_filename \"$frame\" \'filename\'","class":"lineCov","hits":"11","order":"546","possible_hits":"0",},
{"lineNum":"  100","line":"  bats_frame_lineno \"$frame\" \'lineno\'","class":"lineCov","hits":"11","order":"547","possible_hits":"0",},
{"lineNum":"  101","line":"  bats_extract_line \"$filename\" \"$lineno\" \'failed_line\'","class":"lineCov","hits":"11","order":"548","possible_hits":"0",},
{"lineNum":"  102","line":"  bats_strip_string \"$failed_line\" \'failed_command\'","class":"lineCov","hits":"11","order":"555","possible_hits":"0",},
{"lineNum":"  103","line":"  local quoted_failed_command","class":"lineCov","hits":"11","order":"558","possible_hits":"0",},
{"lineNum":"  104","line":"  bats_quote_code quoted_failed_command \"$failed_command\"","class":"lineCov","hits":"11","order":"559","possible_hits":"0",},
{"lineNum":"  105","line":"  printf \'#   %s \' \"${quoted_failed_command}\"","class":"lineCov","hits":"11","order":"561","possible_hits":"0",},
{"lineNum":"  106","line":""},
{"lineNum":"  107","line":"  if [[ \"${BATS_TIMED_OUT-NOTSET}\" != NOTSET ]]; then","class":"lineCov","hits":"11","order":"562","possible_hits":"0",},
{"lineNum":"  108","line":"    # the other values can be safely overwritten here,"},
{"lineNum":"  109","line":"    # as the timeout is the primary reason for failure"},
{"lineNum":"  110","line":"    BATS_ERROR_SUFFIX=\" due to timeout\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  111","line":"  fi"},
{"lineNum":"  112","line":""},
{"lineNum":"  113","line":"  if [[ \"$BATS_ERROR_STATUS\" -eq 1 ]]; then","class":"lineCov","hits":"11","order":"563","possible_hits":"0",},
{"lineNum":"  114","line":"    printf \'failed%s\\n\' \"$BATS_ERROR_SUFFIX\"","class":"lineCov","hits":"5","order":"598","possible_hits":"0",},
{"lineNum":"  115","line":"  else"},
{"lineNum":"  116","line":"    printf \'failed with status %d%s\\n\' \"$BATS_ERROR_STATUS\" \"$BATS_ERROR_SUFFIX\"","class":"lineCov","hits":"6","order":"564","possible_hits":"0",},
{"lineNum":"  117","line":"  fi"},
{"lineNum":"  118","line":"}"},
{"lineNum":"  119","line":""},
{"lineNum":"  120","line":"bats_frame_lineno() {"},
{"lineNum":"  121","line":"  printf -v \"$2\" \'%s\' \"${1%% *}\"","class":"lineCov","hits":"22","order":"521","possible_hits":"0",},
{"lineNum":"  122","line":"}"},
{"lineNum":"  123","line":""},
{"lineNum":"  124","line":"bats_frame_function() {"},
{"lineNum":"  125","line":"  local __bff_function=\"${1#* }\"","class":"lineCov","hits":"11","order":"527","possible_hits":"0",},
{"lineNum":"  126","line":"  printf -v \"$2\" \'%s\' \"${__bff_function%% *}\"","class":"lineCov","hits":"11","order":"528","possible_hits":"0",},
{"lineNum":"  127","line":"}"},
{"lineNum":"  128","line":""},
{"lineNum":"  129","line":"bats_frame_filename() {"},
{"lineNum":"  130","line":"  local __bff_filename=\"${1#* }\"","class":"lineCov","hits":"22","order":"513","possible_hits":"0",},
{"lineNum":"  131","line":"  __bff_filename=\"${__bff_filename#* }\"","class":"lineCov","hits":"22","order":"514","possible_hits":"0",},
{"lineNum":"  132","line":""},
{"lineNum":"  133","line":"  if [[ \"$__bff_filename\" == \"${BATS_TEST_SOURCE-}\" ]]; then","class":"lineCov","hits":"22","order":"515","possible_hits":"0",},
{"lineNum":"  134","line":"    __bff_filename=\"$BATS_TEST_FILENAME\"","class":"lineCov","hits":"22","order":"516","possible_hits":"0",},
{"lineNum":"  135","line":"  fi"},
{"lineNum":"  136","line":"  printf -v \"$2\" \'%s\' \"$__bff_filename\"","class":"lineCov","hits":"22","order":"517","possible_hits":"0",},
{"lineNum":"  137","line":"}"},
{"lineNum":"  138","line":""},
{"lineNum":"  139","line":"bats_extract_line() {"},
{"lineNum":"  140","line":"  local __bats_extract_line_line","class":"lineCov","hits":"11","order":"549","possible_hits":"0",},
{"lineNum":"  141","line":"  local __bats_extract_line_index=0","class":"lineCov","hits":"11","order":"550","possible_hits":"0",},
{"lineNum":"  142","line":""},
{"lineNum":"  143","line":"  while IFS= read -r __bats_extract_line_line; do","class":"lineCov","hits":"3148","order":"551","possible_hits":"0",},
{"lineNum":"  144","line":"    if [[ \"$((++__bats_extract_line_index))\" -eq \"$2\" ]]; then","class":"lineCov","hits":"1574","order":"552","possible_hits":"0",},
{"lineNum":"  145","line":"      printf -v \"$3\" \'%s\' \"${__bats_extract_line_line%$\'\\r\'}\"","class":"lineCov","hits":"11","order":"553","possible_hits":"0",},
{"lineNum":"  146","line":"      break","class":"lineCov","hits":"11","order":"554","possible_hits":"0",},
{"lineNum":"  147","line":"    fi"},
{"lineNum":"  148","line":"  done <\"$1\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  149","line":"}"},
{"lineNum":"  150","line":""},
{"lineNum":"  151","line":"bats_strip_string() {"},
{"lineNum":"  152","line":"  [[ \"$1\" =~ ^[[:space:]]*(.*)[[:space:]]*$ ]]","class":"lineCov","hits":"11","order":"556","possible_hits":"0",},
{"lineNum":"  153","line":"  printf -v \"$2\" \'%s\' \"${BASH_REMATCH[1]}\"","class":"lineCov","hits":"11","order":"557","possible_hits":"0",},
{"lineNum":"  154","line":"}"},
{"lineNum":"  155","line":""},
{"lineNum":"  156","line":"bats_trim_filename() {"},
{"lineNum":"  157","line":"  printf -v \"$2\" \'%s\' \"${1#\"$BATS_CWD\"/}\"","class":"lineCov","hits":"11","order":"519","possible_hits":"0",},
{"lineNum":"  158","line":"}"},
{"lineNum":"  159","line":""},
{"lineNum":"  160","line":"# normalize a windows path from e.g. C:/directory to /c/directory"},
{"lineNum":"  161","line":"# The path must point to an existing/accessable directory, not a file!"},
{"lineNum":"  162","line":"bats_normalize_windows_dir_path() { # <output-var> <path>"},
{"lineNum":"  163","line":"  local output_var=\"$1\" path=\"$2\"","class":"lineCov","hits":"1678","order":"247","possible_hits":"0",},
{"lineNum":"  164","line":"  if [[ \"$output_var\" != NORMALIZED_INPUT ]]; then","class":"lineCov","hits":"1678","order":"248","possible_hits":"0",},
{"lineNum":"  165","line":"    local NORMALIZED_INPUT","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  166","line":"  fi"},
{"lineNum":"  167","line":"  if [[ $path == ?:* ]]; then","class":"lineCov","hits":"1678","order":"249","possible_hits":"0",},
{"lineNum":"  168","line":"    NORMALIZED_INPUT=\"$("},
{"lineNum":"  169","line":"      cd \"$path\" || exit 1"},
{"lineNum":"  170","line":"      pwd"},
{"lineNum":"  171","line":"    )\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  172","line":"  else"},
{"lineNum":"  173","line":"    NORMALIZED_INPUT=\"$path\"","class":"lineCov","hits":"1678","order":"250","possible_hits":"0",},
{"lineNum":"  174","line":"  fi"},
{"lineNum":"  175","line":"  printf -v \"$output_var\" \"%s\" \"$NORMALIZED_INPUT\"","class":"lineCov","hits":"1678","order":"251","possible_hits":"0",},
{"lineNum":"  176","line":"}"},
{"lineNum":"  177","line":""},
{"lineNum":"  178","line":"bats_emit_trace() {"},
{"lineNum":"  179","line":"  if [[ $BATS_TRACE_LEVEL -gt 0 ]]; then","class":"lineCov","hits":"264","order":"348","possible_hits":"0",},
{"lineNum":"  180","line":"    local line=${BASH_LINENO[1]}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  181","line":"    # shellcheck disable=SC2016"},
{"lineNum":"  182","line":"    if [[ $BASH_COMMAND != \'\"$BATS_TEST_NAME\" >> \"$BATS_OUT\" 2>&1 4>&1\' && $BASH_COMMAND != \"bats_test_begin \"* ]] && # don\'t emit these internal calls","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  183","line":"      [[ $BASH_COMMAND != \"$BATS_LAST_BASH_COMMAND\" || $line != \"$BATS_LAST_BASH_LINENO\" ]] &&","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  184","line":"      # avoid printing a function twice (at call site and at definition site)"},
{"lineNum":"  185","line":"      [[ $BASH_COMMAND != \"$BATS_LAST_BASH_COMMAND\" || ${BASH_LINENO[2]} != \"$BATS_LAST_BASH_LINENO\" || ${BASH_SOURCE[3]} != \"$BATS_LAST_BASH_SOURCE\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  186","line":"      local file=\"${BASH_SOURCE[2]}\" # index 2: skip over bats_emit_trace and bats_debug_trap","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  187","line":"      if [[ $file == \"${BATS_TEST_SOURCE}\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  188","line":"        file=\"$BATS_TEST_FILENAME\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  189","line":"      fi"},
{"lineNum":"  190","line":"      local padding=\'$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  191","line":"      if ((BATS_LAST_STACK_DEPTH != ${#BASH_LINENO[@]})); then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  192","line":"        local reference","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  193","line":"        bats_format_file_line_reference reference \"${file##*/}\" \"$line\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  194","line":"        printf \'%s [%s]\\n\' \"${padding::${#BASH_LINENO[@]}-4}\" \"$reference\" >&4","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  195","line":"      fi"},
{"lineNum":"  196","line":"      printf \'%s %s\\n\' \"${padding::${#BASH_LINENO[@]}-4}\" \"$BASH_COMMAND\" >&4","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  197","line":"      BATS_LAST_BASH_COMMAND=\"$BASH_COMMAND\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  198","line":"      BATS_LAST_BASH_LINENO=\"$line\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  199","line":"      BATS_LAST_BASH_SOURCE=\"${BASH_SOURCE[2]}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  200","line":"      BATS_LAST_STACK_DEPTH=\"${#BASH_LINENO[@]}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  201","line":"    fi"},
{"lineNum":"  202","line":"  fi"},
{"lineNum":"  203","line":"}"},
{"lineNum":"  204","line":""},
{"lineNum":"  205","line":"# bats_debug_trap tracks the last line of code executed within a test. This is"},
{"lineNum":"  206","line":"# necessary because $BASH_LINENO is often incorrect inside of ERR and EXIT"},
{"lineNum":"  207","line":"# trap handlers."},
{"lineNum":"  208","line":"#"},
{"lineNum":"  209","line":"# Below are tables describing different command failure scenarios and the"},
{"lineNum":"  210","line":"# reliability of $BASH_LINENO within different the executed DEBUG, ERR, and EXIT"},
{"lineNum":"  211","line":"# trap handlers. Naturally, the behaviors change between versions of Bash."},
{"lineNum":"  212","line":"#"},
{"lineNum":"  213","line":"# Table rows should be read left to right. For example, on bash version"},
{"lineNum":"  214","line":"# 4.0.44(2)-release, if a test executes `false` (or any other failing external"},
{"lineNum":"  215","line":"# command), bash will do the following in order:"},
{"lineNum":"  216","line":"# 1. Call the DEBUG trap handler (bats_debug_trap) with $BASH_LINENO referring"},
{"lineNum":"  217","line":"#    to the source line containing the `false` command, then"},
{"lineNum":"  218","line":"# 2. Call the DEBUG trap handler again, but with an incorrect $BASH_LINENO, then"},
{"lineNum":"  219","line":"# 3. Call the ERR trap handler, but with a (possibly-different) incorrect"},
{"lineNum":"  220","line":"#    $BASH_LINENO, then"},
{"lineNum":"  221","line":"# 4. Call the DEBUG trap handler again, but with $BASH_LINENO set to 1, then"},
{"lineNum":"  222","line":"# 5. Call the EXIT trap handler, with $BASH_LINENO set to 1."},
{"lineNum":"  223","line":"#"},
{"lineNum":"  224","line":"# bash version 4.4.20(1)-release"},
{"lineNum":"  225","line":"#  command     | first DEBUG | second DEBUG | ERR     | third DEBUG | EXIT"},
{"lineNum":"  226","line":"# -------------+-------------+--------------+---------+-------------+--------"},
{"lineNum":"  227","line":"#  false       | OK          | OK           | OK      | BAD[1]      | BAD[1]"},
{"lineNum":"  228","line":"#  [[ 1 = 2 ]] | OK          | BAD[2]       | BAD[2]  | BAD[1]      | BAD[1]"},
{"lineNum":"  229","line":"#  (( 1 = 2 )) | OK          | BAD[2]       | BAD[2]  | BAD[1]      | BAD[1]"},
{"lineNum":"  230","line":"#  ! true      | OK          | ---          | BAD[4]  | ---         | BAD[1]"},
{"lineNum":"  231","line":"#  $var_dne    | OK          | ---          | ---     | BAD[1]      | BAD[1]"},
{"lineNum":"  232","line":"#  source /dne | OK          | ---          | ---     | BAD[1]      | BAD[1]"},
{"lineNum":"  233","line":"#"},
{"lineNum":"  234","line":"# bash version 4.0.44(2)-release"},
{"lineNum":"  235","line":"#  command     | first DEBUG | second DEBUG | ERR     | third DEBUG | EXIT"},
{"lineNum":"  236","line":"# -------------+-------------+--------------+---------+-------------+--------"},
{"lineNum":"  237","line":"#  false       | OK          | BAD[3]       | BAD[3]  | BAD[1]      | BAD[1]"},
{"lineNum":"  238","line":"#  [[ 1 = 2 ]] | OK          | ---          | BAD[3]  | ---         | BAD[1]"},
{"lineNum":"  239","line":"#  (( 1 = 2 )) | OK          | ---          | BAD[3]  | ---         | BAD[1]"},
{"lineNum":"  240","line":"#  ! true      | OK          | ---          | BAD[3]  | ---         | BAD[1]"},
{"lineNum":"  241","line":"#  $var_dne    | OK          | ---          | ---     | BAD[1]      | BAD[1]"},
{"lineNum":"  242","line":"#  source /dne | OK          | ---          | ---     | BAD[1]      | BAD[1]"},
{"lineNum":"  243","line":"#"},
{"lineNum":"  244","line":"# [1] The reported line number is always 1."},
{"lineNum":"  245","line":"# [2] The reported source location is that of the beginning of the function"},
{"lineNum":"  246","line":"#     calling the command."},
{"lineNum":"  247","line":"# [3] The reported line is that of the last command executed in the DEBUG trap"},
{"lineNum":"  248","line":"#     handler."},
{"lineNum":"  249","line":"# [4] The reported source location is that of the call to the function calling"},
{"lineNum":"  250","line":"#     the command."},
{"lineNum":"  251","line":"bats_debug_trap() {"},
{"lineNum":"  252","line":"  # on windows we sometimes get a mix of paths (when install via nmp install -g)"},
{"lineNum":"  253","line":"  # which have C:/... or /c/... comparing them is going to be problematic."},
{"lineNum":"  254","line":"  # We need to normalize them to a common format!"},
{"lineNum":"  255","line":"  local NORMALIZED_INPUT","class":"lineCov","hits":"1678","order":"245","possible_hits":"0",},
{"lineNum":"  256","line":"  bats_normalize_windows_dir_path NORMALIZED_INPUT \"${1%/*}\"","class":"lineCov","hits":"1678","order":"246","possible_hits":"0",},
{"lineNum":"  257","line":"  local file_excluded=\'\' path","class":"lineCov","hits":"1678","order":"252","possible_hits":"0",},
{"lineNum":"  258","line":"  for path in \"${BATS_DEBUG_EXCLUDE_PATHS[@]}\"; do","class":"lineCov","hits":"3172","order":"253","possible_hits":"0",},
{"lineNum":"  259","line":"    if [[ \"$NORMALIZED_INPUT\" == \"$path\"* ]]; then","class":"lineCov","hits":"3172","order":"254","possible_hits":"0",},
{"lineNum":"  260","line":"      file_excluded=1","class":"lineCov","hits":"1413","order":"255","possible_hits":"0",},
{"lineNum":"  261","line":"      break","class":"lineCov","hits":"1413","order":"256","possible_hits":"0",},
{"lineNum":"  262","line":"    fi"},
{"lineNum":"  263","line":"  done"},
{"lineNum":"  264","line":""},
{"lineNum":"  265","line":"  # don\'t update the trace within library functions or we get backtraces from inside traps"},
{"lineNum":"  266","line":"  # also don\'t record new stack traces while handling interruptions, to avoid overriding the interrupted command"},
{"lineNum":"  267","line":"  if [[ -z \"$file_excluded\" &&","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  268","line":"    \"${BATS_INTERRUPTED-NOTSET}\" == NOTSET &&","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  269","line":"    \"${BATS_TIMED_OUT-NOTSET}\" == NOTSET ]]; then","class":"lineCov","hits":"2208","order":"257","possible_hits":"0",},
{"lineNum":"  270","line":"    BATS_DEBUG_LASTLAST_STACK_TRACE=(","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  271","line":"      ${BATS_DEBUG_LAST_STACK_TRACE[@]+\"${BATS_DEBUG_LAST_STACK_TRACE[@]}\"}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  272","line":"    )"},
{"lineNum":"  273","line":""},
{"lineNum":"  274","line":"    BATS_DEBUG_LAST_LINENO=(${BASH_LINENO[@]+\"${BASH_LINENO[@]}\"})","class":"lineCov","hits":"265","order":"334","possible_hits":"0",},
{"lineNum":"  275","line":"    BATS_DEBUG_LAST_SOURCE=(${BASH_SOURCE[@]+\"${BASH_SOURCE[@]}\"})","class":"lineCov","hits":"265","order":"335","possible_hits":"0",},
{"lineNum":"  276","line":"    bats_capture_stack_trace","class":"lineCov","hits":"266","order":"336","possible_hits":"0",},
{"lineNum":"  277","line":"    bats_emit_trace","class":"lineCov","hits":"264","order":"347","possible_hits":"0",},
{"lineNum":"  278","line":"  fi"},
{"lineNum":"  279","line":"}"},
{"lineNum":"  280","line":""},
{"lineNum":"  281","line":"# For some versions of Bash, the `ERR` trap may not always fire for every"},
{"lineNum":"  282","line":"# command failure, but the `EXIT` trap will. Also, some command failures may not"},
{"lineNum":"  283","line":"# set `$?` properly. See #72 and #81 for details."},
{"lineNum":"  284","line":"#"},
{"lineNum":"  285","line":"# For this reason, we call `bats_check_status_from_trap` at the very beginning"},
{"lineNum":"  286","line":"# of `bats_teardown_trap` and check the value of `$BATS_TEST_COMPLETED` before"},
{"lineNum":"  287","line":"# taking other actions. We also adjust the exit status value if needed."},
{"lineNum":"  288","line":"#"},
{"lineNum":"  289","line":"# See `bats_exit_trap` for an additional EXIT error handling case when `$?`"},
{"lineNum":"  290","line":"# isn\'t set properly during `teardown()` errors."},
{"lineNum":"  291","line":"bats_check_status_from_trap() {"},
{"lineNum":"  292","line":"  local status=\"$?\"","class":"lineCov","hits":"58","order":"451","possible_hits":"0",},
{"lineNum":"  293","line":"  if [[ -z \"${BATS_TEST_COMPLETED:-}\" ]]; then","class":"lineCov","hits":"58","order":"452","possible_hits":"0",},
{"lineNum":"  294","line":"    BATS_ERROR_STATUS=\"${BATS_ERROR_STATUS:-$status}\"","class":"lineCov","hits":"40","order":"491","possible_hits":"0",},
{"lineNum":"  295","line":"    if [[ \"$BATS_ERROR_STATUS\" -eq 0 ]]; then","class":"lineCov","hits":"40","order":"492","possible_hits":"0",},
{"lineNum":"  296","line":"      BATS_ERROR_STATUS=1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  297","line":"    fi"},
{"lineNum":"  298","line":"    trap - DEBUG","class":"lineCov","hits":"40","order":"493","possible_hits":"0",},
{"lineNum":"  299","line":"  fi"},
{"lineNum":"  300","line":"}"},
{"lineNum":"  301","line":""},
{"lineNum":"  302","line":"bats_add_debug_exclude_path() { # <path>"},
{"lineNum":"  303","line":"  if [[ -z \"$1\" ]]; then        # don\'t exclude everything","class":"lineCov","hits":"66","order":"232","possible_hits":"0",},
{"lineNum":"  304","line":"    printf \"bats_add_debug_exclude_path: Exclude path must not be empty!\\n\" >&2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  305","line":"    return 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  306","line":"  fi"},
{"lineNum":"  307","line":"  if [[ \"$OSTYPE\" == cygwin || \"$OSTYPE\" == msys ]]; then","class":"lineCov","hits":"132","order":"233","possible_hits":"0",},
{"lineNum":"  308","line":"    local normalized_dir","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  309","line":"    bats_normalize_windows_dir_path normalized_dir \"$1\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  310","line":"    BATS_DEBUG_EXCLUDE_PATHS+=(\"$normalized_dir\")","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  311","line":"  else"},
{"lineNum":"  312","line":"    BATS_DEBUG_EXCLUDE_PATHS+=(\"$1\")","class":"lineCov","hits":"66","order":"234","possible_hits":"0",},
{"lineNum":"  313","line":"  fi"},
{"lineNum":"  314","line":"}"},
{"lineNum":"  315","line":""},
{"lineNum":"  316","line":"bats_setup_tracing() {"},
{"lineNum":"  317","line":"  # Variables for capturing accurate stack traces. See bats_debug_trap for"},
{"lineNum":"  318","line":"  # details."},
{"lineNum":"  319","line":"  #"},
{"lineNum":"  320","line":"  # BATS_DEBUG_LAST_LINENO, BATS_DEBUG_LAST_SOURCE, and"},
{"lineNum":"  321","line":"  # BATS_DEBUG_LAST_STACK_TRACE hold data from the most recent call to"},
{"lineNum":"  322","line":"  # bats_debug_trap."},
{"lineNum":"  323","line":"  #"},
{"lineNum":"  324","line":"  # BATS_DEBUG_LASTLAST_STACK_TRACE holds data from two bats_debug_trap calls"},
{"lineNum":"  325","line":"  # ago."},
{"lineNum":"  326","line":"  #"},
{"lineNum":"  327","line":"  # BATS_DEBUG_LAST_STACK_TRACE_IS_VALID indicates that"},
{"lineNum":"  328","line":"  # BATS_DEBUG_LAST_STACK_TRACE contains the stack trace of the test\'s error. If"},
{"lineNum":"  329","line":"  # unset, BATS_DEBUG_LAST_STACK_TRACE is unreliable and"},
{"lineNum":"  330","line":"  # BATS_DEBUG_LASTLAST_STACK_TRACE should be used instead."},
{"lineNum":"  331","line":"  BATS_DEBUG_LASTLAST_STACK_TRACE=()"},
{"lineNum":"  332","line":"  BATS_DEBUG_LAST_LINENO=()"},
{"lineNum":"  333","line":"  BATS_DEBUG_LAST_SOURCE=()"},
{"lineNum":"  334","line":"  BATS_DEBUG_LAST_STACK_TRACE=()"},
{"lineNum":"  335","line":"  BATS_DEBUG_LAST_STACK_TRACE_IS_VALID=","class":"lineCov","hits":"22","order":"229","possible_hits":"0",},
{"lineNum":"  336","line":"  BATS_ERROR_SUFFIX=","class":"lineCov","hits":"22","order":"230","possible_hits":"0",},
{"lineNum":"  337","line":"  BATS_DEBUG_EXCLUDE_PATHS=()"},
{"lineNum":"  338","line":"  # exclude some paths by default"},
{"lineNum":"  339","line":"  bats_add_debug_exclude_path \"$BATS_ROOT/lib/\"","class":"lineCov","hits":"22","order":"231","possible_hits":"0",},
{"lineNum":"  340","line":"  bats_add_debug_exclude_path \"$BATS_ROOT/libexec/\"","class":"lineCov","hits":"22","order":"235","possible_hits":"0",},
{"lineNum":"  341","line":""},
{"lineNum":"  342","line":"  exec 4<&1 # used for tracing","class":"lineCov","hits":"22","order":"236","possible_hits":"0",},
{"lineNum":"  343","line":"  if [[ \"${BATS_TRACE_LEVEL:-0}\" -gt 0 ]]; then","class":"lineCov","hits":"22","order":"237","possible_hits":"0",},
{"lineNum":"  344","line":"    # avoid undefined variable errors"},
{"lineNum":"  345","line":"    BATS_LAST_BASH_COMMAND=","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  346","line":"    BATS_LAST_BASH_LINENO=","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  347","line":"    BATS_LAST_BASH_SOURCE=","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  348","line":"    BATS_LAST_STACK_DEPTH=","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  349","line":"    # try to exclude helper libraries if found, this is only relevant for tracing"},
{"lineNum":"  350","line":"    while read -r path; do","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  351","line":"      bats_add_debug_exclude_path \"$path\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  352","line":"    done < <(find \"$PWD\" -type d -name bats-assert -o -name bats-support)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  353","line":"  fi"},
{"lineNum":"  354","line":""},
{"lineNum":"  355","line":"  local exclude_paths path","class":"lineCov","hits":"22","order":"238","possible_hits":"0",},
{"lineNum":"  356","line":"  # exclude user defined libraries"},
{"lineNum":"  357","line":"  IFS=\':\' read -r exclude_paths <<<\"${BATS_DEBUG_EXCLUDE_PATHS:-}\"","class":"lineCov","hits":"44","order":"239","possible_hits":"0",},
{"lineNum":"  358","line":"  for path in \"${exclude_paths[@]}\"; do","class":"lineCov","hits":"22","order":"240","possible_hits":"0",},
{"lineNum":"  359","line":"    if [[ -n \"$path\" ]]; then","class":"lineCov","hits":"22","order":"241","possible_hits":"0",},
{"lineNum":"  360","line":"      bats_add_debug_exclude_path \"$path\"","class":"lineCov","hits":"22","order":"242","possible_hits":"0",},
{"lineNum":"  361","line":"    fi"},
{"lineNum":"  362","line":"  done"},
{"lineNum":"  363","line":""},
{"lineNum":"  364","line":"  # turn on traps after setting excludes to avoid tracing the exclude setup"},
{"lineNum":"  365","line":"  trap \'bats_debug_trap \"$BASH_SOURCE\"\' DEBUG","class":"lineCov","hits":"22","order":"243","possible_hits":"0",},
{"lineNum":"  366","line":"  trap \'bats_error_trap\' ERR","class":"lineCov","hits":"44","order":"244","possible_hits":"0",},
{"lineNum":"  367","line":"}"},
{"lineNum":"  368","line":""},
{"lineNum":"  369","line":"bats_error_trap() {"},
{"lineNum":"  370","line":"  bats_check_status_from_trap","class":"lineCov","hits":"28","order":"490","possible_hits":"0",},
{"lineNum":"  371","line":""},
{"lineNum":"  372","line":"  # If necessary, undo the most recent stack trace captured by bats_debug_trap."},
{"lineNum":"  373","line":"  # See bats_debug_trap for details."},
{"lineNum":"  374","line":"  if [[ \"${BASH_LINENO[*]}\" = \"${BATS_DEBUG_LAST_LINENO[*]:-}\" &&","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  375","line":"    \"${BASH_SOURCE[*]}\" = \"${BATS_DEBUG_LAST_SOURCE[*]:-}\" &&","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  376","line":"    -z \"$BATS_DEBUG_LAST_STACK_TRACE_IS_VALID\" ]]; then","class":"lineCov","hits":"40","order":"494","possible_hits":"0",},
{"lineNum":"  377","line":"    BATS_DEBUG_LAST_STACK_TRACE=(","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  378","line":"      ${BATS_DEBUG_LASTLAST_STACK_TRACE[@]+\"${BATS_DEBUG_LASTLAST_STACK_TRACE[@]}\"}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  379","line":"    )"},
{"lineNum":"  380","line":"  fi"},
{"lineNum":"  381","line":"  BATS_DEBUG_LAST_STACK_TRACE_IS_VALID=1","class":"lineCov","hits":"16","order":"495","possible_hits":"0",},
{"lineNum":"  382","line":"}"},
{"lineNum":"  383","line":""},
{"lineNum":"  384","line":"bats_interrupt_trap() {"},
{"lineNum":"  385","line":"  # mark the interruption, to handle during exit"},
{"lineNum":"  386","line":"  BATS_INTERRUPTED=true","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  387","line":"  BATS_ERROR_STATUS=130","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  388","line":"  # debug trap fires before interrupt trap but gets wrong linenumber (line 1)"},
{"lineNum":"  389","line":"  # -> use last stack trace instead of BATS_DEBUG_LAST_STACK_TRACE_IS_VALID=true"},
{"lineNum":"  390","line":"}"},
{"lineNum":"  391","line":""},
{"lineNum":"  392","line":"# this is used inside run()"},
{"lineNum":"  393","line":"bats_interrupt_trap_in_run() {"},
{"lineNum":"  394","line":"  # mark the interruption, to handle during exit"},
{"lineNum":"  395","line":"  BATS_INTERRUPTED=true","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  396","line":"  BATS_ERROR_STATUS=130","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  397","line":"  BATS_DEBUG_LAST_STACK_TRACE_IS_VALID=true","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  398","line":"  exit 130","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  399","line":"}"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "bats", "date" : "2023-04-09 21:57:35", "instrumented" : 168, "covered" : 112,};
var merged_data = [];
