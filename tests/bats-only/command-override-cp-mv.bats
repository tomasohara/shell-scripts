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

	alias testuser="sed -r "s/"$USER"+/userxf333/g""
	alias testnum="sed -r "s/[0-9]/N/g""
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
	ls -l | awk '!($6="")' | testnum | testuser
	linebr
	ls -l ./mvtest_dir1 | awk '!($6="")' | testnum | testuser
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
	echo -e "removed './testdir1/.bashrc'removed directory './testdir1'--------------------------------------------------------------------------------renamed 'abc' -> './mvtest_dir1/abc'renamed 'def' -> './mvtest_dir1/def'renamed 'ghi' -> './mvtest_dir1/ghi'--------------------------------------------------------------------------------total N    drwxrwsr-x N userxf333 userxf333 NNNN  N NN:NN mvtest_dirN--------------------------------------------------------------------------------total N    -rw-rw-r-- N userxf333 userxf333 N  N NN:NN abc-rw-rw-r-- N userxf333 userxf333 N  N NN:NN def-rw-rw-r-- N userxf333 userxf333 N  N NN:NN ghi--------------------------------------------------------------------------------"
}

@test "test9" {
	test_folder=$(echo /tmp/test9-$$)
	mkdir $test_folder && cd $test_folder

	rm -rf ./*
	touch abc def ghi
	cp abc ./cptest_dir1
	copy def ./cptest_dir1
	copy-force ghi ./cptest_dir1
	ls -l | awk '!($6="")' | testnum | testuser
	linebr
	ls -l ./cptest_dir1 | awk '!($6="")' | testnum | testuser
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
	echo -e "removed './mvtest_dir1/abc'removed './mvtest_dir1/ghi'removed './mvtest_dir1/def'removed directory './mvtest_dir1'--------------------------------------------------------------------------------'abc' -> './cptest_dir1/abc''def' -> './cptest_dir1/def''ghi' -> './cptest_dir1/ghi'--------------------------------------------------------------------------------total N    -rw-rw-r-- N userxf333 userxf333 N  N NN:NN abcdrwxrwsr-x N userxf333 userxf333 NNNN  N NN:NN cptest_dirN-rw-rw-r-- N userxf333 userxf333 N  N NN:NN def-rw-rw-r-- N userxf333 userxf333 N  N NN:NN ghi--------------------------------------------------------------------------------total N    -rw-rw-r-- N userxf333 userxf333 N  N NN:NN abc-rw-rw-r-- N userxf333 userxf333 N  N NN:NN def-rw-rw-r-- N userxf333 userxf333 N  N NN:NN ghi--------------------------------------------------------------------------------"
}

@test "test10" {
	test_folder=$(echo /tmp/test10-$$)
	mkdir $test_folder && cd $test_folder

	rm -rf ./* > /dev/null
	touch abc def ghi
	mkdir TDIR1 TDIR2 TDIR3 TDIR4
	ls -l | awk '!($6="")' | testnum | testuser
	remove-dir "TDIR1"
	delete-dir "TDIR2"
	remove-dir-force TDIR3
	delete-dir-force TDIR4
	ls -l | awk '!($6="")' | testnum | testuser
}


@test "test11" {
	test_folder=$(echo /tmp/test11-$$)
	mkdir $test_folder && cd $test_folder

	copy-readonly | testuser
	rm -rf ./* > /dev/null
	mkdir testdir1
	linebr
	copy-readonly ~/.bashrc ./testdir1/ | awk '!($6="")' | testnum | testuser
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
	ls -l | awk '!($6="")' | testnum | testuser
}
function test12-assert1-expected () {
	echo -e 'total N    drwxrwsr-x N userxf333 userxf333 NNNN  N NN:NN testdirN'
}
