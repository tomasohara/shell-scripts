var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bats"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":""},
{"lineNum":"    4","line":"# Make executables ./tests/../ visible to PATH"},
{"lineNum":"    5","line":"PATH=\"/home/aveey/tom-project/shell-scripts/tests/../:$PATH\"","class":"lineCov","hits":"36","order":"314","possible_hits":"0",},
{"lineNum":"    6","line":""},
{"lineNum":"    7","line":"# Source files"},
{"lineNum":"    8","line":"shopt -s expand_aliases","class":"lineCov","hits":"36","order":"330","possible_hits":"0",},
{"lineNum":"    9","line":""},
{"lineNum":"   10","line":""},
{"lineNum":"   11","line":"test_test0() { bats_test_begin \"test0\";"},
{"lineNum":"   12","line":"\ttest_folder=$(echo /tmp/test0-$$)","class":"lineCov","hits":"8","order":"424","possible_hits":"0",},
{"lineNum":"   13","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"8","order":"425","possible_hits":"0",},
{"lineNum":"   14","line":""},
{"lineNum":"   15","line":"}"},
{"lineNum":"   16","line":""},
{"lineNum":"   17","line":""},
{"lineNum":"   18","line":"test_test1() { bats_test_begin \"test1\";"},
{"lineNum":"   19","line":"\ttest_folder=$(echo /tmp/test1-$$)","class":"lineCov","hits":"8","order":"465","possible_hits":"0",},
{"lineNum":"   20","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"8","order":"466","possible_hits":"0",},
{"lineNum":"   21","line":""},
{"lineNum":"   22","line":"\tunalias -a","class":"lineCov","hits":"4","order":"467","possible_hits":"0",},
{"lineNum":"   23","line":"\talias | wc -l","class":"lineCov","hits":"8","order":"468","possible_hits":"0",},
{"lineNum":"   24","line":"\tfor f in $(typeset -f | egrep \'^\\w+\'); do unset -f $f; done","class":"lineCov","hits":"116","order":"469","possible_hits":"0",},
{"lineNum":"   25","line":"\tactual=$(test1-assert4-actual)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   26","line":"\texpected=$(test1-assert4-expected)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   27","line":"\techo \"========== actual ==========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   28","line":"\techo \"$actual\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   29","line":"\techo \"========= expected =========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   30","line":"\techo \"$expected\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   31","line":"\techo \"============================\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   32","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   33","line":""},
{"lineNum":"   34","line":"}"},
{"lineNum":"   35","line":""},
{"lineNum":"   36","line":"function test1-assert4-actual () {"},
{"lineNum":"   37","line":"\ttypeset -f | egrep \'^\\w+\' | wc -l","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   38","line":"}"},
{"lineNum":"   39","line":"function test1-assert4-expected () {"},
{"lineNum":"   40","line":"\techo -e \'00\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   41","line":"}"},
{"lineNum":"   42","line":""},
{"lineNum":"   43","line":"test_test2() { bats_test_begin \"test2\";"},
{"lineNum":"   44","line":"\ttest_folder=$(echo /tmp/test2-$$)","class":"lineCov","hits":"8","order":"554","possible_hits":"0",},
{"lineNum":"   45","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"8","order":"555","possible_hits":"0",},
{"lineNum":"   46","line":""},
{"lineNum":"   47","line":"\tBIN_DIR=$PWD/..","class":"lineCov","hits":"4","order":"556","possible_hits":"0",},
{"lineNum":"   48","line":"\tactual=$(test2-assert2-actual)","class":"lineCov","hits":"8","order":"557","possible_hits":"0",},
{"lineNum":"   49","line":"\texpected=$(test2-assert2-expected)","class":"lineCov","hits":"8","order":"559","possible_hits":"0",},
{"lineNum":"   50","line":"\techo \"========== actual ==========\"","class":"lineCov","hits":"4","order":"561","possible_hits":"0",},
{"lineNum":"   51","line":"\techo \"$actual\" | hexview.perl","class":"lineCov","hits":"8","order":"562","possible_hits":"0",},
{"lineNum":"   52","line":"\techo \"========= expected =========\"","class":"lineCov","hits":"4","order":"563","possible_hits":"0",},
{"lineNum":"   53","line":"\techo \"$expected\" | hexview.perl","class":"lineCov","hits":"8","order":"564","possible_hits":"0",},
{"lineNum":"   54","line":"\techo \"============================\"","class":"lineCov","hits":"4","order":"565","possible_hits":"0",},
{"lineNum":"   55","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineCov","hits":"4","order":"566","possible_hits":"0",},
{"lineNum":"   56","line":""},
{"lineNum":"   57","line":"}"},
{"lineNum":"   58","line":""},
{"lineNum":"   59","line":"function test2-assert2-actual () {"},
{"lineNum":"   60","line":"\talias | wc -l","class":"lineCov","hits":"8","order":"558","possible_hits":"0",},
{"lineNum":"   61","line":"}"},
{"lineNum":"   62","line":"function test2-assert2-expected () {"},
{"lineNum":"   63","line":"\techo -e \'0\'","class":"lineCov","hits":"4","order":"560","possible_hits":"0",},
{"lineNum":"   64","line":"}"},
{"lineNum":"   65","line":""},
{"lineNum":"   66","line":"test_test3() { bats_test_begin \"test3\";"},
{"lineNum":"   67","line":"\ttest_folder=$(echo /tmp/test3-$$)","class":"lineCov","hits":"8","order":"567","possible_hits":"0",},
{"lineNum":"   68","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"8","order":"568","possible_hits":"0",},
{"lineNum":"   69","line":""},
{"lineNum":"   70","line":"\ttemp_dir=$TMP/test-6411","class":"lineCov","hits":"4","order":"569","possible_hits":"0",},
{"lineNum":"   71","line":"\tcd \"$temp_dir\"","class":"lineCov","hits":"8","order":"570","possible_hits":"0",},
{"lineNum":"   72","line":"}"},
{"lineNum":"   73","line":""},
{"lineNum":"   74","line":""},
{"lineNum":"   75","line":"test_test4() { bats_test_begin \"test4\";"},
{"lineNum":"   76","line":"\ttest_folder=$(echo /tmp/test4-$$)","class":"lineCov","hits":"8","order":"572","possible_hits":"0",},
{"lineNum":"   77","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"8","order":"573","possible_hits":"0",},
{"lineNum":"   78","line":""},
{"lineNum":"   79","line":"\tactual=$(test4-assert1-actual)","class":"lineCov","hits":"8","order":"574","possible_hits":"0",},
{"lineNum":"   80","line":"\texpected=$(test4-assert1-expected)","class":"lineCov","hits":"8","order":"576","possible_hits":"0",},
{"lineNum":"   81","line":"\techo \"========== actual ==========\"","class":"lineCov","hits":"4","order":"578","possible_hits":"0",},
{"lineNum":"   82","line":"\techo \"$actual\" | hexview.perl","class":"lineCov","hits":"8","order":"579","possible_hits":"0",},
{"lineNum":"   83","line":"\techo \"========= expected =========\"","class":"lineCov","hits":"4","order":"580","possible_hits":"0",},
{"lineNum":"   84","line":"\techo \"$expected\" | hexview.perl","class":"lineCov","hits":"8","order":"581","possible_hits":"0",},
{"lineNum":"   85","line":"\techo \"============================\"","class":"lineCov","hits":"4","order":"582","possible_hits":"0",},
{"lineNum":"   86","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineCov","hits":"8","order":"583","possible_hits":"0",},
{"lineNum":"   87","line":""},
{"lineNum":"   88","line":"}"},
{"lineNum":"   89","line":""},
{"lineNum":"   90","line":"function test4-assert1-actual () {"},
{"lineNum":"   91","line":"\ttypeset -f | egrep \'^\\w+\' | wc -l","class":"lineCov","hits":"12","order":"575","possible_hits":"0",},
{"lineNum":"   92","line":"}"},
{"lineNum":"   93","line":"function test4-assert1-expected () {"},
{"lineNum":"   94","line":"\techo -e \'10\'","class":"lineCov","hits":"4","order":"577","possible_hits":"0",},
{"lineNum":"   95","line":"}"},
{"lineNum":"   96","line":""},
{"lineNum":"   97","line":"test_test5() { bats_test_begin \"test5\";"},
{"lineNum":"   98","line":"\ttest_folder=$(echo /tmp/test5-$$)","class":"lineCov","hits":"8","order":"584","possible_hits":"0",},
{"lineNum":"   99","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"8","order":"585","possible_hits":"0",},
{"lineNum":"  100","line":""},
{"lineNum":"  101","line":"\talias tab-sort=\"sort -t $\'\\t\'\"","class":"lineCov","hits":"4","order":"586","possible_hits":"0",},
{"lineNum":"  102","line":"\talias colon-sort=\"sort $SORT_COL2 -t \':\'\"","class":"lineCov","hits":"4","order":"587","possible_hits":"0",},
{"lineNum":"  103","line":"\talias colon-sort-rev-num=\'colon-sort -rn\'","class":"lineCov","hits":"4","order":"588","possible_hits":"0",},
{"lineNum":"  104","line":"\tfunction echoize { perl -00 -pe \'s/\\n(.)/ $1/g;\'; }"},
{"lineNum":"  105","line":"}"},
{"lineNum":"  106","line":""},
{"lineNum":"  107","line":""},
{"lineNum":"  108","line":"test_test6() { bats_test_begin \"test6\";"},
{"lineNum":"  109","line":"\ttest_folder=$(echo /tmp/test6-$$)","class":"lineCov","hits":"8","order":"589","possible_hits":"0",},
{"lineNum":"  110","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"8","order":"590","possible_hits":"0",},
{"lineNum":"  111","line":""},
{"lineNum":"  112","line":"}"},
{"lineNum":"  113","line":""},
{"lineNum":"  114","line":""},
{"lineNum":"  115","line":"test_test7() { bats_test_begin \"test7\";"},
{"lineNum":"  116","line":"\ttest_folder=$(echo /tmp/test7-$$)","class":"lineCov","hits":"8","order":"591","possible_hits":"0",},
{"lineNum":"  117","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"8","order":"592","possible_hits":"0",},
{"lineNum":"  118","line":""},
{"lineNum":"  119","line":"\trm -rf ./*","class":"lineCov","hits":"4","order":"593","possible_hits":"0",},
{"lineNum":"  120","line":"\tman printf > pf_manual.txt","class":"lineCov","hits":"4","order":"594","possible_hits":"0",},
{"lineNum":"  121","line":"\tcat pf_manual.txt | tab-sort","class":"lineCov","hits":"12","order":"595","possible_hits":"0",},
{"lineNum":"  122","line":"}"},
{"lineNum":"  123","line":""},
{"lineNum":"  124","line":""},
{"lineNum":"  125","line":"test_test8() { bats_test_begin \"test8\";"},
{"lineNum":"  126","line":"\ttest_folder=$(echo /tmp/test8-$$)","class":"lineCov","hits":"8","order":"596","possible_hits":"0",},
{"lineNum":"  127","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"8","order":"597","possible_hits":"0",},
{"lineNum":"  128","line":""},
{"lineNum":"  129","line":"}"},
{"lineNum":"  130","line":""},
{"lineNum":"  131","line":""},
{"lineNum":"  132","line":"test_test9() { bats_test_begin \"test9\";"},
{"lineNum":"  133","line":"\ttest_folder=$(echo /tmp/test9-$$)","class":"lineCov","hits":"8","order":"598","possible_hits":"0",},
{"lineNum":"  134","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"8","order":"599","possible_hits":"0",},
{"lineNum":"  135","line":""},
{"lineNum":"  136","line":"\tcat pf_manual.txt | colon-sort","class":"lineCov","hits":"12","order":"600","possible_hits":"0",},
{"lineNum":"  137","line":"}"},
{"lineNum":"  138","line":""},
{"lineNum":"  139","line":""},
{"lineNum":"  140","line":"test_test10() { bats_test_begin \"test10\";"},
{"lineNum":"  141","line":"\ttest_folder=$(echo /tmp/test10-$$)","class":"lineCov","hits":"8","order":"601","possible_hits":"0",},
{"lineNum":"  142","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"8","order":"602","possible_hits":"0",},
{"lineNum":"  143","line":""},
{"lineNum":"  144","line":"}"},
{"lineNum":"  145","line":""},
{"lineNum":"  146","line":""},
{"lineNum":"  147","line":"test_test11() { bats_test_begin \"test11\";"},
{"lineNum":"  148","line":"\ttest_folder=$(echo /tmp/test11-$$)","class":"lineCov","hits":"8","order":"603","possible_hits":"0",},
{"lineNum":"  149","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"8","order":"604","possible_hits":"0",},
{"lineNum":"  150","line":""},
{"lineNum":"  151","line":"\t\'\' syntax.","class":"lineCov","hits":"8","order":"605","possible_hits":"0",},
{"lineNum":"  152","line":"}"},
{"lineNum":"  153","line":""},
{"lineNum":"  154","line":""},
{"lineNum":"  155","line":"test_test12() { bats_test_begin \"test12\";"},
{"lineNum":"  156","line":"\ttest_folder=$(echo /tmp/test12-$$)","class":"lineCov","hits":"8","order":"606","possible_hits":"0",},
{"lineNum":"  157","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"8","order":"607","possible_hits":"0",},
{"lineNum":"  158","line":""},
{"lineNum":"  159","line":"\t\'\' syntax.","class":"lineCov","hits":"8","order":"608","possible_hits":"0",},
{"lineNum":"  160","line":"}"},
{"lineNum":"  161","line":""},
{"lineNum":"  162","line":""},
{"lineNum":"  163","line":"test_test13() { bats_test_begin \"test13\";"},
{"lineNum":"  164","line":"\ttest_folder=$(echo /tmp/test13-$$)","class":"lineCov","hits":"8","order":"609","possible_hits":"0",},
{"lineNum":"  165","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"8","order":"610","possible_hits":"0",},
{"lineNum":"  166","line":""},
{"lineNum":"  167","line":"\tuname -a > linux-info.txt","class":"lineCov","hits":"4","order":"611","possible_hits":"0",},
{"lineNum":"  168","line":"}"},
{"lineNum":"  169","line":""},
{"lineNum":"  170","line":""},
{"lineNum":"  171","line":"test_test14() { bats_test_begin \"test14\";"},
{"lineNum":"  172","line":"\ttest_folder=$(echo /tmp/test14-$$)","class":"lineCov","hits":"8","order":"612","possible_hits":"0",},
{"lineNum":"  173","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"8","order":"613","possible_hits":"0",},
{"lineNum":"  174","line":""},
{"lineNum":"  175","line":"}"},
{"lineNum":"  176","line":""},
{"lineNum":"  177","line":""},
{"lineNum":"  178","line":"test_test15() { bats_test_begin \"test15\";"},
{"lineNum":"  179","line":"\ttest_folder=$(echo /tmp/test15-$$)","class":"lineCov","hits":"8","order":"614","possible_hits":"0",},
{"lineNum":"  180","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"8","order":"615","possible_hits":"0",},
{"lineNum":"  181","line":""},
{"lineNum":"  182","line":"\t\'\' syntax.","class":"lineCov","hits":"8","order":"616","possible_hits":"0",},
{"lineNum":"  183","line":"}"},
{"lineNum":"  184","line":""},
{"lineNum":"  185","line":"bats_test_function --tags \'\' test_test0","class":"lineCov","hits":"36","order":"331","possible_hits":"0",},
{"lineNum":"  186","line":"bats_test_function --tags \'\' test_test1","class":"lineCov","hits":"36","order":"334","possible_hits":"0",},
{"lineNum":"  187","line":"bats_test_function --tags \'\' test_test2","class":"lineCov","hits":"36","order":"335","possible_hits":"0",},
{"lineNum":"  188","line":"bats_test_function --tags \'\' test_test3","class":"lineCov","hits":"36","order":"336","possible_hits":"0",},
{"lineNum":"  189","line":"bats_test_function --tags \'\' test_test4","class":"lineCov","hits":"36","order":"337","possible_hits":"0",},
{"lineNum":"  190","line":"bats_test_function --tags \'\' test_test5","class":"lineCov","hits":"36","order":"338","possible_hits":"0",},
{"lineNum":"  191","line":"bats_test_function --tags \'\' test_test6","class":"lineCov","hits":"36","order":"339","possible_hits":"0",},
{"lineNum":"  192","line":"bats_test_function --tags \'\' test_test7","class":"lineCov","hits":"36","order":"340","possible_hits":"0",},
{"lineNum":"  193","line":"bats_test_function --tags \'\' test_test8","class":"lineCov","hits":"36","order":"341","possible_hits":"0",},
{"lineNum":"  194","line":"bats_test_function --tags \'\' test_test9","class":"lineCov","hits":"36","order":"342","possible_hits":"0",},
{"lineNum":"  195","line":"bats_test_function --tags \'\' test_test10","class":"lineCov","hits":"36","order":"343","possible_hits":"0",},
{"lineNum":"  196","line":"bats_test_function --tags \'\' test_test11","class":"lineCov","hits":"36","order":"344","possible_hits":"0",},
{"lineNum":"  197","line":"bats_test_function --tags \'\' test_test12","class":"lineCov","hits":"36","order":"345","possible_hits":"0",},
{"lineNum":"  198","line":"bats_test_function --tags \'\' test_test13","class":"lineCov","hits":"36","order":"346","possible_hits":"0",},
{"lineNum":"  199","line":"bats_test_function --tags \'\' test_test14","class":"lineCov","hits":"36","order":"347","possible_hits":"0",},
{"lineNum":"  200","line":"bats_test_function --tags \'\' test_test15","class":"lineCov","hits":"36","order":"348","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "bats", "date" : "2022-09-26 10:24:42", "instrumented" : 97, "covered" : 87,};
var merged_data = [];
