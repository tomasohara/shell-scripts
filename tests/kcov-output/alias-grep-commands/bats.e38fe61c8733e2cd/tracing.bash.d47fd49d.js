var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":"# shellcheck source=lib/bats-core/common.bash"},
{"lineNum":"    4","line":"source \"$BATS_ROOT/lib/bats-core/common.bash\"","class":"lineCov","hits":"37","order":"208","possible_hits":"0",},
{"lineNum":"    5","line":""},
{"lineNum":"    6","line":"bats_capture_stack_trace() {"},
{"lineNum":"    7","line":"\tlocal test_file","class":"lineCov","hits":"262","order":"318","possible_hits":"0",},
{"lineNum":"    8","line":"\tlocal funcname","class":"lineCov","hits":"262","order":"319","possible_hits":"0",},
{"lineNum":"    9","line":"\tlocal i","class":"lineCov","hits":"262","order":"320","possible_hits":"0",},
{"lineNum":"   10","line":""},
{"lineNum":"   11","line":"\tBATS_DEBUG_LAST_STACK_TRACE=()"},
{"lineNum":"   12","line":""},
{"lineNum":"   13","line":"\tfor ((i = 2; i != ${#FUNCNAME[@]}; ++i)); do","class":"lineCov","hits":"592","order":"321","possible_hits":"0",},
{"lineNum":"   14","line":"\t\t# Use BATS_TEST_SOURCE if necessary to work around Bash < 4.4 bug whereby"},
{"lineNum":"   15","line":"\t\t# calling an exported function erases the test file\'s BASH_SOURCE entry."},
{"lineNum":"   16","line":"\t\ttest_file=\"${BASH_SOURCE[$i]:-$BATS_TEST_SOURCE}\"","class":"lineCov","hits":"296","order":"322","possible_hits":"0",},
{"lineNum":"   17","line":"\t\tfuncname=\"${FUNCNAME[$i]}\"","class":"lineCov","hits":"296","order":"323","possible_hits":"0",},
{"lineNum":"   18","line":"\t\tBATS_DEBUG_LAST_STACK_TRACE+=(\"${BASH_LINENO[$((i-1))]} $funcname $test_file\")","class":"lineCov","hits":"296","order":"324","possible_hits":"0",},
{"lineNum":"   19","line":"\t\tcase \"$funcname\" in","class":"lineCov","hits":"296","order":"325","possible_hits":"0",},
{"lineNum":"   20","line":"\t\t\"${BATS_TEST_NAME-}\" | setup | teardown | setup_file | teardown_file | setup_suite | teardown_suite)"},
{"lineNum":"   21","line":"\t\t\tbreak","class":"lineCov","hits":"243","order":"420","possible_hits":"0",},
{"lineNum":"   22","line":"\t\t\t;;"},
{"lineNum":"   23","line":"\t\tesac"},
{"lineNum":"   24","line":"\t\tif [[ \"${BASH_SOURCE[$i + 1]:-}\" == *\"bats-exec-file\" ]] && [[ \"$funcname\" == \'source\' ]]; then","class":"lineCov","hits":"72","order":"326","possible_hits":"0",},
{"lineNum":"   25","line":"\t\t\tbreak","class":"lineCov","hits":"19","order":"327","possible_hits":"0",},
{"lineNum":"   26","line":"\t\tfi"},
{"lineNum":"   27","line":"\tdone"},
{"lineNum":"   28","line":"}"},
{"lineNum":"   29","line":""},
{"lineNum":"   30","line":"bats_get_failure_stack_trace() {"},
{"lineNum":"   31","line":"\tlocal stack_trace_var","class":"lineCov","hits":"6","order":"486","possible_hits":"0",},
{"lineNum":"   32","line":"\t# See bats_debug_trap for details."},
{"lineNum":"   33","line":"\tif [[ -n \"${BATS_DEBUG_LAST_STACK_TRACE_IS_VALID:-}\" ]]; then","class":"lineCov","hits":"6","order":"487","possible_hits":"0",},
{"lineNum":"   34","line":"\t\tstack_trace_var=BATS_DEBUG_LAST_STACK_TRACE","class":"lineCov","hits":"6","order":"488","possible_hits":"0",},
{"lineNum":"   35","line":"\telse"},
{"lineNum":"   36","line":"\t\tstack_trace_var=BATS_DEBUG_LASTLAST_STACK_TRACE","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   37","line":"\tfi"},
{"lineNum":"   38","line":"\t# shellcheck disable=SC2016"},
{"lineNum":"   39","line":"\teval \"$(printf \\","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   40","line":"\t\t\'%s=(${%s[@]+\"${%s[@]}\"})\' \\"},
{"lineNum":"   41","line":"\t\t\"${1}\" \\"},
{"lineNum":"   42","line":"\t\t\"${stack_trace_var}\" \\"},
{"lineNum":"   43","line":"\t\t\"${stack_trace_var}\")\""},
{"lineNum":"   44","line":"}"},
{"lineNum":"   45","line":""},
{"lineNum":"   46","line":"bats_print_stack_trace() {"},
{"lineNum":"   47","line":"\tlocal frame","class":"lineCov","hits":"6","order":"490","possible_hits":"0",},
{"lineNum":"   48","line":"\tlocal index=1","class":"lineCov","hits":"6","order":"491","possible_hits":"0",},
{"lineNum":"   49","line":"\tlocal count=\"${#@}\"","class":"lineCov","hits":"6","order":"492","possible_hits":"0",},
{"lineNum":"   50","line":"\tlocal filename","class":"lineCov","hits":"6","order":"493","possible_hits":"0",},
{"lineNum":"   51","line":"\tlocal lineno","class":"lineCov","hits":"6","order":"494","possible_hits":"0",},
{"lineNum":"   52","line":""},
{"lineNum":"   53","line":"\tfor frame in \"$@\"; do","class":"lineCov","hits":"6","order":"495","possible_hits":"0",},
{"lineNum":"   54","line":"\t\tbats_frame_filename \"$frame\" \'filename\'","class":"lineCov","hits":"6","order":"496","possible_hits":"0",},
{"lineNum":"   55","line":"\t\tbats_trim_filename \"$filename\" \'filename\'","class":"lineCov","hits":"6","order":"502","possible_hits":"0",},
{"lineNum":"   56","line":"\t\tbats_frame_lineno \"$frame\" \'lineno\'","class":"lineCov","hits":"6","order":"504","possible_hits":"0",},
{"lineNum":"   57","line":""},
{"lineNum":"   58","line":"\t\tprintf \'%s\' \"${BATS_STACK_TRACE_PREFIX-# }\"","class":"lineCov","hits":"6","order":"506","possible_hits":"0",},
{"lineNum":"   59","line":"\t\tif [[ $index -eq 1 ]]; then","class":"lineCov","hits":"6","order":"507","possible_hits":"0",},
{"lineNum":"   60","line":"\t\t\tprintf \'(\'","class":"lineCov","hits":"6","order":"508","possible_hits":"0",},
{"lineNum":"   61","line":"\t\telse"},
{"lineNum":"   62","line":"\t\t\tprintf \' \'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   63","line":"\t\tfi"},
{"lineNum":"   64","line":""},
{"lineNum":"   65","line":"\t\tlocal fn","class":"lineCov","hits":"6","order":"509","possible_hits":"0",},
{"lineNum":"   66","line":"\t\tbats_frame_function \"$frame\" \'fn\'","class":"lineCov","hits":"6","order":"510","possible_hits":"0",},
{"lineNum":"   67","line":"\t\tif [[ \"$fn\" != \"${BATS_TEST_NAME-}\" ]] &&","class":"lineCov","hits":"6","order":"513","possible_hits":"0",},
{"lineNum":"   68","line":"\t\t\t# don\'t print \"from function `source\'\"\","},
{"lineNum":"   69","line":"\t\t\t# when failing in free code during `source $test_file` from bats-exec-file"},
{"lineNum":"   70","line":"\t\t\t! [[ \"$fn\" == \'source\' &&  $index -eq $count ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   71","line":"\t\t\tlocal quoted_fn","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   72","line":"\t\t\tbats_quote_code quoted_fn \"$fn\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   73","line":"\t\t\tprintf \"from function %s \" \"$quoted_fn\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   74","line":"\t\tfi"},
{"lineNum":"   75","line":""},
{"lineNum":"   76","line":"\t\tif [[ $index -eq $count ]]; then","class":"lineCov","hits":"6","order":"514","possible_hits":"0",},
{"lineNum":"   77","line":"\t\t\tprintf \'in test file %s, line %d)\\n\' \"$filename\" \"$lineno\"","class":"lineCov","hits":"6","order":"515","possible_hits":"0",},
{"lineNum":"   78","line":"\t\telse"},
{"lineNum":"   79","line":"\t\t\tprintf \'in file %s, line %d,\\n\' \"$filename\" \"$lineno\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   80","line":"\t\tfi"},
{"lineNum":"   81","line":""},
{"lineNum":"   82","line":"\t\t((++index))"},
{"lineNum":"   83","line":"\tdone"},
{"lineNum":"   84","line":"}"},
{"lineNum":"   85","line":""},
{"lineNum":"   86","line":"bats_print_failed_command() {"},
{"lineNum":"   87","line":"\tlocal stack_trace=(\"${@}\")","class":"lineCov","hits":"12","order":"517","possible_hits":"0",},
{"lineNum":"   88","line":"\tif [[ ${#stack_trace[@]} -eq 0 ]]; then","class":"lineCov","hits":"6","order":"518","possible_hits":"0",},
{"lineNum":"   89","line":"\t\treturn 0","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   90","line":"\tfi"},
{"lineNum":"   91","line":"\tlocal frame=\"${stack_trace[${#stack_trace[@]} - 1]}\"","class":"lineCov","hits":"6","order":"519","possible_hits":"0",},
{"lineNum":"   92","line":"\tlocal filename","class":"lineCov","hits":"6","order":"520","possible_hits":"0",},
{"lineNum":"   93","line":"\tlocal lineno","class":"lineCov","hits":"6","order":"521","possible_hits":"0",},
{"lineNum":"   94","line":"\tlocal failed_line","class":"lineCov","hits":"6","order":"522","possible_hits":"0",},
{"lineNum":"   95","line":"\tlocal failed_command","class":"lineCov","hits":"6","order":"523","possible_hits":"0",},
{"lineNum":"   96","line":""},
{"lineNum":"   97","line":"\tbats_frame_filename \"$frame\" \'filename\'","class":"lineCov","hits":"6","order":"524","possible_hits":"0",},
{"lineNum":"   98","line":"\tbats_frame_lineno \"$frame\" \'lineno\'","class":"lineCov","hits":"6","order":"525","possible_hits":"0",},
{"lineNum":"   99","line":"\tbats_extract_line \"$filename\" \"$lineno\" \'failed_line\'","class":"lineCov","hits":"6","order":"526","possible_hits":"0",},
{"lineNum":"  100","line":"\tbats_strip_string \"$failed_line\" \'failed_command\'","class":"lineCov","hits":"6","order":"533","possible_hits":"0",},
{"lineNum":"  101","line":"\tlocal quoted_failed_command","class":"lineCov","hits":"6","order":"536","possible_hits":"0",},
{"lineNum":"  102","line":"\tbats_quote_code quoted_failed_command \"$failed_command\"","class":"lineCov","hits":"6","order":"537","possible_hits":"0",},
{"lineNum":"  103","line":"\tprintf \'#   %s \' \"${quoted_failed_command}\"","class":"lineCov","hits":"6","order":"539","possible_hits":"0",},
{"lineNum":"  104","line":""},
{"lineNum":"  105","line":"\tif [[ \"${BATS_TIMED_OUT-NOTSET}\" != NOTSET ]]; then","class":"lineCov","hits":"6","order":"540","possible_hits":"0",},
{"lineNum":"  106","line":"\t\t# the other values can be safely overwritten here,"},
{"lineNum":"  107","line":"\t\t# as the timeout is the primary reason for failure"},
{"lineNum":"  108","line":"\t\tBATS_ERROR_SUFFIX=\" due to timeout\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  109","line":"\tfi"},
{"lineNum":"  110","line":""},
{"lineNum":"  111","line":"\tif [[ \"$BATS_ERROR_STATUS\" -eq 1 ]]; then","class":"lineCov","hits":"6","order":"541","possible_hits":"0",},
{"lineNum":"  112","line":"\t\tprintf \'failed%s\\n\' \"$BATS_ERROR_SUFFIX\"","class":"lineCov","hits":"4","order":"590","possible_hits":"0",},
{"lineNum":"  113","line":"\telse"},
{"lineNum":"  114","line":"\t\tprintf \'failed with status %d%s\\n\' \"$BATS_ERROR_STATUS\" \"$BATS_ERROR_SUFFIX\"","class":"lineCov","hits":"2","order":"542","possible_hits":"0",},
{"lineNum":"  115","line":"\tfi"},
{"lineNum":"  116","line":"}"},
{"lineNum":"  117","line":""},
{"lineNum":"  118","line":"bats_frame_lineno() {"},
{"lineNum":"  119","line":"\tprintf -v \"$2\" \'%s\' \"${1%% *}\"","class":"lineCov","hits":"12","order":"505","possible_hits":"0",},
{"lineNum":"  120","line":"}"},
{"lineNum":"  121","line":""},
{"lineNum":"  122","line":"bats_frame_function() {"},
{"lineNum":"  123","line":"\tlocal __bff_function=\"${1#* }\"","class":"lineCov","hits":"6","order":"511","possible_hits":"0",},
{"lineNum":"  124","line":"\tprintf -v \"$2\" \'%s\' \"${__bff_function%% *}\"","class":"lineCov","hits":"6","order":"512","possible_hits":"0",},
{"lineNum":"  125","line":"}"},
{"lineNum":"  126","line":""},
{"lineNum":"  127","line":"bats_frame_filename() {"},
{"lineNum":"  128","line":"\tlocal __bff_filename=\"${1#* }\"","class":"lineCov","hits":"12","order":"497","possible_hits":"0",},
{"lineNum":"  129","line":"\t__bff_filename=\"${__bff_filename#* }\"","class":"lineCov","hits":"12","order":"498","possible_hits":"0",},
{"lineNum":"  130","line":""},
{"lineNum":"  131","line":"\tif [[ \"$__bff_filename\" == \"${BATS_TEST_SOURCE-}\" ]]; then","class":"lineCov","hits":"12","order":"499","possible_hits":"0",},
{"lineNum":"  132","line":"\t\t__bff_filename=\"$BATS_TEST_FILENAME\"","class":"lineCov","hits":"12","order":"500","possible_hits":"0",},
{"lineNum":"  133","line":"\tfi"},
{"lineNum":"  134","line":"\tprintf -v \"$2\" \'%s\' \"$__bff_filename\"","class":"lineCov","hits":"12","order":"501","possible_hits":"0",},
{"lineNum":"  135","line":"}"},
{"lineNum":"  136","line":""},
{"lineNum":"  137","line":"bats_extract_line() {"},
{"lineNum":"  138","line":"\tlocal __bats_extract_line_line","class":"lineCov","hits":"6","order":"527","possible_hits":"0",},
{"lineNum":"  139","line":"\tlocal __bats_extract_line_index=0","class":"lineCov","hits":"6","order":"528","possible_hits":"0",},
{"lineNum":"  140","line":""},
{"lineNum":"  141","line":"\twhile IFS= read -r __bats_extract_line_line; do","class":"lineCov","hits":"1318","order":"529","possible_hits":"0",},
{"lineNum":"  142","line":"\t\tif [[ \"$((++__bats_extract_line_index))\" -eq \"$2\" ]]; then","class":"lineCov","hits":"659","order":"530","possible_hits":"0",},
{"lineNum":"  143","line":"\t\t\tprintf -v \"$3\" \'%s\' \"${__bats_extract_line_line%$\'\\r\'}\"","class":"lineCov","hits":"6","order":"531","possible_hits":"0",},
{"lineNum":"  144","line":"\t\t\tbreak","class":"lineCov","hits":"6","order":"532","possible_hits":"0",},
{"lineNum":"  145","line":"\t\tfi"},
{"lineNum":"  146","line":"\tdone <\"$1\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  147","line":"}"},
{"lineNum":"  148","line":""},
{"lineNum":"  149","line":"bats_strip_string() {"},
{"lineNum":"  150","line":"\t[[ \"$1\" =~ ^[[:space:]]*(.*)[[:space:]]*$ ]]","class":"lineCov","hits":"6","order":"534","possible_hits":"0",},
{"lineNum":"  151","line":"\tprintf -v \"$2\" \'%s\' \"${BASH_REMATCH[1]}\"","class":"lineCov","hits":"6","order":"535","possible_hits":"0",},
{"lineNum":"  152","line":"}"},
{"lineNum":"  153","line":""},
{"lineNum":"  154","line":"bats_trim_filename() {"},
{"lineNum":"  155","line":"\tprintf -v \"$2\" \'%s\' \"${1#\"$BATS_CWD\"/}\"","class":"lineCov","hits":"6","order":"503","possible_hits":"0",},
{"lineNum":"  156","line":"}"},
{"lineNum":"  157","line":""},
{"lineNum":"  158","line":"# normalize a windows path from e.g. C:/directory to /c/directory"},
{"lineNum":"  159","line":"# The path must point to an existing/accessable directory, not a file!"},
{"lineNum":"  160","line":"bats_normalize_windows_dir_path() { # <output-var> <path>"},
{"lineNum":"  161","line":"\tlocal output_var=\"$1\" path=\"$2\"","class":"lineCov","hits":"1455","order":"228","possible_hits":"0",},
{"lineNum":"  162","line":"\tif [[ \"$output_var\" != NORMALIZED_INPUT ]]; then","class":"lineCov","hits":"1455","order":"229","possible_hits":"0",},
{"lineNum":"  163","line":"\t\tlocal NORMALIZED_INPUT","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  164","line":"\tfi"},
{"lineNum":"  165","line":"\tif [[ $path == ?:* ]]; then","class":"lineCov","hits":"1455","order":"230","possible_hits":"0",},
{"lineNum":"  166","line":"\t\tNORMALIZED_INPUT=\"$(cd \"$path\" || exit 1; pwd)\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  167","line":"\telse"},
{"lineNum":"  168","line":"\t\tNORMALIZED_INPUT=\"$path\"","class":"lineCov","hits":"1455","order":"231","possible_hits":"0",},
{"lineNum":"  169","line":"\tfi"},
{"lineNum":"  170","line":"\tprintf -v \"$output_var\" \"%s\" \"$NORMALIZED_INPUT\"","class":"lineCov","hits":"1455","order":"232","possible_hits":"0",},
{"lineNum":"  171","line":"}"},
{"lineNum":"  172","line":""},
{"lineNum":"  173","line":"bats_emit_trace() {"},
{"lineNum":"  174","line":"\tif [[ $BATS_TRACE_LEVEL -gt 0 ]]; then","class":"lineCov","hits":"262","order":"329","possible_hits":"0",},
{"lineNum":"  175","line":"\t\tlocal line=${BASH_LINENO[1]}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  176","line":"\t\t# shellcheck disable=SC2016"},
{"lineNum":"  177","line":"\t\tif [[ $BASH_COMMAND != \'\"$BATS_TEST_NAME\" >> \"$BATS_OUT\" 2>&1 4>&1\' && $BASH_COMMAND != \"bats_test_begin \"* ]] && # don\'t emit these internal calls","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  178","line":"\t\t\t[[ $BASH_COMMAND != \"$BATS_LAST_BASH_COMMAND\" || $line != \"$BATS_LAST_BASH_LINENO\" ]] &&","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  179","line":"\t\t\t# avoid printing a function twice (at call site and at definition site)"},
{"lineNum":"  180","line":"\t\t\t[[ $BASH_COMMAND != \"$BATS_LAST_BASH_COMMAND\" || ${BASH_LINENO[2]} != \"$BATS_LAST_BASH_LINENO\" || ${BASH_SOURCE[3]} != \"$BATS_LAST_BASH_SOURCE\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  181","line":"\t\t\tlocal file=\"${BASH_SOURCE[2]}\" # index 2: skip over bats_emit_trace and bats_debug_trap","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  182","line":"\t\t\tif [[ $file == \"${BATS_TEST_SOURCE}\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  183","line":"\t\t\t\tfile=\"$BATS_TEST_FILENAME\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  184","line":"\t\t\tfi"},
{"lineNum":"  185","line":"\t\t\tlocal padding=\'$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  186","line":"\t\t\tif (( BATS_LAST_STACK_DEPTH != ${#BASH_LINENO[@]} )); then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  187","line":"\t\t\t\tprintf \'%s [%s:%d]\\n\' \"${padding::${#BASH_LINENO[@]}-4}\" \"${file##*/}\" \"$line\" >&4","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  188","line":"\t\t\tfi"},
{"lineNum":"  189","line":"\t\t\tprintf \'%s %s\\n\'  \"${padding::${#BASH_LINENO[@]}-4}\" \"$BASH_COMMAND\"  >&4","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  190","line":"\t\t\tBATS_LAST_BASH_COMMAND=\"$BASH_COMMAND\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  191","line":"\t\t\tBATS_LAST_BASH_LINENO=\"$line\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  192","line":"\t\t\tBATS_LAST_BASH_SOURCE=\"${BASH_SOURCE[2]}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  193","line":"\t\t\tBATS_LAST_STACK_DEPTH=\"${#BASH_LINENO[@]}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  194","line":"\t\tfi"},
{"lineNum":"  195","line":"\tfi"},
{"lineNum":"  196","line":"}"},
{"lineNum":"  197","line":""},
{"lineNum":"  198","line":"# bats_debug_trap tracks the last line of code executed within a test. This is"},
{"lineNum":"  199","line":"# necessary because $BASH_LINENO is often incorrect inside of ERR and EXIT"},
{"lineNum":"  200","line":"# trap handlers."},
{"lineNum":"  201","line":"#"},
{"lineNum":"  202","line":"# Below are tables describing different command failure scenarios and the"},
{"lineNum":"  203","line":"# reliability of $BASH_LINENO within different the executed DEBUG, ERR, and EXIT"},
{"lineNum":"  204","line":"# trap handlers. Naturally, the behaviors change between versions of Bash."},
{"lineNum":"  205","line":"#"},
{"lineNum":"  206","line":"# Table rows should be read left to right. For example, on bash version"},
{"lineNum":"  207","line":"# 4.0.44(2)-release, if a test executes `false` (or any other failing external"},
{"lineNum":"  208","line":"# command), bash will do the following in order:"},
{"lineNum":"  209","line":"# 1. Call the DEBUG trap handler (bats_debug_trap) with $BASH_LINENO referring"},
{"lineNum":"  210","line":"#    to the source line containing the `false` command, then"},
{"lineNum":"  211","line":"# 2. Call the DEBUG trap handler again, but with an incorrect $BASH_LINENO, then"},
{"lineNum":"  212","line":"# 3. Call the ERR trap handler, but with a (possibly-different) incorrect"},
{"lineNum":"  213","line":"#    $BASH_LINENO, then"},
{"lineNum":"  214","line":"# 4. Call the DEBUG trap handler again, but with $BASH_LINENO set to 1, then"},
{"lineNum":"  215","line":"# 5. Call the EXIT trap handler, with $BASH_LINENO set to 1."},
{"lineNum":"  216","line":"#"},
{"lineNum":"  217","line":"# bash version 4.4.20(1)-release"},
{"lineNum":"  218","line":"#  command     | first DEBUG | second DEBUG | ERR     | third DEBUG | EXIT"},
{"lineNum":"  219","line":"# -------------+-------------+--------------+---------+-------------+--------"},
{"lineNum":"  220","line":"#  false       | OK          | OK           | OK      | BAD[1]      | BAD[1]"},
{"lineNum":"  221","line":"#  [[ 1 = 2 ]] | OK          | BAD[2]       | BAD[2]  | BAD[1]      | BAD[1]"},
{"lineNum":"  222","line":"#  (( 1 = 2 )) | OK          | BAD[2]       | BAD[2]  | BAD[1]      | BAD[1]"},
{"lineNum":"  223","line":"#  ! true      | OK          | ---          | BAD[4]  | ---         | BAD[1]"},
{"lineNum":"  224","line":"#  $var_dne    | OK          | ---          | ---     | BAD[1]      | BAD[1]"},
{"lineNum":"  225","line":"#  source /dne | OK          | ---          | ---     | BAD[1]      | BAD[1]"},
{"lineNum":"  226","line":"#"},
{"lineNum":"  227","line":"# bash version 4.0.44(2)-release"},
{"lineNum":"  228","line":"#  command     | first DEBUG | second DEBUG | ERR     | third DEBUG | EXIT"},
{"lineNum":"  229","line":"# -------------+-------------+--------------+---------+-------------+--------"},
{"lineNum":"  230","line":"#  false       | OK          | BAD[3]       | BAD[3]  | BAD[1]      | BAD[1]"},
{"lineNum":"  231","line":"#  [[ 1 = 2 ]] | OK          | ---          | BAD[3]  | ---         | BAD[1]"},
{"lineNum":"  232","line":"#  (( 1 = 2 )) | OK          | ---          | BAD[3]  | ---         | BAD[1]"},
{"lineNum":"  233","line":"#  ! true      | OK          | ---          | BAD[3]  | ---         | BAD[1]"},
{"lineNum":"  234","line":"#  $var_dne    | OK          | ---          | ---     | BAD[1]      | BAD[1]"},
{"lineNum":"  235","line":"#  source /dne | OK          | ---          | ---     | BAD[1]      | BAD[1]"},
{"lineNum":"  236","line":"#"},
{"lineNum":"  237","line":"# [1] The reported line number is always 1."},
{"lineNum":"  238","line":"# [2] The reported source location is that of the beginning of the function"},
{"lineNum":"  239","line":"#     calling the command."},
{"lineNum":"  240","line":"# [3] The reported line is that of the last command executed in the DEBUG trap"},
{"lineNum":"  241","line":"#     handler."},
{"lineNum":"  242","line":"# [4] The reported source location is that of the call to the function calling"},
{"lineNum":"  243","line":"#     the command."},
{"lineNum":"  244","line":"bats_debug_trap() {"},
{"lineNum":"  245","line":"\t# on windows we sometimes get a mix of paths (when install via nmp install -g)"},
{"lineNum":"  246","line":"\t# which have C:/... or /c/... comparing them is going to be problematic."},
{"lineNum":"  247","line":"\t# We need to normalize them to a common format!"},
{"lineNum":"  248","line":"\tlocal NORMALIZED_INPUT","class":"lineCov","hits":"1455","order":"226","possible_hits":"0",},
{"lineNum":"  249","line":"\tbats_normalize_windows_dir_path NORMALIZED_INPUT \"${1%/*}\"","class":"lineCov","hits":"1455","order":"227","possible_hits":"0",},
{"lineNum":"  250","line":"\tlocal file_excluded=\'\' path","class":"lineCov","hits":"1455","order":"233","possible_hits":"0",},
{"lineNum":"  251","line":"\tfor path in \"${BATS_DEBUG_EXCLUDE_PATHS[@]}\"; do","class":"lineCov","hits":"2906","order":"234","possible_hits":"0",},
{"lineNum":"  252","line":"\t\tif [[ \"$NORMALIZED_INPUT\" == \"$path\"* ]]; then","class":"lineCov","hits":"2906","order":"235","possible_hits":"0",},
{"lineNum":"  253","line":"\t\t\tfile_excluded=1","class":"lineCov","hits":"1192","order":"236","possible_hits":"0",},
{"lineNum":"  254","line":"\t\t\tbreak","class":"lineCov","hits":"1192","order":"237","possible_hits":"0",},
{"lineNum":"  255","line":"\t\tfi"},
{"lineNum":"  256","line":"\tdone"},
{"lineNum":"  257","line":""},
{"lineNum":"  258","line":"\t# don\'t update the trace within library functions or we get backtraces from inside traps"},
{"lineNum":"  259","line":"\t# also don\'t record new stack traces while handling interruptions, to avoid overriding the interrupted command"},
{"lineNum":"  260","line":"\tif [[ -z \"$file_excluded\" &&","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  261","line":"\t\t\t\"${BATS_INTERRUPTED-NOTSET}\" == NOTSET &&","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  262","line":"\t\t\t\"${BATS_TIMED_OUT-NOTSET}\" == NOTSET ]]; then","class":"lineCov","hits":"1981","order":"238","possible_hits":"0",},
{"lineNum":"  263","line":"\t\tBATS_DEBUG_LASTLAST_STACK_TRACE=(","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  264","line":"\t\t\t${BATS_DEBUG_LAST_STACK_TRACE[@]+\"${BATS_DEBUG_LAST_STACK_TRACE[@]}\"}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  265","line":"\t\t)"},
{"lineNum":"  266","line":""},
{"lineNum":"  267","line":"\t\tBATS_DEBUG_LAST_LINENO=(${BASH_LINENO[@]+\"${BASH_LINENO[@]}\"})","class":"lineCov","hits":"263","order":"315","possible_hits":"0",},
{"lineNum":"  268","line":"\t\tBATS_DEBUG_LAST_SOURCE=(${BASH_SOURCE[@]+\"${BASH_SOURCE[@]}\"})","class":"lineCov","hits":"263","order":"316","possible_hits":"0",},
{"lineNum":"  269","line":"\t\tbats_capture_stack_trace","class":"lineCov","hits":"264","order":"317","possible_hits":"0",},
{"lineNum":"  270","line":"\t\tbats_emit_trace","class":"lineCov","hits":"262","order":"328","possible_hits":"0",},
{"lineNum":"  271","line":"\tfi"},
{"lineNum":"  272","line":"}"},
{"lineNum":"  273","line":""},
{"lineNum":"  274","line":"# For some versions of Bash, the `ERR` trap may not always fire for every"},
{"lineNum":"  275","line":"# command failure, but the `EXIT` trap will. Also, some command failures may not"},
{"lineNum":"  276","line":"# set `$?` properly. See #72 and #81 for details."},
{"lineNum":"  277","line":"#"},
{"lineNum":"  278","line":"# For this reason, we call `bats_check_status_from_trap` at the very beginning"},
{"lineNum":"  279","line":"# of `bats_teardown_trap` and check the value of `$BATS_TEST_COMPLETED` before"},
{"lineNum":"  280","line":"# taking other actions. We also adjust the exit status value if needed."},
{"lineNum":"  281","line":"#"},
{"lineNum":"  282","line":"# See `bats_exit_trap` for an additional EXIT error handling case when `$?`"},
{"lineNum":"  283","line":"# isn\'t set properly during `teardown()` errors."},
{"lineNum":"  284","line":"bats_check_status_from_trap() {"},
{"lineNum":"  285","line":"\tlocal status=\"$?\"","class":"lineCov","hits":"39","order":"433","possible_hits":"0",},
{"lineNum":"  286","line":"\tif [[ -z \"${BATS_TEST_COMPLETED:-}\" ]]; then","class":"lineCov","hits":"39","order":"434","possible_hits":"0",},
{"lineNum":"  287","line":"\t\tBATS_ERROR_STATUS=\"${BATS_ERROR_STATUS:-$status}\"","class":"lineCov","hits":"17","order":"476","possible_hits":"0",},
{"lineNum":"  288","line":"\t\tif [[ \"$BATS_ERROR_STATUS\" -eq 0 ]]; then","class":"lineCov","hits":"17","order":"477","possible_hits":"0",},
{"lineNum":"  289","line":"\t\t\tBATS_ERROR_STATUS=1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  290","line":"\t\tfi"},
{"lineNum":"  291","line":"\t\ttrap - DEBUG","class":"lineCov","hits":"17","order":"478","possible_hits":"0",},
{"lineNum":"  292","line":"\tfi"},
{"lineNum":"  293","line":"}"},
{"lineNum":"  294","line":""},
{"lineNum":"  295","line":"bats_add_debug_exclude_path() { # <path>"},
{"lineNum":"  296","line":"\tif [[ -z \"$1\" ]]; then # don\'t exclude everything","class":"lineCov","hits":"57","order":"213","possible_hits":"0",},
{"lineNum":"  297","line":"\t\tprintf \"bats_add_debug_exclude_path: Exclude path must not be empty!\\n\" >&2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  298","line":"\t\treturn 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  299","line":"\tfi"},
{"lineNum":"  300","line":"\tif [[ \"$OSTYPE\" == cygwin || \"$OSTYPE\" == msys ]]; then","class":"lineCov","hits":"114","order":"214","possible_hits":"0",},
{"lineNum":"  301","line":"\t\tlocal normalized_dir","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  302","line":"\t\tbats_normalize_windows_dir_path normalized_dir \"$1\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  303","line":"\t\tBATS_DEBUG_EXCLUDE_PATHS+=(\"$normalized_dir\")","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  304","line":"\telse"},
{"lineNum":"  305","line":"\t\tBATS_DEBUG_EXCLUDE_PATHS+=(\"$1\")","class":"lineCov","hits":"57","order":"215","possible_hits":"0",},
{"lineNum":"  306","line":"\tfi"},
{"lineNum":"  307","line":"}"},
{"lineNum":"  308","line":""},
{"lineNum":"  309","line":"bats_setup_tracing() {"},
{"lineNum":"  310","line":"\t# Variables for capturing accurate stack traces. See bats_debug_trap for"},
{"lineNum":"  311","line":"\t# details."},
{"lineNum":"  312","line":"\t#"},
{"lineNum":"  313","line":"\t# BATS_DEBUG_LAST_LINENO, BATS_DEBUG_LAST_SOURCE, and"},
{"lineNum":"  314","line":"\t# BATS_DEBUG_LAST_STACK_TRACE hold data from the most recent call to"},
{"lineNum":"  315","line":"\t# bats_debug_trap."},
{"lineNum":"  316","line":"\t#"},
{"lineNum":"  317","line":"\t# BATS_DEBUG_LASTLAST_STACK_TRACE holds data from two bats_debug_trap calls"},
{"lineNum":"  318","line":"\t# ago."},
{"lineNum":"  319","line":"\t#"},
{"lineNum":"  320","line":"\t# BATS_DEBUG_LAST_STACK_TRACE_IS_VALID indicates that"},
{"lineNum":"  321","line":"\t# BATS_DEBUG_LAST_STACK_TRACE contains the stack trace of the test\'s error. If"},
{"lineNum":"  322","line":"\t# unset, BATS_DEBUG_LAST_STACK_TRACE is unreliable and"},
{"lineNum":"  323","line":"\t# BATS_DEBUG_LASTLAST_STACK_TRACE should be used instead."},
{"lineNum":"  324","line":"\tBATS_DEBUG_LASTLAST_STACK_TRACE=()"},
{"lineNum":"  325","line":"\tBATS_DEBUG_LAST_LINENO=()"},
{"lineNum":"  326","line":"\tBATS_DEBUG_LAST_SOURCE=()"},
{"lineNum":"  327","line":"\tBATS_DEBUG_LAST_STACK_TRACE=()"},
{"lineNum":"  328","line":"\tBATS_DEBUG_LAST_STACK_TRACE_IS_VALID=","class":"lineCov","hits":"19","order":"210","possible_hits":"0",},
{"lineNum":"  329","line":"\tBATS_ERROR_SUFFIX=","class":"lineCov","hits":"19","order":"211","possible_hits":"0",},
{"lineNum":"  330","line":"\tBATS_DEBUG_EXCLUDE_PATHS=()"},
{"lineNum":"  331","line":"\t# exclude some paths by default"},
{"lineNum":"  332","line":"\tbats_add_debug_exclude_path \"$BATS_ROOT/lib/\"","class":"lineCov","hits":"19","order":"212","possible_hits":"0",},
{"lineNum":"  333","line":"\tbats_add_debug_exclude_path \"$BATS_ROOT/libexec/\"","class":"lineCov","hits":"19","order":"216","possible_hits":"0",},
{"lineNum":"  334","line":""},
{"lineNum":"  335","line":""},
{"lineNum":"  336","line":"\texec 4<&1 # used for tracing","class":"lineCov","hits":"19","order":"217","possible_hits":"0",},
{"lineNum":"  337","line":"\tif [[ \"${BATS_TRACE_LEVEL:-0}\" -gt 0 ]]; then","class":"lineCov","hits":"19","order":"218","possible_hits":"0",},
{"lineNum":"  338","line":"\t\t# avoid undefined variable errors"},
{"lineNum":"  339","line":"\t\tBATS_LAST_BASH_COMMAND=","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  340","line":"\t\tBATS_LAST_BASH_LINENO=","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  341","line":"\t\tBATS_LAST_BASH_SOURCE=","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  342","line":"\t\tBATS_LAST_STACK_DEPTH=","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  343","line":"\t\t# try to exclude helper libraries if found, this is only relevant for tracing"},
{"lineNum":"  344","line":"\t\twhile read -r path; do","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  345","line":"\t\t\tbats_add_debug_exclude_path \"$path\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  346","line":"\t\tdone < <(find \"$PWD\" -type d -name bats-assert -o -name bats-support)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  347","line":"\tfi"},
{"lineNum":"  348","line":""},
{"lineNum":"  349","line":"\tlocal exclude_paths path","class":"lineCov","hits":"19","order":"219","possible_hits":"0",},
{"lineNum":"  350","line":"\t# exclude user defined libraries"},
{"lineNum":"  351","line":"\tIFS=\':\' read -r exclude_paths <<< \"${BATS_DEBUG_EXCLUDE_PATHS:-}\"","class":"lineCov","hits":"38","order":"220","possible_hits":"0",},
{"lineNum":"  352","line":"\tfor path in \"${exclude_paths[@]}\"; do","class":"lineCov","hits":"19","order":"221","possible_hits":"0",},
{"lineNum":"  353","line":"\t\tif [[ -n \"$path\" ]]; then","class":"lineCov","hits":"19","order":"222","possible_hits":"0",},
{"lineNum":"  354","line":"\t\t\tbats_add_debug_exclude_path \"$path\"","class":"lineCov","hits":"19","order":"223","possible_hits":"0",},
{"lineNum":"  355","line":"\t\tfi"},
{"lineNum":"  356","line":"\tdone"},
{"lineNum":"  357","line":""},
{"lineNum":"  358","line":"\t# turn on traps after setting excludes to avoid tracing the exclude setup"},
{"lineNum":"  359","line":"\ttrap \'bats_debug_trap \"$BASH_SOURCE\"\' DEBUG","class":"lineCov","hits":"19","order":"224","possible_hits":"0",},
{"lineNum":"  360","line":"  \ttrap \'bats_error_trap\' ERR","class":"lineCov","hits":"38","order":"225","possible_hits":"0",},
{"lineNum":"  361","line":"}"},
{"lineNum":"  362","line":""},
{"lineNum":"  363","line":"bats_error_trap() {"},
{"lineNum":"  364","line":"  bats_check_status_from_trap","class":"lineCov","hits":"11","order":"475","possible_hits":"0",},
{"lineNum":"  365","line":""},
{"lineNum":"  366","line":"  # If necessary, undo the most recent stack trace captured by bats_debug_trap."},
{"lineNum":"  367","line":"  # See bats_debug_trap for details."},
{"lineNum":"  368","line":"  if [[ \"${BASH_LINENO[*]}\" = \"${BATS_DEBUG_LAST_LINENO[*]:-}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  369","line":"     && \"${BASH_SOURCE[*]}\" = \"${BATS_DEBUG_LAST_SOURCE[*]:-}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  370","line":"\t && -z \"$BATS_DEBUG_LAST_STACK_TRACE_IS_VALID\" ]]; then","class":"lineCov","hits":"16","order":"479","possible_hits":"0",},
{"lineNum":"  371","line":"    BATS_DEBUG_LAST_STACK_TRACE=(","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  372","line":"      ${BATS_DEBUG_LASTLAST_STACK_TRACE[@]+\"${BATS_DEBUG_LASTLAST_STACK_TRACE[@]}\"}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  373","line":"    )"},
{"lineNum":"  374","line":"  fi"},
{"lineNum":"  375","line":"  BATS_DEBUG_LAST_STACK_TRACE_IS_VALID=1","class":"lineCov","hits":"6","order":"480","possible_hits":"0",},
{"lineNum":"  376","line":"}"},
{"lineNum":"  377","line":""},
{"lineNum":"  378","line":"bats_interrupt_trap() {"},
{"lineNum":"  379","line":"  # mark the interruption, to handle during exit"},
{"lineNum":"  380","line":"  BATS_INTERRUPTED=true","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  381","line":"  BATS_ERROR_STATUS=130","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  382","line":"  # debug trap fires before interrupt trap but gets wrong linenumber (line 1)"},
{"lineNum":"  383","line":"  # -> use last stack trace"},
{"lineNum":"  384","line":"  exit $BATS_ERROR_STATUS","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  385","line":"}"},
{"lineNum":"  386","line":""},
{"lineNum":"  387","line":"# this is used inside run()"},
{"lineNum":"  388","line":"bats_interrupt_trap_in_run() {"},
{"lineNum":"  389","line":"  # mark the interruption, to handle during exit"},
{"lineNum":"  390","line":"  BATS_INTERRUPTED=true","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  391","line":"  BATS_ERROR_STATUS=130","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  392","line":"  BATS_DEBUG_LAST_STACK_TRACE_IS_VALID=true","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  393","line":"  exit $BATS_ERROR_STATUS","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  394","line":"}"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "bats", "date" : "2022-10-25 17:18:02", "instrumented" : 165, "covered" : 109,};
var merged_data = [];
