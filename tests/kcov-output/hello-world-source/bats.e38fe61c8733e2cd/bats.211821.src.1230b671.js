var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bats"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":""},
{"lineNum":"    4","line":"# Make executables ./tests/../ visible to PATH"},
{"lineNum":"    5","line":"PATH=\"/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH\"","class":"lineCov","hits":"11","order":"333","possible_hits":"0",},
{"lineNum":"    6","line":""},
{"lineNum":"    7","line":"# Enable aliases"},
{"lineNum":"    8","line":"shopt -s expand_aliases","class":"lineCov","hits":"11","order":"349","possible_hits":"0",},
{"lineNum":"    9","line":""},
{"lineNum":"   10","line":""},
{"lineNum":"   11","line":""},
{"lineNum":"   12","line":"test_test-2d1() { bats_test_begin \"test-1\";"},
{"lineNum":"   13","line":"\ttestfolder=\"/tmp/batspp-211587/test-1\"","class":"lineCov","hits":"2","order":"434","possible_hits":"0",},
{"lineNum":"   14","line":"\tmkdir --parents \"$testfolder\"","class":"lineCov","hits":"2","order":"435","possible_hits":"0",},
{"lineNum":"   15","line":"\tbuiltin cd \"$testfolder\" || echo Warning: Unable to \"cd $testfolder\"","class":"lineCov","hits":"2","order":"436","possible_hits":"0",},
{"lineNum":"   16","line":""},
{"lineNum":"   17","line":"\techo \"==========\" $\'function count-aliases { alias | wc -l; }\\n\' \"==========\"","class":"lineCov","hits":"2","order":"437","possible_hits":"0",},
{"lineNum":"   18","line":"\ttest-1-actual","class":"lineCov","hits":"2","order":"438","possible_hits":"0",},
{"lineNum":"   19","line":"\techo \"=========\" $\'$ function clear-aliases { unalias -a; }\' \"=========\"","class":"lineCov","hits":"2","order":"440","possible_hits":"0",},
{"lineNum":"   20","line":"\ttest-1-expected","class":"lineCov","hits":"2","order":"441","possible_hits":"0",},
{"lineNum":"   21","line":"\techo \"============================\"","class":"lineCov","hits":"2","order":"444","possible_hits":"0",},
{"lineNum":"   22","line":"\t# ???: \'function count-aliases { alias | wc -l; }\\n\'=$(test-1-actual)"},
{"lineNum":"   23","line":"\t# ???: \'$ function clear-aliases { unalias -a; }\'=$(test-1-expected)"},
{"lineNum":"   24","line":"\t[ \"$(test-1-actual)\" == \"$(test-1-expected)\" ]","class":"lineCov","hits":"8","order":"445","possible_hits":"0",},
{"lineNum":"   25","line":"}"},
{"lineNum":"   26","line":""},
{"lineNum":"   27","line":"function test-1-actual () {"},
{"lineNum":"   28","line":"\t# no-op in case content just a comment"},
{"lineNum":"   29","line":"\ttrue","class":"lineCov","hits":"4","order":"439","possible_hits":"0",},
{"lineNum":"   30","line":""},
{"lineNum":"   31","line":"\tfunction count-aliases { alias | wc -l; }"},
{"lineNum":"   32","line":""},
{"lineNum":"   33","line":"}"},
{"lineNum":"   34","line":""},
{"lineNum":"   35","line":"function test-1-expected () {"},
{"lineNum":"   36","line":"\t# no-op in case content just a comment"},
{"lineNum":"   37","line":"\ttrue","class":"lineCov","hits":"4","order":"442","possible_hits":"0",},
{"lineNum":"   38","line":""},
{"lineNum":"   39","line":"\tcat <<END_EXPECTED","class":"lineCov","hits":"4","order":"443","possible_hits":"0",},
{"lineNum":"   40","line":"$ function clear-aliases { unalias -a; }"},
{"lineNum":"   41","line":"END_EXPECTED"},
{"lineNum":"   42","line":"}"},
{"lineNum":"   43","line":""},
{"lineNum":"   44","line":""},
{"lineNum":"   45","line":"test_test-2d3() { bats_test_begin \"test-3\";"},
{"lineNum":"   46","line":"\ttestfolder=\"/tmp/batspp-211587/test-3\"","class":"lineCov","hits":"2","order":"568","possible_hits":"0",},
{"lineNum":"   47","line":"\tmkdir --parents \"$testfolder\"","class":"lineCov","hits":"2","order":"569","possible_hits":"0",},
{"lineNum":"   48","line":"\tbuiltin cd \"$testfolder\" || echo Warning: Unable to \"cd $testfolder\"","class":"lineCov","hits":"2","order":"570","possible_hits":"0",},
{"lineNum":"   49","line":""},
{"lineNum":"   50","line":"\techo \"==========\" $\'clear-aliases\\n\' \"==========\"","class":"lineCov","hits":"2","order":"571","possible_hits":"0",},
{"lineNum":"   51","line":"\ttest-3-actual","class":"lineCov","hits":"2","order":"572","possible_hits":"0",},
{"lineNum":"   52","line":"\techo \"=========\" $\'$ count-aliases\\n0\' \"=========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   53","line":"\ttest-3-expected","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   54","line":"\techo \"============================\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   55","line":"\t# ???: \'clear-aliases\\n\'=$(test-3-actual)"},
{"lineNum":"   56","line":"\t# ???: \'$ count-aliases\\n0\'=$(test-3-expected)"},
{"lineNum":"   57","line":"\t[ \"$(test-3-actual)\" == \"$(test-3-expected)\" ]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   58","line":"}"},
{"lineNum":"   59","line":""},
{"lineNum":"   60","line":"function test-3-actual () {"},
{"lineNum":"   61","line":"\t# no-op in case content just a comment"},
{"lineNum":"   62","line":"\ttrue","class":"lineCov","hits":"2","order":"573","possible_hits":"0",},
{"lineNum":"   63","line":""},
{"lineNum":"   64","line":"\tclear-aliases","class":"lineCov","hits":"4","order":"574","possible_hits":"0",},
{"lineNum":"   65","line":""},
{"lineNum":"   66","line":"}"},
{"lineNum":"   67","line":""},
{"lineNum":"   68","line":"function test-3-expected () {"},
{"lineNum":"   69","line":"\t# no-op in case content just a comment"},
{"lineNum":"   70","line":"\ttrue","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   71","line":""},
{"lineNum":"   72","line":"\tcat <<END_EXPECTED","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"   73","line":"$ count-aliases"},
{"lineNum":"   74","line":"0"},
{"lineNum":"   75","line":"END_EXPECTED"},
{"lineNum":"   76","line":"}"},
{"lineNum":"   77","line":""},
{"lineNum":"   78","line":""},
{"lineNum":"   79","line":"test_test-2d4() { bats_test_begin \"test-4\";"},
{"lineNum":"   80","line":"\ttestfolder=\"/tmp/batspp-211587/test-4\"","class":"lineCov","hits":"2","order":"582","possible_hits":"0",},
{"lineNum":"   81","line":"\tmkdir --parents \"$testfolder\"","class":"lineCov","hits":"2","order":"583","possible_hits":"0",},
{"lineNum":"   82","line":"\tbuiltin cd \"$testfolder\" || echo Warning: Unable to \"cd $testfolder\"","class":"lineCov","hits":"2","order":"584","possible_hits":"0",},
{"lineNum":"   83","line":""},
{"lineNum":"   84","line":"\techo \"==========\" $\'function count-aliases { alias | wc -l; }\\n\' \"==========\"","class":"lineCov","hits":"2","order":"585","possible_hits":"0",},
{"lineNum":"   85","line":"\ttest-4-actual","class":"lineCov","hits":"2","order":"586","possible_hits":"0",},
{"lineNum":"   86","line":"\techo \"=========\" $\"$ function list-functions { typeset -f | egrep \'^[A-ZZa-z_-]\'; }\\n$ function count-functions { list-functions | wc -l; }\" \"=========\"","class":"lineCov","hits":"2","order":"588","possible_hits":"0",},
{"lineNum":"   87","line":"\ttest-4-expected","class":"lineCov","hits":"2","order":"589","possible_hits":"0",},
{"lineNum":"   88","line":"\techo \"============================\"","class":"lineCov","hits":"2","order":"592","possible_hits":"0",},
{"lineNum":"   89","line":"\t# ???: \'function count-aliases { alias | wc -l; }\\n\'=$(test-4-actual)"},
{"lineNum":"   90","line":"\t# ???: \"$ function list-functions { typeset -f | egrep \'^[A-ZZa-z_-]\'; }\\n$ function count-functions { list-functions | wc -l; }\"=$(test-4-expected)"},
{"lineNum":"   91","line":"\t[ \"$(test-4-actual)\" == \"$(test-4-expected)\" ]","class":"lineCov","hits":"8","order":"593","possible_hits":"0",},
{"lineNum":"   92","line":"}"},
{"lineNum":"   93","line":""},
{"lineNum":"   94","line":"function test-4-actual () {"},
{"lineNum":"   95","line":"\t# no-op in case content just a comment"},
{"lineNum":"   96","line":"\ttrue","class":"lineCov","hits":"4","order":"587","possible_hits":"0",},
{"lineNum":"   97","line":""},
{"lineNum":"   98","line":"\tfunction count-aliases { alias | wc -l; }"},
{"lineNum":"   99","line":""},
{"lineNum":"  100","line":"}"},
{"lineNum":"  101","line":""},
{"lineNum":"  102","line":"function test-4-expected () {"},
{"lineNum":"  103","line":"\t# no-op in case content just a comment"},
{"lineNum":"  104","line":"\ttrue","class":"lineCov","hits":"4","order":"590","possible_hits":"0",},
{"lineNum":"  105","line":""},
{"lineNum":"  106","line":"\tcat <<END_EXPECTED","class":"lineCov","hits":"4","order":"591","possible_hits":"0",},
{"lineNum":"  107","line":"$ function list-functions { typeset -f | egrep \'^[A-ZZa-z_-]\'; }"},
{"lineNum":"  108","line":"$ function count-functions { list-functions | wc -l; }"},
{"lineNum":"  109","line":"END_EXPECTED"},
{"lineNum":"  110","line":"}"},
{"lineNum":"  111","line":""},
{"lineNum":"  112","line":""},
{"lineNum":"  113","line":"test_test-2d5() { bats_test_begin \"test-5\";"},
{"lineNum":"  114","line":"\ttestfolder=\"/tmp/batspp-211587/test-5\"","class":"lineCov","hits":"2","order":"594","possible_hits":"0",},
{"lineNum":"  115","line":"\tmkdir --parents \"$testfolder\"","class":"lineCov","hits":"2","order":"595","possible_hits":"0",},
{"lineNum":"  116","line":"\tbuiltin cd \"$testfolder\" || echo Warning: Unable to \"cd $testfolder\"","class":"lineCov","hits":"2","order":"596","possible_hits":"0",},
{"lineNum":"  117","line":""},
{"lineNum":"  118","line":"\techo \"==========\" $\'BIN_DIR=$PWD/..\\n\' \"==========\"","class":"lineCov","hits":"2","order":"597","possible_hits":"0",},
{"lineNum":"  119","line":"\ttest-5-actual","class":"lineCov","hits":"2","order":"598","possible_hits":"0",},
{"lineNum":"  120","line":"\techo \"=========\" $\'$ echo $BIN_DIR\\n# source $BIN_DIR/tomohara-aliases.bash\\n/home/aveey/tom-project/shell-scripts/tests/..\' \"=========\"","class":"lineCov","hits":"2","order":"601","possible_hits":"0",},
{"lineNum":"  121","line":"\ttest-5-expected","class":"lineCov","hits":"2","order":"602","possible_hits":"0",},
{"lineNum":"  122","line":"\techo \"============================\"","class":"lineCov","hits":"2","order":"605","possible_hits":"0",},
{"lineNum":"  123","line":"\t# ???: \'BIN_DIR=$PWD/..\\n\'=$(test-5-actual)"},
{"lineNum":"  124","line":"\t# ???: \'$ echo $BIN_DIR\\n# source $BIN_DIR/tomohara-aliases.bash\\n/home/aveey/tom-project/shell-scripts/tests/..\'=$(test-5-expected)"},
{"lineNum":"  125","line":"\t[ \"$(test-5-actual)\" == \"$(test-5-expected)\" ]","class":"lineCov","hits":"8","order":"606","possible_hits":"0",},
{"lineNum":"  126","line":"}"},
{"lineNum":"  127","line":""},
{"lineNum":"  128","line":"function test-5-actual () {"},
{"lineNum":"  129","line":"\t# no-op in case content just a comment"},
{"lineNum":"  130","line":"\ttrue","class":"lineCov","hits":"4","order":"599","possible_hits":"0",},
{"lineNum":"  131","line":""},
{"lineNum":"  132","line":"\tBIN_DIR=$PWD/..","class":"lineCov","hits":"4","order":"600","possible_hits":"0",},
{"lineNum":"  133","line":""},
{"lineNum":"  134","line":"}"},
{"lineNum":"  135","line":""},
{"lineNum":"  136","line":"function test-5-expected () {"},
{"lineNum":"  137","line":"\t# no-op in case content just a comment"},
{"lineNum":"  138","line":"\ttrue","class":"lineCov","hits":"4","order":"603","possible_hits":"0",},
{"lineNum":"  139","line":""},
{"lineNum":"  140","line":"\tcat <<END_EXPECTED","class":"lineCov","hits":"4","order":"604","possible_hits":"0",},
{"lineNum":"  141","line":"$ echo $BIN_DIR"},
{"lineNum":"  142","line":"# source $BIN_DIR/tomohara-aliases.bash"},
{"lineNum":"  143","line":"/home/aveey/tom-project/shell-scripts/tests/.."},
{"lineNum":"  144","line":"END_EXPECTED"},
{"lineNum":"  145","line":"}"},
{"lineNum":"  146","line":""},
{"lineNum":"  147","line":""},
{"lineNum":"  148","line":"test_test-2d6() { bats_test_begin \"test-6\";"},
{"lineNum":"  149","line":"\ttestfolder=\"/tmp/batspp-211587/test-6\"","class":"lineCov","hits":"2","order":"607","possible_hits":"0",},
{"lineNum":"  150","line":"\tmkdir --parents \"$testfolder\"","class":"lineCov","hits":"2","order":"608","possible_hits":"0",},
{"lineNum":"  151","line":"\tbuiltin cd \"$testfolder\" || echo Warning: Unable to \"cd $testfolder\"","class":"lineCov","hits":"2","order":"609","possible_hits":"0",},
{"lineNum":"  152","line":""},
{"lineNum":"  153","line":"\techo \"==========\" $\'source $BIN_DIR/tomohara-aliases.bash\\n\' \"==========\"","class":"lineCov","hits":"2","order":"610","possible_hits":"0",},
{"lineNum":"  154","line":"\ttest-6-actual","class":"lineCov","hits":"2","order":"611","possible_hits":"0",},
{"lineNum":"  155","line":"\techo \"=========\" $\'\' \"=========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  156","line":"\ttest-6-expected","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  157","line":"\techo \"============================\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  158","line":"\t# ???: \'source $BIN_DIR/tomohara-aliases.bash\\n\'=$(test-6-actual)"},
{"lineNum":"  159","line":"\t# ???: \'\'=$(test-6-expected)"},
{"lineNum":"  160","line":"\t[ \"$(test-6-actual)\" == \"$(test-6-expected)\" ]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  161","line":"}"},
{"lineNum":"  162","line":""},
{"lineNum":"  163","line":"function test-6-actual () {"},
{"lineNum":"  164","line":"\t# no-op in case content just a comment"},
{"lineNum":"  165","line":"\ttrue","class":"lineCov","hits":"2","order":"612","possible_hits":"0",},
{"lineNum":"  166","line":""},
{"lineNum":"  167","line":"\tsource $BIN_DIR/tomohara-aliases.bash","class":"lineCov","hits":"2","order":"613","possible_hits":"0",},
{"lineNum":"  168","line":""},
{"lineNum":"  169","line":"}"},
{"lineNum":"  170","line":""},
{"lineNum":"  171","line":"function test-6-expected () {"},
{"lineNum":"  172","line":"\t# no-op in case content just a comment"},
{"lineNum":"  173","line":"\ttrue","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  174","line":""},
{"lineNum":"  175","line":"\tcat <<END_EXPECTED","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  176","line":""},
{"lineNum":"  177","line":"END_EXPECTED"},
{"lineNum":"  178","line":"}"},
{"lineNum":"  179","line":""},
{"lineNum":"  180","line":""},
{"lineNum":"  181","line":"test_test-2d7() { bats_test_begin \"test-7\";"},
{"lineNum":"  182","line":"\ttestfolder=\"/tmp/batspp-211587/test-7\"","class":"lineCov","hits":"2","order":"615","possible_hits":"0",},
{"lineNum":"  183","line":"\tmkdir --parents \"$testfolder\"","class":"lineCov","hits":"2","order":"616","possible_hits":"0",},
{"lineNum":"  184","line":"\tbuiltin cd \"$testfolder\" || echo Warning: Unable to \"cd $testfolder\"","class":"lineCov","hits":"2","order":"617","possible_hits":"0",},
{"lineNum":"  185","line":""},
{"lineNum":"  186","line":"\techo \"==========\" $\'clear\\n\' \"==========\"","class":"lineCov","hits":"2","order":"618","possible_hits":"0",},
{"lineNum":"  187","line":"\ttest-7-actual","class":"lineCov","hits":"2","order":"619","possible_hits":"0",},
{"lineNum":"  188","line":"\techo \"=========\" $\'use cls instead (or /bin/clear)\' \"=========\"","class":"lineCov","hits":"2","order":"622","possible_hits":"0",},
{"lineNum":"  189","line":"\ttest-7-expected","class":"lineCov","hits":"2","order":"623","possible_hits":"0",},
{"lineNum":"  190","line":"\techo \"============================\"","class":"lineCov","hits":"2","order":"626","possible_hits":"0",},
{"lineNum":"  191","line":"\t# ???: \'clear\\n\'=$(test-7-actual)"},
{"lineNum":"  192","line":"\t# ???: \'use cls instead (or /bin/clear)\'=$(test-7-expected)"},
{"lineNum":"  193","line":"\t[ \"$(test-7-actual)\" == \"$(test-7-expected)\" ]","class":"lineCov","hits":"8","order":"627","possible_hits":"0",},
{"lineNum":"  194","line":"}"},
{"lineNum":"  195","line":""},
{"lineNum":"  196","line":"function test-7-actual () {"},
{"lineNum":"  197","line":"\t# no-op in case content just a comment"},
{"lineNum":"  198","line":"\ttrue","class":"lineCov","hits":"4","order":"620","possible_hits":"0",},
{"lineNum":"  199","line":""},
{"lineNum":"  200","line":"\tclear","class":"lineCov","hits":"4","order":"621","possible_hits":"0",},
{"lineNum":"  201","line":""},
{"lineNum":"  202","line":"}"},
{"lineNum":"  203","line":""},
{"lineNum":"  204","line":"function test-7-expected () {"},
{"lineNum":"  205","line":"\t# no-op in case content just a comment"},
{"lineNum":"  206","line":"\ttrue","class":"lineCov","hits":"4","order":"624","possible_hits":"0",},
{"lineNum":"  207","line":""},
{"lineNum":"  208","line":"\tcat <<END_EXPECTED","class":"lineCov","hits":"4","order":"625","possible_hits":"0",},
{"lineNum":"  209","line":"use cls instead (or /bin/clear)"},
{"lineNum":"  210","line":"END_EXPECTED"},
{"lineNum":"  211","line":"}"},
{"lineNum":"  212","line":""},
{"lineNum":"  213","line":""},
{"lineNum":"  214","line":"test_test-2d8() { bats_test_begin \"test-8\";"},
{"lineNum":"  215","line":"\ttestfolder=\"/tmp/batspp-211587/test-8\"","class":"lineCov","hits":"2","order":"628","possible_hits":"0",},
{"lineNum":"  216","line":"\tmkdir --parents \"$testfolder\"","class":"lineCov","hits":"2","order":"629","possible_hits":"0",},
{"lineNum":"  217","line":"\tbuiltin cd \"$testfolder\" || echo Warning: Unable to \"cd $testfolder\"","class":"lineCov","hits":"2","order":"630","possible_hits":"0",},
{"lineNum":"  218","line":""},
{"lineNum":"  219","line":"\techo \"==========\" $\'help\\n\' \"==========\"","class":"lineCov","hits":"2","order":"631","possible_hits":"0",},
{"lineNum":"  220","line":"\ttest-8-actual","class":"lineCov","hits":"2","order":"632","possible_hits":"0",},
{"lineNum":"  221","line":"\techo \"=========\" $\"GNU bash, version 5.1.16(1)-release (x86_64-pc-linux-gnu)\\nThese shell commands are defined internally.  Type `help\' to see this list.\\nType `help name\' to find out more about the function `name\'.\\nUse `info bash\' to find out more about the shell in general.\\nUse `man -k\' or `info\' to find out more about commands not in this list.\" \"=========\"","class":"lineCov","hits":"2","order":"635","possible_hits":"0",},
{"lineNum":"  222","line":"\ttest-8-expected","class":"lineCov","hits":"2","order":"636","possible_hits":"0",},
{"lineNum":"  223","line":"\techo \"============================\"","class":"lineCov","hits":"2","order":"639","possible_hits":"0",},
{"lineNum":"  224","line":"\t# ???: \'help\\n\'=$(test-8-actual)"},
{"lineNum":"  225","line":"\t# ???: \"GNU bash, version 5.1.16(1)-release (x86_64-pc-linux-gnu)\\nThese shell commands are defined internally.  Type `help\' to see this list.\\nType `help name\' to find out more about the function `name\'.\\nUse `info bash\' to find out more about the shell in general.\\nUse `man -k\' or `info\' to find out more about commands not in this list.\"=$(test-8-expected)"},
{"lineNum":"  226","line":"\t[ \"$(test-8-actual)\" == \"$(test-8-expected)\" ]","class":"lineCov","hits":"8","order":"640","possible_hits":"0",},
{"lineNum":"  227","line":"}"},
{"lineNum":"  228","line":""},
{"lineNum":"  229","line":"function test-8-actual () {"},
{"lineNum":"  230","line":"\t# no-op in case content just a comment"},
{"lineNum":"  231","line":"\ttrue","class":"lineCov","hits":"4","order":"633","possible_hits":"0",},
{"lineNum":"  232","line":""},
{"lineNum":"  233","line":"\thelp","class":"lineCov","hits":"4","order":"634","possible_hits":"0",},
{"lineNum":"  234","line":""},
{"lineNum":"  235","line":"}"},
{"lineNum":"  236","line":""},
{"lineNum":"  237","line":"function test-8-expected () {"},
{"lineNum":"  238","line":"\t# no-op in case content just a comment"},
{"lineNum":"  239","line":"\ttrue","class":"lineCov","hits":"4","order":"637","possible_hits":"0",},
{"lineNum":"  240","line":""},
{"lineNum":"  241","line":"\tcat <<END_EXPECTED","class":"lineCov","hits":"4","order":"638","possible_hits":"0",},
{"lineNum":"  242","line":"GNU bash, version 5.1.16(1)-release (x86_64-pc-linux-gnu)"},
{"lineNum":"  243","line":"These shell commands are defined internally.  Type `help\' to see this list."},
{"lineNum":"  244","line":"Type `help name\' to find out more about the function `name\'."},
{"lineNum":"  245","line":"Use `info bash\' to find out more about the shell in general."},
{"lineNum":"  246","line":"Use `man -k\' or `info\' to find out more about commands not in this list."},
{"lineNum":"  247","line":"END_EXPECTED"},
{"lineNum":"  248","line":"}"},
{"lineNum":"  249","line":""},
{"lineNum":"  250","line":""},
{"lineNum":"  251","line":"test_test-2d9() { bats_test_begin \"test-9\";"},
{"lineNum":"  252","line":"\ttestfolder=\"/tmp/batspp-211587/test-9\"","class":"lineCov","hits":"2","order":"641","possible_hits":"0",},
{"lineNum":"  253","line":"\tmkdir --parents \"$testfolder\"","class":"lineCov","hits":"2","order":"642","possible_hits":"0",},
{"lineNum":"  254","line":"\tbuiltin cd \"$testfolder\" || echo Warning: Unable to \"cd $testfolder\"","class":"lineCov","hits":"2","order":"643","possible_hits":"0",},
{"lineNum":"  255","line":""},
{"lineNum":"  256","line":"\techo \"==========\" $\'history -c\\n\' \"==========\"","class":"lineCov","hits":"2","order":"644","possible_hits":"0",},
{"lineNum":"  257","line":"\ttest-9-actual","class":"lineCov","hits":"2","order":"645","possible_hits":"0",},
{"lineNum":"  258","line":"\techo \"=========\" $\'\' \"=========\"","class":"lineCov","hits":"2","order":"648","possible_hits":"0",},
{"lineNum":"  259","line":"\ttest-9-expected","class":"lineCov","hits":"2","order":"649","possible_hits":"0",},
{"lineNum":"  260","line":"\techo \"============================\"","class":"lineCov","hits":"2","order":"652","possible_hits":"0",},
{"lineNum":"  261","line":"\t# ???: \'history -c\\n\'=$(test-9-actual)"},
{"lineNum":"  262","line":"\t# ???: \'\'=$(test-9-expected)"},
{"lineNum":"  263","line":"\t[ \"$(test-9-actual)\" == \"$(test-9-expected)\" ]","class":"lineCov","hits":"6","order":"653","possible_hits":"0",},
{"lineNum":"  264","line":"}"},
{"lineNum":"  265","line":""},
{"lineNum":"  266","line":"function test-9-actual () {"},
{"lineNum":"  267","line":"\t# no-op in case content just a comment"},
{"lineNum":"  268","line":"\ttrue","class":"lineCov","hits":"4","order":"646","possible_hits":"0",},
{"lineNum":"  269","line":""},
{"lineNum":"  270","line":"\thistory -c","class":"lineCov","hits":"4","order":"647","possible_hits":"0",},
{"lineNum":"  271","line":""},
{"lineNum":"  272","line":"}"},
{"lineNum":"  273","line":""},
{"lineNum":"  274","line":"function test-9-expected () {"},
{"lineNum":"  275","line":"\t# no-op in case content just a comment"},
{"lineNum":"  276","line":"\ttrue","class":"lineCov","hits":"4","order":"650","possible_hits":"0",},
{"lineNum":"  277","line":""},
{"lineNum":"  278","line":"\tcat <<END_EXPECTED","class":"lineCov","hits":"4","order":"651","possible_hits":"0",},
{"lineNum":"  279","line":""},
{"lineNum":"  280","line":"END_EXPECTED"},
{"lineNum":"  281","line":"}"},
{"lineNum":"  282","line":""},
{"lineNum":"  283","line":""},
{"lineNum":"  284","line":"test_test-2d10() { bats_test_begin \"test-10\";"},
{"lineNum":"  285","line":"\ttestfolder=\"/tmp/batspp-211587/test-10\"","class":"lineCov","hits":"2","order":"661","possible_hits":"0",},
{"lineNum":"  286","line":"\tmkdir --parents \"$testfolder\"","class":"lineCov","hits":"2","order":"662","possible_hits":"0",},
{"lineNum":"  287","line":"\tbuiltin cd \"$testfolder\" || echo Warning: Unable to \"cd $testfolder\"","class":"lineCov","hits":"2","order":"663","possible_hits":"0",},
{"lineNum":"  288","line":""},
{"lineNum":"  289","line":"\techo \"==========\" $\'hist\\n\' \"==========\"","class":"lineCov","hits":"2","order":"664","possible_hits":"0",},
{"lineNum":"  290","line":"\ttest-10-actual","class":"lineCov","hits":"2","order":"665","possible_hits":"0",},
{"lineNum":"  291","line":"\techo \"=========\" $\'1  [2023-04-06 20:32:50] echo $?\\n    2  [2023-04-06 20:32:52] hist\' \"=========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  292","line":"\ttest-10-expected","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  293","line":"\techo \"============================\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  294","line":"\t# ???: \'hist\\n\'=$(test-10-actual)"},
{"lineNum":"  295","line":"\t# ???: \'1  [2023-04-06 20:32:50] echo $?\\n    2  [2023-04-06 20:32:52] hist\'=$(test-10-expected)"},
{"lineNum":"  296","line":"\t[ \"$(test-10-actual)\" == \"$(test-10-expected)\" ]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  297","line":"}"},
{"lineNum":"  298","line":""},
{"lineNum":"  299","line":"function test-10-actual () {"},
{"lineNum":"  300","line":"\t# no-op in case content just a comment"},
{"lineNum":"  301","line":"\ttrue","class":"lineCov","hits":"2","order":"666","possible_hits":"0",},
{"lineNum":"  302","line":""},
{"lineNum":"  303","line":"\thist","class":"lineCov","hits":"4","order":"667","possible_hits":"0",},
{"lineNum":"  304","line":""},
{"lineNum":"  305","line":"}"},
{"lineNum":"  306","line":""},
{"lineNum":"  307","line":"function test-10-expected () {"},
{"lineNum":"  308","line":"\t# no-op in case content just a comment"},
{"lineNum":"  309","line":"\ttrue","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  310","line":""},
{"lineNum":"  311","line":"\tcat <<END_EXPECTED","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  312","line":"1  [2023-04-06 20:32:50] echo $?"},
{"lineNum":"  313","line":"    2  [2023-04-06 20:32:52] hist"},
{"lineNum":"  314","line":"END_EXPECTED"},
{"lineNum":"  315","line":"}"},
{"lineNum":"  316","line":""},
{"lineNum":"  317","line":"bats_test_function --tags \'\' test_test-2d1","class":"lineCov","hits":"11","order":"350","possible_hits":"0",},
{"lineNum":"  318","line":"bats_test_function --tags \'\' test_test-2d3","class":"lineCov","hits":"11","order":"351","possible_hits":"0",},
{"lineNum":"  319","line":"bats_test_function --tags \'\' test_test-2d4","class":"lineCov","hits":"11","order":"352","possible_hits":"0",},
{"lineNum":"  320","line":"bats_test_function --tags \'\' test_test-2d5","class":"lineCov","hits":"11","order":"353","possible_hits":"0",},
{"lineNum":"  321","line":"bats_test_function --tags \'\' test_test-2d6","class":"lineCov","hits":"11","order":"354","possible_hits":"0",},
{"lineNum":"  322","line":"bats_test_function --tags \'\' test_test-2d7","class":"lineCov","hits":"11","order":"355","possible_hits":"0",},
{"lineNum":"  323","line":"bats_test_function --tags \'\' test_test-2d8","class":"lineCov","hits":"11","order":"356","possible_hits":"0",},
{"lineNum":"  324","line":"bats_test_function --tags \'\' test_test-2d9","class":"lineCov","hits":"11","order":"357","possible_hits":"0",},
{"lineNum":"  325","line":"bats_test_function --tags \'\' test_test-2d10","class":"lineCov","hits":"11","order":"358","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "bats", "date" : "2023-06-15 21:55:57", "instrumented" : 126, "covered" : 108,};
var merged_data = [];
