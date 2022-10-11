var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bats"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":""},
{"lineNum":"    4","line":"# Make executables ./tests/../ visible to PATH"},
{"lineNum":"    5","line":"PATH=\"/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH\"","class":"lineCov","hits":"23","order":"314","possible_hits":"0",},
{"lineNum":"    6","line":""},
{"lineNum":"    7","line":"# Source files"},
{"lineNum":"    8","line":"shopt -s expand_aliases","class":"lineCov","hits":"23","order":"330","possible_hits":"0",},
{"lineNum":"    9","line":""},
{"lineNum":"   10","line":""},
{"lineNum":"   11","line":"test_test0() { bats_test_begin \"test0\";"},
{"lineNum":"   12","line":"\ttest_folder=$(echo /tmp/test0-$$)","class":"lineCov","hits":"4","order":"429","possible_hits":"0",},
{"lineNum":"   13","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"430","possible_hits":"0",},
{"lineNum":"   14","line":""},
{"lineNum":"   15","line":"\tbind \'set enable-bracketed-paste off\'","class":"lineCov","hits":"2","order":"431","possible_hits":"0",},
{"lineNum":"   16","line":"}"},
{"lineNum":"   17","line":""},
{"lineNum":"   18","line":""},
{"lineNum":"   19","line":"test_test1() { bats_test_begin \"test1\";"},
{"lineNum":"   20","line":"\ttest_folder=$(echo /tmp/test1-$$)","class":"lineCov","hits":"4","order":"471","possible_hits":"0",},
{"lineNum":"   21","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"472","possible_hits":"0",},
{"lineNum":"   22","line":""},
{"lineNum":"   23","line":"}"},
{"lineNum":"   24","line":""},
{"lineNum":"   25","line":""},
{"lineNum":"   26","line":"test_test2() { bats_test_begin \"test2\";"},
{"lineNum":"   27","line":"\ttest_folder=$(echo /tmp/test2-$$)","class":"lineCov","hits":"4","order":"473","possible_hits":"0",},
{"lineNum":"   28","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"474","possible_hits":"0",},
{"lineNum":"   29","line":""},
{"lineNum":"   30","line":"\tunalias -a","class":"lineCov","hits":"2","order":"475","possible_hits":"0",},
{"lineNum":"   31","line":"\talias | wc -l","class":"lineCov","hits":"4","order":"476","possible_hits":"0",},
{"lineNum":"   32","line":"\tfor f in $(typeset -f | egrep \'^\\w+\'); do unset -f $f; done","class":"lineCov","hits":"58","order":"477","possible_hits":"0",},
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
{"lineNum":"   52","line":"\ttest_folder=$(echo /tmp/test3-$$)","class":"lineCov","hits":"4","order":"562","possible_hits":"0",},
{"lineNum":"   53","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"563","possible_hits":"0",},
{"lineNum":"   54","line":""},
{"lineNum":"   55","line":"\tmkdir -p tmp/test-dir-aliases","class":"lineCov","hits":"2","order":"564","possible_hits":"0",},
{"lineNum":"   56","line":"}"},
{"lineNum":"   57","line":""},
{"lineNum":"   58","line":""},
{"lineNum":"   59","line":"test_test4() { bats_test_begin \"test4\";"},
{"lineNum":"   60","line":"\ttest_folder=$(echo /tmp/test4-$$)","class":"lineCov","hits":"4","order":"565","possible_hits":"0",},
{"lineNum":"   61","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"566","possible_hits":"0",},
{"lineNum":"   62","line":""},
{"lineNum":"   63","line":"\tsource _dir-aliases.bash","class":"lineCov","hits":"2","order":"567","possible_hits":"0",},
{"lineNum":"   64","line":"\tactual=$(test4-assert2-actual)","class":"lineCov","hits":"4","order":"582","possible_hits":"0",},
{"lineNum":"   65","line":"\texpected=$(test4-assert2-expected)","class":"lineCov","hits":"4","order":"584","possible_hits":"0",},
{"lineNum":"   66","line":"\techo \"========== actual ==========\"","class":"lineCov","hits":"2","order":"586","possible_hits":"0",},
{"lineNum":"   67","line":"\techo \"$actual\" | hexview.perl","class":"lineCov","hits":"4","order":"587","possible_hits":"0",},
{"lineNum":"   68","line":"\techo \"========= expected =========\"","class":"lineCov","hits":"2","order":"588","possible_hits":"0",},
{"lineNum":"   69","line":"\techo \"$expected\" | hexview.perl","class":"lineCov","hits":"4","order":"589","possible_hits":"0",},
{"lineNum":"   70","line":"\techo \"============================\"","class":"lineCov","hits":"2","order":"590","possible_hits":"0",},
{"lineNum":"   71","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineCov","hits":"2","order":"591","possible_hits":"0",},
{"lineNum":"   72","line":""},
{"lineNum":"   73","line":"}"},
{"lineNum":"   74","line":""},
{"lineNum":"   75","line":"function test4-assert2-actual () {"},
{"lineNum":"   76","line":"\talias | wc -l","class":"lineCov","hits":"4","order":"583","possible_hits":"0",},
{"lineNum":"   77","line":"}"},
{"lineNum":"   78","line":"function test4-assert2-expected () {"},
{"lineNum":"   79","line":"\techo -e \'8\'","class":"lineCov","hits":"2","order":"585","possible_hits":"0",},
{"lineNum":"   80","line":"}"},
{"lineNum":"   81","line":""},
{"lineNum":"   82","line":"test_test5() { bats_test_begin \"test5\";"},
{"lineNum":"   83","line":"\ttest_folder=$(echo /tmp/test5-$$)","class":"lineCov","hits":"4","order":"592","possible_hits":"0",},
{"lineNum":"   84","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"593","possible_hits":"0",},
{"lineNum":"   85","line":""},
{"lineNum":"   86","line":"\tactual=$(test5-assert1-actual)","class":"lineCov","hits":"4","order":"594","possible_hits":"0",},
{"lineNum":"   87","line":"\texpected=$(test5-assert1-expected)","class":"lineCov","hits":"4","order":"596","possible_hits":"0",},
{"lineNum":"   88","line":"\techo \"========== actual ==========\"","class":"lineCov","hits":"2","order":"598","possible_hits":"0",},
{"lineNum":"   89","line":"\techo \"$actual\" | hexview.perl","class":"lineCov","hits":"4","order":"599","possible_hits":"0",},
{"lineNum":"   90","line":"\techo \"========= expected =========\"","class":"lineCov","hits":"2","order":"600","possible_hits":"0",},
{"lineNum":"   91","line":"\techo \"$expected\" | hexview.perl","class":"lineCov","hits":"4","order":"601","possible_hits":"0",},
{"lineNum":"   92","line":"\techo \"============================\"","class":"lineCov","hits":"2","order":"602","possible_hits":"0",},
{"lineNum":"   93","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineCov","hits":"4","order":"603","possible_hits":"0",},
{"lineNum":"   94","line":""},
{"lineNum":"   95","line":"}"},
{"lineNum":"   96","line":""},
{"lineNum":"   97","line":"function test5-assert1-actual () {"},
{"lineNum":"   98","line":"\talias | wc -l","class":"lineCov","hits":"4","order":"595","possible_hits":"0",},
{"lineNum":"   99","line":"}"},
{"lineNum":"  100","line":"function test5-assert1-expected () {"},
{"lineNum":"  101","line":"\techo -e \'8\'","class":"lineCov","hits":"2","order":"597","possible_hits":"0",},
{"lineNum":"  102","line":"}"},
{"lineNum":"  103","line":""},
{"lineNum":"  104","line":"test_test6() { bats_test_begin \"test6\";"},
{"lineNum":"  105","line":"\ttest_folder=$(echo /tmp/test6-$$)","class":"lineCov","hits":"4","order":"605","possible_hits":"0",},
{"lineNum":"  106","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"606","possible_hits":"0",},
{"lineNum":"  107","line":""},
{"lineNum":"  108","line":"\tactual=$(test6-assert1-actual)","class":"lineCov","hits":"4","order":"607","possible_hits":"0",},
{"lineNum":"  109","line":"\texpected=$(test6-assert1-expected)","class":"lineCov","hits":"4","order":"609","possible_hits":"0",},
{"lineNum":"  110","line":"\techo \"========== actual ==========\"","class":"lineCov","hits":"2","order":"611","possible_hits":"0",},
{"lineNum":"  111","line":"\techo \"$actual\" | hexview.perl","class":"lineCov","hits":"4","order":"612","possible_hits":"0",},
{"lineNum":"  112","line":"\techo \"========= expected =========\"","class":"lineCov","hits":"2","order":"613","possible_hits":"0",},
{"lineNum":"  113","line":"\techo \"$expected\" | hexview.perl","class":"lineCov","hits":"4","order":"614","possible_hits":"0",},
{"lineNum":"  114","line":"\techo \"============================\"","class":"lineCov","hits":"2","order":"615","possible_hits":"0",},
{"lineNum":"  115","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineCov","hits":"4","order":"616","possible_hits":"0",},
{"lineNum":"  116","line":""},
{"lineNum":"  117","line":"}"},
{"lineNum":"  118","line":""},
{"lineNum":"  119","line":"function test6-assert1-actual () {"},
{"lineNum":"  120","line":"\ttypeset -f | egrep \'^\\w+\' | wc -l","class":"lineCov","hits":"6","order":"608","possible_hits":"0",},
{"lineNum":"  121","line":"}"},
{"lineNum":"  122","line":"function test6-assert1-expected () {"},
{"lineNum":"  123","line":"\techo -e \'2\'","class":"lineCov","hits":"2","order":"610","possible_hits":"0",},
{"lineNum":"  124","line":"}"},
{"lineNum":"  125","line":""},
{"lineNum":"  126","line":"test_test7() { bats_test_begin \"test7\";"},
{"lineNum":"  127","line":"\ttest_folder=$(echo /tmp/test7-$$)","class":"lineCov","hits":"4","order":"617","possible_hits":"0",},
{"lineNum":"  128","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"618","possible_hits":"0",},
{"lineNum":"  129","line":""},
{"lineNum":"  130","line":"\ttemp_dir=$TMP/test-7919","class":"lineCov","hits":"2","order":"619","possible_hits":"0",},
{"lineNum":"  131","line":"\tcd \"$temp_dir\"","class":"lineCov","hits":"4","order":"620","possible_hits":"0",},
{"lineNum":"  132","line":"}"},
{"lineNum":"  133","line":""},
{"lineNum":"  134","line":""},
{"lineNum":"  135","line":"test_test8() { bats_test_begin \"test8\";"},
{"lineNum":"  136","line":"\ttest_folder=$(echo /tmp/test8-$$)","class":"lineCov","hits":"4","order":"621","possible_hits":"0",},
{"lineNum":"  137","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"622","possible_hits":"0",},
{"lineNum":"  138","line":""},
{"lineNum":"  139","line":"\t/bin/rm -rvf /tmp/test-dir-aliases/test-7919/* >| /tmp/_cleanup-test-dir-aliases.log 2>&1","class":"lineCov","hits":"2","order":"623","possible_hits":"0",},
{"lineNum":"  140","line":"}"},
{"lineNum":"  141","line":""},
{"lineNum":"  142","line":""},
{"lineNum":"  143","line":"test_test9() { bats_test_begin \"test9\";"},
{"lineNum":"  144","line":"\ttest_folder=$(echo /tmp/test9-$$)","class":"lineCov","hits":"4","order":"624","possible_hits":"0",},
{"lineNum":"  145","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"625","possible_hits":"0",},
{"lineNum":"  146","line":""},
{"lineNum":"  147","line":"\ttouch file1","class":"lineCov","hits":"2","order":"626","possible_hits":"0",},
{"lineNum":"  148","line":"}"},
{"lineNum":"  149","line":""},
{"lineNum":"  150","line":""},
{"lineNum":"  151","line":"test_test10() { bats_test_begin \"test10\";"},
{"lineNum":"  152","line":"\ttest_folder=$(echo /tmp/test10-$$)","class":"lineCov","hits":"4","order":"627","possible_hits":"0",},
{"lineNum":"  153","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"628","possible_hits":"0",},
{"lineNum":"  154","line":""},
{"lineNum":"  155","line":"\tbash $BIN_DIR/tests/_dir-aliases.bash","class":"lineCov","hits":"4","order":"629","possible_hits":"0",},
{"lineNum":"  156","line":"}"},
{"lineNum":"  157","line":""},
{"lineNum":"  158","line":""},
{"lineNum":"  159","line":"test_test11() { bats_test_begin \"test11\";"},
{"lineNum":"  160","line":"\ttest_folder=$(echo /tmp/test11-$$)","class":"lineCov","hits":"4","order":"630","possible_hits":"0",},
{"lineNum":"  161","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"631","possible_hits":"0",},
{"lineNum":"  162","line":""},
{"lineNum":"  163","line":"\tactual=$(test11-assert1-actual)","class":"lineCov","hits":"7","order":"632","possible_hits":"0",},
{"lineNum":"  164","line":"\texpected=$(test11-assert1-expected)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  165","line":"\techo \"========== actual ==========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  166","line":"\techo \"$actual\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  167","line":"\techo \"========= expected =========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  168","line":"\techo \"$expected\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  169","line":"\techo \"============================\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  170","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  171","line":""},
{"lineNum":"  172","line":"}"},
{"lineNum":"  173","line":""},
{"lineNum":"  174","line":"function test11-assert1-actual () {"},
{"lineNum":"  175","line":"\tsymlinks-proper","class":"lineCov","hits":"4","order":"633","possible_hits":"0",},
{"lineNum":"  176","line":"}"},
{"lineNum":"  177","line":"function test11-assert1-expected () {"},
{"lineNum":"  178","line":"\techo -e \'bash: sublinks: command not found\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  179","line":"}"},
{"lineNum":"  180","line":""},
{"lineNum":"  181","line":"test_test12() { bats_test_begin \"test12\";"},
{"lineNum":"  182","line":"\ttest_folder=$(echo /tmp/test12-$$)","class":"lineCov","hits":"4","order":"634","possible_hits":"0",},
{"lineNum":"  183","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"635","possible_hits":"0",},
{"lineNum":"  184","line":""},
{"lineNum":"  185","line":"}"},
{"lineNum":"  186","line":""},
{"lineNum":"  187","line":""},
{"lineNum":"  188","line":"test_test13() { bats_test_begin \"test13\";"},
{"lineNum":"  189","line":"\ttest_folder=$(echo /tmp/test13-$$)","class":"lineCov","hits":"4","order":"636","possible_hits":"0",},
{"lineNum":"  190","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"637","possible_hits":"0",},
{"lineNum":"  191","line":""},
{"lineNum":"  192","line":"\tactual=$(test13-assert1-actual)","class":"lineCov","hits":"4","order":"638","possible_hits":"0",},
{"lineNum":"  193","line":"\texpected=$(test13-assert1-expected)","class":"lineCov","hits":"4","order":"640","possible_hits":"0",},
{"lineNum":"  194","line":"\techo \"========== actual ==========\"","class":"lineCov","hits":"2","order":"642","possible_hits":"0",},
{"lineNum":"  195","line":"\techo \"$actual\" | hexview.perl","class":"lineCov","hits":"4","order":"643","possible_hits":"0",},
{"lineNum":"  196","line":"\techo \"========= expected =========\"","class":"lineCov","hits":"2","order":"644","possible_hits":"0",},
{"lineNum":"  197","line":"\techo \"$expected\" | hexview.perl","class":"lineCov","hits":"4","order":"645","possible_hits":"0",},
{"lineNum":"  198","line":"\techo \"============================\"","class":"lineCov","hits":"2","order":"646","possible_hits":"0",},
{"lineNum":"  199","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineCov","hits":"4","order":"647","possible_hits":"0",},
{"lineNum":"  200","line":""},
{"lineNum":"  201","line":"}"},
{"lineNum":"  202","line":""},
{"lineNum":"  203","line":"function test13-assert1-actual () {"},
{"lineNum":"  204","line":"\tls -l | cut --characters=12-46 --complement","class":"lineCov","hits":"4","order":"639","possible_hits":"0",},
{"lineNum":"  205","line":"}"},
{"lineNum":"  206","line":"function test13-assert1-expected () {"},
{"lineNum":"  207","line":"\techo -e \'total 0-rw-rw-r-- lrwxrwxrwx -> file1lrwxrwxrwx ink -> /tmp\'","class":"lineCov","hits":"2","order":"641","possible_hits":"0",},
{"lineNum":"  208","line":"}"},
{"lineNum":"  209","line":""},
{"lineNum":"  210","line":"test_test14() { bats_test_begin \"test14\";"},
{"lineNum":"  211","line":"\ttest_folder=$(echo /tmp/test14-$$)","class":"lineCov","hits":"4","order":"648","possible_hits":"0",},
{"lineNum":"  212","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"649","possible_hits":"0",},
{"lineNum":"  213","line":""},
{"lineNum":"  214","line":"\talias ln-symbolic-force=\'ln-symbolic --force\'","class":"lineCov","hits":"2","order":"650","possible_hits":"0",},
{"lineNum":"  215","line":"}"},
{"lineNum":"  216","line":""},
{"lineNum":"  217","line":""},
{"lineNum":"  218","line":"test_test15() { bats_test_begin \"test15\";"},
{"lineNum":"  219","line":"\ttest_folder=$(echo /tmp/test15-$$)","class":"lineCov","hits":"4","order":"651","possible_hits":"0",},
{"lineNum":"  220","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"652","possible_hits":"0",},
{"lineNum":"  221","line":""},
{"lineNum":"  222","line":"\tactual=$(test15-assert1-actual)","class":"lineCov","hits":"7","order":"653","possible_hits":"0",},
{"lineNum":"  223","line":"\texpected=$(test15-assert1-expected)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  224","line":"\techo \"========== actual ==========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  225","line":"\techo \"$actual\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  226","line":"\techo \"========= expected =========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  227","line":"\techo \"$expected\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  228","line":"\techo \"============================\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  229","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  230","line":""},
{"lineNum":"  231","line":"}"},
{"lineNum":"  232","line":""},
{"lineNum":"  233","line":"function test15-assert1-actual () {"},
{"lineNum":"  234","line":"\tln-symbolic-force /tmp temp-link","class":"lineCov","hits":"4","order":"654","possible_hits":"0",},
{"lineNum":"  235","line":"}"},
{"lineNum":"  236","line":"function test15-assert1-expected () {"},
{"lineNum":"  237","line":"\techo -e \"ln: failed to create symbolic link \'temp-link/tmp\': File exists\'temp-link/tmp\' -> \'/tmp\'\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  238","line":"}"},
{"lineNum":"  239","line":""},
{"lineNum":"  240","line":"test_test16() { bats_test_begin \"test16\";"},
{"lineNum":"  241","line":"\ttest_folder=$(echo /tmp/test16-$$)","class":"lineCov","hits":"4","order":"655","possible_hits":"0",},
{"lineNum":"  242","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"656","possible_hits":"0",},
{"lineNum":"  243","line":""},
{"lineNum":"  244","line":"}"},
{"lineNum":"  245","line":""},
{"lineNum":"  246","line":""},
{"lineNum":"  247","line":"test_test17() { bats_test_begin \"test17\";"},
{"lineNum":"  248","line":"\ttest_folder=$(echo /tmp/test17-$$)","class":"lineCov","hits":"4","order":"657","possible_hits":"0",},
{"lineNum":"  249","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"658","possible_hits":"0",},
{"lineNum":"  250","line":""},
{"lineNum":"  251","line":"}"},
{"lineNum":"  252","line":""},
{"lineNum":"  253","line":""},
{"lineNum":"  254","line":"test_test18() { bats_test_begin \"test18\";"},
{"lineNum":"  255","line":"\ttest_folder=$(echo /tmp/test18-$$)","class":"lineCov","hits":"4","order":"659","possible_hits":"0",},
{"lineNum":"  256","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"660","possible_hits":"0",},
{"lineNum":"  257","line":""},
{"lineNum":"  258","line":"\tactual=$(test18-assert1-actual)","class":"lineCov","hits":"4","order":"661","possible_hits":"0",},
{"lineNum":"  259","line":"\texpected=$(test18-assert1-expected)","class":"lineCov","hits":"4","order":"663","possible_hits":"0",},
{"lineNum":"  260","line":"\techo \"========== actual ==========\"","class":"lineCov","hits":"2","order":"665","possible_hits":"0",},
{"lineNum":"  261","line":"\techo \"$actual\" | hexview.perl","class":"lineCov","hits":"4","order":"666","possible_hits":"0",},
{"lineNum":"  262","line":"\techo \"========= expected =========\"","class":"lineCov","hits":"2","order":"667","possible_hits":"0",},
{"lineNum":"  263","line":"\techo \"$expected\" | hexview.perl","class":"lineCov","hits":"4","order":"668","possible_hits":"0",},
{"lineNum":"  264","line":"\techo \"============================\"","class":"lineCov","hits":"2","order":"669","possible_hits":"0",},
{"lineNum":"  265","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineCov","hits":"4","order":"670","possible_hits":"0",},
{"lineNum":"  266","line":""},
{"lineNum":"  267","line":"}"},
{"lineNum":"  268","line":""},
{"lineNum":"  269","line":"function test18-assert1-actual () {"},
{"lineNum":"  270","line":"\tls -l | cut --characters=12-46 --complement","class":"lineCov","hits":"4","order":"662","possible_hits":"0",},
{"lineNum":"  271","line":"}"},
{"lineNum":"  272","line":"function test18-assert1-expected () {"},
{"lineNum":"  273","line":"\techo -e \'total 0-rw-rw-r-- lrwxrwxrwx -> file1lrwxrwxrwx ink -> /tmplrwxrwxrwx ink-safe -> /tmp/tmp\'","class":"lineCov","hits":"2","order":"664","possible_hits":"0",},
{"lineNum":"  274","line":"}"},
{"lineNum":"  275","line":""},
{"lineNum":"  276","line":"test_test19() { bats_test_begin \"test19\";"},
{"lineNum":"  277","line":"\ttest_folder=$(echo /tmp/test19-$$)","class":"lineCov","hits":"4","order":"671","possible_hits":"0",},
{"lineNum":"  278","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"672","possible_hits":"0",},
{"lineNum":"  279","line":""},
{"lineNum":"  280","line":"\tactual=$(test19-assert1-actual)","class":"lineCov","hits":"7","order":"673","possible_hits":"0",},
{"lineNum":"  281","line":"\texpected=$(test19-assert1-expected)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  282","line":"\techo \"========== actual ==========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  283","line":"\techo \"$actual\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  284","line":"\techo \"========= expected =========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  285","line":"\techo \"$expected\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  286","line":"\techo \"============================\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  287","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  288","line":""},
{"lineNum":"  289","line":"}"},
{"lineNum":"  290","line":""},
{"lineNum":"  291","line":"function test19-assert1-actual () {"},
{"lineNum":"  292","line":"\tglob-links","class":"lineCov","hits":"4","order":"674","possible_hits":"0",},
{"lineNum":"  293","line":"}"},
{"lineNum":"  294","line":"function test19-assert1-expected () {"},
{"lineNum":"  295","line":"\techo -e \'temp-link-safelink1temp-link\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  296","line":"}"},
{"lineNum":"  297","line":""},
{"lineNum":"  298","line":"test_test20() { bats_test_begin \"test20\";"},
{"lineNum":"  299","line":"\ttest_folder=$(echo /tmp/test20-$$)","class":"lineCov","hits":"4","order":"675","possible_hits":"0",},
{"lineNum":"  300","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"676","possible_hits":"0",},
{"lineNum":"  301","line":""},
{"lineNum":"  302","line":"\tpwd","class":"lineCov","hits":"2","order":"677","possible_hits":"0",},
{"lineNum":"  303","line":"\tmkdir test-7919-a test-7919-b","class":"lineCov","hits":"2","order":"678","possible_hits":"0",},
{"lineNum":"  304","line":"}"},
{"lineNum":"  305","line":""},
{"lineNum":"  306","line":"bats_test_function --tags \'\' test_test0","class":"lineCov","hits":"23","order":"331","possible_hits":"0",},
{"lineNum":"  307","line":"bats_test_function --tags \'\' test_test1","class":"lineCov","hits":"23","order":"334","possible_hits":"0",},
{"lineNum":"  308","line":"bats_test_function --tags \'\' test_test2","class":"lineCov","hits":"23","order":"335","possible_hits":"0",},
{"lineNum":"  309","line":"bats_test_function --tags \'\' test_test3","class":"lineCov","hits":"23","order":"336","possible_hits":"0",},
{"lineNum":"  310","line":"bats_test_function --tags \'\' test_test4","class":"lineCov","hits":"23","order":"337","possible_hits":"0",},
{"lineNum":"  311","line":"bats_test_function --tags \'\' test_test5","class":"lineCov","hits":"23","order":"338","possible_hits":"0",},
{"lineNum":"  312","line":"bats_test_function --tags \'\' test_test6","class":"lineCov","hits":"23","order":"339","possible_hits":"0",},
{"lineNum":"  313","line":"bats_test_function --tags \'\' test_test7","class":"lineCov","hits":"23","order":"340","possible_hits":"0",},
{"lineNum":"  314","line":"bats_test_function --tags \'\' test_test8","class":"lineCov","hits":"23","order":"341","possible_hits":"0",},
{"lineNum":"  315","line":"bats_test_function --tags \'\' test_test9","class":"lineCov","hits":"23","order":"342","possible_hits":"0",},
{"lineNum":"  316","line":"bats_test_function --tags \'\' test_test10","class":"lineCov","hits":"23","order":"343","possible_hits":"0",},
{"lineNum":"  317","line":"bats_test_function --tags \'\' test_test11","class":"lineCov","hits":"23","order":"344","possible_hits":"0",},
{"lineNum":"  318","line":"bats_test_function --tags \'\' test_test12","class":"lineCov","hits":"23","order":"345","possible_hits":"0",},
{"lineNum":"  319","line":"bats_test_function --tags \'\' test_test13","class":"lineCov","hits":"23","order":"346","possible_hits":"0",},
{"lineNum":"  320","line":"bats_test_function --tags \'\' test_test14","class":"lineCov","hits":"23","order":"347","possible_hits":"0",},
{"lineNum":"  321","line":"bats_test_function --tags \'\' test_test15","class":"lineCov","hits":"23","order":"348","possible_hits":"0",},
{"lineNum":"  322","line":"bats_test_function --tags \'\' test_test16","class":"lineCov","hits":"23","order":"349","possible_hits":"0",},
{"lineNum":"  323","line":"bats_test_function --tags \'\' test_test17","class":"lineCov","hits":"23","order":"350","possible_hits":"0",},
{"lineNum":"  324","line":"bats_test_function --tags \'\' test_test18","class":"lineCov","hits":"23","order":"351","possible_hits":"0",},
{"lineNum":"  325","line":"bats_test_function --tags \'\' test_test19","class":"lineCov","hits":"23","order":"352","possible_hits":"0",},
{"lineNum":"  326","line":"bats_test_function --tags \'\' test_test20","class":"lineCov","hits":"23","order":"353","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "bats", "date" : "2022-10-11 20:49:26", "instrumented" : 169, "covered" : 135,};
var merged_data = [];
