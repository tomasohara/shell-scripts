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
	TMP=/tmp/test-extensionless
	actual=$(test1-assert5-actual)
	expected=$(test1-assert5-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test1-assert5-actual () {
	BIN_DIR=$PWD/..
}
function test1-assert5-expected () {
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

	temp_dir=$TMP/test-3570
	mkdir -p "$temp_dir"
	cd "$temp_dir"
}


@test "test4" {
	test_folder=$(echo /tmp/test4-$$)
	mkdir $test_folder && cd $test_folder

	alias testnum="sed -r "s/[0-9,A-F,a-f]/X/g"" 
	alias testuser="sed -r "s/"$USER"+/user/g""
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

	pwd
	rm -rf ./*
}


@test "test7" {
	test_folder=$(echo /tmp/test7-$$)
	mkdir $test_folder && cd $test_folder

	source $BIN_DIR/tomohara-aliases.bash
}


@test "test8" {
	test_folder=$(echo /tmp/test8-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test8-assert1-actual)
	expected=$(test8-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test8-assert1-actual () {
	show-unicode-code-info-aux ./version1.txt | testnum 
}
function test8-assert1-expected () {
	echo -e 'XhXr\torX\toXXsXt\tXnXoXingX.XX.X-XX-gXnXriX: XXX\tXXXX\tX\tXX.\tXXXX\tX\tXXX\tXXXX\tX\tXXX\tXXXX\tX\tXX.\tXXXX\tX\tXXX\tXXXX\tX\tXX-\tXXXX\tX\tXXX\tXXXX\tX\tXXX\tXXXX\tX\tXX-\tXXXX\tX\tXXg\tXXXX\tXX\tXXX\tXXXX\tXX\tXXn\tXXXX\tXX\tXXX\tXXXX\tXX\tXXr\tXXXX\tXX\tXXi\tXXXX\tXX\tXXX\tXXXX\tXX\tXX'
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
	show-unicode-code-info ./version1.txt | testnum
}
function test9-assert1-expected () {
	echo -e 'XhXr\torX\toXXsXt\tXnXoXingX.XX.X-XX-gXnXriX: XXX\tXXXX\tX\tXX.\tXXXX\tX\tXXX\tXXXX\tX\tXXX\tXXXX\tX\tXX.\tXXXX\tX\tXXX\tXXXX\tX\tXX-\tXXXX\tX\tXXX\tXXXX\tX\tXXX\tXXXX\tX\tXX-\tXXXX\tX\tXXg\tXXXX\tXX\tXXX\tXXXX\tXX\tXXn\tXXXX\tXX\tXXX\tXXXX\tXX\tXXr\tXXXX\tXX\tXXi\tXXXX\tXX\tXXX\tXXXX\tXX\tXX'
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
	echo "END"
}
function test10-assert1-expected () {
	echo -e 'END'
}
