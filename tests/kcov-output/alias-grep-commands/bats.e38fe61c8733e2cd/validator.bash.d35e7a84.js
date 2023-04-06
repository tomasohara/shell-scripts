var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":"bats_test_count_validator() {"},
{"lineNum":"    4","line":"  trap \'\' INT # continue forwarding","class":"lineCov","hits":"1","order":"95","possible_hits":"0",},
{"lineNum":"    5","line":"  header_pattern=\'[0-9]+\\.\\.[0-9]+\'","class":"lineCov","hits":"1","order":"96","possible_hits":"0",},
{"lineNum":"    6","line":"  IFS= read -r header","class":"lineCov","hits":"2","order":"97","possible_hits":"0",},
{"lineNum":"    7","line":"  # repeat the header"},
{"lineNum":"    8","line":"  printf \"%s\\n\" \"$header\"","class":"lineCov","hits":"1","order":"220","possible_hits":"0",},
{"lineNum":"    9","line":""},
{"lineNum":"   10","line":"  # if we detect a TAP plan"},
{"lineNum":"   11","line":"  if [[ \"$header\" =~ $header_pattern ]]; then","class":"lineCov","hits":"1","order":"221","possible_hits":"0",},
{"lineNum":"   12","line":"    # extract the number of tests ..."},
{"lineNum":"   13","line":"    local expected_number_of_tests=\"${header:3}\"","class":"lineCov","hits":"1","order":"222","possible_hits":"0",},
{"lineNum":"   14","line":"    # ... count the actual number of [not ] oks..."},
{"lineNum":"   15","line":"    local actual_number_of_tests=0","class":"lineCov","hits":"1","order":"223","possible_hits":"0",},
{"lineNum":"   16","line":"    while IFS= read -r line; do","class":"lineCov","hits":"140","order":"224","possible_hits":"0",},
{"lineNum":"   17","line":"      # forward line"},
{"lineNum":"   18","line":"      printf \"%s\\n\" \"$line\"","class":"lineCov","hits":"69","order":"470","possible_hits":"0",},
{"lineNum":"   19","line":"      case \"$line\" in","class":"lineCov","hits":"69","order":"472","possible_hits":"0",},
{"lineNum":"   20","line":"      \'ok \'*)"},
{"lineNum":"   21","line":"        ((++actual_number_of_tests))"},
{"lineNum":"   22","line":"        ;;"},
{"lineNum":"   23","line":"      \'not ok\'*)"},
{"lineNum":"   24","line":"        ((++actual_number_of_tests))"},
{"lineNum":"   25","line":"        ;;"},
{"lineNum":"   26","line":"      esac"},
{"lineNum":"   27","line":"    done"},
{"lineNum":"   28","line":"    # ... and error if they are not the same"},
{"lineNum":"   29","line":"    if [[ \"${actual_number_of_tests}\" != \"${expected_number_of_tests}\" ]]; then","class":"lineCov","hits":"1","order":"700","possible_hits":"0",},
{"lineNum":"   30","line":"      printf \'# bats warning: Executed %s instead of expected %s tests\\n\' \"$actual_number_of_tests\" \"$expected_number_of_tests\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   31","line":"      return 1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   32","line":"    fi"},
{"lineNum":"   33","line":"  else"},
{"lineNum":"   34","line":"    # forward output unchanged"},
{"lineNum":"   35","line":"    cat","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   36","line":"  fi"},
{"lineNum":"   37","line":"}"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "bats", "date" : "2023-04-06 21:10:23", "instrumented" : 14, "covered" : 11,};
var merged_data = [];
