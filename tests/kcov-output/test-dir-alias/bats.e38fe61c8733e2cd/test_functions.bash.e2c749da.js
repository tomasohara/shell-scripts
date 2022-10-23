var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":"BATS_TEST_DIRNAME=\"${BATS_TEST_FILENAME%/*}\"","class":"lineCov","hits":"19","order":"298","possible_hits":"0",},
{"lineNum":"    4","line":"BATS_TEST_NAMES=()"},
{"lineNum":"    5","line":""},
{"lineNum":"    6","line":"# shellcheck source=lib/bats-core/warnings.bash"},
{"lineNum":"    7","line":"source \"$BATS_ROOT/lib/bats-core/warnings.bash\"","class":"lineCov","hits":"19","order":"299","possible_hits":"0",},
{"lineNum":"    8","line":""},
{"lineNum":"    9","line":"# find_in_bats_lib_path echoes the first recognized load path to"},
{"lineNum":"   10","line":"# a library in BATS_LIB_PATH or relative to BATS_TEST_DIRNAME."},
{"lineNum":"   11","line":"#"},
{"lineNum":"   12","line":"# Libraries relative to BATS_TEST_DIRNAME take precedence over"},
{"lineNum":"   13","line":"# BATS_LIB_PATH."},
{"lineNum":"   14","line":"#"},
{"lineNum":"   15","line":"# Library load paths are recognized using find_library_load_path."},
{"lineNum":"   16","line":"#"},
{"lineNum":"   17","line":"# If no library is found find_in_bats_lib_path returns 1."},
{"lineNum":"   18","line":"find_in_bats_lib_path() { # <return-var> <library-name>"},
{"lineNum":"   19","line":"  local return_var=\"${1:?}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   20","line":"  local library_name=\"${2:?}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   21","line":""},
{"lineNum":"   22","line":"  local -a bats_lib_paths","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   23","line":"  IFS=: read -ra bats_lib_paths <<< \"$BATS_LIB_PATH\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   24","line":""},
{"lineNum":"   25","line":"  for path in \"${bats_lib_paths[@]}\"; do","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   26","line":"    if [[ -f \"$path/$library_name\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   27","line":"      printf -v \"$return_var\" \"%s\" \"$path/$library_name\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   28","line":"      # A library load path was found, return"},
{"lineNum":"   29","line":"      return 0","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   30","line":"    elif [[ -f \"$path/$library_name/load.bash\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   31","line":"      printf -v \"$return_var\" \"%s\" \"$path/$library_name/load.bash\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   32","line":"      # A library load path was found, return"},
{"lineNum":"   33","line":"      return 0","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   34","line":"    fi"},
{"lineNum":"   35","line":"  done"},
{"lineNum":"   36","line":""},
{"lineNum":"   37","line":"  return 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   38","line":"}"},
{"lineNum":"   39","line":""},
{"lineNum":"   40","line":"# bats_internal_load expects an absolute path that is a library load path."},
{"lineNum":"   41","line":"#"},
{"lineNum":"   42","line":"# If the library load path points to a file (a library loader) it is"},
{"lineNum":"   43","line":"# sourced."},
{"lineNum":"   44","line":"#"},
{"lineNum":"   45","line":"# If it points to a directory all files ending in .bash inside of the"},
{"lineNum":"   46","line":"# directory are sourced."},
{"lineNum":"   47","line":"#"},
{"lineNum":"   48","line":"# If the sourcing of the library loader or of a file in a library"},
{"lineNum":"   49","line":"# directory fails bats_internal_load prints an error message and returns 1."},
{"lineNum":"   50","line":"#"},
{"lineNum":"   51","line":"# If the passed library load path is not absolute or is not a valid file"},
{"lineNum":"   52","line":"# or directory bats_internal_load prints an error message and returns 1."},
{"lineNum":"   53","line":"bats_internal_load() {"},
{"lineNum":"   54","line":"  local library_load_path=\"${1:?}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   55","line":""},
{"lineNum":"   56","line":"  if [[ \"${library_load_path:0:1}\" != / ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   57","line":"    printf \"Passed library load path is not an absolute path: %s\\n\" \"$library_load_path\" >&2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   58","line":"    return 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   59","line":"  fi"},
{"lineNum":"   60","line":""},
{"lineNum":"   61","line":"  # library_load_path is a library loader"},
{"lineNum":"   62","line":"  if [[ -f \"$library_load_path\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   63","line":"      # shellcheck disable=SC1090"},
{"lineNum":"   64","line":"      if ! source \"$library_load_path\"; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   65","line":"          printf \"Error while sourcing library loader at \'%s\'\\n\" \"$library_load_path\" >&2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   66","line":"          return 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   67","line":"      fi"},
{"lineNum":"   68","line":"      return 0","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   69","line":"  fi"},
{"lineNum":"   70","line":""},
{"lineNum":"   71","line":"  printf \"Passed library load path is neither a library loader nor library directory: %s\\n\" \"$library_load_path\" >&2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   72","line":"  return 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   73","line":"}"},
{"lineNum":"   74","line":""},
{"lineNum":"   75","line":"# bats_load_safe accepts an argument called \'slug\' and attempts to find and"},
{"lineNum":"   76","line":"# source a library based on the slug."},
{"lineNum":"   77","line":"#"},
{"lineNum":"   78","line":"# A slug can be an absolute path, a library name or a relative path."},
{"lineNum":"   79","line":"#"},
{"lineNum":"   80","line":"# If the slug is an absolute path bats_load_safe attempts to find the library"},
{"lineNum":"   81","line":"# load path using find_library_load_path."},
{"lineNum":"   82","line":"# What is considered a library load path is documented in the"},
{"lineNum":"   83","line":"# documentation for find_library_load_path."},
{"lineNum":"   84","line":"#"},
{"lineNum":"   85","line":"# If the slug is not an absolute path it is considered a library name or"},
{"lineNum":"   86","line":"# relative path. bats_load_safe attempts to find the library load path using"},
{"lineNum":"   87","line":"# find_in_bats_lib_path."},
{"lineNum":"   88","line":"#"},
{"lineNum":"   89","line":"# If bats_load_safe can find a library load path it is passed to bats_internal_load."},
{"lineNum":"   90","line":"# If bats_internal_load fails bats_load_safe returns 1."},
{"lineNum":"   91","line":"#"},
{"lineNum":"   92","line":"# If no library load path can be found bats_load_safe prints an error message"},
{"lineNum":"   93","line":"# and returns 1."},
{"lineNum":"   94","line":"bats_load_safe() {"},
{"lineNum":"   95","line":"  local slug=\"${1:?}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   96","line":"  if [[ ${slug:0:1} != / ]]; then # relative paths are relative to BATS_TEST_DIRNAME","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   97","line":"    slug=\"$BATS_TEST_DIRNAME/$slug\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   98","line":"  fi"},
{"lineNum":"   99","line":""},
{"lineNum":"  100","line":"  if [[ -f \"$slug.bash\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  101","line":"    bats_internal_load \"$slug.bash\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  102","line":"    return $?","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  103","line":"  elif [[ -f \"$slug\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  104","line":"    bats_internal_load \"$slug\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  105","line":"    return $?","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  106","line":"  fi"},
{"lineNum":"  107","line":""},
{"lineNum":"  108","line":"  # loading from PATH (retained for backwards compatibility)"},
{"lineNum":"  109","line":"  if [[ ! -f \"$1\" ]] && type -P \"$1\" >/dev/null; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  110","line":"    # shellcheck disable=SC1090"},
{"lineNum":"  111","line":"    source \"$1\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  112","line":"    return $?","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  113","line":"  fi"},
{"lineNum":"  114","line":""},
{"lineNum":"  115","line":"  # No library load path can be found"},
{"lineNum":"  116","line":"  printf \"bats_load_safe: Could not find \'%s\'[.bash]\\n\" \"$slug\" >&2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  117","line":"  return 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  118","line":"}"},
{"lineNum":"  119","line":""},
{"lineNum":"  120","line":"bats_load_library_safe() { # <slug>"},
{"lineNum":"  121","line":"  local slug=\"${1:?}\" library_path","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  122","line":""},
{"lineNum":"  123","line":"  # Check for library load paths in BATS_TEST_DIRNAME and BATS_LIB_PATH"},
{"lineNum":"  124","line":"  if [[ ${slug:0:1} != / ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  125","line":"    if ! find_in_bats_lib_path library_path \"$slug\"; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  126","line":"      printf \"Could not find library \'%s\' relative to test file or in BATS_LIB_PATH\\n\" \"$slug\" >&2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  127","line":"      return 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  128","line":"    fi"},
{"lineNum":"  129","line":"  else"},
{"lineNum":"  130","line":"    # absolute paths are taken as is"},
{"lineNum":"  131","line":"    library_path=\"$slug\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  132","line":"    if [[ ! -f \"$library_path\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  133","line":"      printf \"Could not find library on absolute path \'%s\'\\n\" \"$library_path\" >&2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  134","line":"      return 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  135","line":"    fi"},
{"lineNum":"  136","line":"  fi"},
{"lineNum":"  137","line":""},
{"lineNum":"  138","line":"  bats_internal_load \"$library_path\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  139","line":"  return $?","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  140","line":"}"},
{"lineNum":"  141","line":""},
{"lineNum":"  142","line":"# immediately exit on error, use bats_load_library_safe to catch and handle errors"},
{"lineNum":"  143","line":"bats_load_library() { # <slug>"},
{"lineNum":"  144","line":"  if ! bats_load_library_safe \"$@\"; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  145","line":"    exit 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  146","line":"  fi"},
{"lineNum":"  147","line":"}"},
{"lineNum":"  148","line":""},
{"lineNum":"  149","line":"# load acts like bats_load_safe but exits the shell instead of returning 1."},
{"lineNum":"  150","line":"load() {"},
{"lineNum":"  151","line":"    if ! bats_load_safe \"$@\"; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  152","line":"        exit 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  153","line":"    fi"},
{"lineNum":"  154","line":"}"},
{"lineNum":"  155","line":""},
{"lineNum":"  156","line":"bats_redirect_stderr_into_file() {"},
{"lineNum":"  157","line":"  \"$@\" 2>>\"$bats_run_separate_stderr_file\" # use >> to see collisions\' content","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  158","line":"}"},
{"lineNum":"  159","line":""},
{"lineNum":"  160","line":"bats_merge_stdout_and_stderr() {"},
{"lineNum":"  161","line":"  \"$@\" 2>&1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  162","line":"}"},
{"lineNum":"  163","line":""},
{"lineNum":"  164","line":"# write separate lines from <input-var> into <output-array>"},
{"lineNum":"  165","line":"bats_separate_lines() { # <output-array> <input-var>"},
{"lineNum":"  166","line":"  local output_array_name=\"$1\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  167","line":"  local input_var_name=\"$2\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  168","line":"  if [[ $keep_empty_lines ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  169","line":"    local bats_separate_lines_lines=()","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  170","line":"    if [[ -n \"${!input_var_name}\" ]]; then # avoid getting an empty line for empty input","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  171","line":"      while IFS= read -r line; do","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  172","line":"        bats_separate_lines_lines+=(\"$line\")","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  173","line":"      done <<<\"${!input_var_name}\""},
{"lineNum":"  174","line":"    fi"},
{"lineNum":"  175","line":"    eval \"${output_array_name}=(\\\"\\${bats_separate_lines_lines[@]}\\\")\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  176","line":"  else"},
{"lineNum":"  177","line":"    # shellcheck disable=SC2034,SC2206"},
{"lineNum":"  178","line":"    IFS=$\'\\n\' read -d \'\' -r -a \"$output_array_name\" <<<\"${!input_var_name}\" || true # don\'t fail due to EOF","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  179","line":"  fi"},
{"lineNum":"  180","line":"}"},
{"lineNum":"  181","line":""},
{"lineNum":"  182","line":"run() { # [!|-N] [--keep-empty-lines] [--separate-stderr] [--] <command to run...>"},
{"lineNum":"  183","line":"  # This has to be restored on exit from this function to avoid leaking our trap INT into surrounding code."},
{"lineNum":"  184","line":"  # Non zero exits won\'t restore under the assumption that they will fail the test before it can be aborted,"},
{"lineNum":"  185","line":"  # which allows us to avoid duplicating the restore code on every exit path"},
{"lineNum":"  186","line":"  trap bats_interrupt_trap_in_run INT","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  187","line":"  local expected_rc=","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  188","line":"  local keep_empty_lines=","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  189","line":"  local output_case=merged","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  190","line":"  local has_flags=","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  191","line":"  # parse options starting with -"},
{"lineNum":"  192","line":"  while [[ $# -gt 0 ]] && [[ $1 == -* || $1 == \'!\' ]]; do","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  193","line":"    has_flags=1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  194","line":"    case \"$1\" in","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  195","line":"      \'!\')"},
{"lineNum":"  196","line":"        expected_rc=-1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  197","line":"      ;;"},
{"lineNum":"  198","line":"      -[0-9]*)"},
{"lineNum":"  199","line":"        expected_rc=${1#-}","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  200","line":"        if [[ $expected_rc =~ [^0-9] ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  201","line":"          printf \"Usage error: run: \'-NNN\' requires numeric NNN (got: %s)\\n\" \"$expected_rc\" >&2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  202","line":"          return 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  203","line":"        elif [[ $expected_rc -gt 255 ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  204","line":"          printf \"Usage error: run: \'-NNN\': NNN must be <= 255 (got: %d)\\n\" \"$expected_rc\" >&2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  205","line":"          return 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  206","line":"        fi"},
{"lineNum":"  207","line":"      ;;"},
{"lineNum":"  208","line":"      --keep-empty-lines)"},
{"lineNum":"  209","line":"        keep_empty_lines=1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  210","line":"      ;;"},
{"lineNum":"  211","line":"      --separate-stderr)"},
{"lineNum":"  212","line":"        output_case=\"separate\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  213","line":"      ;;"},
{"lineNum":"  214","line":"      --)"},
{"lineNum":"  215","line":"        shift # eat the -- before breaking away","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  216","line":"        break","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  217","line":"      ;;"},
{"lineNum":"  218","line":"      *)"},
{"lineNum":"  219","line":"        printf \"Usage error: unknown flag \'%s\'\" \"$1\" >&2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  220","line":"        return 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  221","line":"      ;;"},
{"lineNum":"  222","line":"    esac"},
{"lineNum":"  223","line":"    shift","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  224","line":"  done"},
{"lineNum":"  225","line":""},
{"lineNum":"  226","line":"  if [[ -n $has_flags ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  227","line":"    bats_warn_minimum_guaranteed_version \"Using flags on \\`run\\`\" 1.5.0","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  228","line":"  fi"},
{"lineNum":"  229","line":""},
{"lineNum":"  230","line":"  local pre_command=","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  231","line":""},
{"lineNum":"  232","line":"  case \"$output_case\" in","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  233","line":"    merged) # redirects stderr into stdout and fills only $output/$lines","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  234","line":"      pre_command=bats_merge_stdout_and_stderr","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  235","line":"    ;;"},
{"lineNum":"  236","line":"    separate) # splits stderr into own file and fills $stderr/$stderr_lines too","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  237","line":"      local bats_run_separate_stderr_file","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  238","line":"      bats_run_separate_stderr_file=\"$(mktemp \"${BATS_TEST_TMPDIR}/separate-stderr-XXXXXX\")\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  239","line":"      pre_command=bats_redirect_stderr_into_file","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  240","line":"    ;;"},
{"lineNum":"  241","line":"  esac"},
{"lineNum":"  242","line":""},
{"lineNum":"  243","line":"  local origFlags=\"$-\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  244","line":"  set +eET","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  245","line":"  if [[ $keep_empty_lines ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  246","line":"    # \'output\', \'status\', \'lines\' are global variables available to tests."},
{"lineNum":"  247","line":"    # preserve trailing newlines by appending . and removing it later"},
{"lineNum":"  248","line":"    # shellcheck disable=SC2034"},
{"lineNum":"  249","line":"    output=\"$(\"$pre_command\" \"$@\"; status=$?; printf .; exit $status)\" && status=0 || status=$?","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  250","line":"    output=\"${output%.}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  251","line":"  else"},
{"lineNum":"  252","line":"    # \'output\', \'status\', \'lines\' are global variables available to tests."},
{"lineNum":"  253","line":"    # shellcheck disable=SC2034"},
{"lineNum":"  254","line":"    output=\"$(\"$pre_command\" \"$@\")\" && status=0 || status=$?","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  255","line":"  fi"},
{"lineNum":"  256","line":""},
{"lineNum":"  257","line":"  bats_separate_lines lines output","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  258","line":""},
{"lineNum":"  259","line":"  if [[ \"$output_case\" == separate ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  260","line":"      # shellcheck disable=SC2034"},
{"lineNum":"  261","line":"      read -d \'\' -r stderr < \"$bats_run_separate_stderr_file\" || true","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  262","line":"      bats_separate_lines stderr_lines stderr","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  263","line":"  fi"},
{"lineNum":"  264","line":""},
{"lineNum":"  265","line":"  # shellcheck disable=SC2034"},
{"lineNum":"  266","line":"  BATS_RUN_COMMAND=\"${*}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  267","line":"  set \"-$origFlags\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  268","line":""},
{"lineNum":"  269","line":"  if [[ ${BATS_VERBOSE_RUN:-} ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  270","line":"    printf \"%s\\n\" \"$output\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  271","line":"  fi"},
{"lineNum":"  272","line":""},
{"lineNum":"  273","line":""},
{"lineNum":"  274","line":"  if [[ -n \"$expected_rc\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  275","line":"    if [[ \"$expected_rc\" = \"-1\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  276","line":"      if [[ \"$status\" -eq 0 ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  277","line":"        BATS_ERROR_SUFFIX=\", expected nonzero exit code!\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  278","line":"        return 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  279","line":"      fi"},
{"lineNum":"  280","line":"    elif [ \"$status\" -ne \"$expected_rc\" ]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  281","line":"      # shellcheck disable=SC2034"},
{"lineNum":"  282","line":"      BATS_ERROR_SUFFIX=\", expected exit code $expected_rc, got $status\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  283","line":"      return 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  284","line":"    fi"},
{"lineNum":"  285","line":"  elif [[ \"$status\" -eq 127 ]]; then # \"command not found\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  286","line":"    bats_generate_warning 1 \"$BATS_RUN_COMMAND\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  287","line":"  fi"},
{"lineNum":"  288","line":"  # don\'t leak our trap into surrounding code"},
{"lineNum":"  289","line":"  trap bats_interrupt_trap INT","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  290","line":"}"},
{"lineNum":"  291","line":""},
{"lineNum":"  292","line":"setup() {"},
{"lineNum":"  293","line":"  return 0","class":"lineCov","hits":"36","order":"425","possible_hits":"0",},
{"lineNum":"  294","line":"}"},
{"lineNum":"  295","line":""},
{"lineNum":"  296","line":"teardown() {"},
{"lineNum":"  297","line":"  return 0","class":"lineCov","hits":"27","order":"438","possible_hits":"0",},
{"lineNum":"  298","line":"}"},
{"lineNum":"  299","line":""},
{"lineNum":"  300","line":"skip() {"},
{"lineNum":"  301","line":"  # if this is a skip in teardown ..."},
{"lineNum":"  302","line":"  if [[ -n \"${BATS_TEARDOWN_STARTED-}\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  303","line":"    # ... we want to skip the rest of teardown."},
{"lineNum":"  304","line":"    # communicate to bats_exit_trap that the teardown was completed without error"},
{"lineNum":"  305","line":"    # shellcheck disable=SC2034"},
{"lineNum":"  306","line":"    BATS_TEARDOWN_COMPLETED=1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  307","line":"    # if we are already in the exit trap (e.g. due to previous skip) ..."},
{"lineNum":"  308","line":"    if [[ \"$BATS_TEARDOWN_STARTED\" == as-exit-trap ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  309","line":"      # ... we need to do the rest of the tear_down_trap that would otherwise be skipped after the next call to exit"},
{"lineNum":"  310","line":"      bats_exit_trap","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  311","line":"      # and then do the exit (at the end of this function)"},
{"lineNum":"  312","line":"    fi"},
{"lineNum":"  313","line":"    # if we aren\'t in exit trap, the normal exit handling should suffice"},
{"lineNum":"  314","line":"  else"},
{"lineNum":"  315","line":"    # ... this is either skip in test or skip in setup."},
{"lineNum":"  316","line":"    # Following variables are used in bats-exec-test which sources this file"},
{"lineNum":"  317","line":"    # shellcheck disable=SC2034"},
{"lineNum":"  318","line":"    BATS_TEST_SKIPPED=\"${1:-1}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  319","line":"    # shellcheck disable=SC2034"},
{"lineNum":"  320","line":"    BATS_TEST_COMPLETED=1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  321","line":"  fi"},
{"lineNum":"  322","line":"  exit 0","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  323","line":"}"},
{"lineNum":"  324","line":""},
{"lineNum":"  325","line":"bats_test_begin() {"},
{"lineNum":"  326","line":"  BATS_TEST_DESCRIPTION=\"$1\"","class":"lineCov","hits":"36","order":"422","possible_hits":"0",},
{"lineNum":"  327","line":"  if [[ -n \"$BATS_EXTENDED_SYNTAX\" ]]; then","class":"lineCov","hits":"36","order":"423","possible_hits":"0",},
{"lineNum":"  328","line":"    printf \'begin %d %s\\n\' \"$BATS_SUITE_TEST_NUMBER\" \"${BATS_TEST_NAME_PREFIX:-}$BATS_TEST_DESCRIPTION\" >&3","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  329","line":"  fi"},
{"lineNum":"  330","line":"  setup","class":"lineCov","hits":"36","order":"424","possible_hits":"0",},
{"lineNum":"  331","line":"}"},
{"lineNum":"  332","line":""},
{"lineNum":"  333","line":"bats_test_function() {"},
{"lineNum":"  334","line":"  local test_name=\"$1\"","class":"lineCov","hits":"360","order":"332","possible_hits":"0",},
{"lineNum":"  335","line":"  BATS_TEST_NAMES+=(\"$test_name\")","class":"lineCov","hits":"360","order":"333","possible_hits":"0",},
{"lineNum":"  336","line":"}"},
{"lineNum":"  337","line":""},
{"lineNum":"  338","line":"# decides whether a failed test should be run again"},
{"lineNum":"  339","line":"bats_should_retry_test() {"},
{"lineNum":"  340","line":"  # test try number starts at 1"},
{"lineNum":"  341","line":"  # 0 retries means run only first try"},
{"lineNum":"  342","line":"  (( BATS_TEST_TRY_NUMBER <= BATS_TEST_RETRIES ))"},
{"lineNum":"  343","line":"}"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "bats", "date" : "2022-10-23 20:35:15", "instrumented" : 138, "covered" : 9,};
var merged_data = [];
