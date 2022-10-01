#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

# Source files
shopt -s expand_aliases


@test "test0" {
	test_folder=$(echo /tmp/test0-$$)
	mkdir $test_folder && cd $test_folder

	bind 'set enable-bracketed-paste off'
}


@test "test1" {
	test_folder=$(echo /tmp/test1-$$)
	mkdir $test_folder && cd $test_folder

	unalias -a
	for f in $(typeset -f | egrep '^\w+'); do unset -f $f; done
	BIN_DIR=$PWD/..
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
	python3 $BIN_DIR/check_errors.py
}
function test2-assert1-expected () {
	echo -e 'usage: check_errors.py [-h] [--warning] [--warnings] [--skip_warnings][--no_asterisks] [--ruby] [--skip_ruby_lib] [--relaxed][--strict] [--verbose] [--context CONTEXT][filename]'
}

@test "test3" {
	test_folder=$(echo /tmp/test3-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test3-assert1-actual)
	expected=$(test3-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test3-assert1-actual () {
	pip3 install mezcla
}
function test3-assert1-expected () {
	echo -e 'Defaulting to user installation because normal site-packages is not writeableRequirement already satisfied: mezcla in /home/aveey/.local/lib/python3.10/site-packages (1.3.1)'
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
	python3 $BIN_DIR/check_errors.py
}
function test4-assert1-expected () {
	echo -e 'usage: check_errors.py [-h] [--warning] [--warnings] [--skip_warnings][--no_asterisks] [--ruby] [--skip_ruby_lib] [--relaxed][--strict] [--verbose] [--context CONTEXT][filename]'
}

@test "test5" {
	test_folder=$(echo /tmp/test5-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test6" {
	test_folder=$(echo /tmp/test6-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test6-assert1-actual)
	expected=$(test6-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test6-assert1-actual () {
	python3 $BIN_DIR/check_errors.py ./test_check_errors.py
}
function test6-assert1-expected () {
	echo -e 'Processing input'
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
	python3 $BIN_DIR/check_errors.py ./test_check_errors.py --verbose
}
function test7-assert1-expected () {
	echo -e 'Processing input'
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
	python3 $BIN_DIR/check_errors.py -h
}
function test8-assert1-expected () {
	echo -e 'usage: check_errors.py [-h] [--warning] [--warnings] [--skip_warnings][--no_asterisks] [--ruby] [--skip_ruby_lib] [--relaxed][--strict] [--verbose] [--context CONTEXT][filename]'
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
	python3 $BIN_DIR/check_errors.py ./test_extract_matches.py --verbose
}
function test9-assert1-expected () {
	echo -e 'Processing input'
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
	python3 $BIN_DIR/check_errors.py --warning ./test_extract_matches.py
}
function test10-assert1-expected () {
	echo -e 'Processing input'
}
