#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

# Source files
shopt -s expand_aliases


@test "test0" {
	test_folder=$(echo /tmp/test0-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test0-assert1-actual)
	expected=$(test0-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test0-assert1-actual () {
	basename $PWD
}
function test0-assert1-expected () {
	echo -e 'tests'
}

@test "test1" {
	test_folder=$(echo /tmp/test1-$$)
	mkdir $test_folder && cd $test_folder

	/bin/rm -rf "/tmp/test-dir-15485863"
	test_dir="/tmp/test-dir-15485863"
	mkdir -p "$test_dir"
	command cd "$test_dir"
}


@test "test2" {
	test_folder=$(echo /tmp/test2-$$)
	mkdir $test_folder && cd $test_folder

}


@test "test3" {
	test_folder=$(echo /tmp/test3-$$)
	mkdir $test_folder && cd $test_folder

	dir=$(realpath "..")
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
	url-path ../template.html | perl -pe "s@$dir@/x/y/z@;"
}
function test3-assert2-expected () {
	echo -e 'file:////x/y/z/template.html'
}

@test "test4" {
	test_folder=$(echo /tmp/test4-$$)
	mkdir $test_folder && cd $test_folder

	umask ug=rwx,o=r
	mkdir abc def
	touch ghi jkl
	echo > mno
	dir | perl -pe "s/ (\d+) [\w ]{2,8}/ \1 username /; s/\w\w\w \d+ \d\d:\d\d/mon \1 hh:mm/;";
}
