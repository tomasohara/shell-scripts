var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bash"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":"BATS_TMPNAME=\"$BATS_RUN_TMPDIR/bats.$$\"","class":"lineCov","hits":"39","order":"265","possible_hits":"0",},
{"lineNum":"    4","line":"BATS_PARENT_TMPNAME=\"$BATS_RUN_TMPDIR/bats.$PPID\"","class":"lineCov","hits":"39","order":"266","possible_hits":"0",},
{"lineNum":"    5","line":"# shellcheck disable=SC2034"},
{"lineNum":"    6","line":"BATS_OUT=\"${BATS_TMPNAME}.out\" # used in bats-exec-file","class":"lineCov","hits":"39","order":"267","possible_hits":"0",},
{"lineNum":"    7","line":""},
{"lineNum":"    8","line":"bats_preprocess_source() {"},
{"lineNum":"    9","line":"\t# export to make it visible to bats_evaluate_preprocessed_source"},
{"lineNum":"   10","line":"\t# since the latter runs in bats-exec-test\'s bash while this runs in bats-exec-file\'s"},
{"lineNum":"   11","line":"\texport BATS_TEST_SOURCE=\"${BATS_TMPNAME}.src\"","class":"lineCov","hits":"2","order":"292","possible_hits":"0",},
{"lineNum":"   12","line":"\tCHECK_BATS_COMMENT_COMMANDS=1 bats-preprocess \"$BATS_TEST_FILENAME\" >\"$BATS_TEST_SOURCE\"","class":"lineCov","hits":"2","order":"293","possible_hits":"0",},
{"lineNum":"   13","line":"}"},
{"lineNum":"   14","line":""},
{"lineNum":"   15","line":"bats_evaluate_preprocessed_source() {"},
{"lineNum":"   16","line":"\tif [[ -z \"${BATS_TEST_SOURCE:-}\" ]]; then","class":"lineCov","hits":"38","order":"422","possible_hits":"0",},
{"lineNum":"   17","line":"\t\tBATS_TEST_SOURCE=\"${BATS_PARENT_TMPNAME}.src\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   18","line":"\tfi"},
{"lineNum":"   19","line":"\t# Dynamically loaded user files provided outside of Bats."},
{"lineNum":"   20","line":"\t# shellcheck disable=SC1090"},
{"lineNum":"   21","line":"\tsource \"$BATS_TEST_SOURCE\"","class":"lineCov","hits":"38","order":"423","possible_hits":"0",},
{"lineNum":"   22","line":"}"},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "bats", "date" : "2022-10-23 20:33:47", "instrumented" : 8, "covered" : 7,};
var merged_data = [];
