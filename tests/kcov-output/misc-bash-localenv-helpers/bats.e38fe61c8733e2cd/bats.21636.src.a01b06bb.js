var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bats"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":""},
{"lineNum":"    4","line":"# Make executables ./tests/../ visible to PATH"},
{"lineNum":"    5","line":"PATH=\"/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH\"","class":"lineCov","hits":"14","order":"314","possible_hits":"0",},
{"lineNum":"    6","line":""},
{"lineNum":"    7","line":"# Source files"},
{"lineNum":"    8","line":"shopt -s expand_aliases","class":"lineCov","hits":"14","order":"330","possible_hits":"0",},
{"lineNum":"    9","line":""},
{"lineNum":"   10","line":""},
{"lineNum":"   11","line":"test_test0() { bats_test_begin \"test0\";"},
{"lineNum":"   12","line":"\ttest_folder=$(echo /tmp/test0-$$)","class":"lineCov","hits":"4","order":"420","possible_hits":"0",},
{"lineNum":"   13","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"421","possible_hits":"0",},
{"lineNum":"   14","line":""},
{"lineNum":"   15","line":"}"},
{"lineNum":"   16","line":""},
{"lineNum":"   17","line":""},
{"lineNum":"   18","line":"test_test1() { bats_test_begin \"test1\";"},
{"lineNum":"   19","line":"\ttest_folder=$(echo /tmp/test1-$$)","class":"lineCov","hits":"4","order":"461","possible_hits":"0",},
{"lineNum":"   20","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"462","possible_hits":"0",},
{"lineNum":"   21","line":""},
{"lineNum":"   22","line":"}"},
{"lineNum":"   23","line":""},
{"lineNum":"   24","line":""},
{"lineNum":"   25","line":"test_test2() { bats_test_begin \"test2\";"},
{"lineNum":"   26","line":"\ttest_folder=$(echo /tmp/test2-$$)","class":"lineCov","hits":"4","order":"463","possible_hits":"0",},
{"lineNum":"   27","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"464","possible_hits":"0",},
{"lineNum":"   28","line":""},
{"lineNum":"   29","line":"\tunalias -a","class":"lineCov","hits":"2","order":"465","possible_hits":"0",},
{"lineNum":"   30","line":"\talias | wc -l","class":"lineCov","hits":"4","order":"466","possible_hits":"0",},
{"lineNum":"   31","line":"\tfor f in $(typeset -f | egrep \'^\\w+\'); do unset -f $f; done","class":"lineCov","hits":"58","order":"467","possible_hits":"0",},
{"lineNum":"   32","line":"\tactual=$(test2-assert4-actual)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   33","line":"\texpected=$(test2-assert4-expected)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   34","line":"\techo \"========== actual ==========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   35","line":"\techo \"$actual\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   36","line":"\techo \"========= expected =========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   37","line":"\techo \"$expected\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   38","line":"\techo \"============================\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   39","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   40","line":""},
{"lineNum":"   41","line":"}"},
{"lineNum":"   42","line":""},
{"lineNum":"   43","line":"function test2-assert4-actual () {"},
{"lineNum":"   44","line":"\ttypeset -f | egrep \'^\\w+\' | wc -l","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   45","line":"}"},
{"lineNum":"   46","line":"function test2-assert4-expected () {"},
{"lineNum":"   47","line":"\techo -e \'00\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   48","line":"}"},
{"lineNum":"   49","line":""},
{"lineNum":"   50","line":"test_test3() { bats_test_begin \"test3\";"},
{"lineNum":"   51","line":"\ttest_folder=$(echo /tmp/test3-$$)","class":"lineCov","hits":"4","order":"552","possible_hits":"0",},
{"lineNum":"   52","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"553","possible_hits":"0",},
{"lineNum":"   53","line":""},
{"lineNum":"   54","line":"\tBIN_DIR=$PWD/..","class":"lineCov","hits":"2","order":"554","possible_hits":"0",},
{"lineNum":"   55","line":"\tactual=$(test3-assert2-actual)","class":"lineCov","hits":"4","order":"555","possible_hits":"0",},
{"lineNum":"   56","line":"\texpected=$(test3-assert2-expected)","class":"lineCov","hits":"4","order":"557","possible_hits":"0",},
{"lineNum":"   57","line":"\techo \"========== actual ==========\"","class":"lineCov","hits":"2","order":"559","possible_hits":"0",},
{"lineNum":"   58","line":"\techo \"$actual\" | hexview.perl","class":"lineCov","hits":"4","order":"560","possible_hits":"0",},
{"lineNum":"   59","line":"\techo \"========= expected =========\"","class":"lineCov","hits":"2","order":"561","possible_hits":"0",},
{"lineNum":"   60","line":"\techo \"$expected\" | hexview.perl","class":"lineCov","hits":"4","order":"562","possible_hits":"0",},
{"lineNum":"   61","line":"\techo \"============================\"","class":"lineCov","hits":"2","order":"563","possible_hits":"0",},
{"lineNum":"   62","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineCov","hits":"2","order":"564","possible_hits":"0",},
{"lineNum":"   63","line":""},
{"lineNum":"   64","line":"}"},
{"lineNum":"   65","line":""},
{"lineNum":"   66","line":"function test3-assert2-actual () {"},
{"lineNum":"   67","line":"\talias | wc -l","class":"lineCov","hits":"4","order":"556","possible_hits":"0",},
{"lineNum":"   68","line":"}"},
{"lineNum":"   69","line":"function test3-assert2-expected () {"},
{"lineNum":"   70","line":"\techo -e \'0\'","class":"lineCov","hits":"2","order":"558","possible_hits":"0",},
{"lineNum":"   71","line":"}"},
{"lineNum":"   72","line":""},
{"lineNum":"   73","line":"test_test4() { bats_test_begin \"test4\";"},
{"lineNum":"   74","line":"\ttest_folder=$(echo /tmp/test4-$$)","class":"lineCov","hits":"4","order":"565","possible_hits":"0",},
{"lineNum":"   75","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"566","possible_hits":"0",},
{"lineNum":"   76","line":""},
{"lineNum":"   77","line":"\ttemp_dir=$TMP/test-2800","class":"lineCov","hits":"2","order":"567","possible_hits":"0",},
{"lineNum":"   78","line":"\tcd \"$temp_dir\"","class":"lineCov","hits":"4","order":"568","possible_hits":"0",},
{"lineNum":"   79","line":"}"},
{"lineNum":"   80","line":""},
{"lineNum":"   81","line":""},
{"lineNum":"   82","line":"test_test5() { bats_test_begin \"test5\";"},
{"lineNum":"   83","line":"\ttest_folder=$(echo /tmp/test5-$$)","class":"lineCov","hits":"4","order":"570","possible_hits":"0",},
{"lineNum":"   84","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"571","possible_hits":"0",},
{"lineNum":"   85","line":""},
{"lineNum":"   86","line":"\tactual=$(test5-assert1-actual)","class":"lineCov","hits":"4","order":"572","possible_hits":"0",},
{"lineNum":"   87","line":"\texpected=$(test5-assert1-expected)","class":"lineCov","hits":"4","order":"574","possible_hits":"0",},
{"lineNum":"   88","line":"\techo \"========== actual ==========\"","class":"lineCov","hits":"2","order":"576","possible_hits":"0",},
{"lineNum":"   89","line":"\techo \"$actual\" | hexview.perl","class":"lineCov","hits":"4","order":"577","possible_hits":"0",},
{"lineNum":"   90","line":"\techo \"========= expected =========\"","class":"lineCov","hits":"2","order":"578","possible_hits":"0",},
{"lineNum":"   91","line":"\techo \"$expected\" | hexview.perl","class":"lineCov","hits":"4","order":"579","possible_hits":"0",},
{"lineNum":"   92","line":"\techo \"============================\"","class":"lineCov","hits":"2","order":"580","possible_hits":"0",},
{"lineNum":"   93","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineCov","hits":"4","order":"581","possible_hits":"0",},
{"lineNum":"   94","line":""},
{"lineNum":"   95","line":"}"},
{"lineNum":"   96","line":""},
{"lineNum":"   97","line":"function test5-assert1-actual () {"},
{"lineNum":"   98","line":"\ttypeset -f | egrep \'^\\w+\' | wc -l","class":"lineCov","hits":"6","order":"573","possible_hits":"0",},
{"lineNum":"   99","line":"}"},
{"lineNum":"  100","line":"function test5-assert1-expected () {"},
{"lineNum":"  101","line":"\techo -e \'10\'","class":"lineCov","hits":"2","order":"575","possible_hits":"0",},
{"lineNum":"  102","line":"}"},
{"lineNum":"  103","line":""},
{"lineNum":"  104","line":"test_test6() { bats_test_begin \"test6\";"},
{"lineNum":"  105","line":"\ttest_folder=$(echo /tmp/test6-$$)","class":"lineCov","hits":"4","order":"582","possible_hits":"0",},
{"lineNum":"  106","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"583","possible_hits":"0",},
{"lineNum":"  107","line":""},
{"lineNum":"  108","line":"\talias perlgrep=\'perlgrep.perl\'","class":"lineCov","hits":"2","order":"584","possible_hits":"0",},
{"lineNum":"  109","line":"\tfunction shell-check-full {"},
{"lineNum":"  110","line":"\tshellcheck \"$@\";","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  111","line":"\t}"},
{"lineNum":"  112","line":"\tfunction shell-check {"},
{"lineNum":"  113","line":"\t# note: filters out following"},
{"lineNum":"  114","line":"\t# - SC1090: Can\'t follow non-constant source. Use a directive to specify location."},
{"lineNum":"  115","line":"\t# - SC1091: Not following: ./my-git-credentials-etc.bash was not specified as input (see shellcheck -x)."},
{"lineNum":"  116","line":"\t# - SC2009: Consider using pgrep instead of grepping ps output."},
{"lineNum":"  117","line":"\t# - SC2129: Consider using { cmd1; cmd2; } >> file instead of individual redirects."},
{"lineNum":"  118","line":"\t# - SC2164: Use \'cd ... || exit\' or \'cd ... || return\' in case cd fails."},
{"lineNum":"  119","line":"\tshell-check-full \"$@\" | perl-grep -para -v \'(SC1090|SC1091|SC2009|SC2129|SC2164)\';","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  120","line":"\t}"},
{"lineNum":"  121","line":"}"},
{"lineNum":"  122","line":""},
{"lineNum":"  123","line":""},
{"lineNum":"  124","line":"test_test7() { bats_test_begin \"test7\";"},
{"lineNum":"  125","line":"\ttest_folder=$(echo /tmp/test7-$$)","class":"lineCov","hits":"4","order":"585","possible_hits":"0",},
{"lineNum":"  126","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"586","possible_hits":"0",},
{"lineNum":"  127","line":""},
{"lineNum":"  128","line":"\tactual=$(test7-assert1-actual)","class":"lineCov","hits":"7","order":"587","possible_hits":"0",},
{"lineNum":"  129","line":"\texpected=$(test7-assert1-expected)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  130","line":"\techo \"========== actual ==========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  131","line":"\techo \"$actual\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  132","line":"\techo \"========= expected =========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  133","line":"\techo \"$expected\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  134","line":"\techo \"============================\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  135","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  136","line":""},
{"lineNum":"  137","line":"}"},
{"lineNum":"  138","line":""},
{"lineNum":"  139","line":"function test7-assert1-actual () {"},
{"lineNum":"  140","line":"\tshell-check --version","class":"lineCov","hits":"4","order":"588","possible_hits":"0",},
{"lineNum":"  141","line":"}"},
{"lineNum":"  142","line":"function test7-assert1-expected () {"},
{"lineNum":"  143","line":"\techo -e \'ShellCheck - shell script analysis toolversion: 0.8.0license: GNU General Public License, version 3website: https://www.shellcheck.net\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  144","line":"}"},
{"lineNum":"  145","line":""},
{"lineNum":"  146","line":"test_test8() { bats_test_begin \"test8\";"},
{"lineNum":"  147","line":"\ttest_folder=$(echo /tmp/test8-$$)","class":"lineCov","hits":"4","order":"589","possible_hits":"0",},
{"lineNum":"  148","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"590","possible_hits":"0",},
{"lineNum":"  149","line":""},
{"lineNum":"  150","line":"\tactual=$(test8-assert1-actual)","class":"lineCov","hits":"7","order":"591","possible_hits":"0",},
{"lineNum":"  151","line":"\texpected=$(test8-assert1-expected)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  152","line":"\techo \"========== actual ==========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  153","line":"\techo \"$actual\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  154","line":"\techo \"========= expected =========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  155","line":"\techo \"$expected\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  156","line":"\techo \"============================\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  157","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  158","line":""},
{"lineNum":"  159","line":"}"},
{"lineNum":"  160","line":""},
{"lineNum":"  161","line":"function test8-assert1-actual () {"},
{"lineNum":"  162","line":"\tshell-check $BIN_DIR/tomohara-settings.bash","class":"lineCov","hits":"4","order":"592","possible_hits":"0",},
{"lineNum":"  163","line":"}"},
{"lineNum":"  164","line":"function test8-assert1-expected () {"},
{"lineNum":"  165","line":"\techo -e \'In /home/aveey/tom-project/shell-scripts/tests/../tomohara-settings.bash line 10:add-python-path $HOME/python/Mezcla/mezcla^---^ SC2086 (info): Double quote to prevent globbing and word splitting.\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  166","line":"}"},
{"lineNum":"  167","line":""},
{"lineNum":"  168","line":"test_test9() { bats_test_begin \"test9\";"},
{"lineNum":"  169","line":"\ttest_folder=$(echo /tmp/test9-$$)","class":"lineCov","hits":"4","order":"593","possible_hits":"0",},
{"lineNum":"  170","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"594","possible_hits":"0",},
{"lineNum":"  171","line":""},
{"lineNum":"  172","line":"\tactual=$(test9-assert1-actual)","class":"lineCov","hits":"7","order":"595","possible_hits":"0",},
{"lineNum":"  173","line":"\texpected=$(test9-assert1-expected)","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  174","line":"\techo \"========== actual ==========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  175","line":"\techo \"$actual\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  176","line":"\techo \"========= expected =========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  177","line":"\techo \"$expected\" | hexview.perl","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  178","line":"\techo \"============================\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  179","line":"\t[ \"$actual\" == \"$expected\" ]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  180","line":""},
{"lineNum":"  181","line":"}"},
{"lineNum":"  182","line":""},
{"lineNum":"  183","line":"function test9-assert1-actual () {"},
{"lineNum":"  184","line":"\tshell-check $BIN_DIR/cs_setup.sh","class":"lineCov","hits":"4","order":"596","possible_hits":"0",},
{"lineNum":"  185","line":"}"},
{"lineNum":"  186","line":"function test9-assert1-expected () {"},
{"lineNum":"  187","line":"\techo -e \'In /home/aveey/tom-project/shell-scripts/tests/../cs_setup.sh line 1:#! /bin/csh -f^-- SC1071 (error): ShellCheck only supports sh/bash/dash/ksh scripts. Sorry!\'","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  188","line":"}"},
{"lineNum":"  189","line":""},
{"lineNum":"  190","line":"test_test10() { bats_test_begin \"test10\";"},
{"lineNum":"  191","line":"\ttest_folder=$(echo /tmp/test10-$$)","class":"lineCov","hits":"4","order":"597","possible_hits":"0",},
{"lineNum":"  192","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"598","possible_hits":"0",},
{"lineNum":"  193","line":""},
{"lineNum":"  194","line":"\tfunction downcase-stdin { perl -pe \"use open \':std\', \':encoding(UTF-8)\'; s/.*/\\L$&/;\"; }"},
{"lineNum":"  195","line":"\talias hoy=todays-date","class":"lineCov","hits":"2","order":"599","possible_hits":"0",},
{"lineNum":"  196","line":"\tfunction sleepyhead() {"},
{"lineNum":"  197","line":"\tlog_file=\"$HOME/temp/sleepyhead.$(todays-date).log\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  198","line":"\techo \"start: $(date)\" >> \"$log_file\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  199","line":"\tcommand sleepyhead >> \"$log_file\" 2>&1 &","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  200","line":"\techo \"end: $(date)\" $\'\\n\' >> \"$log_file\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  201","line":"\t}"},
{"lineNum":"  202","line":"\talias sleepy=\'sleepyhead\'","class":"lineCov","hits":"2","order":"600","possible_hits":"0",},
{"lineNum":"  203","line":"}"},
{"lineNum":"  204","line":""},
{"lineNum":"  205","line":""},
{"lineNum":"  206","line":"test_test11() { bats_test_begin \"test11\";"},
{"lineNum":"  207","line":"\ttest_folder=$(echo /tmp/test11-$$)","class":"lineCov","hits":"4","order":"601","possible_hits":"0",},
{"lineNum":"  208","line":"\tmkdir $test_folder && cd $test_folder","class":"lineCov","hits":"4","order":"602","possible_hits":"0",},
{"lineNum":"  209","line":""},
{"lineNum":"  210","line":"}"},
{"lineNum":"  211","line":""},
{"lineNum":"  212","line":"bats_test_function --tags \'\' test_test0","class":"lineCov","hits":"14","order":"331","possible_hits":"0",},
{"lineNum":"  213","line":"bats_test_function --tags \'\' test_test1","class":"lineCov","hits":"14","order":"334","possible_hits":"0",},
{"lineNum":"  214","line":"bats_test_function --tags \'\' test_test2","class":"lineCov","hits":"14","order":"335","possible_hits":"0",},
{"lineNum":"  215","line":"bats_test_function --tags \'\' test_test3","class":"lineCov","hits":"14","order":"336","possible_hits":"0",},
{"lineNum":"  216","line":"bats_test_function --tags \'\' test_test4","class":"lineCov","hits":"14","order":"337","possible_hits":"0",},
{"lineNum":"  217","line":"bats_test_function --tags \'\' test_test5","class":"lineCov","hits":"14","order":"338","possible_hits":"0",},
{"lineNum":"  218","line":"bats_test_function --tags \'\' test_test6","class":"lineCov","hits":"14","order":"339","possible_hits":"0",},
{"lineNum":"  219","line":"bats_test_function --tags \'\' test_test7","class":"lineCov","hits":"14","order":"340","possible_hits":"0",},
{"lineNum":"  220","line":"bats_test_function --tags \'\' test_test8","class":"lineCov","hits":"14","order":"341","possible_hits":"0",},
{"lineNum":"  221","line":"bats_test_function --tags \'\' test_test9","class":"lineCov","hits":"14","order":"342","possible_hits":"0",},
{"lineNum":"  222","line":"bats_test_function --tags \'\' test_test10","class":"lineCov","hits":"14","order":"343","possible_hits":"0",},
{"lineNum":"  223","line":"bats_test_function --tags \'\' test_test11","class":"lineCov","hits":"14","order":"344","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "bats", "date" : "2022-10-11 20:50:14", "instrumented" : 113, "covered" : 73,};
var merged_data = [];
