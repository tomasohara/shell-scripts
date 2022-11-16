var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":"set -eET","class":"lineCov","hits":"1","order":"249","possible_hits":"0",},
{"lineNum":"    3","line":""},
{"lineNum":"    4","line":"flags=(\'--dummy-flag\')","class":"lineCov","hits":"1","order":"250","possible_hits":"0",},
{"lineNum":"    5","line":"num_jobs=${BATS_NUMBER_OF_PARALLEL_JOBS:-1}","class":"lineCov","hits":"1","order":"251","possible_hits":"0",},
{"lineNum":"    6","line":"extended_syntax=\'\'","class":"lineCov","hits":"1","order":"252","possible_hits":"0",},
{"lineNum":"    7","line":"BATS_TRACE_LEVEL=\"${BATS_TRACE_LEVEL:-0}\"","class":"lineCov","hits":"1","order":"253","possible_hits":"0",},
{"lineNum":"    8","line":"declare -r BATS_RETRY_RETURN_CODE=126","class":"lineCov","hits":"1","order":"254","possible_hits":"0",},
{"lineNum":"    9","line":"export BATS_TEST_RETRIES=0 # no retries by default","class":"lineCov","hits":"2","order":"255","possible_hits":"0",},
{"lineNum":"   10","line":""},
{"lineNum":"   11","line":"while [[ \"$#\" -ne 0 ]]; do","class":"lineCov","hits":"2","order":"256","possible_hits":"0",},
{"lineNum":"   12","line":"  case \"$1\" in","class":"lineCov","hits":"2","order":"257","possible_hits":"0",},
{"lineNum":"   13","line":"  -j)"},
{"lineNum":"   14","line":"    shift","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   15","line":"    num_jobs=\"$1\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   16","line":"    ;;"},
{"lineNum":"   17","line":"  -T)"},
{"lineNum":"   18","line":"    flags+=(\'-T\')","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   19","line":"    ;;"},
{"lineNum":"   20","line":"  -x)"},
{"lineNum":"   21","line":"    flags+=(\'-x\')","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   22","line":"    extended_syntax=1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   23","line":"    ;;"},
{"lineNum":"   24","line":"  --no-parallelize-within-files)"},
{"lineNum":"   25","line":"    # use singular to allow for users to override in file"},
{"lineNum":"   26","line":"    BATS_NO_PARALLELIZE_WITHIN_FILE=1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   27","line":"    ;;"},
{"lineNum":"   28","line":"  --dummy-flag)"},
{"lineNum":"   29","line":"    ;;"},
{"lineNum":"   30","line":"  --trace)"},
{"lineNum":"   31","line":"    flags+=(\'--trace\')","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   32","line":"    ;;"},
{"lineNum":"   33","line":"  --print-output-on-failure)"},
{"lineNum":"   34","line":"    flags+=(--print-output-on-failure)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   35","line":"    ;;"},
{"lineNum":"   36","line":"  --show-output-of-passing-tests)"},
{"lineNum":"   37","line":"    flags+=(--show-output-of-passing-tests)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   38","line":"    ;;"},
{"lineNum":"   39","line":"  --verbose-run)"},
{"lineNum":"   40","line":"    flags+=(--verbose-run)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   41","line":"    ;;"},
{"lineNum":"   42","line":"  --gather-test-outputs-in)"},
{"lineNum":"   43","line":"    shift","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   44","line":"    flags+=(--gather-test-outputs-in \"$1\")","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   45","line":"    ;;"},
{"lineNum":"   46","line":"  *)"},
{"lineNum":"   47","line":"    break","class":"lineCov","hits":"1","order":"259","possible_hits":"0",},
{"lineNum":"   48","line":"    ;;"},
{"lineNum":"   49","line":"  esac"},
{"lineNum":"   50","line":"  shift","class":"lineCov","hits":"1","order":"258","possible_hits":"0",},
{"lineNum":"   51","line":"done"},
{"lineNum":"   52","line":""},
{"lineNum":"   53","line":"filename=\"$1\"","class":"lineCov","hits":"1","order":"260","possible_hits":"0",},
{"lineNum":"   54","line":"TESTS_FILE=\"$2\"","class":"lineCov","hits":"1","order":"261","possible_hits":"0",},
{"lineNum":"   55","line":""},
{"lineNum":"   56","line":"if [[ ! -f \"$filename\" ]]; then","class":"lineCov","hits":"1","order":"262","possible_hits":"0",},
{"lineNum":"   57","line":"  printf \'Testfile \"%s\" not found\\n\' \"$filename\" >&2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   58","line":"  exit 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   59","line":"fi"},
{"lineNum":"   60","line":""},
{"lineNum":"   61","line":"export BATS_TEST_FILENAME=\"$filename\"","class":"lineCov","hits":"2","order":"263","possible_hits":"0",},
{"lineNum":"   62","line":""},
{"lineNum":"   63","line":"# shellcheck source=lib/bats-core/preprocessing.bash"},
{"lineNum":"   64","line":"# shellcheck disable=SC2153"},
{"lineNum":"   65","line":"source \"$BATS_ROOT/lib/bats-core/preprocessing.bash\"","class":"lineCov","hits":"1","order":"264","possible_hits":"0",},
{"lineNum":"   66","line":""},
{"lineNum":"   67","line":"bats_run_setup_file() {"},
{"lineNum":"   68","line":"  # shellcheck source=lib/bats-core/tracing.bash"},
{"lineNum":"   69","line":"  # shellcheck disable=SC2153"},
{"lineNum":"   70","line":"  source \"$BATS_ROOT/lib/bats-core/tracing.bash\"","class":"lineCov","hits":"1","order":"296","possible_hits":"0",},
{"lineNum":"   71","line":"  # shellcheck source=lib/bats-core/test_functions.bash"},
{"lineNum":"   72","line":"  # shellcheck disable=SC2153"},
{"lineNum":"   73","line":"  source \"$BATS_ROOT/lib/bats-core/test_functions.bash\"","class":"lineCov","hits":"1","order":"297","possible_hits":"0",},
{"lineNum":"   74","line":""},
{"lineNum":"   75","line":"  exec 3<&1","class":"lineCov","hits":"1","order":"302","possible_hits":"0",},
{"lineNum":"   76","line":""},
{"lineNum":"   77","line":"  # these are defined only to avoid errors when referencing undefined variables down the line"},
{"lineNum":"   78","line":"  # shellcheck disable=2034"},
{"lineNum":"   79","line":"  BATS_TEST_NAME=      # used in tracing.bash","class":"lineCov","hits":"1","order":"303","possible_hits":"0",},
{"lineNum":"   80","line":"  # shellcheck disable=2034"},
{"lineNum":"   81","line":"  BATS_TEST_COMPLETED= # used in tracing.bash","class":"lineCov","hits":"1","order":"304","possible_hits":"0",},
{"lineNum":"   82","line":""},
{"lineNum":"   83","line":"  BATS_SOURCE_FILE_COMPLETED=","class":"lineCov","hits":"1","order":"305","possible_hits":"0",},
{"lineNum":"   84","line":"  BATS_SETUP_FILE_COMPLETED=","class":"lineCov","hits":"1","order":"306","possible_hits":"0",},
{"lineNum":"   85","line":"  BATS_TEARDOWN_FILE_COMPLETED=","class":"lineCov","hits":"1","order":"307","possible_hits":"0",},
{"lineNum":"   86","line":"  # shellcheck disable=2034"},
{"lineNum":"   87","line":"  BATS_ERROR_STATUS= # used in tracing.bash","class":"lineCov","hits":"1","order":"308","possible_hits":"0",},
{"lineNum":"   88","line":"  touch \"$BATS_OUT\"","class":"lineCov","hits":"1","order":"309","possible_hits":"0",},
{"lineNum":"   89","line":"  bats_setup_tracing","class":"lineCov","hits":"1","order":"310","possible_hits":"0",},
{"lineNum":"   90","line":"  trap \'bats_file_teardown_trap\' EXIT","class":"lineCov","hits":"2","order":"311","possible_hits":"0",},
{"lineNum":"   91","line":""},
{"lineNum":"   92","line":"  local status=0","class":"lineCov","hits":"2","order":"312","possible_hits":"0",},
{"lineNum":"   93","line":"  # get the setup_file/teardown_file functions for this file (if it has them)"},
{"lineNum":"   94","line":"  # shellcheck disable=SC1090"},
{"lineNum":"   95","line":"  source \"$BATS_TEST_SOURCE\"  >>\"$BATS_OUT\" 2>&1","class":"lineCov","hits":"2","order":"313","possible_hits":"0",},
{"lineNum":"   96","line":""},
{"lineNum":"   97","line":"  BATS_SOURCE_FILE_COMPLETED=1","class":"lineCov","hits":"2","order":"368","possible_hits":"0",},
{"lineNum":"   98","line":""},
{"lineNum":"   99","line":"  setup_file >>\"$BATS_OUT\" 2>&1","class":"lineCov","hits":"2","order":"369","possible_hits":"0",},
{"lineNum":"  100","line":""},
{"lineNum":"  101","line":"  BATS_SETUP_FILE_COMPLETED=1","class":"lineCov","hits":"2","order":"371","possible_hits":"0",},
{"lineNum":"  102","line":"}"},
{"lineNum":"  103","line":""},
{"lineNum":"  104","line":"bats_run_teardown_file() {"},
{"lineNum":"  105","line":"  local bats_teardown_file_status=0","class":"lineCov","hits":"2","order":"765","possible_hits":"0",},
{"lineNum":"  106","line":"  # avoid running the therdown trap due to errors in teardown_file"},
{"lineNum":"  107","line":"  trap \'bats_file_exit_trap\' EXIT","class":"lineCov","hits":"2","order":"766","possible_hits":"0",},
{"lineNum":"  108","line":""},
{"lineNum":"  109","line":"  # rely on bats_error_trap to catch failures"},
{"lineNum":"  110","line":"  teardown_file >>\"$BATS_OUT\" 2>&1 || bats_teardown_file_status=$?","class":"lineCov","hits":"2","order":"767","possible_hits":"0",},
{"lineNum":"  111","line":""},
{"lineNum":"  112","line":"  if (( bats_teardown_file_status == 0 )); then","class":"lineCov","hits":"2","order":"769","possible_hits":"0",},
{"lineNum":"  113","line":"    BATS_TEARDOWN_FILE_COMPLETED=1","class":"lineCov","hits":"2","order":"770","possible_hits":"0",},
{"lineNum":"  114","line":"  elif [[ -n \"${BATS_SETUP_FILE_COMPLETED:-}\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  115","line":"    BATS_DEBUG_LAST_STACK_TRACE_IS_VALID=1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  116","line":"    BATS_ERROR_STATUS=$bats_teardown_file_status","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  117","line":"    return $BATS_ERROR_STATUS","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  118","line":"  fi"},
{"lineNum":"  119","line":"}"},
{"lineNum":"  120","line":""},
{"lineNum":"  121","line":"bats_file_teardown_trap() {"},
{"lineNum":"  122","line":"  bats_run_teardown_file","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  123","line":"  bats_file_exit_trap in-teardown_trap","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  124","line":"}"},
{"lineNum":"  125","line":""},
{"lineNum":"  126","line":"# shellcheck source=lib/bats-core/common.bash"},
{"lineNum":"  127","line":"source \"$BATS_ROOT/lib/bats-core/common.bash\"","class":"lineCov","hits":"1","order":"268","possible_hits":"0",},
{"lineNum":"  128","line":""},
{"lineNum":"  129","line":"bats_file_exit_trap() {"},
{"lineNum":"  130","line":"  local -r last_return_code=$?","class":"lineCov","hits":"2","order":"772","possible_hits":"0",},
{"lineNum":"  131","line":"  if [[ ${1:-} != in-teardown_trap ]]; then","class":"lineCov","hits":"2","order":"773","possible_hits":"0",},
{"lineNum":"  132","line":"    BATS_ERROR_STATUS=$last_return_code","class":"lineCov","hits":"2","order":"774","possible_hits":"0",},
{"lineNum":"  133","line":"  fi"},
{"lineNum":"  134","line":"  trap - ERR EXIT","class":"lineCov","hits":"2","order":"775","possible_hits":"0",},
{"lineNum":"  135","line":"  local failure_reason","class":"lineCov","hits":"2","order":"776","possible_hits":"0",},
{"lineNum":"  136","line":"  local -i failure_test_index=$(( BATS_FILE_FIRST_TEST_NUMBER_IN_SUITE + 1 ))","class":"lineCov","hits":"2","order":"777","possible_hits":"0",},
{"lineNum":"  137","line":"  if [[ -z \"$BATS_SETUP_FILE_COMPLETED\" || -z \"$BATS_TEARDOWN_FILE_COMPLETED\" ]]; then","class":"lineCov","hits":"3","order":"778","possible_hits":"0",},
{"lineNum":"  138","line":"    if [[ -z \"$BATS_SETUP_FILE_COMPLETED\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  139","line":"      failure_reason=\'setup_file\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  140","line":"    elif [[ -z \"$BATS_TEARDOWN_FILE_COMPLETED\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  141","line":"      failure_reason=\'teardown_file\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  142","line":"      failure_test_index=$(( BATS_FILE_FIRST_TEST_NUMBER_IN_SUITE + ${#tests_to_run[@]} + 1 ))","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  143","line":"    elif [[ -z \"$BATS_SOURCE_FILE_COMPLETED\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  144","line":"      failure_reason=\'source\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  145","line":"    else"},
{"lineNum":"  146","line":"      failure_reason=\'unknown internal\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  147","line":"    fi"},
{"lineNum":"  148","line":"    printf \"not ok %d %s\\n\" \"$failure_test_index\" \"$failure_reason failed\" >&3","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  149","line":"    local stack_trace","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  150","line":"    bats_get_failure_stack_trace stack_trace","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  151","line":"    bats_print_stack_trace \"${stack_trace[@]}\" >&3","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  152","line":"    bats_print_failed_command \"${stack_trace[@]}\" >&3","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  153","line":"    bats_prefix_lines_for_tap_output < \"$BATS_OUT\" | bats_replace_filename >&3","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  154","line":"    rm -rf \"$BATS_OUT\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  155","line":"    bats_exec_file_status=1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  156","line":"  fi"},
{"lineNum":"  157","line":""},
{"lineNum":"  158","line":"  # setup_file not executed but defined in this test file? -> might be defined in the wrong file"},
{"lineNum":"  159","line":"  if [[ -z \"${BATS_SETUP_SUITE_COMPLETED-}\" ]] && declare -F setup_suite >/dev/null; then","class":"lineCov","hits":"4","order":"779","possible_hits":"0",},
{"lineNum":"  160","line":"    bats_generate_warning 3 --no-stacktrace \"$BATS_TEST_FILENAME\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  161","line":"  fi"},
{"lineNum":"  162","line":""},
{"lineNum":"  163","line":"  exit $bats_exec_file_status","class":"lineCov","hits":"2","order":"780","possible_hits":"0",},
{"lineNum":"  164","line":"}"},
{"lineNum":"  165","line":""},
{"lineNum":"  166","line":"function setup_file() {"},
{"lineNum":"  167","line":"  return 0","class":"lineCov","hits":"2","order":"370","possible_hits":"0",},
{"lineNum":"  168","line":"}"},
{"lineNum":"  169","line":""},
{"lineNum":"  170","line":"function teardown_file() {"},
{"lineNum":"  171","line":"  return 0","class":"lineCov","hits":"2","order":"768","possible_hits":"0",},
{"lineNum":"  172","line":"}"},
{"lineNum":"  173","line":""},
{"lineNum":"  174","line":"bats_forward_output_of_parallel_test() {"},
{"lineNum":"  175","line":"  local test_number_in_suite=$1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  176","line":"  local status=0","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  177","line":"  wait \"$(cat \"$output_folder/$test_number_in_suite/pid\")\" || status=1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  178","line":"  cat \"$output_folder/$test_number_in_suite/stdout\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  179","line":"  cat \"$output_folder/$test_number_in_suite/stderr\" >&2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  180","line":"  return $status","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  181","line":"}"},
{"lineNum":"  182","line":""},
{"lineNum":"  183","line":"bats_is_next_parallel_test_finished() {"},
{"lineNum":"  184","line":"  local PID","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  185","line":"  # get the pid of the next potentially finished test"},
{"lineNum":"  186","line":"  PID=$(cat \"$output_folder/$(( test_number_in_suite_of_last_finished_test + 1 ))/pid\")","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  187","line":"  # try to send a signal to this process"},
{"lineNum":"  188","line":"  # if it fails, the process exited,"},
{"lineNum":"  189","line":"  # if it succeeds, the process is still running"},
{"lineNum":"  190","line":"  if kill -0 \"$PID\" 2>/dev/null; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  191","line":"    return 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  192","line":"  fi"},
{"lineNum":"  193","line":"}"},
{"lineNum":"  194","line":""},
{"lineNum":"  195","line":"# prints output from all tests in the order they were started"},
{"lineNum":"  196","line":"# $1 == \"blocking\": wait for a test to finish before printing"},
{"lineNum":"  197","line":"#    != \"blocking\": abort printing, when a test has not finished"},
{"lineNum":"  198","line":"bats_forward_output_for_parallel_tests() {"},
{"lineNum":"  199","line":"  local status=0","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  200","line":"  # was the next test already started?"},
{"lineNum":"  201","line":"  while (( test_number_in_suite_of_last_finished_test + 1 <= test_number_in_suite )); do","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  202","line":"    # if we are okay with waiting or if the test has already been finished"},
{"lineNum":"  203","line":"    if [[ \"$1\" == \"blocking\" ]] || bats_is_next_parallel_test_finished ; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  204","line":"      (( ++test_number_in_suite_of_last_finished_test ))"},
{"lineNum":"  205","line":"      bats_forward_output_of_parallel_test \"$test_number_in_suite_of_last_finished_test\" || status=$?","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  206","line":"    else"},
{"lineNum":"  207","line":"      # non-blocking and the process has not finished -> abort the printing"},
{"lineNum":"  208","line":"      break","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  209","line":"    fi"},
{"lineNum":"  210","line":"  done"},
{"lineNum":"  211","line":"  return $status","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  212","line":"}"},
{"lineNum":"  213","line":""},
{"lineNum":"  214","line":"bats_run_test_with_retries() { # <args>"},
{"lineNum":"  215","line":"  local status=0","class":"lineCov","hits":"70","order":"381","possible_hits":"0",},
{"lineNum":"  216","line":"  local should_try_again=1 try_number","class":"lineCov","hits":"70","order":"382","possible_hits":"0",},
{"lineNum":"  217","line":"  for ((try_number=1; should_try_again; ++try_number)); do","class":"lineCov","hits":"280","order":"383","possible_hits":"0",},
{"lineNum":"  218","line":"    if \"$BATS_LIBEXEC/bats-exec-test\" \"$@\" \"$try_number\"; then","class":"lineCov","hits":"70","order":"384","possible_hits":"0",},
{"lineNum":"  219","line":"      should_try_again=0","class":"lineCov","hits":"32","order":"482","possible_hits":"0",},
{"lineNum":"  220","line":"    else"},
{"lineNum":"  221","line":"      status=$?","class":"lineCov","hits":"38","order":"569","possible_hits":"0",},
{"lineNum":"  222","line":"      if ((status == BATS_RETRY_RETURN_CODE)); then","class":"lineCov","hits":"38","order":"570","possible_hits":"0",},
{"lineNum":"  223","line":"        should_try_again=1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  224","line":"      else"},
{"lineNum":"  225","line":"        should_try_again=0","class":"lineCov","hits":"38","order":"571","possible_hits":"0",},
{"lineNum":"  226","line":"        bats_exec_file_status=$status","class":"lineCov","hits":"38","order":"572","possible_hits":"0",},
{"lineNum":"  227","line":"      fi"},
{"lineNum":"  228","line":"    fi"},
{"lineNum":"  229","line":"  done"},
{"lineNum":"  230","line":"  return $status","class":"lineCov","hits":"70","order":"483","possible_hits":"0",},
{"lineNum":"  231","line":"}"},
{"lineNum":"  232","line":""},
{"lineNum":"  233","line":"bats_run_tests_in_parallel() {"},
{"lineNum":"  234","line":"  local output_folder=\"$BATS_RUN_TMPDIR/parallel_output\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  235","line":"  local status=0","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  236","line":"  mkdir -p \"$output_folder\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  237","line":"  # shellcheck source=lib/bats-core/semaphore.bash"},
{"lineNum":"  238","line":"  source \"$BATS_ROOT/lib/bats-core/semaphore.bash\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  239","line":"  bats_semaphore_setup","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  240","line":"  # the test_number_in_file is not yet incremented -> one before the next test to run"},
{"lineNum":"  241","line":"  local test_number_in_suite_of_last_finished_test=\"$BATS_FILE_FIRST_TEST_NUMBER_IN_SUITE\" # stores which test was printed last","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  242","line":"  local test_number_in_file=0 test_number_in_suite=$BATS_FILE_FIRST_TEST_NUMBER_IN_SUITE","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  243","line":"  for test_name in \"${tests_to_run[@]}\"; do","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  244","line":"    # Only handle non-empty lines"},
{"lineNum":"  245","line":"    if [[ $test_name ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  246","line":"      ((++test_number_in_suite))"},
{"lineNum":"  247","line":"      ((++test_number_in_file))"},
{"lineNum":"  248","line":"      mkdir -p \"$output_folder/$test_number_in_suite\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  249","line":"      bats_semaphore_run \"$output_folder/$test_number_in_suite\" \\","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  250","line":"                          bats_run_test_with_retries \"${flags[@]}\" \"$filename\" \"$test_name\" \"$test_number_in_suite\" \"$test_number_in_file\" \\"},
{"lineNum":"  251","line":"                          > \"$output_folder/$test_number_in_suite/pid\""},
{"lineNum":"  252","line":"    fi"},
{"lineNum":"  253","line":"    # print results early to get interactive feedback"},
{"lineNum":"  254","line":"    bats_forward_output_for_parallel_tests non-blocking || status=1 # ignore if we did not finish yet","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  255","line":"  done"},
{"lineNum":"  256","line":"  bats_forward_output_for_parallel_tests blocking || status=1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  257","line":"  return $status","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  258","line":"}"},
{"lineNum":"  259","line":""},
{"lineNum":"  260","line":"bats_read_tests_list_file() {"},
{"lineNum":"  261","line":"  local line_number=0","class":"lineCov","hits":"1","order":"273","possible_hits":"0",},
{"lineNum":"  262","line":"  tests_to_run=()"},
{"lineNum":"  263","line":"  # the global test number must be visible to traps -> not local"},
{"lineNum":"  264","line":"  local test_number_in_suite=\'\'","class":"lineCov","hits":"1","order":"274","possible_hits":"0",},
{"lineNum":"  265","line":"  while read -r test_line; do","class":"lineCov","hits":"36","order":"275","possible_hits":"0",},
{"lineNum":"  266","line":"    # check if the line begins with filename"},
{"lineNum":"  267","line":"    # filename might contain some hard to parse characters,"},
{"lineNum":"  268","line":"    # use simple string operations to work around that issue"},
{"lineNum":"  269","line":"    if [[ \"$filename\" == \"${test_line::${#filename}}\" ]]; then","class":"lineCov","hits":"35","order":"276","possible_hits":"0",},
{"lineNum":"  270","line":"      # get the rest of the line without the separator \\t"},
{"lineNum":"  271","line":"      test_name=${test_line:$((1 + ${#filename} ))}","class":"lineCov","hits":"35","order":"277","possible_hits":"0",},
{"lineNum":"  272","line":"      tests_to_run+=(\"$test_name\")","class":"lineCov","hits":"35","order":"278","possible_hits":"0",},
{"lineNum":"  273","line":"      # save the first test\'s number for later iteration"},
{"lineNum":"  274","line":"      # this assumes that tests for a file are stored consecutive in the file!"},
{"lineNum":"  275","line":"      if [[ -z \"$test_number_in_suite\" ]]; then","class":"lineCov","hits":"35","order":"279","possible_hits":"0",},
{"lineNum":"  276","line":"        test_number_in_suite=$line_number","class":"lineCov","hits":"1","order":"280","possible_hits":"0",},
{"lineNum":"  277","line":"      fi"},
{"lineNum":"  278","line":"    fi"},
{"lineNum":"  279","line":"    ((++line_number))"},
{"lineNum":"  280","line":"  done <\"$TESTS_FILE\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  281","line":"  BATS_FILE_FIRST_TEST_NUMBER_IN_SUITE=\"$test_number_in_suite\"","class":"lineCov","hits":"1","order":"281","possible_hits":"0",},
{"lineNum":"  282","line":"  declare -ri BATS_FILE_FIRST_TEST_NUMBER_IN_SUITE # mark readonly (cannot merge assignment, because value would be lost)","class":"lineCov","hits":"1","order":"282","possible_hits":"0",},
{"lineNum":"  283","line":"}"},
{"lineNum":"  284","line":""},
{"lineNum":"  285","line":"bats_run_tests() {"},
{"lineNum":"  286","line":"  bats_exec_file_status=0","class":"lineCov","hits":"2","order":"374","possible_hits":"0",},
{"lineNum":"  287","line":""},
{"lineNum":"  288","line":"  if [[ \"$num_jobs\" != 1 && \"${BATS_NO_PARALLELIZE_WITHIN_FILE-False}\" == False ]]; then","class":"lineCov","hits":"2","order":"375","possible_hits":"0",},
{"lineNum":"  289","line":"    export BATS_SEMAPHORE_NUMBER_OF_SLOTS=\"$num_jobs\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  290","line":"    bats_run_tests_in_parallel \"$BATS_RUN_TMPDIR/parallel_output\" || bats_exec_file_status=1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  291","line":"  else"},
{"lineNum":"  292","line":"    local test_number_in_suite=$BATS_FILE_FIRST_TEST_NUMBER_IN_SUITE \\","class":"lineCov","hits":"2","order":"376","possible_hits":"0",},
{"lineNum":"  293","line":"          test_number_in_file=0"},
{"lineNum":"  294","line":"    for test_name in \"${tests_to_run[@]}\"; do","class":"lineCov","hits":"70","order":"377","possible_hits":"0",},
{"lineNum":"  295","line":"      if [[ \"${BATS_INTERRUPTED-NOTSET}\" != NOTSET ]]; then","class":"lineCov","hits":"70","order":"378","possible_hits":"0",},
{"lineNum":"  296","line":"        bats_exec_file_status=130 # bash\'s code for SIGINT exits","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  297","line":"        break","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  298","line":"      fi"},
{"lineNum":"  299","line":"      # Only handle non-empty lines"},
{"lineNum":"  300","line":"      if [[ $test_name ]]; then","class":"lineCov","hits":"70","order":"379","possible_hits":"0",},
{"lineNum":"  301","line":"        ((++test_number_in_suite))"},
{"lineNum":"  302","line":"        ((++test_number_in_file))"},
{"lineNum":"  303","line":"        bats_run_test_with_retries \"${flags[@]}\" \"$filename\" \"$test_name\" \\","class":"lineCov","hits":"70","order":"380","possible_hits":"0",},
{"lineNum":"  304","line":"                                    \"$test_number_in_suite\" \"$test_number_in_file\" || bats_exec_file_status=$?"},
{"lineNum":"  305","line":"      fi"},
{"lineNum":"  306","line":"    done"},
{"lineNum":"  307","line":"  fi"},
{"lineNum":"  308","line":"}"},
{"lineNum":"  309","line":""},
{"lineNum":"  310","line":"bats_create_file_tempdirs() {"},
{"lineNum":"  311","line":"  local bats_files_tmpdir=\"${BATS_RUN_TMPDIR}/file\"","class":"lineCov","hits":"1","order":"285","possible_hits":"0",},
{"lineNum":"  312","line":"  if ! mkdir -p \"$bats_files_tmpdir\"; then","class":"lineCov","hits":"1","order":"286","possible_hits":"0",},
{"lineNum":"  313","line":"    printf \'Failed to create %s\\n\' \"$bats_files_tmpdir\" >&2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  314","line":"    exit 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  315","line":"  fi"},
{"lineNum":"  316","line":"  BATS_FILE_TMPDIR=\"$bats_files_tmpdir/${BATS_FILE_FIRST_TEST_NUMBER_IN_SUITE?}\"","class":"lineCov","hits":"1","order":"287","possible_hits":"0",},
{"lineNum":"  317","line":"  if ! mkdir \"$BATS_FILE_TMPDIR\"; then","class":"lineCov","hits":"1","order":"288","possible_hits":"0",},
{"lineNum":"  318","line":"    printf \'Failed to create BATS_FILE_TMPDIR=%s\\n\' \"$BATS_FILE_TMPDIR\" >&2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  319","line":"    exit 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  320","line":"  fi"},
{"lineNum":"  321","line":"  ln -s \"$BATS_TEST_FILENAME\" \"$BATS_FILE_TMPDIR-$(basename \"$BATS_TEST_FILENAME\").source_file\"","class":"lineCov","hits":"2","order":"289","possible_hits":"0",},
{"lineNum":"  322","line":"  export BATS_FILE_TMPDIR","class":"lineCov","hits":"1","order":"290","possible_hits":"0",},
{"lineNum":"  323","line":"}"},
{"lineNum":"  324","line":""},
{"lineNum":"  325","line":"trap \'BATS_INTERRUPTED=true\' INT","class":"lineCov","hits":"1","order":"269","possible_hits":"0",},
{"lineNum":"  326","line":""},
{"lineNum":"  327","line":"if [[ -n \"$extended_syntax\" ]]; then","class":"lineCov","hits":"1","order":"270","possible_hits":"0",},
{"lineNum":"  328","line":"  printf \"suite %s\\n\" \"$filename\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  329","line":"fi"},
{"lineNum":"  330","line":""},
{"lineNum":"  331","line":"BATS_FILE_FIRST_TEST_NUMBER_IN_SUITE=0 # predeclare as Bash 3.2 does not support declare -g","class":"lineCov","hits":"1","order":"271","possible_hits":"0",},
{"lineNum":"  332","line":"bats_read_tests_list_file","class":"lineCov","hits":"1","order":"272","possible_hits":"0",},
{"lineNum":"  333","line":""},
{"lineNum":"  334","line":"# don\'t run potentially expensive setup/teardown_file"},
{"lineNum":"  335","line":"# when there are no tests to run"},
{"lineNum":"  336","line":"if [[ ${#tests_to_run[@]} -eq 0 ]]; then","class":"lineCov","hits":"1","order":"283","possible_hits":"0",},
{"lineNum":"  337","line":"  exit 0","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  338","line":"fi"},
{"lineNum":"  339","line":""},
{"lineNum":"  340","line":"# requires the test list to be read but not empty"},
{"lineNum":"  341","line":"bats_create_file_tempdirs","class":"lineCov","hits":"1","order":"284","possible_hits":"0",},
{"lineNum":"  342","line":""},
{"lineNum":"  343","line":"bats_preprocess_source \"$filename\"","class":"lineCov","hits":"1","order":"291","possible_hits":"0",},
{"lineNum":"  344","line":""},
{"lineNum":"  345","line":"trap bats_interrupt_trap INT","class":"lineCov","hits":"1","order":"294","possible_hits":"0",},
{"lineNum":"  346","line":"bats_run_setup_file","class":"lineCov","hits":"1","order":"295","possible_hits":"0",},
{"lineNum":"  347","line":""},
{"lineNum":"  348","line":"# during tests, we don\'t want to get backtraces from this level"},
{"lineNum":"  349","line":"# just wait for the test to be interrupted and display their trace"},
{"lineNum":"  350","line":"trap \'BATS_INTERRUPTED=true\' INT","class":"lineCov","hits":"2","order":"372","possible_hits":"0",},
{"lineNum":"  351","line":"bats_run_tests","class":"lineCov","hits":"2","order":"373","possible_hits":"0",},
{"lineNum":"  352","line":""},
{"lineNum":"  353","line":"trap bats_interrupt_trap INT","class":"lineCov","hits":"2","order":"763","possible_hits":"0",},
{"lineNum":"  354","line":"bats_run_teardown_file","class":"lineCov","hits":"2","order":"764","possible_hits":"0",},
{"lineNum":"  355","line":""},
{"lineNum":"  356","line":"exit $bats_exec_file_status","class":"lineCov","hits":"2","order":"771","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "bats", "date" : "2022-10-25 17:17:25", "instrumented" : 176, "covered" : 97,};
var merged_data = [];