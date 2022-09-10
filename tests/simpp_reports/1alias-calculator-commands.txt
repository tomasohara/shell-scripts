#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/../:$PATH"

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

}


@test "test2" {
	test_folder=$(echo /tmp/test2-$$)
	mkdir $test_folder && cd $test_folder

	unalias -a
	alias | wc -l
	for f in $(typeset -f | egrep '^\w+'); do unset -f $f; done
	actual=$(test2-assert4-actual)
	expected=$(test2-assert4-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test2-assert4-actual () {
	typeset -f | egrep '^\w+' | wc -l
}
function test2-assert4-expected () {
	echo -e '00'
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
	echo -e '0'
}

@test "test4" {
	test_folder=$(echo /tmp/test4-$$)
	mkdir $test_folder && cd $test_folder

	temp_dir=$TMP/test-1210
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
	alias | wc -l
}
function test5-assert1-expected () {
	echo -e '1'
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
	typeset -f | egrep '^\w+' | wc -l
}
function test6-assert1-expected () {
	echo -e '0'
}

@test "test7" {
	test_folder=$(echo /tmp/test7-$$)
	mkdir $test_folder && cd $test_folder

	function perl-calc-init () { initexpr="$1"; shift; echo "$@" | perl perlcalc.perl -init="$initexpr" -; }
	alias calc='perl-calc'
	alias calc-prec6='perl-calc -precision=6'
	alias calc-init='perl-calc-init'
	function old-perl-calc () { perl -e "print $*;"; }
	function hex2dec { perl -e "printf '%d', 0x$1;" -e 'print "\n";'; }
	function dec2hex { perl -e "printf '%x', $1;" -e 'print "\n";'; }
	function bin2dec { perl -e "printf '%d', 0b$1;" -e 'print "\n";'; }
	function dec2bin { perl -e "printf '%b', $1;" -e 'print "\n";'; }
	alias hv='hexview.perl'
}


@test "test8" {
	test_folder=$(echo /tmp/test8-$$)
	mkdir $test_folder && cd $test_folder

	old-calc "24 / 4.0 - (35 / 7.0) * 5" # returns -19 as float
	linebr
	old-calc "(2^3)*(2^2)" # returns 32
	linebr
}


@test "test9" {
	test_folder=$(echo /tmp/test9-$$)
	mkdir $test_folder && cd $test_folder

	old-perl-calc "70 + 69 + 68"
	printf "\n"
	linebr
	old-perl-calc "8/8/8/8/8"
	printf "\n"
	actual=$(test9-assert6-actual)
	expected=$(test9-assert6-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test9-assert6-actual () {
	linebr
}
function test9-assert6-expected () {
	echo -e '207--------------------------------------------------------------------------------0.001953125--------------------------------------------------------------------------------'
}

@test "test10" {
	test_folder=$(echo /tmp/test10-$$)
	mkdir $test_folder && cd $test_folder

	linebr
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
	dec2hex "A12" 
}
function test11-assert1-expected () {
	echo -e '800'
}

@test "test12" {
	test_folder=$(echo /tmp/test12-$$)
	mkdir $test_folder && cd $test_folder

	bin2dec "11110011"
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
	bin2dec "0110" 
}
function test12-assert2-expected () {
	echo -e '243--------------------------------------------------------------------------------6'
}

@test "test13" {
	test_folder=$(echo /tmp/test13-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test13-assert1-actual)
	expected=$(test13-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test13-assert1-actual () {
	dec2bin "10"
}
function test13-assert1-expected () {
	echo -e '100010011000100111010'
}

@test "test14" {
	test_folder=$(echo /tmp/test14-$$)
	mkdir $test_folder && cd $test_folder

	pwd
	ps -l > testforhv.txt
}
