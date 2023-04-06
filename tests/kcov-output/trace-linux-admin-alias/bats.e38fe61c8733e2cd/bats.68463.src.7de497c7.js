var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bats"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":""},
{"lineNum":"    4","line":"# Make executables ./tests/../ visible to PATH"},
{"lineNum":"    5","line":"PATH=\"/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH\"","class":"lineCov","hits":"22","order":"333","possible_hits":"0",},
{"lineNum":"    6","line":""},
{"lineNum":"    7","line":"# Source files"},
{"lineNum":"    8","line":"shopt -s expand_aliases","class":"lineCov","hits":"22","order":"349","possible_hits":"0",},
{"lineNum":"    9","line":""},
{"lineNum":"   10","line":""},
{"lineNum":"   11","line":"test_test0() { bats_test_begin \"test0\";"},
{"lineNum":"   12","line":"\ttest_folder=$(echo /tmp/test0-$$)","class":"lineCov","hits":"4","order":"445","possible_hits":"0",},
{"lineNum":"   13","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"446","possible_hits":"0",},
{"lineNum":"   14","line":""},
{"lineNum":"   15","line":"}"},
{"lineNum":"   16","line":""},
{"lineNum":"   17","line":""},
{"lineNum":"   18","line":"test_test1() { bats_test_begin \"test1\";"},
{"lineNum":"   19","line":"\ttest_folder=$(echo /tmp/test1-$$)","class":"lineCov","hits":"4","order":"485","possible_hits":"0",},
{"lineNum":"   20","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"486","possible_hits":"0",},
{"lineNum":"   21","line":""},
{"lineNum":"   22","line":"\tunalias -a","class":"lineCov","hits":"2","order":"487","possible_hits":"0",},
{"lineNum":"   23","line":"\talias | wc -l","class":"lineCov","hits":"4","order":"488","possible_hits":"0",},
{"lineNum":"   24","line":"\tfor f in $(typeset -f | egrep \'^\\w+\'); do unset -f $f; done","class":"lineCov","hits":"66","order":"489","possible_hits":"0",},
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
{"lineNum":"   44","line":"\ttest_folder=$(echo /tmp/test2-$$)","class":"lineCov","hits":"4","order":"581","possible_hits":"0",},
{"lineNum":"   45","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"582","possible_hits":"0",},
{"lineNum":"   46","line":""},
{"lineNum":"   47","line":"\talias testuser=\"sed -r \"s/\"$USER\"+/userxf333/g\"\"","class":"lineCov","hits":"2","order":"583","possible_hits":"0",},
{"lineNum":"   48","line":"\talias testnum=\"sed -r \"s/[0-9]/N/g\"\"","class":"lineCov","hits":"2","order":"584","possible_hits":"0",},
{"lineNum":"   49","line":"}"},
{"lineNum":"   50","line":""},
{"lineNum":"   51","line":""},
{"lineNum":"   52","line":"test_test3() { bats_test_begin \"test3\";"},
{"lineNum":"   53","line":"\ttest_folder=$(echo /tmp/test3-$$)","class":"lineCov","hits":"4","order":"585","possible_hits":"0",},
{"lineNum":"   54","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"586","possible_hits":"0",},
{"lineNum":"   55","line":""},
{"lineNum":"   56","line":"\tBIN_DIR=$PWD/..","class":"lineCov","hits":"2","order":"587","possible_hits":"0",},
{"lineNum":"   57","line":"\tactual=$(test3-assert2-actual)","class":"lineCov","hits":"4","order":"588","possible_hits":"0",},
{"lineNum":"   58","line":"\texpected=$(test3-assert2-expected)","class":"lineCov","hits":"4","order":"590","possible_hits":"0",},
{"lineNum":"   59","line":"\techo \"========== actual ==========\"","class":"lineCov","hits":"2","order":"592","possible_hits":"0",},
{"lineNum":"   60","line":"\techo \"$actual\" | hexview.perl","class":"lineCov","hits":"4","order":"593","possible_hits":"0",},
{"lineNum":"   61","line":"\techo \"========= expected =========\"","class":"lineCov","hits":"2","order":"594","possible_hits":"0",},
{"lineNum":"   62","line":"\techo \"$expected\" | hexview.perl","class":"lineCov","hits":"4","order":"595","possible_hits":"0",},
{"lineNum":"   63","line":"\techo \"============================\"","class":"lineCov","hits":"2","order":"596","possible_hits":"0",},
{"lineNum":"   64","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineCov","hits":"4","order":"597","possible_hits":"0",},
{"lineNum":"   65","line":""},
{"lineNum":"   66","line":"}"},
{"lineNum":"   67","line":""},
{"lineNum":"   68","line":"function test3-assert2-actual () {"},
{"lineNum":"   69","line":"\talias | wc -l","class":"lineCov","hits":"4","order":"589","possible_hits":"0",},
{"lineNum":"   70","line":"}"},
{"lineNum":"   71","line":"function test3-assert2-expected () {"},
{"lineNum":"   72","line":"\techo -e \'2\'","class":"lineCov","hits":"2","order":"591","possible_hits":"0",},
{"lineNum":"   73","line":"}"},
{"lineNum":"   74","line":""},
{"lineNum":"   75","line":"test_test4() { bats_test_begin \"test4\";"},
{"lineNum":"   76","line":"\ttest_folder=$(echo /tmp/test4-$$)","class":"lineCov","hits":"4","order":"599","possible_hits":"0",},
{"lineNum":"   77","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"600","possible_hits":"0",},
{"lineNum":"   78","line":""},
{"lineNum":"   79","line":"\ttemp_dir=$TMP/test-3245","class":"lineCov","hits":"2","order":"601","possible_hits":"0",},
{"lineNum":"   80","line":"\tcd \"$temp_dir\"","class":"lineCov","hits":"4","order":"602","possible_hits":"0",},
{"lineNum":"   81","line":"}"},
{"lineNum":"   82","line":""},
{"lineNum":"   83","line":""},
{"lineNum":"   84","line":"test_test5() { bats_test_begin \"test5\";"},
{"lineNum":"   85","line":"\ttest_folder=$(echo /tmp/test5-$$)","class":"lineCov","hits":"4","order":"603","possible_hits":"0",},
{"lineNum":"   86","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"604","possible_hits":"0",},
{"lineNum":"   87","line":""},
{"lineNum":"   88","line":"\tactual=$(test5-assert1-actual)","class":"lineCov","hits":"4","order":"605","possible_hits":"0",},
{"lineNum":"   89","line":"\texpected=$(test5-assert1-expected)","class":"lineCov","hits":"4","order":"607","possible_hits":"0",},
{"lineNum":"   90","line":"\techo \"========== actual ==========\"","class":"lineCov","hits":"2","order":"609","possible_hits":"0",},
{"lineNum":"   91","line":"\techo \"$actual\" | hexview.perl","class":"lineCov","hits":"4","order":"610","possible_hits":"0",},
{"lineNum":"   92","line":"\techo \"========= expected =========\"","class":"lineCov","hits":"2","order":"611","possible_hits":"0",},
{"lineNum":"   93","line":"\techo \"$expected\" | hexview.perl","class":"lineCov","hits":"4","order":"612","possible_hits":"0",},
{"lineNum":"   94","line":"\techo \"============================\"","class":"lineCov","hits":"2","order":"613","possible_hits":"0",},
{"lineNum":"   95","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineCov","hits":"4","order":"614","possible_hits":"0",},
{"lineNum":"   96","line":""},
{"lineNum":"   97","line":"}"},
{"lineNum":"   98","line":""},
{"lineNum":"   99","line":"function test5-assert1-actual () {"},
{"lineNum":"  100","line":"\ttypeset -f | egrep \'^\\w+\' | wc -l","class":"lineCov","hits":"6","order":"606","possible_hits":"0",},
{"lineNum":"  101","line":"}"},
{"lineNum":"  102","line":"function test5-assert1-expected () {"},
{"lineNum":"  103","line":"\techo -e \'30\'","class":"lineCov","hits":"2","order":"608","possible_hits":"0",},
{"lineNum":"  104","line":"}"},
{"lineNum":"  105","line":""},
{"lineNum":"  106","line":"test_test6() { bats_test_begin \"test6\";"},
{"lineNum":"  107","line":"\ttest_folder=$(echo /tmp/test6-$$)","class":"lineCov","hits":"4","order":"615","possible_hits":"0",},
{"lineNum":"  108","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"616","possible_hits":"0",},
{"lineNum":"  109","line":""},
{"lineNum":"  110","line":"\tsource $BIN_DIR/tomohara-aliases.bash","class":"lineCov","hits":"2","order":"617","possible_hits":"0",},
{"lineNum":"  111","line":"}"},
{"lineNum":"  112","line":""},
{"lineNum":"  113","line":""},
{"lineNum":"  114","line":"test_test7() { bats_test_begin \"test7\";"},
{"lineNum":"  115","line":"\ttest_folder=$(echo /tmp/test7-$$)","class":"lineCov","hits":"4","order":"619","possible_hits":"0",},
{"lineNum":"  116","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"620","possible_hits":"0",},
{"lineNum":"  117","line":""},
{"lineNum":"  118","line":"\talias apt-install=\'apt-get install --yes --fix-missing --no-remove\'","class":"lineCov","hits":"2","order":"621","possible_hits":"0",},
{"lineNum":"  119","line":"\talias apt-search=\'apt-cache search\'","class":"lineCov","hits":"2","order":"622","possible_hits":"0",},
{"lineNum":"  120","line":"\talias apt-installed=\'apt list --installed\'","class":"lineCov","hits":"2","order":"623","possible_hits":"0",},
{"lineNum":"  121","line":"\talias apt-uninstall=\'apt-get remove\'","class":"lineCov","hits":"2","order":"624","possible_hits":"0",},
{"lineNum":"  122","line":"\talias dpkg-install=\'dpkg --install \'","class":"lineCov","hits":"2","order":"625","possible_hits":"0",},
{"lineNum":"  123","line":"}"},
{"lineNum":"  124","line":""},
{"lineNum":"  125","line":""},
{"lineNum":"  126","line":"test_test8() { bats_test_begin \"test8\";"},
{"lineNum":"  127","line":"\ttest_folder=$(echo /tmp/test8-$$)","class":"lineCov","hits":"4","order":"626","possible_hits":"0",},
{"lineNum":"  128","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"627","possible_hits":"0",},
{"lineNum":"  129","line":""},
{"lineNum":"  130","line":"\tapt-installed *python3* | grep ipython | cut -d \\/ -f 1 | testnum","class":"lineCov","hits":"10","order":"628","possible_hits":"0",},
{"lineNum":"  131","line":"}"},
{"lineNum":"  132","line":""},
{"lineNum":"  133","line":""},
{"lineNum":"  134","line":"test_test9() { bats_test_begin \"test9\";"},
{"lineNum":"  135","line":"\ttest_folder=$(echo /tmp/test9-$$)","class":"lineCov","hits":"4","order":"629","possible_hits":"0",},
{"lineNum":"  136","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"630","possible_hits":"0",},
{"lineNum":"  137","line":""},
{"lineNum":"  138","line":"\tactual=$(test9-assert1-actual)","class":"lineCov","hits":"7","order":"631","possible_hits":"0",},
{"lineNum":"  139","line":"\texpected=$(test9-assert1-expected)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  140","line":"\techo \"========== actual ==========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  141","line":"\techo \"$actual\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  142","line":"\techo \"========= expected =========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  143","line":"\techo \"$expected\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  144","line":"\techo \"============================\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  145","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  146","line":""},
{"lineNum":"  147","line":"}"},
{"lineNum":"  148","line":""},
{"lineNum":"  149","line":"function test9-assert1-actual () {"},
{"lineNum":"  150","line":"\tapt-search rolldice","class":"lineCov","hits":"4","order":"632","possible_hits":"0",},
{"lineNum":"  151","line":"}"},
{"lineNum":"  152","line":"function test9-assert1-expected () {"},
{"lineNum":"  153","line":"\techo -e \'rolldice - virtual dice roller\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  154","line":"}"},
{"lineNum":"  155","line":""},
{"lineNum":"  156","line":"test_test10() { bats_test_begin \"test10\";"},
{"lineNum":"  157","line":"\ttest_folder=$(echo /tmp/test10-$$)","class":"lineCov","hits":"4","order":"633","possible_hits":"0",},
{"lineNum":"  158","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"634","possible_hits":"0",},
{"lineNum":"  159","line":""},
{"lineNum":"  160","line":"\tapt-installed | grep acpi | wc -l","class":"lineCov","hits":"6","order":"635","possible_hits":"0",},
{"lineNum":"  161","line":"}"},
{"lineNum":"  162","line":""},
{"lineNum":"  163","line":""},
{"lineNum":"  164","line":"test_test11() { bats_test_begin \"test11\";"},
{"lineNum":"  165","line":"\ttest_folder=$(echo /tmp/test11-$$)","class":"lineCov","hits":"4","order":"636","possible_hits":"0",},
{"lineNum":"  166","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"637","possible_hits":"0",},
{"lineNum":"  167","line":""},
{"lineNum":"  168","line":"\talias start-service=\'systemctl start\'","class":"lineCov","hits":"2","order":"638","possible_hits":"0",},
{"lineNum":"  169","line":"\talias list-all-service=\'systemctl --type=service\'","class":"lineCov","hits":"2","order":"639","possible_hits":"0",},
{"lineNum":"  170","line":"\talias restart-service-sudoless=\'systemctl restart\'","class":"lineCov","hits":"2","order":"640","possible_hits":"0",},
{"lineNum":"  171","line":"\talias status-service=\'systemctl status\'","class":"lineCov","hits":"2","order":"641","possible_hits":"0",},
{"lineNum":"  172","line":"\talias service-status=\'status-service\'","class":"lineCov","hits":"2","order":"642","possible_hits":"0",},
{"lineNum":"  173","line":"}"},
{"lineNum":"  174","line":""},
{"lineNum":"  175","line":""},
{"lineNum":"  176","line":"test_test12() { bats_test_begin \"test12\";"},
{"lineNum":"  177","line":"\ttest_folder=$(echo /tmp/test12-$$)","class":"lineCov","hits":"4","order":"643","possible_hits":"0",},
{"lineNum":"  178","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"644","possible_hits":"0",},
{"lineNum":"  179","line":""},
{"lineNum":"  180","line":"\tactual=$(test12-assert1-actual)","class":"lineCov","hits":"7","order":"645","possible_hits":"0",},
{"lineNum":"  181","line":"\texpected=$(test12-assert1-expected)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  182","line":"\techo \"========== actual ==========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  183","line":"\techo \"$actual\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  184","line":"\techo \"========= expected =========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  185","line":"\techo \"$expected\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  186","line":"\techo \"============================\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  187","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  188","line":""},
{"lineNum":"  189","line":"}"},
{"lineNum":"  190","line":""},
{"lineNum":"  191","line":"function test12-assert1-actual () {"},
{"lineNum":"  192","line":"\tlist-all-service | grep ufw","class":"lineCov","hits":"6","order":"646","possible_hits":"0",},
{"lineNum":"  193","line":"}"},
{"lineNum":"  194","line":"function test12-assert1-expected () {"},
{"lineNum":"  195","line":"\techo -e \'ufw.service                                           loaded active exited  Uncomplicated firewall\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  196","line":"}"},
{"lineNum":"  197","line":""},
{"lineNum":"  198","line":"test_test13() { bats_test_begin \"test13\";"},
{"lineNum":"  199","line":"\ttest_folder=$(echo /tmp/test13-$$)","class":"lineCov","hits":"4","order":"647","possible_hits":"0",},
{"lineNum":"  200","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"648","possible_hits":"0",},
{"lineNum":"  201","line":""},
{"lineNum":"  202","line":"}"},
{"lineNum":"  203","line":""},
{"lineNum":"  204","line":""},
{"lineNum":"  205","line":"test_test14() { bats_test_begin \"test14\";"},
{"lineNum":"  206","line":"\ttest_folder=$(echo /tmp/test14-$$)","class":"lineCov","hits":"4","order":"649","possible_hits":"0",},
{"lineNum":"  207","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"650","possible_hits":"0",},
{"lineNum":"  208","line":""},
{"lineNum":"  209","line":"}"},
{"lineNum":"  210","line":""},
{"lineNum":"  211","line":""},
{"lineNum":"  212","line":"test_test15() { bats_test_begin \"test15\";"},
{"lineNum":"  213","line":"\ttest_folder=$(echo /tmp/test15-$$)","class":"lineCov","hits":"4","order":"651","possible_hits":"0",},
{"lineNum":"  214","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"652","possible_hits":"0",},
{"lineNum":"  215","line":""},
{"lineNum":"  216","line":"}"},
{"lineNum":"  217","line":""},
{"lineNum":"  218","line":""},
{"lineNum":"  219","line":"test_test16() { bats_test_begin \"test16\";"},
{"lineNum":"  220","line":"\ttest_folder=$(echo /tmp/test16-$$)","class":"lineCov","hits":"4","order":"653","possible_hits":"0",},
{"lineNum":"  221","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"654","possible_hits":"0",},
{"lineNum":"  222","line":""},
{"lineNum":"  223","line":"}"},
{"lineNum":"  224","line":""},
{"lineNum":"  225","line":""},
{"lineNum":"  226","line":"test_test17() { bats_test_begin \"test17\";"},
{"lineNum":"  227","line":"\ttest_folder=$(echo /tmp/test17-$$)","class":"lineCov","hits":"4","order":"655","possible_hits":"0",},
{"lineNum":"  228","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"656","possible_hits":"0",},
{"lineNum":"  229","line":""},
{"lineNum":"  230","line":"\tprintf \"HELLO THERE,\\nI AM EXTREMELY PLEASED TO USE UBUNTU.\" >> abc.txt","class":"lineCov","hits":"2","order":"657","possible_hits":"0",},
{"lineNum":"  231","line":"\tget-free-filename \"abc.txt\" 2      #DOUBT(?)","class":"lineCov","hits":"4","order":"658","possible_hits":"0",},
{"lineNum":"  232","line":"\tlinebr","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  233","line":"\tls -l | awk \'!($6=\"\")\' | testnum | testuser","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  234","line":"\tlinebr","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  235","line":"\tactual=$(test17-assert6-actual)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  236","line":"\texpected=$(test17-assert6-expected)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  237","line":"\techo \"========== actual ==========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  238","line":"\techo \"$actual\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  239","line":"\techo \"========= expected =========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  240","line":"\techo \"$expected\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  241","line":"\techo \"============================\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  242","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  243","line":""},
{"lineNum":"  244","line":"}"},
{"lineNum":"  245","line":""},
{"lineNum":"  246","line":"function test17-assert6-actual () {"},
{"lineNum":"  247","line":"\tcat \"abc.txt\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  248","line":"}"},
{"lineNum":"  249","line":"function test17-assert6-expected () {"},
{"lineNum":"  250","line":"\techo -e \'abc.txt22--------------------------------------------------------------------------------total N    -rw-rw-r-- N userxf333 userxf333 NNN  N NN:NN abc.txt--------------------------------------------------------------------------------HELLO THERE,I AM EXTREMELY PLEASED TO USE UBUNTU.HELLO THERE,I AM EXTREMELY PLEASED TO USE UBUNTU.HELLO THERE,I AM EXTREMELY PLEASED TO USE UBUNTU.HELLO THERE,I AM EXTREMELY PLEASED TO USE UBUNTU.HELLO THERE,I AM EXTREMELY PLEASED TO USE UBUNTU.HELLO THERE,I AM EXTREMELY PLEASED TO USE UBUNTU.\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  251","line":"}"},
{"lineNum":"  252","line":""},
{"lineNum":"  253","line":"test_test18() { bats_test_begin \"test18\";"},
{"lineNum":"  254","line":"\ttest_folder=$(echo /tmp/test18-$$)","class":"lineCov","hits":"4","order":"659","possible_hits":"0",},
{"lineNum":"  255","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"660","possible_hits":"0",},
{"lineNum":"  256","line":""},
{"lineNum":"  257","line":"\tsync2","class":"lineCov","hits":"4","order":"661","possible_hits":"0",},
{"lineNum":"  258","line":"}"},
{"lineNum":"  259","line":""},
{"lineNum":"  260","line":""},
{"lineNum":"  261","line":"test_test19() { bats_test_begin \"test19\";"},
{"lineNum":"  262","line":"\ttest_folder=$(echo /tmp/test19-$$)","class":"lineCov","hits":"4","order":"662","possible_hits":"0",},
{"lineNum":"  263","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"663","possible_hits":"0",},
{"lineNum":"  264","line":""},
{"lineNum":"  265","line":"\tactual=$(test19-assert1-actual)","class":"lineCov","hits":"7","order":"664","possible_hits":"0",},
{"lineNum":"  266","line":"\texpected=$(test19-assert1-expected)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  267","line":"\techo \"========== actual ==========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  268","line":"\techo \"$actual\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  269","line":"\techo \"========= expected =========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  270","line":"\techo \"$expected\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  271","line":"\techo \"============================\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  272","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  273","line":""},
{"lineNum":"  274","line":"}"},
{"lineNum":"  275","line":""},
{"lineNum":"  276","line":"function test19-assert1-actual () {"},
{"lineNum":"  277","line":"\tfix-sudoer-home-permission","class":"lineCov","hits":"4","order":"665","possible_hits":"0",},
{"lineNum":"  278","line":"}"},
{"lineNum":"  279","line":"function test19-assert1-expected () {"},
{"lineNum":"  280","line":"\techo -e \'Warning: no sudo user for current shell\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  281","line":"}"},
{"lineNum":"  282","line":""},
{"lineNum":"  283","line":"bats_test_function --tags \'\' test_test0","class":"lineCov","hits":"22","order":"350","possible_hits":"0",},
{"lineNum":"  284","line":"bats_test_function --tags \'\' test_test1","class":"lineCov","hits":"22","order":"351","possible_hits":"0",},
{"lineNum":"  285","line":"bats_test_function --tags \'\' test_test2","class":"lineCov","hits":"22","order":"352","possible_hits":"0",},
{"lineNum":"  286","line":"bats_test_function --tags \'\' test_test3","class":"lineCov","hits":"22","order":"353","possible_hits":"0",},
{"lineNum":"  287","line":"bats_test_function --tags \'\' test_test4","class":"lineCov","hits":"22","order":"354","possible_hits":"0",},
{"lineNum":"  288","line":"bats_test_function --tags \'\' test_test5","class":"lineCov","hits":"22","order":"355","possible_hits":"0",},
{"lineNum":"  289","line":"bats_test_function --tags \'\' test_test6","class":"lineCov","hits":"22","order":"356","possible_hits":"0",},
{"lineNum":"  290","line":"bats_test_function --tags \'\' test_test7","class":"lineCov","hits":"22","order":"357","possible_hits":"0",},
{"lineNum":"  291","line":"bats_test_function --tags \'\' test_test8","class":"lineCov","hits":"22","order":"358","possible_hits":"0",},
{"lineNum":"  292","line":"bats_test_function --tags \'\' test_test9","class":"lineCov","hits":"22","order":"359","possible_hits":"0",},
{"lineNum":"  293","line":"bats_test_function --tags \'\' test_test10","class":"lineCov","hits":"22","order":"360","possible_hits":"0",},
{"lineNum":"  294","line":"bats_test_function --tags \'\' test_test11","class":"lineCov","hits":"22","order":"361","possible_hits":"0",},
{"lineNum":"  295","line":"bats_test_function --tags \'\' test_test12","class":"lineCov","hits":"22","order":"362","possible_hits":"0",},
{"lineNum":"  296","line":"bats_test_function --tags \'\' test_test13","class":"lineCov","hits":"22","order":"363","possible_hits":"0",},
{"lineNum":"  297","line":"bats_test_function --tags \'\' test_test14","class":"lineCov","hits":"22","order":"364","possible_hits":"0",},
{"lineNum":"  298","line":"bats_test_function --tags \'\' test_test15","class":"lineCov","hits":"22","order":"365","possible_hits":"0",},
{"lineNum":"  299","line":"bats_test_function --tags \'\' test_test16","class":"lineCov","hits":"22","order":"366","possible_hits":"0",},
{"lineNum":"  300","line":"bats_test_function --tags \'\' test_test17","class":"lineCov","hits":"22","order":"367","possible_hits":"0",},
{"lineNum":"  301","line":"bats_test_function --tags \'\' test_test18","class":"lineCov","hits":"22","order":"368","possible_hits":"0",},
{"lineNum":"  302","line":"bats_test_function --tags \'\' test_test19","class":"lineCov","hits":"22","order":"369","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "bats", "date" : "2023-04-06 21:10:30", "instrumented" : 159, "covered" : 112,};
var merged_data = [];
