var data = {lines:[
{"lineNum":"    1","line":"#!/usr/bin/env bats"},
{"lineNum":"    2","line":""},
{"lineNum":"    3","line":""},
{"lineNum":"    4","line":"# Make executables ./tests/../ visible to PATH"},
{"lineNum":"    5","line":"PATH=\"/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH\"","class":"lineCov","hits":"5","order":"333","possible_hits":"0",},
{"lineNum":"    6","line":""},
{"lineNum":"    7","line":"# Enable aliases"},
{"lineNum":"    8","line":"shopt -s expand_aliases","class":"lineCov","hits":"5","order":"349","possible_hits":"0",},
{"lineNum":"    9","line":""},
{"lineNum":"   10","line":""},
{"lineNum":"   11","line":""},
{"lineNum":"   12","line":"test_test-2d1() { bats_test_begin \"test-1\";"},
{"lineNum":"   13","line":"\ttestfolder=\"/tmp/batspp-214619/test-1\"","class":"lineCov","hits":"2","order":"428","possible_hits":"0",},
{"lineNum":"   14","line":"\tmkdir --parents \"$testfolder\"","class":"lineCov","hits":"2","order":"429","possible_hits":"0",},
{"lineNum":"   15","line":"\tbuiltin cd \"$testfolder\" || echo Warning: Unable to \"cd $testfolder\"","class":"lineCov","hits":"2","order":"430","possible_hits":"0",},
{"lineNum":"   16","line":""},
{"lineNum":"   17","line":"\techo \"==========\" $\"bind \'set enable-bracketed-paste off\'\\n\" \"==========\"","class":"lineCov","hits":"2","order":"431","possible_hits":"0",},
{"lineNum":"   18","line":"\ttest-1-actual","class":"lineCov","hits":"2","order":"432","possible_hits":"0",},
{"lineNum":"   19","line":"\techo \"=========\" $\'$ echo \"BIND ON!\"\' \"=========\"","class":"lineCov","hits":"2","order":"435","possible_hits":"0",},
{"lineNum":"   20","line":"\ttest-1-expected","class":"lineCov","hits":"2","order":"436","possible_hits":"0",},
{"lineNum":"   21","line":"\techo \"============================\"","class":"lineCov","hits":"2","order":"439","possible_hits":"0",},
{"lineNum":"   22","line":"\t# ???: \"bind \'set enable-bracketed-paste off\'\\n\"=$(test-1-actual)"},
{"lineNum":"   23","line":"\t# ???: \'$ echo \"BIND ON!\"\'=$(test-1-expected)"},
{"lineNum":"   24","line":"\t[ \"$(test-1-actual)\" == \"$(test-1-expected)\" ]","class":"lineCov","hits":"8","order":"440","possible_hits":"0",},
{"lineNum":"   25","line":"}"},
{"lineNum":"   26","line":""},
{"lineNum":"   27","line":"function test-1-actual () {"},
{"lineNum":"   28","line":"\t# no-op in case content just a comment"},
{"lineNum":"   29","line":"\ttrue","class":"lineCov","hits":"4","order":"433","possible_hits":"0",},
{"lineNum":"   30","line":""},
{"lineNum":"   31","line":"\tbind \'set enable-bracketed-paste off\'","class":"lineCov","hits":"4","order":"434","possible_hits":"0",},
{"lineNum":"   32","line":""},
{"lineNum":"   33","line":"}"},
{"lineNum":"   34","line":""},
{"lineNum":"   35","line":"function test-1-expected () {"},
{"lineNum":"   36","line":"\t# no-op in case content just a comment"},
{"lineNum":"   37","line":"\ttrue","class":"lineCov","hits":"4","order":"437","possible_hits":"0",},
{"lineNum":"   38","line":""},
{"lineNum":"   39","line":"\tcat <<END_EXPECTED","class":"lineCov","hits":"4","order":"438","possible_hits":"0",},
{"lineNum":"   40","line":"$ echo \"BIND ON!\""},
{"lineNum":"   41","line":"END_EXPECTED"},
{"lineNum":"   42","line":"}"},
{"lineNum":"   43","line":""},
{"lineNum":"   44","line":""},
{"lineNum":"   45","line":"test_test-2d3() { bats_test_begin \"test-3\";"},
{"lineNum":"   46","line":"\ttestfolder=\"/tmp/batspp-214619/test-3\"","class":"lineCov","hits":"2","order":"563","possible_hits":"0",},
{"lineNum":"   47","line":"\tmkdir --parents \"$testfolder\"","class":"lineCov","hits":"2","order":"564","possible_hits":"0",},
{"lineNum":"   48","line":"\tbuiltin cd \"$testfolder\" || echo Warning: Unable to \"cd $testfolder\"","class":"lineCov","hits":"2","order":"565","possible_hits":"0",},
{"lineNum":"   49","line":""},
{"lineNum":"   50","line":"\techo \"==========\" $\'echo \"Hi Mom!\"\\n\' \"==========\"","class":"lineCov","hits":"2","order":"566","possible_hits":"0",},
{"lineNum":"   51","line":"\ttest-3-actual","class":"lineCov","hits":"2","order":"567","possible_hits":"0",},
{"lineNum":"   52","line":"\techo \"=========\" $\'Hi Mom!\' \"=========\"","class":"lineCov","hits":"2","order":"570","possible_hits":"0",},
{"lineNum":"   53","line":"\ttest-3-expected","class":"lineCov","hits":"2","order":"571","possible_hits":"0",},
{"lineNum":"   54","line":"\techo \"============================\"","class":"lineCov","hits":"2","order":"574","possible_hits":"0",},
{"lineNum":"   55","line":"\t# ???: \'echo \"Hi Mom!\"\\n\'=$(test-3-actual)"},
{"lineNum":"   56","line":"\t# ???: \'Hi Mom!\'=$(test-3-expected)"},
{"lineNum":"   57","line":"\t[ \"$(test-3-actual)\" == \"$(test-3-expected)\" ]","class":"lineCov","hits":"6","order":"575","possible_hits":"0",},
{"lineNum":"   58","line":"}"},
{"lineNum":"   59","line":""},
{"lineNum":"   60","line":"function test-3-actual () {"},
{"lineNum":"   61","line":"\t# no-op in case content just a comment"},
{"lineNum":"   62","line":"\ttrue","class":"lineCov","hits":"4","order":"568","possible_hits":"0",},
{"lineNum":"   63","line":""},
{"lineNum":"   64","line":"\techo \"Hi Mom!\"","class":"lineCov","hits":"4","order":"569","possible_hits":"0",},
{"lineNum":"   65","line":""},
{"lineNum":"   66","line":"}"},
{"lineNum":"   67","line":""},
{"lineNum":"   68","line":"function test-3-expected () {"},
{"lineNum":"   69","line":"\t# no-op in case content just a comment"},
{"lineNum":"   70","line":"\ttrue","class":"lineCov","hits":"4","order":"572","possible_hits":"0",},
{"lineNum":"   71","line":""},
{"lineNum":"   72","line":"\tcat <<END_EXPECTED","class":"lineCov","hits":"4","order":"573","possible_hits":"0",},
{"lineNum":"   73","line":"Hi Mom!"},
{"lineNum":"   74","line":"END_EXPECTED"},
{"lineNum":"   75","line":"}"},
{"lineNum":"   76","line":""},
{"lineNum":"   77","line":""},
{"lineNum":"   78","line":"test_test-2d4() { bats_test_begin \"test-4\";"},
{"lineNum":"   79","line":"\ttestfolder=\"/tmp/batspp-214619/test-4\"","class":"lineCov","hits":"2","order":"583","possible_hits":"0",},
{"lineNum":"   80","line":"\tmkdir --parents \"$testfolder\"","class":"lineCov","hits":"2","order":"584","possible_hits":"0",},
{"lineNum":"   81","line":"\tbuiltin cd \"$testfolder\" || echo Warning: Unable to \"cd $testfolder\"","class":"lineCov","hits":"2","order":"585","possible_hits":"0",},
{"lineNum":"   82","line":""},
{"lineNum":"   83","line":"\techo \"==========\" $\"echo \'Hello world\' | wc -l\\n\" \"==========\"","class":"lineCov","hits":"2","order":"586","possible_hits":"0",},
{"lineNum":"   84","line":"\ttest-4-actual","class":"lineCov","hits":"2","order":"587","possible_hits":"0",},
{"lineNum":"   85","line":"\techo \"=========\" $\'1\' \"=========\"","class":"lineCov","hits":"2","order":"590","possible_hits":"0",},
{"lineNum":"   86","line":"\ttest-4-expected","class":"lineCov","hits":"2","order":"591","possible_hits":"0",},
{"lineNum":"   87","line":"\techo \"============================\"","class":"lineCov","hits":"2","order":"594","possible_hits":"0",},
{"lineNum":"   88","line":"\t# ???: \"echo \'Hello world\' | wc -l\\n\"=$(test-4-actual)"},
{"lineNum":"   89","line":"\t# ???: \'1\'=$(test-4-expected)"},
{"lineNum":"   90","line":"\t[ \"$(test-4-actual)\" == \"$(test-4-expected)\" ]","class":"lineCov","hits":"6","order":"595","possible_hits":"0",},
{"lineNum":"   91","line":"}"},
{"lineNum":"   92","line":""},
{"lineNum":"   93","line":"function test-4-actual () {"},
{"lineNum":"   94","line":"\t# no-op in case content just a comment"},
{"lineNum":"   95","line":"\ttrue","class":"lineCov","hits":"4","order":"588","possible_hits":"0",},
{"lineNum":"   96","line":""},
{"lineNum":"   97","line":"\techo \'Hello world\' | wc -l","class":"lineCov","hits":"8","order":"589","possible_hits":"0",},
{"lineNum":"   98","line":""},
{"lineNum":"   99","line":"}"},
{"lineNum":"  100","line":""},
{"lineNum":"  101","line":"function test-4-expected () {"},
{"lineNum":"  102","line":"\t# no-op in case content just a comment"},
{"lineNum":"  103","line":"\ttrue","class":"lineCov","hits":"4","order":"592","possible_hits":"0",},
{"lineNum":"  104","line":""},
{"lineNum":"  105","line":"\tcat <<END_EXPECTED","class":"lineCov","hits":"4","order":"593","possible_hits":"0",},
{"lineNum":"  106","line":"1"},
{"lineNum":"  107","line":"END_EXPECTED"},
{"lineNum":"  108","line":"}"},
{"lineNum":"  109","line":""},
{"lineNum":"  110","line":"bats_test_function --tags \'\' test_test-2d1","class":"lineCov","hits":"5","order":"350","possible_hits":"0",},
{"lineNum":"  111","line":"bats_test_function --tags \'\' test_test-2d3","class":"lineCov","hits":"5","order":"351","possible_hits":"0",},
{"lineNum":"  112","line":"bats_test_function --tags \'\' test_test-2d4","class":"lineCov","hits":"5","order":"352","possible_hits":"0",},
]};
var percent_low = 25;var percent_high = 75;
var header = { "command" : "bats", "date" : "2023-06-15 21:56:13", "instrumented" : 44, "covered" : 44,};
var merged_data = [];
