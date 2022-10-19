var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":"set -eET","class":"lineCov","hits":"35","order":"385","possible_hits":"0",},
{"lineNum":"    3","line":""},
{"lineNum":"    4","line":"# Variables used in other scripts."},
{"lineNum":"    5","line":"BATS_ENABLE_TIMING=\'\'","class":"lineCov","hits":"35","order":"386","possible_hits":"0",},
{"lineNum":"    6","line":"BATS_EXTENDED_SYNTAX=\'\'","class":"lineCov","hits":"35","order":"387","possible_hits":"0",},
{"lineNum":"    7","line":"BATS_TRACE_LEVEL=\"${BATS_TRACE_LEVEL:-0}\"","class":"lineCov","hits":"35","order":"388","possible_hits":"0",},
{"lineNum":"    8","line":"BATS_PRINT_OUTPUT_ON_FAILURE=\"${BATS_PRINT_OUTPUT_ON_FAILURE:-}\"","class":"lineCov","hits":"35","order":"389","possible_hits":"0",},
{"lineNum":"    9","line":"BATS_SHOW_OUTPUT_OF_SUCCEEDING_TESTS=\"${BATS_SHOW_OUTPUT_OF_SUCCEEDING_TESTS:-}\"","class":"lineCov","hits":"35","order":"390","possible_hits":"0",},
{"lineNum":"   10","line":"BATS_VERBOSE_RUN=\"${BATS_VERBOSE_RUN:-}\"","class":"lineCov","hits":"35","order":"391","possible_hits":"0",},
{"lineNum":"   11","line":"BATS_GATHER_TEST_OUTPUTS_IN=\"${BATS_GATHER_TEST_OUTPUTS_IN:-}\"","class":"lineCov","hits":"35","order":"392","possible_hits":"0",},
{"lineNum":"   12","line":"BATS_TEST_NAME_PREFIX=\"${BATS_TEST_NAME_PREFIX:-}\"","class":"lineCov","hits":"35","order":"393","possible_hits":"0",},
{"lineNum":"   13","line":""},
{"lineNum":"   14","line":"while [[ \"$#\" -ne 0 ]]; do","class":"lineCov","hits":"70","order":"394","possible_hits":"0",},
{"lineNum":"   15","line":"  case \"$1\" in","class":"lineCov","hits":"70","order":"395","possible_hits":"0",},
{"lineNum":"   16","line":"  -T)"},
{"lineNum":"   17","line":"    BATS_ENABLE_TIMING=\'-T\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   18","line":"    ;;"},
{"lineNum":"   19","line":"  -x)"},
{"lineNum":"   20","line":"    # shellcheck disable=SC2034"},
{"lineNum":"   21","line":"    BATS_EXTENDED_SYNTAX=\'-x\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   22","line":"    ;;"},
{"lineNum":"   23","line":"  --dummy-flag)"},
{"lineNum":"   24","line":"    ;;"},
{"lineNum":"   25","line":"  --trace)"},
{"lineNum":"   26","line":"    (( ++BATS_TRACE_LEVEL )) # avoid returning 0","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   27","line":"    ;;"},
{"lineNum":"   28","line":"  --print-output-on-failure)"},
{"lineNum":"   29","line":"    BATS_PRINT_OUTPUT_ON_FAILURE=1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   30","line":"    ;;"},
{"lineNum":"   31","line":"  --show-output-of-passing-tests)"},
{"lineNum":"   32","line":"    BATS_SHOW_OUTPUT_OF_SUCCEEDING_TESTS=1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   33","line":"    ;;"},
{"lineNum":"   34","line":"  --verbose-run)"},
{"lineNum":"   35","line":"    BATS_VERBOSE_RUN=1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   36","line":"    ;;"},
{"lineNum":"   37","line":"  --gather-test-outputs-in)"},
{"lineNum":"   38","line":"    shift","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   39","line":"    BATS_GATHER_TEST_OUTPUTS_IN=\"$1\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   40","line":"    ;;"},
{"lineNum":"   41","line":"  *)"},
{"lineNum":"   42","line":"    break","class":"lineCov","hits":"35","order":"397","possible_hits":"0",},
{"lineNum":"   43","line":"    ;;"},
{"lineNum":"   44","line":"  esac"},
{"lineNum":"   45","line":"  shift","class":"lineCov","hits":"35","order":"396","possible_hits":"0",},
{"lineNum":"   46","line":"done"},
{"lineNum":"   47","line":""},
{"lineNum":"   48","line":"export BATS_TEST_FILENAME=\"$1\"","class":"lineCov","hits":"70","order":"398","possible_hits":"0",},
{"lineNum":"   49","line":"export BATS_TEST_NAME=\"$2\"","class":"lineCov","hits":"70","order":"399","possible_hits":"0",},
{"lineNum":"   50","line":"export BATS_SUITE_TEST_NUMBER=\"$3\"","class":"lineCov","hits":"70","order":"400","possible_hits":"0",},
{"lineNum":"   51","line":"export BATS_TEST_NUMBER=\"$4\"","class":"lineCov","hits":"70","order":"401","possible_hits":"0",},
{"lineNum":"   52","line":"BATS_TEST_TRY_NUMBER=\"$5\"","class":"lineCov","hits":"35","order":"402","possible_hits":"0",},
{"lineNum":"   53","line":""},
{"lineNum":"   54","line":"if [[ -z \"$BATS_TEST_FILENAME\" ]]; then","class":"lineCov","hits":"35","order":"403","possible_hits":"0",},
{"lineNum":"   55","line":"  printf \'usage: bats-exec-test <filename>\\n\' >&2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   56","line":"  exit 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   57","line":"elif [[ ! -f \"$BATS_TEST_FILENAME\" ]]; then","class":"lineCov","hits":"35","order":"404","possible_hits":"0",},
{"lineNum":"   58","line":"  printf \'bats: %s does not exist\\n\' \"$BATS_TEST_FILENAME\" >&2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   59","line":"  exit 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   60","line":"fi"},
{"lineNum":"   61","line":""},
{"lineNum":"   62","line":"bats_create_test_tmpdirs() {"},
{"lineNum":"   63","line":"  local tests_tmpdir=\"${BATS_RUN_TMPDIR}/test\"","class":"lineCov","hits":"35","order":"412","possible_hits":"0",},
{"lineNum":"   64","line":"  if ! mkdir -p \"$tests_tmpdir\"; then","class":"lineCov","hits":"35","order":"413","possible_hits":"0",},
{"lineNum":"   65","line":"    printf \'Failed to create: %s\\n\' \"$tests_tmpdir\" >&2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   66","line":"    exit 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   67","line":"  fi"},
{"lineNum":"   68","line":""},
{"lineNum":"   69","line":"  BATS_TEST_TMPDIR=\"$tests_tmpdir/$BATS_SUITE_TEST_NUMBER\"","class":"lineCov","hits":"35","order":"414","possible_hits":"0",},
{"lineNum":"   70","line":"  if ! mkdir \"$BATS_TEST_TMPDIR\"; then","class":"lineCov","hits":"35","order":"415","possible_hits":"0",},
{"lineNum":"   71","line":"    printf \'Failed to create BATS_TEST_TMPDIR%d: %s\\n\' \"$BATS_TEST_TRY_NUMBER\" \"$BATS_TEST_TMPDIR\" >&2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   72","line":"    exit 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   73","line":"  fi"},
{"lineNum":"   74","line":""},
{"lineNum":"   75","line":"  printf \"%s\\n\" \"$BATS_TEST_NAME\" > \"$BATS_TEST_TMPDIR.name\"","class":"lineCov","hits":"35","order":"416","possible_hits":"0",},
{"lineNum":"   76","line":""},
{"lineNum":"   77","line":"  export BATS_TEST_TMPDIR","class":"lineCov","hits":"35","order":"417","possible_hits":"0",},
{"lineNum":"   78","line":"}"},
{"lineNum":"   79","line":""},
{"lineNum":"   80","line":"# load the test helper functions like `load` or `run` that are needed to run a (preprocessed) .bats file without bash errors"},
{"lineNum":"   81","line":"# shellcheck source=lib/bats-core/test_functions.bash disable=SC2153"},
{"lineNum":"   82","line":"source \"$BATS_ROOT/lib/bats-core/test_functions.bash\"","class":"lineCov","hits":"35","order":"405","possible_hits":"0",},
{"lineNum":"   83","line":"# shellcheck source=lib/bats-core/tracing.bash disable=SC2153"},
{"lineNum":"   84","line":"source \"$BATS_ROOT/lib/bats-core/tracing.bash\"","class":"lineCov","hits":"35","order":"406","possible_hits":"0",},
{"lineNum":"   85","line":""},
{"lineNum":"   86","line":"bats_teardown_trap() {"},
{"lineNum":"   87","line":"  bats_check_status_from_trap","class":"lineCov","hits":"51","order":"448","possible_hits":"0",},
{"lineNum":"   88","line":"  local bats_teardown_trap_status=0","class":"lineCov","hits":"51","order":"451","possible_hits":"0",},
{"lineNum":"   89","line":""},
{"lineNum":"   90","line":"  # `bats_teardown_trap` is always called with one parameter (BATS_TEARDOWN_STARTED)"},
{"lineNum":"   91","line":"  # The second parameter is optional and corresponds for to the killer pid"},
{"lineNum":"   92","line":"  # that will be forwarded to the exit trap to kill it if necesary"},
{"lineNum":"   93","line":"  local killer_pid=${2:-}","class":"lineCov","hits":"51","order":"452","possible_hits":"0",},
{"lineNum":"   94","line":""},
{"lineNum":"   95","line":"  # mark the start of this function to distinguish where skip is called"},
{"lineNum":"   96","line":"  # parameter 1 will signify the reason why this function was called"},
{"lineNum":"   97","line":"  # this is used to identify when this is called as exit trap function"},
{"lineNum":"   98","line":"  BATS_TEARDOWN_STARTED=${1:-1}","class":"lineCov","hits":"51","order":"453","possible_hits":"0",},
{"lineNum":"   99","line":"  teardown >>\"$BATS_OUT\" 2>&1 || bats_teardown_trap_status=\"$?\"","class":"lineCov","hits":"51","order":"454","possible_hits":"0",},
{"lineNum":"  100","line":""},
{"lineNum":"  101","line":"  if [[ $bats_teardown_trap_status -eq 0 ]]; then","class":"lineCov","hits":"51","order":"456","possible_hits":"0",},
{"lineNum":"  102","line":"    BATS_TEARDOWN_COMPLETED=1","class":"lineCov","hits":"51","order":"457","possible_hits":"0",},
{"lineNum":"  103","line":"  elif [[ -n \"$BATS_TEST_COMPLETED\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  104","line":"    BATS_DEBUG_LAST_STACK_TRACE_IS_VALID=1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  105","line":"    BATS_ERROR_STATUS=\"$bats_teardown_trap_status\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  106","line":"  fi"},
{"lineNum":"  107","line":""},
{"lineNum":"  108","line":"  bats_exit_trap \"$killer_pid\"","class":"lineCov","hits":"51","order":"458","possible_hits":"0",},
{"lineNum":"  109","line":"}"},
{"lineNum":"  110","line":""},
{"lineNum":"  111","line":"# shellcheck source=lib/bats-core/common.bash"},
{"lineNum":"  112","line":"source \"$BATS_ROOT/lib/bats-core/common.bash\"","class":"lineCov","hits":"35","order":"407","possible_hits":"0",},
{"lineNum":"  113","line":""},
{"lineNum":"  114","line":"bats_exit_trap() {"},
{"lineNum":"  115","line":"  local status","class":"lineCov","hits":"51","order":"459","possible_hits":"0",},
{"lineNum":"  116","line":"  local exit_metadata=\'\'","class":"lineCov","hits":"51","order":"460","possible_hits":"0",},
{"lineNum":"  117","line":"  local killer_pid=${1:-}","class":"lineCov","hits":"51","order":"461","possible_hits":"0",},
{"lineNum":"  118","line":"  trap - ERR EXIT","class":"lineCov","hits":"51","order":"462","possible_hits":"0",},
{"lineNum":"  119","line":"  if [[ -n \"${BATS_TEST_TIMEOUT:-}\" ]]; then","class":"lineCov","hits":"51","order":"463","possible_hits":"0",},
{"lineNum":"  120","line":"    # Kill the watchdog in the case of of kernel finished before the timeout"},
{"lineNum":"  121","line":"    bats_abort_timeout_countdown \"$killer_pid\" || status=1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  122","line":"  fi"},
{"lineNum":"  123","line":""},
{"lineNum":"  124","line":"  if [[ -n \"$BATS_TEST_SKIPPED\" ]]; then","class":"lineCov","hits":"51","order":"464","possible_hits":"0",},
{"lineNum":"  125","line":"    exit_metadata=\' # skip\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  126","line":"    if [[ \"$BATS_TEST_SKIPPED\" != \'1\' ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  127","line":"        exit_metadata+=\" $BATS_TEST_SKIPPED\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  128","line":"    fi"},
{"lineNum":"  129","line":"  elif [[ \"${BATS_TIMED_OUT-NOTSET}\" != NOTSET ]]; then","class":"lineCov","hits":"51","order":"465","possible_hits":"0",},
{"lineNum":"  130","line":"     exit_metadata=\" # timeout after ${BATS_TEST_TIMEOUT}s\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  131","line":"  fi"},
{"lineNum":"  132","line":""},
{"lineNum":"  133","line":"  BATS_TEST_TIME=\'\'","class":"lineCov","hits":"51","order":"466","possible_hits":"0",},
{"lineNum":"  134","line":"  if [[ -n \"$BATS_ENABLE_TIMING\" ]]; then","class":"lineCov","hits":"51","order":"467","possible_hits":"0",},
{"lineNum":"  135","line":"    BATS_TEST_TIME=\" in \"$(( $(get_mills_since_epoch) - BATS_TEST_START_TIME ))\"ms\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  136","line":"  fi"},
{"lineNum":"  137","line":""},
{"lineNum":"  138","line":"  local print_bats_out=\"${BATS_SHOW_OUTPUT_OF_SUCCEEDING_TESTS}\"","class":"lineCov","hits":"51","order":"468","possible_hits":"0",},
{"lineNum":"  139","line":""},
{"lineNum":"  140","line":"  local should_retry=\'\'","class":"lineCov","hits":"51","order":"469","possible_hits":"0",},
{"lineNum":"  141","line":"  if [[ -z \"$BATS_TEST_COMPLETED\" || -z \"$BATS_TEARDOWN_COMPLETED\" || \"${BATS_INTERRUPTED-NOTSET}\" != NOTSET ]]; then","class":"lineCov","hits":"83","order":"470","possible_hits":"0",},
{"lineNum":"  142","line":"    if [[ \"$BATS_ERROR_STATUS\" -eq 0 ]]; then","class":"lineCov","hits":"19","order":"495","possible_hits":"0",},
{"lineNum":"  143","line":"      # For some versions of bash, `$?` may not be set properly for some error"},
{"lineNum":"  144","line":"      # conditions before triggering the EXIT trap directly (see #72 and #81)."},
{"lineNum":"  145","line":"      # Thanks to the `BATS_TEARDOWN_COMPLETED` signal, this will pinpoint such"},
{"lineNum":"  146","line":"      # errors if they happen during `teardown()` when `bats_perform_test` calls"},
{"lineNum":"  147","line":"      # `bats_teardown_trap` directly after the test itself passes."},
{"lineNum":"  148","line":"      #"},
{"lineNum":"  149","line":"      # If instead the test fails, and the `teardown()` error happens while"},
{"lineNum":"  150","line":"      # `bats_teardown_trap` runs as the EXIT trap, the test will fail with no"},
{"lineNum":"  151","line":"      # output, since there\'s no way to reach the `bats_exit_trap` call."},
{"lineNum":"  152","line":"      BATS_ERROR_STATUS=1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  153","line":"    fi"},
{"lineNum":"  154","line":"    if bats_should_retry_test; then","class":"lineCov","hits":"19","order":"496","possible_hits":"0",},
{"lineNum":"  155","line":"      should_retry=1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  156","line":"      status=126 # signify retry","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  157","line":"      rm -r \"$BATS_TEST_TMPDIR\" # clean up for retry","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  158","line":"    else"},
{"lineNum":"  159","line":"      printf \'not ok %d %s%s\\n\' \"$BATS_SUITE_TEST_NUMBER\" \"${BATS_TEST_NAME_PREFIX:-}${BATS_TEST_DESCRIPTION}${BATS_TEST_TIME}\" \"$exit_metadata\" >&3","class":"lineCov","hits":"19","order":"497","possible_hits":"0",},
{"lineNum":"  160","line":"      local stack_trace","class":"lineCov","hits":"19","order":"498","possible_hits":"0",},
{"lineNum":"  161","line":"      bats_get_failure_stack_trace stack_trace","class":"lineCov","hits":"19","order":"499","possible_hits":"0",},
{"lineNum":"  162","line":"      bats_print_stack_trace \"${stack_trace[@]}\" >&3","class":"lineCov","hits":"19","order":"503","possible_hits":"0",},
{"lineNum":"  163","line":"      bats_print_failed_command \"${stack_trace[@]}\" >&3","class":"lineCov","hits":"19","order":"530","possible_hits":"0",},
{"lineNum":"  164","line":""},
{"lineNum":"  165","line":"      if [[ $BATS_PRINT_OUTPUT_ON_FAILURE ]]; then","class":"lineCov","hits":"19","order":"557","possible_hits":"0",},
{"lineNum":"  166","line":"        if [[ -n \"${output:-}\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  167","line":"          printf \"Last output:\\n%s\\n\" \"$output\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  168","line":"        fi"},
{"lineNum":"  169","line":"        if [[ -n \"${stderr:-}\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  170","line":"          printf \"Last stderr: \\n%s\\n\" \"$stderr\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  171","line":"        fi"},
{"lineNum":"  172","line":"      fi  >> \"$BATS_OUT\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  173","line":""},
{"lineNum":"  174","line":"      print_bats_out=1","class":"lineCov","hits":"19","order":"558","possible_hits":"0",},
{"lineNum":"  175","line":"      status=1","class":"lineCov","hits":"19","order":"559","possible_hits":"0",},
{"lineNum":"  176","line":"      local state=failed","class":"lineCov","hits":"19","order":"560","possible_hits":"0",},
{"lineNum":"  177","line":"    fi"},
{"lineNum":"  178","line":"  else"},
{"lineNum":"  179","line":"    printf \'ok %d %s%s\\n\' \"$BATS_SUITE_TEST_NUMBER\" \"${BATS_TEST_NAME_PREFIX:-}${BATS_TEST_DESCRIPTION}${BATS_TEST_TIME}\" \\","class":"lineCov","hits":"32","order":"471","possible_hits":"0",},
{"lineNum":"  180","line":"      \"$exit_metadata\" >&3"},
{"lineNum":"  181","line":"    status=0","class":"lineCov","hits":"32","order":"474","possible_hits":"0",},
{"lineNum":"  182","line":"    local state=passed","class":"lineCov","hits":"32","order":"475","possible_hits":"0",},
{"lineNum":"  183","line":"  fi"},
{"lineNum":"  184","line":""},
{"lineNum":"  185","line":"  if [[ -z \"$should_retry\" ]]; then","class":"lineCov","hits":"51","order":"476","possible_hits":"0",},
{"lineNum":"  186","line":"    printf \"%s %s\\t%s\\n\" \"$state\" \"$BATS_TEST_FILENAME\" \"$BATS_TEST_NAME\" >> \"$BATS_RUNLOG_FILE\"","class":"lineCov","hits":"51","order":"477","possible_hits":"0",},
{"lineNum":"  187","line":""},
{"lineNum":"  188","line":"    if [[ $print_bats_out ]]; then","class":"lineCov","hits":"51","order":"478","possible_hits":"0",},
{"lineNum":"  189","line":"      bats_prefix_lines_for_tap_output < \"$BATS_OUT\" | bats_replace_filename >&3","class":"lineCov","hits":"38","order":"561","possible_hits":"0",},
{"lineNum":"  190","line":"    fi"},
{"lineNum":"  191","line":"  fi"},
{"lineNum":"  192","line":"  if [[ $BATS_GATHER_TEST_OUTPUTS_IN ]]; then","class":"lineCov","hits":"51","order":"479","possible_hits":"0",},
{"lineNum":"  193","line":"    local try_suffix=","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  194","line":"    if [[ -n \"$should_retry\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  195","line":"      try_suffix=\"-try$BATS_TEST_TRY_NUMBER\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  196","line":"    fi"},
{"lineNum":"  197","line":"    cp \"$BATS_OUT\" \"$BATS_GATHER_TEST_OUTPUTS_IN/$BATS_SUITE_TEST_NUMBER$try_suffix-$BATS_TEST_DESCRIPTION.log\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  198","line":"  fi"},
{"lineNum":"  199","line":"  rm -f \"$BATS_OUT\"","class":"lineCov","hits":"51","order":"480","possible_hits":"0",},
{"lineNum":"  200","line":"  exit \"$status\"","class":"lineCov","hits":"51","order":"481","possible_hits":"0",},
{"lineNum":"  201","line":"}"},
{"lineNum":"  202","line":""},
{"lineNum":"  203","line":"# Marks the test as failed due to timeout."},
{"lineNum":"  204","line":"# The actual termination of subprocesses is done via pkill in the background"},
{"lineNum":"  205","line":"# process in bats_start_timeout_countdown"},
{"lineNum":"  206","line":"bats_timeout_trap() {"},
{"lineNum":"  207","line":"  BATS_TIMED_OUT=1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  208","line":"  BATS_DEBUG_LAST_STACK_TRACE_IS_VALID=","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  209","line":"  exit 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  210","line":"}"},
{"lineNum":"  211","line":""},
{"lineNum":"  212","line":"bats_get_child_processes_of() { # <parent-pid>"},
{"lineNum":"  213","line":"    local -ri parent_pid=${1?}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  214","line":"    {"},
{"lineNum":"  215","line":"      read -ra header","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  216","line":"      local pid_col ppid_col","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  217","line":"      for (( i = 0; i < ${#header[@]}; ++i )); do","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  218","line":"        if [[ ${header[$i]} == \"PID\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  219","line":"          pid_col=$i","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  220","line":"        fi"},
{"lineNum":"  221","line":"        if [[ ${header[$i]} == \"PPID\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  222","line":"          ppid_col=$i","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  223","line":"        fi"},
{"lineNum":"  224","line":"      done"},
{"lineNum":"  225","line":"      while read -ra row; do","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  226","line":"        if (( ${row[$ppid_col]} == parent_pid )); then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  227","line":"          printf \"%d\\n\" \"${row[$pid_col]}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  228","line":"        fi"},
{"lineNum":"  229","line":"      done"},
{"lineNum":"  230","line":"    } < <(ps -ef \"$parent_pid\")","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  231","line":"}"},
{"lineNum":"  232","line":""},
{"lineNum":"  233","line":"bats_kill_childprocesses_of() { # <parent-pid>"},
{"lineNum":"  234","line":"  local -ir parent_pid=\"${1?}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  235","line":"  if command -v pkill; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  236","line":"    pkill -P \"$parent_pid\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  237","line":"  else"},
{"lineNum":"  238","line":"    # kill in reverse order (latest first)"},
{"lineNum":"  239","line":"    while read -r pid; do","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  240","line":"      kill \"$pid\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  241","line":"    done < <(bats_get_child_processes_of \"$parent_pid\" | sort -r)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  242","line":"  fi >/dev/null","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  243","line":"}"},
{"lineNum":"  244","line":""},
{"lineNum":"  245","line":"# sets a timeout for this process"},
{"lineNum":"  246","line":"#"},
{"lineNum":"  247","line":"# using SIGABRT for interprocess communication."},
{"lineNum":"  248","line":"# Ruled out:"},
{"lineNum":"  249","line":"# USR1/2 - not available on Windows"},
{"lineNum":"  250","line":"# SIGALRM - interferes with sleep:"},
{"lineNum":"  251","line":"#           \"sleep(3) may be implemented using SIGALRM; mixing calls to alarm()"},
{"lineNum":"  252","line":"#           and sleep(3) is a bad idea.\" ~ https://linux.die.net/man/2/alarm"},
{"lineNum":"  253","line":"bats_start_timeout_countdown() { # <timeout>"},
{"lineNum":"  254","line":"  local -ri timeout=$1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  255","line":"  local -ri target_pid=$$","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  256","line":"  # shellcheck disable=SC2064"},
{"lineNum":"  257","line":"  trap \"bats_timeout_trap $target_pid\" ABRT","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  258","line":"  if ! (command -v ps || command -v pkill) >/dev/null; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  259","line":"    printf \"Error: Cannot execute timeout because neither pkill nor ps are available on this system!\\n\" >&2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  260","line":"    exit 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  261","line":"  fi"},
{"lineNum":"  262","line":"  # Start another process to kill the children of this process"},
{"lineNum":"  263","line":"  (","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  264","line":"     sleep \"$timeout\" &","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  265","line":"     # sleep won\'t recieve signals, so we use wait below"},
{"lineNum":"  266","line":"     # and kill sleep explicitly when signalled to do so"},
{"lineNum":"  267","line":"     # shellcheck disable=SC2064"},
{"lineNum":"  268","line":"     trap \"kill $!; exit 0\" ABRT","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  269","line":"     wait","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  270","line":"     if kill -ABRT \"$target_pid\"; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  271","line":"        # get rid of signal blocking child processes (like sleep)"},
{"lineNum":"  272","line":"        bats_kill_childprocesses_of \"$target_pid\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  273","line":"     fi  &> /dev/null","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  274","line":"  ) &","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  275","line":"}"},
{"lineNum":"  276","line":""},
{"lineNum":"  277","line":"bats_abort_timeout_countdown() {"},
{"lineNum":"  278","line":"  # kill the countdown process, don\'t care if its still there"},
{"lineNum":"  279","line":"  kill -ABRT \"$1\" &>/dev/null || true","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  280","line":"}"},
{"lineNum":"  281","line":""},
{"lineNum":"  282","line":"get_mills_since_epoch() {"},
{"lineNum":"  283","line":"  local ms_since_epoch","class":"lineCov","hits":"70","order":"432","possible_hits":"0",},
{"lineNum":"  284","line":"  ms_since_epoch=$(date +%s%N)","class":"lineCov","hits":"140","order":"433","possible_hits":"0",},
{"lineNum":"  285","line":"  if [[ \"$ms_since_epoch\" == *N || \"${#ms_since_epoch}\" -lt 19 ]]; then","class":"lineCov","hits":"105","order":"434","possible_hits":"0",},
{"lineNum":"  286","line":"        ms_since_epoch=$(( $(date +%s) * 1000 ))","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  287","line":"  else"},
{"lineNum":"  288","line":"        ms_since_epoch=$(( ms_since_epoch / 1000000 ))","class":"lineCov","hits":"70","order":"435","possible_hits":"0",},
{"lineNum":"  289","line":"  fi"},
{"lineNum":"  290","line":""},
{"lineNum":"  291","line":"  printf \"%d\\n\" \"$ms_since_epoch\"","class":"lineCov","hits":"70","order":"436","possible_hits":"0",},
{"lineNum":"  292","line":"}"},
{"lineNum":"  293","line":""},
{"lineNum":"  294","line":"bats_perform_test() {"},
{"lineNum":"  295","line":"  if ! declare -F \"$BATS_TEST_NAME\" &>/dev/null; then","class":"lineCov","hits":"35","order":"422","possible_hits":"0",},
{"lineNum":"  296","line":"    local quoted_test_name","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  297","line":"    bats_quote_code quoted_test_name \"$BATS_TEST_NAME\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  298","line":"    printf \"bats: unknown test name %s\\n\" \"$quoted_test_name\" >&2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  299","line":"    exit 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  300","line":"  fi"},
{"lineNum":"  301","line":""},
{"lineNum":"  302","line":"  local BATS_killer_pid=\'\'","class":"lineCov","hits":"35","order":"423","possible_hits":"0",},
{"lineNum":"  303","line":"  if [[ -n \"${BATS_TEST_TIMEOUT:-}\" ]]; then","class":"lineCov","hits":"35","order":"424","possible_hits":"0",},
{"lineNum":"  304","line":"    bats_start_timeout_countdown \"$BATS_TEST_TIMEOUT\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  305","line":"    BATS_killer_pid=$!","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  306","line":"  fi"},
{"lineNum":"  307","line":"  BATS_TEST_COMPLETED=","class":"lineCov","hits":"35","order":"425","possible_hits":"0",},
{"lineNum":"  308","line":"  BATS_TEST_SKIPPED=","class":"lineCov","hits":"35","order":"426","possible_hits":"0",},
{"lineNum":"  309","line":"  BATS_TEARDOWN_COMPLETED=","class":"lineCov","hits":"35","order":"427","possible_hits":"0",},
{"lineNum":"  310","line":"  BATS_ERROR_STATUS=","class":"lineCov","hits":"35","order":"428","possible_hits":"0",},
{"lineNum":"  311","line":"  bats_setup_tracing","class":"lineCov","hits":"35","order":"429","possible_hits":"0",},
{"lineNum":"  312","line":"  # use parameter to mark this call as trap call"},
{"lineNum":"  313","line":"  # shellcheck disable=SC2064"},
{"lineNum":"  314","line":"  trap \"bats_teardown_trap as-exit-trap $BATS_killer_pid\" EXIT","class":"lineCov","hits":"70","order":"430","possible_hits":"0",},
{"lineNum":"  315","line":""},
{"lineNum":"  316","line":"  BATS_TEST_START_TIME=$(get_mills_since_epoch)","class":"lineCov","hits":"140","order":"431","possible_hits":"0",},
{"lineNum":"  317","line":"  \"$BATS_TEST_NAME\" >>\"$BATS_OUT\" 2>&1 4>&1","class":"lineCov","hits":"70","order":"437","possible_hits":"0",},
{"lineNum":"  318","line":""},
{"lineNum":"  319","line":"  BATS_TEST_COMPLETED=1","class":"lineCov","hits":"32","order":"445","possible_hits":"0",},
{"lineNum":"  320","line":"  # shellcheck disable=SC2064"},
{"lineNum":"  321","line":"  trap \"bats_exit_trap $BATS_killer_pid\" EXIT","class":"lineCov","hits":"32","order":"446","possible_hits":"0",},
{"lineNum":"  322","line":"  bats_teardown_trap \"\" \"$BATS_killer_pid\" # pass empty parameter to signify call outside trap","class":"lineCov","hits":"32","order":"447","possible_hits":"0",},
{"lineNum":"  323","line":"}"},
{"lineNum":"  324","line":""},
{"lineNum":"  325","line":"trap bats_interrupt_trap INT","class":"lineCov","hits":"35","order":"408","possible_hits":"0",},
{"lineNum":"  326","line":""},
{"lineNum":"  327","line":"# shellcheck source=lib/bats-core/preprocessing.bash"},
{"lineNum":"  328","line":"source \"$BATS_ROOT/lib/bats-core/preprocessing.bash\"","class":"lineCov","hits":"35","order":"409","possible_hits":"0",},
{"lineNum":"  329","line":""},
{"lineNum":"  330","line":"exec 3<&1","class":"lineCov","hits":"35","order":"410","possible_hits":"0",},
{"lineNum":"  331","line":""},
{"lineNum":"  332","line":"bats_create_test_tmpdirs","class":"lineCov","hits":"35","order":"411","possible_hits":"0",},
{"lineNum":"  333","line":"# Run the given test."},
{"lineNum":"  334","line":"bats_evaluate_preprocessed_source","class":"lineCov","hits":"35","order":"418","possible_hits":"0",},
{"lineNum":"  335","line":"bats_perform_test","class":"lineCov","hits":"35","order":"421","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "bats", "date" : "2022-10-19 20:15:42", "instrumented" : 177, "covered" : 95,};
var merged_data = [];
