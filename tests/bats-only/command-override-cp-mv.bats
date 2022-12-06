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

	TMP=./tmp/test-cp-mv
	temp_dir=$TMP/test-1210
	cd "$temp_dir"
	pwd | testuser
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
	alias | wc -l
}
function test4-assert1-expected () {
	echo -e '3'
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
	echo -e '0'
}

@test "test6" {
	test_folder=$(echo /tmp/test6-$$)
	mkdir $test_folder && cd $test_folder

	source $BIN_DIR/tomohara-aliases.bash
}


@test "test7" {
	test_folder=$(echo /tmp/test7-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test7-assert1-actual)
	expected=$(test7-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test7-assert1-actual () {
	clear
}
function test7-assert1-expected () {
	echo -e 'use cls instead (or /bin/clear)'
}

@test "test8" {
	test_folder=$(echo /tmp/test8-$$)
	mkdir $test_folder && cd $test_folder

	rm -rf ./*
	touch abc def ghi
	mv abc ./mvtest_dir1
	move def ./mvtest_dir1
	move-force ghi ./mvtest_dir1
	ls -l | awk '!($6="")' | testuser | testnum
	linebr
	ls -l ./mvtest_dir1 | awk '!($6="")' | testuser | testnum
	actual=$(test8-assert9-actual)
	expected=$(test8-assert9-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test8-assert9-actual () {
	linebr
}
function test8-assert9-expected () {
	echo -e "removed './testdir1/.bashrc'removed directory './testdir1'--------------------------------------------------------------------------------renamed 'abc' -> './mvtest_dir1/abc'renamed 'def' -> './mvtest_dir1/def'renamed 'ghi' -> './mvtest_dir1/ghi'--------------------------------------------------------------------------------total X    drwxrwsr-x X user user XXXX  XX XX:XX mvtest_dirX--------------------------------------------------------------------------------total X    -rw-rw-r-- X user user X  XX XX:XX abc-rw-rw-r-- X user user X  XX XX:XX def-rw-rw-r-- X user user X  XX XX:XX ghi--------------------------------------------------------------------------------"
}

@test "test9" {
	test_folder=$(echo /tmp/test9-$$)
	mkdir $test_folder && cd $test_folder

	rm -rf ./*
	touch abc def ghi
	cp abc ./cptest_dir1
	copy def ./cptest_dir1
	copy-force ghi ./cptest_dir1
	ls -l | awk '!($6="")' | testuser | testnum
	linebr
	ls -l ./cptest_dir1 | awk '!($6="")' | testuser | testnum
	actual=$(test9-assert9-actual)
	expected=$(test9-assert9-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test9-assert9-actual () {
	linebr
}
function test9-assert9-expected () {
	echo -e "removed './mvtest_dir1/abc'removed './mvtest_dir1/ghi'removed './mvtest_dir1/def'removed directory './mvtest_dir1'--------------------------------------------------------------------------------'abc' -> './cptest_dir1/abc''def' -> './cptest_dir1/def''ghi' -> './cptest_dir1/ghi'--------------------------------------------------------------------------------total X    -rw-rw-r-- X user user X  XX XX:XX abcdrwxrwsr-x X user user XXXX  XX XX:XX cptest_dirX-rw-rw-r-- X user user X  XX XX:XX def-rw-rw-r-- X user user X  XX XX:XX ghi--------------------------------------------------------------------------------total X    -rw-rw-r-- X user user X  XX XX:XX abc-rw-rw-r-- X user user X  XX XX:XX def-rw-rw-r-- X user user X  XX XX:XX ghi--------------------------------------------------------------------------------"
}

@test "test10" {
	test_folder=$(echo /tmp/test10-$$)
	mkdir $test_folder && cd $test_folder

	rm -rf ./*
	touch abc def ghi
	mkdir TDIR1 TDIR2 TDIR3 TDIR4
	ls -l | awk '!($6="")' | testuser | testnum
	remove-dir "TDIR1"
	delete-dir "TDIR2"
	remove-dir-force TDIR3
	delete-dir-force TDIR4
	ls -l | awk '!($6="")' | testuser | testnum
	actual=$(test10-assert10-actual)
	expected=$(test10-assert10-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test10-assert10-actual () {
	linebr
}
function test10-assert10-expected () {
	echo -e "removed './abc'removed './cptest_dir1/abc'removed './cptest_dir1/ghi'removed './cptest_dir1/def'removed directory './cptest_dir1'removed './def'removed './ghi'--------------------------------------------------------------------------------total XX    -rw-rw-r-- X user user X  XX XX:XX abc-rw-rw-r-- X user user X  XX XX:XX def-rw-rw-r-- X user user X  XX XX:XX ghidrwxrwsr-x X user user XXXX  XX XX:XX TDIRXdrwxrwsr-x X user user XXXX  XX XX:XX TDIRXdrwxrwsr-x X user user XXXX  XX XX:XX TDIRXdrwxrwsr-x X user user XXXX  XX XX:XX TDIRX--------------------------------------------------------------------------------removed directory 'TDIR1'removed directory 'TDIR2'removed directory 'TDIR3'removed directory 'TDIR4'--------------------------------------------------------------------------------total X    -rw-rw-r-- X user user X  XX XX:XX abc-rw-rw-r-- X user user X  XX XX:XX def-rw-rw-r-- X user user X  XX XX:XX ghi--------------------------------------------------------------------------------"
}

@test "test11" {
	test_folder=$(echo /tmp/test11-$$)
	mkdir $test_folder && cd $test_folder

	copy-readonly | testuser
	rm -rf ./*
	mkdir testdir1
	linebr
	copy-readonly ~/.bashrc ./testdir1/ | awk '!($6="")' | testuser | testnum
	cat ./testdir1/.bashrc | head 
}


@test "test12" {
	test_folder=$(echo /tmp/test12-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test12-assert1-actual)
	expected=$(test12-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test12-assert1-actual () {
	ls -l | awk '!($6="")' | testuser | testnum
}
function test12-assert1-expected () {
	echo -e 'total X    drwxrwsr-x X user user XXXX  XX XX:XX testdirX'
}
