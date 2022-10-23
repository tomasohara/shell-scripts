var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":"set -e","class":"lineCov","hits":"1","order":"90","possible_hits":"0",},
{"lineNum":"    3","line":""},
{"lineNum":"    4","line":"count_only_flag=\'\'","class":"lineCov","hits":"1","order":"91","possible_hits":"0",},
{"lineNum":"    5","line":"filter=\'\'","class":"lineCov","hits":"1","order":"92","possible_hits":"0",},
{"lineNum":"    6","line":"num_jobs=${BATS_NUMBER_OF_PARALLEL_JOBS:-1}","class":"lineCov","hits":"1","order":"93","possible_hits":"0",},
{"lineNum":"    7","line":"bats_no_parallelize_across_files=${BATS_NO_PARALLELIZE_ACROSS_FILES-}","class":"lineCov","hits":"1","order":"94","possible_hits":"0",},
{"lineNum":"    8","line":"bats_no_parallelize_within_files=","class":"lineCov","hits":"1","order":"95","possible_hits":"0",},
{"lineNum":"    9","line":"filter_status=\'\'","class":"lineCov","hits":"1","order":"96","possible_hits":"0",},
{"lineNum":"   10","line":"filter_tags_list=()"},
{"lineNum":"   11","line":"flags=(\'--dummy-flag\') # add a dummy flag to prevent unset variable errors on empty array expansion in old bash versions","class":"lineCov","hits":"1","order":"97","possible_hits":"0",},
{"lineNum":"   12","line":"setup_suite_file=\'\'","class":"lineCov","hits":"1","order":"98","possible_hits":"0",},
{"lineNum":"   13","line":"BATS_TRACE_LEVEL=\"${BATS_TRACE_LEVEL:-0}\"","class":"lineCov","hits":"1","order":"99","possible_hits":"0",},
{"lineNum":"   14","line":"BATS_SHOW_OUTPUT_OF_SUCCEEDING_TESTS=","class":"lineCov","hits":"1","order":"100","possible_hits":"0",},
{"lineNum":"   15","line":""},
{"lineNum":"   16","line":"abort() {"},
{"lineNum":"   17","line":"  printf \'Error: %s\\n\' \"$1\" >&2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   18","line":"  exit 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   19","line":"}"},
{"lineNum":"   20","line":""},
{"lineNum":"   21","line":"# shellcheck source=lib/bats-core/common.bash disable=SC2153"},
{"lineNum":"   22","line":"source \"$BATS_ROOT/lib/bats-core/common.bash\"","class":"lineCov","hits":"1","order":"101","possible_hits":"0",},
{"lineNum":"   23","line":""},
{"lineNum":"   24","line":"while [[ \"$#\" -ne 0 ]]; do","class":"lineCov","hits":"2","order":"102","possible_hits":"0",},
{"lineNum":"   25","line":"  case \"$1\" in","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   26","line":"  -c)"},
{"lineNum":"   27","line":"    count_only_flag=1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   28","line":"    ;;"},
{"lineNum":"   29","line":"  -f)"},
{"lineNum":"   30","line":"    shift","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   31","line":"    filter=\"$1\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   32","line":"    ;;"},
{"lineNum":"   33","line":"  -j)"},
{"lineNum":"   34","line":"    shift","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   35","line":"    num_jobs=\"$1\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   36","line":"    flags+=(\'-j\' \"$num_jobs\")","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   37","line":"    ;;"},
{"lineNum":"   38","line":"  -T)"},
{"lineNum":"   39","line":"    flags+=(\'-T\')","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   40","line":"    ;;"},
{"lineNum":"   41","line":"  -x)"},
{"lineNum":"   42","line":"    flags+=(\'-x\')","class":"lineCov","hits":"2","order":"103","possible_hits":"0",},
{"lineNum":"   43","line":"    ;;"},
{"lineNum":"   44","line":"  --no-parallelize-across-files)"},
{"lineNum":"   45","line":"    bats_no_parallelize_across_files=1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   46","line":"    ;;"},
{"lineNum":"   47","line":"  --no-parallelize-within-files)"},
{"lineNum":"   48","line":"    bats_no_parallelize_within_files=1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   49","line":"    flags+=(\"--no-parallelize-within-files\")","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   50","line":"    ;;"},
{"lineNum":"   51","line":"  --filter-status)"},
{"lineNum":"   52","line":"    shift","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   53","line":"    filter_status=\"$1\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   54","line":"    ;;"},
{"lineNum":"   55","line":"  --filter-tags)"},
{"lineNum":"   56","line":"    shift","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   57","line":"    IFS=, read -ra tags <<<\"$1\" || true","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   58","line":"    if (( ${#tags[@]} > 0 )); then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   59","line":"      for (( i = 0; i < ${#tags[@]}; ++i )); do","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   60","line":"        bats_trim \"tags[$i]\" \"${tags[$i]}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   61","line":"      done"},
{"lineNum":"   62","line":"      bats_sort sorted_tags \"${tags[@]}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   63","line":"      IFS=, filter_tags_list+=(\"${sorted_tags[*]}\")","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   64","line":"    else"},
{"lineNum":"   65","line":"      filter_tags_list+=(\"\")","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   66","line":"    fi"},
{"lineNum":"   67","line":"    ;;"},
{"lineNum":"   68","line":"  --dummy-flag)"},
{"lineNum":"   69","line":"    ;;"},
{"lineNum":"   70","line":"  --trace)"},
{"lineNum":"   71","line":"    flags+=(\'--trace\')","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   72","line":"    (( ++BATS_TRACE_LEVEL )) # avoid returning 0","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   73","line":"    ;;"},
{"lineNum":"   74","line":"  --print-output-on-failure)"},
{"lineNum":"   75","line":"    flags+=(--print-output-on-failure)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   76","line":"    ;;"},
{"lineNum":"   77","line":"  --show-output-of-passing-tests)"},
{"lineNum":"   78","line":"    flags+=(--show-output-of-passing-tests)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   79","line":"    BATS_SHOW_OUTPUT_OF_SUCCEEDING_TESTS=1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   80","line":"    ;;"},
{"lineNum":"   81","line":"  --verbose-run)"},
{"lineNum":"   82","line":"    flags+=(--verbose-run)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   83","line":"    ;;"},
{"lineNum":"   84","line":"  --gather-test-outputs-in)"},
{"lineNum":"   85","line":"    shift","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   86","line":"    flags+=(--gather-test-outputs-in \"$1\")","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   87","line":"    ;;"},
{"lineNum":"   88","line":"  --setup-suite-file)"},
{"lineNum":"   89","line":"    shift","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   90","line":"    setup_suite_file=\"$1\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   91","line":"    ;;"},
{"lineNum":"   92","line":"  *)"},
{"lineNum":"   93","line":"    break","class":"lineCov","hits":"1","order":"105","possible_hits":"0",},
{"lineNum":"   94","line":"    ;;"},
{"lineNum":"   95","line":"  esac"},
{"lineNum":"   96","line":"  shift","class":"lineCov","hits":"1","order":"104","possible_hits":"0",},
{"lineNum":"   97","line":"done"},
{"lineNum":"   98","line":""},
{"lineNum":"   99","line":"if [[ \"$num_jobs\" != 1 ]]; then","class":"lineCov","hits":"1","order":"106","possible_hits":"0",},
{"lineNum":"  100","line":"  if ! type -p parallel >/dev/null && [[ -z \"$bats_no_parallelize_across_files\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  101","line":"    abort \"Cannot execute \\\"${num_jobs}\\\" jobs without GNU parallel\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  102","line":"    exit 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  103","line":"  fi"},
{"lineNum":"  104","line":"  # shellcheck source=lib/bats-core/semaphore.bash"},
{"lineNum":"  105","line":"  source \"${BATS_ROOT}/lib/bats-core/semaphore.bash\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  106","line":"  bats_semaphore_setup","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  107","line":"fi"},
{"lineNum":"  108","line":""},
{"lineNum":"  109","line":"# create a file that contains all (filtered) tests to run from all files"},
{"lineNum":"  110","line":"TESTS_LIST_FILE=\"${BATS_RUN_TMPDIR}/test_list_file.txt\"","class":"lineCov","hits":"1","order":"107","possible_hits":"0",},
{"lineNum":"  111","line":""},
{"lineNum":"  112","line":"bats_gather_tests() {"},
{"lineNum":"  113","line":"  local line test_line tags","class":"lineCov","hits":"1","order":"116","possible_hits":"0",},
{"lineNum":"  114","line":"  all_tests=()"},
{"lineNum":"  115","line":"  for filename in \"$@\"; do","class":"lineCov","hits":"3","order":"117","possible_hits":"0",},
{"lineNum":"  116","line":"    if [[ ! -f \"$filename\" ]]; then","class":"lineCov","hits":"1","order":"118","possible_hits":"0",},
{"lineNum":"  117","line":"      abort \"Test file \\\"${filename}\\\" does not exist\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  118","line":"    fi"},
{"lineNum":"  119","line":""},
{"lineNum":"  120","line":"    test_names=()"},
{"lineNum":"  121","line":"    test_dupes=()"},
{"lineNum":"  122","line":"    while read -r line; do","class":"lineCov","hits":"180","order":"122","possible_hits":"0",},
{"lineNum":"  123","line":"      if [[ ! \"$line\" =~ ^bats_test_function\\  ]]; then","class":"lineCov","hits":"179","order":"141","possible_hits":"0",},
{"lineNum":"  124","line":"        continue","class":"lineCov","hits":"168","order":"142","possible_hits":"0",},
{"lineNum":"  125","line":"      fi"},
{"lineNum":"  126","line":"      line=\"${line%$\'\\r\'}\"","class":"lineCov","hits":"11","order":"176","possible_hits":"0",},
{"lineNum":"  127","line":"      line=\"${line#* }\"","class":"lineCov","hits":"11","order":"177","possible_hits":"0",},
{"lineNum":"  128","line":"      TAG_REGEX=\"--tags \'(.*)\' (.*)\"","class":"lineCov","hits":"11","order":"178","possible_hits":"0",},
{"lineNum":"  129","line":"      if [[ \"$line\" =~ $TAG_REGEX ]]; then","class":"lineCov","hits":"11","order":"179","possible_hits":"0",},
{"lineNum":"  130","line":"        IFS=, read -ra tags <<<\"${BASH_REMATCH[1]}\" || true","class":"lineCov","hits":"22","order":"181","possible_hits":"0",},
{"lineNum":"  131","line":"        line=\"${BASH_REMATCH[2]}\"","class":"lineCov","hits":"11","order":"182","possible_hits":"0",},
{"lineNum":"  132","line":"      else"},
{"lineNum":"  133","line":"        tags=()"},
{"lineNum":"  134","line":"      fi"},
{"lineNum":"  135","line":"      if [[ ${#filter_tags_list[@]} -gt 0 ]]; then","class":"lineCov","hits":"11","order":"183","possible_hits":"0",},
{"lineNum":"  136","line":"        local match=","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  137","line":"        for filter_tags in \"${filter_tags_list[@]}\"; do","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  138","line":"            # empty search tags only match empty test tags!"},
{"lineNum":"  139","line":"            if [[ -z \"$filter_tags\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  140","line":"              if [[ ${#tags[@]} -eq 0 ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  141","line":"                match=1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  142","line":"                break","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  143","line":"              fi"},
{"lineNum":"  144","line":"              continue","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  145","line":"            fi"},
{"lineNum":"  146","line":"            local -a positive_filter_tags=() negative_filter_tags=()","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  147","line":"            IFS=, read -ra filter_tags <<< \"$filter_tags\" || true","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  148","line":"            for filter_tag in \"${filter_tags[@]}\"; do","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  149","line":"              if [[ $filter_tag == !* ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  150","line":"                bats_trim filter_tag \"${filter_tag#!}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  151","line":"                negative_filter_tags+=(\"${filter_tag}\")","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  152","line":"              else"},
{"lineNum":"  153","line":"                positive_filter_tags+=(\"${filter_tag}\")","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  154","line":"              fi"},
{"lineNum":"  155","line":"            done"},
{"lineNum":"  156","line":"            if bats_append_arrays_as_args positive_filter_tags -- bats_all_in tags &&","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  157","line":"              ! bats_append_arrays_as_args negative_filter_tags -- bats_any_in tags; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  158","line":"              match=1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  159","line":"            fi"},
{"lineNum":"  160","line":"        done"},
{"lineNum":"  161","line":"        if [[ -z \"$match\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  162","line":"          continue","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  163","line":"        fi"},
{"lineNum":"  164","line":"      fi"},
{"lineNum":"  165","line":"      test_line=$(printf \"%s\\t%s\" \"$filename\" \"$line\")","class":"lineCov","hits":"22","order":"184","possible_hits":"0",},
{"lineNum":"  166","line":"      all_tests+=(\"$test_line\")","class":"lineCov","hits":"11","order":"185","possible_hits":"0",},
{"lineNum":"  167","line":"      printf \"%s\\n\" \"$test_line\" >>\"$TESTS_LIST_FILE\"","class":"lineCov","hits":"11","order":"186","possible_hits":"0",},
{"lineNum":"  168","line":"      # avoid unbound variable errors on empty array expansion with old bash versions"},
{"lineNum":"  169","line":"      if [[ ${#test_names[@]} -gt 0 && \" ${test_names[*]} \" == *\" $line \"* ]]; then","class":"lineCov","hits":"21","order":"187","possible_hits":"0",},
{"lineNum":"  170","line":"        test_dupes+=(\"$line\")","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  171","line":"        continue","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  172","line":"      fi"},
{"lineNum":"  173","line":"      test_names+=(\"$line\")","class":"lineCov","hits":"11","order":"188","possible_hits":"0",},
{"lineNum":"  174","line":"    done < <(BATS_TEST_FILTER=\"$filter\" bats-preprocess \"$filename\")","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  175","line":""},
{"lineNum":"  176","line":"    if [[ \"${#test_dupes[@]}\" -ne 0 ]]; then","class":"lineCov","hits":"1","order":"189","possible_hits":"0",},
{"lineNum":"  177","line":"      abort \"Duplicate test name(s) in file \\\"${filename}\\\": ${test_dupes[*]}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  178","line":"    fi"},
{"lineNum":"  179","line":"  done"},
{"lineNum":"  180","line":""},
{"lineNum":"  181","line":"  test_count=\"${#all_tests[@]}\"","class":"lineCov","hits":"1","order":"190","possible_hits":"0",},
{"lineNum":"  182","line":"}"},
{"lineNum":"  183","line":""},
{"lineNum":"  184","line":"TEST_ROOT=${1-}","class":"lineCov","hits":"1","order":"108","possible_hits":"0",},
{"lineNum":"  185","line":"TEST_ROOT=${TEST_ROOT%/*}","class":"lineCov","hits":"1","order":"109","possible_hits":"0",},
{"lineNum":"  186","line":"BATS_RUN_LOGS_DIRECTORY=\"$TEST_ROOT/.bats/run-logs\"","class":"lineCov","hits":"1","order":"110","possible_hits":"0",},
{"lineNum":"  187","line":"if [[ ! -d \"$BATS_RUN_LOGS_DIRECTORY\" ]]; then","class":"lineCov","hits":"1","order":"111","possible_hits":"0",},
{"lineNum":"  188","line":"  if [[ -n \"$filter_status\" ]]; then","class":"lineCov","hits":"1","order":"112","possible_hits":"0",},
{"lineNum":"  189","line":"    printf \"Error: --filter-status needs \'%s/\' to save failed tests. Please create this folder, add it to .gitignore and try again.\\n\" \"$BATS_RUN_LOGS_DIRECTORY\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  190","line":"    exit 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  191","line":"  else"},
{"lineNum":"  192","line":"    BATS_RUN_LOGS_DIRECTORY=","class":"lineCov","hits":"1","order":"113","possible_hits":"0",},
{"lineNum":"  193","line":"  fi"},
{"lineNum":"  194","line":"  # discard via sink instead of having a conditional later"},
{"lineNum":"  195","line":"  export BATS_RUNLOG_FILE=\'/dev/null\'","class":"lineCov","hits":"2","order":"114","possible_hits":"0",},
{"lineNum":"  196","line":"else"},
{"lineNum":"  197","line":"  # use UTC (-u) to avoid problems with TZ changes"},
{"lineNum":"  198","line":"  BATS_RUNLOG_DATE=$(date -u \'+%Y-%m-%d %H:%M:%S UTC\')","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  199","line":"  export BATS_RUNLOG_FILE=\"$BATS_RUN_LOGS_DIRECTORY/${BATS_RUNLOG_DATE}.log\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  200","line":"fi"},
{"lineNum":"  201","line":""},
{"lineNum":"  202","line":"bats_gather_tests \"$@\"","class":"lineCov","hits":"1","order":"115","possible_hits":"0",},
{"lineNum":"  203","line":""},
{"lineNum":"  204","line":"if [[ -n \"$filter_status\" ]]; then","class":"lineCov","hits":"1","order":"191","possible_hits":"0",},
{"lineNum":"  205","line":"  case \"$filter_status\" in","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  206","line":"    failed)"},
{"lineNum":"  207","line":"      bats_filter_test_by_status() { # <line>"},
{"lineNum":"  208","line":"        ! bats_binary_search \"$1\" \"passed_tests\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  209","line":"      }"},
{"lineNum":"  210","line":"    ;;"},
{"lineNum":"  211","line":"    passed)"},
{"lineNum":"  212","line":"      bats_filter_test_by_status() {"},
{"lineNum":"  213","line":"        ! bats_binary_search \"$1\" \"failed_tests\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  214","line":"      }"},
{"lineNum":"  215","line":"    ;;"},
{"lineNum":"  216","line":"    missed)"},
{"lineNum":"  217","line":"      bats_filter_test_by_status() {"},
{"lineNum":"  218","line":"        ! bats_binary_search \"$1\" \"failed_tests\" && ! bats_binary_search \"$1\" \"passed_tests\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  219","line":"      }"},
{"lineNum":"  220","line":"    ;;"},
{"lineNum":"  221","line":"    *)"},
{"lineNum":"  222","line":"      printf \"Error: Unknown value \'%s\' for --filter-status. Valid values are \'failed\' and \'missed\'.\\n\" \"$filter_status\">&2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  223","line":"      exit 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  224","line":"    ;;"},
{"lineNum":"  225","line":"  esac"},
{"lineNum":"  226","line":""},
{"lineNum":"  227","line":"  if IFS=\'\' read -d $\'\\n\' -r BATS_PREVIOUS_RUNLOG_FILE < <(ls -1r \"$BATS_RUN_LOGS_DIRECTORY\"); then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  228","line":"    BATS_PREVIOUS_RUNLOG_FILE=\"$BATS_RUN_LOGS_DIRECTORY/$BATS_PREVIOUS_RUNLOG_FILE\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  229","line":"    if [[ $BATS_PREVIOUS_RUNLOG_FILE == \"$BATS_RUNLOG_FILE\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  230","line":"      count=$(find \"$BATS_RUN_LOGS_DIRECTORY\" -name \"$BATS_RUNLOG_DATE*\" | wc -l)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  231","line":"      BATS_RUNLOG_FILE=\"$BATS_RUN_LOGS_DIRECTORY/${BATS_RUNLOG_DATE}-$count.log\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  232","line":"    fi"},
{"lineNum":"  233","line":"    failed_tests=()"},
{"lineNum":"  234","line":"    passed_tests=()"},
{"lineNum":"  235","line":"    # store tests that were already filtered out in the last run for the same filter reason"},
{"lineNum":"  236","line":"    last_filtered_tests=()"},
{"lineNum":"  237","line":"    i=0","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  238","line":"    while read -rd $\'\\n\' line; do","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  239","line":"      ((++i))"},
{"lineNum":"  240","line":"      case \"$line\" in","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  241","line":"        \"passed \"*)"},
{"lineNum":"  242","line":"          passed_tests+=(\"${line#passed }\")","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  243","line":"        ;;"},
{"lineNum":"  244","line":"        \"failed \"*)"},
{"lineNum":"  245","line":"          failed_tests+=(\"${line#failed }\")","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  246","line":"        ;;"},
{"lineNum":"  247","line":"        \"status-filtered $filter_status\"*) # pick up tests that were filtered in the last round for the same status","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  248","line":"          last_filtered_tests+=(\"${line#status-filtered \"$filter_status\" }\")","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  249","line":"        ;;"},
{"lineNum":"  250","line":"        \"status-filtered \"*) # ignore other status-filtered lines","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  251","line":"        ;;"},
{"lineNum":"  252","line":"        \"#\"*) # allow for comments","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  253","line":"        ;;"},
{"lineNum":"  254","line":"        *)"},
{"lineNum":"  255","line":"          printf \"Error: %s:%d: Invalid format: %s\\n\" \"$BATS_PREVIOUS_RUNLOG_FILE\" \"$i\" \"$line\" >&2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  256","line":"          exit 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  257","line":"        ;;"},
{"lineNum":"  258","line":"      esac"},
{"lineNum":"  259","line":"    done < <(sort \"$BATS_PREVIOUS_RUNLOG_FILE\")","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  260","line":""},
{"lineNum":"  261","line":"    filtered_tests=()"},
{"lineNum":"  262","line":"    for line in \"${all_tests[@]}\"; do","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  263","line":"      if bats_filter_test_by_status \"$line\" && ! bats_binary_search \"$line\" last_filtered_tests; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  264","line":"        printf \"%s\\n\" \"$line\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  265","line":"        filtered_tests+=(\"$line\")","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  266","line":"      else"},
{"lineNum":"  267","line":"        printf \"status-filtered %s %s\\n\" \"$filter_status\" \"$line\" >> \"$BATS_RUNLOG_FILE\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  268","line":"      fi"},
{"lineNum":"  269","line":"    done > \"$TESTS_LIST_FILE\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  270","line":""},
{"lineNum":"  271","line":"    # save filtered tests to exclude them again in next round"},
{"lineNum":"  272","line":"    for test_line in \"${last_filtered_tests[@]}\"; do","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  273","line":"      printf \"status-filtered %s %s\\n\" \"$filter_status\" \"$test_line\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  274","line":"    done >> \"$BATS_RUNLOG_FILE\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  275","line":""},
{"lineNum":"  276","line":"    test_count=\"${#filtered_tests[@]}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  277","line":"    if [[ ${#failed_tests[@]} -eq 0 && ${#filtered_tests[@]} -eq 0 ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  278","line":"      printf \"There where no failed tests in the last recorded run.\\n\" >&2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  279","line":"    fi"},
{"lineNum":"  280","line":"  else"},
{"lineNum":"  281","line":"    printf \"No recording of previous runs found. Running all tests!\\n\" >&2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  282","line":"  fi"},
{"lineNum":"  283","line":"fi"},
{"lineNum":"  284","line":""},
{"lineNum":"  285","line":"if [[ -n \"$count_only_flag\" ]]; then","class":"lineCov","hits":"1","order":"192","possible_hits":"0",},
{"lineNum":"  286","line":"  printf \'%d\\n\' \"${test_count}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  287","line":"  exit","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  288","line":"fi"},
{"lineNum":"  289","line":""},
{"lineNum":"  290","line":"if [[ -n \"$bats_no_parallelize_across_files\" ]] && [[ ! \"$num_jobs\" -gt 1 ]]; then","class":"lineCov","hits":"1","order":"193","possible_hits":"0",},
{"lineNum":"  291","line":"  abort \"The flag --no-parallelize-across-files requires at least --jobs 2\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  292","line":"  exit 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  293","line":"fi"},
{"lineNum":"  294","line":""},
{"lineNum":"  295","line":"if [[ -n \"$bats_no_parallelize_within_files\" ]] && [[ ! \"$num_jobs\" -gt 1 ]]; then","class":"lineCov","hits":"1","order":"194","possible_hits":"0",},
{"lineNum":"  296","line":"  abort \"The flag --no-parallelize-across-files requires at least --jobs 2\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  297","line":"  exit 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  298","line":"fi"},
{"lineNum":"  299","line":""},
{"lineNum":"  300","line":"# only abort on the lowest levels"},
{"lineNum":"  301","line":"trap \'BATS_INTERRUPTED=true\' INT","class":"lineCov","hits":"1","order":"195","possible_hits":"0",},
{"lineNum":"  302","line":""},
{"lineNum":"  303","line":"bats_exec_suite_status=0","class":"lineCov","hits":"1","order":"196","possible_hits":"0",},
{"lineNum":"  304","line":"printf \'1..%d\\n\' \"${test_count}\"","class":"lineCov","hits":"1","order":"197","possible_hits":"0",},
{"lineNum":"  305","line":""},
{"lineNum":"  306","line":"# No point on continuing if there\'s no tests."},
{"lineNum":"  307","line":"if [[ \"${test_count}\" == 0 ]]; then","class":"lineCov","hits":"1","order":"198","possible_hits":"0",},
{"lineNum":"  308","line":"  exit","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  309","line":"fi"},
{"lineNum":"  310","line":""},
{"lineNum":"  311","line":"export BATS_SUITE_TMPDIR=\"${BATS_RUN_TMPDIR}/suite\"","class":"lineCov","hits":"2","order":"200","possible_hits":"0",},
{"lineNum":"  312","line":"if ! mkdir \"$BATS_SUITE_TMPDIR\"; then","class":"lineCov","hits":"1","order":"202","possible_hits":"0",},
{"lineNum":"  313","line":"  printf \'%s\\n\' \"Failed to create BATS_SUITE_TMPDIR\" >&2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  314","line":"  exit 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  315","line":"fi"},
{"lineNum":"  316","line":""},
{"lineNum":"  317","line":"# Deduplicate filenames (without reordering) to avoid running duplicate tests n by n times."},
{"lineNum":"  318","line":"# (see https://github.com/bats-core/bats-core/issues/329)"},
{"lineNum":"  319","line":"# If a file was specified multiple times, we already got it repeatedly in our TESTS_LIST_FILE."},
{"lineNum":"  320","line":"# Thus, it suffices to bats-exec-file it once to run all repeated tests on it."},
{"lineNum":"  321","line":"IFS=$\'\\n\' read -d \'\' -r -a  BATS_UNIQUE_TEST_FILENAMES < <(printf \"%s\\n\" \"$@\"| nl | sort -k 2 | uniq -f 1 | sort -n | cut -f 2-) || true","class":"lineCov","hits":"9","order":"206","possible_hits":"0",},
{"lineNum":"  322","line":""},
{"lineNum":"  323","line":"# shellcheck source=lib/bats-core/tracing.bash"},
{"lineNum":"  324","line":"source \"$BATS_ROOT/lib/bats-core/tracing.bash\"","class":"lineCov","hits":"1","order":"207","possible_hits":"0",},
{"lineNum":"  325","line":"bats_setup_tracing","class":"lineCov","hits":"1","order":"209","possible_hits":"0",},
{"lineNum":"  326","line":""},
{"lineNum":"  327","line":"trap bats_suite_exit_trap EXIT","class":"lineCov","hits":"2","order":"239","possible_hits":"0",},
{"lineNum":"  328","line":""},
{"lineNum":"  329","line":"exec 3<&1","class":"lineCov","hits":"2","order":"240","possible_hits":"0",},
{"lineNum":"  330","line":""},
{"lineNum":"  331","line":"bats_suite_exit_trap() {"},
{"lineNum":"  332","line":"  local print_bats_out=\"${BATS_SHOW_OUTPUT_OF_SUCCEEDING_TESTS}\"","class":"lineCov","hits":"2","order":"646","possible_hits":"0",},
{"lineNum":"  333","line":"  if [[ -z \"${BATS_SETUP_SUITE_COMPLETED}\" || -z \"${BATS_TEARDOWN_SUITE_COMPLETED}\" ]]; then","class":"lineCov","hits":"3","order":"647","possible_hits":"0",},
{"lineNum":"  334","line":"    if [[ -z \"${BATS_SETUP_SUITE_COMPLETED}\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  335","line":"      printf \"not ok 1 setup_suite\\n\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  336","line":"    elif [[ -z \"${BATS_TEARDOWN_SUITE_COMPLETED}\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  337","line":"      printf \"not ok %d teardown_suite\\n\" $((test_count+1))","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  338","line":"    fi"},
{"lineNum":"  339","line":"    local stack_trace","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  340","line":"    bats_get_failure_stack_trace stack_trace","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  341","line":"    bats_print_stack_trace \"${stack_trace[@]}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  342","line":"    bats_print_failed_command \"${stack_trace[@]}\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  343","line":"    print_bats_out=1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  344","line":"    bats_exec_suite_status=1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  345","line":"  fi"},
{"lineNum":"  346","line":""},
{"lineNum":"  347","line":"  if [[ -n \"$print_bats_out\" ]]; then","class":"lineCov","hits":"2","order":"648","possible_hits":"0",},
{"lineNum":"  348","line":"    bats_prefix_lines_for_tap_output < \"$BATS_OUT\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  349","line":"  fi"},
{"lineNum":"  350","line":""},
{"lineNum":"  351","line":"  if [[ ${BATS_INTERRUPTED-NOTSET} != NOTSET ]]; then","class":"lineCov","hits":"2","order":"649","possible_hits":"0",},
{"lineNum":"  352","line":"    printf \"\\n# Received SIGINT, aborting ...\\n\\n\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  353","line":"  fi"},
{"lineNum":"  354","line":""},
{"lineNum":"  355","line":"  if [[ -d \"$BATS_RUN_LOGS_DIRECTORY\" && -n \"${BATS_INTERRUPTED:-}\" ]]; then","class":"lineCov","hits":"2","order":"650","possible_hits":"0",},
{"lineNum":"  356","line":"    # aborting a test run with CTRL+C does not save the runlog file"},
{"lineNum":"  357","line":"    rm \"$BATS_RUNLOG_FILE\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  358","line":"  fi"},
{"lineNum":"  359","line":"  exit \"$bats_exec_suite_status\"","class":"lineCov","hits":"2","order":"651","possible_hits":"0",},
{"lineNum":"  360","line":"} >&3","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  361","line":""},
{"lineNum":"  362","line":"bats_run_teardown_suite() {"},
{"lineNum":"  363","line":"  local bats_teardown_suite_status=0","class":"lineCov","hits":"2","order":"638","possible_hits":"0",},
{"lineNum":"  364","line":"  # avoid being called twice, in case this is not called through bats_teardown_suite_trap"},
{"lineNum":"  365","line":"  # but from the end of file"},
{"lineNum":"  366","line":"  trap bats_suite_exit_trap EXIT","class":"lineCov","hits":"2","order":"639","possible_hits":"0",},
{"lineNum":"  367","line":"  BATS_TEARDOWN_SUITE_COMPLETED=","class":"lineCov","hits":"2","order":"640","possible_hits":"0",},
{"lineNum":"  368","line":"  teardown_suite >>\"$BATS_OUT\" 2>&1 || bats_teardown_suite_status=$?","class":"lineCov","hits":"2","order":"641","possible_hits":"0",},
{"lineNum":"  369","line":"  if (( bats_teardown_suite_status == 0 )); then","class":"lineCov","hits":"2","order":"643","possible_hits":"0",},
{"lineNum":"  370","line":"    BATS_TEARDOWN_SUITE_COMPLETED=1","class":"lineCov","hits":"2","order":"644","possible_hits":"0",},
{"lineNum":"  371","line":"  elif [[ -n \"${BATS_SETUP_SUITE_COMPLETED:-}\" ]]; then","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  372","line":"    BATS_DEBUG_LAST_STACK_TRACE_IS_VALID=1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  373","line":"    BATS_ERROR_STATUS=$bats_teardown_suite_status","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  374","line":"    return $BATS_ERROR_STATUS","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  375","line":"  fi"},
{"lineNum":"  376","line":"}"},
{"lineNum":"  377","line":""},
{"lineNum":"  378","line":"bats_teardown_suite_trap() {"},
{"lineNum":"  379","line":"  bats_run_teardown_suite","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  380","line":"  bats_suite_exit_trap","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  381","line":"}"},
{"lineNum":"  382","line":""},
{"lineNum":"  383","line":"teardown_suite() {"},
{"lineNum":"  384","line":"  :","class":"lineCov","hits":"2","order":"642","possible_hits":"0",},
{"lineNum":"  385","line":"}"},
{"lineNum":"  386","line":""},
{"lineNum":"  387","line":"trap bats_teardown_suite_trap EXIT","class":"lineCov","hits":"2","order":"241","possible_hits":"0",},
{"lineNum":"  388","line":""},
{"lineNum":"  389","line":"BATS_OUT=\"$BATS_RUN_TMPDIR/suite.out\"","class":"lineCov","hits":"2","order":"242","possible_hits":"0",},
{"lineNum":"  390","line":"if [[ -n \"$setup_suite_file\" ]]; then","class":"lineCov","hits":"2","order":"243","possible_hits":"0",},
{"lineNum":"  391","line":"  setup_suite() {"},
{"lineNum":"  392","line":"    printf \"%s does not define \\`setup_suite()\\`\\n\" \"$setup_suite_file\" >&2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  393","line":"    return 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  394","line":"  }"},
{"lineNum":"  395","line":""},
{"lineNum":"  396","line":"  # shellcheck disable=SC2034 # will be used in the sourced file below"},
{"lineNum":"  397","line":"  BATS_TEST_FILENAME=\"$setup_suite_file\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  398","line":"  # shellcheck source=lib/bats-core/test_functions.bash"},
{"lineNum":"  399","line":"  source \"$BATS_ROOT/lib/bats-core/test_functions.bash\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  400","line":""},
{"lineNum":"  401","line":"  # shellcheck disable=SC1090"},
{"lineNum":"  402","line":"  source \"$setup_suite_file\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  403","line":""},
{"lineNum":"  404","line":"  set -eET","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  405","line":"  export BATS_SETUP_SUITE_COMPLETED=","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  406","line":"  setup_suite >>\"$BATS_OUT\" 2>&1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  407","line":"  BATS_SETUP_SUITE_COMPLETED=1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  408","line":"  set +ET","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  409","line":"else"},
{"lineNum":"  410","line":"  # prevent exit trap from printing an error because of incomplete setup_suite,"},
{"lineNum":"  411","line":"  # when there was none to execute"},
{"lineNum":"  412","line":"  BATS_SETUP_SUITE_COMPLETED=1","class":"lineCov","hits":"2","order":"244","possible_hits":"0",},
{"lineNum":"  413","line":"fi"},
{"lineNum":"  414","line":""},
{"lineNum":"  415","line":""},
{"lineNum":"  416","line":"if [[ \"$num_jobs\" -gt 1 ]] && [[ -z \"$bats_no_parallelize_across_files\" ]]; then","class":"lineCov","hits":"2","order":"245","possible_hits":"0",},
{"lineNum":"  417","line":"  # run files in parallel to get the maximum pool of parallel tasks"},
{"lineNum":"  418","line":"  # shellcheck disable=SC2086,SC2068"},
{"lineNum":"  419","line":"  # we need to handle the quoting of ${flags[@]} ourselves,"},
{"lineNum":"  420","line":"  # because parallel can only quote it as one"},
{"lineNum":"  421","line":"  parallel --keep-order --jobs \"$num_jobs\" bats-exec-file \"$(printf \"%q \" \"${flags[@]}\")\" \"{}\" \"$TESTS_LIST_FILE\"  ::: \"${BATS_UNIQUE_TEST_FILENAMES[@]}\" 2>&1 || bats_exec_suite_status=1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  422","line":"else"},
{"lineNum":"  423","line":"  for filename in \"${BATS_UNIQUE_TEST_FILENAMES[@]}\"; do","class":"lineCov","hits":"2","order":"246","possible_hits":"0",},
{"lineNum":"  424","line":"    if [[ \"${BATS_INTERRUPTED-NOTSET}\" != NOTSET ]]; then","class":"lineCov","hits":"2","order":"247","possible_hits":"0",},
{"lineNum":"  425","line":"      bats_exec_suite_status=130 # bash\'s code for SIGINT exits","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  426","line":"      break","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  427","line":"    fi"},
{"lineNum":"  428","line":"    bats-exec-file \"${flags[@]}\" \"$filename\" \"${TESTS_LIST_FILE}\" || bats_exec_suite_status=1","class":"lineCov","hits":"4","order":"248","possible_hits":"0",},
{"lineNum":"  429","line":"  done"},
{"lineNum":"  430","line":"fi"},
{"lineNum":"  431","line":""},
{"lineNum":"  432","line":"set -eET","class":"lineCov","hits":"2","order":"636","possible_hits":"0",},
{"lineNum":"  433","line":"bats_run_teardown_suite","class":"lineCov","hits":"2","order":"637","possible_hits":"0",},
{"lineNum":"  434","line":""},
{"lineNum":"  435","line":"exit \"$bats_exec_suite_status\"","class":"lineCov","hits":"2","order":"645","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "bats", "date" : "2022-10-23 20:32:16", "instrumented" : 229, "covered" : 85,};
var merged_data = [];
