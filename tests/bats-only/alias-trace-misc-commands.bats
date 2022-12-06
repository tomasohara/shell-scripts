#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

# Source files
shopt -s expand_aliases


@test "test0" {
	test_folder=$(echo /tmp/test0-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test1" {
	test_folder=$(echo /tmp/test1-$$)
	mkdir $test_folder && cd $test_folder

	unalias -a
	alias | wc -l
	for f in $(typeset -f | egrep '^\w+'); do unset -f $f; done
	actual=$(test1-assert4-actual)
	expected=$(test1-assert4-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test1-assert4-actual () {
	typeset -f | egrep '^\w+' | wc -l
}
function test1-assert4-expected () {
	echo -e '00'
}

@test "test2" {
	test_folder=$(echo /tmp/test2-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test2-assert1-actual)
	expected=$(test2-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test2-assert1-actual () {
	alias | wc -l
}
function test2-assert1-expected () {
	echo -e '0'
}

@test "test3" {
	test_folder=$(echo /tmp/test3-$$)
	mkdir $test_folder && cd $test_folder

	temp_dir=$TMP/test-1210
	cd "$temp_dir"
}


@test "test4" {
	test_folder=$(echo /tmp/test4-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test4-assert1-actual)
	expected=$(test4-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test4-assert1-actual () {
	typeset -f | egrep '^\w+' | wc -l
}
function test4-assert1-expected () {
	echo -e '10'
}

@test "test5" {
	test_folder=$(echo /tmp/test5-$$)
	mkdir $test_folder && cd $test_folder

	alias testuser="sed -r "s/"$USER"+/user/g""
	alias testnum="sed -r "s/[0-9]/X/g"" 
	alias testnumhex="sed -r "s/[0-9,a-f,A-F]/X/g"" 
}


@test "test6" {
	test_folder=$(echo /tmp/test6-$$)
	mkdir $test_folder && cd $test_folder

	source $BIN_DIR/tomohara-aliases.bash
}


@test "test7" {
	test_folder=$(echo /tmp/test7-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test8" {
	test_folder=$(echo /tmp/test8-$$)
	mkdir $test_folder && cd $test_folder

	function asctime() { perl -e 'print (scalar localtime($1));'; echo ''; }
	actual=$(test8-assert2-actual)
	expected=$(test8-assert2-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test8-assert2-actual () {
	asctime | perl -pe 's/\d/N/g; s/\w+ \w+/DDD MMM/;'
}
function test8-assert2-expected () {
	echo -e 'DDD MMM  N NN:NN:NN NNNN'
}

@test "test9" {
	test_folder=$(echo /tmp/test9-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test9-assert1-actual)
	expected=$(test9-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test9-assert1-actual () {
	ps | filter-dirnames | testnum
}
function test9-assert1-expected () {
	echo -e 'PID TTY          TIME CMDXXXX pts/X    XX:XX:XX bashXXXX pts/X    XX:XX:XX psXXXX pts/X    XX:XX:XX bashXXXX pts/X    XX:XX:XX sedXXXX pts/X    XX:XX:XX perl'
}

@test "test10" {
	test_folder=$(echo /tmp/test10-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test10-assert1-actual)
	expected=$(test10-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test10-assert1-actual () {
	echo '99012342305324254' | comma-ize-number
}
function test10-assert1-expected () {
	echo -e '99,012,342,305,324,254'
}

@test "test11" {
	test_folder=$(echo /tmp/test11-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test11-assert1-actual)
	expected=$(test11-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test11-assert1-actual () {
	echo "8000000000" | apply-numeric-suffixes
}
function test11-assert1-expected () {
	echo -e '7.45G'
}

@test "test12" {
	test_folder=$(echo /tmp/test12-$$)
	mkdir $test_folder && cd $test_folder

	echo "8000000000" | apply-usage-numeric-suffixes
	actual=$(test12-assert2-actual)
	expected=$(test12-assert2-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test12-assert2-actual () {
	echo "8000000" | apply-usage-numeric-suffixes 
}
function test12-assert2-expected () {
	echo -e '7.45T7.63G'
}

@test "test13" {
	test_folder=$(echo /tmp/test13-$$)
	mkdir $test_folder && cd $test_folder

	byte-usage | testnum
	actual=$(test13-assert2-actual)
	expected=$(test13-assert2-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test13-assert2-actual () {
	usage-pp | testnum
}
function test13-assert2-expected () {
	echo -e "Backing up 'usage.bytes.list' to './backup/usage.bytes.list'XX.XM\t.X.XXM\t./backupXXK\t.XXK\t./backup"
}

@test "test14" {
	test_folder=$(echo /tmp/test14-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test14-assert1-actual)
	expected=$(test14-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test14-assert1-actual () {
	usage 
}
function test14-assert1-expected () {
	echo -e "renamed 'usage.list' -> 'usage.list.26Nov22'\x1b[?1h\x1b="
}

@test "test15" {
	test_folder=$(echo /tmp/test15-$$)
	mkdir $test_folder && cd $test_folder

	rm -rf ./* > /dev/null
	mkdir backup
	printf "THIS IS THE START\nTHIS IS A TEST\nTHIS IS A TEST\nTHIS IS A TEST\nTHIS IS A TEST\nTHIS IS A TEST\nTHIS IS THE END\n" > thisisatest.txt
	ps -aux > process.txt
	number-columns thisisatest.txt
	actual=$(test15-assert6-actual)
	expected=$(test15-assert6-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test15-assert6-actual () {
	number-columns-comma process.txt
}
function test15-assert6-expected () {
	echo -e '1: THIS IS THE START1: USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND'
}

@test "test16" {
	test_folder=$(echo /tmp/test16-$$)
	mkdir $test_folder && cd $test_folder

	alias reverse='tac'
	cat thisisatest.txt
	linebr
	actual=$(test16-assert4-actual)
	expected=$(test16-assert4-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test16-assert4-actual () {
	reverse thisisatest.txt
}
function test16-assert4-expected () {
	echo -e 'THIS IS THE STARTTHIS IS A TESTTHIS IS A TESTTHIS IS A TESTTHIS IS A TESTTHIS IS A TESTTHIS IS THE END--------------------------------------------------------------------------------THIS IS THE ENDTHIS IS A TESTTHIS IS A TESTTHIS IS A TESTTHIS IS A TESTTHIS IS A TESTTHIS IS THE START'
}

@test "test17" {
	test_folder=$(echo /tmp/test17-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test17-assert1-actual)
	expected=$(test17-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test17-assert1-actual () {
	backup-file thisisatest.txt
}
function test17-assert1-expected () {
	echo -e "Backing up 'thisisatest.txt' to './backup/thisisatest.txt'"
}

@test "test18" {
	test_folder=$(echo /tmp/test18-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test19" {
	test_folder=$(echo /tmp/test19-$$)
	mkdir $test_folder && cd $test_folder

	check-errors process.txt
	linebr
	check-all-errors process.txt
	linebr
	check-warnings
	linebr
	check-all-warnings
	linebr
}


@test "test20" {
	test_folder=$(echo /tmp/test20-$$)
	mkdir $test_folder && cd $test_folder

	diff_options="--ignore-space-change --ignore-blank-lines"
	alias diff='command diff $diff_options'
	alias diff-default='command diff'
	alias diff-ignore-spacing='diff --ignore-all-space'
	alias do-diff='do_diff.sh'
	function diff-rev () {
	local diff_program="diff"
	if [ "$1" = "--diff-prog" ]; then
	diff_program="$2"
	shift 2
	fi
	local right_file="$1"
	local left_file="$2"
	if [ -d "$left_file" ]; then left_file="$left_file"/$(basename "$right_file"); fi
	"$diff_program" "$left_file" "$right_file"
	}
	alias kdiff-rev='diff-rev --diff-prog kdiff'
	alias diff-log-output='compare-log-output.sh'
	alias vdiff-rev=kdiff-rev
}


@test "test21" {
	test_folder=$(echo /tmp/test21-$$)
	mkdir $test_folder && cd $test_folder

	ps -u > process1.txt
	ps -u > process2.txt
}


@test "test22" {
	test_folder=$(echo /tmp/test22-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test22-assert1-actual)
	expected=$(test22-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test22-assert1-actual () {
	diff process1.txt process2.txt | testuser | testnumhex
}
function test22-assert1-expected () {
	echo -e 'XXXXXXX< usXr       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss   XX:XX   X:XX /usr/Xin/XXsh< usXr       XXXX  X.X  X.X  XXXXX  XXXX pts/X    R+   XX:XX   X:XX ps -u---> usXr       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss   XX:XX   X:XX /usr/Xin/XXsh> usXr       XXXX  X.X  X.X  XXXXX  XXXX pts/X    R+   XX:XX   X:XX ps -u'
}

@test "test23" {
	test_folder=$(echo /tmp/test23-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test23-assert1-actual)
	expected=$(test23-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test23-assert1-actual () {
	diff-default process1.txt process2.txt | testuser | testnumhex
}
function test23-assert1-expected () {
	echo -e 'XXXXXXX< usXr       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss   XX:XX   X:XX /usr/Xin/XXsh< usXr       XXXX  X.X  X.X  XXXXX  XXXX pts/X    R+   XX:XX   X:XX ps -u---> usXr       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss   XX:XX   X:XX /usr/Xin/XXsh> usXr       XXXX  X.X  X.X  XXXXX  XXXX pts/X    R+   XX:XX   X:XX ps -u'
}

@test "test24" {
	test_folder=$(echo /tmp/test24-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test24-assert1-actual)
	expected=$(test24-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test24-assert1-actual () {
	diff-ignore-spacing process1.txt process2.txt | testuser | testnumhex
}
function test24-assert1-expected () {
	echo -e 'XXXXXXX< usXr       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss   XX:XX   X:XX /usr/Xin/XXsh< usXr       XXXX  X.X  X.X  XXXXX  XXXX pts/X    R+   XX:XX   X:XX ps -u---> usXr       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss   XX:XX   X:XX /usr/Xin/XXsh> usXr       XXXX  X.X  X.X  XXXXX  XXXX pts/X    R+   XX:XX   X:XX ps -u'
}

@test "test25" {
	test_folder=$(echo /tmp/test25-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test25-assert1-actual)
	expected=$(test25-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test25-assert1-actual () {
	do-diff process1.txt process2.txt | testuser | testnumhex
}
function test25-assert1-expected () {
	echo -e 'proXXssX.txt vs. proXXssX.txtXiXXXrXnXXs: proXXssX.txt proXXssX.txt-rw-rw-r-- X usXr usXr XXX Nov XX XX:XX proXXssX.txt-rw-rw-r-- X usXr usXr XXX Nov XX XX:XX proXXssX.txtXXXXXXX< usXr       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss   XX:XX   X:XX /usr/Xin/XXsh< usXr       XXXX  X.X  X.X  XXXXX  XXXX pts/X    R+   XX:XX   X:XX ps -u---> usXr       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss   XX:XX   X:XX /usr/Xin/XXsh> usXr       XXXX  X.X  X.X  XXXXX  XXXX pts/X    R+   XX:XX   X:XX ps -u------------------------------------------------------------------------'
}

@test "test26" {
	test_folder=$(echo /tmp/test26-$$)
	mkdir $test_folder && cd $test_folder

	printf "TESTFILE1\nNEXT LINE" > testtxt1.txt
	printf "TESTFILE2\nNEXT LINE2" > testtxt2.txt
}


@test "test27" {
	test_folder=$(echo /tmp/test27-$$)
	mkdir $test_folder && cd $test_folder

	diff-log-output ls-alR.list.log ls-R.list.log
}


@test "test28" {
	test_folder=$(echo /tmp/test28-$$)
	mkdir $test_folder && cd $test_folder

	rm -rf $HOME/info > /dev/null
	mkdir -p $HOME/info
	echo "THIS IS A NOICE SIGNATURE" > $HOME/info/.noice-signature
}


@test "test29" {
	test_folder=$(echo /tmp/test29-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test30" {
	test_folder=$(echo /tmp/test30-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test30-assert1-actual)
	expected=$(test30-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test30-assert1-actual () {
	dobackup process1.txt
}
function test30-assert1-expected () {
	echo -e "Backing up 'process1.txt' to './backup/process1.txt'"
}
