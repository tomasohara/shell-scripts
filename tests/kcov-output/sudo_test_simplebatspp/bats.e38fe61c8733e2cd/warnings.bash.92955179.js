var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":"# shellcheck source=lib/bats-core/tracing.bash"},
{"lineNum":"    4","line":"source \"$BATS_ROOT/lib/bats-core/tracing.bash\"","class":"lineCov","hits":"7","order":"319","possible_hits":"0",},
{"lineNum":"    5","line":""},
{"lineNum":"    6","line":"# generate a warning report for the parent call\'s call site"},
{"lineNum":"    7","line":"bats_generate_warning() { # <warning number> [--no-stacktrace] [<printf args for warning string>...]"},
{"lineNum":"    8","line":"  local warning_number=\"${1-}\" padding=\"00\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"    9","line":"  shift","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   10","line":"  local no_stacktrace=","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   11","line":"  if [[ ${1-} == --no-stacktrace ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   12","line":"    no_stacktrace=1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   13","line":"    shift","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   14","line":"  fi"},
{"lineNum":"   15","line":"  if [[ $warning_number =~ [0-9]+ ]] && ((warning_number < ${#BATS_WARNING_SHORT_DESCS[@]})); then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   16","line":"    {"},
{"lineNum":"   17","line":"      printf \"BW%s: ${BATS_WARNING_SHORT_DESCS[$warning_number]}\\n\" \"${padding:${#warning_number}}${warning_number}\" \"$@\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   18","line":"      if [[ -z \"$no_stacktrace\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   19","line":"        bats_capture_stack_trace","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   20","line":"        BATS_STACK_TRACE_PREFIX=\'      \' bats_print_stack_trace \"${BATS_DEBUG_LAST_STACK_TRACE[@]}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   21","line":"      fi"},
{"lineNum":"   22","line":"    } >>\"$BATS_WARNING_FILE\" 2>&3","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   23","line":"  else"},
{"lineNum":"   24","line":"    printf \"Invalid Bats warning number \'%s\'. It must be an integer between 1 and %d.\" \"$warning_number\" \"$((${#BATS_WARNING_SHORT_DESCS[@]} - 1))\" >&2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   25","line":"    exit 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   26","line":"  fi"},
{"lineNum":"   27","line":"}"},
{"lineNum":"   28","line":""},
{"lineNum":"   29","line":"# generate a warning if the BATS_GUARANTEED_MINIMUM_VERSION is not high enough"},
{"lineNum":"   30","line":"bats_warn_minimum_guaranteed_version() { # <feature> <minimum required version>"},
{"lineNum":"   31","line":"  if bats_version_lt \"$BATS_GUARANTEED_MINIMUM_VERSION\" \"$2\"; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   32","line":"    bats_generate_warning 2 \"$1\" \"$2\" \"$2\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   33","line":"  fi"},
{"lineNum":"   34","line":"}"},
{"lineNum":"   35","line":""},
{"lineNum":"   36","line":"# put after functions to avoid line changes in tests when new ones get added"},
{"lineNum":"   37","line":"BATS_WARNING_SHORT_DESCS=(","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   38","line":"  # to start with 1"},
{"lineNum":"   39","line":"  \'PADDING\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   40","line":"  # see issue #578 for context"},
{"lineNum":"   41","line":"  \"\\`run\\`\'s command \\`%s\\` exited with code 127, indicating \'Command not found\'. Use run\'s return code checks, e.g. \\`run -127\\`, to fix this message.\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   42","line":"  \"%s requires at least BATS_VERSION=%s. Use \\`bats_require_minimum_version %s\\` to fix this message.\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   43","line":"  \"\\`setup_suite\\` is visible to test file \'%s\', but was not executed. It belongs into \'setup_suite.bash\' to be picked up automatically.\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   44","line":")","class":"lineCov","hits":"7","order":"320","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "bats", "date" : "2023-04-09 21:57:31", "instrumented" : 23, "covered" : 2,};
var merged_data = [];
