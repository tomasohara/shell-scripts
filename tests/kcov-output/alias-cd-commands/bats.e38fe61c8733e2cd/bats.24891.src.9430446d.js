var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bats"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":""},
{"lineNum":"    4","line":"# Make executables ./tests/../ visible to PATH"},
{"lineNum":"    5","line":"PATH=\"/home/aveey/tom-project/shell-scripts/tests/../:$PATH\"","class":"lineCov","hits":"26","order":"314","possible_hits":"0",},
{"lineNum":"    6","line":""},
{"lineNum":"    7","line":"# Source files"},
{"lineNum":"    8","line":"shopt -s expand_aliases","class":"lineCov","hits":"26","order":"330","possible_hits":"0",},
{"lineNum":"    9","line":""},
{"lineNum":"   10","line":""},
{"lineNum":"   11","line":"test_test0() { bats_test_begin \"test0\";"},
{"lineNum":"   12","line":"\ttest_folder=$(echo /tmp/test0-$$)","class":"lineCov","hits":"8","order":"419","possible_hits":"0",},
{"lineNum":"   13","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"8","order":"420","possible_hits":"0",},
{"lineNum":"   14","line":""},
{"lineNum":"   15","line":"\tbind \'set enable-bracketed-paste off\'","class":"lineCov","hits":"4","order":"421","possible_hits":"0",},
{"lineNum":"   16","line":"}"},
{"lineNum":"   17","line":""},
{"lineNum":"   18","line":""},
{"lineNum":"   19","line":"test_test1() { bats_test_begin \"test1\";"},
{"lineNum":"   20","line":"\ttest_folder=$(echo /tmp/test1-$$)","class":"lineCov","hits":"8","order":"461","possible_hits":"0",},
{"lineNum":"   21","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"8","order":"462","possible_hits":"0",},
{"lineNum":"   22","line":""},
{"lineNum":"   23","line":"}"},
{"lineNum":"   24","line":""},
{"lineNum":"   25","line":""},
{"lineNum":"   26","line":"test_test2() { bats_test_begin \"test2\";"},
{"lineNum":"   27","line":"\ttest_folder=$(echo /tmp/test2-$$)","class":"lineCov","hits":"8","order":"463","possible_hits":"0",},
{"lineNum":"   28","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"8","order":"464","possible_hits":"0",},
{"lineNum":"   29","line":""},
{"lineNum":"   30","line":"\tunalias -a","class":"lineCov","hits":"4","order":"465","possible_hits":"0",},
{"lineNum":"   31","line":"\talias | wc -l","class":"lineCov","hits":"8","order":"466","possible_hits":"0",},
{"lineNum":"   32","line":"\tfor f in $(typeset -f | egrep \'^\\w+\'); do unset -f $f; done","class":"lineCov","hits":"116","order":"467","possible_hits":"0",},
{"lineNum":"   33","line":"\tactual=$(test2-assert4-actual)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   34","line":"\texpected=$(test2-assert4-expected)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   35","line":"\techo \"========== actual ==========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   36","line":"\techo \"$actual\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   37","line":"\techo \"========= expected =========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   38","line":"\techo \"$expected\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   39","line":"\techo \"============================\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   40","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   41","line":""},
{"lineNum":"   42","line":"}"},
{"lineNum":"   43","line":""},
{"lineNum":"   44","line":"function test2-assert4-actual () {"},
{"lineNum":"   45","line":"\ttypeset -f | egrep \'^\\w+\' | wc -l","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   46","line":"}"},
{"lineNum":"   47","line":"function test2-assert4-expected () {"},
{"lineNum":"   48","line":"\techo -e \'00\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   49","line":"}"},
{"lineNum":"   50","line":""},
{"lineNum":"   51","line":"test_test3() { bats_test_begin \"test3\";"},
{"lineNum":"   52","line":"\ttest_folder=$(echo /tmp/test3-$$)","class":"lineCov","hits":"8","order":"552","possible_hits":"0",},
{"lineNum":"   53","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"8","order":"553","possible_hits":"0",},
{"lineNum":"   54","line":""},
{"lineNum":"   55","line":"\tsource _dir-aliases.bash","class":"lineCov","hits":"4","order":"554","possible_hits":"0",},
{"lineNum":"   56","line":"\tactual=$(test3-assert2-actual)","class":"lineCov","hits":"8","order":"569","possible_hits":"0",},
{"lineNum":"   57","line":"\texpected=$(test3-assert2-expected)","class":"lineCov","hits":"8","order":"571","possible_hits":"0",},
{"lineNum":"   58","line":"\techo \"========== actual ==========\"","class":"lineCov","hits":"4","order":"573","possible_hits":"0",},
{"lineNum":"   59","line":"\techo \"$actual\" | hexview.perl","class":"lineCov","hits":"8","order":"574","possible_hits":"0",},
{"lineNum":"   60","line":"\techo \"========= expected =========\"","class":"lineCov","hits":"4","order":"575","possible_hits":"0",},
{"lineNum":"   61","line":"\techo \"$expected\" | hexview.perl","class":"lineCov","hits":"8","order":"576","possible_hits":"0",},
{"lineNum":"   62","line":"\techo \"============================\"","class":"lineCov","hits":"4","order":"577","possible_hits":"0",},
{"lineNum":"   63","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineCov","hits":"4","order":"578","possible_hits":"0",},
{"lineNum":"   64","line":""},
{"lineNum":"   65","line":"}"},
{"lineNum":"   66","line":""},
{"lineNum":"   67","line":"function test3-assert2-actual () {"},
{"lineNum":"   68","line":"\talias | wc -l","class":"lineCov","hits":"8","order":"570","possible_hits":"0",},
{"lineNum":"   69","line":"}"},
{"lineNum":"   70","line":"function test3-assert2-expected () {"},
{"lineNum":"   71","line":"\techo -e \'8\'","class":"lineCov","hits":"4","order":"572","possible_hits":"0",},
{"lineNum":"   72","line":"}"},
{"lineNum":"   73","line":""},
{"lineNum":"   74","line":"test_test4() { bats_test_begin \"test4\";"},
{"lineNum":"   75","line":"\ttest_folder=$(echo /tmp/test4-$$)","class":"lineCov","hits":"8","order":"579","possible_hits":"0",},
{"lineNum":"   76","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"8","order":"580","possible_hits":"0",},
{"lineNum":"   77","line":""},
{"lineNum":"   78","line":"\ttemp_dir=$TMP/test-6869","class":"lineCov","hits":"4","order":"581","possible_hits":"0",},
{"lineNum":"   79","line":"\tcd \"$temp_dir\"","class":"lineCov","hits":"8","order":"582","possible_hits":"0",},
{"lineNum":"   80","line":"}"},
{"lineNum":"   81","line":""},
{"lineNum":"   82","line":""},
{"lineNum":"   83","line":"test_test5() { bats_test_begin \"test5\";"},
{"lineNum":"   84","line":"\ttest_folder=$(echo /tmp/test5-$$)","class":"lineCov","hits":"8","order":"584","possible_hits":"0",},
{"lineNum":"   85","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"8","order":"585","possible_hits":"0",},
{"lineNum":"   86","line":""},
{"lineNum":"   87","line":"\tactual=$(test5-assert1-actual)","class":"lineCov","hits":"8","order":"586","possible_hits":"0",},
{"lineNum":"   88","line":"\texpected=$(test5-assert1-expected)","class":"lineCov","hits":"8","order":"588","possible_hits":"0",},
{"lineNum":"   89","line":"\techo \"========== actual ==========\"","class":"lineCov","hits":"4","order":"590","possible_hits":"0",},
{"lineNum":"   90","line":"\techo \"$actual\" | hexview.perl","class":"lineCov","hits":"8","order":"591","possible_hits":"0",},
{"lineNum":"   91","line":"\techo \"========= expected =========\"","class":"lineCov","hits":"4","order":"592","possible_hits":"0",},
{"lineNum":"   92","line":"\techo \"$expected\" | hexview.perl","class":"lineCov","hits":"8","order":"593","possible_hits":"0",},
{"lineNum":"   93","line":"\techo \"============================\"","class":"lineCov","hits":"4","order":"594","possible_hits":"0",},
{"lineNum":"   94","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineCov","hits":"8","order":"595","possible_hits":"0",},
{"lineNum":"   95","line":""},
{"lineNum":"   96","line":"}"},
{"lineNum":"   97","line":""},
{"lineNum":"   98","line":"function test5-assert1-actual () {"},
{"lineNum":"   99","line":"\talias | wc -l","class":"lineCov","hits":"8","order":"587","possible_hits":"0",},
{"lineNum":"  100","line":"}"},
{"lineNum":"  101","line":"function test5-assert1-expected () {"},
{"lineNum":"  102","line":"\techo -e \'9\'","class":"lineCov","hits":"4","order":"589","possible_hits":"0",},
{"lineNum":"  103","line":"}"},
{"lineNum":"  104","line":""},
{"lineNum":"  105","line":"test_test6() { bats_test_begin \"test6\";"},
{"lineNum":"  106","line":"\ttest_folder=$(echo /tmp/test6-$$)","class":"lineCov","hits":"8","order":"596","possible_hits":"0",},
{"lineNum":"  107","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"8","order":"597","possible_hits":"0",},
{"lineNum":"  108","line":""},
{"lineNum":"  109","line":"\tactual=$(test6-assert1-actual)","class":"lineCov","hits":"8","order":"598","possible_hits":"0",},
{"lineNum":"  110","line":"\texpected=$(test6-assert1-expected)","class":"lineCov","hits":"8","order":"600","possible_hits":"0",},
{"lineNum":"  111","line":"\techo \"========== actual ==========\"","class":"lineCov","hits":"4","order":"602","possible_hits":"0",},
{"lineNum":"  112","line":"\techo \"$actual\" | hexview.perl","class":"lineCov","hits":"8","order":"603","possible_hits":"0",},
{"lineNum":"  113","line":"\techo \"========= expected =========\"","class":"lineCov","hits":"4","order":"604","possible_hits":"0",},
{"lineNum":"  114","line":"\techo \"$expected\" | hexview.perl","class":"lineCov","hits":"8","order":"605","possible_hits":"0",},
{"lineNum":"  115","line":"\techo \"============================\"","class":"lineCov","hits":"4","order":"606","possible_hits":"0",},
{"lineNum":"  116","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineCov","hits":"8","order":"607","possible_hits":"0",},
{"lineNum":"  117","line":""},
{"lineNum":"  118","line":"}"},
{"lineNum":"  119","line":""},
{"lineNum":"  120","line":"function test6-assert1-actual () {"},
{"lineNum":"  121","line":"\ttypeset -f | egrep \'^\\w+\' | wc -l","class":"lineCov","hits":"12","order":"599","possible_hits":"0",},
{"lineNum":"  122","line":"}"},
{"lineNum":"  123","line":"function test6-assert1-expected () {"},
{"lineNum":"  124","line":"\techo -e \'2\'","class":"lineCov","hits":"4","order":"601","possible_hits":"0",},
{"lineNum":"  125","line":"}"},
{"lineNum":"  126","line":""},
{"lineNum":"  127","line":"test_test7() { bats_test_begin \"test7\";"},
{"lineNum":"  128","line":"\ttest_folder=$(echo /tmp/test7-$$)","class":"lineCov","hits":"8","order":"608","possible_hits":"0",},
{"lineNum":"  129","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"8","order":"609","possible_hits":"0",},
{"lineNum":"  130","line":""},
{"lineNum":"  131","line":"\tfunction cd-realdir {"},
{"lineNum":"  132","line":"\tlocal dir=\"$1\";","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  133","line":"\tif [ \"$dir\" = \"\" ]; then dir=.; fi;","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  134","line":"\tcd \"$(realpath \"$dir\")\";","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  135","line":"\tpwd;","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  136","line":"\t}"},
{"lineNum":"  137","line":"\talias cd-this-realdir=\'cd-realdir .\'","class":"lineCov","hits":"4","order":"610","possible_hits":"0",},
{"lineNum":"  138","line":"}"},
{"lineNum":"  139","line":""},
{"lineNum":"  140","line":""},
{"lineNum":"  141","line":"test_test8() { bats_test_begin \"test8\";"},
{"lineNum":"  142","line":"\ttest_folder=$(echo /tmp/test8-$$)","class":"lineCov","hits":"8","order":"611","possible_hits":"0",},
{"lineNum":"  143","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"8","order":"612","possible_hits":"0",},
{"lineNum":"  144","line":""},
{"lineNum":"  145","line":"\tfunction pushd-q () { builtin pushd \"$@\" >| /dev/null; }"},
{"lineNum":"  146","line":"}"},
{"lineNum":"  147","line":""},
{"lineNum":"  148","line":""},
{"lineNum":"  149","line":"test_test9() { bats_test_begin \"test9\";"},
{"lineNum":"  150","line":"\ttest_folder=$(echo /tmp/test9-$$)","class":"lineCov","hits":"8","order":"613","possible_hits":"0",},
{"lineNum":"  151","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"8","order":"614","possible_hits":"0",},
{"lineNum":"  152","line":""},
{"lineNum":"  153","line":"}"},
{"lineNum":"  154","line":""},
{"lineNum":"  155","line":""},
{"lineNum":"  156","line":"test_test10() { bats_test_begin \"test10\";"},
{"lineNum":"  157","line":"\ttest_folder=$(echo /tmp/test10-$$)","class":"lineCov","hits":"8","order":"615","possible_hits":"0",},
{"lineNum":"  158","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"8","order":"616","possible_hits":"0",},
{"lineNum":"  159","line":""},
{"lineNum":"  160","line":"\tchdir ..","class":"lineCov","hits":"8","order":"617","possible_hits":"0",},
{"lineNum":"  161","line":"\tpwd","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  162","line":"\tchdir test-6869/","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  163","line":"\tpwd","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  164","line":"\tchdir ..","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  165","line":"\tpwd","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  166","line":"\tchdir test-6869/","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  167","line":"}"},
{"lineNum":"  168","line":""},
{"lineNum":"  169","line":"bats_test_function --tags \'\' test_test0","class":"lineCov","hits":"26","order":"331","possible_hits":"0",},
{"lineNum":"  170","line":"bats_test_function --tags \'\' test_test1","class":"lineCov","hits":"26","order":"334","possible_hits":"0",},
{"lineNum":"  171","line":"bats_test_function --tags \'\' test_test2","class":"lineCov","hits":"26","order":"335","possible_hits":"0",},
{"lineNum":"  172","line":"bats_test_function --tags \'\' test_test3","class":"lineCov","hits":"26","order":"336","possible_hits":"0",},
{"lineNum":"  173","line":"bats_test_function --tags \'\' test_test4","class":"lineCov","hits":"26","order":"337","possible_hits":"0",},
{"lineNum":"  174","line":"bats_test_function --tags \'\' test_test5","class":"lineCov","hits":"26","order":"338","possible_hits":"0",},
{"lineNum":"  175","line":"bats_test_function --tags \'\' test_test6","class":"lineCov","hits":"26","order":"339","possible_hits":"0",},
{"lineNum":"  176","line":"bats_test_function --tags \'\' test_test7","class":"lineCov","hits":"26","order":"340","possible_hits":"0",},
{"lineNum":"  177","line":"bats_test_function --tags \'\' test_test8","class":"lineCov","hits":"26","order":"341","possible_hits":"0",},
{"lineNum":"  178","line":"bats_test_function --tags \'\' test_test9","class":"lineCov","hits":"26","order":"342","possible_hits":"0",},
{"lineNum":"  179","line":"bats_test_function --tags \'\' test_test10","class":"lineCov","hits":"26","order":"343","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "bats", "date" : "2022-09-26 10:25:54", "instrumented" : 94, "covered" : 74,};
var merged_data = [];
