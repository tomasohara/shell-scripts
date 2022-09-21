var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bats"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":""},
{"lineNum":"    4","line":"# Make executables ./tests/../ visible to PATH"},
{"lineNum":"    5","line":"PATH=\"/home/aveey/tom-project/shell-scripts/tests/../:$PATH\"","class":"lineCov","hits":"20","order":"314","possible_hits":"0",},
{"lineNum":"    6","line":""},
{"lineNum":"    7","line":"# Source files"},
{"lineNum":"    8","line":"shopt -s expand_aliases","class":"lineCov","hits":"20","order":"330","possible_hits":"0",},
{"lineNum":"    9","line":""},
{"lineNum":"   10","line":""},
{"lineNum":"   11","line":"test_test0() { bats_test_begin \"test0\";"},
{"lineNum":"   12","line":"\ttest_folder=$(echo /tmp/test0-$$)","class":"lineCov","hits":"4","order":"426","possible_hits":"0",},
{"lineNum":"   13","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"427","possible_hits":"0",},
{"lineNum":"   14","line":""},
{"lineNum":"   15","line":"}"},
{"lineNum":"   16","line":""},
{"lineNum":"   17","line":""},
{"lineNum":"   18","line":"test_test1() { bats_test_begin \"test1\";"},
{"lineNum":"   19","line":"\ttest_folder=$(echo /tmp/test1-$$)","class":"lineCov","hits":"4","order":"467","possible_hits":"0",},
{"lineNum":"   20","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"468","possible_hits":"0",},
{"lineNum":"   21","line":""},
{"lineNum":"   22","line":"\tunalias -a","class":"lineCov","hits":"2","order":"469","possible_hits":"0",},
{"lineNum":"   23","line":"\talias | wc -l","class":"lineCov","hits":"4","order":"470","possible_hits":"0",},
{"lineNum":"   24","line":"\tfor f in $(typeset -f | egrep \'^\\w+\'); do unset -f $f; done","class":"lineCov","hits":"58","order":"471","possible_hits":"0",},
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
{"lineNum":"   44","line":"\ttest_folder=$(echo /tmp/test2-$$)","class":"lineCov","hits":"4","order":"556","possible_hits":"0",},
{"lineNum":"   45","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"557","possible_hits":"0",},
{"lineNum":"   46","line":""},
{"lineNum":"   47","line":"\tsource _dir-aliases.bash","class":"lineCov","hits":"2","order":"558","possible_hits":"0",},
{"lineNum":"   48","line":"\tactual=$(test2-assert2-actual)","class":"lineCov","hits":"4","order":"573","possible_hits":"0",},
{"lineNum":"   49","line":"\texpected=$(test2-assert2-expected)","class":"lineCov","hits":"4","order":"575","possible_hits":"0",},
{"lineNum":"   50","line":"\techo \"========== actual ==========\"","class":"lineCov","hits":"2","order":"577","possible_hits":"0",},
{"lineNum":"   51","line":"\techo \"$actual\" | hexview.perl","class":"lineCov","hits":"4","order":"578","possible_hits":"0",},
{"lineNum":"   52","line":"\techo \"========= expected =========\"","class":"lineCov","hits":"2","order":"579","possible_hits":"0",},
{"lineNum":"   53","line":"\techo \"$expected\" | hexview.perl","class":"lineCov","hits":"4","order":"580","possible_hits":"0",},
{"lineNum":"   54","line":"\techo \"============================\"","class":"lineCov","hits":"2","order":"581","possible_hits":"0",},
{"lineNum":"   55","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineCov","hits":"2","order":"582","possible_hits":"0",},
{"lineNum":"   56","line":""},
{"lineNum":"   57","line":"}"},
{"lineNum":"   58","line":""},
{"lineNum":"   59","line":"function test2-assert2-actual () {"},
{"lineNum":"   60","line":"\talias | wc -l","class":"lineCov","hits":"4","order":"574","possible_hits":"0",},
{"lineNum":"   61","line":"}"},
{"lineNum":"   62","line":"function test2-assert2-expected () {"},
{"lineNum":"   63","line":"\techo -e \'8\'","class":"lineCov","hits":"2","order":"576","possible_hits":"0",},
{"lineNum":"   64","line":"}"},
{"lineNum":"   65","line":""},
{"lineNum":"   66","line":"test_test3() { bats_test_begin \"test3\";"},
{"lineNum":"   67","line":"\ttest_folder=$(echo /tmp/test3-$$)","class":"lineCov","hits":"4","order":"583","possible_hits":"0",},
{"lineNum":"   68","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"584","possible_hits":"0",},
{"lineNum":"   69","line":""},
{"lineNum":"   70","line":"\tactual=$(test3-assert1-actual)","class":"lineCov","hits":"4","order":"585","possible_hits":"0",},
{"lineNum":"   71","line":"\texpected=$(test3-assert1-expected)","class":"lineCov","hits":"4","order":"587","possible_hits":"0",},
{"lineNum":"   72","line":"\techo \"========== actual ==========\"","class":"lineCov","hits":"2","order":"589","possible_hits":"0",},
{"lineNum":"   73","line":"\techo \"$actual\" | hexview.perl","class":"lineCov","hits":"4","order":"590","possible_hits":"0",},
{"lineNum":"   74","line":"\techo \"========= expected =========\"","class":"lineCov","hits":"2","order":"591","possible_hits":"0",},
{"lineNum":"   75","line":"\techo \"$expected\" | hexview.perl","class":"lineCov","hits":"4","order":"592","possible_hits":"0",},
{"lineNum":"   76","line":"\techo \"============================\"","class":"lineCov","hits":"2","order":"593","possible_hits":"0",},
{"lineNum":"   77","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineCov","hits":"4","order":"594","possible_hits":"0",},
{"lineNum":"   78","line":""},
{"lineNum":"   79","line":"}"},
{"lineNum":"   80","line":""},
{"lineNum":"   81","line":"function test3-assert1-actual () {"},
{"lineNum":"   82","line":"\talias | wc -l","class":"lineCov","hits":"4","order":"586","possible_hits":"0",},
{"lineNum":"   83","line":"}"},
{"lineNum":"   84","line":"function test3-assert1-expected () {"},
{"lineNum":"   85","line":"\techo -e \'8\'","class":"lineCov","hits":"2","order":"588","possible_hits":"0",},
{"lineNum":"   86","line":"}"},
{"lineNum":"   87","line":""},
{"lineNum":"   88","line":"test_test4() { bats_test_begin \"test4\";"},
{"lineNum":"   89","line":"\ttest_folder=$(echo /tmp/test4-$$)","class":"lineCov","hits":"4","order":"596","possible_hits":"0",},
{"lineNum":"   90","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"597","possible_hits":"0",},
{"lineNum":"   91","line":""},
{"lineNum":"   92","line":"\tactual=$(test4-assert1-actual)","class":"lineCov","hits":"4","order":"598","possible_hits":"0",},
{"lineNum":"   93","line":"\texpected=$(test4-assert1-expected)","class":"lineCov","hits":"4","order":"600","possible_hits":"0",},
{"lineNum":"   94","line":"\techo \"========== actual ==========\"","class":"lineCov","hits":"2","order":"602","possible_hits":"0",},
{"lineNum":"   95","line":"\techo \"$actual\" | hexview.perl","class":"lineCov","hits":"4","order":"603","possible_hits":"0",},
{"lineNum":"   96","line":"\techo \"========= expected =========\"","class":"lineCov","hits":"2","order":"604","possible_hits":"0",},
{"lineNum":"   97","line":"\techo \"$expected\" | hexview.perl","class":"lineCov","hits":"4","order":"605","possible_hits":"0",},
{"lineNum":"   98","line":"\techo \"============================\"","class":"lineCov","hits":"2","order":"606","possible_hits":"0",},
{"lineNum":"   99","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineCov","hits":"4","order":"607","possible_hits":"0",},
{"lineNum":"  100","line":""},
{"lineNum":"  101","line":"}"},
{"lineNum":"  102","line":""},
{"lineNum":"  103","line":"function test4-assert1-actual () {"},
{"lineNum":"  104","line":"\ttypeset -f | egrep \'^\\w+\' | wc -l","class":"lineCov","hits":"6","order":"599","possible_hits":"0",},
{"lineNum":"  105","line":"}"},
{"lineNum":"  106","line":"function test4-assert1-expected () {"},
{"lineNum":"  107","line":"\techo -e \'2\'","class":"lineCov","hits":"2","order":"601","possible_hits":"0",},
{"lineNum":"  108","line":"}"},
{"lineNum":"  109","line":""},
{"lineNum":"  110","line":"test_test5() { bats_test_begin \"test5\";"},
{"lineNum":"  111","line":"\ttest_folder=$(echo /tmp/test5-$$)","class":"lineCov","hits":"4","order":"608","possible_hits":"0",},
{"lineNum":"  112","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"609","possible_hits":"0",},
{"lineNum":"  113","line":""},
{"lineNum":"  114","line":"\ttemp_dir=$TMP/test-7919","class":"lineCov","hits":"2","order":"610","possible_hits":"0",},
{"lineNum":"  115","line":"\tcd \"$temp_dir\"","class":"lineCov","hits":"4","order":"611","possible_hits":"0",},
{"lineNum":"  116","line":"}"},
{"lineNum":"  117","line":""},
{"lineNum":"  118","line":""},
{"lineNum":"  119","line":"test_test6() { bats_test_begin \"test6\";"},
{"lineNum":"  120","line":"\ttest_folder=$(echo /tmp/test6-$$)","class":"lineCov","hits":"4","order":"612","possible_hits":"0",},
{"lineNum":"  121","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"613","possible_hits":"0",},
{"lineNum":"  122","line":""},
{"lineNum":"  123","line":"\t/bin/rm -rvf /tmp/test-dir-aliases/test-7919/* >| /tmp/_cleanup-test-dir-aliases.log 2>&1","class":"lineCov","hits":"2","order":"614","possible_hits":"0",},
{"lineNum":"  124","line":"}"},
{"lineNum":"  125","line":""},
{"lineNum":"  126","line":""},
{"lineNum":"  127","line":"test_test7() { bats_test_begin \"test7\";"},
{"lineNum":"  128","line":"\ttest_folder=$(echo /tmp/test7-$$)","class":"lineCov","hits":"4","order":"615","possible_hits":"0",},
{"lineNum":"  129","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"616","possible_hits":"0",},
{"lineNum":"  130","line":""},
{"lineNum":"  131","line":"\ttouch file1","class":"lineCov","hits":"2","order":"617","possible_hits":"0",},
{"lineNum":"  132","line":"}"},
{"lineNum":"  133","line":""},
{"lineNum":"  134","line":""},
{"lineNum":"  135","line":"test_test8() { bats_test_begin \"test8\";"},
{"lineNum":"  136","line":"\ttest_folder=$(echo /tmp/test8-$$)","class":"lineCov","hits":"4","order":"618","possible_hits":"0",},
{"lineNum":"  137","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"619","possible_hits":"0",},
{"lineNum":"  138","line":""},
{"lineNum":"  139","line":"\tbash $BIN_DIR/tests/_dir-aliases.bash","class":"lineCov","hits":"4","order":"620","possible_hits":"0",},
{"lineNum":"  140","line":"}"},
{"lineNum":"  141","line":""},
{"lineNum":"  142","line":""},
{"lineNum":"  143","line":"test_test9() { bats_test_begin \"test9\";"},
{"lineNum":"  144","line":"\ttest_folder=$(echo /tmp/test9-$$)","class":"lineCov","hits":"4","order":"621","possible_hits":"0",},
{"lineNum":"  145","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"622","possible_hits":"0",},
{"lineNum":"  146","line":""},
{"lineNum":"  147","line":"\tactual=$(test9-assert1-actual)","class":"lineCov","hits":"4","order":"623","possible_hits":"0",},
{"lineNum":"  148","line":"\texpected=$(test9-assert1-expected)","class":"lineCov","hits":"4","order":"625","possible_hits":"0",},
{"lineNum":"  149","line":"\techo \"========== actual ==========\"","class":"lineCov","hits":"2","order":"627","possible_hits":"0",},
{"lineNum":"  150","line":"\techo \"$actual\" | hexview.perl","class":"lineCov","hits":"4","order":"628","possible_hits":"0",},
{"lineNum":"  151","line":"\techo \"========= expected =========\"","class":"lineCov","hits":"2","order":"629","possible_hits":"0",},
{"lineNum":"  152","line":"\techo \"$expected\" | hexview.perl","class":"lineCov","hits":"4","order":"630","possible_hits":"0",},
{"lineNum":"  153","line":"\techo \"============================\"","class":"lineCov","hits":"2","order":"631","possible_hits":"0",},
{"lineNum":"  154","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineCov","hits":"4","order":"632","possible_hits":"0",},
{"lineNum":"  155","line":""},
{"lineNum":"  156","line":"}"},
{"lineNum":"  157","line":""},
{"lineNum":"  158","line":"function test9-assert1-actual () {"},
{"lineNum":"  159","line":"\tls -l | cut --characters=12-46 --complement","class":"lineCov","hits":"4","order":"624","possible_hits":"0",},
{"lineNum":"  160","line":"}"},
{"lineNum":"  161","line":"function test9-assert1-expected () {"},
{"lineNum":"  162","line":"\techo -e \'total 0-rw-rw-r-- lrwxrwxrwx -> file1\'","class":"lineCov","hits":"2","order":"626","possible_hits":"0",},
{"lineNum":"  163","line":"}"},
{"lineNum":"  164","line":""},
{"lineNum":"  165","line":"test_test10() { bats_test_begin \"test10\";"},
{"lineNum":"  166","line":"\ttest_folder=$(echo /tmp/test10-$$)","class":"lineCov","hits":"4","order":"633","possible_hits":"0",},
{"lineNum":"  167","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"634","possible_hits":"0",},
{"lineNum":"  168","line":""},
{"lineNum":"  169","line":"}"},
{"lineNum":"  170","line":""},
{"lineNum":"  171","line":""},
{"lineNum":"  172","line":"test_test11() { bats_test_begin \"test11\";"},
{"lineNum":"  173","line":"\ttest_folder=$(echo /tmp/test11-$$)","class":"lineCov","hits":"4","order":"635","possible_hits":"0",},
{"lineNum":"  174","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"636","possible_hits":"0",},
{"lineNum":"  175","line":""},
{"lineNum":"  176","line":"\tactual=$(test11-assert1-actual)","class":"lineCov","hits":"4","order":"637","possible_hits":"0",},
{"lineNum":"  177","line":"\texpected=$(test11-assert1-expected)","class":"lineCov","hits":"4","order":"639","possible_hits":"0",},
{"lineNum":"  178","line":"\techo \"========== actual ==========\"","class":"lineCov","hits":"2","order":"641","possible_hits":"0",},
{"lineNum":"  179","line":"\techo \"$actual\" | hexview.perl","class":"lineCov","hits":"4","order":"642","possible_hits":"0",},
{"lineNum":"  180","line":"\techo \"========= expected =========\"","class":"lineCov","hits":"2","order":"643","possible_hits":"0",},
{"lineNum":"  181","line":"\techo \"$expected\" | hexview.perl","class":"lineCov","hits":"4","order":"644","possible_hits":"0",},
{"lineNum":"  182","line":"\techo \"============================\"","class":"lineCov","hits":"2","order":"645","possible_hits":"0",},
{"lineNum":"  183","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineCov","hits":"4","order":"646","possible_hits":"0",},
{"lineNum":"  184","line":""},
{"lineNum":"  185","line":"}"},
{"lineNum":"  186","line":""},
{"lineNum":"  187","line":"function test11-assert1-actual () {"},
{"lineNum":"  188","line":"\tls -l | cut --characters=12-46 --complement","class":"lineCov","hits":"4","order":"638","possible_hits":"0",},
{"lineNum":"  189","line":"}"},
{"lineNum":"  190","line":"function test11-assert1-expected () {"},
{"lineNum":"  191","line":"\techo -e \'total 0-rw-rw-r-- lrwxrwxrwx -> file1lrwxrwxrwx ink -> /tmp\'","class":"lineCov","hits":"2","order":"640","possible_hits":"0",},
{"lineNum":"  192","line":"}"},
{"lineNum":"  193","line":""},
{"lineNum":"  194","line":"test_test12() { bats_test_begin \"test12\";"},
{"lineNum":"  195","line":"\ttest_folder=$(echo /tmp/test12-$$)","class":"lineCov","hits":"4","order":"647","possible_hits":"0",},
{"lineNum":"  196","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"648","possible_hits":"0",},
{"lineNum":"  197","line":""},
{"lineNum":"  198","line":"}"},
{"lineNum":"  199","line":""},
{"lineNum":"  200","line":""},
{"lineNum":"  201","line":"test_test13() { bats_test_begin \"test13\";"},
{"lineNum":"  202","line":"\ttest_folder=$(echo /tmp/test13-$$)","class":"lineCov","hits":"4","order":"649","possible_hits":"0",},
{"lineNum":"  203","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"650","possible_hits":"0",},
{"lineNum":"  204","line":""},
{"lineNum":"  205","line":"\tactual=$(test13-assert1-actual)","class":"lineCov","hits":"4","order":"651","possible_hits":"0",},
{"lineNum":"  206","line":"\texpected=$(test13-assert1-expected)","class":"lineCov","hits":"4","order":"653","possible_hits":"0",},
{"lineNum":"  207","line":"\techo \"========== actual ==========\"","class":"lineCov","hits":"2","order":"655","possible_hits":"0",},
{"lineNum":"  208","line":"\techo \"$actual\" | hexview.perl","class":"lineCov","hits":"4","order":"656","possible_hits":"0",},
{"lineNum":"  209","line":"\techo \"========= expected =========\"","class":"lineCov","hits":"2","order":"657","possible_hits":"0",},
{"lineNum":"  210","line":"\techo \"$expected\" | hexview.perl","class":"lineCov","hits":"4","order":"658","possible_hits":"0",},
{"lineNum":"  211","line":"\techo \"============================\"","class":"lineCov","hits":"2","order":"659","possible_hits":"0",},
{"lineNum":"  212","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineCov","hits":"4","order":"660","possible_hits":"0",},
{"lineNum":"  213","line":""},
{"lineNum":"  214","line":"}"},
{"lineNum":"  215","line":""},
{"lineNum":"  216","line":"function test13-assert1-actual () {"},
{"lineNum":"  217","line":"\tls -l | cut --characters=12-46 --complement","class":"lineCov","hits":"4","order":"652","possible_hits":"0",},
{"lineNum":"  218","line":"}"},
{"lineNum":"  219","line":"function test13-assert1-expected () {"},
{"lineNum":"  220","line":"\techo -e \'total 0-rw-rw-r-- lrwxrwxrwx -> file1lrwxrwxrwx ink -> /tmp/tmp\'","class":"lineCov","hits":"2","order":"654","possible_hits":"0",},
{"lineNum":"  221","line":"}"},
{"lineNum":"  222","line":""},
{"lineNum":"  223","line":"test_test14() { bats_test_begin \"test14\";"},
{"lineNum":"  224","line":"\ttest_folder=$(echo /tmp/test14-$$)","class":"lineCov","hits":"4","order":"661","possible_hits":"0",},
{"lineNum":"  225","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"662","possible_hits":"0",},
{"lineNum":"  226","line":""},
{"lineNum":"  227","line":"\talias ln-symbolic-force=\'ln-symbolic --force\'","class":"lineCov","hits":"2","order":"663","possible_hits":"0",},
{"lineNum":"  228","line":"}"},
{"lineNum":"  229","line":""},
{"lineNum":"  230","line":""},
{"lineNum":"  231","line":"test_test15() { bats_test_begin \"test15\";"},
{"lineNum":"  232","line":"\ttest_folder=$(echo /tmp/test15-$$)","class":"lineCov","hits":"4","order":"664","possible_hits":"0",},
{"lineNum":"  233","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"665","possible_hits":"0",},
{"lineNum":"  234","line":""},
{"lineNum":"  235","line":"}"},
{"lineNum":"  236","line":""},
{"lineNum":"  237","line":""},
{"lineNum":"  238","line":"test_test16() { bats_test_begin \"test16\";"},
{"lineNum":"  239","line":"\ttest_folder=$(echo /tmp/test16-$$)","class":"lineCov","hits":"4","order":"666","possible_hits":"0",},
{"lineNum":"  240","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"667","possible_hits":"0",},
{"lineNum":"  241","line":""},
{"lineNum":"  242","line":"}"},
{"lineNum":"  243","line":""},
{"lineNum":"  244","line":""},
{"lineNum":"  245","line":"test_test17() { bats_test_begin \"test17\";"},
{"lineNum":"  246","line":"\ttest_folder=$(echo /tmp/test17-$$)","class":"lineCov","hits":"4","order":"668","possible_hits":"0",},
{"lineNum":"  247","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"669","possible_hits":"0",},
{"lineNum":"  248","line":""},
{"lineNum":"  249","line":"\tactual=$(test17-assert1-actual)","class":"lineCov","hits":"4","order":"670","possible_hits":"0",},
{"lineNum":"  250","line":"\texpected=$(test17-assert1-expected)","class":"lineCov","hits":"4","order":"672","possible_hits":"0",},
{"lineNum":"  251","line":"\techo \"========== actual ==========\"","class":"lineCov","hits":"2","order":"674","possible_hits":"0",},
{"lineNum":"  252","line":"\techo \"$actual\" | hexview.perl","class":"lineCov","hits":"4","order":"675","possible_hits":"0",},
{"lineNum":"  253","line":"\techo \"========= expected =========\"","class":"lineCov","hits":"2","order":"676","possible_hits":"0",},
{"lineNum":"  254","line":"\techo \"$expected\" | hexview.perl","class":"lineCov","hits":"4","order":"677","possible_hits":"0",},
{"lineNum":"  255","line":"\techo \"============================\"","class":"lineCov","hits":"2","order":"678","possible_hits":"0",},
{"lineNum":"  256","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineCov","hits":"4","order":"679","possible_hits":"0",},
{"lineNum":"  257","line":""},
{"lineNum":"  258","line":"}"},
{"lineNum":"  259","line":""},
{"lineNum":"  260","line":"function test17-assert1-actual () {"},
{"lineNum":"  261","line":"\tls -l | cut --characters=12-46 --complement","class":"lineCov","hits":"4","order":"671","possible_hits":"0",},
{"lineNum":"  262","line":"}"},
{"lineNum":"  263","line":"function test17-assert1-expected () {"},
{"lineNum":"  264","line":"\techo -e \'total 0-rw-rw-r-- lrwxrwxrwx -> file1lrwxrwxrwx ink -> /tmp/tmp\'","class":"lineCov","hits":"2","order":"673","possible_hits":"0",},
{"lineNum":"  265","line":"}"},
{"lineNum":"  266","line":""},
{"lineNum":"  267","line":"bats_test_function --tags \'\' test_test0","class":"lineCov","hits":"20","order":"331","possible_hits":"0",},
{"lineNum":"  268","line":"bats_test_function --tags \'\' test_test1","class":"lineCov","hits":"20","order":"334","possible_hits":"0",},
{"lineNum":"  269","line":"bats_test_function --tags \'\' test_test2","class":"lineCov","hits":"20","order":"335","possible_hits":"0",},
{"lineNum":"  270","line":"bats_test_function --tags \'\' test_test3","class":"lineCov","hits":"20","order":"336","possible_hits":"0",},
{"lineNum":"  271","line":"bats_test_function --tags \'\' test_test4","class":"lineCov","hits":"20","order":"337","possible_hits":"0",},
{"lineNum":"  272","line":"bats_test_function --tags \'\' test_test5","class":"lineCov","hits":"20","order":"338","possible_hits":"0",},
{"lineNum":"  273","line":"bats_test_function --tags \'\' test_test6","class":"lineCov","hits":"20","order":"339","possible_hits":"0",},
{"lineNum":"  274","line":"bats_test_function --tags \'\' test_test7","class":"lineCov","hits":"20","order":"340","possible_hits":"0",},
{"lineNum":"  275","line":"bats_test_function --tags \'\' test_test8","class":"lineCov","hits":"20","order":"341","possible_hits":"0",},
{"lineNum":"  276","line":"bats_test_function --tags \'\' test_test9","class":"lineCov","hits":"20","order":"342","possible_hits":"0",},
{"lineNum":"  277","line":"bats_test_function --tags \'\' test_test10","class":"lineCov","hits":"20","order":"343","possible_hits":"0",},
{"lineNum":"  278","line":"bats_test_function --tags \'\' test_test11","class":"lineCov","hits":"20","order":"344","possible_hits":"0",},
{"lineNum":"  279","line":"bats_test_function --tags \'\' test_test12","class":"lineCov","hits":"20","order":"345","possible_hits":"0",},
{"lineNum":"  280","line":"bats_test_function --tags \'\' test_test13","class":"lineCov","hits":"20","order":"346","possible_hits":"0",},
{"lineNum":"  281","line":"bats_test_function --tags \'\' test_test14","class":"lineCov","hits":"20","order":"347","possible_hits":"0",},
{"lineNum":"  282","line":"bats_test_function --tags \'\' test_test15","class":"lineCov","hits":"20","order":"348","possible_hits":"0",},
{"lineNum":"  283","line":"bats_test_function --tags \'\' test_test16","class":"lineCov","hits":"20","order":"349","possible_hits":"0",},
{"lineNum":"  284","line":"bats_test_function --tags \'\' test_test17","class":"lineCov","hits":"20","order":"350","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "bats", "date" : "2022-09-21 21:58:39", "instrumented" : 146, "covered" : 136,};
var merged_data = [];
