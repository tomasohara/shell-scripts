var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bats"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":""},
{"lineNum":"    4","line":"# Make executables ./tests/../ visible to PATH"},
{"lineNum":"    5","line":"PATH=\"/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH\"","class":"lineCov","hits":"11","order":"314","possible_hits":"0",},
{"lineNum":"    6","line":""},
{"lineNum":"    7","line":"# Source files"},
{"lineNum":"    8","line":"shopt -s expand_aliases","class":"lineCov","hits":"11","order":"330","possible_hits":"0",},
{"lineNum":"    9","line":""},
{"lineNum":"   10","line":""},
{"lineNum":"   11","line":"test_test0() { bats_test_begin \"test0\";"},
{"lineNum":"   12","line":"\ttest_folder=$(echo /tmp/test0-$$)","class":"lineCov","hits":"4","order":"417","possible_hits":"0",},
{"lineNum":"   13","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"418","possible_hits":"0",},
{"lineNum":"   14","line":""},
{"lineNum":"   15","line":"\tbind \'set enable-bracketed-paste off\'","class":"lineCov","hits":"2","order":"419","possible_hits":"0",},
{"lineNum":"   16","line":"\tunalias -a","class":"lineCov","hits":"2","order":"420","possible_hits":"0",},
{"lineNum":"   17","line":"\tfor f in $(typeset -f | egrep \'^\\w+\'); do unset -f $f; done","class":"lineCov","hits":"58","order":"421","possible_hits":"0",},
{"lineNum":"   18","line":"\tBIN_DIR=$PWD/..","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   19","line":"}"},
{"lineNum":"   20","line":""},
{"lineNum":"   21","line":""},
{"lineNum":"   22","line":"test_test1() { bats_test_begin \"test1\";"},
{"lineNum":"   23","line":"\ttest_folder=$(echo /tmp/test1-$$)","class":"lineCov","hits":"4","order":"538","possible_hits":"0",},
{"lineNum":"   24","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"539","possible_hits":"0",},
{"lineNum":"   25","line":""},
{"lineNum":"   26","line":"\tcalc_entropy=calc_entropy.perl","class":"lineCov","hits":"2","order":"540","possible_hits":"0",},
{"lineNum":"   27","line":"\tsimple=\"-simple\"","class":"lineCov","hits":"2","order":"541","possible_hits":"0",},
{"lineNum":"   28","line":"\talias encode-blank-line=\'perl -pe \"s/^$/<NL>/;\"\'","class":"lineCov","hits":"2","order":"542","possible_hits":"0",},
{"lineNum":"   29","line":"}"},
{"lineNum":"   30","line":""},
{"lineNum":"   31","line":""},
{"lineNum":"   32","line":"test_test2() { bats_test_begin \"test2\";"},
{"lineNum":"   33","line":"\ttest_folder=$(echo /tmp/test2-$$)","class":"lineCov","hits":"4","order":"550","possible_hits":"0",},
{"lineNum":"   34","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"551","possible_hits":"0",},
{"lineNum":"   35","line":""},
{"lineNum":"   36","line":"\tactual=$(test2-assert1-actual)","class":"lineCov","hits":"7","order":"552","possible_hits":"0",},
{"lineNum":"   37","line":"\texpected=$(test2-assert1-expected)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   38","line":"\techo \"========== actual ==========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   39","line":"\techo \"$actual\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   40","line":"\techo \"========= expected =========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   41","line":"\techo \"$expected\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   42","line":"\techo \"============================\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   43","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   44","line":""},
{"lineNum":"   45","line":"}"},
{"lineNum":"   46","line":""},
{"lineNum":"   47","line":"function test2-assert1-actual () {"},
{"lineNum":"   48","line":"\t$calc_entropy $simple .25 .25 .25 .25","class":"lineCov","hits":"4","order":"553","possible_hits":"0",},
{"lineNum":"   49","line":"}"},
{"lineNum":"   50","line":"function test2-assert1-expected () {"},
{"lineNum":"   51","line":"\techo -e \'Entropy2.000\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   52","line":"}"},
{"lineNum":"   53","line":""},
{"lineNum":"   54","line":"test_test3() { bats_test_begin \"test3\";"},
{"lineNum":"   55","line":"\ttest_folder=$(echo /tmp/test3-$$)","class":"lineCov","hits":"4","order":"554","possible_hits":"0",},
{"lineNum":"   56","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"555","possible_hits":"0",},
{"lineNum":"   57","line":""},
{"lineNum":"   58","line":"}"},
{"lineNum":"   59","line":""},
{"lineNum":"   60","line":""},
{"lineNum":"   61","line":"test_test4() { bats_test_begin \"test4\";"},
{"lineNum":"   62","line":"\ttest_folder=$(echo /tmp/test4-$$)","class":"lineCov","hits":"4","order":"556","possible_hits":"0",},
{"lineNum":"   63","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"557","possible_hits":"0",},
{"lineNum":"   64","line":""},
{"lineNum":"   65","line":"\tactual=$(test4-assert1-actual)","class":"lineCov","hits":"7","order":"558","possible_hits":"0",},
{"lineNum":"   66","line":"\texpected=$(test4-assert1-expected)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   67","line":"\techo \"========== actual ==========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   68","line":"\techo \"$actual\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   69","line":"\techo \"========= expected =========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   70","line":"\techo \"$expected\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   71","line":"\techo \"============================\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   72","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   73","line":""},
{"lineNum":"   74","line":"}"},
{"lineNum":"   75","line":""},
{"lineNum":"   76","line":"function test4-assert1-actual () {"},
{"lineNum":"   77","line":"\t$calc_entropy $simple - < ./calc_entropy.simple.input","class":"lineCov","hits":"4","order":"559","possible_hits":"0",},
{"lineNum":"   78","line":"}"},
{"lineNum":"   79","line":"function test4-assert1-expected () {"},
{"lineNum":"   80","line":"\techo -e \'Entropy2.000\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   81","line":"}"},
{"lineNum":"   82","line":""},
{"lineNum":"   83","line":"test_test5() { bats_test_begin \"test5\";"},
{"lineNum":"   84","line":"\ttest_folder=$(echo /tmp/test5-$$)","class":"lineCov","hits":"4","order":"561","possible_hits":"0",},
{"lineNum":"   85","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"562","possible_hits":"0",},
{"lineNum":"   86","line":""},
{"lineNum":"   87","line":"\tactual=$(test5-assert1-actual)","class":"lineCov","hits":"7","order":"563","possible_hits":"0",},
{"lineNum":"   88","line":"\texpected=$(test5-assert1-expected)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   89","line":"\techo \"========== actual ==========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   90","line":"\techo \"$actual\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   91","line":"\techo \"========= expected =========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   92","line":"\techo \"$expected\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   93","line":"\techo \"============================\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   94","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   95","line":""},
{"lineNum":"   96","line":"}"},
{"lineNum":"   97","line":""},
{"lineNum":"   98","line":"function test5-assert1-actual () {"},
{"lineNum":"   99","line":"\t$calc_entropy $simple - < ./calc_entropy.simple.input2","class":"lineCov","hits":"4","order":"564","possible_hits":"0",},
{"lineNum":"  100","line":"}"},
{"lineNum":"  101","line":"function test5-assert1-expected () {"},
{"lineNum":"  102","line":"\techo -e \'Entropy1.497\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  103","line":"}"},
{"lineNum":"  104","line":""},
{"lineNum":"  105","line":"test_test6() { bats_test_begin \"test6\";"},
{"lineNum":"  106","line":"\ttest_folder=$(echo /tmp/test6-$$)","class":"lineCov","hits":"4","order":"565","possible_hits":"0",},
{"lineNum":"  107","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"566","possible_hits":"0",},
{"lineNum":"  108","line":""},
{"lineNum":"  109","line":"}"},
{"lineNum":"  110","line":""},
{"lineNum":"  111","line":""},
{"lineNum":"  112","line":"test_test7() { bats_test_begin \"test7\";"},
{"lineNum":"  113","line":"\ttest_folder=$(echo /tmp/test7-$$)","class":"lineCov","hits":"4","order":"567","possible_hits":"0",},
{"lineNum":"  114","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"568","possible_hits":"0",},
{"lineNum":"  115","line":""},
{"lineNum":"  116","line":"\tactual=$(test7-assert1-actual)","class":"lineCov","hits":"7","order":"569","possible_hits":"0",},
{"lineNum":"  117","line":"\texpected=$(test7-assert1-expected)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  118","line":"\techo \"========== actual ==========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  119","line":"\techo \"$actual\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  120","line":"\techo \"========= expected =========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  121","line":"\techo \"$expected\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  122","line":"\techo \"============================\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  123","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  124","line":""},
{"lineNum":"  125","line":"}"},
{"lineNum":"  126","line":""},
{"lineNum":"  127","line":"function test7-assert1-actual () {"},
{"lineNum":"  128","line":"\t$calc_entropy - < ./calc_entropy.input","class":"lineCov","hits":"4","order":"570","possible_hits":"0",},
{"lineNum":"  129","line":"}"},
{"lineNum":"  130","line":"function test7-assert1-expected () {"},
{"lineNum":"  131","line":"\techo -e \'2.230\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  132","line":"}"},
{"lineNum":"  133","line":""},
{"lineNum":"  134","line":"test_test8() { bats_test_begin \"test8\";"},
{"lineNum":"  135","line":"\ttest_folder=$(echo /tmp/test8-$$)","class":"lineCov","hits":"4","order":"571","possible_hits":"0",},
{"lineNum":"  136","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"572","possible_hits":"0",},
{"lineNum":"  137","line":""},
{"lineNum":"  138","line":"}"},
{"lineNum":"  139","line":""},
{"lineNum":"  140","line":"bats_test_function --tags \'\' test_test0","class":"lineCov","hits":"11","order":"331","possible_hits":"0",},
{"lineNum":"  141","line":"bats_test_function --tags \'\' test_test1","class":"lineCov","hits":"11","order":"334","possible_hits":"0",},
{"lineNum":"  142","line":"bats_test_function --tags \'\' test_test2","class":"lineCov","hits":"11","order":"335","possible_hits":"0",},
{"lineNum":"  143","line":"bats_test_function --tags \'\' test_test3","class":"lineCov","hits":"11","order":"336","possible_hits":"0",},
{"lineNum":"  144","line":"bats_test_function --tags \'\' test_test4","class":"lineCov","hits":"11","order":"337","possible_hits":"0",},
{"lineNum":"  145","line":"bats_test_function --tags \'\' test_test5","class":"lineCov","hits":"11","order":"338","possible_hits":"0",},
{"lineNum":"  146","line":"bats_test_function --tags \'\' test_test6","class":"lineCov","hits":"11","order":"339","possible_hits":"0",},
{"lineNum":"  147","line":"bats_test_function --tags \'\' test_test7","class":"lineCov","hits":"11","order":"340","possible_hits":"0",},
{"lineNum":"  148","line":"bats_test_function --tags \'\' test_test8","class":"lineCov","hits":"11","order":"341","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "bats", "date" : "2022-10-23 20:34:43", "instrumented" : 76, "covered" : 43,};
var merged_data = [];
