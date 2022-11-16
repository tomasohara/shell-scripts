var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bats"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":""},
{"lineNum":"    4","line":"# Make executables ./tests/../ visible to PATH"},
{"lineNum":"    5","line":"PATH=\"/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH\"","class":"lineCov","hits":"5","order":"314","possible_hits":"0",},
{"lineNum":"    6","line":""},
{"lineNum":"    7","line":"# Source files"},
{"lineNum":"    8","line":"shopt -s expand_aliases","class":"lineCov","hits":"5","order":"330","possible_hits":"0",},
{"lineNum":"    9","line":""},
{"lineNum":"   10","line":""},
{"lineNum":"   11","line":"test_test0() { bats_test_begin \"test0\";"},
{"lineNum":"   12","line":"\ttest_folder=$(echo /tmp/test0-$$)","class":"lineCov","hits":"4","order":"411","possible_hits":"0",},
{"lineNum":"   13","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"412","possible_hits":"0",},
{"lineNum":"   14","line":""},
{"lineNum":"   15","line":"\tbind \'set enable-bracketed-paste off\'","class":"lineCov","hits":"2","order":"413","possible_hits":"0",},
{"lineNum":"   16","line":"\techo \"BIND ON!\"","class":"lineCov","hits":"2","order":"414","possible_hits":"0",},
{"lineNum":"   17","line":"}"},
{"lineNum":"   18","line":""},
{"lineNum":"   19","line":""},
{"lineNum":"   20","line":"test_test1() { bats_test_begin \"test1\";"},
{"lineNum":"   21","line":"\ttest_folder=$(echo /tmp/test1-$$)","class":"lineCov","hits":"4","order":"454","possible_hits":"0",},
{"lineNum":"   22","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"455","possible_hits":"0",},
{"lineNum":"   23","line":""},
{"lineNum":"   24","line":"\tactual=$(test1-assert1-actual)","class":"lineCov","hits":"4","order":"456","possible_hits":"0",},
{"lineNum":"   25","line":"\texpected=$(test1-assert1-expected)","class":"lineCov","hits":"4","order":"458","possible_hits":"0",},
{"lineNum":"   26","line":"\techo \"========== actual ==========\"","class":"lineCov","hits":"2","order":"460","possible_hits":"0",},
{"lineNum":"   27","line":"\techo \"$actual\" | hexview.perl","class":"lineCov","hits":"4","order":"461","possible_hits":"0",},
{"lineNum":"   28","line":"\techo \"========= expected =========\"","class":"lineCov","hits":"2","order":"462","possible_hits":"0",},
{"lineNum":"   29","line":"\techo \"$expected\" | hexview.perl","class":"lineCov","hits":"4","order":"463","possible_hits":"0",},
{"lineNum":"   30","line":"\techo \"============================\"","class":"lineCov","hits":"2","order":"464","possible_hits":"0",},
{"lineNum":"   31","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineCov","hits":"2","order":"465","possible_hits":"0",},
{"lineNum":"   32","line":""},
{"lineNum":"   33","line":"}"},
{"lineNum":"   34","line":""},
{"lineNum":"   35","line":"function test1-assert1-actual () {"},
{"lineNum":"   36","line":"\techo \"Hi Mom!\"","class":"lineCov","hits":"2","order":"457","possible_hits":"0",},
{"lineNum":"   37","line":"}"},
{"lineNum":"   38","line":"function test1-assert1-expected () {"},
{"lineNum":"   39","line":"\techo -e \'Hi Mom!\'","class":"lineCov","hits":"2","order":"459","possible_hits":"0",},
{"lineNum":"   40","line":"}"},
{"lineNum":"   41","line":""},
{"lineNum":"   42","line":"test_test2() { bats_test_begin \"test2\";"},
{"lineNum":"   43","line":"\ttest_folder=$(echo /tmp/test2-$$)","class":"lineCov","hits":"4","order":"466","possible_hits":"0",},
{"lineNum":"   44","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"467","possible_hits":"0",},
{"lineNum":"   45","line":""},
{"lineNum":"   46","line":"\tactual=$(test2-assert1-actual)","class":"lineCov","hits":"4","order":"468","possible_hits":"0",},
{"lineNum":"   47","line":"\texpected=$(test2-assert1-expected)","class":"lineCov","hits":"4","order":"470","possible_hits":"0",},
{"lineNum":"   48","line":"\techo \"========== actual ==========\"","class":"lineCov","hits":"2","order":"472","possible_hits":"0",},
{"lineNum":"   49","line":"\techo \"$actual\" | hexview.perl","class":"lineCov","hits":"4","order":"473","possible_hits":"0",},
{"lineNum":"   50","line":"\techo \"========= expected =========\"","class":"lineCov","hits":"2","order":"474","possible_hits":"0",},
{"lineNum":"   51","line":"\techo \"$expected\" | hexview.perl","class":"lineCov","hits":"4","order":"475","possible_hits":"0",},
{"lineNum":"   52","line":"\techo \"============================\"","class":"lineCov","hits":"2","order":"476","possible_hits":"0",},
{"lineNum":"   53","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineCov","hits":"2","order":"477","possible_hits":"0",},
{"lineNum":"   54","line":""},
{"lineNum":"   55","line":"}"},
{"lineNum":"   56","line":""},
{"lineNum":"   57","line":"function test2-assert1-actual () {"},
{"lineNum":"   58","line":"\techo \'Hello world\' | wc -l","class":"lineCov","hits":"4","order":"469","possible_hits":"0",},
{"lineNum":"   59","line":"}"},
{"lineNum":"   60","line":"function test2-assert1-expected () {"},
{"lineNum":"   61","line":"\techo -e \'1\'","class":"lineCov","hits":"2","order":"471","possible_hits":"0",},
{"lineNum":"   62","line":"}"},
{"lineNum":"   63","line":""},
{"lineNum":"   64","line":"bats_test_function --tags \'\' test_test0","class":"lineCov","hits":"5","order":"331","possible_hits":"0",},
{"lineNum":"   65","line":"bats_test_function --tags \'\' test_test1","class":"lineCov","hits":"5","order":"334","possible_hits":"0",},
{"lineNum":"   66","line":"bats_test_function --tags \'\' test_test2","class":"lineCov","hits":"5","order":"335","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "bats", "date" : "2022-10-25 17:15:46", "instrumented" : 33, "covered" : 33,};
var merged_data = [];