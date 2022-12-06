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

	alias testuser="sed -r "s/"$USER"+/user/g""
	alias testnum="sed -r "s/[0-9]/X/g""
}


@test "test3" {
	test_folder=$(echo /tmp/test3-$$)
	mkdir $test_folder && cd $test_folder

	BIN_DIR=$PWD/..
	actual=$(test3-assert2-actual)
	expected=$(test3-assert2-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test3-assert2-actual () {
	alias | wc -l
}
function test3-assert2-expected () {
	echo -e '2'
}

@test "test4" {
	test_folder=$(echo /tmp/test4-$$)
	mkdir $test_folder && cd $test_folder

	temp_dir=$TMP/test-9890
	cd "$temp_dir"
}


@test "test5" {
	test_folder=$(echo /tmp/test5-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test5-assert1-actual)
	expected=$(test5-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test5-assert1-actual () {
	typeset -f | egrep '^\w+' | wc -l
}
function test5-assert1-expected () {
	echo -e '30'
}

@test "test6" {
	test_folder=$(echo /tmp/test6-$$)
	mkdir $test_folder && cd $test_folder

	source $BIN_DIR/tomohara-aliases.bash
}


@test "test7" {
	test_folder=$(echo /tmp/test7-$$)
	mkdir $test_folder && cd $test_folder

	rm -rf ./*
	free -m > freemem_mb.txt
	linebr
	linebr
	ls -l ./backup/ | testuser | testnum | awk '!($6="")'
	linebr
}


@test "test8" {
	test_folder=$(echo /tmp/test8-$$)
	mkdir $test_folder && cd $test_folder

	perl-slurp -v | testnum
}


@test "test9" {
	test_folder=$(echo /tmp/test9-$$)
	mkdir $test_folder && cd $test_folder

	function test-text () { printf "THIS IS A TEST. \rTHIS IS ALSO A TEST\r. THIS IS A TEST TOO."; }
	test-text
	printf "\n"
	linebr
	test-text | remove-cr
	printf "\n"
	linebr
}


@test "test10" {
	test_folder=$(echo /tmp/test10-$$)
	mkdir $test_folder && cd $test_folder

	ps -l > process_list.txt
	actual=$(test10-assert2-actual)
	expected=$(test10-assert2-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test10-assert2-actual () {
	remove-cr-and-backup process_list.txt
}
function test10-assert2-expected () {
	echo -e "Backing up 'process_list.txt' to './backup/process_list.txt'"
}

@test "test11" {
	test_folder=$(echo /tmp/test11-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test12" {
	test_folder=$(echo /tmp/test12-$$)
	mkdir $test_folder && cd $test_folder

	ps -u > ntest1.txt
	ps -l > ntest2.txt
	actual=$(test12-assert3-actual)
	expected=$(test12-assert3-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test12-assert3-actual () {
	intersection ntest1.txt ntest2.txt | testnum
}
function test12-assert3-expected () {
	echo -e 'PIDTTYTIMEbashbashXXXXpts/Xpts/Xps'
}

@test "test13" {
	test_folder=$(echo /tmp/test13-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test14" {
	test_folder=$(echo /tmp/test14-$$)
	mkdir $test_folder && cd $test_folder

	free -m > free1.txt
	free > free2.txt
	actual=$(test14-assert3-actual)
	expected=$(test14-assert3-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test14-assert3-actual () {
	line-intersection free1.txt free2.txt
}
function test14-assert3-expected () {
	echo -e 'total        used        free      shared  buff/cache   available'
}

@test "test15" {
	test_folder=$(echo /tmp/test15-$$)
	mkdir $test_folder && cd $test_folder

	line-difference free1.txt free2.txt | testnum
	linebr
	actual=$(test15-assert3-actual)
	expected=$(test15-assert3-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test15-assert3-actual () {
	line-difference free2.txt free1.txt | testnum
}
function test15-assert3-expected () {
	echo -e 'Mem:            XXXX        XXXX         XXX         XXX        XXXX         XXXSwap:           XXXX         XXX        XXXX--------------------------------------------------------------------------------Mem:         XXXXXXX     XXXXXXX      XXXXXX      XXXXXX     XXXXXXX      XXXXXXSwap:        XXXXXXX      XXXXXX     XXXXXXX'
}

@test "test16" {
	test_folder=$(echo /tmp/test16-$$)
	mkdir $test_folder && cd $test_folder

	cat ntest1.txt | testuser | testnum
	linebr
	actual=$(test16-assert3-actual)
	expected=$(test16-assert3-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test16-assert3-actual () {
	show-line 3 ntest1.txt | testuser | testnum
}
function test16-assert3-expected () {
	echo -e 'USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMANDuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss   XX:XX   X:XX bashuser       XXXX  X.X  X.X XXXXXX XXXXXX pts/X   Sl+  XX:XX   X:XX /usr/bin/pythuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX /usr/bin/bashuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX /usr/bin/bashuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX bashuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX /usr/bin/bashuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss   XX:XX   X:XX /usr/bin/bashuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    R+   XX:XX   X:XX ps -u--------------------------------------------------------------------------------user       XXXX  X.X  X.X XXXXXX XXXXXX pts/X   Sl+  XX:XX   X:XX /usr/bin/pyth'
}

@test "test17" {
	test_folder=$(echo /tmp/test17-$$)
	mkdir $test_folder && cd $test_folder

	last-n-with-header 4 ntest1.txt | testuser | testnum
	linebr
	actual=$(test17-assert3-actual)
	expected=$(test17-assert3-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test17-assert3-actual () {
	last-n-with-header 2 ntest2.txt | testuser | testnum
}
function test17-assert3-expected () {
	echo -e 'USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMANDuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX bashuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss+  XX:XX   X:XX /usr/bin/bashuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    Ss   XX:XX   X:XX /usr/bin/bashuser       XXXX  X.X  X.X  XXXXX  XXXX pts/X    R+   XX:XX   X:XX ps -u--------------------------------------------------------------------------------F S   UID     PID    PPID  C PRI  NI ADDR SZ WCHAN  TTY          TIME CMDX S  XXXX    XXXX    XXXX  X  XX   X -  XXXX do_wai pts/X    XX:XX:XX bashX R  XXXX    XXXX    XXXX  X  XX   X -  XXXX -      pts/X    XX:XX:XX ps'
}

@test "test18" {
	test_folder=$(echo /tmp/test18-$$)
	mkdir $test_folder && cd $test_folder

	rm -rf ./* > /dev/null
}
