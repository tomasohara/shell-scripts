var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bats"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":""},
{"lineNum":"    4","line":"# Make executables ./tests/../ visible to PATH"},
{"lineNum":"    5","line":"PATH=\"/home/aveey/tom-project/shell-scripts/tests/../:$PATH\"","class":"lineCov","hits":"2","order":"314","possible_hits":"0",},
{"lineNum":"    6","line":""},
{"lineNum":"    7","line":"# Source files"},
{"lineNum":"    8","line":"shopt -s expand_aliases","class":"lineCov","hits":"2","order":"330","possible_hits":"0",},
{"lineNum":"    9","line":""},
{"lineNum":"   10","line":""},
{"lineNum":"   11","line":"test_test0() { bats_test_begin \"test0\";"},
{"lineNum":"   12","line":"\ttest_folder=$(echo /tmp/test0-$$)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   13","line":"\tmkdir $test_folder && cd $test_folder","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   14","line":""},
{"lineNum":"   15","line":"}"},
{"lineNum":"   16","line":""},
{"lineNum":"   17","line":""},
{"lineNum":"   18","line":"test_test1() { bats_test_begin \"test1\";"},
{"lineNum":"   19","line":"\ttest_folder=$(echo /tmp/test1-$$)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   20","line":"\tmkdir $test_folder && cd $test_folder","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   21","line":""},
{"lineNum":"   22","line":"\tunalias -a","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   23","line":"\talias | wc -l","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   24","line":"\tfor f in $(typeset -f | egrep \'^\\w+\'); do unset -f $f; done","class":"lineNoCov","hits":"0","possible_hits":"0",},
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
{"lineNum":"   44","line":"\ttest_folder=$(echo /tmp/test2-$$)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   45","line":"\tmkdir $test_folder && cd $test_folder","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   46","line":""},
{"lineNum":"   47","line":"\tsource _dir-aliases.bash","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   48","line":"\tactual=$(test2-assert2-actual)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   49","line":"\texpected=$(test2-assert2-expected)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   50","line":"\techo \"========== actual ==========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   51","line":"\techo \"$actual\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   52","line":"\techo \"========= expected =========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   53","line":"\techo \"$expected\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   54","line":"\techo \"============================\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   55","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   56","line":""},
{"lineNum":"   57","line":"}"},
{"lineNum":"   58","line":""},
{"lineNum":"   59","line":"function test2-assert2-actual () {"},
{"lineNum":"   60","line":"\talias | wc -l","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   61","line":"}"},
{"lineNum":"   62","line":"function test2-assert2-expected () {"},
{"lineNum":"   63","line":"\techo -e \'8\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   64","line":"}"},
{"lineNum":"   65","line":""},
{"lineNum":"   66","line":"test_test3() { bats_test_begin \"test3\";"},
{"lineNum":"   67","line":"\ttest_folder=$(echo /tmp/test3-$$)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   68","line":"\tmkdir $test_folder && cd $test_folder","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   69","line":""},
{"lineNum":"   70","line":"\tactual=$(test3-assert1-actual)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   71","line":"\texpected=$(test3-assert1-expected)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   72","line":"\techo \"========== actual ==========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   73","line":"\techo \"$actual\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   74","line":"\techo \"========= expected =========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   75","line":"\techo \"$expected\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   76","line":"\techo \"============================\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   77","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   78","line":""},
{"lineNum":"   79","line":"}"},
{"lineNum":"   80","line":""},
{"lineNum":"   81","line":"function test3-assert1-actual () {"},
{"lineNum":"   82","line":"\talias | wc -l","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   83","line":"}"},
{"lineNum":"   84","line":"function test3-assert1-expected () {"},
{"lineNum":"   85","line":"\techo -e \'8\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   86","line":"}"},
{"lineNum":"   87","line":""},
{"lineNum":"   88","line":"test_test4() { bats_test_begin \"test4\";"},
{"lineNum":"   89","line":"\ttest_folder=$(echo /tmp/test4-$$)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   90","line":"\tmkdir $test_folder && cd $test_folder","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   91","line":""},
{"lineNum":"   92","line":"\tactual=$(test4-assert1-actual)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   93","line":"\texpected=$(test4-assert1-expected)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   94","line":"\techo \"========== actual ==========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   95","line":"\techo \"$actual\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   96","line":"\techo \"========= expected =========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   97","line":"\techo \"$expected\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   98","line":"\techo \"============================\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   99","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  100","line":""},
{"lineNum":"  101","line":"}"},
{"lineNum":"  102","line":""},
{"lineNum":"  103","line":"function test4-assert1-actual () {"},
{"lineNum":"  104","line":"\ttypeset -f | egrep \'^\\w+\' | wc -l","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  105","line":"}"},
{"lineNum":"  106","line":"function test4-assert1-expected () {"},
{"lineNum":"  107","line":"\techo -e \'2\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  108","line":"}"},
{"lineNum":"  109","line":""},
{"lineNum":"  110","line":"test_test5() { bats_test_begin \"test5\";"},
{"lineNum":"  111","line":"\ttest_folder=$(echo /tmp/test5-$$)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  112","line":"\tmkdir $test_folder && cd $test_folder","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  113","line":""},
{"lineNum":"  114","line":"\ttemp_dir=$TMP/test-7919","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  115","line":"\tcd \"$temp_dir\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  116","line":"}"},
{"lineNum":"  117","line":""},
{"lineNum":"  118","line":""},
{"lineNum":"  119","line":"test_test6() { bats_test_begin \"test6\";"},
{"lineNum":"  120","line":"\ttest_folder=$(echo /tmp/test6-$$)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  121","line":"\tmkdir $test_folder && cd $test_folder","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  122","line":""},
{"lineNum":"  123","line":"\t/bin/rm -rvf /tmp/test-dir-aliases/test-7919/* >| /tmp/_cleanup-test-dir-aliases.log 2>&1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  124","line":"}"},
{"lineNum":"  125","line":""},
{"lineNum":"  126","line":""},
{"lineNum":"  127","line":"test_test7() { bats_test_begin \"test7\";"},
{"lineNum":"  128","line":"\ttest_folder=$(echo /tmp/test7-$$)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  129","line":"\tmkdir $test_folder && cd $test_folder","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  130","line":""},
{"lineNum":"  131","line":"\ttouch file1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  132","line":"}"},
{"lineNum":"  133","line":""},
{"lineNum":"  134","line":""},
{"lineNum":"  135","line":"test_test8() { bats_test_begin \"test8\";"},
{"lineNum":"  136","line":"\ttest_folder=$(echo /tmp/test8-$$)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  137","line":"\tmkdir $test_folder && cd $test_folder","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  138","line":""},
{"lineNum":"  139","line":"}"},
{"lineNum":"  140","line":""},
{"lineNum":"  141","line":""},
{"lineNum":"  142","line":"test_test9() { bats_test_begin \"test9\";"},
{"lineNum":"  143","line":"\ttest_folder=$(echo /tmp/test9-$$)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  144","line":"\tmkdir $test_folder && cd $test_folder","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  145","line":""},
{"lineNum":"  146","line":"\tactual=$(test9-assert1-actual)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  147","line":"\texpected=$(test9-assert1-expected)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  148","line":"\techo \"========== actual ==========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  149","line":"\techo \"$actual\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  150","line":"\techo \"========= expected =========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  151","line":"\techo \"$expected\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  152","line":"\techo \"============================\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  153","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  154","line":""},
{"lineNum":"  155","line":"}"},
{"lineNum":"  156","line":""},
{"lineNum":"  157","line":"function test9-assert1-actual () {"},
{"lineNum":"  158","line":"\tLS ${opts} \"$@\" 2>&1 | $PAGER;","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  159","line":"}"},
{"lineNum":"  160","line":"function test9-assert1-expected () {"},
{"lineNum":"  161","line":"\techo -e \'function dir-proper () { $LS ${dir_options} --directory \"$@\" 2>&1 | $PAGER; }alias ls-full=\\\'$LS ${core_dir_options}\\\'function dir-full () { ls-full \"$@\" 2>&1 | $PAGER; }## TODO: WH with the grep (i.e., isn\\\'t there a simpler way)?function dir-sans-backups () { $LS ${dir_options} \"$@\" 2>&1 | $GREP -v \\\'~[0-9]*~\\\' | $PAGER; }# dir-ro/dir-rw(spec): show files that are read-only/read-write for the userfunction dir-ro () { $LS ${dir_options} \"$@\" 2>&1 | $GREP -v \\\'^..w\\\' | $PAGER; }function dir-rw () { $LS ${dir_options} \"$@\" 2>&1 | $GREP \\\'^..w\\\' | $PAGER; }\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  162","line":"}"},
{"lineNum":"  163","line":""},
{"lineNum":"  164","line":"test_test10() { bats_test_begin \"test10\";"},
{"lineNum":"  165","line":"\ttest_folder=$(echo /tmp/test10-$$)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  166","line":"\tmkdir $test_folder && cd $test_folder","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  167","line":""},
{"lineNum":"  168","line":"\tbash $BIN_DIR/tests/_dir-aliases.bash","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  169","line":"}"},
{"lineNum":"  170","line":""},
{"lineNum":"  171","line":""},
{"lineNum":"  172","line":"test_test11() { bats_test_begin \"test11\";"},
{"lineNum":"  173","line":"\ttest_folder=$(echo /tmp/test11-$$)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  174","line":"\tmkdir $test_folder && cd $test_folder","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  175","line":""},
{"lineNum":"  176","line":"\tactual=$(test11-assert1-actual)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  177","line":"\texpected=$(test11-assert1-expected)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  178","line":"\techo \"========== actual ==========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  179","line":"\techo \"$actual\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  180","line":"\techo \"========= expected =========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  181","line":"\techo \"$expected\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  182","line":"\techo \"============================\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  183","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  184","line":""},
{"lineNum":"  185","line":"}"},
{"lineNum":"  186","line":""},
{"lineNum":"  187","line":"function test11-assert1-actual () {"},
{"lineNum":"  188","line":"\tls -l | cut --characters=12-46 --complement","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  189","line":"}"},
{"lineNum":"  190","line":"function test11-assert1-expected () {"},
{"lineNum":"  191","line":"\techo -e \'total 0-rw-rw-r-- lrwxrwxrwx -> file1\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  192","line":"}"},
{"lineNum":"  193","line":""},
{"lineNum":"  194","line":"test_test12() { bats_test_begin \"test12\";"},
{"lineNum":"  195","line":"\ttest_folder=$(echo /tmp/test12-$$)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  196","line":"\tmkdir $test_folder && cd $test_folder","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  197","line":""},
{"lineNum":"  198","line":"}"},
{"lineNum":"  199","line":""},
{"lineNum":"  200","line":""},
{"lineNum":"  201","line":"test_test13() { bats_test_begin \"test13\";"},
{"lineNum":"  202","line":"\ttest_folder=$(echo /tmp/test13-$$)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  203","line":"\tmkdir $test_folder && cd $test_folder","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  204","line":""},
{"lineNum":"  205","line":"\tactual=$(test13-assert1-actual)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  206","line":"\texpected=$(test13-assert1-expected)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  207","line":"\techo \"========== actual ==========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  208","line":"\techo \"$actual\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  209","line":"\techo \"========= expected =========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  210","line":"\techo \"$expected\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  211","line":"\techo \"============================\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  212","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  213","line":""},
{"lineNum":"  214","line":"}"},
{"lineNum":"  215","line":""},
{"lineNum":"  216","line":"function test13-assert1-actual () {"},
{"lineNum":"  217","line":"\tls -l | cut --characters=12-46 --complement","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  218","line":"}"},
{"lineNum":"  219","line":"function test13-assert1-expected () {"},
{"lineNum":"  220","line":"\techo -e \'total 0-rw-rw-r-- lrwxrwxrwx -> file1lrwxrwxrwx ink -> /tmp\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  221","line":"}"},
{"lineNum":"  222","line":""},
{"lineNum":"  223","line":"test_test14() { bats_test_begin \"test14\";"},
{"lineNum":"  224","line":"\ttest_folder=$(echo /tmp/test14-$$)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  225","line":"\tmkdir $test_folder && cd $test_folder","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  226","line":""},
{"lineNum":"  227","line":"}"},
{"lineNum":"  228","line":""},
{"lineNum":"  229","line":""},
{"lineNum":"  230","line":"test_test15() { bats_test_begin \"test15\";"},
{"lineNum":"  231","line":"\ttest_folder=$(echo /tmp/test15-$$)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  232","line":"\tmkdir $test_folder && cd $test_folder","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  233","line":""},
{"lineNum":"  234","line":"\tactual=$(test15-assert1-actual)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  235","line":"\texpected=$(test15-assert1-expected)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  236","line":"\techo \"========== actual ==========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  237","line":"\techo \"$actual\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  238","line":"\techo \"========= expected =========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  239","line":"\techo \"$expected\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  240","line":"\techo \"============================\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  241","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  242","line":""},
{"lineNum":"  243","line":"}"},
{"lineNum":"  244","line":""},
{"lineNum":"  245","line":"function test15-assert1-actual () {"},
{"lineNum":"  246","line":"\tls -l | cut --characters=12-46 --complement","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  247","line":"}"},
{"lineNum":"  248","line":"function test15-assert1-expected () {"},
{"lineNum":"  249","line":"\techo -e \'total 0-rw-rw-r-- lrwxrwxrwx -> file1lrwxrwxrwx ink -> /tmp/tmp\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  250","line":"}"},
{"lineNum":"  251","line":""},
{"lineNum":"  252","line":"test_test16() { bats_test_begin \"test16\";"},
{"lineNum":"  253","line":"\ttest_folder=$(echo /tmp/test16-$$)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  254","line":"\tmkdir $test_folder && cd $test_folder","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  255","line":""},
{"lineNum":"  256","line":"\talias ln-symbolic-force=\'ln-symbolic --force\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  257","line":"}"},
{"lineNum":"  258","line":""},
{"lineNum":"  259","line":""},
{"lineNum":"  260","line":"test_test17() { bats_test_begin \"test17\";"},
{"lineNum":"  261","line":"\ttest_folder=$(echo /tmp/test17-$$)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  262","line":"\tmkdir $test_folder && cd $test_folder","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  263","line":""},
{"lineNum":"  264","line":"}"},
{"lineNum":"  265","line":""},
{"lineNum":"  266","line":""},
{"lineNum":"  267","line":"test_test18() { bats_test_begin \"test18\";"},
{"lineNum":"  268","line":"\ttest_folder=$(echo /tmp/test18-$$)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  269","line":"\tmkdir $test_folder && cd $test_folder","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  270","line":""},
{"lineNum":"  271","line":"}"},
{"lineNum":"  272","line":""},
{"lineNum":"  273","line":""},
{"lineNum":"  274","line":"test_test19() { bats_test_begin \"test19\";"},
{"lineNum":"  275","line":"\ttest_folder=$(echo /tmp/test19-$$)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  276","line":"\tmkdir $test_folder && cd $test_folder","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  277","line":""},
{"lineNum":"  278","line":"\tactual=$(test19-assert1-actual)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  279","line":"\texpected=$(test19-assert1-expected)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  280","line":"\techo \"========== actual ==========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  281","line":"\techo \"$actual\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  282","line":"\techo \"========= expected =========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  283","line":"\techo \"$expected\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  284","line":"\techo \"============================\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  285","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  286","line":""},
{"lineNum":"  287","line":"}"},
{"lineNum":"  288","line":""},
{"lineNum":"  289","line":"function test19-assert1-actual () {"},
{"lineNum":"  290","line":"\tls -l | cut --characters=12-46 --complement","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  291","line":"}"},
{"lineNum":"  292","line":"function test19-assert1-expected () {"},
{"lineNum":"  293","line":"\techo -e \'total 0-rw-rw-r-- lrwxrwxrwx -> file1lrwxrwxrwx ink -> /tmp/tmp\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  294","line":"}"},
{"lineNum":"  295","line":""},
{"lineNum":"  296","line":"bats_test_function --tags \'\' test_test0","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  297","line":"bats_test_function --tags \'\' test_test1","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  298","line":"bats_test_function --tags \'\' test_test2","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  299","line":"bats_test_function --tags \'\' test_test3","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  300","line":"bats_test_function --tags \'\' test_test4","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  301","line":"bats_test_function --tags \'\' test_test5","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  302","line":"bats_test_function --tags \'\' test_test6","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  303","line":"bats_test_function --tags \'\' test_test7","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  304","line":"bats_test_function --tags \'\' test_test8","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  305","line":"bats_test_function --tags \'\' test_test9","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  306","line":"bats_test_function --tags \'\' test_test10","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  307","line":"bats_test_function --tags \'\' test_test11","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  308","line":"bats_test_function --tags \'\' test_test12","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  309","line":"bats_test_function --tags \'\' test_test13","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  310","line":"bats_test_function --tags \'\' test_test14","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  311","line":"bats_test_function --tags \'\' test_test15","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  312","line":"bats_test_function --tags \'\' test_test16","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  313","line":"bats_test_function --tags \'\' test_test17","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  314","line":"bats_test_function --tags \'\' test_test18","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  315","line":"bats_test_function --tags \'\' test_test19","class":"lineNoCov","hits":"0","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "bats", "date" : "2022-09-23 19:55:33", "instrumented" : 162, "covered" : 2,};
var merged_data = [];
