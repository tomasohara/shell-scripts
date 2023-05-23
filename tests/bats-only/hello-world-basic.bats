#!/usr/bin/env bats


# Make executables ./tests/../ visible to PATH
PATH="/home/aveey/tom-project/shell-scripts/tests/batspp-only/../:$PATH"

<<<<<<< HEAD
# Enable aliases
shopt -s expand_aliases



@test "test-1" {
	testfolder="/tmp/batspp-141664/test-1"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $"bind 'set enable-bracketed-paste off'\n" "=========="
	test-1-actual 
	echo "=========" $'$ echo "BIND ON!"' "========="
	test-1-expected 
	echo "============================"
	# ???: "bind 'set enable-bracketed-paste off'\n"=$(test-1-actual)
	# ???: '$ echo "BIND ON!"'=$(test-1-expected)
	[ "$(test-1-actual)" == "$(test-1-expected)" ]
}

function test-1-actual () {
	# no-op in case content just a comment
	true

	bind 'set enable-bracketed-paste off'

}

function test-1-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
$ echo "BIND ON!"
END_EXPECTED
}


@test "test-3" {
	testfolder="/tmp/batspp-141664/test-3"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $'echo "Hi Mom!"\n' "=========="
	test-3-actual 
	echo "=========" $'Hi Mom!' "========="
	test-3-expected 
	echo "============================"
	# ???: 'echo "Hi Mom!"\n'=$(test-3-actual)
	# ???: 'Hi Mom!'=$(test-3-expected)
	[ "$(test-3-actual)" == "$(test-3-expected)" ]
}

function test-3-actual () {
	# no-op in case content just a comment
	true

	echo "Hi Mom!"

}

function test-3-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
Hi Mom!
END_EXPECTED
}


@test "test-4" {
	testfolder="/tmp/batspp-141664/test-4"
	mkdir --parents "$testfolder"
	cd "$testfolder" || echo Warning: Unable to "cd $testfolder"

	echo "==========" $"echo 'Hello world' | wc -l\n" "=========="
	test-4-actual 
	echo "=========" $'1' "========="
	test-4-expected 
	echo "============================"
	# ???: "echo 'Hello world' | wc -l\n"=$(test-4-actual)
	# ???: '1'=$(test-4-expected)
	[ "$(test-4-actual)" == "$(test-4-expected)" ]
}

function test-4-actual () {
	# no-op in case content just a comment
	true

	echo 'Hello world' | wc -l

}

function test-4-expected () {
	# no-op in case content just a comment
	true

	cat <<END_EXPECTED
1
END_EXPECTED
=======
# Source files
shopt -s expand_aliases


@test "test0" {
	test_folder=$(echo /tmp/test0-$$)
	mkdir $test_folder && cd $test_folder

	bind 'set enable-bracketed-paste off'
	echo "BIND ON!"
}


@test "test1" {
	test_folder=$(echo /tmp/test1-$$)
	mkdir $test_folder && cd $test_folder

	actual=$(test1-assert1-actual)
	expected=$(test1-assert1-expected)
	echo "========== actual =========="
	echo "$actual" | hexview.perl
	echo "========= expected ========="
	echo "$expected" | hexview.perl
	echo "============================"
	[ "$actual" == "$expected" ]

}

function test1-assert1-actual () {
	echo "Hi Mom!"
}
function test1-assert1-expected () {
	echo -e 'Hi Mom!'
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
	echo 'Hello world' | wc -l
}
function test2-assert1-expected () {
	echo -e '1'
>>>>>>> integration-testing-3fa2c13
}
