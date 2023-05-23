var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bats"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":""},
{"lineNum":"    4","line":"# Make executables ./tests/../ visible to PATH"},
{"lineNum":"    5","line":"PATH=\"/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH\"","class":"lineCov","hits":"13","order":"333","possible_hits":"0",},
{"lineNum":"    6","line":""},
{"lineNum":"    7","line":"# Source files"},
{"lineNum":"    8","line":"shopt -s expand_aliases","class":"lineCov","hits":"13","order":"349","possible_hits":"0",},
{"lineNum":"    9","line":""},
{"lineNum":"   10","line":""},
{"lineNum":"   11","line":"test_test0() { bats_test_begin \"test0\";"},
{"lineNum":"   12","line":"\ttest_folder=$(echo /tmp/test0-$$)","class":"lineCov","hits":"4","order":"436","possible_hits":"0",},
{"lineNum":"   13","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"437","possible_hits":"0",},
{"lineNum":"   14","line":""},
{"lineNum":"   15","line":"}"},
{"lineNum":"   16","line":""},
{"lineNum":"   17","line":""},
{"lineNum":"   18","line":"test_test1() { bats_test_begin \"test1\";"},
{"lineNum":"   19","line":"\ttest_folder=$(echo /tmp/test1-$$)","class":"lineCov","hits":"4","order":"476","possible_hits":"0",},
{"lineNum":"   20","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"477","possible_hits":"0",},
{"lineNum":"   21","line":""},
{"lineNum":"   22","line":"\tunalias -a","class":"lineCov","hits":"2","order":"478","possible_hits":"0",},
{"lineNum":"   23","line":"\talias | wc -l","class":"lineCov","hits":"4","order":"479","possible_hits":"0",},
{"lineNum":"   24","line":"\tfor f in $(typeset -f | egrep \'^\\w+\'); do unset -f $f; done","class":"lineCov","hits":"66","order":"480","possible_hits":"0",},
{"lineNum":"   25","line":"\tTMP=/tmp/test-extensionless","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   26","line":"\tactual=$(test1-assert5-actual)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   27","line":"\texpected=$(test1-assert5-expected)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   28","line":"\techo \"========== actual ==========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   29","line":"\techo \"$actual\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   30","line":"\techo \"========= expected =========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   31","line":"\techo \"$expected\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   32","line":"\techo \"============================\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   33","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   34","line":""},
{"lineNum":"   35","line":"}"},
{"lineNum":"   36","line":""},
{"lineNum":"   37","line":"function test1-assert5-actual () {"},
{"lineNum":"   38","line":"\tBIN_DIR=$PWD/..","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   39","line":"}"},
{"lineNum":"   40","line":"function test1-assert5-expected () {"},
{"lineNum":"   41","line":"\techo -e \'00\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   42","line":"}"},
{"lineNum":"   43","line":""},
{"lineNum":"   44","line":"test_test2() { bats_test_begin \"test2\";"},
{"lineNum":"   45","line":"\ttest_folder=$(echo /tmp/test2-$$)","class":"lineCov","hits":"4","order":"572","possible_hits":"0",},
{"lineNum":"   46","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"573","possible_hits":"0",},
{"lineNum":"   47","line":""},
{"lineNum":"   48","line":"\tactual=$(test2-assert1-actual)","class":"lineCov","hits":"4","order":"574","possible_hits":"0",},
{"lineNum":"   49","line":"\texpected=$(test2-assert1-expected)","class":"lineCov","hits":"4","order":"576","possible_hits":"0",},
{"lineNum":"   50","line":"\techo \"========== actual ==========\"","class":"lineCov","hits":"2","order":"578","possible_hits":"0",},
{"lineNum":"   51","line":"\techo \"$actual\" | hexview.perl","class":"lineCov","hits":"4","order":"579","possible_hits":"0",},
{"lineNum":"   52","line":"\techo \"========= expected =========\"","class":"lineCov","hits":"2","order":"580","possible_hits":"0",},
{"lineNum":"   53","line":"\techo \"$expected\" | hexview.perl","class":"lineCov","hits":"4","order":"581","possible_hits":"0",},
{"lineNum":"   54","line":"\techo \"============================\"","class":"lineCov","hits":"2","order":"582","possible_hits":"0",},
{"lineNum":"   55","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineCov","hits":"2","order":"583","possible_hits":"0",},
{"lineNum":"   56","line":""},
{"lineNum":"   57","line":"}"},
{"lineNum":"   58","line":""},
{"lineNum":"   59","line":"function test2-assert1-actual () {"},
{"lineNum":"   60","line":"\talias | wc -l","class":"lineCov","hits":"4","order":"575","possible_hits":"0",},
{"lineNum":"   61","line":"}"},
{"lineNum":"   62","line":"function test2-assert1-expected () {"},
{"lineNum":"   63","line":"\techo -e \'0\'","class":"lineCov","hits":"2","order":"577","possible_hits":"0",},
{"lineNum":"   64","line":"}"},
{"lineNum":"   65","line":""},
{"lineNum":"   66","line":"test_test3() { bats_test_begin \"test3\";"},
{"lineNum":"   67","line":"\ttest_folder=$(echo /tmp/test3-$$)","class":"lineCov","hits":"4","order":"584","possible_hits":"0",},
{"lineNum":"   68","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"585","possible_hits":"0",},
{"lineNum":"   69","line":""},
{"lineNum":"   70","line":"\ttemp_dir=$TMP/test-3570","class":"lineCov","hits":"2","order":"586","possible_hits":"0",},
{"lineNum":"   71","line":"\tmkdir -p \"$temp_dir\"","class":"lineCov","hits":"4","order":"587","possible_hits":"0",},
{"lineNum":"   72","line":"\tcd \"$temp_dir\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   73","line":"}"},
{"lineNum":"   74","line":""},
{"lineNum":"   75","line":""},
{"lineNum":"   76","line":"test_test4() { bats_test_begin \"test4\";"},
{"lineNum":"   77","line":"\ttest_folder=$(echo /tmp/test4-$$)","class":"lineCov","hits":"4","order":"589","possible_hits":"0",},
{"lineNum":"   78","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"590","possible_hits":"0",},
{"lineNum":"   79","line":""},
{"lineNum":"   80","line":"\talias testnum=\"sed -r \"s/[0-9,A-F,a-f]/X/g\"\"","class":"lineCov","hits":"2","order":"591","possible_hits":"0",},
{"lineNum":"   81","line":"\talias testuser=\"sed -r \"s/\"$USER\"+/user/g\"\"","class":"lineCov","hits":"2","order":"592","possible_hits":"0",},
{"lineNum":"   82","line":"}"},
{"lineNum":"   83","line":""},
{"lineNum":"   84","line":""},
{"lineNum":"   85","line":"test_test5() { bats_test_begin \"test5\";"},
{"lineNum":"   86","line":"\ttest_folder=$(echo /tmp/test5-$$)","class":"lineCov","hits":"4","order":"593","possible_hits":"0",},
{"lineNum":"   87","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"594","possible_hits":"0",},
{"lineNum":"   88","line":""},
{"lineNum":"   89","line":"\tactual=$(test5-assert1-actual)","class":"lineCov","hits":"4","order":"595","possible_hits":"0",},
{"lineNum":"   90","line":"\texpected=$(test5-assert1-expected)","class":"lineCov","hits":"4","order":"597","possible_hits":"0",},
{"lineNum":"   91","line":"\techo \"========== actual ==========\"","class":"lineCov","hits":"2","order":"599","possible_hits":"0",},
{"lineNum":"   92","line":"\techo \"$actual\" | hexview.perl","class":"lineCov","hits":"4","order":"600","possible_hits":"0",},
{"lineNum":"   93","line":"\techo \"========= expected =========\"","class":"lineCov","hits":"2","order":"601","possible_hits":"0",},
{"lineNum":"   94","line":"\techo \"$expected\" | hexview.perl","class":"lineCov","hits":"4","order":"602","possible_hits":"0",},
{"lineNum":"   95","line":"\techo \"============================\"","class":"lineCov","hits":"2","order":"603","possible_hits":"0",},
{"lineNum":"   96","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineCov","hits":"4","order":"604","possible_hits":"0",},
{"lineNum":"   97","line":""},
{"lineNum":"   98","line":"}"},
{"lineNum":"   99","line":""},
{"lineNum":"  100","line":"function test5-assert1-actual () {"},
{"lineNum":"  101","line":"\ttypeset -f | egrep \'^\\w+\' | wc -l","class":"lineCov","hits":"6","order":"596","possible_hits":"0",},
{"lineNum":"  102","line":"}"},
{"lineNum":"  103","line":"function test5-assert1-expected () {"},
{"lineNum":"  104","line":"\techo -e \'30\'","class":"lineCov","hits":"2","order":"598","possible_hits":"0",},
{"lineNum":"  105","line":"}"},
{"lineNum":"  106","line":""},
{"lineNum":"  107","line":"test_test6() { bats_test_begin \"test6\";"},
{"lineNum":"  108","line":"\ttest_folder=$(echo /tmp/test6-$$)","class":"lineCov","hits":"4","order":"605","possible_hits":"0",},
{"lineNum":"  109","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"606","possible_hits":"0",},
{"lineNum":"  110","line":""},
{"lineNum":"  111","line":"\tpwd","class":"lineCov","hits":"2","order":"607","possible_hits":"0",},
{"lineNum":"  112","line":"\trm -rf ./*","class":"lineCov","hits":"2","order":"608","possible_hits":"0",},
{"lineNum":"  113","line":"}"},
{"lineNum":"  114","line":""},
{"lineNum":"  115","line":""},
{"lineNum":"  116","line":"test_test7() { bats_test_begin \"test7\";"},
{"lineNum":"  117","line":"\ttest_folder=$(echo /tmp/test7-$$)","class":"lineCov","hits":"4","order":"609","possible_hits":"0",},
{"lineNum":"  118","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"610","possible_hits":"0",},
{"lineNum":"  119","line":""},
{"lineNum":"  120","line":"\tsource $BIN_DIR/tomohara-aliases.bash","class":"lineCov","hits":"2","order":"611","possible_hits":"0",},
{"lineNum":"  121","line":"}"},
{"lineNum":"  122","line":""},
{"lineNum":"  123","line":""},
{"lineNum":"  124","line":"test_test8() { bats_test_begin \"test8\";"},
{"lineNum":"  125","line":"\ttest_folder=$(echo /tmp/test8-$$)","class":"lineCov","hits":"4","order":"613","possible_hits":"0",},
{"lineNum":"  126","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"614","possible_hits":"0",},
{"lineNum":"  127","line":""},
{"lineNum":"  128","line":"\tactual=$(test8-assert1-actual)","class":"lineCov","hits":"7","order":"615","possible_hits":"0",},
{"lineNum":"  129","line":"\texpected=$(test8-assert1-expected)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  130","line":"\techo \"========== actual ==========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  131","line":"\techo \"$actual\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  132","line":"\techo \"========= expected =========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  133","line":"\techo \"$expected\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  134","line":"\techo \"============================\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  135","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  136","line":""},
{"lineNum":"  137","line":"}"},
{"lineNum":"  138","line":""},
{"lineNum":"  139","line":"function test8-assert1-actual () {"},
{"lineNum":"  140","line":"\tshow-unicode-code-info-aux ./version1.txt | testnum","class":"lineCov","hits":"6","order":"616","possible_hits":"0",},
{"lineNum":"  141","line":"}"},
{"lineNum":"  142","line":"function test8-assert1-expected () {"},
{"lineNum":"  143","line":"\techo -e \'XhXr\\torX\\toXXsXt\\tXnXoXingX.XX.X-XX-gXnXriX: XXX\\tXXXX\\tX\\tXX.\\tXXXX\\tX\\tXXX\\tXXXX\\tX\\tXXX\\tXXXX\\tX\\tXX.\\tXXXX\\tX\\tXXX\\tXXXX\\tX\\tXX-\\tXXXX\\tX\\tXXX\\tXXXX\\tX\\tXXX\\tXXXX\\tX\\tXX-\\tXXXX\\tX\\tXXg\\tXXXX\\tXX\\tXXX\\tXXXX\\tXX\\tXXn\\tXXXX\\tXX\\tXXX\\tXXXX\\tXX\\tXXr\\tXXXX\\tXX\\tXXi\\tXXXX\\tXX\\tXXX\\tXXXX\\tXX\\tXX\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  144","line":"}"},
{"lineNum":"  145","line":""},
{"lineNum":"  146","line":"test_test9() { bats_test_begin \"test9\";"},
{"lineNum":"  147","line":"\ttest_folder=$(echo /tmp/test9-$$)","class":"lineCov","hits":"4","order":"617","possible_hits":"0",},
{"lineNum":"  148","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"618","possible_hits":"0",},
{"lineNum":"  149","line":""},
{"lineNum":"  150","line":"\tactual=$(test9-assert1-actual)","class":"lineCov","hits":"7","order":"619","possible_hits":"0",},
{"lineNum":"  151","line":"\texpected=$(test9-assert1-expected)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  152","line":"\techo \"========== actual ==========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  153","line":"\techo \"$actual\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  154","line":"\techo \"========= expected =========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  155","line":"\techo \"$expected\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  156","line":"\techo \"============================\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  157","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  158","line":""},
{"lineNum":"  159","line":"}"},
{"lineNum":"  160","line":""},
{"lineNum":"  161","line":"function test9-assert1-actual () {"},
{"lineNum":"  162","line":"\tshow-unicode-code-info ./version1.txt | testnum","class":"lineCov","hits":"6","order":"620","possible_hits":"0",},
{"lineNum":"  163","line":"}"},
{"lineNum":"  164","line":"function test9-assert1-expected () {"},
{"lineNum":"  165","line":"\techo -e \'XhXr\\torX\\toXXsXt\\tXnXoXingX.XX.X-XX-gXnXriX: XXX\\tXXXX\\tX\\tXX.\\tXXXX\\tX\\tXXX\\tXXXX\\tX\\tXXX\\tXXXX\\tX\\tXX.\\tXXXX\\tX\\tXXX\\tXXXX\\tX\\tXX-\\tXXXX\\tX\\tXXX\\tXXXX\\tX\\tXXX\\tXXXX\\tX\\tXX-\\tXXXX\\tX\\tXXg\\tXXXX\\tXX\\tXXX\\tXXXX\\tXX\\tXXn\\tXXXX\\tXX\\tXXX\\tXXXX\\tXX\\tXXr\\tXXXX\\tXX\\tXXi\\tXXXX\\tXX\\tXXX\\tXXXX\\tXX\\tXX\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  166","line":"}"},
{"lineNum":"  167","line":""},
{"lineNum":"  168","line":"test_test10() { bats_test_begin \"test10\";"},
{"lineNum":"  169","line":"\ttest_folder=$(echo /tmp/test10-$$)","class":"lineCov","hits":"4","order":"621","possible_hits":"0",},
{"lineNum":"  170","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"622","possible_hits":"0",},
{"lineNum":"  171","line":""},
{"lineNum":"  172","line":"\tactual=$(test10-assert1-actual)","class":"lineCov","hits":"4","order":"623","possible_hits":"0",},
{"lineNum":"  173","line":"\texpected=$(test10-assert1-expected)","class":"lineCov","hits":"4","order":"625","possible_hits":"0",},
{"lineNum":"  174","line":"\techo \"========== actual ==========\"","class":"lineCov","hits":"2","order":"627","possible_hits":"0",},
{"lineNum":"  175","line":"\techo \"$actual\" | hexview.perl","class":"lineCov","hits":"4","order":"628","possible_hits":"0",},
{"lineNum":"  176","line":"\techo \"========= expected =========\"","class":"lineCov","hits":"2","order":"629","possible_hits":"0",},
{"lineNum":"  177","line":"\techo \"$expected\" | hexview.perl","class":"lineCov","hits":"4","order":"630","possible_hits":"0",},
{"lineNum":"  178","line":"\techo \"============================\"","class":"lineCov","hits":"2","order":"631","possible_hits":"0",},
{"lineNum":"  179","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineCov","hits":"2","order":"632","possible_hits":"0",},
{"lineNum":"  180","line":""},
{"lineNum":"  181","line":"}"},
{"lineNum":"  182","line":""},
{"lineNum":"  183","line":"function test10-assert1-actual () {"},
{"lineNum":"  184","line":"\techo \"END\"","class":"lineCov","hits":"2","order":"624","possible_hits":"0",},
{"lineNum":"  185","line":"}"},
{"lineNum":"  186","line":"function test10-assert1-expected () {"},
{"lineNum":"  187","line":"\techo -e \'END\'","class":"lineCov","hits":"2","order":"626","possible_hits":"0",},
{"lineNum":"  188","line":"}"},
{"lineNum":"  189","line":""},
{"lineNum":"  190","line":"bats_test_function --tags \'\' test_test0","class":"lineCov","hits":"13","order":"350","possible_hits":"0",},
{"lineNum":"  191","line":"bats_test_function --tags \'\' test_test1","class":"lineCov","hits":"13","order":"351","possible_hits":"0",},
{"lineNum":"  192","line":"bats_test_function --tags \'\' test_test2","class":"lineCov","hits":"13","order":"352","possible_hits":"0",},
{"lineNum":"  193","line":"bats_test_function --tags \'\' test_test3","class":"lineCov","hits":"13","order":"353","possible_hits":"0",},
{"lineNum":"  194","line":"bats_test_function --tags \'\' test_test4","class":"lineCov","hits":"13","order":"354","possible_hits":"0",},
{"lineNum":"  195","line":"bats_test_function --tags \'\' test_test5","class":"lineCov","hits":"13","order":"355","possible_hits":"0",},
{"lineNum":"  196","line":"bats_test_function --tags \'\' test_test6","class":"lineCov","hits":"13","order":"356","possible_hits":"0",},
{"lineNum":"  197","line":"bats_test_function --tags \'\' test_test7","class":"lineCov","hits":"13","order":"357","possible_hits":"0",},
{"lineNum":"  198","line":"bats_test_function --tags \'\' test_test8","class":"lineCov","hits":"13","order":"358","possible_hits":"0",},
{"lineNum":"  199","line":"bats_test_function --tags \'\' test_test9","class":"lineCov","hits":"13","order":"359","possible_hits":"0",},
{"lineNum":"  200","line":"bats_test_function --tags \'\' test_test10","class":"lineCov","hits":"13","order":"360","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "bats", "date" : "2023-05-06 21:39:03", "instrumented" : 107, "covered" : 79,};
var merged_data = [];
