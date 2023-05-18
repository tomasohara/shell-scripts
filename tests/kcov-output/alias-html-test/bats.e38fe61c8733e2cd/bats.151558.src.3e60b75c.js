var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bats"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":""},
{"lineNum":"    4","line":"# Make executables ./tests/../ visible to PATH"},
{"lineNum":"    5","line":"PATH=\"/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH\"","class":"lineCov","hits":"14","order":"333","possible_hits":"0",},
{"lineNum":"    6","line":""},
{"lineNum":"    7","line":"# Enable aliases"},
{"lineNum":"    8","line":"shopt -s expand_aliases","class":"lineCov","hits":"14","order":"349","possible_hits":"0",},
{"lineNum":"    9","line":""},
{"lineNum":"   10","line":""},
{"lineNum":"   11","line":""},
{"lineNum":"   12","line":"test_test-2d1() { bats_test_begin \"test-1\";"},
{"lineNum":"   13","line":"\ttestfolder=\"/tmp/batspp-151240/test-1\"","class":"lineCov","hits":"2","order":"437","possible_hits":"0",},
{"lineNum":"   14","line":"\tmkdir --parents \"$testfolder\"","class":"lineCov","hits":"2","order":"438","possible_hits":"0",},
{"lineNum":"   15","line":"\tcd \"$testfolder\" || echo Warning: Unable to \"cd $testfolder\"","class":"lineCov","hits":"2","order":"439","possible_hits":"0",},
{"lineNum":"   16","line":""},
{"lineNum":"   17","line":"\techo \"==========\" $\'# $ jupyter notebook --allow-root\\n\' \"==========\"","class":"lineCov","hits":"2","order":"440","possible_hits":"0",},
{"lineNum":"   18","line":"\ttest-1-actual","class":"lineCov","hits":"2","order":"441","possible_hits":"0",},
{"lineNum":"   19","line":"\techo \"=========\" $\"## Bracketed Paste is disabled to prevent characters after output\\n## Example: \\n# $ echo \'Hi\'\\n# | Hi?2004l\\n# bind \'set enable-bracketed-paste off\'\" \"=========\"","class":"lineCov","hits":"2","order":"443","possible_hits":"0",},
{"lineNum":"   20","line":"\ttest-1-expected","class":"lineCov","hits":"2","order":"444","possible_hits":"0",},
{"lineNum":"   21","line":"\techo \"============================\"","class":"lineCov","hits":"2","order":"447","possible_hits":"0",},
{"lineNum":"   22","line":"\t# ???: \'# $ jupyter notebook --allow-root\\n\'=$(test-1-actual)"},
{"lineNum":"   23","line":"\t# ???: \"## Bracketed Paste is disabled to prevent characters after output\\n## Example: \\n# $ echo \'Hi\'\\n# | Hi?2004l\\n# bind \'set enable-bracketed-paste off\'\"=$(test-1-expected)"},
{"lineNum":"   24","line":"\t[ \"$(test-1-actual)\" == \"$(test-1-expected)\" ]","class":"lineCov","hits":"8","order":"448","possible_hits":"0",},
{"lineNum":"   25","line":"}"},
{"lineNum":"   26","line":""},
{"lineNum":"   27","line":"function test-1-actual () {"},
{"lineNum":"   28","line":"\t# no-op in case content just a comment"},
{"lineNum":"   29","line":"\ttrue","class":"lineCov","hits":"4","order":"442","possible_hits":"0",},
{"lineNum":"   30","line":""},
{"lineNum":"   31","line":""},
{"lineNum":"   32","line":"}"},
{"lineNum":"   33","line":""},
{"lineNum":"   34","line":"function test-1-expected () {"},
{"lineNum":"   35","line":"\t# no-op in case content just a comment"},
{"lineNum":"   36","line":"\ttrue","class":"lineCov","hits":"4","order":"445","possible_hits":"0",},
{"lineNum":"   37","line":""},
{"lineNum":"   38","line":"\tcat <<END_EXPECTED","class":"lineCov","hits":"4","order":"446","possible_hits":"0",},
{"lineNum":"   39","line":"## Bracketed Paste is disabled to prevent characters after output"},
{"lineNum":"   40","line":"## Example:"},
{"lineNum":"   41","line":"# $ echo \'Hi\'"},
{"lineNum":"   42","line":"# | Hi?2004l"},
{"lineNum":"   43","line":"# bind \'set enable-bracketed-paste off\'"},
{"lineNum":"   44","line":"END_EXPECTED"},
{"lineNum":"   45","line":"}"},
{"lineNum":"   46","line":""},
{"lineNum":"   47","line":""},
{"lineNum":"   48","line":"test_test-2d3() { bats_test_begin \"test-3\";"},
{"lineNum":"   49","line":"\ttestfolder=\"/tmp/batspp-151240/test-3\"","class":"lineCov","hits":"2","order":"571","possible_hits":"0",},
{"lineNum":"   50","line":"\tmkdir --parents \"$testfolder\"","class":"lineCov","hits":"2","order":"572","possible_hits":"0",},
{"lineNum":"   51","line":"\tcd \"$testfolder\" || echo Warning: Unable to \"cd $testfolder\"","class":"lineCov","hits":"2","order":"573","possible_hits":"0",},
{"lineNum":"   52","line":""},
{"lineNum":"   53","line":"\techo \"==========\" $\'echo $PS1\\n\' \"==========\"","class":"lineCov","hits":"2","order":"574","possible_hits":"0",},
{"lineNum":"   54","line":"\ttest-3-actual","class":"lineCov","hits":"2","order":"575","possible_hits":"0",},
{"lineNum":"   55","line":"\techo \"=========\" $\'[PEXP\\\\[\\\\]ECT_PROMPT>\' \"=========\"","class":"lineCov","hits":"2","order":"578","possible_hits":"0",},
{"lineNum":"   56","line":"\ttest-3-expected","class":"lineCov","hits":"2","order":"579","possible_hits":"0",},
{"lineNum":"   57","line":"\techo \"============================\"","class":"lineCov","hits":"2","order":"582","possible_hits":"0",},
{"lineNum":"   58","line":"\t# ???: \'echo $PS1\\n\'=$(test-3-actual)"},
{"lineNum":"   59","line":"\t# ???: \'[PEXP\\\\[\\\\]ECT_PROMPT>\'=$(test-3-expected)"},
{"lineNum":"   60","line":"\t[ \"$(test-3-actual)\" == \"$(test-3-expected)\" ]","class":"lineCov","hits":"8","order":"583","possible_hits":"0",},
{"lineNum":"   61","line":"}"},
{"lineNum":"   62","line":""},
{"lineNum":"   63","line":"function test-3-actual () {"},
{"lineNum":"   64","line":"\t# no-op in case content just a comment"},
{"lineNum":"   65","line":"\ttrue","class":"lineCov","hits":"4","order":"576","possible_hits":"0",},
{"lineNum":"   66","line":""},
{"lineNum":"   67","line":"\techo $PS1","class":"lineCov","hits":"4","order":"577","possible_hits":"0",},
{"lineNum":"   68","line":""},
{"lineNum":"   69","line":"}"},
{"lineNum":"   70","line":""},
{"lineNum":"   71","line":"function test-3-expected () {"},
{"lineNum":"   72","line":"\t# no-op in case content just a comment"},
{"lineNum":"   73","line":"\ttrue","class":"lineCov","hits":"4","order":"580","possible_hits":"0",},
{"lineNum":"   74","line":""},
{"lineNum":"   75","line":"\tcat <<END_EXPECTED","class":"lineCov","hits":"4","order":"581","possible_hits":"0",},
{"lineNum":"   76","line":"[PEXP\\[\\]ECT_PROMPT>"},
{"lineNum":"   77","line":"END_EXPECTED"},
{"lineNum":"   78","line":"}"},
{"lineNum":"   79","line":""},
{"lineNum":"   80","line":""},
{"lineNum":"   81","line":"test_test-2d4() { bats_test_begin \"test-4\";"},
{"lineNum":"   82","line":"\ttestfolder=\"/tmp/batspp-151240/test-4\"","class":"lineCov","hits":"2","order":"584","possible_hits":"0",},
{"lineNum":"   83","line":"\tmkdir --parents \"$testfolder\"","class":"lineCov","hits":"2","order":"585","possible_hits":"0",},
{"lineNum":"   84","line":"\tcd \"$testfolder\" || echo Warning: Unable to \"cd $testfolder\"","class":"lineCov","hits":"2","order":"586","possible_hits":"0",},
{"lineNum":"   85","line":""},
{"lineNum":"   86","line":"\techo \"==========\" $\'unalias -a\\n\' \"==========\"","class":"lineCov","hits":"2","order":"587","possible_hits":"0",},
{"lineNum":"   87","line":"\ttest-4-actual","class":"lineCov","hits":"2","order":"588","possible_hits":"0",},
{"lineNum":"   88","line":"\techo \"=========\" $\"$ alias | wc -l\\n$ for f in $(typeset -f | egrep \'^\\\\w+\'); do unset -f $f; done\\n$ typeset -f | egrep \'^\\\\w+\' | wc -l\\n0\\n0\" \"=========\"","class":"lineCov","hits":"8","order":"591","possible_hits":"0",},
{"lineNum":"   89","line":"\ttest-4-expected","class":"lineCov","hits":"2","order":"592","possible_hits":"0",},
{"lineNum":"   90","line":"\techo \"============================\"","class":"lineCov","hits":"2","order":"595","possible_hits":"0",},
{"lineNum":"   91","line":"\t# ???: \'unalias -a\\n\'=$(test-4-actual)"},
{"lineNum":"   92","line":"\t# ???: \"$ alias | wc -l\\n$ for f in $(typeset -f | egrep \'^\\\\w+\'); do unset -f $f; done\\n$ typeset -f | egrep \'^\\\\w+\' | wc -l\\n0\\n0\"=$(test-4-expected)"},
{"lineNum":"   93","line":"\t[ \"$(test-4-actual)\" == \"$(test-4-expected)\" ]","class":"lineCov","hits":"8","order":"596","possible_hits":"0",},
{"lineNum":"   94","line":"}"},
{"lineNum":"   95","line":""},
{"lineNum":"   96","line":"function test-4-actual () {"},
{"lineNum":"   97","line":"\t# no-op in case content just a comment"},
{"lineNum":"   98","line":"\ttrue","class":"lineCov","hits":"4","order":"589","possible_hits":"0",},
{"lineNum":"   99","line":""},
{"lineNum":"  100","line":"\tunalias -a","class":"lineCov","hits":"4","order":"590","possible_hits":"0",},
{"lineNum":"  101","line":""},
{"lineNum":"  102","line":"}"},
{"lineNum":"  103","line":""},
{"lineNum":"  104","line":"function test-4-expected () {"},
{"lineNum":"  105","line":"\t# no-op in case content just a comment"},
{"lineNum":"  106","line":"\ttrue","class":"lineCov","hits":"4","order":"593","possible_hits":"0",},
{"lineNum":"  107","line":""},
{"lineNum":"  108","line":"\tcat <<END_EXPECTED","class":"lineCov","hits":"12","order":"594","possible_hits":"0",},
{"lineNum":"  109","line":"$ alias | wc -l"},
{"lineNum":"  110","line":"$ for f in $(typeset -f | egrep \'^\\w+\'); do unset -f $f; done"},
{"lineNum":"  111","line":"$ typeset -f | egrep \'^\\w+\' | wc -l"},
{"lineNum":"  112","line":"0"},
{"lineNum":"  113","line":"0"},
{"lineNum":"  114","line":"END_EXPECTED"},
{"lineNum":"  115","line":"}"},
{"lineNum":"  116","line":""},
{"lineNum":"  117","line":""},
{"lineNum":"  118","line":"test_test-2d5() { bats_test_begin \"test-5\";"},
{"lineNum":"  119","line":"\ttestfolder=\"/tmp/batspp-151240/test-5\"","class":"lineCov","hits":"2","order":"597","possible_hits":"0",},
{"lineNum":"  120","line":"\tmkdir --parents \"$testfolder\"","class":"lineCov","hits":"2","order":"598","possible_hits":"0",},
{"lineNum":"  121","line":"\tcd \"$testfolder\" || echo Warning: Unable to \"cd $testfolder\"","class":"lineCov","hits":"2","order":"599","possible_hits":"0",},
{"lineNum":"  122","line":""},
{"lineNum":"  123","line":"\techo \"==========\" $\'alias testuser=\"sed -r \"s/\"$USER\"+/userxf333/g\"\"\\n\' \"==========\"","class":"lineCov","hits":"2","order":"600","possible_hits":"0",},
{"lineNum":"  124","line":"\ttest-5-actual","class":"lineCov","hits":"2","order":"601","possible_hits":"0",},
{"lineNum":"  125","line":"\techo \"=========\" $\'$ alias testnum=\"sed -r \"s/[0-9]/N/g\"\"\' \"=========\"","class":"lineCov","hits":"2","order":"604","possible_hits":"0",},
{"lineNum":"  126","line":"\ttest-5-expected","class":"lineCov","hits":"2","order":"605","possible_hits":"0",},
{"lineNum":"  127","line":"\techo \"============================\"","class":"lineCov","hits":"2","order":"608","possible_hits":"0",},
{"lineNum":"  128","line":"\t# ???: \'alias testuser=\"sed -r \"s/\"$USER\"+/userxf333/g\"\"\\n\'=$(test-5-actual)"},
{"lineNum":"  129","line":"\t# ???: \'$ alias testnum=\"sed -r \"s/[0-9]/N/g\"\"\'=$(test-5-expected)"},
{"lineNum":"  130","line":"\t[ \"$(test-5-actual)\" == \"$(test-5-expected)\" ]","class":"lineCov","hits":"8","order":"609","possible_hits":"0",},
{"lineNum":"  131","line":"}"},
{"lineNum":"  132","line":""},
{"lineNum":"  133","line":"function test-5-actual () {"},
{"lineNum":"  134","line":"\t# no-op in case content just a comment"},
{"lineNum":"  135","line":"\ttrue","class":"lineCov","hits":"4","order":"602","possible_hits":"0",},
{"lineNum":"  136","line":""},
{"lineNum":"  137","line":"\talias testuser=\"sed -r \"s/\"$USER\"+/userxf333/g\"\"","class":"lineCov","hits":"4","order":"603","possible_hits":"0",},
{"lineNum":"  138","line":""},
{"lineNum":"  139","line":"}"},
{"lineNum":"  140","line":""},
{"lineNum":"  141","line":"function test-5-expected () {"},
{"lineNum":"  142","line":"\t# no-op in case content just a comment"},
{"lineNum":"  143","line":"\ttrue","class":"lineCov","hits":"4","order":"606","possible_hits":"0",},
{"lineNum":"  144","line":""},
{"lineNum":"  145","line":"\tcat <<END_EXPECTED","class":"lineCov","hits":"4","order":"607","possible_hits":"0",},
{"lineNum":"  146","line":"$ alias testnum=\"sed -r \"s/[0-9]/N/g\"\""},
{"lineNum":"  147","line":"END_EXPECTED"},
{"lineNum":"  148","line":"}"},
{"lineNum":"  149","line":""},
{"lineNum":"  150","line":""},
{"lineNum":"  151","line":"test_test-2d6() { bats_test_begin \"test-6\";"},
{"lineNum":"  152","line":"\ttestfolder=\"/tmp/batspp-151240/test-6\"","class":"lineCov","hits":"2","order":"610","possible_hits":"0",},
{"lineNum":"  153","line":"\tmkdir --parents \"$testfolder\"","class":"lineCov","hits":"2","order":"611","possible_hits":"0",},
{"lineNum":"  154","line":"\tcd \"$testfolder\" || echo Warning: Unable to \"cd $testfolder\"","class":"lineCov","hits":"2","order":"612","possible_hits":"0",},
{"lineNum":"  155","line":""},
{"lineNum":"  156","line":"\techo \"==========\" $\'TMP=/tmp/test-admin-commands\\n\' \"==========\"","class":"lineCov","hits":"2","order":"613","possible_hits":"0",},
{"lineNum":"  157","line":"\ttest-6-actual","class":"lineCov","hits":"2","order":"614","possible_hits":"0",},
{"lineNum":"  158","line":"\techo \"=========\" $\'## NOTE: Source it directly from the ./tests directory.\\n$ BIN_DIR=$PWD/..\\n$ alias | wc -l\\n2\' \"=========\"","class":"lineCov","hits":"2","order":"617","possible_hits":"0",},
{"lineNum":"  159","line":"\ttest-6-expected","class":"lineCov","hits":"2","order":"618","possible_hits":"0",},
{"lineNum":"  160","line":"\techo \"============================\"","class":"lineCov","hits":"2","order":"621","possible_hits":"0",},
{"lineNum":"  161","line":"\t# ???: \'TMP=/tmp/test-admin-commands\\n\'=$(test-6-actual)"},
{"lineNum":"  162","line":"\t# ???: \'## NOTE: Source it directly from the ./tests directory.\\n$ BIN_DIR=$PWD/..\\n$ alias | wc -l\\n2\'=$(test-6-expected)"},
{"lineNum":"  163","line":"\t[ \"$(test-6-actual)\" == \"$(test-6-expected)\" ]","class":"lineCov","hits":"8","order":"622","possible_hits":"0",},
{"lineNum":"  164","line":"}"},
{"lineNum":"  165","line":""},
{"lineNum":"  166","line":"function test-6-actual () {"},
{"lineNum":"  167","line":"\t# no-op in case content just a comment"},
{"lineNum":"  168","line":"\ttrue","class":"lineCov","hits":"4","order":"615","possible_hits":"0",},
{"lineNum":"  169","line":""},
{"lineNum":"  170","line":"\tTMP=/tmp/test-admin-commands","class":"lineCov","hits":"4","order":"616","possible_hits":"0",},
{"lineNum":"  171","line":""},
{"lineNum":"  172","line":"}"},
{"lineNum":"  173","line":""},
{"lineNum":"  174","line":"function test-6-expected () {"},
{"lineNum":"  175","line":"\t# no-op in case content just a comment"},
{"lineNum":"  176","line":"\ttrue","class":"lineCov","hits":"4","order":"619","possible_hits":"0",},
{"lineNum":"  177","line":""},
{"lineNum":"  178","line":"\tcat <<END_EXPECTED","class":"lineCov","hits":"4","order":"620","possible_hits":"0",},
{"lineNum":"  179","line":"## NOTE: Source it directly from the ./tests directory."},
{"lineNum":"  180","line":"$ BIN_DIR=$PWD/.."},
{"lineNum":"  181","line":"$ alias | wc -l"},
{"lineNum":"  182","line":"2"},
{"lineNum":"  183","line":"END_EXPECTED"},
{"lineNum":"  184","line":"}"},
{"lineNum":"  185","line":""},
{"lineNum":"  186","line":""},
{"lineNum":"  187","line":"test_test-2d7() { bats_test_begin \"test-7\";"},
{"lineNum":"  188","line":"\ttestfolder=\"/tmp/batspp-151240/test-7\"","class":"lineCov","hits":"2","order":"623","possible_hits":"0",},
{"lineNum":"  189","line":"\tmkdir --parents \"$testfolder\"","class":"lineCov","hits":"2","order":"624","possible_hits":"0",},
{"lineNum":"  190","line":"\tcd \"$testfolder\" || echo Warning: Unable to \"cd $testfolder\"","class":"lineCov","hits":"2","order":"625","possible_hits":"0",},
{"lineNum":"  191","line":""},
{"lineNum":"  192","line":"\techo \"==========\" $\'temp_dir=$TMP/test-5400\\n\' \"==========\"","class":"lineCov","hits":"2","order":"626","possible_hits":"0",},
{"lineNum":"  193","line":"\ttest-7-actual","class":"lineCov","hits":"2","order":"627","possible_hits":"0",},
{"lineNum":"  194","line":"\techo \"=========\" $\'$ mkdir -p \"$temp_dir\"\\n# TODO: /bin/rm -rvf \"$temp_dir\"\\n$ cd \"$temp_dir\"\\n$ pwd\\n#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)\\n$ alias linebr=\"printf \\\'%*s\\\\n\\\' \"${COLUMNS:-$(tput cols)}\" \\\'\\\' | tr \\\' \\\' -\"\\n/tmp/test-admin-commands/test-5400\' \"=========\"","class":"lineCov","hits":"2","order":"630","possible_hits":"0",},
{"lineNum":"  195","line":"\ttest-7-expected","class":"lineCov","hits":"2","order":"631","possible_hits":"0",},
{"lineNum":"  196","line":"\techo \"============================\"","class":"lineCov","hits":"2","order":"634","possible_hits":"0",},
{"lineNum":"  197","line":"\t# ???: \'temp_dir=$TMP/test-5400\\n\'=$(test-7-actual)"},
{"lineNum":"  198","line":"\t# ???: \'$ mkdir -p \"$temp_dir\"\\n# TODO: /bin/rm -rvf \"$temp_dir\"\\n$ cd \"$temp_dir\"\\n$ pwd\\n#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)\\n$ alias linebr=\"printf \\\'%*s\\\\n\\\' \"${COLUMNS:-$(tput cols)}\" \\\'\\\' | tr \\\' \\\' -\"\\n/tmp/test-admin-commands/test-5400\'=$(test-7-expected)"},
{"lineNum":"  199","line":"\t[ \"$(test-7-actual)\" == \"$(test-7-expected)\" ]","class":"lineCov","hits":"8","order":"635","possible_hits":"0",},
{"lineNum":"  200","line":"}"},
{"lineNum":"  201","line":""},
{"lineNum":"  202","line":"function test-7-actual () {"},
{"lineNum":"  203","line":"\t# no-op in case content just a comment"},
{"lineNum":"  204","line":"\ttrue","class":"lineCov","hits":"4","order":"628","possible_hits":"0",},
{"lineNum":"  205","line":""},
{"lineNum":"  206","line":"\ttemp_dir=$TMP/test-5400","class":"lineCov","hits":"4","order":"629","possible_hits":"0",},
{"lineNum":"  207","line":""},
{"lineNum":"  208","line":"}"},
{"lineNum":"  209","line":""},
{"lineNum":"  210","line":"function test-7-expected () {"},
{"lineNum":"  211","line":"\t# no-op in case content just a comment"},
{"lineNum":"  212","line":"\ttrue","class":"lineCov","hits":"4","order":"632","possible_hits":"0",},
{"lineNum":"  213","line":""},
{"lineNum":"  214","line":"\tcat <<END_EXPECTED","class":"lineCov","hits":"8","order":"633","possible_hits":"0",},
{"lineNum":"  215","line":"$ mkdir -p \"$temp_dir\""},
{"lineNum":"  216","line":"# TODO: /bin/rm -rvf \"$temp_dir\""},
{"lineNum":"  217","line":"$ cd \"$temp_dir\""},
{"lineNum":"  218","line":"$ pwd"},
{"lineNum":"  219","line":"#ALIAS FOR PRINTING SEPERATION LINES (FOR JUPYTER)"},
{"lineNum":"  220","line":"$ alias linebr=\"printf \'%*s\\n\' \"${COLUMNS:-$(tput cols)}\" \'\' | tr \' \' -\""},
{"lineNum":"  221","line":"/tmp/test-admin-commands/test-5400"},
{"lineNum":"  222","line":"END_EXPECTED"},
{"lineNum":"  223","line":"}"},
{"lineNum":"  224","line":""},
{"lineNum":"  225","line":""},
{"lineNum":"  226","line":"test_test-2d8() { bats_test_begin \"test-8\";"},
{"lineNum":"  227","line":"\ttestfolder=\"/tmp/batspp-151240/test-8\"","class":"lineCov","hits":"2","order":"636","possible_hits":"0",},
{"lineNum":"  228","line":"\tmkdir --parents \"$testfolder\"","class":"lineCov","hits":"2","order":"637","possible_hits":"0",},
{"lineNum":"  229","line":"\tcd \"$testfolder\" || echo Warning: Unable to \"cd $testfolder\"","class":"lineCov","hits":"2","order":"638","possible_hits":"0",},
{"lineNum":"  230","line":""},
{"lineNum":"  231","line":"\techo \"==========\" $\'alias | wc -l\\n\' \"==========\"","class":"lineCov","hits":"2","order":"639","possible_hits":"0",},
{"lineNum":"  232","line":"\ttest-8-actual","class":"lineCov","hits":"2","order":"640","possible_hits":"0",},
{"lineNum":"  233","line":"\techo \"=========\" $\"# Count functions\\n$ typeset -f | egrep \'^\\\\w+\' | wc -l\\n3\\n0\" \"=========\"","class":"lineCov","hits":"2","order":"643","possible_hits":"0",},
{"lineNum":"  234","line":"\ttest-8-expected","class":"lineCov","hits":"2","order":"644","possible_hits":"0",},
{"lineNum":"  235","line":"\techo \"============================\"","class":"lineCov","hits":"2","order":"647","possible_hits":"0",},
{"lineNum":"  236","line":"\t# ???: \'alias | wc -l\\n\'=$(test-8-actual)"},
{"lineNum":"  237","line":"\t# ???: \"# Count functions\\n$ typeset -f | egrep \'^\\\\w+\' | wc -l\\n3\\n0\"=$(test-8-expected)"},
{"lineNum":"  238","line":"\t[ \"$(test-8-actual)\" == \"$(test-8-expected)\" ]","class":"lineCov","hits":"8","order":"648","possible_hits":"0",},
{"lineNum":"  239","line":"}"},
{"lineNum":"  240","line":""},
{"lineNum":"  241","line":"function test-8-actual () {"},
{"lineNum":"  242","line":"\t# no-op in case content just a comment"},
{"lineNum":"  243","line":"\ttrue","class":"lineCov","hits":"4","order":"641","possible_hits":"0",},
{"lineNum":"  244","line":""},
{"lineNum":"  245","line":"\talias | wc -l","class":"lineCov","hits":"8","order":"642","possible_hits":"0",},
{"lineNum":"  246","line":""},
{"lineNum":"  247","line":"}"},
{"lineNum":"  248","line":""},
{"lineNum":"  249","line":"function test-8-expected () {"},
{"lineNum":"  250","line":"\t# no-op in case content just a comment"},
{"lineNum":"  251","line":"\ttrue","class":"lineCov","hits":"4","order":"645","possible_hits":"0",},
{"lineNum":"  252","line":""},
{"lineNum":"  253","line":"\tcat <<END_EXPECTED","class":"lineCov","hits":"4","order":"646","possible_hits":"0",},
{"lineNum":"  254","line":"# Count functions"},
{"lineNum":"  255","line":"$ typeset -f | egrep \'^\\w+\' | wc -l"},
{"lineNum":"  256","line":"3"},
{"lineNum":"  257","line":"0"},
{"lineNum":"  258","line":"END_EXPECTED"},
{"lineNum":"  259","line":"}"},
{"lineNum":"  260","line":""},
{"lineNum":"  261","line":""},
{"lineNum":"  262","line":"test_test-2d9() { bats_test_begin \"test-9\";"},
{"lineNum":"  263","line":"\ttestfolder=\"/tmp/batspp-151240/test-9\"","class":"lineCov","hits":"2","order":"649","possible_hits":"0",},
{"lineNum":"  264","line":"\tmkdir --parents \"$testfolder\"","class":"lineCov","hits":"2","order":"650","possible_hits":"0",},
{"lineNum":"  265","line":"\tcd \"$testfolder\" || echo Warning: Unable to \"cd $testfolder\"","class":"lineCov","hits":"2","order":"651","possible_hits":"0",},
{"lineNum":"  266","line":""},
{"lineNum":"  267","line":"\techo \"==========\" $\'source $BIN_DIR/tomohara-aliases.bash\\n\' \"==========\"","class":"lineCov","hits":"2","order":"652","possible_hits":"0",},
{"lineNum":"  268","line":"\ttest-9-actual","class":"lineCov","hits":"2","order":"653","possible_hits":"0",},
{"lineNum":"  269","line":"\techo \"=========\" $\'\' \"=========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  270","line":"\ttest-9-expected","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  271","line":"\techo \"============================\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  272","line":"\t# ???: \'source $BIN_DIR/tomohara-aliases.bash\\n\'=$(test-9-actual)"},
{"lineNum":"  273","line":"\t# ???: \'\'=$(test-9-expected)"},
{"lineNum":"  274","line":"\t[ \"$(test-9-actual)\" == \"$(test-9-expected)\" ]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  275","line":"}"},
{"lineNum":"  276","line":""},
{"lineNum":"  277","line":"function test-9-actual () {"},
{"lineNum":"  278","line":"\t# no-op in case content just a comment"},
{"lineNum":"  279","line":"\ttrue","class":"lineCov","hits":"2","order":"654","possible_hits":"0",},
{"lineNum":"  280","line":""},
{"lineNum":"  281","line":"\tsource $BIN_DIR/tomohara-aliases.bash","class":"lineCov","hits":"2","order":"655","possible_hits":"0",},
{"lineNum":"  282","line":""},
{"lineNum":"  283","line":"}"},
{"lineNum":"  284","line":""},
{"lineNum":"  285","line":"function test-9-expected () {"},
{"lineNum":"  286","line":"\t# no-op in case content just a comment"},
{"lineNum":"  287","line":"\ttrue","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  288","line":""},
{"lineNum":"  289","line":"\tcat <<END_EXPECTED","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  290","line":""},
{"lineNum":"  291","line":"END_EXPECTED"},
{"lineNum":"  292","line":"}"},
{"lineNum":"  293","line":""},
{"lineNum":"  294","line":""},
{"lineNum":"  295","line":"test_test-2d10() { bats_test_begin \"test-10\";"},
{"lineNum":"  296","line":"\ttestfolder=\"/tmp/batspp-151240/test-10\"","class":"lineCov","hits":"2","order":"663","possible_hits":"0",},
{"lineNum":"  297","line":"\tmkdir --parents \"$testfolder\"","class":"lineCov","hits":"2","order":"664","possible_hits":"0",},
{"lineNum":"  298","line":"\tcd \"$testfolder\" || echo Warning: Unable to \"cd $testfolder\"","class":"lineCov","hits":"2","order":"665","possible_hits":"0",},
{"lineNum":"  299","line":""},
{"lineNum":"  300","line":"\techo \"==========\" $\'rm -rf ./* > /dev/null\\n\' \"==========\"","class":"lineCov","hits":"2","order":"666","possible_hits":"0",},
{"lineNum":"  301","line":"\ttest-10-actual","class":"lineCov","hits":"2","order":"667","possible_hits":"0",},
{"lineNum":"  302","line":"\techo \"=========\" $\'$ printf \"<html><h1>THIS IS A HEADER OF SIZE 1</h1><br><i>THIS IS IN ITALICS</i></html>\" >> template1.html\' \"=========\"","class":"lineCov","hits":"2","order":"670","possible_hits":"0",},
{"lineNum":"  303","line":"\ttest-10-expected","class":"lineCov","hits":"2","order":"671","possible_hits":"0",},
{"lineNum":"  304","line":"\techo \"============================\"","class":"lineCov","hits":"2","order":"674","possible_hits":"0",},
{"lineNum":"  305","line":"\t# ???: \'rm -rf ./* > /dev/null\\n\'=$(test-10-actual)"},
{"lineNum":"  306","line":"\t# ???: \'$ printf \"<html><h1>THIS IS A HEADER OF SIZE 1</h1><br><i>THIS IS IN ITALICS</i></html>\" >> template1.html\'=$(test-10-expected)"},
{"lineNum":"  307","line":"\t[ \"$(test-10-actual)\" == \"$(test-10-expected)\" ]","class":"lineCov","hits":"8","order":"675","possible_hits":"0",},
{"lineNum":"  308","line":"}"},
{"lineNum":"  309","line":""},
{"lineNum":"  310","line":"function test-10-actual () {"},
{"lineNum":"  311","line":"\t# no-op in case content just a comment"},
{"lineNum":"  312","line":"\ttrue","class":"lineCov","hits":"4","order":"668","possible_hits":"0",},
{"lineNum":"  313","line":""},
{"lineNum":"  314","line":"\trm -rf ./* > /dev/null","class":"lineCov","hits":"4","order":"669","possible_hits":"0",},
{"lineNum":"  315","line":""},
{"lineNum":"  316","line":"}"},
{"lineNum":"  317","line":""},
{"lineNum":"  318","line":"function test-10-expected () {"},
{"lineNum":"  319","line":"\t# no-op in case content just a comment"},
{"lineNum":"  320","line":"\ttrue","class":"lineCov","hits":"4","order":"672","possible_hits":"0",},
{"lineNum":"  321","line":""},
{"lineNum":"  322","line":"\tcat <<END_EXPECTED","class":"lineCov","hits":"4","order":"673","possible_hits":"0",},
{"lineNum":"  323","line":"$ printf \"<html><h1>THIS IS A HEADER OF SIZE 1</h1><br><i>THIS IS IN ITALICS</i></html>\" >> template1.html"},
{"lineNum":"  324","line":"END_EXPECTED"},
{"lineNum":"  325","line":"}"},
{"lineNum":"  326","line":""},
{"lineNum":"  327","line":""},
{"lineNum":"  328","line":"test_test-2d11() { bats_test_begin \"test-11\";"},
{"lineNum":"  329","line":"\ttestfolder=\"/tmp/batspp-151240/test-11\"","class":"lineCov","hits":"2","order":"676","possible_hits":"0",},
{"lineNum":"  330","line":"\tmkdir --parents \"$testfolder\"","class":"lineCov","hits":"2","order":"677","possible_hits":"0",},
{"lineNum":"  331","line":"\tcd \"$testfolder\" || echo Warning: Unable to \"cd $testfolder\"","class":"lineCov","hits":"2","order":"678","possible_hits":"0",},
{"lineNum":"  332","line":""},
{"lineNum":"  333","line":"\techo \"==========\" $\'check-html template1.html\\n\' \"==========\"","class":"lineCov","hits":"2","order":"679","possible_hits":"0",},
{"lineNum":"  334","line":"\ttest-11-actual","class":"lineCov","hits":"2","order":"680","possible_hits":"0",},
{"lineNum":"  335","line":"\techo \"=========\" $\'\' \"=========\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  336","line":"\ttest-11-expected","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  337","line":"\techo \"============================\"","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  338","line":"\t# ???: \'check-html template1.html\\n\'=$(test-11-actual)"},
{"lineNum":"  339","line":"\t# ???: \'\'=$(test-11-expected)"},
{"lineNum":"  340","line":"\t[ \"$(test-11-actual)\" == \"$(test-11-expected)\" ]","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  341","line":"}"},
{"lineNum":"  342","line":""},
{"lineNum":"  343","line":"function test-11-actual () {"},
{"lineNum":"  344","line":"\t# no-op in case content just a comment"},
{"lineNum":"  345","line":"\ttrue","class":"lineCov","hits":"2","order":"681","possible_hits":"0",},
{"lineNum":"  346","line":""},
{"lineNum":"  347","line":"\tcheck-html template1.html","class":"lineCov","hits":"4","order":"682","possible_hits":"0",},
{"lineNum":"  348","line":""},
{"lineNum":"  349","line":"}"},
{"lineNum":"  350","line":""},
{"lineNum":"  351","line":"function test-11-expected () {"},
{"lineNum":"  352","line":"\t# no-op in case content just a comment"},
{"lineNum":"  353","line":"\ttrue","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  354","line":""},
{"lineNum":"  355","line":"\tcat <<END_EXPECTED","class":"lineNoCov","hits":"0","possible_hits":"0",},
{"lineNum":"  356","line":""},
{"lineNum":"  357","line":"END_EXPECTED"},
{"lineNum":"  358","line":"}"},
{"lineNum":"  359","line":""},
{"lineNum":"  360","line":""},
{"lineNum":"  361","line":"test_test-2d12() { bats_test_begin \"test-12\";"},
{"lineNum":"  362","line":"\ttestfolder=\"/tmp/batspp-151240/test-12\"","class":"lineCov","hits":"2","order":"684","possible_hits":"0",},
{"lineNum":"  363","line":"\tmkdir --parents \"$testfolder\"","class":"lineCov","hits":"2","order":"685","possible_hits":"0",},
{"lineNum":"  364","line":"\tcd \"$testfolder\" || echo Warning: Unable to \"cd $testfolder\"","class":"lineCov","hits":"2","order":"686","possible_hits":"0",},
{"lineNum":"  365","line":""},
{"lineNum":"  366","line":"\techo \"==========\" $\'printf \\\'<!DOCTYPE html><html><body><h1>JavaScript Operators</h1><p>The + operator concatenates (adds) strings.</p><p id=\"demo\"></p><script>var txt1 = \"What a very\";var txt2 = \"nice day\";document.getElementById(\"demo\").innerHTML = txt1 + txt2;</script></body></html>\\\' >> template2.js\\n\' \"==========\"","class":"lineCov","hits":"2","order":"687","possible_hits":"0",},
{"lineNum":"  367","line":"\ttest-12-actual","class":"lineCov","hits":"2","order":"688","possible_hits":"0",},
{"lineNum":"  368","line":"\techo \"=========\" $\'\' \"=========\"","class":"lineCov","hits":"2","order":"691","possible_hits":"0",},
{"lineNum":"  369","line":"\ttest-12-expected","class":"lineCov","hits":"2","order":"692","possible_hits":"0",},
{"lineNum":"  370","line":"\techo \"============================\"","class":"lineCov","hits":"2","order":"695","possible_hits":"0",},
{"lineNum":"  371","line":"\t# ???: \'printf \\\'<!DOCTYPE html><html><body><h1>JavaScript Operators</h1><p>The + operator concatenates (adds) strings.</p><p id=\"demo\"></p><script>var txt1 = \"What a very\";var txt2 = \"nice day\";document.getElementById(\"demo\").innerHTML = txt1 + txt2;</script></body></html>\\\' >> template2.js\\n\'=$(test-12-actual)"},
{"lineNum":"  372","line":"\t# ???: \'\'=$(test-12-expected)"},
{"lineNum":"  373","line":"\t[ \"$(test-12-actual)\" == \"$(test-12-expected)\" ]","class":"lineCov","hits":"6","order":"696","possible_hits":"0",},
{"lineNum":"  374","line":"}"},
{"lineNum":"  375","line":""},
{"lineNum":"  376","line":"function test-12-actual () {"},
{"lineNum":"  377","line":"\t# no-op in case content just a comment"},
{"lineNum":"  378","line":"\ttrue","class":"lineCov","hits":"4","order":"689","possible_hits":"0",},
{"lineNum":"  379","line":""},
{"lineNum":"  380","line":"\tprintf \'<!DOCTYPE html><html><body><h1>JavaScript Operators</h1><p>The + operator concatenates (adds) strings.</p><p id=\"demo\"></p><script>var txt1 = \"What a very\";var txt2 = \"nice day\";document.getElementById(\"demo\").innerHTML = txt1 + txt2;</script></body></html>\' >> template2.js","class":"lineCov","hits":"4","order":"690","possible_hits":"0",},
{"lineNum":"  381","line":""},
{"lineNum":"  382","line":"}"},
{"lineNum":"  383","line":""},
{"lineNum":"  384","line":"function test-12-expected () {"},
{"lineNum":"  385","line":"\t# no-op in case content just a comment"},
{"lineNum":"  386","line":"\ttrue","class":"lineCov","hits":"4","order":"693","possible_hits":"0",},
{"lineNum":"  387","line":""},
{"lineNum":"  388","line":"\tcat <<END_EXPECTED","class":"lineCov","hits":"4","order":"694","possible_hits":"0",},
{"lineNum":"  389","line":""},
{"lineNum":"  390","line":"END_EXPECTED"},
{"lineNum":"  391","line":"}"},
{"lineNum":"  392","line":""},
{"lineNum":"  393","line":""},
{"lineNum":"  394","line":"test_test-2d13() { bats_test_begin \"test-13\";"},
{"lineNum":"  395","line":"\ttestfolder=\"/tmp/batspp-151240/test-13\"","class":"lineCov","hits":"2","order":"704","possible_hits":"0",},
{"lineNum":"  396","line":"\tmkdir --parents \"$testfolder\"","class":"lineCov","hits":"2","order":"705","possible_hits":"0",},
{"lineNum":"  397","line":"\tcd \"$testfolder\" || echo Warning: Unable to \"cd $testfolder\"","class":"lineCov","hits":"2","order":"706","possible_hits":"0",},
{"lineNum":"  398","line":""},
{"lineNum":"  399","line":"\techo \"==========\" $\'# $ check-html-java-script template2.js\\n\' \"==========\"","class":"lineCov","hits":"2","order":"707","possible_hits":"0",},
{"lineNum":"  400","line":"\ttest-13-actual","class":"lineCov","hits":"2","order":"708","possible_hits":"0",},
{"lineNum":"  401","line":"\techo \"=========\" $\'# | bash: jsl: command not found\' \"=========\"","class":"lineCov","hits":"2","order":"710","possible_hits":"0",},
{"lineNum":"  402","line":"\ttest-13-expected","class":"lineCov","hits":"2","order":"711","possible_hits":"0",},
{"lineNum":"  403","line":"\techo \"============================\"","class":"lineCov","hits":"2","order":"714","possible_hits":"0",},
{"lineNum":"  404","line":"\t# ???: \'# $ check-html-java-script template2.js\\n\'=$(test-13-actual)"},
{"lineNum":"  405","line":"\t# ???: \'# | bash: jsl: command not found\'=$(test-13-expected)"},
{"lineNum":"  406","line":"\t[ \"$(test-13-actual)\" == \"$(test-13-expected)\" ]","class":"lineCov","hits":"8","order":"715","possible_hits":"0",},
{"lineNum":"  407","line":"}"},
{"lineNum":"  408","line":""},
{"lineNum":"  409","line":"function test-13-actual () {"},
{"lineNum":"  410","line":"\t# no-op in case content just a comment"},
{"lineNum":"  411","line":"\ttrue","class":"lineCov","hits":"4","order":"709","possible_hits":"0",},
{"lineNum":"  412","line":""},
{"lineNum":"  413","line":""},
{"lineNum":"  414","line":"}"},
{"lineNum":"  415","line":""},
{"lineNum":"  416","line":"function test-13-expected () {"},
{"lineNum":"  417","line":"\t# no-op in case content just a comment"},
{"lineNum":"  418","line":"\ttrue","class":"lineCov","hits":"4","order":"712","possible_hits":"0",},
{"lineNum":"  419","line":""},
{"lineNum":"  420","line":"\tcat <<END_EXPECTED","class":"lineCov","hits":"4","order":"713","possible_hits":"0",},
{"lineNum":"  421","line":"# | bash: jsl: command not found"},
{"lineNum":"  422","line":"END_EXPECTED"},
{"lineNum":"  423","line":"}"},
{"lineNum":"  424","line":""},
{"lineNum":"  425","line":"bats_test_function --tags \'\' test_test-2d1","class":"lineCov","hits":"14","order":"350","possible_hits":"0",},
{"lineNum":"  426","line":"bats_test_function --tags \'\' test_test-2d3","class":"lineCov","hits":"14","order":"351","possible_hits":"0",},
{"lineNum":"  427","line":"bats_test_function --tags \'\' test_test-2d4","class":"lineCov","hits":"14","order":"352","possible_hits":"0",},
{"lineNum":"  428","line":"bats_test_function --tags \'\' test_test-2d5","class":"lineCov","hits":"14","order":"353","possible_hits":"0",},
{"lineNum":"  429","line":"bats_test_function --tags \'\' test_test-2d6","class":"lineCov","hits":"14","order":"354","possible_hits":"0",},
{"lineNum":"  430","line":"bats_test_function --tags \'\' test_test-2d7","class":"lineCov","hits":"14","order":"355","possible_hits":"0",},
{"lineNum":"  431","line":"bats_test_function --tags \'\' test_test-2d8","class":"lineCov","hits":"14","order":"356","possible_hits":"0",},
{"lineNum":"  432","line":"bats_test_function --tags \'\' test_test-2d9","class":"lineCov","hits":"14","order":"357","possible_hits":"0",},
{"lineNum":"  433","line":"bats_test_function --tags \'\' test_test-2d10","class":"lineCov","hits":"14","order":"358","possible_hits":"0",},
{"lineNum":"  434","line":"bats_test_function --tags \'\' test_test-2d11","class":"lineCov","hits":"14","order":"359","possible_hits":"0",},
{"lineNum":"  435","line":"bats_test_function --tags \'\' test_test-2d12","class":"lineCov","hits":"14","order":"360","possible_hits":"0",},
{"lineNum":"  436","line":"bats_test_function --tags \'\' test_test-2d13","class":"lineCov","hits":"14","order":"361","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "bats", "date" : "2023-05-18 22:52:34", "instrumented" : 168, "covered" : 156,};
var merged_data = [];
